module bundle

import ruby

// Translated from Homebrew/brew `bundle/brewfile.rb`.
pub type BrewfileReader = fn (path string) !string

pub fn handle_brewfile_file_value(filename string, dash_writes_to_stdout bool) string {
	if filename != '-' {
		return filename
	}
	return if dash_writes_to_stdout { '/dev/stdout' } else { '/dev/stdin' }
}

pub fn resolve_bundle_brewfile_path(config BundleBrewfilePathConfig,
	dash_writes_to_stdout bool) !string {
	mut filename := ''
	if config.global {
		if config.env_bundle_file_global.trim_space() != '' {
			filename = config.env_bundle_file_global
		} else {
			if config.env_bundle_file.trim_space() != '' {
				return error("'HOMEBREW_BUNDLE_FILE' cannot be specified with '--global'")
			}
			home_brewfile := ruby.join_path(config.home_directory, '.Brewfile')
			user_config_brewfile := ruby.join_path(config.user_config_home, 'Brewfile')
			filename = if config.user_config_home.trim_space() != '' && config.user_config_home_exists && (config.user_config_brewfile_exists || !config.home_brewfile_exists) {
				user_config_brewfile
			} else {
				home_brewfile
			}
		}
	} else if requested_file := config.file {
		if requested_file.trim_space() != '' {
			filename = handle_brewfile_file_value(requested_file, dash_writes_to_stdout)
		}
	}
	if filename == '' {
		filename = if config.env_bundle_file.trim_space() != '' {
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

pub fn read_bundle_brewfile(config BundleBrewfilePathConfig, reader BrewfileReader) !BundleDsl {
	path := resolve_bundle_brewfile_path(config, false)!
	input := reader(path) or { return error('No Brewfile found') }
	return parse_bundle_dsl(path, input)!
}

pub fn real_brewfile_reader(path string) !string {
	return ruby.read_file(path)!
}

pub fn current_bundle_brewfile_path_config(global bool, file ?string) BundleBrewfilePathConfig {
	working_directory := ruby.current_directory()
	home_directory := ruby.environment_value_opt('HOME') or { working_directory }
	user_config_home := ruby.environment_value('HOMEBREW_USER_CONFIG_HOME')
	home_brewfile := ruby.join_path(home_directory, '.Brewfile')
	user_config_brewfile := ruby.join_path(user_config_home, 'Brewfile')
	return BundleBrewfilePathConfig{
		global: global
		file: file
		working_directory: working_directory
		home_directory: home_directory
		env_bundle_file_global: ruby.environment_value('HOMEBREW_BUNDLE_FILE_GLOBAL')
		env_bundle_file: ruby.environment_value('HOMEBREW_BUNDLE_FILE')
		user_config_home: user_config_home
		user_config_home_exists: user_config_home != '' && ruby.is_dir(user_config_home)
		user_config_brewfile_exists: user_config_home != '' && ruby.path_exists(user_config_brewfile)
		home_brewfile_exists: ruby.path_exists(home_brewfile)
	}
}

fn brewfile_path_config_from_value(value ruby.Value) BundleBrewfilePathConfig {
	file_value := value.attributes['file'] or { '' }
	return BundleBrewfilePathConfig{
		global: (value.attributes['global'] or { 'false' }) == 'true'
		file: if file_value != '' { ?string(file_value) } else { none }
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

fn brewfile_boundary_config(args []ruby.Value, config_index int) BundleBrewfilePathConfig {
	if config_index < args.len && args[config_index].type_name == 'BundleBrewfilePathConfig' {
		return brewfile_path_config_from_value(args[config_index])
	}
	global := if config_index < args.len {
		args[config_index].as_bool() or { false }
	} else {
		false
	}
	file := if config_index + 1 < args.len && args[config_index + 1].type_name !in [
		'Nil',
		'NilClass',
	] {
		?string(args[config_index + 1].as_string())
	} else {
		none
	}
	return current_bundle_brewfile_path_config(global, file)
}
