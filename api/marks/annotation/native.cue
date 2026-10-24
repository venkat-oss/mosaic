package annotation

import (
	"encoding/json"
	"list"
	"strings"
)

_nativeSource: "package annotationvalues\n\n" + strings.Join([for Contract in supportContracts {"#" + Contract.name + ": " + projection.nativeDefinitions[Contract.name]}], "\n\n") + "\n"
nativeFiles: {"packages/vgplot/spec/src/generated/annotation-values.cue": _nativeSource}
#NativeSample: {contract!: or([for Contract in supportContracts {Contract.name}]), value!: string}
nativeSamples: [...#NativeSample] & [
	{contract: "VectorShapeName", value: "arrow"},
	{contract: "VectorShape", value: "spike"},
]
nativeChecks: [{files: {"contracts.cue": _nativeSource, "examples.cue": "package annotationvalues\n" + strings.Join([for i, Sample in nativeSamples {"sample\(i): #\(Sample.contract) & \(json.Marshal(Sample.value))"}], "\n") + "\n"}}]

nativeSampleChecks: {
	unique: true & list.UniqueItems([for Sample in nativeSamples {Sample.contract}])
}
