package gridmarks

import (
	"encoding/json"
	"strings"
)

interpolationModes: typeExpressions.gridInterpolateType.values

_nativeSource: "package gridvalues\n\n#GridInterpolate: " + projection.nativeDefinitions.GridInterpolate + "\n"
nativeFiles: {"packages/vgplot/spec/src/generated/grid-values.cue": _nativeSource}
nativeChecks: [{files: {"contracts.cue": _nativeSource, "examples.cue": "package gridvalues\n" + strings.Join([for i, Mode in interpolationModes {"mode\(i): #GridInterpolate & " + json.Marshal(Mode)}], "\n") + "\n"}}]
