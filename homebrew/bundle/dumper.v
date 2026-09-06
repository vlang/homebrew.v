module bundle

import ruby

// Translated from Homebrew/brew `bundle/dumper.rb`.

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

pub type BrewfileWriter = fn (path string, content string) !

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

fn bundle_dump_sorted_unique(values []string) []string {
	mut result := []string{}
	for value in values {
		if result.len == 0 || result.last() != value {
			result << value
		}
	}
	return result
}
