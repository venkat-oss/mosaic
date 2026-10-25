export async function exerciseWidget(source) {
  const url = URL.createObjectURL(new Blob([source], { type: 'text/javascript' }));
  const widget = (await import(url)).default;
  URL.revokeObjectURL(url);
  const wait = async (condition, label) => {
    const start = performance.now();
    while (!condition()) {
      if (performance.now() - start > 15000) throw new Error(`Timed out waiting for ${label}`);
      await new Promise(resolve => requestAnimationFrame(resolve));
    }
  };
  class Model {
    constructor(spec, schema) {
      this.values = { spec, params: {}, preagg_schema: schema };
      this.handlers = new Map();
      this.sent = [];
      this.held = [];
      this.hold = undefined;
      this.saves = 0;
      this.padded = 0;
      this.failures = [];
      this.el = document.body.appendChild(document.createElement('div'));
    }
    get(name) { return this.values[name]; }
    set(name, value) {
      this.values[name] = value;
      this.emit(`change:${name}`);
    }
    save_changes() { ++this.saves; }
    on(name, callback) {
      if (!this.handlers.has(name)) this.handlers.set(name, new Set());
      this.handlers.get(name).add(callback);
    }
    off(name, callback) {
      const callbacks = this.handlers.get(name);
      callbacks?.delete(callback);
      if (!callbacks?.size) this.handlers.delete(name);
    }
    emit(name, ...args) { [...(this.handlers.get(name) ?? [])].forEach(callback => callback(...args)); }
    send(query) {
      this.sent.push(query);
      const hold = this.hold === query.type;
      if (hold) this.hold = undefined;
      window.widgetQuery(query).then(result => {
        const deliver = () => {
          const bytes = result.bytes;
          const buffers = [];
          if (bytes) {
            const padded = new Uint8Array(bytes.length + 16).fill(255);
            padded.set(bytes, 8);
            buffers.push(new DataView(padded.buffer, 8, bytes.length));
            ++this.padded;
          }
          this.emit('msg:custom', { type: query.type, uuid: query.uuid }, buffers);
        };
        if (hold) this.held.push(deliver);
        else deliver();
      }, error => {
        this.failures.push(error.message);
        this.emit('msg:custom', { uuid: query.uuid, error: error.message }, []);
      });
    }
    mark() { return this.el.querySelector('.plot')?.value.marks[0]; }
    async ready(label) {
      await wait(() => this.mark()?.data?.numRows && this.get('params').marker?.value === label, label);
      await this.mark().pending;
    }
    release() { this.held.splice(0).forEach(deliver => deliver()); }
  }
  const spec = (table, marker, rows = [{ x: 0, y: 10 }, { x: 1, y: 20 }, { x: 2, y: 30 }]) => ({
    data: { [table]: rows, [`${table}_other`]: [{ x: 50, y: 60 }] },
    params: Object.fromEntries([
      ['brush', { select: 'crossfilter' }], ['cutoff', 1], ['field', 'x'], ['source', table], ['marker', marker], ['__proto__', 7]
    ]),
    vconcat: [
      { input: 'slider', as: '$cutoff', min: 0, max: 5, step: 1 },
      { input: 'menu', as: '$field', options: ['x', 'y'] },
      { input: 'menu', as: '$source', options: [table, `${table}_other`] },
      { plot: [{ mark: 'dot', data: { from: '$source', filterBy: '$brush' }, x: { sql: '$$field + $cutoff' }, y: 'y' }], width: 260, height: 180 }
    ]
  });
  const first = new Model(spec('widget_first', 'first'), 'widget_first_preagg');
  const second = new Model(spec('widget_second', 'second'), 'widget_second_preagg');
  first.cleanup = widget.render({ model: first, el: first.el });
  second.cleanup = widget.render({ model: second, el: second.el });
  await Promise.all([first.ready('first'), second.ready('second')]);
  const initial = {
    rows: first.mark().data.numRows,
    x: Array.from(first.mark().data.columns.x, Number),
    predicate: first.get('params').brush.predicate,
    ownParam: Object.hasOwn(first.get('params'), '__proto__') && first.get('params')['__proto__'].value,
    isolated: first.mark().coordinator !== second.mark().coordinator && first.mark().sqlOwner !== second.mark().sqlOwner
  };
  const selection = first.mark().filterBy;
  const native = first.mark().sqlOwner;
  const intervalSource = {};
  const pointSource = {};
  selection.update(native.interval(first.mark().channelField('x').field, [1, 3], { source: intervalSource }));
  await selection.pending('value');
  selection.update(native.point('y', 20, { source: pointSource }));
  await selection.pending('value');
  await first.mark().pending;
  const predicate = first.get('params').brush.predicate;
  const filtered = {
    rows: first.mark().data.numRows,
    circles: first.el.querySelectorAll('g[aria-label="dot"] circle').length,
    rowsInOtherWidget: second.mark().data.numRows
  };
  const slider = first.el.querySelector('input[type="range"]');
  slider.value = '2';
  slider.dispatchEvent(new Event('input', { bubbles: true }));
  await wait(() => first.get('params').cutoff?.value === 2 && Number(first.mark().data.columns.x[0]) === 3, 'active selection scalar binding');
  const activeScalarPredicate = first.get('params').brush.predicate;
  const field = first.el.querySelectorAll('select')[0];
  field.value = 'y';
  field.dispatchEvent(new Event('input', { bubbles: true }));
  await wait(() => first.get('params').field?.value === 'y' && first.mark().data.numRows === 0, 'active selection identifier binding');
  const activeIdentifierPredicate = first.get('params').brush.predicate;
  const activeIdentifierRows = first.mark().data.numRows;
  selection.update(native.clear(intervalSource));
  await selection.pending('value');
  selection.update(native.clear(pointSource));
  await selection.pending('value');
  await first.mark().pending;
  const empty = first.get('params').brush.predicate;
  const sourceInput = first.el.querySelectorAll('select')[1];
  sourceInput.value = 'widget_first_other';
  sourceInput.dispatchEvent(new Event('input', { bubbles: true }));
  await wait(() => first.mark().data.numRows === 1 && Number(first.mark().data.columns.x[0]) === 62, 'source binding');
  const bindings = { x: Number(first.mark().data.columns.x[0]), rows: first.mark().data.numRows, otherX: Number(second.mark().data.columns.x[0]) };
  first.cleanup();
  const afterCleanup = first.sent.length;
  first.set('spec', spec('widget_ignored', 'ignored'));
  await new Promise(resolve => requestAnimationFrame(resolve));
  const cleanup = { handlers: first.handlers.size, unchanged: first.sent.length === afterCleanup };
  const otherSelection = second.mark().filterBy;
  otherSelection.update(second.mark().sqlOwner.point('y', 20, { source: {} }));
  await otherSelection.pending('value');
  await second.mark().pending;
  const otherRows = second.mark().data.numRows;

  const a = spec('widget_stale_a', 'a');
  const b = spec('widget_stale_b', 'b', [{ x: 100, y: 200 }]);
  const stale = new Model(a, 'widget_stale_preagg');
  stale.hold = 'exec';
  stale.cleanup = widget.render({ model: stale, el: stale.el });
  await wait(() => stale.held.length === 1, 'held first spec');
  stale.set('spec', b);
  stale.set('spec', a);
  stale.release();
  await stale.ready('a');
  const repeated = {
    rows: stale.mark().data.numRows,
    aExecutions: stale.sent.filter(query => query.type === 'exec' && query.sql.includes('widget_stale_a')).length,
    bExecutions: stale.sent.filter(query => query.type === 'exec' && query.sql.includes('widget_stale_b')).length,
    saves: stale.saves
  };
  const oldMark = stale.mark();
  stale.hold = 'arrow';
  oldMark.coordinator.clear({ clients: false });
  oldMark.requestQuery();
  await wait(() => stale.held.length === 1, 'held old Arrow result');
  stale.set('spec', b);
  stale.release();
  await stale.ready('b');
  const replacement = { rows: stale.mark().data.numRows, x: Number(stale.mark().data.columns.x[0]), oldDisconnected: oldMark.coordinator === null };
  stale.hold = 'arrow';
  stale.mark().coordinator.clear({ clients: false });
  stale.mark().requestQuery();
  await wait(() => stale.held.length === 1, 'held cleanup Arrow result');
  stale.cleanup();
  stale.release();
  await new Promise(resolve => requestAnimationFrame(resolve));
  second.cleanup();
  const failed = new Model({ ...spec('widget_recovered', 'recovered'), data: { widget_recovered: 'SELECT nonexistent_widget_column' } }, 'widget_recovered_preagg');
  failed.cleanup = widget.render({ model: failed, el: failed.el });
  await wait(() => failed.failures.length > 0, 'query error response');
  failed.set('spec', spec('widget_recovered', 'recovered'));
  await failed.ready('recovered');
  const recovered = { failures: failed.failures.length, rows: failed.mark().data.numRows };
  failed.cleanup();
  const closed = new Model(spec('widget_closed', 'closed'), 'widget_closed_preagg');
  closed.hold = 'exec';
  closed.cleanup = widget.render({ model: closed, el: closed.el });
  await wait(() => closed.held.length === 1, 'cleanup during exec');
  closed.cleanup();
  closed.release();
  await new Promise(resolve => requestAnimationFrame(resolve));
  return {
    initial, filtered, predicate, activeScalarPredicate, activeIdentifierPredicate, activeIdentifierRows, empty, bindings, cleanup, otherRows, repeated, replacement, recovered,
    finalHandlers: [second.handlers.size, stale.handlers.size, failed.handlers.size, closed.handlers.size],
    closedBeforeRender: closed.el.childElementCount === 0,
    padded: first.padded + second.padded + stale.padded
  };
}
