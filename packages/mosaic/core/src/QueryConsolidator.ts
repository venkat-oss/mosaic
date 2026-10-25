import type { Table } from '@uwdata/flechette';
import { bindingOf, compileResolved, hasColumnExpansion, inspectSelect, isAggregateExpression, isDescribeQuery, isSelectQuery, Query, params, resolvePositional, selectEntries, snapshotAll, walk } from '@uwdata/mosaic-sql';
import type { SelectProjection, SqlExpression } from '@uwdata/mosaic-sql';
import type { SqlContext } from './sql-context.js';
import type { Cache, QueryEntry, QueryType } from './types.js';
import { tableByteLength } from './util/decode-ipc.js';
import { QueryResult } from './util/query-result.js';

interface GroupEntry {
  entry: QueryEntry;
  priority: number;
  index: number;
  removed?: boolean;
  shape?: QueryShape;
}

interface QueryGroup extends Array<GroupEntry> {
  query?: Query;
  result?: QueryResult;
  maps?: Array<Array<[string, string]>>;
  cacheKeys?: string[];
  cached?: Table[];
  issued?: number;
}

interface QueryShape {
  query: Query;
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
  generation: () => number,
  sqlContext: () => SqlContext
) {
  let pending: GroupEntry[] = [];
  let id: unknown = 0;
  const awaiting = new Set<QueryGroup>();

  function run(): void {
    // group queries into bundles that can be consolidated
    const context = sqlContext();
    const groups = entryGroups(pending, context);
    pending = [];
    id = 0;

    // build and issue consolidated queries
    for (const group of groups) {
      consolidate(group, enqueue, context, generation, cache);
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
    const extracts = group.cached ?? group.map(({ removed }, index) => {
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
      if (request.cache && !group.cached && (group.issued ?? issued) === generation()) {
        const key = group.cacheKeys?.[index];
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

function queryShape(query: QueryType | readonly QueryType[], context: SqlContext): QueryShape | undefined {
  if (!isSelectQuery(query)) return;
  const select = inspectSelect(query);
  if (select.where_clause || select.qualify || select.having || select.order_by
    || select.distinct || select.distinct_on?.length || select.windows?.length
    || select.group_by?.all != null || select.group_by?.totals) return;
  if (select.group_by?.expressions.some(expression => params(expression).length || hasDynamicShape(expression) || hasGroupingOperation(expression))) return;
  const projections = selectEntries(query);
  if (projections.some(({ alias, expr }) => alias === undefined || hasColumnExpansion(expr) || hasDynamicShape(expr))) return;
  const aliases = new Map(projections.map(({ alias, expr }) => [alias, expr]));
  const groupby = (select.group_by?.expressions ?? []).map(expression => {
    const alias = 'column' in expression && !expression.column.table
      ? aliases.get(expression.column.name.name)
      : undefined;
    return alias ?? resolvePositional(expression, projections)?.expr ?? expression;
  });
  const sorted = groupby.map(expression => ({ expression, key: context.structuralKey(expression) }))
    .sort((a, b) => a.key < b.key ? -1 : a.key > b.key ? 1 : 0);
  const grouping = select.group_by
    ? { ...select.group_by, expressions: sorted.map(({ expression }) => expression) }
    : null;
  const shape: SqlExpression = { select: { ...select, expressions: [], group_by: grouping } };
  const aggregate = !groupby.length && projections.some(({ expr }) => isAggregateExpression(expr));
  return {
    query,
    projections,
    groupby,
    key: context.cacheKey(JSON.stringify([aggregate, context.structuralKey(shape)])),
    fullKey: context.structuralKey(query)
  };
}

function entryGroups(entries: GroupEntry[], context: SqlContext): QueryGroup[] {
  const groups: QueryGroup[] = [];
  const grouped = new Map<string, QueryGroup>();
  for (const item of entries) {
    const { request } = item.entry;
    let shape: QueryShape | undefined;
    try {
      shape = request.options && Object.keys(request.options).length
        ? undefined
        : queryShape(request.query, context);
    } catch (error) {
      item.entry.result.reject(error);
      continue;
    }
    if (!shape) {
      groups.push([item]);
      continue;
    }
    item.shape = shape;
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

function consolidate(
  group: QueryGroup,
  enqueue: (entry: QueryEntry, priority?: number) => void,
  context: SqlContext,
  generation: () => number,
  cache: () => Cache
): void {
  const first = group[0].shape;
  if (!first || group.length < 2 || group.every(item => item.shape?.fullKey === first.fullKey)) {
    for (const { entry, priority } of group) enqueue(entry, priority);
    return;
  }
  const fields = new Map<string, [string, SqlExpression]>();
  group.maps = group.map(item => item.shape!.projections.map(({ alias, expr }) => {
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
  const originals = group.map(item => item.shape!.query.clone());
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
      const cached = group.map((item, index) => item.entry.request.cache ? cache().get(group.cacheKeys![index]) : undefined);
      if (cached.every((value): value is Table => value != null)) {
        group.cached = cached;
        return null;
      }
      return sql[sql.length - 1];
    }
  }, Math.min(...group.map(item => item.priority)));
}

function hasDynamicShape(expression: SqlExpression): boolean {
  let dynamic = false;
  walk(expression, node => {
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
  walk(expression, node => {
    if ('group' in node || 'grouping_sets' in node || 'cube' in node || 'rollup' in node) {
      grouping = true;
      return -1;
    }
  });
  return grouping;
}
