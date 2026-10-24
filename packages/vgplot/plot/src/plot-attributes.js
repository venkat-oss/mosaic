import { CARTESIAN_ATTRIBUTE_ROUTES } from './generated/cartesian-attribute-routes.js';
import { COLOR_ATTRIBUTE_ROUTES } from './generated/color-attribute-routes.js';
import { FACET_ATTRIBUTE_ROUTES } from './generated/facet-attribute-routes.js';
import { PLOT_ATTRIBUTE_ROUTES } from './generated/plot-attribute-routes.js';
import { PROJECTION_ATTRIBUTE_ROUTES } from './generated/projection-attribute-routes.js';
import { SIZE_ATTRIBUTE_ROUTES } from './generated/size-attribute-routes.js';

export const attributeMap = new Map([
  ...PLOT_ATTRIBUTE_ROUTES,
  ...CARTESIAN_ATTRIBUTE_ROUTES,
  ...FACET_ATTRIBUTE_ROUTES,
  ...COLOR_ATTRIBUTE_ROUTES,
  ...SIZE_ATTRIBUTE_ROUTES,
  ...PROJECTION_ATTRIBUTE_ROUTES,
]);

function setProperty(object, path, value) {
  for (let i = 0; i < path.length; ++i) {
    const key = path[i];
    if (i === path.length - 1) {
      object[key] = value;
    } else {
      object = (object[key] || (object[key] = {}));
    }
  }
}

export function setAttributes(attributes, spec, symbols) {
  // populate top-level and scale properties
  for (const key in attributes) {
    const specKey = attributeMap.get(key);
    if (specKey == null) {
      throw new Error(`Unrecognized plot attribute: ${key}`);
    }
    const value = attributes[key];
    if (typeof value === 'symbol') {
      symbols.push(key);
    } else if (value !== undefined) {
      setProperty(spec, specKey.split('.'), value);
    }
  }
}
