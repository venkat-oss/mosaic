import { readFileSync } from 'node:fs';
import http from 'node:http';
import http2 from 'node:http2';
import { findCertificates } from './https.js';
import { ProtocolError, request, validateSQL, preaggregate, errorResponse } from './protocol.js';

export function dataServer(db, {
  rest = true,
  port = 3000
} = {}) {
  const handleQuery = queryHandler(db);
  const certificates = findCertificates();
  const secure = !!certificates;
  const app = createHTTPServer(handleQuery, rest, certificates);

  const server = app.listen(port, () => {
    const address = server.address();
    const boundPort = address && typeof address === 'object' ? address.port : port;
    console.log(`Data server running on port ${boundPort}`);
    if (secure) console.log(`  TLS certificate: ${certificates.cert}`);
    if (rest) console.log(`  http${secure ? 's' : ''}://localhost:${boundPort}/`);
  });
  return server;
}

function createHTTPServer(handleQuery, rest, certificates) {
  const app = certificates
    ? http2.createSecureServer({
        cert: readFileSync(certificates.cert),
        key: readFileSync(certificates.key),
        allowHTTP1: true,
        settings: { maxHeaderListSize: 2 * 1024 * 1024 }
      })
    : http.createServer({ maxHeaderSize: 2 * 1024 * 1024 });
  return app.on('request', (req, resp) => {
    const res = httpResponse(resp);
    if (!rest) {
      res.done();
      return;
    }

    resp.setHeader('Cache-Control', 'no-store');
    resp.setHeader('Access-Control-Allow-Origin', '*');
    resp.setHeader('Access-Control-Request-Method', '*');
    resp.setHeader('Access-Control-Allow-Methods', 'OPTIONS, POST, GET');
    resp.setHeader('Access-Control-Allow-Headers', req.headers['access-control-request-headers'] ?? 'Content-Type');
    resp.setHeader('Access-Control-Max-Age', 2592000);

    switch (req.method) {
      case 'OPTIONS':
        res.done();
        break;
      case 'GET': {
        const params = new URL(req.url, 'http://localhost').searchParams;
        handleQuery(res, JSON.stringify(Object.fromEntries(params)), true);
        break;
      }
      case 'POST': {
        const mediaType = String(req.headers['content-type'] ?? '').split(';', 1)[0].trim().toLowerCase();
        if (mediaType !== 'application/json') {
          res.error(new ProtocolError('Content-Type must be application/json', 'unsupported_media_type', undefined, 415));
          req.resume();
          break;
        }
        const chunks = [];
        let size = 0;
        let rejected = false;
        req.on('error', err => res.error(err));
        req.on('data', chunk => {
          size += chunk.length;
          if (rejected) return;
          if (size > 16 * 1024 * 1024) {
            rejected = true;
            chunks.length = 0;
            res.error(new ProtocolError('Request body exceeds 16 MiB', 'payload_too_large', undefined, 413));
          } else chunks.push(chunk);
        });
        req.on('end', () => { if (!rejected) handleQuery(res, Buffer.concat(chunks)); });
        break;
      }
      default:
        resp.setHeader('Allow', 'GET, POST, OPTIONS');
        res.error(new ProtocolError(`Unsupported HTTP method: ${req.method}`, 'method_not_allowed', undefined, 405));
    }
  });
}

export function queryHandler(db) {
  const tables = new Map();
  let pending = Promise.resolve();
  const handle = async (res, data, get) => {
    try {
      let value;
      try {
        value = JSON.parse(data);
      } catch {
        throw new ProtocolError('Malformed JSON', 'malformed_json');
      }
      const { sql, type } = request(value, get);
      if (type !== 'exec') await validateSQL(db, sql, get || type === 'preagg');
      switch (type) {
        case 'exec':
          await db.exec(sql);
          res.done();
          break;
        case 'arrow': {
          let buffer;
          if (get) {
            await db.exec('BEGIN TRANSACTION READ ONLY');
            try {
              buffer = await db.arrowBuffer(sql);
            } finally {
              await db.exec('ROLLBACK');
            }
          } else buffer = await db.arrowBuffer(sql);
          res.arrow(buffer);
          break;
        }
        case 'preagg':
          res.json(await preaggregate(db, sql, tables));
          break;
      }
    } catch (err) {
      const [status, body] = errorResponse(err, tables);
      res.error(body, status);
    }
  };
  return (res, data, get = false) => {
    const task = pending.then(() => handle(res, data, get));
    pending = task.catch(() => {});
    return task;
  };
}

function httpResponse(res) {
  return {
    arrow(data) {
      res.setHeader('Content-Type', 'application/vnd.apache.arrow.stream');
      for (const chunk of data) res.write(chunk);
      res.end();
    },
    json(data) {
      res.setHeader('Content-Type', 'application/json');
      res.end(JSON.stringify(data));
    },
    done() {
      res.writeHead(200);
      res.end();
    },
    error(err, code) {
      if (res.writableEnded) return;
      const [status, body] = code ? [code, err] : errorResponse(err, new Map());
      res.writeHead(status, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(body));
    }
  }
}
