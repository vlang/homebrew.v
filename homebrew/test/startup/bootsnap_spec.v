module startup

import brew_runtime
import homebrew.startup
import os

// Translated from Homebrew/brew `test/startup/bootsnap_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn bootsnap_spec_environment(no_bootsnap_set bool, tests_set bool) startup.BootsnapEnvironment {
	return startup.BootsnapEnvironment{
		ruby_version: '3.4.0'
		ruby_platform: 'arm64-darwin'
		gem_directories: ['bootsnap-1.18.4']
		cache: '/tmp/homebrew-cache'
		cache_set: true
		library_path: '/brew/Library/Homebrew'
		gem_path: 'gem/path'
		no_bootsnap_set: no_bootsnap_set
		tests_set: tests_set
		ruby_exec_args: ['/brew/vendor/portable-ruby/current/bin/ruby', '--disable=gems']
		load_path: ['/brew/Library/Homebrew', '/brew/Library/Homebrew/vendor']
	}
}

// Ruby it `it "does not error when the configured gem path is unavailable" do` at line 6.
pub fn ruby_bootsnap_spec_l6_d1_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := startup.BootsnapState{}
	loaded := startup.bootsnap_load(mut state, bootsnap_spec_environment(false, false), false, true) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(!loaded && state.setup_calls.len == 0)
}

// Ruby it `it "compiles caches for common command load graphs in a detached background process" do` at line 14.
pub fn ruby_bootsnap_spec_l14_d2_compiles(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	environment := bootsnap_spec_environment(false, false)
	mut process := startup.BootsnapProcess{
		pid: 12345
	}
	result := startup.bootsnap_prewarm(environment, mut process)
	mut expected_arguments := environment.ruby_exec_args.clone()
	expected_arguments << ['-I', environment.load_path.join(os.path_delimiter.str()), '-rglobal',
		'-rcmd/install', '-rcmd/fetch', '-rcmd/upgrade', '-e', '']
	return brew_runtime.bool_value(result.spawn_attempted && result.detach_attempted
		&& result.pid == 12345 && process.spawn_requests.len == 1
		&& process.spawn_requests[0].arguments == expected_arguments
		&& process.spawn_requests[0].pgroup && process.detached_pids == [12345])
}

// Ruby it `it "does nothing when Bootsnap is disabled" do` at line 27.
pub fn ruby_bootsnap_spec_l27_d3_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut process := startup.BootsnapProcess{
		pid: 12345
	}
	result := startup.bootsnap_prewarm(bootsnap_spec_environment(true, false), mut process)
	return brew_runtime.bool_value(!result.spawn_attempted && process.spawn_requests.len == 0)
}

// Ruby it `it "does not error when starting the prewarm process fails" do` at line 35.
pub fn ruby_bootsnap_spec_l35_d4_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut process := startup.BootsnapProcess{
		pid: 12345
		spawn_error: 'resource temporarily unavailable'
	}
	result := startup.bootsnap_prewarm(bootsnap_spec_environment(false, false), mut process)
	return brew_runtime.bool_value(result.spawn_attempted && !result.detach_attempted
		&& result.suppressed_error == 'resource temporarily unavailable'
		&& process.spawn_requests.len == 1 && process.detached_pids.len == 0)
}

// Ruby it `it "does not error when detaching the prewarm process fails" do` at line 44.
pub fn ruby_bootsnap_spec_l44_d5_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut process := startup.BootsnapProcess{
		pid: 12345
		detach_error: 'no child process'
	}
	result := startup.bootsnap_prewarm(bootsnap_spec_environment(false, false), mut process)
	return brew_runtime.bool_value(result.spawn_attempted && result.detach_attempted
		&& result.suppressed_error == 'no child process' && process.detached_pids == [
		12345,
	])
}

// Ruby it `it "does nothing in tests" do` at line 53.
pub fn ruby_bootsnap_spec_l53_d6_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut process := startup.BootsnapProcess{
		pid: 12345
	}
	result := startup.bootsnap_prewarm(bootsnap_spec_environment(false, true), mut process)
	return brew_runtime.bool_value(!result.spawn_attempted && process.spawn_requests.len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Homebrew::Bootsnap do
// 5:   describe "::load!" do
// 6:     it "does not error when the configured gem path is unavailable" do
// 7:       with_env(HOMEBREW_BOOTSNAP_GEM_PATH: "#{TEST_TMPDIR}/missing-bootsnap", HOMEBREW_NO_BOOTSNAP: nil) do
// 8:         expect { described_class.load! }.not_to raise_error
// 9:       end
// 10:     end
// 11:   end
// 12:
// 13:   describe "::prewarm!" do
// 14:     it "compiles caches for common command load graphs in a detached background process" do
// 15:       with_env(HOMEBREW_BOOTSNAP_GEM_PATH: "gem/path", HOMEBREW_NO_BOOTSNAP: nil, HOMEBREW_TESTS: nil) do
// 16:         expect(Process).to receive(:spawn).with(
// 17:           *HOMEBREW_RUBY_EXEC_ARGS, "-I", $LOAD_PATH.join(File::PATH_SEPARATOR),
// 18:           "-rglobal", "-rcmd/install", "-rcmd/fetch", "-rcmd/upgrade", "-e", "",
// 19:           hash_including(pgroup: true)
// 20:         ).and_return(12345)
// 21:         expect(Process).to receive(:detach).with(12345)
// 22:
// 23:         described_class.prewarm!
// 24:       end
// 25:     end
// 26:
// 27:     it "does nothing when Bootsnap is disabled" do
// 28:       with_env(HOMEBREW_BOOTSNAP_GEM_PATH: "gem/path", HOMEBREW_NO_BOOTSNAP: "1", HOMEBREW_TESTS: nil) do
// 29:         expect(Process).not_to receive(:spawn)
// 30:
// 31:         described_class.prewarm!
// 32:       end
// 33:     end
// 34:
// 35:     it "does not error when starting the prewarm process fails" do
// 36:       with_env(HOMEBREW_BOOTSNAP_GEM_PATH: "gem/path", HOMEBREW_NO_BOOTSNAP: nil, HOMEBREW_TESTS: nil) do
// 37:         expect(Process).to receive(:spawn).and_raise(Errno::EAGAIN)
// 38:         expect(Process).not_to receive(:detach)
// 39:
// 40:         expect { described_class.prewarm! }.not_to raise_error
// 41:       end
// 42:     end
// 43:
// 44:     it "does not error when detaching the prewarm process fails" do
// 45:       with_env(HOMEBREW_BOOTSNAP_GEM_PATH: "gem/path", HOMEBREW_NO_BOOTSNAP: nil, HOMEBREW_TESTS: nil) do
// 46:         expect(Process).to receive(:spawn).and_return(12345)
// 47:         expect(Process).to receive(:detach).with(12345).and_raise(Errno::ECHILD)
// 48:
// 49:         expect { described_class.prewarm! }.not_to raise_error
// 50:       end
// 51:     end
// 52:
// 53:     it "does nothing in tests" do
// 54:       with_env(HOMEBREW_BOOTSNAP_GEM_PATH: "gem/path", HOMEBREW_NO_BOOTSNAP: nil, HOMEBREW_TESTS: "1") do
// 55:         expect(Process).not_to receive(:spawn)
// 56:
// 57:         described_class.prewarm!
// 58:       end
// 59:     end
// 60:   end
// 61: end
