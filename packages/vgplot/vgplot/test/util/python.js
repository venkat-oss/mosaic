import { resolve } from 'node:path';

export const pythonExecutable = resolve(process.env.TEST_SRCDIR, process.env.MOSAIC_PYTHON);
