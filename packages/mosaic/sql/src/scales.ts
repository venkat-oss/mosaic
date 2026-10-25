import { asNode, literal } from './expression.js';
import { abs, epoch_ms, exp, ln, log, nullif, sign, sqrt } from './numeric.js';
import { add, div, mul, pow, sub } from './operators.js';
import type { ExprValue, SqlExpression } from './types.js';

export type ScaleType =
  | 'identity'
  | 'linear'
  | 'log'
  | 'symlog'
  | 'sqrt'
  | 'pow'
  | 'time'
  | 'utc'
  | (string & Record<never, never>);

export type ScaleDomain = [number, number] | [Date, Date];

export interface ScaleOptions {
  /** The scale type, such as `'linear'`, `'log'`, etc. */
  type: ScaleType;
  /** The scale domain, as an array of start and end data values. */
  domain?: ScaleDomain;
  /**
   * The scale range, as an array of start and end screen pixels.
   * The range may be omitted for *identity* scales.
   */
  range?: [number, number];
  /** The base of the logarithm. For `'log'` scales only. */
  base?: number;
  /** The constant parameter. For `'symlog'` scales only. */
  constant?: number;
  /** The exponent parameter. For `'pow'` scales only. */
  exponent?: number;
}

export interface ScaleTransform<T> {
  apply: (value: T) => number;
  invert: (value: number) => T;
  sqlApply: (value: ExprValue) => SqlExpression;
  sqlInvert: (value: SqlExpression) => SqlExpression;
}

export type Scale<T> = ScaleTransform<T> & ScaleOptions;

function scaleLinear(): ScaleTransform<number> {
  return { apply: x => x, invert: x => x, sqlApply: asNode, sqlInvert: x => x };
}

function scaleLog({ base }: ScaleOptions): ScaleTransform<number> {
  if (!base || base === Math.E) return {
    apply: x => Math.sign(x) * Math.log(Math.abs(x)),
    invert: x => Math.sign(x) * Math.exp(Math.abs(x)),
    sqlApply: value => { const x = asNode(value); return mul(sign(x), ln(abs(nullif(x, 0)))); },
    sqlInvert: x => mul(sign(x), exp(abs(x)))
  };
  if (base === 10) return {
    apply: x => Math.sign(x) * Math.log10(Math.abs(x)),
    invert: x => Math.sign(x) * Math.pow(10, Math.abs(x)),
    sqlApply: value => { const x = asNode(value); return mul(sign(x), log(abs(nullif(x, 0)))); },
    sqlInvert: x => mul(sign(x), pow(10, abs(x)))
  };
  const b = +base;
  return {
    apply: x => Math.sign(x) * Math.log(Math.abs(x)) / Math.log(b),
    invert: x => Math.sign(x) * Math.pow(b, Math.abs(x)),
    sqlApply: value => { const x = asNode(value); return mul(sign(x), div(ln(abs(nullif(x, 0))), ln(b))); },
    sqlInvert: x => mul(sign(x), pow(b, abs(x)))
  };
}

function scaleSymlog({ constant = 1 }: ScaleOptions): ScaleTransform<number> {
  const c = +constant;
  return {
    apply: x => Math.sign(x) * Math.log1p(Math.abs(x / c)),
    invert: x => Math.sign(x) * Math.expm1(Math.abs(x)) * c,
    sqlApply: value => { const x = asNode(value); return mul(sign(x), ln(add(1, abs(div(x, c))))); },
    sqlInvert: x => mul(sign(x), mul(sub(exp(abs(x)), 1), c))
  };
}

function scaleSqrt(): ScaleTransform<number> {
  return {
    apply: x => Math.sign(x) * Math.sqrt(Math.abs(x)),
    invert: x => Math.sign(x) * x * x,
    sqlApply: value => { const x = asNode(value); return mul(sign(x), sqrt(abs(x))); },
    sqlInvert: x => mul(sign(x), pow(x, 2))
  };
}

function scalePow({ exponent = 1 }: ScaleOptions): ScaleTransform<number> {
  const e = +exponent;
  return {
    apply: x => Math.sign(x) * Math.pow(Math.abs(x), e),
    invert: x => Math.sign(x) * Math.pow(Math.abs(x), 1 / e),
    sqlApply: value => { const x = asNode(value); return mul(sign(x), pow(abs(x), e)); },
    sqlInvert: x => mul(sign(x), pow(abs(x), div(1, e)))
  };
}

function scaleTime(): ScaleTransform<number | Date> {
  return {
    apply: Number,
    invert: x => new Date(x),
    sqlApply: value => {
      if (value instanceof Date) return literal(+value);
      return epoch_ms(value);
    },
    sqlInvert: x => x
  };
}

const scales = {
  identity: scaleLinear,
  linear: scaleLinear,
  log: scaleLog,
  symlog: scaleSymlog,
  sqrt: scaleSqrt,
  pow: scalePow,
  time: scaleTime,
  utc: scaleTime
};

export function scaleTransform<T = number>(options: ScaleOptions): Scale<T>;
export function scaleTransform(options: ScaleOptions): Scale<number> | Scale<number | Date> {
  if (!Object.hasOwn(scales, options.type)) throw new Error(`Unrecognized scale type: ${options.type}`);
  const create = scales[options.type as keyof typeof scales];
  return { ...options, ...create(options) };
}
