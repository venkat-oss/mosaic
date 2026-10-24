import { writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { installPackages } from './npm-install.mjs';

const name = process.argv[2];
const runfile = path => resolve(process.env.TEST_SRCDIR, path);
const workspaceFile = path => resolve(process.env.TEST_SRCDIR, process.env.TEST_WORKSPACE, path);
const packages = Object.fromEntries(Object.entries(JSON.parse(process.env.MOSAIC_PACKAGES)).map(([key, path]) => [key, runfile(path)]));
const links = Object.fromEntries(Object.entries(JSON.parse(process.env.MOSAIC_LINKS)).map(([key, path]) => [key, workspaceFile(path)]));
const { directory, run } = installPackages(runfile(process.env.PNPM_BIN), packages, links);
const jsdom = pathToFileURL(workspaceFile('node_modules/jsdom/lib/api.js')).href;
const setup = `
import assert from 'node:assert/strict';
import { JSDOM } from ${JSON.stringify(jsdom)};
const dom = new JSDOM('<!doctype html><body></body>', { pretendToBeVisual: true });
for (const key of ['window', 'document', 'HTMLElement', 'Element', 'SVGElement', 'CustomEvent', 'Event']) globalThis[key] = dom.window[key];
globalThis.requestAnimationFrame = dom.window.requestAnimationFrame.bind(dom.window);
globalThis.cancelAnimationFrame = dom.window.cancelAnimationFrame.bind(dom.window);
const api = await import(${JSON.stringify(name)});
`;
const consumers = {
  '@uwdata/mosaic-inputs': `
const { Param } = await import('@uwdata/mosaic-core');
const param = Param.value('alpha');
const element = new api.Menu({ options: ['alpha', 'beta'], as: param }).element;
const select = element.querySelector('select');
select.value = 'beta';
select.dispatchEvent(new Event('input', { bubbles: true }));
assert.equal(param.value, 'beta');
`,
  '@uwdata/mosaic-plot': `
const plot = new api.Plot();
plot.addMark(new api.Mark('dot', [{ x: 1, y: 2 }], { x: 'x', y: 'y' }));
await plot.render();
assert.equal(plot.element.querySelectorAll('g[aria-label="dot"] circle').length, 1);
`,
  '@uwdata/vgplot': `
const element = api.plot(api.dot([{ x: 1, y: 2 }], { x: 'x', y: 'y' }));
await element.value.render();
assert.equal(element.querySelectorAll('g[aria-label="dot"] circle').length, 1);
`,
  '@uwdata/mosaic-spec': `
const spec = { plot: [{ mark: 'dot', data: { from: 'points' }, x: 'x', y: 'y' }] };
const ast = api.parseSpec(spec);
assert.deepEqual(ast.toJSON(), spec);
assert.match(api.astToESM(ast), /vg\\.dot/);
assert.match(api.astToPython(ast), /vg\\.dot/);
const { readFileSync } = await import('node:fs');
const schema = JSON.parse(readFileSync(new URL('../mosaic-schema.json', import.meta.resolve('@uwdata/mosaic-spec')), 'utf8'));
assert.ok(schema.$schema);
`
};
run(process.execPath, ['--input-type=module', '-e', setup + consumers[name] + '\ndom.window.close();']);
const expressions = {
  '@uwdata/mosaic-inputs': 'api.menu({ options: [1, 2] })',
  '@uwdata/mosaic-plot': 'new api.Plot().element',
  '@uwdata/vgplot': 'api.plot(api.dot([{ x: 1 }], { x: "x" }))',
  '@uwdata/mosaic-spec': 'api.parseSpec({ plot: [] }).toJSON()'
};
writeFileSync(join(directory, 'consumer.ts'), `import * as api from '${name}';\nconst output: object = ${expressions[name]};\nvoid output;\n`);
writeFileSync(join(directory, 'tsconfig.json'), JSON.stringify({
  compilerOptions: { strict: true, noEmit: true, module: 'Node16', target: 'ES2022', skipLibCheck: true, types: [] },
  files: ['consumer.ts']
}));
run(runfile(process.env.TSC_BIN), ['--project', join(directory, 'tsconfig.json')]);
