import * as nativeSQL from '@uwdata/mosaic-sql/native';
import type { SqlExpression, SqlRoot } from '@uwdata/mosaic-sql/native';
import { nativeBaseExpression, nativeBaseTable, nativeColumnPath, type NativeTable } from './lineage.js';
import { NativeStatistics } from './sufficient-statistics.js';
import { asNode, collectAggregates, isAggregateExpression, isColumnRef, isSelectQuery, rewrite, sql } from '@uwdata/mosaic-sql';
import type { AggregateNode, ColumnRefNode, ExprNode, TableRefNode } from '@uwdata/mosaic-sql';
import type { MosaicClient } from '../MosaicClient.js';
import { resolvePositional } from '../util/positional.js';
import { baseExpression, baseTable } from './lineage.js';
import { sufficientStatistics } from './sufficient-statistics.js';

// result of determining columns for preaggregation optimization
export interface PreAggColumnsResult {
  // Columns to include in a created preaggregate table
  preagg: Record<string, ExprNode>;
  // Output columns for selection update queries
  output: Record<string, ExprNode>;
  // Group by dimension aliases
  groupby: string[]
  // ORDER BY clause expressions, potentially rewritten for preaggregation
  orderby: ExprNode[];
  // HAVING clause expressions, potentially rewritten for preaggregation
  having: ExprNode[];
  // QUALIFY clause expressions, potentially rewritten for preaggregation
  qualify: ExprNode[];
  // The base table of the client query
  source: TableRefNode;
}

/**
 * Determine pre-aggregation columns for a given Mosaic client.
 * @param client The Mosaic client.
 * @returns An object with necessary column data to generate pre-aggregated
 *  columns, or null if the client can't be optimized or the client query
 *  contains an invalid or unsupported expression.
 */
export function preaggColumns(client: MosaicClient): PreAggColumnsResult | null {
  if (!client.filterStable) return null;
  const q = client.query();

  // bail if query is not analyzable
  if (!isSelectQuery(q)) return null;

  // bail if no single base table
  const source = baseTable(q);
  if (!source) return null;

  // generate a scalar subquery for a global average
  // this may be used to mean-center data in preaggregate calculations
  // throws if unresolvable, which bails from preaggregation below
  const avg = (ref: ColumnRefNode) => {
    const expr = baseExpression(q, ref);
    if (!expr) throw new Error('unresolvable base expression');
    return sql`(SELECT avg(${expr}) FROM ${source})`;
  };

  const aggrs = new Map<AggregateNode, ExprNode>();
  const preagg: Record<string, ExprNode> = {}; // alias -> expr
  const output: Record<string, ExprNode> = {}; // alias -> expr
  const groupby: Record<string, string> = {}; // lower case alias -> alias

  try {
    const select = q._select;

    // iterate over select clauses and analyze expressions
    for (const { alias, expr } of select) {
      const result = analyzeExpression(expr, aggrs, preagg, avg);
      if (result) {
        // rewrite original select clause to use preaggregates
        output[alias] = result;
      } else {
        // include non-aggregates in preagg table and update results
        preagg[alias] = expr;
        output[alias] = asNode(alias);
        groupby[alias.toLowerCase()] = alias;
      }
    }

    // analyze any orderby expressions
    const orderby = q._orderby
      .map(expr => analyzeExpression(expr, aggrs, preagg, avg) ?? expr);

    // analyze any having expressions
    const having = q._having
      .map(expr => analyzeExpression(expr, aggrs, preagg, avg) ?? expr);

    // analyze any qualify expressions
    const qualify = q._qualify
      .map(expr => analyzeExpression(expr, aggrs, preagg, avg) ?? expr);

    // bail if query has no aggregates
    if (!aggrs.size) return null;

    // add groupby entries; these may or may not be selected
    let id = 0;
    for (let expr of q._groupby) {
      expr = resolvePositional(expr, select)?.expr ?? expr;
      const alias = isColumnRef(expr) ? expr.column : `__groupby_${++id}`;
      const key = alias.toLowerCase();
      if (!groupby[key]) {
        // add non-selected groupby term
        preagg[alias] = expr;
        groupby[key] = alias;
      }
    }

    return {
      groupby: Object.values(groupby),
      orderby,
      preagg,
      output,
      having,
      qualify,
      source
    };
  } catch {
    // bail if unsupported aggregate was encountered
    return null;
  }
}

/**
 * Analyzes an expression and returns a rewritten expression if preaggregation
 * optimization is supported. Returns undefined if the expression does not
 * contain any aggregates. Throws if the expression contains an unsupported
 * or non-optimizable aggregate.
 */
function analyzeExpression(
  expr: ExprNode,
  aggrs: Map<AggregateNode, ExprNode>,
  preagg: Record<string, ExprNode>,
  avg: (ref: ColumnRefNode) => ExprNode
) {
  // bail if there is an aggregate we can't analyze
  // a value > 1 indicates an aggregate in verbatim text
  if (isAggregateExpression(expr!) > 1) throw new Error();

  const nodes = collectAggregates(expr!);
  if (nodes.length) {
    for (const node of nodes) {
      // bail if distinct aggregate
      if (node.isDistinct) throw new Error();

      // bail if aggregate function is unsupported
      // otherwise add output aggregate to rewrite map
      const agg = sufficientStatistics(node, preagg, avg);
      if (!agg) throw new Error();
      aggrs.set(node, agg);
    }

    // rewrite original expression to use preaggregates
    return rewrite(expr!, aggrs)!;
  }
}


export interface NativePreAggColumnsResult {
  preagg: Record<string, SqlExpression>;
  output: Record<string, SqlExpression>;
  groupby: string[];
  orderby: SqlExpression[];
  having: SqlExpression | null;
  qualify: SqlExpression | null;
  source: NativeTable;
  windows: ReturnType<typeof nativeSQL.inspectSelect>['windows'];
}

export function nativePreaggColumns(
  client: MosaicClient<SqlExpression>,
  key: (expression: SqlRoot) => string
): NativePreAggColumnsResult | null {
  if (!client.filterStable) return null;
  const query = client.query();
  if (!nativeSQL.isSelectQuery(query) || !nativeIndexable(query)) return null;
  const source = nativeBaseTable(query);
  if (!source) return null;
  const selected = nativeSQL.inspectSelect(query);
  const projections = nativeSQL.selectEntries(query);
  if (projections.some(({ alias, expr }) => alias === undefined || nativeSQL.hasColumnExpansion(expr))) return null;
  const preagg: Record<string, SqlExpression> = {};
  const output: Record<string, SqlExpression> = {};
  const groupby = new Map<string, string>();
  const aggregates = new Map<SqlExpression, SqlExpression>();
  const average = (expression: SqlExpression): SqlExpression => {
    const base = nativeBaseExpression(query, expression);
    if (!base) throw new Error('Unresolvable base expression.');
    return nativeSQL.subquery(nativeSQL.Query.from(source).select({ mean: nativeSQL.avg(base) }));
  };
  const statistics = new NativeStatistics(preagg, average, key);
  const analyze = (expression: SqlExpression): SqlExpression | undefined => {
    const nodes = nativeSQL.collectAggregates(expression);
    if (!nodes.length) return;
    for (const node of nodes) {
      if (aggregates.has(node)) continue;
      const result = statistics.expression(node);
      if (!result) throw new Error('Aggregate cannot be preaggregated.');
      aggregates.set(node, result);
    }
    return nativeSQL.rewrite(expression, aggregates);
  };
  try {
    for (const { alias, expr } of projections) {
      if (!nativeSQL.collectAggregates(expr).length && !nativeHasWindow(expr)) {
        if (nativeConstant(expr)) output[alias!] = expr;
        else {
          if (!selected.group_by?.expressions.length) return null;
          preagg[alias!] = expr;
          output[alias!] = nativeSQL.column(alias!);
          groupby.set(alias!.toLowerCase(), alias!);
        }
      }
    }
    let index = 0;
    const aliases = new Map(projections.map(({ alias, expr }) => [alias!.toLowerCase(), expr]));
    for (const original of selected.group_by?.expressions ?? []) {
      const name = nativeColumnPath(original)?.at(-1);
      const expression = nativeSQL.resolvePositional(original, projections)?.expr
        ?? (name === undefined ? undefined : aliases.get(name.toLowerCase())) ?? original;
      const alias = name ?? nativeColumnPath(expression)?.at(-1) ?? `__groupby_${++index}`;
      if (!groupby.has(alias.toLowerCase())) {
        preagg[alias] = expression;
        groupby.set(alias.toLowerCase(), alias);
      }
    }
    for (const { alias, expr } of projections) {
      const rewritten = analyze(expr);
      if (rewritten || nativeHasWindow(expr)) output[alias!] = rewritten ?? expr;
    }
    const orderby = (selected.order_by?.expressions ?? []).map(ordered => {
      const root = { ordered } satisfies SqlExpression;
      return analyze(root) ?? root;
    });
    const having = selected.having ? analyze(selected.having.this) ?? selected.having.this : null;
    const qualify = selected.qualify ? analyze(selected.qualify.this) ?? selected.qualify.this : null;
    const windows = selected.windows?.map(definition => ({ ...definition, spec: {
      ...definition.spec,
      partition_by: definition.spec.partition_by.map(expression => analyze(expression) ?? expression),
      order_by: definition.spec.order_by.map(ordered => {
        const expression = analyze({ ordered }) ?? { ordered };
        if (!('ordered' in expression)) throw new TypeError('Expected a native window ordering.');
        return expression.ordered;
      })
    } })) ?? null;
    if (!aggregates.size) return null;
    return { preagg, output, groupby: [...groupby.values()], orderby, having, qualify, source, windows };
  } catch {
    return null;
  }
}

export function nativeIndexable(input: SqlRoot): boolean {
  let indexable = true;
  nativeSQL.walk(input, node => {
    const binding = nativeSQL.bindingOf(node);
    if (binding && binding.kind !== 'scalar'
      || 'group' in node && (node.group.grouping_sets != null || node.group.cube != null || node.group.rollup != null || node.group.all != null || node.group.totals != null)
      || 'cube' in node || 'rollup' in node || 'grouping_sets' in node
      || 'select' in node && (node.select.group_by?.all != null || node.select.group_by?.totals || node.select.with?.recursive)) {
      indexable = false;
      return -1;
    }
  });
  return indexable;
}

function nativeHasWindow(input: SqlRoot): boolean {
  let window = false;
  nativeSQL.walk(input, node => {
    if ('subquery' in node) return 1;
    if ('window_function' in node) { window = true; return -1; }
  });
  return window;
}

function nativeConstant(input: SqlRoot): boolean {
  let constant = true;
  nativeSQL.walk(input, node => {
    if ('column' in node || 'dot' in node || 'identifier' in node || 'star' in node || 'columns' in node
      || 'subquery' in node || 'select' in node || 'union' in node || 'intersect' in node || 'except' in node) {
      constant = false;
      return -1;
    }
  });
  return constant;
}
