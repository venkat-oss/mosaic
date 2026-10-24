package column

import "encoding/json"

nativeChecks: [{files: {
	"contracts.cue": _typeFiles["packages/vgplot/spec/src/generated/column.cue"]
	"examples.cue":  "package columnadmission\n\ncolumn: #Column & \(json.Marshal({column: "x"}))\nsql: #SQLExpression & \(json.Marshal(sqlWireExpression))\naggregate: #AggregateExpression & \(json.Marshal(aggregateExample.value))\n"
}}]
