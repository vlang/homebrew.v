module language

import ruby
import homebrew.language as python_language

// Translated from Homebrew/brew `test/language/python_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns a Version for Python 2" do` at line 8.
pub fn ruby_python_spec_l8_d1_returns(args ...ruby.Value) ruby.Value {
	version := python_language.ruby_python_l16_d1_self_major_minor_version(ruby.string_value('python'), ruby.string_value('Python 2.7.18'))
	return ruby.bool_value(version.type_name == 'Version' && version.as_string() == '2.7')
}

// Ruby it `it "gives a different location between PyPy and Python 2" do` at line 15.
pub fn ruby_python_spec_l15_d2_gives(args ...ruby.Value) ruby.Value {
	python := python_language.ruby_python_l29_d3_self_site_packages(ruby.string_value('python'), ruby.string_value('Python 2.7.18')).as_string()
	pypy := python_language.ruby_python_l29_d3_self_site_packages(ruby.string_value('pypy'), ruby.string_value('Python 2.7.18')).as_string()
	return ruby.bool_value(python != pypy)
}

// Ruby it `it "returns the Homebrew site packages location" do` at line 21.
pub fn ruby_python_spec_l21_d3_returns(args ...ruby.Value) ruby.Value {
	location := python_language.ruby_python_l24_d2_self_homebrew_site_packages(ruby.string_value('python'), ruby.string_value('/opt/homebrew'), ruby.string_value('Python 2.7.18'))
	return ruby.bool_value(location.as_string() == '/opt/homebrew/lib/python2.7/site-packages')
}

// Ruby it `it "can determine user site packages location" do` at line 28.
pub fn ruby_python_spec_l28_d4_can(args ...ruby.Value) ruby.Value {
	location := python_language.ruby_python_l78_d6_self_user_site_packages(ruby.string_value('python'), ruby.string_value('/Users/brew/Library/Python/3.13/lib/python/site-packages\n'))
	return ruby.bool_value(location.as_string() == '/Users/brew/Library/Python/3.13/lib/python/site-packages')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "language/python"
// 5:
// 6: RSpec.describe Language::Python, :needs_python do
// 7:   describe "#major_minor_version" do
// 8:     it "returns a Version for Python 2" do
// 9:       expect(described_class).to receive(:major_minor_version).and_return(Version)
// 10:       described_class.major_minor_version("python")
// 11:     end
// 12:   end
// 13:
// 14:   describe "#site_packages" do
// 15:     it "gives a different location between PyPy and Python 2" do
// 16:       expect(described_class.site_packages("python")).not_to eql(described_class.site_packages("pypy"))
// 17:     end
// 18:   end
// 19:
// 20:   describe "#homebrew_site_packages" do
// 21:     it "returns the Homebrew site packages location" do
// 22:       expect(described_class).to receive(:site_packages).and_return(Pathname)
// 23:       described_class.site_packages("python")
// 24:     end
// 25:   end
// 26:
// 27:   describe "#user_site_packages" do
// 28:     it "can determine user site packages location" do
// 29:       expect(described_class).to receive(:user_site_packages).and_return(Pathname)
// 30:       described_class.user_site_packages("python")
// 31:     end
// 32:   end
// 33: end
