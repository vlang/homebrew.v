module rubocops

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/components_redundancy_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_components_redundancy_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports an offense if `url` is outside `stable` block" do` at line 10.
pub fn ruby_components_redundancy_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense if both `head` and `head do` are present" do` at line 26.
pub fn ruby_components_redundancy_spec_l26_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense if both `bottle :modifier` and `bottle do` are present" do` at line 38.
pub fn ruby_components_redundancy_spec_l38_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses if `stable do` is present with a `head` method" do` at line 51.
pub fn ruby_components_redundancy_spec_l51_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses if `stable do` is present with a `head do` block" do` at line 63.
pub fn ruby_components_redundancy_spec_l63_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense if `stable do` or `head do` is present with only `url`" do` at line 77.
pub fn ruby_components_redundancy_spec_l77_d7_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense if `head do` is present with only `url` and `branch`" do` at line 93.
pub fn ruby_components_redundancy_spec_l93_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses if `stable do` is present with `url` and `depends_on`" do` at line 106.
pub fn ruby_components_redundancy_spec_l106_d9_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses if `head do` is present with `url` and `depends_on`" do` at line 119.
pub fn ruby_components_redundancy_spec_l119_d10_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/components_redundancy"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::ComponentsRedundancy do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing formula components" do
// 10:     it "reports an offense if `url` is outside `stable` block" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           url "https://brew.sh/foo-1.0.tgz"
// 14:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/ComponentsRedundancy: `url` should be put inside `stable` block
// 15:           stable do
// 16:             # stuff
// 17:           end
// 18:
// 19:           head do
// 20:             # stuff
// 21:           end
// 22:         end
// 23:       RUBY
// 24:     end
// 25:
// 26:     it "reports an offense if both `head` and `head do` are present" do
// 27:       expect_offense(<<~RUBY)
// 28:         class Foo < Formula
// 29:           head "https://brew.sh/foo.git", branch: "develop"
// 30:           head do
// 31:           ^^^^^^^ FormulaAudit/ComponentsRedundancy: `head` and `head do` should not be simultaneously present
// 32:             # stuff
// 33:           end
// 34:         end
// 35:       RUBY
// 36:     end
// 37:
// 38:     it "reports an offense if both `bottle :modifier` and `bottle do` are present" do
// 39:       expect_offense(<<~RUBY)
// 40:         class Foo < Formula
// 41:           url "https://brew.sh/foo-1.0.tgz"
// 42:           bottle do
// 43:           ^^^^^^^^^ FormulaAudit/ComponentsRedundancy: `bottle :modifier` and `bottle do` should not be simultaneously present
// 44:             # bottles go here
// 45:           end
// 46:           bottle :unneeded
// 47:         end
// 48:       RUBY
// 49:     end
// 50:
// 51:     it "reports no offenses if `stable do` is present with a `head` method" do
// 52:       expect_no_offenses(<<~RUBY)
// 53:         class Foo < Formula
// 54:           head "https://brew.sh/foo.git", branch: "develop"
// 55:
// 56:           stable do
// 57:             # stuff
// 58:           end
// 59:         end
// 60:       RUBY
// 61:     end
// 62:
// 63:     it "reports no offenses if `stable do` is present with a `head do` block" do
// 64:       expect_no_offenses(<<~RUBY)
// 65:         class Foo < Formula
// 66:           stable do
// 67:             # stuff
// 68:           end
// 69:
// 70:           head do
// 71:             # stuff
// 72:           end
// 73:         end
// 74:       RUBY
// 75:     end
// 76:
// 77:     it "reports an offense if `stable do` or `head do` is present with only `url`" do
// 78:       expect_offense(<<~RUBY)
// 79:         class Foo < Formula
// 80:           stable do
// 81:           ^^^^^^^^^ FormulaAudit/ComponentsRedundancy: `stable do` should not be present with only url/sha256/mirror/version
// 82:             url "https://brew.sh/foo-1.0.tgz"
// 83:           end
// 84:
// 85:           head do
// 86:           ^^^^^^^ FormulaAudit/ComponentsRedundancy: `head do` should not be present with only url/branch
// 87:             url "https://brew.sh/foo.git"
// 88:           end
// 89:         end
// 90:       RUBY
// 91:     end
// 92:
// 93:     it "reports an offense if `head do` is present with only `url` and `branch`" do
// 94:       expect_offense(<<~RUBY)
// 95:         class Foo < Formula
// 96:           url "https://brew.sh/foo-1.0.tgz"
// 97:
// 98:           head do
// 99:           ^^^^^^^ FormulaAudit/ComponentsRedundancy: `head do` should not be present with only url/branch
// 100:             url "https://brew.sh/foo.git", branch: "develop"
// 101:           end
// 102:         end
// 103:       RUBY
// 104:     end
// 105:
// 106:     it "reports no offenses if `stable do` is present with `url` and `depends_on`" do
// 107:       expect_no_offenses(<<~RUBY)
// 108:         class Foo < Formula
// 109:           head "https://brew.sh/foo.git", branch: "trunk"
// 110:
// 111:           stable do
// 112:             url "https://brew.sh/foo-1.0.tgz"
// 113:             depends_on "bar"
// 114:           end
// 115:         end
// 116:       RUBY
// 117:     end
// 118:
// 119:     it "reports no offenses if `head do` is present with `url` and `depends_on`" do
// 120:       expect_no_offenses(<<~RUBY)
// 121:         class Foo < Formula
// 122:           url "https://brew.sh/foo-1.0.tgz"
// 123:
// 124:           head do
// 125:             url "https://brew.sh/foo.git"
// 126:             branch "develop"
// 127:             depends_on "bar"
// 128:           end
// 129:         end
// 130:       RUBY
// 131:     end
// 132:   end
// 133: end
