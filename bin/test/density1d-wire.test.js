import assert from 'node:assert/strict';
import { resolve } from 'node:path';
import { validateSpec } from './util/spec-admission.js';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
const schema=JSON.parse(readFileSync(resolve('packages/vgplot/spec/dist/mosaic-schema.json'),'utf8'));
const ajv=new Ajv({allowUnionTypes:true});addFormats.default(ajv);const validate=ajv.compile(schema);
const cases=[
 ['X keeps required declarative base type','densityX',{},false],
 ['Y preserves omitted areaY base type','densityY',{},true],
 ['X area orientation','densityX',{type:'areaX',y:'value'},true],
 ['Y area orientation','densityY',{type:'areaY',x:'value'},true],
 ['X omitted density endpoint','densityX',{type:'areaX',x:2},false],
 ['Y omitted density endpoint','densityY',{type:'areaY',y1:0},false],
 ['X rejects Y base type','densityX',{type:'dot'},false],
 ['Y rejects X base type','densityY',{type:'dotX'},false],
 ['line branches retain markers','densityX',{type:'lineX',markerStart:'arrow'},true],
 ['area branches omit line markers','densityX',{type:'areaX',markerStart:'arrow'},false],
 ['dot branches retain radius','densityX',{type:'dotX',r:3,symbol:'square'},true],
 ['line branches omit dot radius','densityX',{type:'lineX',r:3},false],
 ['Y circle remains in dot branch','densityY',{type:'circle',symbol:'square'},true],
 ['text branch retains font options','densityY',{type:'text',fontSize:14},true],
 ['dot branch omits text options','densityY',{type:'dot',fontSize:14},false],
 ['area stacking retained','densityY',{type:'areaY',stack:true},true],
 ['dot branch omits stack','densityY',{type:'dotY',stack:true},false],
 ['parameter bandwidth retained','densityY',{bandwidth:'$bandwidth'},true],
 ['type discriminator is not parameterized','densityY',{type:'$type'},false],
 ['bins retain unconstrained numeric schema','densityY',{bins:0},true],
 ['unknown branch options rejected','densityY',{futureOption:1},false],
 ['wire references retain arbitrary normalization strings','densityY',{normalize:'count'},true],
 ['normalization object rejected','densityY',{normalize:{}},false],
];
for(const normalize of [false,'none',true,'sum','max'])cases.push(['normalization '+normalize,'densityY',{normalize},true]);
for(const[name,mark,options,expected]of cases)test(name,()=>{
 const value={plot:[{mark,data:{from:'records'},...options}]};assert.equal(validate(value),expected,JSON.stringify(validate.errors));
});


test('density option unions agree with the closed native schema adapter', () => {
 const values=cases.map(([,mark,options])=>({plot:[{mark,data:{from:'records'},...options}]}));
 assert.deepEqual(validateSpec(values).map(result=>result.accepted),cases.map(([, , ,expected])=>expected));
});
