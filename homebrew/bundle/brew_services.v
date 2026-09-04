module bundle

import ruby
import json2
import os

// Translated from Homebrew/brew `bundle/brew_services.rb`.
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

fn brew_services_entry_from_value(value ruby.Value) BundleDslEntry {
	return BundleDslEntry{
		entry_type: value.attributes['type'] or { 'brew' }
		name: value.attributes['name'] or { value.repr }
		options: value.map_data.clone()
	}
}

pub fn brew_services_entry_to_formula(entry BundleDslEntry) BundleBrewInstaller {
	return bundle_brew_installer(entry.name, bundle_brew_options_from_value(ruby.map_value(entry.options)))
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

fn brew_services_entries_from_value(value ruby.Value) []BundleDslEntry {
	return value.as_array() or { [] }.map(brew_services_entry_from_value(it))
}

fn brew_services_entries_value(entries []BundleDslEntry) ruby.Value {
	return ruby.array_value(entries.map(bundle_dsl_entry_value(it)))
}

fn brew_services_state_value(state &BrewServicesState) ruby.Value {
	return ruby.structured_value('Homebrew::Bundle::Brew::Services', '', {
		'brew_services_state_address': u64(voidptr(state)).str()
	})
}

pub fn brew_services_state_boundary(state &BrewServicesState) ruby.Value {
	return brew_services_state_value(state)
}

fn brew_services_state_from_args(args []ruby.Value, method string) &BrewServicesState {
	if args.len == 0 || 'brew_services_state_address' !in args[0].attributes {
		panic('Brew::Services.${method} requires translated BrewServices state')
	}
	return unsafe { &BrewServicesState(voidptr(args[0].attributes['brew_services_state_address'].u64())) }
}

fn brew_services_error(type_name string, message string) ruby.Value {
	return ruby.structured_value(type_name, message, {
		'message': message
	})
}

fn brew_services_optional_string(args []ruby.Value, index int) string {
	if index >= args.len || args[index].type_name in ['Nil', 'NilClass'] {
		return ''
	}
	return args[index].as_string()
}
