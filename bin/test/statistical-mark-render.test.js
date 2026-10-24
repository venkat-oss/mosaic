import assert from 'node:assert/strict';
import test from 'node:test';
import {JSDOM} from 'jsdom';
import * as vg from '../../packages/vgplot/vgplot/src/index.js';
import {createRequire} from 'node:module';
import {pathToFileURL} from 'node:url';
const plotURL=pathToFileURL(createRequire(new URL('../../packages/vgplot/vgplot/src/index.js',import.meta.url)).resolve('@uwdata/mosaic-plot'));
const {Plot}=await import(plotURL);
const {plotRenderer}=await import(new URL('./plot-renderer.js',plotURL));
import {DuckDB} from '../../packages/server/duckdb/src/DuckDB.js';

const dom=new JSDOM('<!doctype html>');
for(const key of ['window','document','Node','Element','HTMLElement','SVGElement'])globalThis[key]=dom.window[key];
globalThis.requestAnimationFrame=()=>0;
globalThis.cancelAnimationFrame=()=>{};
const database=new DuckDB(':memory:',{},'');
await database.exec("CREATE TABLE statistics(g VARCHAR,x DOUBLE,y DOUBLE); INSERT INTO statistics VALUES ('A',0,1),('A',1,3),('A',2,5),('B',0,2),('B',1,4),('B',2,6);CREATE TABLE hex_points(x DOUBLE,y DOUBLE);INSERT INTO hex_points VALUES (0.1,0.1),(0.1,0.1),(0.1,0.1),(0.9,0.9),(NULL,0.5);CREATE TABLE noisy(x DOUBLE,y DOUBLE);INSERT INTO noisy VALUES (1,1),(2,3),(3,2),(4,5),(5,4),(6,6.5)");
async function prepare(name,options,attributes={},table='statistics'){
 const plot=new Plot;
 for(const [key,value]of Object.entries({width:320,height:240,marginLeft:40,marginTop:40,marginRight:40,marginBottom:40,axis:null,xDomain:[0,2],yDomain:[0,8],...attributes}))plot.setAttribute(key,value);
 vg[name]({table,options:{}},options)(plot);
 const mark=plot.marks[0];
 const rows=await database.query(String(mark.query()));
 if(rows[0]?.g)rows.sort((a,b)=>a.g.localeCompare(b.g));
 mark.queryResult(rows);
 return {plot,mark,rows};
}
const paths=svg=>[...svg.querySelectorAll('g[aria-label="line"] path')].map(path=>path.getAttribute('d')).sort();
const expectedLines=['M40,160L280,80','M40,180L280,100'];
const near=(actual,expected)=>assert.ok(Math.abs(actual-expected)<1e-5,actual+' != '+expected);

for(const [name,dim]of [['errorbarX','x'],['errorbarY','y']])test(name+' renders independently calculated grouped confidence bounds and tick markers',async()=>{
 const options=dim==='x'?{x:'y',y:'g',stroke:'g',marker:'tick'}:{x:'g',y:'y',stroke:'g',marker:'tick'};
 const attrs=dim==='x'?{xDomain:[0,8],yDomain:['A','B']}:{xDomain:['A','B'],yDomain:[0,8]};
 const {plot}=await prepare(name,options,attrs);
 const svg=await plotRenderer(plot);
 assert.doesNotMatch(svg.outerHTML,/NaN|Infinity/);
 const lines=[...svg.querySelectorAll('g[aria-label="rule"] > line')];
 assert.equal(lines.length,2);
 const half=1.959963984540054*2/Math.sqrt(3);
 lines.forEach((line,index)=>{
  const average=index===0?3:4;
  if(dim==='x'){
   near(Number(line.getAttribute('x1')),40+(average-half)*30);
   near(Number(line.getAttribute('x2')),40+(average+half)*30);
   assert.equal(line.getAttribute('y1'),String(80+index*80));
   assert.equal(line.getAttribute('y2'),line.getAttribute('y1'));
  }else{
   near(Number(line.getAttribute('y1')),200-(average-half)*20);
   near(Number(line.getAttribute('y2')),200-(average+half)*20);
   assert.equal(line.getAttribute('x1'),String(100+index*120));
   assert.equal(line.getAttribute('x2'),line.getAttribute('x1'));
  }
  for(const edge of ['start','mid','end'])assert.match(line.getAttribute('marker-'+edge),/^url\(#plot-marker-\d+\)$/);
 });
});
for(const ci of [0,0.95])test('regressionY renders exact grouped OLS line paths and ci='+ci,async()=>{
 const {plot,mark}=await prepare('regressionY',{x:'x',y:'y',stroke:'g',ci});
 const svg=await plotRenderer(plot);
 assert.deepEqual(paths(svg),expectedLines);
 assert.equal(svg.querySelectorAll('g[aria-label="area"] > path').length,ci?2:0);
 assert.equal(mark.areaData?.numRows??0,ci?122:0);
 assert.doesNotMatch(svg.outerHTML,/NaN|Infinity/);
});
for(const type of ['hexagon','dot','circle','text'])test('hexbin '+type+' renders actual binned coordinates and excludes null input rows',async()=>{
 const {plot,mark,rows}=await prepare('hexbin',{x:'x',y:'y',fill:vg.count(),type},{xDomain:[0,1],yDomain:[0,1]},'hex_points');
 assert.deepEqual(rows.map(row=>Number(row[mark.channelField('fill').as])).sort(),[1,3]);
 const svg=await plotRenderer(plot);
 assert.doesNotMatch(svg.outerHTML,/NaN|Infinity/);
 if(type==='hexagon'){
  const items=[...svg.querySelectorAll('g[aria-label="dot"] g > path')];
  assert.equal(items.length,2);
  for(const node of items)assert.equal(node.getAttribute('d'),'M0,11.547L10,5.774L10,-5.774L0,-11.547L-10,-5.774L-10,5.774Z');
 }else if(type==='text'){
  assert.deepEqual([...svg.querySelectorAll('g[aria-label="text"] text')].map(node=>node.textContent),['0','1']);
 }else{
  const items=[...svg.querySelectorAll('g[aria-label="dot"] circle')];
  assert.equal(items.length,2);
  assert.deepEqual(items.map(node=>Number(node.getAttribute('cx'))).sort((a,b)=>a-b),[70.5,250.5]);
  assert.ok(items.every(node=>node.getAttribute('r')==='10'));
 }
 assert.equal(svg.querySelectorAll('clipPath rect').length,1);
});
test('regression ci Param recomputes the existing model and changes real rendered bands',async()=>{
 const ci=vg.Param.value(0);
 const {plot,mark}=await prepare('regressionY',{x:'x',y:'y',stroke:'g',ci});
 const model=mark.modelFit;
 assert.equal(mark.areaData,null);
 assert.equal((await plotRenderer(plot)).querySelectorAll('g[aria-label="area"]').length,0);
 ci.update(0.95);
 assert.equal(mark.modelFit,model);
 assert.equal(mark.areaData.numRows,122);
 const svg=await plotRenderer(plot);
 assert.equal(svg.querySelectorAll('g[aria-label="area"] > path').length,2);
 assert.deepEqual(paths(svg),expectedLines);
});
test('regression precision Param recomputes sample density without changing fitted lines',async()=>{
 const precision=vg.Param.value(4);
 const {plot,mark}=await prepare('regressionY',{x:'x',y:'y',stroke:'g',precision});
 assert.equal(mark.areaData.numRows,122);
 precision.update(8);
 assert.equal(mark.areaData.numRows,62);
 assert.deepEqual(paths(await plotRenderer(plot)),expectedLines);
});
for(const [name,dim]of [['errorbarX','x'],['errorbarY','y']])test(name+' ci Param changes independently calculated confidence endpoints',async()=>{
 const ci=vg.Param.value(0.95);
 const options=dim==='x'?{x:'y',y:'g',ci}:{x:'g',y:'y',ci};
 const attrs=dim==='x'?{xDomain:[0,8],yDomain:['A','B']}:{xDomain:['A','B'],yDomain:[0,8]};
 const {plot,mark}=await prepare(name,options,attrs);
 ci.update(0.5);
 assert.equal(mark.ci,0.5);
 const spec=mark.plotSpecs()[0];
 const half=0.6744897501960817*2/Math.sqrt(3);
 for(let index=0;index<2;index++){
  near(spec.options[dim+'1'][index],3+index-half);
  near(spec.options[dim+'2'][index],3+index+half);
 }
 assert.doesNotMatch((await plotRenderer(plot)).outerHTML,/NaN|Infinity/);
});
test('regression confidence bounds use independent residual SSE and a known Student t quantile',async()=>{
 const {mark}=await prepare('regressionY',{x:'x',y:'y'},{xDomain:[1,6],yDomain:[0,8]},'noisy');
 const x=[1,2,3,4,5,6],y=[1,3,2,5,4,6.5],n=x.length;
 const xm=x.reduce((a,b)=>a+b,0)/n,ym=y.reduce((a,b)=>a+b,0)/n;
 const ssx=x.reduce((s,v)=>s+(v-xm)**2,0);
 const slope=x.reduce((s,v,i)=>s+(v-xm)*(y[i]-ym),0)/ssx;
 const intercept=ym-slope*xm;
 const sse=x.reduce((s,v,i)=>s+(y[i]-intercept-slope*v)**2,0);
 const se=Math.sqrt(sse/(n-2)),t=2.7764451051977987;
 const columns=mark.areaData.columns;
 columns.x.forEach((value,index)=>{
  const center=intercept+slope*value;
  const half=t*se*Math.sqrt(1/n+(value-xm)**2/ssx);
  near((columns.y1[index]+columns.y2[index])/2,center);
  near(Math.abs(columns.y2[index]-columns.y1[index])/2,half);
 });
});
test('regression z groups while fill alone retains the original ungrouped result',async()=>{
 const grouped=await prepare('regressionY',{x:'x',y:'y',z:'g'});
 assert.equal(grouped.rows.length,2);
 assert.deepEqual(paths(await plotRenderer(grouped.plot)),expectedLines);
 const fill=await prepare('regressionY',{x:'x',y:'y',fill:'g'});
 assert.equal(fill.rows.length,1);
 assert.equal((await plotRenderer(fill.plot)).querySelectorAll('g[aria-label="line"] > path').length,1);
});
test('hexbin type Param retains its independently observed admitted renderer failure',async()=>{
 const {plot}=await prepare('hexbin',{x:'x',y:'y',fill:vg.count(),type:vg.Param.value('hexagon')},{xDomain:[0,1],yDomain:[0,1]},'hex_points');
 await assert.rejects(plotRenderer(plot),error=>error instanceof TypeError&&error.message==='Plot[type] is not a function');
});
test('hexbin binWidth Param retains its independently observed NaN default radius geometry',async()=>{
 const {plot,mark}=await prepare('hexbin',{x:'x',y:'y',fill:vg.count(),binWidth:vg.Param.value(20)},{xDomain:[0,1],yDomain:[0,1]},'hex_points');
 assert.equal(mark.binWidth,20);
 assert.ok(Number.isNaN(mark.channel('r').value));
 const svg=await plotRenderer(plot);
 assert.equal([...svg.querySelectorAll('g[aria-label="dot"] path')].filter(path=>/NaN/.test(path.getAttribute('d'))).length,2);
});
for(const name of ['hexbin','regressionY'])test(name+' preserves its optional-wire-position versus SQL-source requirement',async()=>{
 await assert.rejects(prepare(name,{}),TypeError);
});
test('native null confidence suppresses regression bands and collapses errorbar bounds',async()=>{
 const regression=await prepare('regressionY',{x:'x',y:'y',ci:null});
 assert.equal(regression.mark.areaData,null);
 assert.equal((await plotRenderer(regression.plot)).querySelectorAll('g[aria-label="area"]').length,0);
 const error=await prepare('errorbarX',{x:'y',y:'g',ci:null},{xDomain:[0,8],yDomain:['A','B']});
 const spec=error.mark.plotSpecs()[0];
 assert.deepEqual(spec.options.x1,[3,4]);
 assert.deepEqual(spec.options.x2,[3,4]);
});
test.after(()=>{database.close();dom.window.close();});
