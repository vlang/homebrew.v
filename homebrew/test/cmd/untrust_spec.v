module cmd

import ruby
import homebrew.cmd as cmd_core

fn untrust_spec_store(trusted map[string][]string, taps []cmd_core.UntrustedTapSnapshot) cmd_core.UntrustStore {
	return cmd_core.UntrustStore{
		trusted: trusted
		untrusted_taps: taps
	}
}

// Translated from Homebrew/brew `test/cmd/untrust_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "untrusts a given tap", :integration_test do` at line 11.
pub fn ruby_untrust_spec_l11_d1_untrusts(args ...ruby.Value) ruby.Value {
	result := cmd_core.run_untrust(untrust_spec_store({
		'tap': ['thirdparty/foo']
	}, []), [cmd_core.UntrustTarget{
		kind: .tap
		name: 'thirdparty/foo'
	}], none)
	return ruby.bool_value(result.messages == ['Untrusted tap: thirdparty/foo'] && result.store.trusted['tap'].len == 0)
}

// Ruby it `it "notes official taps are always trusted" do` at line 31.
pub fn ruby_untrust_spec_l31_d2_notes(args ...ruby.Value) ruby.Value {
	result := cmd_core.run_untrust(cmd_core.UntrustStore{}, [cmd_core.UntrustTarget{
		kind: .tap
		name: 'homebrew/core'
		official: true
	}], none)
	return ruby.bool_value(result.messages == [
		'Official tap homebrew/core is always trusted.',
	])
}

// Ruby it `it "untrusts a command with the plural switch alias" do` at line 36.
pub fn ruby_untrust_spec_l36_d3_untrusts(args ...ruby.Value) ruby.Value {
	result := cmd_core.run_untrust(untrust_spec_store({
		'command': ['thirdparty/foo/hello']
	}, []), [cmd_core.UntrustTarget{
		kind: .command
		name: 'thirdparty/foo/hello'
	}], .command)
	return ruby.bool_value(result.messages == [
		'Untrusted command: thirdparty/foo/hello',
	])
}

// Ruby it `it "untrusts legacy and remote-qualified entries for custom-remote tap items" do` at line 43.
pub fn ruby_untrust_spec_l43_d4_untrusts(args ...ruby.Value) ruby.Value {
	result := cmd_core.run_untrust(untrust_spec_store({
		'formula': ['thirdparty/custom/bar', 'https://gitlab.com/other/repo/bar']
	}, []), [cmd_core.UntrustTarget{
		kind: .formula
		name: 'thirdparty/custom/bar'
		aliases: ['https://gitlab.com/other/repo/bar']
	}], .formula)
	return ruby.bool_value(result.store.trusted['formula'].len == 0)
}

// Ruby it `it "untrusts trusted items from a tap" do` at line 60.
pub fn ruby_untrust_spec_l60_d5_untrusts(args ...ruby.Value) ruby.Value {
	result := cmd_core.run_untrust(untrust_spec_store({
		'formula': ['thirdparty/foo/bar']
		'cask':    ['thirdparty/foo/baz']
		'command': ['thirdparty/foo/hello']
	}, []), [cmd_core.UntrustTarget{
		kind: .tap
		name: 'thirdparty/foo'
	}], none)
	return ruby.bool_value(result.messages == ['Untrusted tap: thirdparty/foo'] && result.store.trusted['formula'].len == 0 && result.store.trusted['cask'].len == 0 && result.store.trusted['command'].len == 0)
}

// Ruby it `it "lists untrusted entries with no arguments" do` at line 73.
pub fn ruby_untrust_spec_l73_d6_lists(args ...ruby.Value) ruby.Value {
	result := cmd_core.run_untrust(untrust_spec_store({}, [cmd_core.UntrustedTapSnapshot{
		name: 'untrustlist/foo'
		casks: ['bar']
	}]), [], none)
	return ruby.bool_value(result.messages == ['Untrusted taps:', '  untrustlist/foo',
		'Untrusted casks:', '  untrustlist/foo/bar'])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "cmd/untrust"
// 6: require "trust"
// 7:
// 8: RSpec.describe Homebrew::Cmd::Untrust, :trust_store do
// 9:   it_behaves_like "parseable arguments"
// 10:
// 11:   it "untrusts a given tap", :integration_test do
// 12:     trust_home = Pathname(TEST_TMPDIR)/"untrust-tap"
// 13:     trust_home.mkpath
// 14:     (trust_home/"trust.json").write(<<~JSON)
// 15:       {
// 16:         "trustedtaps": [
// 17:           "thirdparty/foo"
// 18:         ]
// 19:       }
// 20:     JSON
// 21:
// 22:     expect { brew "untrust", "thirdparty/foo", "HOMEBREW_USER_CONFIG_HOME" => trust_home.to_s }
// 23:       .to output(%r{Untrusted tap: thirdparty/foo}).to_stdout
// 24:       .and be_a_success
// 25:
// 26:     expect(trust_home/"trust.json").not_to exist
// 27:   ensure
// 28:     FileUtils.rm_rf trust_home if trust_home
// 29:   end
// 30:
// 31:   it "notes official taps are always trusted" do
// 32:     expect { described_class.new(["homebrew/core"]).run }
// 33:       .to output("Official tap homebrew/core is always trusted.\n").to_stdout
// 34:   end
// 35:
// 36:   it "untrusts a command with the plural switch alias" do
// 37:     expect(Homebrew::Trust).to receive(:untrust!).with(:command, "thirdparty/foo/hello").and_return(true)
// 38:
// 39:     expect { described_class.new(["--commands", "thirdparty/foo/hello"]).run }
// 40:       .to output("Untrusted command: thirdparty/foo/hello\n").to_stdout
// 41:   end
// 42:
// 43:   it "untrusts legacy and remote-qualified entries for custom-remote tap items" do
// 44:     tap = Tap.fetch("thirdparty", "custom")
// 45:     tap.path.mkpath
// 46:     system "git", "-C", tap.path.to_s, "init"
// 47:     system "git", "-C", tap.path.to_s, "remote", "add", "origin", "https://gitlab.com/other/repo"
// 48:     Homebrew::Trust.trust!(:formula, "thirdparty/custom/bar")
// 49:     Homebrew::Trust.trust!(:formula, "https://gitlab.com/other/repo/bar")
// 50:
// 51:     expect { described_class.new(["--formula", "thirdparty/custom/bar"]).run }
// 52:       .to output("Untrusted formula: thirdparty/custom/bar\n").to_stdout
// 53:     expect(Homebrew::Trust.trusted_entries(:formula)).to be_empty
// 54:     expect(Homebrew::Trust.trusted?(:formula, "thirdparty/custom/bar")).to be(false)
// 55:   ensure
// 56:     Homebrew::Trust.clear!(:formula)
// 57:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 58:   end
// 59:
// 60:   it "untrusts trusted items from a tap" do
// 61:     expect(Homebrew::Trust).to receive(:untrust!).with(:tap, "thirdparty/foo").and_return(false)
// 62:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:formula).and_return(["thirdparty/foo/bar"])
// 63:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:cask).and_return(["thirdparty/foo/baz"])
// 64:     allow(Homebrew::Trust).to receive(:trusted_entries).with(:command).and_return(["thirdparty/foo/hello"])
// 65:     expect(Homebrew::Trust).to receive(:untrust!).with(:formula, "thirdparty/foo/bar").and_return(true)
// 66:     expect(Homebrew::Trust).to receive(:untrust!).with(:cask, "thirdparty/foo/baz").and_return(true)
// 67:     expect(Homebrew::Trust).to receive(:untrust!).with(:command, "thirdparty/foo/hello").and_return(true)
// 68:
// 69:     expect { described_class.new(["thirdparty/foo"]).run }
// 70:       .to output("Untrusted tap: thirdparty/foo\n").to_stdout
// 71:   end
// 72:
// 73:   it "lists untrusted entries with no arguments" do
// 74:     tap = Tap.fetch("untrustlist", "foo")
// 75:     tap.cask_dir.mkpath
// 76:     (tap.cask_dir/"bar.rb").write("cask 'bar'\n")
// 77:
// 78:     expect { described_class.new([]).run }
// 79:       .to output(<<~EOS).to_stdout
// 80:         Untrusted taps:
// 81:           untrustlist/foo
// 82:         Untrusted casks:
// 83:           untrustlist/foo/bar
// 84:       EOS
// 85:   ensure
// 86:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"untrustlist"
// 87:   end
// 88: end
