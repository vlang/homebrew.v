module test

import brew_runtime

// Translated from Homebrew/brew `test/test_bot_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "trusts a third-party tap before running test-bot", :trust_store do` at line 8.
pub fn ruby_test_bot_spec_l8_d1_trusts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trusts', ...args)
}

// Ruby it `it "trusts a custom-remote third-party tap by its remote URL", :trust_store do` at line 41.
pub fn ruby_test_bot_spec_l41_d2_trusts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trusts', ...args)
}

// Ruby it `it "trusts a third-party tap in the local test-bot config home", :trust_store do` at line 76.
pub fn ruby_test_bot_spec_l76_d3_trusts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trusts', ...args)
}

// Ruby it `it "does not set up the sandbox for only runs without sandboxed code" do` at line 123.
pub fn ruby_test_bot_spec_l123_d4_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "sets up the sandbox for formulae runs" do` at line 157.
pub fn ruby_test_bot_spec_l157_d5_sets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sets', ...args)
}

// Ruby it `it "enables the Linux sandbox for GitHub Actions developers" do` at line 197.
pub fn ruby_test_bot_spec_l197_d6_enables(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('enables', ...args)
}

// Ruby it `it "configures the Linux sandbox for GitHub Actions" do` at line 206.
pub fn ruby_test_bot_spec_l206_d7_configures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('configures', ...args)
}

// Ruby it `it "raises when GitHub Actions cannot configure the Linux sandbox for Homebrew repositories" do` at line 212.
pub fn ruby_test_bot_spec_l212_d8_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "disables the Linux sandbox if GitHub Actions cannot configure it for external repositories" do` at line 220.
pub fn ruby_test_bot_spec_l220_d9_disables(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('disables', ...args)
}

// Ruby it `it "does nothing outside GitHub Actions" do` at line 229.
pub fn ruby_test_bot_spec_l229_d10_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does nothing when the Linux sandbox is disabled" do` at line 236.
pub fn ruby_test_bot_spec_l236_d11_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
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
