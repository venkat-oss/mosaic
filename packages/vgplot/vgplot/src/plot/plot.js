import { Plot } from '@uwdata/mosaic-plot';
import { coordinator } from '@uwdata/mosaic-core';
import { connect } from '../connect.js';

export function plot(...directives) {
  const mc = this?.context?.coordinator ?? coordinator();
  const p = new Plot(undefined, mc.nativeContext);
  directives.flat().forEach(dir => dir(p));
  connect(this, ...p.marks); // this -> optional API context
  p.update(); // request update, needed if no marks are defined
  return p.element;
}
