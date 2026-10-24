import { createHash } from 'node:crypto';

const READ_ONLY_PLAN = `WITH plan AS (SELECT system.main.json_serialize_plan(?) AS tree)
SELECT system.main.json_extract_string(tree, '$.error')::BOOLEAN AS unsupported,
EXISTS (SELECT 1 FROM system.main.json_tree(tree) WHERE
system.main.json_extract_string(value, '$.expression_class') = 'BOUND_FUNCTION'
AND system.main.json_extract_string(value, '$.qname.path[0]') = 'system'
AND system.main.json_extract_string(value, '$.qname.path[#-1]') IN ('nextval', 'setval', 'setseed', 'write_log')) AS writes
FROM plan`;

export class ProtocolError extends Error {
  constructor(message, reason, field, status = 400) {
    super(message);
    this.code = 'bad_request';
    this.reason = reason;
    this.field = field;
    this.status = status;
  }
}

export function request(value, get = false) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    throw new ProtocolError('Expected a JSON object', 'malformed_json');
  }
  for (const field of ['type', 'sql']) {
    if (!Object.hasOwn(value, field)) {
      throw new ProtocolError(`Missing required field: ${field}`, 'missing_field', field);
    }
    if (typeof value[field] !== 'string' || !value[field].trim()) {
      throw new ProtocolError(`Invalid field: ${field}`, 'invalid_field', field);
    }
  }
  if (!['arrow', 'exec', 'preagg'].includes(value.type) || (get && value.type !== 'arrow')) {
    throw new ProtocolError('Invalid command type', 'invalid_field', 'type');
  }
  return value;
}

export async function validateSQL(db, sql, readOnly) {
  await db._init;
  const statements = await db.con.extractStatements(sql);
  if (statements.count !== 1) {
    throw new ProtocolError('Expected exactly one SQL statement', 'multiple_statements');
  }
  if (!readOnly) return;
  const stmt = await db.prepare('SELECT system.main.json_serialize_sql(?) AS parsed');
  let parsed;
  try {
    parsed = (await stmt.query([sql]))[0].parsed;
    if (typeof parsed === 'string') parsed = JSON.parse(parsed);
  } finally {
    stmt.finalize();
  }
  if (parsed.error) {
    throw new ProtocolError('Expected a read-only SELECT statement', 'not_read_only');
  }
  await db.exec('BEGIN TRANSACTION READ ONLY');
  try {
    await db.exec(`EXPLAIN ${sql}`);
  } catch (err) {
    if (/^TransactionContext Error:.*read.only mode/i.test(err.message)) {
      throw new ProtocolError('Expected a read-only SELECT statement', 'not_read_only');
    }
    throw err;
  } finally {
    await db.exec('ROLLBACK');
  }
  const bound = await db.prepare(READ_ONLY_PLAN);
  try {
    const [{ unsupported, writes }] = await bound.query([sql]);
    if (unsupported) throw new ProtocolError('Cannot inspect this statement', 'unsupported_statement');
    if (writes) throw new ProtocolError('Expected a read-only SELECT statement', 'not_read_only');
  } finally {
    bound.finalize();
  }
}

export async function preaggregate(db, sql, tables) {
  const table = 'preagg_' + createHash('sha256').update(sql).digest('hex').slice(0, 32);
  const exists = await db.query(`SELECT system.main.count(*) AS n FROM system.information_schema.tables WHERE table_schema = 'mosaic' AND table_name = '${table}'`);
  if (tables.has(table) && Number(exists[0].n) > 0) return tables.get(table);
  await db.exec('CREATE SCHEMA IF NOT EXISTS mosaic');
  await db.exec(`CREATE OR REPLACE TABLE mosaic.${table} AS ${sql}`);
  const [{ catalog }] = await db.query('SELECT system.main.current_database() AS catalog');
  const result = {
    reference: { catalog, schema: ['mosaic'], table },
    createdAt: new Date().toISOString()
  };
  tables.set(table, result);
  return result;
}

export function errorResponse(err, tables) {
  const message = String(err?.message ?? err);
  if (err instanceof ProtocolError) {
    return [err.status, { error: message, code: err.code, reason: err.reason, ...(err.field ? { field: err.field } : {}) }];
  }
  for (const [name, result] of tables) {
    if (message.startsWith(`Catalog Error: Table with name ${name} does not exist`)) {
      return [404, { error: message, code: 'table_not_found', reason: 'materialization_missing', reference: result.reference }];
    }
  }
  if (/^(?:Failed to extract statements: )?Parser Error:/i.test(message)) {
    return [400, { error: message, code: 'bad_request', reason: 'sql_parse_error' }];
  }
  if (/^TransactionContext Error:.*read.only mode/i.test(message)) {
    return [400, { error: message, code: 'bad_request', reason: 'not_read_only' }];
  }
  if (/^(?:Failed to extract statements: )?Out of Memory Error/i.test(message)) {
    return [429, { error: message, code: 'resource_exhausted', reason: 'resource_limit_exceeded' }];
  }
  return [500, { error: message, code: 'internal_error', reason: 'execution_failed' }];
}
