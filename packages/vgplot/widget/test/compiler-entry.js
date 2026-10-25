import '../src/compiler.js';
import {
  asLiteral,
  asNode,
  compile,
  createExecutionContext,
  native
} from '@uwdata/mosaic-sql';

export function compilePredicate() {
  return compile([
    native.binary('gte', asNode('amount'), asLiteral(10))
  ], createExecutionContext());
}

export function compileBatch() {
  return compile([42, 7].map(value => native.select([
    native.alias(asLiteral(value), 'value')
  ])), createExecutionContext());
}
