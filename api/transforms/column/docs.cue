package column

import (
	"encoding/json"
	"list"
	"strings"
)

columnDocs: {
	intro: """
		Column transforms derive one value per source row. JavaScript calls the
		existing SQL or plot function; Python builds a declarative dictionary for
		the specification parser. These host representations have different purposes.
		See the [SQL expression API](/api/sql/expressions) for expression and query methods.
		"""
	options: """
		Python helpers have the signature `helper(col: TransformArg, **options: Any)`.
		Their options retain raw keys and values, including `None`, and may override
		the transform's discriminator. This permissive authoring behavior does not
		broaden the declared wire schema. A unary wire argument may be a scalar or a
		singleton tuple; empty and longer tuples are rejected by the owning contract.
		"""
	expressions: """
		`sql` is a JavaScript template tag and a Python `sql(expr: str)` helper.
		A declarative SQL expression uses `{"sql": "x + $offset"}`. `$offset` binds
		a value parameter; `$$column` binds a column-valued parameter. Quoted SQL
		strings and identifiers retain their existing tokenization behavior.

		`SQLExpression` also declares an optional `label`. The current parser drops
		that label when normalizing an expression. `AggregateExpression` is declared by the wire and TypeScript
		contracts, but the parser retains an `agg` object as a literal instead of
		constructing an aggregate expression. Use the supported aggregate helpers
		when an evaluated aggregate is needed.
		"""
	spatial: """
		Spatial transforms require DuckDB's `spatial` extension. Declare it in
		`config.extensions`, or install and load it before executing JavaScript queries.
		Use the geojson transform to pass geometry results to a geo mark.
		"""
	shared: """
		These field and frame types also appear in aggregate and window contracts.
		They describe argument admission; the query engines implement their
		semantics. Native JavaScript Date values adapt to date-time strings in the
		wire schema for date transforms. This differs from a parameter's `date`
		property, whose existing wire contract is an unrestricted string.
		"""
}

#PropertyTable: {
	properties!: [...]
	text: "| Property | Type | Required | Description |\n| --- | --- | --- | --- |\n" + strings.Join([for property in properties {
		"| `\(property.name)` | `\(strings.Replace(_shape.projections[property.type].typescript, "|", "\\|", -1))` | \(property.required) | \(strings.Replace(strings.Replace(property.description, "\n", " ", -1), "|", "\\|", -1)) |"
	}], "\n")
}

_columnSections: [for api in apis {
	"""
		### \(api.key)

		\(api.description)

		JavaScript: `\(api.key)(column\(strings.Join([if api.key == "bin" {", options?"}], "")))`, from `\(api.origin)`.
		Python: `\(api.python)(\(api.argument.name): \(api.argument.type), **options: Any)`.

		\((#PropertyTable & {properties: _shape.effectiveProperties[api.name]}).text)

		"""
}]

_expressionSections: [for name in ["Expression", "SQLExpression", "AggregateExpression"] {
	"### \(name)\n\n\(contractIndex[name].description)\n\n```ts\n\(_shape.contractProjections[name].declaration)```"
}]

referenceSections: [{
	id:      "column"
	order:   4
	content: """
		## Expressions and Column Transforms

		\(columnDocs.intro)

		\(columnDocs.options)

		\(columnDocs.spatial)

		### Column examples

		\(strings.Join([for Example in columnExamples {"- `\(Example.key)`: [YAML](/templates/transforms/column/\(Example.key).yaml) · [JSON](/templates/transforms/column/\(Example.key).json) · [JavaScript](/templates/transforms/column/\(Example.key).js) · <a :href=\"withBase('/templates/transforms/column/\(Example.key).py')\" download>Python</a>."}], "\n"))
		- `sql`: [YAML](/templates/transforms/column/sql.yaml) · [JSON](/templates/transforms/column/sql.json) · [JavaScript](/templates/transforms/column/sql.js) · <a :href="withBase('/templates/transforms/column/sql.py')" download>Python</a>.
		- [TypeScript aggregate expression](/templates/transforms/column/aggregate-expression.ts).

		\(strings.Join(_columnSections, "\n\n"))

		## Expression Contracts

		\(columnDocs.expressions)

		`AggregateExpression` has the optional label illustrated by the example above.
		The SQL example's initial expression is `\(sqlWireExpression.sql)` with
		`\(sqlExample.parameter) = \(json.Marshal(sqlExample.value))`.

		\(strings.Join(_expressionSections, "\n\n"))

		## Shared Field and Frame Contracts

		\(columnDocs.shared)

		\(strings.Join([for contract in publicContracts if !list.Contains([for api in apis {api.name}], contract.name) if !list.Contains(["Expression", "SQLExpression", "AggregateExpression"], contract.name) {
		"### \(contract.name)\n\n\(contract.description)\n\n```ts\n\(_shape.contractProjections[contract.name].declaration)```"
	}], "\n\n"))

		### Argument Shapes

		| Shape | Meaning |
		| --- | --- |
		\(strings.Join([for shape in argumentShapes {"| `\(shape.name)\(strings.Join([if shape.parameter != _|_ {"<\(shape.parameter)>"}], ""))` | \(shape.description) |"}], "\n"))

		"""
}]
