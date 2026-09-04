module extensions

import ruby
import os

// Translated from Homebrew/brew `bundle/extensions/krew.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct KrewState {
pub mut:
	executable                string
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

pub fn new_krew_state() &KrewState {
	return &KrewState{
		last_environment: map[string]string{}
	}
}

pub fn krew_definition() ExtensionDefinition {
	return ExtensionDefinition{
		class_name: 'Homebrew::Bundle::Krew'
		type_name: 'krew'
		banner_name: 'Krew plugins'
		check_label: 'Krew Plugin'
		cleanup_heading: 'Krew plugins'
	}
}

pub fn krew_parse_plugin_list(output string) []string {
	mut plugins := []string{}
	for line in output.split_into_lines() {
		fields := line.trim_space().fields()
		if fields.len == 0 || fields[0] in plugins {
			continue
		}
		plugins << fields[0]
	}
	return plugins
}

pub fn krew_environment(executable string, original_path string) map[string]string {
	return {
		'PATH': '${os.dir(executable)}:${original_path}'
	}
}

pub fn krew_dump(packages []string) string {
	return packages.map(extension_dump_entry(krew_definition(), ExtensionPackage{
		name: it
	})).join('\n')
}

pub fn krew_cleanup_items(entries []ExtensionEntry, executable string, packages []string) []string {
	if executable == '' {
		return []
	}
	mut kept := []string{}
	for entry in entries {
		if entry.entry_type == 'krew' {
			kept << entry.name
		}
	}
	if kept.len == 0 {
		return []
	}
	return packages.filter(it !in kept)
}

pub fn krew_preinstall(executable string, installed []string, name string) !bool {
	if executable == '' {
		return error('Unable to install ${name} krew plugin. krew installation failed.')
	}
	return name !in installed
}

pub fn (mut state KrewState) reset() {
	state.packages = []
	state.packages_loaded = false
	state.installed_packages = []
	state.installed_packages_loaded = false
	state.executable = ''
}

pub fn (mut state KrewState) discover_packages() []string {
	if state.packages_loaded {
		return state.packages.clone()
	}
	state.packages = if state.executable == '' {
		[]
	} else {
		state.last_environment = krew_environment(state.executable, state.original_path)
		krew_parse_plugin_list(state.list_output)
	}
	state.packages_loaded = true
	return state.packages.clone()
}

pub fn (mut state KrewState) discover_installed_packages() []string {
	if state.installed_packages_loaded {
		return state.installed_packages.clone()
	}
	state.installed_packages = state.discover_packages()
	state.installed_packages_loaded = true
	return state.installed_packages.clone()
}

pub fn (mut state KrewState) install_package(name string, result bool) !bool {
	if state.executable == '' {
		return error('krew is not installed')
	}
	state.last_environment = krew_environment(state.executable, state.original_path)
	state.commands << [state.executable, 'install', name]
	return result
}

pub fn (mut state KrewState) install(name string, preinstall bool, verbose bool, result bool) !bool {
	if !preinstall {
		return true
	}
	if verbose {
		state.output << 'Installing ${name} krew plugin. It is not currently installed.'
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

pub fn (mut state KrewState) uninstall(name string, executable string) {
	state.last_environment = krew_environment(executable, state.original_path)
	state.commands << [executable, 'uninstall', name]
}

pub fn (mut state KrewState) cleanup(items []string) {
	if state.executable == '' {
		return
	}
	for item in items {
		state.uninstall(item, state.executable)
	}
	suffix := if items.len == 1 { '' } else { 's' }
	state.output << 'Uninstalled ${items.len} ${krew_definition().banner_name}${suffix}'
}

fn krew_state_value(state &KrewState) ruby.Value {
	return ruby.structured_value('Homebrew::Bundle::Krew', '', {
		'krew_state_address': u64(voidptr(state)).str()
	})
}

fn krew_state_from_args(args []ruby.Value, method string) &KrewState {
	if args.len == 0 || 'krew_state_address' !in args[0].attributes {
		panic('Krew.${method} requires translated Krew state')
	}
	return unsafe { &KrewState(voidptr(args[0].attributes['krew_state_address'].u64())) }
}

pub fn krew_state_boundary(state &KrewState) ruby.Value {
	return krew_state_value(state)
}

// Ruby method `type = :krew` at line 11.
pub fn ruby_krew_l11_d1_type(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Symbol', 'krew')
}

// Ruby method `check_label = "Krew Plugin"` at line 14.
pub fn ruby_krew_l14_d2_check_label(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(krew_definition().check_label)
}

// Ruby method `banner_name = "Krew plugins"` at line 17.
pub fn ruby_krew_l17_d3_banner_name(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(krew_definition().banner_name)
}

// Ruby method `reset!` at line 20.
pub fn ruby_krew_l20_d4_reset(args ...ruby.Value) ruby.Value {
	mut state := krew_state_from_args(args, 'reset!')
	state.reset()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `cleanup_heading` at line 27.
pub fn ruby_krew_l27_d5_cleanup_heading(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(krew_definition().cleanup_heading or { '' })
}

// Ruby method `package_manager_executable` at line 32.
pub fn ruby_krew_l32_d6_package_manager_executable(args ...ruby.Value) ruby.Value {
	state := krew_state_from_args(args, 'package_manager_executable')
	return if state.executable == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.object_value('Pathname', state.executable)
	}
}

// Ruby method `packages` at line 37.
pub fn ruby_krew_l37_d7_packages(args ...ruby.Value) ruby.Value {
	mut state := krew_state_from_args(args, 'packages')
	return ruby.string_array_value(state.discover_packages())
}

// Ruby method `install_package!(name, with: nil, verbose: false)` at line 57.
pub fn ruby_krew_l57_d8_install_package(args ...ruby.Value) ruby.Value {
	mut state := krew_state_from_args(args, 'install_package!')
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'name is required')
	}
	result := if args.len > 4 { args[4].bool_data } else { false }
	return ruby.bool_value(state.install_package(args[1].as_string(), result) or {
		return ruby.object_value('RuntimeError', err.msg())
	})
}

// Ruby method `installed_packages` at line 66.
pub fn ruby_krew_l66_d9_installed_packages(args ...ruby.Value) ruby.Value {
	mut state := krew_state_from_args(args, 'installed_packages')
	return ruby.string_array_value(state.discover_installed_packages())
}

// Ruby method `parse_plugin_list(output)` at line 74.
pub fn ruby_krew_l74_d10_parse_plugin_list(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(krew_parse_plugin_list(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `uninstall_package!(name, executable: Pathname.new(""))` at line 86.
pub fn ruby_krew_l86_d11_uninstall_package(args ...ruby.Value) ruby.Value {
	mut state := krew_state_from_args(args, 'uninstall_package!')
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'name is required')
	}
	executable := if args.len > 2 { args[2].as_string() } else { '' }
	state.uninstall(args[1].as_string(), executable)
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/extensions/extension"
// 5:
// 6: module Homebrew
// 7:   module Bundle
// 8:     class Krew < Extension
// 9:       class << self
// 10:         sig { override.returns(Symbol) }
// 11:         def type = :krew
// 12:
// 13:         sig { override.returns(String) }
// 14:         def check_label = "Krew Plugin"
// 15:
// 16:         sig { override.returns(String) }
// 17:         def banner_name = "Krew plugins"
// 18:
// 19:         sig { override.void }
// 20:         def reset!
// 21:           @packages = T.let(nil, T.nilable(T::Array[String]))
// 22:           @installed_packages = T.let(nil, T.nilable(T::Array[String]))
// 23:           @package_manager_executable = T.let(nil, T.nilable(Pathname))
// 24:         end
// 25:
// 26:         sig { override.returns(T.nilable(String)) }
// 27:         def cleanup_heading
// 28:           banner_name
// 29:         end
// 30:
// 31:         sig { override.returns(T.nilable(Pathname)) }
// 32:         def package_manager_executable
// 33:           @package_manager_executable ||= T.let(which("kubectl-krew", ORIGINAL_PATHS), T.nilable(Pathname))
// 34:         end
// 35:
// 36:         sig { override.returns(T::Array[String]) }
// 37:         def packages
// 38:           packages = @packages
// 39:           return packages if packages
// 40:
// 41:           @packages = if package_manager_installed?
// 42:             with_package_manager_env do |krew|
// 43:               parse_plugin_list(`#{krew} list 2>/dev/null`)
// 44:             end
// 45:           else
// 46:             []
// 47:           end
// 48:         end
// 49:
// 50:         sig {
// 51:           override.params(
// 52:             name:    String,
// 53:             with:    T.nilable(T::Array[String]),
// 54:             verbose: T::Boolean,
// 55:           ).returns(T::Boolean)
// 56:         }
// 57:         def install_package!(name, with: nil, verbose: false)
// 58:           _ = with
// 59:
// 60:           with_package_manager_env do |krew|
// 61:             Bundle.system(krew.to_s, "install", name, verbose:)
// 62:           end
// 63:         end
// 64:
// 65:         sig { override.returns(T::Array[String]) }
// 66:         def installed_packages
// 67:           installed_packages = @installed_packages
// 68:           return installed_packages if installed_packages
// 69:
// 70:           @installed_packages = packages.dup
// 71:         end
// 72:
// 73:         sig { params(output: String).returns(T::Array[String]) }
// 74:         def parse_plugin_list(output)
// 75:           output.lines.filter_map do |line|
// 76:             line = line.strip
// 77:             next if line.empty?
// 78:
// 79:             name = line.split(/\s+/).first
// 80:             name.presence
// 81:           end.uniq
// 82:         end
// 83:         private :parse_plugin_list
// 84:
// 85:         sig { override.params(name: String, executable: Pathname).void }
// 86:         def uninstall_package!(name, executable: Pathname.new(""))
// 87:           Bundle.system(executable.to_s, "uninstall", name, verbose: false)
// 88:         end
// 89:       end
// 90:     end
// 91:   end
// 92: end
