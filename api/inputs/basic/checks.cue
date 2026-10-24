package basicinputs

import (
	"encoding/json"
	"strings"
)

nativeChecks: [{files: {
	"contracts.cue": _typeFiles["packages/vgplot/spec/src/generated/basic-inputs.cue"]
	"examples.cue": "package basicinputadmission\n\n" + strings.Join([for example in inputExamples {
		let Projection = exampleProjections[example.name]
		"\(json.Marshal(example.name)): #\(Projection.contract) & \(json.Marshal({input: example.input, for key, value in Projection.options {(key): value}}))\n"
	}], "\n")
}}]
