package window

import "strings"

windowDocs: {
	intro: """
		Window transforms calculate values over ordered partitions. JavaScript calls
		the SQL expression functions; Python helpers build dictionaries consumed by
		the specification parser. Use `orderby`, `partitionby`, `rows`, `range`,
		`groups` and `exclude` to configure a window, or the corresponding JavaScript
		expression methods. The SQL engines execute the calculations.
		See [SQL window functions](/api/sql/window-functions) for query methods.
		"""
	nullary: """
		The five nullary functions accept null or an empty tuple in a wire specification.
		Python helpers return a null argument; JavaScript calls omit the argument.
		The parser normalizes both wire forms to an empty string in `toJSON()`, which
		remains outside the nullary wire signature. Python code generation emits the
		no-argument helper, restoring its null dictionary representation.
		"""
	lag: """
		TypeScript permits omitted lag/lead tuple offset and default members, while the
		existing wire schema requires all three tuple positions. A scalar field is
		accepted by both. The default value may be a date-time string in wire data or
		a native Date in TypeScript. Python signatures use `UNSET` for optional
		arguments and retain their historical omission compression: `lag("x",
		default=None)` emits `{"lag": ["x", None]}`. An explicit null offset is kept.
		"""
	buckets: """
		`ntile` retains a field/expression argument in the declaration and wire schema.
		A bare numeric bucket count is rejected there; use a SQL constant
		expression such as `{"sql": "2"}`.
		"""
	frames: """
		Frame bounds contain exactly two values: a number, a date/time interval, or
		null. A null bound means unbounded. JavaScript frame helpers retain the SQL
		engine's offset interpretation, including zero as the current row. Frame
		exclusion accepts all-uppercase or all-lowercase modes; the parser normalizes
		exclusion to uppercase.

		The parser chooses the first truthy frame key in the order shown below. A
		parameter reference may provide a whole frame; individual string bounds stay
		literals rather than becoming parameter references. Custom WindowFrameNode
		types retain the existing computed helper-name fallback.
		"""
	intervals: """
		Date/time interval transforms use a numeric value and remain JavaScript
		utilities. Python has no interval or frame factory: use their dictionaries
		in specification options. Python code generation preserves those interval
		dictionaries instead of inventing Python utility calls.
		"""
}

_windowSections: [for api in apis {
	let Arguments = strings.Join([for argument in api.arguments {argument.name + strings.Join([if !argument.required {" = " + argument.default}], "")}], ", ")
	"""
  ### \(api.key)

  \(api.description)

  JavaScript: `\(api.key)(\(strings.Join([for argument in api.arguments {argument.name + strings.Join([if !argument.required {"?"}], "")}], ", ")))`, from `\(api.origin)`.
  Python: `\(api.python)(\(Arguments)\(strings.Join([if len(api.arguments) > 0 {", "}], ""))**options: Any)`.

  ```ts
  \(_shape.contractProjections[api.name].declaration)```

  """
}]

referenceSections: [{
	id:      "window"
	order:   6
	content: """
  ## Window Transforms

  \(windowDocs.intro)

  \(windowDocs.nullary)

  \(windowDocs.lag)

  \(windowDocs.buckets)

  \(strings.Join(_windowSections, "\n\n"))

  ### Lag and Lead Argument Contract

  ```ts
  \(_shape.contractProjections.ArgLagLead.declaration)```

  ### Window Frames

  \(windowDocs.frames)

  | Frame key | SQL type | JavaScript utility |
  | --- | --- | --- |
  \(strings.Join([for frame in frameKinds {"| `\(frame.key)` | `\(frame.type)` | `\(frame.javascript)(extent, exclude?)` |"}], "\n"))

  ### Window examples

  \(strings.Join([for Starter in windowStarters {"- `\(Starter.name)`: [YAML](/templates/transforms/window/\(Starter.name).yaml) · [JSON](/templates/transforms/window/\(Starter.name).json) · [JavaScript](/templates/transforms/window/\(Starter.name).js) · <a :href=\"withBase('/templates/transforms/window/\(Starter.name).py')\" download>Python</a>."}], "\n"))
  - [JavaScript interval utility](/templates/transforms/window/generic-interval.js).

  """
}, {
	id:      "interval"
	order:   7
	content: """
  ## Date/Time Intervals

  \(windowDocs.intervals)

  ```ts
  \(_shape.contractProjections.IntervalTransform.declaration)```

  \(strings.Join([for api in intervalAPIs {"### \(api.key)\n\n\(api.description)\n\nJavaScript: `\(api.key)(value)`, from `\(api.origin)`.\n\n```ts\n\(_shape.contractProjections[api.name].declaration)```"}], "\n\n"))
  """
}]
