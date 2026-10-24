import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { readFileSync, writeFileSync, rmSync } from 'node:fs';
import { resolve } from 'node:path';
import { tmpdir } from 'node:os';
import { fileURLToPath } from 'node:url';
import { mkdtempSync } from 'node:fs';
import test from 'node:test';
const workspace=fileURLToPath(new URL('../..',import.meta.url));
const original=readFileSync(resolve(import.meta.dirname,'fixtures/mark-family.cue'),'utf8').replace(/([A-Za-z]+):\s+/g,'$1:');
function replace(source,before,after){assert.ok(source.includes(before),before);return source.replace(before,after);}
let count=0;
function evaluate(source,expression){
 const directory=mkdtempSync(resolve(tmpdir(),`mosaic-mark-family-${count++}-`));const path=resolve(directory,'fixture.cue');writeFileSync(path,source);
 try{return spawnSync(process.env.CUE_BIN,expression?['export',path,'-e',expression]:['vet','-c',path],{cwd:workspace,encoding:'utf8',maxBuffer:8*1024*1024});}finally{rmSync(directory,{recursive:true,force:true});}
}
for(const[profile,options,expected]of[
 ['ordinary','',"mark('fixture', ...args)"],
 ['explicit',',runtimeClass:"ErrorBarMark",runtimeType:"ruleY"',"explicitType(ErrorBarMark, 'ruleY', ...args)"],
 ['implicit',',runtimeClass:"HeatmapMark"','implicitType(HeatmapMark, ...args)']
])test(`${profile} profile preserves constructor argument policy and public Python globals`,()=>{
 const result=evaluate(replace(original,'profile:"ordinary"',`profile:"${profile}"${options}`),'projection.sections');
 assert.equal(result.status,0,result.stderr);const sections=JSON.parse(result.stdout);assert.ok(sections.find(section=>section.id==='fixture-1').text.includes(expected));
 if(profile==='ordinary'){
  const files=evaluate(original,'{fileData:projection.files,schemaData:projection.schemaFragment}');assert.equal(files.status,0,files.stderr);const {fileData:f,schemaData:s}=JSON.parse(files.stdout);
  assert.deepEqual(s.definitions.Fixture,{type:'object',additionalProperties:false,description:'The fixture mark.',properties:{mark:{type:'string',const:'fixture',description:'A fixture mark.'}},required:['mark']});
  assert.match(f['packages/vgplot/vgplot-python/vgplot/_generated/fixture_marks.py'],/__module__ = "vgplot\._generated\.marks"/);
  assert.match(sections.find(r=>r.id==='js-Fixture').text,/A fixture mark\./);
 }
});
for(const[name,before,after]of[
 ['raw source payload','jsSection:"fixture-1"','jsSection:"fixture-1",code:"execute()"'],
 ['unknown profile','profile:"ordinary"','profile:"custom"'],
 ['unknown constructor','profile:"ordinary"','profile:"explicit",runtimeClass:"UnknownConstructor"'],
 ['wrong retained constructor policy','profile:"ordinary"','profile:"explicit",runtimeClass:"HeatmapMark"'],
 ['empty runtime type','profile:"ordinary"','profile:"ordinary",runtimeType:""'],
 ['raw runtime type','profile:"ordinary"','profile:"ordinary",runtimeType:"run()"'],
 ['ordinary constructor class','profile:"ordinary"','profile:"ordinary",runtimeClass:"Mark"'],
 ['missing supplied constructor','profile:"ordinary"','profile:"explicit"'],
 ['wrong discriminator','value:"fixture"','value:"wrong"'],
 ['unknown import','imports:[]','imports:["Unknown"]'],
 ['missing docs coverage','names:["fixture"]','names:["other"]']
])test(`complete owning helper admission rejects ${name}`,()=>{
 const result=evaluate(replace(original,before,after));assert.equal(result.status,1,result.stderr);
});

for(const[profile,runtimeClass]of[['explicit','UnknownConstructor'],['explicit','HeatmapMark'],['custom','ErrorBarMark']])test(`unused ${profile}/${runtimeClass} constructor record is rejected`,()=>{
 const result=evaluate(original+`\nunused:family.#Mark & {name:"unused",contract:"Fixture",jsSection:"unused",profile:"${profile}",runtimeClass:"${runtimeClass}"}\n`);assert.equal(result.status,1,result.stderr);
});

test('curated starters render download links once beside shared option docs',()=>{
 const source=replace(original,'referenceGroups:[','starters:[{id:"demo",mark:"fixture"}]\nstarterFiles:{for Format in ["json","yaml","js","py"] {"templates/marks/fixture/demo.\\(Format)":"sample"}}\nreferenceGroups:[');
 const result=evaluate(source,'projection.sections');assert.equal(result.status,0,result.stderr);
 const reference=JSON.parse(result.stdout).filter(r=>r.path.startsWith('docs/')).map(r=>r.text).join('\n');
 assert.match(reference,/common mark options/);assert.match(reference,/withBase\('\/templates\/marks\/fixture\/demo\.py'\)/);
 for(const format of['json','yaml','js'])assert.ok(reference.includes(`/templates/marks/fixture/demo.${format}`));
 const bad=evaluate(replace(source,'mark:"fixture"','mark:"foreign"'));assert.equal(bad.status,1,bad.stderr);
});

test('owning reference notes render from the same family contract and reject foreign marks',()=>{
 const source=replace(original,'referenceGroups:[','referenceNotes:[{marks:["fixture"],text:"**Known defect**: native behavior differs from strict admission."}]\nreferenceGroups:[');
 const result=evaluate(source,'projection.sections');assert.equal(result.status,0,result.stderr);const records=JSON.parse(result.stdout);assert.match(records.filter(r=>r.path.startsWith('docs/')).map(r=>r.text).join('\n'),/\*\*Known defect\*\*: native behavior differs/);
 const invalid=evaluate(replace(source,'marks:["fixture"]','marks:["foreign"]'));assert.equal(invalid.status,1,invalid.stderr);
});
