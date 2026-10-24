import { mkdirSync } from 'node:fs';
import { isAbsolute, join } from 'node:path';

if (process.env.TEST_TMPDIR) {
  const home = join(process.env.TEST_TMPDIR, 'home');
  mkdirSync(home, { recursive: true });
  process.env.HOME = home;
  process.env.XDG_CONFIG_HOME = join(home, '.config');
  process.env.XDG_CACHE_HOME = join(home, '.cache');
  for (const tool of ['MOSAIC_PYTHON', 'CUE_BIN', 'TSC_BIN']) {
    if (process.env[tool] && !isAbsolute(process.env[tool])) {
      process.env[tool] = join(process.env.TEST_SRCDIR, process.env[tool]);
    }
  }
}
