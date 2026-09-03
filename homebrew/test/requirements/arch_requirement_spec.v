module requirements

import homebrew.requirements as requirement_api

// Translated from Homebrew/brew `test/requirements/arch_requirement_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:requirement) { described_class.new([Hardware::CPU.type]) }` at line 7.
pub fn ruby_arch_requirement_spec_l7_d1_requirement() requirement_api.ArchRequirement {
	return requirement_api.new_arch_requirement([requirement_api.current_cpu_type()])
}

// Ruby it `it "supports architecture symbols" do` at line 10.
pub fn ruby_arch_requirement_spec_l10_d2_supports() bool {
	return ruby_arch_requirement_spec_l7_d1_requirement().satisfied()
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "requirements/arch_requirement"
// 5:
// 6: RSpec.describe ArchRequirement do
// 7:   subject(:requirement) { described_class.new([Hardware::CPU.type]) }
// 8:
// 9:   describe "#satisfied?" do
// 10:     it "supports architecture symbols" do
// 11:       expect(requirement).to be_satisfied
// 12:     end
// 13:   end
// 14: end
