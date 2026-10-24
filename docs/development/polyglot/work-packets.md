# Native Polyglot implementation packets

These packets implement the [target architecture](./index.md). P00 is complete
on the isolated private Polyglot branch `mosaic-native-ast` at
`d75e21fccecd6d7362b263055d957ee711d318c9`. Its built SDK is distributed as a
[public Mosaic release asset](https://github.com/venkat-oss/mosaic/releases/tag/polyglot-sdk-d75e21fccecd6d7362b263055d957ee711d318c9); Polyglot source remains private.
P01–P07 implement compiler loading, the reactive Slider slice, relational queries,
consolidation, aggregates, windows, native DuckDB preaggregation and plot,
collection, loading and spatial consumers. Installed SQL/core consumers execute
these paths against DuckDB and Arrow. Startup
measurements are recorded in the architecture. Mosaic's default SQL runtime still
uses its existing implementation. Native plots execute histograms, connected-line
M4, density, statistical, grid, raster and geographic queries through metadata,
selection, Arrow and rendering. P08–P10 remain: expression/spec/input/widget
integration, the default switch, compiler retirement and the PostgreSQL connector.

Each packet includes its runtime consumer, meaningful tests, documentation and
deletion work. Use normal source changes and reviewable commits. Do not create a
parallel progress registry, result manifest, comparison service or migration CLI.

## Order and parallel work

| Phase | Packet | Depends on | Result |
| --- | --- | --- | --- |
| Compiler prerequisite | P00 | — | Fix our Polyglot fork: AST-in compilation, lowering and diagnostics |
| Foundation | P01 | P00 | Pinned SDK, native data helpers, working Node/browser/widget packaging |
| First vertical slice | P02 | P01 | Reactive Slider and filtered query execute native AST against DuckDB |
| Core optimizations | P03 | P02 | Relational analysis and query consolidation |
| Core optimizations | P04 | P03 | Aggregates, windows, lineage and preaggregation |
| Consumer families | P05 | P04 | Numeric/temporal/binning and actual plot interactions |
| Consumer families | P06 | P04 and P05 common Mark commit | Collections, stars and nested-expression consumers |
| Consumer families | P07 | P04 and P05 common Mark commit | Loading, metadata and spatial consumers |
| Authoring integration | P08 | P05, P06, P07 | Raw input, spec/Python/widget and all input clients |
| Retirement | P09 | P08 | Native default; old SQL AST and renderer deleted |
| Additional backend | P10 | P09 | One tested PostgreSQL Node connector and bounded feature support |

P05 first lands a small shared native `Mark.js`/clause-construction commit after
P04. The remaining P05 work and P06/P07 can then develop and land in parallel.
Each owns the files named below; P06/P07 consume that common Mark contract.
P08 owns shared spec-expression integration, P09 owns root export removal and the default
switch. A family may update its own CUE producer, but one integration commit owns
regeneration of shared generated files. Do not have parallel branches hand-edit
`vgplot/src/api.js` or generated spec declarations.

New file and target names below are proposed implementation locations. Existing
commands are identified separately from targets that a packet must add.

## Shared implementation rules

- The normal `@uwdata/mosaic-sql` API stays on its current implementation until
  P09. P01 introduces a temporary declared `/native` compiler entry; P02 extends
  it with the query facade for migrated clients and tests. P09 redirects the root
  facade to native implementations and removes
  the temporary subpath and pilot selection code.
- Introduce one `native/legacy-input.ts` adapter in P02 for legacy expressions
  entering a native query, especially existing selection predicates. It converts
  structure once with a shared identity memo. It has no SQL-string roundtrip, no
  native-to-legacy conversion and no retry through the old renderer. A native
  expression must not escape into an unmigrated legacy query.
- Native pilot coordinators have native clause-construction workers and isolated
  Selection graphs. Migrate their point/interval/match producers with the slice.
  Never pass native fields to legacy `asNode` or clause helpers. If a pilot admits
  an external legacy clause, normalize it once with a context-owned memo shared
  by fields, predicate, query and preaggregator. Reject accidental mixed graphs;
  P09 moves the remaining producers and removes this restriction and adapter.
- New helpers build `ast.Expression` data through small native factories. Do not
  use consumable SDK builders as reusable Mosaic query state or copy the entire
  Polyglot type union into Mosaic. Do not build SQL strings merely to parse them
  back into native nodes.
- Preserve the mutable public query facade and parameter identity. New native
  inspection functions replace `_select` and similar accesses. No facade stores
  both native clauses and parallel legacy clause arrays.
- Execute the DuckDB path throughout the migration. Additional target generation
  has a declared support boundary and rejects unsupported operations. Never label
  an unexecuted dialect as a fully supported Mosaic database.
- Delete leaf legacy code when its last consumer moves. Shared deletions below
  are assigned to P09 because legacy clients still need them before that switch.
  Rewrite public helper implementations in place; do not delete still-supported
  API names just because their old implementation is removed.

## P00 — Provide native compilation in Polyglot

**Scope:** [our Polyglot fork](https://github.com/venkat-oss/polyglot) and the
complete SDK artifact Mosaic will consume. Fix its compiler/AST gaps there;
Mosaic must not retain an alternative AST/compiler to compensate for them.
The inspected upstream revision is `00bba766a9361e660b4560324c564b257bddcb86`;
the observed package is 0.13.4. At planning time the local fork was on
`bazel-migration` at `330ffc7`, with package/core metadata 0.13.3. Reconcile relevant upstream compiler
changes while retaining its Bazel/CUE migration; do not assume identical sources.
None currently supplies the required native compilation entry.

1. In `crates/polyglot-sql/src/dialects/mod.rs`, extract the post-parse expression
   worker from `Dialect::transpile_inner`. Keep source preparation, normalization,
   target transforms, strict diagnostics and generation in that one worker.
2. Expose an AST-in entry through the Rust library, `polyglot-sql-wasm` and
   `packages/sdk/src/index.ts`, with this proposed shape:

   ```typescript
   compileAst(expressions, {
     sourceDialect: Dialect.DuckDB,
     targetDialect: Dialect.PostgreSQL,
     unsupportedLevel: 'raise',
   });
   ```

3. Accept typed native expressions and return SQL statements plus diagnostics.
   Support statement and scalar-expression roots so widget predicates use the
   same lowering worker. An expression result must not require wrapping a SELECT
   and stripping its SQL. Native data-type generation stays with Polyglot.
   Preserve input data. Apply AST complexity checks before recursive transforms.
   SQL lexical checks stay with SQL parsing; equivalent structural checks belong
   on the AST entry. The worker must not serialize and reparse generated SQL.
4. Fix or explicitly reject observed gaps: `QUALIFY`, `strftime`, aggregate
   empty-input differences, `TRY_CAST`, `GROUP BY ALL`, `COLUMNS`, and description
   queries. In particular, replacing `TRY_CAST` with throwing `CAST` is not a
   valid lowering. Test timestamp-to-milliseconds `epoch_ms` separately from its
   numeric-to-timestamp overload; the published transpiler can invert that meaning.
   Execute alias-dependent QUALIFY examples to catch invalid projection/alias
   rewrites. Unknown function calls must not silently imply portability.
5. Export synchronous typed native factories/defaults for the expression/query
   variants Mosaic needs, returning complete plain `ast.Expression` objects.
   Mosaic must not copy brittle serde defaults into another factory schema.
   Reusable native objects must not require consuming `SelectBuilder.build()`
   repeatedly. Extend the same fork-owned factories as later families migrate.

**Exercise:** manually constructed native objects and parsed equivalent input
must use the same compilation worker. Execute supported cases in DuckDB and
PostgreSQL, including null/empty aggregates, invalid casts, dates, windows and
QUALIFY. Unsupported cases must fail before database execution. Tests of generated
text alone do not settle behavior. Use the fork's existing Bazel targets in its
checkout, not upstream Cargo/pnpm build chains. Build `//packages/sdk:package.pack`
(complete development SDK archive)
or `//bazel/release:sdk_archive` for release packaging. Run
`//packages/sdk:quality_tests`, `//crates/polyglot-sql-wasm:glue_test`,
`//packages/sdk/testing:packed_node_tests`,
`//packages/sdk/testing:packed_browser_tests` and `//bazel/typescript:tests`,
plus `//crates/polyglot-sql:unit_tests`, `:integration_tests`, and WASM
`:unit_tests` for affected behavior. For a release artifact, also run
`//packages/sdk/testing:release_packed_node_tests` and
`:release_packed_browser_tests`. There is no inspected root `//:check` alias.

The fork already has CUE ownership: guard options come from
`spec/runtime/{model,schema,rust,typescript}.cue`; shared operation behavior and
fixtures from `spec/protocol/operations.cue`; function aliases/recognition from
`spec/functions/{model,recognition,schema,rust}.cue` and its `catalog_*.cue`
producers. Update those producers only when their owned facts change. Use
`bazelisk run //crates/polyglot-sql:update_types` or `:update_functions` as
appropriate, `//bazel/typescript:declarations` for assembled declarations, and
`//spec/runtime:tests`, `//spec/protocol:tests`, `//spec/functions:tests` for affected
contracts. Do not hand-edit generated Rust/TypeScript files or copy the SQL AST
into CUE. Most compiler options and the compilation worker remain handwritten.

**Delivery:** build an immutable, complete npm artifact from our fork containing
the JS, declarations and matching WASM. Pin its revision, artifact version and
integrity in Mosaic, never a mutable Git branch or installation-time compiler
build. Upstreaming can proceed independently and does not block this work. Do not
land P01 against plain `generate` as a substitute.

**Remove:** duplicated post-parse compiler logic in the dependency refactor.
Mosaic's legacy code is still required at this point.

## P01 — Pin the compiler and make every runtime load it

**Owners:** root/SQL/widget `package.json`, SQL and docs `BUILD.bazel`,
`pnpm-lock.yaml`, affected
`MODULE.bazel.lock` translation; `build/javascript.bzl`, `build/npm-consumer.mjs`,
Vite/example configuration, docs builder, widget bundle and Python packaging.
Add SQL `src/native/{expression,runtime,compile,index}.ts` as the native
implementation home and expose its temporary `/native` compiler entry.

1. Pin the P00 artifact as a required SQL dependency and declare its npm link in
   Bazel. Installation must consume the built SDK; keep lifecycle compilation off.
2. Export the pinned SDK's `ast.Expression` type through the native module. Add
   only the authoring adapters and compile entry needed for P02, delegating native
   AST construction to the fork-owned factories. Keep AST data constructors
   synchronous and avoid Rust/WASM calls for each identifier or literal.
3. Use Node ESM module readiness for automatic SDK initialization. Browser builds
   declare and emit the WASM asset, enable the required Vite support, use a modern
   ESM target and exclude the SDK from incompatible dependency prebundling.
4. For the widget, import the WASM asset as an embedded data URL using its declared
   esbuild action (`--loader:.wasm=dataurl`, ESM and ES2022+ output). Call
   `await init({ wasmUrl: embeddedWasmUrl })` through one manual runtime entry
   before issuing queries. Every compiler import in this bundle must use that
   instance; a root SDK import would also fetch a sibling asset from the blob URL.
   Include the embedded output in wheel/sdist packaging; use no CDN or install hook.
5. Add the execution context type: source semantics, target dialect and connection
   generation, owned per coordinator. Keep DuckDB as the default. P02 wires that
   context into coordinator submission and clears cache, in-flight, consolidation
   and preaggregation state when it changes. Public builders remain synchronous
   after module readiness.
6. Document high-level compatibility and the eventual breaking removal of exported
   low-level AST constructors, `instanceof` extension behavior, underscore clause
   mutation, `SQLCodeGenerator` and custom renderer subclasses. Show native factory
   and delayed-binding replacements. Update SQL package setup/browser requirements.

**Exercise:** compile a manually constructed native query and execute it through
Node DuckDB from an installed SQL tarball. Load a browser example and a built docs
page. Load the installed widget from a blob module and compile a selection
predicate. Exercise missing asset and failed initialization as actionable errors.
Measure compiler download, module startup and first-query cost; do not infer a
speedup from avoiding a SQL parse.

**Run existing targets:** SQL `:check` and `:tarball`, `//build:npm_consumer`,
`//packages/vgplot/widget:check`, widget `:wheel` and `:sdist`, and `//docs:site`.
Add a focused native compiler/browser/widget test to the owning Bazel packages
and CI selection; a declaration check does not load WASM. Run `pnpm docs:build`.

**Remove:** any experimental dependency loaders or copied SDK distributions used
for the probe. Do not add another package build runner or a second SQL emitter.

## P02 — Execute the first reactive native slice

**Owners:** native SQL facade/factories and bindings; core `Coordinator.ts`,
`QueryManager.ts`, connector submission boundary; `inputs/src/Slider.js` and a
filtered `MosaicClient` fixture. Use the existing Node DuckDB connector.

1. Implement native columns/tables/literals, scalar casts/operators, select/from,
   where, aggregate count/sum/min/max, group/order/limit and DuckDB description
   statements.
   Preserve `asNode` versus `asLiteral`, escaped identifiers, UTC date handling,
   non-finite values and empty lists. Preserve mutable facade and clone behavior.
   Own base `functions/{table-ref,column,cast,operators,numeric,util}.ts` behavior
   and `util/{ast,type-check,function}.ts` here; P04/P05 extend their native workers.
   Preserve aggregate/window method chains through thin native authoring handles;
   do not substitute SDK builders whose first `build()` consumes their state.
2. Introduce the one-way legacy-input adapter and extend the temporary `/native`
   compiler entry with the query facade.
   Keep one explicit internal pilot context and isolated Selection graph. Native
   clause construction receives that context's expression factory; legacy clause
   wrappers keep their default until their clients move. Do not switch clients by
   recognizing a function name or by catching a compiler error.
   Extend core `types.ts`, `MosaicClient.ts`, `make-client.ts`, `Selection.ts` and
   clause interfaces so native query/predicate types reach `ClientQuery`, `_request`
   and callbacks without `unknown` casts or native values entering legacy execution.
   P09 removes these transitional legacy type alternatives.
3. Maintain external binding registries with reserved native parameter IDs. A
   binding records scalar, identifier or delayed-expression behavior and its
   original `ParamLike`; it is resolved at submission, not at query construction.
   Preserve shared field/predicate references when converting a clause. Reuse the
   memo across its query and optimizer consumers; do not convert each independently.
   Compose binding registries when joining queries, CTEs, subqueries or templates:
   rebase IDs without changing Param identity or scalar/identifier binding kind.
   Reject unresolved binding slots before compilation. Field/lineage inspection
   resolves identifier binding metadata without prematurely freezing scalar values.
   If an identifier changes while queued, recompute its dependent analysis/plan
   before submission. Resolve late bin dependencies before dependent analysis.
   Release bindings/subscriptions when clients disconnect or contexts are cleared.
4. Move Slider's metadata, bounds, filter and update query path to the native
   facade. Exercise a real Slider selection that changes a filtered count/sum
   query through coordinator, connector, DuckDB and Arrow extraction.
5. Native submission resolves a snapshot, calls `compileAst` and uses its context
   in cache/deduplication keys. An Arrow query requires one result-producing
   statement. For exec, compile every input in order and join/execute using the
   backend's existing ordered SQL batch behavior. Connector requests still carry
   one SQL string; do not invent a list-shaped wire protocol.
   Preserve abort behavior, connection-generation isolation and exec ordering.
   Never truncate multi-statement output to `sql[0]`.
6. Explicitly bypass legacy-only consolidation/preaggregation for this pilot
   path. Keep both enabled for existing clients. P03/P04 restore their native
   implementations; this pilot is not the final performance behavior.

**Exercise:** live scalar and column parameter changes, two coordinators,
selection clear/empty/null values, initial and explicit Slider bounds, escaped
column names, updates while a query is queued, cancellation and late responses
from the previous connection. Assert results and actual control events.

**Run:** SQL/core/inputs `:check`, `//build:npm_consumer`,
`//build:npm_core_consumer`, and the matching browser case via `bin/visual-test.sh`.
Add a narrow native installed-consumer test if the existing target does not
exercise the temporary subpath. Update Slider/runtime setup documentation.

**Remove:** pilot-local renderer shims and duplicated parameter snapshots. Shared
`ParamNode`, `ColumnParamNode` and the old renderer remain owned by P09 until the
remaining clients move.

## P03 — Relational queries and consolidation

**Owners:** SQL `functions/{cte,from,join,order-by,positional-ref,values}.ts`,
query/relational native facade workers, native tree utilities,
`transforms/filter-query.ts`, core `QueryConsolidator.ts` and positional access.

1. Extend native construction to CTEs, aliases, scalar subqueries, join kinds,
   set operations, distinct/distinct-on, sampling, pivot and positional clauses.
   Preserve alias/source scoping, join operands and clone isolation. Unsupported
   target operations must lower in P00's compiler or reject before execution.
   PostgreSQL rejects unquoted `#n` column positions, POSITIONAL/ASOF and unlowered
   SEMI/ANTI joins, BY NAME sets, query-level or reservoir/row sampling, and
   PIVOT/UNPIVOT. Preserve existing ON-to-EXISTS lowering and table-level percentage
   sampling. An unsupported join must never disappear during normalization.
2. Replace walk/collect/clone/rewrite consumers with native-tree operations.
   Identity-sensitive walks return original JS nodes. Cloning uses a shared memo
   and propagates external binding entries. Never use copied Rust aggregate nodes
   as keys into a map over the original tree.
3. Rewrite filter pushdown and consolidator query-shape inspection against native
   clauses. Eliminate its underscore-field access on the native path. Preserve
   CTE/subquery boundaries, star/COLUMNS exclusions, aggregate grouping, output
   projection and the handling of missing/null columns across grouped queries.
4. Enable consolidation for the migrated path. Preserve cancellation of one
   constituent query, rejection of every constituent on extraction failure and
   the IPC extraction options captured when each flight starts. Changing extraction
   options invalidates incompatible reuse. Keep execution-context
   boundaries out of consolidation groups.

**Exercise:** carry forward SQL `query`, `clone`, `cte`, `join`, `pivot`,
`positional-ref`, `filter-pushdown` and `visitors` behavior tests, plus core
`query-consolidator`, `query-manager`, `query-abort` and `to-data-columns` cases.
Execute joins/set operations against fixture tables; do not compare only SQL text.

**Run:** SQL/core `:check` and both installed SQL/core consumer targets. Update
handwritten SQL query/visitor docs for the native extension surface.

**Remove:** native pilot's consolidation bypass and native uses of old traversal
dispatch. Delete superseded consolidator branches once legacy callers use the
same native inspection adapter; otherwise assign that exact branch to P09.

## P04 — Aggregates, windows and native preaggregation

**Owners:** SQL `functions/{aggregate,window,window-frame}.ts`; core
`src/preagg/{PreAggregator,preagg-columns,sufficient-statistics,lineage,subquery-pushdown}.ts`,
`util/positional.ts`; clause field/binding normalization.

1. Construct semantic aggregate and window variants, including filters, distinct,
   ordering, frames and sufficient-statistics expressions. Preserve function
   aliases and target semantics for empty groups and nulls. Include the native
   numeric/cast/coalesce/nullif and `scaleTransform` support closure used by
   `PreAggregator.binInterval` here, before promising interval preaggregation;
   P05 extends those same workers for plot transforms.
2. Port the preaggregation closure together. It must inspect native clauses and
   retain CTE shadowing, positional references, set-operation correspondence,
   star projection rules, single-base-table restrictions and nested source scope.
3. Preserve mean-centered variance/regression math and the existing rejection of
   non-indexable/dynamic queries. Preserve shared active-field identity through
   rewrite and snapshot resolution. A native optimizer failure falls back to the
   original native query, never the old emitter.
4. Keep DuckDB materialized tables in its writable local scratch schema. Restore
   preaggregation on the migrated path and test its creation, update, invalidation
   and query fallback. Backend support is explicit; P10 does not inherit it merely
   because PostgreSQL supports `CREATE TABLE`.

**Exercise:** native `aggregate`, `window`, `selection-clause`, `selection`,
`preaggregator`, `lineage` and `subquery-pushdown` fixtures. Compare final rows from
preaggregated and original native queries over nulls, constant/large-offset data,
selection changes and nested relations. Retain numerical tolerances appropriate
to variance/regression; SQL text equality is not a numerical test.

**Run:** SQL/core `:check` and installed core consumer. Update preaggregation and
SQL aggregate/window guides. If a generated function signature changes, edit its
owning CUE family and run the generation commands listed below.

**Remove:** the native preaggregation bypass, native reads of legacy clause arrays
and any parallel aggregate renderer. Legacy type dispatch still used by old
clients is removed in P09.

## P05 — Numeric, temporal and interactive plot queries

**Owners:** SQL numeric/string/case/collation/interval/datetime helpers,
`transforms/{scales,bin-1d,bin-2d,bin-date,bin-histogram,bin-linear-1d,bin-linear-2d,m4,line-density}.ts`
and their utilities; plot `Mark.js`, `ConnectedMark.js`, `DenseLineMark.js`,
`Density1DMark.js`, `ErrorBarMark.js`, `RegressionMark.js`; bin/extent/field helpers
and `interactors/Highlight.js`.

1. Build native expressions for the existing function/transform algorithms.
   Keep arithmetic, time zones, date interval boundaries and aggregate ordering
   equivalent on DuckDB. Generic function spelling is not a substitute for the
   semantic variant expected by the compiler. First land the common native Mark
   query/parameter contract and its context-aware native selection producers;
   P06/P07 can consume that commit while the rest of this packet proceeds.
   Resolve the coordinator's context before plot directives construct marks and
   pass it through their constructors. Mark ownership is fixed at construction.
   Include native field labels and the minimal DuckDB `queryFieldInfo` worker
   needed by `Mark.prepare`; P07 extends its backend and Arrow metadata behavior.
2. Replace `BinTransformNode` with an external delayed-expression binding. Resolve
   it after channel metadata and scale statistics exist, and again when those
   inputs change. Preserve its source-field/statistics association outside AST
   payloads. Query construction must not freeze the first observed extent. Native
   analysis is binding-aware and recomputes field/statistics-dependent plans when
   the identifier, source data or scale changes.
   Resolve known plot bins into channel expressions after preparation and before
   preaggregation analysis. Keep arbitrary delayed expressions non-indexable.
   Reuse Mark initialization and query-update invalidation for parameter, source
   and scale changes, rather than introducing another invalidation registry.
3. Port Mark's parameter collection and aggregate/field analysis. Replace
   `get-field.js` legacy tags and `extent.js` class checks with native inspection.
   Move ConnectedMark's select access and Highlight's group access together with
   their native query paths.
4. Exercise a histogram selection through bin computation, optimized SQL,
   selection update, Arrow result and SVG rendering. Exercise connected-line M4,
   density and statistical marks; preserve hover/highlighting group order.

**Run:** SQL/core/plot/vgplot `:check`, plot/vgplot `:package_test`, and affected
histogram/connected/density/statistical browser cases. Keep generated starter
execution and Python roundtrips covered by the owning existing tests.

**Remove:** native plot dependencies on `BinTransformNode`, its custom renderer
and `duckDBCodeGenerator`. Its legacy branch still serves the default runtime
until P09 and is explicitly deleted there with the legacy Mark/channel workers.
Remove native private-clause/tag/class checks in this slice's consumers. Retain
the separate visualization transform classes in the spec parser.

## P06 — Collections and nested query consumers

**Owners:** SQL `functions/{all,column,lambda,list,named-arg,star,subscript,unnest}.ts`,
tuple/quantified/collection native factories; plot `Grid2DMark.js`, `HexbinMark.js`,
`RasterTileMark.js` and their array/unnest query helpers. Consume P05's Mark contract.

1. Construct native lists, tuples, lambdas, subscripts/slices, named arguments,
   quantified comparisons, recursive unnest and star selectors. Preserve indexing
   conventions, null/empty collection behavior and parameterized identifiers.
2. Preserve star EXCLUDE/REPLACE/RENAME and COLUMNS behavior on DuckDB. For a target
   needing expansion, use actual table metadata before compilation; otherwise
   reject that operation. Do not send unchanged DuckDB selectors to PostgreSQL.
3. Move grid/hexbin/raster queries through native workers, retaining UNNEST output
   shape, aggregation ordering, prefetch concurrency and Arrow column extraction.
   Add any currently implicit native tree factory defaults to the common factory
   module rather than duplicating its serde shapes in each mark.
   Reuse P05's minimal UNNEST support and bin helpers; remove RasterTileMark's
   duplicated SQL-template implementations of `bin2d` and `binLinear2d`.

**Exercise:** existing `list`, `lambda`, `subscript`, `star`, `unnest`, `tuple`,
`named-arg`, `quantified-op`, grid/raster/hexbin tests; execute nested-data queries
and render a real grid/raster case. Include qualified selectors and empty inputs.

**Run:** SQL/plot/vgplot `:check`, installed plot consumer and affected browsers.
Update the SQL collection/star docs. CUE family edits are needed only if the
public authoring or wire contract changes.

**Remove:** this family's old construction/visitor handlers when unused, with
shared legacy node dispatch deleted in P09. Keep result-shape and browser tests.

## P07 — Loading, metadata and spatial queries

**Owners:** SQL `load/{create,extension,load,sql-from}.ts`, `functions/spatial.ts`,
core `util/field-info.ts`/`js-type.ts`, spec `ast/DataNode.js`, plot `GeoMark.js`,
source/data runtime adapters and associated guides. Consume P05's Mark contract.

1. Construct native create/schema/table and file-reader queries. Preserve unions
   before object projection, quoted paths/nested options, expression-valued
   loader options and load-object type behavior. DuckDB setup commands that the
   SDK cannot model are explicitly backend-owned same-dialect commands; they
   cannot masquerade as portable relational expressions.
2. Introduce one backend-aware metadata path. DuckDB can retain description-row
   semantics; an Arrow-schema strategy must normalize names, SQL/JS types,
   nullability and zero-row results for a future backend. Remove hard-coded
   `GROUP BY ALL`/raw `DESC` assumptions from the shared native path.
3. Move spatial expression and geometry query construction to native factories.
   Preserve CRS/geometry encoding and Arrow/GeoJSON conversion. Keep spatial
   extension setup explicit. Reject unimplemented target spatial operations.
4. Run spec data loading through the native DuckDB path and render a geographic
   example. Preserve source/table identifier quoting and reuse of input mappings.

**Run:** SQL/core/spec/plot `:check`, installed package checks and affected data/
spatial browser cases. Update SQL loading/spatial and data-source guides. Keep
runtime extension-loading and protocol tests where actual setup behavior changes.

**Remove:** native assumptions that description results are always DuckDB rows,
old spatial node handling and replaced loader renderer branches. Do not remove
DuckDB runtime engines, extension setup or published schema history.

## P08 — Expression ingress, specifications, Python and widgets

**Owners:** SQL `functions/{sql-template-tag,literal}.ts`, native raw-input parsing;
spec `ast/{ExpressionNode,TransformNode,WindowFrameNode}.js` and expression/config
adapters; remaining Menu/Search/Table input query paths; widget `src/index.js`;
relevant CUE family producers and authoring guides.

1. Preserve raw template semantics. Parse raw expressions/statements with an
   explicit source dialect. Preserve string-as-SQL interpolation, scalar versus
   identifier placeholders, escaped delimiters and partial-fragment composition
   at the enclosing syntax boundary. Use Polyglot's parser; do not add a second
   general SQL parser/validator in Mosaic. Bring forward the upstream 0.13.4
   input-precedence, lambda/exponent and DuckDB relation-alias fixes while retaining
   the fork's CUE-owned carriers and guards.
   Apply the same source-aware normalization and strict checks to manually built
   generic Function nodes. DuckDB `isfinite`, `time_bucket` and `range` calls must
   not bypass the restrictions of their canonical native variants on PostgreSQL.
   Preserve qualified/quoted user functions and PostgreSQL's set-valued regex
   semantics rather than treating names alone as portable operations.
2. Substitute structured interpolation and live bindings using reserved holes;
   distinguish `$param` values and `$$param` identifiers in the spec parser.
   Detect collisions with user identifiers. Unparseable portable input fails
   explicitly; same-dialect opaque input is documented and excluded from rewrites.
3. Replace direct SQL WindowFrameNode construction with native frame helpers.
   Keep the visualization AST and its JavaScript/Python code generators. Replace
   their SQL internals, not their visualization node classes.
4. Move remaining input clients, public vgplot query helpers and spec-generated
   queries to the native facade. Compile widget selection predicates with the
   same context/binding snapshot as normal queries. Python's filtered-data query
   and the default widget connector remain DuckDB-backed.
5. Change CUE sources only for actual contract changes. Normal generation updates
   transform metadata, selective exports, signatures, Python bindings, reference
   sections and starters together. No Polyglot Python dependency is introduced.

**Exercise:** SQL-template tests with values and identifiers, dynamic spec columns,
windows, selection predicate export, JSON/YAML/ESM/Python roundtrips, actual widget
messages and fresh wheel/sdist imports. Run the installed blob-loaded widget with
WASM initialization. Check that invalid inputs still reject at the right boundary.

**Run:** SQL/inputs/spec/vgplot/Python/widget `:check`, their installed-package
targets, affected browsers, and generation/gallery checks when producers change.
Update shared JavaScript/Python guides together and run `pnpm docs:build`.

**Remove:** replaced template-fragment renderer paths, widget `map(String)`
predicate serialization and direct spec imports of old SQL node constructors.
Preserve visualization AST classes and Python serialization/runtime modules.

## P09 — Switch the default and delete the superseded compiler

**Owners:** SQL public entry points/types, core submission/clause types, remaining
legacy-input sites, shared generated exports, native targets and migration guide.
This is a breaking compiler-extension release with high-level authoring preserved.

1. Redirect root SQL exports to the native implementations. Replace remaining
   selection producers with native expressions so fields and predicates share
   native nodes directly. Preserve `Param`, `Selection`, coordinator and client
   identities across all installed packages.
2. Remove the internal pilot switch and temporary `/native` package export. Move
   final implementation modules into their normal runtime homes; do not leave
   parallel `old`/`new` package trees. Submit every generated query through the
   native compiler and the coordinator's own context.
3. Delete legacy SQL `src/ast/` concrete node implementations, old constructor
   reexports, `visit/codegen/{sql,duckdb}.ts`, `init.ts`, global visitor setup,
   node-dispatch constants and replaced walker/clone/rewrite implementations.
   Keep a native-backed Query facade and accurately named type aliases. Keep
   unrelated semantic constants and public helpers that still have real users.
4. Delete `native/legacy-input.ts`, all temporary conversions, legacy optimizer
   branches, legacy Mark/channel/bin workers including `BinTransformNode`,
   duplicate fixtures and comparison-only tests. Replace representation
   snapshots with meaningful API/result tests where needed; retain SQL-string
   assertions for escaping, aliases, raw-input semantics and required syntax.
5. Check the complete public SQL entry point against `docs/api/sql/`, vgplot's
   selective reexports, generated CUE ownership, README/setup guides and package
   archives. Document removed low-level extension APIs and native replacements.

**Deletion check:** re-run Sitting Duck import/member/class queries against fresh
sources, then inspect compiler imports, package exports and native typechecks.
Investigate all remaining old constructor names, `CUSTOM`, private-clause access,
global visitor references and generated-query `String` serialization. Grammar
recovery means a zero-row AST query alone cannot establish removal. Legitimate
raw source strings and the visualization AST are outside the deletion set.

**Exercise:** installed Embedding Atlas composition with one copy of every Mosaic
package, plus installed SQL/core/render consumers and a constructor-extension
migration example. Confirm root tarballs and widget archives contain all required
compiler assets and no legacy SQL compiler modules.

**Run:** `bazelisk build //:build`, `bazelisk test //:check`,
`bazelisk test //packages/server:protocol`, `bin/visual-test.sh` in its matching
container, and `pnpm docs:build`. Rebuild/check generated artifacts using their
normal commands. The four DuckDB server implementations retain their behavior.

## P10 — Execute one additional database backend

**Owners:** a new Node-only PostgreSQL adapter under `packages/server/postgres/`,
a declared optional Node connector entry alongside the existing Node DuckDB
connector, native SQL context/metadata integration, backend documentation and
installed consumer tests. This packet adds no PostgreSQL Python/Go/Rust server
ports and no browser database gateway.

1. Pin the PostgreSQL driver and declare its Bazel/npm dependencies. Add the
   isolated Node export and optional peer metadata to core's package manifest.
   Register the package in root BUILD package/build/check/archive selections.
   The normal browser/core entry must not import the Node driver. Each connector
   owns its connection/session and returns Arrow IPC with accurate schema/types.
2. Use the native compiler with target PostgreSQL. Support the initial tested
   subset: columns/literals, scalar/null filters, grouping/count/sum/avg/min/max, ordering,
   limits, live scalar/identifier parameters and selection updates. Execute native
   compiler regression cases for dates/windows/QUALIFY where advertised. Reject
   unsupported loaders, extensions, selectors or functions before execution.
3. Use P07's metadata strategy. Map PostgreSQL driver field OIDs, table/attribute
   IDs and type modifiers to Arrow types, including decimal precision/scale. Query
   `pg_catalog` for base-column NOT NULL where available; unknown expression
   nullability is conservatively nullable. A zero-row SELECT alone does not prove
   expression nullability. Configure driver parsing to preserve int8, decimals and
   timestamp microseconds rather than losing them through JS Number/Date defaults.
   Test empty results and parameterized identifiers. Do not infer types from values.
4. Support ordered `exec`, explicit session cleanup and cancellation through the
   driver/database cancellation mechanism. Late responses cannot repopulate a
   newer execution context. Test multiple coordinators without shared state.
5. Declare PostgreSQL preaggregation unsupported initially unless its complete
   scratch-schema/session behavior is implemented and tested in this packet.
   A backend profile selects its default; an explicit unsupported enable request
   raises an error. Native query/consolidation correctness still applies. DuckDB
   preaggregation stays enabled and fully tested.
6. Add one end-to-end Node example that drives selection changes through a
   coordinator into real PostgreSQL and extracts the resulting Arrow table.
   Exercise a rendered chart/table with a test DOM. Document Node-only scope,
   backend setup and the supported operations; browser users still need a gateway.

**Add targets:** PostgreSQL package `:check`, `:package_test` and
`:integration_test`. The integration test provisions a pinned PostgreSQL container
and cleans it up through its Bazel test executable; declare its Docker requirement
and run it in a CI job with Docker available. Pin the supported database release
and image digest when implementing this packet. Unit/mocked-driver tests cannot
replace the real database test. Builds and tests remain Bazel-owned.

**Run:** the new targets, SQL/core `:check`, installed SQL/core/connector consumer
tests and docs build. Compare observable query results with equivalent DuckDB
fixtures using explicit tolerances/type normalization, not a new result-reporting
framework. Only document additional database support after this path runs.

**Remove:** temporary direct-driver examples, hard-coded PostgreSQL generation
experiments and any fallback back to DuckDB on compilation/execution errors.
There should be no old SQL AST left to compare against after P09.

## Commands shared by affected packets

Existing package checks are independently selectable:

```sh
bazelisk test //packages/mosaic/sql:check //packages/mosaic/core:check
bazelisk test //packages/vgplot/inputs:check //packages/vgplot/plot:check
bazelisk test //packages/vgplot/spec:check //packages/vgplot/vgplot:check
bazelisk test //packages/vgplot/vgplot-python:check //packages/vgplot/widget:check
bazelisk test //build:npm_consumer //build:npm_core_consumer
```

Run only the affected closure during a packet, then the full checks at P09.
Browser cases run through `bin/visual-test.sh` in its matching container. New
browser/compiler asset tests must be added to the actual CI target selections.

For changed CUE producers, use these existing root aliases:

```sh
bazelisk run //:generate
bazelisk test //:api_check
```

For changed gallery YAML, use `bazelisk run //:examples` and
`bazelisk test //:examples_check`. Do not edit generated variants or invoke schema
publication. All documentation changes require `pnpm docs:build`.
