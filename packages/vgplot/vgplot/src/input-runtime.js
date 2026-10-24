import { connect } from './connect.js';

export function input(ctx, InputClass, options) {
  const input = new InputClass(options);
  connect(ctx, input);
  return input.element;
}
