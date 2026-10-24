import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import test from 'node:test';
import ts from 'typescript';

const methods = JSON.parse(execFileSync(process.env.CUE_BIN, ['export', './api/spec/model', '-e', 'parserAPIs'], {encoding: 'utf8'}));
const contexts = {parseSpec: 'ParseContext', astToDOM: 'InstantiateContext', astToESM: 'CodegenContext'};
const filenames = {parseSpec: 'parse-spec.js', astToDOM: 'ast-to-dom.js', astToESM: 'ast-to-esm.js', astToPython: 'ast-to-python.js'};
const normalize = value => value.replace(/\s/g, '').replace(/"/g, "'").replace(/newMap(?!\()/g, 'newMap()');

for (const method of methods) test(method.name + ' reference matches the retained runtime signature and options', () => {
  const path = resolve('packages/vgplot/spec/src', filenames[method.name]);
  const source = ts.createSourceFile(path, readFileSync(path, 'utf8'), ts.ScriptTarget.Latest, true, ts.ScriptKind.JS);
  const declaration = source.statements.find(node => ts.isFunctionDeclaration(node) && node.name?.text === method.name);
  assert.ok(declaration);
  assert.deepEqual(declaration.parameters.map(parameter => ({name: parameter.name.getText(source), default: parameter.initializer?.getText(source) || ''})), method.parameters.map(parameter => ({name: parameter.name, default: parameter.default})));
  assert.equal(declaration.modifiers?.some(modifier => modifier.kind === ts.SyntaxKind.AsyncKeyword) || false, method.asynchronous);
  if (method.name === 'astToPython') {
    assert.deepEqual(method.options, []);
    return;
  }
  const context = source.statements.find(node => ts.isClassDeclaration(node) && node.name?.text === contexts[method.name]);
  const constructor = context.members.find(ts.isConstructorDeclaration);
  const options = constructor.parameters[0].name.elements.filter(element => element.name.text !== 'plotDefaults');
  const actual = new Map(options.map(element => [element.name.text, normalize(element.initializer.getText(source))]));
  if (method.name === 'astToESM') {
    const binding = declaration.body.statements.find(node => ts.isVariableStatement(node) && node.declarationList.declarations.some(declaration => ts.isObjectBindingPattern(declaration.name) && declaration.name.elements.some(element => element.name.text === 'preamble')));
    const {name} = binding.declarationList.declarations[0];
    assert.ok(name.elements.some(element => element.name.text === 'preamble'));
    actual.set('preamble', 'undefined');
  }
  assert.deepEqual([...actual].sort(), method.options.map(option => [option.name, normalize(option.default)]).sort());
});
