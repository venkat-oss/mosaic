package buildinput

import catalog "idl.uw.edu/mosaic/api/catalog:catalogsources"

familyInputs: close({for Source in catalog.sources {(Source)!: {source: Source, ...}}})
let Families = familyInputs
inputData: input: families: [for Source in catalog.sources {Families[Source]}]
