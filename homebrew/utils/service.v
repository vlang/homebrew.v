module utils

import brew_runtime
import os

// Translated from Homebrew/brew `utils/service.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct ServiceFormula {
pub:
	plist_name           string
	service_name         string
	launchd_service_path string
	systemd_service_path string
}

pub struct ServiceManagerState {
pub:
	launchctl_path    string
	systemctl_path    string
	launchctl_running bool
	systemctl_active  bool
}

pub fn service_running(formula ServiceFormula, state ServiceManagerState) bool {
	if state.launchctl_path != '' {
		return state.launchctl_running
	}
	if state.systemctl_path != '' {
		return state.systemctl_active
	}
	_ = formula
	return false
}

pub fn service_installed(formula ServiceFormula, state ServiceManagerState) bool {
	return (state.launchctl_path != '' && os.exists(formula.launchd_service_path))
		|| (state.systemctl_path != '' && os.exists(formula.systemd_service_path))
}

pub fn service_executable(name string, generic_os bool, path_environment string) ?string {
	if generic_os {
		return none
	}
	for directory in path_environment.split(os.path_delimiter) {
		if directory == '' {
			continue
		}
		path := os.join_path(directory, name)
		if os.is_file(path) && os.is_executable(path) {
			return path
		}
	}
	return none
}

pub fn systemd_quote(value string) string {
	mut result := '"'
	for character in value.bytes() {
		result += match character {
			7 { r'\a' }
			8 { r'\b' }
			12 { r'\f' }
			10 { r'\n' }
			13 { r'\r' }
			9 { r'\t' }
			11 { r'\v' }
			`\\` { r'\\' }
			`"` { r'\"' }
			else { character.ascii_str() }
		}
	}
	return result + '"'
}

fn service_formula_from_value(value brew_runtime.Value) ServiceFormula {
	return ServiceFormula{
		plist_name: value.attributes['plist_name']
		service_name: value.attributes['service_name']
		launchd_service_path: value.attributes['launchd_service_path']
		systemd_service_path: value.attributes['systemd_service_path']
	}
}

fn service_state_from_value(value brew_runtime.Value) ServiceManagerState {
	return ServiceManagerState{
		launchctl_path: value.attributes['launchctl_path']
		systemctl_path: value.attributes['systemctl_path']
		launchctl_running: value.attributes['launchctl_running'] == 'true'
		systemctl_active: value.attributes['systemctl_active'] == 'true'
	}
}

// Ruby method `self.running?(formula)` at line 11.
pub fn ruby_service_l11_d1_self_running(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(service_running(service_formula_from_value(args[0]), service_state_from_value(args[1])))
}

// Ruby method `self.installed?(formula)` at line 23.
pub fn ruby_service_l23_d2_self_installed(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(service_installed(service_formula_from_value(args[0]), service_state_from_value(args[1])))
}

// Ruby method `self.launchctl` at line 30.
pub fn ruby_service_l30_d3_self_launchctl(args ...brew_runtime.Value) brew_runtime.Value {
	generic_os := args.len > 0 && (args[0].as_bool() or { false })
	path_environment := if args.len > 1 { args[1].as_string() } else { os.getenv('PATH') }
	return if path := service_executable('launchctl', generic_os, path_environment) {
		brew_runtime.object_value('Pathname', path)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby method `self.systemctl` at line 39.
pub fn ruby_service_l39_d4_self_systemctl(args ...brew_runtime.Value) brew_runtime.Value {
	generic_os := args.len > 0 && (args[0].as_bool() or { false })
	path_environment := if args.len > 1 { args[1].as_string() } else { os.getenv('PATH') }
	return if path := service_executable('systemctl', generic_os, path_environment) {
		brew_runtime.object_value('Pathname', path)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby method `self.launchctl?` at line 47.
pub fn ruby_service_l47_d5_self_launchctl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(ruby_service_l30_d3_self_launchctl(...args).type_name == 'Pathname')
}

// Ruby method `self.systemctl?` at line 52.
pub fn ruby_service_l52_d6_self_systemctl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(ruby_service_l39_d4_self_systemctl(...args).type_name == 'Pathname')
}

// Ruby method `self.systemd_quote(str)` at line 59.
pub fn ruby_service_l59_d7_self_systemd_quote(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(systemd_quote(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "services/system"
// 5:
// 6: module Utils
// 7:   # Helpers for `brew services` related code.
// 8:   module Service
// 9:     # Check if a service is running for a specified formula.
// 10:     sig { params(formula: Formula).returns(T::Boolean) }
// 11:     def self.running?(formula)
// 12:       if launchctl?
// 13:         Homebrew::Services::System.launchctl_service_running?(formula.plist_name)
// 14:       elsif systemctl?
// 15:         quiet_system(systemctl, "is-active", "--quiet", formula.service_name)
// 16:       else
// 17:         false
// 18:       end
// 19:     end
// 20:
// 21:     # Check if a service file is installed in the expected location.
// 22:     sig { params(formula: Formula).returns(T::Boolean) }
// 23:     def self.installed?(formula)
// 24:       (launchctl? && formula.launchd_service_path.exist?) ||
// 25:         (systemctl? && formula.systemd_service_path.exist?)
// 26:     end
// 27:
// 28:     # Path to launchctl binary.
// 29:     sig { returns(T.nilable(Pathname)) }
// 30:     def self.launchctl
// 31:       return @launchctl if defined? @launchctl
// 32:       return if ENV["HOMEBREW_TEST_GENERIC_OS"]
// 33:
// 34:       @launchctl = T.let(which("launchctl"), T.nilable(Pathname))
// 35:     end
// 36:
// 37:     # Path to systemctl binary.
// 38:     sig { returns(T.nilable(Pathname)) }
// 39:     def self.systemctl
// 40:       return @systemctl if defined? @systemctl
// 41:       return if ENV["HOMEBREW_TEST_GENERIC_OS"]
// 42:
// 43:       @systemctl = T.let(which("systemctl"), T.nilable(Pathname))
// 44:     end
// 45:
// 46:     sig { returns(T::Boolean) }
// 47:     def self.launchctl?
// 48:       !launchctl.nil?
// 49:     end
// 50:
// 51:     sig { returns(T::Boolean) }
// 52:     def self.systemctl?
// 53:       !systemctl.nil?
// 54:     end
// 55:
// 56:     # Quote a string for use in systemd command lines, e.g., in `ExecStart`.
// 57:     # https://www.freedesktop.org/software/systemd/man/latest/systemd.syntax.html#Quoting
// 58:     sig { params(str: String).returns(String) }
// 59:     def self.systemd_quote(str)
// 60:       result = +"\""
// 61:       # No need to escape single quotes and spaces, as we're always double
// 62:       # quoting the entire string.
// 63:       str.each_char do |char|
// 64:         result << case char
// 65:         when "\a" then "\\a"
// 66:         when "\b" then "\\b"
// 67:         when "\f" then "\\f"
// 68:         when "\n" then "\\n"
// 69:         when "\r" then "\\r"
// 70:         when "\t" then "\\t"
// 71:         when "\v" then "\\v"
// 72:         when "\\" then "\\\\"
// 73:         when "\"" then "\\\""
// 74:         else char
// 75:         end
// 76:       end
// 77:       result << "\""
// 78:       result.freeze
// 79:     end
// 80:   end
// 81: end
