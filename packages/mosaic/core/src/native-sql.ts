import type { ExprValue, SqlExpression, SqlExecutionContext, SqlValue, SqlRoot, Query } from '@uwdata/mosaic-sql/native';
import {
  and, asLiteral, asNode, between, compileBatch, createExecutionContext,
  isNotDistinct, LegacyInputAdapter, or, StructuralKeyScope
} from '@uwdata/mosaic-sql/native';
import { isMosaicClient } from './MosaicClient.js';
import { Selection, SelectionResolver } from './Selection.js';
import type { SelectionOptions, SelectionExpressions, SelectionResolverOptions } from './Selection.js';
import type { ClauseSource, SelectionClause } from './clause/SelectionClause.js';
import type { DescribeQuery, ScaleDomain, ScaleOptions, SelectQuery } from '@uwdata/mosaic-sql';
import type { IntervalOptions, IntervalMetadata } from './clause/IntervalClause.js';
import type { PointOptions } from './clause/PointClause.js';

export type NativeSelection = Selection<SqlExpression>;
export type NativeSelectionClause = SelectionClause<SqlExpression>;
type NativePointOptions = Omit<PointOptions, 'clients'> & Pick<NativeSelectionClause, 'clients'>;
type NativeIntervalOptions = Omit<IntervalOptions, 'clients'> & Pick<NativeSelectionClause, 'clients'>;

export class NativeSqlContext {
  private _execution: SqlExecutionContext;
  private readonly input = new LegacyInputAdapter();
  private readonly keys = new StructuralKeyScope();
  private _owner?: object;
  private _invalidate?: () => void;
  readonly expressions: SelectionExpressions<SqlExpression>;

  constructor(execution: Partial<SqlExecutionContext> = {}) {
    this._execution = createExecutionContext(execution);
    this.expressions = {
      owner: this,
      literal: value => asLiteral(value),
      or: values => or(values)
    };
  }

  get execution(): SqlExecutionContext {
    return this._execution;
  }

  attach(owner: object, invalidate: () => void): void {
    if (this._owner && this._owner !== owner) {
      throw new TypeError('Native SQL context is already attached to another query manager.');
    }
    this._owner = owner;
    this._invalidate = invalidate;
  }

  detach(owner: object): void {
    if (this._owner !== owner) return;
    this._owner = undefined;
    this._invalidate = undefined;
  }

  replace(execution: Partial<SqlExecutionContext> = {}): void {
    this._execution = createExecutionContext({
      ...this._execution,
      ...execution,
      generation: this._execution.generation + 1
    });
    this.reset();
    this._invalidate?.();
  }

  compileBatch(inputs: readonly (SqlRoot | string)[], execution = this._execution): string[] {
    return compileBatch(inputs, execution);
  }

  structuralKey(input: SqlRoot): string {
    return this.keys.key(input);
  }

  cacheKey(sql: string, execution = this._execution): string {
    return JSON.stringify([execution.backend, execution.sourceDialect, execution.targetDialect, execution.generation, sql]);
  }

  adoptClause(clause: SelectionClause): NativeSelectionClause {
    return { ...this.input.clause(clause), context: this };
  }

  adoptQuery(query: SelectQuery | DescribeQuery): Query {
    return this.input.query(query);
  }

  reset(): void {
    this.input.reset();
  }

  selection(
    { cross = false, empty = false, include = [], ...options }:
      SelectionOptions<SqlExpression> & SelectionResolverOptions = {}
  ): NativeSelection {
    return new Selection(
      new SelectionResolver({ cross, empty, ...options }, this.expressions),
      [include].flat()
    );
  }

  point(field: ExprValue, value: unknown, { source, clients = isMosaicClient(source) ? new Set([source]) : undefined }: NativePointOptions): NativeSelectionClause {
    const node = asNode(field);
    return {
      context: this,
      meta: { type: 'point' },
      source,
      clients,
      fields: [node],
      value,
      predicate: value === undefined ? null : isNotDistinct(node, asLiteral(pointValue(value)))
    };
  }

  points(
    fields: readonly ExprValue[],
    value: readonly (readonly unknown[])[] | null | undefined,
    { source, clients = isMosaicClient(source) ? new Set([source]) : undefined }: NativePointOptions
  ): NativeSelectionClause {
    const nodes = fields.map(asNode);
    const predicate = value == null ? null : or(value.map(row => {
      if (row.length !== nodes.length) throw new RangeError('Native points require one value per field.');
      return and(row.map((item, index) => isNotDistinct(nodes[index], asLiteral(pointValue(item)))));
    }));
    return { context: this, meta: { type: 'point' }, source, clients, fields: nodes, value, predicate };
  }

  interval(
    field: ExprValue,
    value: ScaleDomain | null | undefined,
    { source, clients = isMosaicClient(source) ? new Set([source]) : undefined, bin, pixelSize = 1, scale }:
      NativeIntervalOptions & { scale?: ScaleOptions }
  ): NativeSelectionClause {
    const node = asNode(field);
    const meta: IntervalMetadata = { type: 'interval', scales: scale && [scale], bin, pixelSize };
    return {
      context: this,
      meta,
      source,
      clients,
      fields: [node],
      value,
      predicate: value == null ? null : between(node, value)
    };
  }

  intervals(
    fields: readonly ExprValue[],
    value: readonly ScaleDomain[] | null | undefined,
    { source, clients = isMosaicClient(source) ? new Set([source]) : undefined, bin, pixelSize = 1, scales = [] }:
      NativeIntervalOptions & { scales?: ScaleOptions[] }
  ): NativeSelectionClause {
    const nodes = fields.map(asNode);
    if (value && value.length !== nodes.length) throw new RangeError('Native intervals require one extent per field.');
    const meta: IntervalMetadata = { type: 'interval', scales, bin, pixelSize };
    return {
      context: this, meta, source, clients, fields: nodes, value,
      predicate: value == null ? null : and(nodes.map((node, index) => between(node, value[index])))
    };
  }

  clear(source: ClauseSource): NativeSelectionClause {
    return { context: this, source, fields: [], value: null, predicate: null };
  }
}

function pointValue(value: unknown): SqlValue {
  if (value == null || typeof value === 'string' || typeof value === 'number' ||
      typeof value === 'bigint' || typeof value === 'boolean' ||
      value instanceof Date || value instanceof RegExp) {
    return value;
  }
  throw new TypeError('Native point selections require a scalar SQL value.');
}
