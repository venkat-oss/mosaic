import assert from'node:assert/strict';import{execFileSync}from'node:child_process';import{readFile}from'node:fs/promises';import{resolve}from'node:path';import{fileURLToPath}from'node:url';import test from'node:test';import{JSDOM}from'jsdom';import{geoMercator}from'd3';import{Ajv}from'ajv';import addFormats from'ajv-formats';import{parse as parseYAML}from'yaml';
import{NodeConnector}from'@uwdata/mosaic-core/node-connector';
import{astToDOM,astToESM,astToPython,parseSpec}from'@uwdata/mosaic-spec';
import{compile,createExecutionContext}from'@uwdata/mosaic-sql';
import * as vg from'../../packages/vgplot/vgplot/src/index.js';
import{GeoMark}from'@uwdata/mosaic-plot';
import{Mark}from'@uwdata/mosaic-plot';
import{Plot}from'@uwdata/mosaic-plot';
import{clientsReady}from'../../packages/vgplot/vgplot/test/util/clients-ready.js';
const root=fileURLToPath(new URL('../..',import.meta.url));const projection={'marks':[{'name':'geo'},{'name':'sphere'},{'name':'graticule'},{'name':'voronoi'},{'name':'voronoiMesh'},{'name':'delaunayLink'},{'name':'delaunayMesh'},{'name':'hull'}],'cases':[{'id':'geo-polygons','mark':'geo','kind':'polygons'}],'hostCases':[{'id':'native-projection-initializer','mark':'geo','kind':'projection-initializer'}]};const factories=Object.fromEntries(projection.marks.map(m=>[m.name,vg[m.name]]));
const dom=new JSDOM('<!DOCTYPE html>',{pretendToBeVisual:true});for(const key of['window','document','Node','Element','HTMLElement','SVGElement'])globalThis[key]=dom.window[key];globalThis.requestAnimationFrame=dom.window.requestAnimationFrame.bind(dom.window);globalThis.cancelAnimationFrame=dom.window.cancelAnimationFrame.bind(dom.window);
const schema=JSON.parse(await readFile(resolve(root,'packages/vgplot/spec/dist/mosaic-schema.json'),'utf8'));const ajv=new Ajv({allowUnionTypes:true,allErrors:true});addFormats.default(ajv);const validate=ajv.compile(schema);const database=NodeConnector.make();
function expected(e){return e.kind==='polygons'?2:3;}
function geometry(element,e){const groups=[...element.querySelectorAll('g[aria-label]')].filter(g=>!/(axis|grid|frame)/.test(g.getAttribute('aria-label'))&&g.querySelector('path,circle,line,rect'));const shapes=groups.flatMap(g=>[...g.querySelectorAll('path,circle,line,rect')]);assert.equal(shapes.length,expected(e),JSON.stringify(groups.map(g=>({label:g.getAttribute('aria-label'),count:g.children.length}))));for(const shape of shapes){assert.ok(shape.getAttribute('d')?.startsWith('M'),shape.outerHTML);assert.doesNotMatch(shape.outerHTML,/NaN|Infinity/);}return shapes;}
async function source(name,format){const s=await readFile(resolve(root,'templates/marks/spatial',name+'.'+format),'utf8');return s;}
async function ready(element,errors){return Promise.race([clientsReady(element),new Promise((_,reject)=>{const timer=setTimeout(()=>reject(new Error('render timeout '+JSON.stringify(errors))),8000);timer.unref();})]);}
for(const example of projection.cases){
 test(example.id+' admits JSON/YAML and round trips both public Python paths',async()=>{const spec=JSON.parse(await source(example.id,'json'));assert.deepEqual(parseYAML(await source(example.id,'yaml')),spec);assert.equal(validate(spec),true,JSON.stringify(validate.errors));const ast=parseSpec(spec);assert.deepEqual(ast.toJSON(),spec);for(const code of[await source(example.id,'py'),astToPython(ast)]){const output=execFileSync(process.env.PYTHON_BIN,['-c','import json,sys;ns={};exec(sys.stdin.read(),ns);v=ns["view"];print(json.dumps(v.to_dict(_context=ns) if hasattr(v,"_build_spec") else v.to_dict()))'],{input:code,encoding:'utf8',env:{...process.env,PYTHONDONTWRITEBYTECODE:'1'}});assert.deepEqual(JSON.parse(output),spec);}});
 for(const mode of['native','esm','ast'])test(example.id+' executes generated '+mode+' with real geometry and spatial SQL',async()=>{const coordinator=new vg.Coordinator(await database,{logger:null});const errors=[];coordinator.logger({...coordinator.logger(),error:e=>errors.push(e)});const api=vg.createAPIContext({coordinator,extensions:factories});try{await coordinator.exec('DROP TABLE IF EXISTS spatial_data');const spec=JSON.parse(await source(example.id,'json'));let element;if(mode==='ast')element=(await astToDOM(parseSpec(spec),{api})).element;else{const code=mode==='native'?await source(example.id,'js'):astToESM(parseSpec(spec),{imports:new Map()});const body=code.replace(/^import .*$/gm,'').replace('export default ','const element = ');element=await new Function('vg','return(async()=>{'+body+'\nreturn element;})();')(api);}assert.deepEqual((await ready(element,errors)).map(r=>r.status),['fulfilled']);assert.deepEqual(errors,[]);const m=element.value.marks[0];assert.ok(m instanceof(example.mark==='geo'?GeoMark:Mark));assert.equal(m.type,example.mark);geometry(element,example);}finally{coordinator.clear();}});
}
for(const example of projection.hostCases)test(example.id+' executes only its declared native host boundary',async()=>{for(const format of['json','yaml','py'])await assert.rejects(source(example.id,format),{code:'ENOENT'});const coordinator=new vg.Coordinator(await database,{logger:null});const errors=[];coordinator.logger({...coordinator.logger(),error:e=>errors.push(e)});const api=vg.createAPIContext({coordinator,extensions:factories});try{const code=await source(example.id,'js');const body=code.replace(/^import .*$/gm,'').replace(/^export const /gm,'const ').replace('export default ','const element = ');const element=await new Function('vg','geoMercator','return(async()=>{'+body+'\nreturn element;})();')(api,geoMercator);assert.deepEqual((await ready(element,errors)).map(r=>r.status),['fulfilled']);assert.deepEqual(errors,[]);geometry(element,example);assert.equal(typeof element.value.getAttribute('projectionType'),'function');}finally{coordinator.clear();}});
test('strict data/geometry and initializer boundaries remain unchanged',async()=>{
 for(const name of['geo','voronoi','voronoiMesh','delaunayLink','delaunayMesh','hull']){const spec={plot:[{mark:name,data:[],x:'x',y:'y'}]};delete spec.plot[0].data;assert.equal(validate(spec),false,name);}
 for(const name of['sphere','graticule']){const spec={plot:[{mark:name}]};spec.plot[0].data=[];assert.equal(validate(spec),false,name);}
 const spec=JSON.parse(await source('geo-polygons','json'));spec.plot[0].data={type:'FeatureCollection',features:[]};assert.equal(validate(spec),false);spec.plot[0].data=[];spec.plot[0].geometry={notGeometry:1};assert.equal(validate(spec),false);const initializer=JSON.parse(await source('geo-polygons','json'));initializer.projectionType={stream:'native'};assert.equal(validate(initializer),false);
});
test('Geo implicit constructor and decorator argument policies preserve their distinct effects',()=>{
 let observed;const plot={addMark:m=>observed=m};const options={};factories.geo(vg.from('spatial_data'),options,{ignored:true})(plot);assert.ok(observed instanceof GeoMark);assert.deepEqual(options,{});assert.deepEqual(compile([observed.channelField('geometry').field],createExecutionContext()),['ST_ASGEOJSON("geom")']);assert.deepEqual(observed.reqs,{});
 for(const name of['sphere','graticule']){factories[name]({stroke:'steelblue'})(plot);assert.equal(observed.source,null);assert.equal(observed.channel('stroke').value,'steelblue');}
 for(const name of['voronoi','voronoiMesh','delaunayLink','delaunayMesh','hull']){factories[name]({x:1})(plot);assert.equal(observed.data.numRows,1);assert.equal(observed.channel('x').value,1);}
});
test('raw FeatureCollection source still fails and omitted geometry on raw GeoJSON arrays stays empty',async()=>{
 const feature={type:'Feature',properties:{},geometry:{type:'Point',coordinates:[0,0]}};const raw=new Plot();factories.geo({type:'FeatureCollection',features:[feature]})(raw);vg.projectionType('equirectangular')(raw);await assert.rejects(raw.render(),/length.*null/);
 const array=new Plot();factories.geo([feature])(array);vg.projectionType('equirectangular')(array);await array.render();assert.equal(array.element.querySelectorAll('g[aria-label="geo"] path').length,0);
});
test('GeoJSON decoding preserves its first-row string gate',()=>{let observed;factories.geo([],{geometry:'geometry'})({addMark:m=>observed=m});const point='{"type":"Point","coordinates":[0,0]}';observed.queryResult([{geometry:null},{geometry:point}]);assert.equal(observed.data.columns.geometry[1],point);observed.queryResult([{geometry:point},{geometry:null}]);assert.deepEqual(observed.data.columns.geometry[0],{type:'Point',coordinates:[0,0]});assert.equal(observed.data.columns.geometry[1],null);});
test('projection Param updates actual geographic paths',async()=>{
 const spec=JSON.parse(await source('geo-polygons','json'));spec.params={rotation:[0,0,0]};spec.projectionRotate='$rotation';
 const coordinator=new vg.Coordinator(await database,{logger:null});const api=vg.createAPIContext({coordinator,extensions:factories});
 try{
  const result=await astToDOM(parseSpec(spec),{api});await clientsReady(result.element);const before=geometry(result.element,{mark:'geo',kind:'polygons'}).map(n=>n.getAttribute('d'));
  const rotation=result.params.get('rotation');rotation.update([20,0,0]);await rotation.pending('value');await result.element.value.update();await clientsReady(result.element);
  assert.notDeepEqual(geometry(result.element,{mark:'geo',kind:'polygons'}).map(n=>n.getAttribute('d')),before);
 }finally{coordinator.clear();}
});
test('Geo table sources query default geometry as decoded GeoJSON',async()=>{
 const spec={config:{extensions:['spatial']},data:{spatial_data:{type:'table',query:'SELECT ST_Point(-20,0) AS geom UNION ALL SELECT ST_Point(20,10)'}},plot:[{mark:'geo',data:{from:'spatial_data'},stroke:'steelblue',r:4}],projectionType:'equirectangular',projectionDomain:{type:'Sphere'},width:420,height:260};
 const coordinator=new vg.Coordinator(await database,{logger:null});const errors=[];coordinator.logger({...coordinator.logger(),error:error=>errors.push(error)});const api=vg.createAPIContext({coordinator,extensions:factories});
 try{
  await coordinator.exec('DROP TABLE IF EXISTS spatial_data');const result=await astToDOM(parseSpec(spec),{api});await clientsReady(result.element);
  assert.deepEqual(errors,[]);const mark=result.element.value.marks[0];assert.match(compile([mark.query()],coordinator.sqlContext.execution)[0],/ST_ASGEOJSON\("geom"\)/);
  assert.deepEqual(mark.data.columns.geometry,[{type:'Point',coordinates:[-20,0]},{type:'Point',coordinates:[20,10]}]);
  geometry(result.element,{mark:'geo',kind:'polygons'});
 }finally{coordinator.clear();}
});
test('Geo native geometry accessors preserve callback identity and render indexed geometry',async()=>{
 const points=[{type:'Point',coordinates:[-20,0]},{type:'Point',coordinates:[0,10]},{type:'Point',coordinates:[20,-5]}];
 const accessor=(_datum,index)=>points[index];const p=new Plot();factories.geo(points.map((_,index)=>({id:index})),{geometry:accessor,r:4})(p);
 vg.projectionType('equirectangular')(p);vg.projectionDomain({type:'Sphere'})(p);vg.width(420)(p);vg.height(260)(p);
 await p.render();assert.equal(p.marks[0].channel('geometry').value,accessor);geometry(p.element,{mark:'geo',kind:'accessor'});
});
test.after(async()=>{(await database)._db.close();dom.window.close();});
