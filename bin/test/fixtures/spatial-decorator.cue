package fixture

import family "idl.uw.edu/mosaic/api/marks/render:markrender"

projection: family.#MarkFamilyProjection & {
	identity: slug: "fixture"
	contracts: [{name: "Fixture", description: "The fixture mark.", wire: true, kind: "interface", extends: [], properties: [{name: "mark", description: "A fixture mark.", required: true, type: "fixtureLiteral"}]}]
	typeExpressions: fixtureLiteral: {kind: "literal", value: "fixture"}
	declarationFiles: [{basename: "Fixture", imports: [], contracts: ["Fixture"]}]
	marks: [{name: "fixture", contract: "Fixture", jsSection: "fixture-1", profile: "ordinary"}]
	referenceGroups: [{title: "Fixture", names: ["fixture"], sections: {js: "js-Fixture", python: "python-Fixture"}}]
}
