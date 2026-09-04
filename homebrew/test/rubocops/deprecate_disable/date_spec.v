module deprecate_disable

import ruby
import homebrew.rubocops

// Translated from Homebrew/brew `test/rubocops/deprecate_disable/date_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn date_spec_source(method string, arguments string) string {
	return "class Foo < Formula\n  url 'https://brew.sh/foo-1.0.tgz'\n  ${method}${arguments}\nend\n"
}

fn date_spec_no_offense(method string, arguments string) bool {
	source := date_spec_source(method, arguments)
	analysis := rubocops.analyze_deprecate_disable_dates(source) or { return false }
	return analysis.offenses.len == 0 && analysis.corrected == source
}

fn date_spec_correction(method string, arguments string) bool {
	source := date_spec_source(method, arguments)
	analysis := rubocops.analyze_deprecate_disable_dates(source) or { return false }
	literal := '"June 25, 2020"'
	begin_pos := source.index(literal) or { return false }
	end_pos := begin_pos + literal.len
	replacement := '"2020-06-25"'
	expected := source[..begin_pos] + replacement + source[end_pos..]
	return analysis.offenses.len == 1 && analysis.offenses[0].begin_pos == begin_pos && analysis.offenses[0].end_pos == end_pos && analysis.offenses[0].message == 'Use `2020-06-25` to comply with ISO 8601' && analysis.offenses[0].replacement == replacement && analysis.corrected == expected
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_date_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('RuboCop::Cop::FormulaAudit::DeprecateDisableDate', 'DeprecateDisableDate')
}

// Ruby it `it "reports and corrects an offense if `date` is not ISO 8601 compliant" do` at line 10.
pub fn ruby_date_spec_l10_d2_reports(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(date_spec_correction('deprecate!', ' date: "June 25, 2020"'))
}

// Ruby it `it "reports and corrects an offense if `date` is not ISO 8601 compliant (with `reason`)" do` at line 27.
pub fn ruby_date_spec_l27_d3_reports(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(date_spec_correction('deprecate!', ' because: "is broken", date: "June 25, 2020"'))
}

// Ruby it `it "reports no offenses if `date` is ISO 8601 compliant" do` at line 44.
pub fn ruby_date_spec_l44_d4_reports(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(date_spec_no_offense('deprecate!', ' date: "2020-06-25"'))
}

// Ruby it `it "reports no offenses if `date` is ISO 8601 compliant (with `reason`)" do` at line 53.
pub fn ruby_date_spec_l53_d5_reports(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(date_spec_no_offense('deprecate!', ' because: "is broken", date: "2020-06-25"'))
}

// Ruby it `it "reports no offenses if no `date` is specified" do` at line 62.
pub fn ruby_date_spec_l62_d6_reports(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(date_spec_no_offense('deprecate!', ''))
}

// Ruby it `it "reports no offenses if no `date` is specified (with `reason`)" do` at line 71.
pub fn ruby_date_spec_l71_d7_reports(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(date_spec_no_offense('deprecate!', ' because: "is broken"'))
}

// Ruby it `it "reports and corrects an offense if `date` is not ISO 8601 compliant" do` at line 82.
pub fn ruby_date_spec_l82_d8_reports(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(date_spec_correction('disable!', ' date: "June 25, 2020"'))
}

// Ruby it `it "reports and corrects an offense if `date` is not ISO 8601 compliant (with `reason`)" do` at line 99.
pub fn ruby_date_spec_l99_d9_reports(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(date_spec_correction('disable!', ' because: "is broken", date: "June 25, 2020"'))
}

// Ruby it `it "reports no offenses if `date` is ISO 8601 compliant" do` at line 116.
pub fn ruby_date_spec_l116_d10_reports(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(date_spec_no_offense('disable!', ' date: "2020-06-25"'))
}

// Ruby it `it "reports no offenses if `date` is ISO 8601 compliant (with `reason`)" do` at line 125.
pub fn ruby_date_spec_l125_d11_reports(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(date_spec_no_offense('disable!', ' because: "is broken", date: "2020-06-25"'))
}

// Ruby it `it "reports no offenses if no `date` is specified" do` at line 134.
pub fn ruby_date_spec_l134_d12_reports(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(date_spec_no_offense('disable!', ''))
}

// Ruby it `it "reports no offenses if no `date` is specified (with `reason`)" do` at line 143.
pub fn ruby_date_spec_l143_d13_reports(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(date_spec_no_offense('disable!', ' because: "is broken"'))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/deprecate_disable"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::DeprecateDisableDate do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing `deprecate!`" do
// 10:     it "reports and corrects an offense if `date` is not ISO 8601 compliant" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           url 'https://brew.sh/foo-1.0.tgz'
// 14:           deprecate! date: "June 25, 2020"
// 15:                            ^^^^^^^^^^^^^^^ FormulaAudit/DeprecateDisableDate: Use `2020-06-25` to comply with ISO 8601
// 16:         end
// 17:       RUBY
// 18:
// 19:       expect_correction(<<~RUBY)
// 20:         class Foo < Formula
// 21:           url 'https://brew.sh/foo-1.0.tgz'
// 22:           deprecate! date: "2020-06-25"
// 23:         end
// 24:       RUBY
// 25:     end
// 26:
// 27:     it "reports and corrects an offense if `date` is not ISO 8601 compliant (with `reason`)" do
// 28:       expect_offense(<<~RUBY)
// 29:         class Foo < Formula
// 30:           url 'https://brew.sh/foo-1.0.tgz'
// 31:           deprecate! because: "is broken", date: "June 25, 2020"
// 32:                                                  ^^^^^^^^^^^^^^^ FormulaAudit/DeprecateDisableDate: Use `2020-06-25` to comply with ISO 8601
// 33:         end
// 34:       RUBY
// 35:
// 36:       expect_correction(<<~RUBY)
// 37:         class Foo < Formula
// 38:           url 'https://brew.sh/foo-1.0.tgz'
// 39:           deprecate! because: "is broken", date: "2020-06-25"
// 40:         end
// 41:       RUBY
// 42:     end
// 43:
// 44:     it "reports no offenses if `date` is ISO 8601 compliant" do
// 45:       expect_no_offenses(<<~RUBY)
// 46:         class Foo < Formula
// 47:           url 'https://brew.sh/foo-1.0.tgz'
// 48:           deprecate! date: "2020-06-25"
// 49:         end
// 50:       RUBY
// 51:     end
// 52:
// 53:     it "reports no offenses if `date` is ISO 8601 compliant (with `reason`)" do
// 54:       expect_no_offenses(<<~RUBY)
// 55:         class Foo < Formula
// 56:           url 'https://brew.sh/foo-1.0.tgz'
// 57:           deprecate! because: "is broken", date: "2020-06-25"
// 58:         end
// 59:       RUBY
// 60:     end
// 61:
// 62:     it "reports no offenses if no `date` is specified" do
// 63:       expect_no_offenses(<<~RUBY)
// 64:         class Foo < Formula
// 65:           url 'https://brew.sh/foo-1.0.tgz'
// 66:           deprecate!
// 67:         end
// 68:       RUBY
// 69:     end
// 70:
// 71:     it "reports no offenses if no `date` is specified (with `reason`)" do
// 72:       expect_no_offenses(<<~RUBY)
// 73:         class Foo < Formula
// 74:           url 'https://brew.sh/foo-1.0.tgz'
// 75:           deprecate! because: "is broken"
// 76:         end
// 77:       RUBY
// 78:     end
// 79:   end
// 80:
// 81:   context "when auditing `disable!`" do
// 82:     it "reports and corrects an offense if `date` is not ISO 8601 compliant" do
// 83:       expect_offense(<<~RUBY)
// 84:         class Foo < Formula
// 85:           url 'https://brew.sh/foo-1.0.tgz'
// 86:           disable! date: "June 25, 2020"
// 87:                          ^^^^^^^^^^^^^^^ FormulaAudit/DeprecateDisableDate: Use `2020-06-25` to comply with ISO 8601
// 88:         end
// 89:       RUBY
// 90:
// 91:       expect_correction(<<~RUBY)
// 92:         class Foo < Formula
// 93:           url 'https://brew.sh/foo-1.0.tgz'
// 94:           disable! date: "2020-06-25"
// 95:         end
// 96:       RUBY
// 97:     end
// 98:
// 99:     it "reports and corrects an offense if `date` is not ISO 8601 compliant (with `reason`)" do
// 100:       expect_offense(<<~RUBY)
// 101:         class Foo < Formula
// 102:           url 'https://brew.sh/foo-1.0.tgz'
// 103:           disable! because: "is broken", date: "June 25, 2020"
// 104:                                                ^^^^^^^^^^^^^^^ FormulaAudit/DeprecateDisableDate: Use `2020-06-25` to comply with ISO 8601
// 105:         end
// 106:       RUBY
// 107:
// 108:       expect_correction(<<~RUBY)
// 109:         class Foo < Formula
// 110:           url 'https://brew.sh/foo-1.0.tgz'
// 111:           disable! because: "is broken", date: "2020-06-25"
// 112:         end
// 113:       RUBY
// 114:     end
// 115:
// 116:     it "reports no offenses if `date` is ISO 8601 compliant" do
// 117:       expect_no_offenses(<<~RUBY)
// 118:         class Foo < Formula
// 119:           url 'https://brew.sh/foo-1.0.tgz'
// 120:           disable! date: "2020-06-25"
// 121:         end
// 122:       RUBY
// 123:     end
// 124:
// 125:     it "reports no offenses if `date` is ISO 8601 compliant (with `reason`)" do
// 126:       expect_no_offenses(<<~RUBY)
// 127:         class Foo < Formula
// 128:           url 'https://brew.sh/foo-1.0.tgz'
// 129:           disable! because: "is broken", date: "2020-06-25"
// 130:         end
// 131:       RUBY
// 132:     end
// 133:
// 134:     it "reports no offenses if no `date` is specified" do
// 135:       expect_no_offenses(<<~RUBY)
// 136:         class Foo < Formula
// 137:           url 'https://brew.sh/foo-1.0.tgz'
// 138:           disable!
// 139:         end
// 140:       RUBY
// 141:     end
// 142:
// 143:     it "reports no offenses if no `date` is specified (with `reason`)" do
// 144:       expect_no_offenses(<<~RUBY)
// 145:         class Foo < Formula
// 146:           url 'https://brew.sh/foo-1.0.tgz'
// 147:           disable! because: "is broken"
// 148:         end
// 149:       RUBY
// 150:     end
// 151:   end
// 152: end
