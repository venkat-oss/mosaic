package layouts

import (
	"encoding/json"
	"encoding/yaml"
	"list"
)

#LayoutExample: {
	name!: or([for layout in layouts {layout.name}])
	gap!: number | string
}
layoutExamples: [...#LayoutExample] & [{name: "hconcat", gap: 12}]
exampleDefaults: {width: 180, height: 140, radius: 4, nestedGap: 8}
exampleQuery: "SELECT * FROM (VALUES (1, 2, 'A'), (2, 1, 'B'), (3, 3, 'A')) AS t(x, y, category)"
exampleChecks: {
	names: true & list.UniqueItems([for item in layoutExamples {item.name}])
}

#LayoutExampleProjection: {
	example!: #LayoutExample
	let Item = example
	let Layout = layoutIndex[Item.name]
	let Plot = {plot: [{mark: "dot", data: {from: "layout_data"}, x: "x", y: "y", r: "$radius"}]}
	let Defaults = exampleDefaults
	root: {
		if Item.name == "hconcat" {hconcat: [Plot, {hspace: Item.gap}, {vconcat: [Plot, {vspace: Defaults.nestedGap}, Plot]}]}
		if Item.name == "vconcat" {vconcat: [Plot, {vspace: Item.gap}, {hconcat: [Plot, {hspace: Defaults.nestedGap}, Plot]}]}
		if Item.name == "hspace" {hconcat: [Plot, {hspace: Item.gap}, Plot]}
		if Item.name == "vspace" {vconcat: [Plot, {vspace: Item.gap}, Plot]}
	}
	let Root = root
	spec: {
		data: layout_data: {type: "table", query: exampleQuery}
		params: radius: Defaults.radius
		plotDefaults: {width: Defaults.width, height: Defaults.height}
		for key, value in Root {(key): value}
	}
	js:     string
	python: string
	if Layout.kind == "concat" {
		let Other = [for candidate in layouts if candidate.kind == "concat" if candidate.name != Item.name {candidate}][0]
		let Spacer = [for candidate in layouts if candidate.kind == "space" if candidate.dimension == {horizontal: "width", vertical: "height"}[Layout.direction] {candidate}][0]
		let OtherSpacer = [for candidate in layouts if candidate.kind == "space" if candidate.name != Spacer.name {candidate}][0]
		js:     "vg.\(Layout.name)(chart(), vg.\(Spacer.name)(\(json.Marshal(Item.gap))), vg.\(Other.name)(chart(), vg.\(OtherSpacer.name)(\(Defaults.nestedGap)), chart()))"
		python: "vg.\(Layout.name)(chart(), vg.\(Spacer.name)(\(json.Marshal(Item.gap))), vg.\(Other.name)(chart(), vg.\(OtherSpacer.name)(\(Defaults.nestedGap)), chart()))"
	}
	if Layout.kind == "space" {
		let Parent = [for candidate in layouts if candidate.kind == "concat" if {horizontal: "width", vertical: "height"}[candidate.direction] == Layout.dimension {candidate}][0]
		js:     "vg.\(Parent.name)(chart(), vg.\(Layout.name)(\(json.Marshal(Item.gap))), chart())"
		python: "vg.\(Parent.name)(chart(), vg.\(Layout.name)(\(json.Marshal(Item.gap))), chart())"
	}
}
exampleProjections: {for item in layoutExamples {(item.name): #LayoutExampleProjection & {example: item}}}
_layoutTemplateFiles: {
	for item in layoutExamples {
		let Projection = exampleProjections[item.name]
		"\(item.name).json": json.Indent(json.Marshal(Projection.spec), "", "  ") + "\n"
		"\(item.name).yaml": yaml.Marshal(Projection.spec)
		"\(item.name).js":   """
			import * as vg from '@uwdata/vgplot';

			await vg.coordinator().exec(vg.createTable('layout_data', \(json.Marshal(exampleQuery))));
			const radius = vg.Param.value(\(exampleDefaults.radius));
			const chart = () => vg.plot(
			  vg.dot(vg.from('layout_data'), {x: 'x', y: 'y', r: radius}),
			  vg.width(\(exampleDefaults.width)),
			  vg.height(\(exampleDefaults.height))
			);

			export default \(Projection.js);

			"""
		"\(item.name).py":   """
			from __future__ import annotations

			import vgplot as vg

			radius = vg.param(\(exampleDefaults.radius))


			def chart() -> vg.View:
			    return vg.plot(vg.dot("layout_data", x="x", y="y", r=radius))


			view = vg.spec(
			    data={"layout_data": vg.table(\(json.Marshal(exampleQuery)))},
			    params={"radius": radius},
			    plot_defaults={"width": \(exampleDefaults.width), "height": \(exampleDefaults.height)},
			    view=\(Projection.python),
			)

			"""
	}
}
templateFiles: {
	for name, content in _layoutTemplateFiles {
		"templates/layouts/\(name)": content
	}
}
