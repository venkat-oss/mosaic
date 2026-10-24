import { afterEach, describe, it, expect, vi } from 'vitest';
import { throttle } from '../src/util/throttle.js';
import { QueryResult } from '../src/util/query-result.js';

async function wait() {
  return new Promise<void>(resolve => setTimeout(resolve));
}

describe('throttle', () => {
  afterEach(() => vi.unstubAllGlobals());

  it('debounces changing events to the latest event in each frame', async () => {
    const frames: FrameRequestCallback[] = [];
    vi.stubGlobal('requestAnimationFrame', (callback: FrameRequestCallback) => frames.push(callback));
    const callback = vi.fn(async (_event?: string) => {});
    const throttled = throttle(callback, true);

    throttled('one');
    throttled('two');
    throttled('three');
    expect(frames).toHaveLength(1);
    frames.shift()!(0);
    await wait();
    expect(callback.mock.calls).toEqual([['three']]);

    throttled();
    expect(frames).toHaveLength(1);
    frames.shift()!(0);
    await wait();
    expect(callback.mock.calls).toEqual([['three'], [undefined]]);
  });

  it('retains only the latest frame event while a callback is pending', async () => {
    const frames: FrameRequestCallback[] = [];
    vi.stubGlobal('requestAnimationFrame', (callback: FrameRequestCallback) => frames.push(callback));
    const requests: QueryResult[] = [];
    const callback = vi.fn((_event?: string) => {
      const request = new QueryResult();
      requests.push(request);
      return request;
    });
    const throttled = throttle(callback, true);
    throttled('one');
    frames.shift()!(0);
    throttled('two');
    throttled('three');
    frames.shift()!(0);
    expect(callback.mock.calls).toEqual([['one']]);
    requests[0].fulfill('done');
    await wait();
    expect(callback.mock.calls).toEqual([['one'], ['three']]);
    requests[1].fulfill('done');
  });

  it('should throttle successful query results', async () => {
    const requests: QueryResult[] = [];
    const throttled = throttle(() => {
      const req = new QueryResult();
      requests.push(req);
      return req;
    });

    throttled();
    await wait();
    expect(requests.length).toBe(1);

    throttled();
    await wait();
    expect(requests.length).toBe(1);

    requests[0].fulfill('fulfilled');
    await wait();

    expect(requests.length).toBe(2);
  });

  it('should throttle unsuccessful query results', async () => {
    const requests: QueryResult[] = [];
    const throttled = throttle(() => {
      const req = new QueryResult();
      requests.push(req);
      return req;
    });

    throttled();
    await wait();
    expect(requests.length).toBe(1);

    throttled();
    await wait();
    expect(requests.length).toBe(1);

    requests[0].reject('rejected');
    await wait();

    expect(requests.length).toBe(2);
  });
});
