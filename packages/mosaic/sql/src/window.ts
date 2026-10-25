import { isParamLike } from './util/type-check.js';
import { bind, bindingOf, bindTemplate, cloneExpression, rootExpression, unbindTemplate } from './bindings.js';
import { asLiteral, asNode, isExpression, isExpressionHandle } from './expression.js';
import { ast, createExecutionContext, native } from './runtime.js';
import type { SqlExecutionContext } from './runtime.js';
import { compile } from './compile.js';
import type { ExprValue, MaybeArray, ParamLike, ParamReader, SqlExpression, SqlExpressionHandle, SqlRoot } from './types.js';

export type WindowFrame = ReturnType<typeof native.windowFrame>;
export type FrameBound = ReturnType<typeof native.frameBound>;
export type FrameScalar = number | SqlRoot | null;
export type FrameValue = FrameScalar | FrameBound;
export type FrameExtent = readonly [FrameValue, FrameValue] | ParamLike;
export type FrameExclude = 'NO OTHERS' | 'CURRENT ROW' | 'TIES' | 'GROUP';
export type WindowDefinition = ReturnType<typeof native.over>;
export type NamedWindow = ReturnType<typeof native.namedWindow>;
export type WindowInput = MaybeArray<NamedWindow | Record<string, WindowDef | WindowDefinition> | null | undefined>;

function ordered(values: readonly MaybeArray<ExprValue>[]) {
  return values.flat().filter(value => value != null).map(value => {
    const expression = asNode(value);
    return 'ordered' in expression ? expression.ordered : native.ordered(expression).ordered;
  });
}

function frameBound(value: unknown, side: 'Preceding' | 'Following'): FrameBound {
  if (value == null || typeof value === 'number' && !Number.isFinite(value)) {
    return native.frameBound(side === 'Preceding' ? 'UnboundedPreceding' : 'UnboundedFollowing');
  }
  if (typeof value === 'number') return value === 0
    ? native.frameBound('CurrentRow')
    : native.frameBound(side, asLiteral(Math.abs(value)));
  if (isExpression(value) || isExpressionHandle(value)) return native.frameBound(side, asNode(value));
  if (value === 'CurrentRow' || value === 'UnboundedPreceding' || value === 'UnboundedFollowing'
    || value === 'BarePreceding' || value === 'BareFollowing') return native.frameBound(value);
  if (value && typeof value === 'object') {
    if ('Preceding' in value && isExpression(value.Preceding)) return native.frameBound('Preceding', value.Preceding);
    if ('Following' in value && isExpression(value.Following)) return native.frameBound('Following', value.Following);
    if ('Value' in value && isExpression(value.Value)) return native.frameBound('Value', value.Value);
  }
  throw new TypeError('Invalid window frame bound.');
}

function buildFrame(kind: WindowFrame['kind'], extent: unknown, exclude: WindowFrame['exclude']): WindowFrame {
  if (!Array.isArray(extent) || extent.length !== 2) throw new TypeError('Window frame extents require two bounds.');
  return native.windowFrame(kind, frameBound(extent[0], 'Preceding'), frameBound(extent[1], 'Following'), exclude);
}

function frame(kind: WindowFrame['kind'], extent: FrameExtent, exclude?: FrameExclude): WindowFrame {
  const exclusion = exclude === 'NO OTHERS' ? 'NoOthers' : exclude === 'CURRENT ROW' ? 'CurrentRow'
    : exclude === 'TIES' ? 'Ties' : exclude === 'GROUP' ? 'Group' : null;
  if (!isParamLike(extent)) return buildFrame(kind, extent, exclusion);
  const marker = bind({
    kind: 'deferred', frame: true, parameters: [extent],
    resolve: (read, template) => {
      if (!template || !('over' in template) || !template.over.frame) throw new TypeError('Dynamic frames require their current native template.');
      const current = template.over.frame;
      return ast.makeExpr('over', native.over({ frame: buildFrame(current.kind, read(extent), current.exclude) }));
    }
  });
  return native.windowFrame(kind, native.frameBound('Preceding', marker), native.frameBound('Following', marker), exclusion);
}

export const frameRows = (extent: FrameExtent, exclude?: FrameExclude): WindowFrame => frame('Rows', extent, exclude);
export const frameRange = (extent: FrameExtent, exclude?: FrameExclude): WindowFrame => frame('Range', extent, exclude);
export const frameGroups = (extent: FrameExtent, exclude?: FrameExclude): WindowFrame => frame('Groups', extent, exclude);
export const currentRow = (): FrameBound => native.frameBound('CurrentRow');
export const preceding = (value: FrameScalar): FrameBound => value == null
  ? native.frameBound('UnboundedPreceding') : native.frameBound('Preceding', asNode(value));
export const following = (value: FrameScalar): FrameBound => value == null
  ? native.frameBound('UnboundedFollowing') : native.frameBound('Following', asNode(value));

function boundExpression(bound: FrameBound | null): SqlExpression | undefined {
  if (!bound || typeof bound === 'string') return;
  if ('Preceding' in bound) return bound.Preceding;
  if ('Following' in bound) return bound.Following;
  return bound.Value;
}

function frameMarkers(frame: WindowFrame | null): SqlExpression[] {
  if (!frame) return [];
  return [boundExpression(frame.start), boundExpression(frame.end)]
    .filter((value): value is SqlExpression => !!value && !!bindingOf(value)?.frame);
}

function resolveFrame(frame: WindowFrame | null, read: ParamReader): WindowFrame | null {
  const markers = frameMarkers(frame);
  if (!markers.length) return frame;
  const binding = bindingOf(markers[0])!;
  if (markers.some(marker => bindingOf(marker) !== binding)) throw new TypeError('A frame cannot combine different dynamic extents.');
  const result = rootExpression(binding.resolve(read, ast.makeExpr('over', native.over({ frame }))));
  if (!('over' in result) || !result.over.frame) throw new TypeError('A dynamic frame must resolve to a native frame.');
  return result.over.frame;
}

function resolveWindowTemplate(read: ParamReader, template?: SqlExpression): SqlExpression {
  if (!template) throw new TypeError('A deferred window requires its current native template.');
  if ('window_function' in template) {
    const { this: func, over: definition, ...options } = template.window_function;
    return native.window(func, native.over({ ...definition, frame: resolveFrame(definition.frame, read) }), options);
  }
  if ('select' in template) return { select: {
    ...template.select,
    windows: template.select.windows?.map(({ name, spec }) => native.namedWindow(name,
      native.over({ ...spec, frame: resolveFrame(spec.frame, read) }))) ?? null
  } };
  throw new TypeError('Unsupported deferred window template.');
}

export function syncWindowTemplate(expression: SqlExpression): void {
  const dynamic = 'window_function' in expression ? frameMarkers(expression.window_function.over.frame).length > 0
    : 'select' in expression && expression.select.windows?.some(window => frameMarkers(window.spec.frame).length > 0);
  if (dynamic) bindTemplate(expression, { kind: 'deferred', parameters: [], resolve: resolveWindowTemplate });
  else if (bindingOf(expression)?.resolve === resolveWindowTemplate) unbindTemplate(expression);
}

export class WindowDef {
  constructor(readonly definition: WindowDefinition = native.over()) {}

  over(name: string): WindowDef {
    return new WindowDef(native.over({ ...this.definition, window_name: native.identifier(name, true).identifier }));
  }

  partitionby(...values: MaybeArray<ExprValue>[]): WindowDef {
    return new WindowDef(native.over({ ...this.definition, partition_by: values.flat().filter(value => value != null).map(asNode) }));
  }

  orderby(...values: MaybeArray<ExprValue>[]): WindowDef {
    return new WindowDef(native.over({ ...this.definition, order_by: ordered(values) }));
  }

  frame(frame: WindowFrame): WindowDef {
    return new WindowDef(native.over({ ...this.definition, frame }));
  }
}

function isNamedWindow(value: unknown): value is NamedWindow {
  if (!value || typeof value !== 'object' || !('name' in value) || !('spec' in value)) return false;
  const name = value.name;
  return !!name && typeof name === 'object' && 'name' in name && typeof name.name === 'string';
}

export function namedWindows(values: readonly WindowInput[]): NamedWindow[] {
  const windows: NamedWindow[] = [];
  for (const value of values.flat()) {
    if (value == null) continue;
    if (isNamedWindow(value)) {
      windows.push(native.namedWindow(value.name, value.spec));
      continue;
    }
    if (Object.getPrototypeOf(value) !== Object.prototype && Object.getPrototypeOf(value) !== null) {
      throw new TypeError('WINDOW requires native named definitions or a plain alias map.');
    }
    for (const [name, input] of Object.entries(value)) {
      const definition = input instanceof WindowDef ? input.definition : input;
      if (!definition || !Array.isArray(definition.partition_by) || !Array.isArray(definition.order_by)) {
        throw new TypeError('Expected a native window definition.');
      }
      windows.push(native.namedWindow(native.identifier(name, true).identifier, definition));
    }
  }
  return windows;
}

export function over(): WindowDef {
  return new WindowDef();
}

export class Window implements SqlExpressionHandle {
  readonly expression: SqlExpression;

  constructor(value: SqlRoot) {
    const expression = rootExpression(value);
    this.expression = 'window_function' in expression ? expression : native.window(expression);
    syncWindowTemplate(this.expression);
  }

  private derive(update: (definition: WindowDef) => WindowDef): Window {
    if (!('window_function' in this.expression)) throw new TypeError('Expected a native window expression.');
    const { this: func, over: definition, ...options } = this.expression.window_function;
    return new Window(native.window(func, update(new WindowDef(definition)).definition, options));
  }

  over(name: string): Window { return this.derive(definition => definition.over(name)); }
  partitionby(...values: MaybeArray<ExprValue>[]): Window { return this.derive(definition => definition.partitionby(...values)); }
  orderby(...values: MaybeArray<ExprValue>[]): Window { return this.derive(definition => definition.orderby(...values)); }
  frame(frame: WindowFrame): Window { return this.derive(definition => definition.frame(frame)); }

  clone(): Window {
    return new Window(cloneExpression(this));
  }

  toString(context: SqlExecutionContext = createExecutionContext()): string {
    return compile([this], context)[0];
  }
}

export const row_number = (): Window => new Window(native.windowCall('row_number'));
export const rank = (): Window => new Window(native.windowCall('rank'));
export const dense_rank = (): Window => new Window(native.windowCall('dense_rank'));
export const percent_rank = (): Window => new Window(native.windowCall('percent_rank'));
export const cume_dist = (): Window => new Window(native.windowCall('cume_dist'));
export const ntile = (buckets: ExprValue): Window => new Window(native.windowCall('n_tile', [asNode(buckets)]));
export const first_value = (value: ExprValue): Window => new Window(native.windowCall('first_value', [asNode(value)]));
export const last_value = (value: ExprValue): Window => new Window(native.windowCall('last_value', [asNode(value)]));
export const nth_value = (value: ExprValue, nth: ExprValue): Window => new Window(native.windowCall('nth_value', [asNode(value), asNode(nth)]));

function offsetWindow(operator: 'lead' | 'lag', value: ExprValue, offset?: ExprValue, fallback?: unknown): Window {
  const args = [asNode(value)];
  if (offset !== undefined || fallback !== undefined) args.push(asNode(offset));
  if (fallback !== undefined) args.push(asNode(fallback));
  return new Window(native.windowCall(operator, args));
}

export const lag = (value: ExprValue, offset?: ExprValue, fallback?: unknown): Window => offsetWindow('lag', value, offset, fallback);
export const lead = (value: ExprValue, offset?: ExprValue, fallback?: unknown): Window => offsetWindow('lead', value, offset, fallback);
