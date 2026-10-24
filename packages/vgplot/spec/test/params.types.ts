import type { Param, ParamBase, ParamDate, ParamDefinition, ParamLiteral, ParamRef, ParamValue, Selection } from '../src/index.js';

export const acceptedParams = {
  reference: '$value' satisfies ParamRef,
  emptyReference: '$' satisfies ParamRef,
  doubleReference: '$$column' satisfies ParamRef,
  literal: null satisfies ParamLiteral,
  value: ['$lower', 4, false, null, 'literal'] satisfies ParamValue,
  base: {} satisfies ParamBase,
  wrapped: { select: 'value', value: null } satisfies Param,
  date: { select: 'value', date: '' } satisfies ParamDate,
  selection: { select: 'crossfilter', cross: false, empty: true, include: ['$upstream'] } satisfies Selection,
  definitions: [null, false, 0, '$literal', [], { value: 4 }, { date: 'not-a-date' }, { select: 'union', include: '$other' }] satisfies ParamDefinition[]
};

// @ts-expect-error TypeScript references retain the leading dollar sign.
export const plainReference: ParamRef = 'plain';
// @ts-expect-error Object references remain a parser extension beyond the public wire type.
export const objectReference: ParamRef = { param: 'value' };
// @ts-expect-error Literal parameter values exclude arrays.
export const arrayLiteral: ParamLiteral = [];
// @ts-expect-error Parameter arrays remain flat.
export const nestedArray: ParamValue = [[1]];
// @ts-expect-error Wrapped values are required.
export const missingValue: Param = { select: 'value' };
// @ts-expect-error Value parameters exclude selection discriminants.
export const selectedValue: Param = { select: 'single', value: 1 };
// @ts-expect-error Dates require strings even though string contents are unrestricted.
export const numericDate: ParamDate = { date: 1 };
// @ts-expect-error Selection discriminants remain required.
export const missingSelect: Selection = { empty: false };
// @ts-expect-error Selection inclusion uses parameter references.
export const plainInclude: Selection = { select: 'intersect', include: 'upstream' };
// @ts-expect-error Cross filtering is a boolean option.
export const numericCross: Selection = { select: 'crossfilter', cross: 1 };
// @ts-expect-error Arbitrary objects do not define parameters.
export const arbitraryDefinition: ParamDefinition = { arbitrary: true };
