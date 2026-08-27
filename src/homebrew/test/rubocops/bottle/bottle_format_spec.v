module bottle

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/bottle/bottle_format_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_bottle_format_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports no offenses for `bottle :unneeded`" do` at line 9.
pub fn ruby_bottle_format_spec_l9_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects old `sha256` syntax in `bottle` block without cellars" do` at line 19.
pub fn ruby_bottle_format_spec_l19_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports and corrects old `sha256` syntax in `bottle` block with cellars" do` at line 68.
pub fn ruby_bottle_format_spec_l68_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/bottle"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::BottleFormat do
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
// 19:   it "reports and corrects old `sha256` syntax in `bottle` block without cellars" do
// 20:     expect_offense(<<~RUBY)
// 21:       class Foo < Formula
// 22:         url "https://brew.sh/foo-1.0.tgz"
// 23:
// 24:         bottle do
// 25:           sha256 "faceb00c" => :big_sur
// 26:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/BottleFormat: `sha256` should use new syntax
// 27:         end
// 28:       end
// 29:     RUBY
// 30:
// 31:     expect_correction(<<~RUBY)
// 32:       class Foo < Formula
// 33:         url "https://brew.sh/foo-1.0.tgz"
// 34:
// 35:         bottle do
// 36:           sha256 big_sur: "faceb00c"
// 37:         end
// 38:       end
// 39:     RUBY
// 40:
// 41:     expect_offense(<<~RUBY)
// 42:       class Foo < Formula
// 43:         url "https://brew.sh/foo-1.0.tgz"
// 44:
// 45:         bottle do
// 46:           rebuild 4
// 47:           sha256 "faceb00c" => :big_sur
// 48:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/BottleFormat: `sha256` should use new syntax
// 49:           sha256 "deadbeef" => :catalina
// 50:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/BottleFormat: `sha256` should use new syntax
// 51:         end
// 52:       end
// 53:     RUBY
// 54:
// 55:     expect_correction(<<~RUBY)
// 56:       class Foo < Formula
// 57:         url "https://brew.sh/foo-1.0.tgz"
// 58:
// 59:         bottle do
// 60:           rebuild 4
// 61:           sha256 big_sur: "faceb00c"
// 62:           sha256 catalina: "deadbeef"
// 63:         end
// 64:       end
// 65:     RUBY
// 66:   end
// 67:
// 68:   it "reports and corrects old `sha256` syntax in `bottle` block with cellars" do
// 69:     expect_offense(<<~RUBY)
// 70:       class Foo < Formula
// 71:         url "https://brew.sh/foo-1.0.tgz"
// 72:
// 73:         bottle do
// 74:           cellar :any
// 75:           ^^^^^^^^^^^ FormulaAudit/BottleFormat: `cellar` should be a parameter to `sha256`
// 76:           rebuild 4
// 77:           sha256 "faceb00c" => :big_sur
// 78:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/BottleFormat: `sha256` should use new syntax
// 79:           sha256 "deadbeef" => :catalina
// 80:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/BottleFormat: `sha256` should use new syntax
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
// 91:           sha256 cellar: :any, big_sur: "faceb00c"
// 92:           sha256 cellar: :any, catalina: "deadbeef"
// 93:         end
// 94:       end
// 95:     RUBY
// 96:
// 97:     expect_offense(<<~RUBY)
// 98:       class Foo < Formula
// 99:         url "https://brew.sh/foo-1.0.tgz"
// 100:
// 101:         bottle do
// 102:           cellar :any
// 103:           ^^^^^^^^^^^ FormulaAudit/BottleFormat: `cellar` should be a parameter to `sha256`
// 104:           sha256 "faceb00c" => :big_sur
// 105:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/BottleFormat: `sha256` should use new syntax
// 106:         end
// 107:       end
// 108:     RUBY
// 109:
// 110:     expect_correction(<<~RUBY)
// 111:       class Foo < Formula
// 112:         url "https://brew.sh/foo-1.0.tgz"
// 113:
// 114:         bottle do
// 115:           sha256 cellar: :any, big_sur: "faceb00c"
// 116:         end
// 117:       end
// 118:     RUBY
// 119:
// 120:     expect_offense(<<~RUBY)
// 121:       class Foo < Formula
// 122:         url "https://brew.sh/foo-1.0.tgz"
// 123:
// 124:         bottle do
// 125:           cellar "/usr/local/Cellar"
// 126:           ^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/BottleFormat: `cellar` should be a parameter to `sha256`
// 127:           rebuild 4
// 128:           sha256 "faceb00c" => :big_sur
// 129:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/BottleFormat: `sha256` should use new syntax
// 130:           sha256 "deadbeef" => :catalina
// 131:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/BottleFormat: `sha256` should use new syntax
// 132:         end
// 133:       end
// 134:     RUBY
// 135:
// 136:     expect_correction(<<~RUBY)
// 137:       class Foo < Formula
// 138:         url "https://brew.sh/foo-1.0.tgz"
// 139:
// 140:         bottle do
// 141:           rebuild 4
// 142:           sha256 cellar: "/usr/local/Cellar", big_sur: "faceb00c"
// 143:           sha256 cellar: "/usr/local/Cellar", catalina: "deadbeef"
// 144:         end
// 145:       end
// 146:     RUBY
// 147:   end
// 148: end
