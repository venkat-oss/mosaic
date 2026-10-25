# PostgreSQL Connector

`@uwdata/mosaic-postgres` executes Mosaic queries against PostgreSQL from Node.js
and returns Arrow IPC. Install it alongside `@uwdata/mosaic-core` and
`@uwdata/mosaic-sql`. Core exposes the same class through its optional
`@uwdata/mosaic-core/postgres-connector` entry. Browser applications still need a
server or gateway; this package opens PostgreSQL connections directly.

## Queries and selections

This example creates a temporary table, queries it, and updates the result through
a selection. The coordinator automatically selects PostgreSQL generation and
keeps DuckDB as the source semantics for Mosaic's authoring helpers.

```js
import { Coordinator, makeClient, Selection, clausePoint } from '@uwdata/mosaic-core';
import { PostgresConnector } from '@uwdata/mosaic-core/postgres-connector';
import { Query, count, createTable, float64, literal, sum } from '@uwdata/mosaic-sql';

const connector = await PostgresConnector.make(process.env.DATABASE_URL);
const coordinator = new Coordinator(connector);
const selection = Selection.intersect();
const source = {};

try {
  await coordinator.exec(createTable('mosaic_orders', Query.unionAll(
    Query.select({ category: literal('books'), amount: float64(10) }),
    Query.select({ category: literal('music'), amount: float64(20) }),
    Query.select({ category: literal('books'), amount: float64(15) })
  ), { temp: true }));

  const client = makeClient({
    coordinator,
    selection,
    query: filter => Query.from('mosaic_orders')
      .select({ rows: count(), total: sum('amount') }).where(filter ?? []),
    queryResult: table => console.log(Array.from(table))
  });
  await client.pending;

  selection.update(clausePoint('category', 'books', { source }));
  await selection.pending('value');
  client.destroy();
} finally {
  coordinator.clear();
  await connector.close();
}
```

The two results contain three orders totaling 45, then two orders totaling 25.
Live scalar and column parameters resolve at submission. Grouping, scalar/null
filters, ordering, limits, aggregates and window functions use the same native
query path as DuckDB. PostgreSQL preaggregation is disabled by default; explicitly
enabling it raises an error. Query caching and compatible consolidation remain
available.

Alias-dependent `QUALIFY` requires a complete, explicitly named input projection
so the compiler can distinguish window aliases from physical columns:

```js
const query = Query.from(Query.from('mosaic_orders').select({ source_amount: 'amount' }))
  .select({ amount: 'source_amount', rank: row_number().orderby('source_amount') })
  .qualify(gt('rank', 1)).orderby('amount');
```

Import `row_number` and `gt` from `@uwdata/mosaic-sql` for this example.
Unresolved alias collisions reject before execution. DuckDB file readers,
extension setup, spatial operations and schema-dependent column expansion are
outside this connector's supported operations.

## Connection lifecycle

`await PostgresConnector.make(config)` connects both owned sessions and completes
setup. The constructor also accepts a connection string; when constructing it
directly, await its `ready` promise. Connection options follow
[`pg.Client`](https://node-postgres.com/apis/client), with Mosaic retaining control
of type parsers, text protocol and client query timeouts. Use the coordinator's
`timeout` option for cancellation.

`query({ type: 'arrow', sql }, options)` returns a `Uint8Array` containing one
result's Arrow IPC. `query({ type: 'exec', sql }, options)` executes ordered SQL
and returns no data. These direct connector calls accept backend SQL. Use native
query expressions through the coordinator; opaque coordinator SQL strings require
matching source and target dialects and do not undergo transpilation.

Each connector serializes its data session. An abort signal cancels database work
through its control session, and the next request waits for cancellation to finish.
`await connector.close()` cancels pending work and closes both sessions. A
coordinator clears its own client/cache state; close its connector separately.

## Arrow types and metadata

Result types come from PostgreSQL field OIDs and type modifiers, including empty
results. Base-table nullability comes from `pg_catalog`; outer joins, grouped
queries and expressions retain conservative nullable fields. Coordinator submission supplies the safe
base-projection hint locally, without adding fields to HTTP query payloads.

- `bigint` uses Arrow Int64; timestamps use microsecond Arrow timestamps.
- Declared `numeric(p,s)` uses Decimal128 or Decimal256. Negative scales use the
  value-preserving Arrow type `Decimal(p-s,0)`: `NUMERIC(5,-2)` returns `12300` as
  `Decimal(7,0)`. The original SQL type and type modifier remain field metadata.
- Unconstrained numerics, such as PostgreSQL's `AVG(integer)` result, retain exact
  decimal text and SQL type metadata. Precision and scale are never inferred from
  observed rows.
- Booleans, signed integers, OIDs, floats, text, UUID, JSON text, bytea, dates and
  time values have explicit mappings. Unsupported OIDs, non-finite fixed decimals,
  unrepresentable timestamps and decimal precision beyond 76 reject explicitly.

Use `decodeIPC(bytes, { useBigInt: true, useBigIntTimestamp: true,
useDecimalInt: true })` for exact integer representations outside a coordinator,
or pass these extraction options as the coordinator's `ipc` option. Decimal
integers are scaled according to the Arrow field's scale; the default numeric and
Date extraction can lose precision.

The database integration test uses PostgreSQL 18.6 with a pinned container digest:

```sh
bazelisk test //packages/server/postgres:check
bazelisk test //packages/server/postgres:integration_test
```
