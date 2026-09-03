module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/services.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ServicesCommandResult {
pub:
	subcommand string
	named      []string
	options    map[string]string
	output     string
}

pub fn services_canonical_subcommand(value string) string {
	return match value {
		'', 'l', 'list' { 'list' }
		'i', 'info' { 'info' }
		'start' { 'start' }
		'stop' { 'stop' }
		'run' { 'run' }
		'restart' { 'restart' }
		'kill' { 'kill' }
		else { value }
	}
}

pub fn services_all_description(subcommand string) ?string {
	return match services_canonical_subcommand(subcommand) {
		'start' { 'Start all services and register them to launch at login (or boot).' }
		'stop' {
			'Stop all services and unregister them from launching at login (or boot), unless `--keep` is specified.'
		}
		'run' { 'Run all services without registering them to launch at login (or boot).' }
		'restart' { 'Restart all services.' }
		'kill' {
			'Stop all services immediately but keep them registered to launch at login (or boot).'
		}
		'info' { 'List all managed services.' }
		else { none }
	}
}

pub fn run_services_command(argv []string) !ServicesCommandResult {
	subcommand := services_canonical_subcommand(if argv.len > 0 { argv[0] } else { '' })
	if subcommand !in ['list', 'info', 'start', 'stop', 'run', 'restart', 'kill'] {
		return error('Unknown services subcommand `${subcommand}`')
	}
	mut named := []string{}
	mut options := map[string]string{}
	argument_start := if argv.len > 0 { 1 } else { 0 }
	for argument in argv[argument_start..] {
		if argument.starts_with('--') {
			if argument.contains('=') {
				options[argument.all_before('=')] = argument.all_after('=')
			} else {
				options[argument] = 'true'
			}
		} else {
			named << argument
		}
	}
	if subcommand == 'info' && '--file' in options {
		return error('`info` subcommand does not accept the `--file` flag')
	}
	if '--all' in options && '--file' in options {
		return error('options `--all` and `--file` are mutually exclusive')
	}
	if '--max-wait' in options && '--no-wait' in options {
		return error('options `--max-wait` and `--no-wait` are mutually exclusive')
	}
	return ServicesCommandResult{
		subcommand: subcommand
		named: named
		options: options
	}
}

pub fn services_result_to_value(result ServicesCommandResult) brew_runtime.Value {
	mut options := map[string]brew_runtime.Value{}
	for name, value in result.options {
		options[name] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value({
		'subcommand': brew_runtime.string_value(result.subcommand)
		'named':      brew_runtime.string_array_value(result.named)
		'options':    brew_runtime.map_value(options)
		'output':     brew_runtime.string_value(result.output)
	})
}

// Ruby method `run` at line 37.
pub fn ruby_services_l37_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	argv := if args.len > 0 { args[0].as_string_array() or { []string{} } } else { []string{} }
	result := run_services_command(argv) or {
		return brew_runtime.object_value('UsageError', err.msg())
	}
	return services_result_to_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class Services < AbstractCommand
// 9:       require "services/subcommand"
// 10:
// 11:       cmd_args do
// 12:         usage_banner <<~EOS
// 13:           `services` [<subcommand>]
// 14:
// 15:           Manage background services with macOS' `launchctl`(1) daemon manager or
// 16:           Linux's `systemctl`(1) service manager.
// 17:
// 18:           If `sudo` is passed, operate on `/Library/LaunchDaemons` or `/usr/lib/systemd/system` (started at boot).
// 19:           Otherwise, operate on `~/Library/LaunchAgents` or `~/.config/systemd/user` (started at login).
// 20:
// 21:           Environment variables can be added or overridden for a service by creating
// 22:           `$HOMEBREW_USER_CONFIG_HOME/services/<formula>.env` (defaults to
// 23:           `~/.homebrew/services/<formula>.env`). The file uses `KEY=value`
// 24:           format, one per line; lines starting with `#` are comments. Changes take
// 25:           effect on the next `brew services restart` and persist across upgrades.
// 26:         EOS
// 27:         flag   "--sudo-service-user=",
// 28:                description: "When run as root on macOS, run the service(s) as this user."
// 29:
// 30:         Homebrew::AbstractSubcommand.define_all(self, command: Homebrew::Cmd::Services)
// 31:
// 32:         conflicts "--all", "--file"
// 33:         conflicts "--max-wait", "--no-wait"
// 34:       end
// 35:
// 36:       sig { override.void }
// 37:       def run
// 38:         Homebrew::Cmd::Services.dispatch(args)
// 39:       end
// 40:     end
// 41:   end
// 42: end
