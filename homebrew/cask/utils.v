module cask

import ruby
import os

// Translated from Homebrew/brew `cask/utils.rb`.

pub const cask_bug_reports_url = 'https://github.com/Homebrew/homebrew-cask#reporting-bugs'
pub const full_disk_access_tcc_path = '~/Library/Application Support/com.apple.TCC'

pub struct CaskUtilsCommand {
pub:
	executable        string
	args              []string
	sudo              bool
	print_stderr      bool
	raises_on_failure bool
}

pub type CaskUtilsCommandRunner = fn (CaskUtilsCommand) !bool

pub enum CaskUtilsPathOperation {
	rmdir
	remove_file
	remove_directory
}

pub struct CaskUtilsPermissionOptions {
pub:
	debug    bool
	verbose  bool
	username string
}

pub struct CaskUtilsPermissionResult {
pub mut:
	success           bool = true
	error             string
	commands          []CaskUtilsCommand
	output            []string
	attempts          int
	tried_permissions bool
	tried_ownership   bool
}

fn cask_utils_native_runner(command CaskUtilsCommand) !bool {
	mut argv := []string{}
	if command.sudo {
		argv << 'sudo'
	}
	argv << command.executable
	argv << command.args
	result := ruby.run_captured_command(argv, ruby.CapturedCommandOptions{
		environment: ruby.environment()
	})!
	if result.exit_code != 0 {
		message := if result.stderr.trim_space() != '' {
			result.stderr.trim_space()
		} else {
			'Command failed with exit status ${result.exit_code}: ${argv.join(' ')}'
		}
		return error(message)
	}
	return true
}

fn cask_utils_command_args(command_args []string, suffix []string) []string {
	mut args := command_args.clone()
	args << suffix
	return args
}

fn cask_utils_recorded_run(command CaskUtilsCommand, runner CaskUtilsCommandRunner,
	mut result CaskUtilsPermissionResult) ! {
	result.commands << command
	succeeded := runner(command)!
	if !succeeded {
		return error('Command failed: ${command.executable}')
	}
}

fn cask_utils_recorded_non_bang_run(command CaskUtilsCommand, runner CaskUtilsCommandRunner,
	mut result CaskUtilsPermissionResult) {
	result.commands << command
	_ = runner(command) or { return }
}

fn cask_utils_nearest_directory(path string) ?string {
	mut candidate := path
	for {
		if os.is_dir(candidate) {
			return candidate
		}
		parent := os.dir(candidate)
		if parent == candidate || parent == '' {
			return none
		}
		candidate = parent
	}
	return none
}

fn cask_utils_apply_path_operation(path string, operation CaskUtilsPathOperation,
	runner CaskUtilsCommandRunner, mut result CaskUtilsPermissionResult) ! {
	parent_writable := os.is_writable(os.dir(path))
	match operation {
		.rmdir {
			if parent_writable {
				os.rmdir(path)!
			} else {
				cask_utils_recorded_run(CaskUtilsCommand{
					executable: 'rmdir'
					args: ['--', path]
					sudo: true
					raises_on_failure: true
				}, runner, mut result)!
			}
		}
		.remove_file {
			if parent_writable {
				os.rm(path)!
			} else {
				cask_utils_recorded_run(CaskUtilsCommand{
					executable: '/bin/rm'
					args: ['-f', '--', path]
					sudo: true
					raises_on_failure: true
				}, runner, mut result)!
			}
		}
		.remove_directory {
			if parent_writable {
				os.rmdir_all(path)!
			} else {
				cask_utils_recorded_run(CaskUtilsCommand{
					executable: '/bin/rm'
					args: ['-R', '-f', '--', path]
					sudo: true
					raises_on_failure: true
				}, runner, mut result)!
			}
		}
	}
}

fn cask_utils_effective_username(options CaskUtilsPermissionOptions) string {
	if options.username != '' {
		return options.username
	}
	return ruby.current_username()
}

// gain_permissions_with_runner preserves the source retry order: an operation is
// retried after clearing flags/ACLs and widening mode bits, then after taking
// ownership, and finally after applying the permission repair once more.
pub fn gain_permissions_with_runner(path string, command_args []string,
	operation CaskUtilsPathOperation, options CaskUtilsPermissionOptions,
	runner CaskUtilsCommandRunner) CaskUtilsPermissionResult {
	mut result := CaskUtilsPermissionResult{}
	mut tried_permissions := false
	mut tried_ownership := false
	for {
		result.attempts++
		cask_utils_apply_path_operation(path, operation, runner, mut result) or {
			operation_error := err.msg()
			if !tried_permissions {
				print_stderr := options.debug || options.verbose
				cask_utils_recorded_non_bang_run(CaskUtilsCommand{
					executable: '/usr/bin/chflags'
					args: cask_utils_command_args(command_args, ['--', '000', path])
					print_stderr: print_stderr
				}, runner, mut result)
				cask_utils_recorded_non_bang_run(CaskUtilsCommand{
					executable: 'chmod'
					args: cask_utils_command_args(command_args, ['--', 'u+rwx', path])
					print_stderr: print_stderr
				}, runner, mut result)
				cask_utils_recorded_non_bang_run(CaskUtilsCommand{
					executable: 'chmod'
					args: cask_utils_command_args(command_args, ['-N', path])
					print_stderr: print_stderr
				}, runner, mut result)
				tried_permissions = true
				result.tried_permissions = true
				continue
			}
			if !tried_ownership {
				result.output << "Using sudo to gain ownership of path '${path}'"
				cask_utils_recorded_non_bang_run(CaskUtilsCommand{
					executable: 'chown'
					args: cask_utils_command_args(command_args, ['--',
						cask_utils_effective_username(options), path])
					sudo: true
				}, runner, mut result)
				tried_ownership = true
				result.tried_ownership = true
				// Retry chflags/chmod after chown.
				tried_permissions = false
				continue
			}
			result.success = false
			result.error = operation_error
			return result
		}
		return result
	}
	return result
}

pub fn gain_permissions_mkpath_with_runner(path string,
	runner CaskUtilsCommandRunner) CaskUtilsPermissionResult {
	mut result := CaskUtilsPermissionResult{}
	directory := cask_utils_nearest_directory(path) or {
		return CaskUtilsPermissionResult{
			success: false
			error: 'No existing ancestor directory for ${path}'
		}
	}
	if path == directory {
		return result
	}
	if os.is_writable(directory) {
		os.mkdir_all(path) or {
			result.success = false
			result.error = err.msg()
		}
		return result
	}
	cask_utils_recorded_run(CaskUtilsCommand{
		executable: 'mkdir'
		args: ['-p', '--', path]
		sudo: true
		raises_on_failure: true
	}, runner, mut result) or {
		result.success = false
		result.error = err.msg()
	}
	return result
}

pub fn gain_permissions_mkpath(path string) CaskUtilsPermissionResult {
	return gain_permissions_mkpath_with_runner(path, cask_utils_native_runner)
}

pub fn gain_permissions_rmdir_with_runner(path string,
	runner CaskUtilsCommandRunner) CaskUtilsPermissionResult {
	return gain_permissions_with_runner(path, [], .rmdir, CaskUtilsPermissionOptions{}, runner)
}

pub fn gain_permissions_rmdir(path string) CaskUtilsPermissionResult {
	return gain_permissions_rmdir_with_runner(path, cask_utils_native_runner)
}

pub fn gain_permissions_remove_with_runner(path string,
	runner CaskUtilsCommandRunner) CaskUtilsPermissionResult {
	operation := if os.is_link(path) {
		CaskUtilsPathOperation.remove_file
	} else if os.is_dir(path) {
		CaskUtilsPathOperation.remove_directory
	} else if os.exists(path) {
		CaskUtilsPathOperation.remove_file
	} else {
		// Nothing to remove.
		return CaskUtilsPermissionResult{}
	}
	command_args := match operation {
		.remove_file {
			if os.is_link(path) { ['-h'] } else { []string{} }
		}
		.remove_directory { ['-R'] }
		else { []string{} }
	}
	return gain_permissions_with_runner(path, command_args, operation, CaskUtilsPermissionOptions{}, runner)
}

pub fn gain_permissions_remove(path string) CaskUtilsPermissionResult {
	return gain_permissions_remove_with_runner(path, cask_utils_native_runner)
}

pub fn privacy_security_preference_pane(access string, macos_major int) string {
	navigation_path := if macos_major >= 13 {
		'System Settings → Privacy & Security'
	} else {
		'System Preferences → Security & Privacy → Privacy'
	}
	return '${navigation_path} → ${access}'
}

pub fn current_macos_major_version() int {
	result := ruby.run_command('/usr/bin/sw_vers', ['-productVersion'])
	if result.exit_code == 0 {
		major := result.output.trim_space().all_before('.').int()
		if major > 0 {
			return major
		}
	}
	// Homebrew only calls this helper on macOS; Ventura is the modern fallback
	// for deterministic behavior when the boundary is exercised elsewhere.
	return 13
}

pub fn full_disk_access_enabled(path string) bool {
	expanded := os.expand_tilde_to_home(path)
	return os.is_readable(expanded)
}

pub fn path_occupied(path string) bool {
	return os.exists(path) || os.is_link(path)
}

pub fn token_from(name string) string {
	mut expanded := name.to_lower().replace('+', '-plus-')
	expanded = expanded.replace(' ', '-').replace('_', '-').replace('·', '-').replace('•', '-')
	mut filtered := ''
	for character in expanded.bytes() {
		if (character >= `a` && character <= `z`) || (character >= `0` && character <= `9`)
			|| character == `_` || character == `@` || character == `-` {
			filtered += character.ascii_str()
		}
	}
	for filtered.contains('--') {
		filtered = filtered.replace('--', '-')
	}
	return filtered.trim('-')
}

fn cask_utils_void_result(result CaskUtilsPermissionResult) ruby.Value {
	if result.success {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.object_value('CaskError', result.error)
}
