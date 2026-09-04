module subcommand

import ruby

// Translated from Homebrew/brew `services/subcommand/cleanup.rb`.
pub struct ServiceSubcommandTarget {
pub:
	name                 string
	loaded               bool
	service_file_present bool
}

pub struct ServiceSubcommandRequest {
pub:
	targets  []ServiceSubcommandTarget
	file     ?string
	verbose  bool
	no_wait  bool
	max_wait f64 = 60.0
	keep     bool
	root     bool
	orphaned []string
	unused   []string
}

pub struct ServiceSubcommandResult {
pub:
	operation string
	checked   []string
	cleaned   []string
	stopped   []string
	started   []string
	ran       []string
	killed    []string
	file      ?string
	verbose   bool
	no_wait   bool
	max_wait  f64
	keep      bool
	output    string
}

pub fn service_target_names(targets []ServiceSubcommandTarget) []string {
	return targets.map(it.name)
}

pub fn service_subcommand_check(request ServiceSubcommandRequest) ![]string {
	if request.targets.len == 0 {
		return error('A service target or `--all` is required.')
	}
	if request.targets.any(it.name == '') {
		return error('Service target names must not be empty.')
	}
	return service_target_names(request.targets)
}

pub fn service_cleanup(request ServiceSubcommandRequest) ServiceSubcommandResult {
	mut cleaned := []string{}
	for name in request.orphaned {
		if name !in cleaned {
			cleaned << name
		}
	}
	for name in request.unused {
		if name !in cleaned {
			cleaned << name
		}
	}
	service_type := if request.root { 'root' } else { 'user-space' }
	return ServiceSubcommandResult{
		operation: 'cleanup'
		cleaned: cleaned
		output: if cleaned.len == 0 {
			'All ${service_type} services OK, nothing cleaned...\n'
		} else {
			''
		}
	}
}

pub fn service_simple_operation(operation string, request ServiceSubcommandRequest) !ServiceSubcommandResult {
	checked := service_subcommand_check(request)!
	return match operation {
		'kill' {
			ServiceSubcommandResult{
				operation: operation
				checked: checked
				killed: checked.clone()
				verbose: request.verbose
			}
		}
		'run' {
			ServiceSubcommandResult{
				operation: operation
				checked: checked
				ran: checked.clone()
				file: request.file
				verbose: request.verbose
			}
		}
		'start' {
			ServiceSubcommandResult{
				operation: operation
				checked: checked
				started: checked.clone()
				file: request.file
				verbose: request.verbose
			}
		}
		'stop' {
			ServiceSubcommandResult{
				operation: operation
				checked: checked
				stopped: checked.clone()
				verbose: request.verbose
				no_wait: request.no_wait
				max_wait: request.max_wait
				keep: request.keep
			}
		}
		else {
			return error('Unsupported service operation `${operation}`')
		}
	}
}

pub fn service_restart(request ServiceSubcommandRequest) !ServiceSubcommandResult {
	if request.targets.len == 0 {
		return error('Invalid usage: Formula(e) missing, please provide a formula name or use `--all`.')
	}
	checked := service_subcommand_check(request)!
	mut stopped := []string{}
	mut started := []string{}
	mut ran := []string{}
	for service in request.targets {
		if service.loaded {
			stopped << service.name
		}
		if service.loaded && !service.service_file_present {
			ran << service.name
		} else {
			started << service.name
		}
	}
	return ServiceSubcommandResult{
		operation: 'restart'
		checked: checked
		stopped: stopped
		started: started
		ran: ran
		file: request.file
		verbose: request.verbose
	}
}

pub fn service_subcommand_request_from_args(args []ruby.Value) !ServiceSubcommandRequest {
	if args.len == 0 {
		return ServiceSubcommandRequest{}
	}
	values := args[0].as_map()!
	target_values := if value := values['targets'] {
		value.as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	mut targets := []ServiceSubcommandTarget{}
	for value in target_values {
		targets << ServiceSubcommandTarget{
			name: value.attributes['name'] or { value.as_string() }
			loaded: (value.attributes['loaded'] or { 'false' }) == 'true'
			service_file_present: (value.attributes['service_file_present'] or { 'true' }) == 'true'
		}
	}
	mut file := ?string(none)
	if value := values['file'] {
		if value.type_name != 'NilClass' && value.as_string() != '' {
			file = value.as_string()
		}
	}
	return ServiceSubcommandRequest{
		targets: targets
		file: file
		verbose: if value := values['verbose'] { value.as_bool() or { false } } else { false }
		no_wait: if value := values['no_wait'] { value.as_bool() or { false } } else { false }
		max_wait: if value := values['max_wait'] { value.as_float() or { 60.0 } } else { 60.0 }
		keep: if value := values['keep'] { value.as_bool() or { false } } else { false }
		root: if value := values['root'] { value.as_bool() or { false } } else { false }
		orphaned: if value := values['orphaned'] {
			value.as_string_array() or { []string{} }
		} else {
			[]string{}
		}
		unused: if value := values['unused'] {
			value.as_string_array() or { []string{} }
		} else {
			[]string{}
		}
	}
}

pub fn service_subcommand_result_to_value(result ServiceSubcommandResult) ruby.Value {
	return ruby.map_value({
		'operation': ruby.string_value(result.operation)
		'checked':   ruby.string_array_value(result.checked)
		'cleaned':   ruby.string_array_value(result.cleaned)
		'stopped':   ruby.string_array_value(result.stopped)
		'started':   ruby.string_array_value(result.started)
		'ran':       ruby.string_array_value(result.ran)
		'killed':    ruby.string_array_value(result.killed)
		'output':    ruby.string_value(result.output)
		'no_wait':   ruby.bool_value(result.no_wait)
		'max_wait':  ruby.float_value(result.max_wait)
		'keep':      ruby.bool_value(result.keep)
	})
}
