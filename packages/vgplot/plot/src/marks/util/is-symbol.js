import { SYMBOL_TYPES } from '../../generated/symbol-types.js';

const symbols = new Set(SYMBOL_TYPES);

export function isSymbol(value) {
  return symbols.has(`${value}`.toLowerCase());
}
