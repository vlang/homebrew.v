module bundle

import brew_runtime
import json2
import os

// Translated from Homebrew/brew `bundle/brew_services.rb`.
// The original source is retained below for source-level traceability.
pub const brew_services_missing_daemon_manager_message = 'Invalid usage: `brew services` is supported only on macOS or Linux (with systemd)!'

pub struct BrewServicesListEntry {
pub:
	name   string
	status string
}

pub struct BrewServicesFormula {
pub:
	name         string
	version      string
	rack         string
	plist_name   string
	service_name string
}

pub struct BrewServicesCommand {
pub:
	arguments []string
	verbose   bool
}

@[heap]
pub struct BrewServicesState {
pub mut:
	launchctl               bool
	systemctl               bool
	linux                   bool
	services_json           string = '[]'
	started_services        []string
	started_services_loaded bool
	command_results         map[string]bool
	commands                []BrewServicesCommand
	formula_versions        map[string]string
	formulae                []BrewServicesFormula
	old_names               map[string]string
	warnings                []string
}

pub fn new_brew_services_state() &BrewServicesState {
	return &BrewServicesState{
		command_results: map[string]bool{}
		formula_versions: map[string]string{}
		old_names: map[string]string{}
	}
}

fn brew_services_command_key(arguments []string) string {
	return arguments.join('\x1f')
}

fn (state BrewServicesState) command_result(arguments []string) bool {
	return state.command_results[brew_services_command_key(arguments)] or { true }
}

pub fn (mut state BrewServicesState) reset() {
	state.started_services = []
	state.started_services_loaded = false
}

pub fn (mut state BrewServicesState) started_services_without_daemon_manager() ![]string {
	if state.linux {
		state.warnings << 'Skipping `brew services list` due to missing systemctl'
		return []
	}
	return error(brew_services_missing_daemon_manager_message)
}

pub fn (mut state BrewServicesState) load_started_services() ![]string {
	if state.started_services_loaded {
		return state.started_services.clone()
	}
	if !state.launchctl && !state.systemctl {
		state.started_services = state.started_services_without_daemon_manager()!
	} else {
		services_list := json2.decode[[]BrewServicesListEntry](state.services_json)!
		state.started_services = services_list.filter(it.status !in ['stopped', 'none']).map(it.name)
	}
	state.started_services_loaded = true
	return state.started_services.clone()
}

pub fn (mut state BrewServicesState) started(name string) !bool {
	return name in state.load_started_services()!
}

pub fn (mut state BrewServicesState) stop(name string, keep bool, verbose bool) !bool {
	if !state.started(name)! {
		return true
	}
	mut arguments := ['services', 'stop', name]
	if keep {
		arguments << '--keep'
	}
	state.commands << BrewServicesCommand{
		arguments: arguments
		verbose: verbose
	}
	if !state.command_result(arguments) {
		return false
	}
	state.started_services = state.started_services.filter(it != name)
	return true
}

fn (mut state BrewServicesState) start_with_verb(verb string, name string, file string,
	verbose bool) bool {
	mut arguments := ['services', verb, name]
	if file != '' {
		arguments << '--file=${file}'
	}
	state.commands << BrewServicesCommand{
		arguments: arguments
		verbose: verbose
	}
	if !state.command_result(arguments) {
		return false
	}
	state.started_services << name
	state.started_services_loaded = true
	return true
}

pub fn (mut state BrewServicesState) start(name string, file string, verbose bool) bool {
	return state.start_with_verb('start', name, file, verbose)
}

pub fn (mut state BrewServicesState) run(name string, file string, verbose bool) bool {
	return state.start_with_verb('run', name, file, verbose)
}

pub fn (mut state BrewServicesState) restart(name string, file string, verbose bool) bool {
	return state.start_with_verb('restart', name, file, verbose)
}

fn (state BrewServicesState) formula(name string) ?BrewServicesFormula {
	for formula in state.formulae {
		if formula.name == name {
			return formula
		}
	}
	return none
}

pub fn (state BrewServicesState) versioned_service_file(name string) ?string {
	env_version := state.formula_versions[name] or { return none }
	formula := state.formula(name) or { return none }
	prefix := os.join_path(formula.rack, env_version)
	if !os.is_dir(prefix) {
		return none
	}
	service_basename := if state.launchctl {
		'${formula.plist_name}.plist'
	} else {
		'${formula.service_name}.service'
	}
	service_file := os.join_path(prefix, service_basename)
	return if os.is_file(service_file) { service_file } else { none }
}

pub fn brew_services_failure_reason(name string, no_upgrade bool) string {
	_ = no_upgrade
	return 'Service ${name} needs to be started.'
}

fn brew_services_entry_from_value(value brew_runtime.Value) BundleDslEntry {
	return BundleDslEntry{
		entry_type: value.attributes['type'] or { 'brew' }
		name: value.attributes['name'] or { value.repr }
		options: value.map_data.clone()
	}
}

pub fn brew_services_entry_to_formula(entry BundleDslEntry) BundleBrewInstaller {
	return bundle_brew_installer(entry.name, bundle_brew_options_from_value(brew_runtime.map_value(entry.options)))
}

pub fn brew_services_formula_needs_to_start(formula BundleBrewInstaller) bool {
	return bundle_brew_start_service(formula) || bundle_brew_restart_service(formula)
}

pub fn (state BrewServicesState) lookup_old_name(service_name string) ?string {
	if old_name := state.old_names[service_name] {
		return old_name
	}
	base_name := bundle_brew_name_from_full_name(service_name)
	return state.old_names[base_name] or { none }
}

pub fn (mut state BrewServicesState) installed_and_up_to_date(entry BundleDslEntry,
	no_upgrade bool) !bool {
	_ = no_upgrade
	formula := brew_services_entry_to_formula(entry)
	if !brew_services_formula_needs_to_start(formula) {
		return true
	}
	name := entry.name
	if state.started(name)! {
		return true
	}
	base_name := bundle_brew_name_from_full_name(name)
	if base_name != name && state.started(base_name)! {
		return true
	}
	old_name := state.lookup_old_name(name) or { return false }
	return state.started(old_name)!
}

pub fn brew_services_format_checkable(entries []BundleDslEntry) []BundleDslEntry {
	return entries.filter(it.entry_type == 'brew')
}

fn brew_services_entries_from_value(value brew_runtime.Value) []BundleDslEntry {
	return value.as_array() or { [] }.map(brew_services_entry_from_value(it))
}

fn brew_services_entries_value(entries []BundleDslEntry) brew_runtime.Value {
	return brew_runtime.array_value(entries.map(bundle_dsl_entry_value(it)))
}

fn brew_services_state_value(state &BrewServicesState) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::Bundle::Brew::Services', '', {
		'brew_services_state_address': u64(voidptr(state)).str()
	})
}

pub fn brew_services_state_boundary(state &BrewServicesState) brew_runtime.Value {
	return brew_services_state_value(state)
}

fn brew_services_state_from_args(args []brew_runtime.Value, method string) &BrewServicesState {
	if args.len == 0 || 'brew_services_state_address' !in args[0].attributes {
		panic('Brew::Services.${method} requires translated BrewServices state')
	}
	return unsafe { &BrewServicesState(voidptr(args[0].attributes['brew_services_state_address'].u64())) }
}

fn brew_services_error(type_name string, message string) brew_runtime.Value {
	return brew_runtime.structured_value(type_name, message, {
		'message': message
	})
}

fn brew_services_optional_string(args []brew_runtime.Value, index int) string {
	if index >= args.len || args[index].type_name in ['Nil', 'NilClass'] {
		return ''
	}
	return args[index].as_string()
}

// Ruby method `reset!` at line 17.
pub fn ruby_brew_services_l17_d1_reset(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := brew_services_state_from_args(args, 'reset!')
	state.reset()
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `stop(name, keep: false, verbose: false)` at line 24.
pub fn ruby_brew_services_l24_d2_stop(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := brew_services_state_from_args(args, 'stop')
	if args.len < 2 {
		return brew_services_error('ArgumentError', 'name is required')
	}
	keep := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	verbose := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	return brew_runtime.bool_value(state.stop(args[1].as_string(), keep, verbose) or {
		return brew_services_error('SystemExit', err.msg())
	})
}

// Ruby method `start(name, file: nil, verbose: false)` at line 36.
pub fn ruby_brew_services_l36_d3_start(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := brew_services_state_from_args(args, 'start')
	if args.len < 2 {
		return brew_services_error('ArgumentError', 'name is required')
	}
	verbose := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	return brew_runtime.bool_value(state.start(args[1].as_string(), brew_services_optional_string(args, 2), verbose))
}

// Ruby method `run(name, file: nil, verbose: false)` at line 46.
pub fn ruby_brew_services_l46_d4_run(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := brew_services_state_from_args(args, 'run')
	if args.len < 2 {
		return brew_services_error('ArgumentError', 'name is required')
	}
	verbose := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	return brew_runtime.bool_value(state.run(args[1].as_string(), brew_services_optional_string(args, 2), verbose))
}

// Ruby method `restart(name, file: nil, verbose: false)` at line 56.
pub fn ruby_brew_services_l56_d5_restart(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := brew_services_state_from_args(args, 'restart')
	if args.len < 2 {
		return brew_services_error('ArgumentError', 'name is required')
	}
	verbose := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	return brew_runtime.bool_value(state.restart(args[1].as_string(), brew_services_optional_string(args, 2), verbose))
}

// Ruby method `started?(name)` at line 67.
pub fn ruby_brew_services_l67_d6_started(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := brew_services_state_from_args(args, 'started?')
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(state.started(args[1].as_string()) or {
		return brew_services_error('SystemExit', err.msg())
	})
}

// Ruby method `started_services_without_daemon_manager` at line 72.
pub fn ruby_brew_services_l72_d7_started_services_without_daemon_manager(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := brew_services_state_from_args(args, 'started_services_without_daemon_manager')
	services := state.started_services_without_daemon_manager() or {
		return brew_services_error('SystemExit', err.msg())
	}
	return brew_runtime.string_array_value(services)
}

// Ruby method `started_services` at line 77.
pub fn ruby_brew_services_l77_d8_started_services(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := brew_services_state_from_args(args, 'started_services')
	services := state.load_started_services() or {
		return brew_services_error(if err.msg().contains('supported only') {
			'SystemExit'
		} else {
			'JSON::ParserError'
		}, err.msg())
	}
	return brew_runtime.string_array_value(services)
}

// Ruby method `versioned_service_file(name)` at line 94.
pub fn ruby_brew_services_l94_d9_versioned_service_file(args ...brew_runtime.Value) brew_runtime.Value {
	state := brew_services_state_from_args(args, 'versioned_service_file')
	if args.len < 2 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	path := state.versioned_service_file(args[1].as_string()) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.object_value('Pathname', path)
}

// Ruby method `failure_reason(name, no_upgrade:)` at line 113.
pub fn ruby_brew_services_l113_d10_failure_reason(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	no_upgrade := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	return brew_runtime.string_value(brew_services_failure_reason(name, no_upgrade))
}

// Ruby method `installed_and_up_to_date?(formula, no_upgrade: false)` at line 120.
pub fn ruby_brew_services_l120_d11_installed_and_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := brew_services_state_from_args(args, 'installed_and_up_to_date?')
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	no_upgrade := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	return brew_runtime.bool_value(state.installed_and_up_to_date(brew_services_entry_from_value(args[1]), no_upgrade) or { return brew_services_error('SystemExit', err.msg()) })
}

// Ruby method `entry_to_formula(entry)` at line 141.
pub fn ruby_brew_services_l141_d12_entry_to_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_services_error('ArgumentError', 'entry is required')
	}
	return bundle_brew_installer_value(brew_services_entry_to_formula(brew_services_entry_from_value(args[0])))
}

// Ruby method `formula_needs_to_start?(formula)` at line 146.
pub fn ruby_brew_services_l146_d13_formula_needs_to_start(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(brew_services_formula_needs_to_start(bundle_brew_installer_from_value(args[0])))
}

// Ruby method `lookup_old_name(service_name)` at line 151.
pub fn ruby_brew_services_l151_d14_lookup_old_name(args ...brew_runtime.Value) brew_runtime.Value {
	state := brew_services_state_from_args(args, 'lookup_old_name')
	if args.len < 2 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	old_name := state.lookup_old_name(args[1].as_string()) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.string_value(old_name)
}

// Ruby method `format_checkable(entries)` at line 159.
pub fn ruby_brew_services_l159_d15_format_checkable(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.array_value([])
	}
	return brew_services_entries_value(brew_services_format_checkable(brew_services_entries_from_value(args[0])))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "services/system"
// 5: require "utils/output"
// 6: require "bundle/brew"
// 7: require "bundle/dsl"
// 8:
// 9: module Homebrew
// 10:   module Bundle
// 11:     class Brew
// 12:       class Services < Homebrew::Bundle::Brew
// 13:         extend Utils::Output::Mixin
// 14:
// 15:         class << self
// 16:           sig { override.void }
// 17:           def reset!
// 18:             @started_services = nil
// 19:           end
// 20:
// 21:           # Action methods that return a success/failure boolean, not predicate methods.
// 22:           # rubocop:disable Naming/PredicateMethod
// 23:           sig { params(name: String, keep: T::Boolean, verbose: T::Boolean).returns(T::Boolean) }
// 24:           def stop(name, keep: false, verbose: false)
// 25:             return true unless started?(name)
// 26:
// 27:             args = ["services", "stop", name]
// 28:             args << "--keep" if keep
// 29:             return false unless Bundle.brew(*args, verbose:)
// 30:
// 31:             started_services.delete(name)
// 32:             true
// 33:           end
// 34:
// 35:           sig { params(name: String, file: T.nilable(String), verbose: T::Boolean).returns(T::Boolean) }
// 36:           def start(name, file: nil, verbose: false)
// 37:             args = ["services", "start", name]
// 38:             args << "--file=#{file}" if file
// 39:             return false unless Bundle.brew(*args, verbose:)
// 40:
// 41:             started_services << name
// 42:             true
// 43:           end
// 44:
// 45:           sig { params(name: String, file: T.nilable(T.any(Pathname, String)), verbose: T::Boolean).returns(T::Boolean) }
// 46:           def run(name, file: nil, verbose: false)
// 47:             args = ["services", "run", name]
// 48:             args << "--file=#{file}" if file
// 49:             return false unless Bundle.brew(*args, verbose:)
// 50:
// 51:             started_services << name
// 52:             true
// 53:           end
// 54:
// 55:           sig { params(name: String, file: T.nilable(String), verbose: T::Boolean).returns(T::Boolean) }
// 56:           def restart(name, file: nil, verbose: false)
// 57:             args = ["services", "restart", name]
// 58:             args << "--file=#{file}" if file
// 59:             return false unless Bundle.brew(*args, verbose:)
// 60:
// 61:             started_services << name
// 62:             true
// 63:           end
// 64:           # rubocop:enable Naming/PredicateMethod
// 65:
// 66:           sig { params(name: String).returns(T::Boolean) }
// 67:           def started?(name)
// 68:             started_services.include? name
// 69:           end
// 70:
// 71:           sig { returns(T::Array[String]) }
// 72:           def started_services_without_daemon_manager
// 73:             odie Homebrew::Services::System::MISSING_DAEMON_MANAGER_EXCEPTION_MESSAGE
// 74:           end
// 75:
// 76:           sig { returns(T::Array[String]) }
// 77:           def started_services
// 78:             @started_services ||= T.let(
// 79:               if !Homebrew::Services::System.launchctl? && !Homebrew::Services::System.systemctl?
// 80:                 started_services_without_daemon_manager
// 81:               else
// 82:                 states_to_skip = %w[stopped none]
// 83:
// 84:                 services_list = JSON.parse(Utils.safe_popen_read(HOMEBREW_BREW_FILE, "services", "list", "--json"))
// 85:                 services_list.filter_map do |hash|
// 86:                   hash.fetch("name") if states_to_skip.exclude?(hash.fetch("status"))
// 87:                 end
// 88:               end,
// 89:               T.nilable(T::Array[String]),
// 90:             )
// 91:           end
// 92:
// 93:           sig { params(name: String).returns(T.nilable(Pathname)) }
// 94:           def versioned_service_file(name)
// 95:             env_version = Bundle.formula_versions_from_env(name)
// 96:             return if env_version.nil?
// 97:
// 98:             formula = Formula[name]
// 99:             prefix = formula.rack/env_version
// 100:             return unless prefix.directory?
// 101:
// 102:             service_file = if Homebrew::Services::System.launchctl?
// 103:               prefix/"#{formula.plist_name}.plist"
// 104:             else
// 105:               prefix/"#{formula.service_name}.service"
// 106:             end
// 107:
// 108:             service_file if service_file.file?
// 109:           end
// 110:         end
// 111:
// 112:         sig { override.params(name: Object, no_upgrade: T::Boolean).returns(String) }
// 113:         def failure_reason(name, no_upgrade:)
// 114:           _ = no_upgrade
// 115:
// 116:           "Service #{name} needs to be started."
// 117:         end
// 118:
// 119:         sig { override.params(formula: Object, no_upgrade: T::Boolean).returns(T::Boolean) }
// 120:         def installed_and_up_to_date?(formula, no_upgrade: false)
// 121:           _ = no_upgrade
// 122:           entry = T.cast(formula, Homebrew::Bundle::Dsl::Entry)
// 123:
// 124:           return true unless formula_needs_to_start?(entry_to_formula(entry))
// 125:
// 126:           name = entry.name
// 127:           return true if self.class.started?(name)
// 128:
// 129:           # `brew services list` returns base names, so fall back to the last
// 130:           # path component for tap-qualified entries (e.g., "user/tap/formula").
// 131:           base_name = Utils.name_from_full_name(name)
// 132:           return true if base_name != name && self.class.started?(base_name)
// 133:
// 134:           old_name = lookup_old_name(name)
// 135:           return true if old_name && self.class.started?(old_name)
// 136:
// 137:           false
// 138:         end
// 139:
// 140:         sig { params(entry: Homebrew::Bundle::Dsl::Entry).returns(Homebrew::Bundle::Brew) }
// 141:         def entry_to_formula(entry)
// 142:           Homebrew::Bundle::Brew.new(entry.name, entry.options)
// 143:         end
// 144:
// 145:         sig { params(formula: Homebrew::Bundle::Brew).returns(T::Boolean) }
// 146:         def formula_needs_to_start?(formula)
// 147:           formula.start_service? || formula.restart_service?
// 148:         end
// 149:
// 150:         sig { params(service_name: String).returns(T.nilable(String)) }
// 151:         def lookup_old_name(service_name)
// 152:           @old_names ||= T.let(Homebrew::Bundle::Brew.formula_oldnames, T.nilable(T::Hash[String, String]))
// 153:           old_name = @old_names[service_name]
// 154:           old_name ||= @old_names[Utils.name_from_full_name(service_name)]
// 155:           old_name
// 156:         end
// 157:
// 158:         sig { params(entries: T::Array[Dsl::Entry]).returns(T::Array[Object]) }
// 159:         def format_checkable(entries)
// 160:           checkable_entries(entries)
// 161:         end
// 162:       end
// 163:     end
// 164:   end
// 165: end
// 166:
// 167: require "extend/os/bundle/brew_services"
