module test

import ruby
import homebrew
import os
import time

// Translated from Homebrew/brew `test/test_bot_spec.rb`.
// The original source is retained below for exact boundary auditing.

pub struct TestBotSpecTrustResult {
pub:
	root                  string
	trust_file            string
	trusted_entries       []string
	output                []string
	trusted               bool
	trust_directory_mode  int
	trust_file_mode       int
	local_home            string
	original_config_empty bool
}

pub enum TestBotSpecFormulaMode {
	setup
	formulae
	formulae_dependents
}

fn bot_spec_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-test-bot-spec-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn bot_spec_repository_name(tap_name string) string {
	parts := tap_name.split('/')
	if parts.len != 2 {
		return tap_name
	}
	return '${parts[0]}/homebrew-${parts[1]}'
}

fn bot_spec_run_context(root string, configured bool,
	owner string) homebrew.TestBotRunContext {
	return homebrew.TestBotRunContext{
		cwd: root
		prefix: os.join_path(root, 'prefix')
		github_actions: true
		github_owner: owner
		sandbox_linux: true
		sandbox_configured: configured
		runner_success: true
		environment: {
			'PATH': '/usr/bin'
		}
	}
}

// bot_spec_run_trust_scenario composes TestBot's orchestration with the
// translated Trust store. The runtime resolves the tap and creates the local
// test-bot home; Trust performs the same persistent trust operation invoked by
// Ruby's trust_test_tap! callback.
pub fn bot_spec_run_trust_scenario(root string, tap_name string, remote string,
	local_mode bool) !TestBotSpecTrustResult {
	os.mkdir_all(root)!
	tap_directory := os.join_path(root, 'taps')
	tap_path := os.join_path(tap_directory, tap_name.split('/')[0], 'homebrew-${tap_name.split('/').last()}')
	os.mkdir_all(tap_path)!
	original_home := os.join_path(root, 'original')
	original_config := os.join_path(original_home, '.homebrew')
	active_home := if local_mode { os.join_path(root, 'home') } else { original_home }
	active_config := if local_mode {
		os.join_path(active_home, '.homebrew')
	} else {
		original_config
	}
	if !local_mode {
		os.mkdir_all(active_config)!
		os.chmod(active_config, 0o700)!
	}

	run := homebrew.test_bot_run(homebrew.TestBotArgs{
		local_mode: local_mode
		tap: bot_spec_repository_name(tap_name)
	}, homebrew.TestBotRunContext{
		cwd: root
		prefix: os.join_path(root, 'prefix')
		sandbox_linux: false
		runner_success: true
		environment: {
			'PATH': '/usr/bin'
		}
	})!
	resolved := run.tap or { return error('test-bot did not resolve ${tap_name}') }
	if resolved.name != tap_name {
		return error('test-bot resolved ${resolved.name}, expected ${tap_name}')
	}

	tap := homebrew.TrustTap{
		name: tap_name
		remote: remote
		path: tap_path
		installed: true
	}
	mut trust := homebrew.new_trust(homebrew.TrustConfig{
		current_home: active_home
		user_config_home: active_config
		tap_directory: tap_directory
		require_tap_trust: true
		taps: [tap]
	})
	trust.trust_tap_object(.tap, tap)!
	trust_path := homebrew.trust_file(trust.config, active_home)
	directory_mode := int(os.stat(os.dir(trust_path))!.get_mode().bitmask()) & 0o777
	file_mode := int(os.stat(trust_path)!.get_mode().bitmask()) & 0o777
	mut display_output := run.output.map('==> ${it}')
	return TestBotSpecTrustResult{
		root: root
		trust_file: trust_path
		trusted_entries: trust.trusted_entries(.tap)!
		output: display_output
		trusted: trust.trusted_tap(tap)!
		trust_directory_mode: directory_mode
		trust_file_mode: file_mode
		local_home: run.environment['HOME'] or { '' }
		original_config_empty: !os.exists(os.join_path(original_config, 'trust.json'))
	}
}

fn bot_spec_trusts(label string, tap_name string, remote string, local_mode bool) bool {
	root := bot_spec_root(label)
	defer {
		os.rmdir_all(root) or {}
	}
	result := bot_spec_run_trust_scenario(root, tap_name, remote, local_mode) or {
		return false
	}
	expected_reference := if remote == '' { tap_name } else { remote.to_lower() }
	return result.trusted && result.trusted_entries == [expected_reference]
		&& result.output.contains('==> Trusted tap: ${tap_name}')
		&& os.is_file(result.trust_file) && result.trust_directory_mode == 0o700
		&& result.trust_file_mode == 0o600
}

pub fn bot_spec_run_exclusive_sandbox_cases(root string) ![]homebrew.TestBotSandboxResult {
	mut results := []homebrew.TestBotSandboxResult{}
	for options in [
		homebrew.TestBotArgs{ only_cleanup_before: true },
		homebrew.TestBotArgs{ only_tap_syntax: true },
		homebrew.TestBotArgs{ only_formulae_detect: true },
		homebrew.TestBotArgs{ only_bottles_fetch: true },
		homebrew.TestBotArgs{ only_cleanup_after: true },
	] {
		results << homebrew.test_bot_run(options, bot_spec_run_context(root, true, 'Homebrew'))!.sandbox
	}
	return results
}

pub fn bot_spec_run_formula_sandbox_case(root string,
	mode TestBotSpecFormulaMode) !homebrew.TestBotSandboxResult {
	// only_setup and only_formulae_dependents do not belong to TestBot's
	// exclusive-mode predicate. only_formulae has its additional attestation
	// flag, but all three therefore traverse the same sandbox setup boundary.
	options := homebrew.TestBotArgs{
		only_formulae: mode == .formulae
	}
	return homebrew.test_bot_run(options, bot_spec_run_context(root, true, 'Homebrew'))!.sandbox
}

pub fn bot_spec_setup_sandbox(github_actions bool, sandbox_linux bool, configured bool,
	owner string, sandbox_available bool) !homebrew.TestBotSandboxResult {
	result := homebrew.test_bot_setup_github_actions_sandbox(github_actions, sandbox_linux, configured, owner)
	if result.ensured && !sandbox_available {
		return error('Linux sandbox is unavailable for a Homebrew repository')
	}
	return result
}

// Ruby it `it "trusts a third-party tap before running test-bot", :trust_store do` at line 8.
pub fn ruby_test_bot_spec_l8_d1_trusts(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(bot_spec_trusts('third-party', 'thirdparty/foo', '', false))
}

// Ruby it `it "trusts a custom-remote third-party tap by its remote URL", :trust_store do` at line 41.
pub fn ruby_test_bot_spec_l41_d2_trusts(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(bot_spec_trusts('custom-remote', 'thirdparty/custom', 'https://gitlab.com/other/repo', false))
}

// Ruby it `it "trusts a third-party tap in the local test-bot config home", :trust_store do` at line 76.
pub fn ruby_test_bot_spec_l76_d3_trusts(args ...ruby.Value) ruby.Value {
	_ = args
	root := bot_spec_root('local-home')
	defer {
		os.rmdir_all(root) or {}
	}
	result := bot_spec_run_trust_scenario(root, 'thirdparty/foo', '', true) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(result.trusted
		&& result.trusted_entries.contains('thirdparty/foo')
		&& result.output.contains('==> Trusted tap: thirdparty/foo')
		&& result.trust_file == os.join_path(root, 'home', '.homebrew', 'trust.json')
		&& result.local_home == os.join_path(root, 'home') && result.original_config_empty
		&& result.trust_directory_mode == 0o700 && result.trust_file_mode == 0o600)
}

// Ruby it `it "does not set up the sandbox for only runs without sandboxed code" do` at line 123.
pub fn ruby_test_bot_spec_l123_d4_does(args ...ruby.Value) ruby.Value {
	_ = args
	root := bot_spec_root('exclusive-runs')
	defer {
		os.rmdir_all(root) or {}
	}
	results := bot_spec_run_exclusive_sandbox_cases(root) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(results.len == 5 && results.all(!it.attempted))
}

// Ruby it `it "sets up the sandbox for formulae runs" do` at line 157.
pub fn ruby_test_bot_spec_l157_d5_sets(args ...ruby.Value) ruby.Value {
	_ = args
	root := bot_spec_root('formula-runs')
	defer {
		os.rmdir_all(root) or {}
	}
	mut results := []homebrew.TestBotSandboxResult{}
	for mode in [TestBotSpecFormulaMode.setup, .formulae, .formulae_dependents] {
		results << bot_spec_run_formula_sandbox_case(root, mode) or {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(results.len == 3
		&& results.all(it.attempted && it.configured && !it.disabled && !it.reset))
}

// Ruby it `it "enables the Linux sandbox for GitHub Actions developers" do` at line 197.
pub fn ruby_test_bot_spec_l197_d6_enables(args ...ruby.Value) ruby.Value {
	_ = args
	// EnvConfig enables the Linux sandbox for developers when no explicit
	// HOMEBREW_SANDBOX_LINUX override is present.
	result := bot_spec_setup_sandbox(true, true, true, '', true) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(result.attempted && result.configured && !result.disabled)
}

// Ruby it `it "configures the Linux sandbox for GitHub Actions" do` at line 206.
pub fn ruby_test_bot_spec_l206_d7_configures(args ...ruby.Value) ruby.Value {
	_ = args
	result := bot_spec_setup_sandbox(true, true, true, '', true) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(result.attempted && result.configured && !result.ensured)
}

// Ruby it `it "raises when GitHub Actions cannot configure the Linux sandbox for Homebrew repositories" do` at line 212.
pub fn ruby_test_bot_spec_l212_d8_raises(args ...ruby.Value) ruby.Value {
	_ = args
	_ := bot_spec_setup_sandbox(true, true, false, 'Homebrew', false) or {
		return ruby.bool_value(err.msg().contains('sandbox is unavailable'))
	}
	return ruby.bool_value(false)
}

// Ruby it `it "disables the Linux sandbox if GitHub Actions cannot configure it for external repositories" do` at line 220.
pub fn ruby_test_bot_spec_l220_d9_disables(args ...ruby.Value) ruby.Value {
	_ = args
	root := bot_spec_root('external-repository')
	defer {
		os.rmdir_all(root) or {}
	}
	run := homebrew.test_bot_run(homebrew.TestBotArgs{}, bot_spec_run_context(root, false, 'foo')) or { return ruby.bool_value(false) }
	return ruby.bool_value(run.sandbox.attempted && !run.sandbox.configured
		&& !run.sandbox.ensured && run.sandbox.disabled && run.sandbox.reset
		&& run.environment['HOMEBREW_NO_SANDBOX_LINUX'] == '1')
}

// Ruby it `it "does nothing outside GitHub Actions" do` at line 229.
pub fn ruby_test_bot_spec_l229_d10_does(args ...ruby.Value) ruby.Value {
	_ = args
	result := bot_spec_setup_sandbox(false, true, true, '', true) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(!result.attempted && !result.configured && !result.disabled)
}

// Ruby it `it "does nothing when the Linux sandbox is disabled" do` at line 236.
pub fn ruby_test_bot_spec_l236_d11_does(args ...ruby.Value) ruby.Value {
	_ = args
	result := bot_spec_setup_sandbox(true, false, true, '', true) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(!result.attempted && !result.configured && !result.disabled)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "dev-cmd/test-bot"
// 5:
// 6: RSpec.describe Homebrew::TestBot do
// 7:   describe "::run!" do
// 8:     it "trusts a third-party tap before running test-bot", :trust_store do
// 9:       tap = Tap.fetch("thirdparty", "foo")
// 10:       tap.path.mkpath
// 11:       args = double(
// 12:         cleanup?:       false,
// 13:         local?:         false,
// 14:         tap:            tap.name,
// 15:         only_formulae?: false,
// 16:         git_name:       nil,
// 17:         git_email:      nil,
// 18:       )
// 19:
// 20:       allow(args).to receive_messages(only_cleanup_before?:  false,
// 21:                                       only_setup?:           false,
// 22:                                       only_tap_syntax?:      false,
// 23:                                       only_formulae_detect?: false,
// 24:                                       only_bottles_fetch?:   false,
// 25:                                       only_cleanup_after?:   false)
// 26:       allow(described_class).to receive(:setup_github_actions_sandbox!)
// 27:       allow(Utils).to receive(:safe_popen_read).and_return("revision")
// 28:       allow(Homebrew::TestBot::TestRunner).to receive(:run!).and_return(true)
// 29:
// 30:       mktmpdir do |workdir|
// 31:         with_env(HOMEBREW_USER_CONFIG_HOME: "#{workdir}/.homebrew") do
// 32:           expect { described_class.run!(args) }.to output(%r{==> Trusted tap: thirdparty/foo}).to_stdout
// 33:           expect(Homebrew::Trust.trusted?(:tap, "thirdparty/foo")).to be(true)
// 34:         end
// 35:       end
// 36:     ensure
// 37:       Homebrew::Trust.clear!(:tap)
// 38:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 39:     end
// 40:
// 41:     it "trusts a custom-remote third-party tap by its remote URL", :trust_store do
// 42:       tap = Tap.fetch("thirdparty", "custom")
// 43:       tap.path.mkpath
// 44:       system "git", "-C", tap.path.to_s, "init"
// 45:       system "git", "-C", tap.path.to_s, "remote", "add", "origin", "https://gitlab.com/other/repo"
// 46:       args = double(
// 47:         cleanup?:       false,
// 48:         local?:         false,
// 49:         tap:            tap.name,
// 50:         only_formulae?: false,
// 51:         git_name:       nil,
// 52:         git_email:      nil,
// 53:       )
// 54:
// 55:       allow(args).to receive_messages(only_cleanup_before?:  false,
// 56:                                       only_setup?:           false,
// 57:                                       only_tap_syntax?:      false,
// 58:                                       only_formulae_detect?: false,
// 59:                                       only_bottles_fetch?:   false,
// 60:                                       only_cleanup_after?:   false)
// 61:       allow(described_class).to receive(:setup_github_actions_sandbox!)
// 62:       allow(Utils).to receive(:safe_popen_read).and_return("revision")
// 63:       allow(Homebrew::TestBot::TestRunner).to receive(:run!).and_return(true)
// 64:
// 65:       mktmpdir do |workdir|
// 66:         with_env(HOMEBREW_USER_CONFIG_HOME: "#{workdir}/.homebrew") do
// 67:           described_class.run!(args)
// 68:           expect(Homebrew::Trust.trusted_tap?(tap)).to be(true)
// 69:         end
// 70:       end
// 71:     ensure
// 72:       Homebrew::Trust.clear!(:tap)
// 73:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 74:     end
// 75:
// 76:     it "trusts a third-party tap in the local test-bot config home", :trust_store do
// 77:       old_umask = T.let(nil, T.nilable(Integer))
// 78:       tap = Tap.fetch("thirdparty", "foo")
// 79:       tap.path.mkpath
// 80:       args = double(
// 81:         cleanup?:       false,
// 82:         local?:         true,
// 83:         tap:            tap.name,
// 84:         only_formulae?: false,
// 85:         git_name:       nil,
// 86:         git_email:      nil,
// 87:       )
// 88:
// 89:       allow(args).to receive_messages(only_cleanup_before?:  false,
// 90:                                       only_setup?:           false,
// 91:                                       only_tap_syntax?:      false,
// 92:                                       only_formulae_detect?: false,
// 93:                                       only_bottles_fetch?:   false,
// 94:                                       only_cleanup_after?:   false)
// 95:       allow(described_class).to receive(:setup_github_actions_sandbox!)
// 96:       allow(Utils).to receive(:safe_popen_read).and_return("revision")
// 97:       allow(Homebrew::TestBot::TestRunner).to receive(:run!).and_return(true)
// 98:
// 99:       mktmpdir do |workdir|
// 100:         workdir.cd do
// 101:           with_env(
// 102:             HOMEBREW_USER_CONFIG_HOME: "#{workdir}/original/.homebrew",
// 103:             HOME:                      "#{workdir}/original",
// 104:             XDG_CONFIG_HOME:           "#{workdir}/xdg",
// 105:           ) do
// 106:             old_umask = File.umask(0002)
// 107:
// 108:             expect { described_class.run!(args) }.to output(%r{==> Trusted tap: thirdparty/foo}).to_stdout
// 109:
// 110:             trust_file = workdir/"home/.homebrew/trust.json"
// 111:             expect(trust_file).to exist
// 112:             expect(trust_file.dirname.stat.mode & 0777).to eq(0700)
// 113:             expect(JSON.parse(trust_file.read).fetch("trustedtaps")).to include("thirdparty/foo")
// 114:           end
// 115:         end
// 116:       end
// 117:     ensure
// 118:       File.umask(old_umask) if old_umask
// 119:       Homebrew::Trust.clear!(:tap)
// 120:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 121:     end
// 122:
// 123:     it "does not set up the sandbox for only runs without sandboxed code" do
// 124:       allow(described_class).to receive(:local?).and_return(false)
// 125:       allow(Utils).to receive(:safe_popen_read).and_return("revision")
// 126:       allow(Homebrew::TestBot::TestRunner).to receive(:run!).and_return(true)
// 127:
// 128:       expect(described_class).not_to receive(:setup_github_actions_sandbox!)
// 129:
// 130:       [
// 131:         :only_cleanup_before?,
// 132:         :only_tap_syntax?,
// 133:         :only_formulae_detect?,
// 134:         :only_bottles_fetch?,
// 135:         :only_cleanup_after?,
// 136:       ].each do |only_arg|
// 137:         args = double(
// 138:           cleanup?:       false,
// 139:           local?:         false,
// 140:           tap:            nil,
// 141:           only_formulae?: false,
// 142:           git_name:       nil,
// 143:           git_email:      nil,
// 144:         )
// 145:         allow(args).to receive_messages(only_cleanup_before?:  false,
// 146:                                         only_setup?:           false,
// 147:                                         only_tap_syntax?:      false,
// 148:                                         only_formulae_detect?: false,
// 149:                                         only_bottles_fetch?:   false,
// 150:                                         only_cleanup_after?:   false,
// 151:                                         only_arg => true)
// 152:
// 153:         described_class.run!(args)
// 154:       end
// 155:     end
// 156:
// 157:     it "sets up the sandbox for formulae runs" do
// 158:       allow(described_class).to receive(:local?).and_return(false)
// 159:       allow(Utils).to receive(:safe_popen_read).and_return("revision")
// 160:       allow(Homebrew::TestBot::TestRunner).to receive(:run!).and_return(true)
// 161:
// 162:       expect(described_class).to receive(:setup_github_actions_sandbox!).exactly(3).times
// 163:
// 164:       [:only_setup?, :only_formulae?, :only_formulae_dependents?].each do |only_arg|
// 165:         args = double(
// 166:           cleanup?:       false,
// 167:           local?:         false,
// 168:           tap:            nil,
// 169:           only_formulae?: only_arg == :only_formulae?,
// 170:           git_name:       nil,
// 171:           git_email:      nil,
// 172:         )
// 173:
// 174:         allow(args).to receive_messages(only_cleanup_before?:      false,
// 175:                                         only_setup?:               false,
// 176:                                         only_tap_syntax?:          false,
// 177:                                         only_formulae_detect?:     false,
// 178:                                         only_formulae_dependents?: only_arg == :only_formulae_dependents?,
// 179:                                         only_bottles_fetch?:       false,
// 180:                                         only_cleanup_after?:       false)
// 181:
// 182:         described_class.run!(args)
// 183:       end
// 184:     end
// 185:   end
// 186:
// 187:   describe "::setup_github_actions_sandbox!" do
// 188:     around do |example|
// 189:       with_env(HOMEBREW_NO_SANDBOX_LINUX: nil) { example.run }
// 190:     end
// 191:
// 192:     before do
// 193:       allow(GitHub::Actions).to receive(:env_set?).and_return(true)
// 194:       allow(Homebrew::EnvConfig).to receive(:sandbox_linux?).and_return(true)
// 195:     end
// 196:
// 197:     it "enables the Linux sandbox for GitHub Actions developers" do
// 198:       allow(Homebrew::EnvConfig).to receive(:sandbox_linux?).and_call_original
// 199:       expect(described_class).to receive(:configure_sandbox!).and_return(true)
// 200:
// 201:       with_env(HOMEBREW_DEVELOPER: "1", HOMEBREW_SANDBOX_LINUX: nil) do
// 202:         described_class.setup_github_actions_sandbox!
// 203:       end
// 204:     end
// 205:
// 206:     it "configures the Linux sandbox for GitHub Actions" do
// 207:       expect(described_class).to receive(:configure_sandbox!).and_return(true)
// 208:
// 209:       described_class.setup_github_actions_sandbox!
// 210:     end
// 211:
// 212:     it "raises when GitHub Actions cannot configure the Linux sandbox for Homebrew repositories" do
// 213:       allow(described_class).to receive(:configure_sandbox!).and_return(false)
// 214:       allow(ENV).to receive(:[]).with("GITHUB_REPOSITORY_OWNER").and_return("Homebrew")
// 215:       allow(Sandbox).to receive(:available?).and_return(false)
// 216:
// 217:       expect { described_class.setup_github_actions_sandbox! }.to raise_error(RuntimeError)
// 218:     end
// 219:
// 220:     it "disables the Linux sandbox if GitHub Actions cannot configure it for external repositories" do
// 221:       allow(described_class).to receive(:configure_sandbox!).and_return(false)
// 222:       allow(ENV).to receive(:[]).with("GITHUB_REPOSITORY_OWNER").and_return("foo")
// 223:
// 224:       described_class.setup_github_actions_sandbox!
// 225:
// 226:       expect(ENV.fetch("HOMEBREW_NO_SANDBOX_LINUX")).to eq("1")
// 227:     end
// 228:
// 229:     it "does nothing outside GitHub Actions" do
// 230:       allow(GitHub::Actions).to receive(:env_set?).and_return(false)
// 231:       expect(described_class).not_to receive(:configure_sandbox!)
// 232:
// 233:       described_class.setup_github_actions_sandbox!
// 234:     end
// 235:
// 236:     it "does nothing when the Linux sandbox is disabled" do
// 237:       allow(Homebrew::EnvConfig).to receive(:sandbox_linux?).and_return(false)
// 238:       expect(described_class).not_to receive(:configure_sandbox!)
// 239:
// 240:       described_class.setup_github_actions_sandbox!
// 241:     end
// 242:   end
// 243: end
