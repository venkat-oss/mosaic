package gridmarks

runtimeLimitations: {
	tileGrid: {
		text: "rasterTile fails on multi-pixel grids; use raster or heatmap. Tile queries use the global coordinator even inside a local API context."
	}
	nullInterpolation: {
		text: "Null interpolation fails during rendering. Use none to disable interpolation."
	}
	cellDomain: {
		text: "Density cells use ordinal domains; set pad=1 so endpoint grid positions fall inside those domains."
	}
}
nativeInterpolation: {name: "interpolateNearest", module: "@observablehq/plot"}
