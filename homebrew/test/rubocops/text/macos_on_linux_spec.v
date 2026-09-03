module text

import brew_runtime
import homebrew.rubocops as line_cops

// Translated from Homebrew/brew `test/rubocops/text/macos_on_linux_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn macos_on_linux_spec_formula(body string) string {
	indented := body.split('\n').map('  ${it}').join('\n')
	return 'class Foo < Formula\n  desc "foo"\n  url \'https://brew.sh/linux-1.0.tgz\'\n${indented}\nend'
}

fn macos_on_linux_spec_reports(source string) bool {
	analysis := line_cops.audit_lines_macos_on_linux(line_cops.LinesContext{
		source: source
		tap: 'homebrew-core'
	})
	return analysis.offenses.len == 1 && analysis.offenses[0].message == "Don't use `MacOS` where it could be called on Linux." && source[analysis.offenses[0].begin_pos..analysis.offenses[0].end_pos] == 'MacOS' && analysis.corrected == source
}

fn macos_on_linux_spec_accepts(source string) bool {
	analysis := line_cops.audit_lines_macos_on_linux(line_cops.LinesContext{
		source: source
		tap: 'homebrew-core'
	})
	return analysis.offenses.len == 0 && analysis.corrected == source
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_macos_on_linux_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::FormulaAudit::MacOSOnLinux', 'MacOSOnLinux')
}

// Ruby it `it "reports an offense when `MacOS` is used in the `Formula` class" do` at line 9.
pub fn ruby_macos_on_linux_spec_l9_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := macos_on_linux_spec_formula('if MacOS::Xcode.version >= "12.0"\n  url \'https://brew.sh/linux-1.0.tgz\'\nend')
	return brew_runtime.bool_value(macos_on_linux_spec_reports(source))
}

// Ruby it `it "reports an offense when `MacOS` is used in a `resource` block" do` at line 21.
pub fn ruby_macos_on_linux_spec_l21_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := macos_on_linux_spec_formula('resource "foo" do\n  url "https://brew.sh/linux-1.0.tgz" if MacOS::full_version >= "12.0"\nend')
	return brew_runtime.bool_value(macos_on_linux_spec_reports(source))
}

// Ruby it `it "reports an offense when `MacOS` is used in an `on_linux` block" do` at line 35.
pub fn ruby_macos_on_linux_spec_l35_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := macos_on_linux_spec_formula('on_linux do\n  if MacOS::Xcode.version >= "12.0"\n    url \'https://brew.sh/linux-1.0.tgz\'\n  end\nend')
	return brew_runtime.bool_value(macos_on_linux_spec_reports(source))
}

// Ruby it `it "reports an offense when `MacOS` is used in an `on_arm` block" do` at line 49.
pub fn ruby_macos_on_linux_spec_l49_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := macos_on_linux_spec_formula('on_arm do\n  if MacOS::Xcode.version >= "12.0"\n    url \'https://brew.sh/linux-1.0.tgz\'\n  end\nend')
	return brew_runtime.bool_value(macos_on_linux_spec_reports(source))
}

// Ruby it `it "reports an offense when `MacOS` is used in an `on_intel` block" do` at line 63.
pub fn ruby_macos_on_linux_spec_l63_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := macos_on_linux_spec_formula('on_intel do\n  if MacOS::Xcode.version >= "12.0"\n    url \'https://brew.sh/linux-1.0.tgz\'\n  end\nend')
	return brew_runtime.bool_value(macos_on_linux_spec_reports(source))
}

// Ruby it `it "reports no offenses when `MacOS` is used in an `on_macos` block" do` at line 77.
pub fn ruby_macos_on_linux_spec_l77_d7_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := macos_on_linux_spec_formula('on_macos do\n  if MacOS::Xcode.version >= "12.0"\n    url \'https://brew.sh/linux-1.0.tgz\'\n  end\nend')
	return brew_runtime.bool_value(macos_on_linux_spec_accepts(source))
}

// Ruby it `it "reports no offenses when `MacOS` is used in an `on_ventura` block" do` at line 90.
pub fn ruby_macos_on_linux_spec_l90_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := macos_on_linux_spec_formula('on_ventura :or_older do\n  if MacOS::Xcode.version >= "12.0"\n    url \'https://brew.sh/linux-1.0.tgz\'\n  end\nend')
	return brew_runtime.bool_value(macos_on_linux_spec_accepts(source))
}

// Ruby it `it "reports no offenses when `MacOS` is used in the `install` method" do` at line 103.
pub fn ruby_macos_on_linux_spec_l103_d9_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := macos_on_linux_spec_formula('def install\n  MacOS.version\nend')
	return brew_runtime.bool_value(macos_on_linux_spec_accepts(source))
}

// Ruby method `install` at line 109.
pub fn ruby_macos_on_linux_spec_l109_d10_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('def install\n  MacOS.version\nend')
}

// Ruby it `it "reports no offenses when `MacOS` is used in the `test` block" do` at line 116.
pub fn ruby_macos_on_linux_spec_l116_d11_reports(args ...brew_runtime.Value) brew_runtime.Value {
	source := macos_on_linux_spec_formula('test do\n  MacOS.version\nend')
	return brew_runtime.bool_value(macos_on_linux_spec_accepts(source))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/lines"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAudit::MacOSOnLinux do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "reports an offense when `MacOS` is used in the `Formula` class" do
// 10:     expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 11:       class Foo < Formula
// 12:         desc "foo"
// 13:         if MacOS::Xcode.version >= "12.0"
// 14:            ^^^^^ FormulaAudit/MacOSOnLinux: Don't use `MacOS` where it could be called on Linux.
// 15:           url 'https://brew.sh/linux-1.0.tgz'
// 16:         end
// 17:       end
// 18:     RUBY
// 19:   end
// 20:
// 21:   it "reports an offense when `MacOS` is used in a `resource` block" do
// 22:     expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 23:       class Foo < Formula
// 24:         desc "foo"
// 25:         url 'https://brew.sh/linux-1.0.tgz'
// 26:
// 27:         resource "foo" do
// 28:           url "https://brew.sh/linux-1.0.tgz" if MacOS::full_version >= "12.0"
// 29:                                                  ^^^^^ FormulaAudit/MacOSOnLinux: Don't use `MacOS` where it could be called on Linux.
// 30:         end
// 31:       end
// 32:     RUBY
// 33:   end
// 34:
// 35:   it "reports an offense when `MacOS` is used in an `on_linux` block" do
// 36:     expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 37:       class Foo < Formula
// 38:         desc "foo"
// 39:         on_linux do
// 40:           if MacOS::Xcode.version >= "12.0"
// 41:              ^^^^^ FormulaAudit/MacOSOnLinux: Don't use `MacOS` where it could be called on Linux.
// 42:             url 'https://brew.sh/linux-1.0.tgz'
// 43:           end
// 44:         end
// 45:       end
// 46:     RUBY
// 47:   end
// 48:
// 49:   it "reports an offense when `MacOS` is used in an `on_arm` block" do
// 50:     expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 51:       class Foo < Formula
// 52:         desc "foo"
// 53:         on_arm do
// 54:           if MacOS::Xcode.version >= "12.0"
// 55:              ^^^^^ FormulaAudit/MacOSOnLinux: Don't use `MacOS` where it could be called on Linux.
// 56:             url 'https://brew.sh/linux-1.0.tgz'
// 57:           end
// 58:         end
// 59:       end
// 60:     RUBY
// 61:   end
// 62:
// 63:   it "reports an offense when `MacOS` is used in an `on_intel` block" do
// 64:     expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 65:       class Foo < Formula
// 66:         desc "foo"
// 67:         on_intel do
// 68:           if MacOS::Xcode.version >= "12.0"
// 69:              ^^^^^ FormulaAudit/MacOSOnLinux: Don't use `MacOS` where it could be called on Linux.
// 70:             url 'https://brew.sh/linux-1.0.tgz'
// 71:           end
// 72:         end
// 73:       end
// 74:     RUBY
// 75:   end
// 76:
// 77:   it "reports no offenses when `MacOS` is used in an `on_macos` block" do
// 78:     expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 79:       class Foo < Formula
// 80:         desc "foo"
// 81:         on_macos do
// 82:           if MacOS::Xcode.version >= "12.0"
// 83:             url 'https://brew.sh/linux-1.0.tgz'
// 84:           end
// 85:         end
// 86:       end
// 87:     RUBY
// 88:   end
// 89:
// 90:   it "reports no offenses when `MacOS` is used in an `on_ventura` block" do
// 91:     expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 92:       class Foo < Formula
// 93:         desc "foo"
// 94:         on_ventura :or_older do
// 95:           if MacOS::Xcode.version >= "12.0"
// 96:             url 'https://brew.sh/linux-1.0.tgz'
// 97:           end
// 98:         end
// 99:       end
// 100:     RUBY
// 101:   end
// 102:
// 103:   it "reports no offenses when `MacOS` is used in the `install` method" do
// 104:     expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 105:       class Foo < Formula
// 106:         desc "foo"
// 107:         url 'https://brew.sh/linux-1.0.tgz'
// 108:
// 109:         def install
// 110:           MacOS.version
// 111:         end
// 112:       end
// 113:     RUBY
// 114:   end
// 115:
// 116:   it "reports no offenses when `MacOS` is used in the `test` block" do
// 117:     expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 118:       class Foo < Formula
// 119:         desc "foo"
// 120:         url 'https://brew.sh/linux-1.0.tgz'
// 121:
// 122:         test do
// 123:           MacOS.version
// 124:         end
// 125:       end
// 126:     RUBY
// 127:   end
// 128: end
