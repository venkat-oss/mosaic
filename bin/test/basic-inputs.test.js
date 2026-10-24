import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { cpSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { after, test } from 'node:test';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const cue = process.env.CUE_BIN;
const workspaces = [];
function workspace(copy = false) {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-basic-inputs-'));
  workspaces.push(root);
  if (copy) for (const path of ['cue.mod','api']) cpSync(resolve(ROOT,path),resolve(root,path),{recursive: true, dereference: true, filter: () => true});
  return root;
}
after(() => workspaces.forEach(root=>rmSync(root,{recursive:true,force:true})));

for (const [name,accepted,rejected] of [
  ['Menu',[{input:'menu'},{input:'menu',options:[null,{label:3},[]]},{input:'menu',listMatch:'any',as:'ordinary-reference'}],[{}, {input:'menu',options:{}},{input:'menu',listMatch:'none'},{input:'menu',format:'callback'}]],
  ['Search',[{input:'search'},{input:'search',type:'regexp',from:'rows',filterBy:'$filter'}],[{}, {input:'search',type:'exact'},{input:'search',value:'initial'}]],
  ['Slider',[{input:'slider'},{input:'slider',select:'interval',min:0,max:4,step:1,value:2}],[{}, {input:'slider',select:'list'},{input:'slider',min:'0'}]]
]) {
  test(`native #${name} preserves input discriminator and target boundaries without adding defaults`,()=>{
    const root=workspace();
    const candidate=resolve(root,'candidate.json');
    const native=resolve(ROOT,'packages/vgplot/spec/src/generated/basic-inputs.cue');
    for(const [value,expected] of [...accepted.map(value=>[value,0]),...rejected.map(value=>[value,1])]) {
      writeFileSync(candidate,JSON.stringify(value));
      const result=spawnSync(cue,['vet','-c',native,candidate,'-d',`#${name}`],{cwd:ROOT,encoding:'utf8'});
      assert.equal(result.error,undefined);
      assert.equal(result.status,expected,`${name}: ${JSON.stringify(value)}\n${result.stderr}`);
      if(expected===0) {
        const exported=spawnSync(cue,['export',native,candidate,'-d',`#${name}`,'--out','json'],{cwd:ROOT,encoding:'utf8'});
        assert.equal(exported.status,0,exported.stderr);
        assert.deepEqual(JSON.parse(exported.stdout),value);
      }
    }
  });
}

for(const [name,metadata] of [
  ['raw Python type text','invalid: #PythonParameter & {name:"label",annotation:"eval(unsafe)",kind:"positional-or-keyword",default:"required"}'],
]) {
  test(`owning basic input admission rejects ${name}`,()=>{
    const root=workspace(true);
    writeFileSync(resolve(root,'api/inputs/basic/invalid.cue'),`package basicinputs\n${metadata}\n`);

    assert.throws(()=>execFileSync(cue,['vet','-c','./api/inputs/basic'],{cwd:root,stdio:'pipe'}),/annotation|wire|applicability|conflicting values|empty disjunction/);

  });
}

for(const [name,parameters] of [
  ['duplicate parameters',[{name:'label',annotation:'Any',kind:'positional-or-keyword',default:'required'},{name:'label',annotation:'Any',kind:'positional-or-keyword',default:'required'}]],
  ['required after default',[{name:'label',annotation:'Any',kind:'positional-or-keyword',default:'none'},{name:'bind',annotation:'Any',kind:'positional-or-keyword',default:'required'}]],
  ['variadic before positional',[{name:'opts',annotation:'Any',kind:'keyword-variadic',default:'required'},{name:'label',annotation:'Any',kind:'positional-or-keyword',default:'required'}]]
]) {
  test(`Python input contracts reject ${name}`,()=>{
    const root=workspace(true);
    writeFileSync(resolve(root,'api/inputs/basic/invalid.cue'),`package basicinputs\ninvalid: #PythonFactory & ${JSON.stringify({name:'menu',contract:'Menu',applicability:'shared',description:'Invalid independent contract',parameters})}\n`);

    assert.throws(()=>execFileSync(cue,['vet','-c','./api/inputs/basic'],{cwd:root,stdio:'pipe'}),/parameter|conflicting values|invalid value|false/);

  });
}
