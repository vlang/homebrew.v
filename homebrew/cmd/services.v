module cmd

import ruby

// Translated from Homebrew/brew `cmd/services.rb`.
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

pub fn services_result_to_value(result ServicesCommandResult) ruby.Value {
	mut options := map[string]ruby.Value{}
	for name, value in result.options {
		options[name] = ruby.string_value(value)
	}
	return ruby.map_value({
		'subcommand': ruby.string_value(result.subcommand)
		'named':      ruby.string_array_value(result.named)
		'options':    ruby.map_value(options)
		'output':     ruby.string_value(result.output)
	})
}
