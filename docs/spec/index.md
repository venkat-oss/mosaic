<script setup>
  import { coordinator } from '@uwdata/vgplot';
  import { withBase } from 'vitepress';
  coordinator().clear();
</script>

# Mosaic Declarative Specifications

The `mosaic-spec` package enables declarative specification of Mosaic applications as JSON or YAML files. The package provides a specification parser, as well as generators to create either running applications or JavaScript code.

For example, below is an example of a declarative specification, in either YAML or equivalent JSON, for a simple line chart. The JavaScript and Python tabs show equivalent code that builds the same specification using the [`vgplot`](/vgplot/) API in each language.

<Example spec="/specs/yaml/line.yaml" />

::: code-group
<<< @/public/specs/yaml/line.yaml [YAML]
<<< @/public/specs/json/line.json [JSON]
<<< @/public/specs/esm/line.js [JavaScript]
<<< @/public/specs/python/line.py [Python]
:::

Using a declarative specification, we can describe an application in a standard file format, enabling portability across platforms. The same spec can be authored as YAML/JSON or built programmatically with the `vgplot` API in either JavaScript or Python (see the [Python API](/vgplot/?lang=python)). For example, the [Mosaic Jupyter widget](/jupyter/) uses this format to pass visualization and dashboard definitions from Python to the browser.

::: tip
The [TypeScript types in the `@uwdata/mosaic-spec` package](https://github.com/uwdata/mosaic/tree/main/packages/vgplot/spec/src/spec) provide comprehensive documentation of Mosaic declarative specifications.
:::

## Specification Format

Here is a slightly more complicated example, in which a dynamic `Param` value is added to the data before visualizing it.

<Example spec="/specs/yaml/bias.yaml" />

::: code-group
<<< @/public/specs/yaml/bias.yaml [YAML]
<<< @/public/specs/json/bias.json [JSON]
<<< @/public/specs/esm/bias.js [JavaScript]
<<< @/public/specs/python/bias.py [Python]
:::

The example above includes descriptive metadata, `data` and `params` definitions, and nested components: an input `slider` and `plot` are positioned using a `vconcat` layout. The `plot` uses a SQL expression that includes a `Param` reference (`$point`) to define a dynamic `y` encoding channel.

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

For more, see the [Specification Format Reference](/api/spec/format).

## Parser & Generators Format

The `parseSpec()` method parses a specification in JSON format into an _abstract syntax tree_ (AST): a structured representation of the specification content that is more convenient to analyze and manipulate.

Given a parsed AST, the generator method `astToDOM()` instantiates a running web application, returning Mosaic-backed Document Object Model (DOM) elements that can be added to a web page.

The API context supplies the data loaders used during instantiation. To use the
native SQL preview, pass `astToDOM(ast, { api: createAPIContext({ coordinator }) })`
with a coordinator that owns a `NativeSqlContext`. Table-query definitions are
parsed into native queries, and file and inline-object definitions use the
[native loaders](/api/sql/data-loading). Relative file paths still resolve
against `baseURL`, and required DuckDB extensions load before the datasets.
Generated JavaScript calls `createTable` through its API namespace so table
setup follows the runtime context as well.

Meanwhile, the `astToESM()` method instead generates JavaScript code, in the form of an ECMAScript Module (ESM), that uses the `vgplot` API. The JavaScript code listed in the examples above was generated using this method, and `astToPython()` similarly generates equivalent Python code for the [`vgplot` Python API](/vgplot/?lang=python).

For more, see the [Specification Parser & Generators Reference](/api/spec/parser-generators).

## Linked dashboard starter

The dashboard combines a slider, two plots, a brush, a color legend and a filtered table. Brush a day range in the scatter plot to filter the category counts and table. Move the slider to recompute the plotted values. The default plot attributes apply to both plots.

[json](/templates/spec/dashboard.json) · [yaml](/templates/spec/dashboard.yaml) · [js](/templates/spec/dashboard.js) · <a :href="withBase('/templates/spec/dashboard.py')" download>Python</a>

Use the same data and parameter names across the linked components. The Python starter passes named data and params explicitly. Public vg.spec and View methods also discover named local DataDef, frame and parameter values in the caller's scope; retain those direct entry points when composing applications.
