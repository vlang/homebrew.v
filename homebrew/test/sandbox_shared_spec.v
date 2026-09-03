module test

import homebrew
import os

pub struct SandboxSharedExecutableState {
pub mut:
	test_executable_name string
	unsuitable           []string
}

fn sandbox_shared_paths(root string) !homebrew.SandboxPaths {
	home := os.join_path(root, 'home')
	prefix := os.join_path(root, 'prefix')
	repository := os.join_path(root, 'repository')
	cache := os.join_path(root, 'cache')
	logs := os.join_path(root, 'logs')
	temp := os.join_path(root, 'tmp')
	for path in [home, prefix, repository, cache, logs, temp] {
		os.mkdir_all(path)!
	}
	return homebrew.SandboxPaths{
		home: home
		prefix: prefix
		repository: repository
		cache: cache
		logs: logs
		temp: temp
		library: os.join_path(repository, 'Library')
		original_brew_file: os.join_path(repository, 'bin/brew')
	}
}

fn sandbox_shared_new(root string) !homebrew.Sandbox {
	return homebrew.ruby_sandbox_l283_d31_initialize(sandbox_shared_paths(root)!)
}

fn sandbox_shared_make_executable(path string) ! {
	os.mkdir_all(os.dir(path))!
	os.write_file(path, '#!/bin/sh\nexit 0\n')!
	os.chmod(path, 0o755)!
}

fn sandbox_shared_executable_context(name string, original []string, environment string, brew_file string,
	unsuitable []string) homebrew.SandboxExecutableContext {
	return homebrew.SandboxExecutableContext{
		executable_name: name
		original_paths: original
		environment_path: environment
		original_brew_file: brew_file
		unsuitable: unsuitable
	}
}

fn sandbox_shared_denied_paths(value homebrew.Sandbox) []string {
	mut paths := []string{}
	for rule in value.profile.rules {
		if !rule.allow && rule.operation == 'file-read*' && rule.has_filter { paths << rule.filter.path }
	}
	return paths
}

fn sandbox_shared_inside_home_paths(base homebrew.SandboxPaths, home string, cache string,
	trust_file string, github string, runner_workspace string, runner_temp string,
	home_write_paths []string) homebrew.SandboxPaths {
	return homebrew.SandboxPaths{
		home: home
		prefix: base.prefix
		repository: base.repository
		cache: cache
		logs: base.logs
		temp: base.temp
		library: base.library
		original_brew_file: base.original_brew_file
		trust_file: trust_file
		github_workspace: github
		runner_workspace: runner_workspace
		runner_temp: runner_temp
		home_write_paths: home_write_paths
	}
}

fn sandbox_shared_replace_paths(base homebrew.SandboxPaths, prefix string, logs string) homebrew.SandboxPaths {
	return homebrew.SandboxPaths{
		home: base.home
		prefix: prefix
		repository: base.repository
		cache: base.cache
		logs: logs
		temp: base.temp
		library: base.library
		original_brew_file: base.original_brew_file
		trust_file: base.trust_file
		github_workspace: base.github_workspace
		runner_workspace: base.runner_workspace
		runner_temp: base.runner_temp
		home_write_paths: base.home_write_paths
	}
}

// Translated from Homebrew/brew `test/sandbox_shared_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:sandbox) { described_class.new }` at line 7.
pub fn ruby_sandbox_shared_spec_l7_d1_sandbox(root string) !homebrew.Sandbox {
	return sandbox_shared_new(root)
}

// Ruby it `it "uses an available non-nested sandbox" do` at line 10.
pub fn ruby_sandbox_shared_spec_l10_d2_uses() bool {
	decision := homebrew.ruby_sandbox_l124_d16_self_use_for('running install hooks', true, homebrew.SandboxUseContext{ available: true })
	return decision.use && decision.warning == ''
}

// Ruby it `it "warns when the sandbox is unavailable" do` at line 16.
pub fn ruby_sandbox_shared_spec_l16_d3_warns() bool {
	decision := homebrew.ruby_sandbox_l124_d16_self_use_for('running install hooks', true, homebrew.SandboxUseContext{})
	return !decision.use && decision.warning == 'Sandbox unavailable: running install hooks without sandboxing!'
}

// Ruby it `it "can quietly fall back when the sandbox is unavailable" do` at line 23.
pub fn ruby_sandbox_shared_spec_l23_d4_can() bool {
	decision := homebrew.ruby_sandbox_l124_d16_self_use_for('testing a formula', false, homebrew.SandboxUseContext{})
	return !decision.use && decision.warning == ''
}

// Ruby it `it "warns when relying on an outer sandbox" do` at line 30.
pub fn ruby_sandbox_shared_spec_l30_d5_warns() bool {
	decision := homebrew.ruby_sandbox_l124_d16_self_use_for('running install hooks', true, homebrew.SandboxUseContext{ available: true, avoid_nested: true })
	return !decision.use && decision.warning == "Running install hooks without Homebrew's sandbox; relying on the outer sandbox."
}

// Ruby let `let(:command_sandbox) { instance_double(described_class) }` at line 40.
pub fn ruby_sandbox_shared_spec_l40_d6_command_sandbox(root string) !homebrew.Sandbox {
	return sandbox_shared_new(root)
}

// Ruby it `it "configures and uses the sandbox when available" do` at line 42.
pub fn ruby_sandbox_shared_spec_l42_d7_configures() bool {
	result := homebrew.ruby_sandbox_l146_d17_self_run_or_fork(['command', 'argument'], 'running a command', true, homebrew.SandboxUseContext{ available: true })
	return result.sandboxed && !result.forked && result.command == ['command', 'argument']
}

// Ruby it `it "forks without configuring a sandbox when unavailable" do` at line 51.
pub fn ruby_sandbox_shared_spec_l51_d8_forks() bool {
	result := homebrew.ruby_sandbox_l146_d17_self_run_or_fork(['command'], 'running a command', true, homebrew.SandboxUseContext{})
	return !result.sandboxed && result.forked && result.command == ['command']
}

// Ruby it `it "restores bin/brew after a sandboxed process replaces it" do` at line 63.
pub fn ruby_sandbox_shared_spec_l63_d9_restores(root string) !bool {
	prefix := os.join_path(root, 'prefix')
	brew_file := os.join_path(prefix, 'bin/brew')
	original := os.join_path(prefix, 'Homebrew/bin/brew')
	os.mkdir_all(os.dir(original))!
	os.mkdir_all(os.dir(brew_file))!
	os.write_file(original, '#!/bin/sh\n')!
	os.symlink('../../Homebrew/bin/brew', brew_file)!
	target := os.readlink(brew_file)!
	mode := os.stat(os.dir(brew_file))!.mode & 0o7777
	homebrew.ruby_sandbox_l159_d18_self_with_preserved_brew_file(prefix, false, homebrew.SandboxBrewMutation{ replacement: 'malicious\n', directory_mode: 0o500 })!
	return os.is_link(brew_file) && os.readlink(brew_file)! == target && (os.stat(os.dir(brew_file))!.mode & 0o7777) == mode
}

// Ruby it `it "applies common install hook restrictions" do` at line 89.
pub fn ruby_sandbox_shared_spec_l89_d10_applies(root string) !bool {
	mut value := sandbox_shared_new(root)!
	homebrew.ruby_sandbox_l497_d46_add_install_hook_rules(mut value, false)!
	operations := value.profile.rules.map(it.operation)
	return operations[..3] == ['file-write*', 'file-write-setugid', 'file-write-mode'] && operations[3..6] == [
		'file-write*',
		'file-write-setugid',
		'file-write-mode',
	] && operations.contains('file-read*') && operations.last() == 'network*'
}

// Ruby it `it "allows network access when requested" do` at line 98.
pub fn ruby_sandbox_shared_spec_l98_d11_allows(root string) !bool {
	mut value := sandbox_shared_new(root)!
	homebrew.ruby_sandbox_l497_d46_add_install_hook_rules(mut value, true)!
	return !value.profile.rules.any(it.operation == 'network*')
}

// Ruby let `let(:command_sandbox) { instance_double(described_class) }` at line 111.
pub fn ruby_sandbox_shared_spec_l111_d12_command_sandbox(root string) !homebrew.Sandbox {
	return sandbox_shared_new(root)
}

// Ruby let `let(:writable_path) { mktmpdir }` at line 112.
pub fn ruby_sandbox_shared_spec_l112_d13_writable_path(root string) !string {
	path := os.join_path(root, 'writable')
	os.mkdir_all(path)!
	return path
}

// Ruby it `it "runs a command with the requested writable path" do` at line 128.
pub fn ruby_sandbox_shared_spec_l128_d14_runs(root string) !bool {
	paths := sandbox_shared_paths(root)!
	writable := os.join_path(root, 'writable')
	os.mkdir_all(writable)!
	plan := homebrew.ruby_sandbox_l209_d23_self_run_command(['make', 'test'], writable, false, true, '', paths)!
	return plan.command == ['/bin/sh', '-c', 'cd "\$1" && shift && exec "\$@"', 'brew-sandbox-exec',
		os.real_path(writable), 'make', 'test'] && plan.writable_path == os.real_path(writable) && !plan.sandbox.profile.rules.any(it.operation == 'network*')
}

// Ruby it `it "can deny network access" do` at line 146.
pub fn ruby_sandbox_shared_spec_l146_d15_can(root string) !bool {
	paths := sandbox_shared_paths(root)!
	writable := os.join_path(root, 'writable')
	os.mkdir_all(writable)!
	plan := homebrew.ruby_sandbox_l209_d23_self_run_command(['make'], writable, true, true, '', paths)!
	return plan.sandbox.profile.rules.any(!it.allow && it.operation == 'network*' && !it.has_filter)
}

// Ruby it `it "does not run unsandboxed when sandboxing is unavailable" do` at line 152.
pub fn ruby_sandbox_shared_spec_l152_d16_does(root string) !bool {
	paths := sandbox_shared_paths(root)!
	writable := os.join_path(root, 'writable')
	os.mkdir_all(writable)!
	homebrew.ruby_sandbox_l209_d23_self_run_command(['make'], writable, false, false, 'sandbox unavailable', paths) or { return err.msg() == 'sandbox unavailable' }
	return false
}

// Ruby it `it "raises a usage error when the writable path does not exist" do` at line 160.
pub fn ruby_sandbox_shared_spec_l160_d17_raises(root string) !bool {
	paths := sandbox_shared_paths(root)!
	missing := os.join_path(root, 'missing')
	homebrew.ruby_sandbox_l209_d23_self_run_command(['make'], missing, false, true, '', paths) or {
		return err.msg() == 'Invalid usage: `${os.abs_path(missing)}` is not a writable directory.'
	}
	return false
}

// Ruby it `it "raises a usage error when the writable path is not a directory" do` at line 168.
pub fn ruby_sandbox_shared_spec_l168_d18_raises(root string) !bool {
	paths := sandbox_shared_paths(root)!
	file := os.join_path(root, 'file')
	os.write_file(file, '')!
	homebrew.ruby_sandbox_l209_d23_self_run_command(['make'], file, false, true, '', paths) or {
		return err.msg() == 'Invalid usage: `${os.abs_path(file)}` is not a writable directory.'
	}
	return false
}

// Ruby it `it "treats a PTY EIO as EOF" do` at line 179.
pub fn ruby_sandbox_shared_spec_l179_d19_treats() bool {
	return homebrew.ruby_sandbox_l684_d58_copy_pty_output('', true) == ''
}

// Ruby let `let(:sandbox_class) { Class.new(described_class) }` at line 188.
pub fn ruby_sandbox_shared_spec_l188_d20_sandbox_class() homebrew.SandboxState {
	return .unavailable
}

// Ruby it `it "returns nil if the sandbox is available" do` at line 190.
pub fn ruby_sandbox_shared_spec_l190_d21_returns() bool {
	return homebrew.ruby_sandbox_l199_d21_self_failure_reason(.available) == none
}

// Ruby it `it "returns a sandbox failure reason if the sandbox is unavailable" do` at line 196.
pub fn ruby_sandbox_shared_spec_l196_d22_returns() bool {
	return (homebrew.ruby_sandbox_l199_d21_self_failure_reason(.unavailable) or { '' }).to_lower().contains('sandbox')
}

// Ruby let `let(:sandbox_class) do` at line 204.
pub fn ruby_sandbox_shared_spec_l204_d23_sandbox_class() SandboxSharedExecutableState {
	return SandboxSharedExecutableState{ test_executable_name: 'sandbox-tool' }
}

// Ruby attr_accessor `attr_accessor :test_executable_name, :unsuitable_executables` at line 207.
pub fn ruby_sandbox_shared_spec_l207_d24_test_executable_name(state SandboxSharedExecutableState) string {
	return state.test_executable_name
}

// Ruby attr_accessor `attr_accessor :test_executable_name, :unsuitable_executables` at line 207.
pub fn ruby_sandbox_shared_spec_l207_d25_test_executable_name(mut state SandboxSharedExecutableState, value string) string {
	state.test_executable_name = value
	return state.test_executable_name
}

// Ruby attr_accessor `attr_accessor :test_executable_name, :unsuitable_executables` at line 207.
pub fn ruby_sandbox_shared_spec_l207_d26_unsuitable_executables(state SandboxSharedExecutableState) []string {
	return state.unsuitable.clone()
}

// Ruby attr_accessor `attr_accessor :test_executable_name, :unsuitable_executables` at line 207.
pub fn ruby_sandbox_shared_spec_l207_d27_unsuitable_executables(mut state SandboxSharedExecutableState, value []string) []string {
	state.unsuitable = value.clone()
	return state.unsuitable.clone()
}

// Ruby method `executable_name = test_executable_name` at line 209.
pub fn ruby_sandbox_shared_spec_l209_d28_executable_name(state SandboxSharedExecutableState) string {
	return state.test_executable_name
}

// Ruby method `executable_usable?(candidate)` at line 211.
pub fn ruby_sandbox_shared_spec_l211_d29_executable_usable(state SandboxSharedExecutableState, candidate string) bool {
	return candidate !in state.unsuitable
}

// Ruby let `let(:first_dir) { mktmpdir }` at line 217.
pub fn ruby_sandbox_shared_spec_l217_d30_first_dir(root string) !string {
	path := os.join_path(root, 'first')
	os.mkdir_all(path)!
	return path
}

// Ruby let `let(:second_dir) { mktmpdir }` at line 218.
pub fn ruby_sandbox_shared_spec_l218_d31_second_dir(root string) !string {
	path := os.join_path(root, 'second')
	os.mkdir_all(path)!
	return path
}

// Ruby let `let(:homebrew_bin) { mktmpdir }` at line 219.
pub fn ruby_sandbox_shared_spec_l219_d32_homebrew_bin(root string) !string {
	path := os.join_path(root, 'homebrew-bin')
	os.mkdir_all(path)!
	return path
}

// Ruby let `let(:executable_name) { "sandbox-tool" }` at line 220.
pub fn ruby_sandbox_shared_spec_l220_d33_executable_name() string {
	return 'sandbox-tool'
}

// Ruby let `let(:first_executable) { first_dir/executable_name }` at line 221.
pub fn ruby_sandbox_shared_spec_l221_d34_first_executable(first_dir string) string {
	return os.join_path(first_dir, 'sandbox-tool')
}

// Ruby let `let(:second_executable) { second_dir/executable_name }` at line 222.
pub fn ruby_sandbox_shared_spec_l222_d35_second_executable(second_dir string) string {
	return os.join_path(second_dir, 'sandbox-tool')
}

// Ruby let `let(:homebrew_executable) { homebrew_bin/executable_name }` at line 223.
pub fn ruby_sandbox_shared_spec_l223_d36_homebrew_executable(homebrew_bin string) string {
	return os.join_path(homebrew_bin, 'sandbox-tool')
}

// Ruby it `it "uses the first suitable executable candidate" do` at line 231.
pub fn ruby_sandbox_shared_spec_l231_d37_uses(root string) !bool {
	first := os.join_path(root, 'first/sandbox-tool')
	second := os.join_path(root, 'second/sandbox-tool')
	sandbox_shared_make_executable(first)!
	sandbox_shared_make_executable(second)!
	context := sandbox_shared_executable_context('sandbox-tool', [os.dir(first)], os.dir(second), os.join_path(root, 'homebrew-bin/brew'), [])
	return (homebrew.ruby_sandbox_l241_d26_self_executable(context) or { return false }) == first
}

// Ruby it `it "skips unsuitable executable candidates" do` at line 243.
pub fn ruby_sandbox_shared_spec_l243_d38_skips(root string) !bool {
	first := os.join_path(root, 'first/sandbox-tool')
	second := os.join_path(root, 'second/sandbox-tool')
	sandbox_shared_make_executable(first)!
	sandbox_shared_make_executable(second)!
	context := sandbox_shared_executable_context('sandbox-tool', [os.dir(first)], os.dir(second), os.join_path(root, 'homebrew-bin/brew'), [
		first,
	])
	return (homebrew.ruby_sandbox_l241_d26_self_executable(context) or { return false }) == second
}

// Ruby it `it "falls back to the original Homebrew bin directory" do` at line 256.
pub fn ruby_sandbox_shared_spec_l256_d39_falls(root string) !bool {
	homebrew_executable := os.join_path(root, 'homebrew-bin/sandbox-tool')
	sandbox_shared_make_executable(homebrew_executable)!
	context := sandbox_shared_executable_context('sandbox-tool', [], os.join_path(root, 'empty'), os.join_path(root, 'homebrew-bin/brew'), [])
	return (homebrew.ruby_sandbox_l241_d26_self_executable(context) or { return false }) == homebrew_executable
}

// Ruby it `it "checks absolute executable paths directly" do` at line 266.
pub fn ruby_sandbox_shared_spec_l266_d40_checks(root string) !bool {
	executable := os.join_path(root, 'first/sandbox-tool')
	sandbox_shared_make_executable(executable)!
	context := sandbox_shared_executable_context(executable, [], os.join_path(root, 'empty'), os.join_path(root, 'homebrew-bin/brew'), [])
	return (homebrew.ruby_sandbox_l241_d26_self_executable(context) or { return false }) == executable
}

// Ruby it `it "raises when no executable candidate exists" do` at line 277.
pub fn ruby_sandbox_shared_spec_l277_d41_raises(root string) bool {
	context := sandbox_shared_executable_context('sandbox-tool', [], os.join_path(root, 'empty'), os.join_path(root, 'homebrew-bin/brew'), [])
	homebrew.ruby_sandbox_l259_d27_self_executable(context) or {
		return err.msg() == 'sandbox-tool is required to use the sandbox.'
	}
	return false
}

// Ruby it `it "allows paths containing` at line 290.
pub fn ruby_sandbox_shared_spec_l290_d42_allows(root string) !bool {
	os.mkdir_all(root)!
	for character in ["'", '"', '(', ')', '\\', ' ', ';', '#', '\n'] {
		filter := homebrew.ruby_sandbox_l665_d56_path_filter(os.join_path(root, 'foo${character}bar'), .subpath)!
		if filter.type_name != .subpath {
			return false
		}
	}
	return true
}

// Ruby it `it "allows reads for existing paths" do` at line 297.
pub fn ruby_sandbox_shared_spec_l297_d43_allows(root string) !bool {
	mut value := sandbox_shared_new(root)!
	file := os.join_path(root, 'foo.rb')
	os.write_file(file, '')!
	homebrew.ruby_sandbox_l453_d39_allow_read_if_exists(mut value, file, .literal)!
	rule := value.profile.rules.last()
	return rule.allow && rule.operation == 'file-read*' && rule.filter.path == os.real_path(file) && rule.filter.type_name == .literal
}

// Ruby it `it "skips missing paths" do` at line 308.
pub fn ruby_sandbox_shared_spec_l308_d44_skips(root string) !bool {
	mut value := sandbox_shared_new(root)!
	homebrew.ruby_sandbox_l453_d39_allow_read_if_exists(mut value, os.join_path(root, 'missing.rb'), .literal)!
	return value.profile.rules.len == 0
}

// Ruby it `it "skips nil paths" do` at line 314.
pub fn ruby_sandbox_shared_spec_l314_d45_skips(root string) !bool {
	mut value := sandbox_shared_new(root)!
	homebrew.ruby_sandbox_l453_d39_allow_read_if_exists(mut value, none, .literal)!
	return value.profile.rules.len == 0
}

// Ruby it `it "allows a process to run outside the sandbox when requested" do` at line 322.
pub fn ruby_sandbox_shared_spec_l322_d46_allows(root string) !bool {
	mut value := sandbox_shared_new(root)!
	homebrew.ruby_sandbox_l310_d35_allow_process_exec(mut value, '/usr/bin/sudo', true)!
	rule := value.profile.rules.last()
	return rule.allow && rule.operation == 'process-exec' && rule.modifier == 'no-sandbox' && rule.filter.path == '/usr/bin/sudo' && rule.filter.type_name == .literal
}

// Ruby it `it "denies reads for a subpath" do` at line 332.
pub fn ruby_sandbox_shared_spec_l332_d47_denies(root string) !bool {
	mut value := sandbox_shared_new(root)!
	directory := os.join_path(root, 'foo')
	os.mkdir_all(directory)!
	homebrew.ruby_sandbox_l321_d37_deny_read_path(mut value, directory)!
	rule := value.profile.rules.last()
	return !rule.allow && rule.operation == 'file-read*' && rule.filter.path == os.real_path(directory) && rule.filter.type_name == .subpath
}

// Ruby let `let(:home) { mktmpdir/"home" }` at line 345.
pub fn ruby_sandbox_shared_spec_l345_d48_home(root string) !string {
	return (sandbox_shared_paths(root)!).home
}

// Ruby let `let(:prefix) { mktmpdir/"prefix" }` at line 346.
pub fn ruby_sandbox_shared_spec_l346_d49_prefix(root string) !string {
	return (sandbox_shared_paths(root)!).prefix
}

// Ruby let `let(:repository) { mktmpdir/"repository" }` at line 347.
pub fn ruby_sandbox_shared_spec_l347_d50_repository(root string) !string {
	return (sandbox_shared_paths(root)!).repository
}

// Ruby let `let(:temp) { mktmpdir/"tmp" }` at line 348.
pub fn ruby_sandbox_shared_spec_l348_d51_temp(root string) !string {
	return (sandbox_shared_paths(root)!).temp
}

// Ruby let `let(:cache) { mktmpdir/"cache" }` at line 349.
pub fn ruby_sandbox_shared_spec_l349_d52_cache(root string) !string {
	return (sandbox_shared_paths(root)!).cache
}

// Ruby let `let(:logs) { mktmpdir/"logs" }` at line 350.
pub fn ruby_sandbox_shared_spec_l350_d53_logs(root string) !string {
	return (sandbox_shared_paths(root)!).logs
}

// Ruby it `it "denies reads from the real home" do` at line 362.
pub fn ruby_sandbox_shared_spec_l362_d54_denies(root string) !bool {
	mut value := sandbox_shared_new(root)!
	homebrew.ruby_sandbox_l326_d38_deny_read_home(mut value)!
	rule := value.profile.rules.last()
	return !rule.allow && rule.operation == 'file-read*' && rule.filter.path == os.real_path(value.paths.home) && rule.filter.type_name == .subpath
}

// Ruby it `it "skips the deny when` at line 377.
pub fn ruby_sandbox_shared_spec_l377_d55_skips(root string) !bool {
	for index, field in ['prefix', 'repository', 'cache', 'temp', 'logs'] {
		case_root := os.join_path(root, index.str())
		base := sandbox_shared_paths(case_root)!
		inside := os.join_path(base.home, if field == 'logs' {
			'Library/Logs/Homebrew'
		} else {
			field
		})
		os.mkdir_all(inside)!
		paths := homebrew.SandboxPaths{
			home: base.home
			prefix: if field == 'prefix' { inside } else { base.prefix }
			repository: if field == 'repository' { inside } else { base.repository }
			cache: if field == 'cache' { inside } else { base.cache }
			logs: if field == 'logs' { inside } else { base.logs }
			temp: if field == 'temp' { inside } else { base.temp }
			library: base.library
			original_brew_file: base.original_brew_file
		}
		mut value := homebrew.ruby_sandbox_l283_d31_initialize(paths)
		homebrew.ruby_sandbox_l326_d38_deny_read_home(mut value)!
		if value.profile.rules.len != 0 {
			return false
		}
	}
	return true
}

// Ruby it `it "skips the deny when` at line 395.
pub fn ruby_sandbox_shared_spec_l395_d56_skips(root string) !bool {
	for index, field in ['github', 'runner-workspace', 'runner-temp'] {
		case_root := os.join_path(root, index.str())
		base := sandbox_shared_paths(case_root)!
		inside := os.join_path(base.home, field)
		os.mkdir_all(inside)!
		paths := sandbox_shared_inside_home_paths(base, base.home, base.cache, '', if field == 'github' {
			inside
		} else {
			''
		}, if field == 'runner-workspace' { inside } else { '' }, if field == 'runner-temp' {
			inside
		} else {
			''
		}, [])
		mut value := homebrew.ruby_sandbox_l283_d31_initialize(paths)
		homebrew.ruby_sandbox_l326_d38_deny_read_home(mut value)!
		if value.profile.rules.len != 0 {
			return false
		}
	}
	return true
}

// Ruby it `it "skips the deny when a runner path resolves inside the real home" do` at line 406.
pub fn ruby_sandbox_shared_spec_l406_d57_skips(root string) !bool {
	base := sandbox_shared_paths(root)!
	workspace := os.join_path(base.home, 'workspace')
	link := os.join_path(root, 'workspace-link')
	os.mkdir_all(workspace)!
	os.symlink(workspace, link)!
	paths := sandbox_shared_inside_home_paths(base, base.home, base.cache, '', link, '', '', [])
	mut value := homebrew.ruby_sandbox_l283_d31_initialize(paths)
	homebrew.ruby_sandbox_l326_d38_deny_read_home(mut value)!
	return value.profile.rules.len == 0
}

// Ruby it `it "denies known sensitive home paths when Homebrew needs home access" do` at line 418.
pub fn ruby_sandbox_shared_spec_l418_d58_denies(root string) !bool {
	base := sandbox_shared_paths(root)!
	home := base.home
	cache := os.join_path(home, 'Library/Caches/Homebrew')
	allowed_dirs := [cache, os.join_path(home, 'Library/Preferences'), os.join_path(home, '.config'),
		os.join_path(home, '.config/homebrew'), os.join_path(home, 'src')]
	sensitive_dirs := [os.join_path(home, '.claude'), os.join_path(home, '.config/gcloud'),
		os.join_path(home, '.config/gh'), os.join_path(home, '.config/fish'),
		os.join_path(home, '.config/huggingface'), os.join_path(home, '.config/pip'),
		os.join_path(home, '.config/pypoetry'), os.join_path(home, '.config/rclone'),
		os.join_path(home, '.kiro'), os.join_path(home, '.pip'), os.join_path(home, '.ssh'),
		os.join_path(home, 'Documents')]
	sensitive_files := ['.bash_login', '.bash_logout', '.bash_profile', '.bashrc', '.bash_history',
		'.cache/huggingface/token', '.claude.json', '.config/composer/auth.json',
		'.config/containers/auth.json', '.config/sops/age/keys.txt', '.cargo/credentials.toml',
		'.gem/credentials', '.git-credentials', '.mysql_history', '.netrc', '.npmrc', '.profile',
		'.psql_history', '.pypirc', '.python_history', '.terraform.d/credentials.tfrc.json', '.zlogin',
		'.zlogout', '.zprofile', '.zshenv', '.zshrc', '.zsh_history'].map(os.join_path(home, it))
	for path in allowed_dirs {
		os.mkdir_all(path)!
	}
	for path in sensitive_dirs {
		os.mkdir_all(path)!
	}
	for path in sensitive_files {
		os.mkdir_all(os.dir(path))!
		os.write_file(path, '')!
	}
	paths := sandbox_shared_inside_home_paths(base, home, cache, '', '', '', '', [])
	mut value := homebrew.ruby_sandbox_l283_d31_initialize(paths)
	homebrew.ruby_sandbox_l326_d38_deny_read_home(mut value)!
	denied := sandbox_shared_denied_paths(value)
	return sensitive_dirs.all(os.real_path(it) in denied) && sensitive_files.all(os.real_path(it) in denied) && allowed_dirs.all(os.real_path(it) !in denied)
}

// Ruby it `it "keeps Homebrew readable inside a sensitive home path" do` at line 485.
pub fn ruby_sandbox_shared_spec_l485_d59_keeps(root string) !bool {
	base := sandbox_shared_paths(root)!
	prefix := os.join_path(base.home, 'Documents/homebrew')
	ssh := os.join_path(base.home, '.ssh')
	for path in [prefix, ssh] {
		os.mkdir_all(path)!
	}
	paths := sandbox_shared_replace_paths(base, prefix, base.logs)
	mut value := homebrew.ruby_sandbox_l283_d31_initialize(paths)
	homebrew.ruby_sandbox_l326_d38_deny_read_home(mut value)!
	return sandbox_shared_denied_paths(value) == [os.real_path(ssh)]
}

// Ruby it `it "warns when Homebrew is inside a sensitive home path" do` at line 495.
pub fn ruby_sandbox_shared_spec_l495_d60_warns(root string) !bool {
	base := sandbox_shared_paths(root)!
	prefix := os.join_path(base.home, 'Documents/homebrew')
	os.mkdir_all(prefix)!
	paths := sandbox_shared_replace_paths(base, prefix, base.logs)
	mut value := homebrew.ruby_sandbox_l283_d31_initialize(paths)
	homebrew.ruby_sandbox_l326_d38_deny_read_home(mut value)!
	return value.warnings == [
		'The sandbox cannot prevent formulae from reading:\n  ${os.real_path(os.join_path(base.home, 'Documents'))}\nbecause this required path is inside it:\n  ${os.real_path(prefix)}\nFormulae may access personal data in this directory.\n',
	]
}

// Ruby it `it "does not deny arbitrary home entries whose names contain parentheses or backslashes" do` at line 510.
pub fn ruby_sandbox_shared_spec_l510_d61_does(root string) !bool {
	base := sandbox_shared_paths(root)!
	logs := os.join_path(base.home, 'Library/Logs/Homebrew')
	teams := os.join_path(base.home, 'Library/Logs/Microsoft Teams Helper (Renderer)')
	backslash := os.join_path(base.home, 'I:\\')
	ssh := os.join_path(base.home, '.ssh')
	for path in [logs, teams, backslash, ssh] {
		os.mkdir_all(path)!
	}
	paths := sandbox_shared_replace_paths(base, base.prefix, logs)
	mut value := homebrew.ruby_sandbox_l283_d31_initialize(paths)
	homebrew.ruby_sandbox_l326_d38_deny_read_home(mut value)!
	denied := sandbox_shared_denied_paths(value)
	return os.real_path(ssh) in denied && os.real_path(teams) !in denied && os.real_path(backslash) !in denied
}

// Ruby it `it "does not deny sensitive symlinks that resolve outside home" do` at line 523.
pub fn ruby_sandbox_shared_spec_l523_d62_does(root string) !bool {
	base := sandbox_shared_paths(root)!
	cache := os.join_path(base.home, 'Library/Caches/Homebrew')
	os.mkdir_all(cache)!
	os.symlink(os.path_devnull, os.join_path(base.home, '.mysql_history'))!
	paths := sandbox_shared_inside_home_paths(base, base.home, cache, '', '', '', '', [])
	mut value := homebrew.ruby_sandbox_l283_d31_initialize(paths)
	homebrew.ruby_sandbox_l326_d38_deny_read_home(mut value)!
	return os.path_devnull !in sandbox_shared_denied_paths(value)
}

// Ruby it `it "passes resolved sensitive paths to deny_read_path" do` at line 534.
pub fn ruby_sandbox_shared_spec_l534_d63_passes(root string) !bool {
	base := sandbox_shared_paths(root)!
	cache := os.join_path(base.home, 'Library/Caches/Homebrew')
	target := os.join_path(base.home, 'history')
	os.mkdir_all(cache)!
	os.write_file(target, '')!
	os.symlink(target, os.join_path(base.home, '.mysql_history'))!
	paths := sandbox_shared_inside_home_paths(base, base.home, cache, '', '', '', '', [])
	mut value := homebrew.ruby_sandbox_l283_d31_initialize(paths)
	homebrew.ruby_sandbox_l326_d38_deny_read_home(mut value)!
	return os.real_path(target) in sandbox_shared_denied_paths(value)
}

// Ruby it `it "ignores broken sensitive symlinks" do` at line 546.
pub fn ruby_sandbox_shared_spec_l546_d64_ignores(root string) !bool {
	base := sandbox_shared_paths(root)!
	cache := os.join_path(base.home, 'Library/Caches/Homebrew')
	os.mkdir_all(cache)!
	os.symlink(os.join_path(base.home, 'missing'), os.join_path(base.home, '.mysql_history'))!
	paths := sandbox_shared_inside_home_paths(base, base.home, cache, '', '', '', '', [])
	mut value := homebrew.ruby_sandbox_l283_d31_initialize(paths)
	homebrew.ruby_sandbox_l326_d38_deny_read_home(mut value)!
	return true
}

// Ruby it `it "keeps the trust store readable so sandboxed builds can re-check tap trust" do` at line 554.
pub fn ruby_sandbox_shared_spec_l554_d65_keeps(root string) !bool {
	base := sandbox_shared_paths(root)!
	cache := os.join_path(base.home, 'Library/Caches/Homebrew')
	config := os.join_path(base.home, '.homebrew')
	ssh := os.join_path(base.home, '.ssh')
	trust := os.join_path(config, 'trust.json')
	for path in [cache, config, ssh] {
		os.mkdir_all(path)!
	}
	os.write_file(trust, '')!
	paths := sandbox_shared_inside_home_paths(base, base.home, cache, trust, '', '', '', [])
	mut value := homebrew.ruby_sandbox_l283_d31_initialize(paths)
	homebrew.ruby_sandbox_l326_d38_deny_read_home(mut value)!
	denied := sandbox_shared_denied_paths(value)
	return os.real_path(ssh) in denied && os.real_path(trust) !in denied
}

// Ruby it `it "keeps the XDG trust store readable so sandboxed builds can re-check tap trust" do` at line 570.
pub fn ruby_sandbox_shared_spec_l570_d66_keeps(root string) !bool {
	base := sandbox_shared_paths(root)!
	cache := os.join_path(base.home, 'Library/Caches/Homebrew')
	config := os.join_path(base.home, '.config/homebrew')
	gh := os.join_path(base.home, '.config/gh')
	ssh := os.join_path(base.home, '.ssh')
	trust := os.join_path(config, 'trust.json')
	for path in [cache, config, gh, ssh] {
		os.mkdir_all(path)!
	}
	os.write_file(trust, '')!
	paths := sandbox_shared_inside_home_paths(base, base.home, cache, trust, '', '', '', [])
	mut value := homebrew.ruby_sandbox_l283_d31_initialize(paths)
	homebrew.ruby_sandbox_l326_d38_deny_read_home(mut value)!
	denied := sandbox_shared_denied_paths(value)
	return os.real_path(gh) in denied && os.real_path(ssh) in denied && os.real_path(os.join_path(base.home, '.config')) !in denied && os.real_path(trust) !in denied
}

// Ruby it `it "keeps the Xcode directories readable so builds can use them", :needs_macos do` at line 589.
pub fn ruby_sandbox_shared_spec_l589_d67_keeps(root string) !bool {
	base := sandbox_shared_paths(root)!
	developer := os.join_path(base.home, 'Library/Developer')
	swiftpm := os.join_path(base.home, 'Library/Caches/org.swift.swiftpm')
	ssh := os.join_path(base.home, '.ssh')
	for path in [developer, swiftpm, ssh] {
		os.mkdir_all(path)!
	}
	paths := sandbox_shared_inside_home_paths(base, base.home, base.cache, '', '', '', '', [
		developer,
		swiftpm,
	])
	mut value := homebrew.ruby_sandbox_l283_d31_initialize(paths)
	homebrew.ruby_sandbox_l326_d38_deny_read_home(mut value)!
	denied := sandbox_shared_denied_paths(value)
	return os.real_path(developer) !in denied && os.real_path(swiftpm) !in denied && os.real_path(ssh) in denied
}

// Ruby it `it "allows writes for existing paths" do` at line 603.
pub fn ruby_sandbox_shared_spec_l603_d68_allows(root string) !bool {
	mut value := sandbox_shared_new(root)!
	directory := os.join_path(root, 'foo')
	os.mkdir_all(directory)!
	homebrew.ruby_sandbox_l478_d43_allow_write_path_if_exists(mut value, directory)!
	rule := value.profile.rules[0]
	return rule.allow && rule.operation == 'file-write*' && rule.filter.path == os.real_path(directory) && rule.filter.type_name == .subpath
}

// Ruby it `it "skips missing paths" do` at line 614.
pub fn ruby_sandbox_shared_spec_l614_d69_skips(root string) !bool {
	mut value := sandbox_shared_new(root)!
	homebrew.ruby_sandbox_l478_d43_allow_write_path_if_exists(mut value, os.join_path(root, 'missing'))!
	return value.profile.rules.len == 0
}

// Ruby it `it "skips nil paths" do` at line 620.
pub fn ruby_sandbox_shared_spec_l620_d70_skips(root string) !bool {
	mut value := sandbox_shared_new(root)!
	homebrew.ruby_sandbox_l478_d43_allow_write_path_if_exists(mut value, none)!
	return value.profile.rules.len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "sandbox"
// 5:
// 6: RSpec.describe Sandbox do
// 7:   subject(:sandbox) { described_class.new }
// 8:
// 9:   describe "::use_for?" do
// 10:     it "uses an available non-nested sandbox" do
// 11:       allow(described_class).to receive_messages(available?: true, avoid_nested_sandboxing?: false)
// 12:
// 13:       expect(described_class.use_for?("running install hooks")).to be(true)
// 14:     end
// 15:
// 16:     it "warns when the sandbox is unavailable" do
// 17:       allow(described_class).to receive(:available?).and_return(false)
// 18:       expect(described_class).to receive(:opoo).with("Sandbox unavailable: running install hooks without sandboxing!")
// 19:
// 20:       expect(described_class.use_for?("running install hooks")).to be(false)
// 21:     end
// 22:
// 23:     it "can quietly fall back when the sandbox is unavailable" do
// 24:       allow(described_class).to receive(:available?).and_return(false)
// 25:       expect(described_class).not_to receive(:opoo)
// 26:
// 27:       expect(described_class.use_for?("testing a formula", warn_without_sandbox: false)).to be(false)
// 28:     end
// 29:
// 30:     it "warns when relying on an outer sandbox" do
// 31:       allow(described_class).to receive_messages(available?: true, avoid_nested_sandboxing?: true)
// 32:       expect(described_class).to receive(:opoo)
// 33:         .with("Running install hooks without Homebrew's sandbox; relying on the outer sandbox.")
// 34:
// 35:       expect(described_class.use_for?("running install hooks")).to be(false)
// 36:     end
// 37:   end
// 38:
// 39:   describe "::run_or_fork" do
// 40:     let(:command_sandbox) { instance_double(described_class) }
// 41:
// 42:     it "configures and uses the sandbox when available" do
// 43:       allow(described_class).to receive_messages(new: command_sandbox, use_for?: true)
// 44:       expect(command_sandbox).to receive(:run).with("command", "argument")
// 45:
// 46:       described_class.run_or_fork("command", "argument", step: "running a command") do |configured|
// 47:         expect(configured).to eq(command_sandbox)
// 48:       end
// 49:     end
// 50:
// 51:     it "forks without configuring a sandbox when unavailable" do
// 52:       allow(described_class).to receive(:use_for?).and_return(false)
// 53:       expect(described_class).not_to receive(:new)
// 54:       expect(Utils).to receive(:safe_fork)
// 55:
// 56:       described_class.run_or_fork("command", step: "running a command") do
// 57:         raise "sandbox should not be configured"
// 58:       end
// 59:     end
// 60:   end
// 61:
// 62:   describe "::with_preserved_brew_file" do
// 63:     it "restores bin/brew after a sandboxed process replaces it" do
// 64:       prefix = mktmpdir
// 65:       stub_const("HOMEBREW_PREFIX", prefix)
// 66:       brew_file = prefix/"bin/brew"
// 67:       original_brew_file = prefix/"Homebrew/bin/brew"
// 68:       original_brew_file.dirname.mkpath
// 69:       original_brew_file.write "#!/bin/sh\n"
// 70:       brew_file.dirname.mkpath
// 71:       brew_file.make_relative_symlink original_brew_file
// 72:       original_target = brew_file.readlink
// 73:       original_directory_mode = brew_file.dirname.stat.mode & 07777
// 74:       allow(described_class).to receive(:full_write_isolation?).and_return(false)
// 75:
// 76:       described_class.with_preserved_brew_file do
// 77:         FileUtils.rm_f brew_file
// 78:         brew_file.write "malicious\n"
// 79:         brew_file.dirname.chmod 0500
// 80:       end
// 81:
// 82:       expect(brew_file).to be_a_symlink
// 83:       expect(brew_file.readlink).to eq(original_target)
// 84:       expect(brew_file.dirname.stat.mode & 07777).to eq(original_directory_mode)
// 85:     end
// 86:   end
// 87:
// 88:   describe "#add_install_hook_rules" do
// 89:     it "applies common install hook restrictions" do
// 90:       expect(sandbox).to receive(:allow_write_temp_and_cache).ordered
// 91:       expect(sandbox).to receive(:deny_write_homebrew_repository).ordered
// 92:       expect(sandbox).to receive(:deny_read_home).ordered
// 93:       expect(sandbox).to receive(:deny_all_network).ordered
// 94:
// 95:       sandbox.add_install_hook_rules(network_access_allowed: false)
// 96:     end
// 97:
// 98:     it "allows network access when requested" do
// 99:       allow(sandbox).to receive_messages(
// 100:         allow_write_temp_and_cache:     nil,
// 101:         deny_write_homebrew_repository: nil,
// 102:         deny_read_home:                 nil,
// 103:       )
// 104:       expect(sandbox).not_to receive(:deny_all_network)
// 105:
// 106:       sandbox.add_install_hook_rules(network_access_allowed: true)
// 107:     end
// 108:   end
// 109:
// 110:   describe "::run_command" do
// 111:     let(:command_sandbox) { instance_double(described_class) }
// 112:     let(:writable_path) { mktmpdir }
// 113:
// 114:     before do
// 115:       allow(described_class).to receive_messages(
// 116:         available?: true,
// 117:         new:        command_sandbox,
// 118:       )
// 119:       allow(command_sandbox).to receive_messages(
// 120:         allow_write_temp_and_cache: nil,
// 121:         allow_write_path:           nil,
// 122:         deny_read_home:             nil,
// 123:         deny_all_network:           nil,
// 124:         run:                        nil,
// 125:       )
// 126:     end
// 127:
// 128:     it "runs a command with the requested writable path" do
// 129:       expect(command_sandbox).to receive(:allow_write_temp_and_cache).ordered
// 130:       expect(command_sandbox).to receive(:allow_write_path).with(writable_path.realpath).ordered
// 131:       expect(command_sandbox).to receive(:deny_read_home).ordered
// 132:       expect(command_sandbox).not_to receive(:deny_all_network)
// 133:       expect(command_sandbox).to receive(:run).with(
// 134:         "/bin/sh",
// 135:         "-c",
// 136:         "cd \"$1\" && shift && exec \"$@\"",
// 137:         "brew-sandbox-exec",
// 138:         writable_path.realpath,
// 139:         "make",
// 140:         "test",
// 141:       ).ordered
// 142:
// 143:       described_class.run_command("make", "test", writable_path:)
// 144:     end
// 145:
// 146:     it "can deny network access" do
// 147:       expect(command_sandbox).to receive(:deny_all_network)
// 148:
// 149:       described_class.run_command("make", writable_path:, deny_network: true)
// 150:     end
// 151:
// 152:     it "does not run unsandboxed when sandboxing is unavailable" do
// 153:       allow(described_class).to receive_messages(available?: false, failure_reason: "sandbox unavailable")
// 154:       expect(command_sandbox).not_to receive(:run)
// 155:
// 156:       expect { described_class.run_command("make", writable_path:) }
// 157:         .to raise_error(RuntimeError, "sandbox unavailable")
// 158:     end
// 159:
// 160:     it "raises a usage error when the writable path does not exist" do
// 161:       missing_path = writable_path/"missing"
// 162:       expect(command_sandbox).not_to receive(:run)
// 163:
// 164:       expect { described_class.run_command("make", writable_path: missing_path) }
// 165:         .to raise_error(UsageError, "Invalid usage: `#{missing_path}` is not a writable directory.")
// 166:     end
// 167:
// 168:     it "raises a usage error when the writable path is not a directory" do
// 169:       file_path = writable_path/"file"
// 170:       FileUtils.touch file_path
// 171:       expect(command_sandbox).not_to receive(:run)
// 172:
// 173:       expect { described_class.run_command("make", writable_path: file_path) }
// 174:         .to raise_error(UsageError, "Invalid usage: `#{file_path}` is not a writable directory.")
// 175:     end
// 176:   end
// 177:
// 178:   describe "#copy_pty_output" do
// 179:     it "treats a PTY EIO as EOF" do
// 180:       controller = instance_double(IO)
// 181:       allow(controller).to receive(:each_char).and_raise(Errno::EIO)
// 182:
// 183:       expect { sandbox.copy_pty_output(controller) }.not_to raise_error
// 184:     end
// 185:   end
// 186:
// 187:   describe "::failure_reason" do
// 188:     let(:sandbox_class) { Class.new(described_class) }
// 189:
// 190:     it "returns nil if the sandbox is available" do
// 191:       allow(sandbox_class).to receive(:state).and_return(:available)
// 192:
// 193:       expect(sandbox_class.failure_reason).to be_nil
// 194:     end
// 195:
// 196:     it "returns a sandbox failure reason if the sandbox is unavailable" do
// 197:       allow(sandbox_class).to receive(:state).and_return(:unavailable)
// 198:
// 199:       expect(sandbox_class.failure_reason).to match(/sandbox/i)
// 200:     end
// 201:   end
// 202:
// 203:   describe "::executable" do
// 204:     let(:sandbox_class) do
// 205:       Class.new(Sandbox) do
// 206:         class << self
// 207:           attr_accessor :test_executable_name, :unsuitable_executables
// 208:
// 209:           def executable_name = test_executable_name
// 210:
// 211:           def executable_usable?(candidate)
// 212:             unsuitable_executables.exclude?(candidate)
// 213:           end
// 214:         end
// 215:       end
// 216:     end
// 217:     let(:first_dir) { mktmpdir }
// 218:     let(:second_dir) { mktmpdir }
// 219:     let(:homebrew_bin) { mktmpdir }
// 220:     let(:executable_name) { "sandbox-tool" }
// 221:     let(:first_executable) { first_dir/executable_name }
// 222:     let(:second_executable) { second_dir/executable_name }
// 223:     let(:homebrew_executable) { homebrew_bin/executable_name }
// 224:
// 225:     before do
// 226:       sandbox_class.test_executable_name = executable_name
// 227:       sandbox_class.unsuitable_executables = []
// 228:       stub_const("HOMEBREW_ORIGINAL_BREW_FILE", homebrew_bin/"brew")
// 229:     end
// 230:
// 231:     it "uses the first suitable executable candidate" do
// 232:       FileUtils.touch first_executable
// 233:       FileUtils.chmod "+x", first_executable
// 234:       FileUtils.touch second_executable
// 235:       FileUtils.chmod "+x", second_executable
// 236:       stub_const("ORIGINAL_PATHS", [first_dir])
// 237:
// 238:       with_env(PATH: second_dir.to_s) do
// 239:         expect(sandbox_class.executable).to eq(first_executable)
// 240:       end
// 241:     end
// 242:
// 243:     it "skips unsuitable executable candidates" do
// 244:       FileUtils.touch first_executable
// 245:       FileUtils.chmod "+x", first_executable
// 246:       FileUtils.touch second_executable
// 247:       FileUtils.chmod "+x", second_executable
// 248:       stub_const("ORIGINAL_PATHS", [first_dir])
// 249:       sandbox_class.unsuitable_executables = [first_executable]
// 250:
// 251:       with_env(PATH: second_dir.to_s) do
// 252:         expect(sandbox_class.executable).to eq(second_executable)
// 253:       end
// 254:     end
// 255:
// 256:     it "falls back to the original Homebrew bin directory" do
// 257:       FileUtils.touch homebrew_executable
// 258:       FileUtils.chmod "+x", homebrew_executable
// 259:       stub_const("ORIGINAL_PATHS", [])
// 260:
// 261:       with_env(PATH: mktmpdir.to_s) do
// 262:         expect(sandbox_class.executable).to eq(homebrew_executable)
// 263:       end
// 264:     end
// 265:
// 266:     it "checks absolute executable paths directly" do
// 267:       FileUtils.touch first_executable
// 268:       FileUtils.chmod "+x", first_executable
// 269:       sandbox_class.test_executable_name = first_executable.to_s
// 270:       stub_const("ORIGINAL_PATHS", [])
// 271:
// 272:       with_env(PATH: mktmpdir.to_s) do
// 273:         expect(sandbox_class.executable).to eq(first_executable)
// 274:       end
// 275:     end
// 276:
// 277:     it "raises when no executable candidate exists" do
// 278:       stub_const("ORIGINAL_PATHS", [])
// 279:
// 280:       with_env(PATH: mktmpdir.to_s) do
// 281:         expect { sandbox_class.executable! }
// 282:           .to raise_error(RuntimeError, "#{executable_name} is required to use the sandbox.")
// 283:       end
// 284:     end
// 285:   end
// 286:
// 287:   describe "#path_filter" do
// 288:     # The OS-specific renderer quotes paths safely, so no character is rejected.
// 289:     test_each(["'", '"', "(", ")", "\\", " ", ";", "#", "\n"]) do |char|
// 290:       it "allows paths containing #{char.inspect}" do
// 291:         expect { sandbox.path_filter(mktmpdir/"foo#{char}bar", :subpath) }.not_to raise_error
// 292:       end
// 293:     end
// 294:   end
// 295:
// 296:   describe "#allow_read_if_exists" do
// 297:     it "allows reads for existing paths" do
// 298:       file = mktmpdir/"foo.rb"
// 299:       FileUtils.touch file
// 300:
// 301:       sandbox.allow_read_if_exists path: file
// 302:
// 303:       rule = sandbox.profile.rules.fetch(-1)
// 304:       expect(rule).to have_attributes(allow: true, operation: "file-read*")
// 305:       expect(rule.filter).to have_attributes(path: file.realpath.to_s, type: :literal)
// 306:     end
// 307:
// 308:     it "skips missing paths" do
// 309:       sandbox.allow_read_if_exists path: mktmpdir/"missing.rb"
// 310:
// 311:       expect(sandbox.profile.rules).to be_empty
// 312:     end
// 313:
// 314:     it "skips nil paths" do
// 315:       sandbox.allow_read_if_exists path: nil
// 316:
// 317:       expect(sandbox.profile.rules).to be_empty
// 318:     end
// 319:   end
// 320:
// 321:   describe "#allow_process_exec" do
// 322:     it "allows a process to run outside the sandbox when requested" do
// 323:       sandbox.allow_process_exec "/usr/bin/sudo", no_sandbox: true
// 324:
// 325:       rule = sandbox.profile.rules.fetch(-1)
// 326:       expect(rule).to have_attributes(allow: true, operation: "process-exec", modifier: "no-sandbox")
// 327:       expect(rule.filter).to have_attributes(path: "/usr/bin/sudo", type: :literal)
// 328:     end
// 329:   end
// 330:
// 331:   describe "#deny_read_path" do
// 332:     it "denies reads for a subpath" do
// 333:       dir = mktmpdir/"foo"
// 334:       dir.mkpath
// 335:
// 336:       sandbox.deny_read_path dir
// 337:
// 338:       rule = sandbox.profile.rules.fetch(-1)
// 339:       expect(rule).to have_attributes(allow: false, operation: "file-read*")
// 340:       expect(rule.filter).to have_attributes(path: dir.realpath.to_s, type: :subpath)
// 341:     end
// 342:   end
// 343:
// 344:   describe "#deny_read_home" do
// 345:     let(:home) { mktmpdir/"home" }
// 346:     let(:prefix) { mktmpdir/"prefix" }
// 347:     let(:repository) { mktmpdir/"repository" }
// 348:     let(:temp) { mktmpdir/"tmp" }
// 349:     let(:cache) { mktmpdir/"cache" }
// 350:     let(:logs) { mktmpdir/"logs" }
// 351:
// 352:     before do
// 353:       [home, prefix, repository, temp, cache, logs].each(&:mkpath)
// 354:       allow(Dir).to receive(:home).with(ENV.fetch("USER")).and_return(home.to_s)
// 355:       stub_const("HOMEBREW_PREFIX", prefix)
// 356:       stub_const("HOMEBREW_REPOSITORY", repository)
// 357:       stub_const("HOMEBREW_TEMP", temp)
// 358:       stub_const("HOMEBREW_CACHE", cache)
// 359:       stub_const("HOMEBREW_LOGS", logs)
// 360:     end
// 361:
// 362:     it "denies reads from the real home" do
// 363:       sandbox.deny_read_home
// 364:
// 365:       rule = sandbox.profile.rules.fetch(-1)
// 366:       expect(rule).to have_attributes(allow: false, operation: "file-read*")
// 367:       expect(rule.filter).to have_attributes(path: home.realpath.to_s, type: :subpath)
// 368:     end
// 369:
// 370:     test_each([
// 371:       [:HOMEBREW_PREFIX, "prefix"],
// 372:       [:HOMEBREW_REPOSITORY, "repository"],
// 373:       [:HOMEBREW_CACHE, "cache"],
// 374:       [:HOMEBREW_TEMP, "tmp"],
// 375:       [:HOMEBREW_LOGS, "Library/Logs/Homebrew"],
// 376:     ]) do |(constant, directory)|
// 377:       it "skips the deny when #{constant} is inside the real home" do
// 378:         stub_const(constant.to_s, home/directory)
// 379:         # The constant under test is chosen dynamically per example.
// 380:         # rubocop:disable Sorbet/ConstantsFromStrings
// 381:         Object.const_get(constant).mkpath
// 382:         # rubocop:enable Sorbet/ConstantsFromStrings
// 383:
// 384:         sandbox.deny_read_home
// 385:
// 386:         expect(sandbox.profile.rules).to be_empty
// 387:       end
// 388:     end
// 389:
// 390:     test_each([
// 391:       ["GITHUB_WORKSPACE", "workspace"],
// 392:       ["RUNNER_WORKSPACE", "runner-workspace"],
// 393:       ["RUNNER_TEMP", "runner-temp"],
// 394:     ]) do |(env, directory)|
// 395:       it "skips the deny when #{env} is inside the real home" do
// 396:         (home/directory).mkpath
// 397:
// 398:         with_env(env => (home/directory).to_s) do
// 399:           sandbox.deny_read_home
// 400:         end
// 401:
// 402:         expect(sandbox.profile.rules).to be_empty
// 403:       end
// 404:     end
// 405:
// 406:     it "skips the deny when a runner path resolves inside the real home" do
// 407:       (home/"workspace").mkpath
// 408:       workspace_link = mktmpdir/"workspace"
// 409:       FileUtils.ln_s home/"workspace", workspace_link
// 410:
// 411:       with_env(GITHUB_WORKSPACE: workspace_link.to_s) do
// 412:         sandbox.deny_read_home
// 413:       end
// 414:
// 415:       expect(sandbox.profile.rules).to be_empty
// 416:     end
// 417:
// 418:     it "denies known sensitive home paths when Homebrew needs home access" do
// 419:       cache = home/"Library/Caches/Homebrew"
// 420:       stub_const("HOMEBREW_CACHE", cache)
// 421:       allowed_dirs = [
// 422:         cache,
// 423:         home/"Library/Preferences",
// 424:         home/".config",
// 425:         home/".config/homebrew",
// 426:         home/"src",
// 427:       ]
// 428:       sensitive_dirs = [
// 429:         home/".claude",
// 430:         home/".config/gcloud",
// 431:         home/".config/gh",
// 432:         home/".config/fish",
// 433:         home/".config/huggingface",
// 434:         home/".config/pip",
// 435:         home/".config/pypoetry",
// 436:         home/".config/rclone",
// 437:         home/".kiro",
// 438:         home/".pip",
// 439:         home/".ssh",
// 440:         home/"Documents",
// 441:       ]
// 442:       sensitive_files = [
// 443:         home/".bash_login",
// 444:         home/".bash_logout",
// 445:         home/".bash_profile",
// 446:         home/".bashrc",
// 447:         home/".bash_history",
// 448:         home/".cache/huggingface/token",
// 449:         home/".claude.json",
// 450:         home/".config/composer/auth.json",
// 451:         home/".config/containers/auth.json",
// 452:         home/".config/sops/age/keys.txt",
// 453:         home/".cargo/credentials.toml",
// 454:         home/".gem/credentials",
// 455:         home/".git-credentials",
// 456:         home/".mysql_history",
// 457:         home/".netrc",
// 458:         home/".npmrc",
// 459:         home/".profile",
// 460:         home/".psql_history",
// 461:         home/".pypirc",
// 462:         home/".python_history",
// 463:         home/".terraform.d/credentials.tfrc.json",
// 464:         home/".zlogin",
// 465:         home/".zlogout",
// 466:         home/".zprofile",
// 467:         home/".zshenv",
// 468:         home/".zshrc",
// 469:         home/".zsh_history",
// 470:       ]
// 471:
// 472:       [*allowed_dirs, *sensitive_dirs].each(&:mkpath)
// 473:       sensitive_files.each do |path|
// 474:         path.dirname.mkpath
// 475:         FileUtils.touch path
// 476:       end
// 477:
// 478:       sandbox.deny_read_home
// 479:
// 480:       denied = sandbox.profile.rules.map { |rule| rule.filter&.path }
// 481:       expect(denied).to include(*(sensitive_dirs + sensitive_files).map { |path| path.realpath.to_s })
// 482:       expect(denied).not_to include(*allowed_dirs.map { |path| path.realpath.to_s })
// 483:     end
// 484:
// 485:     it "keeps Homebrew readable inside a sensitive home path" do
// 486:       stub_const("HOMEBREW_PREFIX", home/"Documents/homebrew")
// 487:       [HOMEBREW_PREFIX, home/".ssh"].each(&:mkpath)
// 488:
// 489:       sandbox.deny_read_home
// 490:
// 491:       denied = sandbox.profile.rules.map { |rule| rule.filter&.path }
// 492:       expect(denied).to contain_exactly((home/".ssh").realpath.to_s)
// 493:     end
// 494:
// 495:     it "warns when Homebrew is inside a sensitive home path" do
// 496:       stub_const("HOMEBREW_PREFIX", home/"Documents/homebrew")
// 497:       HOMEBREW_PREFIX.mkpath
// 498:
// 499:       expect(sandbox).to receive(:opoo).with(<<~EOS)
// 500:         The sandbox cannot prevent formulae from reading:
// 501:           #{(home/"Documents").realpath}
// 502:         because this required path is inside it:
// 503:           #{HOMEBREW_PREFIX.realpath}
// 504:         Formulae may access personal data in this directory.
// 505:       EOS
// 506:
// 507:       sandbox.deny_read_home
// 508:     end
// 509:
// 510:     it "does not deny arbitrary home entries whose names contain parentheses or backslashes" do
// 511:       stub_const("HOMEBREW_LOGS", home/"Library/Logs/Homebrew")
// 512:       teams_log = home/"Library/Logs/Microsoft Teams Helper (Renderer)"
// 513:       backslash_dir = home/"I:\\"
// 514:       [home/"Library/Logs/Homebrew", teams_log, backslash_dir, home/".ssh"].each(&:mkpath)
// 515:
// 516:       sandbox.deny_read_home
// 517:
// 518:       denied = sandbox.profile.rules.map { |rule| rule.filter&.path }
// 519:       expect(denied).to include((home/".ssh").realpath.to_s)
// 520:       expect(denied).not_to include(teams_log.realpath.to_s, backslash_dir.realpath.to_s)
// 521:     end
// 522:
// 523:     it "does not deny sensitive symlinks that resolve outside home" do
// 524:       stub_const("HOMEBREW_CACHE", home/"Library/Caches/Homebrew")
// 525:       HOMEBREW_CACHE.mkpath
// 526:       FileUtils.ln_s File::NULL, home/".mysql_history"
// 527:
// 528:       sandbox.deny_read_home
// 529:
// 530:       denied = sandbox.profile.rules.map { |rule| rule.filter&.path }
// 531:       expect(denied).not_to include(File::NULL)
// 532:     end
// 533:
// 534:     it "passes resolved sensitive paths to deny_read_path" do
// 535:       stub_const("HOMEBREW_CACHE", home/"Library/Caches/Homebrew")
// 536:       HOMEBREW_CACHE.mkpath
// 537:       target = home/"history"
// 538:       FileUtils.touch target
// 539:       FileUtils.ln_s target, home/".mysql_history"
// 540:
// 541:       expect(sandbox).to receive(:deny_read_path).with(target.realpath)
// 542:
// 543:       sandbox.deny_read_home
// 544:     end
// 545:
// 546:     it "ignores broken sensitive symlinks" do
// 547:       stub_const("HOMEBREW_CACHE", home/"Library/Caches/Homebrew")
// 548:       HOMEBREW_CACHE.mkpath
// 549:       FileUtils.ln_s home/"missing", home/".mysql_history"
// 550:
// 551:       expect { sandbox.deny_read_home }.not_to raise_error
// 552:     end
// 553:
// 554:     it "keeps the trust store readable so sandboxed builds can re-check tap trust" do
// 555:       stub_const("HOMEBREW_CACHE", home/"Library/Caches/Homebrew")
// 556:       config_home = home/".homebrew"
// 557:       [home/"Library/Caches/Homebrew", config_home, home/".ssh"].each(&:mkpath)
// 558:       trust_file = config_home/"trust.json"
// 559:       FileUtils.touch trust_file
// 560:
// 561:       with_env(HOMEBREW_USER_CONFIG_HOME: config_home.to_s) do
// 562:         sandbox.deny_read_home
// 563:       end
// 564:
// 565:       denied = sandbox.profile.rules.map { |rule| rule.filter&.path }
// 566:       expect(denied).to include((home/".ssh").realpath.to_s)
// 567:       expect(denied).not_to include(trust_file.realpath.to_s)
// 568:     end
// 569:
// 570:     it "keeps the XDG trust store readable so sandboxed builds can re-check tap trust" do
// 571:       stub_const("HOMEBREW_CACHE", home/"Library/Caches/Homebrew")
// 572:       config_home = home/".config/homebrew"
// 573:       gh_config = home/".config/gh"
// 574:       [home/"Library/Caches/Homebrew", config_home, gh_config, home/".ssh"].each(&:mkpath)
// 575:       trust_file = config_home/"trust.json"
// 576:       FileUtils.touch trust_file
// 577:
// 578:       with_env(HOMEBREW_USER_CONFIG_HOME: config_home.to_s) do
// 579:         sandbox.deny_read_home
// 580:       end
// 581:
// 582:       denied = sandbox.profile.rules.map { |rule| rule.filter&.path }
// 583:       expect(denied).to include(gh_config.realpath.to_s)
// 584:       expect(denied).to include((home/".ssh").realpath.to_s)
// 585:       expect(denied).not_to include((home/".config").realpath.to_s)
// 586:       expect(denied).not_to include(trust_file.realpath.to_s)
// 587:     end
// 588:
// 589:     it "keeps the Xcode directories readable so builds can use them", :needs_macos do
// 590:       developer = home/"Library/Developer"
// 591:       swiftpm = home/"Library/Caches/org.swift.swiftpm"
// 592:       [developer, swiftpm, home/".ssh"].each(&:mkpath)
// 593:
// 594:       sandbox.deny_read_home
// 595:
// 596:       denied = sandbox.profile.rules.map { |rule| rule.filter&.path }
// 597:       expect(denied).not_to include(developer.realpath.to_s, swiftpm.realpath.to_s)
// 598:       expect(denied).to include((home/".ssh").realpath.to_s)
// 599:     end
// 600:   end
// 601:
// 602:   describe "#allow_write_path_if_exists" do
// 603:     it "allows writes for existing paths" do
// 604:       dir = mktmpdir/"foo"
// 605:       dir.mkpath
// 606:
// 607:       sandbox.allow_write_path_if_exists dir
// 608:
// 609:       rule = sandbox.profile.rules.fetch(0)
// 610:       expect(rule).to have_attributes(allow: true, operation: "file-write*")
// 611:       expect(rule.filter).to have_attributes(path: dir.realpath.to_s, type: :subpath)
// 612:     end
// 613:
// 614:     it "skips missing paths" do
// 615:       sandbox.allow_write_path_if_exists mktmpdir/"missing"
// 616:
// 617:       expect(sandbox.profile.rules).to be_empty
// 618:     end
// 619:
// 620:     it "skips nil paths" do
// 621:       sandbox.allow_write_path_if_exists nil
// 622:
// 623:       expect(sandbox.profile.rules).to be_empty
// 624:     end
// 625:   end
// 626: end
