package params

import (
	"encoding/json"
	"strings"
)

nativeChecks: [{files: {
	"contracts.cue": _typeFiles["packages/vgplot/spec/src/generated/params.cue"]
	"examples.cue": "package paramadmission\n\n" + strings.Join([for item in paramExamples {"\(json.Marshal(item.name)): #\(item.contract) & \(json.Marshal(item.value))\n"}], "\n")
}}]
