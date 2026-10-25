package specmodel

#ParserOption: {name!: string & !="", type!: string & !="", default!: string, description!: string & !=""}
#ParserParameter: {name!: string & !="", optional!: bool, default: *"" | "" | "{}"}
#ParserAPI: {
	name!: "parseSpec" | "astToDOM" | "astToESM" | "astToPython"
	parameters!: [...#ParserParameter]
	returns!:      string & !=""
	asynchronous!: bool
	description!:  string & !=""
	options!: [...#ParserOption]
	notes!: [...string & !=""]
}
parserAPIs: [...#ParserAPI] & [
	{
		name: "parseSpec"
		parameters: [{name: "spec", optional: false}, {name: "options", optional: true}]
		returns:      "SpecNode"
		asynchronous: false
		description:  "Parse a JavaScript specification object into an abstract syntax tree (AST). Parse JSON text with JSON.parse, or YAML text with a YAML parser, before calling this method."
		options: [
			{name: "components", type: "Map<string, Function>", default: "componentMap()", description: "Ordered map of component names to parser functions. The first matching component wins; a caller-supplied map replaces the built-in map."},
			{name: "transforms", type: "Set<string>", default: "transformNames()", description: "Names of allowed transform functions."},
			{name: "inputs", type: "Set<string>", default: "inputNames()", description: "Names of supported input widgets."},
			{name: "plot", type: "PlotNames", default: "plotNames()", description: "Sets of supported plot attributes, interactors, legends and marks."},
			{name: "params", type: "[string, ASTNode][]", default: "[]", description: "Named pre-parsed parameter or selection nodes to seed the parser context."},
			{name: "datasets", type: "[string, ASTNode][]", default: "[]", description: "Named pre-parsed dataset nodes to seed the parser context."},
		]
		notes: ["The AST root exposes meta, config, root, data, params and plotDefaults. Data and params are objects keyed by name. Its toJSON method produces normalized JSON; inferred selections become explicit definitions. The editor-only $schema annotation is not retained in the AST.", "Custom component, transform, input and plot registries belong to the parser context. They do not extend the strict built-in declarative schema automatically."]
	},
	{
		name: "astToDOM"
		parameters: [{name: "ast", optional: false}, {name: "options", optional: true}]
		returns:      "Promise<{element: HTMLElement | SVGSVGElement, params: Map<string, Param | Selection>}>"
		asynchronous: true
		description:  "Load data, instantiate parameters and selections, and create the running application as DOM content using the supplied vgplot API context."
		options: [
			{name: "coordinator", type: "Coordinator | undefined", default: "undefined", description: "Coordinator used to create the API context when api is omitted. If neither is supplied, the global coordinator is used. A supplied api takes precedence."},
			{name: "api", type: "API context", default: "createAPIContext({coordinator})", description: "API context providing the coordinator, named plots and extension methods. The default context uses the supplied or global coordinator and a fresh named-plots map."},
			{name: "params", type: "Map<string, Param | Selection>", default: "new Map()", description: "Live instances to reuse across specifications. Definitions whose names are already present do not replace the supplied instances."},
			{name: "baseURL", type: "string | null", default: "null", description: "Base URL used when loading data files."},
		]
		notes: ["The fulfilled value contains the root element and the active named-parameter map. Add the element to the document to display the application. Each API context can use a separate coordinator; pass shared parameter instances explicitly when linking contexts."]
	},
	{
		name: "astToESM"
		parameters: [{name: "ast", optional: false}, {name: "options", optional: true, default: "{}"}]
		returns:      "string"
		asynchronous: false
		description:  "Generate an ECMAScript module that uses the vgplot JavaScript API to load data and construct the application."
		options: [
			{name: "baseURL", type: "string | undefined", default: "undefined", description: "Base URL used when loading data files."},
			{name: "namespace", type: "string", default: "'vg'", description: "Namespace used for vgplot method calls."},
			{name: "connector", type: "'rest' | 'wasm' | undefined", default: "undefined", description: "Optional connector initialization. When omitted, generated code uses the existing coordinator connector."},
			{name: "depth", type: "number", default: "0", description: "Starting indentation depth."},
			{name: "imports", type: "Map<string, string | string[]>", default: "new Map([['@uwdata/vgplot', '* as vg']])", description: "Module imports: each key names a package, and each value specifies a namespace import or named imports."},
			{name: "preamble", type: "string | string[]", default: "undefined", description: "Code emitted after imports and before connector and data initialization."},
		]
		notes: ["The module's default export is the constructed application element. Metadata and the editor schema annotation are not runtime view arguments. Generated parameter identifiers avoid collisions with imports and retain references to parameters with arbitrary names. Object property names are quoted when required by JavaScript."]
	},
	{
		name: "astToPython"
		parameters: [{name: "ast", optional: false}]
		returns:      "string"
		asynchronous: false
		description:  "Generate Python code using the vgplot authoring API. The emitted module imports vgplot as vg and assigns its outer view to view."
		options: []
		notes: ["This method has no supported options argument; namespace and indentation are managed by its PythonCodegenContext.", "The retained emitter omits specification metadata. Use authored vg.spec(meta=...) when metadata must be preserved. Data, parameter references, configuration, plot defaults and the view are emitted through their public Python APIs. Input, legend and spacer roots retain specification headers through vg.spec. Generated local identifiers avoid collisions with imports and other definitions while preserving original data and parameter names in the specification.", "Generated string literals preserve quotes, backslashes and control characters. Dollar-prefixed strings remain literals in scalar parameter values, inline data, file names and menu option values; parameter-reference positions resolve to the generated Python variables."]
	},
]
parserAPIIndex: {for API in parserAPIs {(API.name): API}}
