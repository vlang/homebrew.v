module subcommand

import ruby
import homebrew.extend.env

// Translated from Homebrew/brew `bundle/subcommand/exec.rb`.

pub struct BundleExecDependency {
pub:
	name       string
	opt_prefix string
	version    string
	keg_only   bool
	installed  bool = true
}

pub struct BundleExecConflictingService {
pub:
	name       string
	running    bool
	registered bool
}

pub struct BundleExecServiceInfo {
pub:
	entry_name     string
	formula_name   string
	installed      bool = true
	info_available bool = true
	service_file   string
	loaded_file    string
	running        bool
	loaded         bool
	registered     bool
	launchctl      bool
	conflicts      []BundleExecConflictingService
}

// BundleExecContext is an immutable snapshot of Brewfile dependencies and all
// environment/executable/service discovery required by the workflow.
pub struct BundleExecContext {
pub:
	argv                      []string
	subcommand                string
	options                   BundleExecSubcommandOptions
	sandbox_path              ?string
	deny_network              bool
	environment               map[string]string
	original_environment      map[string]string
	dependencies              []BundleExecDependency
	missing_dependencies      []string
	services                  []BundleExecServiceInfo
	available_commands        map[string]string
	unwritable_temp_paths     []string
	home_directory            string
	shell_path                string
	all_dependencies_keg_only bool
}

pub struct BundleExecPlan {
pub:
	argv            []string
	environment     map[string]string
	env_output      string
	sandbox_path    ?string
	deny_network    bool
	check_performed bool
	services        bool
	execute         bool
}

pub enum BundleExecServiceOperationKind {
	stop
	run
	restart
}

pub struct BundleExecServiceOperation {
pub:
	kind BundleExecServiceOperationKind
	name string
	file string
	keep bool
}

pub struct BundleExecRuntime {
pub mut:
	command_plans             []BundleExecPlan
	service_operations        []BundleExecServiceOperation
	warnings                  []string
	command_exit_code         int
	command_error             string
	failed_service_operations []string
}

pub struct BundleExecResult {
pub:
	plan      BundleExecPlan
	exit_code int
}

pub struct BundleExecServiceLifecycle {
pub:
	services_to_stop    []string
	services_to_restart []string
}

pub type BundleExecCommandBoundary = fn (mut runtime BundleExecRuntime, plan BundleExecPlan) !int

pub type BundleExecServiceBoundary = fn (mut runtime BundleExecRuntime, operation BundleExecServiceOperation) bool

pub fn build_bundle_exec_plan(context BundleExecContext) !BundleExecPlan {
	if context.options.check && context.missing_dependencies.len > 0 {
		return error("brew bundle can't satisfy your Brewfile's dependencies: ${context.missing_dependencies.join(', ')}")
	}
	if context.argv.len == 0 || context.argv[0].trim_space().len == 0 {
		return error('No command to execute was specified!')
	}
	if sandbox := context.sandbox_path {
		if sandbox.len == 0 {
			return error('`--sandbox` requires a writable path.')
		}
	} else if context.deny_network {
		return error('`--deny-network` requires `--sandbox`.')
	}
	mut environment := context.environment.clone()
	if context.options.no_secrets {
		env.clear_sensitive_environment(mut environment, [], false)
	}
	environment['HOMEBREW_INSIDE_BUNDLE'] = '1'
	environment.delete('HOMEBREW_BUNDLE_EXEC_ALL_KEG_ONLY_DEPS')
	for variable in ['HOMEBREW_TEMP', 'TMPDIR', 'HOMEBREW_TMPDIR'] {
		if value := environment[variable] {
			if value in context.unwritable_temp_paths {
				environment.delete(variable)
			}
		}
	}
	environment_before_path_cleanup := environment.clone()
	for key, value in environment_before_path_cleanup {
		if key.contains('PATH') && value.contains(':') {
			environment[key] = value.split(':').filter(!it.contains('/Homebrew/shims/')).join(':')
		}
	}
	for dependency in context.dependencies.reverse() {
		if !dependency.installed {
			continue
		}
		environment['PATH'] = prepend_bundle_exec_path(environment['PATH'] or { '' }, ruby.join_path(dependency.opt_prefix, 'bin'))
		if context.all_dependencies_keg_only || dependency.keg_only {
			environment['PKG_CONFIG_PATH'] = prepend_bundle_exec_path(environment['PKG_CONFIG_PATH'] or {
				''
			}, ruby.join_path(dependency.opt_prefix, 'lib/pkgconfig'))
			environment['CPPFLAGS'] = append_bundle_exec_flag(environment['CPPFLAGS'] or { '' }, '-I${ruby.join_path(dependency.opt_prefix, 'include')}')
			environment['LDFLAGS'] = append_bundle_exec_flag(environment['LDFLAGS'] or { '' }, '-L${ruby.join_path(dependency.opt_prefix, 'lib')}')
		}
		if dependency.name in ['nodenv', 'pyenv', 'rbenv'] {
			root_key := 'HOMEBREW_${dependency.name.to_upper()}_ROOT'
			root := environment[root_key] or {
				ruby.join_path(context.home_directory, '.${dependency.name}')
			}
			environment['PATH'] = prepend_bundle_exec_path(environment['PATH'] or { '' }, ruby.join_path(root, 'shims'))
		}
		if dependency.version.len > 0 {
			rewrite_bundle_exec_dependency_version(mut environment, dependency)
		}
	}
	if homebrew_path := environment['HOMEBREW_PATH'] {
		environment['PATH'] = append_bundle_exec_path(environment['PATH'] or { '' }, homebrew_path)
	}
	mut argv := context.argv.clone()
	mut execute := true
	mut env_output := ''
	if context.subcommand == 'env' {
		env_output = render_bundle_exec_environment(environment, context.original_environment)
		execute = false
	} else if context.subcommand == 'sh' {
		argv = [
			if context.shell_path.len > 0 { context.shell_path } else { '/bin/bash' },
		]
		environment.delete('HOMEBREW_FORCE_API_AUTO_UPDATE')
	} else {
		command := argv[0]
		if !command.contains('/') {
			command_path := context.available_commands[command] or {
				return error('command was not found in your PATH: ${command}')
			}
			environment['PATH'] = prepend_bundle_exec_path(environment['PATH'] or { '' }, bundle_exec_dirname(command_path))
		}
	}
	return BundleExecPlan{
		argv: argv
		environment: environment
		env_output: env_output
		sandbox_path: context.sandbox_path
		deny_network: context.deny_network
		check_performed: context.options.check
		services: context.options.services
		execute: execute
	}
}

pub fn execute_bundle_exec(context BundleExecContext, mut runtime BundleExecRuntime,
	command_boundary BundleExecCommandBoundary,
	service_boundary BundleExecServiceBoundary) !BundleExecResult {
	plan := build_bundle_exec_plan(context)!
	if !plan.execute {
		return BundleExecResult{
			plan: plan
		}
	}
	mut lifecycle := BundleExecServiceLifecycle{}
	if context.options.services {
		services := map_service_info(context.services)!
		lifecycle = start_bundle_exec_services(services, mut runtime, service_boundary)
	}
	defer {
		if context.options.services {
			cleanup_bundle_exec_services(lifecycle, mut runtime, service_boundary)
		}
	}
	exit_code := command_boundary(mut runtime, plan)!
	return BundleExecResult{
		plan: plan
		exit_code: exit_code
	}
}

pub fn map_service_info(entries []BundleExecServiceInfo) ![]BundleExecServiceInfo {
	mut result := []BundleExecServiceInfo{}
	for entry in entries {
		if !entry.installed || entry.service_file.len == 0 {
			continue
		}
		if !entry.info_available {
			return error('Failed to get service info for ${entry.entry_name}')
		}
		result << entry
	}
	return result
}

pub fn start_bundle_exec_services(entries []BundleExecServiceInfo, mut runtime BundleExecRuntime,
	boundary BundleExecServiceBoundary) BundleExecServiceLifecycle {
	mut services_to_stop := []string{}
	mut services_to_restart := []string{}
	for entry in entries {
		if entry.running && entry.loaded_file.len > 0 && entry.loaded_file == entry.service_file {
			continue
		}
		if entry.running && !boundary(mut runtime, BundleExecServiceOperation{
			kind: .stop
			name: entry.formula_name
			keep: true
		}) {
			runtime.warnings << 'Failed to stop ${entry.formula_name} service'
		}
		for conflict in entry.conflicts {
			if !conflict.running {
				continue
			}
			if boundary(mut runtime, BundleExecServiceOperation{
				kind: .stop
				name: conflict.name
				keep: true
			}) {
				if conflict.registered {
					services_to_restart << conflict.name
				}
			} else {
				runtime.warnings << 'Failed to stop ${conflict.name} service'
			}
		}
		if !boundary(mut runtime, BundleExecServiceOperation{
			kind: .run
			name: entry.formula_name
			file: entry.service_file
		}) {
			runtime.warnings << 'Failed to start ${entry.formula_name} service'
		}
		services_to_stop << entry.formula_name
	}
	return BundleExecServiceLifecycle{
		services_to_stop: bundle_exec_unique(services_to_stop)
		services_to_restart: bundle_exec_unique(services_to_restart)
	}
}

pub fn cleanup_bundle_exec_services(lifecycle BundleExecServiceLifecycle,
	mut runtime BundleExecRuntime, boundary BundleExecServiceBoundary) {
	for service in lifecycle.services_to_stop {
		if !boundary(mut runtime, BundleExecServiceOperation{
			kind: .stop
			name: service
			keep: true
		}) {
			runtime.warnings << 'Failed to stop ${service} service'
		}
	}
	for service in lifecycle.services_to_restart {
		if !boundary(mut runtime, BundleExecServiceOperation{
			kind: .restart
			name: service
		}) {
			runtime.warnings << 'Failed to restart ${service} service'
		}
	}
}

pub fn stop_bundle_exec_services(entries []BundleExecServiceInfo, mut runtime BundleExecRuntime,
	boundary BundleExecServiceBoundary) {
	for entry in entries {
		if !entry.loaded || !entry.running || (entry.launchctl && entry.registered) {
			continue
		}
		if !boundary(mut runtime, BundleExecServiceOperation{
			kind: .stop
			name: entry.formula_name
			keep: true
		}) {
			runtime.warnings << 'Failed to stop ${entry.formula_name} service'
		}
	}
}

pub fn recording_bundle_exec_command(mut runtime BundleExecRuntime, plan BundleExecPlan) !int {
	runtime.command_plans << plan
	if runtime.command_error.len > 0 {
		return error(runtime.command_error)
	}
	return runtime.command_exit_code
}

pub fn recording_bundle_exec_service(mut runtime BundleExecRuntime,
	operation BundleExecServiceOperation) bool {
	runtime.service_operations << operation
	return '${operation.kind}:${operation.name}' !in runtime.failed_service_operations
}

fn prepend_bundle_exec_path(current string, value string) string {
	if value.len == 0 {
		return current
	}
	values := current.split(':').filter(it.len > 0 && it != value)
	return if values.len == 0 { value } else { '${value}:${values.join(':')}' }
}

fn append_bundle_exec_path(current string, value string) string {
	if value.len == 0 {
		return current
	}
	mut values := current.split(':').filter(it.len > 0 && it != value)
	values << value
	return values.join(':')
}

fn append_bundle_exec_flag(current string, value string) string {
	return if current.trim_space().len == 0 { value } else { '${current} ${value}' }
}

fn rewrite_bundle_exec_dependency_version(mut environment map[string]string,
	dependency BundleExecDependency) {
	needle := '/opt/${dependency.name}'
	replacement := '/Cellar/${dependency.name}/${dependency.version}'
	environment_before_rewrite := environment.clone()
	for key, value in environment_before_rewrite {
		if value.contains(needle) {
			environment[key] = value.replace(needle, replacement)
		}
	}
}

fn render_bundle_exec_environment(environment map[string]string,
	original map[string]string) string {
	mut keys := environment.keys()
	keys.sort()
	mut lines := []string{}
	for key in keys {
		if key.starts_with('HOMEBREW_') || key.starts_with('PORTABLE_RUBY_') {
			continue
		}
		value := environment[key]
		if value.trim_space().len == 0 || original[key] or { '' } == value {
			continue
		}
		if key.contains('PATH') && value.contains(':') {
			old_values := (original[key] or { '' }).split(':')
			new_values := value.split(':').filter(it.len > 0 && it !in old_values)
			if new_values.len == 0 {
				continue
			}
			parameter_expansion := rune(36).str() + '{' + key + ':-}'
			lines << 'export ${key}="${bundle_exec_shell_escape(new_values.join(':'))}:${parameter_expansion}"'
		} else {
			lines << 'export ${key}="${bundle_exec_shell_escape(value)}"'
		}
	}
	return if lines.len == 0 { '' } else { '${lines.join('\n')}\n' }
}

fn bundle_exec_shell_escape(value string) string {
	return value.replace('\\', '\\\\').replace('"', '\\"').replace('`', '\\`').replace('\$', '\\\$')
}

fn bundle_exec_dirname(path string) string {
	index := path.last_index('/') or { return '.' }
	return if index == 0 { '/' } else { path[..index] }
}

fn bundle_exec_unique(values []string) []string {
	mut result := []string{}
	for value in values {
		if value !in result {
			result << value
		}
	}
	return result
}

pub fn bundle_exec_context_from_invocation(invocation BundleExecSubcommandInvocation,
	environment map[string]string) BundleExecContext {
	return BundleExecContext{
		argv: invocation.args.clone()
		subcommand: invocation.command
		options: invocation.options
		environment: environment.clone()
		original_environment: environment.clone()
		home_directory: environment['HOME'] or { '' }
	}
}

pub fn bundle_exec_context_value(context BundleExecContext) ruby.Value {
	mut sandbox := ''
	if value := context.sandbox_path {
		sandbox = value
	}
	return ruby.Value{
		type_name: 'BundleExecContext'
		map_data: {
			'argv':                  ruby.string_array_value(context.argv)
			'environment':           bundle_exec_string_map_value(context.environment)
			'original_environment':  bundle_exec_string_map_value(context.original_environment)
			'dependencies':          ruby.array_value(context.dependencies.map(bundle_exec_dependency_value(it)))
			'missing_dependencies':  ruby.string_array_value(context.missing_dependencies)
			'services':              ruby.array_value(context.services.map(bundle_exec_service_value(it)))
			'available_commands':    bundle_exec_string_map_value(context.available_commands)
			'unwritable_temp_paths': ruby.string_array_value(context.unwritable_temp_paths)
		}
		attributes: {
			'subcommand':                context.subcommand
			'check':                     context.options.check.str()
			'no_secrets':                context.options.no_secrets.str()
			'services_enabled':          context.options.services.str()
			'global':                    context.options.global.str()
			'file':                      context.options.file
			'sandbox_path':              sandbox
			'deny_network':              context.deny_network.str()
			'home_directory':            context.home_directory
			'shell_path':                context.shell_path
			'all_dependencies_keg_only': context.all_dependencies_keg_only.str()
		}
	}
}

fn bundle_exec_context_from_value(value ruby.Value) BundleExecContext {
	if value.type_name == 'Bundle::ExecSubcommand::Invocation' {
		options := BundleExecSubcommandOptions{
			check: (value.attributes['check'] or { 'false' }) == 'true'
			no_secrets: (value.attributes['no_secrets'] or { 'false' }) == 'true'
			services: (value.attributes['services'] or { 'false' }) == 'true'
			global: (value.attributes['global'] or { 'false' }) == 'true'
			file: value.attributes['file'] or { '' }
		}
		return BundleExecContext{
			argv: (value.attributes['args'] or { '' }).split('\n').filter(it.len > 0)
			subcommand: value.attributes['command'] or { '' }
			options: options
			environment: ruby.environment()
			original_environment: ruby.environment()
			home_directory: ruby.environment_value('HOME')
		}
	}
	argv_value := value.map_data['argv'] or { ruby.string_array_value([]) }
	environment_value := value.map_data['environment'] or { ruby.map_value({}) }
	original_value := value.map_data['original_environment'] or { ruby.map_value({}) }
	dependencies_value := value.map_data['dependencies'] or { ruby.array_value([]) }
	missing_value := value.map_data['missing_dependencies'] or { ruby.string_array_value([]) }
	services_value := value.map_data['services'] or { ruby.array_value([]) }
	commands_value := value.map_data['available_commands'] or { ruby.map_value({}) }
	unwritable_value := value.map_data['unwritable_temp_paths'] or {
		ruby.string_array_value([])
	}
	sandbox_value := value.attributes['sandbox_path'] or { '' }
	return BundleExecContext{
		argv: argv_value.as_string_array() or { [] }
		subcommand: value.attributes['subcommand'] or { '' }
		options: BundleExecSubcommandOptions{
			check: (value.attributes['check'] or { 'false' }) == 'true'
			no_secrets: (value.attributes['no_secrets'] or { 'false' }) == 'true'
			services: (value.attributes['services_enabled'] or { 'false' }) == 'true'
			global: (value.attributes['global'] or { 'false' }) == 'true'
			file: value.attributes['file'] or { '' }
		}
		sandbox_path: if sandbox_value.len > 0 { ?string(sandbox_value) } else { none }
		deny_network: (value.attributes['deny_network'] or { 'false' }) == 'true'
		environment: bundle_exec_string_map_from_value(environment_value)
		original_environment: bundle_exec_string_map_from_value(original_value)
		dependencies: dependencies_value.array_data.map(bundle_exec_dependency_from_value(it))
		missing_dependencies: missing_value.as_string_array() or { [] }
		services: services_value.array_data.map(bundle_exec_service_from_value(it))
		available_commands: bundle_exec_string_map_from_value(commands_value)
		unwritable_temp_paths: unwritable_value.as_string_array() or { [] }
		home_directory: value.attributes['home_directory'] or { '' }
		shell_path: value.attributes['shell_path'] or { '' }
		all_dependencies_keg_only: (value.attributes['all_dependencies_keg_only'] or { 'false' }) == 'true'
	}
}

fn bundle_exec_plan_value(plan BundleExecPlan) ruby.Value {
	return ruby.Value{
		type_name: 'BundleExecPlan'
		map_data: {
			'environment': bundle_exec_string_map_value(plan.environment)
		}
		attributes: {
			'argv':            plan.argv.join('\n')
			'env_output':      plan.env_output
			'sandbox_path':    plan.sandbox_path or { '' }
			'deny_network':    plan.deny_network.str()
			'check_performed': plan.check_performed.str()
			'services':        plan.services.str()
			'execute':         plan.execute.str()
		}
	}
}

fn bundle_exec_runtime_value(runtime BundleExecRuntime, exit_code int,
	error_message string) ruby.Value {
	return ruby.Value{
		type_name: 'BundleExecRuntimeResult'
		array_data: runtime.service_operations.map(bundle_exec_service_operation_value(it))
		attributes: {
			'exit_code':          exit_code.str()
			'error':              error_message
			'command_plan_count': runtime.command_plans.len.str()
			'warnings':           runtime.warnings.join('\n')
		}
	}
}

fn bundle_exec_dependency_value(dependency BundleExecDependency) ruby.Value {
	return ruby.structured_value('BundleExecDependency', dependency.name, {
		'name':       dependency.name
		'opt_prefix': dependency.opt_prefix
		'version':    dependency.version
		'keg_only':   dependency.keg_only.str()
		'installed':  dependency.installed.str()
	})
}

fn bundle_exec_dependency_from_value(value ruby.Value) BundleExecDependency {
	return BundleExecDependency{
		name: value.attributes['name'] or { value.as_string() }
		opt_prefix: value.attributes['opt_prefix'] or { '' }
		version: value.attributes['version'] or { '' }
		keg_only: (value.attributes['keg_only'] or { 'false' }) == 'true'
		installed: (value.attributes['installed'] or { 'true' }) == 'true'
	}
}

fn bundle_exec_service_value(service BundleExecServiceInfo) ruby.Value {
	return ruby.Value{
		type_name: 'BundleExecServiceInfo'
		array_data: service.conflicts.map(ruby.structured_value('BundleExecConflictingService', it.name, {
			'name':       it.name
			'running':    it.running.str()
			'registered': it.registered.str()
		}))
		attributes: {
			'entry_name':     service.entry_name
			'formula_name':   service.formula_name
			'installed':      service.installed.str()
			'info_available': service.info_available.str()
			'service_file':   service.service_file
			'loaded_file':    service.loaded_file
			'running':        service.running.str()
			'loaded':         service.loaded.str()
			'registered':     service.registered.str()
			'launchctl':      service.launchctl.str()
		}
	}
}

fn bundle_exec_service_from_value(value ruby.Value) BundleExecServiceInfo {
	return BundleExecServiceInfo{
		entry_name: value.attributes['entry_name'] or { '' }
		formula_name: value.attributes['formula_name'] or { value.as_string() }
		installed: (value.attributes['installed'] or { 'true' }) == 'true'
		info_available: (value.attributes['info_available'] or { 'true' }) == 'true'
		service_file: value.attributes['service_file'] or { '' }
		loaded_file: value.attributes['loaded_file'] or { '' }
		running: (value.attributes['running'] or { 'false' }) == 'true'
		loaded: (value.attributes['loaded'] or { 'false' }) == 'true'
		registered: (value.attributes['registered'] or { 'false' }) == 'true'
		launchctl: (value.attributes['launchctl'] or { 'false' }) == 'true'
		conflicts: value.array_data.map(BundleExecConflictingService{
			name: it.attributes['name'] or { it.as_string() }
			running: (it.attributes['running'] or { 'false' }) == 'true'
			registered: (it.attributes['registered'] or { 'false' }) == 'true'
		})
	}
}

fn bundle_exec_service_operation_value(operation BundleExecServiceOperation) ruby.Value {
	return ruby.structured_value('BundleExecServiceOperation', operation.name, {
		'kind': operation.kind.str()
		'name': operation.name
		'file': operation.file
		'keep': operation.keep.str()
	})
}

fn bundle_exec_string_map_value(values map[string]string) ruby.Value {
	mut mapped := map[string]ruby.Value{}
	for key, value in values {
		mapped[key] = ruby.string_value(value)
	}
	return ruby.map_value(mapped)
}

fn bundle_exec_string_map_from_value(value ruby.Value) map[string]string {
	mut mapped := map[string]string{}
	for key, item in value.map_data {
		mapped[key] = item.as_string()
	}
	return mapped
}
