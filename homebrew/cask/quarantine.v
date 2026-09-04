module cask

import ruby
import os
import strconv

pub const quarantine_attribute = 'com.apple.quarantine'
pub const quarantine_user_approved_flag = u64(0x0040)

pub struct QuarantineSigningIdentity {
pub:
	requirement string
}

pub enum QuarantineSupportKind {
	quarantine_unavailable
	quarantine_available
	xattr_broken
}

pub struct QuarantineSupport {
pub:
	kind    QuarantineSupportKind
	message ?string
}

pub struct QuarantineCommand {
pub:
	executable string
	args       []string
	input      string
	sudo       bool
}

pub struct QuarantineCommandResult {
pub:
	stdout    string
	stderr    string
	exit_code int
}

pub fn (result QuarantineCommandResult) success() bool {
	return result.exit_code == 0
}

pub type QuarantineCommandRunner = fn (QuarantineCommand) !QuarantineCommandResult

pub struct QuarantineContext {
pub:
	xattr string
	run   QuarantineCommandRunner @[required]
}

pub struct QuarantinePropagationResult {
pub:
	status string
	paths  []string
}

pub struct QuarantineDetection {
pub:
	present bool
	value   bool
}

pub struct QuarantineCommandOutcome {
pub:
	present bool
	command QuarantineCommand
}

pub struct QuarantinePropagationOutcome {
pub:
	present bool
	result  QuarantinePropagationResult
}

pub fn quarantine_xattr() ?string {
	return ruby.find_executable('xattr') or { return none }
}

pub fn quarantine_xattr_available(context QuarantineContext) bool {
	if context.xattr == '' {
		return false
	}
	result := context.run(QuarantineCommand{
		executable: context.xattr
		args: ['-h']
	}) or { return false }
	return result.success()
}

pub fn quarantine_check_support() QuarantineSupport {
	return QuarantineSupport{ kind: .quarantine_unavailable }
}

pub fn quarantine_available(support QuarantineSupport) bool {
	return support.kind == .quarantine_available
}

pub fn quarantine_status(file string, context QuarantineContext) !string {
	if context.xattr == '' {
		return error('unexpected nil xattr')
	}
	result := context.run(QuarantineCommand{
		executable: context.xattr
		args: ['-p', quarantine_attribute, file]
	})!
	return result.stdout.trim_right('\r\n')
}

pub fn quarantine_detect(file ?string, context QuarantineContext) !QuarantineDetection {
	path := file or { return QuarantineDetection{} }
	return QuarantineDetection{
		present: true
		value: quarantine_status(path, context)! != ''
	}
}

fn quarantine_hex_flags(status string) u64 {
	flags := status.all_before(';')
	return strconv.parse_uint(flags, 16, 64) or { 0 }
}

pub fn quarantine_user_approved(file string, context QuarantineContext) !bool {
	if context.xattr == '' {
		return false
	}
	status := quarantine_status(file, context)!
	return status != '' && (quarantine_hex_flags(status) & quarantine_user_approved_flag) != 0
}

fn quarantine_replace_flags(attribute string, mask u64, minimum_width int) string {
	mut end := 0
	for end < attribute.len {
		character := attribute[end]
		if !((character >= `0` && character <= `9`) || (character >= `a` && character <= `f`) || (character >= `A` && character <= `F`)) {
			break
		}
		end++
	}
	original := attribute[..end]
	value := strconv.parse_uint(original, 16, 64) or { 0 }
	width := if original.len > minimum_width { original.len } else { minimum_width }
	mut replacement := (value | mask).hex()
	if replacement.len < width {
		replacement = '0'.repeat(width - replacement.len) + replacement
	}
	return replacement + attribute[end..]
}

pub fn quarantine_inherit_user_approval(download_path ?string,
	context QuarantineContext) !QuarantineCommandOutcome {
	path := download_path or { return QuarantineCommandOutcome{} }
	detected := quarantine_detect(path, context)!
	if !detected.present || !detected.value {
		return QuarantineCommandOutcome{}
	}
	status := quarantine_status(path, context)!
	command := QuarantineCommand{
		executable: context.xattr
		args: ['-w', quarantine_attribute,
			quarantine_replace_flags(status, quarantine_user_approved_flag, 0), path]
	}
	result := context.run(command)!
	if !result.success() {
		return error('Failed to inherit quarantine approval for ${path}: ${result.stderr}')
	}
	return QuarantineCommandOutcome{
		present: true
		command: command
	}
}

pub fn quarantine_signing_identity(_ string) ?QuarantineSigningIdentity {
	return none
}

pub fn quarantine_signing_identity_match(_ string, _ QuarantineSigningIdentity) ?bool {
	return none
}

pub fn quarantine_toggle_no_translocation_bit(attribute string) string {
	return quarantine_replace_flags(attribute, 0x0100, 4)
}

pub fn quarantine_release(download_path ?string,
	context QuarantineContext) !QuarantineCommandOutcome {
	path := download_path or { return QuarantineCommandOutcome{} }
	detected := quarantine_detect(path, context)!
	if !detected.present || !detected.value {
		return QuarantineCommandOutcome{}
	}
	command := QuarantineCommand{
		executable: context.xattr
		args: ['-d', quarantine_attribute, path]
	}
	result := context.run(command)!
	if !result.success() {
		return error('Failed to release ${path} from quarantine: ${result.stderr}')
	}
	return QuarantineCommandOutcome{
		present: true
		command: command
	}
}

pub fn quarantine_cask(_ ruby.Value, _ ?string, _ bool) ! {
	return error('NotImplementedError')
}

fn quarantine_collect_paths(root string) ![]string {
	mut paths := []string{}
	mut entries := os.ls(root)!
	entries.sort()
	for entry in entries {
		path := os.join_path(root, entry)
		if os.is_link(path) {
			continue
		}
		paths << path
		if os.is_dir(path) {
			paths << quarantine_collect_paths(path)!
		}
	}
	return paths
}

pub fn quarantine_propagate(from ?string, to ?string,
	context QuarantineContext) !QuarantinePropagationOutcome {
	source := from or { return QuarantinePropagationOutcome{} }
	destination := to or { return QuarantinePropagationOutcome{} }
	detected := quarantine_detect(source, context)!
	if !detected.present || !detected.value {
		return error('${source} was not quarantined properly.')
	}
	status := quarantine_toggle_no_translocation_bit(quarantine_status(source, context)!)
	paths := quarantine_collect_paths(destination)!
	input := paths.join('\x00')
	chmod_result := context.run(QuarantineCommand{
		executable: '/usr/bin/xargs'
		args: ['-0', '--', 'chmod', '-h', 'u+w']
		input: input
	})!
	if !chmod_result.success() {
		return error(chmod_result.stderr)
	}
	if context.xattr == '' {
		return error('unexpected nil xattr')
	}
	quarantiner := context.run(QuarantineCommand{
		executable: '/usr/bin/xargs'
		args: ['-0', '--', context.xattr, '-w', quarantine_attribute, status]
		input: input
	})!
	if !quarantiner.success() {
		return error('Failed to propagate quarantine to ${destination}: ${quarantiner.stderr}')
	}
	return QuarantinePropagationOutcome{
		present: true
		result: QuarantinePropagationResult{
			status: status
			paths: paths
		}
	}
}

pub fn quarantine_copy_xattrs(_ string, _ string, _ QuarantineCommandRunner) ! {
	return error('NotImplementedError')
}

fn quarantine_native_runner(command QuarantineCommand) !QuarantineCommandResult {
	mut argv := []string{}
	if command.sudo {
		argv << '/usr/bin/sudo'
	}
	argv << command.executable
	argv << command.args
	result := ruby.run_captured_command(argv, ruby.CapturedCommandOptions{
		input: command.input
		environment: ruby.environment()
	})!
	return QuarantineCommandResult{
		stdout: result.stdout
		stderr: result.stderr
		exit_code: result.exit_code
	}
}

fn quarantine_context_from_values(args []ruby.Value) QuarantineContext {
	mut xattr := quarantine_xattr() or { '' }
	mut status := ''
	mut stderr := ''
	mut exit_code := 0
	for value in args {
		if value.type_name == 'Hash' {
			xattr = value.map_data['xattr'] or { ruby.string_value(xattr) }.as_string()
			status = value.map_data['status'] or { ruby.string_value(status) }.as_string()
			stderr = value.map_data['stderr'] or { ruby.string_value(stderr) }.as_string()
			if raw := value.map_data['exit_code'] {
				exit_code = int(raw.int_data)
			}
		}
	}
	return QuarantineContext{
		xattr: xattr
		run: fn [status, stderr, exit_code] (command QuarantineCommand) !QuarantineCommandResult {
			if status != '' && '-p' in command.args {
				return QuarantineCommandResult{ stdout: status, stderr: stderr, exit_code: exit_code }
			}
			return QuarantineCommandResult{ stderr: stderr, exit_code: exit_code }
		}
	}
}

fn quarantine_command_value(command QuarantineCommand) ruby.Value {
	return ruby.map_value({
		'executable': ruby.string_value(command.executable)
		'args':       ruby.string_array_value(command.args)
		'input':      ruby.string_value(command.input)
		'sudo':       ruby.bool_value(command.sudo)
	})
}

fn quarantine_error_value(message string) ruby.Value {
	return ruby.structured_value('Error', message, {
		'message': message
	})
}

fn quarantine_argument_string(args []ruby.Value, index int) ?string {
	mut current := 0
	for value in args {
		if value.type_name == 'Hash' {
			continue
		}
		if current == index {
			if value.type_name == '' || value.type_name == 'NilClass' {
				return none
			}
			return value.as_string()
		}
		current++
	}
	return none
}

struct CaskAppManagementPermissionCommand {
	touch_error string
	rm_error    string
	native      bool
}

fn (command CaskAppManagementPermissionCommand) touch_and_remove_with_sudo(path string) ! {
	if command.touch_error != '' {
		return error(command.touch_error)
	}
	if command.native {
		touch := ruby.run_captured_command(['/usr/bin/sudo', 'touch', path], ruby.CapturedCommandOptions{ environment: ruby.environment() })!
		if touch.exit_code != 0 {
			return error(touch.stderr)
		}
	}
	if command.rm_error != '' {
		return error(command.rm_error)
	}
	if command.native {
		remove := ruby.run_captured_command(['/usr/bin/sudo', 'rm', path], ruby.CapturedCommandOptions{ environment: ruby.environment() })!
		if remove.exit_code != 0 {
			return error(remove.stderr)
		}
	}
}

fn cask_app_management_error(message string) ruby.Value {
	return ruby.structured_value('ErrorDuringExecution', message, {
		'message': message
		'stderr':  message
	})
}

fn cask_app_management_command_error(value ruby.Value, key string) string {
	if text := value.attributes[key] {
		return text
	}
	if raw := value.map_data[key] {
		return raw.as_string()
	}
	return ''
}

// Translated from Homebrew/brew `cask/quarantine.rb`.
