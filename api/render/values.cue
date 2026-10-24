package render

import (
	"encoding/json"
	"list"
	"strings"
	"idl.uw.edu/mosaic/api/model"
)

#TypeScriptLiteral: {
	value!: string | number | bool | null
	if (value & string) != _|_ {
		_body: strings.TrimSuffix(strings.TrimPrefix(json.Marshal(value), "\""), "\"")
		text:  "'" + strings.Replace(strings.Replace(_body, "\\\"", "\"", -1), "'", "\\'", -1) + "'"
	}
	if (value & string) == _|_ {text: json.Marshal(value)}
}

#TemplateValues: {
	term!: model.#TypeTerm & {kind: "template", schemaAdapter: "enumerate"}
	index!: [string]: model.#ValueContract
	let T = term
	let I = index
	choices: [for part in T.parts {({
		value: [...string]
		if part.literal != _|_ {value: [part.literal]}
		if part.reference != _|_ {value: [for member in (I[part.reference] & {kind: "enum"}).values {"\(member)"}]}
	}).value
	}]
	checks: parts: true & (len(choices) >= 1 && len(choices) <= 3)
	_padded: [for i in list.Range(0, 3, 1) {
		if i < len(choices) {choices[i]}
		if i >= len(choices) {[""]}
	}]
	values: [for first in _padded[0] for second in _padded[1] for third in _padded[2] {first + second + third + T.suffix}]
}

#TypeTermProjection: {
	term!: model.#TypeTerm
	index!: [string]: model.#ValueContract
	let T = term
	let I = index
	if T.kind == "literal" {
		typescript: (#TypeScriptLiteral & {value: T.value}).text
		native: json.Marshal(T.value)
		enumValues: [T.value]
		schemaBranches: [{
			const: T.value
			if (T.value & string) != _|_ {type: "string"}
			if (T.value & number) != _|_ {type: "number"}
			if (T.value & bool) != _|_ {type: "boolean"}
			if T.value == null {type: "null"}
		}]
	}
	if T.kind == "primitive" {
		typescript: T.type
		if T.type == "boolean" {native: "bool"}
		if T.type == "any" {native: "_"}
		if T.type == "never" {native: "_|_"}
		if !list.Contains(["boolean", "any", "never"], T.type) {native: T.type}
		schemaBranches: [{
			if !list.Contains(["any", "never"], T.type) {type: T.type}
			if T.type == "never" {not: {}}
		}]
	}
	if T.kind == "reference" {
		_target:    I[T.name]
		typescript: _target.name
		native:     "#\(_target.name)"
		schemaBranches: [{
			if _target.exported {"$ref": "#/definitions/\(_target.name)"}
			if !_target.exported {
				enum: (_target & {kind: "enum"}).values
				type: "string"
				if _target.description != "" {description: _target.description}
			}
		}]
	}
	if T.kind == "template" {
		_body: strings.Join([for part in T.parts {({
			text: string
			if part.literal != _|_ {text: strings.Replace(strings.Replace(strings.Replace(part.literal, "\\", "\\\\", -1), "`", "\\`", -1), "${", "\\${", -1)}
			if part.reference != _|_ {text: "${\(I[part.reference].name)}"}
			if part.primitive != _|_ {text: "${\(part.primitive)}"}
		}).text
		}], "") + strings.Replace(strings.Replace(strings.Replace(T.suffix, "\\", "\\\\", -1), "`", "\\`", -1), "${", "\\${", -1)
		if T.completion == "empty-record" {typescript: "(`\(_body)` & Record<never, never>)"}
		if T.completion == "plain" {typescript: "`\(_body)`"}
		if T.schemaAdapter == "open-string" {
			native: "string"
			schemaBranches: [{type: "string"}]
		}
		if T.schemaAdapter == "enumerate" {
			_values: (#TemplateValues & {term: T, index: I}).values
			enumValues: _values
			native: strings.Join([for value in _values {json.Marshal(value)}], " | ")
			schemaBranches: [for value in _values {{const: value, type: "string"}}]
		}
	}
	if T.kind == "casefold" {
		_target: I[T.reference] & {kind: "enum"}
		typescript: "(Lowercase<\(_target.name)> & Record<never, never>)"
		native:     "{...}"
		schemaBranches: [for _ in _target.values {{properties: {}, type: "object"}}]
	}
}

#ValueProjection: {
	contract!: model.#ValueContract
	index!: [string]: model.#ValueContract
	typescript: string
	native:     string
	schema:     _
	let C = contract
	let I = index
	if list.Contains(["literal", "primitive", "reference", "template", "casefold"], C.kind) {
		_term: #TypeTermProjection & {
			term: {for key, value in C if !list.Contains(["name", "description", "exported", "file"], key) {(key): value}}
			index: I
		}
		typescript: _term.typescript
		native:     _term.native
		schema:     _term.schemaBranches[0]
	}
	if C.kind == "enum" {
		typescript: strings.Join([for enumValue in C.values {(#TypeScriptLiteral & {value: enumValue}).text}], " | ")
		native: strings.Join([for value in C.values {json.Marshal(value)}], " | ")
		schema: {
			enum: C.values
			if (C.values[0] & string) != _|_ {type: "string"}
			if (C.values[0] & number) != _|_ {type: "number"}
		}
	}
	if C.kind == "union" {
		_members: [for member in C.members {#TypeTermProjection & {term: member, index: I}}]
		typescript: strings.Join([for member in _members {member.typescript}], " | ")
		native: strings.Join([for member in _members {member.native}], " | ")
		if C.schemaAdapter == "any-of" {
			schema: anyOf: list.Concat([for i, member in _members if !list.Contains([for previous in list.Take(_members, i) {previous.schemaBranches}], member.schemaBranches) {member.schemaBranches}])
		}
		if C.schemaAdapter == "unique-enum" {
			_allValues: list.Concat([for member in _members {member.enumValues}])
			schema: {
				enum: [for i, value in _allValues if !list.Contains(list.Take(_allValues, i), value) {value}]
				type: "string"
			}
		}
	}
	if C.kind == "conditional" {
		_branches: [for branch in C.branches {"\(C.parameter.name) extends \(branch.when) ? \((#TypeTermProjection & {term: branch.value, index: I}).typescript)"}]
		typescript: strings.Join(_branches, " : ") + " : \(C.fallback)"
		_first: #TypeTermProjection & {term: C.branches[0].value, index: I}
		native: _first.native
		schema: _first.schemaBranches[0]
	}
	if C.kind == "host" {
		typescript: "Partial<Omit<\(C.host), \(I[C.omit].name)>>"
		native:     "{\n\(strings.Join([for property in C.numberProperties {"  \(json.Marshal(property))?: number"}], "\n"))\n  [string \(strings.Join([for property in C.numberProperties {"& !=\(json.Marshal(property))"}], " "))]: string\n}"
		schema: {
			additionalProperties: {type: C.additionalProperties}
			properties: {
				for property in C.stringProperties {(property): {type: "string"}}
				for property in C.numberProperties {(property): {type: "number"}}
			}
			type: "object"
		}
	}
	if C.description != "" {schema: description: C.description}
	_descriptionLines: [for line in strings.Split(strings.Replace(C.description, "*/", "*\\/", -1), "\n") {({
		text: string
		if line == "" {text: " *"}
		if line != "" {text: " * " + line}
	}).text
	}]
	declaration: "\(strings.Join([if C.description != "" {"/**\n\(strings.Join(_descriptionLines, "\n"))\n */\n"}], ""))\(strings.Join([if C.exported {"export "}], ""))type \(C.name)\(strings.Join([if C.kind == "conditional" {"<\(C.parameter.name) = \(C.parameter.default)>"}], "")) = \(typescript);\n"
}
