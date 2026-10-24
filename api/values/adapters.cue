package values

hostAdapters: [
	{reference: "vg.Fixed", description: "The declarative Fixed string resolves through PlotFixedNode to the existing vg.Fixed Symbol."},
	{reference: "Date", description: "Native JavaScript Date values use the TypeScript `Interval<Date>` branch. Date parameters cross JSON/YAML as `{date: ISO string}` definitions; the retained parser constructs Date values."},
	{reference: "CSSStyleDeclaration", description: "TypeScript adapts the DOM CSSStyleDeclaration interface through Partial and Omit. Wire values use CSS string properties plus numeric length; native style objects pass through the existing attribute setter."},
	{reference: "Function", description: "JavaScript callback values stay in the existing mark and attribute runtime. JSON/YAML and native wire admission have no callback representation, and Python value aliases exclude callables."},
]
