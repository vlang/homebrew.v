module bundle

import ruby

// Translated from Homebrew/brew `bundle/dumper.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.can_write_to_brewfile?(brewfile_path, force: false)` at line 13.
pub fn ruby_dumper_l13_d1_self_can_write_to_brewfile(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Brewfile path is required')
	}
	force := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	can_write_to_brewfile(args[0].as_string(), force) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return ruby.bool_value(true)
}

// Ruby method `self.build_brewfile(describe:, no_restart:, formulae:, taps:, casks:, extension_types: {})` at line 29.
pub fn ruby_dumper_l29_d2_self_build_brewfile(args ...ruby.Value) ruby.Value {
	input := if args.len > 0 { bundle_dump_input_from_value(args[0]) } else { BundleDumpInput{} }
	selection := if args.len > 1 {
		bundle_dump_selection_from_value(args[1])
	} else {
		BundleDumpSelection{}
	}
	return ruby.string_value(build_brewfile(input, selection))
}

// Ruby method `self.dump_brewfile(global:, file:, describe:, force:, no_restart:, formulae:, taps:, casks:,` at line 70.
pub fn ruby_dumper_l70_d3_self_dump_brewfile(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.object_value('ArgumentError', 'path config, selection, and dump input are required')
	}
	config := bundle_brewfile_path_config_from_value(args[0])
	selection := bundle_dump_selection_from_value(args[1])
	input := bundle_dump_input_from_value(args[2])
	force := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	result := dump_brewfile(config, input, selection, force, real_brewfile_writer) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return ruby.structured_value('BundleDumpResult', result.path, {
		'path':    result.path
		'content': result.content
	})
}

// Ruby method `self.brewfile_path(global: false, file: nil)` at line 81.
pub fn ruby_dumper_l81_d4_self_brewfile_path(args ...ruby.Value) ruby.Value {
	config := if args.len > 0 && args[0].type_name == 'BundleBrewfilePathConfig' {
		bundle_brewfile_path_config_from_value(args[0])
	} else {
		default_bundle_brewfile_path_config(if args.len > 0 {
			args[0].as_bool() or { false }
		} else {
			false
		}, if args.len > 1 && args[1].type_name !in ['Nil', 'NilClass'] {
			?string(args[1].as_string())
		} else {
			none
		})
	}
	path := brewfile_path(config) or { return ruby.object_value('RuntimeError', err.msg()) }
	return ruby.object_value('Pathname', path)
}

// Ruby method `self.should_not_write_file?(file, overwrite: false)` at line 87.
pub fn ruby_dumper_l87_d5_self_should_not_write_file(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	overwrite := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	return ruby.bool_value(should_not_write_file(args[0].as_string(), overwrite))
}

// Ruby method `self.write_file(file, content)` at line 92.
pub fn ruby_dumper_l92_d6_self_write_file(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'file and content are required')
	}
	write_brewfile(args[0].as_string(), args[1].as_string(), real_brewfile_writer) or {
		return ruby.object_value('IOError', err.msg())
	}
	return ruby.object_value('NilClass', '')
}

pub const bundle_dump_package_order = ['tap', 'brew', 'cask', 'mas', 'vscode', 'go', 'cargo', 'uv',
	'flatpak', 'winget']

pub struct BundleDumpFormula {
pub:
	full_name            string
	installed_on_request bool
	description          string
	args                 []string
	restart_service      bool
	link                 ?bool
}

pub struct BundleDumpCask {
pub:
	full_name   string
	description string
	config      string
}

pub struct BundleDumpTap {
pub:
	name               string
	remote             string
	default_remote     string
	explicitly_trusted bool
}

pub struct BundleDumpSection {
pub:
	type_name      string
	output         string
	dump_supported bool = true
}

// BundleDumpInput contains the package-manager snapshots used to build a
// Brewfile without querying mutable global package caches.
pub struct BundleDumpInput {
pub:
	formulae         []BundleDumpFormula
	casks            []BundleDumpCask
	taps             []BundleDumpTap
	extensions       []BundleDumpSection
	trusted_formulae []string
	trusted_casks    []string
	trusted_commands []string
}

pub struct BundleDumpSelection {
pub:
	describe        bool
	no_restart      bool
	formulae        bool
	taps            bool
	casks           bool
	extension_types map[string]bool
}

pub struct BundleBrewfilePathConfig {
pub:
	global                      bool
	file                        ?string
	working_directory           string
	home_directory              string
	env_bundle_file_global      string
	env_bundle_file             string
	user_config_home            string
	user_config_home_exists     bool
	user_config_brewfile_exists bool
	home_brewfile_exists        bool
}

pub struct BundleDumpResult {
pub:
	path    string
	content string
}

pub type BrewfileWriter = fn(path string, content string) !

pub fn build_brewfile(input BundleDumpInput, selection BundleDumpSelection) string {
	mut outputs := map[string]string{}
	if selection.taps {
		outputs['tap'] = dump_taps(input)
	}
	if selection.formulae {
		outputs['brew'] = dump_formulae(input, selection)
	}
	if selection.casks {
		outputs['cask'] = dump_casks(input, selection.describe)
	}
	mut extra_types := []string{}
	for section in input.extensions {
		if !section.dump_supported || !(selection.extension_types[section.type_name] or { false }) {
			continue
		}
		outputs[section.type_name] = section.output
		if section.type_name !in bundle_dump_package_order {
			extra_types << section.type_name
		}
	}
	extra_types.sort()
	mut ordered_types := bundle_dump_package_order.clone()
	ordered_types << extra_types
	mut content := []string{}
	for package_type in ordered_types {
		output := outputs[package_type] or { continue }
		if output.len > 0 {
			content << output
		}
	}
	return '${content.join('\n')}\n'
}

pub fn brewfile_path(config BundleBrewfilePathConfig) !string {
	mut filename := ''
	if config.global {
		if config.env_bundle_file_global.trim_space().len > 0 {
			filename = config.env_bundle_file_global
		} else {
			if config.env_bundle_file.trim_space().len > 0 {
				return error("'HOMEBREW_BUNDLE_FILE' cannot be specified with '--global'")
			}
			home_brewfile := ruby.join_path(config.home_directory, '.Brewfile')
			user_config_brewfile := ruby.join_path(config.user_config_home, 'Brewfile')
			filename = if config.user_config_home.trim_space().len > 0 && config.user_config_home_exists && (config.user_config_brewfile_exists || !config.home_brewfile_exists) {
				user_config_brewfile
			} else {
				home_brewfile
			}
		}
	} else if requested_file := config.file {
		if requested_file.trim_space().len > 0 {
			filename = if requested_file == '-' { '/dev/stdout' } else { requested_file }
		}
	}
	if filename.len == 0 {
		filename = if config.env_bundle_file.trim_space().len > 0 {
			config.env_bundle_file
		} else {
			'Brewfile'
		}
	}
	return if filename.starts_with('/') {
		filename
	} else {
		ruby.join_path(config.working_directory, filename)
	}
}

pub fn should_not_write_file(path string, overwrite bool) bool {
	return ruby.path_exists(path) && !overwrite && path != '/dev/stdout'
}

pub fn can_write_to_brewfile(path string, force bool) !bool {
	if should_not_write_file(path, force) {
		return error('${path} already exists')
	}
	return true
}

pub fn write_brewfile(path string, content string, writer BrewfileWriter) ! {
	writer(path, content)!
}

pub fn dump_brewfile(config BundleBrewfilePathConfig, input BundleDumpInput,
	selection BundleDumpSelection, force bool, writer BrewfileWriter) !BundleDumpResult {
	path := brewfile_path(config)!
	can_write_to_brewfile(path, force)!
	content := build_brewfile(input, selection)
	write_brewfile(path, content, writer)!
	return BundleDumpResult{
		path: path
		content: content
	}
}

pub fn real_brewfile_writer(path string, content string) ! {
	ruby.write_file(path, content)!
}

pub fn bundle_dump_input_value(input BundleDumpInput) ruby.Value {
	return ruby.Value{
		type_name: 'BundleDumpInput'
		map_data: {
			'formulae':         ruby.array_value(input.formulae.map(bundle_dump_formula_value(it)))
			'casks':            ruby.array_value(input.casks.map(bundle_dump_cask_value(it)))
			'taps':             ruby.array_value(input.taps.map(bundle_dump_tap_value(it)))
			'extensions':       ruby.array_value(input.extensions.map(bundle_dump_section_value(it)))
			'trusted_formulae': ruby.string_array_value(input.trusted_formulae)
			'trusted_casks':    ruby.string_array_value(input.trusted_casks)
			'trusted_commands': ruby.string_array_value(input.trusted_commands)
		}
	}
}

pub fn bundle_dump_selection_value(selection BundleDumpSelection) ruby.Value {
	mut extension_values := map[string]ruby.Value{}
	for name, selected in selection.extension_types {
		extension_values[name] = ruby.bool_value(selected)
	}
	return ruby.Value{
		type_name: 'BundleDumpSelection'
		map_data: extension_values
		attributes: {
			'describe':   selection.describe.str()
			'no_restart': selection.no_restart.str()
			'formulae':   selection.formulae.str()
			'taps':       selection.taps.str()
			'casks':      selection.casks.str()
		}
	}
}

pub fn bundle_brewfile_path_config_value(config BundleBrewfilePathConfig) ruby.Value {
	return ruby.structured_value('BundleBrewfilePathConfig', config.working_directory, {
		'global':                      config.global.str()
		'file':                        config.file or { '' }
		'working_directory':           config.working_directory
		'home_directory':              config.home_directory
		'env_bundle_file_global':      config.env_bundle_file_global
		'env_bundle_file':             config.env_bundle_file
		'user_config_home':            config.user_config_home
		'user_config_home_exists':     config.user_config_home_exists.str()
		'user_config_brewfile_exists': config.user_config_brewfile_exists.str()
		'home_brewfile_exists':        config.home_brewfile_exists.str()
	})
}

fn dump_formulae(input BundleDumpInput, selection BundleDumpSelection) string {
	mut lines := []string{}
	for formula in input.formulae {
		if !formula.installed_on_request {
			continue
		}
		mut line := ''
		if selection.describe && formula.description.len > 0 {
			line = formula.description.split('\n').map('# ${it}\n').join('')
		}
		line += 'brew "${bundle_dump_escape(formula.full_name)}"'
		if formula.args.len > 0 {
			mut sorted_args := formula.args.clone()
			sorted_args.sort()
			line += ', args: [${bundle_dump_quoted(sorted_args)}]'
		}
		if !selection.no_restart && formula.restart_service {
			line += ', restart_service: :changed'
		}
		if link := formula.link {
			line += ', link: ${link}'
		}
		if formula.full_name in input.trusted_formulae {
			line += ', trusted: true'
		}
		lines << line
	}
	return lines.join('\n')
}

fn dump_casks(input BundleDumpInput, describe bool) string {
	mut lines := []string{}
	for cask in input.casks {
		mut line := if describe && cask.description.len > 0 {
			'# ${cask.description}\n'
		} else {
			''
		}
		line += 'cask "${bundle_dump_escape(cask.full_name)}"'
		if cask.config.len > 0 {
			line += ', args: { ${cask.config} }'
		}
		if cask.full_name in input.trusted_casks {
			line += ', trusted: true'
		}
		lines << line
	}
	return lines.join('\n')
}

fn dump_taps(input BundleDumpInput) string {
	dumped_formulae := input.formulae.filter(it.installed_on_request).map(it.full_name)
	dumped_casks := input.casks.map(it.full_name)
	mut lines := []string{}
	for tap in input.taps {
		mut line := 'tap "${bundle_dump_escape(tap.name)}"'
		if tap.remote.len > 0 && tap.remote != tap.default_remote {
			line += ', "${bundle_dump_escape(tap.remote)}"'
		}
		if tap.explicitly_trusted {
			line += ', trusted: true'
		} else {
			formulae := trusted_tap_items(input.trusted_formulae, tap.name, dumped_formulae)
			casks := trusted_tap_items(input.trusted_casks, tap.name, dumped_casks)
			commands := trusted_tap_items(input.trusted_commands, tap.name, [])
			mut options := []string{}
			if formulae.len > 0 {
				options << 'formulae: [${bundle_dump_quoted(formulae)}]'
			}
			if casks.len > 0 {
				options << 'casks: [${bundle_dump_quoted(casks)}]'
			}
			if commands.len > 0 {
				options << 'commands: [${bundle_dump_quoted(commands)}]'
			}
			if options.len > 0 {
				line += ', trusted: { ${options.join(', ')} }'
			}
		}
		lines << line
	}
	lines.sort()
	return bundle_dump_sorted_unique(lines).join('\n')
}

fn trusted_tap_items(entries []string, tap_name string, dumped_items []string) []string {
	mut items := []string{}
	for entry in entries {
		separator := entry.last_index('/') or { continue }
		reference := entry[..separator]
		item := entry[separator + 1..]
		if reference == tap_name && item.len > 0 && entry !in dumped_items {
			items << item
		}
	}
	items.sort()
	return bundle_dump_sorted_unique(items)
}

fn bundle_dump_escape(value string) string {
	return value.replace('\\', '\\\\').replace('"', '\\"')
}

fn bundle_dump_quoted(values []string) string {
	mut quoted := []string{cap: values.len}
	for value in values {
		quoted << '"${bundle_dump_escape(value)}"'
	}
	return quoted.join(', ')
}

fn default_bundle_brewfile_path_config(global bool, file ?string) BundleBrewfilePathConfig {
	working_directory := ruby.current_directory()
	home := if configured := ruby.environment_value_opt('HOME') {
		configured
	} else {
		working_directory
	}
	user_config_home := ruby.environment_value('HOMEBREW_USER_CONFIG_HOME')
	home_brewfile := ruby.join_path(home, '.Brewfile')
	user_config_brewfile := ruby.join_path(user_config_home, 'Brewfile')
	return BundleBrewfilePathConfig{
		global: global
		file: file
		working_directory: working_directory
		home_directory: home
		env_bundle_file_global: ruby.environment_value('HOMEBREW_BUNDLE_FILE_GLOBAL')
		env_bundle_file: ruby.environment_value('HOMEBREW_BUNDLE_FILE')
		user_config_home: user_config_home
		user_config_home_exists: user_config_home.len > 0 && ruby.is_dir(user_config_home)
		user_config_brewfile_exists: user_config_home.len > 0 && ruby.path_exists(user_config_brewfile)
		home_brewfile_exists: ruby.path_exists(home_brewfile)
	}
}

fn bundle_dump_input_from_value(value ruby.Value) BundleDumpInput {
	formulae_value := value.map_data['formulae'] or { ruby.array_value([]) }
	casks_value := value.map_data['casks'] or { ruby.array_value([]) }
	taps_value := value.map_data['taps'] or { ruby.array_value([]) }
	extensions_value := value.map_data['extensions'] or { ruby.array_value([]) }
	trusted_formulae := value.map_data['trusted_formulae'] or { ruby.string_array_value([]) }
	trusted_casks := value.map_data['trusted_casks'] or { ruby.string_array_value([]) }
	trusted_commands := value.map_data['trusted_commands'] or { ruby.string_array_value([]) }
	return BundleDumpInput{
		formulae: formulae_value.array_data.map(bundle_dump_formula_from_value(it))
		casks: casks_value.array_data.map(bundle_dump_cask_from_value(it))
		taps: taps_value.array_data.map(bundle_dump_tap_from_value(it))
		extensions: extensions_value.array_data.map(bundle_dump_section_from_value(it))
		trusted_formulae: trusted_formulae.as_string_array() or { [] }
		trusted_casks: trusted_casks.as_string_array() or { [] }
		trusted_commands: trusted_commands.as_string_array() or { [] }
	}
}

fn bundle_dump_selection_from_value(value ruby.Value) BundleDumpSelection {
	mut extension_types := map[string]bool{}
	for name, selected in value.map_data {
		extension_types[name] = selected.as_bool() or { selected.as_string() == 'true' }
	}
	return BundleDumpSelection{
		describe: (value.attributes['describe'] or { 'false' }) == 'true'
		no_restart: (value.attributes['no_restart'] or { 'false' }) == 'true'
		formulae: (value.attributes['formulae'] or { 'false' }) == 'true'
		taps: (value.attributes['taps'] or { 'false' }) == 'true'
		casks: (value.attributes['casks'] or { 'false' }) == 'true'
		extension_types: extension_types
	}
}

fn bundle_brewfile_path_config_from_value(value ruby.Value) BundleBrewfilePathConfig {
	file_value := value.attributes['file'] or { '' }
	return BundleBrewfilePathConfig{
		global: (value.attributes['global'] or { 'false' }) == 'true'
		file: if file_value.len > 0 { ?string(file_value) } else { none }
		working_directory: value.attributes['working_directory'] or { ruby.current_directory() }
		home_directory: value.attributes['home_directory'] or { '' }
		env_bundle_file_global: value.attributes['env_bundle_file_global'] or { '' }
		env_bundle_file: value.attributes['env_bundle_file'] or { '' }
		user_config_home: value.attributes['user_config_home'] or { '' }
		user_config_home_exists: (value.attributes['user_config_home_exists'] or { 'false' }) == 'true'
		user_config_brewfile_exists: (value.attributes['user_config_brewfile_exists'] or { 'false' }) == 'true'
		home_brewfile_exists: (value.attributes['home_brewfile_exists'] or { 'false' }) == 'true'
	}
}

fn bundle_dump_formula_value(formula BundleDumpFormula) ruby.Value {
	return ruby.Value{
		type_name: 'BundleDumpFormula'
		string_array_data: formula.args.clone()
		attributes: {
			'full_name':            formula.full_name
			'installed_on_request': formula.installed_on_request.str()
			'description':          formula.description
			'restart_service':      formula.restart_service.str()
			'link':                 if link := formula.link { link.str() } else { '' }
		}
	}
}

fn bundle_dump_formula_from_value(value ruby.Value) BundleDumpFormula {
	link_value := value.attributes['link'] or { '' }
	return BundleDumpFormula{
		full_name: value.attributes['full_name'] or { value.as_string() }
		installed_on_request: (value.attributes['installed_on_request'] or { 'false' }) == 'true'
		description: value.attributes['description'] or { '' }
		args: value.string_array_data.clone()
		restart_service: (value.attributes['restart_service'] or { 'false' }) == 'true'
		link: if link_value.len > 0 { ?bool(link_value == 'true') } else { none }
	}
}

fn bundle_dump_cask_value(cask BundleDumpCask) ruby.Value {
	return ruby.structured_value('BundleDumpCask', cask.full_name, {
		'full_name':   cask.full_name
		'description': cask.description
		'config':      cask.config
	})
}

fn bundle_dump_cask_from_value(value ruby.Value) BundleDumpCask {
	return BundleDumpCask{
		full_name: value.attributes['full_name'] or { value.as_string() }
		description: value.attributes['description'] or { '' }
		config: value.attributes['config'] or { '' }
	}
}

fn bundle_dump_tap_value(tap BundleDumpTap) ruby.Value {
	return ruby.structured_value('BundleDumpTap', tap.name, {
		'name':               tap.name
		'remote':             tap.remote
		'default_remote':     tap.default_remote
		'explicitly_trusted': tap.explicitly_trusted.str()
	})
}

fn bundle_dump_tap_from_value(value ruby.Value) BundleDumpTap {
	return BundleDumpTap{
		name: value.attributes['name'] or { value.as_string() }
		remote: value.attributes['remote'] or { '' }
		default_remote: value.attributes['default_remote'] or { '' }
		explicitly_trusted: (value.attributes['explicitly_trusted'] or { 'false' }) == 'true'
	}
}

fn bundle_dump_section_value(section BundleDumpSection) ruby.Value {
	return ruby.structured_value('BundleDumpSection', section.output, {
		'type_name':      section.type_name
		'output':         section.output
		'dump_supported': section.dump_supported.str()
	})
}

fn bundle_dump_section_from_value(value ruby.Value) BundleDumpSection {
	return BundleDumpSection{
		type_name: value.attributes['type_name'] or { '' }
		output: value.attributes['output'] or { value.as_string() }
		dump_supported: (value.attributes['dump_supported'] or { 'true' }) == 'true'
	}
}

fn bundle_dump_sorted_unique(values []string) []string {
	mut result := []string{}
	for value in values {
		if result.len == 0 || result.last() != value {
			result << value
		}
	}
	return result
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "fileutils"
// 5: require "bundle/dsl"
// 6: require "bundle/extensions"
// 7: require "bundle/package_types"
// 8:
// 9: module Homebrew
// 10:   module Bundle
// 11:     module Dumper
// 12:       sig { params(brewfile_path: Pathname, force: T::Boolean).returns(T::Boolean) }
// 13:       private_class_method def self.can_write_to_brewfile?(brewfile_path, force: false)
// 14:         raise "#{brewfile_path} already exists" if should_not_write_file?(brewfile_path, overwrite: force)
// 15:
// 16:         true
// 17:       end
// 18:
// 19:       sig {
// 20:         params(
// 21:           describe:        T::Boolean,
// 22:           no_restart:      T::Boolean,
// 23:           formulae:        T::Boolean,
// 24:           taps:            T::Boolean,
// 25:           casks:           T::Boolean,
// 26:           extension_types: Homebrew::Bundle::ExtensionTypes,
// 27:         ).returns(String)
// 28:       }
// 29:       def self.build_brewfile(describe:, no_restart:, formulae:, taps:, casks:, extension_types: {})
// 30:         selected_package_types = extension_types.dup
// 31:         selected_package_types[:tap] = taps
// 32:         selected_package_types[:brew] = formulae
// 33:         selected_package_types[:cask] = casks
// 34:         dumped_formulae = if formulae
// 35:           Homebrew::Bundle::Brew.formulae.filter_map { |f| f[:full_name] if f[:installed_on_request?] }
// 36:         else
// 37:           []
// 38:         end
// 39:         dumped_casks = if casks
// 40:           Homebrew::Bundle::Cask.casks.map(&:full_name)
// 41:         else
// 42:           []
// 43:         end
// 44:         content = []
// 45:         Homebrew::Bundle.dump_package_types.select(&:dump_supported?).each do |package_type|
// 46:           next unless selected_package_types.fetch(package_type.type, false)
// 47:
// 48:           content << if package_type == Homebrew::Bundle::Tap
// 49:             Homebrew::Bundle::Tap.dump(dumped_formulae:, dumped_casks:)
// 50:           else
// 51:             package_type.dump_output(describe:, no_restart:)
// 52:           end
// 53:         end
// 54:         "#{content.reject(&:empty?).join("\n")}\n"
// 55:       end
// 56:
// 57:       sig {
// 58:         params(
// 59:           global:          T::Boolean,
// 60:           file:            T.nilable(String),
// 61:           describe:        T::Boolean,
// 62:           force:           T::Boolean,
// 63:           no_restart:      T::Boolean,
// 64:           formulae:        T::Boolean,
// 65:           taps:            T::Boolean,
// 66:           casks:           T::Boolean,
// 67:           extension_types: Homebrew::Bundle::ExtensionTypes,
// 68:         ).void
// 69:       }
// 70:       def self.dump_brewfile(global:, file:, describe:, force:, no_restart:, formulae:, taps:, casks:,
// 71:                              extension_types: {})
// 72:         path = brewfile_path(global:, file:)
// 73:         can_write_to_brewfile?(path, force:)
// 74:         content = build_brewfile(
// 75:           describe:, no_restart:, taps:, formulae:, casks:, extension_types:,
// 76:         )
// 77:         write_file path, content
// 78:       end
// 79:
// 80:       sig { params(global: T::Boolean, file: T.nilable(String)).returns(Pathname) }
// 81:       def self.brewfile_path(global: false, file: nil)
// 82:         require "bundle/brewfile"
// 83:         Brewfile.path(dash_writes_to_stdout: true, global:, file:)
// 84:       end
// 85:
// 86:       sig { params(file: Pathname, overwrite: T::Boolean).returns(T::Boolean) }
// 87:       private_class_method def self.should_not_write_file?(file, overwrite: false)
// 88:         file.exist? && !overwrite && file.to_s != "/dev/stdout"
// 89:       end
// 90:
// 91:       sig { params(file: Pathname, content: String).void }
// 92:       def self.write_file(file, content)
// 93:         Bundle.exchange_uid_if_needed! do
// 94:           file.open("w") { |io| io.write content }
// 95:         end
// 96:       end
// 97:     end
// 98:   end
// 99: end
