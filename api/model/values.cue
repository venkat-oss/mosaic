package model

import "list"

#TemplateLiteralPart: {literal!: string}
#TemplateReferencePart: {reference!: #Name}
#TemplatePrimitivePart: {primitive!: "number" | "string"}
#TemplatePart: #TemplateLiteralPart | #TemplateReferencePart | #TemplatePrimitivePart

#TypeTerm: {
	kind:   "literal"
	value!: string | number | bool | null
} | {
	kind:  "primitive"
	type!: "string" | "number" | "boolean" | "null" | "any" | "never"
} | {
	kind:  "reference"
	name!: #Name
} | {
	kind: "template"
	parts!: [#TemplatePart, ...#TemplatePart]
	completion!:    "plain" | "empty-record"
	schemaAdapter!: "enumerate" | "open-string"
	suffix:         *"" | string
	if schemaAdapter == "enumerate" {
		parts: [...(#TemplateLiteralPart | #TemplateReferencePart)] & list.MaxItems(3)
	}
} | {
	kind:           "casefold"
	reference!:     #Name
	transform!:     "lowercase"
	completion!:    "empty-record"
	schemaAdapter!: "empty-object-per-member"
}

#ValueContract: {
	name!:        #Name
	description!: string
	exported!:    bool
	file!:        "PlotTypes.ts" | "CSSStyles.ts"
	if exported {description: !=""}
	(#TypeTerm | {
		kind: "enum"
		values!: [string, ...string] | [number, ...number]
	} | {
		kind: "union"
		members!: [#TypeTerm, ...#TypeTerm]
		schemaAdapter: *"any-of" | "any-of" | "unique-enum"
	} | {
		kind: "conditional"
		parameter!: {name!: #Name, default!: "any"}
		branches!: [{
			when!:  "Date" | "number"
			value!: #TypeTerm
		}, ...{
			when!:  "Date" | "number"
			value!: #TypeTerm
		}]
		fallback!:      "never"
		schemaAdapter!: "default-first-branch"
	} | {
		kind:     "host"
		adapter!: "dom-css"
		host!:    "CSSStyleDeclaration"
		omit!:    #Name
		stringProperties!: [...string]
		numberProperties!: [...string]
		additionalProperties!: "string"
	})
}
