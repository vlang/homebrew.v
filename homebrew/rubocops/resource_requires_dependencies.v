module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/resource_requires_dependencies.rb`.
pub const resource_dependency_names = ['bcrypt', 'lxml', 'pynacl', 'pyyaml']

pub struct ResourceRequiresDependenciesProblem {
pub:
	resource              string
	dependency_kind       string
	required_dependencies []string
	begin_pos             int
	end_pos               int
	message               string
}

struct ResourceDependencyCall {
	method             string
	argument           string
	argument_kind      string
	argument_is_hash   bool
	hash_value_symbols []string
	begin_pos          int
	end_pos            int
}

fn resource_dependency_identifier_byte(character u8) bool {
	return character.is_alnum() || character in [`_`, `!`, `?`]
}

fn resource_dependency_skip_horizontal(source string, start int) int {
	mut position := start
	for position < source.len && source[position] in [` `, `\t`, `\r`] {
		position++
	}
	return position
}

fn resource_dependency_skip_space(source string, start int) int {
	mut position := start
	for position < source.len && source[position].is_space() {
		position++
	}
	return position
}

fn resource_dependency_quoted_end(source string, start int) int {
	quote := source[start]
	mut position := start + 1
	mut escaped := false
	for position < source.len {
		character := source[position]
		if escaped {
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if character == quote {
			return position + 1
		}
		position++
	}
	return source.len
}

fn resource_dependency_decode_string(source string, start int, end int) string {
	if end <= start + 1 || end > source.len || source[end - 1] != source[start] {
		return ''
	}
	quote := source[start]
	mut decoded := []u8{cap: end - start - 2}
	mut position := start + 1
	for position < end - 1 {
		character := source[position]
		if character != `\\` || position + 1 >= end - 1 {
			decoded << character
			position++
			continue
		}
		next := source[position + 1]
		if quote == `'` {
			if next in [`'`, `\\`] {
				decoded << next
			} else {
				decoded << `\\`
				decoded << next
			}
		} else {
			match next {
				`n` { decoded << `\n` }
				`r` { decoded << `\r` }
				`t` { decoded << `\t` }
				else { decoded << next }
			}
		}
		position += 2
	}
	return decoded.bytestr()
}

fn resource_dependency_symbol_at(source string, start int) ?struct {
	name string
	end  int
} {
	if start >= source.len || source[start] != `:` || start + 1 >= source.len || !(source[start + 1].is_letter() || source[start + 1] == `_`) {
		return none
	}
	mut end := start + 2
	for end < source.len && resource_dependency_identifier_byte(source[end]) {
		end++
	}
	return struct {
		name: source[start + 1..end]
		end:  end
	}
}

fn resource_dependency_value_end(source string, start int) int {
	mut position := start
	mut square_depth := 0
	mut brace_depth := 0
	mut parenthesis_depth := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `"`] {
			position = resource_dependency_quoted_end(source, position)
			continue
		}
		if character == `#` {
			return position
		}
		match character {
			`[` { square_depth++ }
			`]` {
				if square_depth == 0 {
					return position
				}
				square_depth--
			}
			`{` { brace_depth++ }
			`}` {
				if brace_depth == 0 && square_depth == 0 && parenthesis_depth == 0 {
					return position
				}
				brace_depth--
			}
			`(` { parenthesis_depth++ }
			`)` {
				if parenthesis_depth == 0 && square_depth == 0 && brace_depth == 0 {
					return position
				}
				parenthesis_depth--
			}
			`,` {
				if square_depth == 0 && brace_depth == 0 && parenthesis_depth == 0 {
					return position
				}
			}
			`\n` {
				if square_depth == 0 && brace_depth == 0 && parenthesis_depth == 0 {
					return position
				}
			}
			else {}
		}
		position++
	}
	return source.len
}

fn resource_dependency_symbols(source string, start int, end int) []string {
	mut symbols := []string{}
	mut position := start
	for position < end {
		if source[position] in [`'`, `"`] {
			position = resource_dependency_quoted_end(source, position)
			continue
		}
		if source[position] == `:` && (position == 0 || source[position - 1] != `:`) {
			if symbol := resource_dependency_symbol_at(source, position) {
				symbols << symbol.name
				position = symbol.end
				continue
			}
		}
		position++
	}
	return symbols
}

fn resource_dependency_call_at(source string, method string, begin_pos int, method_end int) ?ResourceDependencyCall {
	mut argument_start := resource_dependency_skip_horizontal(source, method_end)
	mut parenthesized := false
	if argument_start < source.len && source[argument_start] == `(` {
		parenthesized = true
		argument_start = resource_dependency_skip_space(source, argument_start + 1)
	}
	mut braced_hash := false
	if argument_start < source.len && source[argument_start] == `{` {
		braced_hash = true
		argument_start = resource_dependency_skip_space(source, argument_start + 1)
	}
	if argument_start >= source.len {
		return none
	}
	mut argument := ''
	mut argument_kind := ''
	mut argument_end := argument_start
	if source[argument_start] in [`'`, `"`] {
		argument_end = resource_dependency_quoted_end(source, argument_start)
		if argument_end <= argument_start + 1 || argument_end > source.len || source[argument_end - 1] != source[argument_start] {
			return none
		}
		argument = resource_dependency_decode_string(source, argument_start, argument_end)
		argument_kind = 'string'
	} else if symbol := resource_dependency_symbol_at(source, argument_start) {
		argument = symbol.name
		argument_kind = 'symbol'
		argument_end = symbol.end
	} else {
		return none
	}
	after_argument := resource_dependency_skip_horizontal(source, argument_end)
	mut argument_is_hash := braced_hash
	mut hash_value_symbols := []string{}
	if after_argument + 1 < source.len && source[after_argument..after_argument + 2] == '=>' {
		argument_is_hash = true
		value_start := resource_dependency_skip_space(source, after_argument + 2)
		value_end := resource_dependency_value_end(source, value_start)
		hash_value_symbols = resource_dependency_symbols(source, value_start, value_end)
	}
	mut end_pos := argument_end
	if parenthesized && !argument_is_hash {
		closing := resource_dependency_skip_horizontal(source, argument_end)
		if closing < source.len && source[closing] == `)` {
			end_pos = closing + 1
		}
	}
	return ResourceDependencyCall{
		method: method
		argument: argument
		argument_kind: argument_kind
		argument_is_hash: argument_is_hash
		hash_value_symbols: hash_value_symbols
		begin_pos: begin_pos
		end_pos: end_pos
	}
}

fn resource_dependency_calls(source string) []ResourceDependencyCall {
	mut calls := []ResourceDependencyCall{}
	mut position := 0
	for position < source.len {
		character := source[position]
		if character in [`'`, `"`] {
			position = resource_dependency_quoted_end(source, position)
			continue
		}
		if character == `#` {
			position = source.index_after('\n', position) or { source.len }
			continue
		}
		if !(character.is_letter() || character == `_`) {
			position++
			continue
		}
		begin_pos := position
		position++
		for position < source.len && resource_dependency_identifier_byte(source[position]) {
			position++
		}
		method := source[begin_pos..position]
		if method !in ['resource', 'uses_from_macos', 'depends_on'] {
			continue
		}
		if begin_pos > 0 && source[begin_pos - 1] == `:` {
			continue
		}
		after_method := resource_dependency_skip_horizontal(source, position)
		if after_method < source.len && ((after_method == position && source[after_method] == `:`) || (source[after_method] == `=` && (after_method + 1 >= source.len || source[after_method + 1] != `>`))) {
			continue
		}
		if call := resource_dependency_call_at(source, method, begin_pos, position) {
			calls << call
		}
	}
	return calls
}

pub fn audit_resource_requires_dependencies(source string) []ResourceRequiresDependenciesProblem {
	calls := resource_dependency_calls(source)
	resource_calls := calls.filter(it.method == 'resource')
	if resource_calls.len == 0 {
		return []ResourceRequiresDependenciesProblem{}
	}
	dependency_calls := calls.filter(it.method == 'uses_from_macos' || it.method == 'depends_on')
	mut available_dependencies := []string{}
	for call in dependency_calls {
		if call.argument_is_hash {
			if 'build' in call.hash_value_symbols {
				available_dependencies << call.argument
			}
		} else {
			available_dependencies << call.argument
		}
	}
	depends_on_linux := dependency_calls.any(it.method == 'depends_on' && it.argument == 'linux')
	mut problems := []ResourceRequiresDependenciesProblem{}
	for resource_name in resource_dependency_names {
		mut found := ?ResourceDependencyCall(none)
		for call in resource_calls {
			if call.argument_kind == 'string' && call.argument == resource_name {
				found = call
				break
			}
		}
		resource_call := found or { continue }
		mut dependency_kind := 'depends_on'
		mut required_dependencies := []string{}
		match resource_name {
			'bcrypt' {
				required_dependencies = ['pkgconf', 'rust']
			}
			'lxml' {
				dependency_kind = if depends_on_linux { 'depends_on' } else { 'uses_from_macos' }
				required_dependencies = ['libxml2', 'libxslt']
			}
			'pynacl' {
				required_dependencies = ['libsodium']
			}
			'pyyaml' {
				required_dependencies = ['libyaml']
			}
			else {
				continue
			}
		}
		if required_dependencies.all(it in available_dependencies) {
			continue
		}
		quoted_dependencies := required_dependencies.map('`"${it}"`')
		requirements := quoted_dependencies.join(' and ')
		message := 'Add `${dependency_kind}` lines above for ${requirements}.'
		problems << ResourceRequiresDependenciesProblem{
			resource: resource_name
			dependency_kind: dependency_kind
			required_dependencies: required_dependencies.clone()
			begin_pos: resource_call.begin_pos
			end_pos: resource_call.end_pos
			message: message
		}
	}
	return problems
}

fn resource_requires_dependencies_problem_value(problem ResourceRequiresDependenciesProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Problem', problem.message, {
		'resource':              problem.resource
		'dependency_kind':       problem.dependency_kind
		'required_dependencies': problem.required_dependencies.join(',')
		'begin_pos':             problem.begin_pos.str()
		'end_pos':               problem.end_pos.str()
		'message':               problem.message
	})
}
