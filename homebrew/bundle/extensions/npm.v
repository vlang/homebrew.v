module extensions

import ruby
import homebrew.language
import os
import x.json2

// Translated from Homebrew/brew `bundle/extensions/npm.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct NpmState {
pub mut:
	executable                string
	executable_exists         bool
	cache_dir                 string
	original_path             string
	list_output               string
	packages                  []string
	packages_loaded           bool
	installed_packages        []string
	installed_packages_loaded bool
	last_environment          map[string]string
	commands                  [][]string
	output                    []string
}

pub fn new_npm_state() &NpmState {
	return &NpmState{
		last_environment: map[string]string{}
	}
}

pub fn npm_definition() ExtensionDefinition {
	return ExtensionDefinition{
		class_name: 'Homebrew::Bundle::Npm'
		type_name: 'npm'
		banner_name: 'npm packages'
		check_label: 'npm Package'
		cleanup_heading: 'npm packages'
	}
}

pub fn npm_parse_package_list(output string) []string {
	if output.trim_space() == '' {
		return []
	}
	decoded := json2.decode[json2.Any](output) or { return [] }
	if decoded !is map[string]json2.Any {
		return []
	}
	root := decoded as map[string]json2.Any
	dependencies_value := root['dependencies'] or { return [] }
	if dependencies_value !is map[string]json2.Any {
		return []
	}
	mut packages := []string{}
	for name in (dependencies_value as map[string]json2.Any).keys() {
		if name != 'npm' {
			packages << name
		}
	}
	return packages
}

pub fn npm_listing_environment(executable string, original_path string) map[string]string {
	return {
		'PATH': '${os.dir(executable)}:${original_path}'
	}
}

pub fn npm_install_command(executable string, cache_dir string, name string) []string {
	mut command := [executable, 'install']
	command << language.npm_install_security_args(cache_dir, true)
	command << '-g'
	command << name
	return command
}

pub fn npm_uninstall_command(executable string, name string) []string {
	return [executable, 'uninstall', '-g', name]
}

pub fn npm_dump(packages []string) string {
	return packages.map(extension_dump_entry(npm_definition(), ExtensionPackage{
		name: it
	})).join('\n')
}

pub fn npm_cleanup_items(entries []ExtensionEntry, executable string, packages []string) []string {
	if executable == '' {
		return []
	}
	mut kept := []string{}
	for entry in entries {
		if entry.entry_type == 'npm' {
			kept << entry.name
		}
	}
	if kept.len == 0 {
		return []
	}
	return packages.filter(it !in kept)
}

pub fn npm_preinstall(executable string, installed []string, name string) !bool {
	if executable == '' {
		return error('Unable to install ${name} npm package. node installation failed.')
	}
	return name !in installed
}

pub fn (mut state NpmState) reset() {
	state.packages = []
	state.packages_loaded = false
	state.installed_packages = []
	state.installed_packages_loaded = false
}

pub fn (mut state NpmState) discover_packages() []string {
	if state.packages_loaded {
		return state.packages.clone()
	}
	state.packages = if state.executable == '' || (state.executable.starts_with('/') && !state.executable_exists && !os.exists(state.executable)) {
		[]
	} else {
		state.last_environment = npm_listing_environment(state.executable, state.original_path)
		npm_parse_package_list(state.list_output)
	}
	state.packages_loaded = true
	return state.packages.clone()
}

pub fn (mut state NpmState) discover_installed_packages() []string {
	if state.installed_packages_loaded {
		return state.installed_packages.clone()
	}
	state.installed_packages = state.discover_packages()
	state.installed_packages_loaded = true
	return state.installed_packages.clone()
}

pub fn (mut state NpmState) install_package(name string, result bool) !bool {
	if state.executable == '' {
		return error('npm is not installed')
	}
	state.commands << npm_install_command(state.executable, state.cache_dir, name)
	return result
}

pub fn (mut state NpmState) install(name string, preinstall bool, verbose bool, result bool) !bool {
	if !preinstall {
		return true
	}
	if verbose {
		state.output << 'Installing ${name} npm package. It is not currently installed.'
	}
	if !state.install_package(name, result)! {
		return false
	}
	if name !in state.discover_installed_packages() {
		state.installed_packages << name
	}
	if state.packages_loaded {
		if name !in state.packages {
			state.packages << name
		}
	} else {
		state.packages = [name]
		state.packages_loaded = true
	}
	return true
}

pub fn (mut state NpmState) uninstall(name string, executable string) {
	state.commands << npm_uninstall_command(executable, name)
}

fn npm_state_value(state &NpmState) ruby.Value {
	return ruby.structured_value('Homebrew::Bundle::Npm', '', {
		'npm_state_address': u64(voidptr(state)).str()
	})
}

fn npm_state_from_args(args []ruby.Value, method string) &NpmState {
	if args.len == 0 || 'npm_state_address' !in args[0].attributes {
		panic('Npm.${method} requires translated Npm state')
	}
	return unsafe { &NpmState(voidptr(args[0].attributes['npm_state_address'].u64())) }
}

pub fn npm_state_boundary(state &NpmState) ruby.Value {
	return npm_state_value(state)
}

// Ruby method `type = :npm` at line 12.
pub fn ruby_npm_l12_d1_type(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Symbol', 'npm')
}

// Ruby method `check_label = "npm Package"` at line 15.
pub fn ruby_npm_l15_d2_check_label(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(npm_definition().check_label)
}

// Ruby method `banner_name = "npm packages"` at line 18.
pub fn ruby_npm_l18_d3_banner_name(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(npm_definition().banner_name)
}

// Ruby method `reset!` at line 21.
pub fn ruby_npm_l21_d4_reset(args ...ruby.Value) ruby.Value {
	mut state := npm_state_from_args(args, 'reset!')
	state.reset()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `cleanup_heading` at line 27.
pub fn ruby_npm_l27_d5_cleanup_heading(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(npm_definition().cleanup_heading or { '' })
}

// Ruby method `package_manager_name` at line 32.
pub fn ruby_npm_l32_d6_package_manager_name(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('node')
}

// Ruby method `package_manager_executable` at line 37.
pub fn ruby_npm_l37_d7_package_manager_executable(args ...ruby.Value) ruby.Value {
	state := npm_state_from_args(args, 'package_manager_executable')
	return if state.executable == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.object_value('Pathname', state.executable)
	}
}

// Ruby method `packages` at line 42.
pub fn ruby_npm_l42_d8_packages(args ...ruby.Value) ruby.Value {
	mut state := npm_state_from_args(args, 'packages')
	return ruby.string_array_value(state.discover_packages())
}

// Ruby method `install_package!(name, with: nil, verbose: false)` at line 64.
pub fn ruby_npm_l64_d9_install_package(args ...ruby.Value) ruby.Value {
	mut state := npm_state_from_args(args, 'install_package!')
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'name is required')
	}
	result := if args.len > 4 { args[4].bool_data } else { false }
	return ruby.bool_value(state.install_package(args[1].as_string(), result) or {
		return ruby.object_value('RuntimeError', err.msg())
	})
}

// Ruby method `installed_packages` at line 73.
pub fn ruby_npm_l73_d10_installed_packages(args ...ruby.Value) ruby.Value {
	mut state := npm_state_from_args(args, 'installed_packages')
	return ruby.string_array_value(state.discover_installed_packages())
}

// Ruby method `uninstall_package!(name, executable: Pathname.new(""))` at line 81.
pub fn ruby_npm_l81_d11_uninstall_package(args ...ruby.Value) ruby.Value {
	mut state := npm_state_from_args(args, 'uninstall_package!')
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'name is required')
	}
	executable := if args.len > 2 { args[2].as_string() } else { '' }
	state.uninstall(args[1].as_string(), executable)
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `parse_package_list(output)` at line 86.
pub fn ruby_npm_l86_d12_parse_package_list(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(npm_parse_package_list(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/extensions/extension"
// 5: require "language/node"
// 6:
// 7: module Homebrew
// 8:   module Bundle
// 9:     class Npm < Extension
// 10:       class << self
// 11:         sig { override.returns(Symbol) }
// 12:         def type = :npm
// 13:
// 14:         sig { override.returns(String) }
// 15:         def check_label = "npm Package"
// 16:
// 17:         sig { override.returns(String) }
// 18:         def banner_name = "npm packages"
// 19:
// 20:         sig { override.void }
// 21:         def reset!
// 22:           @packages = T.let(nil, T.nilable(T::Array[String]))
// 23:           @installed_packages = T.let(nil, T.nilable(T::Array[String]))
// 24:         end
// 25:
// 26:         sig { override.returns(T.nilable(String)) }
// 27:         def cleanup_heading
// 28:           banner_name
// 29:         end
// 30:
// 31:         sig { override.returns(String) }
// 32:         def package_manager_name
// 33:           "node"
// 34:         end
// 35:
// 36:         sig { override.returns(T.nilable(Pathname)) }
// 37:         def package_manager_executable
// 38:           which("npm", ORIGINAL_PATHS)
// 39:         end
// 40:
// 41:         sig { override.returns(T::Array[String]) }
// 42:         def packages
// 43:           packages = @packages
// 44:           return packages if packages
// 45:
// 46:           @packages = if (npm = package_manager_executable) &&
// 47:                          (!npm.to_s.start_with?("/") || npm.exist?)
// 48:             with_env(package_manager_env(npm)) do
// 49:               parse_package_list(`#{npm} list -g --depth=0 --json 2>/dev/null`)
// 50:             end
// 51:           end
// 52:           return [] if @packages.nil?
// 53:
// 54:           @packages
// 55:         end
// 56:
// 57:         sig {
// 58:           override.params(
// 59:             name:    String,
// 60:             with:    T.nilable(T::Array[String]),
// 61:             verbose: T::Boolean,
// 62:           ).returns(T::Boolean)
// 63:         }
// 64:         def install_package!(name, with: nil, verbose: false)
// 65:           _ = with
// 66:
// 67:           npm = package_manager_executable!
// 68:
// 69:           Bundle.system(npm.to_s, "install", *Language::Node.npm_install_security_args, "-g", name, verbose:)
// 70:         end
// 71:
// 72:         sig { override.returns(T::Array[String]) }
// 73:         def installed_packages
// 74:           installed_packages = @installed_packages
// 75:           return installed_packages if installed_packages
// 76:
// 77:           @installed_packages = packages.dup
// 78:         end
// 79:
// 80:         sig { override.params(name: String, executable: Pathname).void }
// 81:         def uninstall_package!(name, executable: Pathname.new(""))
// 82:           Bundle.system(executable.to_s, "uninstall", "-g", name, verbose: false)
// 83:         end
// 84:
// 85:         sig { params(output: String).returns(T::Array[String]) }
// 86:         def parse_package_list(output)
// 87:           return [] if output.blank?
// 88:
// 89:           json = JSON.parse(output)
// 90:           deps = json.fetch("dependencies", {})
// 91:           deps.keys.reject { |name| name == "npm" }
// 92:         rescue JSON::ParserError
// 93:           []
// 94:         end
// 95:         private :parse_package_list
// 96:       end
// 97:     end
// 98:   end
// 99: end
