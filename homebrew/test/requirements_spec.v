module test

import homebrew
import homebrew.dependencies

// Translated from Homebrew/brew `test/requirements_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:requirements) { described_class.new }` at line 7.
pub fn ruby_requirements_spec_l7_d1_requirements() dependencies.Requirements {
	return dependencies.new_requirements()
}

fn requirements_spec_requirement() !homebrew.Requirement {
	return homebrew.new_requirement(homebrew.anonymous_requirement_class('RequirementsSpecAnonymous'), [])
}

// Ruby it `it "returns itself" do` at line 10.
pub fn ruby_requirements_spec_l10_d2_returns() !bool {
	mut requirements := ruby_requirements_spec_l7_d1_requirements()
	returned := requirements.add(requirements_spec_requirement()!)
	return returned.count() == requirements.count() && requirements.count() == 1
}

// Ruby it `it "merges duplicate requirements" do` at line 14.
pub fn ruby_requirements_spec_l14_d3_merges() !bool {
	mut requirements := ruby_requirements_spec_l7_d1_requirements()
	requirements.add(requirements_spec_requirement()!)
	requirements.add(requirements_spec_requirement()!)
	return requirements.count() == 1
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "requirements"
// 5:
// 6: RSpec.describe Requirements do
// 7:   subject(:requirements) { described_class.new }
// 8:
// 9:   describe "#<<" do
// 10:     it "returns itself" do
// 11:       expect(requirements << Class.new(Requirement).new).to be(requirements)
// 12:     end
// 13:
// 14:     it "merges duplicate requirements" do
// 15:       klass = Class.new(Requirement)
// 16:       requirements << klass.new << klass.new
// 17:       expect(requirements.count).to eq(1)
// 18:     end
// 19:   end
// 20: end
