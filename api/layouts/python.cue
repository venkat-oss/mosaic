package layouts

import "strings"

_pythonFunctions: [for layout in layouts {
	if layout.kind == "concat" {
		"""
		def \(layout.name)(
		    *items: Any, param_names: dict[int, str] | None = None, **kwargs: Any
		) -> View:
		    from ..plot import _encode_component
		    from ..spec import View

		    return View(
		        {"\(layout.name)": [_encode_component(i, param_names) for i in items]}, **kwargs
		    )
		"""
	}
	if layout.kind == "space" {
		"""
		def \(layout.name)(value: \(layout.pythonArgumentType)) -> View:
		    from ..spec import View

		    return View({"\(layout.name)": value})
		"""
	}
}]
pythonFiles: {
	"packages/vgplot/vgplot-python/vgplot/_generated/layouts.py": """
		# \(_header)
		from __future__ import annotations

		from typing import TYPE_CHECKING, Any

		if TYPE_CHECKING:
		    from ..spec import View


		\(strings.Join(_pythonFunctions, "\n\n"))

		\(strings.Join([for layout in layouts {"\(layout.name).__module__ = \"\(layout.pythonModule)\""}], "\n"))
		"""
}
