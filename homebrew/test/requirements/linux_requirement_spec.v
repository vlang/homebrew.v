module requirements

import ruby
import homebrew.requirements as brew_requirements

// Translated from Homebrew/brew `test/requirements/linux_requirement_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:requirement) { described_class.new }` at line 7.
pub fn ruby_linux_requirement_spec_l7_d1_requirement(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('LinuxRequirement', 'Linux', {
		'fatal': 'true'
	})
}

// Ruby it `it "returns true on Linux" do` at line 10.
pub fn ruby_linux_requirement_spec_l10_d2_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(brew_requirements.linux_requirement_satisfied() == (ruby.kernel_info().name == 'Linux'))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "requirements/linux_requirement"
// 5:
// 6: RSpec.describe LinuxRequirement do
// 7:   subject(:requirement) { described_class.new }
// 8:
// 9:   describe "#satisfied?" do
// 10:     it "returns true on Linux" do
// 11:       expect(requirement.satisfied?).to eq(OS.linux?)
// 12:     end
// 13:   end
// 14: end
