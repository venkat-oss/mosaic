import { describe, expect, it } from 'vitest';
import { isSymbol } from '../src/marks/util/is-symbol.js';

describe('symbol value classification', () => {
  it.each(['star', 'STAR', 'sTaR', 'circle', 'hexagon', 'triangle2'])('recognizes %s', value => {
    expect(isSymbol(value)).toBe(true);
  });

  it.each(['point', 'star ', '', null, undefined, 1])('rejects %s', value => {
    expect(isSymbol(value)).toBe(false);
  });

  it('preserves string coercion before case normalization', () => {
    expect(isSymbol({ toString: () => 'STAR' })).toBe(true);
    expect(isSymbol({ toString: () => 'POINT' })).toBe(false);
  });
});
