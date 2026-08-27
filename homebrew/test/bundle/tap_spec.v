module bundle

import brew_runtime

// Translated from Homebrew/brew `test/bundle/tap_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:dumper) { described_class }` at line 10.
pub fn ruby_tap_spec_l10_d1_dumper(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dumper', ...args)
}

// Ruby specify `specify do` at line 18.
pub fn ruby_tap_spec_l18_d2_do(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do', ...args)
}

// Ruby it `it "returns list of information" do` at line 52.
pub fn ruby_tap_spec_l52_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "dumps output" do` at line 56.
pub fn ruby_tap_spec_l56_d4_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dumps', ...args)
}

// Ruby it `it "dumps trusted taps with trusted true" do` at line 66.
pub fn ruby_tap_spec_l66_d5_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dumps', ...args)
}

// Ruby it `it "dumps GitHub clone targets matching a tap's default repository" do` at line 76.
pub fn ruby_tap_spec_l76_d6_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dumps', ...args)
}

// Ruby it `it "dumps partially trusted tap entries with trusted hash values" do` at line 90.
pub fn ruby_tap_spec_l90_d7_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dumps', ...args)
}

// Ruby it `it "calls Homebrew" do` at line 113.
pub fn ruby_tap_spec_l113_d8_calls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('calls', ...args)
}

// Ruby it `it "skips" do` at line 123.
pub fn ruby_tap_spec_l123_d9_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "taps" do` at line 134.
pub fn ruby_tap_spec_l134_d10_taps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('taps', ...args)
}

// Ruby it `it "clears cached tap contents after tapping" do` at line 141.
pub fn ruby_tap_spec_l141_d11_clears(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clears', ...args)
}

// Ruby it `it "taps" do` at line 166.
pub fn ruby_tap_spec_l166_d12_taps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('taps', ...args)
}

// Ruby it `it "fails" do` at line 174.
pub fn ruby_tap_spec_l174_d13_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/skipper"
// 6: require "bundle/tap"
// 7:
// 8: RSpec.describe Homebrew::Bundle::Tap do
// 9:   describe "dumping" do
// 10:     subject(:dumper) { described_class }
// 11:
// 12:     context "when there is no tap" do
// 13:       before do
// 14:         described_class.reset!
// 15:         allow(Tap).to receive(:select).and_return []
// 16:       end
// 17:
// 18:       specify do
// 19:         expect(dumper.tap_names).to be_empty
// 20:         expect(dumper.dump).to eql("")
// 21:       end
// 22:     end
// 23:
// 24:     context "with taps" do
// 25:       before do
// 26:         described_class.reset!
// 27:
// 28:         bar = instance_double(Tap, name: "bitbucket/bar", custom_remote?: true,
// 29:                               remote: "https://bitbucket.org/bitbucket/bar.git",
// 30:                               default_remote: "https://github.com/bitbucket/homebrew-bar")
// 31:         baz = instance_double(Tap, name: "homebrew/baz", custom_remote?: false, remote: nil)
// 32:         foo = instance_double(Tap, name: "homebrew/foo", custom_remote?: false, remote: nil)
// 33:
// 34:         ENV["HOMEBREW_GITHUB_API_TOKEN_BEFORE"] = ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", nil)
// 35:         ENV["HOMEBREW_GITHUB_API_TOKEN"] = "some-token"
// 36:         private_tap = instance_double(Tap, name: "privatebrew/private", custom_remote?: true,
// 37:           remote: "https://#{ENV.fetch("HOMEBREW_GITHUB_API_TOKEN")}@github.com/privatebrew/homebrew-private",
// 38:           default_remote: "https://github.com/privatebrew/homebrew-private")
// 39:
// 40:         [bar, baz, foo, private_tap].each do |tap|
// 41:           allow(tap).to receive(:matches_reference?) { |reference| reference == tap.remote }
// 42:         end
// 43:
// 44:         allow(Tap).to receive(:select).and_return [bar, baz, foo, private_tap]
// 45:       end
// 46:
// 47:       after do
// 48:         ENV["HOMEBREW_GITHUB_API_TOKEN"] = ENV.fetch("HOMEBREW_GITHUB_API_TOKEN_BEFORE", nil)
// 49:         ENV.delete("HOMEBREW_GITHUB_API_TOKEN_BEFORE")
// 50:       end
// 51:
// 52:       it "returns list of information" do
// 53:         expect(dumper.tap_names).not_to be_empty
// 54:       end
// 55:
// 56:       it "dumps output" do
// 57:         expected_output = <<~RUBY
// 58:           tap "bitbucket/bar", "https://bitbucket.org/bitbucket/bar.git"
// 59:           tap "homebrew/baz"
// 60:           tap "homebrew/foo"
// 61:           tap "privatebrew/private", "https://\#{ENV.fetch("HOMEBREW_GITHUB_API_TOKEN")}@github.com/privatebrew/homebrew-private"
// 62:         RUBY
// 63:         expect(dumper.dump).to eql(expected_output.chomp)
// 64:       end
// 65:
// 66:       it "dumps trusted taps with trusted true" do
// 67:         allow(Homebrew::Trust).to receive(:trusted_entries).and_return([])
// 68:         allow(Homebrew::Trust).to receive(:trusted_entries).with(:tap)
// 69:                                                            .and_return(["https://bitbucket.org/bitbucket/bar.git"])
// 70:
// 71:         expect(dumper.dump).to include(
// 72:           "tap \"bitbucket/bar\", \"https://bitbucket.org/bitbucket/bar.git\", trusted: true",
// 73:         )
// 74:       end
// 75:
// 76:       it "dumps GitHub clone targets matching a tap's default repository" do
// 77:         described_class.reset!
// 78:         tap = instance_double(Tap, name: "alternatert/tap", custom_remote?: false,
// 79:           remote: "git@github.com:AlternateRT/homebrew-tap.git",
// 80:           default_remote: "https://github.com/alternatert/homebrew-tap")
// 81:
// 82:         allow(tap).to receive(:matches_reference?) { |reference| reference == tap.remote }
// 83:         allow(Tap).to receive(:select).and_return [tap]
// 84:
// 85:         expect(dumper.dump).to eql(
// 86:           "tap \"alternatert/tap\", \"git@github.com:AlternateRT/homebrew-tap.git\"",
// 87:         )
// 88:       end
// 89:
// 90:       it "dumps partially trusted tap entries with trusted hash values" do
// 91:         allow(Homebrew::Trust).to receive(:trusted_entries).with(:tap).and_return([])
// 92:         allow(Homebrew::Trust).to receive(:trusted_entries).with(:formula)
// 93:                                                            .and_return(["https://bitbucket.org/bitbucket/bar.git/foo"])
// 94:         allow(Homebrew::Trust).to receive(:trusted_entries).with(:cask)
// 95:                                                            .and_return(["https://bitbucket.org/bitbucket/bar.git/baz"])
// 96:         allow(Homebrew::Trust).to receive(:trusted_entries).with(:command)
// 97:                                                            .and_return(["https://bitbucket.org/bitbucket/bar.git/qux"])
// 98:
// 99:         expect(dumper.dump).to include(
// 100:           "tap \"bitbucket/bar\", \"https://bitbucket.org/bitbucket/bar.git\", " \
// 101:           "trusted: { formulae: [\"foo\"], casks: [\"baz\"], commands: [\"qux\"] }",
// 102:         )
// 103:       end
// 104:     end
// 105:   end
// 106:
// 107:   describe "installing" do
// 108:     describe ".installed_taps" do
// 109:       before do
// 110:         described_class.reset!
// 111:       end
// 112:
// 113:       it "calls Homebrew" do
// 114:         expect { described_class.installed_taps }.not_to raise_error
// 115:       end
// 116:     end
// 117:
// 118:     context "when tap is installed" do
// 119:       before do
// 120:         allow(described_class).to receive(:installed_taps).and_return(["homebrew/cask"])
// 121:       end
// 122:
// 123:       it "skips" do
// 124:         expect(Homebrew::Bundle).not_to receive(:system)
// 125:         expect(described_class.preinstall!("homebrew/cask")).to be(false)
// 126:       end
// 127:     end
// 128:
// 129:     context "when tap is not installed" do
// 130:       before do
// 131:         allow(described_class).to receive(:installed_taps).and_return([])
// 132:       end
// 133:
// 134:       it "taps" do
// 135:         expect(Homebrew::Bundle).to receive(:system).with(HOMEBREW_BREW_FILE, "tap", "homebrew/cask",
// 136:                                                           verbose: false).and_return(true)
// 137:         expect(described_class.preinstall!("homebrew/cask")).to be(true)
// 138:         expect(described_class.install!("homebrew/cask")).to be(true)
// 139:       end
// 140:
// 141:       it "clears cached tap contents after tapping" do
// 142:         tap = Tap.fetch("bundle-test/rootformula")
// 143:         FileUtils.rm_rf(tap.path)
// 144:         tap.clear_cache
// 145:
// 146:         expect(tap.formula_dir).to eq(tap.path/"Formula")
// 147:
// 148:         expect(Homebrew::Bundle).to receive(:system).with(HOMEBREW_BREW_FILE, "tap", tap.name,
// 149:                                                           verbose: false) do
// 150:           tap.path.mkpath
// 151:           FileUtils.touch tap.path/"foo.rb"
// 152:           true
// 153:         end
// 154:
// 155:         expect(described_class.install!(tap.name)).to be(true)
// 156:         expect(tap.formula_dir).to eq(tap.path)
// 157:         expect(tap.formula_files_by_name).to include("foo" => tap.path/"foo.rb")
// 158:       ensure
// 159:         if tap
// 160:           FileUtils.rm_rf(tap.path)
// 161:           tap.path.parent.rmdir_if_possible
// 162:         end
// 163:       end
// 164:
// 165:       context "with clone target" do
// 166:         it "taps" do
// 167:           expect(Homebrew::Bundle).to \
// 168:             receive(:system).with(HOMEBREW_BREW_FILE, "tap", "homebrew/cask", "clone_target_path",
// 169:                                   verbose: false).and_return(true)
// 170:           expect(described_class.preinstall!("homebrew/cask", clone_target: "clone_target_path")).to be(true)
// 171:           expect(described_class.install!("homebrew/cask", clone_target: "clone_target_path")).to be(true)
// 172:         end
// 173:
// 174:         it "fails" do
// 175:           expect(Homebrew::Bundle).to \
// 176:             receive(:system).with(HOMEBREW_BREW_FILE, "tap", "homebrew/cask", "clone_target_path",
// 177:                                   verbose: false).and_return(false)
// 178:           expect(described_class.preinstall!("homebrew/cask", clone_target: "clone_target_path")).to be(true)
// 179:           expect(described_class.install!("homebrew/cask", clone_target: "clone_target_path")).to be(false)
// 180:         end
// 181:       end
// 182:     end
// 183:   end
// 184: end
