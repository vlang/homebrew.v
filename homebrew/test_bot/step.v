module test_bot

import ruby
import encoding.utf8
import homebrew.utils
import homebrew.utils.github
import os
import time

// Translated from Homebrew/brew `test_bot/step.rb`.
// The original source is retained below until every stub has a typed V body.

pub enum StepStatus {
	running
	passed
	failed
	ignored
}

pub struct StepAnnotationLocation {
pub:
	path     string
	line     int
	has_line bool
}

pub struct StepFormulaLocation {
pub:
	path        string
	method_name string
	method_path string
	method_line int
	has_method  bool
}

pub struct StepConfig {
pub:
	environment         map[string]string
	unset_environment   []string
	verbose             bool
	ignore_failures     bool
	repository          string
	homebrew_library    string
	homebrew_prefix     string
	homebrew_repository string
	runner_os_title     string
	github_actions      bool
	emit_output         bool = true
	formula_locations   map[string]StepFormulaLocation
}

pub struct StepRunOptions {
pub:
	dry_run   bool
	fail_fast bool
}

pub struct StepCommandResult {
pub:
	exit_code int
	output    string
}

pub struct StepRunResult {
pub:
	exit_code      int
	exit_requested bool
	raised         bool
	error_message  string
	emitted        []string
}

pub struct Step {
pub:
	command             []string
	name                string
	has_name            bool
	named_args          []string
	environment         map[string]string
	unset_environment   []string
	verbose             bool
	ignore_failures     bool
	repository          string
	homebrew_library    string
	homebrew_prefix     string
	homebrew_repository string
	runner_title        string
	github_actions      bool
	emit_output         bool
	formula_locations   map[string]StepFormulaLocation
pub mut:
	status         StepStatus = .running
	output         string
	has_output     bool
	start_time     time.Time
	end_time       time.Time
	has_start_time bool
	has_end_time   bool
	emitted        []string
}

pub fn runner_os_title() !string {
	return error('Homebrew::TestBot.runner_os_title must be implemented in extend/os.')
}

pub fn runner_os_title_with_arch(title string) string {
	return title
}

pub fn new_step(command []string, named_args []string, config StepConfig) Step {
	mut complete_command := command.clone()
	complete_command << named_args
	return Step{
		command: complete_command
		name: if command.len > 1 { command[1].replace('-', '') } else { '' }
		has_name: command.len > 1
		named_args: named_args.clone()
		environment: config.environment.clone()
		unset_environment: config.unset_environment.clone()
		verbose: config.verbose
		ignore_failures: config.ignore_failures
		repository: config.repository
		homebrew_library: if config.homebrew_library != '' {
			config.homebrew_library
		} else {
			ruby.environment_value('HOMEBREW_LIBRARY')
		}
		homebrew_prefix: if config.homebrew_prefix != '' {
			config.homebrew_prefix
		} else {
			ruby.environment_value('HOMEBREW_PREFIX')
		}
		homebrew_repository: if config.homebrew_repository != '' {
			config.homebrew_repository
		} else {
			ruby.environment_value('HOMEBREW_REPOSITORY')
		}
		runner_title: if config.runner_os_title != '' {
			config.runner_os_title
		} else {
			ruby.kernel_info().name
		}
		github_actions: config.github_actions
		emit_output: config.emit_output
		formula_locations: config.formula_locations.clone()
	}
}

fn step_delete_prefix(value string, prefix string) string {
	if prefix != '' && value.starts_with(prefix) {
		return value[prefix.len..]
	}
	return value
}

pub fn (step Step) command_trimmed() string {
	mut filtered := []string{cap: step.command.len}
	for argument in step.command {
		if !argument.starts_with('--exclude') {
			filtered << argument
		}
	}
	mut command := filtered.join(' ')
	if step.homebrew_library != '' {
		command = step_delete_prefix(command, '${step.homebrew_library.trim_right('/')}/Taps/')
	}
	if step.homebrew_prefix != '' {
		command = step_delete_prefix(command, '${step.homebrew_prefix.trim_right('/')}/')
	}
	return step_delete_prefix(command, '/usr/bin/')
}

pub fn (step Step) command_short() string {
	mut omitted := ['brew', '-C', '--force', '--retry', '--verbose', '--json']
	omitted << step.repository
	for path in [step.homebrew_prefix, step.homebrew_repository, os.getwd()] {
		if path != '' {
			omitted << path
		}
	}
	mut shortened := []string{cap: step.command.len}
	for argument in step.command {
		if argument !in omitted {
			shortened << argument
		}
	}
	mut command := shortened.join(' ')
	for path in [step.homebrew_prefix, step.homebrew_repository, step.repository, os.getwd()] {
		if path != '' {
			command = command.replace(path, '')
		}
	}
	return command
}

pub fn (step Step) passed() bool {
	return step.status == .passed
}

pub fn (step Step) failed() bool {
	return step.status == .failed
}

pub fn (step Step) ignored() bool {
	return step.status == .ignored
}

fn step_headline(text string, color string) string {
	return utils.formatter_headline(text, color, utils.current_tty_state())
}

fn (mut step Step) emit(text string) {
	step.emitted << text
	if step.emit_output {
		if text.ends_with('\n') {
			print(text)
		} else {
			println(text)
		}
	}
}

pub fn (mut step Step) puts_command() string {
	line := step_headline(step.command_trimmed(), 'blue')
	step.emit(line)
	return line
}

pub fn (mut step Step) puts_result() string {
	if step.passed() {
		return ''
	}
	state := utils.current_tty_state()
	line := utils.formatter_headline(utils.formatter_error('FAILED', none, state), 'red', state)
	step.emit(line)
	return line
}

pub fn (step Step) github_actions_annotation(message string, title string, file string,
	location StepAnnotationLocation) string {
	if !step.actions_enabled() {
		return ''
	}
	kind := if step.passed() {
		'notice'
	} else if step.ignored() {
		'warning'
	} else {
		'error'
	}
	annotation := github.new_actions_annotation(kind, message, github.ActionsAnnotationOptions{
		title: title
		file: file
		line: location.line
		has_line: location.has_line
		workspace: os.getenv('GITHUB_WORKSPACE')
	}) or { return '' }
	return annotation.str()
}

fn (step Step) actions_enabled() bool {
	return step.github_actions || os.getenv('GITHUB_ACTIONS') != ''
}

pub fn github_actions_group(title string, body string, enabled bool) string {
	if !enabled {
		return body
	}
	separator := if body.ends_with('\n') { '' } else { '\n' }
	return '::group::${title}\n${body}${separator}::endgroup::'
}

pub fn (step Step) output_present() bool {
	return step.has_output && step.output.trim_space() != ''
}

pub fn (step Step) elapsed_seconds() !f64 {
	if !step.has_start_time || !step.has_end_time {
		return error('Step#run must complete before Step#time is read')
	}
	return f64(step.end_time.unix_nano() - step.start_time.unix_nano()) / 1_000_000_000.0
}

pub fn (mut step Step) puts_full_output() string {
	if !step.output_present() || step.verbose {
		return ''
	}
	group := github_actions_group('Full ${step.command_short()} output', step.output, step.actions_enabled())
	step.emit(group)
	return group
}

fn step_method_location(path string, method_name string) StepAnnotationLocation {
	if path == '' || !os.is_file(path) {
		return StepAnnotationLocation{ path: path }
	}
	lines := os.read_lines(path) or { return StepAnnotationLocation{ path: path } }
	for index, line in lines {
		trimmed := line.trim_space()
		if trimmed == 'def ${method_name}' || trimmed.starts_with('def ${method_name}(')
			|| trimmed.starts_with('def ${method_name} ') {
			return StepAnnotationLocation{
				path: path
				line: index + 1
				has_line: true
			}
		}
	}
	return StepAnnotationLocation{ path: path }
}

fn step_repository_candidates(repository string, name string) []string {
	if repository == '' || !os.is_dir(repository) {
		return []
	}
	plain_name := name.all_after_last('/').trim_string_right('.rb')
	mut exact := []string{}
	mut fallback := []string{}
	for path in os.walk_ext(repository, '.rb') {
		base := os.base(path)
		if base == '${plain_name}.rb' {
			exact << path
		} else if base.starts_with(plain_name) {
			fallback << path
		}
	}
	exact.sort()
	fallback.sort()
	exact << fallback
	return exact
}

pub fn (step Step) annotation_location(name string) StepAnnotationLocation {
	if supplied := step.formula_locations[name] {
		if supplied.has_method && step.command.len > 1 && supplied.method_name == step.command[1]
			&& supplied.method_path == supplied.path {
			return StepAnnotationLocation{
				path: supplied.method_path
				line: supplied.method_line
				has_line: true
			}
		}
		return StepAnnotationLocation{ path: supplied.path }
	}
	if os.is_file(name) {
		method_name := if step.command.len > 1 { step.command[1] } else { '' }
		return step_method_location(name, method_name)
	}
	candidates := step_repository_candidates(step.repository, name)
	if candidates.len == 0 {
		return StepAnnotationLocation{}
	}
	method_name := if step.command.len > 1 { step.command[1] } else { '' }
	return step_method_location(candidates[0], method_name)
}

fn step_lines_with_endings(output string) []string {
	mut lines := []string{}
	mut start := 0
	for index, character in output.bytes() {
		if character == `\n` {
			lines << output[start..index + 1]
			start = index + 1
		}
	}
	if start < output.len {
		lines << output[start..]
	}
	return lines
}

fn step_is_word_byte(value u8) bool {
	return value.is_alnum() || value == `_`
}

fn step_contains_error_label(line string) bool {
	lower := line.to_lower()
	mut offset := 0
	for offset < lower.len {
		found := lower[offset..].index('error:') or { return false }
		index := offset + found
		before_word := index > 0 && step_is_word_byte(lower[index - 1])
		after := index + 'error:'.len
		if !before_word && after < lower.len && lower[after].is_space() {
			return true
		}
		offset = after
	}
	return false
}

fn step_is_actions_error(line string) bool {
	trimmed := line.trim_space().to_lower()
	return trimmed.starts_with('::error::')
		|| (trimmed.starts_with('::error ') && trimmed.ends_with('::'))
}

fn step_contains_word_phrase(line string, phrase string) bool {
	mut offset := 0
	for offset < line.len {
		found := line[offset..].index(phrase) or { return false }
		index := offset + found
		end := index + phrase.len
		if (index == 0 || !step_is_word_byte(line[index - 1]))
			&& (end == line.len || !step_is_word_byte(line[end])) {
			return true
		}
		offset = end
	}
	return false
}

pub fn truncate_step_output(source string, max_kb int, context_lines int) string {
	lines := step_lines_with_endings(source)
	mut first_error := -1
	for index, line in lines {
		lower := line.to_lower()
		if !step_is_actions_error(line)
			&& (step_contains_error_label(line) || step_contains_word_phrase(lower, 'cmake error')) {
			first_error = index
			break
		}
	}
	if first_error >= 0 {
		start := if first_error > context_lines { first_error - context_lines } else { 0 }
		return lines[start..].join('')
	}
	mut kept := []string{}
	mut length := 0
	for index := lines.len - 1; index >= 0; index-- {
		line := lines[index]
		if kept.len > 0 && line.len + length > max_kb {
			break
		}
		kept.prepend(line)
		length += line.len
	}
	return kept.join('')
}

fn step_utf8_output(output string) string {
	if utf8.validate_str(output) {
		return output
	}
	return output.runes().string()
}

fn step_valid_environment_name(name string) bool {
	if name == '' || name[0].is_digit() || !(name[0].is_letter() || name[0] == `_`) {
		return false
	}
	return name.bytes().all(it.is_alnum() || it == `_`)
}

pub fn execute_step_command(command []string, environment map[string]string,
	unset_environment []string) !StepCommandResult {
	if command.len == 0 || command[0] == '' {
		return error('step command must contain an executable')
	}
	mut process_environment := os.environ()
	for key, value in environment {
		if !step_valid_environment_name(key) {
			return error('Invalid variable name: ${key}')
		}
		process_environment[key] = value
	}
	for key in unset_environment {
		if !step_valid_environment_name(key) {
			return error('Invalid variable name: ${key}')
		}
		process_environment.delete(key)
	}
	mut process := os.new_process(command[0])
	process.set_args(command[1..])
	process.set_environment(process_environment)
	process.set_redirect_stdio_merged()
	process.set_stdin_path(os.path_devnull)
	process.use_pgroup = true
	process.run()
	if process.status == .aborted || process.err != '' {
		message := if process.err == '' { 'failed to start ${command[0]}' } else { process.err }
		process.close()
		return error(message)
	}
	output := process.stdout_slurp()
	process.wait()
	exit_code := process.code
	process.close()
	return StepCommandResult{
		exit_code: exit_code
		output: output
	}
}

fn (mut step Step) finish_result(exit_code int, exit_requested bool, raised bool,
	error_message string) StepRunResult {
	return StepRunResult{
		exit_code: exit_code
		exit_requested: exit_requested
		raised: raised
		error_message: error_message
		emitted: step.emitted.clone()
	}
}

pub fn (mut step Step) run(options StepRunOptions) StepRunResult {
	step.start_time = time.now()
	step.has_start_time = true
	step.puts_command()
	if options.dry_run {
		step.status = .passed
		step.puts_result()
		return step.finish_result(0, false, false, '')
	}
	if step.command.len == 0 {
		return step.finish_result(1, false, true, 'step command must contain an executable')
	}
	if step.command[0] == 'git'
		&& (step.command.len < 2 || step.command[1] !in ['-C', 'clone']) {
		return step.finish_result(1, false, true, 'git should always be called with -C!')
	}
	command_result := execute_step_command(step.command, step.environment, step.unset_environment) or {
		return step.finish_result(1, false, true, err.msg())
	}
	step.end_time = time.now()
	step.has_end_time = true
	step.status = if command_result.exit_code == 0 {
		.passed
	} else if step.ignore_failures {
		.ignored
	} else {
		.failed
	}
	step.puts_result()
	if command_result.output == '' {
		if step.verbose {
			step.emit('')
		}
		return step.finish_result(command_result.exit_code, options.fail_fast && step.failed(), false, '')
	}
	step.output = step_utf8_output(command_result.output)
	step.has_output = true
	if step.verbose {
		step.emit(step.output.trim_right('\n'))
	}
	if step.passed() {
		return step.finish_result(command_result.exit_code, false, false, '')
	}
	step.puts_full_output()
	if !step.actions_enabled() {
		step.emit('')
		return step.finish_result(command_result.exit_code, options.fail_fast && step.failed(), false, '')
	}
	for name in step.named_args {
		if name.trim_space() == '' {
			continue
		}
		location := step.annotation_location(name)
		if location.path.trim_space() == '' {
			continue
		}
		annotation_output := truncate_step_output(step.output, 4, 5)
		title := '`${step.command_trimmed()}` failed on ${runner_os_title_with_arch(step.runner_title)}!'
		file := step_delete_prefix(location.path, '${step.repository.trim_right('/')}/')
		annotation := step.github_actions_annotation(annotation_output, title, file, location)
		if annotation != '' {
			step.emit(github_actions_group('Truncated ${step.command_short()} output', annotation, true))
		}
	}
	return step.finish_result(command_result.exit_code, options.fail_fast && step.failed(), false, '')
}

fn step_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn step_boundary_value(step Step) ruby.Value {
	mut attributes := {
		'name':                step.name
		'has_name':            step.has_name.str()
		'named_args':          step.named_args.join('\x1f')
		'status':              step.status.str()
		'output':              step.output
		'has_output':          step.has_output.str()
		'start_time':          step.start_time.unix_nano().str()
		'end_time':            step.end_time.unix_nano().str()
		'has_start_time':      step.has_start_time.str()
		'has_end_time':        step.has_end_time.str()
		'verbose':             step.verbose.str()
		'ignore_failures':     step.ignore_failures.str()
		'repository':          step.repository
		'homebrew_library':    step.homebrew_library
		'homebrew_prefix':     step.homebrew_prefix
		'homebrew_repository': step.homebrew_repository
		'runner_title':        step.runner_title
		'github_actions':      step.github_actions.str()
		'emit_output':         step.emit_output.str()
		'unset_environment':   step.unset_environment.join('\x1f')
	}
	for key, value in step.environment {
		attributes['environment:${key}'] = value
	}
	return ruby.Value{
		type_name: 'Homebrew::TestBot::Step'
		repr: step.command.join(' ')
		string_array_data: step.command.clone()
		attributes: attributes
	}
}

fn step_from_boundary(value ruby.Value) Step {
	attributes := value.attributes.clone()
	start_nanoseconds := (attributes['start_time'] or { '0' }).i64()
	end_nanoseconds := (attributes['end_time'] or { '0' }).i64()
	status := match attributes['status'] or { 'running' } {
		'passed' { StepStatus.passed }
		'failed' { StepStatus.failed }
		'ignored' { StepStatus.ignored }
		else { StepStatus.running }
	}
	mut environment := map[string]string{}
	for key, contents in attributes {
		if key.starts_with('environment:') {
			environment[key.all_after('environment:')] = contents
		}
	}
	return Step{
		command: value.string_array_data.clone()
		name: attributes['name']
		has_name: attributes['has_name'] == 'true'
		named_args: if attributes['named_args'] == '' {
			[]
		} else {
			attributes['named_args'].split('\x1f')
		}
		environment: environment
		unset_environment: if attributes['unset_environment'] == '' {
			[]
		} else {
			attributes['unset_environment'].split('\x1f')
		}
		verbose: attributes['verbose'] == 'true'
		ignore_failures: attributes['ignore_failures'] == 'true'
		repository: attributes['repository']
		homebrew_library: attributes['homebrew_library']
		homebrew_prefix: attributes['homebrew_prefix']
		homebrew_repository: attributes['homebrew_repository']
		runner_title: attributes['runner_title']
		github_actions: attributes['github_actions'] == 'true'
		emit_output: attributes['emit_output'] == 'true'
		status: status
		output: attributes['output']
		has_output: attributes['has_output'] == 'true'
		start_time: time.unix_nano(start_nanoseconds)
		end_time: time.unix_nano(end_nanoseconds)
		has_start_time: attributes['has_start_time'] == 'true'
		has_end_time: attributes['has_end_time'] == 'true'
	}
}

fn step_boundary_receiver(args []ruby.Value) Step {
	if args.len == 0 || args[0].type_name != 'Homebrew::TestBot::Step' {
		return new_step([], [], StepConfig{ emit_output: false })
	}
	return step_from_boundary(args[0])
}

fn step_named_args(value ruby.Value) []string {
	if value.type_name in ['NilClass', 'Nil'] {
		return []
	}
	if value.type_name == 'Array' {
		return value.as_string_array() or { []string{} }
	}
	return [value.as_string()]
}

fn step_config_from_boundary(args []ruby.Value) StepConfig {
	mut environment := map[string]string{}
	mut unset_environment := []string{}
	if args.len > 1 && args[1].type_name == 'Hash' {
		for key, value in args[1].map_data {
			if value.type_name in ['NilClass', 'Nil'] {
				unset_environment << key
			} else if value.type_name == 'Bool' {
				environment[key] = value.bool_data.str()
			} else {
				environment[key] = value.as_string()
			}
		}
	}
	return StepConfig{
		environment: environment
		unset_environment: unset_environment
		verbose: args.len > 2 && (args[2].as_bool() or { false })
		ignore_failures: args.len > 4 && (args[4].as_bool() or { false })
		repository: if args.len > 5 { args[5].as_string() } else { '' }
		emit_output: false
	}
}

// Ruby method `self.runner_os_title` at line 10.
pub fn ruby_step_l10_d1_self_runner_os_title(args ...ruby.Value) ruby.Value {
	title := runner_os_title() or { return ruby.object_value('NotImplementedError', err.msg()) }
	return ruby.string_value(title)
}

// Ruby method `self.runner_os_title_with_arch` at line 15.
pub fn ruby_step_l15_d2_self_runner_os_title_with_arch(args ...ruby.Value) ruby.Value {
	title := if args.len > 0 { args[0].as_string() } else { ruby.kernel_info().name }
	return ruby.string_value(runner_os_title_with_arch(title))
}

// Ruby attr_reader `attr_reader :command` at line 25.
pub fn ruby_step_l25_d3_command(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(step_boundary_receiver(args).command)
}

// Ruby attr_reader `attr_reader :name` at line 28.
pub fn ruby_step_l28_d4_name(args ...ruby.Value) ruby.Value {
	step := step_boundary_receiver(args)
	return if step.has_name { ruby.string_value(step.name) } else { step_nil_value() }
}

// Ruby attr_reader `attr_reader :status` at line 31.
pub fn ruby_step_l31_d5_status(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', ':' + step_boundary_receiver(args).status.str())
}

// Ruby attr_reader `attr_reader :output` at line 34.
pub fn ruby_step_l34_d6_output(args ...ruby.Value) ruby.Value {
	step := step_boundary_receiver(args)
	return if step.has_output { ruby.string_value(step.output) } else { step_nil_value() }
}

// Ruby attr_reader `attr_reader :start_time, :end_time` at line 37.
pub fn ruby_step_l37_d7_start_time(args ...ruby.Value) ruby.Value {
	step := step_boundary_receiver(args)
	return if step.has_start_time {
		ruby.int_value(step.start_time.unix_nano())
	} else {
		step_nil_value()
	}
}

// Ruby attr_reader `attr_reader :start_time, :end_time` at line 37.
pub fn ruby_step_l37_d8_end_time(args ...ruby.Value) ruby.Value {
	step := step_boundary_receiver(args)
	return if step.has_end_time {
		ruby.int_value(step.end_time.unix_nano())
	} else {
		step_nil_value()
	}
}

// Ruby method `initialize(command, env:, verbose:, named_args: nil, ignore_failures: false, repository: nil)` at line 52.
pub fn ruby_step_l52_d9_initialize(args ...ruby.Value) ruby.Value {
	command := if args.len > 0 { args[0].as_string_array() or { []string{} } } else { []string{} }
	named_args := if args.len > 3 { step_named_args(args[3]) } else { []string{} }
	return step_boundary_value(new_step(command, named_args, step_config_from_boundary(args)))
}

// Ruby method `command_trimmed` at line 66.
pub fn ruby_step_l66_d10_command_trimmed(args ...ruby.Value) ruby.Value {
	return ruby.string_value(step_boundary_receiver(args).command_trimmed())
}

// Ruby method `command_short` at line 75.
pub fn ruby_step_l75_d11_command_short(args ...ruby.Value) ruby.Value {
	return ruby.string_value(step_boundary_receiver(args).command_short())
}

// Ruby method `passed?` at line 95.
pub fn ruby_step_l95_d12_passed(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(step_boundary_receiver(args).passed())
}

// Ruby method `failed?` at line 100.
pub fn ruby_step_l100_d13_failed(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(step_boundary_receiver(args).failed())
}

// Ruby method `ignored?` at line 105.
pub fn ruby_step_l105_d14_ignored(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(step_boundary_receiver(args).ignored())
}

// Ruby method `puts_command` at line 110.
pub fn ruby_step_l110_d15_puts_command(args ...ruby.Value) ruby.Value {
	mut step := step_boundary_receiver(args)
	step.puts_command()
	return step_nil_value()
}

// Ruby method `puts_result` at line 115.
pub fn ruby_step_l115_d16_puts_result(args ...ruby.Value) ruby.Value {
	mut step := step_boundary_receiver(args)
	step.puts_result()
	return step_nil_value()
}

// Ruby method `puts_github_actions_annotation(message, title, file, line)` at line 120.
pub fn ruby_step_l120_d17_puts_github_actions_annotation(args ...ruby.Value) ruby.Value {
	mut step := step_boundary_receiver(args)
	if args.len < 4 {
		return step_nil_value()
	}
	line := if args.len > 4 { int(args[4].as_int() or { 0 }) } else { 0 }
	annotation := step.github_actions_annotation(args[1].as_string(), args[2].as_string(), args[3].as_string(), StepAnnotationLocation{
		path: args[3].as_string()
		line: line
		has_line: args.len > 4 && args[4].type_name !in ['NilClass', 'Nil']
	})
	if annotation != '' {
		step.emit(annotation)
	}
	return step_nil_value()
}

// Ruby method `puts_in_github_actions_group(title, &_block)` at line 136.
pub fn ruby_step_l136_d18_puts_in_github_actions_group(args ...ruby.Value) ruby.Value {
	step := step_boundary_receiver(args)
	title := if args.len > 1 { args[1].as_string() } else { '' }
	body := if args.len > 2 { args[2].as_string() } else { '' }
	_ = github_actions_group(title, body, step.actions_enabled())
	return step_nil_value()
}

// Ruby method `output?` at line 143.
pub fn ruby_step_l143_d19_output(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(step_boundary_receiver(args).output_present())
}

// Ruby method `time` at line 151.
pub fn ruby_step_l151_d20_time(args ...ruby.Value) ruby.Value {
	seconds := step_boundary_receiver(args).elapsed_seconds() or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return ruby.float_value(seconds)
}

// Ruby method `puts_full_output` at line 156.
pub fn ruby_step_l156_d21_puts_full_output(args ...ruby.Value) ruby.Value {
	mut step := step_boundary_receiver(args)
	step.puts_full_output()
	return step_nil_value()
}

// Ruby method `annotation_location(name)` at line 165.
pub fn ruby_step_l165_d22_annotation_location(args ...ruby.Value) ruby.Value {
	step := step_boundary_receiver(args)
	location := step.annotation_location(if args.len > 1 { args[1].as_string() } else { '' })
	return ruby.array_value([
		if location.path == '' {
			step_nil_value()
		} else {
			ruby.object_value('Pathname', location.path)
		},
		if location.has_line { ruby.int_value(location.line) } else { step_nil_value() },
	])
}

// Ruby method `truncate_output(output, max_kb:, context_lines:)` at line 181.
pub fn ruby_step_l181_d23_truncate_output(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.string_value('')
	}
	max_kb := if args.len > 2 { int(args[2].as_int() or { 4 }) } else { 4 }
	context_lines := if args.len > 3 { int(args[3].as_int() or { 5 }) } else { 5 }
	return ruby.string_value(truncate_step_output(args[1].as_string(), max_kb, context_lines))
}

// Ruby method `run(dry_run: false, fail_fast: false)` at line 208.
pub fn ruby_step_l208_d24_run(args ...ruby.Value) ruby.Value {
	mut step := step_boundary_receiver(args)
	result := step.run(StepRunOptions{
		dry_run: args.len > 1 && (args[1].as_bool() or { false })
		fail_fast: args.len > 2 && (args[2].as_bool() or { false })
	})
	return ruby.Value{
		type_name: 'Homebrew::TestBot::StepRunResult'
		repr: result.exit_code.str()
		attributes: {
			'exit_code':      result.exit_code.str()
			'exit_requested': result.exit_requested.str()
			'raised':         result.raised.str()
			'error_message':  result.error_message
			'status':         step.status.str()
			'output':         step.output
		}
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5: require "utils/github/actions"
// 6:
// 7: module Homebrew
// 8:   module TestBot
// 9:     sig { returns(String) }
// 10:     def self.runner_os_title
// 11:       raise NotImplementedError, "Homebrew::TestBot.runner_os_title must be implemented in extend/os."
// 12:     end
// 13:
// 14:     sig { returns(String) }
// 15:     def self.runner_os_title_with_arch
// 16:       runner_os_title
// 17:     end
// 18:
// 19:     # Wraps command invocations. Instantiated by Test#test.
// 20:     # Handles logging and pretty-printing.
// 21:     class Step
// 22:       include SystemCommand::Mixin
// 23:
// 24:       sig { returns(T::Array[String]) }
// 25:       attr_reader :command
// 26:
// 27:       sig { returns(T.nilable(String)) }
// 28:       attr_reader :name
// 29:
// 30:       sig { returns(Symbol) }
// 31:       attr_reader :status
// 32:
// 33:       sig { returns(T.nilable(String)) }
// 34:       attr_reader :output
// 35:
// 36:       sig { returns(T.nilable(Time)) }
// 37:       attr_reader :start_time, :end_time
// 38:
// 39:       # Instantiates a Step object.
// 40:       # @param command Command to execute and arguments.
// 41:       # @param env Environment variables to set when running command.
// 42:       sig {
// 43:         params(
// 44:           command:         T::Array[String],
// 45:           env:             T::Hash[String, T.nilable(T.any(String, T::Boolean, PATH))],
// 46:           verbose:         T::Boolean,
// 47:           named_args:      T.nilable(T.any(String, T::Array[String])),
// 48:           ignore_failures: T::Boolean,
// 49:           repository:      T.nilable(Pathname),
// 50:         ).void
// 51:       }
// 52:       def initialize(command, env:, verbose:, named_args: nil, ignore_failures: false, repository: nil)
// 53:         @named_args = T.let([named_args].flatten.compact.map(&:to_s), T::Array[String])
// 54:         @command = T.let(command + @named_args, T::Array[String])
// 55:         @env = env
// 56:         @verbose = verbose
// 57:         @ignore_failures = ignore_failures
// 58:         @repository = repository
// 59:
// 60:         @name = T.let(command[1]&.delete("-"), T.nilable(String))
// 61:         @status = T.let(:running, Symbol)
// 62:         @output = T.let(nil, T.nilable(String))
// 63:       end
// 64:
// 65:       sig { returns(String) }
// 66:       def command_trimmed
// 67:         command.reject { |arg| arg.to_s.start_with?("--exclude") }
// 68:                .join(" ")
// 69:                .delete_prefix("#{HOMEBREW_LIBRARY}/Taps/")
// 70:                .delete_prefix("#{HOMEBREW_PREFIX}/")
// 71:                .delete_prefix("/usr/bin/")
// 72:       end
// 73:
// 74:       sig { returns(String) }
// 75:       def command_short
// 76:         (@command - %W[
// 77:           brew
// 78:           -C
// 79:           #{HOMEBREW_PREFIX}
// 80:           #{HOMEBREW_REPOSITORY}
// 81:           #{@repository}
// 82:           #{Dir.pwd}
// 83:           --force
// 84:           --retry
// 85:           --verbose
// 86:           --json
// 87:         ].freeze).join(" ")
// 88:           .gsub(HOMEBREW_PREFIX.to_s, "")
// 89:           .gsub(HOMEBREW_REPOSITORY.to_s, "")
// 90:           .gsub(@repository.to_s, "")
// 91:           .gsub(Dir.pwd, "")
// 92:       end
// 93:
// 94:       sig { returns(T::Boolean) }
// 95:       def passed?
// 96:         @status == :passed
// 97:       end
// 98:
// 99:       sig { returns(T::Boolean) }
// 100:       def failed?
// 101:         @status == :failed
// 102:       end
// 103:
// 104:       sig { returns(T::Boolean) }
// 105:       def ignored?
// 106:         @status == :ignored
// 107:       end
// 108:
// 109:       sig { void }
// 110:       def puts_command
// 111:         puts Formatter.headline(command_trimmed, color: :blue)
// 112:       end
// 113:
// 114:       sig { void }
// 115:       def puts_result
// 116:         puts Formatter.headline(Formatter.error("FAILED"), color: :red) unless passed?
// 117:       end
// 118:
// 119:       sig { params(message: String, title: String, file: String, line: T.nilable(Integer)).void }
// 120:       def puts_github_actions_annotation(message, title, file, line)
// 121:         return unless GitHub::Actions.env_set?
// 122:
// 123:         type = if passed?
// 124:           :notice
// 125:         elsif ignored?
// 126:           :warning
// 127:         else
// 128:           :error
// 129:         end
// 130:
// 131:         annotation = GitHub::Actions::Annotation.new(type, message, title:, file:, line:)
// 132:         puts annotation
// 133:       end
// 134:
// 135:       sig { params(title: String, _block: T.proc.void).void }
// 136:       def puts_in_github_actions_group(title, &_block)
// 137:         puts "::group::#{title}" if GitHub::Actions.env_set?
// 138:         yield
// 139:         puts "::endgroup::" if GitHub::Actions.env_set?
// 140:       end
// 141:
// 142:       sig { returns(T::Boolean) }
// 143:       def output?
// 144:         @output.present?
// 145:       end
// 146:
// 147:       # The execution time of the task.
// 148:       # Precondition: Step#run has been called.
// 149:       # @return execution time in seconds
// 150:       sig { returns(Float) }
// 151:       def time
// 152:         T.must(end_time) - T.must(start_time)
// 153:       end
// 154:
// 155:       sig { void }
// 156:       def puts_full_output
// 157:         return if @output.blank? || @verbose
// 158:
// 159:         puts_in_github_actions_group("Full #{command_short} output") do
// 160:           puts @output
// 161:         end
// 162:       end
// 163:
// 164:       sig { params(name: String).returns([T.nilable(String), T.nilable(Integer)]) }
// 165:       def annotation_location(name)
// 166:         formula = Formulary.factory(name)
// 167:         method_sym = command.fetch(1).to_sym
// 168:         method_location = formula.method(method_sym).source_location if formula.respond_to?(method_sym)
// 169:
// 170:         if method_location.present? && (method_location.first == formula.path.to_s)
// 171:           method_location
// 172:         else
// 173:           [formula.path.to_s, nil]
// 174:         end
// 175:       rescue FormulaUnavailableError
// 176:         glob_result = @repository ? @repository.glob("**/#{name}*").first&.to_s : nil
// 177:         [glob_result, nil]
// 178:       end
// 179:
// 180:       sig { params(output: String, max_kb: Integer, context_lines: Integer).returns(String) }
// 181:       def truncate_output(output, max_kb:, context_lines:)
// 182:         output_lines = output.lines
// 183:         first_error_index = output_lines.find_index do |line|
// 184:           !line.strip.match?(/^::error( .*)?::/) &&
// 185:             (line.match?(/\berror:\s+/i) || line.match?(/\bcmake error\b/i))
// 186:         end
// 187:
// 188:         if first_error_index.blank?
// 189:           output = []
// 190:
// 191:           # Collect up to max_kb worth of the last lines of output.
// 192:           output_lines.reverse_each do |line|
// 193:             # Check output.present? so that we at least have _some_ output.
// 194:             break if line.length + output.join.length > max_kb && output.present?
// 195:
// 196:             output.unshift line
// 197:           end
// 198:
// 199:           output.join
// 200:         else
// 201:           start = [first_error_index - context_lines, 0].max
// 202:           # Let GitHub Actions truncate us to 4KB if needed.
// 203:           T.must(output_lines[start..]).join
// 204:         end
// 205:       end
// 206:
// 207:       sig { params(dry_run: T::Boolean, fail_fast: T::Boolean).void }
// 208:       def run(dry_run: false, fail_fast: false)
// 209:         @start_time = T.let(Time.now, T.nilable(Time))
// 210:
// 211:         puts_command
// 212:         if dry_run
// 213:           @status = :passed
// 214:           puts_result
// 215:           return
// 216:         end
// 217:
// 218:         raise "git should always be called with -C!" if command[0] == "git" && %w[-C clone].exclude?(command[1])
// 219:
// 220:         executable, *args = command
// 221:
// 222:         result = system_command T.must(executable), args:,
// 223:                                                     print_stdout: @verbose,
// 224:                                                     print_stderr: @verbose,
// 225:                                                     env:          @env
// 226:
// 227:         @end_time = T.let(Time.now, T.nilable(Time))
// 228:
// 229:         @status = if result.success?
// 230:           :passed
// 231:         elsif @ignore_failures
// 232:           :ignored
// 233:         else
// 234:           :failed
// 235:         end
// 236:
// 237:         puts_result
// 238:
// 239:         output = result.merged_output
// 240:
// 241:         # ActiveSupport can barf on some Unicode so don't use .present?
// 242:         if output.empty?
// 243:           puts if @verbose
// 244:           exit 1 if fail_fast && failed?
// 245:           return
// 246:         end
// 247:
// 248:         output.force_encoding(Encoding::UTF_8)
// 249:         @output = if output.valid_encoding?
// 250:           output
// 251:         else
// 252:           output.encode!(Encoding::UTF_16, invalid: :replace)
// 253:           output.encode!(Encoding::UTF_8)
// 254:         end
// 255:
// 256:         return if passed?
// 257:
// 258:         puts_full_output
// 259:
// 260:         unless GitHub::Actions.env_set?
// 261:           puts
// 262:           exit 1 if fail_fast && failed?
// 263:           return
// 264:         end
// 265:
// 266:         @named_args.each do |name|
// 267:           next if name.blank?
// 268:
// 269:           path, line = annotation_location(name)
// 270:           next if path.blank?
// 271:
// 272:           # GitHub Actions has a 4KB maximum for annotations.
// 273:           annotation_output = truncate_output(@output, max_kb: 4, context_lines: 5)
// 274:
// 275:           annotation_title = "`#{command_trimmed}` failed on #{Homebrew::TestBot.runner_os_title_with_arch}!"
// 276:           file = path.delete_prefix("#{@repository}/")
// 277:           puts_in_github_actions_group("Truncated #{command_short} output") do
// 278:             puts_github_actions_annotation(annotation_output, annotation_title, file, line)
// 279:           end
// 280:         end
// 281:
// 282:         exit 1 if fail_fast && failed?
// 283:       end
// 284:     end
// 285:   end
// 286: end
