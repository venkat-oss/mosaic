package plotattributes

import (
	"strings"
	"idl.uw.edu/mosaic/api/render"
)

runtimeDocs: {
	absentRoute: "This attribute is admitted by the declarative schema and serializes in Python, but the JavaScript renderer has no route for it. Rendering rejects with the error below."
	label:       labelRoute.description
	margins:     "Python uses `vg.margins(top=None, right=None, bottom=None, left=None, **kwargs)`, with each margin passed separately. `None` entries are omitted, falsy values are retained, and extra keyword entries are preserved. JavaScript uses a single object and sets only its defined sides."
	name:        "Names are registered in the calling API context, or in the default named-plot registry when no local context is supplied. Naming preserves the original plot identity."
}
_methodSections: {
	for language in ["js", "python"] {
		(language): strings.Join([for Attribute in attributes {
			let Signature = {
				js: string
				if Attribute.jsKind == "name" {js: "\(Attribute.name)(name)"}
				if Attribute.jsKind == "margins" {js: "\(Attribute.name)(object)"}
				if Attribute.jsKind == "simple" || Attribute.jsKind == "margin" {js: "\(Attribute.name)(value)"}
				python: string
				if Attribute.python.kind == "value" {python: "vg.\(Attribute.python.name)(value\(strings.Join([if Attribute.python.default == "true" {"=True"}], "")))"}
				if Attribute.python.kind == "margins" {python: "vg.\(Attribute.python.name)(\(strings.Join([for side in pythonSides {"\(side.side.name)=None"}], ", ")), **kwargs)"}
			}[language]
			"| [`\(Signature)`](#\(strings.ToLower(Attribute.name))) |"
		}], "\n")
	}
}
_referenceDescription: "\n## Plot attribute reference\n\n" + strings.Join([for Attribute in attributes {
	"### \(Attribute.name)\n\n" + (render.#MarkdownReferences & {value: Attribute.description}).text + "\n" + strings.Join([
		if Attribute.jsKind == "margins" {"\n\(runtimeDocs.margins)\n"},
		if Attribute.jsKind == "name" {"\n\(runtimeDocs.name)\n"},
		if Attribute.route.kind == "absent" {"\n**Known limitation**: \(runtimeDocs.absentRoute) Error: `Unrecognized plot attribute: \(Attribute.name)`.\n"},
	], "")
}], "\n")
_starterSection: "\n### Plot attribute examples\n\n" + strings.Join([for example in attributeExamples {
	"`\(example.name)`: [JSON](/templates/attributes/plot/\(example.name).json) · [YAML](/templates/attributes/plot/\(example.name).yaml) · [JavaScript](/templates/attributes/plot/\(example.name).js) · <a :href=\"withBase('/templates/attributes/plot/\(example.name).py')\" download>Python</a>.\n"
}], "\n")
referenceSections: [
	{path: "docs/api/vgplot/attributes.md", id: "js-Plot-Attributes-23", owner: "plot", language: "js", text: "\n| Directive |\n| --- |\n\(_methodSections.js)\n"},
	{path: "docs/api/vgplot/attributes.md", id: "python-Plot-Attributes-37", owner: "plot", language: "python", text: "\n## Plot Attributes\n\n| Directive |\n| --- |\n\(_methodSections.python)\n"},
	{path: "docs/api/vgplot/attributes.md", id: "reference-plot", owner: "plot", text: _referenceDescription + _starterSection},
]
