module homebrew

import ruby
import time

// Translated from Homebrew/brew `system_command.rb`.
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

pub type SystemCommandOutputCallback = fn (SystemCommandOutputType, string)

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
	return ruby.environment_value(name).to_lower() in ['1', 'true', 'yes', 'on']
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
	for name, value in ruby.environment() {
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
	return ruby.environment_value_opt('HOMEBREW_SUDO_USER')
}

pub fn (command SystemCommand) sudo_prefix() ![]string {
	askpass := if ruby.environment_value('SUDO_ASKPASS') != '' {
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
			expanded[index] = ruby.absolute_path(expanded[index])
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
	mut environment := ruby.environment()
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
	captured := ruby.run_captured_command(argv, ruby.CapturedCommandOptions{
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
