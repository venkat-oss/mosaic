// @vitest-environment jsdom
import { pythonExecutable } from './util/python.js';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { astToDOM, astToESM, astToPython, parseSpec } from '@uwdata/mosaic-spec';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import { parse as parseYAML } from 'yaml';
import * as vg from '../src/index.js';
import { clientsReady } from './util/clients-ready.js';

const directory = resolve(import.meta.dirname, '../../../../templates/marks/common');
const actual = resolve(import.meta.dirname, '../../../..');
const schema = JSON.parse(await readFile(actual+'/packages/vgplot/spec/dist/mosaic-schema.json','utf8'));
const ajv = new Ajv({allowUnionTypes:true,allErrors:true});
addFormats.default(ajv);
const validate = ajv.compile(schema);
const database = NodeConnector.make();
const cases = ['parameter-channel'];
describe.each(cases)('%s common mark starter', name => {
 it('admits JSON/YAML and round trips source Python and generated Python', async () => {
  const spec = JSON.parse(await readFile(resolve(directory,name+'.json'),'utf8'));
  for (const extension of ['json','yaml']) {
   const source = await readFile(resolve(directory,name+'.'+extension),'utf8');

   const value = extension === 'json' ? JSON.parse(source):parseYAML(source);
   expect(validate(value),JSON.stringify(validate.errors)).toBe(true);
   expect(parseSpec(value).toJSON()).toEqual(value);
  }
  for (const source of [await readFile(resolve(directory,name+'.py'),'utf8'),astToPython(parseSpec(spec))]) {
   const result = JSON.parse(execFileSync(pythonExecutable,['-c','import json,sys;ns={};exec(sys.stdin.read(),ns);view=ns["view"];print(json.dumps(view.to_dict(_context=ns) if hasattr(view,"_build_spec") else view.to_dict()))'],{input:source,encoding:'utf8',env:{...process.env}}));
   expect(result).toEqual(spec);
  }
 });
 it.each(['module','esm','ast'])('executes %s through DuckDB and SVG',async mode => {
  const errors=[];
  const mc=new vg.Coordinator(await database,{logger:null});
  mc.logger({...mc.logger(),error:error=>errors.push(error)});
  const api=vg.createAPIContext({coordinator:mc});
  try {
   await mc.exec('DROP TABLE IF EXISTS common_data');
   const spec=JSON.parse(await readFile(resolve(directory,name+'.json'),'utf8'));
   let element;
   if(mode==='ast') element=(await astToDOM(parseSpec(spec),{api})).element;
   else {
    const source=mode==='module'?await readFile(resolve(directory,name+'.js'),'utf8'):astToESM(parseSpec(spec),{imports:new Map()});
    const body=source.replace(/^import \* as vg from ['"]@uwdata\/vgplot['"];?$/m,'').replace('export default ','const element = ');
    element=await new Function('vg',`return (async()=>{${body}\nreturn element;})();`)(api);
   }
   expect((await clientsReady(element)).map(result=>result.status)).toEqual(['fulfilled']);
   expect(errors).toEqual([]);
   expect(element.querySelector('svg'),element.outerHTML).not.toBeNull();
   const mark=element.value.marks[0];
   expect(mark.data.numRows).toBe(6);
   expect(Array.from(mark.data.columns[mark.channelField('y').as])).toEqual([2,1,1,2,3,1]);
  } finally {mc.clear();}
 });
});
