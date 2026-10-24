# Client

The `MosaicClient` class provides a base class for client implementation.
Clients are responsible for publishing their data needs and performing data processing tasks&mdash;such as rendering a visualization&mdash;once data is provided by the [coordinator](./coordinator).

If you are interested in creating your own Mosaic clients, see the [Mosaic GitHub repository](https://github.com/uwdata/mosaic).
For concrete examples, start with the source code of [Mosaic inputs](https://github.com/uwdata/mosaic/tree/main/packages/vgplot/inputs/src).
If you are creating clients for web frameworks such as React, Svelte, or Vue, see the [web clients](/web-clients/) documentation.

## constructor

`new MosaicClient(filterSelection, sqlOwner = null)`

Create a new client instance. If provided, the [Selection](./selection)-valued _filterSelection_ argument will be exposed as the client's [`filterBy`](#filterby) property.
For a native client, pass the coordinator's `NativeSqlContext` as _sqlOwner_ and
use selections from that same context.

## filterBy

`client.filterBy`

Property getter for the Selection that should filter this client.
The [coordinator](./coordinator) uses this property to provide automatic updates to the client upon selection changes.

## filterStable

`client.filterStable`

Property getter for a Boolean value indicating if the client query can be safely optimized using a pre-aggregated materialized view.
This property should return true if changes to the `filterBy` selection do not change the groupby (e.g., binning) values of the client query.

The `MosaicClient` base class will always return `true`.
Subclasses should override the property getter to provide more nuanced results as needed.

## prepare

`client.prepare()`

Prepare the client before its first data query. Override this asynchronous method
to load field metadata or other prerequisites. The base method does nothing.
Call `queryFieldInfo(coordinator, requests)` to request SQL/JavaScript types,
nullability and optional `count`, `nulls`, `distinct`, `min` or `max` statistics.

Asynchronous preparation can be superseded by reinitialization. Capture
`this.pending` before awaiting metadata and check that it is still current before
assigning prepared state:

```js
async prepare() {
  const pending = this.pending;
  const info = await queryFieldInfo(this.coordinator, this.requests);
  if (this.pending !== pending) return;
  this.info = info;
}
```

For a native DuckDB coordinator, requests accept a native relation and expression
as `table` and `column`. Results retain those original references in request order.
An optional third argument, `{ query }`, supplies the actual projection/grouping
scope for aggregate or window expressions; request expressions must refer to its
authored projections. Aggregate statistics then summarize that query's output.
Metadata for an empty relation still reports its schema. A sole `column: '*'`
request returns the relation's columns by backend name.

List expansion statistics summarize the expanded rows. An individual field
request that expands into multiple columns rejects rather than guessing its output.

## query

`client.query(filter)`

Return a query specifying the data needed by this client, incorporating any requested _filter_ criteria.
If provided, the _filter_ argument should consist of Boolean-valued SQL predicates, suitable for inclusion in a `WHERE` clause.

The `MosaicClient` base class simply returns `null`.
Subclasses should override this method to provide a query, typically constructed using [Mosaic SQL builder](/sql/) utilities.

## queryPending

`client.queryPending()`

Called by the [coordinator](./coordinator) to inform the client that a query is pending.
This method should return the current client instance.

The `MosaicClient` base class does nothing here.
Subclasses should override this method as needed.

## queryResult

`client.queryResult(data)`

Called by the [coordinator](./coordinator) to return query results in the form of a _data_ table. This method should return the current client instance.

The `MosaicClient` base class does nothing here.
Subclasses should override this method as needed.

## queryError

`client.queryError(error)`

Called by the [coordinator](./coordinator) to report that an _error_ occurred during query processing. This method should return the current client instance.

The coordinator reports the error through its configured logger; the base client
method does nothing.
Subclasses should override this method as needed.

## update

`client.update()`

Requests that a client update using its current data, for example to (re-)render an interface component, and returns the current client instance.
Called by the [coordinator](./coordinator) after returning data via the [`queryResult`](#queryresult) method.

The `MosaicClient` base class does nothing here.
Subclasses should override this method as needed.

## requestQuery

`client.requestQuery(query)`

Requests that the [coordinator](./coordinator) execute a query for this client, and returns a Promise that resolves upon query completion or error.
If an explicit query is not provided, the client [`query`](#query) method will be called, filtered by the current [`filterBy`](#filterby) selection.
Results and errors from superseded reads do not overwrite the current client.

## initialize

`client.initialize()`

Re-run preparation and request data for a connected, enabled client. Queued reads
from its previous preparation are canceled. A newer initialization supersedes an
older preparation's continuation.

## pending

`client.pending`

Promise for the current preparation or data update, including asynchronous
`update()` work. Current preparation errors reject this promise.

## destroy

`client.destroy()`

Disable and disconnect the client, canceling its queued reads and ignoring late
responses.

## requestUpdate

`client.requestUpdate()`

Request that the [coordinator](./coordinator) perform a throttled update of this client using the default query provided by the [`query`](#query) method.
Unlike [`requestQuery`](#requestquery), for which every call will result in an executed query, multiple calls to `requestUpdate` may be consolidated.
