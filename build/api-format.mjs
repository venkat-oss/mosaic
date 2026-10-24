import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, realpathSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { artifactPath } from './api-sync.mjs';

export function formatAPI({ projection, output, cue, ruff, config }) {
  const { artifacts, inventory, nativeInputs } = JSON.parse(readFileSync(projection, 'utf8'));
  const temporary = mkdtempSync(join(tmpdir(), 'mosaic-api-format-'));
  const options = { encoding: 'utf8', stdio: 'pipe', maxBuffer: 128 * 1024 * 1024, env: { ...process.env, CUE_CACHE_DIR: join(temporary, 'cue-cache'), CUE_REGISTRY: 'none', RUFF_CACHE_DIR: join(temporary, 'ruff-cache') } };
  try {
    for (const [index, check] of nativeInputs.entries()) {
      const staged = join(temporary, 'native-checks', String(index));
      const paths = Object.entries(check.files).map(([name, content]) => {
        const path = artifactPath(staged, name);
        mkdirSync(dirname(path), { recursive: true });
        writeFileSync(path, content);
        return path;
      });
      execFileSync(cue, ['vet', '-c', ...paths], options);
    }
    for (const [name, content] of Object.entries(artifacts)) {
      const path = artifactPath(output, name);
      mkdirSync(dirname(path), { recursive: true });
      writeFileSync(path, content);
    }
    const cueFiles = Object.keys(artifacts).filter(name => name.endsWith('.cue')).map(name => artifactPath(output, name));
    if (cueFiles.length) execFileSync(cue, ['fmt', ...cueFiles], options);
    const pythonFiles = Object.keys(artifacts).filter(name => name.endsWith('.py')).map(name => artifactPath(output, name));
    if (pythonFiles.length) {
      execFileSync(ruff, ['check', '--config', config, '--fix', ...pythonFiles], options);
      execFileSync(ruff, ['format', '--config', config, ...pythonFiles], options);
    }
    const path = artifactPath(output, 'api/generated.json');
    mkdirSync(dirname(path), { recursive: true });
    writeFileSync(path, JSON.stringify(inventory.sort(), null, 2) + '\n');
  } finally {
    rmSync(temporary, { recursive: true, force: true });
  }
}

if (process.argv[1] && existsSync(process.argv[1]) && realpathSync(process.argv[1]) === realpathSync(fileURLToPath(import.meta.url))) {
  if (process.argv.length !== 7) throw new Error('Usage: api-format projection output cue ruff config');
  const [projection, output, cue, ruff, config] = process.argv.slice(2).map(path => resolve(process.env.JS_BINARY__EXECROOT || process.cwd(), path));
  formatAPI({ projection, output, cue, ruff, config });
}
