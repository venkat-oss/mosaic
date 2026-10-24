import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';
import { JSDOM } from 'jsdom';
import { symbolSquare } from 'd3';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { parse as parseYAML } from 'yaml';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { astToDOM, astToESM, astToPython, parseSpec } from '@uwdata/mosaic-spec';
import * as vg from '../../packages/vgplot/vgplot/src/index.js';
import { clientsReady } from '../../packages/vgplot/vgplot/test/util/clients-ready.js';
const root = fileURLToPath(new URL('../..', import.meta.url));
const projection = {'marks':[{'name':'barX'},{'name':'barY'},{'name':'cell'},{'name':'cellX'},{'name':'cellY'},{'name':'rect'},{'name':'rectX'},{'name':'rectY'},{'name':'dot'},{'name':'dotX'},{'name':'dotY'},{'name':'circle'},{'name':'hexagon'},{'name':'ruleX'},{'name':'ruleY'},{'name':'tickX'},{'name':'tickY'}],'cases':[{'id':'dot','mark':'dot','kind':'base'}],'hostCases':[]};
const factories = Object.fromEntries(projection.marks.map(mark => [mark.name, vg[mark.name]]));
const directory = resolve(root, 'templates/marks/basic');
const dom = new JSDOM('<!DOCTYPE html>', { pretendToBeVisual: true });
for (const key of ['window', 'document', 'Node', 'Element', 'HTMLElement', 'SVGElement']) globalThis[key] = dom.window[key];
globalThis.requestAnimationFrame = dom.window.requestAnimationFrame.bind(dom.window);
globalThis.cancelAnimationFrame = dom.window.cancelAnimationFrame.bind(dom.window);
const schema = JSON.parse(await readFile(resolve(root, 'packages/vgplot/spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);
const database = NodeConnector.make();
async function source(name,extension){const text=await readFile(resolve(directory,name+'.'+extension),'utf8');return text;}
function expected(){return 4;}
function geometry(element,example){
 const groups=[...element.querySelectorAll('g[aria-label]')].filter(g=>!/(axis|grid|frame|facet)/.test(g.getAttribute('aria-label'))&&g.querySelector('rect,circle,path,line'));
 const shapes=groups.flatMap(g=>[...g.querySelectorAll('rect,circle,path,line')]);
 assert.equal(shapes.length,expected(example),JSON.stringify(groups.map(g=>({label:g.getAttribute('aria-label'),count:g.children.length}))));
 for(const node of shapes)assert.doesNotMatch(node.outerHTML,/NaN|Infinity/);
 return shapes;
}
for(const example of projection.cases){
 test(example.id+' validates and round trips both generated Python authoring paths',async()=>{
  const spec=JSON.parse(await source(example.id,'json'));assert.deepEqual(parseYAML(await source(example.id,'yaml')),spec);assert.equal(validate(spec),true,JSON.stringify(validate.errors));
  const ast=parseSpec(spec);assert.deepEqual(ast.toJSON(),spec);
  for(const code of[await source(example.id,'py'),astToPython(ast)]){
   const result=execFileSync(process.env.PYTHON_BIN,['-c','import json,sys;ns={};exec(sys.stdin.read(),ns);view=ns["view"];print(json.dumps(view.to_dict(_context=ns) if hasattr(view,"_build_spec") else view.to_dict()))'],{input:code,encoding:'utf8',env:{...process.env,PYTHONDONTWRITEBYTECODE:'1',PYTHONHASHSEED:'0'}});assert.deepEqual(JSON.parse(result),spec);
  }
 });
 for(const mode of['native','esm','ast'])test(example.id+' executes generated factories in '+mode+' through DuckDB and SVG',async()=>{
  const coordinator=new vg.Coordinator(await database,{logger:null});const errors=[];coordinator.logger({...coordinator.logger(),error:error=>errors.push(error)});const api=vg.createAPIContext({coordinator,extensions:factories});
  try{
   await coordinator.exec('DROP TABLE IF EXISTS basic_data');const spec=JSON.parse(await source(example.id,'json'));let element;
   if(mode==='ast')element=(await astToDOM(parseSpec(spec),{api})).element;
   else{const code=mode==='native'?await source(example.id,'js'):astToESM(parseSpec(spec),{imports:new Map()});const body=code.replace(/^import .*$/gm,'').replace('export default ','const element = ');element=await new Function('vg','return (async()=>{'+body+'\nreturn element;})();')(api);}
   assert.deepEqual((await Promise.race([clientsReady(element),new Promise((_,reject)=>{const timer=setTimeout(()=>reject(new Error('render timeout: '+JSON.stringify(errors))),5000);timer.unref();})])).map(r=>r.status),['fulfilled']);assert.deepEqual(errors,[]);geometry(element,example);
   assert.equal(element.value.marks[0].type,example.mark);
   assert.equal(element.value.marks[0].data.numRows,4);
  }finally{coordinator.clear();}
 });
}

test('strict wire rejects wrong variants, properties and retained target differences',async()=>{
 const dot=JSON.parse(await source('dot','json'));
 for(const patch of[{mark:'unknown'},{unknownOwnedField:1},{data:undefined}]){const spec=structuredClone(dot);Object.assign(spec.plot[0],patch);assert.equal(validate(spec),false);}
 const rule={plot:[{mark:'ruleY',data:[],y:'v'}]};rule.plot[0].x1='t';assert.equal(validate(rule),false);
 const interval={plot:[{mark:'barX',data:[],x:'t',y:'v'}]};interval.plot[0].interval=2;assert.equal(validate(interval),false);
 for(const name of['circle','hexagon']){const spec=structuredClone(dot);spec.plot[0].mark=name;spec.plot[0].symbol='square';assert.equal(validate(spec),true,JSON.stringify(validate.errors));}
});
test('generated ordinary factories preserve source/options overloads',()=>{
 for(const name of projection.marks.map(m=>m.name)){
  let observed;const plot={addMark:m=>observed=m};factories[name]({x:7})(plot);assert.equal(observed.type,name);assert.equal(observed.data.numRows,1);assert.equal(observed.channel('x').value,7);
  factories[name]({table:'basic_data'},{x:'t'})(plot);assert.equal(observed.sourceTable(),'basic_data');assert.equal(observed.channel('x').field.toString(),'"t"');
 }
});
test('raw D3 symbol object retains field classification while the explicit host Param preserves its value',()=>{
 let observed;const plot={addMark:m=>observed=m};factories.dot([{t:1}],{symbol:symbolSquare})(plot);assert.equal(observed.channel('symbol').field,symbolSquare);
 factories.dot([{t:1}],{symbol:vg.Param.value(symbolSquare)})(plot);assert.equal(observed.channel('symbol').value,symbolSquare);
});
test('parameter radius updates actual SVG geometry',async()=>{
 const spec=JSON.parse(await source('dot','json'));
 spec.params={radius:4};spec.plot[0].r='$radius';
 const coordinator=new vg.Coordinator(await database,{logger:null});const api=vg.createAPIContext({coordinator,extensions:factories});
 try{
  const result=await astToDOM(parseSpec(spec),{api});await clientsReady(result.element);
  assert.deepEqual(geometry(result.element,{kind:'parameter'}).map(n=>+n.getAttribute('r')),[4,4,4,4]);
  const radius=result.params.get('radius');radius.update(9);await radius.pending('value');await clientsReady(result.element);
  assert.deepEqual(geometry(result.element,{kind:'parameter'}).map(n=>+n.getAttribute('r')),[9,9,9,9]);
 }finally{coordinator.clear();}
});
test('literal interval retains its wire-valid SQL field interpretation',async()=>{
 const spec={data:{basic_data:{type:'table',query:"SELECT * FROM (VALUES (DATE '2024-01-01',2,'A'),(DATE '2024-01-03',4,'B')) AS t(date,v,category)"}},plot:[{mark:'barX',data:{from:'basic_data'},x:'date',y:'category',interval:'day'}]};
 assert.equal(validate(spec),true,JSON.stringify(validate.errors));
 const coordinator=new vg.Coordinator(await database,{logger:null});const errors=[];coordinator.logger({...coordinator.logger(),error:error=>errors.push(error)});const api=vg.createAPIContext({coordinator,extensions:factories});
 try{await coordinator.exec('DROP TABLE IF EXISTS basic_data');const result=await astToDOM(parseSpec(spec),{api});await clientsReady(result.element);assert.equal(errors.length,1);assert.match(errors[0].message,/Referenced column "day" not found/);}finally{coordinator.clear();}
});
test.after(()=>dom.window.close());
