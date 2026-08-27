module homebrew

import brew_runtime

// Translated from Homebrew/brew `github_runner.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `macos?` at line 15.
pub fn ruby_github_runner_l15_d1_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macos?', ...args)
}

// Ruby method `linux?` at line 20.
pub fn ruby_github_runner_l20_d2_linux(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('linux?', ...args)
}

// Ruby method `x86_64?` at line 25.
pub fn ruby_github_runner_l25_d3_x86_64(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('x86_64?', ...args)
}

// Ruby method `arm64?` at line 30.
pub fn ruby_github_runner_l30_d4_arm64(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arm64?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "linux_runner_spec"
// 5: require "macos_runner_spec"
// 6:
// 7: class GitHubRunner < T::Struct
// 8:   const :platform, Symbol
// 9:   const :arch, Symbol
// 10:   const :spec, T.any(LinuxRunnerSpec, MacOSRunnerSpec)
// 11:   const :macos_version, T.nilable(MacOSVersion)
// 12:   prop  :active, T::Boolean, default: false
// 13:
// 14:   sig { returns(T::Boolean) }
// 15:   def macos?
// 16:     platform == :macos
// 17:   end
// 18:
// 19:   sig { returns(T::Boolean) }
// 20:   def linux?
// 21:     platform == :linux
// 22:   end
// 23:
// 24:   sig { returns(T::Boolean) }
// 25:   def x86_64?
// 26:     arch == :x86_64
// 27:   end
// 28:
// 29:   sig { returns(T::Boolean) }
// 30:   def arm64?
// 31:     arch == :arm64
// 32:   end
// 33: end
