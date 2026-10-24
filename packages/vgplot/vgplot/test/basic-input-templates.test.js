// @vitest-environment jsdom
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { astToDOM, parseSpec } from '@uwdata/mosaic-spec';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it, vi } from 'vitest';
import { parse as parseYAML } from 'yaml';
import * as vg from '../src/index.js';
import { clientsReady } from './util/clients-ready.js';
import { pythonExecutable } from './util/python.js';

const root=resolve(import.meta.dirname,'../../../..');
const directories=['templates/inputs/basic'];
const names=['menu-table','slider-param'];
const schema=JSON.parse(await readFile(resolve(root,'packages/vgplot/spec/dist/mosaic-schema.json'),'utf8'));
const validator=new Ajv({allowUnionTypes:true});
addFormats.default(validator);
const validate=validator.compile(schema);
const database=NodeConnector.make();
async function context() {
  const connector=await database;
  await connector.query({type:'exec',sql:'DROP TABLE IF EXISTS input_data'});
  const errors=[];
  const coordinator=new vg.Coordinator(connector,{logger:null});
  coordinator.logger({...coordinator.logger(),error:error=>errors.push(error)});
  await coordinator.preaggregator.dropSchema();
  return {coordinator,errors,api:vg.createAPIContext({coordinator})};
}
async function assertInput(element,errors,name) {
  expect((await clientsReady(element)).map(result=>result.status)).toEqual(['fulfilled']);
  expect(errors).toEqual([]);
  const input=/** @type {any} */ (element).value;
  expect(input.constructor.name).toBe(name.split('-')[0].replace(/^./,c=>c.toUpperCase()));
  if(name.startsWith('menu')) {
    expect(input.select.options.length).toBeGreaterThan(0);
  } else {
    expect(input.min).toBe(1);
    expect(input.max).toBe(3);
    expect(input.step).toBe(1);
  }
}

describe.each(names)('%s input starter',name=>{
  it('admits JSON and YAML and activates a real database-backed input',async()=>{
    for(const extension of ['json','yaml']) {
      const text=await readFile(resolve(root,directories[0],`${name}.${extension}`),'utf8');

      const spec=extension==='json'?JSON.parse(text):parseYAML(text);
      expect(validate(spec),JSON.stringify(validate.errors)).toBe(true);
      const ast=parseSpec(spec);
      expect(ast.toJSON()).toEqual(spec);
      const {coordinator,errors,api}=await context();
      try {
        const {element}=await astToDOM(ast,{api});
        await assertInput(element,errors,name);
      } finally {coordinator.clear();}
    }
  },30000);

  it('executes both downloadable JavaScript starters through live coordinator queries',async()=>{
    for(const directory of directories) {
      const text=await readFile(resolve(root,directory,`${name}.js`),'utf8');
      const source=text.replace(/^import \* as vg from ['"]@uwdata\/vgplot['"];?$/m,'').replace('export default ','return ');
      const {coordinator,errors,api}=await context();
      try {
        const element=await new Function('vg',`return (async()=>{${source}})();`)(api);
        await assertInput(element,errors,name);
      } finally {coordinator.clear();}
    }
  },30000);
});

it.each(/** @type {const} */ (['menu','search','slider']))('keeps %s context-scoped connection and native output identity',name=>{
  const connect=vi.fn();
  const api=vg.createAPIContext({coordinator:/** @type {any} */ ({connect})});
  const binding=vg.Param.value(1);
  const options={as:binding,options:[1,2],min:0,max:3};
  const element=api[name](options);
  const input=/** @type {any} */ (element).value;
  expect(connect).toHaveBeenCalledExactlyOnceWith(input);
  expect(input.selection).toBe(binding);
  expect(vg[name].name).toBe(name);
  expect(vg[name].length).toBe(1);
});

it('executes native-only DOM and format callback starter adapters',async()=>{
  for(const directory of directories) {
    const text=await readFile(resolve(root,directory,'native-menu.js'),'utf8');
    const source=text.replace(/^import \* as vg from ['"]@uwdata\/vgplot['"];?$/m,'').replace('export default ','return ');
    const connect=vi.fn();
    const api=vg.createAPIContext({coordinator:/** @type {any} */ ({connect})});
    const element=new Function('vg',source)(api);
    expect(element.tagName).toBe('SECTION');
    expect([...element.querySelectorAll('option')].map(option=>option.innerText)).toEqual(['Value 1','Value 2']);
    expect(connect).toHaveBeenCalledExactlyOnceWith(element.value);
  }
});

it('filters autocomplete queries through a linked menu selection',async()=>{
  const {coordinator,errors,api}=await context();
  try {
    await coordinator.exec(vg.createTable('input_data',"SELECT * FROM (VALUES (1,'Alpha'),(2,'Beta'),(3,'Gamma')) AS t(x,category)"));
    const brush=vg.Selection.intersect();
    const menu=api.menu({from:'input_data',column:'category',as:brush});
    const search=api.search({from:'input_data',column:'category',filterBy:brush});
    const root=document.createElement('div');
    root.append(menu,search);
    expect((await clientsReady(root)).every(result=>result.status==='fulfilled')).toBe(true);
    const menuInput=/** @type {any} */ (menu).value;
    const searchInput=/** @type {any} */ (search).value;
    expect(Array.from(searchInput.data)).toHaveLength(3);
    menuInput.select.value='Alpha';
    menuInput.select.dispatchEvent(new Event('input'));
    await brush.pending('value');
    expect((await clientsReady(root)).every(result=>result.status==='fulfilled')).toBe(true);
    expect(Array.from(searchInput.data,row=>/** @type {any} */ (row).list)).toEqual(['Alpha']);
    expect(errors).toEqual([]);
  } finally {coordinator.clear();}
},30000);


it('cancels buffered prefetch before reaching the native connector',async()=>{
  const {coordinator}=await context();
  const connector=await database;
  const queries=[];
  coordinator.databaseConnector(/** @type {any} */ ({query(request){
    queries.push(request.sql);
    return connector.query(request);
  }}));
  try {
    const request=coordinator.prefetch('SELECT 42 AS answer');
    const rejected=expect(request).rejects.toBe('Canceled');
    coordinator.cancel([request]);
    await rejected;
    await new Promise(resolve=>requestAnimationFrame(resolve));
    expect(queries).toEqual([]);
  } finally {coordinator.clear();}
},30000);

it.each([{options:[1,2,3]},{from:'input_data',column:'x'}])('selects the initial unbound menu value with %j',async options=>{
  const {coordinator,errors,api}=await context();
  try {
    await coordinator.exec(vg.createTable('input_data','SELECT * FROM (VALUES (1),(2),(3)) AS t(x)'));
    const menu=api.menu({...options,value:2});
    expect((await clientsReady(menu)).every(result=>result.status==='fulfilled')).toBe(true);
    expect(/** @type {any} */ (menu).value.selectedValue()).toBe(2);
    expect(errors).toEqual([]);
  } finally {coordinator.clear();}
},30000);

it('updates filtered slider bounds while retaining explicit bounds and steps',async()=>{
  const {coordinator,errors,api}=await context();
  const connector=await database;
  const queries=[];
  coordinator.databaseConnector(/** @type {any} */ ({query(request){
    queries.push(request.sql);
    return connector.query(request);
  }}));
  try {
    await coordinator.exec(vg.createTable('input_data',"SELECT * FROM (VALUES (1,'Alpha'),(2,'Beta'),(3,'Beta')) AS t(x,category)"));
    const brush=vg.Selection.intersect();
    const menu=api.menu({as:brush,field:'category',options:['Alpha','Beta','Missing']});
    const sliders=[
      api.slider({from:'input_data',column:'x',filterBy:brush}),
      api.slider({from:'input_data',column:'x',filterBy:brush,min:0,step:0.5}),
      api.slider({from:'input_data',column:'x',filterBy:brush,min:0,max:5,step:1}),
      api.slider({min:0,max:10,filterBy:brush})
    ];
    const root=document.createElement('div');
    root.append(menu,...sliders);
    expect((await clientsReady(root)).every(result=>result.status==='fulfilled')).toBe(true);
    const inputs=sliders.map(slider=>/** @type {any} */ (slider).value);
    expect(inputs.map(input=>[input.min,input.max,input.step])).toEqual([[1,3,0.004],[0,3,0.5],[0,5,1],[0,10,undefined]]);
    const control=/** @type {any} */ (menu).value;
    async function select(value) {
      control.select.value=value;
      control.select.dispatchEvent(new Event('input'));
      await brush.pending('value');
      expect((await clientsReady(root)).every(result=>result.status==='fulfilled')).toBe(true);
      expect(inputs.map(input=>input.curval.innerText)).toEqual(inputs.map(input=>input.slider.value));
    }
    await select('Beta');
    expect(inputs.map(input=>[input.min,input.max,input.step])).toEqual([[2,3,0.002],[0,3,0.5],[0,5,1],[0,10,undefined]]);
    await select('Alpha');
    expect(inputs.map(input=>[input.min,input.max,input.step])).toEqual([[1,1,1],[0,1,0.5],[0,5,1],[0,10,undefined]]);
    await select('Missing');
    expect(inputs.map(input=>[input.min,input.max,input.step])).toEqual([[1,1,1],[0,1,0.5],[0,5,1],[0,10,undefined]]);
    expect(queries).not.toContain('null');
    expect(errors).toEqual([]);
  } finally {coordinator.clear();}
},30000);

it.each(['json','yaml','js','py'])('runs the linked filtered-slider %s starter through native queries',async extension=>{
  const {coordinator,errors,api}=await context();
  try {
    const text=await readFile(resolve(root,directories[0],`slider-filtered.${extension}`),'utf8');
    let element;
    if(extension==='js') {
      const source=text.replace(/^import \* as vg from ['"]@uwdata\/vgplot['"];?$/m,'').replace('export default ','return ');
      element=await new Function('vg',`return (async()=>{${source}})();`)(api);
    } else {
      const spec=extension==='py'
        ? JSON.parse(execFileSync(pythonExecutable,['-c','import json,sys;ns={};exec(sys.stdin.read(),ns);print(json.dumps(ns["view"].to_dict()))'],{input:text,encoding:'utf8'}))
        : extension==='json'?JSON.parse(text):parseYAML(text);
      expect(validate(spec),JSON.stringify(validate.errors)).toBe(true);
      ({element}=await astToDOM(parseSpec(spec),{api}));
    }
    expect((await clientsReady(element)).every(result=>result.status==='fulfilled')).toBe(true);
    const menu=/** @type {any} */ (element.querySelector('select').parentElement).value;
    const slider=/** @type {any} */ (element.querySelector('input[type=range]').parentElement).value;
    expect([slider.min,slider.max]).toEqual([1,3]);
    menu.select.value='Beta';
    menu.select.dispatchEvent(new Event('input'));
    await menu.selection.pending('value');
    expect([slider.min,slider.max]).toEqual([2,2]);
    expect(errors).toEqual([]);
  } finally {coordinator.clear();}
},30000);
