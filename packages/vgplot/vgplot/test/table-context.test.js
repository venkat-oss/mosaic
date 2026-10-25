// @vitest-environment jsdom
import { expect, it, vi } from 'vitest';
import * as vg from '../src/index.js';

function controlledCoordinator() {
  const connector={query:vi.fn(()=>{throw new Error('Unexpected connector execution');})};
  const coordinator=new vg.Coordinator(/** @type {any} */ (connector),{logger:null});
  const queries=[];
  vi.spyOn(coordinator,'query').mockImplementation(/** @type {any} */ (query=>{
    const sql=String(query);
    queries.push(sql);
    return Promise.resolve(sql.startsWith('DESC')
      ? [{column_name:'x',column_type:'DOUBLE',null:'YES'}]
      : [{x:sql.includes('OFFSET 1')?2:1}]);
  }));
  return {coordinator,queries,connector};
}

it('keeps table pages, sorts and look-ahead prefetch on their owning coordinator',async()=>{
  const previous=vg.coordinator();
  const global=controlledCoordinator();
  const left=controlledCoordinator();
  const right=controlledCoordinator();
  vg.coordinator(global.coordinator);
  try {
    const leftAPI=vg.createAPIContext({coordinator:left.coordinator});
    const rightAPI=vg.createAPIContext({coordinator:right.coordinator});
    const leftElement=leftAPI.table({from:'left_rows',columns:['x'],rowBatch:1});
    const rightElement=rightAPI.table({from:'right_rows',columns:['x'],rowBatch:1});
    const leftTable=/** @type {any} */ (leftElement).value;
    const rightTable=/** @type {any} */ (rightElement).value;
    await Promise.all([leftTable.pending,rightTable.pending]);
    expect(leftTable.coordinator).toBe(left.coordinator);
    expect(rightTable.coordinator).toBe(right.coordinator);
    expect(left.queries).toEqual([
      'DESCRIBE SELECT "x" AS "__mosaic_field" FROM "left_rows"',
      'SELECT "x" FROM "left_rows" LIMIT 1 OFFSET 0'
    ]);
    expect(right.queries).toEqual([
      'DESCRIBE SELECT "x" AS "__mosaic_field" FROM "right_rows"',
      'SELECT "x" FROM "right_rows" LIMIT 1 OFFSET 0'
    ]);
    expect(global.queries).toEqual([]);
    Object.defineProperties(leftElement,{
      scrollHeight:{value:300},clientHeight:{value:100},scrollTop:{value:150}
    });
    leftElement.dispatchEvent(new Event('scroll'));
    await leftTable.pending;
    expect(left.queries.slice(-2)).toEqual([
      'SELECT "x" FROM "left_rows" LIMIT 1 OFFSET 1',
      'SELECT "x" FROM "left_rows" LIMIT 1 OFFSET 2'
    ]);
    expect(leftTable.body.rows).toHaveLength(2);
    expect(global.queries).toEqual([]);
    expect(right.queries).toHaveLength(2);
    rightElement.querySelector('th').dispatchEvent(new MouseEvent('click'));
    await rightTable.pending;
    expect(right.queries.slice(-2)).toEqual([
      'SELECT "x" FROM "right_rows" ORDER BY "x" LIMIT 1 OFFSET 0',
      'SELECT "x" FROM "right_rows" ORDER BY "x" LIMIT 1 OFFSET 1'
    ]);
    expect(rightTable.body.rows).toHaveLength(1);
    expect(global.queries).toEqual([]);
    expect(left.connector.query).not.toHaveBeenCalled();
    expect(right.connector.query).not.toHaveBeenCalled();
    expect(global.connector.query).not.toHaveBeenCalled();
  } finally {
    left.coordinator.clear();
    right.coordinator.clear();
    global.coordinator.clear();
    vg.coordinator(previous);
  }
});

it('retains per-instance default columns and explicit undefined, null and partial option semantics',async()=>{
  const {coordinator,connector}=controlledCoordinator();
  try {
    const api=vg.createAPIContext({coordinator});
    const first=/** @type {any} */ (api.table({from:'left_rows'})).value;
    const second=/** @type {any} */ (api.table({from:'right_rows',columns:undefined,height:undefined,rowBatch:undefined})).value;
    await Promise.all([first.pending,second.pending]);
    expect(first.columns).toEqual(['*']);
    expect(second.columns).toEqual(['*']);
    expect(first.columns).not.toBe(second.columns);
    expect(first.limit).toBe(100);
    expect(first.element.style.maxHeight).toBe('500px');
    first.columns.push('extra');
    expect(second.columns).toEqual(['*']);
    const columns=['x'];
    const partial=/** @type {any} */ (api.table({from:'partial_rows',columns,height:0,rowBatch:2})).value;
    await partial.pending;
    expect(partial.columns).toBe(columns);
    expect(partial.limit).toBe(2);
    expect(partial.element.style.maxHeight).toBe('0px');
    const omitted=/** @type {any} */ (api.table({from:'omitted_rows',columns:[],height:null,rowBatch:null})).value;
    await omitted.pending;
    expect(omitted.columns).toEqual([]);
    expect(omitted.limit).toBe(0);
    expect(omitted.element.style.maxHeight).toBe('');
    expect(connector.query).not.toHaveBeenCalled();
  } finally {coordinator.clear();}
});
