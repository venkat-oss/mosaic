import { asNode } from './expression.js';
import { Dialect, native } from './runtime.js';
import type { ExprValue, SqlExpression } from './types.js';

export function geojson(expr: ExprValue): SqlExpression {
  return native.call('st_asgeojson', [asNode(expr)], { source_dialect: Dialect.DuckDB });
}

export function x(expr: ExprValue): SqlExpression {
  return native.call('st_x', [asNode(expr)], { source_dialect: Dialect.DuckDB });
}

export function y(expr: ExprValue): SqlExpression {
  return native.call('st_y', [asNode(expr)], { source_dialect: Dialect.DuckDB });
}

export function centroid(expr: ExprValue): SqlExpression {
  return native.call('st_centroid', [asNode(expr)], { source_dialect: Dialect.DuckDB });
}

export function centroidX(expr: ExprValue): SqlExpression {
  return x(centroid(expr));
}

export function centroidY(expr: ExprValue): SqlExpression {
  return y(centroid(expr));
}
