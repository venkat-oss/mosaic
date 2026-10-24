package render

import (
	"regexp"
	"list"
	"strings"
)

#MarkdownReferences: {
	value!:   string
	_pattern: #"^\[([0-9]+)\]:[ \t]+"#
	_lines:   strings.Split(value, "\n")
	_matches: list.Concat([for line in _lines if regexp.Match(_pattern, strings.TrimSpace(line)) {regexp.FindAllSubmatch(#"\[([0-9]+)\]:[ \t]+([^ \t\n]+)"#, line, -1)}])
	_targets: {for entry in _matches {(entry[1]): entry[2]}}
	_body: strings.TrimSpace(strings.Join([for line in _lines if !regexp.Match(_pattern, strings.TrimSpace(line)) {line}], "\n"))
	text: strings.Join([for index, part in strings.Split(_body, "][") {
		if index == 0 {part}
		if index > 0 {
			let Key = strings.Split(part, "]")[0]
			if _targets[Key] != _|_ {"](" + _targets[Key] + ")" + strings.TrimPrefix(part, Key+"]")}
			if _targets[Key] == _|_ {"][" + part}
		}
	}], "")
}
