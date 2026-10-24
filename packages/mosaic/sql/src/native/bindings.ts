import { ast, native } from './runtime.js';
import { mapTree, walk, type CloneMemo } from './tree.js';
import type { ParamLike, ParamReader, SqlExpression, SqlRoot } from './types.js';

const PREFIX = '__mosaic_binding_';
const metadata = new WeakMap<SqlExpression, SqlBinding>();

export interface SqlBinding {
  readonly kind: 'scalar' | 'identifier' | 'deferred';
  readonly parameters: readonly ParamLike[];
  readonly resolve: (read: ParamReader) => SqlRoot;
  readonly field?: (read: ParamReader) => { column: string; table?: string };
}

export function rootExpression(value: SqlRoot): SqlExpression {
  if (ast.isExpressionValue(value)) return value;
  const expression = value?.expression;
  if (ast.isExpressionValue(expression)) return expression;
  throw new TypeError('Expected a native SQL expression or query handle.');
}

export function bindingOf(node: SqlExpression): SqlBinding | undefined {
  return metadata.get(node);
}

function bindingName(node: SqlExpression): string | undefined {
  if ('parameter' in node && node.parameter.name?.startsWith(PREFIX)) {
    return node.parameter.name;
  }
}

function copyBinding(source: SqlExpression, target: SqlExpression) {
  const binding = metadata.get(source);
  if (binding) metadata.set(target, binding);
}

export function cloneExpression(input: SqlRoot, memo: CloneMemo = new Map()): SqlExpression {
  return mapTree(rootExpression(input), () => undefined, memo, true, copyBinding);
}

export class BindingScope {
  private readonly namespace = Array.from(
    globalThis.crypto.getRandomValues(new Uint32Array(4)), value => value.toString(36)
  ).join('_');
  private sequence = 0;
  private ids = new Map<string, SqlBinding>();
  private adoptedSlots = new WeakMap<SqlExpression, SqlExpression>();

  bind(binding: SqlBinding): SqlExpression {
    const expression = native.parameter(this.nextName());
    metadata.set(expression, binding);
    this.ids.set(expression.parameter.name!, binding);
    return expression;
  }

  private nextName(): string {
    let name: string;
    do name = PREFIX + this.namespace + '_' + this.sequence++;
    while (this.ids.has(name));
    return name;
  }

  adopt(input: SqlRoot): SqlExpression {
    return mapTree(rootExpression(input), node => {
      const name = bindingName(node);
      if (!name) return;
      const binding = metadata.get(node);
      if (!binding) throw new Error(`Unresolved native SQL binding: ${name}`);
      const adopted = this.adoptedSlots.get(node);
      if (adopted) return adopted;
      const previous = this.ids.get(name);
      if (!previous || previous === binding) {
        this.ids.set(name, binding);
        this.adoptedSlots.set(node, node);
        return node;
      }
      const replacement = native.parameter(this.nextName());
      metadata.set(replacement, binding);
      this.ids.set(replacement.parameter.name!, binding);
      this.adoptedSlots.set(node, replacement);
      return replacement;
    }, new Map(), false, copyBinding);
  }

  snapshot(input: SqlRoot): SqlExpression {
    return this.snapshotAll([input])[0];
  }

  snapshotAll(inputs: readonly SqlRoot[]): SqlExpression[] {
    const reads = new Map<ParamLike, unknown>();
    const memo: CloneMemo = new Map();
    const resolved = new Map<SqlBinding, SqlExpression>();
    const active = new Set<SqlBinding>();
    const read: ParamReader = param => {
      if (!reads.has(param)) reads.set(param, param.value);
      return reads.get(param);
    };
    const resolve = (expression: SqlExpression): SqlExpression => mapTree(expression, node => {
      const name = bindingName(node);
      if (!name) return;
      const binding = metadata.get(node);
      if (!binding) throw new Error(`Unresolved native SQL binding: ${name}`);
      if (resolved.has(binding)) return resolved.get(binding)!;
      if (active.has(binding)) throw new Error('Cyclic native SQL binding.');
      active.add(binding);
      const value = resolve(rootExpression(binding.resolve(read)));
      active.delete(binding);
      resolved.set(binding, value);
      return value;
    }, memo, true);
    return inputs.map(input => resolve(this.adopt(input)));
  }

  reset(): void {
    this.ids.clear();
    this.adoptedSlots = new WeakMap();
  }
}

export function bind(binding: SqlBinding): SqlExpression {
  return new BindingScope().bind(binding);
}

export function snapshot(input: SqlRoot): SqlExpression {
  return new BindingScope().snapshot(input);
}

export function snapshotAll(inputs: readonly SqlRoot[]): SqlExpression[] {
  return new BindingScope().snapshotAll(inputs);
}

export function params(input: SqlRoot): ParamLike[] {
  const parameters = new Set<ParamLike>();
  for (const node of walk(rootExpression(input))) {
    for (const param of metadata.get(node)?.parameters ?? []) parameters.add(param);
  }
  return [...parameters];
}

export interface SqlField {
  readonly node: SqlExpression;
  readonly column: string;
  readonly table?: string;
}

export function fields(input: SqlRoot): SqlField[] {
  const result: SqlField[] = [];
  const reads = new Map<ParamLike, unknown>();
  const read: ParamReader = param => {
    if (!reads.has(param)) reads.set(param, param.value);
    return reads.get(param);
  };
  for (const node of walk(rootExpression(input))) {
    const binding = metadata.get(node);
    if (binding?.field) {
      result.push({ node, ...binding.field(read) });
    } else if ('column' in node) {
      result.push({ node, column: node.column.name.name, table: node.column.table?.name });
    } else if (binding?.kind === 'deferred') {
      result.push(...fields(snapshot(node)));
    }
  }
  return result;
}
