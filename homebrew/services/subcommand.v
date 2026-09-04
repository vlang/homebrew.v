module services

import ruby

// Translated from Homebrew/brew `services/subcommand.rb`.

pub struct ServicesDispatchArgs {
pub:
	all               bool
	sudo_service_user ?string
	subcommand        string
	formulae          []string
}

pub struct ServicesDispatchContext {
pub:
	tmux                              bool
	pbpaste_exists                    bool
	pbpaste_success                   bool = true
	launchctl                         bool
	systemctl                         bool
	root                              bool
	installed_formulae                []ServiceFormula
	resolved_formulae                 map[string]ServiceFormula
	registered_subcommands            []string
	homebrew_dbus_session_bus_address ?string
	homebrew_xdg_runtime_dir          ?string
}

pub struct ServicesDispatchResult {
pub:
	subcommand                string
	targets                   []ServiceFormula
	warnings                  []string
	sudo_service_user         ?string
	dbus_session_bus_address  ?string
	xdg_runtime_dir           ?string
	systemctl_environment_set bool
	exited_early              bool
	execution                 ruby.Value
}

pub type ServicesSubcommandRunner = fn (subcommand string, args ServicesDispatchArgs, targets []ServiceFormula) !ruby.Value

fn services_registered_subcommands(context ServicesDispatchContext) []string {
	if context.registered_subcommands.len > 0 {
		return context.registered_subcommands.clone()
	}
	// These are the classes loaded by the Dir glob at lines 11-13 of the retained source.
	return ['cleanup', 'info', 'kill', 'list', 'restart', 'run', 'start', 'stop']
}

pub fn services_subcommand_targets(args ServicesDispatchArgs, context ServicesDispatchContext) ![]ServiceFormula {
	if args.all {
		if args.subcommand == 'start' {
			return available_services(context.installed_formulae, false, !context.root)
		}
		if args.subcommand == 'stop' {
			return available_services(context.installed_formulae, true, !context.root)
		}
		return available_services(context.installed_formulae, none, false)
	}
	if args.formulae.len == 0 {
		return []ServiceFormula{}
	}
	mut targets := []ServiceFormula{cap: args.formulae.len}
	for name in args.formulae {
		formula := context.resolved_formulae[name] or {
			return error('No formula resolved for `${name}`')
		}
		targets << formula
	}
	return targets
}

pub fn dispatch_services(args ServicesDispatchArgs, context ServicesDispatchContext,
	runner ServicesSubcommandRunner) !ServicesDispatchResult {
	// pbpaste's exit status is a proxy for detecting the use of reattach-to-user-namespace
	if context.tmux && context.pbpaste_exists && !context.pbpaste_success {
		return error('`brew services` cannot run under tmux!')
	}

	// Keep this after the .parse to keep --help fast.
	if !context.launchctl && !context.systemctl {
		return error(missing_daemon_manager_exception_message)
	}

	if sudo_service_user := args.sudo_service_user {
		if !context.root {
			return error('`brew services --sudo-service-user` is supported only when running as root!')
		}
		if !context.launchctl {
			return error("`brew services --sudo-service-user` is currently supported only on macOS (but we'd love a PR to add Linux support)!")
		}
		_ = sudo_service_user
	}

	mut warnings := []string{}
	if args.formulae.len > 0 && args.all {
		warnings << 'The `--all` argument overrides provided formula argument!'
	}
	targets := services_subcommand_targets(args, context)!

	// Exit successfully if --all was used but there is nothing to do
	if args.all && targets.len == 0 {
		return ServicesDispatchResult{
			subcommand: args.subcommand
			targets: targets
			warnings: warnings
			sudo_service_user: args.sudo_service_user
			exited_early: true
			execution: ruby.object_value('NilClass', '')
		}
	}

	if args.subcommand !in services_registered_subcommands(context) {
		return error('No services subcommand registered for `${args.subcommand}`')
	}
	execution := runner(args.subcommand, args, targets)!
	return ServicesDispatchResult{
		subcommand: args.subcommand
		targets: targets
		warnings: warnings
		sudo_service_user: args.sudo_service_user
		dbus_session_bus_address: if context.systemctl {
			context.homebrew_dbus_session_bus_address
		} else {
			none
		}
		xdg_runtime_dir: if context.systemctl {
			context.homebrew_xdg_runtime_dir
		} else {
			none
		}
		systemctl_environment_set: context.systemctl
		execution: execution
	}
}

fn services_optional_string(values map[string]ruby.Value, key string) ?string {
	if value := values[key] {
		if value.type_name != 'NilClass' {
			return value.as_string()
		}
	}
	return none
}

fn services_formulae_from_value(value ruby.Value) ![]ServiceFormula {
	return value.as_array()!.map(service_formula_from_value(it))
}

fn services_resolved_formulae_from_value(value ruby.Value) !map[string]ServiceFormula {
	mut formulae := map[string]ServiceFormula{}
	for item in value.as_array()! {
		formula := service_formula_from_value(item)
		formulae[formula.name] = formula
	}
	return formulae
}

fn services_dispatch_args_from_value(value ruby.Value) !ServicesDispatchArgs {
	values := value.as_map()!
	return ServicesDispatchArgs{
		all: (values['all'] or { ruby.bool_value(false) }).as_bool()!
		sudo_service_user: services_optional_string(values, 'sudo_service_user')
		subcommand: (values['subcommand'] or { ruby.string_value('list') }).as_string()
		formulae: (values['formulae'] or { ruby.string_array_value([]string{}) }).as_string_array()!
	}
}

fn services_dispatch_context_from_value(value ruby.Value) !ServicesDispatchContext {
	values := value.as_map()!
	return ServicesDispatchContext{
		tmux: (values['tmux'] or { ruby.bool_value(false) }).as_bool()!
		pbpaste_exists: (values['pbpaste_exists'] or { ruby.bool_value(false) }).as_bool()!
		pbpaste_success: (values['pbpaste_success'] or { ruby.bool_value(true) }).as_bool()!
		launchctl: (values['launchctl'] or { ruby.bool_value(false) }).as_bool()!
		systemctl: (values['systemctl'] or { ruby.bool_value(false) }).as_bool()!
		root: (values['root'] or { ruby.bool_value(false) }).as_bool()!
		installed_formulae: services_formulae_from_value(values['installed_formulae'] or {
			ruby.array_value([]ruby.Value{})
		})!
		resolved_formulae: services_resolved_formulae_from_value(values['resolved_formulae'] or {
			ruby.array_value([]ruby.Value{})
		})!
		registered_subcommands: (values['registered_subcommands'] or {
			ruby.string_array_value([]string{})
		}).as_string_array()!
		homebrew_dbus_session_bus_address: services_optional_string(values, 'homebrew_dbus_session_bus_address')
		homebrew_xdg_runtime_dir: services_optional_string(values, 'homebrew_xdg_runtime_dir')
	}
}

fn services_optional_value(value ?string) ruby.Value {
	return if concrete := value {
		ruby.string_value(concrete)
	} else {
		ruby.object_value('NilClass', '')
	}
}

fn services_dispatch_result_value(result ServicesDispatchResult) ruby.Value {
	return ruby.map_value({
		'subcommand':                ruby.string_value(result.subcommand)
		'targets':                   ruby.array_value(result.targets.map(service_formula_value(it)))
		'warnings':                  ruby.string_array_value(result.warnings)
		'sudo_service_user':         services_optional_value(result.sudo_service_user)
		'dbus_session_bus_address':  services_optional_value(result.dbus_session_bus_address)
		'xdg_runtime_dir':           services_optional_value(result.xdg_runtime_dir)
		'systemctl_environment_set': ruby.bool_value(result.systemctl_environment_set)
		'exited_early':              ruby.bool_value(result.exited_early)
		'execution':                 result.execution
	})
}

fn services_boundary_runner(subcommand string, _ ServicesDispatchArgs,
	targets []ServiceFormula) !ruby.Value {
	return ruby.map_value({
		'subcommand': ruby.string_value(subcommand)
		'targets':    ruby.array_value(targets.map(service_formula_value(it)))
	})
}
