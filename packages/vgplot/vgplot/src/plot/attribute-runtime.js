import { isParam } from '@uwdata/mosaic-core';

export function setAttribute(plot, name, value) {
  if (isParam(value)) {
    value.addEventListener('value', value => {
      plot.setAttribute(name, value);
      plot.update();
    });
    if (value.value !== undefined) {
      plot.setAttribute(name, value.value);
    }
  } else {
    plot.setAttribute(name, value);
  }
}

export function attribute(name, value) {
  return plot => { setAttribute(plot, name, value); };
}

export function attributes(values) {
  return plot => {
    for (const [name, value] of Object.entries(values)) {
      setAttribute(plot, name, value)
    }
  };
}


export const attrf = name => value => attribute(name, value);
