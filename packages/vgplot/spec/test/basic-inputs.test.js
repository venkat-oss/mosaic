import { readFile } from 'node:fs/promises';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it, vi } from 'vitest';
import { astToPython, parseSpec } from '../src/index.js';
import { inputNames } from '../src/config/inputs.js';
import { inputArgName } from '../src/python-codegen.js';
import { PYTHON_KEYWORDS } from '../src/python-keywords.js';

const schema = JSON.parse(await readFile(new URL('../dist/mosaic-schema.json', import.meta.url), 'utf8'));
const validator = new Ajv({ allowUnionTypes: true });
addFormats.default(validator);
validator.addSchema(schema, 'inputs');
const inputValidators = Object.fromEntries(['Menu','Search','Slider'].map(name=>[name,validator.getSchema(`inputs#/definitions/${name}`)]));
const admitted = name => inputValidators[name];
const parseWire = value => parseSpec(/** @type {any} */ (value));

for (const [name, input] of [['Menu', 'menu'], ['Search', 'search'], ['Slider', 'slider']]) {
  describe(name, () => {
    it('requires its discriminator and rejects unknown declarative options', () => {
      const validate = admitted(name);
      expect(validate({input})).toBe(true);
      for (const value of [{}, {input:'custom'}, {input,unknown:true}, {input,as:null}, {input,from:3}]) expect(validate(value)).toBe(false);
      expect(validate({input,as:'ordinary-wire-reference'})).toBe(true);
      expect(validate({input,filterBy:'$filter'})).toBe(true);
    });

    it('retains generic parser options and context API dispatch independently of schema admission', () => {
      const value = {input,raw_option:null,field:'x'};
      const ast = parseWire(value);
      expect(ast.toJSON()).toEqual(value);
      const helper = vi.fn().mockReturnValue('element');
      expect(ast.root.instantiate({api:{[input]:helper}})).toBe('element');
      expect(helper).toHaveBeenCalledExactlyOnceWith({raw_option:null,field:'x'});
    });
  });
}

it('keeps Menu any-option admission even when the structured option branch rejects the object', () => {
  const menu = admitted('Menu');
  for (const options of [[null,1,'Alpha',false,[]], [{label:3}], [{unknown:true}], [{value:null,label:'Unset'}]]) expect(menu({input:'menu',options})).toBe(true);
  expect(menu({input:'menu',options:{value:1}})).toBe(false);
  for (const listMatch of ['any','all']) expect(menu({input:'menu',listMatch})).toBe(true);
  expect(menu({input:'menu',listMatch:'none'})).toBe(false);
});

it('retains exact search mode and slider selection choices', () => {
  for (const type of ['contains','prefix','suffix','regexp']) expect(admitted('Search')({input:'search',type})).toBe(true);
  expect(admitted('Search')({input:'search',type:'exact'})).toBe(false);
  for (const select of ['point','interval']) expect(admitted('Slider')({input:'slider',select,min:0,max:4,step:1,width:100,value:2})).toBe(true);
  expect(admitted('Slider')({input:'slider',select:'list'})).toBe(false);
  expect(admitted('Slider')({input:'slider',min:'0'})).toBe(false);
});

it('keeps parser extension names separate from Python named authoring helpers', () => {
  expect([...inputNames()]).toEqual(['menu','search','slider','table']);
  expect([...inputNames(['custom','menu'])]).toEqual(['menu','search','slider','table','custom']);
  for (const input of ['select','checkbox','custom']) {
    const value = /** @type {any} */ ({input,label:'Choose',as:'$choice'});
    expect(() => parseSpec(value)).toThrow(`Unrecognized input type: ${input}`);
    const ast = parseSpec(value,{inputs:inputNames([input])});
    const source = astToPython(ast);
    expect(source).toContain(input === 'custom' ? 'vg.input("custom", ' : `vg.${input}(`);
    expect(source).toContain('bind=choice');
  }
});

it('emits the existing alias and option conventions without adding missing Python required arguments', () => {
  expect(inputArgName('as')).toBe('bind');
  expect(inputArgName('from')).toBe('source');
  expect(inputArgName('listMatch')).toBe('list_match');
  expect(astToPython(parseWire({input:'slider'}))).toContain('vg.slider()');
  const source = astToPython(parseWire({input:'menu',as:'$choice',from:'rows',listMatch:'any',options:[{label:'Alpha',value:'Alpha'},{label:'Unset',value:null}]}));
  expect(source).toContain('bind=choice');
  expect(source).toContain('source="rows"');
  expect(source).toContain('list_match="any"');
  expect(source).toContain('["Alpha", vg.option("Unset", value=None)]');
});

it('keeps Python keywords distinct from valid keyword argument names',()=>{
  expect(PYTHON_KEYWORDS.has('class')).toBe(true);
  expect(inputArgName('type')).toBe('type');
});
