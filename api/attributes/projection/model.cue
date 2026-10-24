package projectionattributes

import (
	"list"
	attributeModel "idl.uw.edu/mosaic/api/attributes"
)

#ProjectionAttribute: attributeModel.#Attribute & {
	name!:  =~"^projection[A-Z]"
	type!:  string
	jsKind: "simple"
	python: kind: "value"
	route: kind:  "mapped"
	if name == "projectionClip" {python: default: "true"}
	if name != "projectionClip" {python: default: "required"}
}

attributes: [...#ProjectionAttribute] & [
	{
		name:        "projectionType"
		type:        "projectionValue"
		description: "The desired projection; one of:\n\n- a named built-in projection such as *albers-usa*\n- null, for no projection\n\nNamed projections are scaled and translated to fit\nthe **domain** to the plot’s frame (minus insets)."
		tsSection:   "projectionType-209"
		jsSection:   "projectionType-210"
		jsKind:      "simple"
		python: {name: "projection_type", default: "required", kind: "value"}
		route: {kind: "mapped", path: "projection.type", order: 0}
	},
	{
		name:        "projectionDomain"
		type:        "domainValue"
		description: "A GeoJSON object to fit to the plot’s frame (minus insets); defaults to a\nSphere for spherical projections (outline of the the whole globe)."
		tsSection:   "projectionDomain-210"
		jsSection:   "projectionDomain-214"
		jsKind:      "simple"
		python: {name: "projection_domain", default: "required", kind: "value"}
		route: {kind: "mapped", path: "projection.domain", order: 4}
	},
	{
		name:        "projectionRotate"
		type:        "rotationValue"
		description: "A rotation of the sphere before projection; defaults to [0, 0, 0].\nSpecified as Euler angles λ (yaw, or reference longitude), φ (pitch, or\nreference latitude), and optionally γ (roll), in degrees."
		tsSection:   "projectionRotate-211"
		jsSection:   "projectionRotate-213"
		jsKind:      "simple"
		python: {name: "projection_rotate", default: "required", kind: "value"}
		route: {kind: "mapped", path: "projection.rotate", order: 3}
	},
	{
		name:        "projectionParallels"
		type:        "parallelsValue"
		description: "The [standard parallels][1]. For conic projections only.\n\n[1]: https://d3js.org/d3-geo/conic#conic_parallels"
		tsSection:   "projectionParallels-212"
		jsSection:   "projectionParallels-211"
		jsKind:      "simple"
		python: {name: "projection_parallels", default: "required", kind: "value"}
		route: {kind: "mapped", path: "projection.parallels", order: 1}
	},
	{
		name:        "projectionPrecision"
		type:        "numberReference"
		description: "The projection’s [sampling threshold][1].\n\n[1]: https://d3js.org/d3-geo/projection#projection_precision"
		tsSection:   "projectionPrecision-213"
		jsSection:   "projectionPrecision-212"
		jsKind:      "simple"
		python: {name: "projection_precision", default: "required", kind: "value"}
		route: {kind: "mapped", path: "projection.precision", order: 2}
	},
	{
		name:        "projectionClip"
		type:        "clipValue"
		description: "The projection’s clipping method; one of:\n\n- *frame* or true (default) - clip to the plot’s frame (including margins but not insets)\n- a number - clip to a circle of the given radius in degrees centered around the origin\n- null or false - do not clip\n\nSome projections (such as [*armadillo*][1] and [*berghaus*][2]) require\nspherical clipping: in that case set the marks’ **clip** option to\n*sphere*.\n\n[1]: https://observablehq.com/@d3/armadillo\n[2]: https://observablehq.com/@d3/berghaus-star"
		tsSection:   "projectionClip-214"
		jsSection:   "projectionClip-220"
		jsKind:      "simple"
		python: {name: "projection_clip", default: "true", kind: "value"}
		route: {kind: "mapped", path: "projection.clip", order: 10}
	},
	{
		name:        "projectionInset"
		type:        "numberReference"
		description: "Shorthand to set the same default for all four projection insets.\nAll insets typically default to zero, though not always. A positive\ninset reduces effective area, while a negative inset increases it."
		tsSection:   "projectionInset-215"
		jsSection:   "projectionInset-215"
		jsKind:      "simple"
		python: {name: "projection_inset", default: "required", kind: "value"}
		route: {kind: "mapped", path: "projection.inset", order: 5}
	},
	{
		name:        "projectionInsetTop"
		type:        "numberReference"
		description: "Insets the top edge of the projection by the specified number of pixels.\nA positive value insets towards the bottom edge (reducing effective area),\nwhile a negative value insets away from the bottom edge (increasing it)."
		tsSection:   "projectionInsetTop-216"
		jsSection:   "projectionInsetTop-218"
		jsKind:      "simple"
		python: {name: "projection_inset_top", default: "required", kind: "value"}
		route: {kind: "mapped", path: "projection.insetTop", order: 8}
	},
	{
		name:        "projectionInsetRight"
		type:        "numberReference"
		description: "Insets the right edge of the projection by the specified number of pixels.\nA positive value insets towards the left edge (reducing effective area),\nwhile a negative value insets away from the left edge (increasing it)."
		tsSection:   "projectionInsetRight-217"
		jsSection:   "projectionInsetRight-217"
		jsKind:      "simple"
		python: {name: "projection_inset_right", default: "required", kind: "value"}
		route: {kind: "mapped", path: "projection.insetRight", order: 7}
	},
	{
		name:        "projectionInsetBottom"
		type:        "numberReference"
		description: "Insets the bottom edge of the projection by the specified number of pixels.\nA positive value insets towards the top edge (reducing effective area),\nwhile a negative value insets away from the top edge (increasing it)."
		tsSection:   "projectionInsetBottom-218"
		jsSection:   "projectionInsetBottom-219"
		jsKind:      "simple"
		python: {name: "projection_inset_bottom", default: "required", kind: "value"}
		route: {kind: "mapped", path: "projection.insetBottom", order: 9}
	},
	{
		name:        "projectionInsetLeft"
		type:        "numberReference"
		description: "Insets the left edge of the projection by the specified number of pixels.\nA positive value insets towards the right edge (reducing effective area),\nwhile a negative value insets away from the right edge (increasing it)."
		tsSection:   "projectionInsetLeft-219"
		jsSection:   "projectionInsetLeft-216"
		jsKind:      "simple"
		python: {name: "projection_inset_left", default: "required", kind: "value"}
		route: {kind: "mapped", path: "projection.insetLeft", order: 6}
	},
]

attributeIndex: {for attribute in attributes {(attribute.name): attribute}}
checks: {
	names: true & list.UniqueItems([for attribute in attributes {attribute.name}])
	pythonNames: true & list.UniqueItems([for attribute in attributes {attribute.python.name}])
	tsSections: true & list.UniqueItems([for attribute in attributes {attribute.tsSection}])
	jsSections: true & list.UniqueItems([for attribute in attributes {attribute.jsSection}])
	routes: true & list.UniqueItems([for attribute in attributes {attribute.route.path}])
}
