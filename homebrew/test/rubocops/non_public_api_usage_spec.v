module rubocops

import ruby
import homebrew.rubocops as non_public_api_core

// Translated from Homebrew/brew `test/rubocops/non_public_api_usage_spec.rb`.
// The original source is retained below until every stub has a typed V body.
const non_public_api_spec_internal_methods = ['tap', 'stable', 'recursive_dependencies']
const non_public_api_spec_private_methods = ['skip_cxxstdlib_check']

fn non_public_api_spec_formula(statement string) string {
	return 'class Foo < Formula\n  def install\n    ${statement}\n  end\nend\n'
}

fn non_public_api_spec_audit(statement string, formula_tap string) []non_public_api_core.NonPublicApiUsageOffense {
	return non_public_api_core.audit_non_public_api_usage_with_methods(non_public_api_spec_formula(statement), formula_tap, non_public_api_spec_internal_methods, non_public_api_spec_private_methods)
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_non_public_api_usage_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAudit::NonPublicApiUsage', 'FormulaAudit/NonPublicApiUsage')
}

// Ruby it `it "reports an offense for using `tap` (an @api internal method)" do` at line 20.
pub fn ruby_non_public_api_usage_spec_l20_d2_reports() bool {
	offenses := non_public_api_spec_audit('puts tap', 'homebrew-core')
	return offenses.len == 1 && offenses[0].method == 'tap' && offenses[0].message == non_public_api_core.non_public_api_internal_message.replace_once('%s', 'tap')
}

// Ruby method `install` at line 23.
pub fn ruby_non_public_api_usage_spec_l23_d3_install() string {
	return 'puts tap'
}

// Ruby it `it "reports an offense for using `stable` (an @api internal method)" do` at line 31.
pub fn ruby_non_public_api_usage_spec_l31_d4_reports() bool {
	offenses := non_public_api_spec_audit('puts stable', 'homebrew-core')
	return offenses.len == 1 && offenses[0].method == 'stable' && offenses[0].message == non_public_api_core.non_public_api_internal_message.replace_once('%s', 'stable')
}

// Ruby method `install` at line 34.
pub fn ruby_non_public_api_usage_spec_l34_d5_install() string {
	return 'puts stable'
}

// Ruby it `it "does not report an offense for using `bin` (an @api public method)" do` at line 42.
pub fn ruby_non_public_api_usage_spec_l42_d6_does() bool {
	return non_public_api_spec_audit('bin.install "foo"', 'homebrew-core').len == 0
}

// Ruby method `install` at line 45.
pub fn ruby_non_public_api_usage_spec_l45_d7_install() string {
	return 'bin.install "foo"'
}

// Ruby it `it "does not report an offense for using `prefix` (an @api public method)" do` at line 52.
pub fn ruby_non_public_api_usage_spec_l52_d8_does() bool {
	return non_public_api_spec_audit('prefix.install "README"', 'homebrew-core').len == 0
}

// Ruby method `install` at line 55.
pub fn ruby_non_public_api_usage_spec_l55_d9_install() string {
	return 'prefix.install "README"'
}

// Ruby it `it "does not flag method calls on non-Formula receivers" do` at line 62.
pub fn ruby_non_public_api_usage_spec_l62_d10_does() bool {
	return non_public_api_spec_audit('something.tap { |x| x }', 'homebrew-core').len == 0
}

// Ruby method `install` at line 65.
pub fn ruby_non_public_api_usage_spec_l65_d11_install() string {
	return 'something.tap { |x| x }'
}

// Ruby it `it "does not report an offense for using internal methods" do` at line 74.
pub fn ruby_non_public_api_usage_spec_l74_d12_does() bool {
	return non_public_api_spec_audit('puts tap', 'homebrew-mytap').len == 0
}

// Ruby method `install` at line 77.
pub fn ruby_non_public_api_usage_spec_l77_d13_install() string {
	return 'puts tap'
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/non_public_api_usage"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::NonPublicApiUsage do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   before do
// 10:     allow(RuboCop::Cop::ApiAnnotationHelper).to receive(:methods_with_api_level).and_return(Set.new)
// 11:     allow(RuboCop::Cop::ApiAnnotationHelper).to receive(:methods_with_api_level)
// 12:       .with(a_string_ending_with("formula.rb"), "internal")
// 13:       .and_return(Set["tap", "stable", "recursive_dependencies"])
// 14:     allow(RuboCop::Cop::ApiAnnotationHelper).to receive(:methods_with_api_level)
// 15:       .with(a_string_ending_with("formula.rb"), "private")
// 16:       .and_return(Set["skip_cxxstdlib_check"])
// 17:   end
// 18:
// 19:   context "when auditing a formula in homebrew-core" do
// 20:     it "reports an offense for using `tap` (an @api internal method)" do
// 21:       expect_offense(<<~RUBY, "/homebrew-core/Formula/f/foo.rb")
// 22:         class Foo < Formula
// 23:           def install
// 24:             puts tap
// 25:                  ^^^ FormulaAudit/NonPublicApiUsage: Do not use `tap` in official tap formulae; it is an internal API (`@api internal`).
// 26:           end
// 27:         end
// 28:       RUBY
// 29:     end
// 30:
// 31:     it "reports an offense for using `stable` (an @api internal method)" do
// 32:       expect_offense(<<~RUBY, "/homebrew-core/Formula/f/foo.rb")
// 33:         class Foo < Formula
// 34:           def install
// 35:             puts stable
// 36:                  ^^^^^^ FormulaAudit/NonPublicApiUsage: Do not use `stable` in official tap formulae; it is an internal API (`@api internal`).
// 37:           end
// 38:         end
// 39:       RUBY
// 40:     end
// 41:
// 42:     it "does not report an offense for using `bin` (an @api public method)" do
// 43:       expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/f/foo.rb")
// 44:         class Foo < Formula
// 45:           def install
// 46:             bin.install "foo"
// 47:           end
// 48:         end
// 49:       RUBY
// 50:     end
// 51:
// 52:     it "does not report an offense for using `prefix` (an @api public method)" do
// 53:       expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/f/foo.rb")
// 54:         class Foo < Formula
// 55:           def install
// 56:             prefix.install "README"
// 57:           end
// 58:         end
// 59:       RUBY
// 60:     end
// 61:
// 62:     it "does not flag method calls on non-Formula receivers" do
// 63:       expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/f/foo.rb")
// 64:         class Foo < Formula
// 65:           def install
// 66:             something.tap { |x| x }
// 67:           end
// 68:         end
// 69:       RUBY
// 70:     end
// 71:   end
// 72:
// 73:   context "when auditing a formula in a non-official tap" do
// 74:     it "does not report an offense for using internal methods" do
// 75:       expect_no_offenses(<<~RUBY, "/homebrew-mytap/Formula/foo.rb")
// 76:         class Foo < Formula
// 77:           def install
// 78:             puts tap
// 79:           end
// 80:         end
// 81:       RUBY
// 82:     end
// 83:   end
// 84: end
