import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { JSDOM } from 'jsdom';

const moduleURL = path => pathToFileURL(path).href;

const input = JSON.parse(readFileSync(0, 'utf8'));
const root = input.root;
const vg = await import(moduleURL(resolve(root, 'packages/vgplot/vgplot/src/index.js')));
const { NodeConnector } = await import(moduleURL(resolve(root, 'packages/mosaic/core/dist/src/connectors/NodeConnector.js')));
const { astToDOM, parseSpec } = await import(moduleURL(resolve(root, 'packages/vgplot/spec/dist/src/index.js')));
const dom = new JSDOM('<!DOCTYPE html>', {pretendToBeVisual: true});
for (const key of ['window', 'document', 'Node', 'Element', 'HTMLElement', 'SVGElement']) globalThis[key] = dom.window[key];
globalThis.requestAnimationFrame = dom.window.requestAnimationFrame.bind(dom.window);
globalThis.cancelAnimationFrame = dom.window.cancelAnimationFrame.bind(dom.window);
const coordinator = new vg.Coordinator(await NodeConnector.make(), {logger: null});
const extensions = input.wrapperModule ? await import(moduleURL(input.wrapperModule)) : null;
const api = vg.createAPIContext({coordinator, extensions});
let element;
const timer = setTimeout(() => {
  process.stderr.write('Expected vectorX rendering failure was not observed.\n');
  process.exit(2);
}, 5000);
process.once('unhandledRejection', error => {
  if (!(error instanceof Error)) throw error;
  clearTimeout(timer);
  process.stdout.write(JSON.stringify({name: error.name, message: error.message, type: element?.value.marks[0].type}) + '\n');
  process.exit(0);
});
if (input.mode === 'ast') element = (await astToDOM(parseSpec(input.spec), {api})).element;
else {
  const body = input.code.replace(/^import .*$/gm, '').replace(/^export const /gm, 'const ').replace('export default ', 'const element = ');
  element = await new Function('vg', 'return (async () => {' + body + '\nreturn element;})();')(api);
}
