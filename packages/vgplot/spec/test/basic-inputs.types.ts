import type { Menu, Search, Slider } from '../src/index.js';

export const inputContracts = {
  menu: { input:'menu',as:'$choice',from:'rows',column:'items',listMatch:'all',options:[null,{label:3},[],{value:'Alpha',label:'First'}] } satisfies Menu,
  search: { input:'search',as:'$query',field:'category',filterBy:'$brush',type:'regexp' } satisfies Search,
  slider: { input:'slider',as:'$value',select:'interval',min:0,max:4,step:1,width:120,value:2 } satisfies Slider,
  minimalSlider: {input:'slider'} satisfies Slider
};

// @ts-expect-error Declarative input names are discriminators.
export const unknownMenu: Menu = {input:'select'};
// @ts-expect-error TypeScript bindings require their parameter prefix.
export const ordinaryBinding: Menu = {input:'menu',as:'choice'};
// @ts-expect-error Native menu callbacks are outside the declarative contract.
export const callbackMenu: Menu = {input:'menu',format:value=>String(value)};
// @ts-expect-error Search mode admission remains a fixed literal union.
export const exactSearch: Search = {input:'search',type:'exact'};
// @ts-expect-error Slider selection clauses are point or interval clauses.
export const listSlider: Slider = {input:'slider',select:'list'};
