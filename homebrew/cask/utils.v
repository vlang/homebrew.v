module cask

import ruby
import os

// Translated from Homebrew/brew `cask/utils.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `self.privacy_security_preference_pane(access)` at line 17.
pub fn ruby_utils_l17_d1_self_privacy_security_preference_pane(args ...ruby.Value) ruby.Value {
	access := if args.len > 0 { args[0].as_string() } else { '' }
	major := if args.len > 1 { int(args[1].int_data) } else { current_macos_major_version() }
	return ruby.string_value(privacy_security_preference_pane(access, major))
}

// Ruby method `self.full_disk_access_enabled?` at line 28.
pub fn ruby_utils_l28_d2_self_full_disk_access_enabled(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 { args[0].as_string() } else { full_disk_access_tcc_path }
	return ruby.bool_value(full_disk_access_enabled(path))
}

// Ruby method `self.gain_permissions_mkpath(path, command: SystemCommand)` at line 33.
pub fn ruby_utils_l33_d3_self_gain_permissions_mkpath(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'path is required')
	}
	return cask_utils_void_result(gain_permissions_mkpath(args[0].as_string()))
}

// Ruby method `self.gain_permissions_rmdir(path, command: SystemCommand)` at line 45.
pub fn ruby_utils_l45_d4_self_gain_permissions_rmdir(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'path is required')
	}
	return cask_utils_void_result(gain_permissions_rmdir(args[0].as_string()))
}

// Ruby method `self.gain_permissions_remove(path, command: SystemCommand)` at line 56.
pub fn ruby_utils_l56_d5_self_gain_permissions_remove(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'path is required')
	}
	return cask_utils_void_result(gain_permissions_remove(args[0].as_string()))
}

// Ruby method `self.gain_permissions(path, command_args, command, &_block)` at line 92.
pub fn ruby_utils_l92_d6_self_gain_permissions(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'path is required')
	}
	command_args := if args.len > 1 {
		args[1].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	operation := if args.len > 2 {
		match args[2].as_string() {
			'rmdir' { CaskUtilsPathOperation.rmdir }
			'remove_directory' { CaskUtilsPathOperation.remove_directory }
			else { CaskUtilsPathOperation.remove_file }
		}
	} else {
		CaskUtilsPathOperation.remove_file
	}
	return cask_utils_void_result(gain_permissions_with_runner(args[0].as_string(), command_args, operation, CaskUtilsPermissionOptions{}, cask_utils_native_runner))
}

// Ruby method `self.path_occupied?(path)` at line 137.
pub fn ruby_utils_l137_d7_self_path_occupied(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && path_occupied(args[0].as_string()))
}

// Ruby method `self.token_from(name)` at line 142.
pub fn ruby_utils_l142_d8_self_token_from(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.string_value(token_from(name))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/user"
// 5: require "open3"
// 6: require "utils/output"
// 7:
// 8: module Cask
// 9:   # Helper functions for various cask operations.
// 10:   module Utils
// 11:     extend ::Utils::Output::Mixin
// 12:
// 13:     BUG_REPORTS_URL = "https://github.com/Homebrew/homebrew-cask#reporting-bugs"
// 14:     FULL_DISK_ACCESS_TCC_PATH = "~/Library/Application Support/com.apple.TCC"
// 15:
// 16:     sig { params(access: String).returns(String) }
// 17:     def self.privacy_security_preference_pane(access)
// 18:       navigation_path = if MacOS.version >= :ventura
// 19:         "System Settings → Privacy & Security"
// 20:       else
// 21:         "System Preferences → Security & Privacy → Privacy"
// 22:       end
// 23:
// 24:       "#{navigation_path} → #{access}"
// 25:     end
// 26:
// 27:     sig { returns(T::Boolean) }
// 28:     def self.full_disk_access_enabled?
// 29:       File.readable?(File.expand_path(FULL_DISK_ACCESS_TCC_PATH))
// 30:     end
// 31:
// 32:     sig { params(path: Pathname, command: T.class_of(SystemCommand)).void }
// 33:     def self.gain_permissions_mkpath(path, command: SystemCommand)
// 34:       dir = path.ascend.find(&:directory?)
// 35:       return if path == dir
// 36:
// 37:       if dir&.writable?
// 38:         path.mkpath
// 39:       else
// 40:         command.run!("mkdir", args: ["-p", "--", path], sudo: true, print_stderr: false)
// 41:       end
// 42:     end
// 43:
// 44:     sig { params(path: Pathname, command: T.class_of(SystemCommand)).void }
// 45:     def self.gain_permissions_rmdir(path, command: SystemCommand)
// 46:       gain_permissions(path, [], command) do |p|
// 47:         if p.parent.writable?
// 48:           FileUtils.rmdir p
// 49:         else
// 50:           command.run!("rmdir", args: ["--", p], sudo: true, print_stderr: false)
// 51:         end
// 52:       end
// 53:     end
// 54:
// 55:     sig { params(path: Pathname, command: T.class_of(SystemCommand)).void }
// 56:     def self.gain_permissions_remove(path, command: SystemCommand)
// 57:       directory = false
// 58:       permission_flags = if path.symlink?
// 59:         ["-h"]
// 60:       elsif path.directory?
// 61:         directory = true
// 62:         ["-R"]
// 63:       elsif path.exist?
// 64:         []
// 65:       else
// 66:         # Nothing to remove.
// 67:         return
// 68:       end
// 69:
// 70:       gain_permissions(path, permission_flags, command) do |p|
// 71:         if p.parent.writable?
// 72:           if directory
// 73:             FileUtils.rm_r p
// 74:           else
// 75:             FileUtils.rm_f p
// 76:           end
// 77:         else
// 78:           recursive_flag = directory ? ["-R"] : []
// 79:           command.run!("/bin/rm", args: recursive_flag + ["-f", "--", p], sudo: true, print_stderr: false)
// 80:         end
// 81:       end
// 82:     end
// 83:
// 84:     sig {
// 85:       params(
// 86:         path:         Pathname,
// 87:         command_args: T::Array[String],
// 88:         command:      T.class_of(SystemCommand),
// 89:         _block:       T.proc.params(path: Pathname).void,
// 90:       ).void
// 91:     }
// 92:     def self.gain_permissions(path, command_args, command, &_block)
// 93:       tried_permissions = false
// 94:       tried_ownership = false
// 95:       begin
// 96:         yield path
// 97:       rescue
// 98:         # in case of permissions problems
// 99:         unless tried_permissions
// 100:           print_stderr = Context.current.debug? || Context.current.verbose?
// 101:           # TODO: Better handling for the case where path is a symlink.
// 102:           #       The `-h` and `-R` flags cannot be combined and behavior is
// 103:           #       dependent on whether the file argument has a trailing
// 104:           #       slash. This should do the right thing, but is fragile.
// 105:           command.run("/usr/bin/chflags",
// 106:                       print_stderr:,
// 107:                       args:         command_args + ["--", "000", path])
// 108:           command.run("chmod",
// 109:                       print_stderr:,
// 110:                       args:         command_args + ["--", "u+rwx", path])
// 111:           command.run("chmod",
// 112:                       print_stderr:,
// 113:                       args:         command_args + ["-N", path])
// 114:           tried_permissions = true
// 115:           retry # rmtree
// 116:         end
// 117:
// 118:         unless tried_ownership
// 119:           # in case of ownership problems
// 120:           # TODO: Further examine files to see if ownership is the problem
// 121:           #       before using `sudo` and `chown`.
// 122:           ohai "Using sudo to gain ownership of path '#{path}'"
// 123:           command.run("chown",
// 124:                       args: command_args + ["--", User.current.to_s, path],
// 125:                       sudo: true)
// 126:           tried_ownership = true
// 127:           # retry chflags/chmod after chown
// 128:           tried_permissions = false
// 129:           retry # rmtree
// 130:         end
// 131:
// 132:         raise
// 133:       end
// 134:     end
// 135:
// 136:     sig { params(path: Pathname).returns(T::Boolean) }
// 137:     def self.path_occupied?(path)
// 138:       path.exist? || path.symlink?
// 139:     end
// 140:
// 141:     sig { params(name: String).returns(String) }
// 142:     def self.token_from(name)
// 143:       name.downcase
// 144:           .gsub("+", "-plus-")
// 145:           .gsub(/[ _·•]/, "-")
// 146:           .gsub(/[^\w@-]/, "")
// 147:           .gsub(/--+/, "-")
// 148:           .delete_prefix("-")
// 149:           .delete_suffix("-")
// 150:     end
// 151:   end
// 152: end
