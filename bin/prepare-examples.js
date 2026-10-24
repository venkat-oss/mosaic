import { execFileSync } from 'node:child_process';
import { mkdir, readdir, readFile, writeFile } from 'node:fs/promises';
import { basename, dirname, extname, join, resolve } from 'node:path';
import { parseSpec } from '../packages/vgplot/spec/src/parse-spec.js';
import { astToESM } from '../packages/vgplot/spec/src/ast-to-esm.js';
import { astToPython } from '../packages/vgplot/spec/src/ast-to-python.js';
import { parse } from 'yaml';
import { exampleDirectories } from './gallery-paths.mjs';

if (process.argv.length !== 6) throw new Error('Usage: prepare-examples source output ruff config');
const [source, output, ruff, config] = process.argv.slice(2).map(path => resolve(process.env.JS_BINARY__EXECROOT || process.cwd(), path));
const pythonFiles = [];
await Promise.all((await readdir(source)).filter(name => extname(name) === '.yaml').sort().map(async name => {
  const base = basename(name, '.yaml');
  const text = await readFile(join(source, name), 'utf8');
  const spec = parse(text);
  const ast = parseSpec(spec);
  const code = astToESM(ast);
  const python = astToPython(ast);
  const files = {
    [`${exampleDirectories.esm}/${base}.js`]: code,
    [`${exampleDirectories.json}/${base}.json`]: JSON.stringify(ast.toJSON(), null, 2),
    [`${exampleDirectories.ts}/${base}.ts`]: `import { Spec } from '@uwdata/mosaic-spec';

export const spec : Spec = ${JSON.stringify(spec, null, 2)};
`,
    [`${exampleDirectories.python}/${base}.py`]: python,
    [`${exampleDirectories.yamlDownload}/${base}.yaml`]: text,
    [`${exampleDirectories.jsonDownload}/${base}.json`]: JSON.stringify(spec, null, 2),
    [`${exampleDirectories.esmDownload}/${base}.js`]: code,
    [`${exampleDirectories.pythonDownload}/${base}.py`]: python,
    [`${exampleDirectories.pages}/${base}.md`]: examplePage(base, spec.meta),
  };
  await Promise.all(Object.entries(files).map(async ([name, content]) => {
    const path = join(output, name);
    await mkdir(dirname(path), { recursive: true });
    await writeFile(path, content);
    if (name.endsWith('.py')) pythonFiles.push(path);
  }));
}));
execFileSync(ruff, ['format', '--no-cache', '--config', config, ...pythonFiles.sort()], { stdio: 'inherit' });

function examplePage(spec, { title = spec, description, credit } = {}) {
  return `<script setup>
  import { coordinator } from '@uwdata/vgplot';
  coordinator().clear();
</script>

# ${title}
${description ? `\n${description.trim()}\n` : ''}
<Example spec="/specs/yaml/${spec}.yaml" />
${credit ? `\n**Credit**: ${credit}\n` : ''}
## Specification

::: code-group
<<< @/public/specs/esm/${spec}.js [JavaScript]
<<< @/public/specs/yaml/${spec}.yaml [YAML]
<<< @/public/specs/json/${spec}.json [JSON]
<<< @/public/specs/python/${spec}.py [Python]
:::
`;
}
