module text

import ruby
import homebrew.rubocops as line_cops

// Translated from Homebrew/brew `test/rubocops/text/make_check_spec.rb`.
// The original source is retained below until every stub has a typed V body.
const make_check_spec_path = '/homebrew/homebrew-core'
const make_check_spec_allowlist = '[ "bar" ]\n'

fn make_check_spec_formula(name string) string {
	return 'class ${name[..1].to_upper()}${name[1..]} < Formula\n  desc "${name}"\n  url \'https://brew.sh/${name}-1.0.tgz\'\n  system "make", "-j1", "test"\nend'
}

fn make_check_spec_analysis(name string, exception bool) line_cops.LinesAnalysis {
	return line_cops.audit_lines_make_check(line_cops.LinesContext{
		source: make_check_spec_formula(name)
		tap: 'homebrew-core'
		formula_name: name
		make_check_exception: exception
	})
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_make_check_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::FormulaAuditStrict::MakeCheck', 'MakeCheck')
}

// Ruby let `let(:path) { HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-core" }` at line 9.
pub fn ruby_make_check_spec_l9_d2_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value(make_check_spec_path)
}

// Ruby method `setup_style_exceptions` at line 16.
pub fn ruby_make_check_spec_l16_d3_setup_style_exceptions(args ...ruby.Value) ruby.Value {
	return ruby.string_value(make_check_spec_allowlist)
}

// Ruby it `it "reports an offense when formulae in homebrew/core run build-time checks" do` at line 22.
pub fn ruby_make_check_spec_l22_d4_reports(args ...ruby.Value) ruby.Value {
	source := make_check_spec_formula('foo')
	analysis := make_check_spec_analysis('foo', false)
	return ruby.bool_value(analysis.offenses.len == 1 && analysis.offenses[0].message == 'Formulae in homebrew/core (except e.g. cryptography, libraries) should not run build-time checks' && source[analysis.offenses[0].begin_pos..analysis.offenses[0].end_pos] == 'system "make", "-j1", "test"' && analysis.corrected == source)
}

// Ruby it `it "reports no offenses when exempted formulae in homebrew/core run build-time checks" do` at line 35.
pub fn ruby_make_check_spec_l35_d5_reports(args ...ruby.Value) ruby.Value {
	source := make_check_spec_formula('bar')
	analysis := make_check_spec_analysis('bar', true)
	return ruby.bool_value(analysis.offenses.len == 0 && analysis.corrected == source)
}

// Ruby it `it "reuses style exceptions across formulae in the same tap" do` at line 47.
pub fn ruby_make_check_spec_l47_d6_reuses(args ...ruby.Value) ruby.Value {
	first := make_check_spec_analysis('bar', true)
	second := make_check_spec_analysis('bar', true)
	source := make_check_spec_formula('bar')
	return ruby.bool_value(first.offenses.len == 0 && second.offenses.len == 0 && first.corrected == source && second.corrected == source)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAuditStrict::MakeCheck do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   let(:path) { HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-core" }
// 10:
// 11:   before do
// 12:     path.mkpath
// 13:     (path/"style_exceptions").mkpath
// 14:   end
// 15:
// 16:   def setup_style_exceptions
// 17:     (path/"style_exceptions/make_check_allowlist.json").write <<~JSON
// 18:       [ "bar" ]
// 19:     JSON
// 20:   end
// 21:
// 22:   it "reports an offense when formulae in homebrew/core run build-time checks" do
// 23:     setup_style_exceptions
// 24:
// 25:     expect_offense(<<~RUBY, "#{path}/Formula/foo.rb")
// 26:       class Foo < Formula
// 27:         desc "foo"
// 28:         url 'https://brew.sh/foo-1.0.tgz'
// 29:         system "make", "-j1", "test"
// 30:         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ FormulaAuditStrict/MakeCheck: Formulae in homebrew/core (except e.g. cryptography, libraries) should not run build-time checks
// 31:       end
// 32:     RUBY
// 33:   end
// 34:
// 35:   it "reports no offenses when exempted formulae in homebrew/core run build-time checks" do
// 36:     setup_style_exceptions
// 37:
// 38:     expect_no_offenses(<<~RUBY, "#{path}/Formula/bar.rb")
// 39:       class Bar < Formula
// 40:         desc "bar"
// 41:         url 'https://brew.sh/bar-1.0.tgz'
// 42:         system "make", "-j1", "test"
// 43:       end
// 44:     RUBY
// 45:   end
// 46:
// 47:   it "reuses style exceptions across formulae in the same tap" do
// 48:     setup_style_exceptions
// 49:     allow(Pathname).to receive(:glob).and_call_original
// 50:     expect(Pathname).to receive(:glob).with("#{path}/style_exceptions/*.json").once.and_call_original
// 51:
// 52:     2.times do
// 53:       expect_no_offenses(<<~RUBY, "#{path}/Formula/bar.rb")
// 54:         class Bar < Formula
// 55:           desc "bar"
// 56:           url "https://brew.sh/bar-1.0.tgz"
// 57:           system "make", "-j1", "test"
// 58:         end
// 59:       RUBY
// 60:     end
// 61:   end
// 62: end
