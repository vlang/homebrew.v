module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/dev-cmd/tests.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `os_bundle_args(bundle_args)` at line 15.
pub fn ruby_tests_l15_d1_os_bundle_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('os_bundle_args', ...args)
}

// Ruby method `os_files(files)` at line 20.
pub fn ruby_tests_l20_d2_os_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('os_files', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module DevCmd
// 7:       module Tests
// 8:         extend T::Helpers
// 9:
// 10:         requires_ancestor { Homebrew::DevCmd::Tests }
// 11:
// 12:         private
// 13:
// 14:         sig { params(bundle_args: T::Array[String]).returns(T::Array[String]) }
// 15:         def os_bundle_args(bundle_args)
// 16:           non_linux_bundle_args(bundle_args)
// 17:         end
// 18:
// 19:         sig { params(files: T::Array[String]).returns(T::Array[String]) }
// 20:         def os_files(files)
// 21:           non_linux_files(files)
// 22:         end
// 23:       end
// 24:     end
// 25:   end
// 26: end
// 27:
// 28: Homebrew::DevCmd::Tests.prepend(OS::Mac::DevCmd::Tests)
