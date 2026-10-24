import * as nativeSQL from '@uwdata/mosaic-sql/native';
import type { AggregateInfo, SqlExpression, SqlRoot } from '@uwdata/mosaic-sql/native';
import type { AggregateNode, ColumnRefNode, ExprNode } from '@uwdata/mosaic-sql';
import { and, argmax, argmin, coalesce, count, div, exp, isNotNull, ln, max, min, mul, pow, regrAvgX, regrAvgY, regrCount, sql, sqrt, sub, sum } from '@uwdata/mosaic-sql';
import { fnv_hash } from '../util/hash.js';

/**
 * Determine sufficient statistics to preaggregate the given node. This
 * method populates the *preagg* and *aggrs* arguments with necessary
 * information for preaggregation optimization.
 * @param node An aggregate function.
 * @param preagg Map of column names to
 *  expressions to include in the preaggregation table.
 * @param avg Global average query generator.
 * @returns Output aggregate expression that uses preaggregated
 *  sufficient statistics to service updates.
 */
export function sufficientStatistics(
  node: AggregateNode,
  preagg: Record<string, ExprNode>,
  avg: (field: ColumnRefNode) => ExprNode
): ExprNode | null {
  switch (node.name) {
    case 'count':
    case 'count_star':
      return sumCountExpr(preagg, node);
    case 'sum':
      return sumExpr(preagg, node);
    case 'avg':
      return avgExpr(preagg, node);
    case 'geomean':
      return geomeanExpr(preagg, node);
    case 'arg_max':
      return argmaxExpr(preagg, node);
    case 'arg_min':
      return argminExpr(preagg, node);

    // variance statistics drop the original aggregate operation
    // in favor of tracking sufficient statistics
    case 'variance':
    case 'var_samp':
      return varianceExpr(preagg, node, avg);
    case 'var_pop':
      return varianceExpr(preagg, node, avg, false);
    case 'stddev':
    case 'stddev_samp':
      return sqrt(varianceExpr(preagg, node, avg));
    case 'stddev_pop':
      return sqrt(varianceExpr(preagg, node, avg, false));
    case 'covar_samp':
      return covarianceExpr(preagg, node, avg);
    case 'covar_pop':
      return covarianceExpr(preagg, node, avg, false);
    case 'corr':
      return corrExpr(preagg, node, avg);

    // regression statistics
    case 'regr_count':
      return regrCountExpr(preagg, node).expr;
    case 'regr_avgx':
      return regrAvgXExpr(preagg, node);
    case 'regr_avgy':
      return regrAvgYExpr(preagg, node);
    case 'regr_syy':
      return regrVarExpr(preagg, 0, node, avg);
    case 'regr_sxx':
      return regrVarExpr(preagg, 1, node, avg);
    case 'regr_sxy':
      return covarianceExpr(preagg, node, avg, null);
    case 'regr_slope':
      return regrSlopeExpr(preagg, node, avg);
    case 'regr_intercept':
      return regrInterceptExpr(preagg, node, avg);
    case 'regr_r2':
      return pow(corrExpr(preagg, node, avg), 2);

    // aggregates that commute directly
    case 'max':
    case 'min':
    case 'bit_and':
    case 'bit_or':
    case 'bit_xor':
    case 'bool_and':
    case 'bool_or':
    case 'product': {
      const name = colName(node);
      preagg[name] = node;
      return sql`${node.name}("${name}")`;
    }

    // unsupported aggregate, return null to indicate failure
    default: return null;
  }
}

/**
 * Generate a column name for the given aggregate node. The name is
 * made from a hash of the string-serialized SQL expression.
 * @param node The aggregate node to name.
 * @returns The generated column name.
 */
function colName(node: AggregateNode): string {
  return 'pre_' + fnv_hash(`${node}`).toString(16);
}

/**
 * Add a sufficient statistic to the preaggregation column set.
 * Generates a unique column name for the statistic and propagates
 * a FILTER clause if one exists on the original aggregate node.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param expr The aggregate statistic to add.
 * @param node The originating aggregate function call.
 * @returns The name of the statistic column.
 */
function addStat(preagg: Record<string, ExprNode>, expr: AggregateNode, node?: AggregateNode): string {
  const filter = node?.filter;
  if (filter) {
    // push filter clause to preaggregate expr
    expr = expr.filter
      ? expr.where(and(filter, expr.filter))
      : expr.where(filter);
  }
  const name = colName(expr);
  preagg[name] = expr;
  return name;
}

/**
 * Generate an expression for calculating counts over data dimensions.
 * As a side effect, this method adds a column to the input *preagg* object
 * to track the count of non-null values per-partition.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @returns An aggregate expression over
 *  pre-aggregated dimensions and associated column name.
 */
function countExpr(preagg: Record<string, ExprNode>, node: AggregateNode): { expr: ExprNode; name: string } {
  const name = addStat(preagg, count(node.args[0]), node);
  return { expr: coalesce(sum(name), 0), name };
}

/**
 * Generate an expression for calculating counts over data dimensions.
 * The expression is a summation with an additional coalesce operation
 * to map null sums to zero-valued counts.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @returns An aggregate expression over pre-aggregated dimensions.
 */
function sumCountExpr(preagg: Record<string, ExprNode>, node: AggregateNode): ExprNode {
  return coalesce(sumExpr(preagg, node), 0);
}

/**
 * Generate an expression for calculating sums over data dimensions.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @returns An aggregate expression over pre-aggregated dimensions.
 */
function sumExpr(preagg: Record<string, ExprNode>, node: AggregateNode): ExprNode {
  return sum(addStat(preagg, node));
}

/**
 * Generate an expression for calculating averages over data dimensions.
 * As a side effect, this method adds a column to the input *preagg* object
 * to track the count of non-null values per-partition.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @returns An aggregate expression over pre-aggregated dimensions.
 */
function avgExpr(preagg: Record<string, ExprNode>, node: AggregateNode): ExprNode {
  const as = addStat(preagg, node);
  const { expr, name } = countExpr(preagg, node);
  return div(sum(mul(as, name)), expr);
}

/**
 * Generate an expression for calculating geometric means over data dimensions.
 * This method uses log-based computations to ensure numerical stability. The
 * geomean calculation uses two sufficient statistics: the sum of log values
 * and the count of non-null values. As a side effect, this method adds columns
 * for these statistics to the input *preagg* object.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @returns An aggregate expression over pre-aggregated dimensions.
 */
function geomeanExpr(preagg: Record<string, ExprNode>, node: AggregateNode): ExprNode {
  const x = node.args[0];
  const expr = addStat(preagg, sum(ln(x)), node);
  const { expr: n } = countExpr(preagg, node);
  return exp(div(sum(expr), n));
}

/**
 * Generate an expression for calculating argmax over data dimensions.
 * As a side effect, this method adds a column to the input *preagg* object
 * to track a maximum value per-partition.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @returns An aggregate expression over pre-aggregated dimensions.
 */
function argmaxExpr(preagg: Record<string, ExprNode>, node: AggregateNode): ExprNode {
  const expr = addStat(preagg, node);
  const maxy = addStat(preagg, max(node.args[1]), node);
  return argmax(expr, maxy);
}

/**
 * Generate an expression for calculating argmin over data dimensions.
 * As a side effect, this method adds a column to the input *preagg* object
 * to track a minimum value per-partition.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @returns An aggregate expression over pre-aggregated dimensions.
 */
function argminExpr(preagg: Record<string, ExprNode>, node: AggregateNode): ExprNode {
  const expr = addStat(preagg, node);
  const miny = addStat(preagg, min(node.args[1]), node);
  return argmin(expr, miny);
}

/**
 * Generate an expression for calculating variance over data dimensions.
 * This method uses the "textbook" definition of variance (E[X^2] - E[X]^2),
 * but on mean-centered data to reduce floating point error. The variance
 * calculation uses three sufficient statistics: the count of non-null values,
 * the residual sum of squares and the sum of residual (mean-centered) values.
 * As a side effect, this method adds columns for these statistics to the
 * input *preagg* object.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @param avg Global average query generator.
 * @param correction A flag for whether a Bessel
 *  correction should be applied to compute the sample variance
 *  rather than the populatation variance.
 * @returns An aggregate expression over pre-aggregated dimensions.
 */
function varianceExpr(
  preagg: Record<string, ExprNode>,
  node: AggregateNode,
  avg: (field: ColumnRefNode) => ExprNode,
  correction: boolean = true
): ExprNode {
  const x = node.args[0];
  const { expr: n } = countExpr(preagg, node);
  const delta = sub(x, avg(x as ColumnRefNode));
  const rssq = addStat(preagg, sum(pow(delta, 2)), node); // residual sum of squares
  const rsum = addStat(preagg, sum(delta), node); // residual sum
  const denom = correction ? sub(n, 1) : n; // Bessel correction
  return div(sub(sum(rssq), div(pow(sum(rsum), 2), n)), denom);
}

/**
 * Generate an expression for calculating covariance over data dimensions.
 * This method uses mean-centered data to reduce floating point error. The
 * covariance calculation uses four sufficient statistics: the count of
 * non-null value pairs, the sum of residual products, and residual sums
 * (of mean-centered values) for x and y. As a side effect, this method
 * adds columns for these statistics to the input *preagg* object.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @param avg Global average query generator.
 * @param correction A flag for whether a Bessel
 *  correction should be applied to compute the sample covariance rather
 *  than the populatation covariance. If null, an expression for the
 *  unnormalized covariance (no division by sample count) is returned.
 * @returns An aggregate expression over pre-aggregated dimensions.
 */
function covarianceExpr(
  preagg: Record<string, ExprNode>,
  node: AggregateNode,
  avg: (field: ColumnRefNode) => ExprNode,
  correction: boolean | null = true
): ExprNode {
  const { expr: n } = regrCountExpr(preagg, node);
  const sxy = regrSumXYExpr(preagg, node, avg);
  const sx = regrSumExpr(preagg, 1, node, avg);
  const sy = regrSumExpr(preagg, 0, node, avg);
  const num = sub(sxy, div(mul(sx, sy), n));
  return correction === null ? num // do not divide by count
    : correction ? div(num, sub(n, 1)) // Bessel correction (sample)
    : div(num, n); // no correction (population)
}

/**
 * Generate an expression for calculating Pearson product-moment correlation
 * coefficients over data dimensions. This method uses mean-centered data
 * to reduce floating point error. The correlation calculation uses six
 * sufficient statistics: the count of non-null value pairs, the sum of
 * residual products, and both residual sums and sums of squares for x and y.
 * As a side effect, this method adds columns for these statistics to the
 * input *preagg* object.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @param avg Global average query generator.
 * @returns An aggregate expression over pre-aggregated dimensions.
 */
function corrExpr(
  preagg: Record<string, ExprNode>,
  node: AggregateNode,
  avg: (field: ColumnRefNode) => ExprNode
): ExprNode {
  const { expr: n } = regrCountExpr(preagg, node);
  const sxy = regrSumXYExpr(preagg, node, avg);
  const sxx = regrSumSqExpr(preagg, 1, node, avg);
  const syy = regrSumSqExpr(preagg, 0, node, avg);
  const sx = regrSumExpr(preagg, 1, node, avg);
  const sy = regrSumExpr(preagg, 0, node, avg);
  const vx = sub(sxx, div(pow(sx, 2), n));
  const vy = sub(syy, div(pow(sy, 2), n));
  return div(
    sub(sxy, div(mul(sx, sy), n)),
    sqrt(mul(vx, vy))
  );
}

/**
 * Generate an expression for the count of non-null (x, y) pairs. As a side
 * effect, this method adds columns to the input *preagg* object to the
 * partition-level count of non-null pairs.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @returns An aggregate expression over
 *  pre-aggregated dimensions and associated column name.
 */
function regrCountExpr(preagg: Record<string, ExprNode>, node: AggregateNode): { expr: ExprNode; name: string } {
  const [x, y] = node.args;
  const n = addStat(preagg, regrCount(x, y), node);
  return { expr: sum(n), name: n };
}

/**
 * Generate an expression for calculating sums of residual values for use in
 * covariance and regression queries. Only values corresponding to non-null
 * (x, y) pairs are included. This method uses mean-centered data to reduce
 * floating point error. As a side effect, this method adds a column for
 * partition-level sums to the input *preagg* object.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param i An index indicating which argument column to sum.
 * @param node The originating aggregate function call.
 * @param avg Global average query generator.
 * @returns An aggregate expression over pre-aggregated dimensions.
 */
function regrSumExpr(
  preagg: Record<string, ExprNode>,
  i: number,
  node: AggregateNode,
  avg: (field: ColumnRefNode) => ExprNode
): ExprNode {
  const args = node.args;
  const v = args[i];
  const o = args[1 - i];
  const rsum = sum(sub(v, avg(v as ColumnRefNode))).where(isNotNull(o));
  return sum(addStat(preagg, rsum, node));
}

/**
 * Generate an expressios for calculating sums of squared residual values for
 * use in covariance and regression queries. Only values corresponding to
 * non-null (x, y) pairs are included. This method uses mean-centered data to
 * reduce floating point error. As a side effect, this method adds a column
 * for partition-level sums to the input *preagg* object.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param i An index indicating which argument column to sum.
 * @param node The originating aggregate function call.
 * @param avg Global average query generator.
 * @returns An aggregate expression over pre-aggregated dimensions.
 */
function regrSumSqExpr(
  preagg: Record<string, ExprNode>,
  i: number,
  node: AggregateNode,
  avg: (field: ColumnRefNode) => ExprNode
): ExprNode {
  const args = node.args;
  const v = args[i];
  const u = args[1 - i];
  const ssq = sum(pow(sub(v, avg(v as ColumnRefNode)), 2)).where(isNotNull(u));
  return sum(addStat(preagg, ssq, node));
}

/**
 * Generate an expression for calculating sums of residual product values for
 * use in covariance and regression queries. Only values corresponding to
 * non-null (x, y) pairs are included. This method uses mean-centered data to
 * reduce floating point error. As a side effect, this method adds a column
 * for partition-level sums to the input *preagg* object.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @param avg Global average query generator.
 * @returns An aggregate expression over pre-aggregated dimensions.
 */
function regrSumXYExpr(
  preagg: Record<string, ExprNode>,
  node: AggregateNode,
  avg: (field: ColumnRefNode) => ExprNode
): ExprNode {
  const [y, x] = node.args;
  const sxy = sum(
    mul(
      sub(x, avg(x as ColumnRefNode)),
      sub(y, avg(y as ColumnRefNode))
    )
  );
  return sum(addStat(preagg, sxy, node));
}

/**
 * Generate an expression for the average x value in a regression context.
 * Only values corresponding to non-null (x, y) pairs are included. As a side
 * effect, this method adds columns to the input *preagg* object to track both
 * the count of non-null pairs and partition-level averages.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @returns An aggregate expression over pre-aggregated dimensions.
 */
function regrAvgXExpr(preagg: Record<string, ExprNode>, node: AggregateNode): ExprNode {
  const [y, x] = node.args;
  const { expr: n, name } = regrCountExpr(preagg, node);
  const a = addStat(preagg, regrAvgX(y, x), node);
  return div(sum(mul(a, name)), n);
}

/**
 * Generate an expression for the average y value in a regression context.
 * Only values corresponding to non-null (x, y) pairs are included. As a side
 * effect, this method adds columns to the input *preagg* object to track both
 * the count of non-null pairs and partition-level averages.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @returns An aggregate expression over pre-aggregated dimensions.
 */
function regrAvgYExpr(preagg: Record<string, ExprNode>, node: AggregateNode): ExprNode {
  const [y, x] = node.args;
  const { expr: n, name } = regrCountExpr(preagg, node);
  const a = addStat(preagg, regrAvgY(y, x), node);
  return div(sum(mul(a, name)), n);
}

/**
 * Generate an expression for calculating variance over data dimensions for
 * use in covariance and regression queries. Only values corresponding to
 * non-null (x, y) pairs are included. This method uses mean-centered data to
 * reduce floating point error. As a side effect, this method adds columns
 * for partition-level count and sums to the input *preagg* object.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param i The index of the argument to compute the variance for.
 * @param node The originating aggregate function call.
 * @param avg Global average query generator.
 * @returns An aggregate expression for calculating variance
 *  over pre-aggregated data dimensions.
 */
function regrVarExpr(
  preagg: Record<string, ExprNode>,
  i: number,
  node: AggregateNode,
  avg: (field: ColumnRefNode) => ExprNode
): ExprNode {
  const { expr: n } = regrCountExpr(preagg, node);
  const sum = regrSumExpr(preagg, i, node, avg);
  const ssq = regrSumSqExpr(preagg, i, node, avg);
  return sub(ssq, div(pow(sum, 2), n));
}

/**
 * Generate an expression for calculating a regression slope. The slope is
 * computed as the covariance divided by the variance of the x variable. As a
 * side effect, this method adds columns for sufficient statistics to the
 * input *preagg* object.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @param avg Global average query generator.
 * @returns An aggregate expression for calculating regression
 *  slopes over pre-aggregated data dimensions.
 */
function regrSlopeExpr(
  preagg: Record<string, ExprNode>,
  node: AggregateNode,
  avg: (field: ColumnRefNode) => ExprNode
): ExprNode {
  const cov = covarianceExpr(preagg, node, avg, null);
  const varx = regrVarExpr(preagg, 1, node, avg);
  return div(cov, varx);
}

/**
 * Generate an expression for calculating a regression intercept. The intercept
 * is derived from the regression slope and average x and y values. As a
 * side effect, this method adds columns for sufficient statistics to the
 * input *preagg* object.
 * @param preagg A map of columns (such as
 *  sufficient statistics) to pre-aggregate.
 * @param node The originating aggregate function call.
 * @param avg Global average query generator.
 * @returns An aggregate expression for calculating regression
 *  intercepts over pre-aggregated data dimensions.
 */
function regrInterceptExpr(
  preagg: Record<string, ExprNode>,
  node: AggregateNode,
  avg: (field: ColumnRefNode) => ExprNode
): ExprNode {
  const ax = regrAvgXExpr(preagg, node);
  const ay = regrAvgYExpr(preagg, node);
  const m = regrSlopeExpr(preagg, node, avg);
  return sub(ay, mul(m, ax));
}

export class NativeStatistics {
  private readonly names = new Map<string, string>();

  constructor(
    private readonly columns: Record<string, SqlExpression>,
    private readonly average: (expression: SqlExpression) => SqlExpression,
    private readonly key: (expression: SqlRoot) => string
  ) {}

  expression(node: SqlExpression): SqlExpression | null {
    const info = nativeSQL.inspectAggregate(node);
    if (!info || info.distinct || info.order_by.length || info.operator === 'aggregate_function') return null;
    const { name, args } = info;
    switch (name) {
      case 'count': case 'count_star': return nativeSQL.coalesce(this.sum(node), 0);
      case 'sum': return this.sum(node);
      case 'avg': {
        const count = this.count(info);
        return nativeSQL.div(nativeSQL.sum(nativeSQL.mul(this.add(node), count.name)), count.expression);
      }
      case 'geomean': case 'geometric_mean':
        return nativeSQL.exp(nativeSQL.div(nativeSQL.sum(this.add(nativeSQL.sum(nativeSQL.ln(args[0])), info)), this.count(info).expression));
      case 'arg_max': return args.length === 2
        ? nativeSQL.argmax(this.add(node), this.add(nativeSQL.max(args[1]).where(nativeSQL.isNotNull(args[0])), info)).expression : null;
      case 'arg_min': return args.length === 2
        ? nativeSQL.argmin(this.add(node), this.add(nativeSQL.min(args[1]).where(nativeSQL.isNotNull(args[0])), info)).expression : null;
      case 'variance': case 'var_samp': return this.variance(info, true);
      case 'var_pop': return this.variance(info, false);
      case 'stddev': case 'stddev_samp': return nativeSQL.sqrt(this.variance(info, true));
      case 'stddev_pop': return nativeSQL.sqrt(this.variance(info, false));
      case 'covar_samp': return this.covariance(info, true);
      case 'covar_pop': return this.covariance(info, false);
      case 'corr': return this.correlation(info);
      case 'regr_count': return this.pairCount(info).expression;
      case 'regr_avgx': return this.pairAverage(info, 1);
      case 'regr_avgy': return this.pairAverage(info, 0);
      case 'regr_sxx': return this.pairVariance(info, 1);
      case 'regr_syy': return this.pairVariance(info, 0);
      case 'regr_sxy': return this.covariance(info, null);
      case 'regr_slope': return this.slope(info);
      case 'regr_intercept': return nativeSQL.sub(this.pairAverage(info, 0), nativeSQL.mul(
        nativeSQL.div(this.covariance(info, null), nativeSQL.nullif(this.pairVariance(info, 1), 0)), this.pairAverage(info, 1)
      ));
      case 'regr_r2': {
        const x = this.pairVariance(info, 1);
        const y = this.pairVariance(info, 0);
        return nativeSQL.asNode(nativeSQL.cond(nativeSQL.eq(x, 0), nativeSQL.literal(null),
          nativeSQL.cond(nativeSQL.eq(y, 0), 1, nativeSQL.div(nativeSQL.pow(this.covariance(info, null), 2), nativeSQL.mul(x, y)))));
      }
      case 'min': case 'max': case 'product': case 'bit_and': case 'bit_or': case 'bit_xor':
      case 'bool_and': case 'bool_or': {
        const reference = nativeSQL.column(this.add(node));
        return nativeSQL.native.aggregateCall(info.operator, [reference]);
      }
      default: return null;
    }
  }

  private add(input: SqlRoot, original?: AggregateInfo): string {
    let expression = nativeSQL.rootExpression(input);
    if (original?.filter) {
      const own = nativeSQL.inspectAggregate(expression)?.filter;
      expression = new nativeSQL.Aggregate(expression).where(own ? nativeSQL.and(own, original.filter) : original.filter).expression;
    }
    const key = this.key(expression);
    let name = this.names.get(key);
    if (!name) {
      name = 'pre_' + (fnv_hash(key) >>> 0).toString(16);
      while (Object.hasOwn(this.columns, name)) name += '_';
      this.names.set(key, name);
      this.columns[name] = expression;
    }
    return name;
  }

  private sum(node: SqlExpression): SqlExpression {
    return nativeSQL.sum(this.add(node)).expression;
  }

  private count(info: AggregateInfo): { name: string; expression: SqlExpression } {
    const name = this.add(nativeSQL.count(info.args[0]), info);
    return { name, expression: nativeSQL.coalesce(nativeSQL.sum(name), 0) };
  }

  private pairCount(info: AggregateInfo): { name: string; expression: SqlExpression } {
    const name = this.add(nativeSQL.regrCount(info.args[0], info.args[1]), info);
    return { name, expression: nativeSQL.coalesce(nativeSQL.sum(name), 0) };
  }

  private variance(info: AggregateInfo, sample: boolean): SqlExpression {
    const n = this.count(info).expression;
    const delta = nativeSQL.sub(info.args[0], this.average(info.args[0]));
    const squares = this.add(nativeSQL.sum(nativeSQL.pow(delta, 2)), info);
    const residual = this.add(nativeSQL.sum(delta), info);
    const numerator = nativeSQL.sub(nativeSQL.sum(squares), nativeSQL.div(nativeSQL.pow(nativeSQL.sum(residual), 2), n));
    return nativeSQL.div(numerator, nativeSQL.nullif(sample ? nativeSQL.sub(n, 1) : n, 0));
  }

  private pairSum(info: AggregateInfo, index: number): SqlExpression {
    const residual = nativeSQL.sub(info.args[index], this.average(info.args[index]));
    const statistic = nativeSQL.sum(residual).where(nativeSQL.isNotNull(info.args[1 - index]));
    return nativeSQL.sum(this.add(statistic, info)).expression;
  }

  private pairSquares(info: AggregateInfo, index: number): SqlExpression {
    const residual = nativeSQL.sub(info.args[index], this.average(info.args[index]));
    const statistic = nativeSQL.sum(nativeSQL.pow(residual, 2)).where(nativeSQL.isNotNull(info.args[1 - index]));
    return nativeSQL.sum(this.add(statistic, info)).expression;
  }

  private pairProducts(info: AggregateInfo): SqlExpression {
    const x = nativeSQL.sub(info.args[1], this.average(info.args[1]));
    const y = nativeSQL.sub(info.args[0], this.average(info.args[0]));
    return nativeSQL.sum(this.add(nativeSQL.sum(nativeSQL.mul(x, y)), info)).expression;
  }

  private covariance(info: AggregateInfo, sample: boolean | null): SqlExpression {
    const n = this.pairCount(info).expression;
    const correction = nativeSQL.div(nativeSQL.mul(this.pairSum(info, 1), this.pairSum(info, 0)), n);
    const covariance = nativeSQL.sub(this.pairProducts(info), correction);
    return sample === null ? covariance
      : nativeSQL.div(covariance, nativeSQL.nullif(sample ? nativeSQL.sub(n, 1) : n, 0));
  }

  private pairVariance(info: AggregateInfo, index: number): SqlExpression {
    const n = this.pairCount(info).expression;
    return nativeSQL.sub(this.pairSquares(info, index), nativeSQL.div(nativeSQL.pow(this.pairSum(info, index), 2), n));
  }

  private correlation(info: AggregateInfo): SqlExpression {
    const numerator = this.covariance(info, null);
    const denominator = nativeSQL.sqrt(nativeSQL.mul(this.pairVariance(info, 1), this.pairVariance(info, 0)));
    return nativeSQL.div(numerator, denominator);
  }

  private pairAverage(info: AggregateInfo, index: number): SqlExpression {
    const count = this.pairCount(info);
    const average = index === 1 ? nativeSQL.regrAvgX(info.args[0], info.args[1]) : nativeSQL.regrAvgY(info.args[0], info.args[1]);
    return nativeSQL.div(nativeSQL.sum(nativeSQL.mul(this.add(average, info), count.name)), count.expression);
  }

  private slope(info: AggregateInfo): SqlExpression {
    return nativeSQL.div(this.covariance(info, null), this.pairVariance(info, 1));
  }
}
