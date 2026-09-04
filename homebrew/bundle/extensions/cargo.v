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
			values['source'].as_string()} else {
			''}
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
			values['executable'].as_string()} else {
			''}
		executable_exists: if 'executable_exists' in values {
			values['executable_exists'].as_bool() or { false }} else {
			false}
		packages: if 'packages' in values {
			cargo_crates_from_value(values['packages'])} else {
			[]}
		installed_packages: if 'installed_packages' in values {
			cargo_crates_from_value(values['installed_packages'])} else {
			[]}
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
// The original source is retained below until every stub has a typed V body.

// Ruby method `type = :cargo` at line 25.
pub fn ruby_cargo_l25_d1_type(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Symbol', 'cargo')
}

// Ruby method `check_label = "Cargo Package"` at line 28.
pub fn ruby_cargo_l28_d2_check_label(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('Cargo Package')
}

// Ruby method `banner_name = "Cargo packages"` at line 31.
pub fn ruby_cargo_l31_d3_banner_name(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('Cargo packages')
}

// Ruby method `entry(name, options = {})` at line 34.
pub fn ruby_cargo_l34_d4_entry(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return cargo_error('ArgumentError', 'name is required', {})
	}
	options := if args.len > 1 {
		args[1].as_map() or { return cargo_error('ArgumentError', err.msg(), {}) }
	} else {
		map[string]ruby.Value{}
	}
	entry := cargo_entry(args[0].as_string(), options) or { return cargo_error('RuntimeError', err.msg(), {}) }
	return extension_entry_value(entry)
}

// Ruby method `reset!` at line 60.
pub fn ruby_cargo_l60_d5_reset(args ...ruby.Value) ruby.Value {
	mut state := if args.len > 0 { cargo_state_from_value(args[0]) } else { CargoState{} }
	state.packages = []
	state.installed_packages = []
	return cargo_state_value(state)
}

// Ruby method `cleanup_heading` at line 66.
pub fn ruby_cargo_l66_d6_cleanup_heading(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('Cargo packages')
}

// Ruby method `package_manager_name` at line 71.
pub fn ruby_cargo_l71_d7_package_manager_name(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('rust')
}

// Ruby method `package_manager_executable` at line 76.
pub fn ruby_cargo_l76_d8_package_manager_executable(args ...ruby.Value) ruby.Value {
	state := if args.len > 0 { cargo_state_from_value(args[0]) } else { CargoState{} }
	if state.executable == '' {
		return ruby.object_value('NilClass', '')
	}
	return ruby.object_value('Pathname', state.executable)
}

// Ruby method `packages` at line 81.
pub fn ruby_cargo_l81_d9_packages(args ...ruby.Value) ruby.Value {
	state := if args.len > 0 { cargo_state_from_value(args[0]) } else { CargoState{} }
	if state.packages.len > 0 {
		return cargo_crates_value(state.packages)
	}
	if state.executable == '' || (state.executable.starts_with('/') && !state.executable_exists) {
		return cargo_crates_value([])
	}
	output := if args.len > 1 { args[1].as_string() } else { '' }
	return cargo_crates_value(cargo_parse_package_list(output))
}

// Ruby method `dump_name(package)` at line 97.
pub fn ruby_cargo_l97_d10_dump_name(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return cargo_error('ArgumentError', 'package is required', {})
	}
	return ruby.string_value(cargo_crate_from_value(args[0]).name)
}

// Ruby method `dump_source(package)` at line 102.
pub fn ruby_cargo_l102_d11_dump_source(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return cargo_error('ArgumentError', 'package is required', {})
	}
	source := cargo_crate_from_value(args[0]).source
	if source == '' {
		return ruby.object_value('NilClass', '')
	}
	return ruby.string_value(source)
}

// Ruby method `dump_entry(package)` at line 110.
pub fn ruby_cargo_l110_d12_dump_entry(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return cargo_error('ArgumentError', 'package is required', {})
	}
	return ruby.string_value(cargo_dump_entry(cargo_crate_from_value(args[0])))
}

// Ruby method `install_package!(name, with: nil, source: nil, verbose: false)` at line 126.
pub fn ruby_cargo_l126_d13_install_package(args ...ruby.Value) ruby.Value {
	state := if args.len > 0 { cargo_state_from_value(args[0]) } else { CargoState{} }
	if state.executable == '' {
		return cargo_error('RuntimeError', 'cargo is not installed', {})
	}
	name := if args.len > 1 { args[1].as_string() } else { '' }
	source := if args.len > 3 && args[3].type_name != 'NilClass' { args[3].as_string() } else { '' }
	result := if args.len > 5 { args[5].as_bool() or { false } } else { false }
	mut command := [state.executable]
	command << cargo_install_args(name, source)
	return ruby.map_value({
		'result':  ruby.bool_value(result)
		'command': ruby.string_array_value(command)
	})
}

// Ruby method `installed_packages` at line 137.
pub fn ruby_cargo_l137_d14_installed_packages(args ...ruby.Value) ruby.Value {
	state := if args.len > 0 { cargo_state_from_value(args[0]) } else { CargoState{} }
	if state.installed_packages.len > 0 {
		return cargo_crates_value(state.installed_packages)
	}
	return cargo_crates_value(state.packages.clone())
}

// Ruby method `uninstall_package!(name, executable: Pathname.new(""))` at line 145.
pub fn ruby_cargo_l145_d15_uninstall_package(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	executable := if args.len > 1 { args[1].as_string() } else { '' }
	return ruby.string_array_value([executable, 'uninstall', name])
}

// Ruby method `package_manager_env(executable)` at line 150.
pub fn ruby_cargo_l150_d16_package_manager_env(args ...ruby.Value) ruby.Value {
	executable := if args.len > 0 { args[0].as_string() } else { '' }
	values := if args.len > 1 {
		args[1].as_map() or { map[string]ruby.Value{} }
	} else {
		map[string]ruby.Value{}
	}
	mut environment := map[string]string{}
	for key, value in values {
		environment[key] = value.as_string()
	}
	mut result := map[string]ruby.Value{}
	for key, value in cargo_env(executable, environment) {
		result[key] = ruby.string_value(value)
	}
	return ruby.map_value(result)
}

// Ruby method `package_record(name, with: nil, source: nil)` at line 161.
pub fn ruby_cargo_l161_d17_package_record(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	source := if args.len > 2 && args[2].type_name != 'NilClass' { args[2].as_string() } else { '' }
	return cargo_crate_value(cargo_crate_record(name, source))
}

// Ruby method `crate_record(name, source: nil)` at line 168.
pub fn ruby_cargo_l168_d18_crate_record(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	source := if args.len > 1 && args[1].type_name != 'NilClass' { args[1].as_string() } else { '' }
	return cargo_crate_value(cargo_crate_record(name, source))
}

// Ruby method `package_installed?(name, with: nil, source: nil)` at line 180.
pub fn ruby_cargo_l180_d19_package_installed(args ...ruby.Value) ruby.Value {
	installed := if args.len > 0 { cargo_crates_from_value(args[0]) } else { [] }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	source := if args.len > 3 && args[3].type_name != 'NilClass' { args[3].as_string() } else { '' }
	return ruby.bool_value(cargo_package_installed(installed, name, source))
}

// Ruby method `preinstall!(name, with: nil, source: nil, no_upgrade: false, verbose: false, **_options)` at line 194.
pub fn ruby_cargo_l194_d20_preinstall(args ...ruby.Value) ruby.Value {
	state := if args.len > 0 { cargo_state_from_value(args[0]) } else { CargoState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	source := if args.len > 3 && args[3].type_name != 'NilClass' { args[3].as_string() } else { '' }
	verbose := if args.len > 4 { args[4].as_bool() or { false } } else { false }
	if state.executable == '' {
		return cargo_error('RuntimeError', 'Unable to install ${name} cargo package. rust installation failed.', {
			'command': 'brew install --formula rust'
		})
	}
	if cargo_package_installed(state.installed_packages, name, source) {
		if verbose {
			return ruby.map_value({
				'result': ruby.bool_value(false)
				'output': ruby.string_value('Skipping install of ${name} cargo package. It is already installed.')
			})
		}
		return ruby.bool_value(false)
	}
	return ruby.bool_value(true)
}

// Ruby method `install!(name, with: nil, source: nil, preinstall: true, no_upgrade: false, verbose: false, force: false,` at line 219.
pub fn ruby_cargo_l219_d21_install(args ...ruby.Value) ruby.Value {
	mut state := if args.len > 0 { cargo_state_from_value(args[0]) } else { CargoState{} }
	name := if args.len > 1 { args[1].as_string() } else { '' }
	source := if args.len > 3 && args[3].type_name != 'NilClass' { args[3].as_string() } else { '' }
	preinstall := if args.len > 4 { args[4].as_bool() or { true } } else { true }
	verbose := if args.len > 5 { args[5].as_bool() or { false } } else { false }
	result := if args.len > 6 { args[6].as_bool() or { false } } else { false }
	if !preinstall {
		return ruby.bool_value(true)
	}
	if state.executable == '' {
		return cargo_error('RuntimeError', 'cargo is not installed', {})
	}
	if verbose {
		state.output << 'Installing ${name} cargo package. It is not currently installed.'
	}
	mut command := [state.executable]
	command << cargo_install_args(name, source)
	state.commands << command
	if !result {
		return ruby.map_value({
			'result': ruby.bool_value(false)
			'state':  cargo_state_value(state)
		})
	}
	crate := cargo_crate_record(name, source)
	if crate !in state.installed_packages {
		state.installed_packages << crate
	}
	if crate !in state.packages {
		state.packages << crate
	}
	return ruby.map_value({
		'result': ruby.bool_value(true)
		'state':  cargo_state_value(state)
	})
}

// Ruby method `source_args(source)` at line 239.
pub fn ruby_cargo_l239_d22_source_args(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 && args[0].type_name != 'NilClass' { args[0].as_string() } else { '' }
	return ruby.string_array_value(cargo_source_args(source))
}

// Ruby method `parse_package_list(output)` at line 253.
pub fn ruby_cargo_l253_d23_parse_package_list(args ...ruby.Value) ruby.Value {
	return cargo_crates_value(cargo_parse_package_list(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `normalize_source(source)` at line 274.
pub fn ruby_cargo_l274_d24_normalize_source(args ...ruby.Value) ruby.Value {
	source := cargo_normalize_source(if args.len > 0 && args[0].type_name != 'NilClass' {
		args[0].as_string()
	} else {
		''
	})
	if source == '' {
		return ruby.object_value('NilClass', '')
	}
	return ruby.string_value(source)
}

// Ruby method `cargo_env(cargo)` at line 284.
pub fn ruby_cargo_l284_d25_cargo_env(args ...ruby.Value) ruby.Value {
	executable := if args.len > 0 { args[0].as_string() } else { '' }
	values := if args.len > 1 {
		args[1].as_map() or { map[string]ruby.Value{} }
	} else {
		map[string]ruby.Value{}
	}
	mut environment := map[string]string{}
	for key, value in values {
		environment[key] = value.as_string()
	}
	mut result := map[string]ruby.Value{}
	for key, value in cargo_env(executable, environment) {
		result[key] = ruby.string_value(value)
	}
	return ruby.map_value(result)
}

// Ruby method `format_checkable(entries)` at line 296.
pub fn ruby_cargo_l296_d26_format_checkable(args ...ruby.Value) ruby.Value {
	entry_values := if args.len > 0 { args[0].as_array() or { [] } } else { [] }
	mut crates := []CargoCrate{}
	for entry_value in entry_values {
		entry := extension_entry_from_value(entry_value)
		if entry.entry_type == 'cargo' {
			crates << cargo_crate_from_value(entry_value)
		}
	}
	return cargo_crates_value(crates)
}

// Ruby method `installed_and_up_to_date?(package, no_upgrade: false)` at line 303.
pub fn ruby_cargo_l303_d27_installed_and_up_to_date(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	installed := cargo_crates_from_value(args[0])
	crate := cargo_crate_from_value(args[1])
	return ruby.bool_value(cargo_package_installed(installed, crate.name, crate.source))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/extensions/extension"
// 5:
// 6: module Homebrew
// 7:   module Bundle
// 8:     class Cargo < Extension
// 9:       SourceOptions = T.type_alias { T::Hash[Symbol, String] }
// 10:       Crate = T.type_alias { { name: String, source: T.nilable(String) } }
// 11:       Checkable = T.type_alias { { name: String, options: SourceOptions } }
// 12:       CrateEntry = T.type_alias { T.any(Crate, Checkable) }
// 13:
// 14:       # `cargo install --list` reports the origin of anything not installed from a
// 15:       # registry, as either a git URL or a local path. Only a git URL that resolves
// 16:       # from another machine is supported here, so neither a path nor the `file://`
// 17:       # scheme is accepted. `--git` rejects an scp-style remote, so a scheme is
// 18:       # required too.
// 19:       GIT_SOURCE_REGEX = %r{\A(?:ssh|git|https?)://}
// 20:       GIT_REFERENCE_KEYS = %w[branch tag rev].freeze
// 21:       PACKAGE_LIST_REGEX = /\A(?<name>[^\s:]+)\s+v[0-9A-Za-z.+-]+(?:\s+\((?<origin>[^)]+)\))?/
// 22:
// 23:       class << self
// 24:         sig { override.returns(Symbol) }
// 25:         def type = :cargo
// 26:
// 27:         sig { override.returns(String) }
// 28:         def check_label = "Cargo Package"
// 29:
// 30:         sig { override.returns(String) }
// 31:         def banner_name = "Cargo packages"
// 32:
// 33:         sig { override.params(name: String, options: Homebrew::Bundle::EntryInputOptions).returns(Dsl::Entry) }
// 34:         def entry(name, options = {})
// 35:           unknown_options = options.keys - [:source]
// 36:           raise "unknown options(#{unknown_options.inspect}) for cargo" if unknown_options.present?
// 37:
// 38:           source = options.fetch(:source, nil)
// 39:           if !source.nil? && !source.is_a?(String)
// 40:             raise "options[:source](#{source.inspect}) should be a String object"
// 41:           end
// 42:
// 43:           normalized_options = {}
// 44:           if source.present?
// 45:             normalized_source = normalize_source(source)
// 46:             raise "options[:source](#{source.inspect}) should be a git URL" if normalized_source.nil?
// 47:
// 48:             selector = normalized_source.partition("?").last
// 49:             if selector.present? && GIT_REFERENCE_KEYS.exclude?(selector.partition("=").first)
// 50:               raise "options[:source](#{source.inspect}) should select a branch, tag or rev"
// 51:             end
// 52:
// 53:             normalized_options[:source] = normalized_source
// 54:           end
// 55:
// 56:           Dsl::Entry.new(:cargo, name, normalized_options)
// 57:         end
// 58:
// 59:         sig { override.void }
// 60:         def reset!
// 61:           @packages = T.let(nil, T.nilable(T::Array[Crate]))
// 62:           @installed_packages = T.let(nil, T.nilable(T::Array[Crate]))
// 63:         end
// 64:
// 65:         sig { override.returns(T.nilable(String)) }
// 66:         def cleanup_heading
// 67:           banner_name
// 68:         end
// 69:
// 70:         sig { override.returns(String) }
// 71:         def package_manager_name
// 72:           "rust"
// 73:         end
// 74:
// 75:         sig { override.returns(T.nilable(Pathname)) }
// 76:         def package_manager_executable
// 77:           which("cargo", ORIGINAL_PATHS)
// 78:         end
// 79:
// 80:         sig { override.returns(T::Array[Crate]) }
// 81:         def packages
// 82:           packages = @packages
// 83:           return packages if packages
// 84:
// 85:           @packages = if (cargo = package_manager_executable) &&
// 86:                          (!cargo.to_s.start_with?("/") || cargo.exist?)
// 87:             with_env(cargo_env(cargo)) do
// 88:               parse_package_list(`#{cargo} install --list`)
// 89:             end
// 90:           end
// 91:           return [] if @packages.nil?
// 92:
// 93:           @packages
// 94:         end
// 95:
// 96:         sig { override.params(package: Object).returns(String) }
// 97:         def dump_name(package)
// 98:           T.cast(package, CrateEntry)[:name]
// 99:         end
// 100:
// 101:         sig { params(package: Object).returns(T.nilable(String)) }
// 102:         def dump_source(package)
// 103:           package = T.cast(package, CrateEntry)
// 104:           return package[:source] if package.key?(:source)
// 105:
// 106:           package[:options].fetch(:source, nil)
// 107:         end
// 108:
// 109:         sig { override.params(package: Object).returns(String) }
// 110:         def dump_entry(package)
// 111:           line = super
// 112:           source = dump_source(package)
// 113:           line = "#{line}, source: #{quote(source)}" if source.present?
// 114:
// 115:           line
// 116:         end
// 117:
// 118:         sig {
// 119:           override.params(
// 120:             name:    String,
// 121:             with:    T.nilable(T::Array[String]),
// 122:             source:  T.nilable(String),
// 123:             verbose: T::Boolean,
// 124:           ).returns(T::Boolean)
// 125:         }
// 126:         def install_package!(name, with: nil, source: nil, verbose: false)
// 127:           _ = with
// 128:
// 129:           cargo = package_manager_executable!
// 130:
// 131:           with_env(cargo_env(cargo)) do
// 132:             Bundle.system(cargo.to_s, "install", "--locked", *source_args(source), name, verbose:)
// 133:           end
// 134:         end
// 135:
// 136:         sig { override.returns(T::Array[Crate]) }
// 137:         def installed_packages
// 138:           installed_packages = @installed_packages
// 139:           return installed_packages if installed_packages
// 140:
// 141:           @installed_packages = packages.dup
// 142:         end
// 143:
// 144:         sig { override.params(name: String, executable: Pathname).void }
// 145:         def uninstall_package!(name, executable: Pathname.new(""))
// 146:           Bundle.system(executable.to_s, "uninstall", name, verbose: false)
// 147:         end
// 148:
// 149:         sig { override.params(executable: Pathname).returns(T::Hash[String, String]) }
// 150:         def package_manager_env(executable)
// 151:           cargo_env(executable)
// 152:         end
// 153:
// 154:         sig {
// 155:           override.params(
// 156:             name:   String,
// 157:             with:   T.nilable(T::Array[String]),
// 158:             source: T.nilable(String),
// 159:           ).returns(Object)
// 160:         }
// 161:         def package_record(name, with: nil, source: nil)
// 162:           _ = with
// 163:
// 164:           crate_record(name, source:)
// 165:         end
// 166:
// 167:         sig { params(name: String, source: T.nilable(String)).returns(Crate) }
// 168:         def crate_record(name, source: nil)
// 169:           { name: name.strip, source: normalize_source(source) }
// 170:         end
// 171:         private :crate_record
// 172:
// 173:         sig {
// 174:           override.params(
// 175:             name:   String,
// 176:             with:   T.nilable(T::Array[String]),
// 177:             source: T.nilable(String),
// 178:           ).returns(T::Boolean)
// 179:         }
// 180:         def package_installed?(name, with: nil, source: nil)
// 181:           installed_packages.include?(package_record(name, with:, source:))
// 182:         end
// 183:
// 184:         sig {
// 185:           override.params(
// 186:             name:       String,
// 187:             with:       T.nilable(T::Array[String]),
// 188:             source:     T.nilable(String),
// 189:             no_upgrade: T::Boolean,
// 190:             verbose:    T::Boolean,
// 191:             _options:   Homebrew::Bundle::EntryOption,
// 192:           ).returns(T::Boolean)
// 193:         }
// 194:         def preinstall!(name, with: nil, source: nil, no_upgrade: false, verbose: false, **_options)
// 195:           _ = no_upgrade
// 196:
// 197:           ensure_package_manager_installed!(name, verbose:)
// 198:
// 199:           if package_installed?(name, with:, source:)
// 200:             puts "Skipping install of #{name} #{package_description}. It is already installed." if verbose
// 201:             return false
// 202:           end
// 203:
// 204:           true
// 205:         end
// 206:
// 207:         sig {
// 208:           override.params(
// 209:             name:       String,
// 210:             with:       T.nilable(T::Array[String]),
// 211:             source:     T.nilable(String),
// 212:             preinstall: T::Boolean,
// 213:             no_upgrade: T::Boolean,
// 214:             verbose:    T::Boolean,
// 215:             force:      T::Boolean,
// 216:             _options:   Homebrew::Bundle::EntryOption,
// 217:           ).returns(T::Boolean)
// 218:         }
// 219:         def install!(name, with: nil, source: nil, preinstall: true, no_upgrade: false, verbose: false, force: false,
// 220:                      **_options)
// 221:           _ = no_upgrade
// 222:           _ = force
// 223:
// 224:           return true unless preinstall
// 225:
// 226:           puts "Installing #{name} #{package_description}. It is not currently installed." if verbose
// 227:           return false unless install_package!(name, with:, source:, verbose:)
// 228:
// 229:           package = crate_record(name, source:)
// 230:           installed_packages << package unless installed_packages.include?(package)
// 231:           packages << package unless packages.include?(package)
// 232:           true
// 233:         end
// 234:
// 235:         # A branch, tag or revision selected at install time is reported by
// 236:         # `cargo install --list` as a URL query, and never more than one of them,
// 237:         # but `--git` rejects a query: it has to be passed as the matching flag.
// 238:         sig { params(source: T.nilable(String)).returns(T::Array[String]) }
// 239:         def source_args(source)
// 240:           source = normalize_source(source)
// 241:           return [] if source.nil?
// 242:
// 243:           url, _, query = source.partition("?")
// 244:           key, _, value = query.partition("=")
// 245:           args = ["--git", url]
// 246:           args.push("--#{key}", value) if GIT_REFERENCE_KEYS.include?(key)
// 247:
// 248:           args
// 249:         end
// 250:         private :source_args
// 251:
// 252:         sig { params(output: String).returns(T::Array[Crate]) }
// 253:         def parse_package_list(output)
// 254:           output.lines.filter_map do |line|
// 255:             next if line.match?(/^\s/)
// 256:
// 257:             match = line.match(PACKAGE_LIST_REGEX)
// 258:             next if match.nil?
// 259:
// 260:             name = match[:name]
// 261:             next if name.nil?
// 262:
// 263:             { name:, source: normalize_source(match[:origin]) }
// 264:           end.uniq
// 265:         end
// 266:         private :parse_package_list
// 267:
// 268:         # The resolved revision that `cargo install --list` appends to a git origin
// 269:         # is deliberately dropped: a dumped Brewfile has to compare equal to a
// 270:         # hand-written one, which a pinned revision would prevent. Anything that is
// 271:         # not a git URL has no `source:` to dump, whether it is a registry crate or
// 272:         # a local path.
// 273:         sig { params(source: T.nilable(String)).returns(T.nilable(String)) }
// 274:         def normalize_source(source)
// 275:           source = source.presence&.strip&.sub(/#[^#]*\z/, "")
// 276:           return if source.blank?
// 277:           return source if source.match?(GIT_SOURCE_REGEX)
// 278:
// 279:           nil
// 280:         end
// 281:         private :normalize_source
// 282:
// 283:         sig { params(cargo: Pathname).returns(T::Hash[String, String]) }
// 284:         def cargo_env(cargo)
// 285:           {
// 286:             "CARGO_HOME"         => ENV.fetch("HOMEBREW_CARGO_HOME", nil),
// 287:             "CARGO_INSTALL_ROOT" => ENV.fetch("HOMEBREW_CARGO_INSTALL_ROOT", nil),
// 288:             "PATH"               => "#{cargo.dirname}:#{ENV.fetch("PATH")}",
// 289:             "RUSTUP_HOME"        => ENV.fetch("HOMEBREW_RUSTUP_HOME", nil),
// 290:           }.compact
// 291:         end
// 292:         private :cargo_env
// 293:       end
// 294:
// 295:       sig { override.params(entries: T::Array[Dsl::Entry]).returns(T::Array[Object]) }
// 296:       def format_checkable(entries)
// 297:         checkable_entries(entries).map do |entry|
// 298:           { name: entry.name, options: entry.options }
// 299:         end
// 300:       end
// 301:
// 302:       sig { override.params(package: Object, no_upgrade: T::Boolean).returns(T::Boolean) }
// 303:       def installed_and_up_to_date?(package, no_upgrade: false)
// 304:         self.class.package_installed?(
// 305:           self.class.dump_name(package),
// 306:           source: self.class.dump_source(package),
// 307:         )
// 308:       end
// 309:     end
// 310:   end
// 311: end
