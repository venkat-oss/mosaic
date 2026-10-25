import { asNode, isExpression, tableRef } from './expression.js';
import { rootExpression } from './bindings.js';
import { native } from './runtime.js';
import type { ExprValue, SqlExpression, SqlRoot } from './types.js';

export interface StarOptions {
  exclude?: readonly (string | SqlRoot)[];
  replace?: Record<string, ExprValue>;
  rename?: Record<string, string> | readonly (readonly [string | SqlRoot, string])[];
}

export function star(table?: string | readonly string[] | SqlRoot | null, options: StarOptions = {}): SqlExpression {
  const qualifier = table == null ? undefined
    : typeof table === 'string' ? native.identifier(table, true).identifier
    : Array.isArray(table) ? tableRef(table)
    : rootExpression(table as SqlRoot);
  return native.star(qualifier, {
    except: options.exclude?.map(value => asNode(value)),
    replace: Object.entries(options.replace ?? {}).map(([name, value]) =>
      native.alias(asNode(value), native.identifier(name, true).identifier).alias),
    rename: (Array.isArray(options.rename) ? options.rename : Object.entries(options.rename ?? {}))
      .map(([from, to]) => [asNode(from), native.identifier(to, true).identifier])
  });
}

export function columns(selector: string | readonly string[] | SqlRoot, unpack = false): SqlExpression {
  const expression = typeof selector === 'string' ? native.literal(selector)
    : Array.isArray(selector) ? native.array(selector.map(value => native.literal(value)))
    : isExpression(selector) ? selector : rootExpression(selector as SqlRoot);
  return native.columns(expression, unpack);
}
