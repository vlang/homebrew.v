module services

import brew_runtime

// Translated from Homebrew/brew `services/system.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.launchctl` at line 19.
pub fn ruby_system_l19_d1_self_launchctl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.launchctl', ...args)
}

// Ruby attr_writer `attr_writer :launchctl` at line 25.
pub fn ruby_system_l25_d2_launchctl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('launchctl=', ...args)
}

// Ruby method `self.launchctl?` at line 30.
pub fn ruby_system_l30_d3_self_launchctl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.launchctl?', ...args)
}

// Ruby method `self.systemctl?` at line 36.
pub fn ruby_system_l36_d4_self_systemctl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.systemctl?', ...args)
}

// Ruby method `self.root?` at line 42.
pub fn ruby_system_l42_d5_self_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.root?', ...args)
}

// Ruby method `self.user` at line 48.
pub fn ruby_system_l48_d6_self_user(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.user', ...args)
}

// Ruby method `self.user_exists?(username)` at line 53.
pub fn ruby_system_l53_d7_self_user_exists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.user_exists?', ...args)
}

// Ruby method `self.boot_path` at line 66.
pub fn ruby_system_l66_d8_self_boot_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.boot_path', ...args)
}

// Ruby method `self.user_path` at line 78.
pub fn ruby_system_l78_d9_self_user_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.user_path', ...args)
}

// Ruby method `self.path` at line 90.
pub fn ruby_system_l90_d10_self_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.path', ...args)
}

// Ruby method `self.domain_target` at line 95.
pub fn ruby_system_l95_d11_self_domain_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.domain_target', ...args)
}

// Ruby method `self.candidate_domain_targets` at line 123.
pub fn ruby_system_l123_d12_self_candidate_domain_targets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.candidate_domain_targets', ...args)
}

// Ruby method `self.launchctl_find_service(label, sudo: false)` at line 134.
pub fn ruby_system_l134_d13_self_launchctl_find_service(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.launchctl_find_service', ...args)
}

// Ruby method `self.launchctl_service_running?(label, sudo: false)` at line 156.
pub fn ruby_system_l156_d14_self_launchctl_service_running(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.launchctl_service_running?', ...args)
}

// Ruby method `self.launchctl_run(cmd, sudo:)` at line 163.
pub fn ruby_system_l163_d15_self_launchctl_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.launchctl_run', ...args)
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
