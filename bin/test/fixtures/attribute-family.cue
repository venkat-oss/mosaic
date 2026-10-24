package attributetest

import (
	attributeRender "idl.uw.edu/mosaic/api/attributes/render:attributerender"
	paramFamily "idl.uw.edu/mosaic/api/params"
	valueFamily "idl.uw.edu/mosaic/api/values"
)

candidate: attributeRender.#AttributeFamilyProjection & {
	identity: {slug: "size", helperName: "TestAttributes"}
	attributes: [
		{name: "aNice", description: "A sample attribute.", type: "niceValue", tsSection: "aNice-1", jsSection: "aNice-2", jsKind: "simple", python: {name: "a_nice", default: "true", kind: "value"}, route: {kind: "mapped", path: "a.nice", order: 0}},
		{name: "bNice", description: "B sample attribute.", type: "niceValue", tsSection: "bNice-1", jsSection: "bNice-2", jsKind: "simple", python: {name: "b_nice", default: "required", kind: "value"}, route: {kind: "mapped", path: "b.nice", order: 1}},
	]
	typeExpressions: {
		numberValue: {kind: "primitive", type: "number"}
		ParamRef: {kind: "named", name: "ParamRef"}
		Interval: {kind: "named", name: "Interval"}
		niceValue: {kind: "union", members: ["numberValue", "Interval", "ParamRef"]}
	}
	contracts: [
		{name: "TestAttributes", description: "Test attributes.", wire: false, exported: false, kind: "interface", extends: [], properties: [
			{name: "aNice", description: "A sample attribute.", required: false, type: "niceValue"},
			{name: "bNice", description: "B sample attribute.", required: false, type: "niceValue"},
		]},
		{name: "ValueAlias", description: "A value alias.", wire: true, exported: true, documentationAdapter: "reference-only", kind: "alias", expression: "numberValue"},
	]
	externalReferences: [{name: "ParamRef", owner: "params", source: "./Param.js"}, {name: "Interval", owner: "values", source: "./PlotTypes.js"}]
	nativeReferences: {
		ParamRef: paramFamily.nativeDefinitions.ParamRef
		for Name in ["Interval", "LiteralTimeInterval", "TimeIntervalName"] {(Name): valueFamily.nativeDefinitions[Name]}
	}
	aliasSections: [{name: "ValueAlias", id: "ValueAlias-0"}]
	referenceGroups: [{id: "sample", title: "Sample Attributes", attributes: ["aNice", "bNice"], sections: {js: "js-sample", python: "py-sample"}}]
}
selectedFiles: {}
