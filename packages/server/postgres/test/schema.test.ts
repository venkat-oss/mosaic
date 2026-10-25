import { describe, expect, it } from 'vitest';
import { tableFromIPC, tableToIPC, TimeUnit, Type } from '@uwdata/flechette';
import type { FieldDef, QueryResult } from 'pg';
import { arrowIPC, decimalValue, PostgresTypeError, timestampValue } from '../src/schema.js';

const definition = (name: string, oid: number, modifier = -1): FieldDef => ({
  name, dataTypeID: oid, dataTypeModifier: modifier, dataTypeSize: -1,
  tableID: 0, columnID: 0, format: 'text'
});
const numericModifier = (precision: number, scale: number) => ((precision << 16) | (scale & 0x7ff)) + 4;

function decode(fields: FieldDef[], rows: (string | null)[][], baseColumnNullability = false,
  catalog = fields.map(field => ({ sqlType: 'OID_' + field.dataTypeID, baseNotNull: field.tableID ? true : null }))) {
  const result: QueryResult<(string | null)[]> = { command: 'SELECT', rowCount: rows.length, oid: 0, fields, rows };
  const bytes = arrowIPC(result, catalog, baseColumnNullability);
  return tableFromIPC(bytes, { useBigInt: true, useBigIntTimestamp: true, useDecimalInt: true, useDate: false });
}

describe('PostgreSQL Arrow schema', () => {
  it('uses declared OIDs and typmods with the same schema for empty and populated results', () => {
    const fields = [definition('id', 20), definition('amount', 1700, numericModifier(38, 8)), definition('time', 1184)];
    const empty = decode(fields, []);
    const table = decode(fields, [['9223372036854775807', '-123456789012345678901234567890.12345678', '2026-10-24 12:34:56.123456+00']]);
    expect(empty.numRows).toBe(0);
    expect(empty.schema).toEqual(table.schema);
    expect(table.getChild('id')!.at(0)).toBe(9223372036854775807n);
    expect(table.getChild('amount')!.at(0)).toBe(-12345678901234567890123456789012345678n);
    expect(table.getChild('time')!.at(0)).toBe(1792845296123456n);
    expect(table.schema.fields[1].type).toMatchObject({ typeId: Type.Decimal, precision: 38, scale: 8, bitWidth: 128 });
    expect(table.schema.fields[2].type).toMatchObject({ typeId: Type.Timestamp, unit: TimeUnit.MICROSECOND, timezone: 'UTC' });
  });

  it('preserves unconstrained numeric text without guessing scale or precision from rows', () => {
    const table = decode([definition('mean', 1700)], [['123456789012345678901234567890.00000000000000000000001'], ['NaN'], [null]]);
    expect(table.schema.fields[0].type.typeId).toBe(Type.Utf8);
    expect(table.schema.fields[0].metadata?.get('postgres.numericEncoding')).toBe('text');
    expect(Array.from(table.getChild('mean')!)).toEqual(['123456789012345678901234567890.00000000000000000000001', 'NaN', null]);
  });

  it('supports large and negative-scale declared decimals without float conversion', () => {
    expect(decimalValue('12300', 5, -2)).toBe(123n);
    expect(decimalValue('0.00123', 3, 5)).toBe(123n);
    const value = '1234567890123456789012345678901234567890.1234';
    const table = decode([definition('large', 1700, numericModifier(44, 4))], [[value]]);
    expect(table.schema.fields[0].type).toMatchObject({ bitWidth: 256, precision: 44, scale: 4 });
    expect(table.getChild('large')!.at(0)).toBe(12345678901234567890123456789012345678901234n);
    const rounded = definition('rounded', 1700, numericModifier(5, -2));
    const catalog = [{ sqlType: 'NUMERIC(5,-2)', baseNotNull: null }];
    const negative = decode([rounded], [['12300']], false, catalog);
    expect(negative.schema.fields[0].type).toMatchObject({ precision: 7, scale: 0 });
    expect(negative.schema.fields[0].metadata?.get('mosaic.sqlType')).toBe('NUMERIC(5,-2)');
    expect(negative.schema.fields[0].metadata?.get('postgres.typmod')).toBe(String(rounded.dataTypeModifier));
    expect(negative.getChild('rounded')!.at(0)).toBe(12300n);
    expect(tableFromIPC(tableToIPC(negative, {})!).getChild('rounded')!.at(0)).toBe(12300);
    expect(decode([rounded], [], false, catalog).schema).toEqual(negative.schema);
    expect(() => decimalValue('1.001', 3, 2)).toThrow(/scale/);
    expect(() => decimalValue('1000', 3, 0)).toThrow(/precision/);
    expect(() => decode([definition('too_wide', 1700, numericModifier(77, 0))], [])).toThrow(PostgresTypeError);
    expect(() => decode([definition('expanded_too_wide', 1700, numericModifier(76, -1))], [])).toThrow(PostgresTypeError);
  });

  it('preserves submillisecond and pre-epoch timestamps and rejects unrepresentable values', () => {
    expect(timestampValue('1970-01-01 00:00:00.000001', false)).toBe(1n);
    expect(timestampValue('1969-12-31 23:59:59.999999', false)).toBe(-1n);
    expect(timestampValue('1970-01-01 02:30:00.123456+02:30', true)).toBe(123456n);
    expect(timestampValue('0001-01-01 00:00:00 BC', false)).toBe(-62167219200000000n);
    expect(() => timestampValue('infinity', false)).toThrow(/Unsupported/);
    expect(() => timestampValue('294276-12-31 23:59:59.999999', false)).toThrow(/Arrow microsecond range/);
  });

  it('preserves time-of-day endpoints and rejects the exclusive day boundary', () => {
    const fields = [definition('time', 1083)];
    const table = decode(fields, [['00:00:00'], ['23:59:59.999999']]);
    expect(Array.from(table.getChild('time')!)).toEqual([0n, 86399999999n]);
    expect(table.schema.fields[0].type).toMatchObject({ typeId: Type.Time, unit: TimeUnit.MICROSECOND, bitWidth: 64 });
    expect(() => decode(fields, [['24:00:00']])).toThrow(/Arrow time64 day range/);
  });

  it('retains binary bounds, prototype field names and null values', () => {
    const table = decode([definition('__proto__', 23), definition('bytes', 17), definition('yes', 16)], [['7', '\\x0041ff', 't'], [null, null, null]]);
    expect(table.names).toEqual(['__proto__', 'bytes', 'yes']);
    expect(table.getChild('__proto__')!.at(0)).toBe(7);
    expect(Array.from(table.getChild('bytes')!.at(0) as Uint8Array)).toEqual([0, 65, 255]);
    expect(table.getChild('yes')!.at(0)).toBe(true);
    expect(table.getChild('bytes')!.at(1)).toBeNull();
  });

  it('uses catalog non-nullability only for an explicitly safe base projection', () => {
    const field = { ...definition('id', 23), tableID: 42, columnID: 1 };
    expect(decode([field], []).schema.fields[0].nullable).toBe(true);
    expect(decode([field], [], true).schema.fields[0].nullable).toBe(false);
    expect(decode([definition('expression', 23)], [], true).schema.fields[0].nullable).toBe(true);
    expect(decode([field], [[null]]).getChild('id')!.at(0)).toBeNull();
  });

  it('rejects unknown output types even for empty results', () => {
    expect(() => decode([definition('unsupported', 999999)], [])).toThrow(/unsupported PostgreSQL output type/);
  });
});
