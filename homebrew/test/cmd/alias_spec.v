module cmd

import homebrew.aliases
import homebrew.cmd as brew_cmd

// Translated from Homebrew/brew `test/cmd/alias_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "sets an alias", :integration_test do` at line 10.
pub fn ruby_alias_spec_l10_d1_sets(config aliases.AliasConfig,
	editor aliases.AliasEditor) !bool {
	brew_cmd.run_alias(config, 'foo-test=bar', false, editor)!
	return brew_cmd.run_alias(config, none, false, editor)! == [
		"brew alias foo-test='bar'",
	]
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/alias"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Alias do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "sets an alias", :integration_test do
// 11:     expect { brew "alias", "foo-test=bar" }
// 12:       .to not_to_output.to_stdout
// 13:       .and not_to_output.to_stderr
// 14:       .and be_a_success
// 15:     expect { brew "alias" }
// 16:       .to output(/brew alias foo-test='bar'/).to_stdout
// 17:       .and not_to_output.to_stderr
// 18:       .and be_a_success
// 19:   end
// 20: end
