import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdtempSync,writeFileSync,rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {resolve} from 'node:path';
import test from 'node:test';
import ts from 'typescript';
const root=resolve(import.meta.dirname,'../..');const fixtures=mkdtempSync(resolve(tmpdir(),'mosaic-guide-ir-'));
const property=(name,type='number',required=false,description='A number.')=>({name,type,required,description});
const contract=(name,properties=[],parents=[])=>({name,description:name+' contract.',wire:true,kind:'interface',extends:parents,properties});
const expressions={number:{kind:'primitive',type:'number'},string:{kind:'primitive',type:'string'}};
function fixture(id,input,expected){const file=resolve(fixtures,id+'.cue');writeFileSync(file,'package guidetest\nimport "idl.uw.edu/mosaic/api/render"\nprojection:render.#ShapeProjection & '+JSON.stringify(input)+'\n');try{const r=spawnSync(process.env.CUE_BIN,['export',file,'-e','{checks:projection.checks,contracts:projection.contractProjections}'],{cwd:root,encoding:'utf8'});assert.equal(r.status,expected,r.stderr);return expected===0?JSON.parse(r.stdout):r.stderr;}finally{rmSync(file);}}
function compiler(id,source,expected){const file=resolve(fixtures,id+'.ts');writeFileSync(file,source);try{const program=ts.createProgram([file],{noEmit:true,strict:true,skipLibCheck:true,types:[],target:ts.ScriptTarget.ESNext});const errors=ts.getPreEmitDiagnostics(program);assert.equal(errors.length>0,expected,ts.formatDiagnosticsWithColorAndContext(errors,{getCurrentDirectory:()=>root,getCanonicalFileName:f=>f,getNewLine:()=> '\n'}));}finally{rmSync(file);}}
test('Pick alias inheritance retains alias spelling and selected schema fields',()=>{
 const value=fixture('pick-alias',{expressions:{...expressions,pick:{kind:'interface-selection',contract:'Base',operator:'pick',keys:['value']}},contracts:[contract('Base',[property('value'),property('label','string')]),{name:'Selected',description:'Only value.',kind:'alias',wire:false,expression:'pick'},contract('Child',[],['Selected'])]},0);
 assert.match(value.contracts.Selected.declaration,/type Selected = Pick<Base, 'value'>;/);assert.match(value.contracts.Child.declaration,/interface Child extends Selected/);assert.deepEqual(Object.keys(value.contracts.Child.schema.properties),['value']);assert.equal(value.contracts.Child.schema.properties.value.type,'number');
 compiler('pick-alias','interface Base{value?:number;label?:string};type Selected=Pick<Base,"value">;interface Child extends Selected{};const value:Child={value:2};',false);
});
test('Omit may name absent keys while Pick must name existing keys',()=>{
 for(const operator of['omit','pick'])fixture(operator+'-absent',{expressions,contracts:[contract('Base',[property('value')]),contract('Child',[],[{name:'Base',operator,keys:['missing']}])]},operator==='omit'?0:1);
 compiler('omit-absent','interface Base{value?:number};interface Child extends Omit<Base,"missing">{};',false);
 compiler('pick-absent','interface Base{value?:number};type Child=Pick<Base,"missing">;',true);
});
test('selected Omit aliases permit absent keys and retain actual canonical bases',()=>{
 const value=fixture('omit-alias-absent',{expressions:{...expressions,omit:{kind:'interface-selection',contract:'Base',operator:'omit',keys:['missing']}},contracts:[contract('Base',[property('value')]),{name:'Selected',description:'Only actual base properties.',kind:'alias',wire:false,expression:'omit'},contract('Child',[],['Selected'])]},0);
 assert.match(value.contracts.Selected.declaration,/type Selected = Omit<Base, 'missing'>;/);
 assert.match(value.contracts.Child.declaration,/interface Child extends Selected/);
 assert.deepEqual(Object.keys(value.contracts.Child.schema.properties),['value']);
 compiler('omit-alias-absent','interface Base{value?:number};type Selected=Omit<Base,"missing">;interface Child extends Selected{};const value:Child={value:2};',false);
});
test('unused selected-interface metadata rejects empty or duplicated keys',()=>{
 for(const keys of[[],['value','value']]){const file=resolve(fixtures,'unused.cue');writeFileSync(file,'package guidetest\nimport "idl.uw.edu/mosaic/api/model"\nunused:model.#ShapeExpression & '+JSON.stringify({kind:'interface-selection',contract:'Base',operator:'pick',keys}));try{const r=spawnSync(process.env.CUE_BIN,['vet','-c',file],{cwd:root,encoding:'utf8'});assert.equal(r.status,1,r.stderr);}finally{rmSync(file);}}
});
test('selected-interface source keys remain checked',()=>{
 for(const change of[{keys:['missing']}])fixture('bad-selection',{expressions:{...expressions,pick:{kind:'interface-selection',contract:'Base',operator:'pick',keys:['value'],...change}},contracts:[contract('Base',[property('value')]),{name:'Selected',description:'Only value.',kind:'alias',wire:false,expression:'pick'}]},1);
});
test('indexed property annotations do not change inherited type compatibility',()=>{
 const out=fixture('indexed-compatible',{expressions:{...expressions,indexed:{kind:'indexed-property',contract:'Base',property:'value',expression:'number'}},contracts:[contract('Base',[property('value','number',false,'Original field prose.')]),contract('Other',[property('value','indexed',false,'Different field prose.')]),contract('Child',[],['Base','Other'])]},0);
 assert.equal(out.contracts.Child.schema.properties.value.description,'Original field prose.');
 compiler('compatible','interface Base{value?:number};interface Other{value?:Base["value"]};interface Child extends Base,Other{};',false);
});
for(const [name,type,required] of[['type','string',false],['requiredness','number',true]])test('incompatible inherited '+name+' still rejects',()=>{
 fixture('incompatible-'+name,{expressions,contracts:[contract('Base',[property('value')]),contract('Other',[property('value',type,required)]),contract('Child',[],['Base','Other'])]},1);
 compiler('incompatible-'+name,'interface Base{value?:number};interface Other{value'+(required?'': '?')+':'+type+'};interface Child extends Base,Other{};',true);
});
test('external reference alternatives stay external with an explicit owned contract inventory',()=>{
 const file=resolve(fixtures,'external-alternatives.cue');
 writeFileSync(file,'package guidetest\nimport "idl.uw.edu/mosaic/api/render"\nout:render.#ShapeAlternatives & '+JSON.stringify({expression:'external',expressions:{external:{kind:'named',name:'External'}},contractIndex:{Base:contract('Base',[property('value')])}})+'\n');
 try{const r=spawnSync(process.env.CUE_BIN,['export',file,'-e','{terms:out.names,complete:out.resolved}'],{cwd:root,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.deepEqual(JSON.parse(r.stdout),{terms:['external'],complete:true});}finally{rmSync(file);}
 const out=fixture('external-indexed',{externalReferences:[{name:'External',owner:'spec',source:'../Root.js'}],expressions:{external:{kind:'named',name:'External'},indexed:{kind:'indexed-property',contract:'Base',property:'value',expression:'external'}},contracts:[contract('Base',[property('value','external')]),contract('Other',[property('value','indexed')]),contract('Child',[],['Base','Other'])]},0);
 assert.equal(out.contracts.Child.schema.properties.value.$ref,'#/definitions/External');
});

test.after(()=>rmSync(fixtures,{recursive:true,force:true}));
