import { MosaicClient, Selection } from '../../src/index.js';
import type { FilterExpr, Query } from '@uwdata/mosaic-sql';

export class TestClient extends MosaicClient {
  private _query: Query | null;

  constructor(
    query: Query | null,
    filterBy?: Selection,
    callbacks: Record<string, unknown> = {}
  ) {
    super(filterBy);
    this._query = query;
    Object.assign(this, callbacks);
  }

  query(filter: FilterExpr = []): Query | null {
    return this._query?.clone().where(filter) || null;
  }
}
