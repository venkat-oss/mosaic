# Window Functions

SQL window function expressions.

## Window expressions {#native-window-preview}

Window helpers from `@uwdata/mosaic-sql` construct Polyglot trees. Window handles retain the high-level `.over()`,
`.partitionby()`, `.orderby()` and `.frame()` chains, including named windows.
Use `frameRows`, `frameRange` or `frameGroups` to define a frame.

``` js
import { Query, frameRows, row_number, sum } from '@uwdata/mosaic-sql';

const query = Query.from('sales').select('day', {
  row: row_number().orderby('day'),
  total: sum('amount').orderby('day').frame(frameRows([null, 0]))
});
```

An implicit extent uses absolute distances: its first bound is PRECEDING and
its second is FOLLOWING. Zero denotes CURRENT ROW; null or a non-finite value
denotes an unbounded extent on that side. `preceding()` and `following()` set
the direction explicitly. Live frame Params resolve into a submission snapshot,
including frames in named WINDOW definitions; cloning retains those live
bindings while isolating editable query clauses.

## Window {#window-node}

The `Window` handle exposes its canonical window expression through
`.expression`. Create one with [`row_number()`](#row_number), [`lag()`](#lag) or
an aggregate's window methods. Its modifiers return new handles, leaving the
original unchanged. `clone()` copies its native expression tree and retains live
frame bindings; modifiers on the clone leave the original window unchanged.
`over()` constructs a `WindowDef` for use in named
`Query.window` definitions.

### over

`Window.over(name)`

Provide the _name_ of a window definition for this function and returns a new Window handle.
The window should be defined separately in an issued query, for example using the [Query.window](./queries#window) method.

### partitionby

`Window.partitionby(...expressions)`

Provide one or more _expressions_ by which to partition this window function and returns a new Window handle.

### orderby

`Window.orderby(...expressions)`

Provide one or more _expressions_ by which to sort this window function and returns a new Window handle.

### frame

`Window.frame(definition)`

Return a new window with the given frame definition. Use `frameRows(extent)`,
`frameRange(extent)` or `frameGroups(extent)`, with an optional second argument
for `EXCLUDE`: `'NO OTHERS'`, `'CURRENT ROW'`, `'TIES'` or `'GROUP'`.

ROWS counts individual rows; RANGE includes peers according to the ordering;
GROUPS counts peer groups. The two-element extent specifies preceding and
following distances. Zero denotes CURRENT ROW, and null or a non-finite value
denotes an unbounded extent on that side. The extent may be a live Param.

## row_number {#row_number}

`row_number()`

Create a window function that returns the number of the current row
within the partition, counting from 1.

## rank

`rank()`

Create a window function that returns the rank of the current row with gaps.
This is the same as the row_number of its first peer.

## dense_rank {#dense_rank}

`dense_rank()`

Create a window function that returns the rank of the current row without gaps,
The function counts peer groups.

## percent_rank {#percent_rank}

`percent_rank()`

Create a window function that returns the relative rank of the current row.
Equal to (rank() - 1) / (total partition rows - 1).

## cume_dist {#cume_dist}

`cume_dist()`

Create a window function that returns the cumulative distribution.
(number of preceding or peer partition rows) / total partition rows.

## ntile

`ntile(num_buckets)`

Create a window function that returns an integer ranging from 1 to _num\_buckets_,
dividing the partition as equally as possible.

## lag

`lag(expression, offset, default)`

Create a window function that returns the _expression_ evaluated at the row
that is _offset_ rows before the current row within the partition.
If there is no such row, instead return _default_ (which must be of the same
type as the expression). Both offset and default are evaluated with respect
to the current row. If omitted, offset defaults to 1 and default to null.

## lead

`lead(expression, offset, default)`

Create a window function that returns the _expression_ evaluated at the row
that is _offset_ rows after the current row within the partition.
If there is no such row, instead return _default_ (which must be of the same
type as the expression). Both offset and default are evaluated with respect
to the current row. If omitted, offset defaults to 1 and default to null.

## first_value {#first_value}

`first_value(expression)`

Create a window function that returns the _expression_ evaluated at the row
that is the first row of the window frame.

## last_value {#last_value}

`last_value(expression)`

Create a window function that returns the _expression_ evaluated at the row
that is the last row of the window frame.

## nth_value {#nth_value}

`nth_value(expression, nth)`

Create a window function that returns the _expression_ evaluated at the
_nth_ row of the window frame (counting from 1), or null if no such row.
