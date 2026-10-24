package render

import (
	"encoding/json"
	"list"
	"strings"
	"idl.uw.edu/mosaic/api/model"
)

#ShapeExpressionProjection: {
	expression!: model.#ShapeExpression
	previous!: [string]: _
	argumentShapes: *{} | {[string]: model.#ArgumentShape}
	finiteValues: *[] | [...string]
	finite: bool
	if expression.kind == "literal" {finite: (expression.value & string) != _|_}
	if !list.Contains(["enum", "reference", "indexed-property", "finite-template", "union", "literal"], expression.kind) {finite: false}
	objectFields?: [...{name: string, native: string, schema: _, required: bool}]
	propertyBranches?: [...[...model.#ShapeProperty]]
	nativeAlternatives?: [...string]
	interfaceProperties: *{} | {[string]: [...model.#ShapeProperty]}
	contractIndex: *{} | {[string]: model.#ShapeContract}
	aliasSelections: *{} | {[string]: model.#InterfaceSelection}
	let E = expression
	let P = previous

	nativeAlternativesRequired: bool
	if list.Contains(["union", "interface-union", "application"], E.kind) {nativeAlternativesRequired: true}
	if !list.Contains(["union", "interface-union", "application", "tuple", "indexed-property", "parameter"], E.kind) {nativeAlternativesRequired: false}
	if E.kind == "indexed-property" {nativeAlternativesRequired: P[E.expression].nativeAlternativesRequired}
	if E.kind == "parameter" {nativeAlternativesRequired: P[E.default].nativeAlternativesRequired}
	if nativeAlternativesRequired {nativeAlternatives!: [...string]}
	if E.kind == "named" {
		typescript: E.name
		native:     "#\(E.name)"
		schema: {"$ref": "#/definitions/\(E.name)"}
	}
	if list.Contains(["primitive", "literal", "template"], E.kind) {
		_projection: #TypeTermProjection & {term: E, index: {}}
		typescript: _projection.typescript
		native:     _projection.native
		schema:     _projection.schemaBranches[0]

		if E.kind == "literal" if (E.value & string) != _|_ {finiteValues: [E.value]}
		if E.kind == "primitive" {primitiveType: E.type}
		if E.kind == "template" if E.schemaAdapter == "open-string" {primitiveType: "string"}
	}
	if E.kind == "enum" {
		finite: (E.values[0] & string) != _|_
		if (E.values[0] & string) != _|_ {finiteValues: E.values}
		typescript: strings.Join([for enumValue in E.values {(#TypeScriptLiteral & {value: enumValue}).text}], " | ")
		native: strings.Join([for value in E.values {json.Marshal(value)}], " | ")
		schema: {
			enum: E.values
			if (E.values[0] & string) != _|_ {type: "string"}
			if (E.values[0] & number) != _|_ {type: "number"}
		}
	}
	if E.kind == "array" {
		typescript: "Array<\(P[E.items].typescript)>"
		native:     "[...\(P[E.items].native)]"
		schema: {items: P[E.items].schema, type: "array"}
	}
	if E.kind == "union" {
		nativeAlternatives: [for Name in E.members {P[Name].native}]
		typescript: strings.Join([for name in E.members {P[name].typescript}], " | ")
		native: "(\(strings.Join([for name in E.members {strings.Join([if E.nativeDefault != _|_ if E.nativeDefault == name {"*"}], "") + P[name].native}], " | ")))"
		finite: len([for name in E.members if P[name].finite {name}]) == len(E.members)
		if finite {
			let Values = list.Concat([for name in E.members {P[name].finiteValues}])
			finiteValues: [for i, value in Values if !list.Contains(list.Take(Values, i), value) {value}]
		}
		if E.schemaAdapter == "literal-enum" {
			let Types = [for name in E.members {P[name].schema.type}]
			schema: {enum: [for name in E.members {P[name].schema.const}], type: [for i, value in Types if !list.Contains(list.Take(Types, i), value) {value}]}
		}
		if E.schemaAdapter == "template-union" {schema: anyOf: list.Concat([for name in E.members {( {branches: [...], if P[name].templateBranches != _|_ {branches: P[name].templateBranches}, if P[name].templateBranches == _|_ {branches: [P[name].schema]}} ).branches}])}
		if E.schemaAdapter == "any-of" {schema: anyOf: [for name in E.members {P[name].schema}]}
		if E.schemaAdapter == "primitive-type-array" {schema: type: [for name in E.members {P[name].primitiveType}]}

		if E.schemaAdapter == "unique-enum" {
			let Values = list.Concat([for name in E.members {P[name].schema.enum}])
			schema: {enum: [for i, value in Values if !list.Contains(list.Take(Values, i), value) {value}], type: "string"}
		}
		if E.schemaAdapter == "unique-primitive-type-array" {
			let Types = [for name in E.members {P[name].primitiveType}]
			schema: type: [for i, value in Types if !list.Contains(list.Take(Types, i), value) {value}]
		}
		if E.schemaAdapter == "flatten-any-of" {schema: anyOf: list.Concat([for name in E.members {({
			branches: [...]
			if P[name].schema.anyOf != _|_ {branches: P[name].schema.anyOf}
			if P[name].schema.anyOf == _|_ {branches: [P[name].schema]}
		}).branches
		}])
		}
	}
	if E.kind == "reference" {
		typescript:   E.name
		native:       "#\(E.name)"
		finite:       P[E.expression].finite
		finiteValues: P[E.expression].finiteValues
		if E.schemaAdapter == "reference" {schema: {"$ref": "#/definitions/\(E.name)"}}
		if E.schemaAdapter == "inline" {schema: P[E.expression].schema & {if contractIndex[E.name].documentationAdapter == "declared" {description: contractIndex[E.name].description}}}
	}
	if E.kind == "interface-selection" {
		typescript: ({pick: "Pick", omit: "Omit"})[E.operator] + "<" + E.contract + ", " + strings.Join([for key in E.keys {(#TypeScriptLiteral & {value: key}).text}], " | ") + ">"
		let Properties = (#SelectedProperties & {selection: E, properties: interfaceProperties[E.contract]}).selected
		objectFields: [for property in Properties {{name: property.name, native: P[property.type].native, schema: {for key, value in P[property.type].schema if key != "description" {(key): value}, if property.documentationAdapter == "declared" {description: property.description}}, required: property.required}}]
	}
	if E.kind == "indexed-property" {
		let Property = ([for property in interfaceProperties[E.contract] if property.name == E.property {property}])[0]
		typescript: "\(E.contract)[\((#TypeScriptLiteral & {value: E.property}).text)]"
		native:     P[E.expression].native
		if P[E.expression].nativeAlternatives != _|_ {nativeAlternatives: P[E.expression].nativeAlternatives}
		finite:       P[E.expression].finite
		finiteValues: P[E.expression].finiteValues
		schema: {
			for key, value in P[E.expression].schema if key != "description" {(key): value}
			if Property.documentationAdapter == "declared" {description: Property.description}
		}
		if P[E.expression].primitiveType != _|_ {primitiveType: P[E.expression].primitiveType}
		if P[E.expression].templateBranches != _|_ {templateBranches: P[E.expression].templateBranches}
		if P[E.expression].objectFields != _|_ {objectFields: P[E.expression].objectFields}
	}
	if E.kind == "finite-template" {
		finite:     true
		typescript: "`\(E.prefix)${\(P[E.reference].typescript)}`"
		finiteValues: [for value in P[E.reference].finiteValues {E.prefix + value}]
		native: strings.Join([for value in finiteValues {json.Marshal(value)}], " | ")
		templateBranches: [for value in finiteValues {{const: value, type: "string"}}]
		schema: anyOf: templateBranches
	}
	if E.kind == "completion-string" {
		typescript: "(string & Record<never, never>)"
		native:     "string"
		schema: type: "string"
	}
	if E.kind == "parameter" {
		typescript: E.name
		native:     P[E.default].native
		if P[E.default].nativeAlternatives != _|_ {nativeAlternatives: P[E.default].nativeAlternatives}
		schema: P[E.default].schema
	}
	if E.kind == "mapped" {
		typescript: "{ [\(E.keyName) in \(P[E.keys].typescript)]" + strings.Join([if !E.required {"?"}], "") + ": " + P[E.values].typescript + " }"
		objectFields: [for key in P[E.keys].finiteValues {{name: key, native: P[E.values].native, schema: P[E.values].schema, required: E.required}}]
	}
	if E.kind == "inline-interface" {
		typescript: E.name
		let Contract = contractIndex[E.name] & {kind: "interface"}
		let Bases = [for base in Contract.extends { let Base = base
			(#ShapeBaseProjection & {base: Base, aliases: aliasSelections})
		}]
		let Properties = list.Concat([list.Concat([for parent in Bases if !list.Contains(E.elideBases, parent.name) {(#SelectedProperties & {selection: parent, properties: interfaceProperties[parent.name]}).selected}]), Contract.properties])
		objectFields: [for property in Properties {{name: property.name, native: P[property.type].native, schema: {for key, value in P[property.type].schema if key != "description" {(key): value}, if property.documentationAdapter == "declared" {description: property.description}}, required: property.required}}]
	}
	if E.kind == "intersection" {
		typescript: strings.Join([for name in E.members {"(" + P[name].typescript + ")"}], " & ")
		let Fields = list.Concat([for name in E.members {P[name].objectFields}])
		objectFields: [for i, field in Fields if !list.Contains([for prior in list.Take(Fields, i) {prior.name}], field.name) {field}]
	}
	if list.Contains(["mapped", "inline-interface", "intersection", "interface-selection"], E.kind) {
		native: "{" + strings.Join([for field in objectFields {json.Marshal(field.name) + strings.Join([if field.required {"!"}, if !field.required {"?"}], "") + ": " + field.native}], ", ") + strings.Join([if E.kind == "intersection" if E.objectClosure == "unspecified" {", ..."}], "") + "}"
		schema: {
			type: "object"
			if E.kind != "intersection" {additionalProperties: false}
			if E.kind == "intersection" if E.objectClosure == "closed" {additionalProperties: false}
			properties: {for field in objectFields {(field.name): field.schema}}
			let Required = [for field in objectFields if field.required {field.name}]
			if len(Required) > 0 {required: Required}
		}
	}

	if E.kind == "interface-union" {
		typescript: E.base + " & (" + strings.Join(E.alternatives, " | ") + ")"
		_combined: [for Name in E.alternatives {list.Concat([interfaceProperties[E.base], interfaceProperties[Name]])}]
		propertyBranches: [for Properties in _combined {[for i, Property in Properties if !list.Contains([for Prior in list.Take(Properties, i) {Prior.name}], Property.name) {Property}]}]
		nativeAlternatives: [for Properties in propertyBranches {"{" + strings.Join([for Property in Properties {json.Marshal(Property.name) + strings.Join([if Property.required {"!"}, if !Property.required {"?"}], "") + ": " + P[Property.type].native}], ", ") + "}"}]
		native: "(" + strings.Join([for BranchIndex, Properties in propertyBranches {strings.Join([if len([for Property in interfaceProperties[E.alternatives[BranchIndex]] if Property.required {Property}]) == 0 {"*"}], "") + "{" + strings.Join([for Property in Properties {json.Marshal(Property.name) + strings.Join([if Property.required {"!"}, if !Property.required {"?"}], "") + ": " + P[Property.type].native}], ", ") + "}"}], " | ") + ")"
		schema: anyOf: [for Properties in propertyBranches {
			type:                 "object"
			additionalProperties: false
			properties: {for Property in Properties {(Property.name): {for Key, Value in P[Property.type].schema if Key != "description" {(Key): Value}, if Property.documentationAdapter == "declared" {description: Property.description}}}}
			let Required = [for Property in Properties if Property.required {Property.name}]
			if len(Required) > 0 {required: Required}
		}]
	}
	if E.kind == "dictionary" {
		typescript: "{ [\(E.keyName): string]: \(P[E.values].typescript) }"
		native:     "{[string]: \(P[E.values].native)}"
		schema: {type: "object", additionalProperties: P[E.values].schema}
	}
	if E.kind == "record" {
		objectFields: [for property in E.properties {{name: property.name, native: P[property.type].native, schema: {for key, value in P[property.type].schema if key != "description" {(key): value}, if property.documentationAdapter == "declared" {description: property.description}}, required: property.required}}]
		typescript: "{ " + strings.Join([for property in E.properties {property.name + strings.Join([if !property.required {"?"}], "") + ": " + P[property.type].typescript + ";"}], " ") + " }"
		native: "{" + strings.Join([for property in E.properties {json.Marshal(property.name) + strings.Join([if property.required {"!"}, if !property.required {"?"}], "") + ": " + P[property.type].native}], ", ") + "}"
		schema: {
			type:                 "object"
			additionalProperties: false
			properties: {for property in E.properties {(property.name): {for key, value in P[property.type].schema if key != "description" {(key): value}, if property.documentationAdapter == "declared" {description: property.description}}}}
			let Required = [for property in E.properties if property.required {property.name}]
			if len(Required) > 0 {required: Required}
		}
	}
	if E.kind == "object" {
		typescript: "object"
		native:     "{...}"
		schema: type: "object"
	}
	if E.kind == "host" {
		typescript: "Date"
		native:     "time.Time"
		schema: {type: "string", format: "date-time"}
	}
	if E.kind == "tuple" {
		typescript: "[" + strings.Join([for element in E.elements {
			strings.Join([if element.label != _|_ {element.label + strings.Join([if !element.required {"?"}], "") + ": " + P[element.type].typescript}, if element.label == _|_ {if element.required {P[element.type].typescript}, if !element.required {"(" + P[element.type].typescript + ")?"}}], "")
		}], ", ") + "]"
		_minItems: len([for element in E.elements if E.wireArity == "all-elements" || element.required {element}])
		nativeAlternativesRequired: _minItems < len(E.elements)
		if _minItems == len(E.elements) {native: "[" + strings.Join([for element in E.elements {P[element.type].native}], ", ") + "]"}
		if _minItems < len(E.elements) {nativeAlternatives: [for size in list.Range(_minItems, len(E.elements)+1, 1) {"[" + strings.Join([for element in list.Take(E.elements, size) {P[element.type].native}], ", ") + "]"}], native: "(" + strings.Join([for size in list.Range(_minItems, len(E.elements)+1, 1) {"[" + strings.Join([for element in list.Take(E.elements, size) {P[element.type].native}], ", ") + "]"}], " | ") + ")"}
		schema: {
			type:     "array"
			minItems: _minItems
			maxItems: len(E.elements)
			if len(E.elements) > 0 {
				if E.schemaAdapter == "homogeneous-items" {items: P[E.elements[0].type].schema}
				if E.schemaAdapter == "positional-items" {items: [for element in E.elements {P[element.type].schema & {if element.label != _|_ {title: element.label}}}]}
			}
		}
	}
	if E.kind == "case-transform" {
		let Type = P[E.reference]
		_typeName: string
		if E.typeName != _|_ {_typeName: E.typeName}
		if E.typeName == _|_ {_typeName: Type.typescript}
		typescript: ({uppercase: "Uppercase", lowercase: "Lowercase"})[E.transform] + "<" + _typeName + ">"
		_values: [for value in Type.schema.enum {({
			result: string
			if E.transform == "uppercase" {result: strings.ToUpper(value)}
			if E.transform == "lowercase" {result: strings.ToLower(value)}
		}).result
		}]
		native: strings.Join([for value in _values {json.Marshal(value)}], " | ")
		schema: {enum: _values, type: "string"}
	}
	if E.kind == "application" {
		let Shape = argumentShapes[E.shape]
		if Shape.parameter != _|_ {typescript: "\(Shape.name)<\(P[E.argument].typescript)>"}
		if Shape.parameter == _|_ {typescript: Shape.name}
		_branches: list.Concat([
			[if Shape.nullable {{type: "null"}}],
			[if Shape.scalar for branch in ({
				values: [...]
				if P[E.argument].schema.anyOf != _|_ {values: P[E.argument].schema.anyOf}
				if P[E.argument].schema.anyOf == _|_ {values: [P[E.argument].schema]}
			}).values {branch}],
			[{type: "array", minItems: Shape.tupleSize, maxItems: Shape.tupleSize
				if Shape.tupleSize > 0 {items: P[E.argument].schema}}],
		])
		schema: {if len(_branches) > 1 {anyOf: _branches}, if len(_branches) == 1 {for key, value in _branches[0] {(key): value}}, description: Shape.description}
		nativeAlternatives: [
			if Shape.nullable {"null"},
			if Shape.scalar {P[E.argument].native},
			"[" + strings.Join([for _ in list.Range(0, Shape.tupleSize, 1) {P[E.argument].native}], ", ") + "]",
		]
		native: "(" + strings.Join([
			if Shape.nullable {"null"},
			if Shape.scalar {P[E.argument].native},
			"[" + strings.Join([for _ in list.Range(0, Shape.tupleSize, 1) {P[E.argument].native}], ", ") + "]",
		], " | ") + ")"
	}

}

#ShapeProjection: {
	expressions!: [string]: model.#ShapeExpression
	contracts!: [...model.#ShapeContract]
	baseContracts: *[] | [...model.#ShapeContract]
	externalReferences: *[] | [...model.#ExternalReference]
	argumentShapes: *[] | [...model.#ArgumentShape]
	let Shapes = {for shape in argumentShapes {(shape.name): shape}}
	let Expressions = expressions
	let Contracts = contracts
	let AllContracts = list.Concat([baseContracts, contracts])
	nativeImports: [if len([for _, expression in Expressions if expression.kind == "host" {expression}]) > 0 {"time"}]
	contractIndex: {for contract in AllContracts {(contract.name): contract}}
	let Index = contractIndex
	_selectionAliases: json.Unmarshal(json.Marshal({for Name, Contract in Index if Contract.kind == "alias" if Expressions[Contract.expression].kind == "interface-selection" {(Name): {contract: Expressions[Contract.expression].contract, operator: Expressions[Contract.expression].operator, keys: Expressions[Contract.expression].keys}}}))
	baseSelections: {for contract in AllContracts if contract.kind == "interface" {(contract.name): [for base in contract.extends { let Base = base
		(#ShapeBaseProjection & {base: Base, aliases: _selectionAliases})
	}]}}
	let Bases = baseSelections
	let P = projections

	_direct: {
		for name, expr in Expressions {
			let Dependencies = list.Concat([
				(#ExpressionDependencies & {expression: expr}).dependencies,
				[if expr.kind == "interface-selection" for property in (#SelectedProperties & {selection: expr, properties: effectiveProperties[expr.contract]}).selected {property.type}],
				[if expr.kind == "inline-interface" for property in list.Concat([list.Concat([for parent in Bases[expr.name] if !list.Contains(expr.elideBases, parent.name) {(#SelectedProperties & {selection: parent, properties: effectiveProperties[parent.name]}).selected}]), Index[expr.name].properties]) {property.type}],
				[if expr.kind == "interface-union" for Name in list.Concat([[expr.base], expr.alternatives]) for property in effectiveProperties[Name] {property.type}],
			])
			let Projection = #ShapeExpressionProjection & {
				expression: expr
				previous: {for dependency in Dependencies {(dependency): _direct[dependency]}}
				argumentShapes: Shapes
				if expr.kind == "inline-interface" {aliasSelections: _selectionAliases, interfaceProperties: {for base in Index[expr.name].extends { let Base = base
					let Parent = #ShapeBaseProjection & {base: Base, aliases: _selectionAliases}
					if !list.Contains(expr.elideBases, Parent.name) {(Parent.name): effectiveProperties[Parent.name]}}}, contractIndex: {(expr.name): Index[expr.name]}}
				if expr.kind == "reference" if expr.schemaAdapter == "inline" {contractIndex: {(expr.name): Index[expr.name]}}
				if expr.kind == "indexed-property" || expr.kind == "interface-selection" {interfaceProperties: {(expr.contract): effectiveProperties[expr.contract]}}
				if expr.kind == "interface-union" {interfaceProperties: {for Name in list.Concat([[expr.base], expr.alternatives]) {(Name): effectiveProperties[Name]}}}
			}
			(name): {
				typescript:   Projection.typescript
				native:       Projection.native
				schema:       Projection.schema
				finite:       Projection.finite
				finiteValues: Projection.finiteValues
				if Projection.primitiveType != _|_ {primitiveType: Projection.primitiveType}
				if Projection.templateBranches != _|_ {templateBranches: Projection.templateBranches}
				if Projection.objectFields != _|_ {objectFields: Projection.objectFields}
				if Projection.propertyBranches != _|_ {propertyBranches: Projection.propertyBranches}
				nativeAlternativesRequired: Projection.nativeAlternativesRequired
				if Projection.nativeAlternativesRequired {nativeAlternatives: Projection.nativeAlternatives}
			}
		}
	}
	// CUE v0.17.1 reports false alias cycles when native checks and artifacts share the live projection graph.
	projections: json.Unmarshal(json.Marshal({for name, result in _direct {
		(name): {
			typescript: result.typescript
			native:     result.native
			schema:     result.schema
			if result.primitiveType != _|_ {primitiveType: result.primitiveType}
			finiteValues: result.finiteValues
			finite:       result.finite
			if result.templateBranches != _|_ {templateBranches: result.templateBranches}
			if result.objectFields != _|_ {objectFields: result.objectFields}
			if result.propertyBranches != _|_ {propertyBranches: result.propertyBranches}
			nativeAlternativesRequired: result.nativeAlternativesRequired
			if result.nativeAlternativesRequired {nativeAlternatives: result.nativeAlternatives}
		}
	}}))
	checks: {
		resolved: true & (len(projections) == len(Expressions))
		dependencies: [for _, expression in Expressions {
			if expression.kind == "enum" {true & list.UniqueItems(expression.values)}
			if expression.kind == "reference" {
				true & projections[expression.expression].finite
				true & list.Contains(list.Concat([[for contract in AllContracts {contract.name}], [for reference in externalReferences {reference.name}]]), expression.name)
				for contract in AllContracts if contract.name == expression.name {true & ((contract & {kind: "alias"}).expression == expression.expression)}
				for reference in externalReferences if reference.name == expression.name {true & (reference.finiteExpression == expression.expression)}
			}
			if expression.kind == "interface-selection" {
				true & (Index[expression.contract].kind == "interface")
				for key in expression.keys if expression.operator == "pick" {true & list.Contains([for property in effectiveProperties[expression.contract] {property.name}], key)}
			}
			if expression.kind == "indexed-property" {
				true & (Index[expression.contract].kind == "interface")
				let Properties = [for property in effectiveProperties[expression.contract] if property.name == expression.property {property}]
				true & (len(Properties) == 1)
				true & (Properties[0].type == expression.expression)
			}
			if expression.kind == "parameter" {
				true & list.Contains(list.Concat([for contract in AllContracts if contract.kind == "alias" {[for parameter in contract.parameters if parameter.default == expression.default {parameter.name}]}]), expression.name)
			}
			if expression.kind == "finite-template" {true & projections[expression.reference].finite, true & (len(projections[expression.reference].finiteValues) > 0)}
			if expression.kind == "mapped" {true & projections[expression.keys].finite, true & (len(projections[expression.keys].finiteValues) > 0)}
			if expression.kind == "intersection" {
				let Fields = list.Concat([for member in expression.members {projections[member].objectFields}])
				for i, field in Fields {for prior in list.Take(Fields, i) if prior.name == field.name {true & (prior.native == field.native && prior.required == field.required)}}
				for member in expression.members {true & (projections[member].schema.type == "object")}
			}

			if expression.kind == "interface-union" {
				true & (len([for Name in expression.alternatives if len([for Property in effectiveProperties[Name] if Property.required {Property}]) == 0 {Name}]) <= 1)
				true & list.UniqueItems(expression.alternatives)
				for Name in list.Concat([[expression.base], expression.alternatives]) {true & (Index[Name].kind == "interface")}
				for Name in expression.alternatives {
					let Combined = list.Concat([effectiveProperties[expression.base], effectiveProperties[Name]])
					for i, Property in Combined for Prior in list.Take(Combined, i) if Prior.name == Property.name {true & (Prior.required == Property.required && projections[Prior.type].native == projections[Property.type].native && projections[Prior.type].schema == projections[Property.type].schema)}
				}
			}
			if expression.kind == "inline-interface" {
				for parent in expression.elideBases {true & list.Contains([for base in Bases[expression.name] {base.name}], parent)}
			}
			if expression.kind == "record" {
				true & list.UniqueItems([for property in expression.properties {property.name}])
			}
			if expression.kind == "tuple" {
				for i, element in expression.elements {
					if element.required {for prior in list.Take(expression.elements, i) {true & prior.required}}
				}
				if expression.schemaAdapter == "homogeneous-items" {for element in expression.elements {true & (projections[element.type].schema == projections[expression.elements[0].type].schema)}}
			}
			if expression.kind == "application" {
				if Shapes[expression.shape].parameter == _|_ {true & (expression.argument == _|_)}
			}
			if expression.kind == "union" {
				if expression.schemaAdapter == "literal-enum" {
					for name in expression.members {true & (Expressions[name].kind == "literal")}
					true & list.UniqueItems([for name in expression.members {projections[name].schema.const}])
				}
				if expression.nativeDefault != _|_ {true & list.Contains(expression.members, expression.nativeDefault)}
			}
		}]
		names: true & list.UniqueItems([for contract in AllContracts {contract.name}])
		argumentNames: true & list.UniqueItems([for shape in argumentShapes {shape.name}])
		externalNames: true & list.UniqueItems(list.Concat([[for contract in AllContracts {contract.name}], [for reference in externalReferences {reference.name}]]))
		for _, expression in Expressions if expression.kind == "named" {
			"reference_\(expression.name)": true & list.Contains(list.Concat([[for contract in AllContracts {contract.name}], [for reference in externalReferences {reference.name}]]), expression.name)
		}
		for _, expression in Expressions if expression.kind == "case-transform" if expression.typeName != _|_ {
			"case_\(expression.typeName)": true & list.Contains(list.Concat([[for contract in AllContracts {contract.name}], [for reference in externalReferences {reference.name}]]), expression.typeName)
		}
		for contract in AllContracts if contract.kind == "interface" {
			"properties_\(contract.name)": true & list.UniqueItems([for property in effectiveProperties[contract.name] {property.name}])
			for property in contract.properties if property.typescriptAlias != _|_ {"alias_\(contract.name)_\(property.name)": true & (Index[property.typescriptAlias].expression == property.type)}
		}
	}
	effectiveProperties: {
		for contract in AllContracts if contract.kind == "interface" {
			let Parents = list.Concat([for parent in Bases[contract.name] {(#SelectedProperties & {selection: parent, properties: effectiveProperties[parent.name]}).selected}])
			let OwnNames = [for property in contract.properties {property.name}]
			(contract.name): list.Concat([
				[for i, property in Parents if !list.Contains([for prior in list.Take(Parents, i) {prior.name}], property.name) {
					if !list.Contains(OwnNames, property.name) {property}
					if list.Contains(OwnNames, property.name) {([for own in contract.properties if own.name == property.name {own}])[0]}
				}],
				[for property in contract.properties if !list.Contains([for parent in Parents {parent.name}], property.name) {property}],
			])
		}
	}
	checks: inheritance: {
		resolved: true & (len(effectiveProperties) == len([for contract in AllContracts if contract.kind == "interface" {contract}]))
		for contract in AllContracts if contract.kind == "interface" {
			"\(contract.name)": {
				parentsUnique: true & list.UniqueItems([for parent in Bases[contract.name] {parent.name}])
				ownUnique: true & list.UniqueItems([for property in contract.properties {property.name}])
				for parent in Bases[contract.name] {
					"parent_\(parent.name)": true & (Index[parent.name].kind == "interface")
					"keys_\(parent.name)": [for key in parent.keys if parent.operator == "pick" {true & list.Contains([for property in effectiveProperties[parent.name] {property.name}], key)}]
					"uniqueKeys_\(parent.name)": true & list.UniqueItems(parent.keys)
				}
				let ParentProperties = list.Concat([for parent in Bases[contract.name] {(#SelectedProperties & {selection: parent, properties: effectiveProperties[parent.name]}).selected}])
				let ParentNames = [for property in ParentProperties {property.name}]
				compatible: [for i, property in ParentProperties for prior in list.Take(ParentProperties, i) if prior.name == property.name {
					if property.type == prior.type {true & (property.required == prior.required)}
					if property.type != prior.type {
						let Left = #ShapeAlternatives & {expression: property.type, expressions: Expressions, contractIndex: Index}
						let Right = #ShapeAlternatives & {expression: prior.type, expressions: Expressions, contractIndex: Index}
						let Same = Left.resolved && Right.resolved && (list.Sort(Left.names, list.Ascending) == list.Sort(Right.names, list.Ascending))
						if Same {true & (property.required == prior.required)}
						if !Same {true & (property.required == prior.required && projections[property.type].native == projections[prior.type].native && projections[property.type].schema == projections[prior.type].schema)}
					}
				}]
				for property in contract.properties {
					"override_\(property.name)": true & (list.Contains(ParentNames, property.name) == (property.override != _|_))
					"required_\(property.name)": [for parent in ParentProperties if parent.name == property.name if parent.required {true & property.required}]
					"narrowing_\(property.name)": [for parent in ParentProperties if parent.name == property.name { let Child = property.type
						let Parent = parent.type
						true & (#ShapeNarrowing & {child: Child, parent: Parent, expressions: Expressions, projections: P, contractIndex: Index}).allowed
					}]
				}
			}
		}
	}
	admissionDefinitions: {for Contract in Contracts {
		if Contract.kind == "interface" {(Contract.name): contractProjections[Contract.name].native}
		if Contract.kind == "alias" {
			if projections[Contract.expression].nativeAlternativesRequired {
				(Contract.name): "matchN(>=1, [" + strings.Join([for i, _ in projections[Contract.expression].nativeAlternatives {"#Admission_" + Contract.name + "_" + "\(i)"}], ", ") + "])"
				for i, Alternative in projections[Contract.expression].nativeAlternatives {("Admission_" + Contract.name + "_" + "\(i)"): Alternative}
			}
			if !projections[Contract.expression].nativeAlternativesRequired {(Contract.name): contractProjections[Contract.name].native}
		}
	}}

	nativeObjects: {
		for Contract in Contracts {
			if Contract.kind == "interface" {
				(Contract.name): [{preferred: false, fields: [for Property in effectiveProperties[Contract.name] {{name: Property.name, required: Property.required, native: projections[Property.type].native}}]}]
			}
			if Contract.kind == "alias" if projections[Contract.expression].propertyBranches != _|_ {
				let Expression = Expressions[Contract.expression]
				(Contract.name): [for BranchIndex, Properties in projections[Contract.expression].propertyBranches {
					preferred: len([for Property in effectiveProperties[Expression.alternatives[BranchIndex]] if Property.required {Property}]) == 0
					fields: [for Property in Properties {{name: Property.name, required: Property.required, native: projections[Property.type].native}}]
				}]
			}
		}
	}

	contractProjections: {
		for contract in Contracts {
			(contract.name): {
				let C = contract
				body:   string
				native: string
				schema: _
				if C.kind == "alias" {
					typescript: projections[C.expression].typescript
					native:     projections[C.expression].native
					if projections[C.expression].propertyBranches != _|_ {propertyBranches: projections[C.expression].propertyBranches}
					schema: {for key, value in projections[C.expression].schema if key != "description" {(key): value}}
					body: "type \(C.name)" + strings.Join([if len(C.parameters) > 0 {"<" + strings.Join([for parameter in C.parameters {parameter.name + " = " + projections[parameter.default].typescript}], ", ") + ">"}], "") + " = \(typescript);"
				}
				if C.kind == "interface" {
					_properties: effectiveProperties[C.name]
					native:      "{\n\(strings.Join([for property in _properties {"  \(json.Marshal(property.name))\(strings.Join([if property.required {"!"}, if !property.required {"?"}], "")): \(projections[property.type].native)"}], "\n"))\n}"
					schema: {
						additionalProperties: false
						properties: {for property in _properties {(property.name): {for key, value in projections[property.type].schema if key != "description" {(key): value}, if property.documentationAdapter == "declared" {description: property.description}}}}
						let Required = [for property in _properties if property.required {property.name}]
						if len(Required) > 0 {required: Required}
						type: "object"
					}
					body: "interface \(C.name)\(strings.Join([if len(C.extends) > 0 {" extends \(strings.Join([for parent in Bases[C.name] {parent.typescript}], ", "))"}], "")) {\n\(strings.Join([for property in C.properties {"\((#ShapeDescription & {description: strings.Join([if property.documentationAdapter == "declared" {property.description}], ""), prefix: "  "}).text)  \(property.name)\(strings.Join([if !property.required {"?"}], "")): \(strings.Join([if property.typescriptAlias != _|_ {property.typescriptAlias}, if property.typescriptAlias == _|_ {projections[property.type].typescript}], ""));"}], "\n\n"))\n}"
				}
				if C.documentationAdapter == "declared" {schema: description: C.description}
				declaration: (#ShapeDescription & {description: strings.Join([if C.documentationAdapter == "declared" {C.description}], ""), prefix: ""}).text + strings.Join([if C.exported {"export "}], "") + body + "\n"
			}
		}
	}
}

#ShapeDescription: {
	description!: string
	prefix!:      string
	text: strings.Join([if description != "" {"\(prefix)/**\n\(strings.Join([for line in strings.Split(strings.Replace(description, "*/", "*\\/", -1), "\n") {"\(prefix) *\(strings.Join([if line != "" {" " + line}], ""))"}], "\n"))\n\(prefix) */\n"}], "")
}

#ArgumentDeclaration: {
	shape!: model.#ArgumentShape
	let S = shape
	_argument: string
	if S.parameter != _|_ {_argument: S.parameter}
	if S.parameter == _|_ {_argument: ""}
	_body: strings.Join([
		if S.nullable {"null"},
		if S.scalar {_argument},
		"[" + strings.Join([for _ in list.Range(0, S.tupleSize, 1) {_argument}], ", ") + "]",
	], " | ")
	declaration: (#ShapeDescription & {description: S.description, prefix: ""}).text + "type \(S.name)" + strings.Join([if S.parameter != _|_ {"<\(S.parameter)>"}], "") + " = \(_body);\n"
}

#DeclarationSection: {
	declaration!: string
	text:         "\n" + strings.Trim(declaration, "\n") + "\n"
}

#ExpressionDependencies: {
	expression!: model.#ShapeExpression
	let E = expression
	dependencies: list.Concat([
		[if E.kind == "array" {E.items}],
		[if E.kind == "reference" {E.expression}],
		[if E.kind == "indexed-property" {E.expression}],
		[if E.kind == "parameter" {E.default}],
		[if E.kind == "finite-template" {E.reference}],
		[if E.kind == "mapped" {E.keys}],
		[if E.kind == "mapped" {E.values}],
		[if E.kind == "intersection" for member in E.members {member}],
		[if E.kind == "dictionary" {E.values}],
		[if E.kind == "union" for member in E.members {member}],
		[if E.kind == "tuple" for element in E.elements {element.type}],
		[if E.kind == "record" for property in E.properties {property.type}],
		[if E.kind == "case-transform" {E.reference}],
		[if E.kind == "application" if E.argument != _|_ {E.argument}],
	])
}

#ExpressionClosure: {
	expressions!: [string]: model.#ShapeExpression
	roots!: [...string]
	let Expressions = expressions
	_reachable: {
		for name, expr in Expressions {
			(name): list.Concat([
				[name],
				for dependency in (#ExpressionDependencies & {expression: expr}).dependencies {_reachable[dependency]},
			])
		}
	}
	_selected: list.Concat([for name in roots {_reachable[name]}])
	selected: {for name, expression in Expressions if list.Contains(_selected, name) {(name): expression}}
}

#ShapeBaseProjection: {
	base!: model.#ShapeBase
	aliases: *{} | {[string]: model.#InterfaceSelection}
	_aliases:     aliases
	_rawName:     string
	_rawOperator: string
	_rawKeys: [...string]
	if (base & string) != _|_ {_rawName: base, _rawOperator: "all", _rawKeys: []}
	if (base & string) == _|_ {_rawName: base.name, _rawOperator: base.operator, _rawKeys: base.keys}
	_isAlias: list.Contains([for Name, _ in _aliases {Name}], _rawName)
	name:     string
	operator: string
	keys: [...string]
	typescript: string
	if _isAlias {
		_validAlias: true & (_rawOperator == "all")
		name:        _aliases[_rawName].contract
		operator:    _aliases[_rawName].operator
		keys:        _aliases[_rawName].keys
		typescript:  _rawName
	}
	if !_isAlias {
		name:     _rawName
		operator: _rawOperator
		keys:     _rawKeys
		if operator == "all" {typescript: name}
		if operator != "all" {typescript: ({omit: "Omit", pick: "Pick", exclude: "Exclude"})[operator] + "<" + name + ", " + strings.Join([for key in keys {(#TypeScriptLiteral & {value: key}).text}], " | ") + ">"}
	}
}
#SelectedProperties: {
	selection!: _
	properties!: [...]
	selected: [for property in properties if selection.operator == "all" || selection.operator == "exclude" || (selection.operator == "omit" && !list.Contains(selection.keys, property.name)) || (selection.operator == "pick" && list.Contains(selection.keys, property.name)) {property}]
}

#ShapeNarrowing: {
	contractIndex: *{} | {[string]: model.#ShapeContract}
	let Index = contractIndex
	child!:  string
	parent!: string
	expressions!: [string]: _
	projections!: [string]: _
	let E = expressions
	let P = projections
	_childAlternatives: #ShapeAlternatives & {expression: child, expressions: E, contractIndex: Index}
	_parentAlternatives: #ShapeAlternatives & {expression: parent, expressions: E, contractIndex: Index}
	_children: _childAlternatives.names
	_parents:  _parentAlternatives.names
	_pairs: {for candidate in _children {(candidate): {for target in _parents {(target): {
		same: P[candidate].native == P[target].native && P[candidate].schema == P[target].schema
		any: len([if E[target].kind == "primitive" if E[target].type == "any" {true}]) > 0
		literal: len([if E[target].kind == "primitive" if E[candidate].kind == "literal" if P[candidate].schema.type == E[target].type {true}]) > 0
		enumLiteral: len([if E[target].kind == "enum" if E[candidate].kind == "literal" if list.Contains(E[target].values, E[candidate].value) {true}]) > 0
		enumMembers: len([if E[target].kind == "enum" if E[candidate].kind == "enum" if len([for value in E[candidate].values if list.Contains(E[target].values, value) {value}]) == len(E[candidate].values) {true}]) > 0
		allowed: same || any || literal || enumLiteral || enumMembers
	}}}}}
	allowed: _childAlternatives.resolved && _parentAlternatives.resolved && len([for candidate in _children if len([for target in _parents if _pairs[candidate][target].allowed {target}]) > 0 {candidate}]) == len(_children)
}

#ShapeAlternatives: {
	expression!: string
	expressions!: [string]: model.#ShapeExpression
	contractIndex: *{} | {[string]: model.#ShapeContract}
	let E = expressions
	let Index = contractIndex
	_aliases: {for name, expression in E {(name): strings.Join([
		if expression.kind == "indexed-property" || expression.kind == "reference" {expression.expression},
		if expression.kind == "named" if Index[expression.name] != _|_ if Index[expression.name].kind == "alias" {Index[expression.name].expression},
	], "")
	}}
	_terms: {
		for name, expression in E {
			(name): list.Concat([
				list.Concat([if expression.kind == "union" for member in expression.members {_terms[member]}]),
				list.Concat([if expression.kind != "union" if _aliases[name] != "" {_terms[_aliases[name]]}]),
				[if expression.kind != "union" if _aliases[name] == "" {name}],
			])
		}
	}
	names: _terms[expression]
	resolved: len([for name in names if E[name].kind == "union" || _aliases[name] != "" {name}]) == 0
}
