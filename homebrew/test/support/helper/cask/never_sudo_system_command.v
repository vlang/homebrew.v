module cask

import brew_runtime
import homebrew

// Translated from Homebrew/brew `test/support/helper/cask/never_sudo_system_command.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn never_sudo_system_command(command string,
	options homebrew.SystemCommandOptions) !homebrew.SystemCommandResult {
	return homebrew.run_system_command(command, homebrew.SystemCommandOptions{
		args: options.args
		sudo: false
		sudo_as_root: false
		environment: options.environment
		input: options.input
		must_succeed: options.must_succeed
		print_stdout: options.print_stdout
		print_stderr: options.print_stderr
		debug: options.debug
		verbose: options.verbose
		secrets: options.secrets
		chdir: options.chdir
		reset_uid: options.reset_uid
		run_as_real_uid: options.run_as_real_uid
		timeout: options.timeout
		absolute_path_args: options.absolute_path_args
	})
}

// Ruby method `self.run(command, **options)` at line 7.
pub fn ruby_never_sudo_system_command_l7_d1_self_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command is required')
	}
	option_values := if args.len > 1 {
		args[1].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	result := never_sudo_system_command(args[0].as_string(), homebrew.SystemCommandOptions{
		args: (option_values['args'] or { brew_runtime.string_array_value([]) }).as_string_array() or { [] }
		input: (option_values['input'] or { brew_runtime.string_array_value([]) }).as_string_array() or { [] }
		must_succeed: (option_values['must_succeed'] or { brew_runtime.bool_value(false) }).bool_data
		sudo: true
		sudo_as_root: true
	}) or { return brew_runtime.object_value('SystemCommand::Error', err.msg()) }
	return brew_runtime.map_value({
		'stdout':       brew_runtime.string_value(result.stdout_text())
		'stderr':       brew_runtime.string_value(result.stderr_text())
		'success':      brew_runtime.bool_value(result.success())
		'sudo':         brew_runtime.bool_value(false)
		'sudo_as_root': brew_runtime.bool_value(false)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5:
// 6: class NeverSudoSystemCommand < SystemCommand
// 7:   def self.run(command, **options)
// 8:     super(command, **options.merge(sudo: false, sudo_as_root: false))
// 9:   end
// 10: end
