module extensions

import ruby
import os

// Translated from Homebrew/brew `bundle/extensions/go.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct GoState {
pub mut:
	executable                string
	gobin                     string
	gopath                    string
	packages                  []string
	packages_loaded           bool
	installed_packages        []string
	installed_packages_loaded bool
	version_outputs           map[string]string
	output                    []string
	commands                  [][]string
	removed_binaries          []string
}

pub fn new_go_state() &GoState {
	return &GoState{
		version_outputs: map[string]string{}
	}
}

pub fn go_definition() ExtensionDefinition {
	return ExtensionDefinition{
		class_name: 'Homebrew::Bundle::Go'
		type_name: 'go'
		banner_name: 'Go packages'
		check_label: 'Go Package'
		cleanup_heading: 'Go packages'
	}
}

pub fn go_bin_directory(gobin string, gopath string) string {
	return if gobin == '' { os.join_path(gopath, 'bin') } else { gobin }
}

pub fn go_module_path(output string) ?string {
	for line in output.split_into_lines() {
		if !line.trim_space().starts_with('path\t') {
			continue
		}
		parts := line.split('\t')
		if parts.len < 3 {
			return none
		}
		path := parts[2].trim_space()
		if path == '' || path == 'command-line-arguments' {
			return none
		}
		return path
	}
	return none
}

pub fn go_discover_packages(bin_directory string, version_outputs map[string]string) []string {
	if !os.is_dir(bin_directory) {
		return []
	}
	mut packages := []string{}
	mut names := os.ls(bin_directory) or { return [] }
	names.sort()
	for name in names {
		binary := os.join_path(bin_directory, name)
		if !os.is_file(binary) || !os.is_executable(binary) || os.is_link(binary) {
			continue
		}
		output := version_outputs[binary] or { continue }
		package := go_module_path(output) or { continue }
		if package !in packages {
			packages << package
		}
	}
	return packages
}

pub fn go_dump(packages []string) string {
	return packages.map(extension_dump_entry(go_definition(), ExtensionPackage{
		name: it
	})).join('\n')
}

pub fn go_cleanup_items(entries []ExtensionEntry, executable string, packages []string) []string {
	if executable == '' {
		return []
	}
	mut kept := []string{}
	for entry in entries {
		if entry.entry_type == 'go' {
			kept << entry.name
		}
	}
	if kept.len == 0 {
		return []
	}
	return packages.filter(it !in kept)
}

pub fn go_preinstall(executable string, installed []string, name string) !bool {
	if executable == '' {
		return error('Unable to install ${name} go package. go installation failed.')
	}
	return name !in installed
}

pub fn (mut state GoState) reset() {
	state.packages = []
	state.packages_loaded = false
	state.installed_packages = []
	state.installed_packages_loaded = false
}

pub fn (mut state GoState) discover_packages() []string {
	if state.packages_loaded {
		return state.packages.clone()
	}
	state.packages = if state.executable == '' {
		[]
	} else {
		go_discover_packages(go_bin_directory(state.gobin, state.gopath), state.version_outputs)
	}
	state.packages_loaded = true
	return state.packages.clone()
}

pub fn (mut state GoState) discover_installed_packages() []string {
	if state.installed_packages_loaded {
		return state.installed_packages.clone()
	}
	state.installed_packages = state.discover_packages()
	state.installed_packages_loaded = true
	return state.installed_packages.clone()
}

pub fn (mut state GoState) install_package(name string, result bool) !bool {
	if state.executable == '' {
		return error('go is not installed')
	}
	state.commands << [state.executable, 'install', '${name}@latest']
	return result
}

pub fn (mut state GoState) install(name string, preinstall bool, verbose bool, result bool) !bool {
	if !preinstall {
		return true
	}
	if verbose {
		state.output << 'Installing ${name} go package. It is not currently installed.'
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

pub fn (mut state GoState) cleanup(items []string) !int {
	if state.executable == '' {
		return 0
	}
	bin_directory := go_bin_directory(state.gobin, state.gopath)
	if !os.is_dir(bin_directory) {
		return 0
	}
	mut removed := 0
	mut names := os.ls(bin_directory)!
	names.sort()
	for name in names {
		binary := os.join_path(bin_directory, name)
		if !os.is_file(binary) || !os.is_executable(binary) || os.is_link(binary) {
			continue
		}
		output := state.version_outputs[binary] or { continue }
		module_path := go_module_path(output) or { continue }
		if module_path !in items {
			continue
		}
		os.rm(binary)!
		state.removed_binaries << binary
		removed++
	}
	suffix := if removed == 1 { '' } else { 's' }
	state.output << 'Uninstalled ${removed} ${go_definition().banner_name}${suffix}'
	return removed
}

fn go_state_value(state &GoState) ruby.Value {
	return ruby.structured_value('Homebrew::Bundle::Go', '', {
		'go_state_address': u64(voidptr(state)).str()
	})
}

fn go_state_from_args(args []ruby.Value, method string) &GoState {
	if args.len == 0 || 'go_state_address' !in args[0].attributes {
		panic('Go.${method} requires translated Go state')
	}
	return unsafe { &GoState(voidptr(args[0].attributes['go_state_address'].u64())) }
}

pub fn go_state_boundary(state &GoState) ruby.Value {
	return go_state_value(state)
}

// Ruby method `type = :go` at line 11.
pub fn ruby_go_l11_d1_type(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Symbol', 'go')
}

// Ruby method `check_label = "Go Package"` at line 14.
pub fn ruby_go_l14_d2_check_label(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(go_definition().check_label)
}

// Ruby method `banner_name = "Go packages"` at line 17.
pub fn ruby_go_l17_d3_banner_name(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(go_definition().banner_name)
}

// Ruby method `reset!` at line 20.
pub fn ruby_go_l20_d4_reset(args ...ruby.Value) ruby.Value {
	mut state := go_state_from_args(args, 'reset!')
	state.reset()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `cleanup_heading` at line 26.
pub fn ruby_go_l26_d5_cleanup_heading(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(go_definition().cleanup_heading or { '' })
}

// Ruby method `packages` at line 31.
pub fn ruby_go_l31_d6_packages(args ...ruby.Value) ruby.Value {
	mut state := go_state_from_args(args, 'packages')
	return ruby.string_array_value(state.discover_packages())
}

// Ruby method `install_package!(name, with: nil, verbose: false)` at line 82.
pub fn ruby_go_l82_d7_install_package(args ...ruby.Value) ruby.Value {
	mut state := go_state_from_args(args, 'install_package!')
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'name is required')
	}
	result := if args.len > 4 { args[4].bool_data } else { false }
	return ruby.bool_value(state.install_package(args[1].as_string(), result) or {
		return ruby.object_value('RuntimeError', err.msg())
	})
}

// Ruby method `installed_packages` at line 91.
pub fn ruby_go_l91_d8_installed_packages(args ...ruby.Value) ruby.Value {
	mut state := go_state_from_args(args, 'installed_packages')
	return ruby.string_array_value(state.discover_installed_packages())
}

// Ruby method `cleanup!(items)` at line 99.
pub fn ruby_go_l99_d9_cleanup(args ...ruby.Value) ruby.Value {
	mut state := go_state_from_args(args, 'cleanup!')
	items := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	state.cleanup(items) or { return ruby.object_value('SystemCallError', err.msg()) }
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
// 8:     class Go < Extension
// 9:       class << self
// 10:         sig { override.returns(Symbol) }
// 11:         def type = :go
// 12:
// 13:         sig { override.returns(String) }
// 14:         def check_label = "Go Package"
// 15:
// 16:         sig { override.returns(String) }
// 17:         def banner_name = "Go packages"
// 18:
// 19:         sig { override.void }
// 20:         def reset!
// 21:           @packages = T.let(nil, T.nilable(T::Array[String]))
// 22:           @installed_packages = T.let(nil, T.nilable(T::Array[String]))
// 23:         end
// 24:
// 25:         sig { override.returns(T.nilable(String)) }
// 26:         def cleanup_heading
// 27:           banner_name
// 28:         end
// 29:
// 30:         sig { override.returns(T::Array[String]) }
// 31:         def packages
// 32:           packages = @packages
// 33:           return packages if packages
// 34:
// 35:           @packages = if (go = package_manager_executable)
// 36:             ENV["GOBIN"] = ENV.fetch("HOMEBREW_GOBIN", nil)
// 37:             ENV["GOPATH"] = ENV.fetch("HOMEBREW_GOPATH", nil)
// 38:             gobin = `#{go} env GOBIN`.chomp
// 39:             gopath = `#{go} env GOPATH`.chomp
// 40:             bin_dir = gobin.empty? ? "#{gopath}/bin" : gobin
// 41:             if File.directory?(bin_dir)
// 42:               binaries = Dir.glob("#{bin_dir}/*").select do |file|
// 43:                 File.executable?(file) && !File.directory?(file) && !File.symlink?(file)
// 44:               end
// 45:
// 46:               binaries.filter_map do |binary|
// 47:                 output = `#{go} version -m "#{binary}" 2>/dev/null`
// 48:                 next if output.empty?
// 49:
// 50:                 lines = output.split("\n")
// 51:                 path_line = lines.find { |line| line.strip.start_with?("path\t") }
// 52:                 next unless path_line
// 53:
// 54:                 # Parse the output to find the path line
// 55:                 # Format: "\tpath\tgithub.com/user/repo"
// 56:                 parts = path_line.split("\t")
// 57:                 # Extract the package path (second field after splitting by tab)
// 58:                 # The line format is: "\tpath\tgithub.com/user/repo"
// 59:                 path = parts[2]&.strip
// 60:
// 61:                 # `command-line-arguments` is a dummy package name for binaries built
// 62:                 # from a list of source files instead of a specific package name.
// 63:                 # https://github.com/golang/go/issues/36043
// 64:                 next if path == "command-line-arguments"
// 65:
// 66:                 path
// 67:               end.uniq
// 68:             end
// 69:           end
// 70:           return [] if @packages.nil?
// 71:
// 72:           @packages
// 73:         end
// 74:
// 75:         sig {
// 76:           override.params(
// 77:             name:    String,
// 78:             with:    T.nilable(T::Array[String]),
// 79:             verbose: T::Boolean,
// 80:           ).returns(T::Boolean)
// 81:         }
// 82:         def install_package!(name, with: nil, verbose: false)
// 83:           _ = with
// 84:
// 85:           go = package_manager_executable!
// 86:
// 87:           Bundle.system(go.to_s, "install", "#{name}@latest", verbose:)
// 88:         end
// 89:
// 90:         sig { override.returns(T::Array[String]) }
// 91:         def installed_packages
// 92:           installed_packages = @installed_packages
// 93:           return installed_packages if installed_packages
// 94:
// 95:           @installed_packages = packages.dup
// 96:         end
// 97:
// 98:         sig { override.params(items: T::Array[String]).void }
// 99:         def cleanup!(items)
// 100:           go = package_manager_executable
// 101:           return if go.nil?
// 102:
// 103:           gobin = `#{go} env GOBIN`.chomp
// 104:           gopath = `#{go} env GOPATH`.chomp
// 105:           bin_dir = gobin.empty? ? "#{gopath}/bin" : gobin
// 106:           return unless File.directory?(bin_dir)
// 107:
// 108:           removed = 0
// 109:           Dir.glob("#{bin_dir}/*").each do |binary|
// 110:             next if !File.executable?(binary) || File.directory?(binary) || File.symlink?(binary)
// 111:
// 112:             output = `#{go} version -m "#{binary}" 2>/dev/null`
// 113:             next if output.empty?
// 114:
// 115:             path_line = output.split("\n").find { |line| line.strip.start_with?("path\t") }
// 116:             next unless path_line
// 117:
// 118:             module_path = path_line.split("\t")[2]&.strip
// 119:             next unless items.include?(module_path)
// 120:
// 121:             FileUtils.rm_f(binary)
// 122:             removed += 1
// 123:           end
// 124:           puts "Uninstalled #{removed} #{banner_name}#{"s" if removed != 1}"
// 125:         end
// 126:       end
// 127:     end
// 128:   end
// 129: end
