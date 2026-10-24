package api

import (
	sourceCatalog "idl.uw.edu/mosaic/api/catalog:catalogsources"

	"encoding/json"
	"list"
	"strings"

	"idl.uw.edu/mosaic/api/model"
	rootspec "idl.uw.edu/mosaic/api/spec:rootspec"
	"idl.uw.edu/mosaic/api/compose"
)

input: {families!: [...{source!: string}]}
familySources: sourceCatalog.sources
familyEntries: [for source in familySources {
	let Matches = [for family in input.families if family.source == source {family}]
	([{publicAPI: compose.#PublicContribution, markRuntimeClasses: *[] | [...string], sections: *[] | [...{path!: string, id!: string, text!: string, ...}], registrations: *[] | [...], interactorRegistrations: *[] | [...], interactorAliases: *[] | [...], pythonInteractors: *[] | [...], interactorRuntimeClasses: *[] | [...]}] & Matches)[0]
}]
_familySources: [for family in input.families {true & list.Contains(familySources, family.source)}]

ownedSymbols: model.#Symbols & {
	for group in ["marks", "attributes", "encodings", "legends"] {
		"\(group)": list.Concat([for family in familyEntries {family.symbols[group]}])
	}
}
interactorRegistry: compose.#InteractorRegistry & {
	owned: list.Concat([for family in familyEntries {family.interactorRegistrations}])
	ownedAliases: list.Concat([for family in familyEntries {family.interactorAliases}])
	python: list.Concat([for family in familyEntries {family.pythonInteractors}])
	ownedRuntimeClasses: list.Concat([for family in familyEntries {family.interactorRuntimeClasses}])
}
transformReference: compose.#TransformReference & {sections: list.Concat([for family in familyEntries {family.referenceSections}])}
transformRegistry: compose.#TransformRegistry & {owned: list.Concat([for family in familyEntries {family.registrations}])}
#NativeCheck: {
	files!: {[string & =~"^[A-Za-z0-9][A-Za-z0-9_.-]*\\.cue$"]: string}
	if len(files) == 0 {files: _|_("native check groups require at least one CUE file")}
}
nativeChecks: [...#NativeCheck] & list.Concat([
	list.Concat([for family in familyEntries {family.nativeChecks}]),
	[{files: {
		"spec.cue": rootProjection.nativeSource
		"templates.cue": "package specadmission\n\n" + strings.Join([for Path, Content in files if strings.HasPrefix(Path, "templates/") if strings.HasSuffix(Path, ".json") {json.Marshal(Path) + ": #Spec & " + Content}], "\n")
	}}],
])

rootProjection: rootspec.#RootProjection & {families: familyEntries}
publicComposition: compose.#PublicComposition & {
	contributions: [for family in familyEntries {family.publicAPI}]
	interactors: list.Concat([for family in familyEntries {family.pythonInteractors}])
}
_markConstructors: list.Sort([for Name, _ in {for Family in familyEntries for Name in Family.markRuntimeClasses {(Name): true}} {Name}], list.Ascending)
sectionEntries: list.Concat([
	list.Concat([for family in familyEntries {family.sections}]),
	[
		{path: "packages/vgplot/vgplot/src/plot/marks.js", id: "constructors", placement: "import", text: "import {\n" + strings.Join([for Name in _markConstructors {"  " + Name}], ",\n") + "\n} from '@uwdata/mosaic-plot';\nimport { mark, explicitType, implicitType } from './mark-runtime.js';\n"},
		{path: "packages/vgplot/vgplot/src/plot/interactors.js", id: "runtime", placement: "import", text: interactorRegistry.importSection},
	],
])
rootTypes: rootspec.#RootTypes & {families: familyEntries, sections: sectionEntries}
_paths: list.Concat([
	[for path, _ in interactorRegistry.files {path}],
	list.Concat([for family in familyEntries {[for path, _ in family.files {path}]}]),
	[for path, _ in rootProjection.files {path}],
	[for path, _ in rootTypes.files {path}],
	[for path, _ in python.files {path}],
	[for path, _ in rootspec.docFiles {path}],
	[for path, _ in rootspec.templateFiles {path}],
	[for path, _ in publicComposition.files {path}],
	[for path, _ in transformReference.files {path}],
	[for path, _ in transformRegistry.files {path}],
	["packages/vgplot/spec/src/generated/mosaic-schema.json", "api/generated.json"],
])
_pathOrdinals: {for ordinal, path in _paths {(path): ordinal}}
checks: {
	familyIds: true & list.UniqueItems([for family in familyEntries {family.id}])
	paths: true & (json.Marshal(_pathOrdinals) != "")
}
earlyFiles: {
	for path, content in interactorRegistry.files {(path): content}
	for path, content in publicComposition.files {(path): content}
	for path, content in transformReference.files {(path): content}
	for path, content in transformRegistry.files {(path): content}
	for family in familyEntries {for path, content in family.files {(path): content}}
	for path, content in rootProjection.files {(path): content}
	for path, content in rootTypes.files {(path): content}
}
python: compose.#Python & {owned: ownedSymbols}
files: earlyFiles & python.files & rootProjection.directSchemaFiles & rootspec.docFiles & rootspec.templateFiles

manifest: [for path, _ in files {path}]
