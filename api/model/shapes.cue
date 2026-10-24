package model

import "list"

#ShapeExpression: ((#TypeTerm & {kind: "primitive" | "literal" | "template"}) | {
	kind:  "named"
	name!: #Name
} | {
	kind: "enum"
	values!: [string, ...string] | [number, ...number]
} | {
	kind:   "array"
	items!: #Name
} | {
	kind: "union"
	members!: [#Name, ...#Name]
	nativeDefault?: #Name
	schemaAdapter:  *"any-of" | "any-of" | "primitive-type-array" | "unique-primitive-type-array" | "flatten-any-of" | "unique-enum" | "literal-enum" | "template-union"
} | {
	kind:          "reference"
	name!:         #Name
	expression!:   #Name
	schemaAdapter: *"reference" | "reference" | "inline"
} | {
	kind: "interface-selection"
	#InterfaceSelection
} | {
	kind:        "indexed-property"
	contract!:   #Name
	property!:   #Name
	expression!: #Name
} | {
	kind:       "finite-template"
	reference!: #Name
	prefix!:    string
} | {
	kind: "completion-string"
} | {
	kind:     "parameter"
	name!:    #Name
	default!: #Name
} | {
	kind:      "mapped"
	keys!:     #Name
	values!:   #Name
	keyName:   *"key" | #Name
	required!: bool
} | {
	kind:  "interface-union"
	base!: #Name
	alternatives!: [#Name, #Name, ...#Name]
} | {
	kind: "intersection"
	members!: [#Name, #Name, ...#Name]
	objectClosure: *"closed" | "closed" | "unspecified"
} | {
	kind:  "inline-interface"
	name!: #Name
	elideBases: *[] | [...#Name]
} | {
	kind:    "dictionary"
	values!: #Name
	keyName: *"key" | #Name
} | {
	kind: "record"
	properties!: [...#ShapeProperty]
} | {
	kind: "object"
} | {
	kind:     "host"
	adapter!: "date-time"
} | {
	kind: "tuple"
	elements!: [...{type!: #Name, label?: #Name, required: *true | bool}]
	wireArity:     *"declared" | "declared" | "all-elements"
	schemaAdapter: *"homogeneous-items" | "homogeneous-items" | "positional-items"
} | {
	kind:       "case-transform"
	reference!: #Name
	transform!: "uppercase" | "lowercase"
	typeName?:  #Name
} | {
	kind:      "application"
	shape!:    #Name
	argument?: #Name
} )

#ShapeProperty: {
	name!:                #Name
	description!:         string & !=""
	documentationAdapter: *"declared" | "declared" | "reference-only"
	required:             *false | bool
	type!:                #Name
	typescriptAlias?:     #Name
	override?:            true
}

#ShapeContract: {
	name!:                #Name
	description!:         string & !=""
	wire:                 *true | bool
	exported:             *true | bool
	documentationAdapter: *"declared" | "declared" | "reference-only"
	({
		kind:        "alias"
		expression!: #Name
		parameters: *[] | [...{name!: #Name, default!: #Name}]
		_parametersUnique: true & list.UniqueItems([for parameter in parameters {parameter.name}])
	} | {
		kind: *"interface" | "interface"
		extends: *[] | [...#ShapeBase]
		properties!: [...#ShapeProperty]
	})
}

#ExternalReference: {
	name!:             #Name
	owner!:            string & !=""
	source!:           string & !=""
	finiteExpression?: #Name
}

#ArgumentShape: {
	name!:        #Name
	description!: string & !=""
	parameter?:   #Name
	scalar!:      bool
	nullable!:    bool
	tupleSize!:   int & >=0 & <=2
	if scalar || tupleSize > 0 {parameter!: #Name}
}

#ShapeBase: #Name | {
	name!:     #Name
	operator!: "all" | "omit" | "pick" | "exclude"
	keys: *[] | [...#Name]
	if operator == "all" {keys: []}
	if operator != "all" {keys: [#Name, ...#Name]}
	_keysUnique: true & list.UniqueItems(keys)
}

#InterfaceSelection: {
	contract!: #Name
	operator!: "pick" | "omit"
	keys!: [#Name, ...#Name]
	_keysUnique: true & list.UniqueItems(keys)
}
