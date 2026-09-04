module main

import os

struct Definition {
	line   int
	kind   string
	name   string
	header string
}

fn main() {
	if os.args.len != 4 {
		eprintln('usage: translate_stub <Homebrew root> <relative-file manifest> <destination root>')
		exit(2)
	}
	source_root := os.real_path(os.args[1])
	manifest := os.args[2]
	destination_root := os.real_path(os.args[3])
	for relative_path in os.read_lines(manifest) or { panic(err) } {
		path := relative_path.trim_space()
		if path == '' || path.starts_with('#') {
			continue
		}
		translate_file(source_root, path, destination_root) or {
			eprintln(err)
			exit(1)
		}
	}
}

fn translate_file(source_root string, relative_path string, destination_root string) ! {
	source_path := os.join_path(source_root, relative_path)
	if !os.exists(source_path) {
		return error('missing Ruby source: ${source_path}')
	}
	lines := os.read_lines(source_path)!
	destination_relative := v_destination_relative_path(relative_path)
	destination_path := os.join_path(destination_root, destination_relative)
	os.mkdir_all(os.dir(destination_path))!
	module_name := module_for(relative_path)
	file_name := identifier(without_rb_suffix(os.file_name(relative_path)))
	definitions := definitions_in(lines)
	has_file_body := relative_path == 'brew.rb'
	mut output := []string{cap: lines.len + definitions.len * 8 + 16}
	output << 'module ${module_name}'
	if definitions.len > 0 || has_file_body {
		output << ''
		output << 'import ruby'
	}
	output << ''
	output << '// Translated from Homebrew/brew `${relative_path}`.'
	output << '// The original source is retained below until every stub has a typed V body.'
	if has_file_body {
		output << ''
		output << '// Ruby top-level program body from `${relative_path}`.'
		output << 'pub fn ruby_brew_file_body(args ...ruby.Value) ruby.Value {'
		output << "\treturn ruby.unimplemented_fn('brew.rb:<top-level>', ...args)"
		output << '}'
	}
	for definition_index, definition in definitions {
		function_name := 'ruby_${file_name}_l${definition.line}_d${definition_index + 1}_${identifier(definition.name)}'
		output << ''
		output << '// Ruby ${definition.kind} `${definition.header}` at line ${definition.line}.'
		output << 'pub fn ${function_name}(args ...ruby.Value) ruby.Value {'
		output << "\treturn ruby.unimplemented_fn('${escape_v_string(definition.name)}', ...args)"
		output << '}'
	}
	output << ''
	output << '// Original Ruby source (line-for-line):'
	for index, line in lines {
		output << '// ${index + 1}: ${line}'
	}
	output << ''
	os.write_file(destination_path, output.join('\n'))!
}

fn module_for(relative_path string) string {
	directory := os.dir(relative_path)
	if directory == '.' {
		return 'homebrew'
	}
	return identifier(os.base(directory))
}

fn without_rb_suffix(path string) string {
	if path.ends_with('.rb') {
		return path[..path.len - 3]
	}
	return path
}

fn v_destination_relative_path(relative_path string) string {
	mut components := relative_path.split('/')
	for index in 0 .. components.len - 1 {
		components[index] = components[index].to_lower()
	}
	mut translated_path := without_rb_suffix(components.join('/'))
	if translated_path.ends_with('_test') {
		translated_path += '_ruby'
	}
	return translated_path + '.v'
}

fn definitions_in(lines []string) []Definition {
	mut definitions := []Definition{}
	for index, line in lines {
		trimmed := line.trim_space()
		if trimmed.starts_with('#') {
			continue
		}
		method_prefix := ruby_method_prefix(trimmed)
		if method_prefix != '' {
			header := trimmed.all_after(method_prefix).trim_space()
			definitions << Definition{
				line:   index + 1
				kind:   'method'
				name:   ruby_method_name(header)
				header: header
			}
			continue
		}
		for construct in ['define_method', 'define_singleton_method'] {
			if trimmed.contains(construct) {
				definitions << Definition{
					line:   index + 1
					kind:   construct
					name:   dynamic_method_name(trimmed, construct)
					header: trimmed
				}
				break
			}
		}
		for construct in ['attr_reader', 'attr_writer', 'attr_accessor', 'alias_method'] {
			if trimmed.contains(construct) {
				statement := logical_statement(lines, index)
				mut names := declaration_names(statement, construct)
				if construct == 'alias_method' && names.len > 1 {
					names = names[..1].clone()
				} else if construct == 'attr_writer' {
					names = names.map(it + '=')
				} else if construct == 'attr_accessor' {
					readers := names.clone()
					names = []string{cap: readers.len * 2}
					for reader in readers {
						names << reader
						names << reader + '='
					}
				}
				if names.len == 0 {
					definitions << Definition{
						line:   index + 1
						kind:   construct
						name:   '${construct}_dynamic'
						header: statement
					}
				}
				for name in names {
					definitions << Definition{
						line:   index + 1
						kind:   construct
						name:   name
						header: statement
					}
				}
				break
			}
		}
		for construct in ['attr_atomic', 'attr_volatile'] {
			if trimmed.starts_with('${construct} ') || trimmed.starts_with('${construct}(') {
				statement := logical_statement(lines, index)
				atomic_names := ruby_symbol_names(statement.all_after(construct))
				for atomic_name in atomic_names {
					mut names := [atomic_name, atomic_name + '=', 'compare_and_set_${atomic_name}']
					if construct == 'attr_atomic' {
						names << 'swap_${atomic_name}'
						names << 'update_${atomic_name}'
					} else {
						names << 'cas_${atomic_name}'
						names << 'lazy_set_${atomic_name}'
					}
					for name in names {
						definitions << Definition{
							line:   index + 1
							kind:   construct
							name:   name
							header: statement
						}
					}
				}
				break
			}
		}
		if trimmed.starts_with('alias ') {
			alias_name := trimmed.all_after('alias ').fields().first()
			definitions << Definition{
				line:   index + 1
				kind:   'alias'
				name:   alias_name
				header: trimmed
			}
		}
		for construct in ['delegate', 'def_delegator', 'def_delegators', 'def_instance_delegator',
			'def_instance_delegators', 'def_node_matcher', 'def_node_search', 'matcher',
			'alias_matcher', 'let', 'let!', 'subject', 'subject!', 'it', 'specify', 'example'] {
			if trimmed.starts_with('${construct} ') || trimmed.starts_with('${construct}(') {
				statement := logical_statement(lines, index)
				if statement.all_after(construct).trim_space().starts_with('=') {
					continue
				}
				names := generated_method_names(statement, construct)
				if names.len == 0 {
					definitions << Definition{
						line:   index + 1
						kind:   construct
						name:   '${construct}_dynamic'
						header: statement
					}
				}
				for name in names {
					definitions << Definition{
						line:   index + 1
						kind:   construct
						name:   name
						header: statement
					}
				}
				break
			}
		}
	}
	return definitions
}

fn ruby_method_prefix(line string) string {
	for prefix in ['def ', 'def\t', 'private def ', 'protected def ', 'public def ',
		'private_class_method def ', 'public_class_method def ', 'module_function def '] {
		if line.starts_with(prefix) {
			return prefix
		}
	}
	return ''
}

fn logical_statement(lines []string, start int) string {
	mut parts := []string{}
	mut square_depth := 0
	mut round_depth := 0
	end := if start + 100 < lines.len { start + 100 } else { lines.len }
	for index in start .. end {
		part := ruby_code_before_comment(lines[index].trim_space())
		parts << part
		square_depth += part.count('[') - part.count(']')
		round_depth += part.count('(') - part.count(')')
		if square_depth <= 0 && round_depth <= 0 && !part.ends_with(',') {
			break
		}
	}
	return parts.join(' ')
}

fn ruby_code_before_comment(line string) string {
	comment := line.index(' #') or { return line }
	return line[..comment].trim_space()
}

fn generated_method_names(statement string, construct string) []string {
	mut declaration := statement.all_after(construct).trim_space().trim('()')
	if declaration.starts_with('=') {
		return []
	}
	if construct in ['def_node_matcher', 'def_node_search', 'matcher', 'alias_matcher', 'let',
		'let!', 'subject', 'subject!'] {
		names := ruby_symbol_names(declaration)
		return if names.len > 0 { names[..1].clone() } else { []string{} }
	}
	if construct in ['it', 'specify', 'example'] {
		return [dynamic_method_name(statement, construct)]
	}
	if construct == 'def_delegator' || construct == 'def_instance_delegator' {
		names := ruby_symbol_names(declaration)
		if names.len >= 3 {
			return [names.last()]
		}
		return if names.len == 2 { [names[1]] } else { []string{} }
	}
	if construct == 'def_delegators' || construct == 'def_instance_delegators' {
		names := ruby_symbol_names(declaration)
		return if names.len > 1 { names[1..].clone() } else { []string{} }
	}
	if arrow := declaration.index('=>') {
		declaration = declaration[..arrow]
	} else if target := declaration.index('to:') {
		declaration = declaration[..target]
	}
	if declaration.starts_with('[') || declaration.starts_with(':') {
		return ruby_symbol_names(declaration)
	}
	colon := declaration.index(':') or { return [] }
	name := declaration[..colon].trim_space().trim('"\'')
	return if name != '' { [name] } else { []string{} }
}

fn ruby_symbol_names(input string) []string {
	mut names := []string{}
	bytes := input.bytes()
	mut index := 0
	for index < bytes.len {
		if bytes[index] != `:` || (index > 0 && is_ruby_name_byte(bytes[index - 1])) {
			index++
			continue
		}
		index++
		if index >= bytes.len {
			break
		}
		if bytes[index] == `"` || bytes[index] == `'` {
			quote := bytes[index]
			index++
			start := index
			for index < bytes.len && bytes[index] != quote {
				index++
			}
			if index > start {
				names << bytes[start..index].bytestr()
			}
			index++
			continue
		}
		start := index
		for index < bytes.len && is_ruby_name_byte(bytes[index]) {
			index++
		}
		if index > start {
			names << bytes[start..index].bytestr()
		}
	}
	return names
}

fn is_ruby_name_byte(character u8) bool {
	return (character >= `a` && character <= `z`)
		|| (character >= `A` && character <= `Z`)
		|| (character >= `0` && character <= `9`)
		|| character in [`_`, `@`, `?`, `!`, `=`, `[`, `]`]
}

fn declaration_names(line string, construct string) []string {
	mut declaration := line.all_after(construct).trim_space()
	declaration = declaration.trim('()')
	symbol_names := ruby_symbol_names(declaration)
	if symbol_names.len > 0 {
		return symbol_names
	}
	mut names := []string{}
	for field in declaration.split(',') {
		candidate := field.trim_space().trim('\'"')
		if candidate.starts_with(':') && candidate.len > 1 {
			names << candidate[1..]
		} else if (field.trim_space().starts_with("'") || field.trim_space().starts_with('"'))
			&& candidate != '' {
			names << candidate
		}
	}
	return names
}

fn ruby_method_name(header string) string {
	mut end := header.len
	for separator in ['(', ' ', '\t'] {
		position := header.index(separator) or { continue }
		if position < end {
			end = position
		}
	}
	name := header[..end].trim_space().trim_right(';')
	if name == '' {
		return 'anonymous'
	}
	return name
}

fn dynamic_method_name(line string, construct string) string {
	mut remainder := line.all_after(construct).trim_space().trim_left('(').trim_space()
	if remainder.starts_with(',') {
		remainder = remainder[1..].trim_space()
	}
	if remainder.starts_with(':') {
		remainder = remainder[1..]
	}
	if remainder.starts_with("'") || remainder.starts_with('"') {
		remainder = remainder[1..]
	}
	mut end := remainder.len
	for separator in ["'", '"', ')', ',', ' ', '\t'] {
		position := remainder.index(separator) or { continue }
		if position < end {
			end = position
		}
	}
	name := remainder[..end]
	if name == '' {
		return '${construct}_dynamic'
	}
	return name
}

fn identifier(input string) string {
	mut result := []u8{cap: input.len + 1}
	for character in input.bytes() {
		if (character >= `a` && character <= `z`) || (character >= `0` && character <= `9`) {
			result << character
		} else if character >= `A` && character <= `Z` {
			result << character + 32
		} else if result.len == 0 || result.last() != `_` {
			result << `_`
		}
	}
	mut value := result.bytestr().trim('_')
	if value == '' {
		value = 'anonymous'
	}
	if value[0].is_digit() {
		value = 'n_${value}'
	}
	return value
}

fn escape_v_string(input string) string {
	return input.replace('\\', '\\\\').replace("'", "\\'")
}
