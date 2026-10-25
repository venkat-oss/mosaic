import { connect } from './connect.js';
import { coordinator } from '@uwdata/mosaic-core';

export function input(ctx, InputClass, options) {
  const owner = ctx?.context?.coordinator ?? coordinator();
  const input = new InputClass(options, owner.nativeContext ?? undefined);
  connect(ctx, input);
  return input.element;
}
