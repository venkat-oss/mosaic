import type { ast } from '#polyglot';
import { isParamLike } from '../util/type-check.js';
import { ast as syntax, native, createExecutionContext } from './runtime.js';
import type { SqlExecutionContext } from './runtime.js';
import { BindingScope, fields, rootExpression } from './bindings.js';
import { asNode, isExpressionHandle, tableRef } from './expression.js';
import { parseExpression } from './ingress.js';
import { and } from './operators.js';
import { mapTree } from './tree.js';
import { compile } from './compile.js';
import type { ExprValue, MaybeArray, SqlExpression, SqlExpressionHandle, SqlRoot } from './types.js';

export type SelectEntry = ExprValue | Record<string, ExprValue> | readonly [string, ExprValue];
export type SelectInput = MaybeArray<SelectEntry>;
export type FromEntry = string | SqlRoot | Record<string, string | SqlRoot>;
export type FromInput = MaybeArray<FromEntry | null | undefined>;
export type FilterInput = MaybeArray<ExprValue>;

export function isQuery(value: unknown): value is Query {
  return value instanceof Query;
}

export function inspectSelect(input: SqlRoot): ast.Select {
  const expression = rootExpression(input);
  if (!('select' in expression)) throw new TypeError('Expected a native SELECT query.');
  return expression.select;
}

function outputName(expression: SqlExpression): string | undefined {
  if ('alias' in expression) return expression.alias.alias.name;
  if ('column' in expression) return expression.column.name.name;
  if ('parameter' in expression) return fields(expression)[0]?.column;
}

function isUnaliasedExpression(value: unknown): value is SqlExpression {
  if (!syntax.isExpressionValue(value)) return false;
  if ('null' in value && value.null === null) return true;
  const payload: unknown = Object.values(value)[0];
  return payload !== null && typeof payload === 'object'
    && !Array.isArray(payload) && !(payload instanceof Date) && !(payload instanceof RegExp)
    && !syntax.isExpressionValue(payload) && !isExpressionHandle(payload) && !isParamLike(payload);
}

export class Query implements SqlExpressionHandle {
  private node: SqlExpression;
  readonly bindings: BindingScope;

  constructor(expression: SqlExpression = native.select(), bindings = new BindingScope()) {
    this.bindings = bindings;
    this.node = bindings.adopt(expression);
  }

  get expression(): SqlExpression {
    if ('select' in this.node && !this.node.select.expressions.length) {
      return { select: { ...this.node.select, expressions: [native.star()] } };
    }
    return this.node;
  }

  private selectData(): ast.Select {
    if (!('select' in this.node)) throw new TypeError('Expected a native SELECT query.');
    return this.node.select;
  }

  static select(...values: SelectInput[]): Query {
    return new Query().select(...values);
  }

  static from(...values: FromInput[]): Query {
    return new Query().from(...values);
  }

  static describe(input: SqlRoot): Query {
    return new Query(native.describe(rootExpression(input)));
  }

  clone(): Query {
    const root = this.node;
    const copy = mapTree(root, node => node === root ? undefined : node, new Map(), true);
    return new Query(copy);
  }

  select(...values: SelectInput[]): this {
    const selected = this.selectData();
    const replacements = new Map<string | SqlExpression, SqlExpression | null>();
    const add = (value: ExprValue, alias?: string) => {
      if (value == null) {
        if (alias !== undefined) replacements.set(alias, null);
        return;
      }
      const node = this.bindings.adopt(asNode(value));
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
    selected.expressions = selected.expressions
      .filter(expression => !replacements.has(outputName(expression) ?? expression))
      .concat([...replacements.values()].filter((value): value is SqlExpression => value !== null));
    return this;
  }

  setSelect(...values: SelectInput[]): this {
    this.selectData().expressions = [];
    return this.select(...values);
  }

  from(...values: FromInput[]): this {
    const selected = this.selectData();
    const relations: SqlExpression[] = [];
    const add = (value: string | SqlRoot, alias?: string) => {
      let relation = typeof value === 'string' ? tableRef(value)! : rootExpression(value);
      if ('select' in relation || 'describe' in relation) {
        throw new TypeError('Native FROM subqueries require a subquery factory.');
      }
      if (alias !== undefined) {
        if (!('table' in relation)) throw new TypeError('Native subquery aliases require a subquery factory.');
        relation = native.table(relation.table.name, {
          ...relation.table, alias: native.identifier(alias, true).identifier, alias_explicit_as: true
        });
      }
      relations.push(this.bindings.adopt(relation));
    };
    for (const value of values.flat()) {
      if (value == null) continue;
      if (typeof value === 'string' || isUnaliasedExpression(value) || isExpressionHandle(value)) {
        add(value);
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

  where(...values: FilterInput[]): this {
    const selected = this.selectData();
    const clauses = values.flat().filter(value => value != null)
      .map(value => this.bindings.adopt(typeof value === 'string' ? parseExpression(value) : asNode(value)));
    if (selected.where_clause) clauses.unshift(selected.where_clause.this);
    if (clauses.length) selected.where_clause = native.where(and(clauses)).where;
    return this;
  }

  setWhere(...values: FilterInput[]): this {
    this.selectData().where_clause = null;
    return this.where(...values);
  }

  groupby(...values: MaybeArray<ExprValue>[]): this {
    const selected = this.selectData();
    const expressions = values.flat().filter(value => value != null).map(value => this.bindings.adopt(asNode(value)));
    selected.group_by = native.groupBy([...(selected.group_by?.expressions ?? []), ...expressions]).group_by;
    return this;
  }

  setGroupby(...values: MaybeArray<ExprValue>[]): this {
    this.selectData().group_by = null;
    return this.groupby(...values);
  }

  orderby(...values: MaybeArray<ExprValue>[]): this {
    const selected = this.selectData();
    const expressions = values.flat().filter(value => value != null).map(value => {
      const node = this.bindings.adopt(asNode(value));
      return 'ordered' in node ? node.ordered : native.ordered(node).ordered;
    });
    selected.order_by = native.orderBy([...(selected.order_by?.expressions ?? []), ...expressions]).order_by;
    return this;
  }

  setOrderby(...values: MaybeArray<ExprValue>[]): this {
    this.selectData().order_by = null;
    return this.orderby(...values);
  }

  limit(value: ExprValue): this {
    this.selectData().limit = native.limit(this.bindings.adopt(asNode(value))).limit;
    return this;
  }

  distinct(value = true): this {
    this.selectData().distinct = !!value;
    return this;
  }

  describe(): Query {
    return Query.describe(this);
  }

  toString(context: SqlExecutionContext = createExecutionContext()): string {
    return compile([this], context).join(';\n');
  }
}
