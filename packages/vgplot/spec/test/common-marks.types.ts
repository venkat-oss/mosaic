import type {
  ChannelDomainOptions, ChannelReducers, ChannelStates, ChannelValues,
  ChannelValueSpec, CurveAutoOptions, CurveOptions, MarkOptions, TipOptions
} from '../src/spec/marks/Marks.js';

export const commonTypes = {
  emptyLimit: { limit: [] } satisfies ChannelDomainOptions,
  partialLimit: { limit: [1] } satisfies ChannelDomainOptions,
  defaultReducer: { x: 'mean' } satisfies ChannelReducers,
  customReducer: { x: { reduce: 'custom', scale: 'color' } } satisfies ChannelReducers<'custom'>,
  states: { x: { value: [1], scale: 'x' } } satisfies ChannelStates,
  values: { x: [1], channels: { x: { value: [1], scale: 'x' } } } satisfies ChannelValues,
  autoCurve: { curve: 'auto' } satisfies CurveAutoOptions,
  curve: { curve: 'linear' } satisfies CurveOptions,
  tip: { filter: 'x', x: 'x', fontFamily: 'sans-serif' } satisfies TipOptions,
  channels: { channels: { 'field name': 'x' } } satisfies MarkOptions
};

// @ts-expect-error The narrowing override excludes auto curves.
export const invalidCurve: CurveOptions = { curve: 'auto' };
// @ts-expect-error Default reducers require the declared Reducer vocabulary.
export const invalidReducer: ChannelReducers = { x: 'custom' };
// @ts-expect-error Mapped states admit only declared channel keys.
export const unknownChannelState: ChannelStates = { unknown: { value: [], scale: 'x' } };
// @ts-expect-error ChannelValues retains its required channels member.
export const missingChannelStates: ChannelValues = { x: [1] };
// @ts-expect-error Scale overrides do not accept parameter references.
export const invalidScale: ChannelValueSpec = { value: 'x', scale: '$scale' };
// @ts-expect-error Additional mark channels have string values.
export const numericExtraChannel: MarkOptions = { channels: { alias: 1 } };
