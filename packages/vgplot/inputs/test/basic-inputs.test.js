// @vitest-environment jsdom
import { and, compile, createExecutionContext } from '@uwdata/mosaic-sql';
import { Param, Selection } from '@uwdata/mosaic-core';
import { describe, expect, it, vi } from 'vitest';
import { Menu, Search, Slider } from '../src/index.js';

describe('Menu retained client', () => {
  it.each([2, null])('selects an unbound initial value %s after creating options', value => {
    const menu = new Menu({options:[1,2,null],value});
    expect(menu.selectedValue()).toBe(value);
  });

  it('retains native containers, option labels, formatting, and value identity', async () => {
    const element = document.createElement('section');
    const binding = Param.value(2);
    const menu = new Menu({element,as:binding,options:[1,{value:2,label:'Second'},null],format:value=>`Value ${value}`});
    expect(menu.element).toBe(element);
    expect(/** @type {any} */ (element).value).toBe(menu);
    expect([...menu.select.options].map(option=>option.innerText)).toEqual(['Value 1','Second','Value null']);
    expect(menu.selectedValue()).toBe(2);
    menu.select.selectedIndex=0;
    menu.select.dispatchEvent(new Event('input'));
    await binding.pending('value');
    expect(binding.value).toBe(1);
    binding.update(2);
    await binding.pending('value');
    expect(menu.selectedValue()).toBe(2);
    expect(menu.query()).toBeNull();
  });

  it.each(/** @type {const} */ (['any','all']))('retains %s list queries and list selection clauses', async listMatch => {
    const selection = Selection.crossfilter();
    const menu = new Menu({from:'rows',column:'items',listMatch,as:selection});
    expect(String(menu.query())).toContain('UNNEST("items") AS "value"');
    menu.queryResult([{value:'Alpha'}]).update();
    expect(menu.data[0]).toEqual({value:'',label:'All'});
    menu.publish('Alpha');
    await selection.pending('value');
    expect(selection.active.meta).toMatchObject({type:'list',match:listMatch});
    expect(compile([and(selection.predicate() ?? [])], createExecutionContext()).join(';\n')).toContain(listMatch==='any'?'&&':'@>');
    menu.publish('');
    await selection.pending('value');
    expect(selection.value).toBeUndefined();
  });
});

describe('Search retained client', () => {
  it.each(/** @type {const} */ (['contains','prefix','suffix','regexp']))('retains %s predicate generation', type => {
    const search = new Search({type,field:'category',from:'rows',column:'category'});
    expect(search.clause('Al').meta).toMatchObject({type:'match',method:type});
    expect(compile([search.clause('Al').predicate], createExecutionContext()).join(';\n').toLowerCase()).toContain(({contains:'contains',prefix:'starts_with',suffix:'ends_with',regexp:'regexp_matches'})[type]);
    expect(search.clause('').predicate).toBeNull();
    expect(String(search.query())).toBe('SELECT DISTINCT "category" AS "list" FROM "rows"');
    search.queryResult([{list:'Alpha'}]).update();
    expect(search.element.querySelectorAll('datalist option')).toHaveLength(1);
  });

  it('does not populate native text from an already-valued Param until an update occurs', async () => {
    const binding = Param.value('Initial');
    const search = new Search({as:binding});
    expect(search.searchbox.value).toBe('');
    binding.update('Later');
    await binding.pending('value');
    expect(search.searchbox.value).toBe('Later');
    search.searchbox.value='';
    search.searchbox.dispatchEvent(new Event('input'));
    await binding.pending('value');
    expect(binding.value).toBeNull();
    expect(search.query()).toBeNull();
  });
});

describe('Slider retained client', () => {
  it('queries missing bounds and derives its step without overriding explicit bounds', () => {
    const slider = new Slider({from:'rows',column:'x',min:0});
    expect(String(slider.query())).toBe('SELECT MIN("x") AS "min", MAX("x") AS "max" FROM "rows"');
    slider.queryResult([{min:1,max:6}]);
    expect(slider.min).toBe(0);
    expect(slider.max).toBe(6);
    expect(slider.step).toBe(0.012);
    expect(slider.query()).not.toBeNull();
    slider.queryResult([{min:2,max:4}]);
    expect([slider.min,slider.max,slider.step]).toEqual([0,4,0.008]);
    slider.queryResult([{min:null,max:null}]);
    expect([slider.min,slider.max,slider.step]).toEqual([0,4,0.008]);
  });

  it.each(/** @type {const} */ (['point','interval']))('retains %s selection clauses and activation', async select => {
    const selection = Selection.crossfilter();
    const slider = new Slider({as:selection,min:1,max:5,step:1,field:'x',select});
    const activate = [];
    selection.addEventListener('activate',clause=>{activate.push(clause);});
    slider.activate();
    expect(activate).toHaveLength(1);
    slider.publish(3);
    await selection.pending('value');
    expect(selection.active.meta).toMatchObject({type:select});
    expect(selection.value).toEqual(select==='interval'?[1,3]:3);
  });

  it('retains scalar Param binding and native width', async () => {
    const binding = Param.value(3);
    const slider = new Slider({as:binding,min:0,max:5,width:120});
    expect(slider.slider.value).toBe('3');
    expect(slider.slider.style.width).toBe('120px');
    slider.slider.value='4';
    slider.slider.dispatchEvent(new Event('input'));
    await binding.pending('value');
    expect(binding.value).toBe(4);
  });
});

it.each([{name:'menu',InputClass:Menu},{name:'search',InputClass:Search}])('activates $name selections through the native focus event',({InputClass})=>{
  const selection=Selection.crossfilter();
  const activation=vi.fn();
  selection.addEventListener('activate',activation);
  const input=new InputClass({as:selection,field:'category',options:['Alpha']});
  const control=input.element.querySelector('select, input');
  control.dispatchEvent(new Event('focus'));
  expect(activation).toHaveBeenCalledExactlyOnceWith(expect.objectContaining({source:input,fields:expect.any(Array)}));
});
