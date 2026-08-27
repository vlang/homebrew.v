module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/unalias_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "unsets an alias", :integration_test do` at line 10.
pub fn ruby_unalias_spec_l10_d1_unsets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unsets', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/unalias"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Unalias do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "unsets an alias", :integration_test do
// 11:     (HOMEBREW_PREFIX/"bin").mkpath
// 12:     Homebrew::Aliases.init
// 13:
// 14:     expect { Homebrew::Aliases.add("foo", "bar") }
// 15:       .to not_to_output.to_stdout
// 16:       .and not_to_output.to_stderr
// 17:     expect { Homebrew::Aliases.show }
// 18:       .to output(/brew alias foo='bar'/).to_stdout
// 19:       .and not_to_output.to_stderr
// 20:
// 21:     expect { brew "unalias", "foo" }
// 22:       .to not_to_output.to_stdout
// 23:       .and not_to_output.to_stderr
// 24:       .and be_a_success
// 25:     expect { Homebrew::Aliases.show }
// 26:       .to not_to_output.to_stdout
// 27:       .and not_to_output.to_stderr
// 28:   end
// 29: end
