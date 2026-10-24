package plotattributes

import (
	"encoding/json"
	"regexp"
	"strings"
)

#PythonDoc: {
	description!: string
	_linked:      regexp.ReplaceAll(#"\[([^\]]+)\]\([^)]*\)"#, description, "${1}")
	_references:  regexp.ReplaceAll(#"\[([^\]]+)\]\[[^\]]*\]"#, _linked, "${1}")
	_bare:        regexp.ReplaceAll(#"\[([^\]]+)\]"#, _references, "${1}")
	_flat:        strings.TrimSpace(regexp.ReplaceAll(#"\s+"#, _bare, " "))
	text:         strings.TrimSpace(strings.SplitAfter(_flat, ". ")[0])
}
_pythonFunctions: [for attribute in attributes {
	if attribute.python.kind == "value" {
		"def \(attribute.python.name)(value: AttrValue\(strings.Join([if attribute.python.default == "true" {" = True"}], ""))) -> Directive:\n    \(json.Marshal((#PythonDoc & {description: attribute.description}).text))\n    from ..plot import Directive\n\n    return Directive(\(json.Marshal(attribute.name)), value)\n"
	}
	if attribute.python.kind == "margins" {
		"def \(attribute.python.name)(\n" + strings.Join([for side in pythonSides {"    \(side.side.name): int | None = None,"}], "\n") + "\n    **kwargs: Any,\n) -> Directive:\n    \(json.Marshal((#PythonDoc & {description: attribute.description}).text))\n    from ..plot import Directive\n\n    return Directive(\n        \(json.Marshal(attribute.name)),\n        omit_none({" + strings.Join([for side in pythonSides {"\(json.Marshal(side.side.name)): \(side.side.name)"}], ", ") + ", **kwargs}),\n    )\n"
	}
}]
pythonFiles: {
	"packages/vgplot/vgplot-python/vgplot/_generated/plot_attributes.py": """
		# \(_header)
		from __future__ import annotations

		from typing import TYPE_CHECKING, Any

		from ..util import omit_none

		if TYPE_CHECKING:
		    from .._types import AttrValue
		    from ..plot import Directive


		\(strings.Join(_pythonFunctions, "\n\n"))

		\(strings.Join([for attribute in attributes {
		if attribute.python.kind == "value" {"\(attribute.python.name).__module__ = \"vgplot._generated.attributes\""}
		if attribute.python.kind == "margins" {"\(attribute.python.name).__module__ = \"vgplot.plot\""}
	}], "\n"))
		"""
}
