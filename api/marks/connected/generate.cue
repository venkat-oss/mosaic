package connected

import (
	canonical "idl.uw.edu/mosaic/api/marks/connected/model:connectedmodel"
	familyRender "idl.uw.edu/mosaic/api/marks/render:markrender"
)

contracts:          canonical.contracts
typeExpressions:    canonical.typeExpressions
contractIndex:      canonical.contractIndex
modelChecks:        canonical.modelChecks
referenceNotes:     canonical.referenceNotes
declarationFiles:   canonical.declarationFiles
externalReferences: canonical.externalReferences
modelAdmission:     canonical

marks: [
	{
		"name":      "area"
		"contract":  "Area"
		"jsSection": "area-5"
		"profile":   "ordinary"
	},
	{
		"name":      "areaX"
		"contract":  "AreaX"
		"jsSection": "areaX-6"
		"profile":   "ordinary"
	},
	{
		"name":      "areaY"
		"contract":  "AreaY"
		"jsSection": "areaY-7"
		"profile":   "ordinary"
	},
	{
		"name":      "line"
		"contract":  "Line"
		"jsSection": "line-8"
		"profile":   "ordinary"
	},
	{
		"name":      "lineX"
		"contract":  "LineX"
		"jsSection": "lineX-9"
		"profile":   "ordinary"
	},
	{
		"name":      "lineY"
		"contract":  "LineY"
		"jsSection": "lineY-10"
		"profile":   "ordinary"
	},
	{
		"name":      "arrow"
		"contract":  "Arrow"
		"jsSection": "arrow-54"
		"profile":   "ordinary"
	},
	{
		"name":      "link"
		"contract":  "Link"
		"jsSection": "link-55"
		"profile":   "ordinary"
	},
]

referenceGroups: [
	{
		"title": "Area"
		"names": [
			"area",
			"areaX",
			"areaY",
		]
		"sections": {
			"js":     "js-Area-3"
			"python": "python-Area-34"
		}
	},
	{
		"title": "Arrow"
		"names": [
			"arrow"
		]
		"sections": {
			"js":     "js-Arrow-4"
			"python": "python-Arrow-35"
		}
	},
	{
		"title": "Line"
		"names": [
			"line",
			"lineX",
			"lineY",
		]
		"sections": {
			"js":     "js-Line-21"
			"python": "python-Line-52"
		}
	},
	{
		"title": "Link"
		"names": [
			"link"
		]
		"sections": {
			"js":     "js-Link-23"
			"python": "python-Link-54"
		}
	},
]

let Contracts = contracts
let Expressions = typeExpressions
let External = externalReferences
let DeclarationFiles = declarationFiles
let Marks = marks
let Groups = referenceGroups
let TemplateFiles = templateFiles
let ReferenceNotes = referenceNotes
let Starters = [for example in examples {{id: example.id, mark: example.mark, kind: "shared"}}, for example in nativeExamples {{id: example.id, mark: example.mark, kind: "javascript"}}]
projection: familyRender.#MarkFamilyProjection & {
	identity: {slug: "connected"}
	contracts:          Contracts
	typeExpressions:    Expressions
	externalReferences: External
	declarationFiles:   DeclarationFiles
	marks:              Marks
	referenceGroups:    Groups
	referenceNotes:     ReferenceNotes
	starters:           Starters
	starterFiles:       TemplateFiles
}
checks:         projection.checks
shapeChecks:    projection.shapeChecks
files:          projection.files
sections:       projection.sections
schemaFragment: projection.schemaFragment
pythonSymbols:  projection.pythonSymbols
