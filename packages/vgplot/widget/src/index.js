import './compiler.js';
import { Coordinator, NativeSqlContext, isSelection } from '@uwdata/mosaic-core';
import { and, isExpression } from '@uwdata/mosaic-sql/native';
import { parseSpec, astToDOM } from '@uwdata/mosaic-spec';
import './style.css';
import { v4 as uuidv4 } from 'uuid';

/**
 * @typedef {Record<string, {value: unknown, predicate?: string}>} Params
 *
 * @typedef Model
 * @property {import('@uwdata/mosaic-spec').Spec} spec
 * @property {string} preagg_schema
 * @property {Params} params
 */

/** @type {import('anywidget/types').AnyWidget<Model>} */
export default {
  render(view) {
    view.el.classList.add('mosaic-widget');
    const native = new NativeSqlContext();
    let disposed = false;
    /** @type {Promise<Awaited<ReturnType<typeof astToDOM>> | null> | undefined} */
    let pending;
    /** @type {Array<() => void>} */
    let paramListeners = [];
    /** @type {Map<string, {query: import('@uwdata/mosaic-core').ConnectorQueryRequest, startTime: number, resolve: (value: any) => void, reject: (reason?: any) => void}>} */
    const openQueries = new Map();
    const canceled = () => new DOMException('Widget query canceled.', 'AbortError');

    /** @type {import('@uwdata/mosaic-core').Connector} */
    const connector = {
      /** @param {import('@uwdata/mosaic-core').ConnectorQueryOptions} [options] */
      query(query, options = {}) {
        const { signal } = options;
        if (disposed || signal?.aborted) return Promise.reject(signal?.reason ?? canceled());
        return new Promise((resolve, reject) => {
          const uuid = uuidv4();
          const settle = (callback, value) => {
            if (!openQueries.delete(uuid)) return;
            signal?.removeEventListener('abort', abort);
            callback(value);
          };
          const abort = () => entry.reject(signal?.reason ?? canceled());
          const entry = {
            query, startTime: performance.now(),
            resolve: value => settle(resolve, value),
            reject: error => settle(reject, error)
          };
          openQueries.set(uuid, entry);
          signal?.addEventListener('abort', abort, { once: true });
          try { view.model.send({ ...query, uuid }); }
          catch (error) { entry.reject(error); }
        });
      }
    };
    const coordinator = new Coordinator(connector, { native });
    const logger = coordinator.logger();
    if (!view.model.get('preagg_schema')) view.model.set('preagg_schema', coordinator.preaggregator.schema);
    const configureCoordinator = () => { coordinator.preaggregator.schema = view.model.get('preagg_schema'); };
    configureCoordinator();

    /** @param {Awaited<ReturnType<typeof astToDOM>>['params']} params */
    function serializeParams(params) {
      /** @type {import('@uwdata/mosaic-sql/native').SqlRoot[]} */
      const roots = [];
      const active = [];
      const entries = Array.from(params, ([name, param]) => {
        if (!isSelection(param)) return [name, { value: param.value }];
        if (param.owner !== native) throw new TypeError('Widget predicate export requires its own native SQL context.');
        const predicate = param.predicate(undefined);
        const predicates = (Array.isArray(predicate) ? predicate : [predicate]).filter(value => value != null);
        if (!predicates.every(isExpression)) throw new TypeError('Widget predicates require native SQL expressions.');
        const entry = { value: param.value, predicate: '' };
        if (predicates.length) {
          active.push(entry);
          roots.push(and(predicates));
        }
        return [name, entry];
      });
      const statements = native.compileBatch(roots);
      if (statements.length !== active.length) throw new Error('Widget predicate compilation must produce one expression per selection.');
      statements.forEach((statement, index) => { active[index].predicate = statement; });
      return Object.freeze(Object.fromEntries(entries));
    }

    const detachParams = () => { paramListeners.forEach(remove => remove()); paramListeners = []; };
    let requestedSpecJSON;
    function updateSpec() {
      if (disposed) return;
      const spec = view.model.get('spec');
      const serialized = JSON.stringify(spec);
      if (serialized === requestedSpecJSON) return;
      requestedSpecJSON = serialized;
      detachParams();
      coordinator.clear();
      const request = Promise.resolve().then(() => pending === request && !disposed
        ? astToDOM(parseSpec(spec), { coordinator }) : null);
      pending = request;
      request.then(dom => {
        if (!dom || disposed || pending !== request) return;
        view.el.replaceChildren(dom.element);
        const publish = () => {
          if (disposed || pending !== request) return;
          view.model.set('params', serializeParams(dom.params));
          view.model.save_changes();
        };
        for (const param of dom.params.values()) {
          param.addEventListener('value', publish);
          paramListeners.push(() => param.removeEventListener('value', publish));
        }
        publish();
      }).catch(error => {
        if (disposed || pending !== request) return;
        requestedSpecJSON = undefined;
        logger.error(error);
      });
    }

    function receive(msg, buffers) {
      const query = openQueries.get(msg.uuid);
      if (!query) return;
      logger.group(`query ${msg.uuid}`);
      logger.log(query.query.sql, (performance.now() - query.startTime).toFixed(1));
      if (msg.error) {
        query.reject(new Error(msg.error));
        logger.error(msg.error);
      } else if (msg.type === 'arrow') {
        const buffer = buffers?.[0];
        if (buffer instanceof ArrayBuffer) query.resolve(buffer);
        else if (ArrayBuffer.isView(buffer)) query.resolve(new Uint8Array(buffer.buffer, buffer.byteOffset, buffer.byteLength));
        else query.reject(new TypeError('Widget Arrow response requires a binary buffer.'));
      } else query.resolve(undefined);
      logger.groupEnd();
    }

    view.model.on('change:spec', updateSpec);
    view.model.on('change:preagg_schema', configureCoordinator);
    view.model.on('msg:custom', receive);
    updateSpec();

    return () => {
      disposed = true;
      pending = undefined;
      detachParams();
      view.model.off('change:spec', updateSpec);
      view.model.off('change:preagg_schema', configureCoordinator);
      view.model.off('msg:custom', receive);
      coordinator.clear();
      for (const query of openQueries.values()) query.reject(canceled());
    };
  }
};
