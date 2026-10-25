package rootspec

import (
	"strings"
	"idl.uw.edu/mosaic/api/render"
	root "idl.uw.edu/mosaic/api/spec/model:specmodel"
)

_overviewPrelude: "<script setup>\n  import { coordinator } from '@uwdata/vgplot';\n  import { withBase } from 'vitepress';\n  coordinator().clear();\n</script>\n\n# Mosaic Declarative Specifications\n\nThe `mosaic-spec` package enables declarative specification of Mosaic applications as JSON or YAML files. The package provides a specification parser, as well as generators to create either running applications or JavaScript code.\n\nFor example, below is an example of a declarative specification, in either YAML or equivalent JSON, for a simple line chart. The JavaScript and Python tabs show equivalent code that builds the same specification using the [`vgplot`](/vgplot/) API in each language.\n\n<Example spec=\"/specs/yaml/line.yaml\" />\n\n::: code-group\n<<< @/public/specs/yaml/line.yaml [YAML]\n<<< @/public/specs/json/line.json [JSON]\n<<< @/public/specs/esm/line.js [JavaScript]\n<<< @/public/specs/python/line.py [Python]\n:::\n\nUsing a declarative specification, we can describe an application in a standard file format, enabling portability across platforms. The same spec can be authored as YAML/JSON or built programmatically with the `vgplot` API in either JavaScript or Python (see the [Python API](/vgplot/?lang=python)). For example, the [Mosaic Jupyter widget](/jupyter/) uses this format to pass visualization and dashboard definitions from Python to the browser.\n\n::: tip\nThe [TypeScript types in the `@uwdata/mosaic-spec` package](https://github.com/uwdata/mosaic/tree/main/packages/vgplot/spec/src/spec) provide comprehensive documentation of Mosaic declarative specifications.\n:::\n\n## Specification Format\n\nHere is a slightly more complicated example, in which a dynamic `Param` value is added to the data before visualizing it.\n\n<Example spec=\"/specs/yaml/bias.yaml\" />\n\n::: code-group\n<<< @/public/specs/yaml/bias.yaml [YAML]\n<<< @/public/specs/json/bias.json [JSON]\n<<< @/public/specs/esm/bias.js [JavaScript]\n<<< @/public/specs/python/bias.py [Python]\n:::\n\nThe example above includes descriptive metadata, `data` and `params` definitions, and nested components: an input `slider` and `plot` are positioned using a `vconcat` layout. The `plot` uses a SQL expression that includes a `Param` reference (`$point`) to define a dynamic `y` encoding channel.\n\n"
_overviewRuntime: "For more, see the [Specification Format Reference](/api/spec/format).\n\n## Parser & Generators Format\n\nThe `parseSpec()` method parses a specification in JSON format into an _abstract syntax tree_ (AST): a structured representation of the specification content that is more convenient to analyze and manipulate.\n\nGiven a parsed AST, the generator method `astToDOM()` instantiates a running web application, returning Mosaic-backed Document Object Model (DOM) elements that can be added to a web page.\n\nThe API context supplies the data loaders used during instantiation. To use the native SQL preview, pass `astToDOM(ast, { coordinator })` with a coordinator that owns a `NativeSqlContext`. Table-query definitions are parsed into native queries, and file and inline-object definitions use the [native loaders](/api/sql/data-loading). Relative file paths still resolve against `baseURL`, and required DuckDB extensions load before the datasets. Generated JavaScript calls `createTable` through its API namespace so table setup follows the runtime context as well.\n\nSQL expressions and window frames also use that context. In an expression such as `{ sql: \"$$field + $offset\" }`, `$$field` binds a live column name and `$offset` binds a live scalar value. The JSON/YAML specification and Python authoring syntax remain the same; JavaScript instantiation parses SQL into the native tree. Selections created by the specification belong to its coordinator.\n\nMeanwhile, the `astToESM()` method instead generates JavaScript code, in the form of an ECMAScript Module (ESM), that uses the `vgplot` API. The JavaScript code listed in the examples above was generated using this method, and `astToPython()` similarly generates equivalent Python code for the [`vgplot` Python API](/vgplot/?lang=python).\n\nFor more, see the [Specification Parser & Generators Reference](/api/spec/parser-generators).\n"
_parserExamples: {
	"parseSpec":   "```js\nimport { parseSpec } from \"@uwdata/mosaic-spec\";\n\n// declarative specification in JSON format\nconst spec = {\n  plot: [\n    {\n      mark: \"lineY\",\n      data: { from: \"table\" },\n      x: \"date\",\n      y: \"value\"\n    }\n  ],\n  width: 640,\n  height: 200\n};\n\n// parse specification to internal AST (abstract syntax tree)\nconst ast = parseSpec(spec);\n\n// serialize back to a normalized JSON format\nconst json = ast.toJSON();\n```\n"
	"astToDOM":    "```js\nimport { astToDOM } from \"@uwdata/mosaic-spec\";\n\n// instantiate a running application\n// assumes standard browser facilities in globabl variable `window`\nconst {\n  element, // root DOM element of the application\n  params   // Map of all named Params and Selections\n} = await astToDOM(ast);\n\n// add application to current web page\ndocument.body.appendChild(element);\n```\n"
	"astToESM":    "```js\nimport { astToESM } from \"@uwdata/mosaic-spec\";\n\n// generate ESM (ECMAScript Module) code\nconst code = astToESM(ast);\n```\n"
	"astToPython": "```js\nimport { astToPython } from \"@uwdata/mosaic-spec\";\n\n// generate Python code\nconst code = astToPython(ast);\n```\n"
}

_docTypes: render.#ShapeProjection & {contracts: [], expressions: root.typeExpressions, externalReferences: root.externalReferences}
#DocCell: {
	value!: string
	let Value = value
	text: strings.Replace(strings.Replace((render.#MarkdownReferences & {value: Value}).text, "|", "\\|", -1), "\n", "<br>", -1)
}

_headerReference: root.contractIndex.SpecHead.description + "\n\n| Property | Type | Required | Description |\n| --- | --- | --- | --- |\n" + strings.Join([for Field in root.contractIndex.SpecHead.fields {"| `" + Field.name + "` | `" + (#DocCell & {value: _docTypes.projections[Field.type].typescript}).text + "` | " + strings.Join([if Field.required {"Yes"}, if !Field.required {"No"}], "") + " | " + (#DocCell & {value: Field.description}).text + " |"}], "\n") + "\n\n"
_componentReference: root.unionIndex.SpecComponent.description + " The supported component contracts are " + strings.Join([for Name in root.componentTypes {"`" + Name + "`"}], ", ") + ".\n\n"
_dashboardReference: "## Linked dashboard starter\n\nThe dashboard combines a slider, two plots, a brush, a color legend and a filtered table. Brush a day range in the scatter plot to filter the category counts and table. Move the slider to recompute the plotted values. The default plot attributes apply to both plots.\n\n" + strings.Join([for Format in ["json", "yaml", "js", "py"] {
	let Path = "/templates/spec/" + dashboard.id + "." + Format
	if Format != "py" {"[" + Format + "](" + Path + ")"}
	if Format == "py" {"<a :href=\"withBase('" + Path + "')\" download>Python</a>"}
}], " · ") + "\n\nUse the same data and parameter names across the linked components. The Python starter passes named data and params explicitly. Public vg.spec and View methods also discover named local DataDef, frame and parameter values in the caller's scope; retain those direct entry points when composing applications.\n\n"
_methodReference: strings.Join([for API in root.parserAPIs {
	"## " + API.name + "\n\n`" + API.name + "(" + strings.Join([for Parameter in API.parameters {Parameter.name + strings.Join([if Parameter.default != "" {" = " + Parameter.default}], "")}], ", ") + ")`\n\n" + API.description + "\n\nReturns `" + API.returns + "`.\n\n" + strings.Join([if len(API.options) > 0 {"The supported options are:\n\n| Option | Type | Default | Description |\n| --- | --- | --- | --- |\n" + strings.Join([for Option in API.options {"| `" + Option.name + "` | `" + (#DocCell & {value: Option.type}).text + "` | `" + (#DocCell & {value: Option.default}).text + "` | " + (#DocCell & {value: Option.description}).text + " |"}], "\n") + "\n\n"}], "") + strings.Join([for Note in API.notes {Note + "\n"}], "\n") + "\n### Example\n\n" + _parserExamples[API.name] + "\n"
}], "\n")
_contractReference: "## Root specification contracts\n\n" + root.specDescription + " It combines the specification header with one component.\n\n" + _headerReference + _componentReference + strings.Join([for Contract in root.contracts if Contract.name != "SpecHead" {
	"### " + Contract.name + "\n\n" + Contract.description + "\n\n" + strings.Join([
		if Contract.kind == "record" {"Names map to `" + _docTypes.projections[Contract.value].typescript + "` definitions.\n\n"}
		if Contract.kind == "interface" {"| Property | Type | Required | Description |\n| --- | --- | --- | --- |\n" + strings.Join([for Field in Contract.fields {"| `" + Field.name + "` | `" + (#DocCell & {value: _docTypes.projections[Field.type].typescript}).text + "` | " + strings.Join([if Field.required {"Yes"}, if !Field.required {"No"}], "") + " | " + (#DocCell & {value: Field.description}).text + " |"}], "\n") + "\n\n"}
		if Contract.open {"Additional properties are admitted by this contract.\n\n"}
		if len(Contract.extends) > 0 {"Inherits " + strings.Join([for Name in Contract.extends {"`" + Name + "`"}], ", ") + ".\n\n"}
	], "")
}], "\n") + "See the [format reference](./format) for data loading, parameter and layout examples, and the [plot API](../vgplot/marks) for concrete mark contracts.\n\n"
docFiles: {
	"docs/spec/index.md":                 strings.TrimRight(_overviewPrelude+_headerReference+_componentReference+_overviewRuntime+"\n"+_dashboardReference, "\n") + "\n"
	"docs/api/spec/parser-generators.md": strings.TrimRight("# Specification Parser & Generators\n\nMethods to parse declarative specifications and generate applications or code as output.\n\n"+_methodReference+_contractReference+_pythonReference, "\n") + "\n"
}
docChecks: {
	types: _docTypes.checks
	methodNames: [for Name in ["parseSpec", "astToDOM", "astToESM", "astToPython"] {true & (root.parserAPIIndex[Name].name == Name)}]
}

_pythonReference: "## Python root authoring\n\nThe Python entry points retain their direct runtime implementations. These contracts describe their public signatures and target applicability.\n\n" + strings.Join([for API in root.pythonRuntimeAPIs {
	"### " + API.name + "\n\n`" + API.name + "(" + strings.Join([for Index, Parameter in API.parameters {
		strings.Join([
			if Parameter.kind == "KEYWORD_ONLY" if Index == 0 {"*, "}
			if Parameter.kind == "KEYWORD_ONLY" if Index > 0 if API.parameters[Index-1].kind == "POSITIONAL_OR_KEYWORD" {"*, "}
			if Parameter.kind == "VAR_POSITIONAL" {"*"}
			if Parameter.kind == "VAR_KEYWORD" {"**"}
		], "") + Parameter.name + strings.Join([if Parameter.annotation != "" {": " + Parameter.annotation}], "") + strings.Join([if Parameter.default != "required" {"=" + Parameter.default}], "")
	}], ", ") + ")`\n\n" + API.description + "\n\n" + strings.Join([if API.callerScope {"This entry point inspects its caller's scope. Keep its direct binding; a forwarding wrapper can change data and parameter discovery.\n\n"}], "") + "Python target; return annotation `" + API.returns + "`.\n\n"
}], "\n")
