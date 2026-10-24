package colorattributes

knownDefects: [
	{attributes: ["colorScale", "opacityScale", "symbolScale"], description: "Compatibility limitation: null is accepted by the specification, but rendering a matching data channel currently throws `unknown scale type: null`. The null-scale examples preserve this expected rejection."},
	{attributes: ["colorRange", "opacityRange", "symbolRange"], description: "Compatibility limitation: `Fixed` is accepted by the specification for this range, but the retained renderer throws an unsupported fixed attribute error. Fixed domains remain supported."},
	{attributes: ["colorScheme"], description: "Compatibility limitation: the wire contract accepts open objects and parameter-reference strings; quantitative rendering rejects scheme objects and unknown scheme strings. Known scheme strings are normalized without case sensitivity."},
]
hostAdapters: [
	{attributes: ["colorInterpolate"], description: "JavaScript additionally accepts a native one-argument sequential interpolator such as D3 `interpolateBlues`; install `d3` to run the native examples. Functions have no JSON, YAML or Python wire representation."},
	{attributes: ["colorInterpolate"], description: "JavaScript additionally accepts a two-argument D3 interpolation factory such as `interpolateRgb.gamma(2.2)` together with explicit color range endpoints; install `d3` for this native example."},
	{attributes: ["colorRange"], description: "For an ordinal color scale, a native JavaScript range callback receives the scale domain and returns the output colors. This callback is a JavaScript-only runtime value."},
	{attributes: ["symbolRange"], description: "JavaScript additionally accepts native D3 symbol objects such as `symbolStar` in a symbol range; install `d3` for the native example. Shared templates use symbol names."},
]
checks: {
	adapterMembers: [for H in hostAdapters for Name in H.attributes {attributeIndex[Name]}]
}
