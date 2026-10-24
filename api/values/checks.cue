package values

import (
	"encoding/json"
	"strings"
)

nativeChecks: [{files: {
	"contracts.cue": _typeFiles["packages/vgplot/spec/src/generated/values.cue"]
	"examples.cue": "package valueadmission\n\n" + strings.Join([for item in valueExamples {"\(json.Marshal(item.name)): #\(item.contract) & \(json.Marshal(item.value))\n"}], "\n")
}}]
