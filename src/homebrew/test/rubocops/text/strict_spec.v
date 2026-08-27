module text

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/text/strict_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_strict_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports an offense if `env :userpaths` is present" do` at line 10.
pub fn ruby_strict_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense if `env :std` is present in homebrew/core" do` at line 21.
pub fn ruby_strict_spec_l21_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it %Q(reports an offense if "\#{share}/<formula name>" is present) do` at line 32.
pub fn ruby_strict_spec_l32_d4_q_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('%Q(reports', ...args)
}

// Ruby method `install` at line 35.
pub fn ruby_strict_spec_l35_d5_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 44.
pub fn ruby_strict_spec_l44_d6_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 53.
pub fn ruby_strict_spec_l53_d7_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it 'reports an offense if `share/"<formula name>"` is present' do` at line 61.
pub fn ruby_strict_spec_l61_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 64.
pub fn ruby_strict_spec_l64_d9_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 73.
pub fn ruby_strict_spec_l73_d10_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 82.
pub fn ruby_strict_spec_l82_d11_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it %Q(reports no offenses if "\#{share}/<directory name>" doesn't match formula name) do` at line 90.
pub fn ruby_strict_spec_l90_d12_q_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('%Q(reports', ...args)
}

// Ruby method `install` at line 93.
pub fn ruby_strict_spec_l93_d13_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it 'reports no offenses if `share/"<formula name>"` is not present' do` at line 100.
pub fn ruby_strict_spec_l100_d14_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby method `install` at line 103.
pub fn ruby_strict_spec_l103_d15_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 111.
pub fn ruby_strict_spec_l111_d16_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install` at line 119.
pub fn ruby_strict_spec_l119_d17_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it %Q(reports no offenses if formula name appears after "\#{share}/<directory name>") do` at line 126.
pub fn ruby_strict_spec_l126_d18_q_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('%Q(reports', ...args)
}

// Ruby method `install` at line 129.
pub fn ruby_strict_spec_l129_d19_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby it `it 'reports an offense & autocorrects if "\#{bin}/<formula_name>" or other dashed binaries too are present' do` at line 137.
pub fn ruby_strict_spec_l137_d20_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it 'does not report an offense if \#{bin}/foo and then a space and more text' do` at line 159.
pub fn ruby_strict_spec_l159_d21_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it 'does not report an offense if "\#{bin}/foo" is in a word array' do` at line 172.
pub fn ruby_strict_spec_l172_d22_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/text"
// 5:
// 6: RSpec.describe RuboCop::Cop::FormulaAuditStrict::Text do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing formula text in homebrew/core" do
// 10:     it "reports an offense if `env :userpaths` is present" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           url "https://brew.sh/foo-1.0.tgz"
// 14:
// 15:           env :userpaths
// 16:           ^^^^^^^^^^^^^^ FormulaAuditStrict/Text: `env :userpaths` in homebrew/core formulae is deprecated
// 17:         end
// 18:       RUBY
// 19:     end
// 20:
// 21:     it "reports an offense if `env :std` is present in homebrew/core" do
// 22:       expect_offense(<<~RUBY, "/homebrew-core/")
// 23:         class Foo < Formula
// 24:           url "https://brew.sh/foo-1.0.tgz"
// 25:
// 26:           env :std
// 27:           ^^^^^^^^ FormulaAuditStrict/Text: `env :std` in homebrew/core formulae is deprecated
// 28:         end
// 29:       RUBY
// 30:     end
// 31:
// 32:     it %Q(reports an offense if "\#{share}/<formula name>" is present) do
// 33:       expect_offense(<<~'RUBY', "/homebrew-core/Formula/foo.rb")
// 34:         class Foo < Formula
// 35:           def install
// 36:             ohai "#{share}/foo"
// 37:                  ^^^^^^^^^^^^^^ FormulaAuditStrict/Text: Use `#{pkgshare}` instead of `#{share}/foo`
// 38:           end
// 39:         end
// 40:       RUBY
// 41:
// 42:       expect_offense(<<~'RUBY', "/homebrew-core/Formula/foo.rb")
// 43:         class Foo < Formula
// 44:           def install
// 45:             ohai "#{share}/foo/bar"
// 46:                  ^^^^^^^^^^^^^^^^^^ FormulaAuditStrict/Text: Use `#{pkgshare}` instead of `#{share}/foo`
// 47:           end
// 48:         end
// 49:       RUBY
// 50:
// 51:       expect_offense(<<~'RUBY', "/homebrew-core/Formula/foolibc++.rb")
// 52:         class Foolibcxx < Formula
// 53:           def install
// 54:             ohai "#{share}/foolibc++"
// 55:                  ^^^^^^^^^^^^^^^^^^^^ FormulaAuditStrict/Text: Use `#{pkgshare}` instead of `#{share}/foolibc++`
// 56:           end
// 57:         end
// 58:       RUBY
// 59:     end
// 60:
// 61:     it 'reports an offense if `share/"<formula name>"` is present' do
// 62:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 63:         class Foo < Formula
// 64:           def install
// 65:             ohai share/"foo"
// 66:                  ^^^^^^^^^^^ FormulaAuditStrict/Text: Use `pkgshare` instead of `share/"foo"`
// 67:           end
// 68:         end
// 69:       RUBY
// 70:
// 71:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 72:         class Foo < Formula
// 73:           def install
// 74:             ohai share/"foo/bar"
// 75:                  ^^^^^^^^^^^^^^^ FormulaAuditStrict/Text: Use `pkgshare` instead of `share/"foo"`
// 76:           end
// 77:         end
// 78:       RUBY
// 79:
// 80:       expect_offense(<<~RUBY, "/homebrew-core/Formula/foolibc++.rb")
// 81:         class Foolibcxx < Formula
// 82:           def install
// 83:             ohai share/"foolibc++"
// 84:                  ^^^^^^^^^^^^^^^^^ FormulaAuditStrict/Text: Use `pkgshare` instead of `share/"foolibc++"`
// 85:           end
// 86:         end
// 87:       RUBY
// 88:     end
// 89:
// 90:     it %Q(reports no offenses if "\#{share}/<directory name>" doesn't match formula name) do
// 91:       expect_no_offenses(<<~'RUBY', "/homebrew-core/Formula/foo.rb")
// 92:         class Foo < Formula
// 93:           def install
// 94:             ohai "#{share}/foo-bar"
// 95:           end
// 96:         end
// 97:       RUBY
// 98:     end
// 99:
// 100:     it 'reports no offenses if `share/"<formula name>"` is not present' do
// 101:       expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 102:         class Foo < Formula
// 103:           def install
// 104:             ohai share/"foo-bar"
// 105:           end
// 106:         end
// 107:       RUBY
// 108:
// 109:       expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 110:         class Foo < Formula
// 111:           def install
// 112:             ohai share/"bar"
// 113:           end
// 114:         end
// 115:       RUBY
// 116:
// 117:       expect_no_offenses(<<~RUBY, "/homebrew-core/Formula/foo.rb")
// 118:         class Foo < Formula
// 119:           def install
// 120:             ohai share/"bar/foo"
// 121:           end
// 122:         end
// 123:       RUBY
// 124:     end
// 125:
// 126:     it %Q(reports no offenses if formula name appears after "\#{share}/<directory name>") do
// 127:       expect_no_offenses(<<~'RUBY', "/homebrew-core/Formula/foo.rb")
// 128:         class Foo < Formula
// 129:           def install
// 130:             ohai "#{share}/bar/foo"
// 131:           end
// 132:         end
// 133:       RUBY
// 134:     end
// 135:
// 136:     context "for interpolated bin paths" do
// 137:       it 'reports an offense & autocorrects if "\#{bin}/<formula_name>" or other dashed binaries too are present' do
// 138:         expect_offense(<<~'RUBY', "/homebrew-core/Formula/foo.rb")
// 139:           class Foo < Formula
// 140:             test do
// 141:               system "#{bin}/foo", "-v"
// 142:                      ^^^^^^^^^^^^ FormulaAuditStrict/Text: Use `bin/"foo"` instead of `"#{bin}/foo"`
// 143:               system "#{bin}/foo-bar", "-v"
// 144:                      ^^^^^^^^^^^^^^^^ FormulaAuditStrict/Text: Use `bin/"foo-bar"` instead of `"#{bin}/foo-bar"`
// 145:             end
// 146:           end
// 147:         RUBY
// 148:
// 149:         expect_correction(<<~RUBY)
// 150:           class Foo < Formula
// 151:             test do
// 152:               system bin/"foo", "-v"
// 153:               system bin/"foo-bar", "-v"
// 154:             end
// 155:           end
// 156:         RUBY
// 157:       end
// 158:
// 159:       it 'does not report an offense if \#{bin}/foo and then a space and more text' do
// 160:         expect_no_offenses(<<~'RUBY', "/homebrew-core/Formula/foo.rb")
// 161:           class Foo < Formula
// 162:             test do
// 163:               shell_output("#{bin}/foo --version")
// 164:               assert_match "help", shell_output("#{bin}/foo-something --help 2>&1")
// 165:               assert_match "OK", shell_output("#{bin}/foo-something_else --check 2>&1")
// 166:             end
// 167:           end
// 168:         RUBY
// 169:       end
// 170:     end
// 171:
// 172:     it 'does not report an offense if "\#{bin}/foo" is in a word array' do
// 173:       expect_no_offenses(<<~'RUBY', "/homebrew-core/Formula/foo.rb")
// 174:         class Foo < Formula
// 175:           test do
// 176:             cmd = %W[
// 177:               #{bin}/foo
// 178:               version
// 179:             ]
// 180:             assert_match version.to_s, shell_output(cmd)
// 181:           end
// 182:         end
// 183:       RUBY
// 184:     end
// 185:   end
// 186: end
