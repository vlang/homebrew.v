module system

import ruby
import os

// Translated from Homebrew/brew `services/system/systemctl.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum SystemctlMode {
	default_mode
	quiet
	read
}

pub struct SystemctlCommand {
pub:
	executable   string
	args         []string
	print_stdout bool
	print_stderr bool
	must_succeed bool
	reset_uid    bool
}

pub struct SystemctlCommandResult {
pub:
	stdout  string
	stderr  string
	success bool
}

pub type SystemctlRunner = fn(SystemctlCommand) !SystemctlCommandResult

@[heap]
pub struct SystemctlState {
pub:
	path_environment string
	root             bool
pub mut:
	executable_path string
	resolved        bool
}

fn systemctl_executable_in_path(path_environment string) ?string {
	for directory in path_environment.split(os.path_delimiter) {
		if directory == '' {
			continue
		}
		candidate := os.join_path(directory, 'systemctl')
		if os.is_file(candidate) && os.is_executable(candidate) {
			return candidate
		}
	}
	return none
}

pub fn new_systemctl_state(path_environment string, root bool) &SystemctlState {
	return &SystemctlState{
		path_environment: if path_environment == '' { os.getenv('PATH') } else { path_environment }
		root: root
	}
}

pub fn (mut state SystemctlState) executable() ?string {
	if !state.resolved {
		state.executable_path = systemctl_executable_in_path(state.path_environment) or { '' }
		state.resolved = true
	}
	return if state.executable_path == '' { none } else { state.executable_path }
}

pub fn (mut state SystemctlState) set_executable(path ?string) ?string {
	state.executable_path = path or { '' }
	state.resolved = path != none
	return path
}

pub fn (state SystemctlState) scope() string {
	return if state.root { '--system' } else { '--user' }
}

fn native_systemctl_runner(command SystemctlCommand) !SystemctlCommandResult {
	mut argv := [command.executable]
	argv << command.args
	result := ruby.run_captured_command(argv, ruby.CapturedCommandOptions{
		environment: ruby.environment()
	})!
	if command.print_stdout && result.stdout != '' {
		print(result.stdout)
	}
	if command.print_stderr && result.stderr != '' {
		eprint(result.stderr)
	}
	if command.must_succeed && result.exit_code != 0 {
		return error('systemctl exited with ${result.exit_code}: ${result.stderr.trim_space()}')
	}
	return SystemctlCommandResult{
		stdout: result.stdout
		stderr: result.stderr
		success: result.exit_code == 0
	}
}

pub fn systemctl_run_with(mut state SystemctlState, arguments []string, mode SystemctlMode,
	runner SystemctlRunner) !SystemctlCommandResult {
	executable := state.executable() or { return error('systemctl executable not found') }
	mut command_args := [state.scope()]
	command_args << arguments
	return runner(SystemctlCommand{
		executable: executable
		args: command_args
		print_stdout: mode == .default_mode
		print_stderr: mode == .default_mode
		must_succeed: mode == .default_mode
		reset_uid: true
	})!
}

pub fn systemctl_run(mut state SystemctlState, arguments []string,
	mode SystemctlMode) !SystemctlCommandResult {
	return systemctl_run_with(mut state, arguments, mode, native_systemctl_runner)
}

pub fn systemctl_state_boundary(state &SystemctlState) ruby.Value {
	return ruby.structured_value('Homebrew::Services::System::Systemctl', 'Systemctl', {
		'systemctl_state_address': u64(voidptr(state)).str()
	})
}

fn systemctl_state_from_args(args []ruby.Value) (&SystemctlState, int) {
	if args.len > 0 && args[0].type_name == 'Homebrew::Services::System::Systemctl' {
		address := args[0].attributes['systemctl_state_address'] or {
			panic('translated Systemctl state is missing')
		}
		return unsafe { &SystemctlState(voidptr(address.u64())) }, 1
	}
	return new_systemctl_state('', os.geteuid() == 0), 0
}

fn systemctl_boundary_result(result SystemctlCommandResult, mode SystemctlMode) ruby.Value {
	return match mode {
		.read { ruby.string_value(result.stdout) }
		.quiet { ruby.bool_value(result.success) }
		.default_mode { ruby.Value{ type_name: 'NilClass', repr: 'nil' } }
	}
}

// Ruby method `self.executable` at line 9.
pub fn ruby_systemctl_l9_d1_self_executable(args ...ruby.Value) ruby.Value {
	mut state, _ := systemctl_state_from_args(args)
	return if executable := state.executable() {
		ruby.object_value('Pathname', executable)
	} else {
		ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
}

// Ruby attr_writer `attr_writer :executable` at line 15.
pub fn ruby_systemctl_l15_d2_executable(args ...ruby.Value) ruby.Value {
	mut state, offset := systemctl_state_from_args(args)
	if args.len <= offset || args[offset].type_name == 'NilClass' {
		state.set_executable(none)
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	state.set_executable(args[offset].as_string())
	return ruby.object_value('Pathname', args[offset].as_string())
}

// Ruby method `self.scope` at line 19.
pub fn ruby_systemctl_l19_d3_self_scope(args ...ruby.Value) ruby.Value {
	state, _ := systemctl_state_from_args(args)
	return ruby.string_value(state.scope())
}

// Ruby method `self.run(*args)` at line 24.
pub fn ruby_systemctl_l24_d4_self_run(args ...ruby.Value) ruby.Value {
	mut state, offset := systemctl_state_from_args(args)
	result := systemctl_run(mut state, args[offset..].map(it.as_string()), .default_mode) or {
		return ruby.object_value('ErrorDuringExecution', err.msg())
	}
	return systemctl_boundary_result(result, .default_mode)
}

// Ruby method `self.quiet_run(*args)` at line 29.
pub fn ruby_systemctl_l29_d5_self_quiet_run(args ...ruby.Value) ruby.Value {
	mut state, offset := systemctl_state_from_args(args)
	result := systemctl_run(mut state, args[offset..].map(it.as_string()), .quiet) or {
		return ruby.bool_value(false)
	}
	return systemctl_boundary_result(result, .quiet)
}

// Ruby method `self.popen_read(*args)` at line 34.
pub fn ruby_systemctl_l34_d6_self_popen_read(args ...ruby.Value) ruby.Value {
	mut state, offset := systemctl_state_from_args(args)
	result := systemctl_run(mut state, args[offset..].map(it.as_string()), .read) or {
		return ruby.string_value('')
	}
	return systemctl_boundary_result(result, .read)
}

// Ruby method `self._run(*args, mode:)` at line 39.
pub fn ruby_systemctl_l39_d7_self_run(args ...ruby.Value) ruby.Value {
	mut state, offset := systemctl_state_from_args(args)
	if args.len <= offset {
		return ruby.object_value('ArgumentError', 'mode is required')
	}
	mode_name := args.last().as_string().trim_left(':')
	mode := match mode_name {
		'default' { SystemctlMode.default_mode }
		'quiet' { SystemctlMode.quiet }
		'read' { SystemctlMode.read }
		else {
			return ruby.object_value('ArgumentError', 'invalid mode ${mode_name}')
		}
	}
	result := systemctl_run(mut state, args[offset..args.len - 1].map(it.as_string()), mode) or {
		return ruby.object_value('ErrorDuringExecution', err.msg())
	}
	return systemctl_boundary_result(result, mode)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Services
// 6:     module System
// 7:       module Systemctl
// 8:         sig { returns(T.nilable(Pathname)) }
// 9:         def self.executable
// 10:           @executable ||= T.let(which("systemctl"), T.nilable(Pathname))
// 11:         end
// 12:
// 13:         class << self
// 14:           sig { params(executable: T.nilable(Pathname)).returns(T.nilable(Pathname)) }
// 15:           attr_writer :executable
// 16:         end
// 17:
// 18:         sig { returns(String) }
// 19:         def self.scope
// 20:           System.root? ? "--system" : "--user"
// 21:         end
// 22:
// 23:         sig { params(args: T.any(String, Pathname)).void }
// 24:         def self.run(*args)
// 25:           _run(*args, mode: :default)
// 26:         end
// 27:
// 28:         sig { params(args: T.any(String, Pathname)).returns(T::Boolean) }
// 29:         def self.quiet_run(*args)
// 30:           _run(*args, mode: :quiet)
// 31:         end
// 32:
// 33:         sig { params(args: T.any(String, Pathname)).returns(String) }
// 34:         def self.popen_read(*args)
// 35:           _run(*args, mode: :read)
// 36:         end
// 37:
// 38:         sig { params(args: T.any(String, Pathname), mode: Symbol).returns(T.nilable(T.any(String, T::Boolean))) }
// 39:         private_class_method def self._run(*args, mode:)
// 40:           require "system_command"
// 41:           result = SystemCommand.run(T.must(executable),
// 42:                                      args:         [scope, *args.map(&:to_s)],
// 43:                                      print_stdout: mode == :default,
// 44:                                      print_stderr: mode == :default,
// 45:                                      must_succeed: mode == :default,
// 46:                                      reset_uid:    true)
// 47:           if mode == :read
// 48:             result.stdout
// 49:           elsif mode == :quiet
// 50:             result.success?
// 51:           end
// 52:         end
// 53:       end
// 54:     end
// 55:   end
// 56: end
