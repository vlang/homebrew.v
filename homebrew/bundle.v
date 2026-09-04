module homebrew

import ruby
import os

// Translated from Homebrew/brew `bundle.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct BundleRuntimeConfig {
pub:
	prefix              string
	library             string
	brew_file           string
	npm_executable      string
	path                string
	no_install_from_api bool
	uid                 int
	euid                int
	user_home           string
}

pub struct BundleTabState {
pub:
	exists               bool
	installed_on_request bool
	writable             bool = true
}

pub struct BundleEntry {
pub:
	entry_type string
	name       string
}

@[heap]
pub struct BundleRuntime {
pub:
	config BundleRuntimeConfig
pub mut:
	upgrade_formulae        []string
	upgrade_formulae_loaded bool
	formula_versions        map[string]string
	formula_versions_loaded bool
	cask_installed          bool
	cask_installed_loaded   bool
	installed_formulae      []string
	tabs                    map[string]BundleTabState
	commands                [][]string
	command_environments    []map[string]string
	output                  []string
	brew_tab_updates        []string
	uid_exchange_count      int
	pkgconf_prepend_count   int
}

pub fn new_bundle_runtime(config BundleRuntimeConfig) &BundleRuntime {
	return &BundleRuntime{
		config: config
	}
}

pub fn (mut runtime BundleRuntime) set_upgrade_formulae(value ?string) {
	raw := value or { '' }
	runtime.upgrade_formulae = if raw == '' { [] } else { raw.split(',') }
	runtime.upgrade_formulae_loaded = true
}

pub fn (runtime &BundleRuntime) get_upgrade_formulae() []string {
	return if runtime.upgrade_formulae_loaded { runtime.upgrade_formulae.clone() } else { [] }
}

pub fn (mut runtime BundleRuntime) run_system(command string, arguments []string,
	verbose bool) bool {
	mut environment := map[string]string{}
	if runtime.config.npm_executable != '' && command == runtime.config.npm_executable {
		path := if runtime.config.path != '' { runtime.config.path } else { os.getenv('PATH') }
		node_bin := os.join_path(runtime.config.prefix, 'opt', 'node', 'bin')
		environment['PATH'] = '${path}:${node_bin}'
	}
	mut command_line := [command]
	command_line << arguments
	runtime.commands << command_line
	runtime.command_environments << environment.clone()
	result := if environment.len > 0 {
		ruby.run_command_with_environment(command, arguments, environment)
	} else {
		ruby.run_command(command, arguments)
	}
	if result.exit_code != 0 || verbose {
		runtime.output << result.output
	}
	return result.exit_code == 0
}

pub fn (mut runtime BundleRuntime) run_brew(arguments []string, verbose bool) bool {
	return runtime.run_system(runtime.config.brew_file, arguments, verbose)
}

pub fn (mut runtime BundleRuntime) is_cask_installed() bool {
	if !runtime.cask_installed_loaded {
		caskroom := os.join_path(runtime.config.prefix, 'Caskroom')
		cask_tap := os.join_path(runtime.config.library, 'Taps', 'homebrew', 'homebrew-cask')
		runtime.cask_installed = os.is_dir(caskroom)
			&& (os.is_dir(cask_tap) || !runtime.config.no_install_from_api)
		runtime.cask_installed_loaded = true
	}
	return runtime.cask_installed
}

pub fn (mut runtime BundleRuntime) exchange_uid_if_needed_value(block_result ruby.Value) ruby.Value {
	if runtime.config.euid != runtime.config.uid {
		// The Ruby process temporarily exchanges IDs around the block. V callers
		// keep process credentials unchanged and expose the exchange as state so
		// privileged launchers can perform it at their process boundary.
		runtime.uid_exchange_count++
	}
	return block_result
}

fn bundle_formula_environment_name(formula_name string) string {
	return formula_name.to_upper().replace('@', 'AT').replace('+', 'X').replace('-', '_')
}

pub fn (mut runtime BundleRuntime) formula_version_from_environment(formula_name string) ?string {
	if !runtime.formula_versions_loaded {
		prefix := 'HOMEBREW_BUNDLE_FORMULA_VERSION_'
		mut versions := map[string]string{}
		for key, value in os.environ() {
			if !key.starts_with(prefix) {
				continue
			}
			name := key[prefix.len..]
			if name == '' {
				continue
			}
			versions[name] = value
			os.unsetenv(key)
		}
		runtime.formula_versions = versions.clone()
		runtime.formula_versions_loaded = true
	}
	return runtime.formula_versions[bundle_formula_environment_name(formula_name)] or { none }
}

pub fn (mut runtime BundleRuntime) set_formula_versions_cache(versions ?map[string]string) {
	if values := versions {
		runtime.formula_versions = values.clone()
		runtime.formula_versions_loaded = true
	} else {
		runtime.formula_versions = map[string]string{}
		runtime.formula_versions_loaded = false
	}
}

pub fn (mut runtime BundleRuntime) prepend_pkgconf_path_if_needed() {
	// The cross-platform extension supplies the platform-specific path. Keep
	// this source-level hook observable while the base implementation is empty.
	runtime.pkgconf_prepend_count++
}

pub fn (mut runtime BundleRuntime) reset() {
	runtime.upgrade_formulae = []
	runtime.upgrade_formulae_loaded = false
	runtime.formula_versions = map[string]string{}
	runtime.formula_versions_loaded = false
	runtime.cask_installed = false
	runtime.cask_installed_loaded = false
}

pub fn (mut runtime BundleRuntime) mark_as_installed_on_request(entries []BundleEntry) {
	if entries.len == 0 || runtime.installed_formulae.len == 0 {
		return
	}
	mut use_brew_tab := false
	mut fallback := []string{}
	for entry in entries {
		if entry.entry_type != 'brew' || entry.name !in runtime.installed_formulae {
			continue
		}
		mut tab := runtime.tabs[entry.name] or { continue }
		if !tab.exists || tab.installed_on_request {
			continue
		}
		if use_brew_tab {
			fallback << entry.name
			continue
		}
		if tab.writable {
			tab = BundleTabState{
				...tab
				installed_on_request: true
			}
			runtime.tabs[entry.name] = tab
		} else {
			use_brew_tab = true
			fallback << entry.name
		}
	}
	if use_brew_tab {
		runtime.brew_tab_updates << fallback
		for name in fallback {
			if tab := runtime.tabs[name] {
				runtime.tabs[name] = BundleTabState{
					...tab
					installed_on_request: true
				}
			}
		}
	}
}

fn bundle_runtime_value(runtime &BundleRuntime) ruby.Value {
	return ruby.structured_value('Homebrew::Bundle', '', {
		'bundle_runtime_address': u64(voidptr(runtime)).str()
	})
}

pub fn bundle_runtime_boundary(runtime &BundleRuntime) ruby.Value {
	return bundle_runtime_value(runtime)
}

fn bundle_runtime_from_args(args []ruby.Value, method string) &BundleRuntime {
	if args.len == 0 || args[0].type_name != 'Homebrew::Bundle' {
		panic('Homebrew::Bundle.${method} requires a translated runtime')
	}
	address := args[0].attributes['bundle_runtime_address'] or {
		panic('Homebrew::Bundle runtime has no translated state')
	}
	return unsafe { &BundleRuntime(voidptr(address.u64())) }
}

fn bundle_string_map_value(values map[string]string) ruby.Value {
	mut mapped := map[string]ruby.Value{}
	for key, value in values {
		mapped[key] = ruby.string_value(value)
	}
	return ruby.map_value(mapped)
}

fn bundle_string_map_from_value(value ruby.Value) map[string]string {
	mut mapped := map[string]string{}
	for key, item in value.as_map() or { return mapped } {
		mapped[key] = item.as_string()
	}
	return mapped
}

pub fn bundle_entry_boundary(entry BundleEntry) ruby.Value {
	return ruby.map_value({
		'type': ruby.string_value(entry.entry_type)
		'name': ruby.string_value(entry.name)
	})
}

fn bundle_entry_from_value(value ruby.Value) BundleEntry {
	fields := value.map_data.clone()
	return BundleEntry{
		entry_type: (fields['type'] or { ruby.string_value('') }).as_string()
		name: (fields['name'] or { ruby.string_value('') }).as_string()
	}
}

// Ruby method `upgrade_formulae=(args_upgrade_formula)` at line 10.
pub fn ruby_bundle_l10_d1_upgrade_formulae(args ...ruby.Value) ruby.Value {
	mut runtime := bundle_runtime_from_args(args, 'upgrade_formulae=')
	value := if args.len > 1 && args[1].type_name !in ['Nil', 'NilClass'] {
		?string(args[1].as_string())
	} else {
		none
	}
	runtime.set_upgrade_formulae(value)
	return ruby.string_array_value(runtime.get_upgrade_formulae())
}

// Ruby method `upgrade_formulae` at line 15.
pub fn ruby_bundle_l15_d2_upgrade_formulae(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(bundle_runtime_from_args(args, 'upgrade_formulae').get_upgrade_formulae())
}

// Ruby method `system(cmd, *args, verbose: false)` at line 20.
pub fn ruby_bundle_l20_d3_system(args ...ruby.Value) ruby.Value {
	mut runtime := bundle_runtime_from_args(args, 'system')
	if args.len < 2 {
		panic('Homebrew::Bundle.system requires a command')
	}
	arguments := if args.len > 2 { args[2].as_string_array() or { [] } } else { [] }
	verbose := args.len > 3 && (args[3].as_bool() or { false })
	return ruby.bool_value(runtime.run_system(args[1].as_string(), arguments, verbose))
}

// Ruby method `brew(*args, verbose: false)` at line 47.
pub fn ruby_bundle_l47_d4_brew(args ...ruby.Value) ruby.Value {
	mut runtime := bundle_runtime_from_args(args, 'brew')
	arguments := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	verbose := args.len > 2 && (args[2].as_bool() or { false })
	return ruby.bool_value(runtime.run_brew(arguments, verbose))
}

// Ruby method `cask_installed?` at line 52.
pub fn ruby_bundle_l52_d5_cask_installed(args ...ruby.Value) ruby.Value {
	mut runtime := bundle_runtime_from_args(args, 'cask_installed?')
	return ruby.bool_value(runtime.is_cask_installed())
}

// Ruby method `exchange_uid_if_needed!(&block)` at line 59.
pub fn ruby_bundle_l59_d6_exchange_uid_if_needed(args ...ruby.Value) ruby.Value {
	mut runtime := bundle_runtime_from_args(args, 'exchange_uid_if_needed!')
	result := if args.len > 1 { args[1] } else { ruby.object_value('NilClass', 'nil') }
	return runtime.exchange_uid_if_needed_value(result)
}

// Ruby method `formula_versions_from_env(formula_name)` at line 85.
pub fn ruby_bundle_l85_d7_formula_versions_from_env(args ...ruby.Value) ruby.Value {
	mut runtime := bundle_runtime_from_args(args, 'formula_versions_from_env')
	if args.len < 2 {
		panic('formula_versions_from_env requires a formula name')
	}
	return if version := runtime.formula_version_from_environment(args[1].as_string()) {
		ruby.string_value(version)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby method `formula_versions_from_env_cache` at line 113.
pub fn ruby_bundle_l113_d8_formula_versions_from_env_cache(args ...ruby.Value) ruby.Value {
	runtime := bundle_runtime_from_args(args, 'formula_versions_from_env_cache')
	return if runtime.formula_versions_loaded {
		bundle_string_map_value(runtime.formula_versions)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby method `formula_versions_from_env_cache=(formula_versions)` at line 118.
pub fn ruby_bundle_l118_d9_formula_versions_from_env_cache(args ...ruby.Value) ruby.Value {
	mut runtime := bundle_runtime_from_args(args, 'formula_versions_from_env_cache=')
	versions := if args.len > 1 && args[1].type_name == 'Hash' {
		?map[string]string(bundle_string_map_from_value(args[1]))
	} else {
		none
	}
	runtime.set_formula_versions_cache(versions)
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `prepend_pkgconf_path_if_needed!; end` at line 123.
pub fn ruby_bundle_l123_d10_prepend_pkgconf_path_if_needed(args ...ruby.Value) ruby.Value {
	mut runtime := bundle_runtime_from_args(args, 'prepend_pkgconf_path_if_needed!')
	runtime.prepend_pkgconf_path_if_needed()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `reset!` at line 126.
pub fn ruby_bundle_l126_d11_reset(args ...ruby.Value) ruby.Value {
	mut runtime := bundle_runtime_from_args(args, 'reset!')
	runtime.reset()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `mark_as_installed_on_request!(entries)` at line 135.
pub fn ruby_bundle_l135_d12_mark_as_installed_on_request(args ...ruby.Value) ruby.Value {
	mut runtime := bundle_runtime_from_args(args, 'mark_as_installed_on_request!')
	entries := if args.len > 1 {
		(args[1].as_array() or { [] }).map(bundle_entry_from_value(it))
	} else {
		[]BundleEntry{}
	}
	runtime.mark_as_installed_on_request(entries)
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "English"
// 5:
// 6: module Homebrew
// 7:   module Bundle
// 8:     class << self
// 9:       sig { params(args_upgrade_formula: T.nilable(String)).void }
// 10:       def upgrade_formulae=(args_upgrade_formula)
// 11:         @upgrade_formulae = args_upgrade_formula.to_s.split(",")
// 12:       end
// 13:
// 14:       sig { returns(T::Array[String]) }
// 15:       def upgrade_formulae
// 16:         @upgrade_formulae || []
// 17:       end
// 18:
// 19:       sig { params(cmd: T.any(String, Pathname), args: T.anything, verbose: T::Boolean).returns(T::Boolean) }
// 20:       def system(cmd, *args, verbose: false)
// 21:         return super cmd, *args if verbose
// 22:
// 23:         env = {}
// 24:
// 25:         # Make sure node's bin opt path is part of the PATH
// 26:         # This is essential for the npm bundle extension that calls node directly
// 27:         if Npm.package_manager_executable && cmd.to_s == Npm.package_manager_executable.to_s
// 28:           node_bin = "#{HOMEBREW_PREFIX}/opt/node/bin"
// 29:           env["PATH"] = "#{ENV.fetch("PATH")}:#{node_bin}"
// 30:         end
// 31:
// 32:         logs = []
// 33:         success = T.let(false, T::Boolean)
// 34:         IO.popen(env, [cmd, *args], err: [:child, :out]) do |pipe|
// 35:           while (buf = pipe.gets)
// 36:             logs << buf
// 37:           end
// 38:           Process.wait(pipe.pid)
// 39:           success = $CHILD_STATUS.success?
// 40:           pipe.close
// 41:         end
// 42:         puts logs.join unless success
// 43:         success
// 44:       end
// 45:
// 46:       sig { params(args: T.anything, verbose: T::Boolean).returns(T::Boolean) }
// 47:       def brew(*args, verbose: false)
// 48:         system(HOMEBREW_BREW_FILE, *args, verbose:)
// 49:       end
// 50:
// 51:       sig { returns(T::Boolean) }
// 52:       def cask_installed?
// 53:         @cask_installed ||= File.directory?("#{HOMEBREW_PREFIX}/Caskroom") &&
// 54:                             (File.directory?("#{HOMEBREW_LIBRARY}/Taps/homebrew/homebrew-cask") ||
// 55:                              !Homebrew::EnvConfig.no_install_from_api?)
// 56:       end
// 57:
// 58:       sig { params(block: T.proc.returns(T.anything)).returns(T.untyped) }
// 59:       def exchange_uid_if_needed!(&block)
// 60:         euid = Process.euid
// 61:         uid = Process.uid
// 62:         return yield if euid == uid
// 63:
// 64:         old_euid = euid
// 65:         process_reexchangeable = Process::UID.re_exchangeable?
// 66:         if process_reexchangeable
// 67:           Process::UID.re_exchange
// 68:         else
// 69:           Process::Sys.seteuid(uid)
// 70:         end
// 71:
// 72:         home = T.must(Etc.getpwuid(Process.uid)).dir
// 73:         return_value = with_env("HOME" => home, &block)
// 74:
// 75:         if process_reexchangeable
// 76:           Process::UID.re_exchange
// 77:         else
// 78:           Process::Sys.seteuid(old_euid)
// 79:         end
// 80:
// 81:         return_value
// 82:       end
// 83:
// 84:       sig { params(formula_name: String).returns(T.nilable(String)) }
// 85:       def formula_versions_from_env(formula_name)
// 86:         @formula_versions_from_env ||= begin
// 87:           formula_versions = {}
// 88:
// 89:           ENV.each do |key, value|
// 90:             match = key.match(/^HOMEBREW_BUNDLE_FORMULA_VERSION_(.+)$/)
// 91:             next if match.blank?
// 92:
// 93:             env_formula_name = match[1]
// 94:             next if env_formula_name.blank?
// 95:
// 96:             ENV.delete(key)
// 97:             formula_versions[env_formula_name] = value
// 98:           end
// 99:
// 100:           formula_versions
// 101:         end
// 102:
// 103:         # Fix up formula name for a valid environment variable name.
// 104:         formula_env_name = formula_name.upcase
// 105:                                        .gsub("@", "AT")
// 106:                                        .tr("+", "X")
// 107:                                        .tr("-", "_")
// 108:
// 109:         @formula_versions_from_env[formula_env_name]
// 110:       end
// 111:
// 112:       sig { returns(T.nilable(T::Hash[String, String])) }
// 113:       def formula_versions_from_env_cache
// 114:         @formula_versions_from_env
// 115:       end
// 116:
// 117:       sig { params(formula_versions: T.nilable(T::Hash[String, String])).void }
// 118:       def formula_versions_from_env_cache=(formula_versions)
// 119:         @formula_versions_from_env = formula_versions
// 120:       end
// 121:
// 122:       sig { void }
// 123:       def prepend_pkgconf_path_if_needed!; end
// 124:
// 125:       sig { void }
// 126:       def reset!
// 127:         @cask_installed = T.let(nil, T.nilable(T::Boolean))
// 128:         @formula_versions_from_env = T.let(nil, T.nilable(T::Hash[String, String]))
// 129:         @upgrade_formulae = T.let(nil, T.nilable(T::Array[String]))
// 130:       end
// 131:
// 132:       # Marks Brewfile formulae as installed_on_request to prevent autoremove
// 133:       # from removing them when their dependents are uninstalled.
// 134:       sig { params(entries: T::Array[Dsl::Entry]).void }
// 135:       def mark_as_installed_on_request!(entries)
// 136:         return if entries.empty?
// 137:
// 138:         require "tab"
// 139:
// 140:         installed_formulae = Formula.installed_formula_names
// 141:         return if installed_formulae.empty?
// 142:
// 143:         use_brew_tab = T.let(false, T::Boolean)
// 144:
// 145:         formulae_to_update = entries.filter_map do |entry|
// 146:           next if entry.type != :brew
// 147:
// 148:           name = entry.name
// 149:           next if installed_formulae.exclude?(name)
// 150:
// 151:           tab = Tab.for_name(name)
// 152:           tabfile = tab.tabfile
// 153:           next unless tabfile&.exist?
// 154:           next if tab.installed_on_request
// 155:
// 156:           next name if use_brew_tab
// 157:
// 158:           tab.installed_on_request = true
// 159:
// 160:           begin
// 161:             tab.write
// 162:             nil
// 163:           rescue Errno::EACCES
// 164:             # Some wrappers might treat `brew bundle` with lower permissions due to its execution of user code.
// 165:             # Running through `brew tab` ensures proper privilege escalation by going through the wrapper again.
// 166:             use_brew_tab = true
// 167:             name
// 168:           end
// 169:         end
// 170:
// 171:         brew "tab", "--installed-on-request", *formulae_to_update if use_brew_tab
// 172:       end
// 173:     end
// 174:   end
// 175: end
// 176:
// 177: require "extend/os/bundle/bundle"
