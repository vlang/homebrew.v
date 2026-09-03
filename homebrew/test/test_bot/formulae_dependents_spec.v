module test_bot

import homebrew.test_bot as formulae_dependents_core

// Translated from Homebrew/brew `test/test_bot/formulae_dependents_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:formulae_dependents) do` at line 7.
pub fn ruby_formulae_dependents_spec_l7_d1_formulae_dependents() &formulae_dependents_core.FormulaeDependents {
	return formulae_dependents_core.new_formulae_dependents(formulae_dependents_core.FormulaeDependentsConfig{})
}

// Ruby it `it "keeps dependent formulae that depend on each other in the same shard" do` at line 12.
pub fn ruby_formulae_dependents_spec_l12_d2_keeps() bool {
	dependency := formulae_dependents_core.FormulaeDependentsFormula{
		name: 'dependent-a'
		full_name: 'dependent-a'
	}
	dependent := formulae_dependents_core.FormulaeDependentsFormula{
		name: 'dependent-b'
		full_name: 'dependent-b'
	}
	independent := formulae_dependents_core.FormulaeDependentsFormula{
		name: 'dependent-c'
		full_name: 'dependent-c'
	}
	shard := formulae_dependents_core.dependents_for_shard([
		formulae_dependents_core.FormulaeDependentPair{
			dependent: dependency
		},
		formulae_dependents_core.FormulaeDependentPair{
			dependent: dependent
			dependencies: [formulae_dependents_core.FormulaeDependentsDependency{
				name: 'dependent-a'
				formula_name: 'dependent-a'
			}]
		},
		formulae_dependents_core.FormulaeDependentPair{
			dependent: independent
		},
	], '1/2') or { return false }
	names := shard.map(it.dependent.name)
	return names.len == 2 && 'dependent-a' in names && 'dependent-b' in names
}

// Ruby it `it "rejects invalid shard indexes" do` at line 43.
pub fn ruby_formulae_dependents_spec_l43_d3_rejects() bool {
	formulae_dependents_core.dependents_for_shard([]formulae_dependents_core.FormulaeDependentPair{}, '2/1') or { return err.msg().contains('must not be greater') }
	return false
}

// Ruby it `it "returns no formulae for an empty shard" do` at line 48.
pub fn ruby_formulae_dependents_spec_l48_d4_returns() bool {
	dependent := formulae_dependents_core.FormulaeDependentsFormula{
		name: 'dependent-a'
		full_name: 'dependent-a'
	}
	shard := formulae_dependents_core.dependents_for_shard([
		formulae_dependents_core.FormulaeDependentPair{
			dependent: dependent
		},
	], '2/2') or { return false }
	return shard.len == 0
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
