import type { Table } from '@uwdata/flechette';
import type { ExprNode, MaybeArray, Query, SelectQuery } from '@uwdata/mosaic-sql';
import { isAggregateExpression, isColumnRef, isDescribeQuery, isSelectQuery, walk } from '@uwdata/mosaic-sql';
import {
  bindingOf, compileResolved, hasColumnExpansion as hasNativeColumnExpansion,
  inspectSelect, isAggregateExpression as isNativeAggregateExpression,
  isSelectQuery as isNativeSelectQuery, Query as NativeQuery,
  params, resolvePositional as resolveNativePositional, selectEntries, snapshotAll, walk as walkNative
} from '@uwdata/mosaic-sql/native';
import type { SelectProjection, SqlExpression } from '@uwdata/mosaic-sql/native';
import type { NativeSqlContext } from './native-sql.js';
import type { Cache, QueryEntry, QueryType } from './types.js';
import { tableByteLength } from './util/decode-ipc.js';
import { resolvePositional } from './util/positional.js';
import { QueryResult } from './util/query-result.js';

interface GroupEntry {
  entry: QueryEntry;
  priority: number;
  index: number;
  removed?: boolean;
  native?: NativeShape;
}

interface QueryGroup extends Array<GroupEntry> {
  query?: Query | NativeQuery;
  result?: QueryResult;
  maps?: Array<Array<[string, string]>>;
  cacheKeys?: string[];
  issued?: number;
}

interface NativeShape {
  query: NativeQuery;
  projections: SelectProjection[];
  groupby: SqlExpression[];
  key: string;
  fullKey: string;
}

function wait(callback: () => void): unknown {
  if (typeof requestAnimationFrame !== 'undefined') {
    return requestAnimationFrame(callback);
  } else if (typeof setImmediate !== 'undefined') {
    return setImmediate(callback);
  } else {
    return setTimeout(callback);
  }
}

/**
 * Create a consolidator to combine structurally compatible queries.
 * @param enqueue Query manager enqueue method
 * @param cache Accessor for the client-side query cache (sql -> data)
 * @returns A consolidator object
 */
export function consolidator(
  enqueue: (entry: QueryEntry, priority?: number) => void,
  cache: () => Cache,
  generation: () => number = () => 0,
  nativeContext: () => NativeSqlContext | null = () => null
) {
  let pending: GroupEntry[] = [];
  let id: unknown = 0;
  const awaiting = new Set<QueryGroup>();

  function run(): void {
    // group queries into bundles that can be consolidated
    const native = nativeContext();
    const groups = native ? nativeEntryGroups(pending, native) : entryGroups(pending, cache());
    pending = [];
    id = 0;

    // build and issue consolidated queries
    for (const group of groups) {
      if (native) consolidateNative(group, enqueue, native, generation);
      else consolidate(group, enqueue);
      if (group.maps) awaiting.add(group);
      processResults(group, cache, generation, awaiting);
    }
  }

  return {
    add(entry: QueryEntry, priority: number): void {
      if (entry.request.type === 'arrow') {
        // wait one frame, gather an ordered list of queries
        // only Apache Arrow is supported, so we can project efficiently
        id ||= wait(() => run());
        pending.push({ entry, priority, index: pending.length });
      } else {
        enqueue(entry, priority);
      }
    },

    /**
     * Remove entries that are waiting to be consolidated or for their share
     * of a consolidated result.
     * @param test A predicate function to test if an entry should be
     *  removed (true to drop, false to keep).
     */
    remove(test: (entry: QueryEntry) => boolean): void {
      pending = pending.filter(({ entry }) => !test(entry));
      for (const group of awaiting) {
        for (const item of group) {
          item.removed ||= test(item.entry);
        }
      }
    }
  };
}

/**
 * Segment query requests into consolidation-compatible groups.
 * @param entries Query request entries ({ request, result } objects)
 * @param cache Client-side query cache
 * @returns An array of grouped entry arrays
 */
function entryGroups(entries: GroupEntry[], cache: Cache): QueryGroup[] {
  const groups: QueryGroup[] = [];
  const groupMap = new Map<string, QueryGroup>();

  for (const query of entries) {
    const { entry: { request } } = query;
    const key = consolidationKey(request.query, cache);
    if (!groupMap.has(key)) {
      const list: QueryGroup = [];
      groups.push(list);
      groupMap.set(key, list);
    }
    groupMap.get(key)!.push(query);
  }

  return groups;
}

/**
 * Generate a key string for query consolidation.
 * Queries with matching keys are conosolidation-compatible.
 * If a query is found in the cache, it is exempted from consolidation,
 * which is indicated by returning a query-specific key.
 * @param query The input query.
 * @param cache The query cache (sql -> data).
 * @returns a key string
 */
function consolidationKey(query: MaybeArray<QueryType>, cache: Cache): string {
  const sql = `${query}`;
  const key = `query:${sql}`;

  // attempt to consolidate non-cached select queries
  if (isSelectQuery(query) && !cache.get(sql)) {
    if (
      query._where.length || query._qualify.length || query._having.length ||
      query._orderby.length || query._distinct || query._distinctOn.length ||
      query._select.some(({ expr }) => hasColumnExpansion(expr))
    ) {
      // bail if query includes clauses that may refer to *derived* columns
      // that we can't resolve. also do not consolidate distinct queries
      return key;
    }

    // create a derived query stripped of selections
    const q = query.clone().setSelect('*');

    // check group by criteria for compatibility
    // 1. queries may refer to *derived* columns as group by criteria;
    //    we resolve these against the true grouping expressions
    // 2. queries may refer to select clauses using a positional index;
    //    we need to resolve these as well
    const groupby = query._groupby;
    const select = query._select;
    if (groupby.length) {
      // build expression lookup map (alias -> expr)
      const map: Record<string, ExprNode> = {};
      select.forEach(({ alias, expr }) => map[alias] = expr);

      // sorted group by expression list
      const exprs = groupby
        .map(e => {
          const expr = (isColumnRef(e) && map[e.column])
            || (resolvePositional(e, select)?.expr ?? e);
          return { sql: `${expr}`, expr }
        })
        .sort((a, b) => a.sql < b.sql ? -1 : a.sql > b.sql ? 1 : 0);
      q.setGroupby(exprs.map(e => e.expr));
    }
    else if (select.some(e => isAggregateExpression(e.expr!))) {
      // if query is an ungrouped aggregate, add an explicit groupby to
      // prevent improper consolidation with non-aggregate queries
      q.setGroupby('ALL');
    }

    return `select:${q}`;
  } else {
    return key;
  }
}

function hasColumnExpansion(expr: ExprNode): boolean {
  let expands = isColumnRef(expr) && expr.column === '*';
  walk(expr, node => {
    if (node.type === 'SCALAR_SUBQUERY') return 1;
    if (node.type === 'COLUMNS' ||
        (node.type === 'VERBATIM' && /\*|\bcolumns\b/i.test(String(node)))) {
      expands = true;
      return -1;
    }
  });
  return expands;
}

/**
 * Issue queries, consolidating where possible.
 * @param group Array of bundled query entries
 * @param enqueue Add entry to query queue
 */
function consolidate(
  group: QueryGroup,
  enqueue: (entry: QueryEntry, priority?: number) => void
): void {
  if (shouldConsolidate(group)) {
    // issue a single consolidated query
    enqueue({
      request: {
        type: 'arrow',
        cache: false,
        query: (group.query = consolidatedQuery(group))
      },
      result: (group.result = new QueryResult())
    });
  } else {
    // issue queries directly
    for (const { entry, priority } of group) {
      enqueue(entry, priority);
    }
  }
}

/**
 * Check if a group contains multiple distinct queries.
 * @param group Array of bundled query entries
 * @returns false if group contains a single (possibly repeated) query,
 *  otherwise true
 */
function shouldConsolidate(group: QueryGroup): boolean {
  if (group.length > 1) {
    const sql = `${group[0].entry.request.query}`;
    for (let i = 1; i < group.length; ++i) {
      if (sql !== `${group[i].entry.request.query}`) {
        return true;
      }
    }
  }
  return false;
}

/**
 * Create a consolidated query for a group.
 * @param group Array of bundled query entries
 * @returns A consolidated Query instance
 */
function consolidatedQuery(group: QueryGroup): Query {
  const maps: Array<Array<[string, string]>> = group.maps = [];
  const fields = new Map<string, [string, ExprNode]>();

  // gather select fields
  for (const item of group) {
    const query = item.entry.request.query as SelectQuery;
    const fieldMap: Array<[string, string]> = [];
    maps.push(fieldMap);
    for (const { alias, expr } of query._select) {
      const e = `${expr}`;
      if (!fields.has(e)) {
        fields.set(e, [`col${fields.size}`, expr]);
      }
      const [name] = fields.get(e)!;
      fieldMap.push([name, alias]);
    }
  }

  // use a cloned query as a starting point
  const query = (group[0].entry.request.query as SelectQuery).clone();

  // update group by statement as needed
  // group by may reference select clauses by alias or by position;
  // both must be remapped to the consolidated column names
  const groupby = query._groupby;
  if (groupby.length) {
    const map: Record<string, string> = {};
    group.maps[0].forEach(([name, as]) => map[as] = name);
    const select = query._select;
    query.setGroupby(
      groupby.map((e: ExprNode) => {
        const alias = isColumnRef(e) ? e.column
          : resolvePositional(e, select)?.alias;
        return (alias && map[alias]) || e;
      })
    );
  }

  // update select statement and return
  return query.setSelect(Array.from(fields.values()));
}

/**
 * Process query results, dispatch results to original requests
 * @param group Array of query requests
 * @param cache Accessor for the client-side query cache (sql -> data)
 * @param generation Cache generation accessor; results issued under an
 *  older generation are delivered but not cached
 * @param awaiting Consolidated groups awaiting their results
 */
async function processResults(
  group: QueryGroup,
  cache: () => Cache,
  generation: () => number,
  awaiting: Set<QueryGroup>
): Promise<void> {
  const { maps, query, result } = group;

  // exit early if no consolidation performed
  // in this case results are passed directly
  if (!maps) return;

  const issued = generation();

  try {
    const data = await result as Table;
    const describe = isDescribeQuery(query!);
    const bytes = tableByteLength(data) ?? 0;
    const extracts = group.map(({ removed }, index) => {
      if (removed) return;
      const map = maps[index];
      return describe && map ? filterResult(data, map)
        : map ? projectResult(data, map)
        : data;
    });
    group.forEach(({ entry, removed }, index) => {
      if (removed) return;
      const { request, result } = entry;
      const extract = extracts[index];
      if (request.cache && (group.issued ?? issued) === generation()) {
        const key = isNativeSelectQuery(query) ? group.cacheKeys?.[index] : String(request.query);
        if (key !== undefined) cache().set(key, extract, bytes);
      }
      result.fulfill(extract);
    });
  } catch (err) {
    // pass error to consolidated queries
    for (const { entry, removed } of group) {
      if (!removed) entry.result.reject(err);
    }
  } finally {
    awaiting.delete(group);
  }
}

/**
 * Project a consolidated result to a client result
 * @param data Consolidated query result, as an Arrow Table
 * @param map Column name map as [source, target] pairs
 * @returns the projected Apache Arrow table
 */
function projectResult(data: Table, map: Array<[string, string]>): Table {
  return data.select(map.map(x => x[0]), map.map(x => x[1]));
}

/**
 * Filter a consolidated describe query result to a client result
 * @param data Consolidated query result, as an Arrow Table
 * @param map Column name map as [source, target] pairs
 * @returns the filtered table data
 */
function filterResult(data: Table, map: Array<[string, string]>): unknown[] {
  const lookup = new Map(map);
  const result: unknown[] = [];
  for (const d of data) {
    if (lookup.has(d.column_name)) {
      result.push({ ...d, column_name: lookup.get(d.column_name) })
    }
  }
  return result;
}

function nativeShape(query: QueryType | QueryType[], context: NativeSqlContext): NativeShape | undefined {
  if (!isNativeSelectQuery(query)) return;
  const select = inspectSelect(query);
  if (select.where_clause || select.qualify || select.having || select.order_by
    || select.distinct || select.distinct_on?.length || select.windows?.length
    || select.group_by?.all != null || select.group_by?.totals) return;
  if (select.group_by?.expressions.some(expression => params(expression).length || hasDynamicShape(expression) || hasGroupingOperation(expression))) return;
  const projections = selectEntries(query);
  if (projections.some(({ alias, expr }) => alias === undefined || hasNativeColumnExpansion(expr) || hasDynamicShape(expr))) return;
  const aliases = new Map(projections.map(({ alias, expr }) => [alias, expr]));
  const groupby = (select.group_by?.expressions ?? []).map(expression => {
    const alias = 'column' in expression && !expression.column.table
      ? aliases.get(expression.column.name.name)
      : undefined;
    return alias ?? resolveNativePositional(expression, projections)?.expr ?? expression;
  });
  const sorted = groupby.map(expression => ({ expression, key: context.structuralKey(expression) }))
    .sort((a, b) => a.key < b.key ? -1 : a.key > b.key ? 1 : 0);
  const grouping = select.group_by
    ? { ...select.group_by, expressions: sorted.map(({ expression }) => expression) }
    : null;
  const shape: SqlExpression = { select: { ...select, expressions: [], group_by: grouping } };
  const aggregate = !groupby.length && projections.some(({ expr }) => isNativeAggregateExpression(expr));
  return {
    query,
    projections,
    groupby,
    key: context.cacheKey(JSON.stringify([aggregate, context.structuralKey(shape)])),
    fullKey: context.structuralKey(query)
  };
}

function nativeEntryGroups(entries: GroupEntry[], context: NativeSqlContext): QueryGroup[] {
  const groups: QueryGroup[] = [];
  const grouped = new Map<string, QueryGroup>();
  for (const item of entries) {
    const { request } = item.entry;
    let shape: NativeShape | undefined;
    try {
      shape = request.options && Object.keys(request.options).length
        ? undefined
        : nativeShape(request.query, context);
    } catch (error) {
      item.entry.result.reject(error);
      continue;
    }
    if (!shape) {
      groups.push([item]);
      continue;
    }
    item.native = shape;
    let group = grouped.get(shape.key);
    if (!group) {
      group = [];
      grouped.set(shape.key, group);
      groups.push(group);
    }
    group.push(item);
  }
  return groups;
}

function consolidateNative(
  group: QueryGroup,
  enqueue: (entry: QueryEntry, priority?: number) => void,
  context: NativeSqlContext,
  generation: () => number
): void {
  const first = group[0].native;
  if (!first || group.length < 2 || group.every(item => item.native?.fullKey === first.fullKey)) {
    for (const { entry, priority } of group) enqueue(entry, priority);
    return;
  }
  const fields = new Map<string, [string, SqlExpression]>();
  group.maps = group.map(item => item.native!.projections.map(({ alias, expr }) => {
    const key = context.structuralKey(expr);
    let field = fields.get(key);
    if (!field) {
      field = [`col${fields.size}`, expr];
      fields.set(key, field);
    }
    return [field[0], alias!];
  }));
  const query = first.query.clone().setSelect([...fields.values()]);
  if (first.groupby.length) query.setGroupby(first.groupby);
  const originals = group.map(item => item.native!.query.clone());
  group.query = query;
  group.result = new QueryResult();
  enqueue({
    request: { type: 'arrow', cache: false, query },
    result: group.result,
    prepare() {
      const execution = context.execution;
      group.issued = generation();
      const expressions = snapshotAll([...originals, query]);
      const sql = expressions.map(expression => {
        const statements = compileResolved([expression], execution);
        if (statements.length !== 1) throw new TypeError('Consolidated Arrow queries require one result-producing statement.');
        return statements[0];
      });
      group.cacheKeys = sql.slice(0, -1).map(statement => context.cacheKey(statement, execution));
      return sql[sql.length - 1];
    }
  }, Math.min(...group.map(item => item.priority)));
}

function hasDynamicShape(expression: SqlExpression): boolean {
  let dynamic = false;
  walkNative(expression, node => {
    const binding = bindingOf(node);
    if (binding && binding.kind !== 'scalar') {
      dynamic = true;
      return -1;
    }
  });
  return dynamic;
}

function hasGroupingOperation(expression: SqlExpression): boolean {
  let grouping = false;
  walkNative(expression, node => {
    if ('group' in node || 'grouping_sets' in node || 'cube' in node || 'rollup' in node) {
      grouping = true;
      return -1;
    }
  });
  return grouping;
}
