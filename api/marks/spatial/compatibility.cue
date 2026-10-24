package spatialmarks

let SpatialMarks = marks

compatibilityNotes: [
	{marks: [for Mark in SpatialMarks {Mark.name}], text: "Geo and topology wire specifications require data; sphere and graticule reject it. Python signatures keep data=None for all spatial marks."},
	{marks: ["geo"], text: "Provide an explicit geometry column for local rows. Queried geo marks otherwise select `st_asgeojson(geom)`; a null first geometry prevents later strings from being decoded. Use the geojson transform for an explicit GEOMETRY channel and load DuckDB spatial before querying spatial tables."},
	{marks: ["geo"], text: "Raw FeatureCollection data fails during rendering. Arrays of GeoJSON objects also need an explicit geometry channel. Geometry accessors and projection initializers are JavaScript-only."},
	{marks: ["sphere", "graticule"], text: "Sphere and graticule take an options object without data in JavaScript. Use a spherical projection; serializing a supplied Python data argument is outside their wire contract."},
	{marks: ["voronoi", "voronoiMesh", "delaunayLink", "delaunayMesh", "hull"], text: "Observable Plot computes topology from x/y positions; z separates groups. Mesh variants do not support fill."},
]
