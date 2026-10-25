import {
  binary, bool, columnFromArray, dateDay, decimal128, decimal256, field,
  float32, float64, int16, int32, int64, Table, tableToIPC, TimeUnit,
  timestamp, timeMicrosecond, uint32, utf8, Version, Endianness
} from '@uwdata/flechette';
import type { DataType, Field } from '@uwdata/flechette';
import type { FieldDef, QueryResult } from 'pg';

export interface CatalogField {
  sqlType: string;
  baseNotNull: boolean | null;
}

interface ColumnMapping {
  type: DataType;
  value: (source: string) => unknown;
}

export class PostgresTypeError extends TypeError {
  constructor(field: FieldDef, message: string) {
    super(`PostgreSQL field ${JSON.stringify(field.name)} (OID ${field.dataTypeID}): ${message}`);
    this.name = 'PostgresTypeError';
  }
}

const identity = (value: string) => value;
const MICROS_PER_DAY = 86_400_000_000n;
const MIN_INT64 = -(1n << 63n);
const MAX_INT64 = (1n << 63n) - 1n;

function signed64(value: bigint): bigint {
  if (value < MIN_INT64 || value > MAX_INT64) throw new RangeError('Timestamp exceeds Arrow microsecond range.');
  return value;
}

function dayNumber(year: number, month: number, day: number): number {
  year -= month <= 2 ? 1 : 0;
  const era = Math.floor(year / 400);
  const y = year - era * 400;
  const doy = Math.floor((153 * (month + (month > 2 ? -3 : 9)) + 2) / 5) + day - 1;
  return era * 146097 + y * 365 + Math.floor(y / 4) - Math.floor(y / 100) + doy - 719468;
}

export function timestampValue(source: string, withZone: boolean): bigint {
  const match = /^(\d{4,6})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)(?:\.(\d{1,6}))?([+-]\d\d(?::\d\d(?::\d\d)?)?)?( BC)?$/.exec(source);
  if (!match || withZone !== !!match[8]) throw new RangeError(`Unsupported PostgreSQL timestamp: ${source}`);
  const year = match[9] ? 1 - Number(match[1]) : Number(match[1]);
  const days = dayNumber(year, Number(match[2]), Number(match[3]));
  const seconds = Number(match[4]) * 3600 + Number(match[5]) * 60 + Number(match[6]);
  const fraction = BigInt((match[7] ?? '').padEnd(6, '0'));
  const zone = match[8];
  let offset = 0;
  if (zone) {
    const [hours, minutes = 0, seconds = 0] = zone.slice(1).split(':').map(Number);
    offset = (zone[0] === '-' ? -1 : 1) * (hours * 3600 + minutes * 60 + seconds);
  }
  return signed64(BigInt(days) * MICROS_PER_DAY + BigInt(seconds - offset) * 1_000_000n + fraction);
}

function dateValue(source: string): number {
  const match = /^(\d{4,7})-(\d\d)-(\d\d)( BC)?$/.exec(source);
  if (!match) throw new RangeError(`Unsupported PostgreSQL date: ${source}`);
  const days = dayNumber(match[4] ? 1 - Number(match[1]) : Number(match[1]), Number(match[2]), Number(match[3]));
  if (days < -2147483648 || days > 2147483647) throw new RangeError('Date exceeds Arrow date32 range.');
  return days * 86400000;
}

function timeValue(source: string): bigint {
  const match = /^(\d\d):(\d\d):(\d\d)(?:\.(\d{1,6}))?$/.exec(source);
  if (!match) throw new RangeError(`Unsupported PostgreSQL time: ${source}`);
  const value = BigInt(Number(match[1]) * 3600 + Number(match[2]) * 60 + Number(match[3])) * 1_000_000n
    + BigInt((match[4] ?? '').padEnd(6, '0'));
  if (value < 0n || value >= MICROS_PER_DAY) throw new RangeError('Time exceeds Arrow time64 day range.');
  return value;
}

export function decimalValue(source: string, precision: number, scale: number): bigint {
  const match = /^([+-]?)(\d+)(?:\.(\d*))?$/.exec(source);
  if (!match) throw new RangeError(`Unsupported PostgreSQL numeric: ${source}`);
  const fraction = match[3] ?? '';
  let value = BigInt(match[2] + fraction);
  const shift = scale - fraction.length;
  if (shift >= 0) value *= 10n ** BigInt(shift);
  else {
    const divisor = 10n ** BigInt(-shift);
    if (value % divisor) throw new RangeError('Numeric value does not fit its declared scale.');
    value /= divisor;
  }
  if (value >= 10n ** BigInt(precision)) throw new RangeError('Numeric value exceeds its declared precision.');
  return match[1] === '-' ? -value : value;
}

function numericMapping(definition: FieldDef): ColumnMapping {
  if (definition.dataTypeModifier < 4) return { type: utf8(), value: identity };
  const modifier = definition.dataTypeModifier - 4;
  const declaredPrecision = (modifier >>> 16) & 0xffff;
  const scale = ((modifier & 0x7ff) ^ 0x400) - 0x400;
  const precision = declaredPrecision - Math.min(scale, 0);
  const arrowScale = Math.max(scale, 0);
  if (!declaredPrecision || precision > 76) throw new PostgresTypeError(definition, 'numeric precision exceeds Arrow decimal256.');
  return {
    type: precision <= 38 ? decimal128(precision, arrowScale) : decimal256(precision, arrowScale),
    value: source => decimalValue(source, precision, arrowScale)
  };
}

function mapping(definition: FieldDef): ColumnMapping {
  switch (definition.dataTypeID) {
    case 16: return { type: bool(), value: value => value === 't' };
    case 17: return { type: binary(), value: value => {
      if (!/^\\x(?:[0-9a-f]{2})*$/i.test(value)) throw new RangeError('Expected hexadecimal PostgreSQL bytea output.');
      return Buffer.from(value.slice(2), 'hex');
    } };
    case 20: return { type: int64(), value: BigInt };
    case 21: return { type: int16(), value: Number };
    case 23: return { type: int32(), value: Number };
    case 26: return { type: uint32(), value: Number };
    case 700: return { type: float32(), value: Number };
    case 701: return { type: float64(), value: Number };
    case 1082: return { type: dateDay(), value: dateValue };
    case 1083: return { type: timeMicrosecond(), value: timeValue };
    case 1114: return { type: timestamp(TimeUnit.MICROSECOND), value: value => timestampValue(value, false) };
    case 1184: return { type: timestamp(TimeUnit.MICROSECOND, 'UTC'), value: value => timestampValue(value, true) };
    case 1700: return numericMapping(definition);
    case 18: case 19: case 25: case 1042: case 1043: case 114: case 3802: case 2950:
      return { type: utf8(), value: identity };
    default: throw new PostgresTypeError(definition, 'unsupported PostgreSQL output type.');
  }
}

export function arrowIPC(result: QueryResult<(string | null)[]>, catalog: readonly CatalogField[], baseColumnNullability = false): Uint8Array {
  const fields: Field[] = [];
  const columns = result.fields.map((definition, index) => {
    const { type, value } = mapping(definition);
    const origin = catalog[index];
    const metadata = new Map([
      ['mosaic.sqlType', origin.sqlType],
      ['postgres.oid', String(definition.dataTypeID)],
      ['postgres.typmod', String(definition.dataTypeModifier)]
    ]);
    if (origin.baseNotNull !== null) metadata.set('postgres.baseNotNull', String(origin.baseNotNull));
    if (definition.dataTypeID === 1700 && definition.dataTypeModifier < 4) metadata.set('postgres.numericEncoding', 'text');
    fields.push(field(definition.name, type, !(baseColumnNullability && origin.baseNotNull), metadata));
    return columnFromArray(result.rows.map(row => row[index] === null ? null : value(row[index]!)), type, {
      useBigInt: true, useBigIntTimestamp: true, useDecimalInt: true
    });
  });
  const bytes = tableToIPC(new Table({ version: Version.V5, endianness: Endianness.Little, fields, metadata: null }, columns), {});
  if (!bytes) throw new Error('PostgreSQL Arrow encoding returned no IPC data.');
  return bytes;
}
