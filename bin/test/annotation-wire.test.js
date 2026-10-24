import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { validateSpec } from './util/spec-admission.js';

const schema=JSON.parse(readFileSync('packages/vgplot/spec/dist/mosaic-schema.json','utf8'));
const ajv=new Ajv({allowUnionTypes:true});addFormats.default(ajv);const validate=ajv.compile(schema);
const variants=['text','textX','textY','image','vector','vectorX','vectorY','spike','waffleX','waffleY'];
const cases=[];
for(const mark of variants){
 cases.push([mark+' absent wire data',{plot:[{mark}]},mark.startsWith('text')]);
 cases.push([mark+' inline data',{plot:[{mark,data:[]}]},true]);
 cases.push([mark+' malformed data',{plot:[{mark,data:42}]},false]);
 cases.push([mark+' unknown options',{plot:[{mark,data:[],futureStyle:7}]},false]);
}
for(const [name,mark,options,accepted]of[
 ['text formatting anchors','text',{text:'label',fontSize:14,textAnchor:'start',lineAnchor:'top'},true],
 ['text anchor rejects object','text',{lineAnchor:{}},false],
 ['textX referenced interval','textX',{interval:'$step'},true],
 ['textY wire retains broad string intervals','textY',{interval:'$step'},true],
 ['textY named interval','textY',{interval:'day'},true],
 ['textY numeric wire interval rejected','textY',{interval:1},false],
 ['image sizing and URL','image',{src:'https://example.com/image.png',width:20,height:10,preserveAspectRatio:'xMidYMid slice'},true],
 ['image malformed channel','image',{src:{arbitrary:true}},false],
 ['image explicit null','image',{src:null,r:null},true],
 ['vector orientation','vector',{length:'value',rotate:'angle',shape:'spike',anchor:'start',r:4},true],
 ['vector broad wire reference','vector',{shape:'future-shape',anchor:'future-anchor'},true],
 ['vector constant radius type','vector',{r:true},false],
 ['vector malformed rotation','vectorY',{rotate:{}},false],
 ['waffle inherits orientation fields','waffleX',{x1:0,x2:'value',y:'label',insetLeft:2,multiple:4,unit:1,gap:1,round:true},true],
 ['waffle fractional cells','waffleY',{y:'value',x:'label',round:false,unit:0.5},true],
 ['waffle malformed layout','waffleY',{multiple:{}},false]
])cases.push([name,{plot:[{mark,data:[],...options}]},accepted]);

test('annotation independent wire cases agree with AJV and native root',()=>{
 for(const[name,value,expected]of cases)assert.equal(validate(value),expected,name+': '+JSON.stringify(validate.errors));
 const native=validateSpec(cases.map(([,value])=>value));
 for(const[i,[name,,expected]]of cases.entries())assert.equal(native[i].accepted,expected,name+': '+native[i].diagnostics);
});
