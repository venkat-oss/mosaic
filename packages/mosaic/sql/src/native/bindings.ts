import { ast, native } from './runtime.js';
import { columnParts, mapTree, walk, type CloneMemo } from './tree.js';
import type { ParamLike, ParamReader, SqlExpression, SqlRoot } from './types.js';

const PREFIX = '__mosaic_binding_';
const metadata = new WeakMap<SqlExpression, SqlBinding>();

export interface SqlBinding {
  readonly kind: 'scalar' | 'identifier' | 'deferred';
  readonly parameters: readonly ParamLike[];
  readonly qualifier?: readonly string[];
  readonly frame?: boolean;
  readonly resolve: (read: ParamReader, template?: SqlExpression) => SqlRoot;
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

export function bindTemplate(node: SqlExpression, binding: SqlBinding): void {
  if ('parameter' in node || binding.kind !== 'deferred') throw new TypeError('Native templates require a structured expression and deferred binding.');
  metadata.set(node, binding);
}

export function unbindTemplate(node: SqlExpression): void {
  if (!('parameter' in node)) metadata.delete(node);
}

function bindingName(node: SqlExpression): string | undefined {
  if ('parameter' in node && node.parameter.name?.startsWith(PREFIX)) {
    return node.parameter.name;
  }
}

export function copyBinding(source: SqlExpression, target: SqlExpression) {
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
    const resolved = new Map<SqlBinding | SqlExpression, SqlExpression>();
    const active = new Set<SqlBinding | SqlExpression>();
    const read: ParamReader = param => {
      if (!reads.has(param)) reads.set(param, param.value);
      return reads.get(param);
    };
    const resolve = (expression: SqlExpression): SqlExpression => mapTree(expression, node => {
      const name = bindingName(node);
      const binding = metadata.get(node);
      if (!binding) {
        if (name) throw new Error(`Unresolved native SQL binding: ${name}`);
        return;
      }
      if (binding.frame) throw new TypeError('Dynamic frames must be attached using a window expression or Query.window.');
      const key = name ? binding : node;
      if (resolved.has(key)) return resolved.get(key)!;
      if (active.has(key)) throw new Error('Cyclic native SQL binding.');
      active.add(key);
      const value = resolve(rootExpression(binding.resolve(read, node)));
      active.delete(key);
      resolved.set(key, value);
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

export function assertResolved(input: SqlRoot): void {
  for (const node of walk(rootExpression(input))) {
    const name = bindingName(node);
    if (name) throw new Error(`Unresolved native SQL binding: ${name}`);
    if (metadata.has(node)) throw new Error('Unresolved native SQL template.');
  }
}

export class StructuralKeyScope {
  private identities = new WeakMap<object, number>();
  private sequence = 0;

  private identity(value: object): number {
    if (!this.identities.has(value)) this.identities.set(value, this.sequence++);
    return this.identities.get(value)!;
  }

  key(input: SqlRoot): string {
    const root = rootExpression(input);
    const memo = new Map<object, string>();
    const templates = new Map<object, string>();
    const active = new Set<object>();
    const pending: { value: object; visited: boolean }[] = [{ value: root, visited: false }];
    const encode = (value: unknown): string => {
      if (value && typeof value === 'object') return memo.get(value)!;
      if (value === undefined) return 'undefined';
      const result = JSON.stringify(value);
      if (result === undefined) throw new TypeError('Native SQL keys require plain AST data.');
      return result;
    };
    while (pending.length) {
      const { value, visited } = pending.pop()!;
      if (memo.has(value)) continue;
      if (!visited) {
        const node = ast.isExpressionValue(value) ? value : undefined;
        const binding = node ? metadata.get(node) : undefined;
        if (binding && node) {
          const token = JSON.stringify([
            'binding', binding.kind, this.identity(binding), this.identity(binding.resolve),
            binding.field ? this.identity(binding.field) : null, binding.qualifier, binding.frame ?? false,
            binding.parameters.map(param => this.identity(param))
          ]);
          if (bindingName(node)) {
            memo.set(value, token);
            continue;
          }
          templates.set(value, token);
        }
        if (active.has(value)) throw new TypeError('Native SQL expressions must be acyclic.');
        active.add(value);
        pending.push({ value, visited: true });
        for (const child of Object.values(value)) {
          if (child && typeof child === 'object' && !memo.has(child)) pending.push({ value: child, visited: false });
        }
      } else {
        active.delete(value);
        const result = Array.isArray(value)
          ? '[' + value.map(encode).join(',') + ']'
          : '{' + Object.keys(value).sort().map(key => JSON.stringify(key) + ':' + encode(Reflect.get(value, key))).join(',') + '}';
        const template = templates.get(value);
        memo.set(value, template ? '["template",' + template + ',' + result + ']' : result);
      }
    }
    return memo.get(root)!;
  }

  reset(): void {
    this.identities = new WeakMap();
    this.sequence = 0;
  }
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
  const pending: unknown[] = [rootExpression(input)];
  const visited = new Set<object>();
  while (pending.length) {
    const node = pending.pop();
    if (!node || typeof node !== 'object' || visited.has(node)) continue;
    visited.add(node);
    if (!ast.isExpressionValue(node)) {
      pending.push(...Object.values(node).reverse());
      continue;
    }
    const binding = metadata.get(node);
    if (binding?.frame) continue;
    if (binding?.field) {
      result.push({ node, ...binding.field(read) });
      continue;
    } else if (binding?.kind === 'deferred' && bindingName(node)) {
      result.push(...fields(snapshot(node)));
      continue;
    }
    if ('star' in node) {
      const parts = columnParts(node);
      result.push({ node, column: '*', table: parts && parts.length > 1 ? parts.slice(0, -1).join('.') : undefined });
      pending.push(...(node.star.replace ?? []).slice().reverse());
      continue;
    }
    if ('columns' in node) {
      const selector = node.columns.this;
      if ('array' in selector && selector.array.expressions.every(value => 'literal' in value && value.literal.literal_type === 'string')) {
        for (const value of selector.array.expressions) {
          if ('literal' in value && value.literal.literal_type === 'string') result.push({ node: value, column: value.literal.value });
        }
      } else {
        if (!('star' in selector)) result.push({ node, column: '*' });
        pending.push(selector);
      }
      continue;
    }
    const parts = columnParts(node);
    if ('column' in node && !node.column.name.quoted && /^#\d+$/.test(node.column.name.name)) {
      result.push({ node, column: '*' });
    } else if (parts) result.push({ node, column: parts[parts.length - 1], table: parts.length > 1 ? parts.slice(0, -1).join('.') : undefined });
    else pending.push(...Object.values(node).reverse());
  }
  return result;
}
