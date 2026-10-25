import * as sql from '@uwdata/mosaic-sql';
import type { SqlExpression, SqlRoot } from '@uwdata/mosaic-sql';
import { baseExpression, baseTable, columnPath, type TableRef } from './lineage.js';
import { Statistics } from './sufficient-statistics.js';
import type { MosaicClient } from '../MosaicClient.js';

export interface PreAggColumnsResult {
  preagg: Record<string, SqlExpression>;
  output: Record<string, SqlExpression>;
  groupby: string[];
  orderby: SqlExpression[];
  having: SqlExpression | null;
  qualify: SqlExpression | null;
  source: TableRef;
  windows: ReturnType<typeof sql.inspectSelect>['windows'];
}

export function preaggColumns(
  client: MosaicClient,
  key: (expression: SqlRoot) => string
): PreAggColumnsResult | null {
  if (!client.filterStable) return null;
  const query = client.query();
  if (!sql.isSelectQuery(query) || !indexable(query)) return null;
  const source = baseTable(query);
  if (!source) return null;
  const selected = sql.inspectSelect(query);
  const projections = sql.selectEntries(query);
  if (projections.some(({ alias, expr }) => alias === undefined || sql.hasColumnExpansion(expr))) return null;
  const preagg: Record<string, SqlExpression> = {};
  const output: Record<string, SqlExpression> = {};
  const groupby = new Map<string, string>();
  const aggregates = new Map<SqlExpression, SqlExpression>();
  const average = (expression: SqlExpression): SqlExpression => {
    const base = baseExpression(query, expression);
    if (!base) throw new Error('Unresolvable base expression.');
    return sql.subquery(sql.Query.from(source).select({ mean: sql.avg(base) }));
  };
  const statistics = new Statistics(preagg, average, key);
  const analyze = (expression: SqlExpression): SqlExpression | undefined => {
    const nodes = sql.collectAggregates(expression);
    if (!nodes.length) return;
    for (const node of nodes) {
      if (aggregates.has(node)) continue;
      const result = statistics.expression(node);
      if (!result) throw new Error('Aggregate cannot be preaggregated.');
      aggregates.set(node, result);
    }
    return sql.rewrite(expression, aggregates);
  };
  try {
    for (const { alias, expr } of projections) {
      if (!sql.collectAggregates(expr).length && !hasWindow(expr)) {
        if (constant(expr)) output[alias!] = expr;
        else {
          if (!selected.group_by?.expressions.length) return null;
          preagg[alias!] = expr;
          output[alias!] = sql.column(alias!);
          groupby.set(alias!.toLowerCase(), alias!);
        }
      }
    }
    let index = 0;
    const aliases = new Map(projections.map(({ alias, expr }) => [alias!.toLowerCase(), expr]));
    for (const original of selected.group_by?.expressions ?? []) {
      const name = columnPath(original)?.at(-1);
      const expression = sql.resolvePositional(original, projections)?.expr
        ?? (name === undefined ? undefined : aliases.get(name.toLowerCase())) ?? original;
      const alias = name ?? columnPath(expression)?.at(-1) ?? `__groupby_${++index}`;
      if (!groupby.has(alias.toLowerCase())) {
        preagg[alias] = expression;
        groupby.set(alias.toLowerCase(), alias);
      }
    }
    for (const { alias, expr } of projections) {
      const rewritten = analyze(expr);
      if (rewritten || hasWindow(expr)) output[alias!] = rewritten ?? expr;
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
        if (!('ordered' in expression)) throw new TypeError('Expected a window ordering.');
        return expression.ordered;
      })
    } })) ?? null;
    if (!aggregates.size) return null;
    return { preagg, output, groupby: [...groupby.values()], orderby, having, qualify, source, windows };
  } catch {
    return null;
  }
}

export function indexable(input: SqlRoot): boolean {
  let indexable = true;
  sql.walk(input, node => {
    const binding = sql.bindingOf(node);
    if (binding && binding.kind !== 'scalar'
      || 'function' in node || 'method_call' in node || 'unnest' in node
      || 'group' in node && (node.group.grouping_sets != null || node.group.cube != null || node.group.rollup != null || node.group.all != null || node.group.totals != null)
      || 'cube' in node || 'rollup' in node || 'grouping_sets' in node
      || 'select' in node && (node.select.group_by?.all != null || node.select.group_by?.totals || node.select.with?.recursive)) {
      indexable = false;
      return -1;
    }
  });
  return indexable;
}

function hasWindow(input: SqlRoot): boolean {
  let window = false;
  sql.walk(input, node => {
    if ('subquery' in node) return 1;
    if ('window_function' in node) { window = true; return -1; }
  });
  return window;
}

function constant(input: SqlRoot): boolean {
  let constant = true;
  sql.walk(input, node => {
    if ('column' in node || 'dot' in node || 'identifier' in node || 'star' in node || 'columns' in node
      || 'subquery' in node || 'select' in node || 'union' in node || 'intersect' in node || 'except' in node) {
      constant = false;
      return -1;
    }
  });
  return constant;
}
