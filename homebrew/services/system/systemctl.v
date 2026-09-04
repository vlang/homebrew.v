module system

import ruby
import os

// Translated from Homebrew/brew `services/system/systemctl.rb`.
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

pub type SystemctlRunner = fn (SystemctlCommand) !SystemctlCommandResult

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
