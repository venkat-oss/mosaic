package layouts

import "strings"

layoutDocs: {
	title:    "Layout"
	intro:    "Layout helpers arrange dashboard components in rows or columns and add space between them. JavaScript helpers return DOM elements; Python helpers return serializable `View` objects."
	children: "JavaScript concatenation flattens child arrays by one level and appends the existing DOM nodes in order. Python concatenation keeps its arguments in order without flattening lists. Declarative `hconcat` and `vconcat` contain arrays of recursively nested components."
	spacing:  "Numbers specify pixels. Strings can specify a [CSS dimension](https://developer.mozilla.org/en-US/docs/Web/CSS/dimension). The JavaScript runtime also converts numeric strings to pixels and defaults an omitted or undefined size to 10 pixels. Python requires a size argument. Spacer values are literal values; reactive parameters belong in the nested plot or input components."
	context:  "Python concatenation helpers accept `param_names` and the existing `View` keyword context, including `data`, `plot_defaults` and `config`. `View.to_dict()` and `vg.spec(...)` preserve caller-local parameter and data discovery. Plot directives keep their last supplied value. A layout preserves child order and shares the enclosing specification's parameters and plot defaults with its nested plots."
	starters: "Each starter creates nested layouts over a three-row SQL table. The concat starters combine both orientations and spacer axes. All starters bind a named radius parameter and use plot defaults for the nested charts. JSON/YAML declare a specification, JavaScript returns DOM, and Python serializes a `Spec`."
}
_languageSections: {
	for language in ["js", "python"] {
		(language): strings.Join([for layout in docLayouts {
			let Signature = {
				if layout.kind == "concat" {
					js:     "\(layout.name)(...elements)"
					python: "vg.\(layout.name)(*items, param_names=None, **kwargs)"
				}
				if layout.kind == "space" {
					js:     "\(layout.name)(size)"
					python: "vg.\(layout.name)(value)"
				}
			}[language]
			"## \(layout.name)\n\n`\(Signature)`\n\n\(strings.Replace(layout.propertyDescription, "\n", " ", -1))\n"
		}], "\n")
	}
}
docFiles: {
	"docs/api/vgplot/layout.md": """
		---
		title: \(layoutDocs.title)
		---
		<!-- \(_header) -->
		<script setup>
		  import { withBase } from 'vitepress';
		  import { useLang } from '../../.vitepress/theme/useLang.js';
		  const { language, setLanguage } = useLang();
		</script>

		<LangToggle :model-value="language" aria-label="Layout documentation language" @update:model-value="setLanguage" />

		# \(layoutDocs.title)

		\(layoutDocs.intro)

		<template v-if="language === 'js'">

		\(_languageSections.js)

		</template>

		<template v-else-if="language === 'python'">

		\(_languageSections.python)

		</template>

		<LangError v-else :language="language" />

		## Children and spacing

		\(layoutDocs.children)

		\(layoutDocs.spacing)

		## Python context

		\(layoutDocs.context)

		## Nested layout starters

		\(layoutDocs.starters)

		| Variant | Downloads |
		| --- | --- |
		\(strings.Join([for item in layoutExamples {"| `\(item.name)` | [YAML](/templates/layouts/\(item.name).yaml), [JSON](/templates/layouts/\(item.name).json), [JavaScript](/templates/layouts/\(item.name).js), <a :href=\"withBase('/templates/layouts/\(item.name).py')\" download>Python</a> |"}], "\n"))

		"""
}
