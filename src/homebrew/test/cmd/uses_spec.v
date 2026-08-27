module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/uses_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "uses tap trust configuration to evaluate all formulae" do` at line 14.
pub fn ruby_uses_spec_l14_d1_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "handles unavailable formula" do` at line 25.
pub fn ruby_uses_spec_l25_d2_handles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handles', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cli/named_args"
// 5: require "cmd/shared_examples/args_parse"
// 6: require "cmd/uses"
// 7: require "fileutils"
// 8:
// 9: RSpec.describe Homebrew::Cmd::Uses do
// 10:   include FileUtils
// 11:
// 12:   it_behaves_like "parseable arguments"
// 13:
// 14:   it "uses tap trust configuration to evaluate all formulae" do
// 15:     used_formula = instance_double(Formula, full_name: "foo")
// 16:     cmd = described_class.new(["--formula", "foo"])
// 17:
// 18:     allow(cmd.args.named).to receive(:to_formulae).and_return([used_formula])
// 19:     expect(Formula).to receive(:all).with(eval_all: true).and_return([])
// 20:
// 21:     expect { with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") { cmd.run } }
// 22:       .to not_to_output.to_stderr
// 23:   end
// 24:
// 25:   it "handles unavailable formula" do
// 26:     cmd = described_class.new(%w[foo --include-optional --recursive])
// 27:     allow(cmd.args.named)
// 28:       .to receive(:to_formulae)
// 29:       .and_raise(FormulaUnavailableError, "foo")
// 30:     allow(cmd).to receive(:intersection_of_dependents)
// 31:       .and_return([
// 32:         instance_double(Formula, full_name: "bar"),
// 33:         instance_double(Formula, full_name: "optional"),
// 34:       ])
// 35:
// 36:     allow(Homebrew::Trust).to receive(:trusted?).and_return(true)
// 37:
// 38:     expect { cmd.run }
// 39:       .to output(/^(bar\noptional|optional\nbar)$/).to_stdout
// 40:       .and output(/Error: Missing formulae should not have dependents!\n/).to_stderr
// 41:       .and raise_error SystemExit
// 42:   end
// 43: end
