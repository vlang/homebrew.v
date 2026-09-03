module text

import brew_runtime
import homebrew.rubocops as line_cops

// Translated from Homebrew/brew `test/rubocops/text/option_declarations_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn option_declarations_spec_method(name string, statement string) string {
	return 'def ${name}\n  ${statement}\nend'
}

fn option_declarations_spec_formula(method_source string) string {
	mut lines := ['class Foo < Formula', '  desc "foo"', "  url 'https://brew.sh/foo-1.0.tgz'"]
	if method_source != '' {
		lines << ''
		for line in method_source.split_into_lines() {
			lines << '  ${line}'
		}
	}
	lines << 'end'
	return lines.join('\n')
}

fn option_declarations_spec_reports(source string, tap string, message string) bool {
	analysis := line_cops.audit_lines_option_declarations(line_cops.LinesContext{
		source: source
		tap: tap
	})
	return analysis.offenses.len == 1 && analysis.offenses[0].message == message && analysis.corrected == source
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_option_declarations_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::OptionDeclarations', 'OptionDeclarations')
}

// Ruby it `it "reports an offense when `build.without?` is used in homebrew/core" do` at line 10.
pub fn ruby_option_declarations_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := option_declarations_spec_formula(option_declarations_spec_method('install', 'build.without? "bar"'))
	return brew_runtime.bool_value(option_declarations_spec_reports(source, 'homebrew-core', 'Formulae in homebrew/core should not use `build.without?`.'))
}

// Ruby method `install` at line 15.
pub fn ruby_option_declarations_spec_l15_d3_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(option_declarations_spec_method('install', 'build.without? "bar"'))
}

// Ruby it `it "reports an offense when `build.with?` is used in homebrew/core" do` at line 23.
pub fn ruby_option_declarations_spec_l23_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := option_declarations_spec_formula(option_declarations_spec_method('install', 'build.with? "bar"'))
	return brew_runtime.bool_value(option_declarations_spec_reports(source, 'homebrew-core', 'Formulae in homebrew/core should not use `build.with?`.'))
}

// Ruby method `install` at line 28.
pub fn ruby_option_declarations_spec_l28_d5_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(option_declarations_spec_method('install', 'build.with? "bar"'))
}

// Ruby it `it "reports an offense when `build.without?` is used for a conditional dependency" do` at line 36.
pub fn ruby_option_declarations_spec_l36_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'class Foo < Formula\n  depends_on "bar" if build.without?("baz")\nend'
	return brew_runtime.bool_value(option_declarations_spec_reports(source, '', 'Use `:optional` or `:recommended` instead of `if build.without?("baz")`'))
}

// Ruby it `it "reports an offense when `build.with?` is used for a conditional dependency" do` at line 45.
pub fn ruby_option_declarations_spec_l45_d7_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := 'class Foo < Formula\n  depends_on "bar" if build.with?("baz")\nend'
	return brew_runtime.bool_value(option_declarations_spec_reports(source, '', 'Use `:optional` or `:recommended` instead of `if build.with?("baz")`'))
}

// Ruby it `it "reports an offense when `build.without?` is used with `unless`" do` at line 54.
pub fn ruby_option_declarations_spec_l54_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := option_declarations_spec_formula(option_declarations_spec_method('post_install', 'return unless build.without? "bar"'))
	return brew_runtime.bool_value(option_declarations_spec_reports(source, '', 'Use `if build.with? "bar"` instead of `unless build.without? "bar"`'))
}

// Ruby method `post_install` at line 59.
pub fn ruby_option_declarations_spec_l59_d9_post_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(option_declarations_spec_method('post_install', 'return unless build.without? "bar"'))
}

// Ruby it `it "reports an offense when `build.with?` is used with `unless`" do` at line 67.
pub fn ruby_option_declarations_spec_l67_d10_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := option_declarations_spec_formula(option_declarations_spec_method('post_install', 'return unless build.with? "bar"'))
	return brew_runtime.bool_value(option_declarations_spec_reports(source, '', 'Use `if build.without? "bar"` instead of `unless build.with? "bar"`'))
}

// Ruby method `post_install` at line 72.
pub fn ruby_option_declarations_spec_l72_d11_post_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(option_declarations_spec_method('post_install', 'return unless build.with? "bar"'))
}

// Ruby it `it "reports an offense when `build.with?` is negated" do` at line 80.
pub fn ruby_option_declarations_spec_l80_d12_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := option_declarations_spec_formula(option_declarations_spec_method('post_install', 'return if !build.with? "bar"'))
	return brew_runtime.bool_value(option_declarations_spec_reports(source, '', 'Instead of negating `build.with?`, use `build.without?`'))
}

// Ruby method `post_install` at line 85.
pub fn ruby_option_declarations_spec_l85_d13_post_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(option_declarations_spec_method('post_install', 'return if !build.with? "bar"'))
}

// Ruby it `it "reports an offense when `build.without?` is negated" do` at line 93.
pub fn ruby_option_declarations_spec_l93_d14_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := option_declarations_spec_formula(option_declarations_spec_method('post_install', 'return if !build.without? "bar"'))
	return brew_runtime.bool_value(option_declarations_spec_reports(source, '', 'Instead of negating `build.without?`, use `build.with?`'))
}

// Ruby method `post_install` at line 98.
pub fn ruby_option_declarations_spec_l98_d15_post_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(option_declarations_spec_method('post_install', 'return if !build.without? "bar"'))
}

// Ruby it `it "reports an offense when a `build.without?` conditional is unnecessary" do` at line 106.
pub fn ruby_option_declarations_spec_l106_d16_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := option_declarations_spec_formula(option_declarations_spec_method('post_install', 'return if build.without? "--without-bar"'))
	return brew_runtime.bool_value(option_declarations_spec_reports(source, '', 'Instead of duplicating `without`, use `build.without? "bar"` to check for "--without-bar"'))
}

// Ruby method `post_install` at line 111.
pub fn ruby_option_declarations_spec_l111_d17_post_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(option_declarations_spec_method('post_install', 'return if build.without? "--without-bar"'))
}

// Ruby it `it "reports an offense when a `build.with?` conditional is unnecessary" do` at line 119.
pub fn ruby_option_declarations_spec_l119_d18_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := option_declarations_spec_formula(option_declarations_spec_method('post_install', 'return if build.with? "--with-bar"'))
	return brew_runtime.bool_value(option_declarations_spec_reports(source, '', 'Instead of duplicating `with`, use `build.with? "bar"` to check for \'--with-bar\''))
}

// Ruby method `post_install` at line 124.
pub fn ruby_option_declarations_spec_l124_d19_post_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(option_declarations_spec_method('post_install', 'return if build.with? "--with-bar"'))
}

// Ruby it `it "reports an offense when `build.include?` is used" do` at line 132.
pub fn ruby_option_declarations_spec_l132_d20_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := option_declarations_spec_formula(option_declarations_spec_method('post_install', 'return if build.include? "foo"'))
	return brew_runtime.bool_value(option_declarations_spec_reports(source, '', '`build.include?` is deprecated'))
}

// Ruby method `post_install` at line 137.
pub fn ruby_option_declarations_spec_l137_d21_post_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(option_declarations_spec_method('post_install', 'return if build.include? "foo"'))
}

// Ruby it `it "reports an offense when `def option` is used" do` at line 145.
pub fn ruby_option_declarations_spec_l145_d22_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := option_declarations_spec_formula('def options\n  [["--bar", "desc"]]\nend')
	return brew_runtime.bool_value(option_declarations_spec_reports(source, '', 'Use new-style option definitions'))
}

// Ruby method `options` at line 151.
pub fn ruby_option_declarations_spec_l151_d23_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def options\n  [["--bar", "desc"]]\nend')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::OptionDeclarations do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing options" do
// 10:     it "reports an offense when `build.without?` is used in homebrew/core" do
// 11:       expect_offense(<<~RUBY, "/homebrew-core/")
// 12:         class Foo < Formula
// 13:           desc "foo"
// 14:           url 'https://brew.sh/foo-1.0.tgz'
// 15:           def install
// 16:             build.without? "bar"
// 17:             ^^^^^^^^^^^^^^^^^^^^ FormulaAudit/OptionDeclarations: Formulae in homebrew/core should not use `build.without?`.
// 18:           end
// 19:         end
// 20:       RUBY
// 21:     end
// 22:
// 23:     it "reports an offense when `build.with?` is used in homebrew/core" do
// 24:       expect_offense(<<~RUBY, "/homebrew-core/")
// 25:         class Foo < Formula
// 26:           desc "foo"
// 27:           url 'https://brew.sh/foo-1.0.tgz'
// 28:           def install
// 29:             build.with? "bar"
// 30:             ^^^^^^^^^^^^^^^^^ FormulaAudit/OptionDeclarations: Formulae in homebrew/core should not use `build.with?`.
// 31:           end
// 32:         end
// 33:       RUBY
// 34:     end
// 35:
// 36:     it "reports an offense when `build.without?` is used for a conditional dependency" do
// 37:       expect_offense(<<~RUBY)
// 38:         class Foo < Formula
// 39:           depends_on "bar" if build.without?("baz")
// 40:                               ^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/OptionDeclarations: Use `:optional` or `:recommended` instead of `if build.without?("baz")`
// 41:         end
// 42:       RUBY
// 43:     end
// 44:
// 45:     it "reports an offense when `build.with?` is used for a conditional dependency" do
// 46:       expect_offense(<<~RUBY)
// 47:         class Foo < Formula
// 48:           depends_on "bar" if build.with?("baz")
// 49:                               ^^^^^^^^^^^^^^^^^^ FormulaAudit/OptionDeclarations: Use `:optional` or `:recommended` instead of `if build.with?("baz")`
// 50:         end
// 51:       RUBY
// 52:     end
// 53:
// 54:     it "reports an offense when `build.without?` is used with `unless`" do
// 55:       expect_offense(<<~RUBY)
// 56:         class Foo < Formula
// 57:           desc "foo"
// 58:           url 'https://brew.sh/foo-1.0.tgz'
// 59:           def post_install
// 60:             return unless build.without? "bar"
// 61:                           ^^^^^^^^^^^^^^^^^^^^ FormulaAudit/OptionDeclarations: Use `if build.with? "bar"` instead of `unless build.without? "bar"`
// 62:           end
// 63:         end
// 64:       RUBY
// 65:     end
// 66:
// 67:     it "reports an offense when `build.with?` is used with `unless`" do
// 68:       expect_offense(<<~RUBY)
// 69:         class Foo < Formula
// 70:           desc "foo"
// 71:           url 'https://brew.sh/foo-1.0.tgz'
// 72:           def post_install
// 73:             return unless build.with? "bar"
// 74:                           ^^^^^^^^^^^^^^^^^ FormulaAudit/OptionDeclarations: Use `if build.without? "bar"` instead of `unless build.with? "bar"`
// 75:           end
// 76:         end
// 77:       RUBY
// 78:     end
// 79:
// 80:     it "reports an offense when `build.with?` is negated" do
// 81:       expect_offense(<<~RUBY)
// 82:         class Foo < Formula
// 83:           desc "foo"
// 84:           url 'https://brew.sh/foo-1.0.tgz'
// 85:           def post_install
// 86:             return if !build.with? "bar"
// 87:                       ^^^^^^^^^^^^^^^^^^ FormulaAudit/OptionDeclarations: Instead of negating `build.with?`, use `build.without?`
// 88:           end
// 89:         end
// 90:       RUBY
// 91:     end
// 92:
// 93:     it "reports an offense when `build.without?` is negated" do
// 94:       expect_offense(<<~RUBY)
// 95:         class Foo < Formula
// 96:           desc "foo"
// 97:           url 'https://brew.sh/foo-1.0.tgz'
// 98:           def post_install
// 99:             return if !build.without? "bar"
// 100:                       ^^^^^^^^^^^^^^^^^^^^^ FormulaAudit/OptionDeclarations: Instead of negating `build.without?`, use `build.with?`
// 101:           end
// 102:         end
// 103:       RUBY
// 104:     end
// 105:
// 106:     it "reports an offense when a `build.without?` conditional is unnecessary" do
// 107:       expect_offense(<<~RUBY)
// 108:         class Foo < Formula
// 109:           desc "foo"
// 110:           url 'https://brew.sh/foo-1.0.tgz'
// 111:           def post_install
// 112:             return if build.without? "--without-bar"
// 113:                                      ^^^^^^^^^^^^^^^ FormulaAudit/OptionDeclarations: Instead of duplicating `without`, use `build.without? "bar"` to check for "--without-bar"
// 114:           end
// 115:         end
// 116:       RUBY
// 117:     end
// 118:
// 119:     it "reports an offense when a `build.with?` conditional is unnecessary" do
// 120:       expect_offense(<<~RUBY)
// 121:         class Foo < Formula
// 122:           desc "foo"
// 123:           url 'https://brew.sh/foo-1.0.tgz'
// 124:           def post_install
// 125:             return if build.with? "--with-bar"
// 126:                                   ^^^^^^^^^^^^ FormulaAudit/OptionDeclarations: Instead of duplicating `with`, use `build.with? "bar"` to check for '--with-bar'
// 127:           end
// 128:         end
// 129:       RUBY
// 130:     end
// 131:
// 132:     it "reports an offense when `build.include?` is used" do
// 133:       expect_offense(<<~RUBY)
// 134:         class Foo < Formula
// 135:           desc "foo"
// 136:           url 'https://brew.sh/foo-1.0.tgz'
// 137:           def post_install
// 138:             return if build.include? "foo"
// 139:                       ^^^^^^^^^^^^^^^^^^^^ FormulaAudit/OptionDeclarations: `build.include?` is deprecated
// 140:           end
// 141:         end
// 142:       RUBY
// 143:     end
// 144:
// 145:     it "reports an offense when `def option` is used" do
// 146:       expect_offense(<<~RUBY)
// 147:         class Foo < Formula
// 148:           desc "foo"
// 149:           url 'https://brew.sh/foo-1.0.tgz'
// 150:
// 151:           def options
// 152:           ^^^^^^^^^^^ FormulaAudit/OptionDeclarations: Use new-style option definitions
// 153:             [["--bar", "desc"]]
// 154:           end
// 155:         end
// 156:       RUBY
// 157:     end
// 158:   end
// 159: end
