package window

import ("encoding/json"
	"strings")

nativeChecks: [{files: {
	"contracts.cue": _typeFiles["packages/vgplot/spec/src/generated/window.cue"]
	"examples.cue": "package windowadmission\n\n" + strings.Join([for api in intervalAPIs {"\(api.key): #\(api.name) & \(json.Marshal({(api.key): 1}))"}], "\n") + "\n"
}}]
