package pointinteractors

import (
	"idl.uw.edu/mosaic/api/model"
	interactorRender "idl.uw.edu/mosaic/api/interactors/render:interactorrender"
)

contracts: [...model.#ShapeContract] & [
	{
		name:        "ToggleOptions"
		description: "Options for toggle interactors."
		wire:        false
		properties: [
			{
				name:        "as"
				description: "The output selection. A clause of the form `(field = value1) OR (field = value2) ...` is added for the currently selected values."
				required:    true
				type:        "paramRef"
			},
			{
				name:        "peers"
				description: "A flag indicating if peer (sibling) marks are excluded when cross-filtering (default `true`). If set, peer marks will not be filtered by this interactor's selection in cross-filtering setups."
				type:        "boolean"
			},
		]
	},
	{
		name:        "Toggle"
		description: "A toggle interactor."
		extends: [{name: "ToggleOptions", operator: "all"}]
		properties: [
			{name: "select", description: "Select individual values.", required: true, type: "toggleSelect"},
			{
				name:        "channels"
				description: "The encoding channels over which to select values. For a selected mark, selection clauses will cover the backing data fields for each channel."
				required:    true
				type:        "strings"
			},
		]
	},
	{
		name:        "ToggleX"
		description: "A toggleX interactor."
		extends: [{name: "ToggleOptions", operator: "all"}]
		properties: [
			{
				name:        "select"
				description: "Select individual values in the `x` scale domain. Clicking or touching a mark toggles its selection status."
				required:    true
				type:        "toggleXSelect"
			}
		]
	},
	{
		name:        "ToggleY"
		description: "A toggleY interactor."
		extends: [{name: "ToggleOptions", operator: "all"}]
		properties: [
			{
				name:        "select"
				description: "Select individual values in the `y` scale domain. Clicking or touching a mark toggles its selection status."
				required:    true
				type:        "toggleYSelect"
			}
		]
	},
	{
		name:        "ToggleZ"
		description: "A toggleZ interactor."
		extends: [{name: "ToggleOptions", operator: "all"}]
		properties: [
			{
				name:        "select"
				description: "Select individual values in the `z` scale domain. Clicking or touching a mark toggles its selection status."
				required:    true
				type:        "toggleZSelect"
			}
		]
	},
	{
		name:        "ToggleColor"
		description: "A toggleColor interactor."
		extends: [{name: "ToggleOptions", operator: "all"}]
		properties: [
			{
				name:        "select"
				description: "Select individual values in the `color` scale domain. Clicking or touching a mark toggles its selection status."
				required:    true
				type:        "toggleColorSelect"
			}
		]
	},
	{
		name:        "NearestOptions"
		description: "Options for nearest interactors."
		wire:        false
		properties: [
			{
				name:        "as"
				description: "The output selection. A clause of the form `field = value` is added for the currently nearest value."
				required:    true
				type:        "paramRef"
			},
			{
				name:        "channels"
				description: "The encoding channels whose domain values should be selected. For example, a setting of `['color']` selects the data value backing the color channel, whereas `['x', 'z']` selects both x and z channel domain values. If unspecified, the selected channels default to match the current pointer settings: a `nearestX` interactor selects the `['x']` channels, while a `nearest` interactor selects the `['x', 'y']` channels."
				type:        "strings"
			},
			{
				name:        "fields"
				description: "The fields (database column names) to use in generated selection clause predicates. If unspecified, the fields backing the selected *channels* in the first valid prior mark definition are used by default."
				type:        "strings"
			},
			{
				name:        "maxRadius"
				description: "The maximum radius of a nearest selection (default 40). Marks with (x, y) coordinates outside this radius will not be selected as nearest points."
				type:        "number"
			},
		]
	},
	{
		name:        "Nearest"
		description: "A nearest interactor."
		extends: [{name: "NearestOptions", operator: "all"}]
		properties: [
			{
				name:        "select"
				description: "Select values from the mark closest to the pointer."
				required:    true
				type:        "nearestSelect"
			}
		]
	},
	{
		name:        "NearestX"
		description: "A nearestX interactor."
		extends: [{name: "NearestOptions", operator: "all"}]
		properties: [
			{
				name:        "select"
				description: "Select values from the mark closest to the pointer *x* location."
				required:    true
				type:        "nearestXSelect"
			}
		]
	},
	{
		name:        "NearestY"
		description: "A nearestY interactor."
		extends: [{name: "NearestOptions", operator: "all"}]
		properties: [
			{
				name:        "select"
				description: "Select values from the mark closest to the pointer *y* location."
				required:    true
				type:        "nearestYSelect"
			}
		]
	},
	{
		name:        "Highlight"
		description: "A highlight interactor."
		properties: [
			{
				name:        "select"
				description: "Highlight selected marks by deemphasizing the others."
				required:    true
				type:        "highlightSelect"
			},
			{name: "by", description: "The input selection. Unselected marks are deemphasized.", required: true, type: "paramRef"},
			{
				name:        "opacity"
				description: "The overall opacity of deemphasized marks. By default the opacity is set to 0.2."
				type:        "number"
			},
			{
				name:        "fillOpacity"
				description: "The fill opacity of deemphasized marks. By default the fill opacity is unchanged."
				type:        "number"
			},
			{
				name:        "strokeOpacity"
				description: "The stroke opacity of deemphasized marks. By default the stroke opacity is unchanged."
				type:        "number"
			},
			{name: "fill", description: "The fill color of deemphasized marks. By default the fill is unchanged.", type: "string"},
			{
				name:        "stroke"
				description: "The stroke color of deemphasized marks. By default the stroke is unchanged."
				type:        "string"
			},
		]
	},
]

typeExpressions: {[string]: model.#ShapeExpression} & {
	boolean: {kind: "primitive", type: "boolean"}
	number: {kind: "primitive", type: "number"}
	string: {kind: "primitive", type: "string"}
	paramRef: {kind: "named", name: "ParamRef"}
	strings: {kind: "array", items: "string"}
	toggleSelect: {kind: "literal", value: "toggle"}
	toggleXSelect: {kind: "literal", value: "toggleX"}
	toggleYSelect: {kind: "literal", value: "toggleY"}
	toggleZSelect: {kind: "literal", value: "toggleZ"}
	toggleColorSelect: {kind: "literal", value: "toggleColor"}
	nearestSelect: {kind: "literal", value: "nearest"}
	nearestXSelect: {kind: "literal", value: "nearestX"}
	nearestYSelect: {kind: "literal", value: "nearestY"}
	highlightSelect: {kind: "literal", value: "highlight"}
}

declarationFiles: [...interactorRender.#DeclarationFile] & [
	{
		path: "packages/vgplot/spec/src/spec/interactors/Toggle.ts"
		imports: [{source: "../Param.js", names: ["ParamRef"]}]
		contracts: ["ToggleOptions", "Toggle", "ToggleX", "ToggleY", "ToggleZ", "ToggleColor"]
	},
	{
		path: "packages/vgplot/spec/src/spec/interactors/Nearest.ts"
		imports: [{source: "../Param.js", names: ["ParamRef"]}]
		contracts: ["NearestOptions", "Nearest", "NearestX", "NearestY"]
	},
	{
		path: "packages/vgplot/spec/src/spec/interactors/Highlight.ts"
		imports: [{source: "../Param.js", names: ["ParamRef"]}]
		contracts: ["Highlight"]
	},
]

interactors: [...interactorRender.#Interactor] & [
	{
		contract:    "Toggle"
		wrapperSlot: "toggle-10"
		javascript: {profile: "selection", runtimeClass: "Toggle"}
		python: arguments: [{wire: "as", adapter: "direct"}, {wire: "channels", adapter: "direct"}, {wire: "peers", adapter: "direct"}]
	},
	{
		contract:    "ToggleX"
		wrapperSlot: "toggleX-11"
		javascript: {profile: "toggle-channel", runtimeClass: "Toggle", base: "toggle", channel: "x"}
		python: arguments: [{wire: "as", adapter: "direct"}, {wire: "peers", adapter: "direct"}]
	},
	{
		contract:    "ToggleY"
		wrapperSlot: "toggleY-12"
		javascript: {profile: "toggle-channel", runtimeClass: "Toggle", base: "toggle", channel: "y"}
		python: arguments: [{wire: "as", adapter: "direct"}, {wire: "peers", adapter: "direct"}]
	},
	{
		contract:    "ToggleZ"
		wrapperSlot: "toggleZ-13"
		javascript: {profile: "toggle-channel", runtimeClass: "Toggle", base: "toggle", channel: "z"}
		python: arguments: [{wire: "as", adapter: "direct"}, {wire: "peers", adapter: "direct"}]
	},
	{
		contract:    "ToggleColor"
		wrapperSlot: "toggleColor-14"
		javascript: {profile: "toggle-channel", runtimeClass: "Toggle", base: "toggle", channel: "color"}
		python: arguments: [{wire: "as", adapter: "direct"}, {wire: "peers", adapter: "direct"}]
	},
	{
		contract:    "Nearest"
		wrapperSlot: "nearest-6"
		javascript: {profile: "selection", runtimeClass: "Nearest", forced: pointer: "xy"}
		python: arguments: [{wire: "as", adapter: "direct"}, {wire: "fields", adapter: "singular-field"}, {wire: "channels", adapter: "direct"}]
	},
	{
		contract:    "NearestX"
		wrapperSlot: "nearestX-7"
		javascript: {profile: "selection", runtimeClass: "Nearest", forced: pointer: "x"}
		python: arguments: [{wire: "as", adapter: "direct"}, {wire: "fields", adapter: "singular-field"}, {wire: "channels", adapter: "direct"}]
	},
	{
		contract:    "NearestY"
		wrapperSlot: "nearestY-8"
		javascript: {profile: "selection", runtimeClass: "Nearest", forced: pointer: "y"}
		python: arguments: [{wire: "as", adapter: "direct"}, {wire: "fields", adapter: "singular-field"}, {wire: "channels", adapter: "direct"}]
	},
	{
		contract:    "Highlight"
		wrapperSlot: "highlight-2"
		javascript: {profile: "highlight", runtimeClass: "Highlight"}
		python: arguments: [{wire: "by", adapter: "direct"}, {wire: "channels", adapter: "highlight-channels"}]
	},
]
