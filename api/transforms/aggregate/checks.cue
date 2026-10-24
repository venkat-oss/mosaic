package aggregate

nativeChecks: [{files: {
	"contracts.cue": _typeFiles["packages/vgplot/spec/src/generated/aggregate.cue"]
	"examples.cue":  "package aggregateadmission\n\noptions: #AggregateOptions & {distinct:true}\n"
}}]
