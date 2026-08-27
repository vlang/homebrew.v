module system

import brew_runtime

// Translated from Homebrew/brew `services/system/systemctl.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.executable` at line 9.
pub fn ruby_systemctl_l9_d1_self_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.executable', ...args)
}

// Ruby attr_writer `attr_writer :executable` at line 15.
pub fn ruby_systemctl_l15_d2_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('executable=', ...args)
}

// Ruby method `self.scope` at line 19.
pub fn ruby_systemctl_l19_d3_self_scope(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.scope', ...args)
}

// Ruby method `self.run(*args)` at line 24.
pub fn ruby_systemctl_l24_d4_self_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.run', ...args)
}

// Ruby method `self.quiet_run(*args)` at line 29.
pub fn ruby_systemctl_l29_d5_self_quiet_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.quiet_run', ...args)
}

// Ruby method `self.popen_read(*args)` at line 34.
pub fn ruby_systemctl_l34_d6_self_popen_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.popen_read', ...args)
}

// Ruby method `self._run(*args, mode:)` at line 39.
pub fn ruby_systemctl_l39_d7_self_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self._run', ...args)
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
