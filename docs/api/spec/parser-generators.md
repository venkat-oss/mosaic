# Specification Parser & Generators

Methods to parse declarative specifications and generate applications or code as output.

## parseSpec

`parseSpec(spec, options)`

Parse a JavaScript specification object into an abstract syntax tree (AST). Parse JSON text with JSON.parse, or YAML text with a YAML parser, before calling this method.

Returns `SpecNode`.

The supported options are:

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `components` | `Map<string, Function>` | `componentMap()` | Ordered map of component names to parser functions. The first matching component wins; a caller-supplied map replaces the built-in map. |
| `transforms` | `Set<string>` | `transformNames()` | Names of allowed transform functions. |
| `inputs` | `Set<string>` | `inputNames()` | Names of supported input widgets. |
| `plot` | `PlotNames` | `plotNames()` | Sets of supported plot attributes, interactors, legends and marks. |
| `params` | `[string, ASTNode][]` | `[]` | Named pre-parsed parameter or selection nodes to seed the parser context. |
| `datasets` | `[string, ASTNode][]` | `[]` | Named pre-parsed dataset nodes to seed the parser context. |

The AST root exposes meta, config, root, data, params and plotDefaults. Data and params are objects keyed by name. Its toJSON method produces normalized JSON; inferred selections become explicit definitions. The editor-only $schema annotation is not retained in the AST.

Custom component, transform, input and plot registries belong to the parser context. They do not extend the strict built-in declarative schema automatically.

### Example

```js
import { parseSpec } from "@uwdata/mosaic-spec";

// declarative specification in JSON format
const spec = {
  plot: [
    {
      mark: "lineY",
      data: { from: "table" },
      x: "date",
      y: "value"
    }
  ],
  width: 640,
  height: 200
};

// parse specification to internal AST (abstract syntax tree)
const ast = parseSpec(spec);

// serialize back to a normalized JSON format
const json = ast.toJSON();
```


## astToDOM

`astToDOM(ast, options)`

Load data, instantiate parameters and selections, and create the running application as DOM content using the supplied vgplot API context.

Returns `Promise<{element: HTMLElement | SVGSVGElement, params: Map<string, Param | Selection>}>`.

The supported options are:

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `coordinator` | `Coordinator \| undefined` | `undefined` | Coordinator used to create the API context when api is omitted. If neither is supplied, the global coordinator is used. A supplied api takes precedence. |
| `api` | `API context` | `createAPIContext({coordinator})` | API context providing the coordinator, named plots and extension methods. The default context uses the supplied or global coordinator and a fresh named-plots map. |
| `params` | `Map<string, Param \| Selection>` | `new Map()` | Live instances to reuse across specifications. Definitions whose names are already present do not replace the supplied instances. |
| `baseURL` | `string \| null` | `null` | Base URL used when loading data files. |

The fulfilled value contains the root element and the active named-parameter map. Add the element to the document to display the application. Each API context can use a separate coordinator; pass shared parameter instances explicitly when linking contexts.

### Example

```js
import { astToDOM } from "@uwdata/mosaic-spec";

// instantiate a running application
// assumes standard browser facilities in globabl variable `window`
const {
  element, // root DOM element of the application
  params   // Map of all named Params and Selections
} = await astToDOM(ast);

// add application to current web page
document.body.appendChild(element);
```


## astToESM

`astToESM(ast, options = {})`

Generate an ECMAScript module that uses the vgplot JavaScript API to load data and construct the application.

Returns `string`.

The supported options are:

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `baseURL` | `string \| undefined` | `undefined` | Base URL used when loading data files. |
| `namespace` | `string` | `'vg'` | Namespace used for vgplot method calls. |
| `connector` | `'rest' \| 'wasm' \| undefined` | `undefined` | Optional connector initialization. When omitted, generated code uses the existing coordinator connector. |
| `depth` | `number` | `0` | Starting indentation depth. |
| `imports` | `Map<string, string \| string[]>` | `new Map([['@uwdata/vgplot', '* as vg']])` | Module imports: each key names a package, and each value specifies a namespace import or named imports. |
| `preamble` | `string \| string[]` | `undefined` | Code emitted after imports and before connector and data initialization. |

The module's default export is the constructed application element. Metadata and the editor schema annotation are not runtime view arguments. Generated parameter identifiers avoid collisions with imports and retain references to parameters with arbitrary names. Object property names are quoted when required by JavaScript.

### Example

```js
import { astToESM } from "@uwdata/mosaic-spec";

// generate ESM (ECMAScript Module) code
const code = astToESM(ast);
```


## astToPython

`astToPython(ast)`

Generate Python code using the vgplot authoring API. The emitted module imports vgplot as vg and assigns its outer view to view.

Returns `string`.

This method has no supported options argument; namespace and indentation are managed by its PythonCodegenContext.

The retained emitter omits specification metadata. Use authored vg.spec(meta=...) when metadata must be preserved. Data, parameter references, configuration, plot defaults and the view are emitted through their public Python APIs. Input, legend and spacer roots retain specification headers through vg.spec. Generated local identifiers avoid collisions with imports and other definitions while preserving original data and parameter names in the specification.

Generated string literals preserve quotes, backslashes and control characters. Dollar-prefixed strings remain literals in scalar parameter values, inline data, file names and menu option values; parameter-reference positions resolve to the generated Python variables.

### Example

```js
import { astToPython } from "@uwdata/mosaic-spec";

// generate Python code
const code = astToPython(ast);
```

## Root specification contracts

A declarative Mosaic specification. It combines the specification header with one component.

Top-level specification properties.

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `$schema` | `string` | No | A [JSON schema](http://json-schema.org/) URL for this specification, such as https://uwdata.github.io/mosaic/schema/latest.json. This property enables validation and autocomplete in editors with JSON schema support. |
| `meta` | `Meta` | No | Specification metadata. |
| `config` | `Config` | No | Configuration options. |
| `data` | `Data` | No | Dataset definitions. |
| `params` | `Params` | No | Param and Selection definitions. |
| `plotDefaults` | `PlotAttributes` | No | A default set of attributes to apply to all plot components. |

A specification component such as a plot, input widget, or layout. The supported component contracts are `HConcat`, `VConcat`, `HSpace`, `VSpace`, `Menu`, `Search`, `Slider`, `Table`, `Plot`, `Legend`.

### Meta

Specification metadata.

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `title` | `string` | No | The specification title. |
| `description` | `string` | No | A description of the specification content. |
| `credit` | `string` | No | Credits or other acknowledgements. |

Additional properties are admitted by this contract.


### Config

Configuration options.

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `extensions` | `string \| Array<string>` | No |  |

Additional properties are admitted by this contract.


### Data

Top-level dataset definitions.

Names map to `DataDefinition` definitions.


### Params

Top-level Param and Selection definitions.

Names map to `ParamDefinition` definitions.


### Plot

A plot component.

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `plot` | `Array<PlotMark \| PlotInteractor \| PlotLegend>` | Yes | An array of plot marks, interactors, or legends. Marks are graphical elements that make up plot layers. Unless otherwise configured, interactors will use the nearest previous mark as a basis for which data fields to select. |

Inherits `PlotAttributes`.

See the [format reference](./format) for data loading, parameter and layout examples, and the [plot API](../vgplot/marks) for concrete mark contracts.

## Python root authoring

The Python entry points retain their direct runtime implementations. These contracts describe their public signatures and target applicability.

### plot

`plot(*items: Mark | Directive | Mapping[str, Any], param_names: dict[int, str] | None=None, **kwargs: Any)`

Create a plot view from marks and directives.

Python target; return annotation `View`.


### spec

`spec(*args: Any, data: dict[str, Any] | None=None, params: dict[str, Any] | None=None, plotDefaults: dict[str, Any] | None=None, plot_defaults: dict[str, Any] | None=None, config: dict[str, Any] | None=None, view: dict[str, Any] | View | None=None, **extra: Any)`

Assemble a specification from a view, data sources, and parameters discovered in the caller scope.

This entry point inspects its caller's scope. Keep its direct binding; a forwarding wrapper can change data and parameter discovery.

Python target; return annotation `Spec`.


### Spec

`Spec(*, data: dict[str, Any] | None=None, data_names: dict[int, str] | None=None, params: dict[str, Any] | None=None, plotDefaults: dict[str, Any] | None=None, plot_defaults: dict[str, Any] | None=None, config: dict[str, Any] | None=None, view: dict[str, Any] | View | None=None, **extra: Any)`

A serializable specification with explicit data and parameter definitions.

Python target; return annotation `None`.


### View

`View(view: dict[str, Any], *, data: dict[str, Any] | None=None, plotDefaults: dict[str, Any] | None=None, plot_defaults: dict[str, Any] | None=None, config: dict[str, Any] | None=None, **extra: Any)`

A composable view that discovers data and parameters from its caller when serialized or displayed.

Python target; return annotation `None`.


### View.to_dict

`View.to_dict(self, _context: dict[str, Any] | None=None)`

Serialize a view using the explicit context or caller scope.

This entry point inspects its caller's scope. Keep its direct binding; a forwarding wrapper can change data and parameter discovery.

Python target; return annotation `dict[str, Any]`.


### View.to_json

`View.to_json(self, _context: dict[str, Any] | None=None, **kwargs: Any)`

Serialize a view as JSON using the explicit context or caller scope.

This entry point inspects its caller's scope. Keep its direct binding; a forwarding wrapper can change data and parameter discovery.

Python target; return annotation `str`.


### View.show

`View.show(self, con: Any=None, data: Any=None)`

Display a view after resolving data and parameters from its caller.

This entry point inspects its caller's scope. Keep its direct binding; a forwarding wrapper can change data and parameter discovery.

Python target; return annotation `None`.
