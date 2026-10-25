import * as sql from '@uwdata/mosaic-sql';
import type { AggregateInfo, SqlExpression, SqlRoot } from '@uwdata/mosaic-sql';
import { fnv_hash } from '../util/hash.js';

export class Statistics {
  private readonly names = new Map<string, string>();

  constructor(
    private readonly columns: Record<string, SqlExpression>,
    private readonly average: (expression: SqlExpression) => SqlExpression,
    private readonly key: (expression: SqlRoot) => string
  ) {}

  expression(node: SqlExpression): SqlExpression | null {
    const info = sql.inspectAggregate(node);
    if (!info || info.distinct || info.order_by.length || info.operator === 'aggregate_function') return null;
    const { name, args } = info;
    switch (name) {
      case 'count': case 'count_star': return sql.coalesce(this.sum(node), 0);
      case 'sum': return this.sum(node);
      case 'avg': {
        const count = this.count(info);
        return sql.div(sql.sum(sql.mul(this.add(node), count.name)), count.expression);
      }
      case 'geomean': case 'geometric_mean':
        return sql.exp(sql.div(sql.sum(this.add(sql.sum(sql.ln(args[0])), info)), this.count(info).expression));
      case 'arg_max': return args.length === 2
        ? sql.argmax(this.add(node), this.add(sql.max(args[1]).where(sql.isNotNull(args[0])), info)).expression : null;
      case 'arg_min': return args.length === 2
        ? sql.argmin(this.add(node), this.add(sql.min(args[1]).where(sql.isNotNull(args[0])), info)).expression : null;
      case 'variance': case 'var_samp': return this.variance(info, true);
      case 'var_pop': return this.variance(info, false);
      case 'stddev': case 'stddev_samp': return sql.sqrt(this.variance(info, true));
      case 'stddev_pop': return sql.sqrt(this.variance(info, false));
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
      case 'regr_intercept': return sql.sub(this.pairAverage(info, 0), sql.mul(
        sql.div(this.covariance(info, null), sql.nullif(this.pairVariance(info, 1), 0)), this.pairAverage(info, 1)
      ));
      case 'regr_r2': {
        const x = this.pairVariance(info, 1);
        const y = this.pairVariance(info, 0);
        return sql.asNode(sql.cond(sql.eq(x, 0), sql.literal(null),
          sql.cond(sql.eq(y, 0), 1, sql.div(sql.pow(this.covariance(info, null), 2), sql.mul(x, y)))));
      }
      case 'min': case 'max': case 'product': case 'bit_and': case 'bit_or': case 'bit_xor':
      case 'bool_and': case 'bool_or': {
        const reference = sql.column(this.add(node));
        return sql.native.aggregateCall(info.operator, [reference]);
      }
      default: return null;
    }
  }

  private add(input: SqlRoot, original?: AggregateInfo): string {
    let expression = sql.rootExpression(input);
    if (original?.filter) {
      const own = sql.inspectAggregate(expression)?.filter;
      expression = new sql.Aggregate(expression).where(own ? sql.and(own, original.filter) : original.filter).expression;
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
    return sql.sum(this.add(node)).expression;
  }

  private count(info: AggregateInfo): { name: string; expression: SqlExpression } {
    const name = this.add(sql.count(info.args[0]), info);
    return { name, expression: sql.coalesce(sql.sum(name), 0) };
  }

  private pairCount(info: AggregateInfo): { name: string; expression: SqlExpression } {
    const name = this.add(sql.regrCount(info.args[0], info.args[1]), info);
    return { name, expression: sql.coalesce(sql.sum(name), 0) };
  }

  private variance(info: AggregateInfo, sample: boolean): SqlExpression {
    const n = this.count(info).expression;
    const delta = sql.sub(info.args[0], this.average(info.args[0]));
    const squares = this.add(sql.sum(sql.pow(delta, 2)), info);
    const residual = this.add(sql.sum(delta), info);
    const numerator = sql.sub(sql.sum(squares), sql.div(sql.pow(sql.sum(residual), 2), n));
    return sql.div(numerator, sql.nullif(sample ? sql.sub(n, 1) : n, 0));
  }

  private pairSum(info: AggregateInfo, index: number): SqlExpression {
    const residual = sql.sub(info.args[index], this.average(info.args[index]));
    const statistic = sql.sum(residual).where(sql.isNotNull(info.args[1 - index]));
    return sql.sum(this.add(statistic, info)).expression;
  }

  private pairSquares(info: AggregateInfo, index: number): SqlExpression {
    const residual = sql.sub(info.args[index], this.average(info.args[index]));
    const statistic = sql.sum(sql.pow(residual, 2)).where(sql.isNotNull(info.args[1 - index]));
    return sql.sum(this.add(statistic, info)).expression;
  }

  private pairProducts(info: AggregateInfo): SqlExpression {
    const x = sql.sub(info.args[1], this.average(info.args[1]));
    const y = sql.sub(info.args[0], this.average(info.args[0]));
    return sql.sum(this.add(sql.sum(sql.mul(x, y)), info)).expression;
  }

  private covariance(info: AggregateInfo, sample: boolean | null): SqlExpression {
    const n = this.pairCount(info).expression;
    const correction = sql.div(sql.mul(this.pairSum(info, 1), this.pairSum(info, 0)), n);
    const covariance = sql.sub(this.pairProducts(info), correction);
    return sample === null ? covariance
      : sql.div(covariance, sql.nullif(sample ? sql.sub(n, 1) : n, 0));
  }

  private pairVariance(info: AggregateInfo, index: number): SqlExpression {
    const n = this.pairCount(info).expression;
    return sql.sub(this.pairSquares(info, index), sql.div(sql.pow(this.pairSum(info, index), 2), n));
  }

  private correlation(info: AggregateInfo): SqlExpression {
    const numerator = this.covariance(info, null);
    const denominator = sql.sqrt(sql.mul(this.pairVariance(info, 1), this.pairVariance(info, 0)));
    return sql.div(numerator, denominator);
  }

  private pairAverage(info: AggregateInfo, index: number): SqlExpression {
    const count = this.pairCount(info);
    const average = index === 1 ? sql.regrAvgX(info.args[0], info.args[1]) : sql.regrAvgY(info.args[0], info.args[1]);
    return sql.div(sql.sum(sql.mul(this.add(average, info), count.name)), count.expression);
  }

  private slope(info: AggregateInfo): SqlExpression {
    return sql.div(this.covariance(info, null), this.pairVariance(info, 1));
  }
}
