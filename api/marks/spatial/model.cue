package spatialmarks

contracts: [
	{
		name:        "GeoOptions"
		description: "Options for the geo mark."
		wire:        false
		extends: ["MarkOptions"]
		properties: [
			{
				name:        "geometry"
				description: "A required channel for the geometry to render; defaults to identity, assuming *data* is a GeoJSON object or an iterable of GeoJSON objects."
				type:        "channelValueReference"
			},
			{
				name:        "r"
				description: "The size of Point and MultiPoint geometries, defaulting to a constant 3 pixels. If **r** is a number, it is interpreted as a constant radius in pixels; otherwise it is interpreted as a channel and the effective radius is controlled by the *r* scale, which defaults to a *sqrt* scale such that the visual area of a point is proportional to its associated value.\n\nIf **r** is a channel, geometries will be sorted by descending radius by default, to limit occlusion; use the **sort** transform to control render order. Geometries with a nonpositive radius are not drawn."
				type:        "channelSpecOrParamRef"
			},
		]
	},
	{
		name:        "Geo"
		description: "The geo mark."
		extends: ["MarkData", "GeoOptions"]
		properties: [
			{
				name:        "mark"
				description: "A geo mark. The **geometry** channel, which defaults to the identity function assuming that *data* is a GeoJSON object or an iterable of GeoJSON objects, is projected to the plane using the plot\u2019s top-level\n**projection**.\n\nIf *data* is a GeoJSON feature collection, then the mark\u2019s data is\n*data*.features; if *data* is a GeoJSON geometry collection, then the mark\u2019s data is *data*.geometries; if *data* is some other GeoJSON object, then the mark\u2019s data is the single-element array [*data*]."
				required:    true
				type:        "geoKind"
			}
		]
	},
	{
		name:        "Sphere"
		description: "The sphere mark."
		extends: ["MarkOptions"]
		properties: [
			{
				name:        "mark"
				description: "A geo mark whose *data* is the outline of the sphere on the projection\u2019s plane. (For use with a spherical **projection** only.)"
				required:    true
				type:        "sphereKind"
			}
		]
	},
	{
		name:        "Graticule"
		description: "The graticule mark."
		extends: ["MarkOptions"]
		properties: [
			{
				name:        "mark"
				description: "A geo mark whose *data* is a 10\u00b0 global graticule. (For use with a spherical **projection** only.)"
				required:    true
				type:        "graticuleKind"
			}
		]
	},
	{
		name:        "DelaunayOptions"
		description: "Options for the Delaunay marks."
		wire:        false
		extends: ["MarkOptions", "MarkerOptions", "CurveOptions",
		]
		properties: [
			{
				name:        "x"
				description: "The horizontal position channel, typically bound to the *x* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The vertical position channel, typically bound to the *y* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "z"
				description: "An optional ordinal channel for grouping to produce multiple (possibly overlapping) triangulations."
				type:        "channelValueReference"
			},
		]
	},
	{
		name:        "DelaunayLink"
		description: "The delaunayLink mark."
		extends: ["MarkData", "DelaunayOptions"]
		properties: [
			{
				name:        "mark"
				description: "A mark that draws links for each edge of the Delaunay triangulation of points given by the **x** and **y** channels. Like the link mark, except that **x1**, **y1**, **x2**, and **y2** are derived automatically from **x** and **y**. When an aesthetic channel is specified (such as\n**stroke** or **strokeWidth**), the link inherits the corresponding channel value from one of its two endpoints arbitrarily.\n\nIf **z** is specified, the input points are grouped by *z*, producing a separate Delaunay triangulation for each group."
				required:    true
				type:        "delaunayLinkKind"
			}
		]
	},
	{
		name:        "DelaunayMesh"
		description: "The delaunayMesh mark."
		extends: ["MarkData", "DelaunayOptions"]
		properties: [
			{
				name:        "mark"
				description: "A mark that draws a mesh of the Delaunay triangulation of the points given by the **x** and **y** channels. The **stroke** option defaults to _currentColor_, and the **strokeOpacity** defaults to 0.2; the **fill** option is not supported. When an aesthetic channel is specified (such as\n**stroke** or **strokeWidth**), the mesh inherits the corresponding channel value from one of its constituent points arbitrarily.\n\nIf **z** is specified, the input points are grouped by *z*, producing a separate Delaunay triangulation for each group."
				required:    true
				type:        "delaunayMeshKind"
			}
		]
	},
	{
		name:        "Hull"
		description: "The hull mark."
		extends: ["MarkData", "DelaunayOptions"]
		properties: [
			{
				name:        "mark"
				description: "A mark that draws a convex hull around the points given by the **x** and\n**y** channels. The **stroke** option defaults to _currentColor_ and the\n**fill** option defaults to _none_. When an aesthetic channel is specified (such as **stroke** or **strokeWidth**), the hull inherits the corresponding channel value from one of its constituent points arbitrarily.\n\nIf **z** is specified, the input points are grouped by *z*, producing a separate hull for each group. If **z** is not specified, it defaults to the **fill** channel, if any, or the **stroke** channel, if any."
				required:    true
				type:        "hullKind"
			}
		]
	},
	{
		name:        "Voronoi"
		description: "The voronoi mark."
		extends: ["MarkData", "DelaunayOptions"]
		properties: [
			{
				name:        "mark"
				description: "A mark that draws polygons for each cell of the Voronoi tesselation of the points given by the **x** and **y** channels.\n\nIf **z** is specified, the input points are grouped by *z*, producing a separate Voronoi tesselation for each group."
				required:    true
				type:        "voronoiKind"
			}
		]
	},
	{
		name:        "VoronoiMesh"
		description: "The voronoiMesh mark."
		extends: ["MarkData", "DelaunayOptions"]
		properties: [
			{
				name:        "mark"
				description: "A mark that draws a mesh for the cell boundaries of the Voronoi tesselation of the points given by the **x** and **y** channels. The\n**stroke** option defaults to _currentColor_, and the **strokeOpacity** defaults to 0.2. The **fill** option is not supported. When an aesthetic channel is specified (such as **stroke** or **strokeWidth**), the mesh inherits the corresponding channel value from one of its constituent points arbitrarily.\n\nIf **z** is specified, the input points are grouped by *z*, producing a separate Voronoi tesselation for each group."
				required:    true
				type:        "voronoiMeshKind"
			}
		]
	},
]
typeExpressions: {
	channelSpecOrParamRef: {kind: "union", members: ["channelValueSpecReference", "paramRefReference"]}
	geoKind: {kind: "literal", value: "geo"}
	sphereKind: {kind: "literal", value: "sphere"}
	graticuleKind: {kind: "literal", value: "graticule"}
	delaunayLinkKind: {kind: "literal", value: "delaunayLink"}
	delaunayMeshKind: {kind: "literal", value: "delaunayMesh"}
	hullKind: {kind: "literal", value: "hull"}
	voronoiKind: {kind: "literal", value: "voronoi"}
	voronoiMeshKind: {kind: "literal", value: "voronoiMesh"}
}
externalReferences: []
declarationFiles: [
	{
		basename: "Geo"
		imports: ["ParamRef", "ChannelValue", "ChannelValueSpec", "MarkData", "MarkOptions"]
		contracts: ["GeoOptions", "Geo", "Sphere", "Graticule"]
	},
	{
		basename: "Delaunay"
		imports: ["ChannelValue", "ChannelValueSpec", "CurveOptions", "MarkData", "MarkOptions", "MarkerOptions"]
		contracts: ["DelaunayOptions", "DelaunayLink", "DelaunayMesh", "Hull", "Voronoi", "VoronoiMesh"]
	},
]
marks: [
	{name: "geo", contract: "Geo", jsSection: "geo-65", profile: "implicit", runtimeClass: "GeoMark"},
	{name: "sphere", contract: "Sphere", jsSection: "sphere-66", profile: "ordinary"},
	{name: "graticule", contract: "Graticule", jsSection: "graticule-67", profile: "ordinary"},
	{name: "voronoi", contract: "Voronoi", jsSection: "voronoi-49", profile: "ordinary"},
	{name: "voronoiMesh", contract: "VoronoiMesh", jsSection: "voronoiMesh-50", profile: "ordinary"},
	{name: "delaunayLink", contract: "DelaunayLink", jsSection: "delaunayLink-51", profile: "ordinary"},
	{name: "delaunayMesh", contract: "DelaunayMesh", jsSection: "delaunayMesh-52", profile: "ordinary"},
	{name: "hull", contract: "Hull", jsSection: "hull-53", profile: "ordinary"},
]
referenceGroups: [
	{title: "Geo", names: ["geo", "sphere", "graticule"], sections: {js: "js-Geo-15", python: "python-Geo-46"}},
	{
		title: "Delaunay"
		names: ["voronoi", "voronoiMesh", "delaunayLink", "delaunayMesh", "hull"]
		sections: {js: "js-Delaunay-9", python: "python-Delaunay-40"}
	},
]
