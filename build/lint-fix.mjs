import { ESLint } from 'eslint';
import config from '../eslint.config.js';

if (!process.env.BUILD_WORKSPACE_DIRECTORY) throw new Error('Use bazelisk run //:lint_fix');
const eslint = new ESLint({
  cwd: process.env.BUILD_WORKSPACE_DIRECTORY,
  overrideConfigFile: true,
  overrideConfig: config,
  fix: true,
});
const results = await eslint.lintFiles(process.argv.slice(2));
await ESLint.outputFixes(results);
console.log(await (await eslint.loadFormatter()).format(results));
process.exitCode = results.some(result => result.errorCount) ? 1 : 0;
