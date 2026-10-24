import { DuckDBInstance } from '@duckdb/node-api';
import { randomUUID } from 'node:crypto';
import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

/** @import { DuckDBConnection, DuckDBPreparedStatement, DuckDBValue, Json } from '@duckdb/node-api' */

const TEMP_DIR = '.duckdb';

const DEFAULT_INIT_STATEMENTS = [
  `PRAGMA temp_directory='${TEMP_DIR}'`,
  'INSTALL nanoarrow FROM community',
  'INSTALL httpfs',
  'LOAD nanoarrow',
  'LOAD httpfs'
].join(';\n');

export class DuckDB {
  /** @type {Promise<void>} */
  _init;
  /** @type {DuckDBInstance | undefined} */
  db;
  /** @type {DuckDBConnection | undefined} */
  con;

  /**
   * @param {string} path
   * @param {Record<string, string>} config
   * @param {string} initStatements
   */
  constructor(
    path = ':memory:',
    config = {},
    initStatements = DEFAULT_INIT_STATEMENTS
  ) {
    this._init = this._initialize(path, config, initStatements);
  }

  /**
   * @param {string} path
   * @param {Record<string, string>} config
   * @param {string} initStatements
   */
  async _initialize(path, config, initStatements) {
    this.db = await DuckDBInstance.create(path, config);
    this.con = await this.db.connect();
    await this.con.run(initStatements);
  }

  close() {
    this.con?.closeSync();
    this.db?.closeSync();
  }

  /**
   * @param {string} sql
   * @returns {Promise<DuckDBStatement>}
   */
  async prepare(sql) {
    await this._init;
    const stmt = await this.con.prepare(sql);
    return new DuckDBStatement(stmt);
  }

  /**
   * @param {string | { toString(): string }} sql
   * @returns {Promise<this>}
   */
  async exec(sql) {
    await this._init;
    await this.con.run(String(sql));
    return this;
  }

  /**
   * @param {string} sql
   * @returns {Promise<Record<string, Json>[]>}
   */
  async query(sql) {
    await this._init;
    const reader = await this.con.runAndReadAll(sql);
    return reader.getRowObjectsJson();
  }

  /**
   * @param {string} sql
   * @returns {Promise<Uint8Array[]>}
   */
  async arrowBuffer(sql) {
    await this._init;
    const result = await this.con.run(sql);
    const names = result.columnNames();
    const name = '_mosaic_arrow_' + randomUUID().replaceAll('-', '');
    const table = `temp.main."${name}"`;
    const columns = names.map((_, i) => `"c${i}" ${result.columnType(i)}`);
    const restoreNames = names.some(name => !name) || new Set(names.map(name => name.toLowerCase())).size !== names.length;
    const projection = names.map((name, i) => `"c${i}" AS "${(name || 'c' + i).replaceAll('"', '""')}"`);
    const directory = await mkdtemp(join(tmpdir(), 'mosaic-arrow-'));
    const path = join(directory, 'result.arrows').replaceAll("'", "''");
    try {
      await this.con.run(`CREATE TEMP TABLE ${table} (${columns.join(', ')})`);
      const appender = await this.con.createAppender(name, 'main', 'temp');
      try {
        for (let i = 0; i < result.chunkCount; ++i) appender.appendDataChunk(result.getChunk(i));
      } finally {
        appender.closeSync();
      }
      await this.con.run(`COPY (SELECT ${projection.join(', ')} FROM ${table}) TO '${path}' (FORMAT ARROWS)`);
      const bytes = await readFile(join(directory, 'result.arrows'));
      if (!restoreNames) return [bytes];
      // DuckDB COPY deduplicates column aliases; restore the original result names.
      const { tableFromIPC, tableToIPC } = await import('@uwdata/flechette');
      const decoded = tableFromIPC(bytes);
      return [/** @type {Uint8Array} */ (tableToIPC(decoded.selectAt(names.map((_, i) => i), names), { format: 'stream' }))];
    } finally {
      await this.con.run(`DROP TABLE IF EXISTS ${table}`).catch(() => {});
      await rm(directory, { recursive: true, force: true });
    }
  }

}

export class DuckDBStatement {
  /** @type {DuckDBPreparedStatement} */
  statement;

  /** @param {DuckDBPreparedStatement} statement */
  constructor(statement) {
    this.statement = statement;
  }

  finalize() {
    this.statement.destroySync();
  }

  /** @param {DuckDBValue[]} [params] */
  async run(params) {
    if (params?.length) this.statement.bind(params);
    await this.statement.run();
  }

  /**
   * @param {DuckDBValue[]} [params]
   * @returns {Promise<this>}
   */
  async exec(params) {
    if (params?.length) this.statement.bind(params);
    await this.statement.run();
    return this;
  }

  /**
   * @param {DuckDBValue[]} [params]
   * @returns {Promise<Record<string, Json>[]>}
   */
  async query(params) {
    if (params?.length) this.statement.bind(params);
    const reader = await this.statement.runAndReadAll();
    return reader.getRowObjectsJson();
  }
}
