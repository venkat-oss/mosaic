import assert from 'node:assert/strict';
import test from 'node:test';
import { JSDOM } from 'jsdom';
import { Plot } from '@uwdata/mosaic-plot';
import { Mark } from '@uwdata/mosaic-plot';
import * as vg from '../../packages/vgplot/vgplot/src/index.js';
const dom = new JSDOM('<!DOCTYPE html>');
for (const name of ['window', 'document', 'Node', 'Element', 'HTMLElement', 'SVGElement']) globalThis[name] = dom.window[name];
const data=[{t:1,u:2,v:3,w:4,category:'a',row:'first'},{t:3,u:4,v:5,w:6,category:'b',row:'second'}];
const cases=[
 ['barX',{x:'v',y:'category'}],['barY',{x:'category',y:'v'}],
 ['cell',{x:'category',y:'row',fill:'v'}],['cellX',{x:'category',y:'row',fill:'v'}],['cellY',{x:'category',y:'row',fill:'v'}],
 ['rect',{x1:'t',x2:'u',y1:'v',y2:'w'}],['rectX',{x1:'t',x2:'u',y1:'v',y2:'w'}],['rectY',{x1:'t',x2:'u',y1:'v',y2:'w'}],
 ['dot',{x:'t',y:'v'}],['dotX',{x:'t',y:'v'}],['dotY',{x:'t',y:'v'}],['circle',{x:'t',y:'v'}],['hexagon',{x:'t',y:'v'}],
 ['ruleX',{x:'t',y1:'v',y2:'w'}],['ruleY',{y:'t',x1:'v',x2:'w'}],['tickX',{x:'t',y:'category'}],['tickY',{y:'t',x:'category'}]
];
for(const[name,options]of cases)test(`${name} preserves its ordinary Mark dispatch and actual SVG geometry`,async()=>{
 const plot=new Plot();vg[name](data,options)(plot);await plot.render();
 const mark=plot.marks[0];assert.ok(mark instanceof Mark);assert.equal(mark.type,name);assert.equal(mark.data.numRows,2);
 const svg=plot.element.querySelector('svg');assert.ok(svg);assert.doesNotMatch(svg.outerHTML,/NaN|Infinity/);
 const groups=[...svg.querySelectorAll('g[aria-label]')].filter(group=>!/(axis|grid|frame)/.test(group.getAttribute('aria-label')));
 assert.equal(groups.length,1);assert.equal(groups[0].children.length,2);assert.ok(groups[0].querySelector('rect,circle,path,line'));
});

for(const name of['circle','hexagon'])test(`${name} retains its forced geometry despite admitted symbol options`,async()=>{
 async function geometry(symbol){const plot=new Plot();vg[name](data,{x:'t',y:'v',symbol})(plot);await plot.render();const group=[...plot.element.querySelectorAll('g[aria-label]')].find(g=>!/(axis|grid|frame)/.test(g.getAttribute('aria-label')));return [...group.children].map(node=>node.outerHTML);}
 assert.deepEqual(await geometry('square'),await geometry('diamond'));
});
test.after(()=>dom.window.close());
