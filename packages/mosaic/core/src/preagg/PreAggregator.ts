import * as sql from '@uwdata/mosaic-sql';
import type { ParamLike, ParamReader, ScaleOptions, SqlExpression } from '@uwdata/mosaic-sql';
import type { SqlContext } from '../sql-context.js';
import { Priority } from '../QueryManager.js';
import { columnPath, type TableRef } from './lineage.js';
import type { BinMethod, ClauseSource, IntervalMetadata, SelectionClause } from '../clause/index.js';
import type { Coordinator } from '../Coordinator.js';
import type { MosaicClient } from '../MosaicClient.js';
import type { Selection } from '../Selection.js';
import { fnv_hash } from '../util/hash.js';
import { QueryError } from '../util/query-error.js';
import { indexable, preaggColumns, type PreAggColumnsResult } from './preagg-columns.js';
import { subqueryPushdown } from './subquery-pushdown.js';

/**
 * Dummy preaggregate info object that indicates a view should be skipped
 * (not filtered) as it is a source of a cross-filtering operation.
 */
const Skip = Object.freeze({ skip: true });

export interface PreAggregateOptions {
  /** Database schema (namespace) in which to write pre-aggregated materialized views (default 'mosaic'). */
  schema?: string;
  /** Flag to enable or disable the pre-aggregation. This flag can be updated later via the `enabled` property. */
  enabled?: boolean;
}

interface ActiveColumnsResult {
  source: ClauseSource | null;
  columns?: Record<string, SqlExpression>;
  predicate?: (clause: SelectionClause) => SqlExpression[];
}

/**
 * Build and query optimized pre-aggregated materaialized views, for fast
 * computation of groupby aggregate queries over compatible client queries
 * and selections. The materialized views contains pre-aggregated data for a
 * Mosaic client, subdivided by possible query values from an active selection
 * clause. These materialized views are database tables that can be queried
 * for rapid updates.
 *
 * Compatible client queries must consist of only groupby dimensions and
 * supported aggregate functions. Compatible selections must contain an active
 * clause that exposes metadata for an interval or point value predicate.
 *
 * Materialized views are written to a dedicated schema (namespace) that
 * can be set using the *schema* constructor option. This schema acts as a
 * persistent cache, and materialized view tables may be used across sessions.
 * The `dropSchema` method issues a query to remove *all* tables within this
 * schema. This may be needed if the original tables have updated data, but
 * should be used with care.
 */
export class PreAggregator {
  public entries: Map<MosaicClient, PreAggregateInfo | typeof Skip | null>;
  private active: ActiveColumnsResult | null;
  private activeKey: string | null;
  private mc: Coordinator;
  private _schema: string;
  private _enabled: boolean | undefined;

  /**
   * Create a new manager of materialized views of pre-aggregated data.
   * @param coordinator A Mosaic coordinator.
   * @param options Pre-aggregation options.
   */
  constructor(coordinator: Coordinator, {
    schema = 'mosaic',
    enabled
  }: PreAggregateOptions = {}) {
    this.entries = new Map();
    this.active = null;
    this.activeKey = null;
    this.mc = coordinator;
    this._schema = schema;
    if (enabled && coordinator.sqlContext.execution.targetDialect !== sql.Dialect.DuckDB) {
      throw new TypeError('Preaggregation is not supported for this database backend.');
    }
    this._enabled = enabled;
  }

  /**
   * Set the enabled state of this manager. If false, any local state is
   * cleared and subsequent request calls will return null until re-enabled.
   * This method has no effect on any pre-aggregated tables already in the
   * database.
   * @param state The enabled state to set.
   */
  set enabled(state: boolean) {
    if (state && this.mc.sqlContext.execution.targetDialect !== sql.Dialect.DuckDB) {
      throw new TypeError('Preaggregation is not supported for this database backend.');
    }
    if (this.enabled !== state && !state) this.clear();
    this._enabled = state;
  }

  /**
   * Get the enabled state of this manager.
   * @returns The current enabled state.
   */
  get enabled(): boolean {
    return (this._enabled ?? true) && this.mc.sqlContext.execution.targetDialect === sql.Dialect.DuckDB;
  }

  /**
   * Set the database schema used for pre-aggregated materialized view tables.
   * Upon changes, any local state is cleared. This method does _not_ drop any
   * existing materialized views, use `dropSchema` before changing the schema
   * to also remove existing materalized views in the database.
   * @param schema The schema name to set.
   */
  set schema(schema: string) {
    if (this._schema !== schema) {
      this.clear();
      this._schema = schema;
    }
  }

  /**
   * Get the database schema used for pre-aggregated materialized view tables.
   * @returns The current schema name.
   */
  get schema(): string {
    return this._schema;
  }

  /**
   * Issues a query through the coordinator to drop the current schema for
   * pre-aggregated materialized views. *All* materialized view tables in the
   * schema will be removed and local state is cleared. Call this method if
   * the underlying base tables have been updated, causing materialized view
   * to become stale and inaccurate. Use this method with care! Once dropped,
   * the schema will be repopulated by future pre-aggregation requests.
   * @returns A query result promise.
   */
  dropSchema(): Promise<unknown> {
    this.clear();
    return this.mc.exec(sql.dropSchema(this.schema, { ifExists: true, cascade: true }));
  }

  /**
   * Clear the cache of pre-aggregation entries for the current active
   * selection clause. This method does _not_ drop any existing materialized
   * views. Use `dropSchema` to remove existing materialized view tables from
   * the database.
   */
  clear(): void {
    this.entries.clear();
    this.active = null;
    this.activeKey = null;
  }

  /**
   * Return pre-aggregation information for the active state of a
   * client-selection pair, or null if the client has unstable filters.
   * This method has multiple possible side effects, including materialized
   * view creation and updating internal caches.
   * @param client A Mosaic client.
   * @param selection A Mosaic selection to filter the client by.
   * @param activeClause A representative active selection
   *  clause for which to generate materialized views of pre-aggregates.
   * @returns Information and query generator
   * for pre-aggregated tables, or null if the client has unstable filters.
   */
  request(client: MosaicClient, selection: Selection, activeClause: SelectionClause | null): PreAggregateInfo | typeof Skip | null {
    if (!this.enabled || !activeClause?.source) return null;
    const { entries, mc, schema } = this;
    const context = mc.sqlContext;
    const execution = context.execution;
    try {
      const active = activeColumns(activeClause);
      const key = JSON.stringify([
        execution.generation, activeClause.meta?.type,
        activeClause.fields.map(field => context.structuralKey(field)),
        Object.entries(active.columns ?? {}).map(([name, expression]) => [name, context.structuralKey(expression)])
      ]);
      if (this.active && (this.active.source !== activeClause.source || key !== this.activeKey)) this.clear();
      if (this.active?.source === null) return null;
      if (!this.active) {
        if (!activeClause.predicate) return null;
        this.active = active;
        this.activeKey = key;
        if (!active.source) return null;
      }
      if (entries.has(client)) return entries.get(client)!;
      let info: PreAggregateInfo | typeof Skip | null = null;
      const columns = preaggColumns(client, expression => context.structuralKey(expression));
      if (columns) {
        if (selection.skip(client, activeClause)) info = Skip;
        else {
          const inactive = selection.remove(activeClause.source).predicate(client);
          const query = client.query(inactive);
          if (sql.isSelectQuery(query)) {
            info = preaggregateInfo(query, activeClause, columns, context, clause => {
              const fallback = client.query([inactive ?? [], clause.predicate ?? []].flat());
              if (!sql.isQuery(fallback) || !sql.isResultQuery(fallback)) {
                throw new TypeError('Preaggregation fallback requires a result query.');
              }
              return fallback;
            }, plan => {
              if (entries.get(client) === plan) entries.delete(client);
            });
          }
        }
      }
      if (info && !info.skip) {
        const plan = info;
        plan.result = mc.manager.request({ type: 'exec', query: plan.create }, Priority.Normal, () => plan.prepare(schema));
        plan.result.catch((error: unknown) => {
          mc.logger().error(error instanceof QueryError ? error : new QueryError(error, plan.create));
          plan.result = null;
        });
      }
      if (context.execution !== execution) return null;
      entries.set(client, info);
      return info;
    } catch {
      if (context.execution === execution) entries.set(client, null);
      return null;
    }
  }
}

function activeColumns(clause: SelectionClause): ActiveColumnsResult {
  const { fields, meta, source } = clause;
  if (!meta || !fields.length || fields.some(field => !indexable(field) || sql.params(field).length)) {
    return { source: null };
  }
  const columns: Record<string, SqlExpression> = {};
  if (meta.type === 'point') {
    fields.forEach((field, index) => { columns[`active${index}`] = field; });
    return {
      source, columns,
      predicate(current = clause) {
        if (!current.predicate) return [];
        const memo = new Map<object, unknown>();
        const fields = current.fields.map(field => sql.deepClone(field, memo));
        const predicate = sql.deepClone(current.predicate, memo);
        const replacements = new Map(fields.map((field, index) => [field, sql.column(`active${index}`)]));
        return [sql.rewrite(predicate, replacements)];
      }
    };
  }
  if (meta.type !== 'interval') return { source: null };
  const { scales, bin, pixelSize = 1 } = meta as IntervalMetadata;
  const bins = scales?.map(scale => binInterval(scale, pixelSize, bin));
  if (!bins || bins.length !== fields.length || bins.some(bin => !bin)) return { source: null };
  const transforms = bins.filter((bin): bin is NonNullable<typeof bin> => !!bin);
  fields.forEach((field, index) => { columns[`active${index}`] = transforms[index](field); });
  return {
    source, columns,
    predicate(current = clause) {
      if (!current.predicate) return [];
      const ranges = fields.length === 1 ? [current.value] : current.value;
      if (!Array.isArray(ranges) || ranges.length !== fields.length) throw new TypeError('Invalid interval dimensions.');
      return ranges.map((range, index) => {
        if (!Array.isArray(range) || range.length !== 2) throw new TypeError('Invalid interval extent.');
        return sql.between(sql.column(`active${index}`), [
          transforms[index](sql.asLiteral(range[0])), transforms[index](sql.asLiteral(range[1]))
        ]);
      });
    }
  };
}

function binInterval(scale: ScaleOptions, pixelSize: number, bin?: BinMethod): ((value: sql.ExprValue) => SqlExpression) | undefined {
  if (!Number.isFinite(pixelSize) || pixelSize <= 0 || !scale.domain?.length) return;
  const { type, domain, range, apply, sqlApply } = sql.scaleTransform<number>(scale);
  const lo = apply(Math.min(...domain!.map(Number)));
  const hi = apply(Math.max(...domain!.map(Number)));
  const scalar = (type === 'identity' ? 1 : Math.abs(range![1] - range![0]) / (hi - lo)) / pixelSize;
  if (!Number.isFinite(lo) || !Number.isFinite(hi) || !Number.isFinite(scalar)) return;
  const round = bin === 'ceil' ? sql.ceil : bin === 'round' ? sql.round : sql.floor;
  return value => {
    const transformed = sqlApply(value);
    const delta = lo === 0 ? transformed : sql.sub(transformed, sql.float64(lo));
    const pixels = scalar === 1 ? delta : sql.mul(sql.float64(scalar), delta);
    return sql.int32(round(pixels));
  };
}

function preaggregateInfo(
  input: sql.Query,
  clause: SelectionClause,
  columns: PreAggColumnsResult,
  context: SqlContext,
  fallback: (clause: SelectionClause) => sql.Query,
  invalidate: (plan: PreAggregateInfo) => void
): PreAggregateInfo | null {
  const memo = new Map<object, unknown>();
  const query = new sql.Query(sql.deepClone(input, memo));
  const clonedClause = {
    ...clause,
    fields: clause.fields.map(field => sql.deepClone(field, memo)),
    predicate: clause.predicate && sql.deepClone(clause.predicate, memo)
  };
  const active = activeColumns(clonedClause);
  if (!active.source || !active.columns) return null;
  const clone = (entries: Record<string, SqlExpression>) => Object.fromEntries(
    Object.entries(entries).map(([name, expression]) => [name, sql.deepClone(expression, memo)])
  );
  const statistics = clone(columns.preagg);
  const output = clone(columns.output);
  const source = sql.deepClone(columns.source, memo);
  if (!('table' in source)) return null;
  const selected = sql.selectEntries(query);
  const names = new Set<string>();
  for (const field of Object.values(active.columns)) {
    sql.walk(field, node => {
      if ('subquery' in node) return 1;
      const path = columnPath(node);
      if (path) { names.add(path[path.length - 1]); return 1; }
    });
  }
  if (!subqueryPushdown(query, source, [...names])) return null;
  const shape = sql.inspectSelect(query);
  const create = new sql.Query({ select: {
    ...shape,
    expressions: Object.entries({ ...statistics, ...active.columns }).map(([name, expression]) =>
      sql.native.alias(expression, sql.native.identifier(name, true).identifier)),
    group_by: sql.native.groupBy([...columns.groupby, ...Object.keys(active.columns)].map(name => sql.column(name))).group_by,
    having: null, qualify: null, order_by: null, windows: null, limit: null, offset: null, fetch: null,
    distinct: false, distinct_on: null
  } });
  const select = query.setSelect(output).setGroupby(columns.groupby)
    .setHaving(columns.having && sql.deepClone(columns.having, memo))
    .setQualify(columns.qualify && sql.deepClone(columns.qualify, memo))
    .setOrderby(columns.orderby.map(expression => replaceIndex(sql.deepClone(expression, memo), selected)));
  const result = sql.inspectSelect(select);
  result.windows = columns.windows?.map(definition => ({
    ...definition,
    spec: {
      ...definition.spec,
      partition_by: definition.spec.partition_by.map(expression => sql.deepClone(expression, memo)),
      order_by: definition.spec.order_by.map(ordered => {
        const expression = sql.deepClone({ ordered }, memo);
        if (!('ordered' in expression)) throw new TypeError('Expected a window ordering.');
        return expression.ordered;
      })
    }
  })) ?? null;
  result.with = null;
  result.where_clause = null;
  result.sample = null;
  result.from = null;
  result.joins = [];
  return new PreAggregateInfo(create, select, active, context, fallback, invalidate);
}

function replaceIndex(expression: SqlExpression, selected: sql.SelectProjection[]): SqlExpression {
  if ('ordered' in expression) {
    const reference = sql.resolvePositional(expression.ordered.this, selected);
    return reference?.alias
      ? { ordered: { ...expression.ordered, this: sql.column(reference.alias) } }
      : expression;
  }
  const reference = sql.resolvePositional(expression, selected);
  return reference?.alias ? sql.column(reference.alias) : expression;
}

export class PreAggregateInfo {
  table?: TableRef;
  result: Promise<unknown> | null = null;
  readonly skip = false;
  private select: sql.Query | null = null;
  private scalarStamp: string[] = [];
  private readonly parameters: ParamLike[];

  constructor(
    readonly create: sql.Query,
    private readonly output: sql.Query,
    readonly active: ActiveColumnsResult,
    private readonly context: SqlContext,
    private readonly fallback: (clause: SelectionClause) => sql.Query,
    private readonly invalidate: (plan: PreAggregateInfo) => void
  ) {
    this.parameters = [...new Set([...sql.params(create), ...sql.params(output)])];
  }

  prepare(schema: string): string {
    const execution = this.context.execution;
    const snapshots = sql.snapshotAll([this.create, this.output, ...this.parameters.map(parameter => sql.asLiteral(parameter))]);
    const [create, output] = snapshots;
    const statements = sql.compileResolved([create], execution);
    if (statements.length !== 1) throw new TypeError('Preaggregation creation requires one SELECT statement.');
    const id = (fnv_hash(this.context.cacheKey(statements[0], execution)) >>> 0).toString(16);
    this.table = sql.tableRef(schema, `preagg_${id}`)!;
    this.select = new sql.Query(output).setFrom(this.table);
    this.scalarStamp = snapshots.slice(2).map(expression => this.context.structuralKey(expression));
    return sql.compileResolved([
      sql.rootExpression(sql.createSchema(schema)),
      sql.rootExpression(sql.createTable(this.table, new sql.Query(create), { temp: false }))
    ], execution).join(';\n');
  }

  query(clause: SelectionClause): sql.Query {
    return sql.Query.from(sql.deferred(read => {
      if (!this.select || this.result === null) return sql.subquery(this.fallback(clause));
      const stamp = this.stamp(read);
      if (stamp.some((value, index) => value !== this.scalarStamp[index])) {
        this.result = null;
        this.invalidate(this);
        return sql.subquery(this.fallback(clause));
      }
      return sql.subquery(this.select.clone().where(this.active.predicate?.(clause) ?? []));
    }, this.parameters));
  }

  private stamp(read: ParamReader): string[] {
    return this.parameters.map(parameter => this.context.structuralKey(sql.asLiteral(read(parameter))));
  }
}
