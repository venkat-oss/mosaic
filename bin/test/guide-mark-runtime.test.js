import assert from 'node:assert/strict';
import test from 'node:test';
import {JSDOM} from 'jsdom';
import * as vg from '../../packages/vgplot/vgplot/src/index.js';
import {createRequire} from 'node:module';
import {pathToFileURL} from 'node:url';
const plotURL=pathToFileURL(createRequire(new URL('../../packages/vgplot/vgplot/src/index.js',import.meta.url)).resolve('@uwdata/mosaic-plot'));
const {Plot}=await import(plotURL);
const {plotRenderer}=await import(new URL('./plot-renderer.js',plotURL));
const dom=new JSDOM('<!doctype html>',{pretendToBeVisual:true});
for(const key of['window','document','Node','Element','HTMLElement','SVGElement'])globalThis[key]=dom.window[key];
globalThis.requestAnimationFrame=dom.window.requestAnimationFrame.bind(dom.window);
globalThis.cancelAnimationFrame=dom.window.cancelAnimationFrame.bind(dom.window);
const names=['frame','axisX','axisY','axisFx','axisFy','gridX','gridY','gridFx','gridFy','hexgrid'];
function plot(name,options={},facets=true){
 const p=new Plot();
 for(const [key,value] of Object.entries({width:320,height:240,marginTop:40,marginRight:40,marginBottom:40,marginLeft:40,axis:null,xDomain:[0,10],yDomain:[0,10],...(facets?{fxDomain:['a','b'],fyDomain:['c','d']}:{})}))p.setAttribute(key,value);
 vg.dot([{x:2,y:3,fx:'a',fy:'c'},{x:7,y:8,fx:'b',fy:'d'}],{x:'x',y:'y',...(facets?{fx:'fx',fy:'fy'}:{})})(p);
 vg[name](options)(p);return p;
}
for(const name of names)test(name+' retains options-only, empty and explicit native source calls',()=>{
 let mark;const p={addMark:value=>mark=value};vg[name]()(p);assert.equal(mark.type,name);assert.equal(mark.source,undefined);assert.equal(mark.data,undefined);
 vg[name]({stroke:'red'})(p);assert.equal(mark.source,null);assert.equal(mark.channel('stroke').value,'red');
 vg[name]([{x:1},{x:2}],{stroke:'blue'})(p);assert.equal(mark.data.numRows,2);assert.equal(mark.channel('stroke').value,'blue');
 vg[name]({table:'guides'},{stroke:'red'})(p);assert.equal(mark.sourceTable(),'guides');assert.equal(mark.channel('stroke').value,'red');
});
const golden={
 frame:['frame',null,0],
 axisX:['x-axis tick label',['0','10','0','10'],'translate(0,9)'],
 axisY:['y-axis tick label',['0','5','10','0','5','10'],'translate(-9,0)'],
 axisFx:['fx-axis tick label',['a','b'],'translate(0,-9)'],
 axisFy:['fy-axis tick label',['c','d'],'translate(9,0)'],
 gridX:['x-grid',null,4],gridY:['y-grid',null,6],gridFx:['fx-grid',null,2],gridFy:['fy-grid',null,2],hexgrid:['hexgrid',null,2]
};
for(const name of names)test(name+' renders actual default guide geometry with facets and null automatic axes',async()=>{
 const p=plot(name,name==='hexgrid'?{binWidth:24}:{});const svg=await plotRenderer(p);const [label,texts,expected]=golden[name];const group=svg.querySelector('g[aria-label="'+label+'"]');assert.ok(group);assert.doesNotMatch(svg.outerHTML,/NaN|Infinity/);assert.equal(p.marks[1].index,-1);
 if(texts){assert.deepEqual([...group.querySelectorAll('text')].map(t=>t.textContent),texts);assert.equal(group.getAttribute('transform'),expected);}
 else if(name.startsWith('grid'))assert.equal(group.querySelectorAll('line').length,expected);
 else if(name==='hexgrid')assert.equal(group.querySelectorAll('path').length,expected);
 assert.equal(p.marks[1].source,null);
});
for(const [name,anchors] of[['axisX',['left','right']],['axisFx',['left','right']],['gridX',['left','right']],['gridFx',['left','right']],['axisY',['top','bottom']],['axisFy',['top','bottom']],['gridY',['top','bottom']],['gridFy',['top','bottom']]])for(const anchor of anchors)test(name+' preserves admitted unsupported '+anchor+' anchor rejection',async()=>{
 const p=plot(name,{anchor});await assert.rejects(plotRenderer(p),new RegExp('invalid anchor: '+anchor));
});
test('native tick formatting keeps callback identity and actual visible labels',async()=>{
 const formatter=value=>'v='+value;const p=plot('axisX',{ticks:[0,5,10],tickFormat:formatter},false);assert.equal(p.marks[1].channel('tickFormat').value,formatter);const svg=await plotRenderer(p);assert.deepEqual([...svg.querySelectorAll('g[aria-label="x-axis tick label"] text')].map(t=>t.textContent),['v=0','v=5','v=10']);
});
test('explicit null tick formatting retains numeric default labels and ticks',async()=>{
 const p=plot('axisX',{ticks:[0,5,10],tickFormat:null},false);const svg=await plotRenderer(p);assert.deepEqual([...svg.querySelectorAll('g[aria-label="x-axis tick label"] text')].map(t=>t.textContent),['0','5','10']);assert.equal(svg.querySelectorAll('g[aria-label="x-axis tick"] path').length,3);
});
test('native numeric intervals and tick-padding Params retain actual guide rendering',async()=>{
 const padding=vg.Param.value(2);const p=plot('axisX',{interval:2,tickPadding:padding},false);
 await p.render();const label=()=>p.element.querySelector('g[aria-label="x-axis tick label"]');
 const before=label().getAttribute('transform');assert.equal(p.marks[1].channel('interval').value,2);
 padding.update(8);await padding.pending('value');
 assert.equal(p.marks[1].channel('tickPadding').value,8);assert.notEqual(label().getAttribute('transform'),before);
 assert.doesNotMatch(p.element.innerHTML,/NaN|Infinity/);
});
test.after(()=>dom.window.close());
