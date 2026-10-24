import { describe, it, expect } from 'vitest';
import { clauseNone, clausePoint, type Param, Selection } from '../src/index.js';

describe('Selection', () => {
  it('emits active values and retains queued updates from distinct sources', async () => {
    const selection = Selection.crossfilter();
    const parameter: Param<unknown> = selection;
    const values: unknown[] = [];
    let release: () => void;
    const blocked = new Promise<void>(resolve => { release = resolve; });
    const complete = new Promise<void>(resolve => {
      parameter.addEventListener('value', async value => {
        values.push(value);
        if (values.length === 1) await blocked;
        if (value === 4) resolve();
      });
    });
    const firstSource = {};
    const secondSource = {};
    const second = clausePoint('b', 2, { source: secondSource });
    const latest = clausePoint('a', 4, { source: firstSource });
    selection.update(clausePoint('a', 1, { source: firstSource }));
    selection.update(second);
    selection.update(clausePoint('a', 3, { source: firstSource }));
    selection.update(latest);
    release!();
    await complete;
    await parameter.pending('value');

    expect(values).toEqual([1, 2, 4]);
    expect(parameter.value).toBe(4);
    expect([...selection.clauses]).toEqual([second, latest]);
    expect(selection.active).toBe(latest);
  });

  it('can be reset', () => {
    const selection = new Selection();
    const clause = clausePoint('column', 5, { source: {} });
    selection.update(clause);

    expect(selection.clauses[0]).toEqual(clause);
    expect(selection.clauses.active).toBe(clause);
    expect(selection.clauses).toHaveLength(1);
    selection.reset();
    expect(selection.clauses).toEqual([]);
  });

  it('clears clauses with empty predicates', () => {
    const selection = new Selection();
    const source = {};
    selection.update(clausePoint('column', 5, { source }));
    expect(selection.clauses).toHaveLength(1);

    const clause = clauseNone(source);
    selection.update(clause);
    expect(selection.clauses.active).toBe(clause);
    expect(selection.clauses).toHaveLength(0);
  });

  it('relays reset downstream ', () => {
    const selectionA = new Selection();
    const selectionB = new Selection();
    const upstreamSelection = Selection.crossfilter({
      include: [selectionA, selectionB],
    });

    const clauseA = clausePoint('a', 1, { source: {} });
    const clauseB = clausePoint('b', 2, { source: {} });

    selectionA.update(clauseA);
    selectionB.update(clauseB);

    expect(upstreamSelection.clauses).toHaveLength(2);
    expect(upstreamSelection.clauses).toContain(clauseA);
    expect(upstreamSelection.clauses).toContain(clauseB);

    selectionB.reset();
    expect(upstreamSelection.clauses).toHaveLength(1);
    expect(upstreamSelection.clauses).toContain(clauseA);

    selectionA.reset();
    expect(upstreamSelection.clauses).toHaveLength(0);
  });

  it('can specify a clause to reset', () => {
    const selectionA = new Selection();
    const selectionB = new Selection();
    const upstreamSelection = Selection.crossfilter({
      include: [selectionA, selectionB],
    });

    const clauseA = clausePoint('a', 1, { source: {} });
    const clauseB = clausePoint('b', 2, { source: {} });

    selectionA.update(clauseA);
    selectionB.update(clauseB);

    expect(upstreamSelection.clauses).toHaveLength(2);
    expect(upstreamSelection.clauses).toContain(clauseA);
    expect(upstreamSelection.clauses).toContain(clauseB);

    upstreamSelection.reset([clauseB]);
    expect(upstreamSelection.clauses).toHaveLength(1);
    expect(upstreamSelection.clauses).toContain(clauseA);

  });
});
