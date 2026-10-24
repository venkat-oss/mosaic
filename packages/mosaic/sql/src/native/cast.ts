import type { ast } from '#polyglot';
import { asNode } from './expression.js';
import { dataType } from './ingress.js';
import { native } from './runtime.js';
import type { ExprValue } from './types.js';

function resolveType(type: string | ast.DataType): ast.DataType {
  if (typeof type !== 'string') return type;
  switch (type.toUpperCase()) {
    case 'INT': case 'INTEGER': return native.dataType('int');
    case 'FLOAT': case 'REAL': return native.dataType('float');
    case 'DOUBLE': return native.dataType('double');
    case 'DATE': return native.dataType('date');
    case 'TIMESTAMP': return native.dataType('timestamp');
    case 'TEXT': return native.dataType('text');
    default: return dataType(type);
  }
}

export function cast(value: ExprValue, type: string | ast.DataType) {
  return native.cast(asNode(value), resolveType(type));
}

export function int32(value: ExprValue) {
  return native.cast(asNode(value), native.dataType('int'));
}

export function float32(value: ExprValue) {
  return native.cast(asNode(value), native.dataType('float'));
}

export function float64(value: ExprValue) {
  return native.cast(asNode(value), native.dataType('double'));
}
