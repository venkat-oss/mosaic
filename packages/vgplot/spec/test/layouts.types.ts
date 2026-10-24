import type { Component, HConcat, HSpace, Spec, VConcat, VSpace } from '../src/index.js';

export const row: HConcat = { hconcat: [{ hspace: 12 }, { vconcat: [] }] };
export const column: VConcat = { vconcat: [row, { vspace: '1.5em' }] };
export const horizontal: HSpace = { hspace: 2.5 };
export const vertical: VSpace = { vspace: '$literal' };
export const recursive: Component = { hconcat: [column, { plot: [] }] };
export const specification: Spec = { params: { radius: 4 }, plotDefaults: { width: 200 }, ...column };

// @ts-expect-error Concatenation children remain components, not nested arrays.
export const nestedChildren: HConcat = { hconcat: [[{ hspace: 12 }]] };
// @ts-expect-error Children must be supplied as an array.
export const scalarChild: VConcat = { vconcat: { vspace: 1 } };
// @ts-expect-error Spacer values retain the number|string contract.
export const booleanSpace: HSpace = { hspace: false };
// @ts-expect-error Spacer values exclude parameter wrapper objects.
export const objectSpace: VSpace = { vspace: { param: 'size' } };
// @ts-expect-error Concat interfaces do not add arbitrary layout options.
export const wrapOption: HConcat = { hconcat: [], wrap: true };
