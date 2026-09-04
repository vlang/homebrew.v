module utils

import ruby
import os

// Translated from Homebrew/brew `utils/popen.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `self.popen_read(*args, safe: false, **options, &block)` at line 17.
pub fn ruby_popen_l17_d1_self_popen_read(args ...ruby.Value) ruby.Value {
	request := popen_boundary_request(args)
	if request.safe {
		output := safe_popen_read(request.argv, request.options) or {
			return popen_execution_error_value(err)
		}
		return ruby.string_value(output)
	}
	result := popen_read(request.argv, request.options) or {
		return popen_execution_error_value(err)
	}
	return ruby.string_value(result.stdout)
}

// Ruby method `self.safe_popen_read(*args, **options, &block)` at line 32.
pub fn ruby_popen_l32_d2_self_safe_popen_read(args ...ruby.Value) ruby.Value {
	request := popen_boundary_request(args)
	output := safe_popen_read(request.argv, request.options) or {
		return popen_execution_error_value(err)
	}
	return ruby.string_value(output)
}

// Ruby method `self.popen_write(*args, safe: false, **options, &_block)` at line 44.
pub fn ruby_popen_l44_d3_self_popen_write(args ...ruby.Value) ruby.Value {
	request := popen_boundary_request(args)
	if request.safe {
		output := safe_popen_write(request.argv, request.options.input, request.options) or {
			return popen_execution_error_value(err)
		}
		return ruby.string_value(output)
	}
	result := popen_write(request.argv, request.options.input, request.options) or {
		return popen_execution_error_value(err)
	}
	return ruby.string_value(result.stdout)
}

// Ruby method `self.safe_popen_write(*args, **options, &block)` at line 75.
pub fn ruby_popen_l75_d4_self_safe_popen_write(args ...ruby.Value) ruby.Value {
	request := popen_boundary_request(args)
	output := safe_popen_write(request.argv, request.options.input, request.options) or {
		return popen_execution_error_value(err)
	}
	return ruby.string_value(output)
}

// Ruby method `self.popen(args, mode, options = {}, &_block)` at line 88.
pub fn ruby_popen_l88_d5_self_popen(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'expected argv and mode')
	}
	mut request_arguments := [args[0]]
	if args.len > 2 {
		request_arguments << args[2]
	}
	request := popen_boundary_request(request_arguments)
	mode := popen_mode(args[1].as_string()) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	result := popen(request.argv, mode, request.options) or {
		return popen_execution_error_value(err)
	}
	return ruby.string_value(result.stdout)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   IO_DEFAULT_BUFFER_SIZE = 4096
// 6:   private_constant :IO_DEFAULT_BUFFER_SIZE
// 7:
// 8:   sig {
// 9:     type_parameters(:U)
// 10:       .params(
// 11:         args:    T.nilable(T.any(String, Pathname, T::Hash[String, String])),
// 12:         safe:    T::Boolean,
// 13:         options: T.nilable(T.any(Pathname, String, Symbol)),
// 14:         block:   T.nilable(T.proc.params(arg0: IO).returns(T.type_parameter(:U))),
// 15:       ).returns(T.any(T.type_parameter(:U), String))
// 16:   }
// 17:   def self.popen_read(*args, safe: false, **options, &block)
// 18:     output = popen(args, "rb", options, &block)
// 19:     return output if !safe || $CHILD_STATUS.success?
// 20:
// 21:     raise ErrorDuringExecution.new(args, status: $CHILD_STATUS, output: [[:stdout, T.cast(output, String)]])
// 22:   end
// 23:
// 24:   sig {
// 25:     type_parameters(:U)
// 26:       .params(
// 27:         args:    T.nilable(T.any(String, Pathname, T::Hash[String, String])),
// 28:         options: T.nilable(T.any(Pathname, String, Symbol)),
// 29:         block:   T.nilable(T.proc.params(arg0: IO).returns(T.type_parameter(:U))),
// 30:       ).returns(T.any(T.type_parameter(:U), String))
// 31:   }
// 32:   def self.safe_popen_read(*args, **options, &block)
// 33:     popen_read(*args, safe: true, **options, &block)
// 34:   end
// 35:
// 36:   sig {
// 37:     params(
// 38:       args:    T.any(String, Pathname),
// 39:       safe:    T::Boolean,
// 40:       options: T.nilable(T.any(Pathname, String, Symbol)),
// 41:       _block:  T.proc.params(arg0: IO).returns(T.anything),
// 42:     ).returns(String)
// 43:   }
// 44:   def self.popen_write(*args, safe: false, **options, &_block)
// 45:     output = ""
// 46:     popen(args, "w+b", options) do |pipe|
// 47:       # Before we yield to the block, capture as much output as we can
// 48:       loop do
// 49:         output += pipe.read_nonblock(IO_DEFAULT_BUFFER_SIZE)
// 50:       rescue IO::WaitReadable, EOFError
// 51:         break
// 52:       end
// 53:
// 54:       yield pipe
// 55:       pipe.close_write
// 56:       pipe.wait_readable
// 57:
// 58:       # Capture the rest of the output
// 59:       output += pipe.read
// 60:       output.freeze
// 61:     end
// 62:     return output if !safe || $CHILD_STATUS.success?
// 63:
// 64:     raise ErrorDuringExecution.new(args, status: $CHILD_STATUS, output: [[:stdout, output]])
// 65:   end
// 66:
// 67:   sig {
// 68:     type_parameters(:U)
// 69:       .params(
// 70:         args:    T.any(String, Pathname),
// 71:         options: T.nilable(T.any(Pathname, String, Symbol)),
// 72:         block:   T.proc.params(arg0: IO).returns(T.type_parameter(:U)),
// 73:       ).returns(T.type_parameter(:U))
// 74:   }
// 75:   def self.safe_popen_write(*args, **options, &block)
// 76:     popen_write(*args, safe: true, **options, &block)
// 77:   end
// 78:
// 79:   sig {
// 80:     type_parameters(:U)
// 81:       .params(
// 82:         args:    T::Array[T.nilable(T.any(Pathname, String, T::Hash[String, String]))],
// 83:         mode:    String,
// 84:         options: T::Hash[Symbol, T.nilable(T.any(Pathname, String, Symbol))],
// 85:         _block:  T.nilable(T.proc.params(arg0: IO).returns(T.type_parameter(:U))),
// 86:       ).returns(T.any(T.type_parameter(:U), String))
// 87:   }
// 88:   def self.popen(args, mode, options = {}, &_block)
// 89:     # `brew prof --vernier` uses this to avoid inheriting Vernier's active
// 90:     # native collector state through `IO.popen("-")` fork paths.
// 91:     if ENV["HOMEBREW_SPAWN_SYSTEM"] == "1"
// 92:       options[:err] ||= File::NULL unless ENV["HOMEBREW_STDERR"]
// 93:       IO.popen(args, mode, options) do |pipe|
// 94:         return pipe.read unless block_given?
// 95:
// 96:         return yield pipe
// 97:       end
// 98:     end
// 99:
// 100:     IO.popen("-", mode) do |pipe|
// 101:       if pipe
// 102:         return pipe.read unless block_given?
// 103:
// 104:         yield pipe
// 105:       else
// 106:         options[:err] ||= File::NULL unless ENV["HOMEBREW_STDERR"]
// 107:         cmd = if args[0].is_a? Hash
// 108:           args[1]
// 109:         else
// 110:           args[0]
// 111:         end
// 112:         begin
// 113:           exec(*args, options)
// 114:         rescue Errno::ENOENT
// 115:           $stderr.puts "brew: command not found: #{cmd}" if options[:err] != :close
// 116:           exit! 127
// 117:         rescue SystemCallError => e
// 118:           if options[:err] != :close
// 119:             require "utils"
// 120:             $stderr.puts "brew: exec failed (#{Utils.demodulize(e.class.name)}): #{cmd}"
// 121:           end
// 122:           exit! 1
// 123:         end
// 124:       end
// 125:     end
// 126:   end
// 127: end
