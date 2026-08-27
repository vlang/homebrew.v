module rubocops

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/keg_only_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_keg_only_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports and corrects an offense when the `keg_only` reason is capitalized" do` at line 9.
pub fn ruby_keg_only_spec_l9_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects an offense when the `keg_only` reason ends with a period" do` at line 32.
pub fn ruby_keg_only_spec_l32_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses when a `keg_only` reason is a block" do` at line 53.
pub fn ruby_keg_only_spec_l53_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses if a capitalized `keg-only` reason is an exempt proper noun" do` at line 69.
pub fn ruby_keg_only_spec_l69_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses if a capitalized `keg_only` reason is the formula's name" do` at line 80.
pub fn ruby_keg_only_spec_l80_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/keg_only"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::KegOnly do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "reports and corrects an offense when the `keg_only` reason is capitalized" do
// 10:     expect_offense(<<~RUBY)
// 11:       class Foo < Formula
// 12:
// 13:         url "https://brew.sh/foo-1.0.tgz"
// 14:         homepage "https://brew.sh"
// 15:
// 16:         keg_only "Because why not"
// 17:                  ^^^^^^^^^^^^^^^^^ FormulaAudit/KegOnly: 'Because' from the `keg_only` reason should be 'because'.
// 18:       end
// 19:     RUBY
// 20:
// 21:     expect_correction(<<~RUBY)
// 22:       class Foo < Formula
// 23:
// 24:         url "https://brew.sh/foo-1.0.tgz"
// 25:         homepage "https://brew.sh"
// 26:
// 27:         keg_only "because why not"
// 28:       end
// 29:     RUBY
// 30:   end
// 31:
// 32:   it "reports and corrects an offense when the `keg_only` reason ends with a period" do
// 33:     expect_offense(<<~RUBY)
// 34:       class Foo < Formula
// 35:         url "https://brew.sh/foo-1.0.tgz"
// 36:         homepage "https://brew.sh"
// 37:
// 38:         keg_only "ending with a period."
// 39:                  ^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/KegOnly: `keg_only` reason should not end with a period.
// 40:       end
// 41:     RUBY
// 42:
// 43:     expect_correction(<<~RUBY)
// 44:       class Foo < Formula
// 45:         url "https://brew.sh/foo-1.0.tgz"
// 46:         homepage "https://brew.sh"
// 47:
// 48:         keg_only "ending with a period"
// 49:       end
// 50:     RUBY
// 51:   end
// 52:
// 53:   it "reports no offenses when a `keg_only` reason is a block" do
// 54:     expect_no_offenses(<<~RUBY)
// 55:       class Foo < Formula
// 56:         url "https://brew.sh/foo-1.0.tgz"
// 57:         homepage "https://brew.sh"
// 58:
// 59:         keg_only <<~EOF
// 60:           this line starts with a lowercase word.
// 61:
// 62:           This line does not but that shouldn't be a
// 63:           problem
// 64:         EOF
// 65:       end
// 66:     RUBY
// 67:   end
// 68:
// 69:   it "reports no offenses if a capitalized `keg-only` reason is an exempt proper noun" do
// 70:     expect_no_offenses(<<~RUBY)
// 71:       class Foo < Formula
// 72:         url "https://brew.sh/foo-1.0.tgz"
// 73:         homepage "https://brew.sh"
// 74:
// 75:         keg_only "Apple ships foo in the CLT package"
// 76:       end
// 77:     RUBY
// 78:   end
// 79:
// 80:   it "reports no offenses if a capitalized `keg_only` reason is the formula's name" do
// 81:     expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 82:       class Foo < Formula
// 83:         url "https://brew.sh/foo-1.0.tgz"
// 84:
// 85:         keg_only "Foo is the formula name hence downcasing is not required"
// 86:       end
// 87:     RUBY
// 88:   end
// 89: end
