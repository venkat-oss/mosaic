export async function renderGridStarter({spec, code, mode, uri = window.__MOSAIC_DATABASE_URI, wrapperURL = undefined, reactive}) {
  const moduleURL = name => '/packages/' + name + '/src/index.js';
  const vg = await import(moduleURL('vgplot/vgplot'));
  const core = await import(moduleURL('mosaic/core'));
  const specAPI = await import(moduleURL('vgplot/spec'));
  const queries = [];
  const errors = [];
  const connector = new core.RestConnector(uri ? {uri} : {});
  const query = connector.query.bind(connector);
  connector.query = request => {
    queries.push(String(request.sql));
    return query(request);
  };
  const coordinator = new core.Coordinator(connector, {logger: null});
  coordinator.logger({...coordinator.logger(), error: error => errors.push({name: error.name, message: error.message})});
  const previous = core.coordinator();
  core.coordinator(coordinator);
  const extensions = wrapperURL ? await import(wrapperURL) : {};
  const api = vg.createAPIContext({coordinator, extensions});
  try {
    await coordinator.exec('DROP TABLE IF EXISTS grid_data');
    let element;
    let params;
    if (mode === 'ast') {
      ({element, params} = await specAPI.astToDOM(specAPI.parseSpec(spec), {api}));
    } else {
      if (mode === 'esm') code = specAPI.astToESM(specAPI.parseSpec(spec), {imports: new Map()});
      let interpolator;
      if (code.includes('interpolateNearest')) {
        const interpolationURL = '/packages/vgplot/plot/test/util/grid-interpolator.js';
        ({interpolateNearest: interpolator} = await import(interpolationURL));
      }
      const body = code.replace(/^import .*$/gm, '').replace(/^export const /gm, 'const ').replace('export default ', 'const element = ');
      ({element, params} = await new Function('vg', 'interpolateNearest', 'return (async () => {' + body + '\nreturn {element, params: new Map([typeof resolution !== "undefined" ? ["resolution", resolution] : typeof $resolution !== "undefined" ? ["resolution", $resolution] : [], typeof bandwidth !== "undefined" ? ["bandwidth", bandwidth] : typeof $bandwidth !== "undefined" ? ["bandwidth", $bandwidth] : []].filter(entry => entry.length))};})();')(api, interpolator));
    }
    document.getElementById('container').replaceChildren(element);
    await new Promise(resolve => requestAnimationFrame(resolve));
    const pending = await Promise.allSettled([...coordinator.clients].map(client => client.pending));
    await new Promise(resolve => requestAnimationFrame(resolve));
    const instance = element.value.marks[0];
    const read = async () => {
      const images = [...element.querySelectorAll('image')];
      let painted = false;
      if (images.length) {
        const image = new Image();
        image.src = images[0].getAttribute('href');
        await image.decode();
        const canvas = document.createElement('canvas');
        canvas.width = canvas.height = 5;
        const context = canvas.getContext('2d');
        context.drawImage(image, 0, 0, 5, 5);
        painted = [...context.getImageData(0, 0, 5, 5).data].some((value, index) => index % 4 === 3 && value > 0);
      }
      return {
        bins: instance.bins,
        rows: instance.data?.numRows,
        groups: [...element.querySelectorAll('g[aria-label]')].map(group => [group.getAttribute('aria-label'), group.children.length]),
        images: images.length,
        source: images[0]?.getAttribute('href'),
        painted,
        text: [...element.querySelectorAll('g[aria-label="text"] text')].map(node => node.textContent),
        finite: !/NaN|Infinity/.test(element.outerHTML),
      };
    };
    const before = await read();
    const requestCount = queries.length;
    let after;
    if (reactive) {
      params.get(reactive.name).update(reactive.value);
      await new Promise(resolve => requestAnimationFrame(resolve));
      await Promise.all([...coordinator.clients].map(client => client.pending));
      await new Promise(resolve => requestAnimationFrame(resolve));
      after = await read();
    }
    return {
      before, after, errors,
      statuses: pending.map(result => result.status),
      failures: pending.filter(result => result.status === 'rejected').map(result => ({name: result.reason.name, message: result.reason.message})),
      queriedAgain: queries.length > requestCount,
      nativeInterpolation: typeof instance.interpolate === 'function',
    };
  } finally {
    coordinator.clear();
    core.coordinator(previous);
  }
}
