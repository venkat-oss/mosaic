import type { ast } from '#polyglot';
import { isParamLike } from '../util/type-check.js';
import { ast as syntax, native, createExecutionContext } from './runtime.js';
import type { SqlExecutionContext } from './runtime.js';
import { BindingScope, copyBinding, fields, rootExpression } from './bindings.js';
import { asLiteral, asNode, isExpressionHandle } from './expression.js';
import { parseExpression } from './ingress.js';
import { and } from './operators.js';
import { mapTree } from './tree.js';
import { compile } from './compile.js';
import { asRelation, cte, sample as makeSample } from './relational.js';
import type { Sample, SampleMethod, TableArg } from './relational.js';
import { namedWindows, syncWindowTemplate } from './window.js';
import type { WindowInput } from './window.js';
import type { ExprValue, MaybeArray, SqlExpression, SqlExpressionHandle, SqlRoot } from './types.js';

export type SelectEntry = ExprValue | Record<string, ExprValue> | readonly [string, ExprValue];
export type SelectInput = MaybeArray<SelectEntry>;
export type FromEntry = string | SqlRoot | Record<string, TableArg> | readonly [string, TableArg];
export type FromInput = MaybeArray<FromEntry | null | undefined>;
export type FilterInput = MaybeArray<ExprValue>;
export type WithInput = MaybeArray<SqlRoot | Record<string, SqlRoot> | null | undefined>;

export function isQuery(value: unknown): value is Query {
  return value instanceof Query;
}

export function inspectSelect(input: SqlRoot): ast.Select {
  const expression = rootExpression(input);
  if (!('select' in expression)) throw new TypeError('Expected a native SELECT query.');
  return expression.select;
}

export function isSelectQuery(value: unknown): value is Query {
  return isQuery(value) && 'select' in value.expression;
}

export function isDescribeQuery(value: unknown): value is Query {
  return isQuery(value) && 'describe' in value.expression;
}

export function isResultQuery(value: unknown): value is SqlRoot {
  if (!syntax.isExpressionValue(value) && !isExpressionHandle(value)) return false;
  const expression = rootExpression(value);
  return 'select' in expression || 'describe' in expression || 'union' in expression
    || 'intersect' in expression || 'except' in expression || 'values' in expression || 'pivot' in expression;
}

export interface SelectProjection {
  readonly alias: string | undefined;
  readonly expr: SqlExpression;
}

export function selectEntries(input: SqlRoot): SelectProjection[] {
  return inspectSelect(input).expressions.map(expression => 'alias' in expression
    ? { alias: expression.alias.alias.name, expr: expression.alias.this }
    : { alias: outputName(expression, false), expr: expression });
}

function outputName(expression: SqlExpression, dynamic = true): string | undefined {
  if ('alias' in expression) return expression.alias.alias.name;
  if ('column' in expression) return expression.column.name.name;
  if ('dot' in expression) return expression.dot.field.name;
  if (dynamic && 'parameter' in expression) return fields(expression)[0]?.column;
}

function isUnaliasedExpression(value: unknown): value is SqlExpression {
  if (!syntax.isExpressionValue(value)) return false;
  if ('null' in value && value.null === null) return true;
  const payload: unknown = Object.values(value)[0];
  return payload !== null && typeof payload === 'object'
    && !Array.isArray(payload) && !(payload instanceof Date) && !(payload instanceof RegExp)
    && !syntax.isExpressionValue(payload)
    && !(isExpressionHandle(payload) && (Object.keys(payload).length === 1
      || Object.getPrototypeOf(payload) !== Object.prototype && Object.getPrototypeOf(payload) !== null))
    && !isParamLike(payload);
}

export class Query implements SqlExpressionHandle {
  private node: SqlExpression;
  private implicitSelect = false;
  private plainDistinct = false;
  readonly bindings: BindingScope;

  constructor(expression: SqlExpression = native.select(), bindings = new BindingScope()) {
    this.bindings = bindings;
    this.node = expression;
    this.plainDistinct = 'select' in expression && expression.select.distinct && !expression.select.distinct_on?.length;
    if ('select' in expression && !expression.select.expressions.length) {
      expression.select.expressions = [native.star()];
      this.implicitSelect = true;
    }
  }

  get expression(): SqlExpression {
    return this.node;
  }

  private selectData(): ast.Select {
    if (!('select' in this.node)) throw new TypeError('Expected a native SELECT query.');
    return this.node.select;
  }

  private statementData(): Pick<ast.Select, 'with' | 'order_by'> {
    const node = this.node;
    if ('select' in node) return node.select;
    if ('union' in node) return node.union;
    if ('intersect' in node) return node.intersect;
    if ('except' in node) return node.except;
    throw new TypeError('Expected a native SELECT or set query.');
  }

  private setData(): Extract<ReturnType<typeof native.setOperation>, { union: object }>['union'] {
    const node = this.node;
    if ('union' in node) return node.union;
    if ('intersect' in node) return node.intersect;
    if ('except' in node) return node.except;
    throw new TypeError('Expected a native set query.');
  }

  private setLimit(limit: ReturnType<typeof native.limit>): this {
    if ('select' in this.node) this.node.select.limit = limit.limit;
    else this.setData().limit = limit;
    return this;
  }

  static select(...values: SelectInput[]): Query {
    return new Query().select(...values);
  }

  static from(...values: FromInput[]): Query {
    return new Query().from(...values);
  }

  static with(...values: WithInput[]): WithQuery {
    return new WithQuery().with(...values);
  }

  static describe(input: SqlRoot): Query {
    return new Query(native.describe(rootExpression(input)));
  }

  static pivot(source: TableArg): PivotQuery {
    return new PivotQuery(source);
  }

  static union(...queries: MaybeArray<SqlRoot>[]): Query {
    return Query.setOperation('union', queries, false, false);
  }

  static unionAll(...queries: MaybeArray<SqlRoot>[]): Query {
    return Query.setOperation('union', queries, true, false);
  }

  static unionByName(...queries: MaybeArray<SqlRoot>[]): Query {
    return Query.setOperation('union', queries, false, true);
  }

  static unionAllByName(...queries: MaybeArray<SqlRoot>[]): Query {
    return Query.setOperation('union', queries, true, true);
  }

  static intersect(...queries: MaybeArray<SqlRoot>[]): Query {
    return Query.setOperation('intersect', queries, false, false);
  }

  static intersectAll(...queries: MaybeArray<SqlRoot>[]): Query {
    return Query.setOperation('intersect', queries, true, false);
  }

  static except(...queries: MaybeArray<SqlRoot>[]): Query {
    return Query.setOperation('except', queries, false, false);
  }

  static exceptAll(...queries: MaybeArray<SqlRoot>[]): Query {
    return Query.setOperation('except', queries, true, false);
  }

  private static setOperation(operator: 'union' | 'intersect' | 'except', inputs: MaybeArray<SqlRoot>[], all: boolean, byName: boolean): Query {
    const queries = inputs.flat().map(rootExpression);
    if (!queries.length) throw new TypeError('A set operation requires at least one query.');
    if (queries.length === 1) return new Query(native.select([native.star()], {
      from: native.from([native.subquery(queries[0])]).from
    }));
    const operands = queries.map(query => 'subquery' in query ? query : native.subquery(query));
    return new Query(operands.slice(1).reduce<SqlExpression>((left, right) => native.setOperation(operator, left, right, {
      all, distinct: !all, by_name: byName
    }), operands[0]));
  }

  clone(): Query {
    const root = this.node;
    const copy = mapTree(root, node => node === root || 'describe' in root && node === root.describe.target ? undefined : node, new Map(), true, copyBinding);
    const query = new Query(copy);
    query.implicitSelect = this.implicitSelect;
    query.plainDistinct = this.plainDistinct;
    return query;
  }

  select(...values: SelectInput[]): this {
    const selected = this.selectData();
    const replacements = new Map<string | SqlExpression, SqlExpression | null>();
    const add = (value: ExprValue, alias?: string) => {
      if (value == null) {
        if (alias !== undefined) replacements.set(alias, null);
        return;
      }
      const node = asNode(value);
      const name = alias ?? (typeof value === 'string' ? value : outputName(node));
      const projection = alias !== undefined
        ? native.alias(node, native.identifier(alias, true).identifier)
        : node;
      replacements.set(name ?? node, projection);
    };
    for (const value of values.flat()) {
      if (value == null) continue;
      if (typeof value !== 'object' || value instanceof Date || value instanceof RegExp || isUnaliasedExpression(value) || isExpressionHandle(value) || isParamLike(value)) {
        add(value);
      } else if (Array.isArray(value)) {
        add(value[1], value[0]);
      } else {
        if (Object.getPrototypeOf(value) !== Object.prototype && Object.getPrototypeOf(value) !== null) {
          throw new TypeError('Expected a native SQL expression or a plain alias map.');
        }
        for (const [name, expression] of Object.entries(value)) add(expression, name);
      }
    }
    if (replacements.size && this.implicitSelect) selected.expressions = [];
    selected.expressions = selected.expressions
      .filter(expression => !replacements.has(outputName(expression) ?? expression))
      .concat([...replacements.values()].filter((value): value is SqlExpression => value !== null));
    if (selected.expressions.length) {
      if (replacements.size) this.implicitSelect = false;
    } else {
      selected.expressions = [native.star()];
      this.implicitSelect = true;
    }
    return this;
  }

  setSelect(...values: SelectInput[]): this {
    this.selectData().expressions = [];
    return this.select(...values);
  }

  from(...values: FromInput[]): this {
    const selected = this.selectData();
    const relations: SqlExpression[] = [];
    const add = (value: TableArg, alias?: string) => {
      relations.push(asRelation(value, alias));
    };
    for (const value of values.flat()) {
      if (value == null) continue;
      if (typeof value === 'string' || isUnaliasedExpression(value) || isExpressionHandle(value)) {
        add(value);
      } else if (Array.isArray(value)) {
        add(value[1], value[0]);
      } else {
        if (Object.getPrototypeOf(value) !== Object.prototype && Object.getPrototypeOf(value) !== null) {
          throw new TypeError('Expected a native SQL expression or a plain alias map.');
        }
        for (const [alias, relation] of Object.entries(value)) add(relation, alias);
      }
    }
    selected.from = native.from([...(selected.from?.expressions ?? []), ...relations]).from;
    return this;
  }

  setFrom(...values: FromInput[]): this {
    this.selectData().from = null;
    return this.from(...values);
  }

  with(...values: WithInput[]): this {
    const statement = this.statementData();
    const clauses: NonNullable<ast.Select['with']>['ctes'] = [];
    for (const value of values.flat()) {
      if (value == null) continue;
      if (isUnaliasedExpression(value) || isExpressionHandle(value)) {
        const expression = rootExpression(value);
        if (!('cte' in expression)) throw new TypeError('WITH requires named common table expressions.');
        clauses.push(expression.cte);
      } else {
        if (Object.getPrototypeOf(value) !== Object.prototype && Object.getPrototypeOf(value) !== null) {
          throw new TypeError('WITH requires native CTEs or a plain alias map.');
        }
        for (const [name, query] of Object.entries(value)) {
          const expression = cte(name, query);
          if ('cte' in expression) clauses.push(expression.cte);
        }
      }
    }
    const { ctes: existing, ...options } = statement.with ?? { ctes: [] };
    const combined = [...existing, ...clauses];
    statement.with = combined.length ? native.withClause(combined, options).with : null;
    return this;
  }

  protected copyWith<T extends Query>(query: T): T {
    query.statementData().with = this.statementData().with;
    return query;
  }

  setWith(...values: WithInput[]): this {
    this.statementData().with = null;
    return this.with(...values);
  }

  window(...values: WindowInput[]): this {
    const selected = this.selectData();
    const windows = namedWindows(values);
    const names = new Set(windows.map(window => window.name.name));
    const combined = [...(selected.windows ?? []).filter(window => !names.has(window.name.name)), ...windows];
    selected.windows = combined.length ? combined : null;
    syncWindowTemplate(this.node);
    return this;
  }

  sample(value?: number | Sample | null, method?: SampleMethod, seed?: number): this {
    const sampling = typeof value === 'number'
      ? makeSample(value > 0 && value < 1 ? value * 100 : Math.floor(value), value > 0 && value < 1, method, seed)
      : value ?? null;
    this.selectData().sample = sampling ? { ...sampling, is_using_sample: true, use_sample_keyword: true } : null;
    return this;
  }

  where(...values: FilterInput[]): this {
    const selected = this.selectData();
    const clauses = values.flat().filter(value => value != null)
      .map(value => typeof value === 'string' ? parseExpression(value) : asNode(value));
    if (selected.where_clause) clauses.unshift(selected.where_clause.this);
    if (clauses.length) selected.where_clause = native.where(and(clauses)).where;
    return this;
  }

  setWhere(...values: FilterInput[]): this {
    this.selectData().where_clause = null;
    return this.where(...values);
  }

  having(...values: FilterInput[]): this {
    const selected = this.selectData();
    const clauses = values.flat().filter(value => value != null)
      .map(value => typeof value === 'string' ? parseExpression(value) : asNode(value));
    if (selected.having) clauses.unshift(selected.having.this);
    if (clauses.length) selected.having = native.having(and(clauses)).having;
    return this;
  }

  setHaving(...values: FilterInput[]): this {
    this.selectData().having = null;
    return this.having(...values);
  }

  qualify(...values: FilterInput[]): this {
    const selected = this.selectData();
    const clauses = values.flat().filter(value => value != null)
      .map(value => typeof value === 'string' ? parseExpression(value) : asNode(value));
    if (selected.qualify) clauses.unshift(selected.qualify.this);
    if (clauses.length) selected.qualify = native.qualify(and(clauses)).qualify;
    return this;
  }

  setQualify(...values: FilterInput[]): this {
    this.selectData().qualify = null;
    return this.qualify(...values);
  }

  groupby(...values: MaybeArray<ExprValue>[]): this {
    const selected = this.selectData();
    const expressions = values.flat().filter(value => value != null).map(asNode);
    const combined = [...(selected.group_by?.expressions ?? []), ...expressions];
    const isAll = (value: SqlExpression) => 'var' in value && value.var.this === 'ALL';
    const all = selected.group_by?.all === true || combined.some(isAll);
    if (all && combined.some(value => !isAll(value))) throw new TypeError('GROUP BY ALL cannot be combined with explicit grouping expressions.');
    selected.group_by = all || combined.length ? native.groupBy(all ? [] : combined, { all: all ? true : selected.group_by?.all ?? null }).group_by : null;
    return this;
  }

  setGroupby(...values: MaybeArray<ExprValue>[]): this {
    this.selectData().group_by = null;
    return this.groupby(...values);
  }

  orderby(...values: MaybeArray<ExprValue>[]): this {
    const selected = this.statementData();
    const expressions = values.flat().filter(value => value != null).map(value => {
      const node = asNode(value);
      return 'ordered' in node ? node.ordered : native.ordered(node).ordered;
    });
    const combined = [...(selected.order_by?.expressions ?? []), ...expressions];
    selected.order_by = combined.length ? native.orderBy(combined).order_by : null;
    return this;
  }

  setOrderby(...values: MaybeArray<ExprValue>[]): this {
    this.statementData().order_by = null;
    return this.orderby(...values);
  }

  limit(value: ExprValue): this {
    return this.setLimit(native.limit(asNode(value)));
  }

  limitPercent(value: ExprValue): this {
    return this.setLimit(native.limit(asNode(value), { percent: true }));
  }

  offset(value: ExprValue): this {
    const expression = asNode(value);
    if ('select' in this.node) this.node.select.offset = native.offset(expression).offset;
    else this.setData().offset = expression;
    return this;
  }

  distinct(value = true): this {
    this.plainDistinct = !!value;
    const selected = this.selectData();
    selected.distinct = this.plainDistinct || !!selected.distinct_on?.length;
    return this;
  }

  distinctOn(...values: MaybeArray<ExprValue>[]): this {
    const selected = this.selectData();
    const expressions = [...(selected.distinct_on ?? []), ...values.flat().filter(value => value != null).map(asNode)];
    selected.distinct_on = expressions.length ? expressions : null;
    selected.distinct = this.plainDistinct || !!expressions.length;
    return this;
  }

  setDistinctOn(...values: MaybeArray<ExprValue>[]): this {
    this.selectData().distinct_on = null;
    return this.distinctOn(...values);
  }

  describe(): Query {
    return Query.describe(this);
  }

  toString(context: SqlExecutionContext = createExecutionContext()): string {
    return compile([this], context).join(';\n');
  }
}

class WithQuery extends Query {
  pivot(source: TableArg): PivotQuery { return this.copyWith(Query.pivot(source)); }
  union(...queries: MaybeArray<SqlRoot>[]): Query { return this.copyWith(Query.union(...queries)); }
  unionAll(...queries: MaybeArray<SqlRoot>[]): Query { return this.copyWith(Query.unionAll(...queries)); }
  unionByName(...queries: MaybeArray<SqlRoot>[]): Query { return this.copyWith(Query.unionByName(...queries)); }
  unionAllByName(...queries: MaybeArray<SqlRoot>[]): Query { return this.copyWith(Query.unionAllByName(...queries)); }
  intersect(...queries: MaybeArray<SqlRoot>[]): Query { return this.copyWith(Query.intersect(...queries)); }
  intersectAll(...queries: MaybeArray<SqlRoot>[]): Query { return this.copyWith(Query.intersectAll(...queries)); }
  except(...queries: MaybeArray<SqlRoot>[]): Query { return this.copyWith(Query.except(...queries)); }
  exceptAll(...queries: MaybeArray<SqlRoot>[]): Query { return this.copyWith(Query.exceptAll(...queries)); }
}

export function isPivotQuery(value: unknown): value is PivotQuery {
  return value instanceof PivotQuery;
}

export class PivotQuery extends Query {
  constructor(source: TableArg, expression?: SqlExpression) {
    super(expression ?? native.select([native.star()], {
      from: native.from([native.subquery(native.pivot(asRelation(source)))]).from
    }));
  }

  private pivotData(): ReturnType<typeof native.pivot>['pivot'] {
    const source = inspectSelect(this).from?.expressions[0];
    if (source && 'subquery' in source && 'pivot' in source.subquery.this) return source.subquery.this.pivot;
    throw new TypeError('Expected a native PIVOT query.');
  }

  on(...values: MaybeArray<ExprValue>[]): this {
    const pivot = this.pivotData();
    const expressions = [...pivot.expressions];
    const previous = expressions[expressions.length - 1];
    let selected: SqlExpression[] | undefined;
    if (previous && 'in' in previous) {
      selected = previous.in.expressions;
      expressions.pop();
      if (!('tuple' in previous.in.this) || previous.in.this.tuple.expressions.length) expressions.push(previous.in.this);
    }
    expressions.push(...values.flat().filter(value => value != null).map(asNode));
    if (selected) {
      const last = expressions.pop() ?? native.tuple([]);
      expressions.push(native.inList(last, selected));
    }
    pivot.expressions = expressions;
    return this;
  }

  in(...values: MaybeArray<ExprValue>[]): this {
    const selected = values.flat().map(asLiteral);
    if (!selected.length) throw new TypeError('PivotQuery.in requires at least one value.');
    const pivot = this.pivotData();
    const expressions = [...pivot.expressions];
    const previous = expressions.pop() ?? native.tuple([]);
    expressions.push('in' in previous
      ? native.inList(previous.in.this, [...previous.in.expressions, ...selected])
      : native.inList(previous, selected));
    pivot.expressions = expressions;
    return this;
  }

  using(...values: SelectInput[]): this {
    if (!values.flat().some(value => value != null)) throw new TypeError('PivotQuery.using requires at least one expression.');
    const expressions = inspectSelect(Query.select(...values)).expressions;
    if (expressions.length === 1 && 'star' in expressions[0]) throw new TypeError('PivotQuery.using requires at least one aggregate expression.');
    const pivot = this.pivotData();
    pivot.using = [...pivot.using, ...expressions];
    return this;
  }

  groupby(...values: MaybeArray<ExprValue>[]): this {
    const pivot = this.pivotData();
    const previous = pivot.group && 'group' in pivot.group ? pivot.group.group.expressions : [];
    const expressions = [...previous, ...values.flat().filter(value => value != null).map(asNode)];
    pivot.group = expressions.length ? native.group(expressions) : null;
    return this;
  }

  setGroupby(...values: MaybeArray<ExprValue>[]): this {
    this.pivotData().group = null;
    return this.groupby(...values);
  }

  clone(): PivotQuery {
    const root = this.expression;
    const copy = mapTree(root, node => node === root || 'subquery' in node || 'pivot' in node ? undefined : node, new Map(), true, copyBinding);
    return new PivotQuery(this.pivotData().this, copy);
  }
}
