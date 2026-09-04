module extend

import ruby
import os
import regex
import x.json2
import homebrew.rubocops.cask.constants as cask_constants

// Translated from Homebrew/brew `rubocops/extend/formula_cop.rb`.
pub struct FormulaCopDependency {
pub:
	name     string
	dep_type string
	required bool
	source   string
}

fn formula_cop_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn formula_cop_string_at(source string, start int) ?(string, int, int) {
	mut position := start
	for position < source.len && source[position].is_space() {
		position++
	}
	if position >= source.len || source[position] !in [`'`, `"`] {
		return none
	}
	quote := source[position]
	mut cursor := position + 1
	mut escaped := false
	mut content := []u8{}
	for cursor < source.len {
		character := source[cursor]
		if escaped {
			content << character
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if character == quote {
			return content.bytestr(), position, cursor + 1
		} else {
			content << character
		}
		cursor++
	}
	return none
}

fn formula_cop_name_at(source string, start int) ?(string, int) {
	mut position := start
	for position < source.len && source[position].is_space() {
		position++
	}
	if value, _, end := formula_cop_string_at(source, position) {
		return value, end
	}
	if position < source.len && source[position] == `:` {
		mut end := position + 1
		for end < source.len && (source[end].is_alnum() || source[end] in [`_`, `-`, `@`]) {
			end++
		}
		if end > position + 1 {
			return source[position + 1..end], end
		}
	}
	return none
}

pub fn parse_formula_cop_dependency(source string) ?FormulaCopDependency {
	trimmed := source.all_before('#').trim_space()
	if !trimmed.starts_with('depends_on') {
		return none
	}
	if trimmed.len > 'depends_on'.len && trimmed['depends_on'.len] !in [` `, `\t`, `(`] {
		return none
	}
	mut argument_start := 'depends_on'.len
	for argument_start < trimmed.len && trimmed[argument_start] in [` `, `\t`, `(`] {
		argument_start++
	}
	name, name_end := formula_cop_name_at(trimmed, argument_start) or { return none }
	after_name := trimmed[name_end..].trim_space().trim_right(')')
	if !after_name.starts_with('=>') {
		return FormulaCopDependency{
			name: name
			dep_type: 'required'
			required: true
			source: trimmed
		}
	}
	dep_type, _ := formula_cop_name_at(after_name, 2) or { return none }
	return FormulaCopDependency{
		name: name
		dep_type: dep_type
		source: trimmed
	}
}

pub fn formula_cop_dependencies(source string) []FormulaCopDependency {
	mut dependencies := []FormulaCopDependency{}
	for line in source.split_into_lines() {
		if dependency := parse_formula_cop_dependency(line) {
			dependencies << dependency
		}
	}
	return dependencies
}

pub fn formula_cop_depends_on(source string, name string, types []string) bool {
	requested_types := if types.len == 0 { ['any'] } else { types }
	return formula_cop_dependencies(source).any(it.name == name && (requested_types.contains('any') || requested_types.contains(it.dep_type)))
}

fn formula_cop_extract_strings(source string) []string {
	mut strings := []string{}
	mut position := 0
	for position < source.len {
		if source[position] in [`'`, `"`] {
			if value, _, end := formula_cop_string_at(source, position) {
				strings << value
				position = end
				continue
			}
		}
		position++
	}
	return strings
}

pub fn formula_cop_caveats_strings(source string) []string {
	lines := source.split_into_lines()
	mut start := -1
	mut indent := 0
	for index, line in lines {
		trimmed := line.trim_space()
		if trimmed.starts_with('def caveats') {
			start = index + 1
			indent = line.len - line.trim_left(' \t').len
			break
		}
	}
	if start < 0 {
		return []string{}
	}
	mut body := []string{}
	for line in lines[start..] {
		line_indent := line.len - line.trim_left(' \t').len
		if line_indent == indent && line.trim_space() == 'end' {
			break
		}
		body << line
	}
	return formula_cop_extract_strings(body.join('\n'))
}

pub fn formula_cop_checksum_source(source string) ?string {
	trimmed := source.all_before('#').trim_space()
	if !trimmed.starts_with('sha256') {
		return none
	}
	argument := trimmed['sha256'.len..].trim_space().trim_left('(').trim_right(')')
	if value, begin, end := formula_cop_string_at(argument, 0) {
		if argument[end..].trim_space().starts_with('=>') {
			return argument[begin..end]
		}
		if !argument[..begin].contains(':') {
			return argument[begin..end]
		}
		_ = value
	}
	mut pairs := []string{}
	mut position := 0
	for position < argument.len {
		colon := argument[position..].index_u8(`:`)
		if colon < 0 {
			break
		}
		key_start := position
		key_end := position + colon
		key := argument[key_start..key_end].trim_space().trim_left(',')
		value_start := key_end + 1
		if _, begin, end := formula_cop_string_at(argument, value_start) {
			pairs << '${key}\x00${argument[begin..end]}'
			position = end
		} else {
			position = value_start
		}
	}
	if pairs.len == 0 {
		return none
	}
	if pairs[0].all_before('\x00') == 'cellar' {
		return pairs.last().all_after('\x00')
	}
	return pairs[0].all_after('\x00')
}

pub fn formula_cop_comments(source string) []string {
	mut comments := []string{}
	for line in source.split_into_lines() {
		mut quote := u8(0)
		mut escaped := false
		for index, character in line.bytes() {
			if quote != 0 {
				if escaped {
					escaped = false
				} else if character == `\\` {
					escaped = true
				} else if character == quote {
					quote = 0
				}
			} else if character in [`'`, `"`] {
				quote = character
			} else if character == `#` {
				comments << line[index..]
				break
			}
		}
	}
	return comments
}

pub fn formula_cop_tap(file_path string) ?string {
	if marker := file_path.index('/Taps/') {
		remainder := file_path[marker + '/Taps/'.len..]
		parts := remainder.split('/')
		if parts.len >= 2 && parts[1].starts_with('homebrew-') {
			return parts[1]
		}
	}
	if file_path.starts_with('/homebrew-') {
		return file_path[1..].all_before('/')
	}
	return none
}

pub fn formula_cop_style_exceptions_dir(file_path string) ?string {
	if file_path == '' {
		return none
	}
	mut formula_directory := os.dir(file_path)
	directory_name := os.base(formula_directory)
	if directory_name.len == 1 || directory_name == 'lib' {
		formula_directory = os.dir(formula_directory)
	}
	if os.base(formula_directory) in ['Formula', 'HomebrewFormula'] {
		formula_directory = os.dir(formula_directory)
	}
	return os.join_path(formula_directory, 'style_exceptions')
}

pub fn formula_cop_style_exception(file_path string, list string, formula string) bool {
	if formula_cop_tap(file_path) == none {
		return false
	}
	directory := formula_cop_style_exceptions_dir(file_path) or { return false }
	path := os.join_path(directory, '${list}.json')
	contents := os.read_file(path) or { return false }
	entries := json2.decode[[]string](contents) or { return false }
	return entries.contains(formula)
}

pub fn formula_cop_class(source string) ?(string, string) {
	for line in source.split_into_lines() {
		trimmed := line.trim_space()
		if !trimmed.starts_with('class ') || !trimmed.contains('<') {
			continue
		}
		parts := trimmed[6..].split('<')
		if parts.len >= 2 {
			return parts[0].trim_space(), parts[1].trim_space().all_before(' ')
		}
	}
	return none
}

pub fn formula_cop_is_formula_class(source string) bool {
	_, parent := formula_cop_class(source) or { return false }
	return parent.trim_left(':') in ['Formula', 'GithubGistFormula', 'ScriptFileFormula',
		'AmazonWebServicesFormula']
}

pub fn formula_cop_on_system_methods() []string {
	mut methods := ['on_intel', 'on_arm', 'on_macos', 'on_linux', 'on_system']
	for method in cask_constants.on_system_methods {
		if method !in methods {
			methods << method
		}
	}
	return methods
}
