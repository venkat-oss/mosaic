import { asLiteral, asNode } from './expression.js';
import { native } from './runtime.js';
import type { ExprValue, SqlExpression } from './types.js';

export function interval(unit: string, steps = 1): SqlExpression {
  return native.interval(asLiteral(`${steps} ${unit}`));
}

export const years = (steps: number): SqlExpression => interval('years', steps);
export const months = (steps: number): SqlExpression => interval('months', steps);
export const days = (steps: number): SqlExpression => interval('days', steps);
export const hours = (steps: number): SqlExpression => interval('hours', steps);
export const minutes = (steps: number): SqlExpression => interval('minutes', steps);
export const seconds = (steps: number): SqlExpression => interval('seconds', steps);
export const milliseconds = (steps: number): SqlExpression => interval('milliseconds', steps);
export const microseconds = (steps: number): SqlExpression => interval('microseconds', steps);

export function dateBin(value: ExprValue, unit: string, steps = 1): SqlExpression {
  return native.timeBucket(interval(unit, steps), asNode(value));
}

export function dateMonth(value: ExprValue): SqlExpression {
  return native.makeDate(asLiteral(2012), native.scalar('month', asNode(value)), asLiteral(1));
}

export function dateMonthDay(value: ExprValue): SqlExpression {
  const expression = asNode(value);
  return native.makeDate(asLiteral(2012), native.scalar('month', expression), native.scalar('day', expression));
}

export function dateDay(value: ExprValue): SqlExpression {
  return native.makeDate(asLiteral(2012), asLiteral(1), native.scalar('day', asNode(value)));
}

export function timezone(zone: string, value: ExprValue): SqlExpression {
  return native.atTimeZone(asNode(value), asLiteral(zone));
}
