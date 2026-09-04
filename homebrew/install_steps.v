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
			options.environment} else {
			ruby.environment()}
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

fn install_steps_nil_value() ruby.Value {
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn install_steps_error_value(message string) ruby.Value {
	return ruby.structured_value('ArgumentError', message, {
		'message': message
	})
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

fn install_steps_kw(args []ruby.Value) map[string]ruby.Value {
	for index := args.len - 1; index >= 0; index-- {
		if args[index].type_name == 'Hash' {
			return args[index].map_data.clone()
		}
	}
	return map[string]ruby.Value{}
}

fn install_steps_kw_string(keywords map[string]ruby.Value, key string,
	fallback string) string {
	if value := keywords[key] {
		return install_steps_value_string(value)
	}
	return fallback
}

fn install_steps_kw_bool(keywords map[string]ruby.Value, key string,
	fallback bool) bool {
	if value := keywords[key] {
		return install_steps_value_bool(value, fallback)
	}
	return fallback
}

fn install_steps_string_value(value string) ruby.Value {
	return ruby.string_value(value)
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

pub fn install_steps_dsl_value(dsl InstallStepsDsl) ruby.Value {
	mut guards := []ruby.Value{}
	for guard in dsl.guards {
		guards << install_steps_path_spec_value(guard)
	}
	return ruby.Value{
		type_name: 'InstallSteps::DSL'
		repr: 'InstallSteps::DSL(${dsl.steps.len} steps)'
		map_data: {
			'default_base':        ruby.string_value(dsl.default_base)
			'default_source_base': ruby.string_value(dsl.default_source_base)
			'default_target_base': ruby.string_value(dsl.default_target_base)
			'steps':               install_steps_value(dsl.steps)
			'guards':              ruby.array_value(guards)
			'next_guard_id':       ruby.int_value(dsl.next_guard_id)
		}
	}
}

pub fn install_steps_dsl_from_value(value ruby.Value) InstallStepsDsl {
	mut dsl := InstallStepsDsl{}
	if value.type_name != 'InstallSteps::DSL' {
		return dsl
	}
	dsl.default_base = install_steps_value_string(value.map_data['default_base'] or {
		ruby.string_value('')
	})
	dsl.default_source_base = install_steps_value_string(value.map_data['default_source_base'] or {
		ruby.string_value('')
	})
	dsl.default_target_base = install_steps_value_string(value.map_data['default_target_base'] or {
		ruby.string_value('')
	})
	dsl.steps = install_steps_from_value(value.map_data['steps'] or { ruby.array_value([]) })
	guard_value := value.map_data['guards'] or { ruby.array_value([]) }
	for guard in guard_value.array_data {
		dsl.guards << install_steps_path_spec_from_value(guard)
	}
	dsl.next_guard_id = install_steps_value_int(value.map_data['next_guard_id'] or {
		ruby.int_value(0)
	}, 0)
	return dsl
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

fn install_steps_paths_value(paths []string, base string, default_base string) ruby.Value {
	return ruby.array_value(paths.map(install_steps_path_spec_value(install_steps_path_spec(it, base, '', default_base))))
}

fn install_steps_value_strings(value ruby.Value) []string {
	if value.type_name == 'Array' {
		return (value.as_array() or { []ruby.Value{} }).map(install_steps_value_string(it))
	}
	if value.type_name == 'NilClass' || value.repr == '' {
		return []
	}
	return [install_steps_value_string(value)]
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

fn install_steps_positional(args []ruby.Value, receiver bool) []ruby.Value {
	start := if receiver && args.len > 0 { 1 } else { 0 }
	mut result := []ruby.Value{}
	for value in args[start..] {
		if value.type_name != 'Hash' || value.type_name == 'PathSpec' {
			result << value
		}
	}
	return result
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

fn install_steps_context_from_value(value ruby.Value) InstallStepsContext {
	mut source := value
	if value.type_name == 'InstallSteps::Runner' {
		source = value.map_data['context'] or { ruby.map_value({}) }
	}
	mut values := source.attributes.clone()
	mut config := map[string]string{}
	for key, raw in source.map_data {
		if key == 'config' {
			for config_key, config_value in raw.map_data {
				config[config_key] = install_steps_value_string(config_value)
			}
		} else if raw.type_name != 'Hash' && raw.type_name != 'Array' {
			values[key] = install_steps_value_string(raw)
		}
	}
	return InstallStepsContext{
		values: values
		config: config
	}
}

fn install_steps_context_boundary(context InstallStepsContext) ruby.Value {
	mut values := map[string]ruby.Value{}
	for key, value in context.values {
		values[key] = ruby.string_value(value)
	}
	mut config := map[string]ruby.Value{}
	for key, value in context.config {
		config[key] = ruby.string_value(value)
	}
	values['config'] = ruby.map_value(config)
	return ruby.Value{
		type_name: 'InstallSteps::Context'
		repr: context.values['name'] or { context.values['token'] or { '' } }
		map_data: values
	}
}

fn install_steps_runner_boundary(context InstallStepsContext) ruby.Value {
	return ruby.Value{
		type_name: 'InstallSteps::Runner'
		repr: 'InstallSteps::Runner'
		map_data: {
			'context': install_steps_context_boundary(context)
		}
	}
}

fn install_steps_runner_from_args(args []ruby.Value) InstallStepsRunner {
	context := if args.len > 0 {
		install_steps_context_from_value(args[0])
	} else {
		InstallStepsContext{}
	}
	return new_install_steps_runner(context, NativeInstallStepsCommandExecutor{})
}

fn install_steps_step_from_value(value ruby.Value) InstallStep {
	return InstallStep(value.map_data.clone())
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

fn install_steps_dispatch(marker int, args []ruby.Value) ruby.Value {
	match marker {
		1 {
			if args.len < 2 {
				return install_steps_error_value('change_dylib_id requires file and id')
			}
			mut runner := new_install_steps_runner(InstallStepsContext{}, NativeInstallStepsCommandExecutor{})
			keywords := install_steps_kw(args)
			install_steps_change_dylib_id(install_steps_value_string(args[0]), install_steps_value_string(args[1]), install_steps_kw_bool(keywords, 'resolve_source', false), mut runner) or { return install_steps_error_value(err.msg()) }
			return install_steps_nil_value()
		}
		2 {
			return ruby.string_value('{{version}}')
		}
		3 {
			return ruby.string_value('{{version.major}}')
		}
		4 {
			return ruby.string_value('{{version.major_minor}}')
		}
		5 {
			keywords := install_steps_kw(args)
			return install_steps_dsl_value(new_install_steps_dsl(install_steps_kw_string(keywords, 'default_base', ''), install_steps_kw_string(keywords, 'default_source_base', ''), install_steps_kw_string(keywords, 'default_target_base', '')))
		}
		6 {
			if args.len == 0 {
				return ruby.array_value([])
			}
			return install_steps_value(install_steps_dsl_from_value(args[0]).steps)
		}
		7 {
			return ruby.string_value('{{name}}')
		}
		8 {
			return ruby.string_value('{{formula_name}}')
		}
		9 {
			return ruby.string_value('{{token}}')
		}
		10 {
			return ruby.object_value('InstallSteps::DSL::TemplateVersion', '{{version}}')
		}
		11 {
			keywords := install_steps_kw(args)
			mut dsl := new_install_steps_dsl(install_steps_kw_string(keywords, 'default_base', ''), install_steps_kw_string(keywords, 'default_source_base', ''), install_steps_kw_string(keywords, 'default_target_base', ''))
			for value in args {
				if value.type_name == 'InstallSteps::DSL' {
					return install_steps_value(install_steps_dsl_from_value(value).steps)
				}
				if value.type_name == 'Array' {
					dsl.steps << install_steps_from_value(value)
				}
			}
			return install_steps_value(dsl.steps)
		}
		12, 13, 14, 15, 64 {
			if args.len == 0 {
				return install_steps_error_value('guard method requires a DSL receiver')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			keywords := install_steps_kw(args)
			mut guard := InstallStepPathSpec{}
			mut block := ruby.array_value([])
			if marker in [12, 13] {
				if args.len < 2 {
					return install_steps_error_value('path guard requires a path')
				}
				guard = install_steps_path_spec(install_steps_value_string(args[1]), install_steps_kw_string(keywords, 'base', ''), '', dsl.default_base)
				guard['condition'] = if marker == 12 { 'if_exists' } else { 'unless_exists' }
				if args.len > 2 && args[2].type_name == 'Array' {
					block = args[2]
				}
			} else if marker in [14, 15] {
				guard = {
					'condition': 'on'
					'value':     if marker == 14 { 'macos' } else { 'linux' }
				}
				if args.len > 1 && args[1].type_name == 'Array' {
					block = args[1]
				}
			} else {
				if args.len > 1 {
					guard = install_steps_path_spec_from_value(args[1])
				}
				if args.len > 2 {
					block = args[2]
				}
			}
			install_steps_apply_guard(mut dsl, guard, block)
			return install_steps_dsl_value(dsl)
		}
		16 {
			if args.len == 0 {
				return ruby.array_value([])
			}
			return install_steps_value(install_steps_normalise((args[0].as_array() or {
				[]ruby.Value{}
			})))
		}
		17 {
			if args.len == 0 {
				return ruby.map_value({})
			}
			steps := install_steps_normalise([args[0]])
			return if steps.len > 0 {
				ruby.map_value(steps[0])
			} else {
				ruby.map_value({})
			}
		}
		18 {
			if args.len < 2 {
				return install_steps_nil_value()
			}
			return install_steps_normalise_step_value(install_steps_value_string(args[0]), args[1])
		}
		19 {
			return if args.len > 0 {
				install_steps_normalise_path_value(args[0])
			} else {
				ruby.map_value({})
			}
		}
		20, 21, 22 {
			if args.len < 2 {
				return install_steps_error_value('path step requires receiver and path')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			kind := match marker {
				20 { 'mkdir' }
				21 { 'mkdir_p' }
				else { 'touch' }
			}
			install_steps_dsl_add_path_step(mut dsl, kind, args[1], install_steps_kw(args))
			return install_steps_dsl_value(dsl)
		}
		23, 24, 25, 26, 27, 30, 31, 32, 33, 34, 35, 36, 58 {
			if args.len < 3 {
				return install_steps_error_value('step requires receiver, source and target')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			keywords := install_steps_kw(args)
			source := install_steps_value_string(args[1])
			mut target := install_steps_value_string(args[2])
			if marker in [35, 36] && (args[2].type_name == 'NilClass' || target == '') {
				target = source
			}
			source_spec := install_steps_path_spec_value(install_steps_path_spec(source, install_steps_kw_string(keywords, 'source_base', ''), install_steps_kw_string(keywords, 'source_formula', ''), dsl.default_source_base))
			target_default := if marker in [33, 34, 35, 36] && dsl.default_target_base == '' {
				'homebrew_prefix'
			} else {
				dsl.default_target_base
			}
			target_spec := install_steps_path_spec_value(install_steps_path_spec(target, install_steps_kw_string(keywords, 'target_base', ''), install_steps_kw_string(keywords, 'target_formula', ''), target_default))
			mut fields := {
				'source': source_spec
				'target': target_spec
			}
			mut kind := 'move'
			match marker {
				23, 24 {
					fields['force'] = ruby.bool_value(install_steps_kw_bool(keywords, 'force', false))
					fields['overwrite'] = ruby.bool_value(install_steps_kw_bool(keywords, 'overwrite', true))
					fields['source_glob'] = ruby.bool_value(install_steps_kw_bool(keywords, 'source_glob', false))
				}
				25 {
					kind = 'move_children'
				}
				26 {
					kind = 'move_contents'
				}
				27 {
					kind = 'copy'
					fields['recursive'] = ruby.bool_value(install_steps_kw_bool(keywords, 'recursive', false))
					if !install_steps_kw_bool(keywords, 'overwrite', true) {
						fields['overwrite'] = ruby.bool_value(false)
					}
					fields['source_glob'] = ruby.bool_value(install_steps_kw_bool(keywords, 'source_glob', false))
				}
				30, 31, 32 {
					kind = 'symlink'
					force := marker == 32 || install_steps_kw_bool(keywords, 'force', false) || install_steps_kw_bool(keywords, 'overwrite', false)
					uninstall := install_steps_kw_bool(keywords, 'uninstall', false) || install_steps_kw_bool(keywords, 'remove_on_uninstall', false)
					fields['force'] = if force {
						ruby.bool_value(true)
					} else {
						install_steps_nil_value()
					}
					fields['uninstall'] = if uninstall {
						ruby.bool_value(true)
					} else {
						install_steps_nil_value()
					}
					fields['source_glob'] = ruby.bool_value(install_steps_kw_bool(keywords, 'source_glob', false))
					if sudo := keywords['sudo'] {
						fields['sudo'] = sudo
					}
				}
				33, 34 {
					kind = 'link_dir'
				}
				35, 36 {
					kind = 'link_children'
					fields['prefix'] = ruby.string_value(install_steps_kw_string(keywords, 'prefix', ''))
					fields['suffix'] = ruby.string_value(install_steps_kw_string(keywords, 'suffix', ''))
				}
				58 {
					kind = 'install_gzipped_executable'
				}
				else {}
			}
			install_steps_add(mut dsl, kind, fields)
			return install_steps_dsl_value(dsl)
		}
		28 {
			if args.len < 2 {
				return install_steps_error_value('remove requires paths')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			keywords := install_steps_kw(args)
			paths := install_steps_value_strings(args[1])
			mut fields := {
				'paths':     install_steps_paths_value(paths, install_steps_kw_string(keywords, 'base', ''), dsl.default_base)
				'recursive': ruby.bool_value(install_steps_kw_bool(keywords, 'recursive', false))
			}
			for key in ['sudo', 'symlink_target_contains', 'content_contains'] {
				if value := keywords[key] {
					fields[key] = value
				}
			}
			install_steps_add(mut dsl, 'remove', fields)
			return install_steps_dsl_value(dsl)
		}
		29 {
			if args.len < 4 {
				return install_steps_error_value('inreplace requires path, before and after')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			keywords := install_steps_kw(args)
			regexp_value := args[2].type_name == 'Regexp'
			mut fields := {
				'path':       install_steps_path_spec_value(install_steps_path_spec(install_steps_value_string(args[1]), install_steps_kw_string(keywords, 'base', ''), '', dsl.default_base))
				'before':     ruby.string_value(install_steps_value_string(args[2]))
				'after':      ruby.string_value(install_steps_value_string(args[3]))
				'regexp':     ruby.bool_value(regexp_value)
				'skip_audit': ruby.bool_value(!install_steps_kw_bool(keywords, 'audit_result', true))
				'first_only': ruby.bool_value(!install_steps_kw_bool(keywords, 'global', true))
			}
			if regexp_value {
				fields['regexp_options'] = ruby.int_value((args[2].attributes['options'] or {
					'0'
				}).int())
			}
			install_steps_add(mut dsl, 'inreplace', fields)
			return install_steps_dsl_value(dsl)
		}
		37, 38 {
			if args.len < 3 {
				return install_steps_error_value('write requires path and content')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			keywords := install_steps_kw(args)
			mut content := install_steps_value_string(args[2])
			if (marker == 37 || install_steps_kw_bool(keywords, 'append_newline', false)) && !content.ends_with('\n') {
				content += '\n'
			}
			default_overwrite := marker == 38
			install_steps_add(mut dsl, 'write', {
				'path':      install_steps_path_spec_value(install_steps_path_spec(install_steps_value_string(args[1]), install_steps_kw_string(keywords, 'base', ''), '', dsl.default_base))
				'content':   ruby.string_value(content)
				'overwrite': if install_steps_kw_bool(keywords, 'overwrite', default_overwrite) {
					ruby.bool_value(true)
				} else {
					install_steps_nil_value()
				}
			})
			return install_steps_dsl_value(dsl)
		}
		39 {
			if args.len < 2 {
				return install_steps_error_value('init_data_dir requires path')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			keywords := install_steps_kw(args)
			mut using := install_steps_kw_string(keywords, 'using', '')
			using = match using {
				'postgresql' { 'postgresql_initdb' }
				'mysql' { 'mysql_initialize' }
				'mariadb' { 'mariadb_install_db' }
				else { using }
			}
			install_steps_add(mut dsl, 'init_data_dir', {
				'path':   install_steps_path_spec_value(install_steps_path_spec(install_steps_value_string(args[1]), install_steps_kw_string(keywords, 'base', ''), '', dsl.default_base))
				'using':  ruby.string_value(using)
				'locale': keywords['locale'] or { install_steps_nil_value() }
			})
			return install_steps_dsl_value(dsl)
		}
		40, 41, 42, 43, 44, 45, 46, 47, 48 {
			if args.len == 0 {
				return install_steps_error_value('action requires DSL receiver')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			match marker {
				40 {
					install_steps_add_rebuild_action(mut dsl, 'compile_gsettings_schemas', 'share/glib-2.0/schemas')
				}
				41, 42 {
					install_steps_add_rebuild_action(mut dsl, 'gio_querymodules', 'lib/gio/modules')
				}
				43, 44 { install_steps_add(mut dsl, 'gdk_pixbuf_query_loaders', {}) }
				45, 46 {
					install_steps_add_rebuild_action(mut dsl, 'gtk_update_icon_cache', 'share/icons/hicolor')
				}
				47 {
					install_steps_add_rebuild_action(mut dsl, 'update_mime_database', 'share/mime')
				}
				48 {
					install_steps_add_rebuild_action(mut dsl, 'update_desktop_database', 'share/applications')
				}
				else {}
			}
			return install_steps_dsl_value(dsl)
		}
		49, 50 {
			if args.len < 2 {
				return install_steps_error_value('certificate step requires name')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			keywords := install_steps_kw(args)
			matching_key := if marker == 49 { 'matching_certificate' } else { 'fingerprint_of' }
			mut fields := {
				'name': ruby.string_value(install_steps_value_string(args[1]))
			}
			if matching := keywords[matching_key] {
				fields['matching_certificate'] = install_steps_path_spec_value(install_steps_path_spec(install_steps_value_string(matching), install_steps_kw_string(keywords, 'base', ''), '', ''))
			}
			install_steps_add(mut dsl, 'delete_keychain_certificate', fields)
			return install_steps_dsl_value(dsl)
		}
		51, 52 {
			if args.len < 2 {
				return install_steps_error_value('path mutation step requires paths')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			keywords := install_steps_kw(args)
			mut fields := {
				'paths':         install_steps_paths_value(install_steps_value_strings(args[1]), install_steps_kw_string(keywords, 'base', ''), dsl.default_base)
				'non_recursive': ruby.bool_value(!install_steps_kw_bool(keywords, 'recursive', true))
			}
			kind := if marker == 51 { 'set_permissions' } else { 'set_ownership' }
			if marker == 51 {
				if args.len < 3 {
					return install_steps_error_value('set_permissions requires permissions')
				}
				fields['permissions'] = ruby.string_value(install_steps_value_string(args[2]))
			} else {
				if user := keywords['user'] {
					fields['user'] = user
				}
				group := install_steps_kw_string(keywords, 'group', 'staff')
				if group != 'staff' {
					fields['group'] = ruby.string_value(group)
				}
			}
			install_steps_add(mut dsl, kind, fields)
			return install_steps_dsl_value(dsl)
		}
		53 {
			if args.len < 3 {
				return install_steps_error_value('change_dylib_id requires source and id')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			keywords := install_steps_kw(args)
			install_steps_add(mut dsl, 'change_dylib_id', {
				'source':         install_steps_path_spec_value(install_steps_path_spec(install_steps_value_string(args[1]), install_steps_kw_string(keywords, 'base', ''), '', dsl.default_source_base))
				'id':             ruby.string_value(install_steps_value_string(args[2]))
				'resolve_source': ruby.bool_value(install_steps_kw_bool(keywords, 'resolve_source', false))
			})
			return install_steps_dsl_value(dsl)
		}
		54 {
			if args.len < 2 {
				return install_steps_error_value('run requires command')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			keywords := install_steps_kw(args)
			mut fields := {
				'command':         install_steps_path_spec_value(install_steps_path_spec(install_steps_value_string(args[1]), install_steps_kw_string(keywords, 'base', ''), '', ''))
				'args':            keywords['args'] or { ruby.array_value([]) }
				'env':             keywords['env'] or { ruby.map_value({}) }
				'sudo':            ruby.bool_value(install_steps_kw_bool(keywords, 'sudo', false))
				'allow_failure':   ruby.bool_value(!install_steps_kw_bool(keywords, 'must_succeed', true))
				'print_stdout':    ruby.bool_value(install_steps_kw_bool(keywords, 'print_stdout', false))
				'suppress_stderr': ruby.bool_value(!install_steps_kw_bool(keywords, 'print_stderr', true))
				'network_access':  ruby.bool_value(install_steps_kw_bool(keywords, 'network_access', false))
			}
			for key in ['stdin_path', 'stdout_path', 'chdir'] {
				if value := keywords[key] {
					if value.type_name != 'NilClass' {
						fields[key] = install_steps_path_spec_value(install_steps_path_spec(install_steps_value_string(value), '', '', dsl.default_base))
					}
				}
			}
			if writable := keywords['writable_paths'] {
				fields['writable_paths'] = install_steps_paths_value(install_steps_value_strings(writable), install_steps_kw_string(keywords, 'writable_base', ''), dsl.default_base)
			}
			install_steps_add(mut dsl, 'run', fields)
			return install_steps_dsl_value(dsl)
		}
		55 {
			if args.len < 2 {
				return install_steps_error_value('terminate_process requires name')
			}
			keywords := install_steps_kw(args)
			attempts := install_steps_value_int(keywords['attempts'] or { ruby.int_value(1) }, 1)
			match_value := install_steps_kw_string(keywords, 'match', 'name')
			if attempts < 1 {
				return install_steps_error_value('terminate_process attempts must be positive')
			}
			if match_value !in ['name', 'full'] {
				return install_steps_error_value('terminate_process match must be :name or :full')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			mut fields := {
				'name':            ruby.string_value(install_steps_value_string(args[1]))
				'sudo':            ruby.bool_value(install_steps_kw_bool(keywords, 'sudo', false))
				'must_succeed':    ruby.bool_value(install_steps_kw_bool(keywords, 'must_succeed', false))
				'notices':         keywords['notices'] or { ruby.array_value([]) }
				'failure_message': keywords['failure_message'] or { install_steps_nil_value() }
			}
			if match_value != 'name' {
				fields['match'] = ruby.string_value(match_value)
			}
			if attempts != 1 {
				fields['attempts'] = ruby.int_value(attempts)
			}
			install_steps_add(mut dsl, 'terminate_process', fields)
			return install_steps_dsl_value(dsl)
		}
		56 {
			if args.len < 2 {
				return install_steps_error_value('warn requires message')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			install_steps_add(mut dsl, 'warn', {
				'message': ruby.string_value(install_steps_value_string(args[1]))
			})
			return install_steps_dsl_value(dsl)
		}
		57, 59, 60, 61, 62 {
			if args.len == 0 {
				return install_steps_error_value('action requires DSL receiver')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			kind := match marker {
				57 { 'configure_gcc_runtime' }
				59 { 'configure_glibc_runtime' }
				60 { 'configure_clang_system' }
				61 { 'configure_php' }
				else { 'bootstrap_cpython' }
			}
			install_steps_add(mut dsl, kind, {})
			return install_steps_dsl_value(dsl)
		}
		63 {
			if args.len == 0 {
				return install_steps_error_value('bootstrap_pypy requires DSL receiver')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			keywords := install_steps_kw(args)
			install_steps_add(mut dsl, 'bootstrap_pypy', {
				'abi_version': ruby.string_value(install_steps_kw_string(keywords, 'abi_version', ''))
			})
			return install_steps_dsl_value(dsl)
		}
		65 {
			if args.len < 2 {
				return install_steps_error_value('add_step requires type')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			install_steps_add(mut dsl, install_steps_value_string(args[1]), install_steps_kw(args))
			return install_steps_dsl_value(dsl)
		}
		66 {
			if args.len < 3 {
				return install_steps_error_value('add_rebuild_action requires type and path')
			}
			mut dsl := install_steps_dsl_from_value(args[0])
			install_steps_add_rebuild_action(mut dsl, install_steps_value_string(args[1]), install_steps_value_string(args[2]))
			return install_steps_dsl_value(dsl)
		}
		67 {
			if args.len < 2 {
				return ruby.map_value({})
			}
			dsl := install_steps_dsl_from_value(args[0])
			keywords := install_steps_kw(args)
			return install_steps_path_spec_value(install_steps_path_spec(install_steps_value_string(args[1]), install_steps_kw_string(keywords, 'base', ''), install_steps_kw_string(keywords, 'formula', ''), install_steps_kw_string(keywords, 'default_base', dsl.default_base)))
		}
		68 {
			if args.len < 2 {
				return ruby.array_value([])
			}
			keywords := install_steps_kw(args)
			return install_steps_paths_value(install_steps_value_strings(args[1]), install_steps_kw_string(keywords, 'base', ''), install_steps_kw_string(keywords, 'default_base', ''))
		}
		69 {
			if args.len < 2 || args[1].type_name == 'NilClass' {
				return install_steps_nil_value()
			}
			keywords := install_steps_kw(args)
			return install_steps_path_spec_value(install_steps_path_spec(install_steps_value_string(args[1]), '', '', install_steps_kw_string(keywords, 'default_base', '')))
		}
		70 {
			if args.len < 3 {
				return install_steps_nil_value()
			}
			base := install_steps_default_base_for(install_steps_value_string(args[1]), install_steps_value_string(args[2]))
			return if base == '' {
				install_steps_nil_value()
			} else {
				ruby.string_value(base)
			}
		}
		71 {
			keywords := install_steps_kw(args)
			context_value := keywords['context'] or {
				if args.len > 0 { args[0] } else { ruby.map_value({}) }
			}
			return install_steps_runner_boundary(install_steps_context_from_value(context_value))
		}
		72 {
			if args.len < 2 {
				return install_steps_error_value('runner run requires steps')
			}
			mut runner := install_steps_runner_from_args(args)
			phase := install_steps_kw_string(install_steps_kw(args), 'phase', 'install')
			install_steps_run(mut runner, install_steps_from_value(args[1]), phase) or {
				return install_steps_error_value(err.msg())
			}
			return install_steps_nil_value()
		}
		73 {
			if args.len < 2 {
				return ruby.array_value([])
			}
			context := install_steps_context_from_value(args[0])
			phase := install_steps_kw_string(install_steps_kw(args), 'phase', 'install')
			paths := install_steps_sandbox_write_paths(context, install_steps_from_value(args[1]), phase) or { return install_steps_error_value(err.msg()) }
			return ruby.string_array_value(paths)
		}
		74 {
			return ruby.bool_value(args.len > 1 && install_steps_sudo_required(install_steps_from_value(args[1])))
		}
		75 {
			if args.len < 2 {
				return install_steps_error_value('run_install_step requires step')
			}
			mut runner := install_steps_runner_from_args(args)
			install_steps_run_install_step(mut runner, install_steps_step_from_value(args[1])) or {
				return install_steps_error_value(err.msg())
			}
			return install_steps_nil_value()
		}
		76, 77 {
			if args.len < 2 {
				return ruby.bool_value(false)
			}
			mut runner := install_steps_runner_from_args(args)
			matches := if marker == 76 {
				runner.step_guards_match(install_steps_step_from_value(args[1])) or { false }
			} else {
				runner.guard_matches(install_steps_path_spec_from_value(args[1])) or { false }
			}
			return ruby.bool_value(matches)
		}
		78, 79, 80, 81, 82, 83, 84 {
			if args.len < 2 {
				return install_steps_error_value('runner helper requires arguments')
			}
			mut runner := install_steps_runner_from_args(args)
			step := if marker == 80 && args.len > 3 {
				install_steps_step_from_value(args[3])
			} else {
				install_steps_step_from_value(args[1])
			}
			match marker {
				78 {
					runner.run_serialised_command(step) or { return install_steps_error_value(err.msg()) }
				}
				79 {
					runner.run_terminate_process(step) or { return install_steps_error_value(err.msg()) }
				}
				80 {
					runner.create_symlink(install_steps_value_string(args[1]), install_steps_value_string(args[2]), step) or {
						return install_steps_error_value(err.msg())
					}
				}
				81 {
					runner.run_set_permissions(step) or { return install_steps_error_value(err.msg()) }
				}
				82 {
					runner.run_set_ownership(step) or { return install_steps_error_value(err.msg()) }
				}
				83 {
					runner.run_uninstall_step(step) or { return install_steps_error_value(err.msg()) }
				}
				84 {
					runner.run_init_data_dir(step) or { return install_steps_error_value(err.msg()) }
				}
				else {}
			}
			return install_steps_nil_value()
		}
		85 {
			if args.len < 2 {
				return ruby.string_value('')
			}
			return ruby.string_value(install_steps_expand_template_tokens(install_steps_context_from_value(args[0]), install_steps_value_string(args[1])))
		}
		86 {
			if args.len < 2 {
				return install_steps_nil_value()
			}
			if value := install_steps_token_value(install_steps_context_from_value(args[0]), install_steps_value_string(args[1])) {
				return ruby.string_value(value)
			}
			return install_steps_nil_value()
		}
		87 {
			if args.len < 3 {
				return ruby.map_value({})
			}
			return install_steps_path_spec_value(install_steps_step_path(install_steps_step_from_value(args[1]), install_steps_value_string(args[2])) or { return install_steps_error_value(err.msg()) })
		}
		88 {
			if args.len < 3 {
				return ruby.array_value([])
			}
			paths := install_steps_step_paths(install_steps_step_from_value(args[1]), install_steps_value_string(args[2])) or { return install_steps_error_value(err.msg()) }
			return ruby.array_value(paths.map(install_steps_path_spec_value(it)))
		}
		89 {
			if args.len < 2 {
				return ruby.array_value([])
			}
			paths := install_steps_existing_paths(install_steps_context_from_value(args[0]), install_steps_step_from_value(args[1])) or { return install_steps_error_value(err.msg()) }
			return ruby.string_array_value(paths)
		}
		90 {
			if args.len < 2 {
				return install_steps_nil_value()
			}
			path := install_steps_resolve_source(install_steps_context_from_value(args[0]), install_steps_step_from_value(args[1])) or { return install_steps_error_value(err.msg()) }
			return ruby.object_value('Pathname', path)
		}
		91 {
			if args.len < 3 {
				return install_steps_nil_value()
			}
			return ruby.object_value('Pathname', install_steps_destination(install_steps_value_string(args[1]), install_steps_value_string(args[2])))
		}
		92 {
			if args.len < 2 {
				return ruby.array_value([])
			}
			paths := install_steps_expand_path_glob(install_steps_context_from_value(args[0]), install_steps_path_spec_from_value(args[1])) or {
				return install_steps_error_value(err.msg())
			}
			return ruby.array_value(paths.map(ruby.object_value('Pathname', it)))
		}
		93 {
			if args.len < 2 {
				return ruby.bool_value(false)
			}
			paths := install_steps_expand_path_glob(install_steps_context_from_value(args[0]), install_steps_path_spec_from_value(args[1])) or { []string{} }
			return ruby.bool_value(paths.any(os.exists(it)))
		}
		94 {
			if args.len < 3 {
				return ruby.string_value('')
			}
			return ruby.string_value(install_steps_step_string(install_steps_step_from_value(args[1]), install_steps_value_string(args[2])) or { return install_steps_error_value(err.msg()) })
		}
		95, 96, 97, 98 {
			context := if args.len > 0 {
				install_steps_context_from_value(args[0])
			} else {
				InstallStepsContext{}
			}
			mut value := ''
			if marker == 95 {
				value = install_steps_context_value(context, 'name')
				if value == '' {
					value = install_steps_context_value(context, 'token')
				}
			} else {
				value = install_steps_context_value(context, 'version')
				if marker == 97 && value != '' {
					version := new_version(value) or { return install_steps_nil_value() }
					value = (version.major() or { return install_steps_nil_value() }).to_s()
				} else if marker == 98 && value != '' {
					version := new_version(value) or { return install_steps_nil_value() }
					value = version.major_minor().to_s()
				}
			}
			return if value == '' {
				install_steps_nil_value()
			} else {
				ruby.string_value(value)
			}
		}
		99, 100, 101 {
			if args.len < 2 {
				return install_steps_nil_value()
			}
			context := install_steps_context_from_value(args[0])
			spec := install_steps_path_spec_from_value(args[1])
			value := if marker == 99 {
				install_steps_resolve_path(context, spec) or { return install_steps_error_value(err.msg()) }
			} else if marker == 100 {
				install_steps_resolve_command(context, spec) or { return install_steps_error_value(err.msg()) }
			} else {
				install_steps_link_source(context, spec) or { return install_steps_error_value(err.msg()) }
			}
			return if marker == 100 || marker == 101 {
				ruby.string_value(value)
			} else {
				ruby.object_value('Pathname', value)
			}
		}
		102 {
			if args.len < 3 {
				return install_steps_error_value('run_formula_tool requires formula and executable')
			}
			mut runner := install_steps_runner_from_args(args)
			runner.run_formula_tool(install_steps_value_string(args[1]), install_steps_value_string(args[2]), args[3..].map(install_steps_value_string(it))) or {
				return install_steps_error_value(err.msg())
			}
			return install_steps_nil_value()
		}
		103 {
			if args.len < 2 {
				return install_steps_nil_value()
			}
			path := install_steps_root_path(install_steps_context_from_value(args[0]), install_steps_value_string(args[1]), if args.len > 2 {
				install_steps_value_string(args[2])
			} else {
				''
			}) or { return install_steps_error_value(err.msg()) }
			return ruby.object_value('Pathname', path)
		}
		104 {
			if args.len < 2 {
				return install_steps_nil_value()
			}
			path := install_steps_context_path(install_steps_context_from_value(args[0]), install_steps_value_string(args[1])) or { return install_steps_error_value(err.msg()) }
			return ruby.object_value('Pathname', path)
		}
		105 {
			if args.len < 3 {
				return install_steps_nil_value()
			}
			path := install_steps_formula_base(install_steps_value_string(args[1]), install_steps_value_string(args[2])) or { return install_steps_error_value(err.msg()) }
			return ruby.object_value('Pathname', path)
		}
		106 {
			if args.len < 2 {
				return install_steps_nil_value()
			}
			value := install_steps_context_value(install_steps_context_from_value(args[0]), install_steps_value_string(args[1]))
			return if value == '' {
				install_steps_nil_value()
			} else {
				ruby.string_value(value)
			}
		}
		107 {
			if args.len < 2 {
				return install_steps_nil_value()
			}
			context := install_steps_context_from_value(args[0])
			value := context.config[install_steps_value_string(args[1])] or { '' }
			return if value == '' {
				install_steps_nil_value()
			} else {
				ruby.string_value(value)
			}
		}
		108, 109 {
			if args.len < 2 {
				return install_steps_error_value('run_command requires command')
			}
			mut runner := install_steps_runner_from_args(args)
			keywords := install_steps_kw(args)
			mut command_args := []string{}
			for value in args[2..] {
				if value.type_name != 'Hash' {
					command_args << install_steps_value_string(value)
				}
			}
			if marker == 108 {
				runner.run_command(install_steps_value_string(args[1]), command_args, install_steps_kw_bool(keywords, 'sudo', false)) or {
					return install_steps_error_value(err.msg())
				}
				return install_steps_nil_value()
			}
			output := runner.run_command_output(install_steps_value_string(args[1]), command_args, install_steps_kw_bool(keywords, 'sudo', false)) or {
				return install_steps_error_value(err.msg())
			}
			return ruby.string_value(output)
		}
		else {
			return install_steps_error_value('unknown InstallSteps boundary ${marker}')
		}
	}
}

// Translated from Homebrew/brew `install_steps.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.change_dylib_id(file, id, resolve_source: false)` at line 27.
pub fn ruby_install_steps_l27_d1_self_change_dylib_id(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(1, args)
}

// Ruby method `to_s` at line 44.
pub fn ruby_install_steps_l44_d2_to_s(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(2, args)
}

// Ruby method `major` at line 49.
pub fn ruby_install_steps_l49_d3_major(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(3, args)
}

// Ruby method `major_minor` at line 54.
pub fn ruby_install_steps_l54_d4_major_minor(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(4, args)
}

// Ruby method `initialize(default_base: nil, default_source_base: nil, default_target_base: nil)` at line 79.
pub fn ruby_install_steps_l79_d5_initialize(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(5, args)
}

// Ruby attr_reader `attr_reader :steps` at line 89.
pub fn ruby_install_steps_l89_d6_steps(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(6, args)
}

// Ruby method `name` at line 93.
pub fn ruby_install_steps_l93_d7_name(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(7, args)
}

// Ruby method `formula_name` at line 98.
pub fn ruby_install_steps_l98_d8_formula_name(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(8, args)
}

// Ruby method `token` at line 103.
pub fn ruby_install_steps_l103_d9_token(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(9, args)
}

// Ruby method `version` at line 108.
pub fn ruby_install_steps_l108_d10_version(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(10, args)
}

// Ruby method `self.build(default_base: nil, default_source_base: nil, default_target_base: nil, &block)` at line 120.
pub fn ruby_install_steps_l120_d11_self_build(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(11, args)
}

// Ruby method `if_path_exists(path, base: nil, &block)` at line 133.
pub fn ruby_install_steps_l133_d12_if_path_exists(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(12, args)
}

// Ruby method `unless_path_exists(path, base: nil, &block)` at line 144.
pub fn ruby_install_steps_l144_d13_unless_path_exists(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(13, args)
}

// Ruby method `on_macos(&block)` at line 149.
pub fn ruby_install_steps_l149_d14_on_macos(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(14, args)
}

// Ruby method `on_linux(&block)` at line 154.
pub fn ruby_install_steps_l154_d15_on_linux(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(15, args)
}

// Ruby method `self.normalise_steps(steps)` at line 159.
pub fn ruby_install_steps_l159_d16_self_normalise_steps(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(16, args)
}

// Ruby method `self.compact_step(step)` at line 170.
pub fn ruby_install_steps_l170_d17_self_compact_step(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(17, args)
}

// Ruby method `self.normalise_step_value(key, obj)` at line 187.
pub fn ruby_install_steps_l187_d18_self_normalise_step_value(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(18, args)
}

// Ruby method `self.normalise_path_value(obj)` at line 218.
pub fn ruby_install_steps_l218_d19_self_normalise_path_value(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(19, args)
}

// Ruby method `mkdir(path, base: nil)` at line 230.
pub fn ruby_install_steps_l230_d20_mkdir(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(20, args)
}

// Ruby method `mkdir_p(path, base: nil)` at line 235.
pub fn ruby_install_steps_l235_d21_mkdir_p(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(21, args)
}

// Ruby method `touch(path, base: nil)` at line 240.
pub fn ruby_install_steps_l240_d22_touch(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(22, args)
}

// Ruby method `move(source, target, source_base: nil, target_base: nil, force: false, overwrite: true, source_glob: false)` at line 256.
pub fn ruby_install_steps_l256_d23_move(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(23, args)
}

// Ruby alias `alias mv move` at line 266.
pub fn ruby_install_steps_l266_d24_mv(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(24, args)
}

// Ruby method `move_children(source, target, source_base: nil, target_base: nil)` at line 277.
pub fn ruby_install_steps_l277_d25_move_children(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(25, args)
}

// Ruby method `move_contents(source, target, source_base: nil, target_base: nil)` at line 291.
pub fn ruby_install_steps_l291_d26_move_contents(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(26, args)
}

// Ruby method `copy(source, target, source_base: nil, target_base: nil, recursive: false, overwrite: true,` at line 308.
pub fn ruby_install_steps_l308_d27_copy(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(27, args)
}

// Ruby method `remove(paths, base: nil, recursive: false, sudo: false, symlink_target_contains: nil,` at line 328.
pub fn ruby_install_steps_l328_d28_remove(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(28, args)
}

// Ruby method `inreplace(path, before, after, base: nil, audit_result: true, global: true)` at line 348.
pub fn ruby_install_steps_l348_d29_inreplace(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(29, args)
}

// Ruby method `symlink(source, target, source_base: nil, target_base: nil, source_formula: nil, target_formula: nil,` at line 377.
pub fn ruby_install_steps_l377_d30_symlink(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(30, args)
}

// Ruby method `ln_s(source, target, source_base: nil, target_base: nil, source_formula: nil, target_formula: nil,` at line 404.
pub fn ruby_install_steps_l404_d31_ln_s(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(31, args)
}

// Ruby method `ln_sf(source, target, source_base: nil, target_base: nil, source_formula: nil, target_formula: nil,` at line 421.
pub fn ruby_install_steps_l421_d32_ln_sf(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(32, args)
}

// Ruby method `link_dir(source, target, source_base: nil, target_base: :homebrew_prefix)` at line 435.
pub fn ruby_install_steps_l435_d33_link_dir(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(33, args)
}

// Ruby method `symlink_tree(source, target, source_base: nil, target_base: :homebrew_prefix)` at line 449.
pub fn ruby_install_steps_l449_d34_symlink_tree(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(34, args)
}

// Ruby method `link_children(source, target = nil, source_base: nil, target_base: :homebrew_prefix, prefix: "", suffix: "")` at line 466.
pub fn ruby_install_steps_l466_d35_link_children(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(35, args)
}

// Ruby method `symlink_children(source, target = nil, source_base: nil, target_base: :homebrew_prefix, prefix: "",` at line 484.
pub fn ruby_install_steps_l484_d36_symlink_children(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(36, args)
}

// Ruby method `write(path, content, base: nil, overwrite: false)` at line 502.
pub fn ruby_install_steps_l502_d37_write(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(37, args)
}

// Ruby method `write_file(path, content, base: nil, overwrite: true, append_newline: false)` at line 519.
pub fn ruby_install_steps_l519_d38_write_file(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(38, args)
}

// Ruby method `init_data_dir(path, using:, base: nil, locale: nil)` at line 535.
pub fn ruby_install_steps_l535_d39_init_data_dir(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(39, args)
}

// Ruby method `compile_gsettings_schemas` at line 549.
pub fn ruby_install_steps_l549_d40_compile_gsettings_schemas(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(40, args)
}

// Ruby method `gio_querymodules` at line 555.
pub fn ruby_install_steps_l555_d41_gio_querymodules(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(41, args)
}

// Ruby method `update_gio_modules_cache` at line 560.
pub fn ruby_install_steps_l560_d42_update_gio_modules_cache(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(42, args)
}

// Ruby method `gdk_pixbuf_query_loaders` at line 566.
pub fn ruby_install_steps_l566_d43_gdk_pixbuf_query_loaders(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(43, args)
}

// Ruby method `update_gdk_pixbuf_loaders_cache` at line 571.
pub fn ruby_install_steps_l571_d44_update_gdk_pixbuf_loaders_cache(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(44, args)
}

// Ruby method `gtk_update_icon_cache` at line 577.
pub fn ruby_install_steps_l577_d45_gtk_update_icon_cache(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(45, args)
}

// Ruby method `update_gtk_icon_cache` at line 582.
pub fn ruby_install_steps_l582_d46_update_gtk_icon_cache(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(46, args)
}

// Ruby method `update_mime_database` at line 587.
pub fn ruby_install_steps_l587_d47_update_mime_database(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(47, args)
}

// Ruby method `update_desktop_database` at line 592.
pub fn ruby_install_steps_l592_d48_update_desktop_database(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(48, args)
}

// Ruby method `delete_keychain_certificate(name, matching_certificate: nil, base: nil)` at line 604.
pub fn ruby_install_steps_l604_d49_delete_keychain_certificate(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(49, args)
}

// Ruby method `delete_keychain_certificates(name, fingerprint_of: nil, base: nil)` at line 618.
pub fn ruby_install_steps_l618_d50_delete_keychain_certificates(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(50, args)
}

// Ruby method `set_permissions(paths, permissions, base: nil, recursive: true)` at line 632.
pub fn ruby_install_steps_l632_d51_set_permissions(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(51, args)
}

// Ruby method `set_ownership(paths, user: nil, group: "staff", base: nil, recursive: true)` at line 648.
pub fn ruby_install_steps_l648_d52_set_ownership(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(52, args)
}

// Ruby method `change_dylib_id(source, id, base: nil, resolve_source: false)` at line 664.
pub fn ruby_install_steps_l664_d53_change_dylib_id(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(53, args)
}

// Ruby method `run(command, args: [], base: nil, env: {}, sudo: false, must_succeed: true, print_stdout: false,` at line 689.
pub fn ruby_install_steps_l689_d54_run(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(54, args)
}

// Ruby method `terminate_process(name, match: :name, sudo: false, attempts: 1, must_succeed: false,` at line 722.
pub fn ruby_install_steps_l722_d55_terminate_process(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(55, args)
}

// Ruby method `warn(message)` at line 742.
pub fn ruby_install_steps_l742_d56_warn(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(56, args)
}

// Ruby method `configure_gcc_runtime` at line 747.
pub fn ruby_install_steps_l747_d57_configure_gcc_runtime(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(57, args)
}

// Ruby method `install_gzipped_executable(source, target, source_base: nil, target_base: nil)` at line 759.
pub fn ruby_install_steps_l759_d58_install_gzipped_executable(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(58, args)
}

// Ruby method `configure_glibc_runtime` at line 766.
pub fn ruby_install_steps_l766_d59_configure_glibc_runtime(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(59, args)
}

// Ruby method `configure_clang_system` at line 771.
pub fn ruby_install_steps_l771_d60_configure_clang_system(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(60, args)
}

// Ruby method `configure_php` at line 776.
pub fn ruby_install_steps_l776_d61_configure_php(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(61, args)
}

// Ruby method `bootstrap_cpython` at line 781.
pub fn ruby_install_steps_l781_d62_bootstrap_cpython(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(62, args)
}

// Ruby method `bootstrap_pypy(abi_version:)` at line 786.
pub fn ruby_install_steps_l786_d63_bootstrap_pypy(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(63, args)
}

// Ruby method `with_guard(guard, &block)` at line 793.
pub fn ruby_install_steps_l793_d64_with_guard(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(64, args)
}

// Ruby method `add_step(type, **fields)` at line 804.
pub fn ruby_install_steps_l804_d65_add_step(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(65, args)
}

// Ruby method `add_rebuild_action(type, path)` at line 812.
pub fn ruby_install_steps_l812_d66_add_rebuild_action(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(66, args)
}

// Ruby method `path_spec(path, base:, formula: nil, default_base: nil)` at line 824.
pub fn ruby_install_steps_l824_d67_path_spec(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(67, args)
}

// Ruby method `path_specs(paths, base:, default_base:)` at line 839.
pub fn ruby_install_steps_l839_d68_path_specs(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(68, args)
}

// Ruby method `optional_path_spec(path, default_base:)` at line 850.
pub fn ruby_install_steps_l850_d69_optional_path_spec(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(69, args)
}

// Ruby method `default_base_for(path, default_base)` at line 860.
pub fn ruby_install_steps_l860_d70_default_base_for(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(70, args)
}

// Ruby method `initialize(context:, command: SystemCommand)` at line 884.
pub fn ruby_install_steps_l884_d71_initialize(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(71, args)
}

// Ruby method `run(steps, phase: :install)` at line 891.
pub fn ruby_install_steps_l891_d72_run(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(72, args)
}

// Ruby method `sandbox_write_paths(steps, phase: :install)` at line 903.
pub fn ruby_install_steps_l903_d73_sandbox_write_paths(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(73, args)
}

// Ruby method `sudo_required?(steps)` at line 944.
pub fn ruby_install_steps_l944_d74_sudo_required(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(74, args)
}

// Ruby method `run_install_step(step)` at line 954.
pub fn ruby_install_steps_l954_d75_run_install_step(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(75, args)
}

// Ruby method `step_guards_match?(step)` at line 1172.
pub fn ruby_install_steps_l1172_d76_step_guards_match(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(76, args)
}

// Ruby method `guard_matches?(guard)` at line 1178.
pub fn ruby_install_steps_l1178_d77_guard_matches(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(77, args)
}

// Ruby method `run_serialised_command(step)` at line 1199.
pub fn ruby_install_steps_l1199_d78_run_serialised_command(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(78, args)
}

// Ruby method `run_terminate_process(step)` at line 1221.
pub fn ruby_install_steps_l1221_d79_run_terminate_process(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(79, args)
}

// Ruby method `create_symlink(source, target, step)` at line 1253.
pub fn ruby_install_steps_l1253_d80_create_symlink(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(80, args)
}

// Ruby method `run_set_permissions(step)` at line 1266.
pub fn ruby_install_steps_l1266_d81_run_set_permissions(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(81, args)
}

// Ruby method `run_set_ownership(step)` at line 1276.
pub fn ruby_install_steps_l1276_d82_run_set_ownership(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(82, args)
}

// Ruby method `run_uninstall_step(step)` at line 1304.
pub fn ruby_install_steps_l1304_d83_run_uninstall_step(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(83, args)
}

// Ruby method `run_init_data_dir(step)` at line 1321.
pub fn ruby_install_steps_l1321_d84_run_init_data_dir(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(84, args)
}

// Ruby method `expand_template_tokens(content)` at line 1358.
pub fn ruby_install_steps_l1358_d85_expand_template_tokens(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(85, args)
}

// Ruby method `template_token_value(token)` at line 1366.
pub fn ruby_install_steps_l1366_d86_template_token_value(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(86, args)
}

// Ruby method `step_path(step, key)` at line 1394.
pub fn ruby_install_steps_l1394_d87_step_path(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(87, args)
}

// Ruby method `step_paths(step, key)` at line 1399.
pub fn ruby_install_steps_l1399_d88_step_paths(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(88, args)
}

// Ruby method `existing_step_paths(step)` at line 1404.
pub fn ruby_install_steps_l1404_d89_existing_step_paths(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(89, args)
}

// Ruby method `resolve_step_source(step)` at line 1409.
pub fn ruby_install_steps_l1409_d90_resolve_step_source(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(90, args)
}

// Ruby method `step_destination(source, target)` at line 1421.
pub fn ruby_install_steps_l1421_d91_step_destination(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(91, args)
}

// Ruby method `expand_path_glob(spec)` at line 1426.
pub fn ruby_install_steps_l1426_d92_expand_path_glob(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(92, args)
}

// Ruby method `path_spec_exists?(spec)` at line 1445.
pub fn ruby_install_steps_l1445_d93_path_spec_exists(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(93, args)
}

// Ruby method `step_string(step, key)` at line 1450.
pub fn ruby_install_steps_l1450_d94_step_string(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(94, args)
}

// Ruby method `context_name` at line 1455.
pub fn ruby_install_steps_l1455_d95_context_name(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(95, args)
}

// Ruby method `context_version` at line 1461.
pub fn ruby_install_steps_l1461_d96_context_version(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(96, args)
}

// Ruby method `context_version_major` at line 1466.
pub fn ruby_install_steps_l1466_d97_context_version_major(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(97, args)
}

// Ruby method `context_version_major_minor` at line 1474.
pub fn ruby_install_steps_l1474_d98_context_version_major_minor(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(98, args)
}

// Ruby method `resolve_path(spec)` at line 1482.
pub fn ruby_install_steps_l1482_d99_resolve_path(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(99, args)
}

// Ruby method `resolve_command(spec)` at line 1493.
pub fn ruby_install_steps_l1493_d100_resolve_command(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(100, args)
}

// Ruby method `link_source(spec)` at line 1500.
pub fn ruby_install_steps_l1500_d101_link_source(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(101, args)
}

// Ruby method `run_formula_tool(formula, executable, *args)` at line 1507.
pub fn ruby_install_steps_l1507_d102_run_formula_tool(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(102, args)
}

// Ruby method `root_path(base, formula)` at line 1517.
pub fn ruby_install_steps_l1517_d103_root_path(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(103, args)
}

// Ruby method `context_path(base)` at line 1535.
pub fn ruby_install_steps_l1535_d104_context_path(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(104, args)
}

// Ruby method `formula_base(formula, method)` at line 1544.
pub fn ruby_install_steps_l1544_d105_formula_base(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(105, args)
}

// Ruby method `context_value(method)` at line 1558.
pub fn ruby_install_steps_l1558_d106_context_value(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(106, args)
}

// Ruby method `context_config_value(method)` at line 1563.
pub fn ruby_install_steps_l1563_d107_context_config_value(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(107, args)
}

// Ruby method `run_command(command, *args, sudo: false)` at line 1569.
pub fn ruby_install_steps_l1569_d108_run_command(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(108, args)
}

// Ruby method `run_command_output(command, *args, sudo: false)` at line 1574.
pub fn ruby_install_steps_l1574_d109_run_command_output(args ...ruby.Value) ruby.Value {
	return install_steps_dispatch(109, args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "simulate_system"
// 5: require "system_command"
// 6: require "utils/output"
// 7:
// 8: module Homebrew
// 9:   # Declarative install steps that can be serialised through the JSON APIs.
// 10:   module InstallSteps
// 11:     PathSpec = T.type_alias { T::Hash[String, String] }
// 12:     PathSpecs = T.type_alias { T::Array[PathSpec] }
// 13:     StepValue = T.type_alias { T.any(String, Integer, T::Boolean, T::Array[String], PathSpec, PathSpecs) }
// 14:     Step = T.type_alias { T::Hash[String, StepValue] }
// 15:     Steps = T.type_alias { T::Array[Step] }
// 16:     Paths = T.type_alias { T.any(String, Pathname, T::Array[T.any(String, Pathname)]) }
// 17:     RawPathSpec = T.type_alias { T::Hash[T.any(String, Symbol), T.nilable(T.any(String, Symbol, Pathname))] }
// 18:     RawPathSpecs = T.type_alias { T::Array[T.any(String, Symbol, Pathname, RawPathSpec)] }
// 19:     RawStepValue = T.type_alias do
// 20:       T.nilable(T.any(String, Symbol, Integer, T::Boolean, Pathname, RawPathSpec, RawPathSpecs))
// 21:     end
// 22:     RawStep = T.type_alias { T::Hash[T.any(String, Symbol), RawStepValue] }
// 23:     SystemCommandArg = T.type_alias { T.any(String, Pathname) }
// 24:     TemplateTokenValue = T.type_alias { T.any(String, Pathname) }
// 25:
// 26:     sig { params(file: Pathname, id: T.any(String, Pathname), resolve_source: T::Boolean).void }
// 27:     def self.change_dylib_id(file, id, resolve_source: false)
// 28:       file = file.realpath if resolve_source
// 29:
// 30:       require "macho"
// 31:       file.ensure_writable do
// 32:         MachO::Tools.change_dylib_id file, id.to_s
// 33:         MachO.codesign! file if Hardware::CPU.arm?
// 34:       end
// 35:     end
// 36:
// 37:     class DSL
// 38:       ((instance_methods + private_instance_methods) -
// 39:         (BasicObject.instance_methods + BasicObject.private_instance_methods) -
// 40:         [:__callee__, :__method__, :class, :object_id]).each { |method| undef_method method }
// 41:
// 42:       class TemplateVersion
// 43:         sig { returns(String) }
// 44:         def to_s
// 45:           "{{version}}"
// 46:         end
// 47:
// 48:         sig { returns(String) }
// 49:         def major
// 50:           "{{version.major}}"
// 51:         end
// 52:
// 53:         sig { returns(String) }
// 54:         def major_minor
// 55:           "{{version.major_minor}}"
// 56:         end
// 57:       end
// 58:       private_constant :TemplateVersion
// 59:
// 60:       TEMPLATE_VERSION = TemplateVersion.new.freeze
// 61:       private_constant :TEMPLATE_VERSION
// 62:
// 63:       ABSOLUTE_TEMPLATE_TOKENS = %w[
// 64:         HOMEBREW_PREFIX HOMEBREW_CELLAR prefix opt_prefix bin sbin lib libexec share pkgshare var etc pkgetc
// 65:         staged_path appdir caskroom_path temp rack bash_completion zsh_completion fish_completion pwsh_completion
// 66:       ].freeze
// 67:       private_constant :ABSOLUTE_TEMPLATE_TOKENS
// 68:
// 69:       PRESERVED_STEP_VALUE_KEYS = %w[after args before content env overwrite].freeze
// 70:       private_constant :PRESERVED_STEP_VALUE_KEYS
// 71:
// 72:       sig {
// 73:         params(
// 74:           default_base:        ::T.nilable(::T.any(::String, ::Symbol)),
// 75:           default_source_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 76:           default_target_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 77:         ).void
// 78:       }
// 79:       def initialize(default_base: nil, default_source_base: nil, default_target_base: nil)
// 80:         @default_base = default_base
// 81:         @default_source_base = default_source_base
// 82:         @default_target_base = default_target_base
// 83:         @steps = ::T.let([], Steps)
// 84:         @guards = ::T.let([], PathSpecs)
// 85:         @next_guard_id = ::T.let(0, ::Integer)
// 86:       end
// 87:
// 88:       sig { returns(Steps) }
// 89:       attr_reader :steps
// 90:
// 91:       # odeprecated
// 92:       sig { returns(String) }
// 93:       def name
// 94:         "{{name}}"
// 95:       end
// 96:
// 97:       sig { returns(String) }
// 98:       def formula_name
// 99:         "{{formula_name}}"
// 100:       end
// 101:
// 102:       sig { returns(String) }
// 103:       def token
// 104:         "{{token}}"
// 105:       end
// 106:
// 107:       sig { returns(TemplateVersion) }
// 108:       def version
// 109:         TEMPLATE_VERSION
// 110:       end
// 111:
// 112:       sig {
// 113:         params(
// 114:           default_base:        ::T.nilable(::T.any(::String, ::Symbol)),
// 115:           default_source_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 116:           default_target_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 117:           block:               ::T.nilable(::T.proc.bind(DSL).void),
// 118:         ).returns(Steps)
// 119:       }
// 120:       def self.build(default_base: nil, default_source_base: nil, default_target_base: nil, &block)
// 121:         dsl = new(default_base:, default_source_base:, default_target_base:)
// 122:         dsl.instance_eval(&block) if block
// 123:         dsl.steps
// 124:       end
// 125:
// 126:       sig {
// 127:         params(
// 128:           path:  ::T.any(::String, ::Pathname),
// 129:           base:  ::T.nilable(::T.any(::String, ::Symbol)),
// 130:           block: ::T.proc.void,
// 131:         ).void
// 132:       }
// 133:       def if_path_exists(path, base: nil, &block)
// 134:         with_guard(path_spec(path, base:, default_base: @default_base).merge("condition" => "if_exists"), &block)
// 135:       end
// 136:
// 137:       sig {
// 138:         params(
// 139:           path:  ::T.any(::String, ::Pathname),
// 140:           base:  ::T.nilable(::T.any(::String, ::Symbol)),
// 141:           block: ::T.proc.void,
// 142:         ).void
// 143:       }
// 144:       def unless_path_exists(path, base: nil, &block)
// 145:         with_guard(path_spec(path, base:, default_base: @default_base).merge("condition" => "unless_exists"), &block)
// 146:       end
// 147:
// 148:       sig { params(block: ::T.proc.void).void }
// 149:       def on_macos(&block)
// 150:         with_guard({ "condition" => "on", "value" => "macos" }, &block)
// 151:       end
// 152:
// 153:       sig { params(block: ::T.proc.void).void }
// 154:       def on_linux(&block)
// 155:         with_guard({ "condition" => "on", "value" => "linux" }, &block)
// 156:       end
// 157:
// 158:       sig { params(steps: ::T::Array[RawStep]).returns(Steps) }
// 159:       def self.normalise_steps(steps)
// 160:         steps.map do |step|
// 161:           step = step.to_h do |key, value|
// 162:             key = key.to_s
// 163:             [key, normalise_step_value(key, value)]
// 164:           end
// 165:           compact_step(step)
// 166:         end
// 167:       end
// 168:
// 169:       sig { params(step: ::T::Hash[String, ::T.nilable(StepValue)]).returns(Step) }
// 170:       def self.compact_step(step)
// 171:         compacted_step = ::T.cast(
// 172:           ::Utils.deep_compact_blank(step.except(*PRESERVED_STEP_VALUE_KEYS)) || {},
// 173:           Step,
// 174:         )
// 175:         PRESERVED_STEP_VALUE_KEYS.each do |key|
// 176:           value = step[key]
// 177:           next if value.nil?
// 178:           next if %w[args env].include?(key) && [[], {}].include?(value)
// 179:
// 180:           compacted_step[key] = value
// 181:         end
// 182:         compacted_step
// 183:       end
// 184:       private_class_method :compact_step
// 185:
// 186:       sig { params(key: String, obj: RawStepValue).returns(::T.nilable(StepValue)) }
// 187:       def self.normalise_step_value(key, obj)
// 188:         case obj
// 189:         when Symbol
// 190:           obj.to_s
// 191:         when Array
// 192:           if %w[guards paths writable_paths].include?(key)
// 193:             obj.map { |value| normalise_path_value(value) }
// 194:           else
// 195:             obj.map(&:to_s)
// 196:           end
// 197:         when Hash
// 198:           if key == "env"
// 199:             ::T.cast(obj.to_h { |env_key, value| [env_key.to_s, value&.to_s] }.compact, PathSpec)
// 200:           else
// 201:             normalise_path_value(obj)
// 202:           end
// 203:         when String, Pathname
// 204:           if %w[
// 205:             path source target command matching_certificate stdin_path stdout_path chdir
// 206:           ].include?(key)
// 207:             normalise_path_value(obj)
// 208:           else
// 209:             obj.to_s
// 210:           end
// 211:         else
// 212:           obj
// 213:         end
// 214:       end
// 215:       private_class_method :normalise_step_value
// 216:
// 217:       sig { params(obj: T.any(String, Symbol, Pathname, RawPathSpec)).returns(PathSpec) }
// 218:       def self.normalise_path_value(obj)
// 219:         case obj
// 220:         when Hash
// 221:           ::T.cast(obj.to_h { |key, value| [key.to_s, value&.to_s] }.compact_blank, PathSpec)
// 222:         else
// 223:           { "path" => obj.to_s }
// 224:         end
// 225:       end
// 226:       private_class_method :normalise_path_value
// 227:
// 228:       # odeprecated
// 229:       sig { params(path: ::T.any(::String, ::Pathname), base: ::T.nilable(::T.any(::String, ::Symbol))).void }
// 230:       def mkdir(path, base: nil)
// 231:         add_step("mkdir", "path" => path_spec(path, base:, default_base: @default_base))
// 232:       end
// 233:
// 234:       sig { params(path: ::T.any(::String, ::Pathname), base: ::T.nilable(::T.any(::String, ::Symbol))).void }
// 235:       def mkdir_p(path, base: nil)
// 236:         add_step("mkdir_p", "path" => path_spec(path, base:, default_base: @default_base))
// 237:       end
// 238:
// 239:       sig { params(path: ::T.any(::String, ::Pathname), base: ::T.nilable(::T.any(::String, ::Symbol))).void }
// 240:       def touch(path, base: nil)
// 241:         add_step("touch", "path" => path_spec(path, base:, default_base: @default_base))
// 242:       end
// 243:
// 244:       sig {
// 245:         params(
// 246:           source:      ::T.any(::String, ::Pathname),
// 247:           target:      ::T.any(::String, ::Pathname),
// 248:           source_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 249:           target_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 250:           # odeprecated
// 251:           force:       ::T::Boolean,
// 252:           overwrite:   ::T::Boolean,
// 253:           source_glob: ::T::Boolean,
// 254:         ).void
// 255:       }
// 256:       def move(source, target, source_base: nil, target_base: nil, force: false, overwrite: true, source_glob: false)
// 257:         add_step("move",
// 258:                  "source"      => path_spec(source, base: source_base, default_base: @default_source_base),
// 259:                  "target"      => path_spec(target, base: target_base, default_base: @default_target_base),
// 260:                  "force"       => force,
// 261:                  "overwrite"   => overwrite,
// 262:                  "source_glob" => source_glob)
// 263:       end
// 264:
// 265:       # odeprecated
// 266:       alias mv move
// 267:
// 268:       # odeprecated
// 269:       sig {
// 270:         params(
// 271:           source:      ::T.any(::String, ::Pathname),
// 272:           target:      ::T.any(::String, ::Pathname),
// 273:           source_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 274:           target_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 275:         ).void
// 276:       }
// 277:       def move_children(source, target, source_base: nil, target_base: nil)
// 278:         add_step("move_children",
// 279:                  "source" => path_spec(source, base: source_base, default_base: @default_source_base),
// 280:                  "target" => path_spec(target, base: target_base, default_base: @default_target_base))
// 281:       end
// 282:
// 283:       sig {
// 284:         params(
// 285:           source:      ::T.any(::String, ::Pathname),
// 286:           target:      ::T.any(::String, ::Pathname),
// 287:           source_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 288:           target_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 289:         ).void
// 290:       }
// 291:       def move_contents(source, target, source_base: nil, target_base: nil)
// 292:         add_step("move_contents",
// 293:                  "source" => path_spec(source, base: source_base, default_base: @default_source_base),
// 294:                  "target" => path_spec(target, base: target_base, default_base: @default_target_base))
// 295:       end
// 296:
// 297:       sig {
// 298:         params(
// 299:           source:      ::T.any(::String, ::Pathname),
// 300:           target:      ::T.any(::String, ::Pathname),
// 301:           source_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 302:           target_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 303:           recursive:   ::T::Boolean,
// 304:           overwrite:   ::T::Boolean,
// 305:           source_glob: ::T::Boolean,
// 306:         ).void
// 307:       }
// 308:       def copy(source, target, source_base: nil, target_base: nil, recursive: false, overwrite: true,
// 309:                source_glob: false)
// 310:         add_step("copy",
// 311:                  "source"      => path_spec(source, base: source_base, default_base: @default_source_base),
// 312:                  "target"      => path_spec(target, base: target_base, default_base: @default_target_base),
// 313:                  "recursive"   => recursive,
// 314:                  "overwrite"   => (false unless overwrite),
// 315:                  "source_glob" => source_glob)
// 316:       end
// 317:
// 318:       sig {
// 319:         params(
// 320:           paths:                   Paths,
// 321:           base:                    ::T.nilable(::T.any(::String, ::Symbol)),
// 322:           recursive:               ::T::Boolean,
// 323:           sudo:                    ::T.any(::T::Boolean, ::Symbol),
// 324:           symlink_target_contains: ::T.nilable(::String),
// 325:           content_contains:        ::T.nilable(::String),
// 326:         ).void
// 327:       }
// 328:       def remove(paths, base: nil, recursive: false, sudo: false, symlink_target_contains: nil,
// 329:                  content_contains: nil)
// 330:         add_step("remove",
// 331:                  "paths"                   => path_specs(paths, base:, default_base: @default_base),
// 332:                  "recursive"               => recursive,
// 333:                  "sudo"                    => sudo.is_a?(::Symbol) ? sudo.to_s : sudo,
// 334:                  "symlink_target_contains" => symlink_target_contains,
// 335:                  "content_contains"        => content_contains)
// 336:       end
// 337:
// 338:       sig {
// 339:         params(
// 340:           path:         ::T.any(::String, ::Pathname),
// 341:           before:       ::T.any(::String, ::Regexp),
// 342:           after:        ::String,
// 343:           base:         ::T.nilable(::T.any(::String, ::Symbol)),
// 344:           audit_result: ::T::Boolean,
// 345:           global:       ::T::Boolean,
// 346:         ).void
// 347:       }
// 348:       def inreplace(path, before, after, base: nil, audit_result: true, global: true)
// 349:         add_step("inreplace",
// 350:                  "path"           => path_spec(path, base:, default_base: @default_base),
// 351:                  "before"         => before.is_a?(::Regexp) ? before.source : before,
// 352:                  "after"          => after,
// 353:                  "regexp"         => before.is_a?(::Regexp),
// 354:                  "regexp_options" => (before.options if before.is_a?(::Regexp)),
// 355:                  "skip_audit"     => !audit_result,
// 356:                  "first_only"     => !global)
// 357:       end
// 358:
// 359:       sig {
// 360:         params(
// 361:           source:              ::T.any(::String, ::Pathname),
// 362:           target:              ::T.any(::String, ::Pathname),
// 363:           source_base:         ::T.nilable(::T.any(::String, ::Symbol)),
// 364:           target_base:         ::T.nilable(::T.any(::String, ::Symbol)),
// 365:           source_formula:      ::T.nilable(::String),
// 366:           target_formula:      ::T.nilable(::String),
// 367:           # odeprecated
// 368:           force:               ::T::Boolean,
// 369:           # odeprecated
// 370:           uninstall:           ::T::Boolean,
// 371:           overwrite:           ::T::Boolean,
// 372:           remove_on_uninstall: ::T::Boolean,
// 373:           source_glob:         ::T::Boolean,
// 374:           sudo:                ::T.any(::T::Boolean, ::Symbol),
// 375:         ).void
// 376:       }
// 377:       def symlink(source, target, source_base: nil, target_base: nil, source_formula: nil, target_formula: nil,
// 378:                   force: false, uninstall: false, overwrite: false, remove_on_uninstall: false,
// 379:                   source_glob: false, sudo: false)
// 380:         add_step("symlink",
// 381:                  "source"      => path_spec(source, base: source_base, formula: source_formula,
// 382:                                     default_base: @default_source_base),
// 383:                  "target"      => path_spec(target, base: target_base, formula: target_formula,
// 384:                                     default_base: @default_target_base),
// 385:                  "force"       => (true if force || overwrite),
// 386:                  "uninstall"   => (true if uninstall || remove_on_uninstall),
// 387:                  "source_glob" => source_glob,
// 388:                  "sudo"        => sudo.is_a?(::Symbol) ? sudo.to_s : sudo)
// 389:       end
// 390:
// 391:       # odeprecated
// 392:       sig {
// 393:         params(
// 394:           source:         ::T.any(::String, ::Pathname),
// 395:           target:         ::T.any(::String, ::Pathname),
// 396:           source_base:    ::T.nilable(::T.any(::String, ::Symbol)),
// 397:           target_base:    ::T.nilable(::T.any(::String, ::Symbol)),
// 398:           source_formula: ::T.nilable(::String),
// 399:           target_formula: ::T.nilable(::String),
// 400:           force:          ::T::Boolean,
// 401:           uninstall:      ::T::Boolean,
// 402:         ).void
// 403:       }
// 404:       def ln_s(source, target, source_base: nil, target_base: nil, source_formula: nil, target_formula: nil,
// 405:                force: false, uninstall: false)
// 406:         symlink(source, target, source_base:, target_base:, source_formula:, target_formula:, force:, uninstall:)
// 407:       end
// 408:
// 409:       # odeprecated
// 410:       sig {
// 411:         params(
// 412:           source:         ::T.any(::String, ::Pathname),
// 413:           target:         ::T.any(::String, ::Pathname),
// 414:           source_base:    ::T.nilable(::T.any(::String, ::Symbol)),
// 415:           target_base:    ::T.nilable(::T.any(::String, ::Symbol)),
// 416:           source_formula: ::T.nilable(::String),
// 417:           target_formula: ::T.nilable(::String),
// 418:           uninstall:      ::T::Boolean,
// 419:         ).void
// 420:       }
// 421:       def ln_sf(source, target, source_base: nil, target_base: nil, source_formula: nil, target_formula: nil,
// 422:                 uninstall: false)
// 423:         symlink(source, target, source_base:, target_base:, source_formula:, target_formula:, force: true, uninstall:)
// 424:       end
// 425:
// 426:       # odeprecated
// 427:       sig {
// 428:         params(
// 429:           source:      ::T.any(::String, ::Pathname),
// 430:           target:      ::T.any(::String, ::Pathname),
// 431:           source_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 432:           target_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 433:         ).void
// 434:       }
// 435:       def link_dir(source, target, source_base: nil, target_base: :homebrew_prefix)
// 436:         add_step("link_dir",
// 437:                  "source" => path_spec(source, base: source_base, default_base: @default_source_base),
// 438:                  "target" => path_spec(target, base: target_base, default_base: @default_target_base))
// 439:       end
// 440:
// 441:       sig {
// 442:         params(
// 443:           source:      ::T.any(::String, ::Pathname),
// 444:           target:      ::T.any(::String, ::Pathname),
// 445:           source_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 446:           target_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 447:         ).void
// 448:       }
// 449:       def symlink_tree(source, target, source_base: nil, target_base: :homebrew_prefix)
// 450:         add_step("link_dir",
// 451:                  "source" => path_spec(source, base: source_base, default_base: @default_source_base),
// 452:                  "target" => path_spec(target, base: target_base, default_base: @default_target_base))
// 453:       end
// 454:
// 455:       # odeprecated
// 456:       sig {
// 457:         params(
// 458:           source:      ::T.any(::String, ::Pathname),
// 459:           target:      ::T.nilable(::T.any(::String, ::Pathname)),
// 460:           source_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 461:           target_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 462:           prefix:      ::String,
// 463:           suffix:      ::String,
// 464:         ).void
// 465:       }
// 466:       def link_children(source, target = nil, source_base: nil, target_base: :homebrew_prefix, prefix: "", suffix: "")
// 467:         add_step("link_children",
// 468:                  "source" => path_spec(source, base: source_base, default_base: @default_source_base),
// 469:                  "target" => path_spec(target || source, base: target_base, default_base: @default_target_base),
// 470:                  "prefix" => prefix,
// 471:                  "suffix" => suffix)
// 472:       end
// 473:
// 474:       sig {
// 475:         params(
// 476:           source:      ::T.any(::String, ::Pathname),
// 477:           target:      ::T.nilable(::T.any(::String, ::Pathname)),
// 478:           source_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 479:           target_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 480:           prefix:      ::String,
// 481:           suffix:      ::String,
// 482:         ).void
// 483:       }
// 484:       def symlink_children(source, target = nil, source_base: nil, target_base: :homebrew_prefix, prefix: "",
// 485:                            suffix: "")
// 486:         add_step("link_children",
// 487:                  "source" => path_spec(source, base: source_base, default_base: @default_source_base),
// 488:                  "target" => path_spec(target || source, base: target_base, default_base: @default_target_base),
// 489:                  "prefix" => prefix,
// 490:                  "suffix" => suffix)
// 491:       end
// 492:
// 493:       # odeprecated
// 494:       sig {
// 495:         params(
// 496:           path:      ::T.any(::String, ::Pathname),
// 497:           content:   ::String,
// 498:           base:      ::T.nilable(::T.any(::String, ::Symbol)),
// 499:           overwrite: ::T::Boolean,
// 500:         ).void
// 501:       }
// 502:       def write(path, content, base: nil, overwrite: false)
// 503:         content = "#{content}\n" unless content.end_with?("\n")
// 504:         add_step("write",
// 505:                  "path"      => path_spec(path, base:, default_base: @default_base),
// 506:                  "content"   => content,
// 507:                  "overwrite" => (true if overwrite))
// 508:       end
// 509:
// 510:       sig {
// 511:         params(
// 512:           path:           ::T.any(::String, ::Pathname),
// 513:           content:        ::String,
// 514:           base:           ::T.nilable(::T.any(::String, ::Symbol)),
// 515:           overwrite:      ::T::Boolean,
// 516:           append_newline: ::T::Boolean,
// 517:         ).void
// 518:       }
// 519:       def write_file(path, content, base: nil, overwrite: true, append_newline: false)
// 520:         content = "#{content}\n" if append_newline && !content.end_with?("\n")
// 521:         add_step("write",
// 522:                  "path"      => path_spec(path, base:, default_base: @default_base),
// 523:                  "content"   => content,
// 524:                  "overwrite" => (true if overwrite))
// 525:       end
// 526:
// 527:       sig {
// 528:         params(
// 529:           path:   ::T.any(::String, ::Pathname),
// 530:           using:  ::T.any(::String, ::Symbol),
// 531:           base:   ::T.nilable(::T.any(::String, ::Symbol)),
// 532:           locale: ::T.nilable(::String),
// 533:         ).void
// 534:       }
// 535:       def init_data_dir(path, using:, base: nil, locale: nil)
// 536:         using = case using.to_s
// 537:         when "postgresql" then "postgresql_initdb"
// 538:         when "mysql" then "mysql_initialize"
// 539:         when "mariadb" then "mariadb_install_db"
// 540:         else using.to_s
// 541:         end
// 542:         add_step("init_data_dir",
// 543:                  "path"   => path_spec(path, base:, default_base: @default_base),
// 544:                  "using"  => using,
// 545:                  "locale" => locale)
// 546:       end
// 547:
// 548:       sig { void }
// 549:       def compile_gsettings_schemas
// 550:         add_rebuild_action("compile_gsettings_schemas", "share/glib-2.0/schemas")
// 551:       end
// 552:
// 553:       # odeprecated
// 554:       sig { void }
// 555:       def gio_querymodules
// 556:         add_rebuild_action("gio_querymodules", "lib/gio/modules")
// 557:       end
// 558:
// 559:       sig { void }
// 560:       def update_gio_modules_cache
// 561:         add_rebuild_action("gio_querymodules", "lib/gio/modules")
// 562:       end
// 563:
// 564:       # odeprecated
// 565:       sig { void }
// 566:       def gdk_pixbuf_query_loaders
// 567:         add_step("gdk_pixbuf_query_loaders")
// 568:       end
// 569:
// 570:       sig { void }
// 571:       def update_gdk_pixbuf_loaders_cache
// 572:         add_step("gdk_pixbuf_query_loaders")
// 573:       end
// 574:
// 575:       # odeprecated
// 576:       sig { void }
// 577:       def gtk_update_icon_cache
// 578:         add_rebuild_action("gtk_update_icon_cache", "share/icons/hicolor")
// 579:       end
// 580:
// 581:       sig { void }
// 582:       def update_gtk_icon_cache
// 583:         add_rebuild_action("gtk_update_icon_cache", "share/icons/hicolor")
// 584:       end
// 585:
// 586:       sig { void }
// 587:       def update_mime_database
// 588:         add_rebuild_action("update_mime_database", "share/mime")
// 589:       end
// 590:
// 591:       sig { void }
// 592:       def update_desktop_database
// 593:         add_rebuild_action("update_desktop_database", "share/applications")
// 594:       end
// 595:
// 596:       # odeprecated
// 597:       sig {
// 598:         params(
// 599:           name:                 ::String,
// 600:           matching_certificate: ::T.nilable(::T.any(::String, ::Pathname)),
// 601:           base:                 ::T.nilable(::T.any(::String, ::Symbol)),
// 602:         ).void
// 603:       }
// 604:       def delete_keychain_certificate(name, matching_certificate: nil, base: nil)
// 605:         add_step("delete_keychain_certificate",
// 606:                  "name"                 => name,
// 607:                  "matching_certificate" => (path_spec(matching_certificate, base:, default_base: nil) if
// 608:                    matching_certificate))
// 609:       end
// 610:
// 611:       sig {
// 612:         params(
// 613:           name:           ::String,
// 614:           fingerprint_of: ::T.nilable(::T.any(::String, ::Pathname)),
// 615:           base:           ::T.nilable(::T.any(::String, ::Symbol)),
// 616:         ).void
// 617:       }
// 618:       def delete_keychain_certificates(name, fingerprint_of: nil, base: nil)
// 619:         add_step("delete_keychain_certificate",
// 620:                  "name"                 => name,
// 621:                  "matching_certificate" => (path_spec(fingerprint_of, base:, default_base: nil) if fingerprint_of))
// 622:       end
// 623:
// 624:       sig {
// 625:         params(
// 626:           paths:       Paths,
// 627:           permissions: ::String,
// 628:           base:        ::T.nilable(::T.any(::String, ::Symbol)),
// 629:           recursive:   ::T::Boolean,
// 630:         ).void
// 631:       }
// 632:       def set_permissions(paths, permissions, base: nil, recursive: true)
// 633:         add_step("set_permissions",
// 634:                  "paths"         => path_specs(paths, base:, default_base: @default_base),
// 635:                  "permissions"   => permissions,
// 636:                  "non_recursive" => !recursive)
// 637:       end
// 638:
// 639:       sig {
// 640:         params(
// 641:           paths:     Paths,
// 642:           user:      ::T.nilable(::String),
// 643:           group:     ::String,
// 644:           base:      ::T.nilable(::T.any(::String, ::Symbol)),
// 645:           recursive: ::T::Boolean,
// 646:         ).void
// 647:       }
// 648:       def set_ownership(paths, user: nil, group: "staff", base: nil, recursive: true)
// 649:         add_step("set_ownership",
// 650:                  "paths"         => path_specs(paths, base:, default_base: @default_base),
// 651:                  "user"          => user,
// 652:                  "group"         => (group if group != "staff"),
// 653:                  "non_recursive" => !recursive)
// 654:       end
// 655:
// 656:       sig {
// 657:         params(
// 658:           source:         ::T.any(::String, ::Pathname),
// 659:           id:             ::T.any(::String, ::Pathname),
// 660:           base:           ::T.nilable(::T.any(::String, ::Symbol)),
// 661:           resolve_source: ::T::Boolean,
// 662:         ).void
// 663:       }
// 664:       def change_dylib_id(source, id, base: nil, resolve_source: false)
// 665:         add_step("change_dylib_id",
// 666:                  "source"         => path_spec(source, base:, default_base: @default_source_base),
// 667:                  "id"             => id.to_s,
// 668:                  "resolve_source" => resolve_source)
// 669:       end
// 670:
// 671:       sig {
// 672:         params(
// 673:           command:        ::T.any(::String, ::Pathname),
// 674:           args:           ::T::Array[::T.any(::String, ::Pathname)],
// 675:           base:           ::T.nilable(::T.any(::String, ::Symbol)),
// 676:           env:            ::T::Hash[::String, ::String],
// 677:           sudo:           ::T::Boolean,
// 678:           must_succeed:   ::T::Boolean,
// 679:           print_stdout:   ::T::Boolean,
// 680:           print_stderr:   ::T::Boolean,
// 681:           stdin_path:     ::T.nilable(::T.any(::String, ::Pathname)),
// 682:           stdout_path:    ::T.nilable(::T.any(::String, ::Pathname)),
// 683:           chdir:          ::T.nilable(::T.any(::String, ::Pathname)),
// 684:           writable_paths: Paths,
// 685:           writable_base:  ::T.nilable(::T.any(::String, ::Symbol)),
// 686:           network_access: ::T::Boolean,
// 687:         ).void
// 688:       }
// 689:       def run(command, args: [], base: nil, env: {}, sudo: false, must_succeed: true, print_stdout: false,
// 690:               print_stderr: true, stdin_path: nil, stdout_path: nil, chdir: nil, writable_paths: [],
// 691:               writable_base: nil, network_access: false)
// 692:         add_step("run",
// 693:                  "command"         => path_spec(command, base:, default_base: nil),
// 694:                  "args"            => args.map(&:to_s),
// 695:                  "env"             => env,
// 696:                  "sudo"            => sudo,
// 697:                  "allow_failure"   => !must_succeed,
// 698:                  "print_stdout"    => print_stdout,
// 699:                  "suppress_stderr" => !print_stderr,
// 700:                  "stdin_path"      => optional_path_spec(stdin_path, default_base: @default_base),
// 701:                  "stdout_path"     => optional_path_spec(stdout_path, default_base: @default_base),
// 702:                  "chdir"           => optional_path_spec(chdir, default_base: @default_base),
// 703:                  "writable_paths"  => path_specs(
// 704:                    writable_paths,
// 705:                    base:         writable_base,
// 706:                    default_base: @default_base,
// 707:                  ),
// 708:                  "network_access"  => network_access)
// 709:       end
// 710:
// 711:       sig {
// 712:         params(
// 713:           name:            ::String,
// 714:           match:           ::T.any(::String, ::Symbol),
// 715:           sudo:            ::T::Boolean,
// 716:           attempts:        ::Integer,
// 717:           must_succeed:    ::T::Boolean,
// 718:           notices:         ::T::Array[::String],
// 719:           failure_message: ::T.nilable(::String),
// 720:         ).void
// 721:       }
// 722:       def terminate_process(name, match: :name, sudo: false, attempts: 1, must_succeed: false,
// 723:                             notices: [], failure_message: nil)
// 724:         ::Kernel.raise ::ArgumentError, "terminate_process attempts must be positive" if attempts < 1
// 725:
// 726:         match = match.to_s
// 727:         unless %w[name full].include?(match)
// 728:           ::Kernel.raise ::ArgumentError, "terminate_process match must be :name or :full"
// 729:         end
// 730:
// 731:         add_step("terminate_process",
// 732:                  "name"            => name,
// 733:                  "match"           => (match if match != "name"),
// 734:                  "sudo"            => sudo,
// 735:                  "attempts"        => (attempts if attempts != 1),
// 736:                  "must_succeed"    => must_succeed,
// 737:                  "notices"         => notices,
// 738:                  "failure_message" => failure_message)
// 739:       end
// 740:
// 741:       sig { params(message: ::String).void }
// 742:       def warn(message)
// 743:         add_step("warn", "message" => message)
// 744:       end
// 745:
// 746:       sig { void }
// 747:       def configure_gcc_runtime
// 748:         add_step("configure_gcc_runtime")
// 749:       end
// 750:
// 751:       sig {
// 752:         params(
// 753:           source:      ::T.any(::String, ::Pathname),
// 754:           target:      ::T.any(::String, ::Pathname),
// 755:           source_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 756:           target_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 757:         ).void
// 758:       }
// 759:       def install_gzipped_executable(source, target, source_base: nil, target_base: nil)
// 760:         add_step("install_gzipped_executable",
// 761:                  "source" => path_spec(source, base: source_base, default_base: @default_source_base),
// 762:                  "target" => path_spec(target, base: target_base, default_base: @default_target_base))
// 763:       end
// 764:
// 765:       sig { void }
// 766:       def configure_glibc_runtime
// 767:         add_step("configure_glibc_runtime")
// 768:       end
// 769:
// 770:       sig { void }
// 771:       def configure_clang_system
// 772:         add_step("configure_clang_system")
// 773:       end
// 774:
// 775:       sig { void }
// 776:       def configure_php
// 777:         add_step("configure_php")
// 778:       end
// 779:
// 780:       sig { void }
// 781:       def bootstrap_cpython
// 782:         add_step("bootstrap_cpython")
// 783:       end
// 784:
// 785:       sig { params(abi_version: ::String).void }
// 786:       def bootstrap_pypy(abi_version:)
// 787:         add_step("bootstrap_pypy", "abi_version" => abi_version)
// 788:       end
// 789:
// 790:       private
// 791:
// 792:       sig { params(guard: PathSpec, block: ::T.proc.bind(DSL).void).void }
// 793:       def with_guard(guard, &block)
// 794:         previous_guards = ::T.let(nil, ::T.nilable(PathSpecs))
// 795:         previous_guards = @guards
// 796:         @next_guard_id += 1
// 797:         @guards = [*@guards, guard.merge("id" => @next_guard_id.to_s)]
// 798:         instance_eval(&block)
// 799:       ensure
// 800:         @guards = previous_guards if previous_guards
// 801:       end
// 802:
// 803:       sig { params(type: ::String, fields: ::T.nilable(StepValue)).void }
// 804:       def add_step(type, **fields)
// 805:         step = fields.transform_keys(&:to_s)
// 806:         step["guards"] = @guards unless @guards.empty?
// 807:         step["type"] = type
// 808:         @steps.concat(::Homebrew::InstallSteps::DSL.normalise_steps([step]))
// 809:       end
// 810:
// 811:       sig { params(type: ::String, path: ::String).void }
// 812:       def add_rebuild_action(type, path)
// 813:         add_step(type, "path" => path_spec(path, base: :homebrew_prefix))
// 814:       end
// 815:
// 816:       sig {
// 817:         params(
// 818:           path:         ::T.any(::String, ::Pathname),
// 819:           base:         ::T.nilable(::T.any(::String, ::Symbol)),
// 820:           formula:      ::T.nilable(::String),
// 821:           default_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 822:         ).returns(PathSpec)
// 823:       }
// 824:       def path_spec(path, base:, formula: nil, default_base: nil)
// 825:         {
// 826:           "base"    => (base || default_base_for(path, default_base))&.to_s,
// 827:           "formula" => formula,
// 828:           "path"    => path.to_s,
// 829:         }.compact_blank
// 830:       end
// 831:
// 832:       sig {
// 833:         params(
// 834:           paths:        Paths,
// 835:           base:         ::T.nilable(::T.any(::String, ::Symbol)),
// 836:           default_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 837:         ).returns(PathSpecs)
// 838:       }
// 839:       def path_specs(paths, base:, default_base:)
// 840:         paths = [paths] unless paths.is_a?(Array)
// 841:         paths.map { |path| path_spec(path, base:, default_base:) }
// 842:       end
// 843:
// 844:       sig {
// 845:         params(
// 846:           path:         ::T.nilable(::T.any(::String, ::Pathname)),
// 847:           default_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 848:         ).returns(::T.nilable(PathSpec))
// 849:       }
// 850:       def optional_path_spec(path, default_base:)
// 851:         path_spec(path, base: nil, default_base:) if path
// 852:       end
// 853:
// 854:       sig {
// 855:         params(
// 856:           path:         ::T.any(::String, ::Pathname),
// 857:           default_base: ::T.nilable(::T.any(::String, ::Symbol)),
// 858:         ).returns(::T.nilable(::T.any(::String, ::Symbol)))
// 859:       }
// 860:       def default_base_for(path, default_base)
// 861:         path = path.to_s
// 862:         return if path.start_with?("/", "~")
// 863:         return if ABSOLUTE_TEMPLATE_TOKENS.any? { |token| path.start_with?("{{#{token}}}") }
// 864:
// 865:         default_base
// 866:       end
// 867:     end
// 868:
// 869:     class Runner
// 870:       include SystemCommand::Mixin
// 871:       include ::Utils::Output::Mixin
// 872:
// 873:       # Path tokens reuse the step base resolution; formula metadata tokens are
// 874:       # resolved separately. Anything else is left verbatim so literal braces in
// 875:       # templates are never rewritten.
// 876:       CONTENT_PATH_TOKENS = %w[
// 877:         prefix opt_prefix bin sbin lib libexec share pkgshare var etc pkgetc staged_path appdir caskroom_path
// 878:         temp rack
// 879:         bash_completion zsh_completion fish_completion pwsh_completion
// 880:       ].freeze
// 881:       IMPLICIT_SUDO_STEP_TYPES = %w[delete_keychain_certificate set_ownership].freeze
// 882:
// 883:       sig { params(context: Object, command: T.class_of(SystemCommand)).void }
// 884:       def initialize(context:, command: SystemCommand)
// 885:         @context = context
// 886:         @command = command
// 887:         @guard_results = T.let({}, T::Hash[PathSpec, T::Boolean])
// 888:       end
// 889:
// 890:       sig { params(steps: Steps, phase: Symbol).void }
// 891:       def run(steps, phase: :install)
// 892:         @guard_results.clear
// 893:         DSL.normalise_steps(steps).each do |step|
// 894:           if phase == :uninstall
// 895:             run_uninstall_step(step)
// 896:           else
// 897:             run_install_step(step)
// 898:           end
// 899:         end
// 900:       end
// 901:
// 902:       sig { params(steps: Steps, phase: Symbol).returns(T::Array[Pathname]) }
// 903:       def sandbox_write_paths(steps, phase: :install)
// 904:         DSL.normalise_steps(steps).flat_map do |step|
// 905:           if phase == :uninstall
// 906:             next [] if step["type"] != "symlink" || step["uninstall"] != true
// 907:
// 908:             next [resolve_path(step_path(step, "target")).parent]
// 909:           end
// 910:
// 911:           case step.fetch("type")
// 912:           when "mkdir", "mkdir_p", "touch", "write"
// 913:             [resolve_path(step_path(step, "path")).parent]
// 914:           when "move"
// 915:             [resolve_path(step_path(step, "source")).parent, resolve_path(step_path(step, "target")).parent]
// 916:           when "move_children", "move_contents"
// 917:             [resolve_path(step_path(step, "source")), resolve_path(step_path(step, "target"))]
// 918:           when "copy", "symlink"
// 919:             [resolve_path(step_path(step, "target")).parent]
// 920:           when "remove"
// 921:             step_paths(step, "paths").flat_map { |path| expand_path_glob(path) }.map(&:parent)
// 922:           when "inreplace", "change_dylib_id"
// 923:             key = (step["type"] == "inreplace") ? "path" : "source"
// 924:             [resolve_path(step_path(step, key))]
// 925:           when "link_dir", "link_children"
// 926:             [resolve_path(step_path(step, "target"))]
// 927:           when "run"
// 928:             paths = step.key?("stdout_path") ? [resolve_path(step_path(step, "stdout_path")).parent] : []
// 929:             if step.key?("writable_paths")
// 930:               paths.concat(step_paths(step, "writable_paths").map do |path|
// 931:                 resolve_path(path)
// 932:               end)
// 933:             end
// 934:             paths
// 935:           when "set_permissions", "set_ownership"
// 936:             existing_step_paths(step)
// 937:           else
// 938:             []
// 939:           end
// 940:         end.uniq
// 941:       end
// 942:
// 943:       sig { params(steps: Steps).returns(T::Boolean) }
// 944:       def sudo_required?(steps)
// 945:         DSL.normalise_steps(steps).any? do |step|
// 946:           step["sudo"] == true || step["sudo"] == "if_needed" ||
// 947:             IMPLICIT_SUDO_STEP_TYPES.include?(step["type"])
// 948:         end
// 949:       end
// 950:
// 951:       private
// 952:
// 953:       sig { params(step: Step).void }
// 954:       def run_install_step(step)
// 955:         return unless step_guards_match?(step)
// 956:
// 957:         case step.fetch("type")
// 958:         when "mkdir"
// 959:           resolve_path(step_path(step, "path")).mkdir
// 960:         when "mkdir_p"
// 961:           resolve_path(step_path(step, "path")).mkpath
// 962:         when "init_data_dir"
// 963:           run_init_data_dir(step)
// 964:         when "touch"
// 965:           path = resolve_path(step_path(step, "path"))
// 966:           path.dirname.mkpath
// 967:           FileUtils.touch path
// 968:         when "move"
// 969:           source = resolve_step_source(step)
// 970:           target = resolve_path(step_path(step, "target"))
// 971:           target.dirname.mkpath
// 972:           destination = step_destination(source, target)
// 973:           if step.key?("overwrite")
// 974:             overwrite = step["overwrite"] == true || step["force"] == true
// 975:             raise Errno::EEXIST, destination.to_s if destination.exist? && !overwrite
// 976:
// 977:             FileUtils.rm_rf destination if overwrite && destination != source && (source.exist? || source.symlink?)
// 978:             FileUtils.mv source, target
// 979:           else
// 980:             FileUtils.mv source, target, force: step["force"] == true
// 981:           end
// 982:         when "move_children", "move_contents"
// 983:           source = resolve_path(step_path(step, "source"))
// 984:           target = resolve_path(step_path(step, "target"))
// 985:           target.mkpath
// 986:           children = source.children.reject { |child| child == target }
// 987:           return if children.empty?
// 988:
// 989:           FileUtils.mv children, target
// 990:         when "copy"
// 991:           source = resolve_step_source(step)
// 992:           target = resolve_path(step_path(step, "target"))
// 993:           target.dirname.mkpath
// 994:           destination = step_destination(source, target)
// 995:           overwrite = step["overwrite"] != false
// 996:           raise Errno::EEXIST, destination.to_s if destination.exist? && !overwrite
// 997:
// 998:           if step["recursive"] == true
// 999:             FileUtils.cp_r source, target, remove_destination: overwrite
// 1000:           else
// 1001:             FileUtils.rm_f destination if overwrite && destination.symlink?
// 1002:             FileUtils.cp source, target
// 1003:           end
// 1004:         when "remove"
// 1005:           paths = step_paths(step, "paths").flat_map { |path| expand_path_glob(path) }
// 1006:           if step.key?("symlink_target_contains")
// 1007:             paths.select! do |path|
// 1008:               path.symlink? && path.readlink.to_s.include?(step_string(step, "symlink_target_contains"))
// 1009:             end
// 1010:           end
// 1011:           if step.key?("content_contains")
// 1012:             paths.select! do |path|
// 1013:               path.file? && path.readable? && path.read.include?(step_string(step, "content_contains"))
// 1014:             end
// 1015:           end
// 1016:           paths.each do |path|
// 1017:             if step["sudo"] == true || (step["sudo"] == "if_needed" && !path.dirname.writable?)
// 1018:               require "cask/utils"
// 1019:               ::Cask::Utils.gain_permissions_remove(path, command: @command)
// 1020:             elsif step["recursive"] == true
// 1021:               FileUtils.rm_rf path
// 1022:             else
// 1023:               FileUtils.rm_f path
// 1024:             end
// 1025:           end
// 1026:         when "inreplace"
// 1027:           require "utils/inreplace"
// 1028:
// 1029:           path = resolve_path(step_path(step, "path"))
// 1030:           before = expand_template_tokens(step_string(step, "before"))
// 1031:           after = expand_template_tokens(step_string(step, "after"))
// 1032:           regexp_options = T.cast(step["regexp_options"], T.nilable(Integer))
// 1033:           before = Regexp.new(before, regexp_options || 0) if step["regexp"] == true
// 1034:           Utils::Inreplace.inreplace(path, before, after,
// 1035:                                      audit_result: step["skip_audit"] != true,
// 1036:                                      global:       step["first_only"] != true)
// 1037:         when "link_dir"
// 1038:           source_dir = resolve_path(step_path(step, "source"))
// 1039:           target_dir = resolve_path(step_path(step, "target"))
// 1040:           source_dir.find do |source|
// 1041:             link_target = target_dir/source.relative_path_from(source_dir)
// 1042:             next if source.basename.to_s == ".DS_Store"
// 1043:             next if link_target.directory? && !link_target.symlink?
// 1044:
// 1045:             FileUtils.rm_f(link_target) if link_target.exist? || link_target.symlink?
// 1046:             if source.symlink? || source.file?
// 1047:               link_target.parent.install_symlink source
// 1048:             elsif source.directory?
// 1049:               link_target.mkpath
// 1050:             end
// 1051:           end
// 1052:         when "link_children"
// 1053:           target_dir = resolve_path(step_path(step, "target"))
// 1054:           target_dir.mkpath
// 1055:           link_prefix = expand_template_tokens(step["prefix"].to_s)
// 1056:           link_suffix = expand_template_tokens(step["suffix"].to_s)
// 1057:           resolve_path(step_path(step, "source")).each_child do |source|
// 1058:             target_dir.install_symlink source => "#{link_prefix}#{source.basename}#{link_suffix}"
// 1059:           end
// 1060:         when "symlink"
// 1061:           target = resolve_path(step_path(step, "target"))
// 1062:           if step["source_glob"] == true
// 1063:             sources = expand_path_glob(step_path(step, "source"))
// 1064:             return if sources.empty?
// 1065:
// 1066:             if sources.length > 1 || target.directory?
// 1067:               target.mkpath
// 1068:               sources.each { |source| create_symlink(source, target/source.basename, step) }
// 1069:             else
// 1070:               source = sources.first
// 1071:               create_symlink(source, target, step) if source
// 1072:             end
// 1073:           else
// 1074:             create_symlink(link_source(step_path(step, "source")), target, step)
// 1075:           end
// 1076:         when "write"
// 1077:           content = T.cast(step["content"], T.nilable(String))
// 1078:           raise ArgumentError, "install step write requires content" if content.nil?
// 1079:
// 1080:           path = resolve_path(step_path(step, "path"))
// 1081:           if step["overwrite"] == true || !path.exist?
// 1082:             path.dirname.mkpath
// 1083:             path.atomic_write(expand_template_tokens(content))
// 1084:           end
// 1085:         when "run"
// 1086:           run_serialised_command(step)
// 1087:         when "terminate_process"
// 1088:           run_terminate_process(step)
// 1089:         when "change_dylib_id"
// 1090:           Homebrew::InstallSteps.change_dylib_id(
// 1091:             resolve_path(step_path(step, "source")),
// 1092:             expand_template_tokens(step_string(step, "id")),
// 1093:             resolve_source: step["resolve_source"] == true,
// 1094:           )
// 1095:         when "warn"
// 1096:           opoo expand_template_tokens(step_string(step, "message"))
// 1097:         when "configure_gcc_runtime"
// 1098:           run_configure_gcc_runtime
// 1099:         when "install_gzipped_executable"
// 1100:           run_install_gzipped_executable(step)
// 1101:         when "configure_glibc_runtime"
// 1102:           run_configure_glibc_runtime
// 1103:         when "configure_clang_system"
// 1104:           run_configure_clang_system
// 1105:         when "configure_php"
// 1106:           run_configure_php
// 1107:         when "bootstrap_cpython"
// 1108:           run_bootstrap_cpython
// 1109:         when "bootstrap_pypy"
// 1110:           run_bootstrap_pypy(step_string(step, "abi_version"))
// 1111:         when "set_permissions"
// 1112:           run_set_permissions(step)
// 1113:         when "set_ownership"
// 1114:           run_set_ownership(step)
// 1115:         when "compile_gsettings_schemas"
// 1116:           run_formula_tool("glib", "glib-compile-schemas", resolve_path(step_path(step, "path")))
// 1117:         when "gio_querymodules"
// 1118:           run_formula_tool("glib", "gio-querymodules", resolve_path(step_path(step, "path")))
// 1119:         when "gdk_pixbuf_query_loaders"
// 1120:           run_formula_tool("gdk-pixbuf", "gdk-pixbuf-query-loaders", "--update-cache")
// 1121:         when "gtk_update_icon_cache"
// 1122:           require "utils/path"
// 1123:           if Utils::Path.formula_any_version_installed?("gtk4")
// 1124:             run_formula_tool("gtk4", "gtk4-update-icon-cache", "-q", "-t", "-f",
// 1125:                              resolve_path(step_path(step, "path")))
// 1126:           else
// 1127:             run_formula_tool("gtk+3", "gtk3-update-icon-cache", "-q", "-t", "-f",
// 1128:                              resolve_path(step_path(step, "path")))
// 1129:           end
// 1130:         when "update_mime_database"
// 1131:           run_formula_tool("shared-mime-info", "update-mime-database", resolve_path(step_path(step, "path")))
// 1132:         when "update_desktop_database"
// 1133:           run_formula_tool("desktop-file-utils", "update-desktop-database", resolve_path(step_path(step, "path")))
// 1134:         when "delete_keychain_certificate"
// 1135:           certificate_hash = nil
// 1136:           if step.key?("matching_certificate")
// 1137:             certificate = resolve_path(step_path(step, "matching_certificate"))
// 1138:             return unless certificate.exist?
// 1139:
// 1140:             certificate_hash = run_command_output("/usr/bin/openssl", "x509", "-fingerprint", "-sha256", "-noout",
// 1141:                                                   "-in", certificate)
// 1142:                                .lines
// 1143:                                .first
// 1144:                                .to_s
// 1145:                                .split("=", 2)[1]
// 1146:                                .to_s
// 1147:                                .delete(":")
// 1148:                                .strip
// 1149:                                .upcase
// 1150:             return if certificate_hash.blank?
// 1151:           end
// 1152:
// 1153:           certificate_hashes = run_command_output(
// 1154:             "/usr/bin/security", "find-certificate", "-a", "-c", step_string(step, "name"), "-Z",
// 1155:             sudo: true
// 1156:           ).lines.filter_map { |line| line[/\ASHA-256 hash:\s*(\S+)/, 1]&.upcase }
// 1157:
// 1158:           if certificate_hash
// 1159:             run_command "/usr/bin/security", "delete-certificate", "-Z", certificate_hash, sudo: true if
// 1160:               certificate_hashes.include?(certificate_hash)
// 1161:           else
// 1162:             certificate_hashes.each do |matching_certificate_hash|
// 1163:               run_command "/usr/bin/security", "delete-certificate", "-Z", matching_certificate_hash, sudo: true
// 1164:             end
// 1165:           end
// 1166:         else
// 1167:           raise ArgumentError, "unknown install step: #{step.fetch("type")}"
// 1168:         end
// 1169:       end
// 1170:
// 1171:       sig { params(step: Step).returns(T::Boolean) }
// 1172:       def step_guards_match?(step)
// 1173:         guards = T.cast(step["guards"], T.nilable(PathSpecs))
// 1174:         guards.nil? || guards.all? { |guard| guard_matches?(guard) }
// 1175:       end
// 1176:
// 1177:       sig { params(guard: PathSpec).returns(T::Boolean) }
// 1178:       def guard_matches?(guard)
// 1179:         return @guard_results.fetch(guard) if @guard_results.key?(guard)
// 1180:
// 1181:         matches = case guard.fetch("condition")
// 1182:         when "if_exists"
// 1183:           path_spec_exists?(guard)
// 1184:         when "unless_exists"
// 1185:           !path_spec_exists?(guard)
// 1186:         when "on"
// 1187:           case guard.fetch("value")
// 1188:           when "macos" then Homebrew::SimulateSystem.simulating_or_running_on_macos?
// 1189:           when "linux" then Homebrew::SimulateSystem.simulating_or_running_on_linux?
// 1190:           else false
// 1191:           end
// 1192:         else
// 1193:           false
// 1194:         end
// 1195:         @guard_results[guard] = matches
// 1196:       end
// 1197:
// 1198:       sig { params(step: Step).void }
// 1199:       def run_serialised_command(step)
// 1200:         command = resolve_command(step_path(step, "command"))
// 1201:         args = T.cast(step["args"], T.nilable(T::Array[String]))&.map { |arg| expand_template_tokens(arg) } || []
// 1202:         environment = T.cast(step["env"] || {}, PathSpec)
// 1203:                        .transform_values { |value| expand_template_tokens(value.to_s) }
// 1204:         input = step.key?("stdin_path") ? resolve_path(step_path(step, "stdin_path")).read : []
// 1205:         working_directory = resolve_path(step_path(step, "chdir")) if step.key?("chdir")
// 1206:         result = @command.run(command, args:, sudo: step["sudo"] == true, env: environment, input:,
// 1207:                                      must_succeed: step["allow_failure"] != true,
// 1208:                                      print_stdout: step["print_stdout"] == true,
// 1209:                                      print_stderr: step["suppress_stderr"] != true, reset_uid: true,
// 1210:                                      chdir: working_directory)
// 1211:
// 1212:         return unless step.key?("stdout_path")
// 1213:         return unless result.success?
// 1214:
// 1215:         output_path = resolve_path(step_path(step, "stdout_path"))
// 1216:         output_path.dirname.mkpath
// 1217:         output_path.write(result.stdout)
// 1218:       end
// 1219:
// 1220:       sig { params(step: Step).void }
// 1221:       def run_terminate_process(step)
// 1222:         T.cast(step["notices"], T.nilable(T::Array[String]))&.each do |notice|
// 1223:           ohai expand_template_tokens(notice)
// 1224:         end
// 1225:         name = expand_template_tokens(step_string(step, "name"))
// 1226:         if step["match"] == "full"
// 1227:           command = "/usr/bin/pkill"
// 1228:           args = ["-f", name]
// 1229:         else
// 1230:           command = "/usr/bin/killall"
// 1231:           args = [name]
// 1232:         end
// 1233:         attempts = T.cast(step["attempts"] || 1, Integer)
// 1234:
// 1235:         begin
// 1236:           run_command command, *args, sudo: step["sudo"] == true
// 1237:         rescue ErrorDuringExecution
// 1238:           attempts -= 1
// 1239:           if attempts <= 0
// 1240:             failure_message = T.cast(step["failure_message"], T.nilable(String))
// 1241:             opoo expand_template_tokens(failure_message) if failure_message
// 1242:             raise if step["must_succeed"] == true
// 1243:
// 1244:             return
// 1245:           end
// 1246:
// 1247:           sleep 1
// 1248:           retry
// 1249:         end
// 1250:       end
// 1251:
// 1252:       sig { params(source: SystemCommandArg, target: Pathname, step: Step).void }
// 1253:       def create_symlink(source, target, step)
// 1254:         target.dirname.mkpath
// 1255:         if step["sudo"] == true || (step["sudo"] == "if_needed" && !target.dirname.writable?)
// 1256:           args = ["-s"]
// 1257:           args << "-f" if step["force"] == true
// 1258:           @command.run!("/bin/ln", args: [*args, source, target], sudo: true)
// 1259:         else
// 1260:           FileUtils.rm_f target if step["force"] == true
// 1261:           File.symlink source, target
// 1262:         end
// 1263:       end
// 1264:
// 1265:       sig { params(step: Step).void }
// 1266:       def run_set_permissions(step)
// 1267:         paths = existing_step_paths(step)
// 1268:         return if paths.empty?
// 1269:
// 1270:         args = []
// 1271:         args << "-R" if step["non_recursive"] != true
// 1272:         @command.run!("chmod", args: [*args, "--", step_string(step, "permissions"), *paths], sudo: false)
// 1273:       end
// 1274:
// 1275:       sig { params(step: Step).void }
// 1276:       def run_set_ownership(step)
// 1277:         require "cask/quarantine"
// 1278:         require "utils/user"
// 1279:
// 1280:         paths = existing_step_paths(step)
// 1281:         return if paths.empty?
// 1282:
// 1283:         paths.each do |path|
// 1284:           next if ::Cask::Quarantine.app_management_permissions_granted?(app: path, command: @command)
// 1285:
// 1286:           raise ::Cask::CaskError, <<~EOS
// 1287:             Cannot change the ownership of '#{path}' because your terminal does not have App Management permissions.
// 1288:             macOS prevents modifying apps without these permissions, even when using `sudo`.
// 1289:             To fix this, approve the permissions prompt (if one was just shown) or go to
// 1290:             System Settings → Privacy & Security → App Management and add or enable your terminal.
// 1291:             Then run this command again.
// 1292:           EOS
// 1293:         end
// 1294:
// 1295:         ohai "Changing ownership of paths required by #{@context} with `sudo` (which may request your password)..."
// 1296:         args = []
// 1297:         args << "-R" if step["non_recursive"] != true
// 1298:         @command.run!("chown", args: [*args, "--", "#{step["user"] || ::User.current}:#{step["group"] || "staff"}",
// 1299:                                       *paths],
// 1300:                                sudo: true)
// 1301:       end
// 1302:
// 1303:       sig { params(step: Step).void }
// 1304:       def run_uninstall_step(step)
// 1305:         return if step.fetch("type") != "symlink"
// 1306:         return if step["uninstall"] != true
// 1307:
// 1308:         target = resolve_path(step_path(step, "target"))
// 1309:         return unless target.symlink?
// 1310:         return if target.readlink != Pathname(link_source(step_path(step, "source")))
// 1311:
// 1312:         if step["sudo"] == true || (step["sudo"] == "if_needed" && !target.dirname.writable?)
// 1313:           require "cask/utils"
// 1314:           ::Cask::Utils.gain_permissions_remove(target, command: @command)
// 1315:         else
// 1316:           FileUtils.rm_f target
// 1317:         end
// 1318:       end
// 1319:
// 1320:       sig { params(step: Step).void }
// 1321:       def run_init_data_dir(step)
// 1322:         using = step_string(step, "using")
// 1323:         marker = case using
// 1324:         when "postgresql_initdb"
// 1325:           "PG_VERSION"
// 1326:         when "mysql_initialize"
// 1327:           "mysql/general_log.CSM"
// 1328:         when "mariadb_install_db"
// 1329:           "mysql/user.frm"
// 1330:         else
// 1331:           raise ArgumentError, "unknown data directory initialiser: #{using}"
// 1332:         end
// 1333:
// 1334:         path = resolve_path(step_path(step, "path"))
// 1335:         path.mkpath
// 1336:         return if ENV["HOMEBREW_GITHUB_ACTIONS"].present?
// 1337:         return if (path/marker).exist?
// 1338:
// 1339:         bin = context_path("bin")
// 1340:         prefix = context_path("prefix")
// 1341:         case using
// 1342:         when "postgresql_initdb"
// 1343:           run_command bin/"initdb", "--locale=#{step["locale"] || "en_US.UTF-8"}", "-E", "UTF-8", path
// 1344:         when "mysql_initialize"
// 1345:           with_env(TMPDIR: nil) do
// 1346:             run_command bin/"mysqld", "--initialize-insecure", "--user=#{ENV.fetch("USER")}",
// 1347:                         "--basedir=#{prefix}", "--datadir=#{path}", "--tmpdir=/tmp"
// 1348:           end
// 1349:         when "mariadb_install_db"
// 1350:           with_env(TMPDIR: nil) do
// 1351:             run_command bin/"mysql_install_db", "--verbose", "--user=#{ENV.fetch("USER")}",
// 1352:                         "--basedir=#{prefix}", "--datadir=#{path}", "--tmpdir=/tmp"
// 1353:           end
// 1354:         end
// 1355:       end
// 1356:
// 1357:       sig { params(content: String).returns(String) }
// 1358:       def expand_template_tokens(content)
// 1359:         content.gsub(/\{\{([A-Za-z_][\w.]*)\}\}/) do |match|
// 1360:           value = template_token_value(T.must(Regexp.last_match(1)))
// 1361:           value.nil? ? match : value.to_s
// 1362:         end
// 1363:       end
// 1364:
// 1365:       sig { params(token: String).returns(T.nilable(TemplateTokenValue)) }
// 1366:       def template_token_value(token)
// 1367:         case token
// 1368:         when "HOMEBREW_BREW_FILE"
// 1369:           HOMEBREW_BREW_FILE
// 1370:         when "HOMEBREW_CELLAR"
// 1371:           HOMEBREW_CELLAR
// 1372:         when "HOMEBREW_PREFIX"
// 1373:           HOMEBREW_PREFIX
// 1374:         when "formula_name"
// 1375:           context_value(:name)&.to_s
// 1376:         when "name"
// 1377:           context_name
// 1378:         when "token"
// 1379:           context_value(:token)&.to_s
// 1380:         when "user"
// 1381:           ENV.fetch("USER")
// 1382:         when "version"
// 1383:           context_version
// 1384:         when "version.major"
// 1385:           context_version_major
// 1386:         when "version.major_minor"
// 1387:           context_version_major_minor
// 1388:         else
// 1389:           root_path(token, nil) if CONTENT_PATH_TOKENS.include?(token)
// 1390:         end
// 1391:       end
// 1392:
// 1393:       sig { params(step: Step, key: String).returns(PathSpec) }
// 1394:       def step_path(step, key)
// 1395:         T.cast(step.fetch(key), PathSpec)
// 1396:       end
// 1397:
// 1398:       sig { params(step: Step, key: String).returns(PathSpecs) }
// 1399:       def step_paths(step, key)
// 1400:         T.cast(step.fetch(key), PathSpecs)
// 1401:       end
// 1402:
// 1403:       sig { params(step: Step).returns(T::Array[Pathname]) }
// 1404:       def existing_step_paths(step)
// 1405:         step_paths(step, "paths").flat_map { |spec| expand_path_glob(spec) }.select(&:exist?)
// 1406:       end
// 1407:
// 1408:       sig { params(step: Step).returns(Pathname) }
// 1409:       def resolve_step_source(step)
// 1410:         source_spec = step_path(step, "source")
// 1411:         source = resolve_path(source_spec)
// 1412:         return source if step["source_glob"] != true
// 1413:
// 1414:         sources = expand_path_glob(source_spec).select { |path| path.exist? || path.symlink? }.uniq
// 1415:         raise ArgumentError, "install step source glob must match exactly one path: #{source}" if sources.length != 1
// 1416:
// 1417:         sources.fetch(0)
// 1418:       end
// 1419:
// 1420:       sig { params(source: Pathname, target: Pathname).returns(Pathname) }
// 1421:       def step_destination(source, target)
// 1422:         target.directory? ? target/source.basename : target
// 1423:       end
// 1424:
// 1425:       sig { params(spec: PathSpec).returns(T::Array[Pathname]) }
// 1426:       def expand_path_glob(spec)
// 1427:         base = spec["base"]
// 1428:         # odeprecated
// 1429:         base = "search_path" if base == "path"
// 1430:         if base == "search_path"
// 1431:           path = expand_template_tokens(spec.fetch("path"))
// 1432:           return ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).flat_map do |directory|
// 1433:             candidate = Pathname(directory)/path
// 1434:             candidate.to_s.match?(/[?*\[{]/) ? Pathname.glob(candidate.to_s) : [candidate]
// 1435:           end
// 1436:         end
// 1437:
// 1438:         path = resolve_path(spec).expand_path
// 1439:         return [path] unless path.to_s.match?(/[?*\[{]/)
// 1440:
// 1441:         Pathname.glob(path.to_s)
// 1442:       end
// 1443:
// 1444:       sig { params(spec: PathSpec).returns(T::Boolean) }
// 1445:       def path_spec_exists?(spec)
// 1446:         expand_path_glob(spec).any?(&:exist?)
// 1447:       end
// 1448:
// 1449:       sig { params(step: Step, key: String).returns(String) }
// 1450:       def step_string(step, key)
// 1451:         T.cast(step.fetch(key), String)
// 1452:       end
// 1453:
// 1454:       sig { returns(T.nilable(String)) }
// 1455:       def context_name
// 1456:         value = context_value(:name) || context_value(:token)
// 1457:         value&.to_s
// 1458:       end
// 1459:
// 1460:       sig { returns(T.nilable(String)) }
// 1461:       def context_version
// 1462:         context_value(:version)&.to_s
// 1463:       end
// 1464:
// 1465:       sig { returns(T.nilable(String)) }
// 1466:       def context_version_major
// 1467:         context_version_value = context_version
// 1468:         return if context_version_value.blank?
// 1469:
// 1470:         Version.new(context_version_value).major&.to_s
// 1471:       end
// 1472:
// 1473:       sig { returns(T.nilable(String)) }
// 1474:       def context_version_major_minor
// 1475:         context_version_value = context_version
// 1476:         return if context_version_value.blank?
// 1477:
// 1478:         Version.new(context_version_value).major_minor.to_s
// 1479:       end
// 1480:
// 1481:       sig { params(spec: PathSpec).returns(Pathname) }
// 1482:       def resolve_path(spec)
// 1483:         path = Pathname(expand_template_tokens(spec.fetch("path")))
// 1484:         base = spec["base"]
// 1485:
// 1486:         return path.expand_path if base.blank? || base == "absolute"
// 1487:         return path if base == "relative"
// 1488:
// 1489:         root_path(base, spec["formula"])/path
// 1490:       end
// 1491:
// 1492:       sig { params(spec: PathSpec).returns(SystemCommandArg) }
// 1493:       def resolve_command(spec)
// 1494:         return expand_template_tokens(spec.fetch("path")) if spec["base"].blank? || spec["base"] == "relative"
// 1495:
// 1496:         resolve_path(spec)
// 1497:       end
// 1498:
// 1499:       sig { params(spec: PathSpec).returns(String) }
// 1500:       def link_source(spec)
// 1501:         return expand_template_tokens(spec.fetch("path")) if spec["base"] == "relative"
// 1502:
// 1503:         resolve_path(spec).to_s
// 1504:       end
// 1505:
// 1506:       sig { params(formula: String, executable: String, args: SystemCommandArg).void }
// 1507:       def run_formula_tool(formula, executable, *args)
// 1508:         require "utils/path"
// 1509:
// 1510:         tool = Utils::Path.formula_opt_bin(formula)/executable
// 1511:         raise ArgumentError, "#{formula} is missing required executable: #{tool}" unless tool.executable?
// 1512:
// 1513:         run_command tool, *args
// 1514:       end
// 1515:
// 1516:       sig { params(base: String, formula: T.nilable(String)).returns(Pathname) }
// 1517:       def root_path(base, formula)
// 1518:         case base
// 1519:         when "home"
// 1520:           context_value(:home) ? context_path(base) : Pathname(Dir.home)
// 1521:         when "temp"
// 1522:           HOMEBREW_TEMP
// 1523:         when "homebrew_prefix"
// 1524:           HOMEBREW_PREFIX
// 1525:         when "formula_pkgetc"
// 1526:           formula_base(formula, :pkgetc)
// 1527:         when "formula_opt_prefix"
// 1528:           formula_base(formula, :opt_prefix)
// 1529:         else
// 1530:           context_path(base)
// 1531:         end
// 1532:       end
// 1533:
// 1534:       sig { params(base: String).returns(Pathname) }
// 1535:       def context_path(base)
// 1536:         method = base.to_sym
// 1537:         value = context_value(method) || context_config_value(method)
// 1538:         raise ArgumentError, "unknown install step base: #{base}" if value.nil?
// 1539:
// 1540:         Pathname(value.to_s)
// 1541:       end
// 1542:
// 1543:       sig { params(formula: T.nilable(String), method: Symbol).returns(Pathname) }
// 1544:       def formula_base(formula, method)
// 1545:         raise ArgumentError, "missing formula for install step base" if formula.blank?
// 1546:
// 1547:         case method
// 1548:         when :pkgetc
// 1549:           HOMEBREW_PREFIX/"etc"/Utils.name_from_full_name(formula)
// 1550:         when :opt_prefix
// 1551:           Utils::Path.formula_opt_prefix(formula)
// 1552:         else
// 1553:           raise ArgumentError, "unknown formula install step base: #{method}"
// 1554:         end
// 1555:       end
// 1556:
// 1557:       sig { params(method: Symbol).returns(T.nilable(Object)) }
// 1558:       def context_value(method)
// 1559:         @context.public_send(method) if @context.respond_to?(method)
// 1560:       end
// 1561:
// 1562:       sig { params(method: Symbol).returns(T.nilable(Object)) }
// 1563:       def context_config_value(method)
// 1564:         config = context_value(:config)
// 1565:         config.public_send(method) if config.respond_to?(method)
// 1566:       end
// 1567:
// 1568:       sig { params(command: SystemCommandArg, args: SystemCommandArg, sudo: T::Boolean).void }
// 1569:       def run_command(command, *args, sudo: false)
// 1570:         @command.run!(command, args: args, sudo:, print_stdout: true, print_stderr: true, reset_uid: true)
// 1571:       end
// 1572:
// 1573:       sig { params(command: SystemCommandArg, args: SystemCommandArg, sudo: T::Boolean).returns(String) }
// 1574:       def run_command_output(command, *args, sudo: false)
// 1575:         @command.run!(command, args: args, sudo:, print_stderr: true, reset_uid: true).stdout
// 1576:       end
// 1577:     end
// 1578:   end
// 1579: end
// 1580:
// 1581: require "install_steps/formula_actions"
