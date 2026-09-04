module utils

import ruby
import os

// Translated from Homebrew/brew `utils/popen.rb`.
pub enum PopenMode {
	read_binary
	read_write_binary
}

pub enum PopenStderr {
	discard
	capture
	stdout
	inherit
}

pub struct PopenOptions {
pub:
	environment map[string]string
	input       string
	chdir       string
	stderr      PopenStderr
}

pub struct PopenResult {
pub:
	argv      []string
	mode      PopenMode
	exit_code int
	stdout    string
	stderr    string
}

pub fn (result PopenResult) success() bool {
	return result.exit_code == 0
}

pub struct PopenExecutionError {
pub:
	result PopenResult
}

pub fn (execution_error PopenExecutionError) msg() string {
	mut message := 'Failure while executing: ${execution_error.result.argv.join(' ')} (exit status ${execution_error.result.exit_code})'
	if execution_error.result.stdout != '' {
		message += '\n${execution_error.result.stdout}'
	}
	return message
}

pub fn (execution_error PopenExecutionError) code() int {
	return execution_error.result.exit_code
}

pub fn popen_mode(mode string) !PopenMode {
	return match mode {
		'rb', 'r' { .read_binary }
		'w+b', 'r+b', 'w+' { .read_write_binary }
		else { error('unsupported popen mode: ${mode}') }
	}
}

fn popen_environment(overrides map[string]string) map[string]string {
	mut environment := ruby.environment()
	for name, value in overrides {
		environment[name] = value
	}
	return environment
}

fn popen_command_path(command string, environment map[string]string, chdir string) ?string {
	if command.contains(os.path_separator) {
		candidate := if os.is_abs_path(command) {
			command
		} else if chdir != '' {
			os.join_path(chdir, command)
		} else {
			os.join_path(os.getwd(), command)
		}
		if os.is_file(candidate) && os.is_executable(candidate) {
			return candidate
		}
		return none
	}
	for directory in (environment['PATH'] or { '' }).split(os.path_delimiter) {
		if directory == '' {
			continue
		}
		candidate := os.join_path(directory, command)
		if os.is_file(candidate) && os.is_executable(candidate) {
			return candidate
		}
	}
	return none
}

fn missing_popen_result(argv []string, mode PopenMode, stderr_mode PopenStderr) PopenResult {
	message := 'brew: command not found: ${argv[0]}\n'
	return PopenResult{
		argv: argv.clone()
		mode: mode
		exit_code: 127
		stdout: if stderr_mode == .stdout { message } else { '' }
		stderr: if stderr_mode in [.capture, .inherit] { message } else { '' }
	}
}

pub fn popen(argv []string, mode PopenMode, options PopenOptions) !PopenResult {
	if argv.len == 0 || argv[0] == '' {
		return error('command cannot be empty')
	}
	environment := popen_environment(options.environment)
	if _ := popen_command_path(argv[0], environment, options.chdir) {
		// Resolution is only a source-faithful ENOENT check. Keep the caller's
		// original argv so relative executable paths and argv[0] are unchanged.
	} else {
		result := missing_popen_result(argv, mode, options.stderr)
		if options.stderr == .inherit {
			eprint(result.stderr)
		}
		return result
	}
	captured := ruby.run_captured_command(argv, ruby.CapturedCommandOptions{
		environment: environment
		input: options.input
		chdir: options.chdir
	})!
	mut standard_output := captured.stdout
	mut standard_error := captured.stderr
	match options.stderr {
		.discard {
			standard_error = ''
		}
		.stdout {
			standard_output += standard_error
			standard_error = ''
		}
		.inherit {
			eprint(standard_error)
		}
		.capture {}
	}
	return PopenResult{
		argv: argv.clone()
		mode: mode
		exit_code: captured.exit_code
		stdout: standard_output
		stderr: standard_error
	}
}

pub fn popen_read(argv []string, options PopenOptions) !PopenResult {
	return popen(argv, .read_binary, options)
}

pub fn safe_popen_read(argv []string, options PopenOptions) !string {
	result := popen_read(argv, options)!
	if !result.success() {
		return PopenExecutionError{
			result: result
		}
	}
	return result.stdout
}

pub fn popen_write(argv []string, input string, options PopenOptions) !PopenResult {
	return popen(argv, .read_write_binary, PopenOptions{
		...options
		input: input
	})
}

pub fn safe_popen_write(argv []string, input string, options PopenOptions) !string {
	result := popen_write(argv, input, options)!
	if !result.success() {
		return PopenExecutionError{
			result: result
		}
	}
	return result.stdout
}

pub fn popen_options_value(options PopenOptions, safe bool) ruby.Value {
	return ruby.structured_value('Utils::PopenOptions', options.input, {
		'input':  options.input
		'chdir':  options.chdir
		'stderr': options.stderr.str()
		'safe':   safe.str()
	})
}

fn popen_options_from_value(value ruby.Value) PopenOptions {
	stderr := match value.attributes['stderr'] or { '' } {
		'capture' { PopenStderr.capture }
		'stdout', 'out' { PopenStderr.stdout }
		'inherit', 'err' { PopenStderr.inherit }
		else { PopenStderr.discard }
	}
	return PopenOptions{
		input: value.attributes['input'] or { '' }
		chdir: value.attributes['chdir'] or { '' }
		stderr: stderr
	}
}

struct PopenBoundaryRequest {
	argv    []string
	options PopenOptions
	safe    bool
}

fn popen_boundary_request(args []ruby.Value) PopenBoundaryRequest {
	mut argv := []string{}
	mut environment := map[string]string{}
	mut options := PopenOptions{}
	mut safe := false
	for argument in args {
		if argument.type_name == 'Utils::PopenOptions' {
			options = popen_options_from_value(argument)
			safe = (argument.attributes['safe'] or { 'false' }) == 'true'
		} else if argument.type_name == 'Hash' {
			for name, value in argument.as_map() or { map[string]ruby.Value{} } {
				environment[name] = value.as_string()
			}
		} else if argument.type_name == 'Array' {
			argv << argument.as_array() or { [] }.map(it.as_string())
		} else {
			argv << argument.as_string()
		}
	}
	options = PopenOptions{
		...options
		environment: environment
	}
	return PopenBoundaryRequest{
		argv: argv
		options: options
		safe: safe
	}
}

fn popen_execution_error_value(execution_error IError) ruby.Value {
	return ruby.structured_value('ErrorDuringExecution', execution_error.msg(), {
		'exit_code': execution_error.code().str()
	})
}
