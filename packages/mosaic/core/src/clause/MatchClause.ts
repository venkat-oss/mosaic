import type { ExprValue } from '@uwdata/mosaic-sql';
import { asNode, contains, literal, lower, or, prefix, regexp_matches, suffix } from '@uwdata/mosaic-sql';
import type { MosaicClient } from '../MosaicClient.js';
import type { ClauseMetadata, ClauseSource, SelectionClause } from './SelectionClause.js';

/**
 * Selection clause metadata indicating text search matching.
 */
export interface MatchMetadata extends ClauseMetadata {
  type: 'match';
  /** The text search matching method used. */
  method?: 'contains' | 'prefix' | 'suffix' | 'regexp' | (string & {});
}

const MATCH_METHODS = { contains, prefix, suffix, regexp: regexp_matches };

/** Text search matching methods. */
export type MatchMethod = keyof typeof MATCH_METHODS;

/**
 * Options for match-type selection clauses.
 */
export interface MatchOptions {
  /**
   * A unique identifier (according to object equality) for the source
   * component that generated this clause. In many cases, this is a
   * reference to the originating component itself.
   */
  source: ClauseSource;
  /**
   * A set of Mosaic clients associated with this clause that should not
   * be updated when this clause is applied in a cross-filtering context.
   */
  clients?: Set<MosaicClient>;
  /**
   * The text matching method to use, default `'contains'`.
   */
  method?: MatchMethod;
  /**
   * Flag for case sensitive matching, default `false`.
   */
  caseSensitive?: boolean;
}

/**
 * Generate a selection clause for text search matching over a single column.
 * @param field The table column or expression to match.
 * @param value The selected text search query string.
 * @param options Additional clause properties.
 * @param options.source The source component generating this clause.
 * @param options.clients Mosaic clients associated with this clause.
 *  These clients are not filtered by this clause in cross-filtering contexts.
 * @param options.method The text matching method to use, default `'contains'`.
 * @param options.caseSensitive Flag for case sensitive matching, default `false`.
 * @returns The generated selection clause.
 */
export function clauseMatch(
  field: ExprValue,
  value: string | null | undefined,
  {
    source,
    clients = undefined,
    method = 'contains',
    caseSensitive = false
  }: MatchOptions
): SelectionClause {
  field = asNode(field);
  const predicate = matchPredicate(field, value, method, caseSensitive);
  const meta: MatchMetadata = { type: 'match', method };
  return { meta, source, clients, fields: [field], value, predicate };
}

/**
 * Generate a selection clause for text search matching over multiple columns.
 * A match will succeed if any field successfully matches.
 * @param fields The table columns or expressions to match.
 * @param value The selected text search query string.
 * @param options Additional clause properties.
 * @param options.source The source component generating this clause.
 * @param options.clients Mosaic clients associated with this clause.
 *  These clients are not filtered by this clause in cross-filtering contexts.
 * @param options.method The text matching method to use, default `'contains'`.
 * @param options.caseSensitive Flag for case sensitive matching, default `false`.
 * @returns The generated selection clause.
 */
export function clauseMatchAny(
  fields: (ExprValue)[],
  value: string | null,
  {
    source,
    clients = undefined,
    method = 'contains',
    caseSensitive = false
  }: MatchOptions
): SelectionClause {
  const nodes = fields.map(asNode);
  value = value || null;
  const predicate = value ? or(nodes.map(field => matchPredicate(field, value, method, caseSensitive)!)) : null;
  const meta: MatchMetadata = { type: 'match', method };
  return {
    meta,
    source,
    clients,
    fields: nodes,
    value,
    predicate
  };
}

function matchPredicate(field: ExprValue, value: string | null | undefined, method: MatchMethod, caseSensitive: boolean) {
  if (!value) return null;
  const text = literal(value);
  return method === 'regexp' ? regexp_matches(field, text, caseSensitive ? undefined : 'i')
    : MATCH_METHODS[method](caseSensitive ? field : lower(field), caseSensitive ? text : lower(text));
}
