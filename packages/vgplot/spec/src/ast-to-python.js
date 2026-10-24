import { MARK_CHANNELS } from './generated/common-marks.js';
import { PYTHON_ATTRIBUTE_APIS } from './generated/plot-attribute-apis.js';
import { PYTHON_BASIC_INPUT_APIS } from './generated/basic-inputs.js';
import { PYTHON_TABLE_INPUT_APIS } from './generated/table-input.js';
import { LAYOUT_APIS } from './generated/layouts.js';
import { camelCaseToSnake } from './util.js';
import { TRANSFORM_KEYS } from './generated/transform-keys.js';
import { LEGEND_APIS, LEGEND_KEY_MAP } from './generated/legends.js';
import { INTERACTOR_KEY_MAP } from './generated/interactors.js';
import { PYTHON_KEYWORDS } from './python-keywords.js';
import { SELECTION_APIS } from './generated/params.js';
import { DATA_APIS, DATA_INFERRED_APIS } from './generated/data.js';
import { COLUMN_TRANSFORM_APIS, SQL_KEY } from './generated/column.js';
import { AGGREGATE_TRANSFORM_APIS } from './generated/aggregate.js';
import { WINDOW_TRANSFORM_APIS } from './generated/window.js';
import {
  kwarg,
  inputArgName,
  literal,
  indentLine,
} from './python-codegen.js';

/** Build snake_cased, keyword-safe kwargs for an options object. */
function buildArgs(opts, ctx, keyMap = null) {
  return Object.entries(opts)
    .filter(([, v]) => v !== undefined)
    .map(([k, v]) => kwarg((keyMap && keyMap[k]) || camelCaseToSnake(k), literal(v, 0, ctx)));
}

/**
 * Generate Python code for a Mosaic spec AST using the vgplot Python DSL.
 * Preamble:  import vgplot as vg
 * Final var: view
 */
export function astToPython(ast) {
  const ctx = new PythonCodegenContext();
  const json = ast.toJSON();
  const { config, data = {}, params = {}, plotDefaults, ...view } = json;
  delete view.meta;
  const dataEntries = Object.entries(data);
  const paramEntries = Object.entries(params);
  for (const [name] of paramEntries) ctx.ident(name);
  for (const [name] of dataEntries) {
    ctx.dataVarMap.set(name, ctx.allocate(ctx.identMap.has(name) ? name + '_data' : name));
  }

  if (Object.values(params).some(dateParamParts)) {
    ctx.emit('from datetime import date');
    ctx.blank();
  }
  ctx.emit('import vgplot as vg');
  ctx.blank();

  // data - emit one variable per named dataset
  for (const [name, def] of dataEntries) {
    ctx.emit(`${ctx.dataVar(name)} = ${emitDataDef(def, ctx)}`);
  }
  if (dataEntries.length) ctx.blank();

  // params - emitted before view so variables are in scope
  for (const [name, def] of paramEntries) {
    ctx.emit(emitParamDef(ctx.ident(name), def, ctx));
  }
  if (paramEntries.length) ctx.blank();

  const renamedData = dataEntries.filter(([name]) => ctx.dataVar(name) !== name || name.startsWith('_'));
  const renamedParams = paramEntries.some(([name]) => ctx.ident(name) !== name || name.startsWith('_'));
  const acceptsHeader = view.plot || LAYOUT_APIS.some(layout => layout.kind === 'concat' && view[layout.key]);
  const wrap = renamedParams || (!acceptsHeader && (config || plotDefaults || renamedData.length));
  const topKwargs = [];
  const dataArgs = wrap ? dataEntries : renamedData;
  if (dataArgs.length) {
    topKwargs.push(`data={${dataArgs.map(([name]) => `${literal(name)}: ${ctx.dataVar(name)}`).join(', ')}}`);
  }
  if (wrap && paramEntries.length) {
    topKwargs.push(`params={${paramEntries.map(([name]) => `${literal(name)}: ${ctx.ident(name)}`).join(', ')}}`);
  }
  if (plotDefaults) topKwargs.push(`plot_defaults=${literal(plotDefaults)}`);
  if (config) topKwargs.push(`config=${literal(config)}`);
  const component = emitComponent(view, ctx, wrap ? [] : topKwargs);
  ctx.emit(wrap
    ? `view = vg.spec(\n${indentLine(`view=${component}`, 1)},\n${topKwargs.map(arg => indentLine(arg, 1)).join(',\n')},\n)`
    : `view = ${component}`);

  return ctx.toString();
}

/** Year/month/day parts of a date-valued param def ({date: 'YYYY-MM-DD'}), or null. */
function dateParamParts(def) {
  if (def && typeof def === 'object' && !Array.isArray(def) &&
      Object.keys(def).length === 1 && typeof def.date === 'string') {
    const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(def.date);
    if (m) return m.slice(1).map(Number);
  }
  return null;
}

function emitParamDef(name, def, ctx) {
  if (def === null || def === undefined) return `${name} = vg.param(None)`;
  if (typeof def !== 'object') return `${name} = vg.param(${literal(def)})`;
  if (Array.isArray(def)) {
    return `${name} = vg.param([${def.map(v => literal(v, 0, ctx)).join(', ')}])`;
  }
  const parts = dateParamParts(def);
  if (parts) return `${name} = vg.param(date(${parts.join(', ')}))`;
  const { select, ...opts } = def;
  if (select) {
    const optArgs = buildArgs(opts, ctx);
    const method = SELECTION_APIS[select]?.python ?? camelCaseToSnake(select);
    return `${name} = vg.selection.${method}(${optArgs.join(', ')})`;
  }
  return `${name} = vg.param(${literal(def)})`;
}

/** @param {PythonCodegenContext} ctx @param {string[]} topKwargs */
function emitComponent(node, ctx, topKwargs = []) {
  if (!node || typeof node !== 'object') return literal(node);
  if (Array.isArray(node)) {
    const body = node.map(n => indentLine(emitComponent(n, ctx), 1)).join(',\n');
    return node.length ? '[\n' + body + ',\n]' : '[]';
  }
  const kwargSuffix = topKwargs.length
    ? ',\n' + topKwargs.map(k => indentLine(k, 1)).join(',\n')
    : '';
  for (const layout of LAYOUT_APIS) {
    const value = node[layout.key];
    if (layout.kind === 'concat' && value) {
      const body = value.map(n => indentLine(emitComponent(n, ctx), 1)).join(',\n');
      return `vg.${layout.python}(\n${body}${kwargSuffix},\n)`;
    }
    if (layout.kind === 'space' && value !== undefined) {
      return `vg.${layout.python}(${literal(value, 0, ctx)})`;
    }
  }
  if (node.input) return emitInput(node, ctx);
  if (node.legend) return emitLegend(node, ctx);
  if (node.plot) return emitPlotObject(node, ctx, topKwargs);
  return literal(node, 0, ctx);
}

/** @param {PythonCodegenContext} ctx */
function emitInteractor(node, ctx) {
  const { select, ...opts } = node;
  const args = Object.entries(opts)
    .filter(([, v]) => v !== undefined)
    .map(([k, v]) => {
      const pyKey = INTERACTOR_KEY_MAP[k] || camelCaseToSnake(k);
      if (k === 'brush' && v && typeof v === 'object' && !Array.isArray(v)) {
        return kwarg(pyKey, `vg.brush(${buildArgs(v, ctx).join(', ')})`);
      }
      return kwarg(pyKey, literal(v, 0, ctx));
    });
  return `vg.${camelCaseToSnake(select)}(${args.join(', ')})`;
}

/** @param {PythonCodegenContext} ctx */
function emitLegend(node, ctx) {
  const { legend, ...opts } = node;
  const args = buildArgs(opts, ctx, LEGEND_KEY_MAP);
  const name = LEGEND_APIS[legend]?.python ?? `${camelCaseToSnake(legend)}_legend`;
  return `vg.${name}(${args.join(', ')})`;
}

/** @param {PythonCodegenContext} ctx @param {string[]} topKwargs */
function emitPlotObject(view, ctx, topKwargs = []) {
  const items = [];
  for (const mark of view.plot || []) {
    if (mark.mark) items.push(emitMark(mark, ctx));
    else if (mark.select) items.push(emitInteractor(mark, ctx));
    else if (mark.legend) items.push(emitLegend(mark, ctx));
    else items.push(literal(mark, 0, ctx));
  }
  for (const [k, v] of Object.entries(view)) {
    if (k === 'plot' || v === undefined) continue;
    items.push(emitDirective(k, v, ctx));
  }
  items.push(...topKwargs);
  const body = items.map(s => indentLine(s, 1)).join(',\n');
  return items.length ? `vg.plot(\n${body},\n)` : 'vg.plot()';
}

function emitDataDef(def, ctx) {
  const { type, file, query, ...rest } = def;
  const inferredType = !type && file && file.lastIndexOf('.') >= 0 ? DATA_INFERRED_APIS[file.slice(file.lastIndexOf('.') + 1)] : undefined;
  const api = DATA_APIS[type || inferredType];
  if (api?.kind === 'file' && file) {
    const extra = buildArgs(rest, ctx).join(', ');
    return extra ? `vg.${api.python}(${literal(file)}, ${extra})` : `vg.${api.python}(${literal(file)})`;
  }
  if (api?.kind === 'spatial' && file) {
    const args = [literal(file)];
    if (rest.layer !== undefined) args.push(`layer=${literal(rest.layer, 0, ctx)}`);
    for (const [k, v] of Object.entries(rest)) {
      if (k !== 'layer') args.push(kwarg(camelCaseToSnake(k), literal(v, 0, ctx)));
    }
    return `vg.${api.python}(${args.join(', ')})`;
  }
  if (api?.kind === 'table' && query && !Object.keys(rest).length) return `vg.${api.python}(${literal(query)})`;
  if (api?.kind === 'json') {
    const { data: inlineData, ...more } = rest;
    const args = [];
    if (inlineData !== undefined) args.push(literal(inlineData));
    if (file) args.push(`file=${literal(file)}`);
    args.push(...buildArgs(more, ctx));
    return `vg.${api.python}(${args.join(', ')})`;
  }
  return literal(def, 0, ctx);
}

/**
 * Emit a channel value: a transform dict becomes a call to the corresponding
 * generated vgplot function (positional transform args + option kwargs);
 * anything else is a literal.
 * @param {any} v
 * @param {PythonCodegenContext} ctx
 */
function emitEncoding(v, ctx) {
  if (!v || typeof v !== 'object' || Array.isArray(v)) return literal(v, 0, ctx);
  const keys = Object.keys(v);
  if (!keys.length) return literal(v, 0, ctx);
  const key = keys[0];
  if (key === SQL_KEY && keys.length === 1) return `vg.sql(${literal(v[SQL_KEY])})`;
  if (!TRANSFORM_KEYS.has(key)) return literal(v, 0, ctx);
  const { [key]: val, ...opts } = v;
  const args = (val === '' || val == null) ? []
    : (Array.isArray(val) ? val : [val]).map(x => emitEncoding(x, ctx));
  args.push(...Object.entries(opts)
    .filter(([, o]) => o !== null && o !== undefined)
    .map(([k, o]) => kwarg(camelCaseToSnake(k), Array.isArray(o)
      ? `[${o.map(x => emitEncoding(x, ctx)).join(', ')}]`
      : emitEncoding(o, ctx))));
  const name = COLUMN_TRANSFORM_APIS[key]?.python
    ?? AGGREGATE_TRANSFORM_APIS[key]?.python
    ?? WINDOW_TRANSFORM_APIS[key]?.python
    ?? camelCaseToSnake(key);
  return `vg.${name}(${args.join(', ')})`;
}

/** @param {PythonCodegenContext} ctx */
function emitMark(mark, ctx) {
  const { mark: name, data, ...enc } = mark;
  const args = [];
  if (data !== undefined) {
    if (data && typeof data === 'object' && data.from &&
        typeof data.from === 'string' && !data.from.startsWith('$') &&
        Object.keys(data).length === 1) {
      // Simple dataset name -> positional variable reference
      args.push(ctx.dataVarMap.has(data.from) ? ctx.dataVar(data.from) : literal(data.from));
    } else {
      let dataRef = data;
      const dataOpts = [];
      if (data && typeof data === 'object' && data.from) {
        const { from: fromVal, ...rest } = data;
        dataRef = { from: fromVal };
        for (const [k, v] of Object.entries(rest)) {
          dataOpts.push(kwarg(camelCaseToSnake(k), literal(v, 0, ctx)));
        }
      }
      args.push(`data=${emitDataRef(dataRef, ctx)}`);
      args.push(...dataOpts);
    }
  }
  for (const [k, v] of Object.entries(enc)) {
    if (v === undefined) continue;
    if (k === 'sort' && v && typeof v === 'object' && !Array.isArray(v)) {
      args.push(`sort=vg.sort(${buildArgs(v, ctx).join(', ')})`);
    } else if (k === MARK_CHANNELS.option && v && typeof v === 'object' && !Array.isArray(v)) {
      const chanArgs = Object.entries(v)
        .map(([ck, cv]) => kwarg(ck, literal(cv))).join(', ');
      args.push(`${MARK_CHANNELS.argument}=vg.${MARK_CHANNELS.helper}(${chanArgs})`);
    } else {
      args.push(kwarg(camelCaseToSnake(k), emitEncoding(v, ctx)));
    }
  }
  const snakeName = camelCaseToSnake(name);
  const argStr = args.join(', ');
  return argStr.length ? `vg.${snakeName}(${argStr})` : `vg.${snakeName}()`;
}

/** @param {PythonCodegenContext} ctx */
function emitDirective(key, value, ctx) {
  const api = PYTHON_ATTRIBUTE_APIS[key];
  const name = api?.python ?? camelCaseToSnake(key);
  if (api?.arguments === 'keywords' && value && typeof value === 'object') {
    return `vg.${name}(${buildArgs(value, ctx).join(', ')})`;
  }
  return `vg.${name}(${literal(value, 0, ctx)})`;
}

/** @param {PythonCodegenContext} ctx */
function emitInput(node, ctx) {
  const kind = node.input;
  const opts = { ...node };
  delete opts.input;
  const args = Object.entries(opts)
    .filter(([, v]) => v !== undefined)
    .map(([k, v]) => kwarg(inputArgName(k), emitInputValue(k, v, ctx)));
  const fn = PYTHON_BASIC_INPUT_APIS[kind] ?? PYTHON_TABLE_INPUT_APIS[kind];
  if (fn) return `vg.${fn}(${args.join(', ')})`;
  return `vg.input(${literal(kind, 0, ctx)}${args.length ? ', ' + args.join(', ') : ''})`;
}

/**
 * @param {string} key
 * @param {any} v
 * @param {PythonCodegenContext} ctx
 */
function emitInputValue(key, v, ctx) {
  if (key === 'options' && Array.isArray(v)) {
    const items = v.map(item => {
      if (item && typeof item === 'object' && 'label' in item && 'value' in item) {
        return item.label === item.value
          ? literal(item.label)
          : `vg.option(${literal(item.label)}, value=${literal(item.value)})`;
      }
      return literal(item);
    });
    return '[' + items.join(', ') + ']';
  }
  if (key === 'from' && typeof v === 'string' && ctx.dataVarMap.has(v)) {
    return ctx.dataVar(v);
  }
  return literal(v, 0, ctx);
}

function emitDataRef(data, ctx) {
  if (Array.isArray(data)) return literal(data);
  if (data && typeof data === 'object' && data.from) {
    const { from: name, ...rest } = data;
    const nameRef = ctx.dataVarMap.has(name) ? ctx.dataVar(name) : literal(name, 0, ctx);
    if (!Object.keys(rest).length) return nameRef;
    const extraArgs = buildArgs(rest, ctx);
    return `vg.source(${[nameRef, ...extraArgs].join(', ')})`;
  }
  return literal(data, 0, ctx);
}

export class PythonCodegenContext {
  constructor() {
    this.lines = [];
    this.depth = 0;
    this.identMap = new Map();
    this.usedNames = new Set(['vg', 'date', 'view', 'float']);
    this.dataVarMap = new Map(); // originalDataName -> pythonVarName
    this.defaultAttrsVar = ''; // variable name for shared plot default attributes
  }
  emit(line) { this.lines.push(this.tab() + line); }
  blank() {
    if (this.lines.length === 0 || this.lines[this.lines.length - 1] !== '') {
      this.lines.push('');
    }
  }
  indent() { this.depth += 1; }
  dedent() { this.depth = Math.max(0, this.depth - 1); }
  tab() { return '    '.repeat(this.depth); }
  toString() { return this.lines.join('\n') + '\n'; }
  ident(name) {
    if (this.identMap.has(name)) return this.identMap.get(name);
    const identifier = this.allocate(name);
    this.identMap.set(name, identifier);
    return identifier;
  }
  allocate(name) {
    let base = name.replace(/[^A-Za-z0-9_]/g, '_').replace(/^([0-9])/, '_$1') || '_';
    if (PYTHON_KEYWORDS.has(base)) base += '_';
    let identifier = base;
    for (let suffix = 2; this.usedNames.has(identifier); ++suffix) identifier = base + suffix;
    this.usedNames.add(identifier);
    return identifier;
  }
  /** Python variable name for a data source (avoids clash with same-named params). */
  dataVar(name) {
    return this.dataVarMap.get(name) ?? this.ident(name);
  }
}
