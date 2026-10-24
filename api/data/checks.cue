package data

import (
	"encoding/json"
	"strings"
)

nativeChecks: [{files: {
	"contracts.cue": _typeFiles["packages/vgplot/spec/src/generated/data.cue"]
	"examples.cue": "package dataadmission\n\n" + strings.Join([for item in dataExamples {
		let Value = exampleProjections[item.name]
		if item.kind == "source" {"\(json.Marshal(item.name)): #\(item.contract) & \(json.Marshal(Value.markData))\n"}
		if item.kind != "source" {"\(json.Marshal(item.name)): #\(item.contract) & \(json.Marshal(item.definition))\n"}
	}], "\n")
}}]
