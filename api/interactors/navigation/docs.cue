package navigationinteractors

import (
	"strings"
	"idl.uw.edu/mosaic/api/render"
)

runtimeNotes: {
	feedback:      "Drag to pan and scroll to zoom. Each directive attaches to the last preceding mark. Fields default to that mark's x and y channels. The interactor updates plot domains through selections; pass the same selections to other plots to link their domains. Selection clauses retain their source and all sibling marks as clients, and can also drive filters. An external selection update changes all listening plots. Domains are initialized by plot attributes; the selection receives its interval after a drag or wheel update. The axis-specific wrappers disable the other axis, and pan wrappers disable zoom after caller options. Omitting options creates independent selections for that interactor."
	gestureExtent: "Native JavaScript accepts zoom, panx and pany booleans or numeric extents. These controls are outside the strict declarative contract and Python signatures. The renderer resets its D3 transform at gesture end: zoom extents constrain each gesture, not the cumulative data-domain scale. With zoom=[1,2], a fresh zoom-out cannot undo a previous gesture, while repeated zoom-ins can exceed an overall twofold scale."
	binding:       "Use Selection objects for x and y. Passing null to an enabled axis throws when the runtime registers its listener. Ordinary value parameters do not implement the selection activation protocol. Python omits None values, while retaining false, zero and empty values; supplying such values does not make them valid runtime Selection objects."
}
_reference: {for Language in ["js", "python"] {
	let Python = Language == "python"
	(Language): "## pan & zoom\n\n" + strings.Join([for Item in projection.records {
		let Name = strings.Join([if Python {Item.pythonName}, if !Python {Item.name}], "")
		let Select = ([for Property in projection.resolvedProperties[Item.contract] if Property.name == "select" {Property}])[0]
		"### " + Name + "\n\n`" + Name + "(" + strings.Join([if !Python {"options = {}"}, if Python {strings.Join([for Argument in Item.python.arguments {Argument.name + "=None"}], ", ")}], "") + ")`\n\n" + (render.#MarkdownReferences & {value: Select.description}).text + "\n\n[Options](#" + strings.ToLower(Item.contract) + "-options).\n"
	}], "\n")
}}
_exampleReference: "\n### navigation examples\n\n" + strings.Join([for Example in examples {
	"`" + Example.id + "`: " + strings.Join([for Format in ["json", "yaml", "js", "py"] {
		let Path = "/templates/interactors/navigation/" + Example.id + "." + Format
		if Format != "py" {"[" + Format + "](" + Path + ")"}
		if Format == "py" {"<a :href=\"withBase('" + Path + "')\" download>Python</a>"}
	}], " · ") + ".\n"
}], "\n") + "\n" + strings.Join([for Example in nativeExamples {"JavaScript-only `" + Example.id + "`: [JavaScript](/templates/interactors/navigation/" + Example.id + ".js).\n"}], "\n")
docSections: [
	for Language, Id in {js: "js-pan-zoom-7", python: "python-pan-zoom-17"} {{path: "docs/api/vgplot/interactors.md", id: Id, owner: "navigation", language: Language, text: _reference[Language]}},
	{path: "docs/api/vgplot/interactors.md", id: "reference-navigation", owner: "navigation", text: "\n## Navigation options\n\n" + runtimeNotes.feedback + "\n\n" + projection.optionReference + "\n" + runtimeNotes.binding + "\n\n" + runtimeNotes.gestureExtent + _exampleReference + "\n[Selection parameters](../core/selection).\n"},
]
