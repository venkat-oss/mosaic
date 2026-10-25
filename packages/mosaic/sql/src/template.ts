import { asLiteral, isExpression, isExpressionHandle, isQueryExpression } from './expression.js';
import { copyBinding, markSourceDialect, rootExpression } from './bindings.js';
import { parseExpression } from './ingress.js';
import { createExecutionContext, Dialect, native } from './runtime.js';
import type { SqlExecutionContext } from './runtime.js';
import { compile } from './compile.js';
import { mapTree } from './tree.js';
import type { SqlIngressOptions } from './ingress.js';
import type { ExprValue, SqlExpression, SqlExpressionHandle, SqlRoot } from './types.js';

const PREFIX = '__mosaic_sql_';
type Span = string | SqlRoot;
export type TemplateValue = ExprValue;
export interface SqlTag {
  (strings: readonly string[], ...values: TemplateValue[]): SqlTemplate;
}

export class SqlTemplate implements SqlExpressionHandle {
  private parsed?: SqlExpression;

  constructor(readonly spans: readonly Span[], readonly sourceDialect = Dialect.DuckDB) {}

  get expression(): SqlExpression {
    return this.parsed ??= parseTemplate(this.spans, this.sourceDialect);
  }

  toString(context: SqlExecutionContext = createExecutionContext()): string {
    return compile([this], context)[0];
  }
}

function template(strings: readonly string[], values: readonly TemplateValue[], sourceDialect: Dialect): SqlTemplate {
  if (strings.length !== values.length + 1 || strings.some(value => typeof value !== 'string')) {
    throw new TypeError('SQL templates require one more text span than interpolation values.');
  }
  const spans: Span[] = [strings[0]];
  values.forEach((value, index) => {
    if (value instanceof SqlTemplate) {
      if (value.sourceDialect !== sourceDialect) throw new TypeError('SQL fragments must use the same source dialect.');
      spans.push(...value.spans);
    } else {
      spans.push(typeof value === 'string' || isExpression(value) || isExpressionHandle(value) ? value : asLiteral(value));
    }
    spans.push(strings[index + 1]);
  });
  return new SqlTemplate(spans, sourceDialect);
}

export function sql(strings: readonly string[], ...values: TemplateValue[]): SqlTemplate;
export function sql(options: SqlIngressOptions): SqlTag;
export function sql(strings: readonly string[] | SqlIngressOptions, ...values: TemplateValue[]): SqlTemplate | SqlTag {
  return Array.isArray(strings)
    ? template(strings, values, Dialect.DuckDB)
    : (spans, ...expressions) => template(spans, expressions, (strings as SqlIngressOptions).sourceDialect ?? Dialect.DuckDB);
}

export function verbatim(source: string, hint?: string | SqlIngressOptions, options: SqlIngressOptions = {}): SqlTemplate {
  return new SqlTemplate([source], (typeof hint === 'object' ? hint : options).sourceDialect ?? Dialect.DuckDB);
}

function parseTemplate(spans: readonly Span[], sourceDialect: Dialect): SqlExpression {
  const namespace = Array.from(globalThis.crypto.getRandomValues(new Uint32Array(4)), value => value.toString(36)).join('_');
  const holes = new Map<string, SqlExpression>();
  const source = spans.map(span => {
    if (typeof span === 'string') return span;
    const name = PREFIX + namespace + '_' + holes.size;
    holes.set(name, rootExpression(span));
    return name;
  }).join('');
  let parsed = parseExpression(source, sourceDialect);
  const rootValue = 'column' in parsed && !parsed.column.table ? holes.get(parsed.column.name.name) : undefined;
  if (rootValue && !isQueryExpression(rootValue)) parsed = parseExpression(`(${source}\n)`, sourceDialect);
  const pending: object[] = [parsed];
  while (pending.length) {
    const object = pending.pop()!;
    for (const [key, value] of Object.entries(object)) {
      if (key === 'name' && typeof value === 'string' && value.startsWith(PREFIX) && !holes.has(value)) {
        throw new SyntaxError('SQL input uses the reserved native template identifier prefix.');
      }
      if (value && typeof value === 'object') pending.push(value);
    }
  }
  const consumed = new Set<string>();
  const result = mapTree(parsed, node => {
    const name = 'column' in node && !node.column.table ? node.column.name.name
      : 'table' in node && !node.table.schema && !node.table.catalog ? node.table.name.name : undefined;
    const value = name === undefined ? undefined : holes.get(name);
    if (value === undefined) return;
    consumed.add(name!);
    let replacement = node === parsed || !isQueryExpression(value) ? value : native.subquery(value);
    if (node === parsed) {
      replacement = { ...replacement };
      copyBinding(value, replacement);
      markSourceDialect(replacement, sourceDialect);
    }
    if ('table' in node && node.table.alias) replacement = native.alias(replacement, node.table.alias, {
      column_aliases: node.table.column_aliases,
      alias_explicit_as: node.table.alias_explicit_as
    });
    return replacement;
  }, new Map(), false, copyBinding);
  if (consumed.size !== holes.size) {
    throw new SyntaxError('SQL interpolations must occupy complete expression or relation positions outside quoted delimiters.');
  }
  return result;
}
