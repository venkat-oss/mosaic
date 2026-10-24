package annotation

import (
	canonical "idl.uw.edu/mosaic/api/marks/annotation/model:annotationmodel"
	"strings"
	familyRender "idl.uw.edu/mosaic/api/marks/render:markrender"
	basic "idl.uw.edu/mosaic/api/marks/basic/model:basicmodel"
)

contracts:        canonical.contracts
supportContracts: canonical.supportContracts
typeExpressions:  canonical.typeExpressions
contractIndex:    canonical.contractIndex
modelChecks:      canonical.modelChecks
declarationFiles: canonical.declarationFiles
modelAdmission:   canonical

marks: [
	{
		"name":      "text"
		"contract":  "Text"
		"jsSection": "text-24"
		"profile":   "ordinary"
	},
	{
		"name":      "textX"
		"contract":  "TextX"
		"jsSection": "textX-25"
		"profile":   "ordinary"
	},
	{
		"name":      "textY"
		"contract":  "TextY"
		"jsSection": "textY-26"
		"profile":   "ordinary"
	},
	{
		"name":      "image"
		"contract":  "Image"
		"jsSection": "image-35"
		"profile":   "ordinary"
	},
	{
		"name":      "vector"
		"contract":  "Vector"
		"jsSection": "vector-31"
		"profile":   "ordinary"
	},
	{
		"name":        "vectorX"
		"contract":    "VectorX"
		"jsSection":   "vectorX-32"
		"profile":     "ordinary"
		"runtimeType": "vectoX"
	},
	{
		"name":      "vectorY"
		"contract":  "VectorY"
		"jsSection": "vectorY-33"
		"profile":   "ordinary"
	},
	{
		"name":      "spike"
		"contract":  "Spike"
		"jsSection": "spike-34"
		"profile":   "ordinary"
	},
	{
		"name":      "waffleX"
		"contract":  "WaffleX"
		"jsSection": "waffleX-68"
		"profile":   "ordinary"
	},
	{
		"name":      "waffleY"
		"contract":  "WaffleY"
		"jsSection": "waffleY-69"
		"profile":   "ordinary"
	},
]

referenceGroups: [
	{
		"title": "Text"
		"names": [
			"text",
			"textX",
			"textY",
		]
		"sections": {
			"js":     "js-Text-27"
			"python": "python-Text-58"
		}
	},
	{
		"title": "Image"
		"names": [
			"image"
		]
		"sections": {
			"js":     "js-Image-20"
			"python": "python-Image-51"
		}
	},
	{
		"title": "Vector"
		"names": [
			"vector",
			"vectorX",
			"vectorY",
			"spike",
		]
		"sections": {
			"js":     "js-Vector-29"
			"python": "python-Vector-60"
		}
	},
	{
		"title": "Waffle"
		"names": [
			"waffleX",
			"waffleY",
		]
		"sections": {
			"js":     "js-Waffle"
			"python": "python-Waffle"
		}
	},
]

let Contracts = contracts
let Supports = supportContracts
let Expressions = typeExpressions
let DeclarationFiles = declarationFiles
let Marks = marks
let Groups = referenceGroups
projection: familyRender.#MarkFamilyProjection & {
	identity: {slug: "annotation"}
	contracts:          Contracts
	supportContracts:   Supports
	typeExpressions:    Expressions
	baseContracts:      basic.contracts
	baseExpressions:    basic.typeExpressions
	externalReferences: basic.externalReferences
	baseImports: [for File in basic.declarationFiles for Name in File.contracts if ([for Contract in basic.contracts if Contract.name == Name {Contract.exported}])[0] {name: Name, owner: "basic", source: "./\(File.basename).js"}]
	declarationFiles: DeclarationFiles
	marks:            Marks
	referenceGroups:  Groups
	starters: [for Example in examples {{id: Example.id, mark: Example.mark, kind: "shared"}}]
	starterFiles: templateFiles
	referenceNotes: [{marks: ["vectorX"], text: "Known JavaScript limitation: vectorX dispatches to the misspelled vectoX runtime type and rendering raises TypeError. Declarative and Python APIs accept and serialize vectorX, but rendering uses the same JavaScript runtime."}, {marks: ["vector"], text: strings.Join([for Contract in supportContracts {"**Specification vocabulary: " + Contract.name + "**\n\n" + Contract.description}], "\n\n")}]
}
checks:      projection.checks
shapeChecks: projection.shapeChecks
files: {for Path, Source in projection.files {(Path): Source}, for Path, Source in nativeFiles {(Path): Source}}
sections:       projection.sections
schemaFragment: projection.schemaFragment
pythonSymbols:  projection.pythonSymbols
