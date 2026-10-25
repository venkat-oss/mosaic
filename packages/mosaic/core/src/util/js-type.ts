import type { JSType } from '../types.js';

/**
 * Maps a SQL data type to its corresponding JavaScript type.
 * @param type The name of a SQL data type
 * @returns The corresponding JavaScript type name
 * @throws Throws an error if the given SQL type name is unsupported or unrecognized.
 */
export function jsType(type: string): JSType {
  type = type.trim().toUpperCase();
  if (type.endsWith(']')) return 'array';
  switch (type) {
    case 'BIGINT':
    case 'HUGEINT':
    case 'INTEGER':
    case 'SMALLINT':
    case 'TINYINT':
    case 'UBIGINT':
    case 'UINTEGER':
    case 'USMALLINT':
    case 'UTINYINT': // integers
    case 'INT': case 'INT2': case 'INT4': case 'INT8':
    case 'FLOAT4': case 'FLOAT8':
    case 'DOUBLE':
    case 'DOUBLE PRECISION':
    case 'OID':
    case 'FLOAT':
    case 'REAL':
      return 'number';
    case 'DATE':
    case 'TIMESTAMP':
    case 'TIMESTAMPTZ':
    case 'TIMESTAMP WITH TIME ZONE':
    case 'TIME':
    case 'TIMESTAMP_MS':
    case 'TIMESTAMP_NS':
      return 'date';
    case 'BOOLEAN':
    case 'BOOL':
      return 'boolean';
    case 'VARCHAR':
    case 'NAME':
    case '"CHAR"':
    case 'UUID':
    case 'JSON':
    case 'JSONB': case 'TEXT': case 'CHAR': case 'CHARACTER': case 'CHARACTER VARYING':
      return 'string';
    case 'ARRAY':
    case 'LIST':
      return 'array';
    case 'BLOB':
    case 'STRUCT':
    case 'MAP':
    case 'GEOMETRY':
    case 'BYTEA': case 'NULL':
      return 'object';
    default:
      if (type.startsWith('ENUM')) {
        return 'string';
      } else if (type.startsWith('DECIMAL') || type.startsWith('NUMERIC')) {
        return 'number';
      } else if (type.startsWith('STRUCT') || type.startsWith('MAP')) {
        return 'object';
      } else if (/^(?:TIME|TIMESTAMP)(?:\(\d+\))?(?: WITH(?:OUT)? TIME ZONE)?$/.test(type)) {
        return 'date';
      } else if (/^(?:CHAR|VARCHAR|CHARACTER(?: VARYING)?)\(\d+\)$/.test(type)) {
        return 'string';
      }
      throw new Error(`Unsupported type: ${type}`);
  }
}
