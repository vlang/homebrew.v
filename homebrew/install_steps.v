module homebrew

import ruby
import compress.gzip as vgzip
import homebrew.utils as hb_utils
import os
import regex
import time

const install_steps_absolute_template_tokens = [
	'HOMEBREW_PREFIX',
	'HOMEBREW_CELLAR',
	'prefix',
	'opt_prefix',
	'bin',
	'sbin',
	'lib',
	'libexec',
	'share',
	'pkgshare',
	'var',
	'etc',
	'pkgetc',
	'staged_path',
	'appdir',
	'caskroom_path',
	'temp',
	'rack',
	'bash_completion',
	'zsh_completion',
	'fish_completion',
	'pwsh_completion',
]

const install_steps_content_path_tokens = [
	'prefix',
	'opt_prefix',
	'bin',
	'sbin',
	'lib',
	'libexec',
	'share',
	'pkgshare',
	'var',
	'etc',
	'pkgetc',
	'staged_path',
	'appdir',
	'caskroom_path',
	'temp',
	'rack',
	'bash_completion',
	'zsh_completion',
	'fish_completion',
	'pwsh_completion',
]

const install_steps_preserved_keys = ['after', 'args', 'before', 'content', 'env', 'overwrite']

pub type InstallStep = map[string]ruby.Value

pub type InstallSteps = []InstallStep

pub type InstallStepPathSpec = map[string]string

pub struct InstallStepsDsl {
pub mut:
	default_base        string
	default_source_base string
	default_target_base string
	steps               InstallSteps
	guards              []InstallStepPathSpec
	next_guard_id       int
}

pub struct InstallStepsContext {
pub:
	values map[string]string
	config map[string]string
}

pub struct InstallStepsCommandOptions {
pub:
	environment  map[string]string
	input        string
	chdir        string
	sudo         bool
	must_succeed bool = true
	print_stdout bool
	print_stderr bool = true
}

pub struct InstallStepsCommandResult {
pub:
	exit_code int
	stdout    string
	stderr    string
}

pub interface InstallStepsCommandExecutor {
	run(command string, arguments []string, options InstallStepsCommandOptions) !InstallStepsCommandResult
}

pub struct NativeInstallStepsCommandExecutor {}

pub fn (_ NativeInstallStepsCommandExecutor) run(command string, arguments []string,
	options InstallStepsCommandOptions) !InstallStepsCommandResult {
	mut argv := []string{}
	if options.sudo {
		argv << '/usr/bin/sudo'
	}
	argv << command
	argv << arguments
	result := ruby.run_captured_command(argv, ruby.CapturedCommandOptions{
		environment: if options.environment.len > 0 {
			options.environment
		} else {
			ruby.environment()
		}
		input: options.input
		chdir: options.chdir
	})!
	if result.exit_code != 0 && options.must_succeed {
		return error('command failed with status ${result.exit_code}: ${argv.join(' ')}\n${result.stderr}')
	}
	return InstallStepsCommandResult{
		exit_code: result.exit_code
		stdout: result.stdout
		stderr: result.stderr
	}
}

struct InstallStepsAppManagementCommand {
	executor InstallStepsCommandExecutor
}

fn (command InstallStepsAppManagementCommand) touch_and_remove_with_sudo(path string) ! {
	options := InstallStepsCommandOptions{
		environment: ruby.environment()
		sudo: true
		must_succeed: true
		print_stderr: false
	}
	command.executor.run('touch', [path], options)!
	command.executor.run('rm', [path], options)!
}

pub struct InstallStepsRunner {
pub:
	context  InstallStepsContext
	executor InstallStepsCommandExecutor
mut:
	guard_results map[string]bool
}

pub fn new_install_steps_runner(context InstallStepsContext,
	executor InstallStepsCommandExecutor) InstallStepsRunner {
	return InstallStepsRunner{
		context: context
		executor: executor
		guard_results: map[string]bool{}
	}
}

fn install_steps_value_string(value ruby.Value) string {
	if value.type_name == 'Symbol' {
		return value.repr.trim_left(':')
	}
	return value.repr
}

fn install_steps_value_bool(value ruby.Value, fallback bool) bool {
	return if value.type_name == 'Bool' { value.bool_data } else { fallback }
}

fn install_steps_value_int(value ruby.Value, fallback int) int {
	return if value.type_name == 'Integer' { int(value.int_data) } else { fallback }
}

fn install_steps_kw_string(keywords map[string]ruby.Value, key string,
	fallback string) string {
	if value := keywords[key] {
		return install_steps_value_string(value)
	}
	return fallback
}

fn install_steps_path_spec_value(spec InstallStepPathSpec) ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in spec {
		result[key] = ruby.string_value(value)
	}
	return ruby.map_value(result)
}

fn install_steps_path_spec_from_value(value ruby.Value) InstallStepPathSpec {
	mut result := InstallStepPathSpec{}
	if value.type_name == 'Hash' {
		for key, raw in value.map_data {
			text := install_steps_value_string(raw)
			if raw.type_name != 'NilClass' && text != '' {
				result[key] = text
			}
		}
	} else {
		result['path'] = install_steps_value_string(value)
	}
	return result
}

fn install_steps_step_value(step InstallStep) ruby.Value {
	return ruby.map_value(step)
}

pub fn install_steps_value(steps InstallSteps) ruby.Value {
	return ruby.array_value(steps.map(install_steps_step_value(it)))
}

pub fn install_steps_from_value(value ruby.Value) InstallSteps {
	mut raw_steps := value.array_data.clone()
	if value.type_name == 'InstallSteps::DSL' {
		raw_steps = value.map_data['steps'] or { ruby.array_value([]) }.array_data.clone()
	}
	mut result := InstallSteps{}
	for raw in raw_steps {
		if raw.type_name == 'Hash' {
			result << InstallStep(raw.map_data.clone())
		}
	}
	return result
}

pub fn new_install_steps_dsl(default_base string, default_source_base string,
	default_target_base string) InstallStepsDsl {
	return InstallStepsDsl{
		default_base: default_base
		default_source_base: default_source_base
		default_target_base: default_target_base
	}
}

fn install_steps_is_blank(value ruby.Value) bool {
	return match value.type_name {
		'NilClass' { true }
		'String', 'Symbol', 'Pathname' { value.repr == '' }
		'Bool' { !value.bool_data }
		'Array' { value.array_data.len == 0 && value.string_array_data.len == 0 }
		'Hash' { value.map_data.len == 0 }
		else { false }
	}
}

fn install_steps_normalise_path_value(value ruby.Value) ruby.Value {
	if value.type_name == 'Hash' {
		mut result := map[string]ruby.Value{}
		for key, raw in value.map_data {
			if raw.type_name != 'NilClass' && install_steps_value_string(raw) != '' {
				// Ruby's `key.to_s` removes the leading colon from symbols. Values
				// arriving through the generic boundary retain that spelling.
				result[key.trim_left(':')] = ruby.string_value(install_steps_value_string(raw))
			}
		}
		return ruby.map_value(result)
	}
	return ruby.map_value({
		'path': ruby.string_value(install_steps_value_string(value))
	})
}

fn install_steps_normalise_step_value(key string, value ruby.Value) ruby.Value {
	if value.type_name == 'Symbol' {
		return ruby.string_value(install_steps_value_string(value))
	}
	if value.type_name == 'Array' {
		items := value.as_array() or { []ruby.Value{} }
		if key in ['guards', 'paths', 'writable_paths'] {
			return ruby.array_value(items.map(install_steps_normalise_path_value(it)))
		}
		return ruby.string_array_value(items.map(install_steps_value_string(it)))
	}
	if value.type_name == 'Hash' {
		if key == 'env' {
			mut environment := map[string]ruby.Value{}
			for env_key, raw in value.map_data {
				if raw.type_name != 'NilClass' {
					environment[env_key] = ruby.string_value(install_steps_value_string(raw))
				}
			}
			return ruby.map_value(environment)
		}
		return install_steps_normalise_path_value(value)
	}
	if value.type_name in ['String', 'Pathname'] && key in ['path', 'source', 'target', 'command',
		'matching_certificate', 'stdin_path', 'stdout_path', 'chdir'] {
		return install_steps_normalise_path_value(value)
	}
	return value
}

pub fn install_steps_normalise(raw_steps []ruby.Value) InstallSteps {
	mut result := InstallSteps{}
	for raw in raw_steps {
		mut normalised := InstallStep{}
		for raw_key, raw_value in raw.map_data {
			key := raw_key.trim_left(':')
			normalised[key] = install_steps_normalise_step_value(key, raw_value)
		}
		mut compacted := InstallStep{}
		for key, value in normalised {
			if key !in install_steps_preserved_keys && !install_steps_is_blank(value) {
				compacted[key] = value
			}
		}
		for key in install_steps_preserved_keys {
			if value := normalised[key] {
				if value.type_name == 'NilClass' {
					continue
				}
				if key in ['args', 'env'] && install_steps_is_blank(value) {
					continue
				}
				compacted[key] = value
			}
		}
		result << compacted
	}
	return result
}

fn install_steps_default_base_for(path string, default_base string) string {
	if path.starts_with('/') || path.starts_with('~') {
		return ''
	}
	for token in install_steps_absolute_template_tokens {
		if path.starts_with('{{${token}}}') {
			return ''
		}
	}
	return default_base
}

fn install_steps_path_spec(path string, base string, formula string,
	default_base string) InstallStepPathSpec {
	mut result := InstallStepPathSpec{}
	resolved_base := if base != '' {
		base
	} else {
		install_steps_default_base_for(path, default_base)
	}
	if resolved_base != '' {
		result['base'] = resolved_base
	}
	if formula != '' {
		result['formula'] = formula
	}
	if path != '' {
		result['path'] = path
	}
	return result
}

pub fn install_steps_add(mut dsl InstallStepsDsl, kind string,
	fields map[string]ruby.Value) {
	mut raw := fields.clone()
	if dsl.guards.len > 0 {
		raw['guards'] = ruby.array_value(dsl.guards.map(install_steps_path_spec_value(it)))
	}
	raw['type'] = ruby.string_value(kind)
	dsl.steps << install_steps_normalise([ruby.map_value(raw)])
}

pub fn install_steps_add_rebuild_action(mut dsl InstallStepsDsl, kind string, path string) {
	install_steps_add(mut dsl, kind, {
		'path': install_steps_path_spec_value(install_steps_path_spec(path, 'homebrew_prefix', '', ''))
	})
}

fn install_steps_context_value(context InstallStepsContext, key string) string {
	if value := context.values[key] {
		return value
	}
	return ''
}

fn install_steps_context_path(context InstallStepsContext, base string) !string {
	if value := context.values[base] {
		return value
	}
	if value := context.config[base] {
		return value
	}
	return error('unknown install step base: ${base}')
}

fn install_steps_formula_name(full_name string) string {
	return full_name.all_after_last('/')
}

fn install_steps_formula_base(formula string, method string) !string {
	if formula == '' {
		return error('missing formula for install step base')
	}
	prefix := ruby.environment_value('HOMEBREW_PREFIX')
	return match method {
		'pkgetc' { os.join_path(prefix, 'etc', install_steps_formula_name(formula)) }
		'opt_prefix' { os.join_path(prefix, 'opt', install_steps_formula_name(formula)) }
		else { error('unknown formula install step base: ${method}') }
	}
}

pub fn install_steps_root_path(context InstallStepsContext, base string, formula string) !string {
	return match base {
		'home' {
			if install_steps_context_value(context, 'home') != '' {
				install_steps_context_path(context, base)
			} else {
				ruby.environment_value('HOME')
			}
		}
		'temp' { ruby.environment_value('HOMEBREW_TEMP') }
		'homebrew_prefix' { ruby.environment_value('HOMEBREW_PREFIX') }
		'formula_pkgetc' { install_steps_formula_base(formula, 'pkgetc') }
		'formula_opt_prefix' { install_steps_formula_base(formula, 'opt_prefix') }
		else { install_steps_context_path(context, base) }
	}
}

fn install_steps_token_value(context InstallStepsContext, token string) ?string {
	return match token {
		'HOMEBREW_BREW_FILE' { ruby.environment_value('HOMEBREW_BREW_FILE') }
		'HOMEBREW_CELLAR' { ruby.environment_value('HOMEBREW_CELLAR') }
		'HOMEBREW_PREFIX' { ruby.environment_value('HOMEBREW_PREFIX') }
		'formula_name' { install_steps_context_value(context, 'name') }
		'name' {
			name := install_steps_context_value(context, 'name')
			if name != '' { name } else { install_steps_context_value(context, 'token') }
		}
		'token' { install_steps_context_value(context, 'token') }
		'user' { ruby.environment_value('USER') }
		'version' { install_steps_context_value(context, 'version') }
		'version.major' {
			version_text := install_steps_context_value(context, 'version')
			if version_text == '' {
				''
			} else {
				version := new_version(version_text) or { return none }
				major := version.major() or { return none }
				major.to_s()
			}
		}
		'version.major_minor' {
			version_text := install_steps_context_value(context, 'version')
			if version_text == '' {
				''
			} else {
				version := new_version(version_text) or { return none }
				version.major_minor().to_s()
			}
		}
		else {
			if token in install_steps_content_path_tokens {
				install_steps_root_path(context, token, '') or { return none }
			} else {
				return none
			}
		}
	}
}

pub fn install_steps_expand_template_tokens(context InstallStepsContext, content string) string {
	mut result := ''
	mut cursor := 0
	for cursor < content.len {
		open_offset := content[cursor..].index('{{') or {
			result += content[cursor..]
			break
		}
		open := cursor + open_offset
		result += content[cursor..open]
		close_offset := content[open + 2..].index('}}') or {
			result += content[open..]
			break
		}
		close := open + 2 + close_offset
		token := content[open + 2..close]
		mut valid := token.len > 0 && (token[0].is_letter() || token[0] == `_`)
		for character in token {
			if !(character.is_alnum() || character == `_` || character == `.`) {
				valid = false
				break
			}
		}
		if valid {
			if value := install_steps_token_value(context, token) {
				result += value
			} else {
				result += content[open..close + 2]
			}
		} else {
			result += content[open..close + 2]
		}
		cursor = close + 2
	}
	return result
}

pub fn install_steps_resolve_path(context InstallStepsContext,
	spec InstallStepPathSpec) !string {
	path := install_steps_expand_template_tokens(context, spec['path'] or { '' })
	base := spec['base'] or { '' }
	if base == '' || base == 'absolute' {
		if path.starts_with('~/') {
			return os.abs_path(os.join_path(ruby.environment_value('HOME'), path[2..]))
		}
		return os.abs_path(path)
	}
	if base == 'relative' {
		return path
	}
	root := install_steps_root_path(context, base, spec['formula'] or { '' })!
	return os.join_path(root, path)
}

pub fn install_steps_resolve_command(context InstallStepsContext,
	spec InstallStepPathSpec) !string {
	base := spec['base'] or { '' }
	if base == '' || base == 'relative' {
		return install_steps_expand_template_tokens(context, spec['path'] or { '' })
	}
	return install_steps_resolve_path(context, spec)
}

pub fn install_steps_link_source(context InstallStepsContext,
	spec InstallStepPathSpec) !string {
	if spec['base'] or { '' } == 'relative' {
		return install_steps_expand_template_tokens(context, spec['path'] or { '' })
	}
	return install_steps_resolve_path(context, spec)
}

fn install_steps_glob_pattern(path string) bool {
	return path.contains_any('?*[\\{')
}

pub fn install_steps_expand_path_glob(context InstallStepsContext,
	spec InstallStepPathSpec) ![]string {
	mut base := spec['base'] or { '' }
	if base == 'path' {
		base = 'search_path'
	}
	if base == 'search_path' {
		path := install_steps_expand_template_tokens(context, spec['path'] or { '' })
		mut result := []string{}
		for directory in ruby.environment_value('PATH').split(os.path_delimiter) {
			candidate := os.join_path(directory, path)
			if install_steps_glob_pattern(candidate) {
				result << (os.glob(candidate) or { []string{} })
			} else {
				result << candidate
			}
		}
		return result
	}
	path := os.abs_path(install_steps_resolve_path(context, spec)!)
	if !install_steps_glob_pattern(path) {
		return [path]
	}
	return os.glob(path)
}

fn install_steps_guard_key(guard InstallStepPathSpec) string {
	mut keys := guard.keys()
	keys.sort()
	return keys.map('${it}=${guard[it]}').join('\x1f')
}

fn (mut runner InstallStepsRunner) guard_matches(guard InstallStepPathSpec) !bool {
	key := install_steps_guard_key(guard)
	if cached := runner.guard_results[key] {
		return cached
	}
	condition := guard['condition'] or { '' }
	mut matches := false
	if condition in ['if_exists', 'unless_exists'] {
		paths := install_steps_expand_path_glob(runner.context, guard)!
		exists := paths.any(os.exists(it))
		matches = if condition == 'if_exists' { exists } else { !exists }
	} else if condition == 'on' {
		matches = match guard['value'] or { '' } {
			'macos' { os.user_os() == 'macos' }
			'linux' { os.user_os() == 'linux' }
			else { false }
		}
	}
	runner.guard_results[key] = matches
	return matches
}

fn (mut runner InstallStepsRunner) step_guards_match(step InstallStep) !bool {
	guards := step['guards'] or { return true }
	for raw in guards.array_data {
		if !runner.guard_matches(install_steps_path_spec_from_value(raw))! {
			return false
		}
	}
	return true
}

fn install_steps_step_string(step InstallStep, key string) !string {
	value := step[key] or { return error('install step is missing ${key}') }
	return install_steps_value_string(value)
}

fn install_steps_step_path(step InstallStep, key string) !InstallStepPathSpec {
	value := step[key] or { return error('install step is missing ${key}') }
	return install_steps_path_spec_from_value(value)
}

fn install_steps_step_paths(step InstallStep, key string) ![]InstallStepPathSpec {
	value := step[key] or { return error('install step is missing ${key}') }
	return value.array_data.map(install_steps_path_spec_from_value(it))
}

fn install_steps_step_bool(step InstallStep, key string, fallback bool) bool {
	if value := step[key] {
		return install_steps_value_bool(value, fallback)
	}
	return fallback
}

fn install_steps_step_int(step InstallStep, key string, fallback int) int {
	if value := step[key] {
		return install_steps_value_int(value, fallback)
	}
	return fallback
}

fn install_steps_destination(source string, target string) string {
	return if os.is_dir(target) { os.join_path(target, os.base(source)) } else { target }
}

fn install_steps_resolve_source(context InstallStepsContext, step InstallStep) !string {
	spec := install_steps_step_path(step, 'source')!
	source := install_steps_resolve_path(context, spec)!
	if !install_steps_step_bool(step, 'source_glob', false) {
		return source
	}
	sources := (install_steps_expand_path_glob(context, spec)!).filter(os.exists(it) || os.is_link(it))
	if sources.len != 1 {
		return error('install step source glob must match exactly one path: ${source}')
	}
	return sources[0]
}

fn install_steps_existing_paths(context InstallStepsContext, step InstallStep) ![]string {
	mut result := []string{}
	for spec in install_steps_step_paths(step, 'paths')! {
		for path in install_steps_expand_path_glob(context, spec)! {
			if os.exists(path) || os.is_link(path) {
				result << path
			}
		}
	}
	return result
}

fn install_steps_remove(path string, recursive bool) ! {
	if os.is_link(path) || !recursive {
		os.rm(path)!
	} else if os.is_dir(path) {
		os.rmdir_all(path)!
	} else {
		os.rm(path)!
	}
}

fn install_steps_make_symlink(source string, target string, force bool) ! {
	os.mkdir_all(os.dir(target))!
	if force && (os.exists(target) || os.is_link(target)) {
		install_steps_remove(target, true)!
	}
	os.symlink(source, target)!
}

fn install_steps_copy(source string, target string, recursive bool, overwrite bool) ! {
	os.mkdir_all(os.dir(target))!
	destination := install_steps_destination(source, target)
	if (os.exists(destination) || os.is_link(destination)) && !overwrite {
		return error('File exists: ${destination}')
	}
	if recursive {
		os.cp_all(source, target, overwrite)!
	} else {
		if overwrite && os.is_link(destination) {
			os.rm(destination)!
		}
		os.cp(source, target)!
	}
}

fn install_steps_link_directory(source_dir string, target_dir string) ! {
	for source in os.walk_ext(source_dir, '', hidden: true) {
		relative := source.trim_string_left(source_dir).trim_left(os.path_separator)
		if os.base(source) == '.DS_Store' {
			continue
		}
		target := os.join_path(target_dir, relative)
		if os.is_dir(target) && !os.is_link(target) {
			continue
		}
		if os.exists(target) || os.is_link(target) {
			install_steps_remove(target, true)!
		}
		if os.is_link(source) || os.is_file(source) {
			install_steps_make_symlink(source, target, false)!
		} else if os.is_dir(source) {
			os.mkdir_all(target)!
		}
	}
}

fn (mut runner InstallStepsRunner) command(command string, arguments []string,
	options InstallStepsCommandOptions) !InstallStepsCommandResult {
	mut environment := ruby.environment()
	for key, value in options.environment {
		environment[key] = value
	}
	return runner.executor.run(command, arguments, InstallStepsCommandOptions{
		environment: environment
		input: options.input
		chdir: options.chdir
		sudo: options.sudo
		must_succeed: options.must_succeed
		print_stdout: options.print_stdout
		print_stderr: options.print_stderr
	})
}

fn (mut runner InstallStepsRunner) run_command(command string, arguments []string,
	sudo bool) ! {
	runner.command(command, arguments, InstallStepsCommandOptions{
		sudo: sudo
		must_succeed: true
		print_stdout: true
		print_stderr: true
	})!
}

fn (mut runner InstallStepsRunner) run_command_output(command string, arguments []string,
	sudo bool) !string {
	return (runner.command(command, arguments, InstallStepsCommandOptions{
		sudo: sudo
		must_succeed: true
		print_stderr: true
	})!).stdout
}

fn (mut runner InstallStepsRunner) run_serialised_command(step InstallStep) ! {
	command_spec := install_steps_step_path(step, 'command')!
	command := install_steps_resolve_command(runner.context, command_spec)!
	mut arguments := []string{}
	if raw := step['args'] {
		for argument in raw.as_array() or { []ruby.Value{} } {
			arguments << install_steps_expand_template_tokens(runner.context, install_steps_value_string(argument))
		}
	}
	mut environment := map[string]string{}
	if raw := step['env'] {
		for key, value in raw.map_data {
			environment[key] = install_steps_expand_template_tokens(runner.context, install_steps_value_string(value))
		}
	}
	mut input := ''
	if raw := step['stdin_path'] {
		input_path := install_steps_resolve_path(runner.context, install_steps_path_spec_from_value(raw))!
		input = os.read_file(input_path)!
	}
	mut chdir := ''
	if raw := step['chdir'] {
		chdir = install_steps_resolve_path(runner.context, install_steps_path_spec_from_value(raw))!
	}
	result := runner.command(command, arguments, InstallStepsCommandOptions{
		environment: environment
		input: input
		chdir: chdir
		sudo: install_steps_step_bool(step, 'sudo', false)
		must_succeed: !install_steps_step_bool(step, 'allow_failure', false)
		print_stdout: install_steps_step_bool(step, 'print_stdout', false)
		print_stderr: !install_steps_step_bool(step, 'suppress_stderr', false)
	})!
	if raw := step['stdout_path'] {
		if result.exit_code == 0 {
			output_path := install_steps_resolve_path(runner.context, install_steps_path_spec_from_value(raw))!
			os.mkdir_all(os.dir(output_path))!
			os.write_file(output_path, result.stdout)!
		}
	}
}

fn (mut runner InstallStepsRunner) run_terminate_process(step InstallStep) ! {
	if notices := step['notices'] {
		for notice in notices.as_array() or { []ruby.Value{} } {
			println(install_steps_expand_template_tokens(runner.context, install_steps_value_string(notice)))
		}
	}
	name := install_steps_expand_template_tokens(runner.context, install_steps_step_string(step, 'name')!)
	command := if install_steps_step_string(step, 'match') or { 'name' } == 'full' {
		'/usr/bin/pkill'
	} else {
		'/usr/bin/killall'
	}
	arguments := if command == '/usr/bin/pkill' { ['-f', name] } else { [name] }
	mut attempts := install_steps_step_int(step, 'attempts', 1)
	for attempts > 0 {
		runner.run_command(command, arguments, install_steps_step_bool(step, 'sudo', false)) or {
			attempts--
			if attempts == 0 {
				if failure_message := step['failure_message'] {
					eprintln('Warning: ${install_steps_expand_template_tokens(runner.context, install_steps_value_string(failure_message))}')
				}
				if install_steps_step_bool(step, 'must_succeed', false) {
					return err
				}
				return
			}
			time.sleep(time.second)
			continue
		}
		return
	}
}

fn (mut runner InstallStepsRunner) create_symlink(source string, target string,
	step InstallStep) ! {
	force := install_steps_step_bool(step, 'force', false)
	sudo_value := step['sudo'] or { ruby.bool_value(false) }
	sudo := sudo_value.bool_data || (install_steps_value_string(sudo_value) == 'if_needed' && !os.is_writable(os.dir(target)))
	if sudo {
		mut arguments := ['-s']
		if force {
			arguments << '-f'
		}
		arguments << source
		arguments << target
		runner.run_command('/bin/ln', arguments, true)!
		return
	}
	install_steps_make_symlink(source, target, force)!
}

fn (mut runner InstallStepsRunner) run_set_permissions(step InstallStep) ! {
	paths := install_steps_existing_paths(runner.context, step)!
	if paths.len == 0 {
		return
	}
	mut arguments := []string{}
	if !install_steps_step_bool(step, 'non_recursive', false) {
		arguments << '-R'
	}
	arguments << '--'
	arguments << install_steps_step_string(step, 'permissions')!
	arguments << paths
	runner.run_command('chmod', arguments, false)!
}

fn (mut runner InstallStepsRunner) run_set_ownership(step InstallStep) ! {
	paths := install_steps_existing_paths(runner.context, step)!
	if paths.len == 0 {
		return
	}
	permission_command := InstallStepsAppManagementCommand{
		executor: runner.executor
	}
	for path in paths {
		if !ruby.app_management_permissions_granted(path, permission_command)! {
			return error("Cannot change the ownership of '${path}' because your terminal does not have App Management permissions.\nmacOS prevents modifying apps without these permissions, even when using `sudo`.\nTo fix this, approve the permissions prompt (if one was just shown) or go to\nSystem Settings → Privacy & Security → App Management and add or enable your terminal.\nThen run this command again.")
		}
	}
	mut arguments := []string{}
	if !install_steps_step_bool(step, 'non_recursive', false) {
		arguments << '-R'
	}
	user := install_steps_step_string(step, 'user') or { ruby.environment_value('USER') }
	group := install_steps_step_string(step, 'group') or { 'staff' }
	arguments << '--'
	arguments << '${user}:${group}'
	arguments << paths
	runner.run_command('chown', arguments, true)!
}

fn (mut runner InstallStepsRunner) run_uninstall_step(step InstallStep) ! {
	if install_steps_step_string(step, 'type')! != 'symlink' || !install_steps_step_bool(step, 'uninstall', false) {
		return
	}
	target := install_steps_resolve_path(runner.context, install_steps_step_path(step, 'target')!)!
	if !os.is_link(target) {
		return
	}
	source := install_steps_link_source(runner.context, install_steps_step_path(step, 'source')!)!
	if os.readlink(target)! != source {
		return
	}
	sudo_value := step['sudo'] or { ruby.bool_value(false) }
	if sudo_value.bool_data || (install_steps_value_string(sudo_value) == 'if_needed' && !os.is_writable(os.dir(target))) {
		runner.run_command('/bin/rm', ['-f', target], true)!
	} else {
		os.rm(target)!
	}
}

fn (mut runner InstallStepsRunner) run_init_data_dir(step InstallStep) ! {
	using := install_steps_step_string(step, 'using')!
	marker := match using {
		'postgresql_initdb' { 'PG_VERSION' }
		'mysql_initialize' { 'mysql/general_log.CSM' }
		'mariadb_install_db' { 'mysql/user.frm' }
		else {
			return error('unknown data directory initialiser: ${using}')
		}
	}
	path := install_steps_resolve_path(runner.context, install_steps_step_path(step, 'path')!)!
	os.mkdir_all(path)!
	if ruby.environment_value('HOMEBREW_GITHUB_ACTIONS') != '' || os.exists(os.join_path(path, marker)) {
		return
	}
	bin := install_steps_context_path(runner.context, 'bin')!
	prefix := install_steps_context_path(runner.context, 'prefix')!
	user := ruby.environment_value('USER')
	match using {
		'postgresql_initdb' {
			locale := install_steps_step_string(step, 'locale') or { 'en_US.UTF-8' }
			runner.run_command(os.join_path(bin, 'initdb'), ['--locale=${locale}', '-E', 'UTF-8',
				path], false)!
		}
		'mysql_initialize' {
			runner.run_command(os.join_path(bin, 'mysqld'), ['--initialize-insecure',
				'--user=${user}', '--basedir=${prefix}', '--datadir=${path}', '--tmpdir=/tmp'], false)!
		}
		'mariadb_install_db' {
			runner.run_command(os.join_path(bin, 'mysql_install_db'), ['--verbose', '--user=${user}',
				'--basedir=${prefix}', '--datadir=${path}', '--tmpdir=/tmp'], false)!
		}
		else {}
	}
}

fn (mut runner InstallStepsRunner) run_formula_tool(formula string, executable string,
	arguments []string) ! {
	tool := os.join_path(ruby.environment_value('HOMEBREW_PREFIX'), 'opt', formula, 'bin', executable)
	if !os.is_executable(tool) {
		return error('${formula} is missing required executable: ${tool}')
	}
	runner.run_command(tool, arguments, false)!
}

fn install_steps_change_dylib_id(file string, id string, resolve_source bool,
	mut runner InstallStepsRunner) ! {
	path := if resolve_source { os.real_path(file) } else { file }
	information := os.stat(path)!
	mode := int(information.mode)
	os.chmod(path, mode | 0o200)!
	defer {
		os.chmod(path, mode) or {}
	}
	runner.run_command('/usr/bin/install_name_tool', ['-id', id, path], false)!
	if os.uname().machine.starts_with('arm') {
		runner.run_command('/usr/bin/codesign', ['--force', '--sign', '-', path], false)!
	}
}

fn install_steps_context_version_major(context InstallStepsContext) ?string {
	version_text := install_steps_context_value(context, 'version')
	if version_text == '' {
		return none
	}
	version := new_version(version_text) or { return none }
	major := version.major() or { return none }
	return major.to_s()
}

fn install_steps_context_version_major_minor(context InstallStepsContext) ?string {
	version_text := install_steps_context_value(context, 'version')
	if version_text == '' {
		return none
	}
	version := new_version(version_text) or { return none }
	return version.major_minor().to_s()
}

fn install_steps_opt_path(formula string, component string) string {
	return os.join_path(ruby.environment_value('HOMEBREW_PREFIX'), 'opt', formula, component)
}

fn install_steps_force_symlink(source string, target string) ! {
	if os.exists(target) || os.is_link(target) {
		install_steps_remove(target, true)!
	}
	install_steps_make_symlink(source, target, false)!
}

fn install_steps_glob_one(pattern string, description string) !string {
	matches := os.glob(pattern)!
	if matches.len != 1 {
		return error('${description} must match exactly one path: ${pattern}')
	}
	return matches[0]
}

fn install_steps_run_configure_gcc_runtime(mut runner InstallStepsRunner) ! {
	if os.user_os() != 'linux' {
		return
	}
	version_major := install_steps_context_version_major(runner.context) or {
		return error('GCC runtime configuration requires a version')
	}
	gcc := os.join_path(install_steps_context_path(runner.context, 'bin')!, 'gcc-${version_major}')
	libgcc := os.dir((runner.run_command_output(gcc, ['-print-libgcc-file-name'], false)!).trim_space())
	glibc_opt := os.join_path(ruby.environment_value('HOMEBREW_PREFIX'), 'opt', 'glibc')
	glibc_installed := os.is_dir(glibc_opt)
	glibc_lib := os.join_path(glibc_opt, 'lib')
	crtdir := if glibc_installed {
		glibc_lib
	} else {
		os.dir((runner.run_command_output('/usr/bin/cc', ['-print-file-name=crti.o'], false)!).trim_space())
	}
	for source in os.glob(os.join_path(crtdir, '*crt?.o'))! {
		install_steps_force_symlink(source, os.join_path(libgcc, os.base(source)))!
	}
	specs := os.join_path(libgcc, 'specs')
	for path in ['${specs}.orig', specs] {
		if os.exists(path) {
			os.rm(path)!
		}
	}
	mut system_header_dirs := [
		os.join_path(ruby.environment_value('HOMEBREW_PREFIX'), 'include'),
	]
	if glibc_installed {
		system_header_dirs << os.join_path(glibc_opt, 'include')
	} else {
		target := (runner.run_command_output(gcc, ['-print-multiarch'], false)!).trim_space()
		system_header_dirs << os.join_path('/usr/include', target)
		system_header_dirs << '/usr/include'
	}
	mut specs_string := runner.run_command_output(gcc, ['-dumpspecs'], false)!
	os.write_file('${specs}.orig', specs_string)!
	context_name := install_steps_context_value(runner.context, 'name')
	libdir := if context_name == 'gcc' {
		os.join_path(ruby.environment_value('HOMEBREW_PREFIX'), 'lib/gcc/current')
	} else {
		os.join_path(ruby.environment_value('HOMEBREW_PREFIX'), 'lib/gcc', version_major)
	}
	link_libgcc := if glibc_installed { '-nostdlib -L${libgcc} -L${glibc_lib}' } else { '+' }
	homebrew_rpath := version_major.int() >= 11
	idirafter := system_header_dirs.map('-idirafter ${it}').join(' ')
	rpath_suffix := if homebrew_rpath {
		''
	} else {
		' -rpath ${ruby.environment_value('HOMEBREW_PREFIX')}/lib'
	}
	specs_string += '\n*cpp_unique_options:\n+ -isysroot ${ruby.environment_value('HOMEBREW_PREFIX')}/nonexistent ${idirafter}\n\n*link_libgcc:\n${link_libgcc} -L${libdir} -L${ruby.environment_value('HOMEBREW_PREFIX')}/lib\n\n*link:\n+ --dynamic-linker ${ruby.environment_value('HOMEBREW_PREFIX')}/lib/ld.so -rpath ${libdir}${rpath_suffix}\n'
	if homebrew_rpath {
		specs_string += '\n*homebrew_rpath:\n-rpath ${ruby.environment_value('HOMEBREW_PREFIX')}/lib\n'
		specs_string = specs_string.replace(' %o ', ' %o %(homebrew_rpath) ')
	}
	os.write_file(specs, specs_string)!
}

fn install_steps_run_install_gzipped_executable(mut runner InstallStepsRunner,
	step InstallStep) ! {
	source := install_steps_resolve_path(runner.context, install_steps_step_path(step, 'source')!)!
	if !os.exists(source) {
		return
	}
	target := install_steps_resolve_path(runner.context, install_steps_step_path(step, 'target')!)!
	os.mkdir_all(os.dir(target))!
	temporary := os.join_path(os.dir(target), '.${os.base(target)}.install-step')
	if os.exists(temporary) {
		os.rm(temporary)!
	}
	defer {
		if os.exists(temporary) {
			os.rm(temporary) or {}
		}
	}
	os.write_file_array(temporary, vgzip.decompress(os.read_bytes(source)!)!)!
	if os.exists(target) || os.is_link(target) {
		install_steps_remove(target, true)!
	}
	os.mv(temporary, target)!
	os.rm(source)!
	os.chmod(target, 0o755)!
}

fn install_steps_run_configure_glibc_runtime(mut runner InstallStepsRunner) ! {
	lib := install_steps_context_path(runner.context, 'lib')!
	os.mkdir_all(os.join_path(lib, 'locale'))!
	legacy := install_steps_context_value(runner.context, 'name') != 'glibc'
	mut locales := []string{}
	for key, value in ruby.environment() {
		eligible := key == 'LANG' || key.starts_with('LC_') || (!legacy && key == 'HOMEBREW_LANG')
		if eligible && value != 'C' && !(legacy && value.starts_with('C.')) {
			locales << value
		}
	}
	locales << 'en_US.UTF-8'
	locales.sort()
	mut unique := []string{}
	for locale in locales {
		if locale !in unique {
			unique << locale
		}
	}
	localedef := os.join_path(install_steps_context_path(runner.context, 'bin')!, 'localedef')
	for locale in unique {
		components := locale.split('.')
		lang := components[0]
		mut arguments := ['-i', lang]
		if components.len > 1 {
			charmap := if components[1] == 'utf8' { 'UTF-8' } else { components[1] }
			arguments << ['-f', charmap]
		}
		arguments << locale
		runner.run_command(localedef, arguments, false)!
	}
	for pair in [
		['/etc/localtime',
			os.join_path(install_steps_context_path(runner.context, 'etc')!, 'localtime')],
		['/usr/share/zoneinfo',
			os.join_path(install_steps_context_path(runner.context, 'share')!, 'zoneinfo')],
	] {
		if os.exists(pair[0]) && !os.exists(pair[1]) {
			install_steps_make_symlink(pair[0], pair[1], false)!
		}
	}
}

fn install_steps_run_configure_clang_system(mut runner InstallStepsRunner) ! {
	if os.user_os() != 'macos' {
		return
	}
	kernel_version := os.uname().release.all_before('.')
	if kernel_version == '' {
		return error('Clang system configuration requires a kernel version')
	}
	config_dir := os.join_path(install_steps_context_path(runner.context, 'etc')!, 'clang')
	macos_version := (runner.run_command_output('/usr/bin/sw_vers', ['-productVersion'], false)!).trim_space()
	arch := os.uname().machine
	mut arches := ['arm64', 'x86_64', 'aarch64']
	if arch !in arches {
		arches << arch
	}
	mut complete := true
	for target_arch in arches {
		for system in ['darwin${kernel_version}', 'macosx${macos_version}'] {
			if !os.exists(os.join_path(config_dir, '${target_arch}-apple-${system}.cfg')) {
				complete = false
			}
		}
	}
	if complete {
		return
	}
	hb_utils.write_clang_system_config_files(config_dir, macos_version, kernel_version, arch, macos_version, '/Library/Developer/CommandLineTools/SDKs')!
}

fn install_steps_run_configure_php(mut runner InstallStepsRunner) ! {
	prefix := ruby.environment_value('HOMEBREW_PREFIX')
	pear_prefix := os.join_path(install_steps_context_path(runner.context, 'pkgshare')!, 'pear')
	channels := [os.join_path(pear_prefix, '.channels'),
		os.join_path(pear_prefix, '.channels/.alias')]
	for directory in channels {
		if os.is_dir(directory) {
			os.chmod(directory, 0o755)!
			for child in os.ls(directory)! {
				path := os.join_path(directory, child)
				if os.is_file(path) {
					os.chmod(path, 0o644)!
				}
			}
		}
	}
	for filename in ['.depdblock', '.filemap', '.depdb', '.lock'] {
		path := os.join_path(pear_prefix, filename)
		if os.is_file(path) {
			os.chmod(path, 0o644)!
		}
	}
	pecl_path := os.join_path(prefix, 'lib/php/pecl')
	os.mkdir_all(pecl_path)!
	prefix_pecl := os.join_path(install_steps_context_path(runner.context, 'prefix')!, 'pecl')
	if os.is_link(prefix_pecl) {
		os.rm(prefix_pecl)!
	}
	if !os.exists(prefix_pecl) {
		install_steps_make_symlink(pecl_path, prefix_pecl, false)!
	}
	php_config := os.join_path(install_steps_context_path(runner.context, 'bin')!, 'php-config')
	php_basename := os.base((runner.run_command_output(php_config, ['--extension-dir'], false)!).trim_space())
	os.mkdir_all(os.join_path(pecl_path, php_basename))!
	version := install_steps_context_version_major_minor(runner.context) or {
		return error('PHP configuration requires a version')
	}
	context_name := install_steps_context_value(runner.context, 'name')
	pear_dir := if context_name == 'php' { 'pear' } else { 'pear@${version}' }
	pear_path := os.join_path(prefix, 'share', pear_dir)
	os.mkdir_all(pear_path)!
	for entry in os.ls(pear_prefix)! {
		os.cp_all(os.join_path(pear_prefix, entry), os.join_path(pear_path, entry), true)!
	}
	opt_prefix := install_steps_context_path(runner.context, 'opt_prefix')!
	php_ext_dir := os.join_path(opt_prefix, 'lib/php', php_basename)
	settings := {
		'php_ini':  os.join_path(install_steps_context_path(runner.context, 'etc')!, 'php', version, 'php.ini')
		'php_dir':  pear_path
		'doc_dir':  os.join_path(pear_path, 'doc')
		'ext_dir':  os.join_path(pecl_path, php_basename)
		'bin_dir':  os.join_path(opt_prefix, 'bin')
		'data_dir': os.join_path(pear_path, 'data')
		'cfg_dir':  os.join_path(pear_path, 'cfg')
		'www_dir':  os.join_path(pear_path, 'htdocs')
		'man_dir':  os.join_path(prefix, 'share/man')
		'test_dir': os.join_path(pear_path, 'test')
		'php_bin':  os.join_path(opt_prefix, 'bin/php')
	}
	pear := os.join_path(install_steps_context_path(runner.context, 'bin')!, 'pear')
	for key, value in settings {
		if key.ends_with('_dir') && key !in ['bin_dir', 'man_dir'] {
			os.mkdir_all(value)!
		}
		runner.run_command(pear, ['config-set', key, value, 'system'], false)!
	}
	runner.run_command(pear, ['update-channels'], false)!
	if context_name == 'php' {
		return
	}
	ext_config := os.join_path(install_steps_context_path(runner.context, 'etc')!, 'php', version, 'conf.d/ext-opcache.ini')
	zend_line := 'zend_extension="${php_ext_dir}/opcache.so"'
	if os.exists(ext_config) {
		install_steps_replace(ext_config, '^\\s*zend_extension\\s*=.*\$', zend_line, true, 0, false, true)!
	} else {
		os.mkdir_all(os.dir(ext_config))!
		os.write_file(ext_config, '[opcache]\n${zend_line}\n')!
	}
}

pub fn install_steps_make_cpython_venv_activation_scripts_writable(lib_cellar string) ! {
	for path in os.walk_ext(os.join_path(lib_cellar, 'venv/scripts'), '', hidden: true) {
		if os.is_file(path) {
			mode := int(os.stat(path)!.get_mode().bitmask())
			os.chmod(path, mode | 0o200)!
		}
	}
}

fn install_steps_run_bootstrap_cpython(mut runner InstallStepsRunner) ! {
	version := install_steps_context_version_major_minor(runner.context) or {
		return error('CPython bootstrap requires a version')
	}
	prefix := ruby.environment_value('HOMEBREW_PREFIX')
	site_packages := os.join_path(prefix, 'lib', 'python${version}', 'site-packages')
	lib_cellar := if os.user_os() == 'macos' {
		os.join_path(install_steps_context_path(runner.context, 'frameworks')!, 'Python.framework/Versions', version, 'lib', 'python${version}')
	} else {
		os.join_path(install_steps_context_path(runner.context, 'lib')!, 'python${version}')
	}
	cellar_site := os.join_path(lib_cellar, 'site-packages')
	os.mkdir_all(site_packages)!
	if os.exists(cellar_site) || os.is_link(cellar_site) {
		install_steps_remove(cellar_site, true)!
	}
	install_steps_make_symlink(site_packages, cellar_site, false)!
	for pattern in ['sitecustomize.py[co]', 'setuptools[-_.][0-9]*', 'setuptools',
		'distribute[-_.][0-9]*', 'distribute', 'pip[-_.][0-9]*', 'pip', 'wheel[-_.][0-9]*', 'wheel'] {
		for path in os.glob(os.join_path(site_packages, pattern))! {
			install_steps_remove(path, true)!
		}
	}
	python := os.join_path(install_steps_context_path(runner.context, 'bin')!, 'python${version}')
	runner.run_command(python, ['-Im', 'ensurepip'], false)!
	bundled := os.join_path(lib_cellar, 'ensurepip/_bundled')
	wheels := [
		install_steps_glob_one(os.join_path(bundled, 'setuptools-*-py3-none-any.whl'), 'CPython bootstrap wheel')!,
		install_steps_glob_one(os.join_path(bundled, 'pip-*-py3-none-any.whl'), 'CPython bootstrap wheel')!,
		install_steps_glob_one(os.join_path(install_steps_context_path(runner.context, 'libexec')!, 'wheel-*-py3-none-any.whl'), 'CPython bootstrap wheel')!,
	]
	mut pip_arguments := ['-Im', 'pip', 'install', '-v', '--no-deps', '--no-index', '--upgrade',
		'--isolated', '--target=${site_packages}']
	pip_arguments << wheels
	runner.run_command(python, pip_arguments, false)!
	bin := install_steps_context_path(runner.context, 'bin')!
	site_bin := os.join_path(site_packages, 'bin')
	for child in os.ls(site_bin)! {
		os.mv(os.join_path(site_bin, child), os.join_path(bin, child))!
	}
	os.rmdir(site_bin)!
	for name in ['pip', 'pip3'] {
		path := os.join_path(bin, name)
		if os.exists(path) || os.is_link(path) {
			install_steps_remove(path, true)!
		}
	}
	os.mv(os.join_path(bin, 'wheel'), os.join_path(bin, 'wheel${version}'))!
	libexec_bin := os.join_path(install_steps_context_path(runner.context, 'libexec')!, 'bin')
	for short, long in {
		'pip':    'pip${version}'
		'pip3':   'pip${version}'
		'wheel':  'wheel${version}'
		'wheel3': 'wheel${version}'
	} {
		install_steps_make_symlink(os.real_path(os.join_path(bin, long)), os.join_path(libexec_bin, short), true)!
	}
	for name in ['wheel${version}', 'pip${version}'] {
		install_steps_force_symlink(os.join_path(bin, name), os.join_path(prefix, 'bin', name))!
	}
	install_steps_make_cpython_venv_activation_scripts_writable(lib_cellar)!
	if version == '3.9' {
		include_dirs := [os.join_path(prefix, 'include'),
			install_steps_opt_path('openssl@3', 'include'),
			install_steps_opt_path('sqlite', 'include')]
		library_dirs := [os.join_path(prefix, 'lib'), install_steps_opt_path('openssl@3', 'lib'),
			install_steps_opt_path('sqlite', 'lib')]
		config := os.join_path(lib_cellar, 'distutils/distutils.cfg')
		os.mkdir_all(os.dir(config))!
		os.write_file(config, '[install]\nprefix=${prefix}\n[build_ext]\ninclude_dirs=${include_dirs.join(':')}\nlibrary_dirs=${library_dirs.join(':')}\n')!
		compat := os.join_path(site_packages, 'setuptools/_distutils/command/_framework_compat.py')
		install_steps_replace(compat, '^(\\s+homebrew_prefix\\s+=\\s+).*', "\\1'${prefix}'", true, 0, false, true)!
	}
}

fn install_steps_run_bootstrap_pypy(mut runner InstallStepsRunner, abi_version string) ! {
	pypy := os.join_path(install_steps_context_path(runner.context, 'bin')!, 'pypy${abi_version}')
	for module_name in ['_sqlite3', '_curses', 'syslog', 'gdbm', '_tkinter'] {
		runner.command(pypy, ['-c', 'import ${module_name}'], InstallStepsCommandOptions{
			must_succeed: false
			print_stdout: false
			print_stderr: false
		})!
	}
	prefix := ruby.environment_value('HOMEBREW_PREFIX')
	site_packages := os.join_path(prefix, 'lib', 'pypy${abi_version}', 'site-packages')
	libexec := install_steps_context_path(runner.context, 'libexec')!
	libexec_site := os.join_path(libexec, 'lib', 'pypy${abi_version}', 'site-packages')
	scripts := os.join_path(prefix, 'share', 'pypy${abi_version}')
	os.mkdir_all(site_packages)!
	mut keep := os.open_append(os.join_path(site_packages, '.keepme'))!
	keep.close()
	if os.exists(libexec_site) || os.is_link(libexec_site) {
		install_steps_remove(libexec_site, true)!
	}
	install_steps_make_symlink(site_packages, libexec_site, false)!
	if abi_version == '3.9' {
		if os.is_link(scripts) {
			os.rm(scripts)!
			os.mkdir_all(scripts)!
			for child in os.ls(install_steps_context_path(runner.context, 'pkgshare')!)! {
				install_steps_make_symlink(os.join_path(install_steps_context_path(runner.context, 'pkgshare')!, child), os.join_path(scripts, child), false)!
			}
		}
		if !os.exists(os.join_path(libexec, 'bin')) {
			install_steps_make_symlink(scripts, os.join_path(libexec, 'bin'), false)!
		}
	}
	os.mkdir_all(scripts)!
	distutils := os.join_path(os.dir(libexec_site), 'distutils/distutils.cfg')
	os.mkdir_all(os.dir(distutils))!
	os.write_file(distutils, '[install]\ninstall-scripts=${scripts}\n')!
	for package in ['setuptools', 'pip'] {
		archive := os.join_path(libexec, 'post-install-resources', '${package}.tar.gz')
		if !os.is_file(archive) {
			return error('PyPy bootstrap archive is missing: ${archive}')
		}
		temporary := os.join_path(ruby.environment_value('HOMEBREW_TEMP'), 'homebrew-pypy-${package}-${os.getpid()}')
		os.mkdir_all(temporary)!
		defer { os.rmdir_all(temporary) or {} }
		runner.run_command('/usr/bin/tar', ['-xzf', archive, '-C', temporary], false)!
		children := os.ls(temporary)!
		source := if children.len == 1 && os.is_dir(os.join_path(temporary, children[0])) {
			os.join_path(temporary, children[0])
		} else {
			temporary
		}
		runner.command(pypy, ['-s', 'setup.py', '--no-user-cfg', 'install', '--force', '--verbose'], InstallStepsCommandOptions{
			chdir: source
			must_succeed: true
			print_stdout: true
			print_stderr: true
		})!
	}
	bin := install_steps_context_path(runner.context, 'bin')!
	install_steps_force_symlink(os.join_path(scripts, 'pip${abi_version}'), os.join_path(bin, 'pip_pypy${abi_version}'))!
	mut prefix_links := ['pip_pypy${abi_version}']
	if install_steps_context_value(runner.context, 'name') == 'pypy3' {
		install_steps_force_symlink('pip_pypy${abi_version}', os.join_path(bin, 'pip_pypy3'))!
		prefix_links << 'pip_pypy3'
	}
	for name in prefix_links {
		install_steps_force_symlink(os.join_path(bin, name), os.join_path(prefix, 'bin', name))!
	}
}

pub fn install_steps_run_formula_action(mut runner InstallStepsRunner, kind string,
	step InstallStep) ! {
	match kind {
		'configure_gcc_runtime' { install_steps_run_configure_gcc_runtime(mut runner)! }
		'install_gzipped_executable' {
			install_steps_run_install_gzipped_executable(mut runner, step)!
		}
		'configure_glibc_runtime' { install_steps_run_configure_glibc_runtime(mut runner)! }
		'configure_clang_system' { install_steps_run_configure_clang_system(mut runner)! }
		'configure_php' { install_steps_run_configure_php(mut runner)! }
		'bootstrap_cpython' { install_steps_run_bootstrap_cpython(mut runner)! }
		'bootstrap_pypy' {
			install_steps_run_bootstrap_pypy(mut runner, install_steps_step_string(step, 'abi_version')!)!
		}
		else {
			return error('unknown formula install action: ${kind}')
		}
	}
}

fn install_steps_parent(path string) string {
	return os.dir(path)
}

pub fn install_steps_sandbox_write_paths(context InstallStepsContext, steps InstallSteps,
	phase string) ![]string {
	mut result := []string{}
	for step in steps {
		kind := install_steps_step_string(step, 'type')!
		if phase == 'uninstall' {
			if kind == 'symlink' && install_steps_step_bool(step, 'uninstall', false) {
				result << install_steps_parent(install_steps_resolve_path(context, install_steps_step_path(step, 'target')!)!)
			}
			continue
		}
		match kind {
			'mkdir', 'mkdir_p', 'touch', 'write' {
				result << install_steps_parent(install_steps_resolve_path(context, install_steps_step_path(step, 'path')!)!)
			}
			'move' {
				result << install_steps_parent(install_steps_resolve_path(context, install_steps_step_path(step, 'source')!)!)
				result << install_steps_parent(install_steps_resolve_path(context, install_steps_step_path(step, 'target')!)!)
			}
			'move_children', 'move_contents' {
				result << install_steps_resolve_path(context, install_steps_step_path(step, 'source')!)!
				result << install_steps_resolve_path(context, install_steps_step_path(step, 'target')!)!
			}
			'copy', 'symlink' {
				result << install_steps_parent(install_steps_resolve_path(context, install_steps_step_path(step, 'target')!)!)
			}
			'remove' {
				for spec in install_steps_step_paths(step, 'paths')! {
					for path in install_steps_expand_path_glob(context, spec)! {
						result << install_steps_parent(path)
					}
				}
			}
			'inreplace', 'change_dylib_id' {
				key := if kind == 'inreplace' { 'path' } else { 'source' }
				result << install_steps_resolve_path(context, install_steps_step_path(step, key)!)!
			}
			'link_dir', 'link_children' {
				result << install_steps_resolve_path(context, install_steps_step_path(step, 'target')!)!
			}
			'run' {
				if raw := step['stdout_path'] {
					result << install_steps_parent(install_steps_resolve_path(context, install_steps_path_spec_from_value(raw))!)
				}
				if raw := step['writable_paths'] {
					for path in raw.array_data {
						result << install_steps_resolve_path(context, install_steps_path_spec_from_value(path))!
					}
				}
			}
			'set_permissions', 'set_ownership' {
				result << install_steps_existing_paths(context, step)!
			}
			else {}
		}
	}
	mut unique := []string{}
	for path in result {
		if path !in unique {
			unique << path
		}
	}
	return unique
}

pub fn install_steps_sudo_required(steps InstallSteps) bool {
	for step in steps {
		sudo := step['sudo'] or { ruby.bool_value(false) }
		kind := install_steps_step_string(step, 'type') or { '' }
		if sudo.bool_data || install_steps_value_string(sudo) == 'if_needed' || kind in [
			'delete_keychain_certificate',
			'set_ownership',
		] {
			return true
		}
	}
	return false
}

fn install_steps_move_children(source string, target string) ! {
	os.mkdir_all(target)!
	for entry in os.ls(source)! {
		child := os.join_path(source, entry)
		if child != target {
			os.mv(child, os.join_path(target, entry))!
		}
	}
}

fn install_steps_replace(path string, before string, after string, regexp bool,
	regexp_options int, first_only bool, audit_result bool) ! {
	content := os.read_file(path)!
	mut replacement := content
	mut found := false
	if regexp {
		mut expression := regex.regex_opt(before)!
		// Ruby's Regexp::IGNORECASE bit is preserved in the serialised step.
		if regexp_options & 1 != 0 {
			expression.flag |= regex.f_ci
		}
		start, _ := expression.find(content)
		found = start >= 0
		replacement = if first_only {
			expression.replace_n(content, after, 1)
		} else {
			expression.replace(content, after)
		}
	} else {
		found = content.contains(before)
		replacement = if first_only {
			content.replace_once(before, after)
		} else {
			content.replace(before, after)
		}
	}
	if audit_result && !found {
		return error('inreplace failed: ${before} not found in ${path}')
	}
	os.write_file(path, replacement)!
}

fn (mut runner InstallStepsRunner) run_delete_keychain_certificate(step InstallStep) ! {
	mut certificate_hash := ''
	if raw := step['matching_certificate'] {
		certificate := install_steps_resolve_path(runner.context, install_steps_path_spec_from_value(raw))!
		if !os.exists(certificate) {
			return
		}
		output := runner.run_command_output('/usr/bin/openssl', ['x509', '-fingerprint', '-sha256',
			'-noout', '-in', certificate], false)!
		first_line := output.split_into_lines()[0] or { '' }
		certificate_hash = first_line.all_after('=').replace(':', '').trim_space().to_upper()
		if certificate_hash == '' {
			return
		}
	}
	output := runner.run_command_output('/usr/bin/security', ['find-certificate', '-a', '-c',
		install_steps_step_string(step, 'name')!, '-Z'], true)!
	mut hashes := []string{}
	for line in output.split_into_lines() {
		if line.trim_space().starts_with('SHA-256 hash:') {
			hashes << line.all_after(':').trim_space().to_upper()
		}
	}
	if certificate_hash != '' {
		if certificate_hash in hashes {
			runner.run_command('/usr/bin/security', ['delete-certificate', '-Z', certificate_hash], true)!
		}
	} else {
		for hash in hashes {
			runner.run_command('/usr/bin/security', ['delete-certificate', '-Z', hash], true)!
		}
	}
}

pub fn install_steps_run_install_step(mut runner InstallStepsRunner, step InstallStep) ! {
	if !runner.step_guards_match(step)! {
		return
	}
	kind := install_steps_step_string(step, 'type')!
	match kind {
		'mkdir' {
			os.mkdir(install_steps_resolve_path(runner.context, install_steps_step_path(step, 'path')!)!)!
		}
		'mkdir_p' {
			os.mkdir_all(install_steps_resolve_path(runner.context, install_steps_step_path(step, 'path')!)!)!
		}
		'init_data_dir' {
			runner.run_init_data_dir(step)!
		}
		'touch' {
			path := install_steps_resolve_path(runner.context, install_steps_step_path(step, 'path')!)!
			os.mkdir_all(os.dir(path))!
			mut file := os.open_append(path)!
			file.close()
		}
		'move' {
			source := install_steps_resolve_source(runner.context, step)!
			target := install_steps_resolve_path(runner.context, install_steps_step_path(step, 'target')!)!
			os.mkdir_all(os.dir(target))!
			destination := install_steps_destination(source, target)
			if _ := step['overwrite'] {
				overwrite := install_steps_step_bool(step, 'overwrite', false) || install_steps_step_bool(step, 'force', false)
				if (os.exists(destination) || os.is_link(destination)) && !overwrite {
					return error('File exists: ${destination}')
				}
				if overwrite && destination != source && (os.exists(source) || os.is_link(source)) && (os.exists(destination) || os.is_link(destination)) {
					install_steps_remove(destination, true)!
				}
			}
			os.mv(source, target)!
		}
		'move_children', 'move_contents' {
			install_steps_move_children(install_steps_resolve_path(runner.context, install_steps_step_path(step, 'source')!)!, install_steps_resolve_path(runner.context, install_steps_step_path(step, 'target')!)!)!
		}
		'copy' {
			install_steps_copy(install_steps_resolve_source(runner.context, step)!, install_steps_resolve_path(runner.context, install_steps_step_path(step, 'target')!)!, install_steps_step_bool(step, 'recursive', false), install_steps_step_bool(step, 'overwrite', true))!
		}
		'remove' {
			mut paths := []string{}
			for spec in install_steps_step_paths(step, 'paths')! {
				paths << install_steps_expand_path_glob(runner.context, spec)!
			}
			if contains := step['symlink_target_contains'] {
				needle := install_steps_value_string(contains)
				paths = paths.filter(os.is_link(it) && (os.readlink(it) or { '' }).contains(needle))
			}
			if contains := step['content_contains'] {
				needle := install_steps_value_string(contains)
				paths = paths.filter(os.is_file(it) && (os.read_file(it) or { '' }).contains(needle))
			}
			for path in paths {
				sudo_value := step['sudo'] or { ruby.bool_value(false) }
				if sudo_value.bool_data || (install_steps_value_string(sudo_value) == 'if_needed' && !os.is_writable(os.dir(path))) {
					arguments := if install_steps_step_bool(step, 'recursive', false) {
						['-rf', path]
					} else {
						['-f', path]
					}
					runner.run_command('/bin/rm', arguments, true)!
				} else if os.exists(path) || os.is_link(path) {
					install_steps_remove(path, install_steps_step_bool(step, 'recursive', false))!
				}
			}
		}
		'inreplace' {
			install_steps_replace(install_steps_resolve_path(runner.context, install_steps_step_path(step, 'path')!)!, install_steps_expand_template_tokens(runner.context, install_steps_step_string(step, 'before')!), install_steps_expand_template_tokens(runner.context, install_steps_step_string(step, 'after')!), install_steps_step_bool(step, 'regexp', false), install_steps_step_int(step, 'regexp_options', 0), install_steps_step_bool(step, 'first_only', false), !install_steps_step_bool(step, 'skip_audit', false))!
		}
		'link_dir' {
			install_steps_link_directory(install_steps_resolve_path(runner.context, install_steps_step_path(step, 'source')!)!, install_steps_resolve_path(runner.context, install_steps_step_path(step, 'target')!)!)!
		}
		'link_children' {
			source_dir := install_steps_resolve_path(runner.context, install_steps_step_path(step, 'source')!)!
			target_dir := install_steps_resolve_path(runner.context, install_steps_step_path(step, 'target')!)!
			os.mkdir_all(target_dir)!
			prefix := install_steps_expand_template_tokens(runner.context, install_steps_step_string(step, 'prefix') or { '' })
			suffix := install_steps_expand_template_tokens(runner.context, install_steps_step_string(step, 'suffix') or { '' })
			for entry in os.ls(source_dir)! {
				runner.create_symlink(os.join_path(source_dir, entry), os.join_path(target_dir, '${prefix}${entry}${suffix}'), step)!
			}
		}
		'symlink' {
			target := install_steps_resolve_path(runner.context, install_steps_step_path(step, 'target')!)!
			if install_steps_step_bool(step, 'source_glob', false) {
				sources := install_steps_expand_path_glob(runner.context, install_steps_step_path(step, 'source')!)!
				if sources.len == 0 {
					return
				}
				if sources.len > 1 || os.is_dir(target) {
					os.mkdir_all(target)!
					for source in sources {
						runner.create_symlink(source, os.join_path(target, os.base(source)), step)!
					}
				} else {
					runner.create_symlink(sources[0], target, step)!
				}
			} else {
				runner.create_symlink(install_steps_link_source(runner.context, install_steps_step_path(step, 'source')!)!, target, step)!
			}
		}
		'write' {
			content := install_steps_step_string(step, 'content') or {
				return error('install step write requires content')
			}
			path := install_steps_resolve_path(runner.context, install_steps_step_path(step, 'path')!)!
			if install_steps_step_bool(step, 'overwrite', false) || !os.exists(path) {
				os.mkdir_all(os.dir(path))!
				os.write_file(path, install_steps_expand_template_tokens(runner.context, content))!
			}
		}
		'run' { runner.run_serialised_command(step)! }
		'terminate_process' { runner.run_terminate_process(step)! }
		'change_dylib_id' {
			install_steps_change_dylib_id(install_steps_resolve_path(runner.context, install_steps_step_path(step, 'source')!)!, install_steps_expand_template_tokens(runner.context, install_steps_step_string(step, 'id')!), install_steps_step_bool(step, 'resolve_source', false), mut runner)!
		}
		'warn' {
			eprintln('Warning: ${install_steps_expand_template_tokens(runner.context, install_steps_step_string(step, 'message')!)}')
		}
		'configure_gcc_runtime', 'install_gzipped_executable', 'configure_glibc_runtime', 'configure_clang_system', 'configure_php', 'bootstrap_cpython', 'bootstrap_pypy' {
			install_steps_run_formula_action(mut runner, kind, step)!
		}
		'set_permissions' { runner.run_set_permissions(step)! }
		'set_ownership' { runner.run_set_ownership(step)! }
		'compile_gsettings_schemas' {
			runner.run_formula_tool('glib', 'glib-compile-schemas', [
				install_steps_resolve_path(runner.context, install_steps_step_path(step, 'path')!)!,
			])!
		}
		'gio_querymodules' {
			runner.run_formula_tool('glib', 'gio-querymodules', [
				install_steps_resolve_path(runner.context, install_steps_step_path(step, 'path')!)!,
			])!
		}
		'gdk_pixbuf_query_loaders' {
			runner.run_formula_tool('gdk-pixbuf', 'gdk-pixbuf-query-loaders', [
				'--update-cache',
			])!
		}
		'gtk_update_icon_cache' {
			formula := if os.is_dir(os.join_path(ruby.environment_value('HOMEBREW_PREFIX'), 'opt', 'gtk4')) {
				'gtk4'
			} else {
				'gtk+3'
			}
			executable := if formula == 'gtk4' {
				'gtk4-update-icon-cache'
			} else {
				'gtk3-update-icon-cache'
			}
			runner.run_formula_tool(formula, executable, ['-q', '-t', '-f',
				install_steps_resolve_path(runner.context, install_steps_step_path(step, 'path')!)!])!
		}
		'update_mime_database' {
			runner.run_formula_tool('shared-mime-info', 'update-mime-database', [
				install_steps_resolve_path(runner.context, install_steps_step_path(step, 'path')!)!,
			])!
		}
		'update_desktop_database' {
			runner.run_formula_tool('desktop-file-utils', 'update-desktop-database', [
				install_steps_resolve_path(runner.context, install_steps_step_path(step, 'path')!)!,
			])!
		}
		'delete_keychain_certificate' { runner.run_delete_keychain_certificate(step)! }
		else {
			return error('unknown install step: ${kind}')
		}
	}
}

pub fn install_steps_run(mut runner InstallStepsRunner, raw_steps InstallSteps,
	phase string) ! {
	runner.guard_results.clear()
	steps := install_steps_normalise(raw_steps.map(ruby.map_value(it)))
	for step in steps {
		if phase == 'uninstall' {
			runner.run_uninstall_step(step)!
		} else {
			install_steps_run_install_step(mut runner, step)!
		}
	}
}

fn install_steps_apply_guard(mut dsl InstallStepsDsl, guard InstallStepPathSpec,
	block ruby.Value) {
	dsl.next_guard_id++
	mut identified_guard := guard.clone()
	identified_guard['id'] = dsl.next_guard_id.str()
	previous_guards := dsl.guards.clone()
	dsl.guards << identified_guard
	for step in install_steps_from_value(block) {
		kind := install_steps_step_string(step, 'type') or { '' }
		mut fields := InstallStep{}
		for key, value in step {
			if key != 'type' {
				fields[key] = value
			}
		}
		install_steps_add(mut dsl, kind, fields)
	}
	dsl.guards = previous_guards
}

fn install_steps_dsl_add_path_step(mut dsl InstallStepsDsl, kind string,
	path ruby.Value, keywords map[string]ruby.Value) {
	base := install_steps_kw_string(keywords, 'base', '')
	install_steps_add(mut dsl, kind, {
		'path': install_steps_path_spec_value(install_steps_path_spec(install_steps_value_string(path), base, '', dsl.default_base))
	})
}

// Translated from Homebrew/brew `install_steps.rb`.
