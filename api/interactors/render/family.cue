package interactorrender

import (
	"encoding/json"
	"list"
	"strings"
	"idl.uw.edu/mosaic/api/model"
	"idl.uw.edu/mosaic/api/render"
	pythonLanguage "idl.uw.edu/mosaic/api/languages/python"
	paramFamily "idl.uw.edu/mosaic/api/params"
)

#PythonArgument: {
	name!: model.#Name
	wire!: model.#Name
	let Wire = wire
	adapter: *"direct" | "direct" | "singular-field" | "highlight-channels"
	if adapter == "direct" {
		if wire == "as" {name: "bind"}
		if wire != "as" {name: (pythonLanguage.#Identifier & {wire: Wire}).name}
	}
	if adapter == "singular-field" {name: "field", wire: "fields"}
	if adapter == "highlight-channels" {name: "channels", wire: "channels"}
}
#Interactor: {
	contract!:    model.#Name
	wrapperSlot!: string & !=""
	group!:       "toggle" | "nearest" | "highlight" | "interval" | "region" | "navigation"
	javascript!: {
		runtimeClass!: "Highlight" | "Nearest" | "Toggle" | "Interval1D" | "Interval2D" | "Region" | "PanZoom"
		profile!:      "highlight" | "selection" | "toggle-channel" | "navigation"
		forced: *{} | {pointer?: "x" | "y" | "xy", channel?: "x" | "y", zoom?: false, panx?: false, pany?: false}
		if profile == "navigation" {runtimeClass: "PanZoom"}
		if profile != "navigation" {forced: {zoom?: _|_, panx?: _|_, pany?: _|_}}
		if profile == "highlight" {runtimeClass: "Highlight"}
		if profile == "toggle-channel" {runtimeClass: "Toggle", base!: model.#Name, channel!: "x" | "y" | "z" | "color"}
		if runtimeClass == "Nearest" {profile: "selection", forced: pointer!: "x" | "y" | "xy"}
	}
	python!: {
		arguments!: [...#PythonArgument]
		extras!: bool
	}
	if javascript.runtimeClass == "PanZoom" {group: "navigation", javascript: {profile: "navigation", forced: {pointer?: _|_, channel?: _|_}}, python: extras: false}
	if javascript.runtimeClass == "Highlight" {group: "highlight", python: extras: true}
	if javascript.runtimeClass == "Nearest" {group: "nearest", python: extras: false}
	if javascript.runtimeClass == "Toggle" {group: "toggle", python: extras: false}
	if javascript.runtimeClass == "Interval1D" {group: "interval", javascript: {profile: "selection", forced: channel!: "x" | "y"}, python: extras: false}
	if javascript.runtimeClass == "Interval2D" {group: "interval", javascript: {profile: "selection", forced: close({})}, python: extras: false}
	if javascript.runtimeClass == "Region" {group: "region", javascript: {profile: "selection", forced: close({})}, python: extras: false}
	_argumentNamesUnique: true & list.UniqueItems([for argument in python.arguments {argument.name}])
}
#PythonOptionHelper: {name: "brush", contract: "BrushStyles", policy: "camelize-omit-none"} | {name: "sort", policy: "omit-none"}

#DeclarationFile: {
	path!: string & =~#"^packages/vgplot/spec/src/spec/interactors/[A-Za-z][A-Za-z0-9]*\.ts$"#
	imports!: [...{source!: string & =~#"^\.\.?/[A-Za-z0-9_/.-]+\.js$"#, names!: [model.#Name, ...model.#Name]}]
	contracts!: [model.#Name, ...model.#Name]
}
#InteractorFamilyProjection: {
	identity!: {slug!: string & =~"^[a-z][a-z_]*$"}
	contracts!: [...model.#ShapeContract]
	typeExpressions!: {[string]: model.#ShapeExpression}
	declarationFiles!: [...#DeclarationFile]
	interactors!: [...#Interactor]
	optionHelpers: *[] | [...#PythonOptionHelper]
	externalReferences: *[] | [...model.#ExternalReference]

	let Identity = identity
	let Contracts = contracts
	let Expressions = typeExpressions
	let Declarations = declarationFiles
	let Interactors = interactors
	let External = externalReferences
	let Helpers = optionHelpers

	_shape: render.#ShapeProjection & {contracts: Contracts, expressions: Expressions, externalReferences: External}
	shapeChecks:        _shape.checks
	resolvedProperties: _shape.effectiveProperties
	optionReference: strings.Join([for Contract in Contracts {
		"### " + Contract.name + " options\n\n" + strings.Join([if len(Contract.extends) > 0 {"Extends " + strings.Join([for Base in _shape.baseSelections[Contract.name] {"[`" + Base.typescript + "`](#" + strings.ToLower(Base.name) + "-options)"}], ", ") + ".\n\n"}], "") + strings.Join([for Property in Contract.properties if Property.name != "select" {
			"**" + Property.name + "** (`" + _shape.projections[Property.type].typescript + "`) — " + (render.#MarkdownReferences & {value: Property.description}).text + "\n"
		}], "\n")
	}], "\n")
	typeProjections: _shape.projections
	_index: {for contract in Contracts {(contract.name): contract}}
	records: [for item in Interactors {
		let Item = item
		let Select = ([for property in _shape.effectiveProperties[Item.contract] if property.name == "select" {property}])[0]
		let Values = _shape.projections[Select.type].finiteValues
		name: Values[0] & model.#Name
		pythonName: (pythonLanguage.#Identifier & {wire: name}).name
		contract:    Item.contract
		wrapperSlot: Item.wrapperSlot
		group:       Item.group
		javascript:  Item.javascript
		python:      Item.python
		checks: {
			discriminator: true & (Select.required && len(Values) == 1)
			owned:         true & _index[Item.contract].wire
			arguments: [for argument in Item.python.arguments {
				if argument.adapter != "highlight-channels" {true & list.Contains([for property in _shape.effectiveProperties[Item.contract] {property.name}], argument.wire)}
				if argument.adapter == "highlight-channels" {true & (Item.javascript.profile == "highlight")}
				if argument.adapter == "singular-field" {true & (Item.javascript.runtimeClass == "Nearest")}
			}]
			if Item.javascript.profile == "toggle-channel" {
				base: true & list.Contains([for other in Interactors if other.javascript.runtimeClass == "Toggle" if other.javascript.profile == "selection" {(_shape.projections[([for property in _shape.effectiveProperties[other.contract] if property.name == "select" {property}])[0].type].finiteValues)[0]}], Item.javascript.base)
			}
		}
	}]
	let Records = records
	checks: {
		uniqueContracts: true & list.UniqueItems([for contract in Contracts {contract.name}])
		uniqueNames: true & list.UniqueItems([for item in Records {item.name}])
		uniquePythonNames: true & list.UniqueItems([for item in Records {item.pythonName}])
		uniqueSlots: true & list.UniqueItems([for item in Records {item.wrapperSlot}])
		records: [for item in Records {item.checks}]
		helperNames: true & list.UniqueItems([for item in Helpers {item.name}])
		helperContracts: [for item in Helpers if item.name == "brush" {true & _index[item.contract].wire}]
		declarations: true & list.UniqueItems(list.Concat([for file in Declarations {file.contracts}]))
		allDeclared: true & (len(list.Concat([for file in Declarations {file.contracts}])) == len(Contracts))
		allWireCovered: true & (len(Records) == len([for contract in Contracts if contract.wire if list.Contains([for property in _shape.effectiveProperties[contract.name] {property.name}], "select") {contract}]))
	}
	schemaFragment: definitions: {for contract in Contracts if contract.wire {(contract.name): {for key, value in _shape.contractProjections[contract.name].schema if key != "required" {(key): value}, let Required = [for property in _shape.effectiveProperties[contract.name] if property.required {property.name}], if len(Required) > 0 {if len(contract.extends) > 0 {required: list.SortStrings(Required)}
		if len(contract.extends) == 0 {required: Required}}}}}
	admissionDefinitions: _shape.admissionDefinitions
	nativeObjects:        _shape.nativeObjects
	nativeDefinitions: {for contract in Contracts {(contract.name): _shape.contractProjections[contract.name].native}}
	_nativeSource: "// Generated by pnpm generate:api from api/interactors/\(Identity.slug). DO NOT EDIT.\npackage interactoradmission\n\n#ParamRef: \(paramFamily.nativeDefinitions.ParamRef)\n\n" + strings.Join([for contract in Contracts {"#\(contract.name): \(nativeDefinitions[contract.name])\n"}], "\n")
	nativeChecks: [{files: {"interactors.cue": _nativeSource}}]
	registrations: [for item in Records {{key: item.name, owner: Identity.slug}}]
	aliases: [for item in Records for argument in item.python.arguments if argument.adapter == "direct" if argument.name != argument.wire {{wire: argument.wire, name: argument.name}}]
	pythonSymbols: [for item in Records {{name: item.pythonName, module: Identity.slug + "_interactors"}}, for item in Helpers {{name: item.name, module: Identity.slug + "_interactors"}}]
	runtimeClasses: list.SortStrings([for key, _ in {for item in Records {(item.javascript.runtimeClass): true}} {key}])
	_header: "Generated by pnpm generate:api from api/interactors/\(Identity.slug). DO NOT EDIT."
	_wrappers: {for item in Records {
		(item.wrapperSlot): strings.Join([
			if item.javascript.profile == "navigation" {"export function \(item.name)(options = {}) {\n  return interactor(\(item.javascript.runtimeClass), " + strings.Join([if len(item.javascript.forced) == 0 {"options"}, if len(item.javascript.forced) > 0 {"{ ...options" + strings.Join([for key, value in item.javascript.forced {", " + key + ": " + json.Marshal(value)}], "") + " }"}], "") + ");\n}\n\n"},
			if item.javascript.profile == "highlight" {"export function \(item.name)({ by, ...channels }) {\n  return interactor(\(item.javascript.runtimeClass), { selection: by, channels });\n}\n\n"},
			if item.javascript.profile == "selection" {"export function \(item.name)({ as, ...rest }) {\n  return interactor(\(item.javascript.runtimeClass), { ...rest, selection: as" + strings.Join([for key, value in item.javascript.forced { let Value = value
				", \(key): \((render.#TypeScriptLiteral & {value: Value}).text)"
			}], "") + " });\n}\n\n"
			},
			if item.javascript.profile == "toggle-channel" {"export function \(item.name)(options) {\n  return \(item.javascript.base)({ ...options, channels: [\((render.#TypeScriptLiteral & {value: item.javascript.channel}).text)] });\n}\n\n"},
		], "")
	}}
	_python: "# \(_header)\nfrom __future__ import annotations\n\nfrom typing import Any\nfrom .._interactor_runtime import _interactor\nfrom ..util import camelize, omit_none\n\n__all__ = [" + strings.Join([for item in Records {json.Marshal(item.pythonName)}, for item in Helpers {json.Marshal(item.name)}], ", ") + "]\n\n\n" + strings.Join([for item in Records {
		"def \(item.pythonName)(" + strings.Join([for argument in item.python.arguments {"\(argument.name): Any = None"}, if item.python.extras {"**kwargs: Any"}], ", ") + ") -> dict[str, Any]:\n" + strings.Join([
			if !item.python.extras {"    return _interactor(" + json.Marshal(item.name) + ", **{" + strings.Join([for argument in item.python.arguments {json.Marshal(strings.Join([if argument.adapter == "singular-field" {argument.name}, if argument.adapter != "singular-field" {argument.wire}], "")) + ": " + argument.name}], ", ") + "})\n"},
			if item.python.extras {"    return omit_none({\"select\": " + json.Marshal(item.name) + ", " + strings.Join([for argument in item.python.arguments {json.Marshal(argument.wire) + ": " + argument.name}], ", ") + ", **{camelize(k): v for k, v in kwargs.items()}})\n"},
		], "")
	}], "\n\n") + strings.Join([for helper in Helpers {"\n\ndef \(helper.name)(**kwargs: Any) -> dict[str, Any]:\n    return {" + strings.Join([if helper.policy == "camelize-omit-none" {"camelize(k)"}, if helper.policy == "omit-none" {"k"}], "") + ": v for k, v in kwargs.items() if v is not None}\n"}], "") + "\nfor _name in __all__:\n    globals()[_name].__module__ = \"vgplot.plot\"\n"
	files: {
		"packages/vgplot/spec/src/generated/\(Identity.slug)-interactors.cue": _nativeSource
		for file in Declarations {(file.path): "// \(_header)\n" + strings.Join([for declaration in file.imports {"import { " + strings.Join(declaration.names, ", ") + " } from '" + declaration.source + "';\n"}], "") + "\n" + strings.Join([for name in file.contracts {_shape.contractProjections[name].declaration}], "\n")}
		"packages/vgplot/vgplot-python/vgplot/_generated/\(Identity.slug)_interactors.py": _python
	}
	sections: [for item in Records {{path: "packages/vgplot/vgplot/src/plot/interactors.js", id: item.wrapperSlot, owner: Identity.slug, text: _wrappers[item.wrapperSlot]}}]
}
