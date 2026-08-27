module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/cleanup_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "removes all files in Homebrew's cache" do` at line 20.
pub fn ruby_cleanup_spec_l20_d1_removes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('removes', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/cleanup"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::CleanupCmd do
// 8:   before do
// 9:     FileUtils.mkdir_p HOMEBREW_LIBRARY/"Homebrew/vendor/"
// 10:     FileUtils.touch HOMEBREW_LIBRARY/"Homebrew/vendor/portable-ruby-version"
// 11:   end
// 12:
// 13:   after do
// 14:     FileUtils.rm_rf HOMEBREW_LIBRARY/"Homebrew"
// 15:   end
// 16:
// 17:   it_behaves_like "parseable arguments"
// 18:
// 19:   describe "--prune=all", :integration_test do
// 20:     it "removes all files in Homebrew's cache" do
// 21:       (HOMEBREW_CACHE/"test").write "test"
// 22:
// 23:       expect { brew "cleanup", "--prune=all" }
// 24:         .to output(%r{#{Regexp.escape(HOMEBREW_CACHE)}/test}o).to_stdout
// 25:         .and not_to_output.to_stderr
// 26:         .and be_a_success
// 27:     end
// 28:   end
// 29: end
