/** @import { SpecNode } from '../ast/SpecNode.js' */
import { DATA_EXTENSIONS } from '../generated/data.js';
import { toArray } from '../util.js';

/**
 * Construct a set of database extensions to load.
 * Automatically adds the spatial extension if a
 * dataset with format "spatial" is loaded.
 * @param {SpecNode} ast Mosaic AST root node.
 * @returns {Set<string>} A set of extension names.
 */
export function resolveExtensions(ast) {
  const spec = ast.config?.extensions;
  const exts = new Set(spec ? toArray(spec) : []);

  for (const def of Object.values(ast.data)) {
    const extension = DATA_EXTENSIONS[def.format];
    if (extension) exts.add(extension);
  }

  return exts;
}
