module linux

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/sandbox.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `allow_write_temp_and_cache` at line 18.
pub fn ruby_sandbox_l18_d1_allow_write_temp_and_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allow_write_temp_and_cache', ...args)
}

// Ruby method `allow_cvs` at line 26.
pub fn ruby_sandbox_l26_d2_allow_cvs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allow_cvs', ...args)
}

// Ruby method `allow_fossil` at line 32.
pub fn ruby_sandbox_l32_d3_allow_fossil(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allow_fossil', ...args)
}

// Ruby method `available?` at line 45.
pub fn ruby_sandbox_l45_d4_available(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('available?', ...args)
}

// Ruby method `full_write_isolation?` at line 50.
pub fn ruby_sandbox_l50_d5_full_write_isolation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('full_write_isolation?', ...args)
}

// Ruby method `state` at line 55.
pub fn ruby_sandbox_l55_d6_state(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('state', ...args)
}

// Ruby method `reset_state!` at line 60.
pub fn ruby_sandbox_l60_d7_reset_state(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset_state!', ...args)
}

// Ruby method `failure_reason` at line 65.
pub fn ruby_sandbox_l65_d8_failure_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('failure_reason', ...args)
}

// Ruby method `terminal_ioctl_request` at line 73.
pub fn ruby_sandbox_l73_d9_terminal_ioctl_request(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('terminal_ioctl_request', ...args)
}

// Ruby method `run(*args)` at line 79.
pub fn ruby_sandbox_l79_d10_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `sandbox_command(args, tmpdir)` at line 86.
pub fn ruby_sandbox_l86_d11_sandbox_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sandbox_command', ...args)
}

// Ruby method `apply_sandbox` at line 91.
pub fn ruby_sandbox_l91_d12_apply_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('apply_sandbox', ...args)
}

// Ruby method `landlock` at line 96.
pub fn ruby_sandbox_l96_d13_landlock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('landlock', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/os/linux/sandbox/landlock"
// 5:
// 6: module OS
// 7:   module Linux
// 8:     module Sandbox
// 9:       extend T::Helpers
// 10:
// 11:       requires_ancestor { ::Sandbox }
// 12:
// 13:       # `TIOCSCTTY` from `<asm-generic/ioctls.h>`; Ruby does not expose it.
// 14:       TIOCSCTTY = 0x540E
// 15:       private_constant :TIOCSCTTY
// 16:
// 17:       sig { void }
// 18:       def allow_write_temp_and_cache
// 19:         allow_write_path "/tmp"
// 20:         allow_write_path "/var/tmp"
// 21:         allow_write_path HOMEBREW_TEMP
// 22:         allow_write_path HOMEBREW_CACHE
// 23:       end
// 24:
// 25:       sig { void }
// 26:       def allow_cvs
// 27:         cvspass = ::Pathname.new("#{Dir.home(ENV.fetch("USER"))}/.cvspass")
// 28:         allow_write path: cvspass, type: :literal if cvspass.exist?
// 29:       end
// 30:
// 31:       sig { void }
// 32:       def allow_fossil
// 33:         [".fossil", ".fossil-journal"].each do |file|
// 34:           fossil_file = ::Pathname.new("#{Dir.home(ENV.fetch("USER"))}/#{file}")
// 35:           allow_write path: fossil_file, type: :literal if fossil_file.exist?
// 36:         end
// 37:       end
// 38:
// 39:       module ClassMethods
// 40:         extend T::Helpers
// 41:
// 42:         requires_ancestor { T.class_of(::Sandbox) }
// 43:
// 44:         sig { returns(T::Boolean) }
// 45:         def available?
// 46:           ::Sandbox::Landlock.available?
// 47:         end
// 48:
// 49:         sig { returns(T::Boolean) }
// 50:         def full_write_isolation?
// 51:           ::Sandbox::Landlock.full_write_isolation?
// 52:         end
// 53:
// 54:         sig { returns(Symbol) }
// 55:         def state
// 56:           ::Sandbox::Landlock.state
// 57:         end
// 58:
// 59:         sig { void }
// 60:         def reset_state!
// 61:           ::Sandbox::Landlock.reset_state!
// 62:         end
// 63:
// 64:         sig { returns(T.nilable(String)) }
// 65:         def failure_reason
// 66:           return super if self != ::Sandbox
// 67:
// 68:           ::Sandbox::Landlock.failure_reason
// 69:         end
// 70:
// 71:         # `ioctl` request used to attach the sandboxed child to a controlling TTY.
// 72:         sig { returns(Integer) }
// 73:         def terminal_ioctl_request
// 74:           TIOCSCTTY
// 75:         end
// 76:       end
// 77:
// 78:       sig { params(args: T.any(String, ::Pathname)).void }
// 79:       def run(*args)
// 80:         landlock.run { super }
// 81:       end
// 82:
// 83:       private
// 84:
// 85:       sig { params(args: T::Array[T.any(String, ::Pathname)], tmpdir: String).returns(T::Array[T.any(String, ::Pathname)]) }
// 86:       def sandbox_command(args, tmpdir)
// 87:         landlock.command(args, tmpdir)
// 88:       end
// 89:
// 90:       sig { void }
// 91:       def apply_sandbox
// 92:         landlock.apply!
// 93:       end
// 94:
// 95:       sig { returns(::Sandbox::Landlock) }
// 96:       def landlock
// 97:         @landlock ||= T.let(::Sandbox::Landlock.new(profile), T.nilable(::Sandbox::Landlock))
// 98:       end
// 99:     end
// 100:   end
// 101: end
// 102:
// 103: Sandbox.prepend(OS::Linux::Sandbox)
// 104: Sandbox.singleton_class.prepend(OS::Linux::Sandbox::ClassMethods)
