module subcommand

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
