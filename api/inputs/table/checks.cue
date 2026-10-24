package tableinput

import (
	"encoding/json"
	"strings"
)

nativeChecks: [{files: {
	"contracts.cue": _typeFiles["packages/vgplot/spec/src/generated/table-input.cue"]
	"examples.cue": "package tableinputadmission\n\n" + strings.Join([for example in tableExamples {"\(json.Marshal(example.name)): #Table & \(json.Marshal(exampleProjections[example.name].table))\n"}], "\n")
}}]
