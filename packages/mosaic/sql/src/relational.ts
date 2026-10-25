import { rootExpression } from './bindings.js';
import { asLiteral, asNode, isQueryExpression, tableRef } from './expression.js';
import { createExecutionContext, native } from './runtime.js';
import type { SqlExecutionContext } from './runtime.js';
import { compile } from './compile.js';
import type { ExprValue, SqlExpression, SqlExpressionHandle, SqlRoot } from './types.js';

export type TableArg = string | readonly string[] | SqlRoot;
export type Sample = ReturnType<typeof native.sample>;
export type SampleMethod = 'reservoir' | 'bernoulli' | 'system';
export type JoinType = 'INNER' | 'LEFT' | 'RIGHT' | 'FULL' | 'SEMI' | 'ANTI';
export interface JoinOptions {
  readonly type?: JoinType;
  readonly on?: ExprValue;
  readonly using?: readonly (string | SqlRoot)[];
}

export function asRelation(value: TableArg, alias?: string, columnNames?: readonly string[]): SqlExpression {
  const expression = typeof value === 'string' || Array.isArray(value)
    ? tableRef(value)!
    : rootExpression(value as SqlRoot);
  const columns = columnNames?.map(name => native.identifier(name, true).identifier);
  if ('table_sample' in expression && expression.table_sample.this && expression.table_sample.sample) {
    if (alias === undefined && columns === undefined) return expression;
    const { this: relation, sample, ...options } = expression.table_sample;
    return native.tableSample(asRelation(relation, alias, columnNames), sample, options);
  }
  if ('table' in expression) {
    return alias === undefined && columns === undefined ? expression : native.table(expression.table.name, {
      ...expression.table,
      alias: alias === undefined ? expression.table.alias : native.identifier(alias, true).identifier,
      alias_explicit_as: alias === undefined ? expression.table.alias_explicit_as : true,
      column_aliases: columns ?? expression.table.column_aliases
    });
  }
  if ('subquery' in expression) {
    return alias === undefined && columns === undefined ? expression : native.subquery(expression.subquery.this, {
      ...expression.subquery,
      alias: alias === undefined ? expression.subquery.alias : native.identifier(alias, true).identifier,
      column_aliases: columns ?? expression.subquery.column_aliases
    });
  }
  if (isQueryExpression(expression)) {
    return native.subquery(expression, {
      alias: alias === undefined ? null : native.identifier(alias, true).identifier,
      column_aliases: columns ?? []
    });
  }
  if (alias !== undefined) return native.subquery(expression, {
    alias: native.identifier(alias, true).identifier,
    column_aliases: columns ?? []
  });
  return expression;
}

export class From implements SqlExpressionHandle {
  constructor(readonly expression: SqlExpression) {}

  as(alias: string, columnNames?: readonly string[]): From {
    return new From(asRelation(this.expression, alias, columnNames));
  }

  toString(context: SqlExecutionContext = createExecutionContext()): string {
    return compile([this], context)[0];
  }
}

export function from(table: TableArg, alias?: string, sampling?: Sample, columnNames?: readonly string[]): From {
  const expression = asRelation(table, alias, columnNames);
  return new From(sampling ? native.tableSample(expression, sampling) : expression);
}

export function subquery(query: SqlRoot): SqlExpression {
  return native.subquery(rootExpression(query));
}

export function cte(name: string, query: SqlRoot, materialized: boolean | null = null, columnNames: readonly string[] = []): SqlExpression {
  return native.cte(native.identifier(name, true).identifier, rootExpression(query), {
    materialized,
    columns: columnNames.map(name => native.identifier(name, true).identifier)
  });
}

export function tuple(values: readonly ExprValue[] | SqlRoot): SqlExpression {
  if (!Array.isArray(values)) {
    const expression = rootExpression(values as SqlRoot);
    if (!('tuple' in expression)) throw new TypeError('Expected a native tuple or list of values.');
    return expression;
  }
  return native.tuple(values.map(asLiteral));
}

export function values(rows: readonly (readonly ExprValue[] | SqlRoot)[]): SqlExpression {
  return native.values(rows.map(row => {
    const expression = tuple(row);
    if (!('tuple' in expression)) throw new TypeError('VALUES requires tuple rows.');
    return expression.tuple;
  }));
}

export function positionalRef(index: number): SqlExpression {
  if (!Number.isSafeInteger(index) || index < 1) throw new RangeError('SQL column positions are positive integers.');
  return native.column(native.identifier('#' + index, false).identifier);
}

export function sample(size: number, percent = false, method?: SampleMethod, seed?: number): Sample {
  if (!Number.isFinite(size) || size < 0) throw new RangeError('Sample size must be a non-negative finite number.');
  const selected = method ?? (percent ? 'bernoulli' : 'reservoir');
  return native.sample(asLiteral(size), {
    is_percent: percent,
    method: selected === 'bernoulli' ? 'Bernoulli' : selected === 'system' ? 'System' : 'Reservoir',
    seed: seed === undefined ? null : asLiteral(seed)
  });
}

function makeJoin(left: TableArg, right: TableArg, variant: 'regular' | 'natural' | 'cross' | 'positional' | 'asof', options: JoinOptions): SqlExpression {
  if (options.on !== undefined && options.using !== undefined) throw new TypeError('Only one join condition (on or using) can be applied.');
  const type = options.type ?? 'INNER';
  type Kind = NonNullable<Parameters<typeof native.join>[1]>['kind'];
  let kind: Kind;
  if (variant === 'cross') kind = 'Cross';
  else if (variant === 'positional') kind = 'Positional';
  else if (variant === 'asof') {
    if (options.on === undefined && options.using === undefined) throw new TypeError('ASOF join requires a join condition.');
    kind = type === 'LEFT' ? 'AsOfLeft' : type === 'RIGHT' ? 'AsOfRight' : type === 'FULL' ? 'AsOfFull'
      : type === 'SEMI' ? 'AsOfSemi' : type === 'ANTI' ? 'AsOfAnti' : 'AsOf';
  } else if (variant === 'natural') {
    kind = type === 'LEFT' ? 'NaturalLeft' : type === 'RIGHT' ? 'NaturalRight' : type === 'FULL' ? 'NaturalFull'
      : type === 'SEMI' ? 'NaturalSemi' : type === 'ANTI' ? 'NaturalAnti' : 'Natural';
  } else {
    kind = type === 'LEFT' ? 'Left' : type === 'RIGHT' ? 'Right' : type === 'FULL' ? 'Full'
      : type === 'SEMI' ? 'Semi' : type === 'ANTI' ? 'Anti' : 'Inner';
  }
  const using = (options.using ?? []).map(value => {
    const expression = asNode(value);
    if (!('column' in expression) || expression.column.table) throw new TypeError('JOIN USING requires unqualified column names.');
    return expression.column.name;
  });
  return native.joinedTable(asRelation(left), [native.join(asRelation(right), {
    kind,
    on: options.on === undefined ? null : asNode(options.on),
    using
  }).join]);
}

export function join(left: TableArg, right: TableArg, options: JoinOptions = {}): SqlExpression {
  return makeJoin(left, right, options.on !== undefined || options.using !== undefined ? 'regular' : 'natural', options);
}

export function cross_join(left: TableArg, right: TableArg): SqlExpression {
  return makeJoin(left, right, 'cross', {});
}

export function positional_join(left: TableArg, right: TableArg): SqlExpression {
  return makeJoin(left, right, 'positional', {});
}

export function asof_join(left: TableArg, right: TableArg, options: JoinOptions): SqlExpression {
  return makeJoin(left, right, 'asof', options);
}
