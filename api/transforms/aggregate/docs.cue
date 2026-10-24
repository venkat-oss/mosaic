package aggregate

import (
	"strings"
)

aggregateDocs: {
	intro: """
		Aggregate transforms combine values within groups. A plot groups by its
		non-aggregate channels. JavaScript calls the SQL expression functions;
		Python helpers create dictionaries for the specification parser.
		See [SQL aggregates](/api/sql/aggregate-functions) for the query methods.
		"""
	options: """
		`distinct` selects distinct input values. `orderby`, `partitionby`, `rows`,
		`range`, `groups` and `exclude` turn the expression into a windowed aggregate.
		JavaScript uses expression methods such as `.distinct()`, `.orderby(...)`,
		`.partitionby(...)` and `.frame(vg.frameRows(...))`; Python passes these as
		keyword options. Python retains raw option keys and values, including `None`,
		and an option may override the transform discriminator. Parser normalization
		and code generation may omit null or falsy options.
		"""
	count: """
		JavaScript `count()` counts all rows. Python `count()` emits `{"count": ""}`;
		`count(None)` emits `{"count": None}`. The wire signature accepts null, an empty
		tuple, or a field argument. The parser normalizes a nullary count to an empty
		string, which is also wire-valid through the unary string-field alternative.
		"""
	quantile: """
		DuckDB `quantile` function computes a discrete quantile.
		For an even-sized group, `quantile(column, 0.5)` can differ from `median(column)`.
		"""
	targets: """
		`covariance`, `covarPop` and `geomean` have exported TypeScript interfaces,
		JavaScript functions and parser registrations, but are absent from the
		`AggregateTransform` wire union and Python API.

		The additional JavaScript-only exports below have no declarative transform
		interface, parser registration or Python helper.
		"""
}

_starterLinks: strings.Join([for Example in aggregateExamples {"- `\(Example.name)`: [YAML](/templates/transforms/aggregate/\(Example.name).yaml) · [JSON](/templates/transforms/aggregate/\(Example.name).json) · [JavaScript](/templates/transforms/aggregate/\(Example.name).js) · <a :href=\"withBase('/templates/transforms/aggregate/\(Example.name).py')\" download>Python</a>."}], "\n")

_aggregateSections: [for api in apis {
	let Arguments = strings.Join([for argument in api.arguments {argument.name + strings.Join([if !argument.required {" = \(argument.default)"}], "")}], ", ")
	"""
		### \(api.key)

		\(api.description)

		JavaScript: `\(api.key)(\(strings.Join([for argument in api.arguments {argument.name + strings.Join([if !argument.required {"?"}], "")}], ", ")))`, from `\(api.origin)`.
		\(strings.Join([if api.targets.python {"Python: `\(api.python)(\(Arguments)\(strings.Join([if len(api.arguments) > 0 {", "}], ""))**options: Any)`."}], ""))

		```ts
		\(_shape.contractProjections[api.name].declaration)```

		"""
}]

referenceSections: [{
	id:      "aggregate"
	order:   5
	content: """
		## Aggregate Transforms

		\(aggregateDocs.intro)

		\(aggregateDocs.options)

		\(aggregateDocs.count)

		\(aggregateDocs.quantile)

		\(aggregateDocs.targets)

		### Aggregate example

		\(_starterLinks)

		\(strings.Join(_aggregateSections, "\n\n"))

		### JavaScript-only Aggregate Exports

		\(strings.Join([for api in jsOnlyAPIs {"#### \(api.key)\n\n\(api.description)\n\nJavaScript: `\(api.key)(\(strings.Join([for argument in api.arguments {argument.name}], ", ")))`, from `\(api.origin)`."}], "\n\n"))

		"""
}]
