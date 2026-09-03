module cask

import brew_runtime
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

pub type QuarantineCommandRunner = fn(QuarantineCommand) !QuarantineCommandResult

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
	return brew_runtime.find_executable('xattr') or { return none }
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

pub fn quarantine_cask(_ brew_runtime.Value, _ ?string, _ bool) ! {
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
	input := paths.join('\0')
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
	result := brew_runtime.run_captured_command(argv, brew_runtime.CapturedCommandOptions{
		input: command.input
		environment: brew_runtime.environment()
	})!
	return QuarantineCommandResult{
		stdout: result.stdout
		stderr: result.stderr
		exit_code: result.exit_code
	}
}

fn quarantine_context_from_values(args []brew_runtime.Value) QuarantineContext {
	mut xattr := quarantine_xattr() or { '' }
	mut status := ''
	mut stderr := ''
	mut exit_code := 0
	for value in args {
		if value.type_name == 'Hash' {
			xattr = value.map_data['xattr'] or { brew_runtime.string_value(xattr) }.as_string()
			status = value.map_data['status'] or { brew_runtime.string_value(status) }.as_string()
			stderr = value.map_data['stderr'] or { brew_runtime.string_value(stderr) }.as_string()
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
			}return QuarantineCommandResult{ stderr: stderr, exit_code: exit_code }
		}
	}
}

fn quarantine_command_value(command QuarantineCommand) brew_runtime.Value {
	return brew_runtime.map_value({
		'executable': brew_runtime.string_value(command.executable)
		'args':       brew_runtime.string_array_value(command.args)
		'input':      brew_runtime.string_value(command.input)
		'sudo':       brew_runtime.bool_value(command.sudo)
	})
}

fn quarantine_error_value(message string) brew_runtime.Value {
	return brew_runtime.structured_value('Error', message, {
		'message': message
	})
}

fn quarantine_argument_string(args []brew_runtime.Value, index int) ?string {
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
		touch := brew_runtime.run_captured_command(['/usr/bin/sudo', 'touch', path], brew_runtime.CapturedCommandOptions{ environment: brew_runtime.environment() })!
		if touch.exit_code != 0 {
			return error(touch.stderr)
		}
	}
	if command.rm_error != '' {
		return error(command.rm_error)
	}
	if command.native {
		remove := brew_runtime.run_captured_command(['/usr/bin/sudo', 'rm', path], brew_runtime.CapturedCommandOptions{ environment: brew_runtime.environment() })!
		if remove.exit_code != 0 {
			return error(remove.stderr)
		}
	}
}

fn cask_app_management_error(message string) brew_runtime.Value {
	return brew_runtime.structured_value('ErrorDuringExecution', message, {
		'message': message
		'stderr':  message
	})
}

fn cask_app_management_command_error(value brew_runtime.Value, key string) string {
	if text := value.attributes[key] {
		return text
	}
	if raw := value.map_data[key] {
		return raw.as_string()
	}
	return ''
}

// Translated from Homebrew/brew `cask/quarantine.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.xattr` at line 24.
pub fn ruby_quarantine_l24_d1_self_xattr(args ...brew_runtime.Value) brew_runtime.Value {
	path := quarantine_xattr() or { return brew_runtime.Value{} }
	return brew_runtime.string_value(path)
}

// Ruby method `self.xattr_available?` at line 30.
pub fn ruby_quarantine_l30_d2_self_xattr_available(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(quarantine_xattr_available(quarantine_context_from_values(args)))
}

// Ruby method `self.check_quarantine_support` at line 38.
pub fn ruby_quarantine_l38_d3_self_check_quarantine_support(args ...brew_runtime.Value) brew_runtime.Value {
	support := quarantine_check_support()
	return brew_runtime.array_value([
		brew_runtime.string_value(support.kind.str()),
		brew_runtime.Value{},
	])
}

// Ruby method `self.available?` at line 43.
pub fn ruby_quarantine_l43_d4_self_available(args ...brew_runtime.Value) brew_runtime.Value {
	mut support := quarantine_check_support()
	if args.len > 0 && args[0].type_name == 'Bool' && args[0].bool_data {
		support = QuarantineSupport{ kind: .quarantine_available }
	}
	return brew_runtime.bool_value(quarantine_available(support))
}

// Ruby method `self.detect(file)` at line 50.
pub fn ruby_quarantine_l50_d5_self_detect(args ...brew_runtime.Value) brew_runtime.Value {
	file := quarantine_argument_string(args, 0)
	detected := quarantine_detect(file, quarantine_context_from_values(args)) or {
		return quarantine_error_value(err.msg())
	}
	if !detected.present {
		return brew_runtime.Value{}
	}
	return brew_runtime.bool_value(detected.value)
}

// Ruby method `self.status(file)` at line 63.
pub fn ruby_quarantine_l63_d6_self_status(args ...brew_runtime.Value) brew_runtime.Value {
	file := quarantine_argument_string(args, 0) or {
		return quarantine_error_value('status requires file')
	}
	status := quarantine_status(file, quarantine_context_from_values(args)) or {
		return quarantine_error_value(err.msg())
	}
	return brew_runtime.string_value(status)
}

// Ruby method `self.user_approved?(file)` at line 73.
pub fn ruby_quarantine_l73_d7_self_user_approved(args ...brew_runtime.Value) brew_runtime.Value {
	file := quarantine_argument_string(args, 0) or { return brew_runtime.bool_value(false) }
	approved := quarantine_user_approved(file, quarantine_context_from_values(args)) or {
		return quarantine_error_value(err.msg())
	}
	return brew_runtime.bool_value(approved)
}

// Ruby method `self.inherit_user_approval!(download_path: nil)` at line 83.
pub fn ruby_quarantine_l83_d8_self_inherit_user_approval(args ...brew_runtime.Value) brew_runtime.Value {
	path := quarantine_argument_string(args, 0)
	outcome := quarantine_inherit_user_approval(path, quarantine_context_from_values(args)) or {
		return quarantine_error_value(err.msg())
	}
	if !outcome.present {
		return brew_runtime.Value{}
	}
	return quarantine_command_value(outcome.command)
}

// Ruby method `self.signing_identity(_file); end` at line 111.
pub fn ruby_quarantine_l111_d9_self_signing_identity(args ...brew_runtime.Value) brew_runtime.Value {
	file := quarantine_argument_string(args, 0) or { '' }
	identity := quarantine_signing_identity(file) or { return brew_runtime.Value{} }
	return brew_runtime.structured_value('SigningIdentity', identity.requirement, {
		'requirement': identity.requirement
	})
}

// Ruby method `self.signing_identity_match(_file, _identity); end` at line 117.
pub fn ruby_quarantine_l117_d10_self_signing_identity_match(args ...brew_runtime.Value) brew_runtime.Value {
	file := quarantine_argument_string(args, 0) or { '' }
	requirement := quarantine_argument_string(args, 1) or { '' }
	matched := quarantine_signing_identity_match(file, QuarantineSigningIdentity{
		requirement: requirement
	}) or { return brew_runtime.Value{} }
	return brew_runtime.bool_value(matched)
}

// Ruby method `self.toggle_no_translocation_bit(attribute)` at line 120.
pub fn ruby_quarantine_l120_d11_self_toggle_no_translocation_bit(args ...brew_runtime.Value) brew_runtime.Value {
	attribute := quarantine_argument_string(args, 0) or { '' }
	return brew_runtime.string_value(quarantine_toggle_no_translocation_bit(attribute))
}

// Ruby method `self.release!(download_path: nil)` at line 134.
pub fn ruby_quarantine_l134_d12_self_release(args ...brew_runtime.Value) brew_runtime.Value {
	path := quarantine_argument_string(args, 0)
	outcome := quarantine_release(path, quarantine_context_from_values(args)) or {
		return quarantine_error_value(err.msg())
	}
	if !outcome.present {
		return brew_runtime.Value{}
	}
	return quarantine_command_value(outcome.command)
}

// Ruby method `self.cask!(cask: nil, download_path: nil, action: true)` at line 156.
pub fn ruby_quarantine_l156_d13_self_cask(args ...brew_runtime.Value) brew_runtime.Value {
	quarantine_cask(brew_runtime.Value{}, none, true) or {
		return quarantine_error_value(err.msg())
	}
	return brew_runtime.Value{}
}

// Ruby method `self.propagate(from: nil, to: nil)` at line 161.
pub fn ruby_quarantine_l161_d14_self_propagate(args ...brew_runtime.Value) brew_runtime.Value {
	from := quarantine_argument_string(args, 0)
	to := quarantine_argument_string(args, 1)
	outcome := quarantine_propagate(from, to, quarantine_context_from_values(args)) or {
		return quarantine_error_value(err.msg())
	}
	if !outcome.present {
		return brew_runtime.Value{}
	}
	return brew_runtime.map_value({
		'status': brew_runtime.string_value(outcome.result.status)
		'paths':  brew_runtime.string_array_value(outcome.result.paths)
	})
}

// Ruby method `self.copy_xattrs(from, to, command:)` at line 203.
pub fn ruby_quarantine_l203_d15_self_copy_xattrs(args ...brew_runtime.Value) brew_runtime.Value {
	from := quarantine_argument_string(args, 0) or { '' }
	to := quarantine_argument_string(args, 1) or { '' }
	quarantine_copy_xattrs(from, to, quarantine_native_runner) or {
		return quarantine_error_value(err.msg())
	}
	return brew_runtime.Value{}
}

// Ruby method `self.app_management_permissions_granted?(app:, command:)` at line 211.
pub fn ruby_quarantine_l211_d16_self_app_management_permissions_granted(args ...brew_runtime.Value) brew_runtime.Value {
	mut app := ''
	mut command_value := brew_runtime.Value{}
	for value in args {
		if value.type_name == 'Hash' {
			if raw := value.map_data['app'] {
				app = raw.as_string()
			}
			if raw := value.map_data['command'] {
				command_value = raw
			}
		} else if app == '' {
			app = value.as_string()
		}
	}
	if app == '' {
		return cask_app_management_error('app_management_permissions_granted? requires app')
	}
	command := CaskAppManagementPermissionCommand{
		touch_error: cask_app_management_command_error(command_value, 'touch_error')
		rm_error: cask_app_management_command_error(command_value, 'rm_error')
		native: command_value.type_name == ''
	}
	granted := brew_runtime.app_management_permissions_granted(app, command) or {
		return cask_app_management_error(err.msg())
	}
	if !granted && brew_runtime.environment_value('HOMEBREW_NO_APP_MANAGEMENT_PERMISSIONS_PROMPT') != '' {
		eprintln('Warning: Your terminal does not have App Management permissions, so Homebrew will delete and reinstall the app.\nThis may result in some configurations (like notification settings or location in the Dock/Launchpad) being lost.\nTo fix this, go to System Settings → Privacy & Security → App Management and add or enable your terminal.')
	}
	return brew_runtime.bool_value(granted)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "development_tools"
// 5: require "cask/exceptions"
// 6: require "system_command"
// 7: require "utils/output"
// 8:
// 9: module Cask
// 10:   # Helper module for quarantining files.
// 11:   module Quarantine
// 12:     extend SystemCommand::Mixin
// 13:     extend ::Utils::Output::Mixin
// 14:
// 15:     class SigningIdentity < T::Struct
// 16:       const :requirement, String
// 17:     end
// 18:
// 19:     QUARANTINE_ATTRIBUTE = "com.apple.quarantine"
// 20:     # https://github.com/apple-oss-distributions/WebKit/blob/WebKit-7618.2.12.11.6/Source/WebCore/PAL/pal/spi/mac/QuarantineSPI.h#L40-L45
// 21:     USER_APPROVED_FLAG = 0x0040
// 22:
// 23:     sig { returns(T.nilable(Pathname)) }
// 24:     def self.xattr
// 25:       @xattr ||= T.let(DevelopmentTools.locate("xattr"), T.nilable(Pathname))
// 26:     end
// 27:     private_class_method :xattr
// 28:
// 29:     sig { returns(T::Boolean) }
// 30:     def self.xattr_available?
// 31:       xattr = self.xattr
// 32:       return false if xattr.nil?
// 33:
// 34:       system_command(xattr, args: ["-h"], print_stderr: false).success?
// 35:     end
// 36:
// 37:     sig { returns([Symbol, T.nilable(String)]) }
// 38:     def self.check_quarantine_support
// 39:       [:quarantine_unavailable, nil]
// 40:     end
// 41:
// 42:     sig { returns(T::Boolean) }
// 43:     def self.available?
// 44:       @quarantine_support ||= T.let(check_quarantine_support, T.nilable([Symbol, T.nilable(String)]))
// 45:
// 46:       @quarantine_support[0] == :quarantine_available
// 47:     end
// 48:
// 49:     sig { params(file: T.nilable(T.any(String, Pathname))).returns(T.nilable(T::Boolean)) }
// 50:     def self.detect(file)
// 51:       return if file.nil?
// 52:
// 53:       odebug "Verifying Gatekeeper status of #{file}"
// 54:
// 55:       quarantine_status = !status(file).empty?
// 56:
// 57:       odebug "#{file} is #{quarantine_status ? "quarantined" : "not quarantined"}"
// 58:
// 59:       quarantine_status
// 60:     end
// 61:
// 62:     sig { params(file: T.any(String, Pathname)).returns(String) }
// 63:     def self.status(file)
// 64:       xattr = self.xattr
// 65:       raise "unexpected nil xattr" if xattr.nil?
// 66:
// 67:       system_command(xattr,
// 68:                      args:         ["-p", QUARANTINE_ATTRIBUTE, file],
// 69:                      print_stderr: false).stdout.rstrip
// 70:     end
// 71:
// 72:     sig { params(file: T.any(String, Pathname)).returns(T::Boolean) }
// 73:     def self.user_approved?(file)
// 74:       return false if xattr.nil?
// 75:
// 76:       quarantine_status = status(file)
// 77:       return false if quarantine_status.empty?
// 78:
// 79:       quarantine_status.split(";").fetch(0).to_i(16).anybits?(USER_APPROVED_FLAG)
// 80:     end
// 81:
// 82:     sig { params(download_path: T.nilable(Pathname)).void }
// 83:     def self.inherit_user_approval!(download_path: nil)
// 84:       return if !download_path || !detect(download_path)
// 85:
// 86:       # Preserve quarantine provenance so Gatekeeper still checks the upgraded app while carrying forward
// 87:       # the user's approval only after the upgrade path verifies that its signing identity is unchanged.
// 88:       # https://developer.apple.com/forums/thread/706442
// 89:       odebug "Inheriting user approval for #{download_path}"
// 90:
// 91:       xattr = self.xattr
// 92:       raise "unexpected nil xattr" if xattr.nil?
// 93:
// 94:       quarantiner = system_command(xattr,
// 95:                                    args:         [
// 96:                                      "-w",
// 97:                                      QUARANTINE_ATTRIBUTE,
// 98:                                      status(download_path).sub(/\A[0-9a-f]+/i) do |flags|
// 99:                                        (flags.to_i(16) | USER_APPROVED_FLAG).to_s(16).rjust(flags.length, "0")
// 100:                                      end,
// 101:                                      download_path,
// 102:                                    ],
// 103:                                    print_stderr: false)
// 104:
// 105:       return if quarantiner.success?
// 106:
// 107:       raise CaskQuarantineReleaseError.new(download_path, quarantiner.stderr)
// 108:     end
// 109:
// 110:     sig { params(_file: T.any(String, Pathname)).returns(T.nilable(SigningIdentity)) }
// 111:     def self.signing_identity(_file); end
// 112:
// 113:     sig {
// 114:       params(_file: T.any(String, Pathname), _identity: SigningIdentity)
// 115:         .returns(T.nilable(T::Boolean))
// 116:     }
// 117:     def self.signing_identity_match(_file, _identity); end
// 118:
// 119:     sig { params(attribute: String).returns(String) }
// 120:     def self.toggle_no_translocation_bit(attribute)
// 121:       fields = attribute.split(";")
// 122:
// 123:       # Fields: status, epoch, download agent, event ID
// 124:       # Let's toggle the app translocation bit, bit 8
// 125:       # http://www.openradar.me/radar?id=5022734169931776
// 126:
// 127:       fields[0] = (fields.fetch(0).to_i(16) | 0x0100).to_s(16).rjust(4, "0")
// 128:
// 129:       fields.join(";")
// 130:     end
// 131:
// 132:     # Fully remove quarantine only when explicitly requested; upgrades preserve it and inherit approval above.
// 133:     sig { params(download_path: T.nilable(Pathname)).void }
// 134:     def self.release!(download_path: nil)
// 135:       return if !download_path || !detect(download_path)
// 136:
// 137:       odebug "Releasing #{download_path} from quarantine"
// 138:
// 139:       xattr = self.xattr
// 140:       raise "unexpected nil xattr" if xattr.nil?
// 141:
// 142:       quarantiner = system_command(xattr,
// 143:                                    args:         [
// 144:                                      "-d",
// 145:                                      QUARANTINE_ATTRIBUTE,
// 146:                                      download_path,
// 147:                                    ],
// 148:                                    print_stderr: false)
// 149:
// 150:       return if quarantiner.success?
// 151:
// 152:       raise CaskQuarantineReleaseError.new(download_path, quarantiner.stderr)
// 153:     end
// 154:
// 155:     sig { params(cask: T.nilable(Cask), download_path: T.nilable(Pathname), action: T::Boolean).void }
// 156:     def self.cask!(cask: nil, download_path: nil, action: true)
// 157:       raise NotImplementedError
// 158:     end
// 159:
// 160:     sig { params(from: T.nilable(Pathname), to: T.nilable(Pathname)).void }
// 161:     def self.propagate(from: nil, to: nil)
// 162:       return if from.nil? || to.nil?
// 163:
// 164:       raise CaskError, "#{from} was not quarantined properly." unless detect(from)
// 165:
// 166:       odebug "Propagating quarantine from #{from} to #{to}"
// 167:
// 168:       quarantine_status = toggle_no_translocation_bit(status(from))
// 169:
// 170:       resolved_paths = Pathname.glob(to/"**/*", File::FNM_DOTMATCH).reject(&:symlink?)
// 171:
// 172:       system_command!("/usr/bin/xargs",
// 173:                       args:  [
// 174:                         "-0",
// 175:                         "--",
// 176:                         "chmod",
// 177:                         "-h",
// 178:                         "u+w",
// 179:                       ],
// 180:                       input: resolved_paths.join("\0"))
// 181:
// 182:       xattr = self.xattr
// 183:       raise "unexpected nil xattr" if xattr.nil?
// 184:
// 185:       quarantiner = system_command("/usr/bin/xargs",
// 186:                                    args:         [
// 187:                                      "-0",
// 188:                                      "--",
// 189:                                      xattr,
// 190:                                      "-w",
// 191:                                      QUARANTINE_ATTRIBUTE,
// 192:                                      quarantine_status,
// 193:                                    ],
// 194:                                    input:        resolved_paths.join("\0"),
// 195:                                    print_stderr: false)
// 196:
// 197:       return if quarantiner.success?
// 198:
// 199:       raise CaskQuarantinePropagationError.new(to, quarantiner.stderr)
// 200:     end
// 201:
// 202:     sig { params(from: Pathname, to: Pathname, command: T.class_of(SystemCommand)).void }
// 203:     def self.copy_xattrs(from, to, command:)
// 204:       raise NotImplementedError
// 205:     end
// 206:
// 207:     # Ensures that Homebrew has permission to update apps on macOS Ventura.
// 208:     # This may be granted either through the App Management toggle or the Full Disk Access toggle.
// 209:     # The system will only show a prompt for App Management, so we ask the user to grant that.
// 210:     sig { params(app: Pathname, command: T.class_of(SystemCommand)).returns(T::Boolean) }
// 211:     def self.app_management_permissions_granted?(app:, command:)
// 212:       return true unless app.directory?
// 213:
// 214:       # To get macOS to prompt the user for permissions, we need to actually attempt to
// 215:       # modify a file in the app.
// 216:       test_file = app/".homebrew-write-test"
// 217:
// 218:       # We can't use app.writable? here because that conflates several access checks,
// 219:       # including both file ownership and whether system permissions are granted.
// 220:       # Here we just want to check whether sudo would be needed.
// 221:       looks_writable_without_sudo = if app.owned?
// 222:         app.lstat.mode.anybits?(0200)
// 223:       elsif app.grpowned?
// 224:         app.lstat.mode.anybits?(0020)
// 225:       else
// 226:         app.lstat.mode.anybits?(0002)
// 227:       end
// 228:
// 229:       if looks_writable_without_sudo
// 230:         begin
// 231:           File.write(test_file, "")
// 232:           test_file.delete
// 233:           return true
// 234:         rescue Errno::EACCES, Errno::EPERM
// 235:           # Using error handler below
// 236:         end
// 237:       else
// 238:         begin
// 239:           command.run!(
// 240:             "touch",
// 241:             args:         [
// 242:               test_file,
// 243:             ],
// 244:             print_stderr: false,
// 245:             sudo:         true,
// 246:           )
// 247:           command.run!(
// 248:             "rm",
// 249:             args:         [
// 250:               test_file,
// 251:             ],
// 252:             print_stderr: false,
// 253:             sudo:         true,
// 254:           )
// 255:           return true
// 256:         rescue ErrorDuringExecution => e
// 257:           # We only want to handle "touch" errors here; propagate "sudo" errors up
// 258:           raise e unless e.stderr.include?("touch: #{test_file}: Operation not permitted")
// 259:         end
// 260:       end
// 261:
// 262:       # Allow undocumented way to skip the prompt.
// 263:       if ENV["HOMEBREW_NO_APP_MANAGEMENT_PERMISSIONS_PROMPT"]
// 264:         opoo <<~EOF
// 265:           Your terminal does not have App Management permissions, so Homebrew will delete and reinstall the app.
// 266:           This may result in some configurations (like notification settings or location in the Dock/Launchpad) being lost.
// 267:           To fix this, go to System Settings → Privacy & Security → App Management and add or enable your terminal.
// 268:         EOF
// 269:       end
// 270:
// 271:       false
// 272:     end
// 273:   end
// 274: end
// 275:
// 276: require "extend/os/cask/quarantine"
