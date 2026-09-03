module services

import brew_runtime
import os

#include <pwd.h>

struct C.passwd {}

fn C.getpwnam(name &char) &C.passwd

// Translated from Homebrew/brew `services/system.rb`.
// The original source is retained below for source-level traceability.
pub const launchctl_domain_action_not_supported = 125

pub struct ServiceSystemConfig {
pub:
	path_environment     string
	home                 string
	user                 string
	launchctl_path       string
	launchctl_overridden bool
	systemctl_path       string
	systemctl_overridden bool
	root                 bool
	root_overridden      bool
	uid                  int = -1
	euid                 int = -1
	ssh_tty              string
	sudo_user            string
	no_domain_warning    bool
	no_env_hints         bool
	console_uid          int = -1
}

@[heap]
pub struct ServiceSystem {
pub:
	path_environment  string
	home              string
	configured_user   string
	root_overridden   bool
	configured_root   bool
	uid               int
	euid              int
	ssh_tty           string
	sudo_user         string
	no_domain_warning bool
	no_env_hints      bool
	console_uid       int
pub mut:
	launchctl_path     string
	launchctl_resolved bool
	systemctl_path     string
	systemctl_resolved bool
	user_name          string
	user_resolved      bool
	output_warning     bool
	warnings           []string
}

pub enum LaunchctlCommandType {
	launchctl_print
	launchctl_list
}

pub struct LaunchctlRunResult {
pub:
	output  string
	success bool
}

pub struct LaunchctlFindResult {
pub:
	output       string
	success      bool
	command_type LaunchctlCommandType
}

pub type LaunchctlRunner = fn([]string, bool) LaunchctlRunResult

pub fn new_service_system(config ServiceSystemConfig) &ServiceSystem {
	path_environment := if config.path_environment != '' {
		config.path_environment
	} else {
		os.getenv('PATH')
	}
	home := if config.home != '' {
		config.home
	} else if os.getenv('HOME') != '' {
		os.getenv('HOME')
	} else {
		os.home_dir()
	}
	uid := if config.uid >= 0 { config.uid } else { os.getuid() }
	euid := if config.euid >= 0 { config.euid } else { os.geteuid() }
	mut console_uid := config.console_uid
	if console_uid < 0 && os.exists('/dev/console') {
		if stat := os.stat('/dev/console') {
			console_uid = int(stat.uid)
		}
	}
	return &ServiceSystem{
		path_environment: path_environment
		home: home
		configured_user: config.user
		root_overridden: config.root_overridden
		configured_root: config.root
		uid: uid
		euid: euid
		ssh_tty: config.ssh_tty
		sudo_user: config.sudo_user
		no_domain_warning: config.no_domain_warning
		no_env_hints: config.no_env_hints
		console_uid: console_uid
		launchctl_path: config.launchctl_path
		launchctl_resolved: config.launchctl_overridden
		systemctl_path: config.systemctl_path
		systemctl_resolved: config.systemctl_overridden
	}
}

fn executable_in_path(name string, path_environment string) ?string {
	for directory in path_environment.split(os.path_delimiter) {
		if directory == '' {
			continue
		}
		candidate := os.join_path(directory, name)
		if os.is_file(candidate) && os.is_executable(candidate) {
			return candidate
		}
	}
	return none
}

pub fn (mut system ServiceSystem) launchctl() ?string {
	if !system.launchctl_resolved {
		system.launchctl_path = executable_in_path('launchctl', system.path_environment) or { '' }
		system.launchctl_resolved = true
	}
	return if system.launchctl_path == '' { none } else { system.launchctl_path }
}

pub fn (mut system ServiceSystem) set_launchctl(path ?string) ?string {
	system.launchctl_path = path or { '' }
	system.launchctl_resolved = true
	return path
}

pub fn (mut system ServiceSystem) launchctl_available() bool {
	return system.launchctl() != none
}

pub fn (mut system ServiceSystem) systemctl_available() bool {
	if !system.systemctl_resolved {
		system.systemctl_path = executable_in_path('systemctl', system.path_environment) or { '' }
		system.systemctl_resolved = true
	}
	return system.systemctl_path != ''
}

pub fn (system ServiceSystem) root() bool {
	return if system.root_overridden { system.configured_root } else { system.euid == 0 }
}

pub fn (mut system ServiceSystem) user() string {
	if !system.user_resolved {
		system.user_name = system.configured_user
		if system.user_name == '' {
			system.user_name = os.getenv('USER')
		}
		if system.user_name == '' {
			result := brew_runtime.run_captured_command(['/usr/bin/whoami'], brew_runtime.CapturedCommandOptions{}) or {
				brew_runtime.CapturedCommandResult{}
			}
			system.user_name = chomp_command_output(result.stdout)
		}
		system.user_resolved = true
	}
	return system.user_name
}

pub fn (mut system ServiceSystem) user_exists(username string) bool {
	if username == system.user() {
		return true
	}
	$if windows {
		return false
	} $else {
		return !isnil(C.getpwnam(username.str))
	}
}

pub fn (mut system ServiceSystem) boot_path() !string {
	if system.launchctl_available() {
		return '/Library/LaunchDaemons'
	}
	if system.systemctl_available() {
		return '/usr/lib/systemd/system'
	}
	return error(missing_daemon_manager_exception_message)
}

pub fn (mut system ServiceSystem) user_path() !string {
	if system.launchctl_available() {
		return os.join_path(system.home, 'Library', 'LaunchAgents')
	}
	if system.systemctl_available() {
		return os.join_path(system.home, '.config', 'systemd', 'user')
	}
	return error(missing_daemon_manager_exception_message)
}

pub fn (mut system ServiceSystem) path() !string {
	return if system.root() { system.boot_path()! } else { system.user_path()! }
}

pub fn (mut system ServiceSystem) domain_target() string {
	if system.root() {
		return 'system'
	}
	ssh_tty := system.ssh_tty != '' && system.console_uid != system.uid
	sudo_user := system.sudo_user != ''
	if ssh_tty || sudo_user || system.uid != system.euid {
		if !system.output_warning && !system.no_domain_warning {
			warning := if ssh_tty {
				'running over SSH without /dev/console ownership, using user/* instead of gui/* domain!'
			} else if sudo_user {
				'running through sudo, using user/* instead of gui/* domain!'
			} else {
				'uid and euid do not match, using user/* instead of gui/* domain!'
			}
			system.warnings << warning
			if !system.no_env_hints {
				system.warnings << 'Hide this warning by setting `HOMEBREW_SERVICES_NO_DOMAIN_WARNING=1`.'
				system.warnings << 'Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).'
			}
			system.output_warning = true
		}
		return 'user/${system.euid}'
	}
	return 'gui/${system.uid}'
}

pub fn (mut system ServiceSystem) candidate_domain_targets() []string {
	mut candidates := [system.domain_target()]
	if !system.root() {
		for candidate in ['user/${system.euid}', 'gui/${system.uid}'] {
			if candidate !in candidates {
				candidates << candidate
			}
		}
	}
	return candidates
}

pub fn (mut system ServiceSystem) launchctl_find_service(label string, sudo bool,
	runner LaunchctlRunner) LaunchctlFindResult {
	launchctl_path := system.launchctl() or {
		return LaunchctlFindResult{
			command_type: .launchctl_list
		}
	}
	for domain in system.candidate_domain_targets() {
		result := runner([launchctl_path, 'print', '${domain}/${label}'], sudo)
		if result.success && result.output != '' {
			return LaunchctlFindResult{
				output: result.output
				success: true
				command_type: .launchctl_print
			}
		}
	}
	result := runner([launchctl_path, 'list', label], sudo)
	return LaunchctlFindResult{
		output: result.output
		success: result.success && result.output != ''
		command_type: .launchctl_list
	}
}

pub fn (mut system ServiceSystem) launchctl_service_running(label string, sudo bool,
	runner LaunchctlRunner) bool {
	return system.launchctl_find_service(label, sudo, runner).success
}

fn chomp_command_output(output string) string {
	if output.ends_with('\r\n') {
		return output[..output.len - 2]
	}
	if output.ends_with('\n') || output.ends_with('\r') {
		return output[..output.len - 1]
	}
	return output
}

pub fn launchctl_run(command []string, sudo bool) LaunchctlRunResult {
	if command.len == 0 {
		return LaunchctlRunResult{}
	}
	mut argv := command.clone()
	if sudo {
		sudo_path := if os.is_executable('/usr/bin/sudo') { '/usr/bin/sudo' } else { 'sudo' }
		argv = [sudo_path, '--']
		argv << command
	}
	result := brew_runtime.run_captured_command(argv, brew_runtime.CapturedCommandOptions{}) or {
		return LaunchctlRunResult{}
	}
	return LaunchctlRunResult{
		output: chomp_command_output(result.stdout)
		success: result.exit_code == 0
	}
}

pub fn launchctl_find_service_native(mut system ServiceSystem, label string,
	sudo bool) LaunchctlFindResult {
	return system.launchctl_find_service(label, sudo, launchctl_run)
}

fn service_system_value(system &ServiceSystem) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::Services::System', 'System', {
		'system_address': u64(voidptr(system)).str()
	})
}

pub fn service_system_boundary(system &ServiceSystem) brew_runtime.Value {
	return service_system_value(system)
}

fn service_system_from_args(args []brew_runtime.Value) (&ServiceSystem, int) {
	if args.len > 0 && args[0].type_name == 'Homebrew::Services::System' {
		address := args[0].attributes['system_address'] or { panic('translated System state is missing') }
		return unsafe { &ServiceSystem(voidptr(address.u64())) }, 1
	}
	return new_service_system(ServiceSystemConfig{}), 0
}

fn launchctl_find_result_value(result LaunchctlFindResult) brew_runtime.Value {
	type_name := if result.command_type == .launchctl_print {
		'launchctl_print'
	} else {
		'launchctl_list'
	}
	return brew_runtime.array_value([
		brew_runtime.string_value(result.output),
		brew_runtime.bool_value(result.success),
		brew_runtime.object_value('Symbol', type_name),
	])
}

fn launchctl_run_result_value(result LaunchctlRunResult) brew_runtime.Value {
	return brew_runtime.array_value([
		brew_runtime.string_value(result.output),
		brew_runtime.bool_value(result.success),
	])
}

// Ruby method `self.launchctl` at line 19.
pub fn ruby_system_l19_d1_self_launchctl(args ...brew_runtime.Value) brew_runtime.Value {
	mut system, _ := service_system_from_args(args)
	return if path := system.launchctl() {
		brew_runtime.object_value('Pathname', path)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby attr_writer `attr_writer :launchctl` at line 25.
pub fn ruby_system_l25_d2_launchctl(args ...brew_runtime.Value) brew_runtime.Value {
	mut system, offset := service_system_from_args(args)
	if args.len <= offset || args[offset].type_name == 'NilClass' {
		system.set_launchctl(none)
		return brew_runtime.object_value('NilClass', 'nil')
	}
	system.set_launchctl(args[offset].as_string())
	return brew_runtime.object_value('Pathname', args[offset].as_string())
}

// Ruby method `self.launchctl?` at line 30.
pub fn ruby_system_l30_d3_self_launchctl(args ...brew_runtime.Value) brew_runtime.Value {
	mut system, _ := service_system_from_args(args)
	return brew_runtime.bool_value(system.launchctl_available())
}

// Ruby method `self.systemctl?` at line 36.
pub fn ruby_system_l36_d4_self_systemctl(args ...brew_runtime.Value) brew_runtime.Value {
	mut system, _ := service_system_from_args(args)
	return brew_runtime.bool_value(system.systemctl_available())
}

// Ruby method `self.root?` at line 42.
pub fn ruby_system_l42_d5_self_root(args ...brew_runtime.Value) brew_runtime.Value {
	system, _ := service_system_from_args(args)
	return brew_runtime.bool_value(system.root())
}

// Ruby method `self.user` at line 48.
pub fn ruby_system_l48_d6_self_user(args ...brew_runtime.Value) brew_runtime.Value {
	mut system, _ := service_system_from_args(args)
	return brew_runtime.string_value(system.user())
}

// Ruby method `self.user_exists?(username)` at line 53.
pub fn ruby_system_l53_d7_self_user_exists(args ...brew_runtime.Value) brew_runtime.Value {
	mut system, offset := service_system_from_args(args)
	if args.len <= offset {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(system.user_exists(args[offset].as_string()))
}

// Ruby method `self.boot_path` at line 66.
pub fn ruby_system_l66_d8_self_boot_path(args ...brew_runtime.Value) !brew_runtime.Value {
	mut system, _ := service_system_from_args(args)
	return brew_runtime.object_value('Pathname', system.boot_path()!)
}

// Ruby method `self.user_path` at line 78.
pub fn ruby_system_l78_d9_self_user_path(args ...brew_runtime.Value) !brew_runtime.Value {
	mut system, _ := service_system_from_args(args)
	return brew_runtime.object_value('Pathname', system.user_path()!)
}

// Ruby method `self.path` at line 90.
pub fn ruby_system_l90_d10_self_path(args ...brew_runtime.Value) !brew_runtime.Value {
	mut system, _ := service_system_from_args(args)
	return brew_runtime.object_value('Pathname', system.path()!)
}

// Ruby method `self.domain_target` at line 95.
pub fn ruby_system_l95_d11_self_domain_target(args ...brew_runtime.Value) brew_runtime.Value {
	mut system, _ := service_system_from_args(args)
	return brew_runtime.string_value(system.domain_target())
}

// Ruby method `self.candidate_domain_targets` at line 123.
pub fn ruby_system_l123_d12_self_candidate_domain_targets(args ...brew_runtime.Value) brew_runtime.Value {
	mut system, _ := service_system_from_args(args)
	return brew_runtime.string_array_value(system.candidate_domain_targets())
}

// Ruby method `self.launchctl_find_service(label, sudo: false)` at line 134.
pub fn ruby_system_l134_d13_self_launchctl_find_service(args ...brew_runtime.Value) brew_runtime.Value {
	mut system, offset := service_system_from_args(args)
	label := if args.len > offset { args[offset].as_string() } else { '' }
	sudo := args.len > offset + 1 && (args[offset + 1].as_bool() or { false })
	return launchctl_find_result_value(system.launchctl_find_service(label, sudo, launchctl_run))
}

// Ruby method `self.launchctl_service_running?(label, sudo: false)` at line 156.
pub fn ruby_system_l156_d14_self_launchctl_service_running(args ...brew_runtime.Value) brew_runtime.Value {
	mut system, offset := service_system_from_args(args)
	label := if args.len > offset { args[offset].as_string() } else { '' }
	sudo := args.len > offset + 1 && (args[offset + 1].as_bool() or { false })
	return brew_runtime.bool_value(system.launchctl_service_running(label, sudo, launchctl_run))
}

// Ruby method `self.launchctl_run(cmd, sudo:)` at line 163.
pub fn ruby_system_l163_d15_self_launchctl_run(args ...brew_runtime.Value) brew_runtime.Value {
	_, offset := service_system_from_args(args)
	command := if args.len > offset {
		args[offset].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	sudo := args.len > offset + 1 && (args[offset + 1].as_bool() or { false })
	return launchctl_run_result_value(launchctl_run(command, sudo))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "etc"
// 5: require "system_command"
// 6: require_relative "system/systemctl"
// 7: require "utils/output"
// 8:
// 9: module Homebrew
// 10:   module Services
// 11:     module System
// 12:       extend Utils::Output::Mixin
// 13:
// 14:       LAUNCHCTL_DOMAIN_ACTION_NOT_SUPPORTED = 125
// 15:       MISSING_DAEMON_MANAGER_EXCEPTION_MESSAGE = "`brew services` is supported only on macOS or Linux (with systemd)!"
// 16:
// 17:       # Path to launchctl binary.
// 18:       sig { returns(T.nilable(Pathname)) }
// 19:       def self.launchctl
// 20:         @launchctl ||= T.let(which("launchctl"), T.nilable(Pathname))
// 21:       end
// 22:
// 23:       class << self
// 24:         sig { params(launchctl: T.nilable(Pathname)).returns(T.nilable(Pathname)) }
// 25:         attr_writer :launchctl
// 26:       end
// 27:
// 28:       # Is this a launchctl system
// 29:       sig { returns(T::Boolean) }
// 30:       def self.launchctl?
// 31:         launchctl.present?
// 32:       end
// 33:
// 34:       # Is this a systemd system
// 35:       sig { returns(T::Boolean) }
// 36:       def self.systemctl?
// 37:         Systemctl.executable.present?
// 38:       end
// 39:
// 40:       # Woohoo, we are root dude!
// 41:       sig { returns(T::Boolean) }
// 42:       def self.root?
// 43:         Process.euid.zero?
// 44:       end
// 45:
// 46:       # Current user running `[sudo] brew services`.
// 47:       sig { returns(T.nilable(String)) }
// 48:       def self.user
// 49:         @user ||= T.let(ENV["USER"].presence || Utils.safe_popen_read("/usr/bin/whoami").chomp, T.nilable(String))
// 50:       end
// 51:
// 52:       sig { params(username: String).returns(T::Boolean) }
// 53:       def self.user_exists?(username)
// 54:         # Current user must be present
// 55:         return true if username == user
// 56:
// 57:         # Check other users
// 58:         Etc.getpwnam(username)
// 59:         true
// 60:       rescue ArgumentError
// 61:         false
// 62:       end
// 63:
// 64:       # Run at boot.
// 65:       sig { returns(Pathname) }
// 66:       def self.boot_path
// 67:         if launchctl?
// 68:           Pathname.new("/Library/LaunchDaemons")
// 69:         elsif systemctl?
// 70:           Pathname.new("/usr/lib/systemd/system")
// 71:         else
// 72:           raise UsageError, MISSING_DAEMON_MANAGER_EXCEPTION_MESSAGE
// 73:         end
// 74:       end
// 75:
// 76:       # Run at login.
// 77:       sig { returns(Pathname) }
// 78:       def self.user_path
// 79:         if launchctl?
// 80:           Pathname.new("#{Dir.home}/Library/LaunchAgents")
// 81:         elsif systemctl?
// 82:           Pathname.new("#{Dir.home}/.config/systemd/user")
// 83:         else
// 84:           raise UsageError, MISSING_DAEMON_MANAGER_EXCEPTION_MESSAGE
// 85:         end
// 86:       end
// 87:
// 88:       # If root, return `boot_path`, else return `user_path`.
// 89:       sig { returns(Pathname) }
// 90:       def self.path
// 91:         root? ? boot_path : user_path
// 92:       end
// 93:
// 94:       sig { returns(String) }
// 95:       def self.domain_target
// 96:         if root?
// 97:           "system"
// 98:         elsif (ssh_tty = ENV.fetch("HOMEBREW_SSH_TTY", nil).present? &&
// 99:                File.stat("/dev/console").uid != Process.uid) ||
// 100:               (sudo_user = ENV.fetch("HOMEBREW_SUDO_USER", nil).present?) ||
// 101:               (Process.uid != Process.euid)
// 102:           if @output_warning.blank? && ENV.fetch("HOMEBREW_SERVICES_NO_DOMAIN_WARNING", nil).blank?
// 103:             if ssh_tty
// 104:               opoo "running over SSH without /dev/console ownership, using user/* instead of gui/* domain!"
// 105:             elsif sudo_user
// 106:               opoo "running through sudo, using user/* instead of gui/* domain!"
// 107:             else
// 108:               opoo "uid and euid do not match, using user/* instead of gui/* domain!"
// 109:             end
// 110:             unless Homebrew::EnvConfig.no_env_hints?
// 111:               $stderr.puts "Hide this warning by setting `HOMEBREW_SERVICES_NO_DOMAIN_WARNING=1`."
// 112:               $stderr.puts "Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`)."
// 113:             end
// 114:             @output_warning = T.let(true, T.nilable(TrueClass))
// 115:           end
// 116:           "user/#{Process.euid}"
// 117:         else
// 118:           "gui/#{Process.uid}"
// 119:         end
// 120:       end
// 121:
// 122:       sig { returns(T::Array[String]) }
// 123:       def self.candidate_domain_targets
// 124:         candidates = [domain_target]
// 125:         candidates += ["user/#{Process.euid}", "gui/#{Process.uid}"] unless root?
// 126:         candidates.uniq
// 127:       end
// 128:
// 129:       # Probe for a launchd service across all candidate domains.
// 130:       # Returns output text, success flag, and the command type used
// 131:       # (`:launchctl_print` or `:launchctl_list`). Pass `sudo: true` to run
// 132:       # the probe with elevated privileges (e.g. for system-owned services).
// 133:       sig { params(label: String, sudo: T::Boolean).returns([String, T::Boolean, Symbol]) }
// 134:       def self.launchctl_find_service(label, sudo: false)
// 135:         launchctl_path = launchctl
// 136:         return ["", false, :launchctl_list] unless launchctl_path
// 137:
// 138:         candidate_domain_targets.each do |domain|
// 139:           cmd = [launchctl_path.to_s, "print", "#{domain}/#{label}"]
// 140:           output, success = launchctl_run(cmd, sudo:)
// 141:           if success && output.present?
// 142:             odebug cmd.join(" "), output
// 143:             return [output, true, :launchctl_print]
// 144:           end
// 145:         end
// 146:
// 147:         cmd = [launchctl_path.to_s, "list", label]
// 148:         output, success = launchctl_run(cmd, sudo:)
// 149:         odebug cmd.join(" "), output
// 150:         [output, success && output.present?, :launchctl_list]
// 151:       end
// 152:
// 153:       # Check if a launchd service is running, given its label (e.g. `homebrew.mxcl.foo`).
// 154:       # Tries domain-qualified lookups first, then falls back to a bare label search.
// 155:       sig { params(label: String, sudo: T::Boolean).returns(T::Boolean) }
// 156:       def self.launchctl_service_running?(label, sudo: false)
// 157:         _, success, = launchctl_find_service(label, sudo:)
// 158:         success
// 159:       end
// 160:
// 161:       # Run a launchctl command, optionally via sudo, capturing its output.
// 162:       sig { params(cmd: T::Array[String], sudo: T::Boolean).returns([String, T::Boolean]) }
// 163:       def self.launchctl_run(cmd, sudo:)
// 164:         if sudo
// 165:           result = SystemCommand.run(
// 166:             cmd.fetch(0),
// 167:             args:         cmd.drop(1),
// 168:             sudo:         true,
// 169:             sudo_as_root: true,
// 170:             print_stderr: false,
// 171:           )
// 172:           [result.stdout.chomp, result.success?]
// 173:         else
// 174:           output = Utils.popen_read(*cmd).chomp
// 175:           [output, ($CHILD_STATUS.present? && $CHILD_STATUS.success?) || false]
// 176:         end
// 177:       end
// 178:       private_class_method :launchctl_run
// 179:     end
// 180:   end
// 181: end
