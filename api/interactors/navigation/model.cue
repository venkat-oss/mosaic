package navigationinteractors

import (
	"idl.uw.edu/mosaic/api/model"
	interactorRender "idl.uw.edu/mosaic/api/interactors/render:interactorrender"
)

contracts: [...model.#ShapeContract] & [
	{
		name:        "PanZoomOptions"
		description: "Options for pan/zoom interactors."
		wire:        false
		properties: [
			{
				name:        "x"
				description: "The output selection for the `x` domain. A clause of the form `field BETWEEN x1 AND x2` is added for the current pan/zom interval [x1, x2]."
				type:        "paramRef"
			},
			{
				name:        "y"
				description: "The output selection for the `y` domain. A clause of the form `field BETWEEN y1 AND y2` is added for the current pan/zom interval [y1, y2]."
				type:        "paramRef"
			},
			{
				name:        "xfield"
				description: "The name of the field (database column) over which the `x`-component of the pan/zoom interval should be defined. If unspecified, the `x` channel field of the first valid prior mark definition is used."
				type:        "string"
			},
			{
				name:        "yfield"
				description: "The name of the field (database column) over which the `y`-component of the pan/zoom interval should be defined. If unspecified, the `y` channel field of the first valid prior mark definition is used."
				type:        "string"
			},
		]
	},
	{
		name:        "Pan"
		description: "A pan interactor."
		extends: [{name: "PanZoomOptions", operator: "all", keys: []}]
		properties: [{name: "select", description: "Pan a plot along both the `x` and `y` scales.", required: true, type: "PanSelect"}]
	},
	{
		name:        "PanX"
		description: "A panX interactor."
		extends: [{name: "PanZoomOptions", operator: "all", keys: []}]
		properties: [{name: "select", description: "Pan a plot along the `x` scale only.", required: true, type: "PanXSelect"}]
	},
	{
		name:        "PanY"
		description: "A panY interactor."
		extends: [{name: "PanZoomOptions", operator: "all", keys: []}]
		properties: [{name: "select", description: "Pan a plot along the `y` scale only.", required: true, type: "PanYSelect"}]
	},
	{
		name:        "PanZoom"
		description: "A panZoom interactor."
		extends: [{name: "PanZoomOptions", operator: "all", keys: []}]
		properties: [
			{
				name:        "select"
				description: "Pan and zoom a plot along both the `x` and `y` scales."
				required:    true
				type:        "PanZoomSelect"
			}
		]
	},
	{
		name:        "PanZoomX"
		description: "A panZoomX interactor."
		extends: [{name: "PanZoomOptions", operator: "all", keys: []}]
		properties: [{name: "select", description: "Pan and zoom a plot along the `x` scale only.", required: true, type: "PanZoomXSelect"}]
	},
	{
		name:        "PanZoomY"
		description: "A panZoomY interactor."
		extends: [{name: "PanZoomOptions", operator: "all", keys: []}]
		properties: [{name: "select", description: "Pan and zoom a plot along the `y` scale only.", required: true, type: "PanZoomYSelect"}]
	},
]

typeExpressions: {[string]: model.#ShapeExpression} & {
	string: {kind: "primitive", type: "string"}
	paramRef: {kind: "named", name: "ParamRef"}
	PanSelect: {kind: "literal", value: "pan"}
	PanXSelect: {kind: "literal", value: "panX"}
	PanYSelect: {kind: "literal", value: "panY"}
	PanZoomSelect: {kind: "literal", value: "panZoom"}
	PanZoomXSelect: {kind: "literal", value: "panZoomX"}
	PanZoomYSelect: {kind: "literal", value: "panZoomY"}
}

declarationFiles: [...interactorRender.#DeclarationFile] & [
	{
		path: "packages/vgplot/spec/src/spec/interactors/PanZoom.ts"
		imports: [{source: "../Param.js", names: ["ParamRef"]}]
		contracts: ["PanZoomOptions", "Pan", "PanX", "PanY", "PanZoom", "PanZoomX", "PanZoomY"]
	}
]

interactors: [...interactorRender.#Interactor] & [
	{
		contract:    "Pan"
		wrapperSlot: "pan-16"
		group:       "navigation"
		javascript: {profile: "navigation", runtimeClass: "PanZoom", forced: zoom: false}
		python: {arguments: [{wire: "x"}, {wire: "y"}, {wire: "xfield"}, {wire: "yfield"}], extras: false}
	},
	{
		contract:    "PanX"
		wrapperSlot: "panX-17"
		group:       "navigation"
		javascript: {profile: "navigation", runtimeClass: "PanZoom", forced: {zoom: false, pany: false}}
		python: {arguments: [{wire: "x"}, {wire: "xfield"}], extras: false}
	},
	{
		contract:    "PanY"
		wrapperSlot: "panY-18"
		group:       "navigation"
		javascript: {profile: "navigation", runtimeClass: "PanZoom", forced: {zoom: false, panx: false}}
		python: {arguments: [{wire: "y"}, {wire: "yfield"}], extras: false}
	},
	{
		contract:    "PanZoom"
		wrapperSlot: "panZoom-19"
		group:       "navigation"
		javascript: {profile: "navigation", runtimeClass: "PanZoom", forced: {}}
		python: {arguments: [{wire: "x"}, {wire: "y"}, {wire: "xfield"}, {wire: "yfield"}], extras: false}
	},
	{
		contract:    "PanZoomX"
		wrapperSlot: "panZoomX-20"
		group:       "navigation"
		javascript: {profile: "navigation", runtimeClass: "PanZoom", forced: pany: false}
		python: {arguments: [{wire: "x"}, {wire: "xfield"}], extras: false}
	},
	{
		contract:    "PanZoomY"
		wrapperSlot: "panZoomY-21"
		group:       "navigation"
		javascript: {profile: "navigation", runtimeClass: "PanZoom", forced: panx: false}
		python: {arguments: [{wire: "y"}, {wire: "yfield"}], extras: false}
	},
]
