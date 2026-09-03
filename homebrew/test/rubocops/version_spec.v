module rubocops

import brew_runtime
import homebrew.rubocops as version_core

// Translated from Homebrew/brew `test/rubocops/version_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_version_spec_l7_d1_cop() brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::Version', 'Version')
}

// Ruby it `it "reports an offense if `version` is an empty string" do` at line 10.
pub fn ruby_version_spec_l10_d2_reports() bool {
	offenses := version_core.audit_formula_version('class Foo < Formula\n  url \'https://brew.sh/foo-1.0.tgz\'\n  version ""\nend\n')
	return offenses.len == 1 && offenses[0].message == 'Version is set to an empty string'
}

// Ruby it `it "reports an offense if `version` has a leading 'v'" do` at line 20.
pub fn ruby_version_spec_l20_d3_reports() bool {
	offenses := version_core.audit_formula_version('class Foo < Formula\n  version "v1.0"\nend\n')
	return offenses.len == 1 && offenses[0].message == "Version v1.0 should not have a leading 'v'"
}

// Ruby it `it "reports an offense if `version` ends with an underline and a number" do` at line 30.
pub fn ruby_version_spec_l30_d4_reports() bool {
	offenses := version_core.audit_formula_version('class Foo < Formula\n  version "1_0"\nend\n')
	return offenses.len == 1 && offenses[0].message == 'Version 1_0 should not end with an underline and a number'
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/version"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Version do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing version" do
// 10:     it "reports an offense if `version` is an empty string" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           url 'https://brew.sh/foo-1.0.tgz'
// 14:           version ""
// 15:           ^^^^^^^^^^ FormulaAudit/Version: Version is set to an empty string
// 16:         end
// 17:       RUBY
// 18:     end
// 19:
// 20:     it "reports an offense if `version` has a leading 'v'" do
// 21:       expect_offense(<<~RUBY)
// 22:         class Foo < Formula
// 23:           url 'https://brew.sh/foo-1.0.tgz'
// 24:           version "v1.0"
// 25:           ^^^^^^^^^^^^^^ FormulaAudit/Version: Version v1.0 should not have a leading 'v'
// 26:         end
// 27:       RUBY
// 28:     end
// 29:
// 30:     it "reports an offense if `version` ends with an underline and a number" do
// 31:       expect_offense(<<~RUBY)
// 32:         class Foo < Formula
// 33:           url 'https://brew.sh/foo-1.0.tgz'
// 34:           version "1_0"
// 35:           ^^^^^^^^^^^^^ FormulaAudit/Version: Version 1_0 should not end with an underline and a number
// 36:         end
// 37:       RUBY
// 38:     end
// 39:   end
// 40: end
