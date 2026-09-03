module homebrew

// Translated from Homebrew/brew `github_runner.rb`.
// The original source is retained below until every stub has a typed V body.
pub type GitHubRunnerSpec = LinuxRunnerSpec | MacOSRunnerSpec

pub struct GitHubRunner {
pub:
	platform      string
	arch          string
	spec          GitHubRunnerSpec
	macos_version string
pub mut:
	active bool
}

pub fn new_github_runner(platform string, arch string, spec GitHubRunnerSpec,
	macos_version string) GitHubRunner {
	return GitHubRunner{
		platform: platform
		arch: arch
		spec: spec
		macos_version: macos_version
	}
}

pub fn (runner GitHubRunner) macos() bool {
	return runner.platform == 'macos'
}

pub fn (runner GitHubRunner) linux() bool {
	return runner.platform == 'linux'
}

pub fn (runner GitHubRunner) x86_64() bool {
	return runner.arch == 'x86_64'
}

pub fn (runner GitHubRunner) arm64() bool {
	return runner.arch == 'arm64'
}

// Ruby method `macos?` at line 15.
pub fn ruby_github_runner_l15_d1_macos(runner GitHubRunner) bool {
	return runner.macos()
}

// Ruby method `linux?` at line 20.
pub fn ruby_github_runner_l20_d2_linux(runner GitHubRunner) bool {
	return runner.linux()
}

// Ruby method `x86_64?` at line 25.
pub fn ruby_github_runner_l25_d3_x86_64(runner GitHubRunner) bool {
	return runner.x86_64()
}

// Ruby method `arm64?` at line 30.
pub fn ruby_github_runner_l30_d4_arm64(runner GitHubRunner) bool {
	return runner.arm64()
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
