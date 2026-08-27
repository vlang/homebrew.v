module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/trust_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "notes official taps are always trusted", :integration_test do` at line 20.
pub fn ruby_trust_spec_l20_d1_notes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('notes', ...args)
}

// Ruby it `it "trusts a command with the plural switch alias" do` at line 28.
pub fn ruby_trust_spec_l28_d2_trusts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trusts', ...args)
}

// Ruby it `it "trusts the whole tap by its remote URL" do` at line 50.
pub fn ruby_trust_spec_l50_d3_trusts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trusts', ...args)
}

// Ruby it `it "trusts an individual formula by its remote-qualified entry" do` at line 56.
pub fn ruby_trust_spec_l56_d4_trusts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trusts', ...args)
}

// Ruby it `it "trusts a not-yet-installed tap directly by its non-GitHub remote URL" do` at line 63.
pub fn ruby_trust_spec_l63_d5_trusts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trusts', ...args)
}

// Ruby it `it "canonicalises a GitHub default-remote URL to the tap name" do` at line 71.
pub fn ruby_trust_spec_l71_d6_canonicalises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('canonicalises', ...args)
}

// Ruby it `it "rejects a bare @-string instead of trusting it as a tap" do` at line 79.
pub fn ruby_trust_spec_l79_d7_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "lists trusted entries with no arguments" do` at line 87.
pub fn ruby_trust_spec_l87_d8_lists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lists', ...args)
}

// Ruby it `it "lists trusted entries as json with no arguments" do` at line 103.
pub fn ruby_trust_spec_l103_d9_lists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lists', ...args)
}

// Ruby it `it "lists trusted entries as a json array for a selected type" do` at line 122.
pub fn ruby_trust_spec_l122_d10_lists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lists', ...args)
}

// Ruby it `it "rejects json output with named arguments" do` at line 129.
pub fn ruby_trust_spec_l129_d11_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "rejects json without an explicit version" do` at line 134.
pub fn ruby_trust_spec_l134_d12_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "cmd/trust"
// 6: require "trust"
// 7:
// 8: RSpec.describe Homebrew::Cmd::Trust, :trust_store do
// 9:   RSpec::Matchers.define :match_json do |expected|
// 10:     T.bind(self, T.class_of(RSpec::Matchers::DSL::Matcher))
// 11:     match do |actual|
// 12:       JSON.parse(actual) == expected
// 13:     rescue JSON::ParserError
// 14:       false
// 15:     end
// 16:   end
// 17:
// 18:   it_behaves_like "parseable arguments"
// 19:
// 20:   it "notes official taps are always trusted", :integration_test do
// 21:     expect { brew "trust", "homebrew/core" }
// 22:       .to output("Official tap homebrew/core is always trusted.\n").to_stdout
// 23:       .and be_a_success
// 24:
// 25:     expect(Homebrew::Trust.trusted?(:tap, "homebrew/core")).to be(false)
// 26:   end
// 27:
// 28:   it "trusts a command with the plural switch alias" do
// 29:     expect { described_class.new(["--commands", "thirdparty/foo/hello"]).run }
// 30:       .to output("Trusted command: thirdparty/foo/hello\n").to_stdout
// 31:
// 32:     expect(Homebrew::Trust.trusted?(:command, "thirdparty/foo/hello")).to be(true)
// 33:   ensure
// 34:     Homebrew::Trust.clear!(:command)
// 35:   end
// 36:
// 37:   context "with a custom-remote tap" do
// 38:     before do
// 39:       tap = Tap.fetch("thirdparty", "custom")
// 40:       tap.path.mkpath
// 41:       system "git", "-C", tap.path.to_s, "init"
// 42:       system "git", "-C", tap.path.to_s, "remote", "add", "origin", "https://gitlab.com/other/repo"
// 43:     end
// 44:
// 45:     after do
// 46:       Homebrew::Trust.clear!(:tap)
// 47:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 48:     end
// 49:
// 50:     it "trusts the whole tap by its remote URL" do
// 51:       expect { described_class.new(["--tap", "thirdparty/custom"]).run }
// 52:         .to output("Trusted tap: https://gitlab.com/other/repo\n").to_stdout
// 53:       expect(Homebrew::Trust.trusted_entries(:tap)).to contain_exactly("https://gitlab.com/other/repo")
// 54:     end
// 55:
// 56:     it "trusts an individual formula by its remote-qualified entry" do
// 57:       expect { described_class.new(["--formula", "thirdparty/custom/bar"]).run }
// 58:         .to output("Trusted formula: https://gitlab.com/other/repo/bar\n").to_stdout
// 59:       expect(Homebrew::Trust.trusted_entries(:formula)).to contain_exactly("https://gitlab.com/other/repo/bar")
// 60:     end
// 61:   end
// 62:
// 63:   it "trusts a not-yet-installed tap directly by its non-GitHub remote URL" do
// 64:     expect { described_class.new(["--tap", "https://gitlab.com/absent/repo"]).run }
// 65:       .to output("Trusted tap: https://gitlab.com/absent/repo\n").to_stdout
// 66:     expect(Homebrew::Trust.trusted_entries(:tap)).to contain_exactly("https://gitlab.com/absent/repo")
// 67:   ensure
// 68:     Homebrew::Trust.clear!(:tap)
// 69:   end
// 70:
// 71:   it "canonicalises a GitHub default-remote URL to the tap name" do
// 72:     expect { described_class.new(["--tap", "https://github.com/thirdparty/homebrew-foo"]).run }
// 73:       .to output("Trusted tap: thirdparty/foo\n").to_stdout
// 74:     expect(Homebrew::Trust.trusted_entries(:tap)).to contain_exactly("thirdparty/foo")
// 75:   ensure
// 76:     Homebrew::Trust.clear!(:tap)
// 77:   end
// 78:
// 79:   it "rejects a bare @-string instead of trusting it as a tap" do
// 80:     expect { described_class.new(["foo@bar"]).run }
// 81:       .to raise_error(UsageError, /fully-qualified/)
// 82:     expect(Homebrew::Trust.trusted_entries(:tap)).to be_empty
// 83:   ensure
// 84:     Homebrew::Trust.clear!(:tap)
// 85:   end
// 86:
// 87:   it "lists trusted entries with no arguments" do
// 88:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:tap).and_return(["thirdparty/foo"])
// 89:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:formula).and_return(["thirdparty/foo/bar"])
// 90:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:cask).and_return([])
// 91:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:command).and_return([])
// 92:
// 93:     expect { described_class.new([]).run }
// 94:       .to output(<<~EOS).to_stdout
// 95:         All official taps and commands are trusted.
// 96:         Trusted taps:
// 97:           thirdparty/foo
// 98:         Trusted formulae:
// 99:           thirdparty/foo/bar
// 100:       EOS
// 101:   end
// 102:
// 103:   it "lists trusted entries as json with no arguments" do
// 104:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:tap).and_return(["thirdparty/foo"])
// 105:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:formula).and_return(["thirdparty/foo/bar"])
// 106:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:cask).and_return([])
// 107:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:command).and_return([])
// 108:
// 109:     expect { described_class.new(["--json=v1"]).run }
// 110:       .to output(
// 111:         match_json(
// 112:           {
// 113:             "taps"     => ["thirdparty/foo"],
// 114:             "formulae" => ["thirdparty/foo/bar"],
// 115:             "casks"    => [],
// 116:             "commands" => [],
// 117:           },
// 118:         ),
// 119:       ).to_stdout
// 120:   end
// 121:
// 122:   it "lists trusted entries as a json array for a selected type" do
// 123:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:formula).and_return(["thirdparty/foo/bar"])
// 124:
// 125:     expect { described_class.new(["--json=v1", "--formula"]).run }
// 126:       .to output(match_json(["thirdparty/foo/bar"])).to_stdout
// 127:   end
// 128:
// 129:   it "rejects json output with named arguments" do
// 130:     expect { described_class.new(["--json=v1", "thirdparty/foo"]).run }
// 131:       .to raise_error(UsageError, /requires no named arguments/)
// 132:   end
// 133:
// 134:   it "rejects json without an explicit version" do
// 135:     expect { described_class.new(["--json"]).run }
// 136:       .to raise_error(OptionParser::MissingArgument, /--json/)
// 137:   end
// 138: end
