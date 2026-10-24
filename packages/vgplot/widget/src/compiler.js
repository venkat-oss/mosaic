import { init } from '@polyglot-sql/sdk/manual';
import wasmUrl from '@polyglot-sql/sdk/polyglot_sql.wasm';

try {
  await init({ wasmUrl });
} catch (cause) {
  throw new Error('Mosaic SQL compiler initialization failed. The embedded WebAssembly asset could not be loaded.', { cause });
}
