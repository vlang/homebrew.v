module cmd

import homebrew.cmd as brew_cmd

// Translated from Homebrew/brew `test/cmd/unlink_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "unlinks a Formula", :integration_test do` at line 10.
pub fn ruby_unlink_spec_l10_d1_unlinks() bool {
	result := brew_cmd.unlink_command([
		brew_cmd.UnlinkCommandKeg{ name: 'testball', path: '/cellar/testball/1.0' },
	], brew_cmd.UnlinkCommandOptions{}, unlink_spec_action) or { return false }
	return result.output.starts_with('Unlinking /cellar/testball/1.0... ') && result.counts == [
		2,
	]
}

fn unlink_spec_action(_ brew_cmd.UnlinkCommandKeg, _ brew_cmd.UnlinkCommandOptions) !int {
	return 2
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "cmd/unlink"
// 6:
// 7: RSpec.describe Homebrew::Cmd::UnlinkCmd do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "unlinks a Formula", :integration_test do
// 11:     setup_test_formula "testball", tab_attributes: { installed_on_request: true }
// 12:     formula_prefix = Formula["testball"].prefix
// 13:     (formula_prefix/"bin").mkpath
// 14:     (formula_prefix/"bin/test").write "test"
// 15:     (HOMEBREW_PREFIX/"bin").mkpath
// 16:     (HOMEBREW_PREFIX/"bin/test").make_relative_symlink(formula_prefix/"bin/test")
// 17:     HOMEBREW_LINKED_KEGS.mkpath
// 18:     (HOMEBREW_LINKED_KEGS/"testball").make_relative_symlink(formula_prefix)
// 19:
// 20:     expect { brew "unlink", "testball" }
// 21:       .to output(/Unlinking /).to_stdout
// 22:       .and not_to_output.to_stderr
// 23:       .and be_a_success
// 24:   end
// 25: end
