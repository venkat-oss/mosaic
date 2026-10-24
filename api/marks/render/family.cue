package markrender

import (
	"list"
	"strings"
	"idl.uw.edu/mosaic/api/model"
	"idl.uw.edu/mosaic/api/render"
	common "idl.uw.edu/mosaic/api/marks/common/model:commonmodel"
	profile "idl.uw.edu/mosaic/api/marks/profile"
	pythonLanguage "idl.uw.edu/mosaic/api/languages/python"
)

#ConstructorHook: {profile: "explicit", name: "Density1DMark" | "ErrorBarMark"} | {profile: "implicit", name: "Density2DMark" | "DenseLineMark" | "ContourMark" | "HeatmapMark" | "RasterMark" | "RasterTileMark" | "HexbinMark" | "RegressionMark" | "GeoMark"}
#InterfaceContract: model.#ShapeContract & {kind: "interface"}
#Starter: {
	id!:   string & =~"^[A-Za-z][A-Za-z0-9_-]*$"
	mark!: model.#Name
	kind:  *"shared" | "shared" | "javascript"
	formats: [...string]
	if kind == "shared" {formats: ["json", "yaml", "js", "py"]}
	if kind == "javascript" {formats: ["js"]}
}
#Mark: {
	name!:      model.#Name
	contract!:  model.#Name
	jsSection!: string & !=""
	branchKey?: model.#Name
	profile!:   "ordinary" | "explicit" | "implicit"
	let Name = name
	let Profile = profile
	runtimeType: *Name | model.#Name
	if profile != "ordinary" {runtimeClass!: (#ConstructorHook & {profile: Profile}).name}
	if profile == "ordinary" {runtimeClass?: _|_}
}
#DeclarationFile: {
	basename!: model.#Name
	imports!: [...model.#Name]
	contracts!: [model.#Name, ...model.#Name]
	ownership: *"file" | "file" | "sections"
	if ownership == "file" {sections?: _|_}
	if ownership == "sections" {sections!: [{contract!: model.#Name, id!: string & !=""}, ...{contract!: model.#Name, id!: string & !=""}]}
}
#ReferenceNote: {marks!: [model.#Name, ...model.#Name], text!: string & !=""}
#ReferenceGroup: {title!: string & !="", names!: [model.#Name, ...model.#Name], sections!: {js!: string & !="", python!: string & !=""}}
#MarkFamilyProjection: {
	identity!: slug!: string & =~"^[a-z][a-z0-9_]*$"
	contracts!: [#InterfaceContract, ...#InterfaceContract]
	supportContracts: *[] | [...model.#ShapeContract & {kind: "alias"}]
	baseContracts: *[] | [...model.#ShapeContract]
	baseExpressions: *{} | {[string]: model.#ShapeExpression}
	baseImports: *[] | [...model.#ExternalReference]
	typeExpressions!: [string]: model.#ShapeExpression
	externalReferences: *[] | [...model.#ExternalReference]
	declarationFiles!: [#DeclarationFile, ...#DeclarationFile]
	marks!: [#Mark, ...#Mark]
	referenceGroups!: [#ReferenceGroup, ...#ReferenceGroup]
	referenceNotes: *[] | [...#ReferenceNote]
	starters: *[] | [...#Starter]
	starterFiles: *{} | {[string]: string}
	let Identity = identity
	let Contracts = list.Concat([contracts, supportContracts])
	let BaseContracts = baseContracts
	let BaseExpressions = baseExpressions
	let BaseImports = baseImports
	let Expressions = typeExpressions
	let External = externalReferences
	let DeclarationFiles = declarationFiles
	let Marks = marks
	let Groups = referenceGroups
	let Notes = referenceNotes
	let Starters = starters
	let StarterFiles = starterFiles
	_shape: render.#ShapeProjection & {
		contracts: Contracts
		baseContracts: list.Concat([common.contracts, BaseContracts])
		expressions: common.typeExpressions & BaseExpressions & Expressions
		externalReferences: list.Concat([common.externalReferences, External])
	}
	shapeChecks:        _shape.checks
	resolvedProperties: _shape.effectiveProperties
	typeProjections:    _shape.projections
	contractIndex: {for Contract in Contracts {(Contract.name): Contract}}
	let Index = contractIndex
	importIndex: {
		for Contract in common.contracts if Contract.exported {(Contract.name): {owner: "common-marks", source: "./Marks.js"}}
		for Reference in list.Concat([common.externalReferences, External, BaseImports]) {(Reference.name): {owner: Reference.owner, source: Reference.source}}
		for File in DeclarationFiles for Name in File.contracts {(Name): {owner: Identity.slug, source: "./\(File.basename).js"}}
	}

	_branches: {for Mark in Marks {
		if Index[Mark.contract].kind == "interface" {(Mark.contract): [_shape.effectiveProperties[Mark.contract]]}
		if Index[Mark.contract].kind == "alias" {(Mark.contract): _shape.contractProjections[Mark.contract].propertyBranches}
	}}
	resolvedBranches: _branches
	checks: {
		baseImportNames: true & list.UniqueItems([for Import in BaseImports {Import.name}])
		baseImportCoverage: true & (list.Sort([for Import in BaseImports {Import.name}], list.Ascending) == list.Sort([for Contract in BaseContracts if Contract.exported {Contract.name}], list.Ascending))
		markNames: true & list.UniqueItems([for Mark in Marks {Mark.name}])
		markContracts: true & list.UniqueItems([for Mark in Marks {Mark.contract}])
		jsSections: true & list.UniqueItems([for Mark in Marks {Mark.jsSection}])
		files: true & list.UniqueItems([for File in DeclarationFiles {File.basename}])
		contractFiles: true & (list.Sort([for File in DeclarationFiles for Name in File.contracts {Name}], list.Ascending) == list.Sort([for Contract in Contracts {Contract.name}], list.Ascending))
		groupCoverage: true & (list.Sort(list.Concat([for Group in Groups {Group.names}]), list.Ascending) == list.Sort([for Mark in Marks {Mark.name}], list.Ascending))
		for Mark in Marks {
			"mark_\(Mark.name)": true & Index[Mark.contract].wire
			"discriminators_\(Mark.name)": [for Branch in _branches[Mark.contract] {true & (_shape.projections[([for Property in Branch if Property.name == "mark" {Property.type}])[0]].schema.const == Mark.name)}]
			if Index[Mark.contract].kind == "interface" {"interface_\(Mark.name)": true & (Mark.branchKey == _|_)}
			if Index[Mark.contract].kind == "alias" {
				"alias_\(Mark.name)":     Expressions[Index[Mark.contract].expression].kind & "interface-union"
				"branchKey_\(Mark.name)": model.#Name & Mark.branchKey & !="mark" & !="data"
				"finiteBranches_\(Mark.name)": [for Branch in _branches[Mark.contract] {true & _shape.projections[([for Property in Branch if Property.name == Mark.branchKey {Property.type}])[0]].finite}]
				"disjointBranches_\(Mark.name)": true & list.UniqueItems(list.Concat([for Branch in _branches[Mark.contract] {_shape.projections[([for Property in Branch if Property.name == Mark.branchKey {Property.type}])[0]].finiteValues}]))
				if Mark.profile == "explicit" {
					"runtimeBranch_\(Mark.name)": true & list.Contains(list.Concat([for Branch in _branches[Mark.contract] {_shape.projections[([for Property in Branch if Property.name == Mark.branchKey {Property.type}])[0]].finiteValues}]), Mark.runtimeType)
					"optionalBranch_\(Mark.name)": [for Branch in _branches[Mark.contract] for Property in Branch if Property.name == Mark.branchKey if !Property.required {true & list.Contains(_shape.projections[Property.type].finiteValues, Mark.runtimeType)}]
				}
			}
		}
		for i, Note in Notes {"note_\(i)": true & list.UniqueItems(Note.marks), for Name in Note.marks {"note_\(i)_\(Name)": true & list.Contains([for Mark in Marks {Mark.name}], Name)}}
		starterIds: true & list.UniqueItems([for Starter in Starters {Starter.id}])
		starterFiles: len([for _, _ in StarterFiles {true}]) & len(list.Concat([for Starter in Starters {Starter.formats}]))
		for Starter in Starters {
			"starter_\(Starter.id)": true & list.Contains([for Mark in Marks {Mark.name}], Starter.mark)
			for Format in Starter.formats {
				"download_\(Starter.id)_\(Format)": string & StarterFiles["templates/marks/\(Identity.slug)/\(Starter.id).\(Format)"]
			}
		}
		for File in DeclarationFiles {
			if File.ownership == "sections" {
				"sectionContracts_\(File.basename)": true & (list.Sort([for Section in File.sections {Section.contract}], list.Ascending) == list.Sort(File.contracts, list.Ascending))
				"sectionIds_\(File.basename)": true & list.UniqueItems([for Section in File.sections {Section.id}])
			}
			"imports_\(File.basename)": true & list.UniqueItems(File.imports)
			for Name in File.imports {"import_\(File.basename)_\(Name)": true & (importIndex[Name].source != "./\(File.basename).js")}
		}
	}
	schemaFragment: definitions: {for Contract in Contracts if Contract.wire {(Contract.name): _shape.contractProjections[Contract.name].schema}}
	admissionDefinitions: _shape.admissionDefinitions
	nativeObjects:        _shape.nativeObjects
	nativeDefinitions: {for Contract in Contracts {(Contract.name): _shape.contractProjections[Contract.name].native}}
	sharedTypeImports: [for File in DeclarationFiles if File.ownership == "sections" {{
		path: "packages/vgplot/spec/src/spec/marks/" + File.basename + ".ts"
		imports: [for Name in File.imports {{name: Name, source: importIndex[Name].source}}]
	}}]

	runtimeClasses: list.Sort([for Name, _ in {for Mark in Marks if Mark.profile != "ordinary" {(Mark.runtimeClass): true}} {Name}], list.Ascending)
	pythonSymbols: [for Mark in Marks {{key: Mark.name, name: (pythonLanguage.#Identifier & {wire: Mark.name}).name, module: "\(Identity.slug)_marks"}}]
	pythonRecords: list.Sort([for Mark in Marks {{key: Mark.name, name: (pythonLanguage.#Identifier & {wire: Mark.name}).name, description: Index[Mark.contract].description, channels: ({ let Names = list.Concat([for Branch in _branches[Mark.contract] {list.Sort([for Property in Branch if Property.name != "mark" && Property.name != "data" {Property.name}], list.Ascending)}]), values: [for i, Name in Names if !list.Contains(list.Take(Names, i), Name) {Name}]}).values}}], {x: _, y: _, less: strings.ToLower(x.key) < strings.ToLower(y.key)})
	pythonProjection: profile.#PythonMarks & {marks: pythonRecords, publicModule: "vgplot._generated.marks"}
	pythonModule: strings.Replace(pythonProjection.text, "api/marks/common", "api/marks/\(Identity.slug)", 1)
	files: {
		for Path, Content in StarterFiles {(Path): Content}
		for File in DeclarationFiles if File.ownership == "file" {
			let Imports = [for Name in File.imports {{name: Name, source: importIndex[Name].source}}]
			"packages/vgplot/spec/src/spec/marks/\(File.basename).ts": "// Generated by pnpm generate:api from api/marks/\(Identity.slug). DO NOT EDIT.\n\n" + strings.Join([for i, Import in Imports if !list.Contains([for Prior in list.Take(Imports, i) {Prior.source}], Import.source) {"import { " + strings.Join([for Member in Imports if Member.source == Import.source {Member.name}], ", ") + " } from '" + Import.source + "';"}], "\n") + "\n\n" + strings.Join([for Name in File.contracts {_shape.contractProjections[Name].declaration}], "\n")
		}
		"packages/vgplot/vgplot-python/vgplot/_generated/\(Identity.slug)_marks.py": pythonModule
	}
	_wrapperText: {for Mark in Marks {
		let Runtime = profile.javascriptProfiles[Mark.profile]
		(Mark.name): "export const \(Mark.name) = (...args) => \(Runtime)(" + strings.Join([
			if Mark.profile != "ordinary" {Mark.runtimeClass},
			if Mark.profile != "implicit" {(render.#TypeScriptLiteral & {value: Mark.runtimeType}).text},
			"...args",
		], ", ") + ");\n"
	}}
	_referenceText: {for Group in Groups for Language in ["js", "python"] {
		let IsPython = Language == "python"
		"\(Language)-\(Group.title)": "## \(Group.title)\n\n" + strings.Join([for Name in Group.names {
			let Mark = ([for Entry in Marks if Entry.name == Name {Entry}])[0]
			let PublicName = strings.Join([if IsPython {(pythonLanguage.#Identifier & {wire: Name}).name}, if !IsPython {Name}], "")
			"### \(PublicName)\n\n`\(PublicName)(" + strings.Join([if IsPython {profile.pythonMarkProfile.data.name + "=" + profile.pythonMarkProfile.data.default + ", **options"}, if !IsPython {strings.Join([if !list.Contains(profile.decoratorTypes, Mark.runtimeType) {"data, "}, "options"], "")}], "") + ")`\n\n" + (render.#MarkdownReferences & {value: ([for Property in _branches[Mark.contract][0] if Property.name == "mark" {Property.description}])[0]}).text + "\n\n[Options](#\(strings.ToLower(Mark.contract))-options).\n"
		}], "\n") + "\n"
	}}
	_optionReference: "\n## \(Identity.slug) mark options\n\nOptions use their wire names below; Python keyword names use snake_case. See [common mark options](../spec/common-marks#markoptions) for shared channels and styles.\n\n" + strings.Join([for Contract in Contracts {
		"### \(Contract.name) options\n\n" + strings.Join([
			if !Contract.wire {(render.#MarkdownReferences & {value: Contract.description}).text + "\n\n"},
			if Contract.kind == "interface" {
				strings.Join([if len(Contract.extends) > 0 {"Extends " + strings.Join([for Base in _shape.baseSelections[Contract.name] {
					let Common = [for C in common.contracts if C.name == Base.name {C}]
					let Target = strings.Join([if len(Common) > 0 {"../spec/common-marks#" + strings.ToLower(Base.name)}, if len(Common) == 0 {"#" + strings.ToLower(Base.name) + "-options"}], "")
					"[`" + Base.typescript + "`](" + Target + ")"
				}], ", ") + ".\n\n"
				}], "") + strings.Join([for Property in Contract.properties if Property.name != "mark" && Property.name != "data" {
					let Inherited = [for Base in _shape.baseSelections[Contract.name] for Prior in _shape.effectiveProperties[Base.name] if Prior.name == Property.name if Prior.description == Property.description {Base.name}]
					"**" + Property.name + "** (`" + _shape.projections[Property.type].typescript + "`) — " + strings.Join([
						if len(Inherited) == 0 {(render.#MarkdownReferences & {value: Property.description}).text},
						if len(Inherited) > 0 {
							let Name = Inherited[0]
							let Common = [for C in common.contracts if C.name == Name {C}]
							"See [`" + Name + "." + Property.name + "`](" + strings.Join([if len(Common) > 0 {"../spec/common-marks#" + strings.ToLower(Name)}, if len(Common) == 0 {"#" + strings.ToLower(Name) + "-options"}], "") + ")."
						},
					], "") + "\n"
				}], "\n")
			},
			if Contract.kind == "alias" {
				if Expressions[Contract.expression].kind == "interface-union" {"Combines [`" + Expressions[Contract.expression].base + "`](#" + strings.ToLower(Expressions[Contract.expression].base) + "-options) with " + strings.Join([for Name in Expressions[Contract.expression].alternatives {"[`" + Name + "`](#" + strings.ToLower(Name) + "-options)"}], ", ") + ".\n"}
				if Expressions[Contract.expression].kind != "interface-union" {"```ts\n" + _shape.contractProjections[Contract.name].body + "\n```\n"}
			},
		], "")
	}], "\n") + "\n" + strings.Join([for Note in Notes {"**" + strings.Join([for Name in Note.marks {"`" + Name + "`"}], ", ") + ":** " + (render.#MarkdownReferences & {value: Note.text}).text + "\n"}], "\n") + strings.Join([if len(Starters) > 0 {"\n### " + Identity.slug + " examples\n\n" + strings.Join([for Starter in Starters {
		strings.Join([if Starter.kind == "javascript" {"JavaScript-only "}], "") + "`\(Starter.id)`: " + strings.Join([for Format in Starter.formats {if Format != "py" {"[\(Format)](/templates/marks/\(Identity.slug)/\(Starter.id).\(Format))"}, if Format == "py" {"<a :href=\"withBase('/templates/marks/\(Identity.slug)/\(Starter.id).py')\" download>Python</a>"}}], " · ") + ".\n"
	}], "\n")
	}], "")
	sections: [
		{path: "docs/api/vgplot/marks.md", id: "options-\(Identity.slug)", owner: Identity.slug, text: _optionReference},
		for File in DeclarationFiles if File.ownership == "sections" for Section in File.sections {{path: "packages/vgplot/spec/src/spec/marks/\(File.basename).ts", id: Section.id, owner: Identity.slug, text: (render.#DeclarationSection & {declaration: _shape.contractProjections[Section.contract].declaration}).text}},
		for Mark in Marks {{path: "packages/vgplot/vgplot/src/plot/marks.js", id: Mark.jsSection, owner: Identity.slug, text: _wrapperText[Mark.name]}},
		for Group in Groups for Language in ["js", "python"] {{path: "docs/api/vgplot/marks.md", id: Group.sections[Language], owner: Identity.slug, language: Language, text: _referenceText["\(Language)-\(Group.title)"]}},
	]
}
