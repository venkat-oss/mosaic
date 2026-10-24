package pointinteractors

import (
	"list"
	"strings"
	"idl.uw.edu/mosaic/api/render"
)

referenceGroups: [
	{name: "toggle", js: "js-toggle-3", python: "python-toggle-13"},
	{name: "nearest", js: "js-nearest-4", python: "python-nearest-14"},
	{name: "highlight", js: "js-highlight-8", python: "python-highlight-18"},
]
compatibilityNotes: [
	{group: "toggle", text: "Interactors attach to the last preceding mark. Toggle aliases force x, y, z or color; color resolves color, fill, then stroke. Fields are inferred from encodings. Click again to clear; shift/meta-click combines values. Compound channels produce tuples. Native listMatch and unnest options are outside the wire format."},
	{group: "nearest", text: "nearest, nearestX and nearestY force xy, x and y pointers. Fields default to the preceding mark; maxRadius defaults to 40. Python’s singular field argument is ignored by native inference and rejected by wire validation; fixed wrappers also reject fields, max_radius and extra kwargs. Use populated data with empty:true for an initially empty selection. Pointerleave clears a Selection but retains a plain Param value."},
	{group: "highlight", text: "Highlight queries its Selection against the last mark’s data and dims unselected SVG elements, defaulting to opacity 0.2. Use queried data for active predicates. Clearing restores prior attributes, including literal null attributes. Python accepts channels and camelized extra kwargs, omits None, and lets select override the default; channels is not a wire property."},
]
_referenceText: {for Language in ["js", "python"] for Group in referenceGroups {
	let Python = Language == "python"
	(Language + "-" + Group.name): "## " + Group.name + "\n\n" + strings.Join([for Item in projection.records if Item.group == Group.name {
		let Name = strings.Join([if Python {Item.pythonName}, if !Python {Item.name}], "")
		let Select = ([for Property in projection.resolvedProperties[Item.contract] if Property.name == "select" {Property}])[0]
		"### " + Name + "\n\n`" + Name + "(" + strings.Join([if !Python {"options"}, if Python {strings.Join([for Argument in Item.python.arguments {Argument.name + "=None"}, if Item.python.extras {"**kwargs"}], ", ")}], "") + ")`\n\n" + (render.#MarkdownReferences & {value: Select.description}).text + "\n\n[Options](#" + strings.ToLower(Item.contract) + "-options).\n"
	}], "\n")
}}
_exampleReference: "\n### point examples\n\n" + strings.Join([for Example in examples {
	"`" + Example.id + "`: " + strings.Join([for Format in ["json", "yaml", "js", "py"] {
		let Path = "/templates/interactors/point/" + Example.id + "." + Format
		if Format != "py" {"[" + Format + "](" + Path + ")"}
		if Format == "py" {"<a :href=\"withBase('" + Path + "')\" download>Python</a>"}
	}], " · ") + ".\n"
}], "\n") + "\n" + strings.Join([for Example in nativeExamples {"JavaScript-only `" + Example.id + "`: [JavaScript](/templates/interactors/point/" + Example.id + ".js).\n"}], "\n")
docSections: [
	for Language in ["js", "python"] for Group in referenceGroups {{path: "docs/api/vgplot/interactors.md", id: Group[Language], owner: "point", language: Language, text: _referenceText[Language+"-"+Group.name]}},
	{path: "docs/api/vgplot/interactors.md", id: "reference-point", owner: "point", text: "\n## point options\n\nOptions use wire names; Python arguments use the names shown in their signatures.\n\n" + projection.optionReference + "\n" + strings.Join([for Note in compatibilityNotes {"**" + Note.group + ":** " + Note.text + "\n"}], "\n") + _exampleReference + "\n[Selection parameters](../core/selection).\n"},
]
referenceChecks: {
	groups: true & list.UniqueItems([for Group in referenceGroups {Group.name}])
	membership: [for Item in projection.records {true & list.Contains([for Group in referenceGroups {Group.name}], Item.group)}]
}
