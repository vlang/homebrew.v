module homebrew

import brew_runtime
import time

// Translated from Homebrew/brew `system_command.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum SystemCommandPrintMode {
	discard
	always
	debug
}

pub enum SystemCommandOutputType {
	stdout
	stderr
}

pub struct SystemCommandOutputLine {
pub:
	kind SystemCommandOutputType
	line string
}

pub struct SystemCommandStatus {
pub:
	exit_code   int
	terminated  bool
	term_signal int
}

pub fn (status SystemCommandStatus) success() bool {
	return !status.terminated && status.exit_code == 0
}

@[params]
pub struct SystemCommandOptions {
pub:
	args               []string
	sudo               bool
	sudo_as_root       bool
	environment        map[string]?string
	input              []string
	must_succeed       bool
	print_stdout       SystemCommandPrintMode
	print_stderr       SystemCommandPrintMode = .always
	debug              ?bool
	verbose            ?bool
	secrets            []string
	chdir              string
	reset_uid          bool
	run_as_real_uid    bool
	timeout            ?time.Duration
	absolute_path_args []int
}

pub struct SystemCommand {
pub mut:
	executable         string
	args               []string
	sudo               bool
	sudo_as_root       bool
	environment        map[string]?string
	input              []string
	must_succeed       bool
	print_stdout       SystemCommandPrintMode
	print_stderr       SystemCommandPrintMode
	debug_override     ?bool
	verbose_override   ?bool
	secrets            []string
	chdir              string
	reset_uid          bool
	run_as_real_uid    bool
	timeout            ?time.Duration
	absolute_path_args []int
}

pub struct SystemCommandExecution {
pub:
	output []SystemCommandOutputLine
	status SystemCommandStatus
}

pub struct SystemCommandResultTuple {
pub:
	stdout string
	stderr string
	status SystemCommandStatus
}

pub struct SystemCommandPlist {
pub:
	raw_xml string
	values  map[string]string
	arrays  map[string][]map[string]string
	garbage []string
}

pub struct SystemCommandResult {
pub mut:
	command     []string
	status      SystemCommandStatus
	exit_status ?int
pub:
	output  []SystemCommandOutputLine
	secrets []string
	verbose bool
}

pub type SystemCommandOutputCallback = fn(SystemCommandOutputType, string)

// system_command_environment lifts the usual all-string environment map into
// the optional-valued source model. Assign `none` directly when a caller needs
// Ruby's environment-unset behavior.
pub fn system_command_environment(values map[string]string) map[string]?string {
	mut environment := map[string]?string{}
	for name, value in values {
		environment[name] = value
	}
	return environment
}

fn system_command_truthy_environment(name string) bool {
	return brew_runtime.environment_value(name).to_lower() in ['1', 'true', 'yes', 'on']
}

fn valid_system_command_environment_name(name string) bool {
	if name == '' {
		return false
	}
	first := name[0]
	if !((first >= `a` && first <= `z`) || (first >= `A` && first <= `Z`) || first == `_`) {
		return false
	}
	for character in name[1..].bytes() {
		if !((character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character == `_`) {
			return false
		}
	}
	return true
}

fn system_command_sensitive_environment_name(name string) bool {
	lower := name.to_lower()
	return lower.contains('cookie') || lower.contains('key') || lower.contains('token') || lower.contains('password') || lower.contains('passphrase') || lower.contains('auth')
}

fn system_command_sensitive_values(environment map[string]?string) []string {
	mut values := []string{}
	for name, maybe_value in environment {
		if system_command_sensitive_environment_name(name) {
			if value := maybe_value {
				if value != '' && value !in values {
					values << value
				}
			}
		}
	}
	return values
}

fn system_command_ambient_sensitive_values() []string {
	mut values := []string{}
	for name, value in brew_runtime.environment() {
		if system_command_sensitive_environment_name(name) && value != '' && value !in values {
			values << value
		}
	}
	return values
}

pub fn new_system_command(executable string, options SystemCommandOptions) !SystemCommand {
	if executable == '' {
		return error('executable cannot be empty')
	}
	if !options.sudo && options.sudo_as_root {
		return error('`sudo_as_root` cannot be set if sudo is false')
	}
	if options.reset_uid && options.run_as_real_uid {
		return error('`reset_uid` and `run_as_real_uid` cannot both be true')
	}
	for name, _ in options.environment {
		if !valid_system_command_environment_name(name) {
			return error('Invalid variable name: ${name}')
		}
	}
	mut secrets := options.secrets.clone()
	for value in system_command_ambient_sensitive_values() {
		if value !in secrets {
			secrets << value
		}
	}
	for value in system_command_sensitive_values(options.environment) {
		if value !in secrets {
			secrets << value
		}
	}
	return SystemCommand{
		executable: executable
		args: options.args.clone()
		sudo: options.sudo
		sudo_as_root: options.sudo_as_root
		environment: options.environment.clone()
		input: options.input.clone()
		must_succeed: options.must_succeed
		print_stdout: options.print_stdout
		print_stderr: options.print_stderr
		debug_override: options.debug
		verbose_override: options.verbose
		secrets: secrets
		chdir: options.chdir
		reset_uid: options.reset_uid
		run_as_real_uid: options.run_as_real_uid
		timeout: options.timeout
		absolute_path_args: options.absolute_path_args.clone()
	}
}

pub fn run_system_command(executable string, options SystemCommandOptions) !SystemCommandResult {
	command := new_system_command(executable, options)!
	return command.run()
}

pub fn run_system_command_or_error(executable string, options SystemCommandOptions) !SystemCommandResult {
	mut command := new_system_command(executable, options)!
	command.must_succeed = true
	return command.run()
}

fn system_command_shell_escape(value string) string {
	if value == '' {
		return "''"
	}
	mut safe := true
	for character in value.bytes() {
		if !((character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character in [
			`_`,
			`-`,
			`.`,
			`/`,
			`:`,
			`+`,
			`=`,
			`,`,
		]) {
			safe = false
			break
		}
	}
	if safe {
		return value
	}
	return "'${value.replace("'", "'\\''")}'"
}

fn redact_system_command_text(text string, secrets []string) string {
	mut redacted := text
	for secret in secrets {
		if secret != '' {
			redacted = redacted.replace(secret, '******')
		}
	}
	return redacted
}

pub fn (command SystemCommand) debug_enabled() bool {
	if value := command.debug_override {
		return value
	}
	return system_command_truthy_environment('HOMEBREW_DEBUG')
}

pub fn (command SystemCommand) verbose_enabled() bool {
	if value := command.verbose_override {
		return value
	}
	return system_command_truthy_environment('HOMEBREW_VERBOSE')
}

pub fn (command SystemCommand) env_args() []string {
	mut names := command.environment.keys()
	names.sort()
	mut arguments := []string{}
	for name in names {
		if value := command.environment[name] {
			arguments << '${system_command_shell_escape(name)}=${system_command_shell_escape(value)}'
		}
	}
	return arguments
}

pub fn (command SystemCommand) homebrew_sudo_user() ?string {
	return brew_runtime.environment_value_opt('HOMEBREW_SUDO_USER')
}

pub fn (command SystemCommand) sudo_prefix() ![]string {
	askpass := if brew_runtime.environment_value('SUDO_ASKPASS') != '' {
		['-A']
	} else {
		[]string{}
	}
	mut user_flags := []string{}
	if system_command_truthy_environment('HOMEBREW_SUDO_THROUGH_SUDO_USER') {
		user := command.homebrew_sudo_user() or {
			return error('`\$HOMEBREW_SUDO_THROUGH_SUDO_USER` set but `\$SUDO_USER` unset!')
		}
		if user.trim_space() == '' {
			return error('`\$HOMEBREW_SUDO_THROUGH_SUDO_USER` set but `\$SUDO_USER` unset!')
		}
		user_flags << ['--prompt', 'Password for %p:', '-u', user]
		user_flags << askpass
		user_flags << ['-E']
		user_flags << command.env_args()
		user_flags << ['--', '/usr/bin/sudo']
	}
	if command.sudo_as_root {
		user_flags << ['-u', 'root']
	}
	mut prefix := ['/usr/bin/sudo']
	prefix << user_flags
	prefix << askpass
	prefix << ['-E']
	prefix << command.env_args()
	prefix << ['--']
	return prefix
}

pub fn (command SystemCommand) env_prefix() []string {
	mut prefix := ['/usr/bin/env']
	prefix << command.env_args()
	return prefix
}

pub fn (command SystemCommand) command_prefix() ![]string {
	return if command.sudo { command.sudo_prefix()! } else { command.env_prefix() }
}

pub fn (command SystemCommand) expanded_args() []string {
	mut expanded := command.args.clone()
	for index in command.absolute_path_args {
		if index >= 0 && index < expanded.len {
			expanded[index] = brew_runtime.absolute_path(expanded[index])
		}
	}
	return expanded
}

pub fn (command SystemCommand) command_line() ![]string {
	mut result := command.command_prefix()!
	result << command.executable
	result << command.expanded_args()
	return result
}

pub fn (command SystemCommand) input_text() string {
	return command.input.join('')
}

fn (command SystemCommand) execution_environment() map[string]string {
	mut environment := brew_runtime.environment()
	for name, maybe_value in command.environment {
		if value := maybe_value {
			environment[name] = value
		} else {
			environment.delete(name)
		}
	}
	return environment
}

pub fn (command SystemCommand) exec3() !SystemCommandExecution {
	argv := command.command_line()!
	captured := brew_runtime.run_captured_command(argv, brew_runtime.CapturedCommandOptions{
		environment: command.execution_environment()
		input: command.input_text()
		chdir: command.chdir
		timeout: command.timeout
		use_pgroup: !command.sudo
	})!
	mut output := []SystemCommandOutputLine{}
	if captured.stdout != '' {
		output << SystemCommandOutputLine{
			kind: .stdout
			line: captured.stdout
		}
	}
	if captured.stderr != '' {
		output << SystemCommandOutputLine{
			kind: .stderr
			line: captured.stderr
		}
	}
	return SystemCommandExecution{
		output: output
		status: SystemCommandStatus{
			exit_code: captured.exit_code
		}
	}
}

pub fn (command SystemCommand) each_output_line(callback SystemCommandOutputCallback) !SystemCommandStatus {
	execution := command.exec3()!
	for line in execution.output {
		callback(line.kind, line.line)
	}
	return execution.status
}

pub fn (command SystemCommand) run() !SystemCommandResult {
	command_line := command.command_line()!
	if command.verbose_enabled() && command.debug_enabled() {
		rendered := command_line.map(system_command_shell_escape(it)).join(' ').replace('\\=', '=')
		eprintln(redact_system_command_text(rendered, command.secrets))
	}
	execution := command.exec3()!
	for item in execution.output {
		redacted := redact_system_command_text(item.line, command.secrets)
		if item.kind == .stdout && (command.print_stdout == .always || (command.print_stdout == .debug && command.debug_enabled())) {
			print(redacted)
		} else if item.kind == .stderr && (command.print_stderr == .always || (command.print_stderr == .debug && command.debug_enabled())) {
			eprint(redacted)
		}
	}
	result := new_system_command_result(command_line, execution.output, execution.status, command.secrets, command.verbose_enabled())
	if command.must_succeed {
		result.assert_success()!
	}
	return result
}

pub fn new_system_command_result(command []string, output []SystemCommandOutputLine,
	status SystemCommandStatus, secrets []string, verbose bool) SystemCommandResult {
	return SystemCommandResult{
		command: command.clone()
		output: output.clone()
		status: status
		exit_status: if status.terminated { none } else { status.exit_code }
		secrets: secrets.clone()
		verbose: verbose
	}
}

pub fn (result SystemCommandResult) assert_success() ! {
	if result.status.success() {
		return
	}
	status := ExecutionStatus{
		has_exitstatus: !result.status.terminated
		exitstatus: result.status.exit_code
		has_termsig: result.status.terminated
		termsig: result.status.term_signal
	}
	output := result.output.map(ExecutionOutputLine{
		kind: it.kind.str()
		line: redact_system_command_text(it.line, result.secrets)
	})
	exception := execution_exception(result.command, status, output, result.secrets)!
	return error(exception.message)
}

pub fn (result SystemCommandResult) stdout_text() string {
	return result.output.filter(it.kind == .stdout).map(it.line).join('')
}

pub fn (result SystemCommandResult) stderr_text() string {
	return result.output.filter(it.kind == .stderr).map(it.line).join('')
}

pub fn (result SystemCommandResult) merged_output_text() string {
	return result.output.map(it.line).join('')
}

pub fn (result SystemCommandResult) success() bool {
	return if status := result.exit_status { status == 0 } else { false }
}

pub fn (result SystemCommandResult) to_tuple() SystemCommandResultTuple {
	return SystemCommandResultTuple{
		stdout: result.stdout_text()
		stderr: result.stderr_text()
		status: result.status
	}
}

fn system_command_xml_unescape(value string) string {
	return value.replace('&lt;', '<').replace('&gt;', '>').replace('&quot;', '"').replace('&apos;', "'").replace('&amp;', '&')
}

fn parse_system_command_plist_values(xml string) map[string]string {
	mut values := map[string]string{}
	mut remaining := xml
	for {
		key_start_relative := remaining.index('<key>') or { break }
		key_content_start := key_start_relative + 5
		key_end_relative := remaining[key_content_start..].index('</key>') or { break }
		key_end := key_content_start + key_end_relative
		key := system_command_xml_unescape(remaining[key_content_start..key_end])
		after_key := remaining[key_end + 6..].trim_space()
		mut value := ''
		if after_key.starts_with('<true/>') {
			value = 'true'
		} else if after_key.starts_with('<false/>') {
			value = 'false'
		} else {
			for tag in ['string', 'integer', 'real', 'date', 'data'] {
				opening := '<${tag}>'
				closing := '</${tag}>'
				if after_key.starts_with(opening) {
					end := after_key[opening.len..].index(closing) or { break }
					value = system_command_xml_unescape(after_key[opening.len..opening.len + end])
					break
				}
			}
		}
		values[key] = value
		remaining = after_key
	}
	return values
}

fn parse_system_command_plist_arrays(xml string) map[string][]map[string]string {
	mut arrays := map[string][]map[string]string{}
	mut remaining := xml
	for {
		key_start := remaining.index('<key>') or { break }
		key_value_start := key_start + 5
		key_end_relative := remaining[key_value_start..].index('</key>') or { break }
		key_end := key_value_start + key_end_relative
		key := system_command_xml_unescape(remaining[key_value_start..key_end])
		after_key := remaining[key_end + 6..].trim_space()
		if after_key.starts_with('<array>') {
			array_end := after_key.index('</array>') or { break }
			array_xml := after_key[7..array_end]
			mut entries := []map[string]string{}
			mut array_remaining := array_xml
			for {
				dict_start := array_remaining.index('<dict>') or { break }
				dict_end_relative := array_remaining[dict_start + 6..].index('</dict>') or { break }
				dict_end := dict_start + 6 + dict_end_relative
				entries << parse_system_command_plist_values(array_remaining[dict_start + 6..dict_end])
				array_remaining = array_remaining[dict_end + 7..]
			}
			arrays[key] = entries
		}
		remaining = after_key
	}
	return arrays
}

pub fn (result SystemCommandResult) plist() ?SystemCommandPlist {
	mut xml := result.stdout_text()
	mut garbage := []string{}
	start := xml.index('<?xml') or { xml.index('<plist') or { return none } }
	if start > 0 {
		prefix := xml[..start]
		if prefix.trim_space() != '' {
			garbage << prefix
			result.warn_plist_garbage(prefix)
		}
		xml = xml[start..]
	}
	closing := '</plist>'
	end_start := xml.last_index(closing) or { return none }
	end := end_start + closing.len
	if end < xml.len {
		suffix := xml[end..]
		if suffix.trim_space() != '' {
			garbage << suffix
			result.warn_plist_garbage(suffix)
		}
		xml = xml[..end]
	}
	return SystemCommandPlist{
		raw_xml: xml
		values: parse_system_command_plist_values(xml)
		arrays: parse_system_command_plist_arrays(xml)
		garbage: garbage
	}
}

pub fn (result SystemCommandResult) warn_plist_garbage(garbage string) ?string {
	if !result.verbose || garbage.trim_space() == '' {
		return none
	}
	warning := 'Received non-XML output from ${result.command[0] or { '' }}:\n${garbage.trim_space()}'
	eprintln(warning)
	return warning
}

// Ruby method `system_command(executable, args: [], sudo: false, sudo_as_root: false, env: {}, input: [],` at line 43.
pub fn ruby_system_command_l43_d1_system_command(executable string, options SystemCommandOptions) !SystemCommandResult {
	return run_system_command(executable, options)
}

// Ruby method `system_command!(executable, args: [], sudo: false, sudo_as_root: false, env: {}, input: [],` at line 72.
pub fn ruby_system_command_l72_d2_system_command(executable string, options SystemCommandOptions) !SystemCommandResult {
	return run_system_command_or_error(executable, options)
}

// Ruby method `self.run(executable, args: [], sudo: false, sudo_as_root: false, env: {}, input: [], must_succeed: false,` at line 102.
pub fn ruby_system_command_l102_d3_self_run(executable string, options SystemCommandOptions) !SystemCommandResult {
	return run_system_command(executable, options)
}

// Ruby method `self.run!(executable, args: [], sudo: false, sudo_as_root: false, env: {}, input: [], must_succeed: true,` at line 129.
pub fn ruby_system_command_l129_d4_self_run(executable string, options SystemCommandOptions) !SystemCommandResult {
	return run_system_command_or_error(executable, options)
}

// Ruby method `run!` at line 137.
pub fn ruby_system_command_l137_d5_run(command SystemCommand) !SystemCommandResult {
	return command.run()
}

// Ruby method `initialize(executable, args: [], sudo: false, sudo_as_root: false, env: {}, input: [], must_succeed: false,` at line 189.
pub fn ruby_system_command_l189_d6_initialize(executable string, options SystemCommandOptions) !SystemCommand {
	return new_system_command(executable, options)
}

// Ruby method `command` at line 228.
pub fn ruby_system_command_l228_d7_command(command SystemCommand) ![]string {
	return command.command_line()
}

// Ruby attr_reader `attr_reader :executable` at line 235.
pub fn ruby_system_command_l235_d8_executable(command SystemCommand) string {
	return command.executable
}

// Ruby attr_reader `attr_reader :args` at line 238.
pub fn ruby_system_command_l238_d9_args(command SystemCommand) []string {
	return command.args.clone()
}

// Ruby attr_reader `attr_reader :input` at line 241.
pub fn ruby_system_command_l241_d10_input(command SystemCommand) []string {
	return command.input.clone()
}

// Ruby attr_reader `attr_reader :chdir` at line 244.
pub fn ruby_system_command_l244_d11_chdir(command SystemCommand) ?string {
	return if command.chdir == '' { none } else { command.chdir }
}

// Ruby attr_reader `attr_reader :env` at line 247.
pub fn ruby_system_command_l247_d12_env(command SystemCommand) map[string]?string {
	return command.environment.clone()
}

// Ruby method `must_succeed? = @must_succeed` at line 250.
pub fn ruby_system_command_l250_d13_must_succeed(command SystemCommand) bool {
	return command.must_succeed
}

// Ruby method `reset_uid? = @reset_uid` at line 253.
pub fn ruby_system_command_l253_d14_reset_uid(command SystemCommand) bool {
	return command.reset_uid
}

// Ruby method `run_as_real_uid? = @run_as_real_uid` at line 256.
pub fn ruby_system_command_l256_d15_run_as_real_uid(command SystemCommand) bool {
	return command.run_as_real_uid
}

// Ruby method `sudo? = @sudo` at line 259.
pub fn ruby_system_command_l259_d16_sudo(command SystemCommand) bool {
	return command.sudo
}

// Ruby method `sudo_as_root? = @sudo_as_root` at line 262.
pub fn ruby_system_command_l262_d17_sudo_as_root(command SystemCommand) bool {
	return command.sudo_as_root
}

// Ruby method `debug?` at line 265.
pub fn ruby_system_command_l265_d18_debug(command SystemCommand) bool {
	return command.debug_enabled()
}

// Ruby method `verbose?` at line 272.
pub fn ruby_system_command_l272_d19_verbose(command SystemCommand) bool {
	return command.verbose_enabled()
}

// Ruby method `env_args` at line 279.
pub fn ruby_system_command_l279_d20_env_args(command SystemCommand) []string {
	return command.env_args()
}

// Ruby method `homebrew_sudo_user` at line 292.
pub fn ruby_system_command_l292_d21_homebrew_sudo_user(command SystemCommand) ?string {
	return command.homebrew_sudo_user()
}

// Ruby method `sudo_prefix` at line 297.
pub fn ruby_system_command_l297_d22_sudo_prefix(command SystemCommand) ![]string {
	return command.sudo_prefix()
}

// Ruby method `env_prefix` at line 315.
pub fn ruby_system_command_l315_d23_env_prefix(command SystemCommand) []string {
	return command.env_prefix()
}

// Ruby method `command_prefix` at line 320.
pub fn ruby_system_command_l320_d24_command_prefix(command SystemCommand) ![]string {
	return command.command_prefix()
}

// Ruby method `expanded_args` at line 325.
pub fn ruby_system_command_l325_d25_expanded_args(command SystemCommand) []string {
	return command.expanded_args()
}

// Ruby method `each_output_line(&block)` at line 339.
pub fn ruby_system_command_l339_d26_each_output_line(command SystemCommand, callback SystemCommandOutputCallback) !SystemCommandStatus {
	return command.each_output_line(callback)
}

// Ruby method `exec3(env, executable, *args, **options)` at line 396.
pub fn ruby_system_command_l396_d27_exec3(command SystemCommand) !SystemCommandExecution {
	return command.exec3()
}

// Ruby method `write_input_to(raw_stdin)` at line 449.
pub fn ruby_system_command_l449_d28_write_input_to(command SystemCommand) string {
	return command.input_text()
}

// Ruby method `each_line_from(sources, &_block)` at line 454.
pub fn ruby_system_command_l454_d29_each_line_from(lines []SystemCommandOutputLine, callback SystemCommandOutputCallback) {
	for line in lines {
		callback(line.kind, line.line)
	}
}

// Ruby attr_accessor `attr_accessor :command` at line 497.
pub fn ruby_system_command_l497_d30_command(result SystemCommandResult) []string {
	return result.command.clone()
}

// Ruby attr_accessor `attr_accessor :command` at line 497.
pub fn ruby_system_command_l497_d31_command(mut result SystemCommandResult, command []string) []string {
	result.command = command.clone()
	return command
}

// Ruby attr_accessor `attr_accessor :status` at line 500.
pub fn ruby_system_command_l500_d32_status(result SystemCommandResult) SystemCommandStatus {
	return result.status
}

// Ruby attr_accessor `attr_accessor :status` at line 500.
pub fn ruby_system_command_l500_d33_status(mut result SystemCommandResult, status SystemCommandStatus) SystemCommandStatus {
	result.status = status
	return status
}

// Ruby attr_accessor `attr_accessor :exit_status` at line 503.
pub fn ruby_system_command_l503_d34_exit_status(result SystemCommandResult) ?int {
	return result.exit_status
}

// Ruby attr_accessor `attr_accessor :exit_status` at line 503.
pub fn ruby_system_command_l503_d35_exit_status(mut result SystemCommandResult, status ?int) ?int {
	result.exit_status = status
	return status
}

// Ruby method `initialize(command, output, status, secrets:)` at line 513.
pub fn ruby_system_command_l513_d36_initialize(command []string, output []SystemCommandOutputLine, status SystemCommandStatus, secrets []string) SystemCommandResult {
	return new_system_command_result(command, output, status, secrets, false)
}

// Ruby method `assert_success!` at line 522.
pub fn ruby_system_command_l522_d37_assert_success(result SystemCommandResult) ! {
	result.assert_success()!
}

// Ruby method `stdout` at line 529.
pub fn ruby_system_command_l529_d38_stdout(result SystemCommandResult) string {
	return result.stdout_text()
}

// Ruby method `stderr` at line 536.
pub fn ruby_system_command_l536_d39_stderr(result SystemCommandResult) string {
	return result.stderr_text()
}

// Ruby method `merged_output` at line 543.
pub fn ruby_system_command_l543_d40_merged_output(result SystemCommandResult) string {
	return result.merged_output_text()
}

// Ruby method `success?` at line 548.
pub fn ruby_system_command_l548_d41_success(result SystemCommandResult) bool {
	return result.success()
}

// Ruby method `to_ary` at line 555.
pub fn ruby_system_command_l555_d42_to_ary(result SystemCommandResult) SystemCommandResultTuple {
	return result.to_tuple()
}

// Ruby alias `alias to_a to_ary` at line 558.
pub fn ruby_system_command_l558_d43_to_a(result SystemCommandResult) SystemCommandResultTuple {
	return result.to_tuple()
}

// Ruby method `plist` at line 561.
pub fn ruby_system_command_l561_d44_plist(result SystemCommandResult) ?SystemCommandPlist {
	return result.plist()
}

// Ruby method `warn_plist_garbage(garbage)` at line 581.
pub fn ruby_system_command_l581_d45_warn_plist_garbage(result SystemCommandResult, garbage string) ?string {
	return result.warn_plist_garbage(garbage)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "shellwords"
// 5: require "stringio"
// 6:
// 7: require "context"
// 8: require "readline_nonblock"
// 9: require "utils/timer"
// 10: require "utils/output"
// 11:
// 12: # Class for running sub-processes and capturing their output and exit status.
// 13: #
// 14: # @api internal
// 15: class SystemCommand
// 16:   # Helper functions for calling {SystemCommand.run}.
// 17:   #
// 18:   # @api internal
// 19:   module Mixin
// 20:     # Run a fallible system command.
// 21:     #
// 22:     # @api internal
// 23:     sig {
// 24:       params(
// 25:         executable:      T.any(String, Pathname),
// 26:         args:            T::Array[T.any(String, Integer, Float, Pathname)],
// 27:         sudo:            T::Boolean,
// 28:         sudo_as_root:    T::Boolean,
// 29:         env:             T::Hash[String, T.nilable(T.any(String, T::Boolean, PATH))],
// 30:         input:           T.any(String, T::Array[String]),
// 31:         must_succeed:    T::Boolean,
// 32:         print_stdout:    T.any(T::Boolean, Symbol),
// 33:         print_stderr:    T.any(T::Boolean, Symbol),
// 34:         debug:           T.nilable(T::Boolean),
// 35:         verbose:         T.nilable(T::Boolean),
// 36:         secrets:         T.any(String, T::Array[String]),
// 37:         chdir:           T.any(String, Pathname),
// 38:         reset_uid:       T::Boolean,
// 39:         run_as_real_uid: T::Boolean,
// 40:         timeout:         T.nilable(T.any(Integer, Float)),
// 41:       ).returns(SystemCommand::Result)
// 42:     }
// 43:     def system_command(executable, args: [], sudo: false, sudo_as_root: false, env: {}, input: [],
// 44:                        must_succeed: false, print_stdout: false, print_stderr: true, debug: nil, verbose: nil,
// 45:                        secrets: [], chdir: T.unsafe(nil), reset_uid: false, run_as_real_uid: false, timeout: nil)
// 46:       SystemCommand.run(executable, args:, sudo:, sudo_as_root:, env:, input:, must_succeed:, print_stdout:,
// 47:                         print_stderr:, debug:, verbose:, secrets:, chdir:, reset_uid:, run_as_real_uid:, timeout:)
// 48:     end
// 49:
// 50:     # Run an infallible system command.
// 51:     #
// 52:     # @api internal
// 53:     sig {
// 54:       params(
// 55:         executable:      T.any(String, Pathname),
// 56:         args:            T::Array[T.any(String, Integer, Float, Pathname)],
// 57:         sudo:            T::Boolean,
// 58:         sudo_as_root:    T::Boolean,
// 59:         env:             T::Hash[String, T.nilable(T.any(String, T::Boolean, PATH))],
// 60:         input:           T.any(String, T::Array[String]),
// 61:         print_stdout:    T.any(T::Boolean, Symbol),
// 62:         print_stderr:    T.any(T::Boolean, Symbol),
// 63:         debug:           T.nilable(T::Boolean),
// 64:         verbose:         T.nilable(T::Boolean),
// 65:         secrets:         T.any(String, T::Array[String]),
// 66:         chdir:           T.any(String, Pathname),
// 67:         reset_uid:       T::Boolean,
// 68:         run_as_real_uid: T::Boolean,
// 69:         timeout:         T.nilable(T.any(Integer, Float)),
// 70:       ).returns(SystemCommand::Result)
// 71:     }
// 72:     def system_command!(executable, args: [], sudo: false, sudo_as_root: false, env: {}, input: [],
// 73:                         print_stdout: false, print_stderr: true, debug: nil, verbose: nil, secrets: [],
// 74:                         chdir: T.unsafe(nil), reset_uid: false, run_as_real_uid: false, timeout: nil)
// 75:       SystemCommand.run!(executable, args:, sudo:, sudo_as_root:, env:, input:, print_stdout:,
// 76:                          print_stderr:, debug:, verbose:, secrets:, chdir:, reset_uid:, run_as_real_uid:, timeout:)
// 77:     end
// 78:   end
// 79:
// 80:   include Context
// 81:
// 82:   sig {
// 83:     params(
// 84:       executable:      T.any(String, Pathname),
// 85:       args:            T::Array[T.any(String, Integer, Float, Pathname)],
// 86:       sudo:            T::Boolean,
// 87:       sudo_as_root:    T::Boolean,
// 88:       env:             T::Hash[String, T.nilable(T.any(String, T::Boolean, PATH))],
// 89:       input:           T.any(String, T::Array[String]),
// 90:       must_succeed:    T::Boolean,
// 91:       print_stdout:    T.any(T::Boolean, Symbol),
// 92:       print_stderr:    T.any(T::Boolean, Symbol),
// 93:       debug:           T.nilable(T::Boolean),
// 94:       verbose:         T.nilable(T::Boolean),
// 95:       secrets:         T.any(String, T::Array[String]),
// 96:       chdir:           T.nilable(T.any(String, Pathname)),
// 97:       reset_uid:       T::Boolean,
// 98:       run_as_real_uid: T::Boolean,
// 99:       timeout:         T.nilable(T.any(Integer, Float)),
// 100:     ).returns(SystemCommand::Result)
// 101:   }
// 102:   def self.run(executable, args: [], sudo: false, sudo_as_root: false, env: {}, input: [], must_succeed: false,
// 103:                print_stdout: false, print_stderr: true, debug: nil, verbose: nil, secrets: [], chdir: nil,
// 104:                reset_uid: false, run_as_real_uid: false, timeout: nil)
// 105:     new(executable, args:, sudo:, sudo_as_root:, env:, input:, must_succeed:, print_stdout:, print_stderr:, debug:,
// 106:         verbose:, secrets:, chdir:, reset_uid:, run_as_real_uid:, timeout:).run!
// 107:   end
// 108:
// 109:   sig {
// 110:     params(
// 111:       executable:      T.any(String, Pathname),
// 112:       args:            T::Array[T.any(String, Integer, Float, Pathname)],
// 113:       sudo:            T::Boolean,
// 114:       sudo_as_root:    T::Boolean,
// 115:       env:             T::Hash[String, T.nilable(T.any(String, T::Boolean, PATH))],
// 116:       input:           T.any(String, T::Array[String]),
// 117:       must_succeed:    T::Boolean,
// 118:       print_stdout:    T.any(T::Boolean, Symbol),
// 119:       print_stderr:    T.any(T::Boolean, Symbol),
// 120:       debug:           T.nilable(T::Boolean),
// 121:       verbose:         T.nilable(T::Boolean),
// 122:       secrets:         T.any(String, T::Array[String]),
// 123:       chdir:           T.nilable(T.any(String, Pathname)),
// 124:       reset_uid:       T::Boolean,
// 125:       run_as_real_uid: T::Boolean,
// 126:       timeout:         T.nilable(T.any(Integer, Float)),
// 127:     ).returns(SystemCommand::Result)
// 128:   }
// 129:   def self.run!(executable, args: [], sudo: false, sudo_as_root: false, env: {}, input: [], must_succeed: true,
// 130:                 print_stdout: false, print_stderr: true, debug: nil, verbose: nil, secrets: [], chdir: nil,
// 131:                 reset_uid: false, run_as_real_uid: false, timeout: nil)
// 132:     run(executable, args:, sudo:, sudo_as_root:, env:, input:, must_succeed:, print_stdout:, print_stderr:,
// 133:         debug:, verbose:, secrets:, chdir:, reset_uid:, run_as_real_uid:, timeout:)
// 134:   end
// 135:
// 136:   sig { returns(SystemCommand::Result) }
// 137:   def run!
// 138:     $stderr.puts Formatter.redact_secrets(command.shelljoin.gsub('\=', "="), @secrets) if verbose? && debug?
// 139:
// 140:     @output = T.let([], T.nilable(T::Array[[Symbol, String]]))
// 141:     @output = T.must(@output)
// 142:
// 143:     each_output_line do |type, line|
// 144:       case type
// 145:       when :stdout
// 146:         case @print_stdout
// 147:         when true
// 148:           $stdout << Formatter.redact_secrets(line, @secrets)
// 149:         when :debug
// 150:           $stderr << Formatter.redact_secrets(line, @secrets) if debug?
// 151:         end
// 152:         @output << [:stdout, line]
// 153:       when :stderr
// 154:         case @print_stderr
// 155:         when true
// 156:           $stderr << Formatter.redact_secrets(line, @secrets)
// 157:         when :debug
// 158:           $stderr << Formatter.redact_secrets(line, @secrets) if debug?
// 159:         end
// 160:         @output << [:stderr, line]
// 161:       end
// 162:     end
// 163:
// 164:     result = Result.new(command, @output, T.must(@status), secrets: @secrets)
// 165:     result.assert_success! if must_succeed?
// 166:     result
// 167:   end
// 168:
// 169:   sig {
// 170:     params(
// 171:       executable:      T.any(String, Pathname),
// 172:       args:            T::Array[T.any(String, Integer, Float, Pathname)],
// 173:       sudo:            T::Boolean,
// 174:       sudo_as_root:    T::Boolean,
// 175:       env:             T::Hash[String, T.nilable(T.any(String, T::Boolean, PATH))],
// 176:       input:           T.any(String, T::Array[String]),
// 177:       must_succeed:    T::Boolean,
// 178:       print_stdout:    T.any(T::Boolean, Symbol),
// 179:       print_stderr:    T.any(T::Boolean, Symbol),
// 180:       debug:           T.nilable(T::Boolean),
// 181:       verbose:         T.nilable(T::Boolean),
// 182:       secrets:         T.any(String, T::Array[String]),
// 183:       chdir:           T.nilable(T.any(String, Pathname)),
// 184:       reset_uid:       T::Boolean,
// 185:       run_as_real_uid: T::Boolean,
// 186:       timeout:         T.nilable(T.any(Integer, Float)),
// 187:     ).void
// 188:   }
// 189:   def initialize(executable, args: [], sudo: false, sudo_as_root: false, env: {}, input: [], must_succeed: false,
// 190:                  print_stdout: false, print_stderr: true, debug: nil, verbose: nil, secrets: [], chdir: nil,
// 191:                  reset_uid: false, run_as_real_uid: false, timeout: nil)
// 192:     require "extend/ENV"
// 193:     @executable = executable
// 194:     @args = args
// 195:
// 196:     raise ArgumentError, "`sudo_as_root` cannot be set if sudo is false" if !sudo && sudo_as_root
// 197:     raise ArgumentError, "`reset_uid` and `run_as_real_uid` cannot both be true" if reset_uid && run_as_real_uid
// 198:
// 199:     if print_stdout.is_a?(Symbol) && print_stdout != :debug
// 200:       raise ArgumentError, "`print_stdout` is not a valid symbol"
// 201:     end
// 202:     if print_stderr.is_a?(Symbol) && print_stderr != :debug
// 203:       raise ArgumentError, "`print_stderr` is not a valid symbol"
// 204:     end
// 205:
// 206:     @sudo = sudo
// 207:     @sudo_as_root = sudo_as_root
// 208:     env.each_key do |name|
// 209:       next if /^[\w&&\D]\w*$/.match?(name)
// 210:
// 211:       raise ArgumentError, "Invalid variable name: #{name}"
// 212:     end
// 213:     @env = env
// 214:     @input = T.let(Array(input), T::Array[String])
// 215:     @must_succeed = must_succeed
// 216:     @print_stdout = print_stdout
// 217:     @print_stderr = print_stderr
// 218:     @debug = debug
// 219:     @verbose = verbose
// 220:     @secrets = T.let((Array(secrets) + ENV.sensitive_environment.values).uniq, T::Array[String])
// 221:     @chdir = chdir
// 222:     @reset_uid = reset_uid
// 223:     @run_as_real_uid = run_as_real_uid
// 224:     @timeout = timeout
// 225:   end
// 226:
// 227:   sig { returns(T::Array[String]) }
// 228:   def command
// 229:     [*command_prefix, executable.to_s, *expanded_args]
// 230:   end
// 231:
// 232:   private
// 233:
// 234:   sig { returns(T.any(Pathname, String)) }
// 235:   attr_reader :executable
// 236:
// 237:   sig { returns(T::Array[T.any(String, Integer, Float, Pathname)]) }
// 238:   attr_reader :args
// 239:
// 240:   sig { returns(T::Array[String]) }
// 241:   attr_reader :input
// 242:
// 243:   sig { returns(T.nilable(T.any(String, Pathname))) }
// 244:   attr_reader :chdir
// 245:
// 246:   sig { returns(T::Hash[String, T.nilable(T.any(String, T::Boolean, PATH))]) }
// 247:   attr_reader :env
// 248:
// 249:   sig { returns(T::Boolean) }
// 250:   def must_succeed? = @must_succeed
// 251:
// 252:   sig { returns(T::Boolean) }
// 253:   def reset_uid? = @reset_uid
// 254:
// 255:   sig { returns(T::Boolean) }
// 256:   def run_as_real_uid? = @run_as_real_uid
// 257:
// 258:   sig { returns(T::Boolean) }
// 259:   def sudo? = @sudo
// 260:
// 261:   sig { returns(T::Boolean) }
// 262:   def sudo_as_root? = @sudo_as_root
// 263:
// 264:   sig { returns(T::Boolean) }
// 265:   def debug?
// 266:     return super if @debug.nil?
// 267:
// 268:     @debug
// 269:   end
// 270:
// 271:   sig { returns(T::Boolean) }
// 272:   def verbose?
// 273:     return super if @verbose.nil?
// 274:
// 275:     @verbose
// 276:   end
// 277:
// 278:   sig { returns(T::Array[String]) }
// 279:   def env_args
// 280:     set_variables = env.compact.map do |name, value|
// 281:       sanitized_name = Shellwords.escape(name)
// 282:       sanitized_value = Shellwords.escape(value)
// 283:       "#{sanitized_name}=#{sanitized_value}"
// 284:     end
// 285:
// 286:     return [] if set_variables.empty?
// 287:
// 288:     set_variables
// 289:   end
// 290:
// 291:   sig { returns(T.nilable(String)) }
// 292:   def homebrew_sudo_user
// 293:     ENV.fetch("HOMEBREW_SUDO_USER", nil)
// 294:   end
// 295:
// 296:   sig { returns(T::Array[String]) }
// 297:   def sudo_prefix
// 298:     askpass_flags = ENV.key?("SUDO_ASKPASS") ? ["-A"] : []
// 299:     user_flags = []
// 300:     if Homebrew::EnvConfig.sudo_through_sudo_user?
// 301:       if homebrew_sudo_user.blank?
// 302:         raise ArgumentError, "`$HOMEBREW_SUDO_THROUGH_SUDO_USER` set but `$SUDO_USER` unset!"
// 303:       end
// 304:
// 305:       user_flags += ["--prompt", "Password for %p:", "-u", homebrew_sudo_user,
// 306:                      *askpass_flags,
// 307:                      "-E", *env_args,
// 308:                      "--", "/usr/bin/sudo"]
// 309:     end
// 310:     user_flags += ["-u", "root"] if sudo_as_root?
// 311:     ["/usr/bin/sudo", *user_flags, *askpass_flags, "-E", *env_args, "--"]
// 312:   end
// 313:
// 314:   sig { returns(T::Array[String]) }
// 315:   def env_prefix
// 316:     ["/usr/bin/env", *env_args]
// 317:   end
// 318:
// 319:   sig { returns(T::Array[String]) }
// 320:   def command_prefix
// 321:     sudo? ? sudo_prefix : env_prefix
// 322:   end
// 323:
// 324:   sig { returns(T::Array[String]) }
// 325:   def expanded_args
// 326:     @expanded_args ||= T.let(args.map do |arg|
// 327:       if arg.is_a?(Pathname)
// 328:         File.absolute_path(arg)
// 329:       else
// 330:         arg.to_s
// 331:       end
// 332:     end, T.nilable(T::Array[String]))
// 333:   end
// 334:
// 335:   class ProcessTerminatedInterrupt < StandardError; end
// 336:   private_constant :ProcessTerminatedInterrupt
// 337:
// 338:   sig { params(block: T.proc.params(type: Symbol, line: String).void).void }
// 339:   def each_output_line(&block)
// 340:     executable, *args = command
// 341:     options = {
// 342:       # Create a new process group so that we can send `SIGINT` from
// 343:       # parent to child rather than the child receiving `SIGINT` directly.
// 344:       pgroup: sudo? ? nil : true,
// 345:     }
// 346:     options[:chdir] = chdir if chdir
// 347:
// 348:     raw_stdin, raw_stdout, raw_stderr, raw_wait_thr = exec3(env, executable, *args, **options)
// 349:
// 350:     write_input_to(raw_stdin)
// 351:     raw_stdin.close_write
// 352:
// 353:     thread_context = Context.current
// 354:     thread_ready_queue = Queue.new
// 355:     thread_done_queue = Queue.new
// 356:     line_thread = Thread.new do
// 357:       # Ensure the new thread inherits the current context.
// 358:       Thread.current[:context] = thread_context
// 359:
// 360:       Thread.handle_interrupt(ProcessTerminatedInterrupt => :never) do
// 361:         thread_ready_queue << true
// 362:         each_line_from [raw_stdout, raw_stderr], &block
// 363:       end
// 364:       thread_done_queue.pop
// 365:     rescue ProcessTerminatedInterrupt
// 366:       nil
// 367:     end
// 368:
// 369:     end_time = Time.now + @timeout if @timeout
// 370:     raise Timeout::Error if raw_wait_thr.join(Utils::Timer.remaining(end_time)).nil?
// 371:
// 372:     @status = T.let(raw_wait_thr.value, T.nilable(Process::Status))
// 373:   rescue Interrupt
// 374:     Process.kill("INT", raw_wait_thr.pid) if raw_wait_thr && !sudo?
// 375:     raise Interrupt
// 376:   ensure
// 377:     if line_thread
// 378:       thread_ready_queue.pop
// 379:       line_thread.raise ProcessTerminatedInterrupt.new
// 380:       thread_done_queue << true
// 381:       line_thread.join
// 382:     end
// 383:     raw_stdin&.close
// 384:     raw_stdout&.close
// 385:     raw_stderr&.close
// 386:   end
// 387:
// 388:   sig {
// 389:     params(
// 390:       env:        T::Hash[String, T.nilable(T.any(String, T::Boolean, PATH))],
// 391:       executable: String,
// 392:       args:       String,
// 393:       options:    T.untyped,
// 394:     ).returns([IO, IO, IO, Thread])
// 395:   }
// 396:   def exec3(env, executable, *args, **options)
// 397:     in_r, in_w = IO.pipe
// 398:     options[:in] = in_r
// 399:     in_w.sync = true
// 400:
// 401:     out_r, out_w = IO.pipe
// 402:     options[:out] = out_w
// 403:
// 404:     err_r, err_w = IO.pipe
// 405:     options[:err] = err_w
// 406:
// 407:     exec_env = env.merge({ "COLUMNS" => Tty.width.to_s })
// 408:
// 409:     # `Process.spawn` avoids running `malloc` in a `fork`ed child, which is not
// 410:     # fork-safe on macOS and can abort it. `fork` is kept for privilege changes
// 411:     # and as a fallback.
// 412:     pid = if (run_as_real_uid? || reset_uid?) && Process.euid != Process.uid
// 413:       nil
// 414:     else
// 415:       begin
// 416:         Process.spawn(exec_env, [executable, executable], *args, **options)
// 417:       rescue SystemCallError
// 418:         nil
// 419:       end
// 420:     end
// 421:
// 422:     pid ||= fork do
// 423:       if run_as_real_uid? && Process.euid != Process.uid
// 424:         Process::UID.change_privilege(Process.uid)
// 425:       elsif reset_uid? && Process.euid != Process.uid
// 426:         Process::UID.change_privilege(Process.euid)
// 427:       end
// 428:
// 429:       exec(exec_env, [executable, executable], *args, **options)
// 430:     rescue SystemCallError => e
// 431:       $stderr.puts(e.message)
// 432:       exit!(127)
// 433:     end
// 434:     wait_thr = Process.detach(pid)
// 435:
// 436:     [in_w, out_r, err_r, wait_thr]
// 437:   rescue
// 438:     in_w&.close
// 439:     out_r&.close
// 440:     err_r&.close
// 441:     raise
// 442:   ensure
// 443:     in_r&.close
// 444:     out_w&.close
// 445:     err_w&.close
// 446:   end
// 447:
// 448:   sig { params(raw_stdin: IO).void }
// 449:   def write_input_to(raw_stdin)
// 450:     input.each { raw_stdin.write(it) }
// 451:   end
// 452:
// 453:   sig { params(sources: T::Array[IO], _block: T.proc.params(type: Symbol, line: String).void).void }
// 454:   def each_line_from(sources, &_block)
// 455:     sources = {
// 456:       sources[0] => :stdout,
// 457:       sources[1] => :stderr,
// 458:     }
// 459:     readers = T.let({}, T::Hash[IO, ReadlineNonblock])
// 460:
// 461:     pending_interrupt = T.let(false, T::Boolean)
// 462:
// 463:     until pending_interrupt || sources.empty?
// 464:       readable_sources = T.let([], T::Array[IO])
// 465:       begin
// 466:         Thread.handle_interrupt(ProcessTerminatedInterrupt => :on_blocking) do
// 467:           readable_sources = T.must(IO.select(sources.keys)).fetch(0)
// 468:         end
// 469:       rescue ProcessTerminatedInterrupt
// 470:         readable_sources = sources.keys
// 471:         pending_interrupt = true
// 472:       end
// 473:
// 474:       readable_sources.each do |source|
// 475:         reader = readers[source] ||= ReadlineNonblock.new(source)
// 476:         loop do
// 477:           line = reader.read
// 478:           yield(sources.fetch(source), line)
// 479:         end
// 480:       rescue EOFError
// 481:         source.close_read
// 482:         sources.delete(source)
// 483:       rescue IO::WaitReadable
// 484:         # We've got all the data that was ready, but the other end of the stream isn't finished yet
// 485:       end
// 486:     end
// 487:
// 488:     sources.each_key(&:close_read)
// 489:   end
// 490:
// 491:   # Result containing the output and exit status of a finished sub-process.
// 492:   class Result
// 493:     include Context
// 494:     include Utils::Output::Mixin
// 495:
// 496:     sig { returns(T::Array[String]) }
// 497:     attr_accessor :command
// 498:
// 499:     sig { returns(Process::Status) }
// 500:     attr_accessor :status
// 501:
// 502:     sig { returns(T.nilable(Integer)) }
// 503:     attr_accessor :exit_status
// 504:
// 505:     sig {
// 506:       params(
// 507:         command: T::Array[String],
// 508:         output:  T::Array[[T.any(String, Symbol), String]],
// 509:         status:  Process::Status,
// 510:         secrets: T::Array[String],
// 511:       ).void
// 512:     }
// 513:     def initialize(command, output, status, secrets:)
// 514:       @command       = command
// 515:       @output        = output
// 516:       @status        = status
// 517:       @exit_status   = T.let(status.exitstatus, T.nilable(Integer))
// 518:       @secrets       = secrets
// 519:     end
// 520:
// 521:     sig { void }
// 522:     def assert_success!
// 523:       return if @status.success?
// 524:
// 525:       raise ErrorDuringExecution.new(command, status: @status, output: @output, secrets: @secrets)
// 526:     end
// 527:
// 528:     sig { returns(String) }
// 529:     def stdout
// 530:       @stdout ||= T.let(@output.select { |type,| type == :stdout }
// 531:                                .map { |_, line| line }
// 532:                                .join, T.nilable(String))
// 533:     end
// 534:
// 535:     sig { returns(String) }
// 536:     def stderr
// 537:       @stderr ||= T.let(@output.select { |type,| type == :stderr }
// 538:                                .map { |_, line| line }
// 539:                                .join, T.nilable(String))
// 540:     end
// 541:
// 542:     sig { returns(String) }
// 543:     def merged_output
// 544:       @merged_output ||= T.let(@output.map { |_, line| line }.join, T.nilable(String))
// 545:     end
// 546:
// 547:     sig { returns(T::Boolean) }
// 548:     def success?
// 549:       return false if @exit_status.nil?
// 550:
// 551:       @exit_status.zero?
// 552:     end
// 553:
// 554:     sig { returns([String, String, Process::Status]) }
// 555:     def to_ary
// 556:       [stdout, stderr, status]
// 557:     end
// 558:     alias to_a to_ary
// 559:
// 560:     sig { returns(T.untyped) }
// 561:     def plist
// 562:       require "plist"
// 563:       @plist ||= T.let(begin
// 564:         output = stdout
// 565:
// 566:         output = output.sub(/\A(.*?)(\s*<\?\s*xml)/m) do
// 567:           warn_plist_garbage(T.must(Regexp.last_match(1)))
// 568:           Regexp.last_match(2)
// 569:         end
// 570:
// 571:         output = output.sub(%r{(<\s*/\s*plist\s*>\s*)(.*?)\Z}m) do
// 572:           warn_plist_garbage(T.must(Regexp.last_match(2)))
// 573:           Regexp.last_match(1)
// 574:         end
// 575:
// 576:         Plist.parse_xml(output, marshal: false)
// 577:       end, T.untyped)
// 578:     end
// 579:
// 580:     sig { params(garbage: String).void }
// 581:     def warn_plist_garbage(garbage)
// 582:       return unless verbose?
// 583:       return unless garbage.match?(/\S/)
// 584:
// 585:       opoo "Received non-XML output from #{Formatter.identifier(command.first)}:"
// 586:       $stderr.puts garbage.strip
// 587:     end
// 588:     private :warn_plist_garbage
// 589:   end
// 590: end
