import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { tableFromIPC } from '@uwdata/flechette';
import { db } from './db.js';
import { dataServer, queryHandler } from '../src/index.js';

describe('queryHandler', () => {
  it('rejects a request with no type', async () => {
    const errors = [];
    const res = { error: (err, code) => errors.push([err, code]) };
    await queryHandler(db)(res, JSON.stringify({ sql: 'SELECT 1' }));
    expect(errors[0][1]).toBe(400);
    expect(errors[0][0]).toMatchObject({ code: 'bad_request', reason: 'missing_field', field: 'type' });
  });
});

describe('HTTP GET', () => {
  let server;
  let uri;

  beforeAll(async () => {
    await db.exec('SELECT 1');
    server = dataServer(db, { port: 0 });
    await new Promise(resolve => server.once('listening', resolve));
    uri = `http://127.0.0.1:${server.address().port}/`;
  });

  afterAll(async () => {
    await new Promise((resolve, reject) => server.close(err => err ? reject(err) : resolve(undefined)));
  });

  it('returns Arrow from encoded flat parameters', async () => {
    const query = { type: 'arrow', sql: 'SELECT \'a & b "c"\' AS value' };
    const params = new URLSearchParams(query);
    const res = await fetch(`${uri}?${params}`);
    expect(res.status).toBe(200);
    expect(res.headers.get('Content-Type')).toBe('application/vnd.apache.arrow.stream');
    const table = tableFromIPC(new Uint8Array(await res.arrayBuffer()));
    expect(table.getChild('value').at(0)).toBe('a & b "c"');
  });
  it('rejects a JSON-wrapped query parameter', async () => {
    const params = new URLSearchParams({ query: JSON.stringify({ type: 'arrow', sql: 'SELECT 1' }) });
    const res = await fetch(`${uri}?${params}`);
    expect(res.status).toBe(400);
    expect(await res.json()).toMatchObject({ code: 'bad_request', reason: 'missing_field', field: 'type' });
  });

  it('accepts large numbers in application fields', async () => {
    const res = await fetch(uri, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: '{"type":"arrow","sql":"SELECT 1 AS x","application":{"number":1e400}}'
    });
    expect(res.status).toBe(200);
    expect(tableFromIPC(new Uint8Array(await res.arrayBuffer())).getChild('x').at(0)).toBe(1);
  });

});
