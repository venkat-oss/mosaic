import { Precision, Type, type DataType } from '@uwdata/flechette';
import * as sql from '@uwdata/mosaic-sql';
import { jsType } from './js-type.js';
import { isArrowTable } from './is-arrow-table.js';
import type { Coordinator } from '../Coordinator.js';
import type { ColumnDescription, FieldInfo, FieldInfoOptions, FieldInfoRequest } from '../types.js';

export const Count = 'count';
export const Nulls = 'nulls';
export const Max = 'max';
export const Min = 'min';
export const Distinct = 'distinct';
export const Stats = { Count, Nulls, Max, Min, Distinct };

export async function queryFieldInfo(
  mc: Coordinator,
  requests: FieldInfoRequest[],
  { query }: FieldInfoOptions = {}
): Promise<FieldInfo[]> {
  const context = mc.sqlContext;
  const execution = context.execution;
  if (!requests.length) return [];
  const read = async (input: sql.Query) => {
    const result = await mc.query(input);
    if (context.execution !== execution) throw new DOMException('SQL execution context changed during field metadata preparation.', 'AbortError');
    return result;
  };
  const describe = async (input: sql.Query): Promise<ColumnDescription[]> => {
    if (execution.targetDialect === sql.Dialect.DuckDB) {
      return Array.from(await read(sql.Query.describe(input)) as Iterable<ColumnDescription>);
    }
    const result = await read(input.clone().limit(0));
    if (!isArrowTable(result)) throw new TypeError('Field metadata requires an Arrow schema for this backend.');
    return result.schema.fields.map(field => ({
      column_name: field.name,
      column_type: field.metadata?.get('mosaic.sqlType') ?? arrowSqlType(field.type),
      null: field.nullable ? 'YES' : 'NO'
    }));
  };
  if (requests.length === 1 && requests[0].column === '*') {
    const { table } = requests[0];
    const description = await describe(sql.Query.from(sql.from(table)).select('*'));
    return description.map(desc => fieldDescription(table, desc.column_name, desc));
  }

  const entries = query && sql.selectEntries(query);
  const descriptions = query
    ? await describe(new sql.Query(sql.rootExpression(query)))
    : undefined;
  return Promise.all(requests.map(async ({ table, column, stats }) => {
    const expression = sql.asNode(column);
    const projected = projectedStats(expression);
    const index = entries?.findIndex(entry => entry.expr === expression || typeof column === 'string'
      && sql.columnParts(entry.expr)?.length === 1 && sql.columnParts(entry.expr)![0] === column);
    const projection = index === undefined ? undefined : entries![index];
    let source: sql.TableArg = table;
    let value: sql.SqlExpression = expression;
    let desc: ColumnDescription | undefined;
    if (descriptions) {
      if (projection?.alias === undefined) throw new TypeError('Metadata fields require a named projection in the descriptor query.');
      if (descriptions.length !== entries!.length) throw new TypeError('Metadata fields require one output column per requested projection.');
      desc = descriptions[index!];
      if (projected) {
        source = query!;
        value = sql.positionalRef(index! + 1);
      }
    } else {
      const descriptor = sql.Query.from(sql.from(table)).select({ __mosaic_field: expression });
      const columns = await describe(descriptor);
      if (columns.length !== 1) throw new TypeError('Metadata fields require one output column per requested projection.');
      [desc] = columns;
      if (projected) {
        source = descriptor;
        value = sql.column('__mosaic_field');
      }
    }
    if (!desc) throw new Error('Field description did not return the requested projection.');
    const info = fieldDescription(table, column, desc);
    if (!stats?.length) return info;
    const summary = sql.Query.from(sql.from(source)).select(stats.map(stat => ({
      [stat]: stat === Count ? sql.count(value)
        : stat === Distinct ? sql.count(value).distinct()
        : stat === Max ? sql.max(value)
        : stat === Min ? sql.min(value)
        : sql.count().where(sql.isNull(value))
    })));
    const [result] = await read(summary);
    return Object.assign(info, result);
  }));
}

function arrowSqlType(type: DataType): string {
  switch (type.typeId) {
    case Type.Dictionary: return arrowSqlType(type.dictionary);
    case Type.Null: return 'NULL';
    case Type.Int: return (type.signed ? '' : 'U') + ({ 8: 'TINYINT', 16: 'SMALLINT', 32: 'INTEGER', 64: 'BIGINT' }[type.bitWidth]);
    case Type.Float: return type.precision === Precision.DOUBLE ? 'DOUBLE' : 'FLOAT';
    case Type.Decimal: return `DECIMAL(${type.precision},${type.scale})`;
    case Type.Bool: return 'BOOLEAN';
    case Type.Utf8: case Type.LargeUtf8: case Type.Utf8View: return 'VARCHAR';
    case Type.Date: return 'DATE';
    case Type.Time: return 'TIME';
    case Type.Timestamp: return type.timezone ? 'TIMESTAMPTZ' : 'TIMESTAMP';
    case Type.List: case Type.LargeList: case Type.FixedSizeList: case Type.ListView: case Type.LargeListView: return 'LIST';
    case Type.Struct: return 'STRUCT';
    case Type.Map: return 'MAP';
    case Type.Binary: case Type.LargeBinary: case Type.FixedSizeBinary: case Type.BinaryView: return 'BLOB';
    default: throw new TypeError(`Unsupported Arrow metadata type: ${type.typeId}`);
  }
}

function projectedStats(expression: sql.SqlExpression): boolean {
  let projected = sql.isAggregateExpression(expression);
  sql.walk(expression, node => {
    if ('subquery' in node || sql.isResultQuery(node)) return 1;
    if ('window_function' in node || 'unnest' in node) projected = true;
  });
  return projected;
}

function fieldDescription(
  table: sql.TableArg,
  column: string | sql.SqlRoot,
  desc: ColumnDescription
): FieldInfo {
  return { table, column, sqlType: desc.column_type, type: jsType(desc.column_type), nullable: desc.null === 'YES' };
}
