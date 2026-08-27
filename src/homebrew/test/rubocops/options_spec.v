module rubocops

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/options_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_options_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports an offense when using bad option names" do` at line 10.
pub fn ruby_options_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when using `without-check` option names" do` at line 20.
pub fn ruby_options_spec_l20_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when using `deprecated_option` in homebrew/core" do` at line 30.
pub fn ruby_options_spec_l30_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when using `option` in homebrew/core" do` at line 40.
pub fn ruby_options_spec_l40_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/options"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::Options do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing options" do
// 10:     it "reports an offense when using bad option names" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           url 'https://brew.sh/foo-1.0.tgz'
// 14:           option "examples", "with-examples"
// 15:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Options: Options should begin with `with` or `without`. Migrate '--examples' with `deprecated_option`.
// 16:         end
// 17:       RUBY
// 18:     end
// 19:
// 20:     it "reports an offense when using `without-check` option names" do
// 21:       expect_offense(<<~RUBY)
// 22:         class Foo < Formula
// 23:           url 'https://brew.sh/foo-1.0.tgz'
// 24:           option "without-check"
// 25:           ^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Options: Use '--without-test' instead of '--without-check'. Migrate '--without-check' with `deprecated_option`.
// 26:         end
// 27:       RUBY
// 28:     end
// 29:
// 30:     it "reports an offense when using `deprecated_option` in homebrew/core" do
// 31:       expect_offense(<<~RUBY, "/homebrew-core/")
// 32:         class Foo < Formula
// 33:           url 'https://brew.sh/foo-1.0.tgz'
// 34:           deprecated_option "examples" => "with-examples"
// 35:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Options: Formulae in homebrew/core should not use `deprecated_option`.
// 36:         end
// 37:       RUBY
// 38:     end
// 39:
// 40:     it "reports an offense when using `option` in homebrew/core" do
// 41:       expect_offense(<<~RUBY, "/homebrew-core/")
// 42:         class Foo < Formula
// 43:           url 'https://brew.sh/foo-1.0.tgz'
// 44:           option "with-examples"
// 45:           ^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/Options: Formulae in homebrew/core should not use `option`.
// 46:         end
// 47:       RUBY
// 48:     end
// 49:   end
// 50: end
