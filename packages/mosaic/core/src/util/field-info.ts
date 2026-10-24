import type { AggregateNode } from '@uwdata/mosaic-sql';
import { Query, asTableRef, count, isAggregateExpression, isNode, isNull, max, min, sql } from '@uwdata/mosaic-sql';
import * as nativeSQL from '@uwdata/mosaic-sql/native';
import { jsType } from './js-type.js';
import type { Coordinator } from '../Coordinator.js';
import type { FieldInfoRequest, FieldInfo, NativeFieldInfoRequest, NativeFieldInfo, NativeFieldInfoOptions, Stat, FieldRef, ColumnDescription } from '../types.js';

export const Count = 'count';
export const Nulls = 'nulls';
export const Max = 'max';
export const Min = 'min';
export const Distinct = 'distinct';
export const Stats = { Count, Nulls, Max, Min, Distinct };

const statMap: Record<Stat, (column: FieldRef) => AggregateNode> = {
  [Count]: count,
  [Distinct]: column => count(column).distinct(),
  [Max]: max,
  [Min]: min,
  [Nulls]: column => count().where(isNull(column))
};

/**
 * Get summary stats of the given column
 * @param field Field information request
 * @returns Query for field statistics
 */
function summarize({ table, column, stats }: FieldInfoRequest): Query {
  return Query
    .from(table)
    .select(Array.from(stats!, s => ({ [s]: statMap[s](column) })));
}

/**
 * Queries information about fields of a table.
 * If the `fields` array contains a single field with the column set to '*',
 * the function will retrieve and return the table information using `getTableInfo`.
 * Otherwise, it will query individual field information using `getFieldInfo`
 * for each field in the `fields` array.
 * @param mc A Mosaic coordinator.
 * @param fields Array of field information requests.
 * @returns Promise resolving to array of field information.
 */
export function queryFieldInfo(mc: Coordinator, fields: FieldInfoRequest[]): Promise<FieldInfo[]>;
export function queryFieldInfo(mc: Coordinator, fields: NativeFieldInfoRequest[], options?: NativeFieldInfoOptions): Promise<NativeFieldInfo[]>;
export async function queryFieldInfo(
  mc: Coordinator,
  fields: FieldInfoRequest[] | NativeFieldInfoRequest[],
  options?: NativeFieldInfoOptions
): Promise<(FieldInfo | NativeFieldInfo)[]> {
  if (mc.nativeContext) return nativeFieldInfo(mc, fields as NativeFieldInfoRequest[], options);
  if (options || fields.some(field => typeof field.table !== 'string'
    || typeof field.column !== 'string' && !isNode(field.column))) {
    throw new TypeError('Native field metadata requires a native coordinator.');
  }
  const legacyFields = fields as FieldInfoRequest[];
  if (fields.length === 1 && fields[0].column === '*') {
    return getTableInfo(mc, legacyFields[0].table);
  } else {
    return (await Promise
      .all(legacyFields.map(f => getFieldInfo(mc, f))))
      .filter((x): x is FieldInfo => x !== undefined);
  }
}

async function nativeFieldInfo(
  mc: Coordinator,
  requests: NativeFieldInfoRequest[],
  { query }: NativeFieldInfoOptions = {}
): Promise<NativeFieldInfo[]> {
  const context = mc.nativeContext!;
  const execution = context.execution;
  if (!requests.length) return [];
  if (execution.targetDialect !== nativeSQL.Dialect.DuckDB) {
    throw new TypeError('Native field metadata currently requires a DuckDB target.');
  }
  const read = async (input: nativeSQL.Query) => {
    const result = await mc.query(input);
    if (context.execution !== execution) throw new DOMException('SQL execution context changed during field metadata preparation.', 'AbortError');
    return result;
  };
  if (requests.length === 1 && requests[0].column === '*') {
    const { table } = requests[0];
    const description = await read(nativeSQL.Query.describe(nativeSQL.Query.from(nativeSQL.from(table)).select('*')));
    return Array.from(description as Iterable<ColumnDescription>, desc => nativeDescription(table, desc.column_name, desc));
  }

  const entries = query && nativeSQL.selectEntries(query);
  const descriptions = query
    ? Array.from(await read(nativeSQL.Query.describe(query)) as Iterable<ColumnDescription>)
    : undefined;
  return Promise.all(requests.map(async ({ table, column, stats }) => {
    const expression = nativeSQL.asNode(column);
    const projected = nativeProjectedStats(expression);
    const index = entries?.findIndex(entry => entry.expr === expression || typeof column === 'string'
      && nativeSQL.columnParts(entry.expr)?.length === 1 && nativeSQL.columnParts(entry.expr)![0] === column);
    const projection = index === undefined ? undefined : entries![index];
    let source: nativeSQL.TableArg = table;
    let value: nativeSQL.SqlExpression = expression;
    let desc: ColumnDescription | undefined;
    if (descriptions) {
      if (projection?.alias === undefined) throw new TypeError('Native metadata fields require a named projection in the descriptor query.');
      if (descriptions.length !== entries!.length) throw new TypeError('Native metadata fields require one output column per requested projection.');
      desc = descriptions[index!];
      if (projected) {
        source = query!;
        value = nativeSQL.positionalRef(index! + 1);
      }
    } else {
      const descriptor = nativeSQL.Query.from(nativeSQL.from(table)).select({ __mosaic_field: expression });
      const columns = Array.from(await read(nativeSQL.Query.describe(descriptor)) as Iterable<ColumnDescription>);
      if (columns.length !== 1) throw new TypeError('Native metadata fields require one output column per requested projection.');
      [desc] = columns;
      if (projected) {
        source = descriptor;
        value = nativeSQL.column('__mosaic_field');
      }
    }
    if (!desc) throw new Error('Native field description did not return the requested projection.');
    const info = nativeDescription(table, column, desc);
    if (!stats?.length) return info;
    const summary = nativeSQL.Query.from(nativeSQL.from(source)).select(stats.map(stat => ({
      [stat]: stat === Count ? nativeSQL.count(value)
        : stat === Distinct ? nativeSQL.count(value).distinct()
        : stat === Max ? nativeSQL.max(value)
        : stat === Min ? nativeSQL.min(value)
        : nativeSQL.count().where(nativeSQL.isNull(value))
    })));
    const [result] = await read(summary);
    return Object.assign(info, result);
  }));
}

function nativeProjectedStats(expression: nativeSQL.SqlExpression): boolean {
  let projected = nativeSQL.isAggregateExpression(expression);
  nativeSQL.walk(expression, node => {
    if ('subquery' in node || nativeSQL.isResultQuery(node)) return 1;
    if ('window_function' in node || 'unnest' in node) projected = true;
  });
  return projected;
}

function nativeDescription(
  table: nativeSQL.TableArg,
  column: string | nativeSQL.SqlRoot,
  desc: ColumnDescription
): NativeFieldInfo {
  return { table, column, sqlType: desc.column_type, type: jsType(desc.column_type), nullable: desc.null === 'YES' };
}

/**
 * Get information about a single field of a table.
 * @param mc A Mosaic coordinator.
 * @param field Field information request.
 * @returns Promise resolving to field information.
 */
async function getFieldInfo(mc: Coordinator, { table, column, stats }: FieldInfoRequest): Promise<FieldInfo> {
  const isAggregate = isNode(column) && isAggregateExpression(column);

  // generate and issue a query for field metadata info
  // use GROUP BY ALL to differentiate & consolidate aggregates
  const q = Query
    .from({ source: table })
    .select({ column }, isAggregate ? '*' : {})
    .groupby(isAggregate ? sql`ALL` : []);

  let desc: ColumnDescription | undefined;
  try {
    [desc] = Array.from(
      await mc.query(Query.describe(q))
    ) as ColumnDescription[];
  } catch {
    // ignore query failure, use dummy description below
  }

  // provide dummy description node upon query failure or empty result
  // this handles true aggregates within window functions
  // DuckDB fails to handle these when using GROUP BY ALL
  desc ??= {
    column_name: 'column',
    column_type: 'DOUBLE',
    null: 'YES'
  };

  const info: FieldInfo = {
    table,
    column: `${column}`,
    sqlType: desc.column_type,
    type: jsType(desc.column_type),
    nullable: desc.null === 'YES'
  };

  // no need for summary statistics
  if (!stats?.length) return info;

  // query for summary stats
  const [result] = await mc.query(summarize({ table, column, stats }));

  // extract summary stats, copy to field info, and return
  return Object.assign(info, result);
}

/**
 * Get information about the fields of a table.
 * @param mc A Mosaic coordinator.
 * @param table The table name.
 * @returns Promise resolving to array of field information.
 */
async function getTableInfo(mc: Coordinator, table: string): Promise<FieldInfo[]> {
  const result = Array.from(
    await mc.query(`DESC ${asTableRef(table)}`)
  ) as ColumnDescription[];
  return result.map(desc => ({
    table,
    column: desc.column_name,
    sqlType: desc.column_type,
    type: jsType(desc.column_type),
    nullable: desc.null === 'YES'
  }));
}
