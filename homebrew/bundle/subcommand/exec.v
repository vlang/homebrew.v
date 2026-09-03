module subcommand

import brew_runtime
import homebrew.extend.env

// Translated from Homebrew/brew `bundle/subcommand/exec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 45.
pub fn ruby_exec_l45_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_exec_l50_d2_self_run_command(...args)
}

// Ruby method `self.run_command(*named_args, args:, context:)` at line 50.
pub fn ruby_exec_l50_d2_self_run_command(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'execution context is required')
	}
	plan := build_bundle_exec_plan(bundle_exec_context_from_value(args[0])) or {
		return brew_runtime.object_value('UsageError', err.msg())
	}
	return bundle_exec_plan_value(plan)
}

// Ruby method `self.run_external_command(` at line 87.
pub fn ruby_exec_l87_d3_self_run_external_command(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'execution context is required')
	}
	context := bundle_exec_context_from_value(args[0])
	mut runtime := BundleExecRuntime{}
	result := execute_bundle_exec(context, mut runtime, recording_bundle_exec_command, recording_bundle_exec_service) or {
		return bundle_exec_runtime_value(runtime, -1, err.msg())
	}
	return bundle_exec_runtime_value(runtime, result.exit_code, '')
}

// Ruby method `self.map_service_info(entries, &_block)` at line 320.
pub fn ruby_exec_l320_d4_self_map_service_info(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.array_value([])
	}
	services := map_service_info(bundle_exec_context_from_value(args[0]).services) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.array_value(services.map(bundle_exec_service_value(it)))
}

// Ruby method `self.run_services(entries, &_block)` at line 387.
pub fn ruby_exec_l387_d5_self_run_services(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'execution context is required')
	}
	mut runtime := BundleExecRuntime{}
	services := map_service_info(bundle_exec_context_from_value(args[0]).services) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	lifecycle := start_bundle_exec_services(services, mut runtime, recording_bundle_exec_service)
	cleanup_bundle_exec_services(lifecycle, mut runtime, recording_bundle_exec_service)
	return bundle_exec_runtime_value(runtime, 0, '')
}

// Ruby method `self.stop_services(entries)` at line 432.
pub fn ruby_exec_l432_d6_self_stop_services(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'execution context is required')
	}
	mut runtime := BundleExecRuntime{}
	services := map_service_info(bundle_exec_context_from_value(args[0]).services) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	stop_bundle_exec_services(services, mut runtime, recording_bundle_exec_service)
	return bundle_exec_runtime_value(runtime, 0, '')
}

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

pub type BundleExecCommandBoundary = fn(mut runtime BundleExecRuntime, plan BundleExecPlan) !int

pub type BundleExecServiceBoundary = fn(mut runtime BundleExecRuntime, operation BundleExecServiceOperation) bool

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
		environment['PATH'] = prepend_bundle_exec_path(environment['PATH'] or { '' }, brew_runtime.join_path(dependency.opt_prefix, 'bin'))
		if context.all_dependencies_keg_only || dependency.keg_only {
			environment['PKG_CONFIG_PATH'] = prepend_bundle_exec_path(environment['PKG_CONFIG_PATH'] or {
				''
			}, brew_runtime.join_path(dependency.opt_prefix, 'lib/pkgconfig'))
			environment['CPPFLAGS'] = append_bundle_exec_flag(environment['CPPFLAGS'] or { '' }, '-I${brew_runtime.join_path(dependency.opt_prefix, 'include')}')
			environment['LDFLAGS'] = append_bundle_exec_flag(environment['LDFLAGS'] or { '' }, '-L${brew_runtime.join_path(dependency.opt_prefix, 'lib')}')
		}
		if dependency.name in ['nodenv', 'pyenv', 'rbenv'] {
			root_key := 'HOMEBREW_${dependency.name.to_upper()}_ROOT'
			root := environment[root_key] or {
				brew_runtime.join_path(context.home_directory, '.${dependency.name}')
			}
			environment['PATH'] = prepend_bundle_exec_path(environment['PATH'] or { '' }, brew_runtime.join_path(root, 'shims'))
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

pub fn bundle_exec_context_value(context BundleExecContext) brew_runtime.Value {
	mut sandbox := ''
	if value := context.sandbox_path {
		sandbox = value
	}
	return brew_runtime.Value{
		type_name: 'BundleExecContext'
		map_data: {
			'argv':                  brew_runtime.string_array_value(context.argv)
			'environment':           bundle_exec_string_map_value(context.environment)
			'original_environment':  bundle_exec_string_map_value(context.original_environment)
			'dependencies':          brew_runtime.array_value(context.dependencies.map(bundle_exec_dependency_value(it)))
			'missing_dependencies':  brew_runtime.string_array_value(context.missing_dependencies)
			'services':              brew_runtime.array_value(context.services.map(bundle_exec_service_value(it)))
			'available_commands':    bundle_exec_string_map_value(context.available_commands)
			'unwritable_temp_paths': brew_runtime.string_array_value(context.unwritable_temp_paths)
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

fn bundle_exec_context_from_value(value brew_runtime.Value) BundleExecContext {
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
			environment: brew_runtime.environment()
			original_environment: brew_runtime.environment()
			home_directory: brew_runtime.environment_value('HOME')
		}
	}
	argv_value := value.map_data['argv'] or { brew_runtime.string_array_value([]) }
	environment_value := value.map_data['environment'] or { brew_runtime.map_value({}) }
	original_value := value.map_data['original_environment'] or { brew_runtime.map_value({}) }
	dependencies_value := value.map_data['dependencies'] or { brew_runtime.array_value([]) }
	missing_value := value.map_data['missing_dependencies'] or { brew_runtime.string_array_value([]) }
	services_value := value.map_data['services'] or { brew_runtime.array_value([]) }
	commands_value := value.map_data['available_commands'] or { brew_runtime.map_value({}) }
	unwritable_value := value.map_data['unwritable_temp_paths'] or {
		brew_runtime.string_array_value([])
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

fn bundle_exec_plan_value(plan BundleExecPlan) brew_runtime.Value {
	return brew_runtime.Value{
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
	error_message string) brew_runtime.Value {
	return brew_runtime.Value{
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

fn bundle_exec_dependency_value(dependency BundleExecDependency) brew_runtime.Value {
	return brew_runtime.structured_value('BundleExecDependency', dependency.name, {
		'name':       dependency.name
		'opt_prefix': dependency.opt_prefix
		'version':    dependency.version
		'keg_only':   dependency.keg_only.str()
		'installed':  dependency.installed.str()
	})
}

fn bundle_exec_dependency_from_value(value brew_runtime.Value) BundleExecDependency {
	return BundleExecDependency{
		name: value.attributes['name'] or { value.as_string() }
		opt_prefix: value.attributes['opt_prefix'] or { '' }
		version: value.attributes['version'] or { '' }
		keg_only: (value.attributes['keg_only'] or { 'false' }) == 'true'
		installed: (value.attributes['installed'] or { 'true' }) == 'true'
	}
}

fn bundle_exec_service_value(service BundleExecServiceInfo) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BundleExecServiceInfo'
		array_data: service.conflicts.map(brew_runtime.structured_value('BundleExecConflictingService', it.name, {
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

fn bundle_exec_service_from_value(value brew_runtime.Value) BundleExecServiceInfo {
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

fn bundle_exec_service_operation_value(operation BundleExecServiceOperation) brew_runtime.Value {
	return brew_runtime.structured_value('BundleExecServiceOperation', operation.name, {
		'kind': operation.kind.str()
		'name': operation.name
		'file': operation.file
		'keep': operation.keep.str()
	})
}

fn bundle_exec_string_map_value(values map[string]string) brew_runtime.Value {
	mut mapped := map[string]brew_runtime.Value{}
	for key, value in values {
		mapped[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(mapped)
}

fn bundle_exec_string_map_from_value(value brew_runtime.Value) map[string]string {
	mut mapped := map[string]string{}
	for key, item in value.map_data {
		mapped[key] = item.as_string()
	}
	return mapped
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5:
// 6: require "English"
// 7: require "exceptions"
// 8: require "extend/ENV"
// 9: require "utils"
// 10: require "PATH"
// 11: require "utils/output"
// 12: module Homebrew
// 13:   module Cmd
// 14:     class Bundle < Homebrew::AbstractCommand
// 15:       class ExecSubcommand < Homebrew::AbstractSubcommand
// 16:         subcommand_args do
// 17:           usage_banner <<~EOS
// 18:             `brew bundle exec` [`--check`] [`--no-secrets`] [`--sandbox=`<path>] [`--deny-network`] <command>:
// 19:             Run an external command in an isolated build environment based on the `Brewfile` dependencies.
// 20:
// 21:             This sanitised build environment ignores unrequested dependencies, which makes sure that things you didn't specify in your `Brewfile` won't get picked up by commands like `bundle install`, `npm install`, etc. It will also add compiler flags which will help with finding keg-only dependencies like `openssl`, `icu4c`, etc.
// 22:           EOS
// 23:           named_args :command
// 24:           switch "--install",
// 25:                  description: "Run `install` before executing the command."
// 26:           switch "--services",
// 27:                  description: "Temporarily start services while executing the command.",
// 28:                  env:         :bundle_services
// 29:           switch "--check",
// 30:                  description: "Check that all dependencies in the Brewfile are installed before " \
// 31:                               "executing the command.",
// 32:                  env:         :bundle_check
// 33:           switch "--no-secrets",
// 34:                  description: "Attempt to remove secrets from the environment before executing the command.",
// 35:                  env:         :bundle_no_secrets
// 36:           flag "--sandbox=",
// 37:                description: "Run <command> in Homebrew's sandbox, allowing writes to <path> and Homebrew's " \
// 38:                             "temporary and cache directories."
// 39:           switch "--deny-network",
// 40:                  description: "Deny network access from inside the sandbox.",
// 41:                  depends_on:  "--sandbox="
// 42:         end
// 43:
// 44:         sig { override.void }
// 45:         def run
// 46:           self.class.run_command(*args.named, args:, context:)
// 47:         end
// 48:
// 49:         sig { params(named_args: String, args: T.untyped, context: Homebrew::Cmd::Bundle::SubcommandContext).void }
// 50:         def self.run_command(*named_args, args:, context:)
// 51:           sandbox_path = args.sandbox
// 52:           sandbox_options = {}
// 53:           if sandbox_path
// 54:             sandbox_options[:sandbox_path] = sandbox_path
// 55:             sandbox_options[:deny_network] = args.deny_network?
// 56:           end
// 57:
// 58:           run_external_command(
// 59:             *named_args,
// 60:             global:     context.global,
// 61:             file:       context.file,
// 62:             subcommand: context.subcommand,
// 63:             services:   args.services?,
// 64:             check:      args.check?,
// 65:             no_secrets: args.no_secrets?,
// 66:             **sandbox_options,
// 67:           )
// 68:         end
// 69:
// 70:         extend Utils::Output::Mixin
// 71:
// 72:         PATH_LIKE_ENV_REGEX = /.+#{File::PATH_SEPARATOR}/
// 73:
// 74:         sig {
// 75:           params(
// 76:             args:         String,
// 77:             global:       T::Boolean,
// 78:             file:         T.nilable(String),
// 79:             subcommand:   String,
// 80:             services:     T::Boolean,
// 81:             check:        T::Boolean,
// 82:             no_secrets:   T::Boolean,
// 83:             sandbox_path: T.nilable(String),
// 84:             deny_network: T::Boolean,
// 85:           ).void
// 86:         }
// 87:         def self.run_external_command(
// 88:           *args,
// 89:           global: false,
// 90:           file: nil,
// 91:           subcommand: "",
// 92:           services: false,
// 93:           check: false,
// 94:           no_secrets: false,
// 95:           sandbox_path: nil,
// 96:           deny_network: false
// 97:         )
// 98:           if check
// 99:             require "bundle/subcommand/check"
// 100:             CheckSubcommand.new(args, context: SubcommandContext.new(
// 101:               subcommand:   "check",
// 102:               global:,
// 103:               file:,
// 104:               no_upgrade:   false,
// 105:               verbose:      false,
// 106:               force:        false,
// 107:               ask:          false,
// 108:               jobs:         1,
// 109:               zap:          false,
// 110:               no_type_args: true,
// 111:               extensions:   Homebrew::Bundle.extensions,
// 112:             ), quiet: true).run
// 113:           end
// 114:
// 115:           # Store the old environment so we can check if things were already set
// 116:           # before we start mutating it.
// 117:           old_env = ENV.to_h
// 118:           ENV.clear_sensitive_environment! if no_secrets
// 119:
// 120:           # Setup Homebrew's ENV extensions
// 121:           ENV.activate_extensions!
// 122:
// 123:           command = args.first
// 124:           raise UsageError, "No command to execute was specified!" if command.blank?
// 125:           raise UsageError, "`--sandbox` requires a writable path." if sandbox_path == ""
// 126:           raise UsageError, "`--deny-network` requires `--sandbox`." if deny_network && sandbox_path.blank?
// 127:
// 128:           require "bundle/brewfile"
// 129:           @dsl ||= T.let(nil, T.nilable(Homebrew::Bundle::Dsl))
// 130:           @dsl = Homebrew::Bundle::Brewfile.read(global:, file:)
// 131:
// 132:           require "formula"
// 133:           require "formulary"
// 134:
// 135:           ENV.deps = @dsl.entries.filter_map do |entry|
// 136:             next if entry.type != :brew
// 137:
// 138:             Formulary.factory(entry.name)
// 139:           end
// 140:
// 141:           # Allow setting all dependencies to be keg-only
// 142:           # (i.e. should be explicitly in HOMEBREW_*PATHs ahead of HOMEBREW_PREFIX)
// 143:           ENV.keg_only_deps = if ENV["HOMEBREW_BUNDLE_EXEC_ALL_KEG_ONLY_DEPS"].present?
// 144:             ENV.delete("HOMEBREW_BUNDLE_EXEC_ALL_KEG_ONLY_DEPS")
// 145:             ENV.deps
// 146:           else
// 147:             ENV.deps.select(&:keg_only?)
// 148:           end
// 149:           ENV.setup_build_environment
// 150:
// 151:           # Enable compiler flag filtering
// 152:           ENV.refurbish_args
// 153:
// 154:           # Add variable to detect being inside a `brew bundle exec` environment
// 155:           ENV["HOMEBREW_INSIDE_BUNDLE"] = "1"
// 156:
// 157:           # Set up `nodenv`, `pyenv` and `rbenv` if present.
// 158:           env_formulae = %w[nodenv pyenv rbenv]
// 159:           ENV.deps.each do |dep|
// 160:             dep_name = dep.name
// 161:             next unless env_formulae.include?(dep_name)
// 162:
// 163:             dep_root = ENV.fetch("HOMEBREW_#{dep_name.upcase}_ROOT", "#{Dir.home}/.#{dep_name}")
// 164:             ENV.prepend_path "PATH", Pathname.new(dep_root)/"shims"
// 165:           end
// 166:
// 167:           # Setup pkgconf, if needed, to help locate packages
// 168:           Homebrew::Bundle.prepend_pkgconf_path_if_needed!
// 169:
// 170:           # For commands which aren't either absolute or relative
// 171:           # Add the command directory to PATH, since it may get blown away by superenv
// 172:           if command.exclude?("/") && (which_command = which(command))
// 173:             ENV.prepend_path "PATH", which_command.dirname.to_s
// 174:           end
// 175:
// 176:           # Replace the formula versions from the environment variables
// 177:           ENV.deps.each do |formula|
// 178:             formula_name = formula.name
// 179:             formula_version = Homebrew::Bundle.formula_versions_from_env(formula_name)
// 180:             next unless formula_version
// 181:
// 182:             ENV.each do |key, value|
// 183:               opt = %r{/opt/#{formula_name}([/:$])}
// 184:               next unless value.match(opt)
// 185:
// 186:               cellar = "/Cellar/#{formula_name}/#{formula_version}\\1"
// 187:
// 188:               # Look for PATH-like environment variables
// 189:               ENV[key] = if key.include?("PATH") && value.match?(PATH_LIKE_ENV_REGEX)
// 190:                 rejected_opts = []
// 191:                 path = PATH.new(ENV.fetch("PATH"))
// 192:                            .reject do |path_value|
// 193:                   rejected_opts << path_value if path_value.match?(opt)
// 194:                 end
// 195:                 rejected_opts.each do |path_value|
// 196:                   path.prepend(path_value.gsub(opt, cellar))
// 197:                 end
// 198:                 path.to_s
// 199:               else
// 200:                 value.gsub(opt, cellar)
// 201:               end
// 202:             end
// 203:           end
// 204:
// 205:           # Ensure brew bundle exec/sh/env commands have access to other tools in the PATH
// 206:           if (homebrew_path = ENV.fetch("HOMEBREW_PATH", nil))
// 207:             ENV.append_path "PATH", homebrew_path
// 208:           end
// 209:
// 210:           # For commands which aren't either absolute or relative
// 211:           raise "command was not found in your PATH: #{command}" if command.exclude?("/") && which(command).nil?
// 212:
// 213:           %w[HOMEBREW_TEMP TMPDIR HOMEBREW_TMPDIR].each do |var|
// 214:             value = ENV.fetch(var, nil)
// 215:             next if value.blank?
// 216:             next if File.writable?(value)
// 217:
// 218:             ENV.delete(var)
// 219:           end
// 220:
// 221:           ENV.each do |key, value|
// 222:             # Look for PATH-like environment variables
// 223:             next if key.exclude?("PATH") || !value.match?(PATH_LIKE_ENV_REGEX)
// 224:
// 225:             # Exclude Homebrew shims from the PATH as they don't work
// 226:             # without all Homebrew environment variables and can interfere with
// 227:             # non-Homebrew builds.
// 228:             ENV[key] = PATH.new(value)
// 229:                            .reject do |path_value|
// 230:               path_value.include?("/Homebrew/shims/")
// 231:             end.to_s
// 232:           end
// 233:
// 234:           if subcommand == "env"
// 235:             ENV.sort.each do |key, value|
// 236:               # Skip exporting Homebrew internal variables that won't be used by other tools.
// 237:               # Those Homebrew needs have already been set to global constants and/or are exported again later.
// 238:               # Setting these globally can interfere with nested Homebrew invocations/environments.
// 239:               if key.start_with?("HOMEBREW_", "PORTABLE_RUBY_")
// 240:                 ENV.delete(key)
// 241:                 next
// 242:               end
// 243:
// 244:               # No need to export empty values.
// 245:               next if value.blank?
// 246:
// 247:               # Skip exporting things that were the same in the old environment.
// 248:               old_value = old_env[key]
// 249:               next if old_value == value
// 250:
// 251:               # Look for PATH-like environment variables
// 252:               if key.include?("PATH") && value.match?(PATH_LIKE_ENV_REGEX)
// 253:                 old_values = old_value.to_s.split(File::PATH_SEPARATOR)
// 254:                 path = PATH.new(value)
// 255:                            .reject do |path_value|
// 256:                   # Exclude existing/old values as they've already been exported.
// 257:                   old_values.include?(path_value)
// 258:                 end
// 259:                 next if path.blank?
// 260:
// 261:                 puts "export #{key}=\"#{Utils::Shell.sh_quote(path.to_s)}:${#{key}:-}\""
// 262:               else
// 263:                 puts "export #{key}=\"#{Utils::Shell.sh_quote(value)}\""
// 264:               end
// 265:             end
// 266:             return
// 267:           elsif subcommand == "sh"
// 268:             preferred_path = Utils::Shell.preferred_path(default: "/bin/bash")
// 269:             notice = unless Homebrew::EnvConfig.no_env_hints?
// 270:               <<~EOS
// 271:                 Your shell has been configured to use a build environment from your `Brewfile`.
// 272:                 This should help you build stuff.
// 273:                 Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
// 274:                 When done, type `exit`.
// 275:               EOS
// 276:             end
// 277:             ENV["HOMEBREW_FORCE_API_AUTO_UPDATE"] = nil
// 278:             args = [Utils::Shell.shell_with_prompt("brew bundle", preferred_path:, notice:)]
// 279:           end
// 280:
// 281:           require "sandbox" if sandbox_path
// 282:
// 283:           if services
// 284:             require "bundle/brew_services"
// 285:
// 286:             exit_code = T.let(0, Integer)
// 287:             run_services(@dsl.entries) do
// 288:               if sandbox_path
// 289:                 begin
// 290:                   Sandbox.run_command(*args, writable_path: sandbox_path, deny_network:)
// 291:                 rescue ErrorDuringExecution => e
// 292:                   exit_code = e.exitstatus || 1
// 293:                 end
// 294:               else
// 295:                 Kernel.system(*args)
// 296:                 if (system_exit_code = $CHILD_STATUS&.exitstatus)
// 297:                   exit_code = system_exit_code
// 298:                 end
// 299:               end
// 300:             end
// 301:             exit!(exit_code)
// 302:           elsif sandbox_path
// 303:             Sandbox.run_command(*args, writable_path: sandbox_path, deny_network:)
// 304:           else
// 305:             exec(*args)
// 306:           end
// 307:         end
// 308:
// 309:         sig {
// 310:           params(
// 311:             entries: T::Array[Homebrew::Bundle::Dsl::Entry],
// 312:             _block:  T.proc.params(
// 313:               entry:                Homebrew::Bundle::Dsl::Entry,
// 314:               info:                 T::Hash[String, T.untyped],
// 315:               service_file:         Pathname,
// 316:               conflicting_services: T::Array[T::Hash[String, T.untyped]],
// 317:             ).void,
// 318:           ).void
// 319:         }
// 320:         private_class_method def self.map_service_info(entries, &_block)
// 321:           entries_formulae = entries.filter_map do |entry|
// 322:             next if entry.type != :brew
// 323:
// 324:             formula = Formula[entry.name]
// 325:             next unless formula.any_version_installed?
// 326:
// 327:             [entry, formula]
// 328:           end.to_h
// 329:
// 330:           return if entries_formulae.empty?
// 331:
// 332:           conflicts = entries_formulae.to_h do |entry, formula|
// 333:             [
// 334:               entry,
// 335:               (
// 336:                 formula.versioned_formulae_names +
// 337:                   formula.conflicts.map(&:name) +
// 338:                   Array(entry.options[:conflicts_with])
// 339:               ).uniq,
// 340:             ]
// 341:           end
// 342:
// 343:           # The formula + everything that could possible conflict with the service
// 344:           names_to_query = entries_formulae.flat_map do |entry, formula|
// 345:             [
// 346:               formula.name,
// 347:               *conflicts.fetch(entry),
// 348:             ]
// 349:           end
// 350:
// 351:           # We parse from a command invocation so that brew wrappers can invoke special actions
// 352:           # for the elevated nature of `brew services`
// 353:           services_info = JSON.parse(
// 354:             Utils.safe_popen_read(HOMEBREW_BREW_FILE, "services", "info", "--json", *names_to_query),
// 355:           )
// 356:
// 357:           entries_formulae.filter_map do |entry, formula|
// 358:             service_file = Homebrew::Bundle::Brew::Services.versioned_service_file(entry.name)
// 359:
// 360:             unless service_file&.file?
// 361:               prefix = formula.any_installed_prefix
// 362:               next if prefix.nil?
// 363:
// 364:               service_file = if Homebrew::Services::System.launchctl?
// 365:                 prefix/"#{formula.plist_name}.plist"
// 366:               else
// 367:                 prefix/"#{formula.service_name}.service"
// 368:               end
// 369:             end
// 370:
// 371:             next unless service_file.file?
// 372:
// 373:             info = services_info.find { |candidate| candidate["name"] == formula.name }
// 374:             conflicting_services = services_info.select do |candidate|
// 375:               next unless candidate["running"]
// 376:
// 377:               conflicts.fetch(entry).include?(candidate["name"])
// 378:             end
// 379:
// 380:             raise "Failed to get service info for #{entry.name}" if info.nil?
// 381:
// 382:             yield entry, info, service_file, conflicting_services
// 383:           end
// 384:         end
// 385:
// 386:         sig { params(entries: T::Array[Homebrew::Bundle::Dsl::Entry], _block: T.nilable(T.proc.void)).void }
// 387:         private_class_method def self.run_services(entries, &_block)
// 388:           entries_to_stop = []
// 389:           services_to_restart = []
// 390:
// 391:           map_service_info(entries) do |entry, info, service_file, conflicting_services|
// 392:             # Don't restart if already running this version
// 393:             loaded_file = Pathname.new(info["loaded_file"].to_s)
// 394:             next if info["running"] && loaded_file.file? && loaded_file.realpath == service_file.realpath
// 395:
// 396:             if info["running"] && !Homebrew::Bundle::Brew::Services.stop(info["name"], keep: true)
// 397:               opoo "Failed to stop #{info["name"]} service"
// 398:             end
// 399:
// 400:             conflicting_services.each do |conflict|
// 401:               if Homebrew::Bundle::Brew::Services.stop(conflict["name"], keep: true)
// 402:                 services_to_restart << conflict["name"] if conflict["registered"]
// 403:               else
// 404:                 opoo "Failed to stop #{conflict["name"]} service"
// 405:               end
// 406:             end
// 407:
// 408:             unless Homebrew::Bundle::Brew::Services.run(info["name"], file: service_file)
// 409:               opoo "Failed to start #{info["name"]} service"
// 410:             end
// 411:
// 412:             entries_to_stop << entry
// 413:           end
// 414:
// 415:           return unless block_given?
// 416:
// 417:           begin
// 418:             yield
// 419:           ensure
// 420:             # Do a full re-evaluation of services instead state has changed
// 421:             stop_services(entries_to_stop)
// 422:
// 423:             services_to_restart.each do |service|
// 424:               next if Homebrew::Bundle::Brew::Services.run(service)
// 425:
// 426:               opoo "Failed to restart #{service} service"
// 427:             end
// 428:           end
// 429:         end
// 430:
// 431:         sig { params(entries: T::Array[Homebrew::Bundle::Dsl::Entry]).void }
// 432:         private_class_method def self.stop_services(entries)
// 433:           map_service_info(entries) do |_, info, _, _|
// 434:             next unless info["loaded"]
// 435:
// 436:             # Try avoid services not started by `brew bundle services`
// 437:             next if Homebrew::Services::System.launchctl? && info["registered"]
// 438:
// 439:             if info["running"] && !Homebrew::Bundle::Brew::Services.stop(info["name"], keep: true)
// 440:               opoo "Failed to stop #{info["name"]} service"
// 441:             end
// 442:           end
// 443:         end
// 444:       end
// 445:     end
// 446:   end
// 447: end
