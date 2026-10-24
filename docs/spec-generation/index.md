# Specification Generation

CUE owns Mosaic's declarative specification and its JavaScript and Python authoring contracts: constraints, public names and signatures, target adapters, types/schema, bindings, registrations, reference prose and starter templates. Ordinary runtime modules implement queries, rendering, interactions, serialization and caller-scope discovery.

Bazel owns the build and test graph. See the [build workflow](../development/build.md) for package builds, installed consumers and browser tests.

## Sources and outputs

| Source | Responsibility |
| --- | --- |
| `.cue-version`, `cue.mod/module.cue` | Pinned CUE tool and module |
| Family packages under `api/` | Canonical contracts, target adapters, prose and templates |
| Each family's `contribution.cue` | Concrete files, shared sections, public exports and schema contributions |
| `api/catalog/sources.cue` | Owning family packages in composition order |
| `api/catalog.cue`, `api/compose/` | Shared files, exports and registry composition |
| `api/model/`, `api/render/` | Shared declaration constraints and generation helpers |
| `api/spec/model/` | Root contracts and parser/runtime API metadata |
| `api/**/BUILD.bazel`, `build/cue.bzl` | Independent family validation and projection actions |
| `build/cue/input.cue` | Assemble concrete family contributions |
| `build/api-format.mjs`, `build/api-sync.mjs` | Native validation, formatting and output I/O |
| `api/generated.json` | Generated filenames for stale-file cleanup |

Edit an owning CUE source and regenerate its artifacts. Public TypeScript declarations, the full JSON Schema, JavaScript wrappers, Python bindings, parser/codegen metadata, reference sections and starter templates are outputs. Shared files have one composer. Contributions live beside their family; there are no separate catalog forwarding packages.

## Contract authoring

Families use constrained CUE records for the information shared by their targets. Common defaults describe ordinary interfaces, optional properties and normal documentation ownership. Declarations override these defaults for required fields, aliases, host-only contracts and other actual differences. Metadata defaults do not insert omitted values into payloads.

Properties and Python parameters are ordered lists. Their order is part of declaration output, documentation and callable signatures; changing to a field map would lose that explicit ordering.

For example, `api/inputs/basic/model.cue` describes Menu, Search and Slider through `_inputs`. This excerpt shows two Menu properties in their existing relative order:

```cue
_inputs: [{
    name:             "Menu"
    description:      "A menu input component."
    input:            "menu"
    inputDescription: "A menu input widget."
    properties: [
        {name: "listMatch", type: "ListMatch", description: "How to match list values."},
        {name: "label", type: "string", description: "A text label for this input."},
    ]
}]

typeExpressions: ListMatch: {kind: "enum", values: ["any", "all"]}
```

The complete source includes the remaining properties and their descriptions. The family derives each required `input` discriminator, its literal type, and its primitive expressions from the same records. Shared constraints supply optionality and ordinary interface metadata. `ListMatch` is a domain name for a reused enum; individual enum members do not need separate expression nodes.

Simple expressions use flat records:

```cue
typeExpressions: {
    stringValue: {kind: "primitive", type: "string"}
    menuKind:    {kind: "literal", value: "menu"}
    ParamRef:    {kind: "named", name: "ParamRef"}
}
```

Arrays, unions, tuples, records and composed shapes refer to named expressions. Template expressions carry their parts and target adapters directly. Shared projections follow expression and inheritance dependencies.

These declarations are explicit generation inputs. They are not a reflection system for arbitrary CUE constraints, comments or target-language constructs. Native CUE payload schemas, TypeScript and JSON Schema are rendered from the same authored declarations; JSON Schema is an output rather than a source from which Python signatures are reconstructed.

Keep target adapters where contracts differ. ParamRef intentionally uses dollar-prefixed references in TypeScript while accepting ordinary strings on the wire. DOM elements, callbacks, dates, symbols and sentinels require host adapters. Typed tuples, overloads, conditional types and Python signatures carry target information that a general schema conversion may not preserve.

Model target differences that affect generated types, bindings or payload constraints. Keep descriptive runtime notes as prose rather than duplicating them in status matrices or source-hook records.

Python factory records keep the callable parameter order, annotations, defaults and aliases with the family. Basic inputs default parameters to `Any = None` and ordinary positional-or-keyword arguments; required parameters, boolean defaults and `**opts` are explicit exceptions. Generated functions delegate to ordinary runtime helpers. The input runtime retains omission of `None` before aliases, `bind` to `as`, `source` to `from`, option sentinels and mixed-option normalization.

Reference sections declare their language and special placement at the producer. IDs identify and order sections; they do not select a language or an import position. Language-neutral sections and ordinary body placement use the root composer's defaults.

## From contracts to generated code

The path for each family is:

1. Shared CUE helpers constrain the complete family and render target declarations, bindings, prose and starters.
2. Its Bazel `:contribution` action runs `cue vet -c`, then exports a concrete contribution as JSON.
3. The root composition combines contributions into shared TypeScript modules, public exports, registries and the full schema.
4. Formatting validates generated native CUE examples and formats CUE and Python files.
5. Explicit synchronization writes generated source and removes obsolete generated filenames.

For the basic-input family, the same declarations reach each public surface:

| Surface | Output or consumer |
| --- | --- |
| TypeScript | Menu, Search and Slider sections in `packages/vgplot/spec/src/spec/Input.ts` |
| Payload validation | `packages/vgplot/spec/src/generated/basic-inputs.cue` and the composed `mosaic-schema.json` |
| JavaScript | `packages/vgplot/vgplot/src/generated/basic-inputs.js` wrappers call the existing Menu, Search and Slider clients |
| Python | `packages/vgplot/vgplot-python/vgplot/_input_api.py` preserves factory signatures and delegates normalization to `_input_runtime.py` |
| Reference | `docs/api/inputs/menu.md`, `search.md`, `slider.md` and `authoring.md` |
| Starters | `templates/inputs/basic/` supplies JSON, YAML, JavaScript and Python examples, including `menu-table` |

The `menu-table` starter creates a small SQL table and binds a selection. Its Python view serializes to the declared wire format; the browser parser resolves the binding and the existing Menu client handles query activation, DOM events and selection updates. Existing contract, serialization, runtime and installed-consumer tests cover this path.

CUE comprehensions, unification and string templates perform generation. The scripts handle formatting and file I/O. There is no second schema parser or semantic validator in JavaScript or Go. A contribution's JSON transports concrete output; it does not transport live CUE constraints.

Bazel keeps family actions separate and caches unchanged outputs. Shared canonical contracts use model-only packages where another family needs them without its generation graph. Splitting files within one CUE package does not create a separate cache boundary.

Runtime algorithms stay in ordinary source files and consume generated names or metadata. For example, `packages/vgplot/spec/src/config/plots.js` owns `plotNames` and its set-building helpers, using generated interactor names and runtime directive tables. Thin generated JavaScript and Python wrappers connect the declared public API to those implementations.

## Generate and check

Bazel downloads the pinned CUE and Ruff tools. Generate and check committed artifacts with:

```sh
bazelisk run //:generate
bazelisk test //:api_check
```

`//api:projection` validates and exports families, assembles their concrete inputs and composes the output map. `//build:api_generated` validates native CUE examples and formats CUE and Python into a declared output directory. Unchanged actions reuse cached outputs.

`//:generate` copies those artifacts into the workspace and removes obsolete files using `api/generated.json`. `//:api_check` compares them with declared source mirrors without repairing files. Commit source changes and regenerated artifacts together.

A family can be built independently:

```sh
bazelisk build //api/inputs/basic:contribution
```

Run affected tests while developing. Native contract and consumer tests are independently selectable under `//bin/test`; `bazelisk test //bin/test:tests` runs the suite with declared CUE, TypeScript and Python tools. For a basic-input change, exercise valid and invalid payloads, TypeScript declarations, Python serialization and the affected input/runtime consumers. Use the package's normal `:check` targets and relevant browser cases through `bin/visual-test.sh` when wrappers, interactions or starters change.

Ordinary builds and installed packages consume committed generated source without CUE. The full schema at `packages/vgplot/spec/src/generated/mosaic-schema.json` is packaged at the existing `dist/mosaic-schema.json` path.

## Extending a family and removing replaced code

Follow a family change through its declarations, contribution, types/schema, bindings, reference sections, starters and runtime consumers. Preserve public names, paths, signatures and target adaptations unless the change deliberately updates that API. Update handwritten runtime guides in the same change.

Register a new family in `api/catalog/sources.cue` and the catalog's Bazel contribution/source collection. Give it its own `:contribution` action with complete validation before export. Compose shared outputs through contributions instead of editing generated files or introducing a forwarding package.

Delete superseded declarations, generator branches, imports, BUILD dependencies and representation-only tests when their consumers switch. Retain shared helpers with real consumers and meaningful payload rejection, type, runtime and installed-consumer tests. Use normal dependency searches to establish whether a helper is still needed.

When a file becomes handwritten, remove its CUE output entry and generated ownership together. Synchronization deletes previously generated files, so preserve the handwritten source across that handoff and confirm a second generation leaves it intact. For obsolete artifacts, remove their imports and let normal generated-file cleanup delete them.

Review source/output diffs and run the affected build/test targets. Generation checks cover deterministic output, filename cleanup and output collisions.

Document runtime limitations at their reference producer and cover them with behavior tests.

## Documentation and gallery examples

Generated reference sections and starter templates come from their owning family. Documentation downloads use the `docs/public/templates` symlink. Keep shared JavaScript/Python docs aligned and build documentation changes with `pnpm docs:build`.

Gallery `specs/yaml/*.yaml` remains canonical. Change its YAML and run `pnpm docs:examples` to update variants and pages. Published versioned schemas remain release history; `pnpm docs:schema` publishes them and is not a validation command.
