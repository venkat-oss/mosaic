import * as Plot from '@observablehq/plot';
import * as sql from '@uwdata/mosaic-sql';
import { binInfo } from './transforms/bin.js';
import { setAttributes } from './plot-attributes.js';
import { Fixed } from './symbols.js';

const OPTIONS_ONLY_MARKS = new Set([
  'frame',
  'hexgrid',
  'sphere',
  'graticule'
]);

const TIMESTAMPTZ_TYPES = new Set([
  'TIMESTAMPTZ',
  'TIMESTAMP WITH TIME ZONE'
]);

const SELECT_TRANSFORMS = new Map(
  /** @type {[string, typeof Plot.selectFirst | typeof Plot.pointer][]} */ ([
    ['first', Plot.selectFirst],
    ['last', Plot.selectLast],
    ['maxX', Plot.selectMaxX],
    ['maxY', Plot.selectMaxY],
    ['minX', Plot.selectMinX],
    ['minY', Plot.selectMinY],
    ['nearest', Plot.pointer],
    ['nearestX', Plot.pointerX],
    ['nearestY', Plot.pointerY]
  ])
);

// construct Plot output
// see https://github.com/observablehq/plot
export async function plotRenderer(plot) {
  const spec = { marks: [] };
  const symbols = [];
  const { attributes } = plot;
  const marks = plot.marks.filter(mark => !mark._failed);

  // populate top-level and scale properties
  setAttributes(attributes, spec, symbols);

  // populate marks
  const indices = [];
  for (const mark of marks) {
    for (const { type, data, options } of mark.plotSpecs()) {
      // prepare mark options
      const { select, ...rest } = options;
      const opt = SELECT_TRANSFORMS.get(select)?.(rest) ?? rest;
      const arg = OPTIONS_ONLY_MARKS.has(type) ? [opt] : [data, opt];

      // instantiate Plot mark and add to spec
      spec.marks.push(Plot[type](...arg));
      if (mark.index > -1) indices.push(mark.index);
    }
  }

  // infer scale types and labels
  inferScaleTypes(spec, marks);
  inferLabels(spec, marks);

  // render plot
  const svg = Plot.plot(spec);

  // annotate svg with mark indices
  annotatePlot(svg, indices);

  // set symbol-valued attributes, such as fixed domains
  setSymbolAttributes(plot, svg, attributes, symbols);

  // initialize interactors
  for (const interactor of plot.interactors) {
    await interactor.init(svg);
  }

  return svg;
}

function setSymbolAttributes(plot, svg, attributes, symbols) {
  symbols.forEach(key => {
    const value = attributes[key];
    if (value === Fixed) {
      if (!key.endsWith('Domain')) {
        throw new Error(`Unsupported fixed attribute: ${key}`);
      }
      const type = key.slice(0, -'Domain'.length);
      const scale = svg.scale(type);
      if (scale?.domain) {
        plot.setAttribute(key, attributes[`${type}Reverse`]
          ? scale.domain.slice().reverse()
          : scale.domain);
      }
    } else {
      throw new Error(`Unrecognized symbol: ${value}`);
    }
  });
}

// Plot defaults temporal scales to UTC; TIMESTAMPTZ values are
// instants, so render them in local time instead
function inferScaleTypes(spec, marks) {
  for (const key of ['x', 'y']) {
    const scale = spec[key] || {};
    if (scale.type != null) continue;
    const timestamptz = marks.some(
      mark => TIMESTAMPTZ_TYPES.has(mark.channelField(key)?.sqlType)
    );
    if (timestamptz) spec[key] = { ...scale, type: 'time' };
  }
}

function inferLabels(spec, marks) {
  inferLabel('x', spec, marks);
  inferLabel('y', spec, marks);
  inferLabel('fx', spec, marks);
  inferLabel('fy', spec, marks);
}

function inferLabel(key, spec, marks) {
  const scale = spec[key] || {};
  if (scale.axis === null || scale.label !== undefined) return; // nothing to do

  const fields = marks.map(mark => mark.channelField(key)?.field);
  if (fields.every(x => x == null)) return; // no columns found

  // check for consistent label
  let candidate;
  for (let i = 0; i < fields.length; ++i) {
    const label = fieldLabel(fields[i], marks[i]);
    if (label === undefined) {
      continue;
    } else if (candidate === undefined) {
      candidate = label;
    } else if (candidate !== label) {
      candidate = undefined;
    }
  }
  if (candidate === undefined) return;

  // add label to spec
  spec[key] = { ...scale, label: candidate };
}

function fieldLabel(field, mark) {
  if (!field) return undefined;
  if (sql.isExpression(field) || sql.isExpressionHandle(field)) {
    const expression = sql.rootExpression(field);
    const bin = binInfo(expression);
    if (bin) return fieldLabel(bin.source, mark);
    const path = sql.columnParts(expression);
    if (path) return path.at(-1);
    if ('parameter' in expression) return sql.fields(expression)[0]?.column;
    if ('cast' in expression) return fieldLabel(expression.cast.this, mark);
    if ('make_date' in expression) return 'date';
    const aggregate = sql.inspectAggregate(expression);
    if (aggregate) return aggregate.args.length
      ? aggregate.name + '(' + aggregate.args.map(arg => fieldLabel(arg, mark)).join(', ') + ')'
      : aggregate.name;
    return sql.compile([expression], mark.coordinator?.sqlContext.execution ?? sql.createExecutionContext()).join(';\n').replaceAll('"', '');
  }
  return String(field);
}

function annotatePlot(svg, indices) {
  let index = -1;
  for (const child of svg.children) {
    const aria = child.getAttribute('aria-label') || '';
    const skip = child.nodeName === 'style'
      // skip axis, grid, and frame marks
      || aria.includes('-axis')
      || aria.includes('-grid')
      || aria === 'frame'
      || aria === 'hexgrid';
    if (!skip) {
      child.setAttribute('data-index', indices[++index]);
    }
  }
}
