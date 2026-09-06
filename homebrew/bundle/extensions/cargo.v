module extensions

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
