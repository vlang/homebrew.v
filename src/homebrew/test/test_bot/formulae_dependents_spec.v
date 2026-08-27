module test_bot

import brew_runtime

// Translated from Homebrew/brew `test/test_bot/formulae_dependents_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:formulae_dependents) do` at line 7.
pub fn ruby_formulae_dependents_spec_l7_d1_formulae_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formulae_dependents', ...args)
}

// Ruby it `it "keeps dependent formulae that depend on each other in the same shard" do` at line 12.
pub fn ruby_formulae_dependents_spec_l12_d2_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby it `it "rejects invalid shard indexes" do` at line 43.
pub fn ruby_formulae_dependents_spec_l43_d3_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "returns no formulae for an empty shard" do` at line 48.
pub fn ruby_formulae_dependents_spec_l48_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "test_bot"
// 5:
// 6: RSpec.describe Homebrew::TestBot::FormulaeDependents do
// 7:   subject(:formulae_dependents) do
// 8:     described_class.new(tap: nil, git: nil, dry_run: false, fail_fast: false, verbose: false)
// 9:   end
// 10:
// 11:   describe "#dependents_for_shard" do
// 12:     it "keeps dependent formulae that depend on each other in the same shard" do
// 13:       dependency = formula "dependent-a" do
// 14:         T.bind(self, T.class_of(Formula))
// 15:         url "https://brew.sh/dependent-a-1.0.tar.gz"
// 16:       end
// 17:       dependent = formula "dependent-b" do
// 18:         T.bind(self, T.class_of(Formula))
// 19:         url "https://brew.sh/dependent-b-1.0.tar.gz"
// 20:         depends_on "dependent-a"
// 21:       end
// 22:       independent = formula "dependent-c" do
// 23:         T.bind(self, T.class_of(Formula))
// 24:         url "https://brew.sh/dependent-c-1.0.tar.gz"
// 25:       end
// 26:
// 27:       stub_formula_loader dependency
// 28:       stub_formula_loader dependent
// 29:       stub_formula_loader independent
// 30:
// 31:       shard = formulae_dependents.dependents_for_shard(
// 32:         [
// 33:           [dependency, dependency.deps.to_a],
// 34:           [dependent, dependent.deps.to_a],
// 35:           [independent, independent.deps.to_a],
// 36:         ],
// 37:         "1/2",
// 38:       )
// 39:
// 40:       expect(shard.map { |formula, _| formula.name }).to contain_exactly("dependent-a", "dependent-b")
// 41:     end
// 42:
// 43:     it "rejects invalid shard indexes" do
// 44:       expect { formulae_dependents.dependents_for_shard([], "2/1") }
// 45:         .to raise_error(UsageError, /must not be greater/)
// 46:     end
// 47:
// 48:     it "returns no formulae for an empty shard" do
// 49:       dependent = formula "dependent-a" do
// 50:         T.bind(self, T.class_of(Formula))
// 51:         url "https://brew.sh/dependent-a-1.0.tar.gz"
// 52:       end
// 53:
// 54:       expect(formulae_dependents.dependents_for_shard([[dependent, dependent.deps.to_a]], "2/2")).to be_empty
// 55:     end
// 56:   end
// 57: end
