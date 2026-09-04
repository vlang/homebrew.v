module bundle

import ruby

// Translated from Homebrew/brew `bundle/brewfile.rb`.
// The original source is retained below until every stub has a typed V body.
pub type BrewfileReader = fn(path string) !string

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

// Ruby method `self.path(dash_writes_to_stdout: false, global: false, file: nil)` at line 16.
pub fn ruby_brewfile_l16_d1_self_path(args ...ruby.Value) ruby.Value {
	if args.len > 0 && args[0].type_name == 'BundleBrewfilePathConfig' {
		config := brewfile_boundary_config(args, 0)
		dash_writes_to_stdout := if args.len > 1 { args[1].as_bool() or { false } } else { false }
		path := resolve_bundle_brewfile_path(config, dash_writes_to_stdout) or {
			return ruby.object_value('RuntimeError', err.msg())
		}
		return ruby.object_value('Pathname', path)
	}
	dash_writes_to_stdout := if args.len > 0 { args[0].as_bool() or { false } } else { false }
	config := brewfile_boundary_config(args, 1)
	path := resolve_bundle_brewfile_path(config, dash_writes_to_stdout) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return ruby.object_value('Pathname', path)
}

// Ruby method `self.read(global: false, file: nil)` at line 51.
pub fn ruby_brewfile_l51_d2_self_read(args ...ruby.Value) ruby.Value {
	config := brewfile_boundary_config(args, 0)
	dsl := read_bundle_brewfile(config, real_brewfile_reader) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return bundle_dsl_value(dsl)
}

// Ruby method `self.handle_file_value(filename, dash_writes_to_stdout)` at line 63.
pub fn ruby_brewfile_l63_d3_self_handle_file_value(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'filename is required')
	}
	dash_writes_to_stdout := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	return ruby.string_value(handle_brewfile_file_value(args[0].as_string(), dash_writes_to_stdout))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/dsl"
// 5:
// 6: module Homebrew
// 7:   module Bundle
// 8:     module Brewfile
// 9:       sig {
// 10:         params(
// 11:           dash_writes_to_stdout: T::Boolean,
// 12:           global:                T::Boolean,
// 13:           file:                  T.nilable(String),
// 14:         ).returns(Pathname)
// 15:       }
// 16:       def self.path(dash_writes_to_stdout: false, global: false, file: nil)
// 17:         env_bundle_file_global = ENV.fetch("HOMEBREW_BUNDLE_FILE_GLOBAL", nil)
// 18:         env_bundle_file = ENV.fetch("HOMEBREW_BUNDLE_FILE", nil)
// 19:         user_config_home = ENV.fetch("HOMEBREW_USER_CONFIG_HOME", nil)
// 20:
// 21:         filename = if global
// 22:           if env_bundle_file_global.present?
// 23:             env_bundle_file_global
// 24:           else
// 25:             raise "'HOMEBREW_BUNDLE_FILE' cannot be specified with '--global'" if env_bundle_file.present?
// 26:
// 27:             home_brewfile = Bundle.exchange_uid_if_needed! do
// 28:               "#{Dir.home}/.Brewfile"
// 29:             end
// 30:             user_config_home_brewfile = "#{user_config_home}/Brewfile"
// 31:
// 32:             if user_config_home.present? && Dir.exist?(user_config_home) &&
// 33:                (File.exist?(user_config_home_brewfile) || !File.exist?(home_brewfile))
// 34:               user_config_home_brewfile
// 35:             else
// 36:               home_brewfile
// 37:             end
// 38:           end
// 39:         elsif file.present?
// 40:           handle_file_value(file, dash_writes_to_stdout)
// 41:         elsif env_bundle_file.present?
// 42:           env_bundle_file
// 43:         else
// 44:           "Brewfile"
// 45:         end
// 46:
// 47:         Pathname.new(filename).expand_path(Dir.pwd)
// 48:       end
// 49:
// 50:       sig { params(global: T::Boolean, file: T.nilable(String)).returns(Dsl) }
// 51:       def self.read(global: false, file: nil)
// 52:         Homebrew::Bundle::Dsl.new(Brewfile.path(global:, file:))
// 53:       rescue Errno::ENOENT
// 54:         raise "No Brewfile found"
// 55:       end
// 56:
// 57:       sig {
// 58:         params(
// 59:           filename:              String,
// 60:           dash_writes_to_stdout: T::Boolean,
// 61:         ).returns(String)
// 62:       }
// 63:       private_class_method def self.handle_file_value(filename, dash_writes_to_stdout)
// 64:         if filename != "-"
// 65:           filename
// 66:         elsif dash_writes_to_stdout
// 67:           "/dev/stdout"
// 68:         else
// 69:           "/dev/stdin"
// 70:         end
// 71:       end
// 72:     end
// 73:   end
// 74: end
