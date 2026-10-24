package brushinteractors

import (
	"list"
	"strings"
	"idl.uw.edu/mosaic/api/render"
)

referenceGroups: [{name: "region", js: "js-region-5", python: "python-region-15"}, {name: "interval", js: "js-interval-6", python: "python-interval-16"}]
compatibilityNotes: [
	{group: "interval", text: "Each interactor attaches to the last preceding mark. IntervalX and intervalY force their x or y channel after caller options. Fields are inferred from that mark unless field, xfield or yfield is provided. Pixel sizes quantize SVG coordinates downward before domain inversion; zero falls back to one. Domain intervals are sorted even when the screen scale is reversed. Brush clearing removes the selection clause. Resetting an interactor only clears its local brush state; Selection.reset clears the selection itself. Peer exclusion defaults to all sibling marks and can be disabled. Crossed facets share one domain selection across per-panel brushes."},
	{group: "interval", text: "Known limitation: a plot with only a horizontal facet scale retains a malformed transform suffix in its brush groups. Use crossed facets for the runnable faceted starter; a single horizontal facet has this rendering limitation."},
	{group: "region", text: "Region selects backing channel values from SVG elements intersecting its screen rectangle, including translated facet groups, and deduplicates equal tuples. Channels are required at runtime; color resolves color, fill, then stroke. Missing channels throw an error. Peer exclusion defaults to all sibling marks. The default brush uses fill none, currentColor stroke and a 1,1 dash pattern. Native style sanitization converts names to SVG attributes and retains additional names; strict wire values allow only BrushStyles fields."},
]
_referenceText: {for Language in ["js", "python"] for Group in referenceGroups {
	let Python = Language == "python"
	(Language + "-" + Group.name): "## " + Group.name + "\n\n" + strings.Join([for Item in projection.records if Item.group == Group.name {
		let Name = strings.Join([if Python {Item.pythonName}, if !Python {Item.name}], "")
		let Select = ([for Property in projection.resolvedProperties[Item.contract] if Property.name == "select" {Property}])[0]
		"### " + Name + "\n\n`" + Name + "(" + strings.Join([if !Python {"options"}, if Python {strings.Join([for Argument in Item.python.arguments {Argument.name + "=None"}, if Item.python.extras {"**kwargs"}], ", ")}], "") + ")`\n\n" + (render.#MarkdownReferences & {value: Select.description}).text + "\n\n[Options](#" + strings.ToLower(Item.contract) + "-options).\n"
	}], "\n")
}}
_exampleReference: "\n### brush examples\n\n" + strings.Join([for Example in examples {
	"`" + Example.id + "`: " + strings.Join([for Format in ["json", "yaml", "js", "py"] {
		let Path = "/templates/interactors/brush/" + Example.id + "." + Format
		if Format != "py" {"[" + Format + "](" + Path + ")"}
		if Format == "py" {"<a :href=\"withBase('" + Path + "')\" download>Python</a>"}
	}], " · ") + ".\n"
}], "\n")
docSections: [
	for Language in ["js", "python"] for Group in referenceGroups {{path: "docs/api/vgplot/interactors.md", id: Group[Language], owner: "brush", language: Language, text: _referenceText[Language+"-"+Group.name]}},
	{path: "docs/api/vgplot/interactors.md", id: "reference-brush-helpers", owner: "brush", text: "\n### Python brush and sort helpers\n\n`brush(**kwargs)` converts snake_case keys to camelCase; `sort(**kwargs)` preserves keys. Both omit `None` and preserve other values. Use brush for brush styling and sort for mark ordering.\n"},
	{path: "docs/api/vgplot/interactors.md", id: "reference-brush", owner: "brush", text: "\n## brush options\n\nOptions use wire names; Python arguments use the names shown in their signatures.\n\n" + projection.optionReference + "\n" + strings.Join([for Note in compatibilityNotes {"**" + Note.group + ":** " + Note.text + "\n"}], "\n") + _exampleReference + "\n[Selection parameters](../core/selection).\n"},
]
referenceChecks: {
	groups: true & list.UniqueItems([for Group in referenceGroups {Group.name}])
	membership: [for Item in projection.records {true & list.Contains([for Group in referenceGroups {Group.name}], Item.group)}]
}
