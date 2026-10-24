package common

import (
	"list"
	"strings"
	markProfile "idl.uw.edu/mosaic/api/marks/profile"
	"idl.uw.edu/mosaic/api/render"
)

compatibilityNotes: [
	{description: "The wire and TypeScript contracts describe channel value objects with value, scale, or interval fields. The retained source-backed mark runtime currently treats those objects as SQL expressions and cannot execute them; runnable examples use primitive field references and time-interval axis ticks."},
	{description: "ChannelDomainOptions.limit has optional tuple positions in TypeScript, while the preserved wire and native contracts require both positions."},
	{description: "Curve excludes auto. CurveOptions narrows CurveAutoOptions in TypeScript; its ParamRef branch remains an unrestricted wire string and therefore also admits auto."},
	{description: "ChannelReducers is generic in TypeScript. Its standalone native contract validates the declared Reducer default specialization."},
	{description: "A channel interval is a string in the existing wire contract, even though the conditional TypeScript Interval type can admit numbers."},
]

publicContracts: [for contract in contracts if contract.exported {contract}]
#DocCell: {
	value!: string
	text:   strings.Replace(strings.Replace(strings.Replace(strings.Replace(value, "&", "&amp;", -1), "<", "&lt;", -1), ">", "&gt;", -1), "|", "\\|", -1)
}
_contractReference: strings.Join([for index, contract in publicContracts {
	let Projection = _shape.contractProjections[contract.name]
	"## " + contract.name + "\n\n" + (render.#MarkdownReferences & {value: contract.description}).text + "\n\n" +
	strings.Join([
		if contract.kind == "alias" {"```ts\n" + Projection.body + "\n```\n"},
		if contract.kind == "interface" {
			strings.Join([if len(contract.extends) > 0 {"Extends " + strings.Join([for base in _shape.baseSelections[contract.name] {"[`" + base.typescript + "`](#" + strings.ToLower(base.name) + ")"}], ", ") + ".\n\n"}], "") +
			"| Property | Type | Presence | Description |\n| --- | --- | --- | --- |\n" + strings.Join([for property in contract.properties {
				let Prior = [for C in list.Take(publicContracts, index) if C.kind == "interface" for P in C.properties if P.name == property.name if P.description != "" if strings.HasPrefix(property.description, P.description) {{name: C.name, description: P.description}}]
				let Description = strings.Join([
					if len(Prior) == 0 {(render.#MarkdownReferences & {value: property.description}).text},
					if len(Prior) > 0 {"See [" + Prior[0].name + "." + property.name + "](#" + strings.ToLower(Prior[0].name) + "). " + (render.#MarkdownReferences & {value: strings.TrimSpace(strings.TrimPrefix(property.description, Prior[0].description))}).text},
				], "")
				"| `" + property.name + "` | `` " + (#DocCell & {value: _shape.projections[property.type].typescript}).text + " `` | " + strings.Join([if property.required {"required"}, if !property.required {"optional"}], "") + " | " + strings.Replace((#DocCell & {value: Description}).text, "\n", "<br>", -1) + " |"
			}], "\n") + "\n"
		},
	], "") + "\n"
}], "\n")
_pythonReference: strings.Join([for factory in pythonFactories { let Factory = factory
	"### " + factory.name + "\n\n" + factory.description + "\n\n```python\n" + (markProfile.#PythonFactoryProjection & {factory: Factory}).signature + "\n```\n"
}], "\n")
#CommonDownload: {
	name!:      string
	extension!: "json" | "yaml" | "js" | "py"
	text:       string
	if extension == "py" {text: "<a :href=\"withBase('/templates/marks/common/\(name).py')\" download>Python</a>"}
	if extension != "py" {text: "[" + extension + "](/templates/marks/common/" + name + "." + extension + ")"}
}

_commonIntroduction: "Marks visualize data through named channels, including position, color, opacity, and size. " + contractIndex.ChannelName.description + " The [common mark contracts](../spec/common-marks) describe channel values, shared options, and target-specific behavior.\n\n"
markIntroductions: {
	javascript: "\n# Marks\n\n" + _commonIntroduction + "Most mark functions accept a data source and an options object. Use `from(tableName)` for database data, or pass an array for inline data. Passing only an options object to an ordinary mark uses a single empty row; reference marks such as axes, grids, and frames can omit data.\n\n```js\nimport * as vg from '@uwdata/vgplot';\n\nvg.plot(vg.dot(vg.from('data'), {x: 'x', y: 'y'}));\n```\n\nMarks follow [Observable Plot](https://observablehq.com/plot/features/marks) semantics. Mark variants can imply different scale types; for example, `barY` uses an ordinal horizontal scale while `rectY` uses a continuous one.\n\n" + "[Examples and target-specific authoring](../spec/common-marks#examples).\n\n"
	python: "\n# Marks\n\n" + _commonIntroduction + "Use a named mark helper or `vg.mark(name, data, **options)` to create marks. Data can be a `DataDef`, a `vg.source(tableName)` reference, an inline array, or a supported frame. Named helpers omit `UNSET` keyword values; the generic `vg.mark` retains the supplied encoding values.\n\n```python\nimport vgplot as vg\n\nvg.plot(vg.mark('dot', vg.source('data'), x='x', y='y'));\n```\n\n`vg.channels(**kwargs)` preserves channel keys and values. `vg.directive(key, value)` creates a plot directive. For source-backed marks, the data options " + strings.Join([for option in dataOptions {"`" + option.python + "` → `" + option.wire + "`"}], ", ") + " are attached to the data reference. See [Python helpers](../spec/common-marks#python-helpers) for signatures.\n\n" + "[Examples and target-specific authoring](../spec/common-marks#examples).\n\n"
}
docFiles: {
	"docs/api/spec/common-marks.md": """
 <script setup>
 import { withBase } from 'vitepress';
 </script>

 # Common mark contracts

 Shared channels and options for mark families. Inherited fields are documented under their parent contract.

 ## Examples

 \(authoringReference)

 Python examples use `mark`, `channels`, and `directive`; JavaScript examples use named mark factories.

 ## Target behavior

 \(strings.Join([for note in compatibilityNotes {"- " + note.description}], "\n"))

 The standalone native definitions are available in `packages/vgplot/spec/src/generated/common-marks.cue`. Use the composed schema to validate complete plot specifications.

 ## Python helpers

 \(_pythonReference)

 ## Data options

 | Python option | Wire property | Meaning |
 | --- | --- | --- |
 \(strings.Join([for option in dataOptions {"| `" + option.python + "` | `" + option.wire + "` | " + strings.Replace((#DocCell & {value: option.description}).text, "\n", "<br>", -1) + " |"}], "\n"))

 ## Contract reference

 \(strings.TrimRight(_contractReference, "\n"))
 """
}
