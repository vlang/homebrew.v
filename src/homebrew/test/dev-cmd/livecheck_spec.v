module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/livecheck_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "reports the latest version of a Formula", :integration_test, :needs_network do` at line 10.
pub fn ruby_livecheck_spec_l10_d1_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "gives an error when no arguments are given and there's no watchlist" do` at line 24.
pub fn ruby_livecheck_spec_l24_d2_gives(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gives', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/livecheck"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::LivecheckCmd do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "reports the latest version of a Formula", :integration_test, :needs_network do
// 11:     content = <<~RUBY
// 12:       desc "Some test"
// 13:       homepage "https://github.com/Homebrew/brew"
// 14:       url "https://brew.sh/test-1.0.0.tgz"
// 15:     RUBY
// 16:     setup_test_formula("test", content)
// 17:
// 18:     expect { brew "livecheck", "test" }
// 19:       .to output(/test: /).to_stdout
// 20:       .and not_to_output.to_stderr
// 21:       .and be_a_success
// 22:   end
// 23:
// 24:   it "gives an error when no arguments are given and there's no watchlist" do
// 25:     allow(Homebrew).to receive(:install_bundler_gems!)
// 26:
// 27:     with_env("HOMEBREW_LIVECHECK_WATCHLIST" => ".this_should_not_exist") do
// 28:       expect { described_class.new([]).run }
// 29:         .to raise_error(UsageError, /No formulae or casks to check/)
// 30:     end
// 31:   end
// 32: end
