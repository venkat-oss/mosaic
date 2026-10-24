export * from './generated/basic-inputs.js';
import { Menu, Search, Slider, Table } from '@uwdata/mosaic-inputs';
import { connect } from './connect.js';

function input(ctx, InputClass, options) {
  const input = new InputClass(options);
  connect(ctx, input); // ctx <- optional API context
  return input.element;
}




export function table(options) {
  return input(this, Table, options);
}
