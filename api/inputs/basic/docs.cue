package basicinputs

import "strings"

inputDocumentation: {
	python:      "Python input helpers return serializable View objects, rather than DOM widgets or MosaicClient instances. The bind argument serializes as as, source serializes as from, and other keyword names use camel case. Options whose value is None are omitted before aliases are applied; for example menu(bind=selection, as_=None) retains the bind argument. False, zero and empty strings remain present. Unknown keyword options are retained for custom clients."
	options:     "Python option(label) uses the label as its value; option(label, None) keeps an explicit null value. In a mixed options list containing a dictionary, Python converts every non-dictionary entry into a label/value dictionary. An all-scalar list remains scalar. The JavaScript menu client treats each scalar option as a value and each object as an option record."
	extensions:  "Python select and checkbox are authoring extensions. The default declarative parser recognizes menu, search, slider and table only. To consume select, checkbox or a custom input, register the name with inputNames and provide a corresponding JavaScript API implementation. Serializing a Python extension does not add a built-in browser widget."
	runtime:     "The Menu, Search and Slider runtime clients retain database query activation, DOM event handling and Param/Selection updates. Native JavaScript options can include element and, for Menu, format; these host values are outside the JSON/YAML input schema."
	slider:      "Python slider requires label and bind arguments. The declarative schema requires only the input discriminator, and native JavaScript accepts an optional options object. Consequently a minimal declarative slider can be valid while its emitted Python call requires additional authoring arguments. With a Selection, point clauses compare for equality and interval clauses span the minimum through the current value. With a scalar Param, the value is assigned directly."
	sliderRange: "A filter selection recomputes inferred minimum, maximum and step values; explicitly supplied bounds and steps remain fixed. Empty filtered results retain the previous range."
}
_pythonSignatures: {for factory in pythonFactories {(factory.name): "vg.\(factory.name)(" + strings.Join([for Parameter in factory.parameters {(#PythonParameterProjection & {parameter: Parameter}).text}], ", ") + ")"}}
docFiles: {
	for input in sharedInputs {
		let Contract = contractIndex[input.contract]
		let Factory = [for factory in pythonFactories if factory.name == input.name {factory}][0]
		"docs/api/inputs/\(input.name).md": """
   <!-- \(_header) -->
   <script setup>
     import { withBase } from 'vitepress';
     import { useLang } from '../../.vitepress/theme/useLang.js';
     const { language, setLanguage } = useLang();
   </script>

   <LangToggle :model-value="language" aria-label="\(input.runtime) documentation language" @update:model-value="setLanguage" />

   # \(input.runtime)

   \(Contract.description)

   <template v-if="language === 'js'">

   ## \(input.name) {#\(input.name)-method}

   `\(input.name)(options)`

   Creates a [\(input.runtime)](#\(input.name)-class) client, connects it to the active coordinator and returns its containing HTML element. The vgplot wrapper uses an explicitly supplied API context coordinator when present; the mosaic-inputs helper uses the default coordinator.

   </template>

   <template v-else-if="language === 'python'">

   ## \(input.name)

   `\(_pythonSignatures[input.name])`

   \(Factory.description)

   \(inputDocumentation.python)

   \(strings.Join([if input.name == "menu" {inputDocumentation.options}, if input.name == "slider" {inputDocumentation.slider}], "\n\n"))

   </template>

   <LangError v-else :language="language" />

   ## Declarative options

   The JSON/YAML object uses `input: "\(input.name)"`. Only this discriminator is required. Native JavaScript uses the options object without the discriminator.

   | Option | Required | Description |
   | --- | --- | --- |
   \(strings.Join([for property in Contract.properties if property.name != "input" {"| `\(property.name)` | \(strings.Join([if property.required {"Yes"}, if !property.required {"No"}], "")) | \(strings.Replace(property.description, "\n", " ", -1)) |"}], "\n"))

   ## \(input.runtime) {#\(input.name)-class}

   `new \(input.runtime)(options)`

   Native JavaScript class extending [MosaicClient](../core/client). Its `element` property contains the input DOM. The constructor accepts the same native options as the helper. Python does not export this JavaScript runtime class.

   \(inputDocumentation.runtime)

   \(strings.Join([if input.name == "slider" {inputDocumentation.sliderRange}], ""))

   \(strings.Join([for adapter in hostAdapters if len([for scope in adapter.scope if scope == input.contract {scope}]) > 0 {adapter.description}], "\n\n"))

   ## Executable starters

   The shared starters create a three-row SQL table, bind a named Param or Selection, and return live inputs. The filtered slider starter links a category menu to the slider range. JSON/YAML declare the view, JavaScript returns DOM, and Python serializes a Spec.

   | Variant | Downloads |
   | --- | --- |
   \(strings.Join([for example in inputExamples if example.input == input.name {"| `\(example.name)` | [JSON](/templates/inputs/basic/\(example.name).json), [YAML](/templates/inputs/basic/\(example.name).yaml), [JavaScript](/templates/inputs/basic/\(example.name).js), <a :href=\"withBase('/templates/inputs/basic/\(example.name).py')\" download>Python</a> |"}], "\n"))

   [Python authoring extensions](./authoring) document input, option, select and checkbox. The [native JavaScript menu](/templates/inputs/basic/native-menu.js) demonstrates DOM and formatting adapters.

   """
	}
	"docs/api/inputs/authoring.md": """
  <!-- \(_header) -->
  <script setup>
    import { withBase } from 'vitepress';
  </script>

  # Python input authoring

  \(inputDocumentation.python)

  ## input

  `vg.input(kind: str, **opts: Any) -> View`

  \(pythonHelpers.generic.description)

  ## option

  `vg.option(label: Any, value: Any = omitted) -> dict[str, Any]`

  \(pythonHelpers.option.description)

  \(inputDocumentation.options)

  \(strings.Join([for factory in pythonFactories if factory.applicability == "python-extension" {"## \(factory.name)\n\n`\(_pythonSignatures[factory.name])`\n\n\(factory.description)\n"}], "\n"))

  \(inputDocumentation.extensions)

  <a :href="withBase('/templates/inputs/basic/python-extensions.py')" download>Download the Python-only extension examples</a>. These examples demonstrate serialized authoring behavior; they have no default JSON/YAML or JavaScript runtime equivalent.

  """
}
