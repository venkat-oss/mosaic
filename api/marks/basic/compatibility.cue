package basicmarks

let BasicMarks = marks
let OwnContracts = {for Contract in contracts {(Contract.name): Contract}}
let IntervalMarks = ["barX", "barY", "dotX", "dotY", "rect", "rectX", "rectY", "ruleX", "ruleY"]

compatibilityNotes: [
	{marks: ["ruleY"], text: "**RuleY limitation:** its wire contract inherits RuleXOptions, admitting y1/y2 and top/bottom insets instead of horizontal endpoints. Native JavaScript supports x1/x2."},
	{marks: ["circle", "hexagon"], text: "Circle and hexagon force their named geometry, even when a symbol option is supplied."},
	{marks: IntervalMarks, text: "Numeric intervals work in TypeScript and native JavaScript. For declarative intervals, bind a named parameter containing a time interval string; a literal string such as `day` is interpreted as a SQL field by the mark runtime."},
	{marks: [for Mark in BasicMarks if OwnContracts[Mark.contract].extends[0] == "MarkData" {Mark.name}], text: "The wire format requires data for these marks. Python defaults data to None; the JavaScript options-only overload supplies one empty row."},
]
