module services

import brew_runtime

// Translated from Homebrew/brew `services/subcommand.rb`.
// The original source is retained below until every stub has a typed V body.

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
	execution                 brew_runtime.Value
}

pub type ServicesSubcommandRunner = fn (subcommand string, args ServicesDispatchArgs, targets []ServiceFormula) !brew_runtime.Value

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
			execution: brew_runtime.object_value('NilClass', '')
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

fn services_optional_string(values map[string]brew_runtime.Value, key string) ?string {
	if value := values[key] {
		if value.type_name != 'NilClass' {
			return value.as_string()
		}
	}
	return none
}

fn services_formulae_from_value(value brew_runtime.Value) ![]ServiceFormula {
	return value.as_array()!.map(service_formula_from_value(it))
}

fn services_resolved_formulae_from_value(value brew_runtime.Value) !map[string]ServiceFormula {
	mut formulae := map[string]ServiceFormula{}
	for item in value.as_array()! {
		formula := service_formula_from_value(item)
		formulae[formula.name] = formula
	}
	return formulae
}

fn services_dispatch_args_from_value(value brew_runtime.Value) !ServicesDispatchArgs {
	values := value.as_map()!
	return ServicesDispatchArgs{
		all: (values['all'] or { brew_runtime.bool_value(false) }).as_bool()!
		sudo_service_user: services_optional_string(values, 'sudo_service_user')
		subcommand: (values['subcommand'] or { brew_runtime.string_value('list') }).as_string()
		formulae: (values['formulae'] or { brew_runtime.string_array_value([]string{}) }).as_string_array()!
	}
}

fn services_dispatch_context_from_value(value brew_runtime.Value) !ServicesDispatchContext {
	values := value.as_map()!
	return ServicesDispatchContext{
		tmux: (values['tmux'] or { brew_runtime.bool_value(false) }).as_bool()!
		pbpaste_exists: (values['pbpaste_exists'] or { brew_runtime.bool_value(false) }).as_bool()!
		pbpaste_success: (values['pbpaste_success'] or { brew_runtime.bool_value(true) }).as_bool()!
		launchctl: (values['launchctl'] or { brew_runtime.bool_value(false) }).as_bool()!
		systemctl: (values['systemctl'] or { brew_runtime.bool_value(false) }).as_bool()!
		root: (values['root'] or { brew_runtime.bool_value(false) }).as_bool()!
		installed_formulae: services_formulae_from_value(values['installed_formulae'] or {
			brew_runtime.array_value([]brew_runtime.Value{})
		})!
		resolved_formulae: services_resolved_formulae_from_value(values['resolved_formulae'] or {
			brew_runtime.array_value([]brew_runtime.Value{})
		})!
		registered_subcommands: (values['registered_subcommands'] or {
			brew_runtime.string_array_value([]string{})
		}).as_string_array()!
		homebrew_dbus_session_bus_address: services_optional_string(values, 'homebrew_dbus_session_bus_address')
		homebrew_xdg_runtime_dir: services_optional_string(values, 'homebrew_xdg_runtime_dir')
	}
}

fn services_optional_value(value ?string) brew_runtime.Value {
	return if concrete := value {
		brew_runtime.string_value(concrete)
	} else {
		brew_runtime.object_value('NilClass', '')
	}
}

fn services_dispatch_result_value(result ServicesDispatchResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'subcommand':                brew_runtime.string_value(result.subcommand)
		'targets':                   brew_runtime.array_value(result.targets.map(service_formula_value(it)))
		'warnings':                  brew_runtime.string_array_value(result.warnings)
		'sudo_service_user':         services_optional_value(result.sudo_service_user)
		'dbus_session_bus_address':  services_optional_value(result.dbus_session_bus_address)
		'xdg_runtime_dir':           services_optional_value(result.xdg_runtime_dir)
		'systemctl_environment_set': brew_runtime.bool_value(result.systemctl_environment_set)
		'exited_early':              brew_runtime.bool_value(result.exited_early)
		'execution':                 result.execution
	})
}

fn services_boundary_runner(subcommand string, _ ServicesDispatchArgs,
	targets []ServiceFormula) !brew_runtime.Value {
	return brew_runtime.map_value({
		'subcommand': brew_runtime.string_value(subcommand)
		'targets':    brew_runtime.array_value(targets.map(service_formula_value(it)))
	})
}

// Ruby method `dispatch(args)` at line 22.
pub fn ruby_subcommand_l22_d1_dispatch(args ...brew_runtime.Value) brew_runtime.Value {
	request := services_dispatch_args_from_value(if args.len > 0 {
		args[0]
	} else {
		brew_runtime.map_value(map[string]brew_runtime.Value{})
	}) or { return brew_runtime.object_value('ArgumentError', err.msg()) }
	context := services_dispatch_context_from_value(if args.len > 1 {
		args[1]
	} else {
		brew_runtime.map_value(map[string]brew_runtime.Value{})
	}) or { return brew_runtime.object_value('ArgumentError', err.msg()) }
	result := dispatch_services(request, context, services_boundary_runner) or {
		return brew_runtime.object_value('UsageError', err.msg())
	}
	return services_dispatch_result_value(result)
}

// Ruby method `targets(args, subcommand:, formulae:)` at line 76.
pub fn ruby_subcommand_l76_d2_targets(args ...brew_runtime.Value) brew_runtime.Value {
	request := services_dispatch_args_from_value(if args.len > 0 {
		args[0]
	} else {
		brew_runtime.map_value(map[string]brew_runtime.Value{})
	}) or { return brew_runtime.object_value('ArgumentError', err.msg()) }
	context := services_dispatch_context_from_value(if args.len > 1 {
		args[1]
	} else {
		brew_runtime.map_value(map[string]brew_runtime.Value{})
	}) or { return brew_runtime.object_value('ArgumentError', err.msg()) }
	targets := services_subcommand_targets(request, context) or {
		return brew_runtime.object_value('FormulaUnavailableError', err.msg())
	}
	return brew_runtime.array_value(targets.map(service_formula_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5: require "cli/parser"
// 6: require "services/cli"
// 7: require "services/formulae"
// 8: require "services/system"
// 9: require "utils/output"
// 10:
// 11: Dir["#{__dir__}/subcommand/*.rb"].each do |subcommand|
// 12:   require "services/subcommand/#{File.basename(subcommand, ".rb")}"
// 13: end
// 14:
// 15: module Homebrew
// 16:   module Cmd
// 17:     class Services < Homebrew::AbstractCommand
// 18:       extend Utils::Output::Mixin
// 19:
// 20:       class << self
// 21:         sig { params(args: T.untyped).void }
// 22:         def dispatch(args)
// 23:           # pbpaste's exit status is a proxy for detecting the use of reattach-to-user-namespace
// 24:           if ENV.fetch("HOMEBREW_TMUX", nil) && File.exist?("/usr/bin/pbpaste") && !quiet_system("/usr/bin/pbpaste")
// 25:             raise UsageError,
// 26:                   "`brew services` cannot run under tmux!"
// 27:           end
// 28:
// 29:           # Keep this after the .parse to keep --help fast.
// 30:           require "utils"
// 31:
// 32:           if !Homebrew::Services::System.launchctl? && !Homebrew::Services::System.systemctl?
// 33:             raise UsageError, Homebrew::Services::System::MISSING_DAEMON_MANAGER_EXCEPTION_MESSAGE
// 34:           end
// 35:
// 36:           if (sudo_service_user = args.sudo_service_user)
// 37:             unless Homebrew::Services::System.root?
// 38:               raise UsageError,
// 39:                     "`brew services --sudo-service-user` is supported only when running as root!"
// 40:             end
// 41:
// 42:             unless Homebrew::Services::System.launchctl?
// 43:               raise UsageError,
// 44:                     "`brew services --sudo-service-user` is currently supported only on macOS " \
// 45:                     "(but we'd love a PR to add Linux support)!"
// 46:             end
// 47:
// 48:             Homebrew::Services::Cli.sudo_service_user = sudo_service_user
// 49:           end
// 50:
// 51:           subcommand = args.subcommand
// 52:           formulae = args.named
// 53:
// 54:           opoo "The `--all` argument overrides provided formula argument!" if formulae.present? && args.all?
// 55:
// 56:           targets = targets(args, subcommand:, formulae:)
// 57:
// 58:           # Exit successfully if --all was used but there is nothing to do
// 59:           return if args.all? && targets.empty?
// 60:
// 61:           if Homebrew::Services::System.systemctl?
// 62:             ENV["DBUS_SESSION_BUS_ADDRESS"] = ENV.fetch("HOMEBREW_DBUS_SESSION_BUS_ADDRESS", nil)
// 63:             ENV["XDG_RUNTIME_DIR"] = ENV.fetch("HOMEBREW_XDG_RUNTIME_DIR", nil)
// 64:           end
// 65:
// 66:           subcommand_class = Homebrew::AbstractSubcommand.subcommands_for(Homebrew::Cmd::Services).find do |candidate|
// 67:             candidate.subcommand_name == subcommand
// 68:           end
// 69:           T.must(subcommand_class).new(args, targets:).run
// 70:         end
// 71:
// 72:         sig {
// 73:           params(args: T.untyped, subcommand: String,
// 74:                  formulae: T::Array[String]).returns(T::Array[Homebrew::Services::FormulaWrapper])
// 75:         }
// 76:         def targets(args, subcommand:, formulae:)
// 77:           if args.all?
// 78:             if subcommand == "start"
// 79:               Homebrew::Services::Formulae.available_services(
// 80:                 loaded:    false,
// 81:                 skip_root: !Homebrew::Services::System.root?,
// 82:               )
// 83:             elsif subcommand == "stop"
// 84:               Homebrew::Services::Formulae.available_services(
// 85:                 loaded:    true,
// 86:                 skip_root: !Homebrew::Services::System.root?,
// 87:               )
// 88:             else
// 89:               Homebrew::Services::Formulae.available_services
// 90:             end
// 91:           elsif formulae.present?
// 92:             formulae.map { |formula| Homebrew::Services::FormulaWrapper.new(Formulary.factory(formula)) }
// 93:           else
// 94:             []
// 95:           end
// 96:         end
// 97:       end
// 98:     end
// 99:   end
// 100: end
