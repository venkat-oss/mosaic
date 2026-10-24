import * as nativeSQL from '@uwdata/mosaic-sql/native';
import type { ParamLike, ParamReader, SqlExpression } from '@uwdata/mosaic-sql/native';
import type { NativeSqlContext } from '../native-sql.js';
import type { SelectionExpression } from '../types.js';
import { Priority } from '../QueryManager.js';
import { nativeColumnPath, type NativeTable } from './lineage.js';
import { ExprNode, ScaleOptions, SelectQuery, Query, ExprValue, MaybeArray, FunctionNode, TableRefNode, createSchema, SelectClauseNode, OrderByNode, and, asNode, ceil, collectColumns, createTable, float64, floor, isBetween, int32, mul, round, scaleTransform, sub, rewrite, deepClone } from '@uwdata/mosaic-sql';
import type { BinMethod, ClauseSource, IntervalMetadata, SelectionClause } from '../clause/index.js';
import type { Coordinator } from '../Coordinator.js';
import type { MosaicClient } from '../MosaicClient.js';
import type { Selection } from '../Selection.js';
import { fnv_hash } from '../util/hash.js';
import { resolvePositional } from '../util/positional.js';
import { QueryError } from '../util/query-error.js';
import { nativeIndexable, nativePreaggColumns, type NativePreAggColumnsResult, preaggColumns, PreAggColumnsResult } from './preagg-columns.js';
import { nativeSubqueryPushdown, subqueryPushdown } from './subquery-pushdown.js';

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

type ActivePredicate = (clause?: SelectionClause) => MaybeArray<ExprNode>;

interface ActiveColumnsResult {
  native?: false;
  source: ClauseSource | null;
  columns?: Record<string, ExprNode>;
  predicate?: ActivePredicate;
}

type AnyClient = MosaicClient<SelectionExpression>;
type AnySelection = Selection<SelectionExpression>;
type AnyClause = SelectionClause<SelectionExpression>;

interface NativeActiveColumnsResult {
  native: true;
  source: ClauseSource | null;
  columns?: Record<string, SqlExpression>;
  predicate?: (clause: SelectionClause<SqlExpression>) => SqlExpression[];
}

interface PreAggregateInfoOptions {
  table: TableRefNode;
  create: SelectQuery;
  active: ActiveColumnsResult;
  select: SelectQuery;
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
  public entries: Map<AnyClient, PreAggregateInfo | NativePreAggregateInfo | typeof Skip | null>;
  private active: ActiveColumnsResult | NativeActiveColumnsResult | null;
  private activeKey: string | null;
  private mc: Coordinator;
  private _schema: string;
  private _enabled: boolean;

  /**
   * Create a new manager of materialized views of pre-aggregated data.
   * @param coordinator A Mosaic coordinator.
   * @param options Pre-aggregation options.
   */
  constructor(coordinator: Coordinator, {
    schema = 'mosaic',
    enabled = true
  }: PreAggregateOptions = {}) {
    this.entries = new Map();
    this.active = null;
    this.activeKey = null;
    this.mc = coordinator;
    this._schema = schema;
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
    if (this._enabled !== state) {
      if (!state) this.clear();
      this._enabled = state;
    }
  }

  /**
   * Get the enabled state of this manager.
   * @returns The current enabled state.
   */
  get enabled(): boolean {
    return this._enabled && (!this.mc.nativeContext
      || this.mc.nativeContext.execution.targetDialect === nativeSQL.Dialect.DuckDB);
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
    return this.mc.nativeContext
      ? this.mc.exec(nativeSQL.dropSchema(this.schema, { ifExists: true, cascade: true }))
      : this.mc.exec(`DROP SCHEMA IF EXISTS "${this.schema}" CASCADE`);
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
  request(client: AnyClient, selection: AnySelection, activeClause: AnyClause | null): PreAggregateInfo | NativePreAggregateInfo | typeof Skip | null {
    if (!this.enabled || !activeClause?.source) return null;
    const { entries, mc, schema } = this;
    const context = mc.nativeContext;
    const execution = context?.execution;
    if (client.sqlOwner !== context || selection.owner !== context || (activeClause.context ?? null) !== context) return null;
    try {
      const nativeActive = context && isNativeClause(activeClause) ? nativeActiveColumns(activeClause) : null;
      const key = context && nativeActive && isNativeClause(activeClause)
        ? JSON.stringify([
          context.execution.generation, activeClause.meta?.type,
          activeClause.fields.map(field => context.structuralKey(field)),
          Object.entries(nativeActive.columns ?? {}).map(([name, expression]) => [name, context.structuralKey(expression)])
        ])
        : null;
      if (this.active && (this.active.source !== activeClause.source || key !== this.activeKey)) this.clear();
      if (this.active?.source === null) return null;
      if (!this.active) {
        if (!activeClause.predicate) return null;
        this.active = nativeActive ?? (isLegacyClause(activeClause) ? activeColumns(activeClause) : null);
        this.activeKey = key;
        if (!this.active?.source) return null;
      }
      if (entries.has(client)) return entries.get(client)!;
      let info: PreAggregateInfo | NativePreAggregateInfo | typeof Skip | null = null;
      if (context && this.active.native && isNativeClient(client) && isNativeSelection(selection) && isNativeClause(activeClause)) {
        const columns = nativePreaggColumns(client, expression => context.structuralKey(expression));
        if (columns) {
          if (selection.skip(client, activeClause)) info = Skip;
          else {
            const inactive = selection.remove(activeClause.source).predicate(client);
            const query = client.query(inactive);
            if (nativeSQL.isSelectQuery(query)) {
              info = nativePreaggregateInfo(query, activeClause, columns, context, clause => {
                if (client.sqlOwner !== context) throw new TypeError('Native preaggregation owner changed.');
                const fallback = client.query([inactive ?? [], clause.predicate ?? []].flat());
                if (!nativeSQL.isQuery(fallback) || !nativeSQL.isResultQuery(fallback)) {
                  throw new TypeError('Native preaggregation fallback requires a native result query.');
                }
                return fallback;
              }, plan => {
                if (entries.get(client) === plan) entries.delete(client);
              });
            }
          }
        }
      } else if (!this.active.native && isLegacyClient(client) && isLegacySelection(selection) && isLegacyClause(activeClause)) {
        const columns = preaggColumns(client);
        if (columns) {
          if (selection.skip(client, activeClause)) info = Skip;
          else {
            const query = client.query(selection.remove(activeClause.source).predicate(client));
            if (query instanceof SelectQuery) info = preaggregateInfo(query, this.active, columns, schema);
          }
        }
      }
      if (info && !info.skip) {
        const plan = info;
        if (plan instanceof NativePreAggregateInfo) {
          plan.result = mc.manager.request({ type: 'exec', query: plan.create }, Priority.Normal, () => plan.prepare(schema));
        } else {
          plan.result = mc.exec([createSchema(schema), createTable(plan.table, plan.create, { temp: false })]);
        }
        plan.result.catch((error: unknown) => {
          mc.logger().error(error instanceof QueryError ? error : new QueryError(error, plan.create));
          plan.result = null;
        });
      }
      if (context && context.execution !== execution) return null;
      entries.set(client, info);
      return info;
    } catch {
      if (!context || context.execution === execution) entries.set(client, null);
      return null;
    }
  }
}

/**
 * Determines the active dimension columns to select over. Returns an object
 * with the clause source, column definitions, and a predicate generator
 * function for the active dimensions of a pre-aggregated materialized view.
 * If the active clause is not indexable or is missing metadata, this method
 * returns an object with a null source property.
 * @param clause The active selection clause to analyze.
 */
function activeColumns(clause: SelectionClause): ActiveColumnsResult {
  const { fields, meta, source } = clause;
  if (!meta || !fields?.length) {
    // bail if no metadata or fields to work with
    return { source: null, columns: undefined, predicate: undefined };
  }

  const columns: Record<string, ExprNode> = {};
  let predicate: ActivePredicate | undefined;

  if (meta.type === 'point') {
    fields.forEach((f, i) => { columns[`active${i}`] = f; });
    predicate = (clause?: SelectionClause) => {
      if (!clause?.predicate) return [];
      const map = new Map<ExprNode, ExprNode>(
        clause.fields.map((f, i) => [f, asNode(`active${i}`)])
      );
      return rewrite(clause.predicate, map)!;
    };
  } else if (meta.type === 'interval') {
    // apply pixel-level binning, bail if a scale type is unsupported
    const { scales, bin, pixelSize = 1 } = meta as IntervalMetadata;
    const bins = scales?.map((s: ScaleOptions) => binInterval(s, pixelSize, bin));
    if (bins?.every(b => b != null)) {
      fields.forEach((f, i) => { columns[`active${i}`] = bins[i](f); });
      if (bins.length === 1) {
        // single interval selection
        // selection clause predicate has type BetweenOpNode
        predicate = (clause?: SelectionClause) => {
          if (!clause?.predicate) return [];
          const v = clause.value as number[];
          return isBetween('active0', v.map(bins[0]));
        };
      } else {
        // multiple interval selection
        // selection clause predicate has type AndNode<BetweenOpNode>
        predicate = (clause?: SelectionClause) => {
          if (!clause?.predicate) return [];
          const v = clause.value as number[][];
          return and(
            fields.map((_, i) => isBetween(`active${i}`, v[i].map(bins[i])))
          );
        };
      }
    }
  }

  if (predicate) {
    return { source, columns, predicate };
  } else {
    return { source: null, columns: undefined, predicate };
  }
}

const BIN: Record<string, (expr: ExprValue) => FunctionNode> = { ceil, round };

/**
 * Returns a bin function generator to discretize a selection interval domain.
 * @param scale A scale that maps domain values to the output range
 *  (typically pixels).
 * @param pixelSize The interactive pixel size. This value indicates
 *  the bin step size and may be greater than an actual screen pixel.
 * @param bin The binning method to apply, one of `floor`, `ceil', or `round`.
 * @returns A bin function generator.
 */
function binInterval(
  scale: ScaleOptions,
  pixelSize: number,
  bin?: BinMethod
): ((value: ExprValue) => ExprNode) | undefined {
  const { type, domain, range, apply, sqlApply } = scaleTransform(scale)!;
  if (!apply) return; // unsupported scale type
  const binFn = BIN[`${bin}`.toLowerCase()] || floor;
  const dom = domain!.map(x => Number(x));
  const lo = apply(Math.min(...dom));
  const hi = apply(Math.max(...dom));
  const s = (type === 'identity'
    ? 1
    : Math.abs(range![1] - range![0]) / (hi - lo)) / pixelSize;
  const scalar = s === 1
    ? (x: ExprValue) => x
    : (x: ExprValue) => mul(float64(s), x);
  const diff = lo === 0
    ? (x: ExprValue) => x
    : (x: ExprValue) => sub(x, float64(lo));
  return value => int32(binFn(scalar(diff(sqlApply(value)))));
}

/**
 * Generate pre-aggregate query information.
 * @param query The original client query.
 * @param active Active (selected) columns.
 * @param preaggCols Pre-aggregation columns.
 * @param schema Database schema name.
 * @returns Pre-aggregation information, or null if the active columns
 *  can not be pushed down to the source table.
 */
function preaggregateInfo(
  query: SelectQuery,
  active: ActiveColumnsResult,
  preaggCols: PreAggColumnsResult,
  schema: string
): PreAggregateInfo | null {
  query = deepClone(query);
  const { groupby, having, orderby, output, preagg, qualify, source } = preaggCols;
  const { columns = {} } = active;
  const selectClauses = query._select;

  // top-level select and group by changes are overwritten below
  const pushed = subqueryPushdown(
    query,
    source,
    Object.values(columns).flatMap(c => collectColumns(c).map(c => c.column))
  );
  if (!pushed) return null;

  // build materialized view construction query
  const create = Query
    .from(query._from)
    .with(query._with)
    .sample(query._sample)
    .where(query._where)
    .select({ ...preagg, ...columns })
    .groupby(groupby, Object.keys(columns));

  // generate preagg table name using creation query hash
  const id = (fnv_hash(create.toString()) >>> 0).toString(16);
  const table = new TableRefNode([schema, `preagg_${id}`]);

  // generate preaggregate select query from original query
  // replace select, from, groupby; sanitize orderby; remove CTEs, where
  const select = query
    .setSelect(output)
    .setFrom(table)
    .setGroupby(groupby)
    .setHaving(having)
    .setQualify(qualify)
    .setOrderby(replaceIndices(orderby, selectClauses))
    .sample(null);
  select._with = [];
  select.setWhere();

  return new PreAggregateInfo({ table, create, active, select });
}

/**
 * Replace column index references with named column expressions.
 * @param exprs A list of expressions to check and potentially replace.
 * @param select Select clauses from the query.
 */
function replaceIndices(exprs: ExprNode[], select: SelectClauseNode[]) {
  return exprs.flatMap(expr => {
    if (expr.type === 'ORDER_BY') {
      const e = (expr as OrderByNode).expr;
      const ref = resolvePositional(e, select);
      if (ref) {
        const cloned = expr.clone();
        // @ts-expect-error assign to cloned order by node
        cloned.expr = asNode(ref.alias);
        return cloned;
      }
    } else {
      const ref = resolvePositional(expr, select);
      if (ref) return asNode(ref.alias);
    }
    return expr;
  });
}

/**
 * Metadata and query generator for materialized views of pre-aggregated data.
 * This object provides the information needed to generate and query the
 * materialized views for a client-selection pair relative to a specific
 * active clause and selection state.
 */
export class PreAggregateInfo {
  /** The name of the materialized view. */
  table: TableRefNode;
  /** The SQL query used to generate the materialized view. */
  create: SelectQuery;
  /**
   * A result promise returned for the materialized view creation query.
   * Null values indicate that a creation query failed and there is no view.
   */
  result: Promise<unknown> | null;
  /**
   * Definitions and predicate function for the active columns,
   * which are dynamically filtered by the active clause.
   */
  active: ActiveColumnsResult;
  /** Select query (sans where clause) for materialized views. */
  select: SelectQuery;
  /**
   * Boolean flag indicating a client that should be skipped.
   * This value is always false for a created materialized view.
   */
  skip: boolean;

  /**
   * Create a new pre-aggregation information instance.
   * @param options Options object.
   */
  constructor({ table, create, active, select }: PreAggregateInfoOptions) {
    this.table = table;
    this.create = create;
    this.result = null; // set subsequently in request method
    this.active = active;
    this.select = select;
    this.skip = false;
  }

  /**
   * Generate a materialized view query for the given predicate.
   * @param clause The current selection clause.
   * @returns A materialized view query.
   */
  query(clause: AnyClause): SelectQuery {
    if (!isLegacyClause(clause)) throw new TypeError('Native clause reached a legacy preaggregation plan.');
    const filter = this.active.predicate?.(clause) ?? [];
    return this.select.clone().where(filter);
  }
}

function nativeActiveColumns(clause: SelectionClause<SqlExpression>): NativeActiveColumnsResult {
  const { fields, meta, source } = clause;
  if (!meta || !fields.length || fields.some(field => !nativeIndexable(field) || nativeSQL.params(field).length)) {
    return { native: true, source: null };
  }
  const columns: Record<string, SqlExpression> = {};
  if (meta.type === 'point') {
    fields.forEach((field, index) => { columns[`active${index}`] = field; });
    return {
      native: true, source, columns,
      predicate(current = clause) {
        if (!current.predicate) return [];
        const memo = new Map<object, unknown>();
        const fields = current.fields.map(field => nativeSQL.deepClone(field, memo));
        const predicate = nativeSQL.deepClone(current.predicate, memo);
        const replacements = new Map(fields.map((field, index) => [field, nativeSQL.column(`active${index}`)]));
        return [nativeSQL.rewrite(predicate, replacements)];
      }
    };
  }
  if (meta.type !== 'interval') return { native: true, source: null };
  const { scales, bin, pixelSize = 1 } = meta as IntervalMetadata;
  const bins = scales?.map(scale => nativeBinInterval(scale, pixelSize, bin));
  if (!bins || bins.length !== fields.length || bins.some(bin => !bin)) return { native: true, source: null };
  const transforms = bins.filter((bin): bin is NonNullable<typeof bin> => !!bin);
  fields.forEach((field, index) => { columns[`active${index}`] = transforms[index](field); });
  return {
    native: true, source, columns,
    predicate(current = clause) {
      if (!current.predicate) return [];
      const ranges = fields.length === 1 ? [current.value] : current.value;
      if (!Array.isArray(ranges) || ranges.length !== fields.length) throw new TypeError('Invalid native interval dimensions.');
      return ranges.map((range, index) => {
        if (!Array.isArray(range) || range.length !== 2) throw new TypeError('Invalid native interval extent.');
        return nativeSQL.between(nativeSQL.column(`active${index}`), [
          transforms[index](nativeSQL.asLiteral(range[0])), transforms[index](nativeSQL.asLiteral(range[1]))
        ]);
      });
    }
  };
}

function nativeBinInterval(scale: ScaleOptions, pixelSize: number, bin?: BinMethod): ((value: nativeSQL.ExprValue) => SqlExpression) | undefined {
  if (!Number.isFinite(pixelSize) || pixelSize <= 0 || !scale.domain?.length) return;
  const { type, domain, range, apply, sqlApply } = nativeSQL.scaleTransform<number>(scale);
  const lo = apply(Math.min(...domain!.map(Number)));
  const hi = apply(Math.max(...domain!.map(Number)));
  const scalar = (type === 'identity' ? 1 : Math.abs(range![1] - range![0]) / (hi - lo)) / pixelSize;
  if (!Number.isFinite(lo) || !Number.isFinite(hi) || !Number.isFinite(scalar)) return;
  const round = bin === 'ceil' ? nativeSQL.ceil : bin === 'round' ? nativeSQL.round : nativeSQL.floor;
  return value => {
    const transformed = sqlApply(value);
    const delta = lo === 0 ? transformed : nativeSQL.sub(transformed, nativeSQL.float64(lo));
    const pixels = scalar === 1 ? delta : nativeSQL.mul(nativeSQL.float64(scalar), delta);
    return nativeSQL.int32(round(pixels));
  };
}

function nativePreaggregateInfo(
  input: nativeSQL.Query,
  clause: SelectionClause<SqlExpression>,
  columns: NativePreAggColumnsResult,
  context: NativeSqlContext,
  fallback: (clause: SelectionClause<SqlExpression>) => nativeSQL.Query,
  invalidate: (plan: NativePreAggregateInfo) => void
): NativePreAggregateInfo | null {
  const memo = new Map<object, unknown>();
  const query = new nativeSQL.Query(nativeSQL.deepClone(input, memo));
  const clonedClause = {
    ...clause,
    fields: clause.fields.map(field => nativeSQL.deepClone(field, memo)),
    predicate: clause.predicate && nativeSQL.deepClone(clause.predicate, memo)
  };
  const active = nativeActiveColumns(clonedClause);
  if (!active.source || !active.columns) return null;
  const clone = (entries: Record<string, SqlExpression>) => Object.fromEntries(
    Object.entries(entries).map(([name, expression]) => [name, nativeSQL.deepClone(expression, memo)])
  );
  const statistics = clone(columns.preagg);
  const output = clone(columns.output);
  const source = nativeSQL.deepClone(columns.source, memo);
  if (!('table' in source)) return null;
  const selected = nativeSQL.selectEntries(query);
  const names = new Set<string>();
  for (const field of Object.values(active.columns)) {
    nativeSQL.walk(field, node => {
      if ('subquery' in node) return 1;
      const path = nativeColumnPath(node);
      if (path) { names.add(path[path.length - 1]); return 1; }
    });
  }
  if (!nativeSubqueryPushdown(query, source, [...names])) return null;
  const shape = nativeSQL.inspectSelect(query);
  const create = new nativeSQL.Query({ select: {
    ...shape,
    expressions: Object.entries({ ...statistics, ...active.columns }).map(([name, expression]) =>
      nativeSQL.native.alias(expression, nativeSQL.native.identifier(name, true).identifier)),
    group_by: nativeSQL.native.groupBy([...columns.groupby, ...Object.keys(active.columns)].map(name => nativeSQL.column(name))).group_by,
    having: null, qualify: null, order_by: null, windows: null, limit: null, offset: null, fetch: null,
    distinct: false, distinct_on: null
  } });
  const select = query.setSelect(output).setGroupby(columns.groupby)
    .setHaving(columns.having && nativeSQL.deepClone(columns.having, memo))
    .setQualify(columns.qualify && nativeSQL.deepClone(columns.qualify, memo))
    .setOrderby(columns.orderby.map(expression => nativeReplaceIndex(nativeSQL.deepClone(expression, memo), selected)));
  const result = nativeSQL.inspectSelect(select);
  result.windows = columns.windows?.map(definition => ({
    ...definition,
    spec: {
      ...definition.spec,
      partition_by: definition.spec.partition_by.map(expression => nativeSQL.deepClone(expression, memo)),
      order_by: definition.spec.order_by.map(ordered => {
        const expression = nativeSQL.deepClone({ ordered }, memo);
        if (!('ordered' in expression)) throw new TypeError('Expected a native window ordering.');
        return expression.ordered;
      })
    }
  })) ?? null;
  result.with = null;
  result.where_clause = null;
  result.sample = null;
  result.from = null;
  result.joins = [];
  return new NativePreAggregateInfo(create, select, active, context, fallback, invalidate);
}

function nativeReplaceIndex(expression: SqlExpression, selected: nativeSQL.SelectProjection[]): SqlExpression {
  if ('ordered' in expression) {
    const reference = nativeSQL.resolvePositional(expression.ordered.this, selected);
    return reference?.alias
      ? { ordered: { ...expression.ordered, this: nativeSQL.column(reference.alias) } }
      : expression;
  }
  const reference = nativeSQL.resolvePositional(expression, selected);
  return reference?.alias ? nativeSQL.column(reference.alias) : expression;
}

export class NativePreAggregateInfo {
  table?: NativeTable;
  result: Promise<unknown> | null = null;
  readonly skip = false;
  private select: nativeSQL.Query | null = null;
  private scalarStamp: string[] = [];
  private readonly parameters: ParamLike[];

  constructor(
    readonly create: nativeSQL.Query,
    private readonly output: nativeSQL.Query,
    readonly active: NativeActiveColumnsResult,
    private readonly context: NativeSqlContext,
    private readonly fallback: (clause: SelectionClause<SqlExpression>) => nativeSQL.Query,
    private readonly invalidate: (plan: NativePreAggregateInfo) => void
  ) {
    this.parameters = [...new Set([...nativeSQL.params(create), ...nativeSQL.params(output)])];
  }

  prepare(schema: string): string {
    const execution = this.context.execution;
    const snapshots = nativeSQL.snapshotAll([this.create, this.output, ...this.parameters.map(parameter => nativeSQL.asLiteral(parameter))]);
    const [create, output] = snapshots;
    const statements = nativeSQL.compileResolved([create], execution);
    if (statements.length !== 1) throw new TypeError('Preaggregation creation requires one SELECT statement.');
    const id = (fnv_hash(this.context.cacheKey(statements[0], execution)) >>> 0).toString(16);
    this.table = nativeSQL.tableRef(schema, `preagg_${id}`)!;
    this.select = new nativeSQL.Query(output).setFrom(this.table);
    this.scalarStamp = snapshots.slice(2).map(expression => this.context.structuralKey(expression));
    return nativeSQL.compileResolved([
      nativeSQL.rootExpression(nativeSQL.createSchema(schema)),
      nativeSQL.rootExpression(nativeSQL.createTable(this.table, new nativeSQL.Query(create), { temp: false }))
    ], execution).join(';\n');
  }

  query(clause: AnyClause): nativeSQL.Query {
    if (!isNativeClause(clause) || clause.context !== this.context) throw new TypeError('Clause owner does not match the native preaggregation plan.');
    return nativeSQL.Query.from(nativeSQL.deferred(read => {
      if (!this.select || this.result === null) return nativeSQL.subquery(this.fallback(clause));
      const stamp = this.stamp(read);
      if (stamp.some((value, index) => value !== this.scalarStamp[index])) {
        this.result = null;
        this.invalidate(this);
        return nativeSQL.subquery(this.fallback(clause));
      }
      return nativeSQL.subquery(this.select.clone().where(this.active.predicate?.(clause) ?? []));
    }, this.parameters));
  }

  private stamp(read: ParamReader): string[] {
    return this.parameters.map(parameter => this.context.structuralKey(nativeSQL.asLiteral(read(parameter))));
  }
}

function isNativeClient(client: AnyClient): client is MosaicClient<SqlExpression> {
  return client.sqlOwner !== null;
}

function isLegacyClient(client: AnyClient): client is MosaicClient {
  return client.sqlOwner === null;
}

function isNativeSelection(selection: AnySelection): selection is Selection<SqlExpression> {
  return selection.owner !== null;
}

function isLegacySelection(selection: AnySelection): selection is Selection {
  return selection.owner === null;
}

function isNativeClause(clause: AnyClause): clause is SelectionClause<SqlExpression> {
  return clause.context !== undefined;
}

function isLegacyClause(clause: AnyClause): clause is SelectionClause {
  return clause.context === undefined;
}
