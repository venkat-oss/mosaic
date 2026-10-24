package rootspec

import (
	"list"
	"strings"
	root "idl.uw.edu/mosaic/api/spec/model:specmodel"
	"idl.uw.edu/mosaic/api/render"
)

#Description: {value!: string, text: strings.Join([if value != "" {"/** " + strings.Replace(value, "*/", "*\\/", -1) + " */\n"}], "")}
_rootTypeShape: render.#ShapeProjection & {expressions: root.typeExpressions, contracts: [], externalReferences: root.externalReferences}
rootTypeChecks: _rootTypeShape.checks
rootURICheck: root.typeExpressions[root.uriExpression] & {kind: "primitive", type: "string"}
_rootTypeProjections: {for Name, Projection in _rootTypeShape.projections {
	if Name != root.uriExpression {(Name): Projection}
	if Name == root.uriExpression {(Name): {typescript: Projection.typescript, native: "net.AbsURL", schema: Projection.schema & {format: "uri"}}}
}}

#RootTypes: {
	families!: [...{files!: [string]: string, sharedTypeImports: *[] | [...{path!: string, imports!: [...{name!: string, source!: string
		...
	}]}]
		...
	}]
	sections!: [...{path!: string, id!: string, text!: string, placement: *"body" | "body" | "import" | "declaration" | "introduction", language: *"" | "" | "js" | "python"
		...
	}]
	let Sections = sections
	typeChecks:      rootTypeChecks
	typeProjections: _rootTypeProjections
	uriCheck:        rootURICheck

	_unions: {for Union in root.unions {(Union.name): (#Description & {value: Union.description}).text + "export type \(Union.name) =\n  | " + strings.Join(Union.members, "\n  | ") + ";\n"}}
	_contracts: {for Contract in root.contracts {
		(Contract.name): (#Description & {value: Contract.description}).text + "export " + strings.Join([
			if Contract.kind == "record" {"type " + Contract.name + " = Record<string, " + typeProjections[Contract.value].typescript + ">;"},
			if Contract.kind == "interface" {"interface " + Contract.name + strings.Join([if Contract.open {" extends Record<string, any>"}, if len(Contract.extends) > 0 {" extends " + strings.Join(Contract.extends, ", ")}], "") + " {\n" + strings.Join([for Field in Contract.fields {"  " + strings.Join([if Field.description != "" {"/** " + Field.description + " */\n  "}], "") + Field.name + strings.Join([if !Field.required {"?"}], "") + ": " + typeProjections[Field.type].typescript + ";"}], "\n") + "\n}"},
		], "") + "\n"
	}}
	_imports: {for Name, Imports in root.rootImports {(Name): strings.Join([for Import in Imports {"import { " + strings.Join(Import.names, ", ") + " } from '" + Import.source + "';"}], "\n") + "\n\n"}}

	_typeModules: {
		for Directory in ["marks", "interactors"] {
			let Candidates = list.Concat([
				[for Family in families for Path, _ in Family.files if strings.HasPrefix(Path, "packages/vgplot/spec/src/spec/"+Directory+"/") if strings.HasSuffix(Path, ".ts") {strings.TrimSuffix(strings.TrimPrefix(Path, "packages/vgplot/spec/src/spec/"+Directory+"/"), ".ts")}],
				[for Section in Sections if strings.HasPrefix(Section.path, "packages/vgplot/spec/src/spec/"+Directory+"/") if strings.HasSuffix(Section.path, ".ts") {strings.TrimSuffix(strings.TrimPrefix(Section.path, "packages/vgplot/spec/src/spec/"+Directory+"/"), ".ts")}],
			])
			(Directory): list.Sort([for i, Module in Candidates if Module != "index" if !list.Contains(list.Take(Candidates, i), Module) {Module}], list.Ascending)
		}
	}

	_sharedImports: {for Shell in fileShells {
		let Candidates = list.Concat([for Family in families for Group in Family.sharedTypeImports if Group.path == Shell.path {Group.imports}])
		let Imports = [for i, Import in Candidates if !list.Contains([for Prior in list.Take(Candidates, i) {Prior.name}], Import.name) {Import}]
		(Shell.path): strings.Join([for i, Import in Imports if !list.Contains([for Prior in list.Take(Imports, i) {Prior.source}], Import.source) {"import { " + strings.Join([for Member in Imports if Member.source == Import.source {Member.name}], ", ") + " } from '" + Import.source + "';"}], "\n")
	}}
	files: {
		"packages/vgplot/spec/src/spec/Spec.ts": _imports.Spec + strings.Join([for Contract in root.contracts if Contract.name != "Plot" {_contracts[Contract.name]}], "\n") + "\n" + _unions.SpecComponent + "\n" + _unions.Component + "\n" + (#Description & {value: root.specDescription}).text + "export type Spec = SpecHead & SpecComponent;\n"
		"packages/vgplot/spec/src/spec/Plot.ts": _imports.Plot + _contracts.Plot
		for Name in ["PlotMark", "PlotInteractor"] {
			let Union = root.unionIndex[Name]
			"packages/vgplot/spec/src/spec/\(Name).ts": strings.Join([for Import in Union.imports {"import { " + strings.Join(Import.names, ", ") + " } from '" + Import.source + "';"}], "\n") + "\n\n" + _unions[Name]
		}
		"packages/vgplot/spec/src/spec/index.ts": strings.Join([for Module in root.rootTypeModules {"export type * from './" + Module + ".js';"}, for Directory in ["marks", "interactors"] {"export type * from './" + Directory + "/index.js';"}], "\n") + "\n"
		for Directory in ["marks", "interactors"] {
			"packages/vgplot/spec/src/spec/\(Directory)/index.ts": strings.Join([for Module in _typeModules[Directory] {"export type * from './" + Module + ".js';"}], "\n") + "\n"
		}

		for Shell in fileShells {
			let Matching = [for Section in Sections if Section.path == Shell.path {Section}]
			(Shell.path): strings.TrimSpace(_sharedImports[Shell.path]+"\n"+Shell.prefix+strings.Join([for Section in Matching if Section.placement == "import" {Section.text}], "\n")+"\n"+strings.Join([for Section in Matching if Section.placement == "declaration" {Section.text}], "\n")+strings.Join([if Shell.opener != _|_ {Shell.opener}], "")+strings.Join([for Section in Matching if Section.placement == "body" {Section.text}], "\n")+strings.Join([if Shell.path == "packages/vgplot/spec/src/spec/Transform.ts" {strings.Join([for Union in root.unions if list.Contains(["ColumnTransform", "AggregateTransform", "WindowTransform", "Transform"], Union.name) {_unions[Union.name]}], "\n")}], "")+Shell.suffix) + "\n"
		}
		for Page in referencePages {
			(Page.path): Page.prefix + strings.Join([for Language in ["js", "python"] {
				let Matching = [for Section in Sections if Section.path == Page.path if Section.language == Language {Section}]
				let Introductions = [for Section in Matching if Section.placement == "introduction" {Section.text}]
				let Body = list.Sort([for Section in Matching if Section.placement == "body" {Section}], {x: _, y: _, less: x.id < y.id})
				"<template " + {js: "v-if", python: "v-else-if"}[Language] + "=\"language === '" + Language + "'\">\n\n" + Page.introduction + strings.Join(Introductions, "\n") + "\n" + strings.Join([for Section in Body {Section.text}], "\n") + "\n</template>\n"
			}], "\n") + "\n<LangError v-else :language=\"language\" />\n\n" + strings.Join([for Section in list.Sort([for Section in Sections if Section.path == Page.path if Section.language == "" {Section}], {x: _, y: _, less: x.id < y.id}) {Section.text}], "\n")
		}
	}
}
