module bundle

import brew_runtime

// Translated from Homebrew/brew `bundle/brewfile.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.path(dash_writes_to_stdout: false, global: false, file: nil)` at line 16.
pub fn ruby_brewfile_l16_d1_self_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.path', ...args)
}

// Ruby method `self.read(global: false, file: nil)` at line 51.
pub fn ruby_brewfile_l51_d2_self_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.read', ...args)
}

// Ruby method `self.handle_file_value(filename, dash_writes_to_stdout)` at line 63.
pub fn ruby_brewfile_l63_d3_self_handle_file_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.handle_file_value', ...args)
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
