module test_bot

import ruby
import encoding.utf8
import homebrew.utils
import homebrew.utils.github
import os
import time

// Translated from Homebrew/brew `test_bot/step.rb`.

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
