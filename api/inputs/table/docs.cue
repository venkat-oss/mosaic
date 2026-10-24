package tableinput

import (
	"strings"
	basicFamily "idl.uw.edu/mosaic/api/inputs/basic:basicinputs"
)

tableDocumentation: {
	intro:    "A sortable, scrollable table component that loads data on demand from a backing database table. JavaScript returns DOM; Python returns a serializable View."
	source:   "The declarative input discriminator and from source are required. The source can be a table name or a parameter reference. Native JavaScript permits an omitted options object; Python requires its source argument but accepts Any values beyond the declarative schema. A source Param reinitializes metadata and table data when its value changes."
	paging:   "Click a column header to sort ascending, click again to sort descending, and meta-click the current header to cancel sorting. Scrolling near the bottom requests the next batch. These are runtime interactions rather than declarative sort properties. Row selection uses pointer hover and clears on pointer leave."
	targets:  "The output binding is a Selection. Python's table_input widget is distinct from the table data-definition helper. The input parser and JavaScript helper use the wire name table; Python code generation uses table_input."
	starters: "Shared starters cover default columns, ordered projection/alignment/width, scrolling batches, row selection, linked filtering and a source Param switching between two named datasets. The paging interaction is supported when context and global coordinator are the same. Native formatting and explicit scoped coordinators have JavaScript-only starters; JSON/YAML do not invent callback or coordinator fields."
}
docFiles: {
	"docs/api/inputs/table.md": """
  <!-- \(_header) -->
  <script setup>
    import { withBase } from 'vitepress';
    import { useLang } from '../../.vitepress/theme/useLang.js';
    const { language, setLanguage } = useLang();
  </script>

  <LangToggle :model-value="language" aria-label="Table documentation language" @update:model-value="setLanguage" />

  # Table

  \(tableDocumentation.intro)

  <template v-if="language === 'js'">

  ## table {#table-method}

  `table(options)`

  Creates a [Table](#table-class), connects it to the active coordinator and returns its containing HTML element. An explicitly supplied vgplot API context determines its coordinator; the mosaic-inputs helper uses the global coordinator.

  </template>

  <template v-else-if="language === 'python'">

  ## table_input

  `vg.\(pythonFactory.name)(\(strings.Join(_pythonParameters, ", ")))`

  \(api.description)

  \(basicFamily.inputDocumentation.python)

  </template>

  <LangError v-else :language="language" />

  ## Declarative options

  \(tableDocumentation.source)

  | Option | Required | Description |
  | --- | --- | --- |
  \(strings.Join([for property in contract.properties {"| `\(property.name)` | \(strings.Join([if property.required {"Yes"}, if !property.required {"No"}], "")) | \(strings.Replace(property.description, "\n", " ", -1)) |"}], "\n"))

  \(tableDocumentation.targets)

  ## Table {#table-class}

  `new Table(options)`

  Native JavaScript class extending [MosaicClient](../core/client). Its `element` property contains the widget DOM. The constructor accepts the native helper options. Python does not export this runtime class.

  Native defaults are wildcard columns `\(runtimeDefaults.columns[0])`, height \(runtimeDefaults.height) pixels and rowBatch \(runtimeDefaults.rowBatch). Each instance receives a fresh default columns array. Columns and per-column alignment/width maps retain their supplied order and values.

  \(tableDocumentation.paging)

  \(strings.Join([for adapter in hostAdapters {adapter.description}], "\n\n"))

  ## Known scoped prefetch limitation

  \(prefetchLimitation)

  ## Executable starters

  \(tableDocumentation.starters)

  | Variant | Downloads |
  | --- | --- |
  \(strings.Join([for example in tableExamples {"| `\(example.name)` | [JSON](/templates/inputs/table/\(example.name).json), [YAML](/templates/inputs/table/\(example.name).yaml), [JavaScript](/templates/inputs/table/\(example.name).js), <a :href=\"withBase('/templates/inputs/table/\(example.name).py')\" download>Python</a> |"}], "\n"))

  Native JavaScript only: [DOM/format adapters](/templates/inputs/table/native-format.js).

  """
}
