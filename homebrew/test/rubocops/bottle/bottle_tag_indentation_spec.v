module bottle

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/bottle/bottle_tag_indentation_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_bottle_tag_indentation_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports no offenses for `bottle :unneeded`" do` at line 9.
pub fn ruby_bottle_tag_indentation_spec_l9_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses for `bottle` blocks without cellars" do` at line 19.
pub fn ruby_bottle_tag_indentation_spec_l19_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses for properly aligned tags in `bottle` blocks with cellars" do` at line 44.
pub fn ruby_bottle_tag_indentation_spec_l44_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects misaligned tags in `bottle` block with cellars" do` at line 69.
pub fn ruby_bottle_tag_indentation_spec_l69_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/bottle"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::BottleTagIndentation do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "reports no offenses for `bottle :unneeded`" do
// 10:     expect_no_offenses(<<~RUBY)
// 11:       class Foo < Formula
// 12:         url "https://brew.sh/foo-1.0.tgz"
// 13:
// 14:         bottle :unneeded
// 15:       end
// 16:     RUBY
// 17:   end
// 18:
// 19:   it "reports no offenses for `bottle` blocks without cellars" do
// 20:     expect_no_offenses(<<~RUBY)
// 21:       class Foo < Formula
// 22:         url "https://brew.sh/foo-1.0.tgz"
// 23:
// 24:         bottle do
// 25:           rebuild 4
// 26:           sha256 arm64_big_sur: "aaaaaaaa"
// 27:           sha256 big_sur: "faceb00c"
// 28:           sha256 catalina: "deadbeef"
// 29:         end
// 30:       end
// 31:     RUBY
// 32:
// 33:     expect_no_offenses(<<~RUBY)
// 34:       class Foo < Formula
// 35:         url "https://brew.sh/foo-1.0.tgz"
// 36:
// 37:         bottle do
// 38:           sha256 big_sur: "faceb00c"
// 39:         end
// 40:       end
// 41:     RUBY
// 42:   end
// 43:
// 44:   it "reports no offenses for properly aligned tags in `bottle` blocks with cellars" do
// 45:     expect_no_offenses(<<~RUBY)
// 46:       class Foo < Formula
// 47:         url "https://brew.sh/foo-1.0.tgz"
// 48:
// 49:         bottle do
// 50:           rebuild 4
// 51:           sha256 cellar: :any,                arm64_big_sur: "aaaaaaaa"
// 52:           sha256 cellar: "/usr/local/Cellar", big_sur:       "faceb00c"
// 53:           sha256                              catalina:      "deadbeef"
// 54:         end
// 55:       end
// 56:     RUBY
// 57:
// 58:     expect_no_offenses(<<~RUBY)
// 59:       class Foo < Formula
// 60:         url "https://brew.sh/foo-1.0.tgz"
// 61:
// 62:         bottle do
// 63:           sha256 cellar: :any, arm64_big_sur: "aaaaaaaa"
// 64:         end
// 65:       end
// 66:     RUBY
// 67:   end
// 68:
// 69:   it "reports and corrects misaligned tags in `bottle` block with cellars" do
// 70:     expect_offense(<<~RUBY)
// 71:       class Foo < Formula
// 72:         url "https://brew.sh/foo-1.0.tgz"
// 73:
// 74:         bottle do
// 75:           rebuild 4
// 76:           sha256 cellar: :any, arm64_big_sur: "aaaaaaaa"
// 77:                                ^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/BottleTagIndentation: Align bottle tags
// 78:           sha256 cellar: "/usr/local/Cellar", big_sur: "faceb00c"
// 79:           sha256 catalina: "deadbeef"
// 80:                  ^^^^^^^^^^^^^^^^^^^^ FormulaAudit/BottleTagIndentation: Align bottle tags
// 81:         end
// 82:       end
// 83:     RUBY
// 84:
// 85:     expect_correction(<<~RUBY)
// 86:       class Foo < Formula
// 87:         url "https://brew.sh/foo-1.0.tgz"
// 88:
// 89:         bottle do
// 90:           rebuild 4
// 91:           sha256 cellar: :any,                arm64_big_sur: "aaaaaaaa"
// 92:           sha256 cellar: "/usr/local/Cellar", big_sur: "faceb00c"
// 93:           sha256                              catalina: "deadbeef"
// 94:         end
// 95:       end
// 96:     RUBY
// 97:   end
// 98: end
