import type { ExprNode, SQLNode } from '../ast/node.js';
import { AggregateNode } from '../ast/aggregate.js';
import { BetweenOpNode, NotBetweenOpNode } from '../ast/between-op.js';
import { BinaryOpNode } from '../ast/binary-op.js';
import { CastNode } from '../ast/cast.js';
import { ColumnNameRefNode } from '../ast/column-ref.js';
import { ColumnParamNode } from '../ast/column-param.js';
import { FromClauseNode } from '../ast/from.js';
import { InOpNode } from '../ast/in-op.js';
import { ListNode } from '../ast/list.js';
import { LiteralNode } from '../ast/literal.js';
import { LogicalOpNode } from '../ast/logical-op.js';
import { OrderByNode } from '../ast/order-by.js';
import { ParamNode } from '../ast/param.js';
import { DescribeQuery, SelectQuery } from '../ast/query.js';
import { SelectClauseNode } from '../ast/select.js';
import { TableRefNode } from '../ast/table-ref.js';
import { TupleNode } from '../ast/tuple.js';
import { UnaryOpNode, UnaryPostfixOpNode } from '../ast/unary-op.js';
import { VerbatimNode } from '../ast/verbatim.js';
import { Aggregate, avg, count, max, min, sum } from './aggregate.js';
import { BindingScope } from './bindings.js';
import { cast } from './cast.js';
import { asLiteral, column, deferred, literal, tableRef } from './expression.js';
import { parseExpression } from './ingress.js';
import * as op from './operators.js';
import { native } from './runtime.js';
import { Query } from './query.js';
import type { SqlExpression } from './types.js';

interface LegacyClause {
  fields: readonly ExprNode[];
  predicate: ExprNode | null;
}

export class LegacyInputAdapter {
  private memo = new WeakMap<SQLNode, SqlExpression>();
  readonly bindings = new BindingScope();

  expression(node: SQLNode): SqlExpression {
    if (!(node instanceof SelectQuery)) {
      const cached = this.memo.get(node);
      if (cached) return cached;
    }
    const expression = this.bindings.adopt(this.convert(node));
    this.memo.set(node, expression);
    return expression;
  }

  clause<T extends LegacyClause>(clause: T): Omit<T, 'fields' | 'predicate'> & {
    fields: SqlExpression[];
    predicate: SqlExpression | null;
  } {
    return {
      ...clause,
      fields: clause.fields.map(field => this.expression(field)),
      predicate: clause.predicate ? this.expression(clause.predicate) : null
    };
  }

  query(query: SelectQuery | DescribeQuery): Query {
    return new Query(this.expression(query), this.bindings);
  }

  reset(): void {
    this.memo = new WeakMap();
    this.bindings.reset();
  }

  private convert(node: SQLNode): SqlExpression {
    if (node instanceof ColumnParamNode) return column(node.param.param, this.qualifier(node.table));
    if (node instanceof ColumnNameRefNode) return column(node.name, this.qualifier(node.table));
    if (node instanceof ParamNode) return asLiteral(node.param);
    if (node instanceof LiteralNode) {
      return node.value instanceof Date
        ? deferred(() => literal(node.value as Date))
        : literal(node.value as Parameters<typeof literal>[0]);
    }
    if (node instanceof TableRefNode) return tableRef(node.table)!;
    if (node instanceof BinaryOpNode) return this.binary(node);
    if (node instanceof LogicalOpNode) {
      const clauses = node.clauses.map(clause => this.expression(clause));
      return node.op === 'AND' ? op.and(clauses) : op.or(clauses);
    }
    if (node instanceof UnaryOpNode) {
      const value = this.expression(node.expr);
      if (node.op === 'NOT') return op.not(value);
      if (node.op === '-') return native.unary('neg', value);
      if (node.op === '~') return native.unary('bitwise_not', value);
      if (node.op === '+') return value;
    }
    if (node instanceof UnaryPostfixOpNode) {
      const value = this.expression(node.expr);
      if (node.op === 'IS NULL') return op.isNull(value);
      if (node.op === 'IS NOT NULL') return op.isNotNull(value);
    }
    if (node instanceof BetweenOpNode || node instanceof NotBetweenOpNode) {
      if (!node.extent) return literal(true);
      const value = this.expression(node.expr);
      const range = node.extent.map(value => this.expression(value)) as [SqlExpression, SqlExpression];
      return node instanceof NotBetweenOpNode ? op.notBetween(value, range) : op.between(value, range);
    }
    if (node instanceof InOpNode && (node.values instanceof ListNode || node.values instanceof TupleNode)) {
      return op.isIn(this.expression(node.expr), node.values.values.map(value => this.expression(value)));
    }
    if (node instanceof CastNode) {
      if (node.isTry) throw new TypeError('Legacy TRY_CAST requires native safe-cast support.');
      return cast(this.expression(node.expr), node.cast);
    }
    if (node instanceof OrderByNode) return node.desc
      ? op.desc(this.expression(node.expr), node.nullsFirst)
      : op.asc(this.expression(node.expr), node.nullsFirst);
    if (node instanceof AggregateNode) return this.aggregate(node).expression;
    if (node instanceof SelectClauseNode) {
      const expression = this.expression(node.expr);
      return node.alias ? native.alias(expression, native.identifier(node.alias, true).identifier) : expression;
    }
    if (node instanceof FromClauseNode) {
      if (node.sample || node.columnNames?.length) throw new TypeError('Legacy sampled/subquery sources require native relational support.');
      const expression = this.expression(node.expr);
      if (!node.alias) return expression;
      if (!('table' in expression)) throw new TypeError('Legacy FROM aliases require a native table reference.');
      return native.table(expression.table.name, {
        ...expression.table, alias: native.identifier(node.alias, true).identifier, alias_explicit_as: true
      });
    }
    if (node instanceof SelectQuery) return this.select(node);
    if (node instanceof DescribeQuery) return native.describe(this.expression(node.query));
    if (node instanceof VerbatimNode) return parseExpression(node.value);
    throw new TypeError(`Legacy SQL input is not supported by this native slice: ${node.type}`);
  }

  private qualifier(table?: TableRefNode): SqlExpression | undefined {
    return table ? this.expression(table) : undefined;
  }

  private binary(node: BinaryOpNode): SqlExpression {
    const operations = {
      '+': op.add, '-': op.sub, '*': op.mul, '/': op.div, '%': op.mod,
      '=': op.eq, '!=': op.neq, '<>': op.neq, '<': op.lt, '<=': op.lte,
      '>': op.gt, '>=': op.gte,
      'IS NOT DISTINCT FROM': op.isNotDistinct, 'IS DISTINCT FROM': op.isDistinct
    };
    const operation = operations[node.op as keyof typeof operations];
    if (!Object.hasOwn(operations, node.op) || !operation) throw new TypeError(`Legacy operator requires a native factory: ${node.op}`);
    return operation(this.expression(node.left), this.expression(node.right));
  }

  private aggregate(node: AggregateNode): Aggregate {
    const [argument] = node.args;
    const value = argument ? this.expression(argument) : undefined;
    const operations = { count, sum, avg, min, max };
    const name = node.name.toLowerCase() as keyof typeof operations;
    if (!Object.hasOwn(operations, name) || name !== 'count' && (!value || node.args.length !== 1)) {
      throw new TypeError(`Legacy aggregate requires a native factory: ${node.name}`);
    }
    let aggregate = name === 'count' ? count(value) : operations[name](value!);
    if (node.isDistinct) aggregate = aggregate.distinct();
    if (node.filter) aggregate = aggregate.where(this.expression(node.filter));
    if (node.order.length) aggregate = aggregate.argOrder(node.order.map(value => this.expression(value)));
    return aggregate;
  }

  private select(node: SelectQuery): SqlExpression {
    if (node._with.length || node._sample || node._having.length || node._window.length
      || node._qualify.length || node._distinctOn.length || node._offset) {
      throw new TypeError('Legacy query requires native relational or window support.');
    }
    const query = native.select(node._select.map(value => this.expression(value)), {
      from: node._from.length ? native.from(node._from.map(value => this.expression(value))).from : null,
      where_clause: node._where.length ? native.where(op.and(node._where.map(value => this.expression(value)))).where : null,
      group_by: node._groupby.length ? native.groupBy(node._groupby.map(value => this.expression(value))).group_by : null,
      order_by: node._orderby.length ? native.orderBy(node._orderby.map(value => {
        const expression = this.expression(value);
        return 'ordered' in expression ? expression.ordered : native.ordered(expression).ordered;
      })).order_by : null,
      distinct: node._distinct,
      limit: node._limit ? native.limit(this.expression(node._limit)).limit : null
    });
    if (query.select.limit) query.select.limit.percent = node._limitPerc;
    return query;
  }
}
