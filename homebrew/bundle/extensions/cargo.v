module extensions

import ruby
import os

pub struct CargoCrate {
pub:
	name   string
	source string
}

pub struct CargoState {
pub mut:
	executable         string
	executable_exists  bool
	packages           []CargoCrate
	installed_packages []CargoCrate
	output             []string
	commands           [][]string
}

fn cargo_error(kind string, message string, attributes map[string]string) ruby.Value {
	return ruby.structured_value(kind, message, attributes)
}

pub fn cargo_definition() ExtensionDefinition {
	return ExtensionDefinition{
		class_name: 'Homebrew::Bundle::Cargo'
		type_name: 'cargo'
		banner_name: 'Cargo packages'
		check_label: 'Cargo Package'
		cleanup_heading: 'Cargo packages'
	}
}

pub fn cargo_normalize_source(raw_source string) string {
	mut source := raw_source.trim_space()
	if source == '' {
		return ''
	}
	if hash_index := source.last_index('#') {
		source = source[..hash_index]
	}
	if source == '' {
		return ''
	}
	for scheme in ['ssh://', 'git://', 'http://', 'https://'] {
		if source.starts_with(scheme) {
			return source
		}
	}
	return ''
}

pub fn cargo_source_args(raw_source string) []string {
	source := cargo_normalize_source(raw_source)
	if source == '' {
		return []
	}
	question := source.index('?') or { return ['--git', source] }
	url := source[..question]
	query := source[question + 1..]
	mut args := ['--git', url]
	equals := query.index('=') or { query.len }
	key := query[..equals]
	value := if equals < query.len { query[equals + 1..] } else { '' }
	if key in ['branch', 'tag', 'rev'] {
		args << '--${key}'
		args << value
	}
	return args
}

pub fn cargo_crate_record(name string, source string) CargoCrate {
	return CargoCrate{
		name: name.trim_space()
		source: cargo_normalize_source(source)
	}
}

pub fn cargo_crate_value(crate CargoCrate) ruby.Value {
	return ruby.map_value({
		'name':   ruby.string_value(crate.name)
		'source': if crate.source == '' {
			ruby.object_value('NilClass', '')
		} else {
			ruby.string_value(crate.source)
		}
	})
}

pub fn cargo_crate_from_value(value ruby.Value) CargoCrate {
	values := value.as_map() or { return cargo_crate_record(value.as_string(), '') }
	if 'options' in values {
		options := values['options'].as_map() or { map[string]ruby.Value{} }
		return cargo_crate_record(if 'name' in values { values['name'].as_string() } else { '' }, if 'source' in options && options['source'].type_name != 'NilClass' {
			options['source'].as_string()
		} else {
			''
		})
	}
	return CargoCrate{
		name: if 'name' in values { values['name'].as_string() } else { '' }
		source: if 'source' in values && values['source'].type_name != 'NilClass' {
			values['source'].as_string()
		} else {
			''
		}
	}
}

pub fn cargo_crates_value(crates []CargoCrate) ruby.Value {
	return ruby.array_value(crates.map(cargo_crate_value(it)))
}

pub fn cargo_crates_from_value(value ruby.Value) []CargoCrate {
	items := value.as_array() or { return [] }
	return items.map(cargo_crate_from_value(it))
}

pub fn cargo_state_value(state CargoState) ruby.Value {
	return ruby.map_value({
		'_definition':        extension_definition_value(cargo_definition())
		'executable':         if state.executable == '' {
			ruby.object_value('NilClass', '')
		} else {
			ruby.object_value('Pathname', state.executable)
		}
		'executable_exists':  ruby.bool_value(state.executable_exists)
		'packages':           cargo_crates_value(state.packages)
		'installed_packages': cargo_crates_value(state.installed_packages)
		'output':             ruby.string_array_value(state.output)
		'commands':           ruby.array_value(state.commands.map(ruby.string_array_value(it)))
	})
}

pub fn cargo_state_from_value(value ruby.Value) CargoState {
	values := value.as_map() or { return CargoState{} }
	mut commands := [][]string{}
	if 'commands' in values {
		for command in values['commands'].as_array() or { [] } {
			commands << (command.as_string_array() or { [] })
		}
	}
	return CargoState{
		executable: if 'executable' in values && values['executable'].type_name != 'NilClass' {
			values['executable'].as_string()
		} else {
			''
		}
		executable_exists: if 'executable_exists' in values {
			values['executable_exists'].as_bool() or { false }
		} else {
			false
		}
		packages: if 'packages' in values {
			cargo_crates_from_value(values['packages'])
		} else {
			[]
		}
		installed_packages: if 'installed_packages' in values {
			cargo_crates_from_value(values['installed_packages'])
		} else {
			[]
		}
		output: if 'output' in values { values['output'].as_string_array() or { [] } } else { [] }
		commands: commands
	}
}

pub fn cargo_entry(name string, options map[string]ruby.Value) !ExtensionEntry {
	mut unknown := []string{}
	for key in options.keys() {
		if key != 'source' {
			unknown << ':${key}'
		}
	}
	if unknown.len > 0 {
		return error('unknown options([${unknown.join(', ')}]) for cargo')
	}
	source_value := options['source'] or { ruby.object_value('NilClass', '') }
	if source_value.type_name !in ['String', 'NilClass'] {
		return error('options[:source](${source_value.repr}) should be a String object')
	}
	mut normalized := map[string]ruby.Value{}
	if source_value.type_name == 'String' && source_value.as_string() != '' {
		source := cargo_normalize_source(source_value.as_string())
		if source == '' {
			return error('options[:source](${source_value.repr}) should be a git URL')
		}
		if question := source.index('?') {
			selector := source[question + 1..]
			if selector != '' {
				equals := selector.index('=') or { selector.len }
				if selector[..equals] !in ['branch', 'tag', 'rev'] {
					return error('options[:source](${source_value.repr}) should select a branch, tag or rev')
				}
			}
		}
		normalized['source'] = ruby.string_value(source)
	}
	return ExtensionEntry{
		entry_type: 'cargo'
		name: name
		options: normalized
	}
}

fn cargo_version_character(character u8) bool {
	return (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character in [
		`.`,
		`+`,
		`-`,
	]
}

pub fn cargo_parse_package_list(output string) []CargoCrate {
	mut crates := []CargoCrate{}
	for line in output.split_into_lines() {
		if line == '' || line[0].is_space() {
			continue
		}
		mut name_end := 0
		for name_end < line.len && line[name_end] !in [` `, `\t`, `:`] {
			name_end++
		}
		if name_end == 0 {
			continue
		}
		mut position := name_end
		if position >= line.len || !line[position].is_space() {
			continue
		}
		for position < line.len && line[position].is_space() {
			position++
		}
		if position >= line.len || line[position] != `v` {
			continue
		}
		position++
		version_start := position
		for position < line.len && cargo_version_character(line[position]) {
			position++
		}
		if position == version_start {
			continue
		}
		mut source := ''
		for position < line.len && line[position].is_space() {
			position++
		}
		if position < line.len && line[position] == `(` {
			if close_relative := line[position + 1..].index(')') {
				source = cargo_normalize_source(line[position + 1..position + 1 + close_relative])
			}
		}
		crate := CargoCrate{
			name: line[..name_end]
			source: source
		}
		if crate !in crates {
			crates << crate
		}
	}
	return crates
}

pub fn cargo_dump_entry(crate CargoCrate) string {
	mut line := extension_dump_entry(cargo_definition(), ExtensionPackage{
		name: crate.name
	})
	if crate.source != '' {
		line += ', source: ${extension_quote(crate.source)}'
	}
	return line
}

pub fn cargo_install_args(name string, source string) []string {
	mut args := ['install', '--locked']
	args << cargo_source_args(source)
	args << name
	return args
}

pub fn cargo_env(executable string, environment map[string]string) map[string]string {
	mut result := map[string]string{}
	for key in ['HOMEBREW_CARGO_HOME', 'HOMEBREW_CARGO_INSTALL_ROOT', 'HOMEBREW_RUSTUP_HOME'] {
		if value := environment[key] {
			if value != '' {
				output_key := match key {
					'HOMEBREW_CARGO_HOME' { 'CARGO_HOME' }
					'HOMEBREW_CARGO_INSTALL_ROOT' { 'CARGO_INSTALL_ROOT' }
					else { 'RUSTUP_HOME' }
				}
				result[output_key] = value
			}
		}
	}
	result['PATH'] = '${os.dir(executable)}:${environment['PATH'] or { '' }}'
	return result
}

pub fn cargo_package_installed(installed []CargoCrate, name string, source string) bool {
	return cargo_crate_record(name, source) in installed
}

pub fn cargo_cleanup_items(entries []ExtensionEntry, executable string, crates []CargoCrate) []string {
	if executable == '' {
		return []
	}
	mut kept := []string{}
	for entry in entries {
		if entry.entry_type == 'cargo' {
			kept << entry.name
		}
	}
	if kept.len == 0 {
		return []
	}
	return crates.filter(it.name !in kept).map(it.name)
}

// Translated from Homebrew/brew `bundle/extensions/cargo.rb`.
