package rootspec

import (
	"encoding/json"
	"list"
	"strings"
	root "idl.uw.edu/mosaic/api/spec/model:specmodel"
)

#NativeField: {name!: string & !="", required!: bool, native!: string & !=""}
#NativeBranch: {preferred!: bool, fields!: [...#NativeField]}
#ObjectSource: {
	fields!: [...#NativeField]
	open: *false | bool
	text: "{" + strings.Join([for Field in fields {json.Marshal(Field.name) + strings.Join([if Field.required {"!"}, if !Field.required {"?"}], "") + ": " + Field.native}, if open {"..."}], ", ") + "}"
}
#RootProjection: {
	families!: [...{
		id!: string
		native!: {
			definitions!: [string]: string
			objects: *{} | {[string]: [...#NativeBranch]}
			attributes: *{} | {[string]: string}
		}
		schemas!: [...{definitions: *{} | {...}, properties: *[] | [...{definition!: string, values!: [string]: _
			...
		}]
			...
		}]
		...
	}]
	let Families = families
	typeChecks:      rootTypeChecks
	typeProjections: _rootTypeProjections
	uriCheck:        rootURICheck

	modelAdmission: root
	_definitions: {for Family in Families for Name, Native in Family.native.definitions {(Name): Native}}
	_objects: {for Family in Families for Name, Branches in Family.native.objects {(Name): Branches}}
	_attributes: {for Family in Families for Name, Native in Family.native.attributes {(Name): Native}}
	_leafSchemas: {for Family in Families for Fragment in Family.schemas for Name, Schema in Fragment.definitions {(Name): Schema}}
	_attributeSchemas: {for Family in Families for Fragment in Family.schemas for Patch in Fragment.properties if Patch.definition == "PlotAttributes" for Name, Schema in Patch.values {(Name): Schema}}
	_attributeFields: [for Name, Native in _attributes {{name: Name, required: false, native: Native}}]
	_rootObjects: {
		for Contract in root.contracts if Contract.kind == "interface" {
			(Contract.name): [{preferred: false, fields: list.Concat([
				for Name in Contract.extends if Name == "PlotAttributes" {_attributeFields},
				[for Field in Contract.fields {{name: Field.name, required: Field.required, native: typeProjections[Field.type].native}}],
			])
			}]
		}
		PlotAttributes: [{preferred: false, fields: _attributeFields}]
	}
	_head: _rootObjects.SpecHead[0].fields
	_headNames: [for Field in _head {Field.name}]

	_componentNames: root.componentTypes
	_objectIndex:    _objects & _rootObjects
	_componentBranches: list.Concat([for Name in _componentNames {_objectIndex[Name]}])
	_specBranches: [for Branch in _componentBranches {{
		preferred: Branch.preferred
		fields: list.Concat([
			[for Field in Branch.fields if !list.Contains(_headNames, Field.name) {Field}],
			[for Field in _head {{
				name:   Field.name
				native: Field.native
				required: Field.required || list.Contains([for Original in Branch.fields if Original.required {Original.name}], Field.name)
			}}],
		])
	}}]
	nativeDefinitions: _definitions & {
		for Contract in root.contracts {
			if Contract.kind == "interface" {
				(Contract.name): (#ObjectSource & {fields: _rootObjects[Contract.name][0].fields, open: Contract.open}).text
			}
			if Contract.kind == "record" {(Contract.name): "{[string]: " + typeProjections[Contract.value].native + "}"}
		}
		PlotAttributes: (#ObjectSource & {fields: _attributeFields}).text
		for Union in root.unions {(Union.name): "matchN(>=1, [" + strings.Join([for Name in Union.members {"#" + Name}], ", ") + "])"}
		for i, Branch in _specBranches {("Admission_Spec_" + "\(i)"): (#ObjectSource & {fields: Branch.fields}).text}
		Spec: "matchN(>=1, [" + strings.Join([for i, _ in _specBranches {"#Admission_Spec_" + "\(i)"}], ", ") + "])"
	}
	nativeSource: "package specadmission\n\nimport (\"time\"\n\"net\")\n\n" + strings.Join([for Name, Native in nativeDefinitions {"#\(Name): \(Native)\n"}], "\n")
	_rootSchemas: {
		for Contract in root.contracts if Contract.name != "SpecHead" {
			(Contract.name): {
				description: Contract.description
				type:        "object"
				if Contract.kind == "record" {additionalProperties: typeProjections[Contract.value].schema}
				if Contract.kind == "interface" {
					if !Contract.open {additionalProperties: false}
					properties: {
						for Name in Contract.extends if Name == "PlotAttributes" {for Key, Value in _attributeSchemas {(Key): Value}}
						for Field in Contract.fields {(Field.name): {for Key, Value in typeProjections[Field.type].schema {(Key): Value}, if Field.description != "" {description: Field.description}}}
					}
					let Required = [for Field in Contract.fields if Field.required {Field.name}]
					if len(Required) > 0 {required: Required}
				}
			}
		}
		PlotAttributes: {description: root.plotAttributesDescription, type: "object", additionalProperties: false, properties: _attributeSchemas}
		for Union in root.unions {(Union.name): {description: Union.description, anyOf: [for Name in Union.members {{
			$ref: "#/definitions/" + Name
		}}]}}
	}
	_allSchemas: _leafSchemas & _rootSchemas
	_headSchemas: {for Field in root.contractIndex.SpecHead.fields {(Field.name): {for Key, Value in typeProjections[Field.type].schema {(Key): Value}, description: Field.description}}}

	_schemaGroups: {for Name in _componentNames {
		if _allSchemas[Name].anyOf == _|_ {(Name): [_allSchemas[Name]]}
		if _allSchemas[Name].anyOf != _|_ {(Name): _allSchemas[Name].anyOf}
	}}
	_schemaBranches: list.Concat([for Name in _componentNames {_schemaGroups[Name]}])

	directSchema: {
		$ref:    "#/definitions/Spec"
		$schema: "http://json-schema.org/draft-07/schema#"
		definitions: _allSchemas & {
			Spec: {
				description: root.specDescription
				anyOf: [for Branch in _schemaBranches {{
					additionalProperties: false
					type:                 "object"
					properties: {
						for Name, Value in Branch.properties if !list.Contains(_headNames, Name) {(Name): Value}
						for Name, Value in _headSchemas {(Name): Value}
					}
					required: list.Sort(Branch.required, list.Ascending)
				}}]
			}
		}
	}
	directSchemaFiles: "packages/vgplot/spec/src/generated/mosaic-schema.json": json.Indent(json.Marshal(directSchema), "", "  ") + "\n"
	files: "packages/vgplot/spec/src/generated/spec.cue":                       nativeSource
	checks: {
		contracts: true & list.UniqueItems([for Family in Families for Name, _ in Family.native.definitions {Name}])
		attributes: true & list.UniqueItems([for Family in Families for Name, _ in Family.native.attributes {Name}])
		components: [for Name in _componentNames {true & list.Contains(list.Concat([[for Key, _ in _objects {Key}], ["Plot"]]), Name)}]
		markCoverage: true & (list.Sort(root.markTypes, list.Ascending) == list.Sort([for Family in Families if strings.HasSuffix(Family.id, "-marks") && Family.id != "common-marks" for Fragment in Family.schemas for Name, _ in Fragment.definitions if list.Contains([for Key, _ in Family.native.objects {Key}], Name) {Name}], list.Ascending))
	}
}
