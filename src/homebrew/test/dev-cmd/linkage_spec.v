module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/linkage_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "works when no arguments are provided", :integration_test do` at line 10.
pub fn ruby_linkage_spec_l10_d1_works(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('works', ...args)
}

// Ruby it `it "accepts no_linkage dependency tag" do` at line 17.
pub fn ruby_linkage_spec_l17_d2_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/linkage"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Linkage do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "works when no arguments are provided", :integration_test do
// 11:     expect { brew "linkage" }
// 12:       .to be_a_success
// 13:       .and not_to_output.to_stdout
// 14:       .and not_to_output.to_stderr
// 15:   end
// 16:
// 17:   it "accepts no_linkage dependency tag" do
// 18:     expect(formula("testball") do
// 19:       T.bind(self, T.class_of(Formula))
// 20:       url "file://#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz"
// 21:       sha256 TESTBALL_SHA256
// 22:
// 23:       depends_on "foo" => :no_linkage
// 24:     end.deps.first).to be_no_linkage
// 25:   end
// 26: end
