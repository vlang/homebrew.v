module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/dev-cmd/tests.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `check_test_environment!` at line 15.
pub fn ruby_tests_l15_d1_check_test_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_test_environment!', ...args)
}

// Ruby method `os_bundle_args(bundle_args)` at line 28.
pub fn ruby_tests_l28_d2_os_bundle_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('os_bundle_args', ...args)
}

// Ruby method `os_files(files)` at line 33.
pub fn ruby_tests_l33_d3_os_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('os_files', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/github/actions"
// 5:
// 6: module OS
// 7:   module Linux
// 8:     module DevCmd
// 9:       module Tests
// 10:         extend T::Helpers
// 11:
// 12:         requires_ancestor { Homebrew::DevCmd::Tests }
// 13:
// 14:         sig { void }
// 15:         def check_test_environment!
// 16:           super
// 17:           return unless Homebrew::EnvConfig.sandbox_linux?
// 18:
// 19:           require "sandbox"
// 20:           return if !::Sandbox.available? && GitHub::Actions.env_set?
// 21:
// 22:           ::Sandbox.ensure_sandbox_available!
// 23:         end
// 24:
// 25:         private
// 26:
// 27:         sig { params(bundle_args: T::Array[String]).returns(T::Array[String]) }
// 28:         def os_bundle_args(bundle_args)
// 29:           non_macos_bundle_args(bundle_args)
// 30:         end
// 31:
// 32:         sig { params(files: T::Array[String]).returns(T::Array[String]) }
// 33:         def os_files(files)
// 34:           non_macos_files(files)
// 35:         end
// 36:       end
// 37:     end
// 38:   end
// 39: end
// 40:
// 41: Homebrew::DevCmd::Tests.prepend(OS::Linux::DevCmd::Tests)
