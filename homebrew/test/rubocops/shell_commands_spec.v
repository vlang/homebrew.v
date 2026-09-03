module rubocops

import brew_runtime
import homebrew.rubocops as shell_commands

// Translated from Homebrew/brew `test/rubocops/shell_commands_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn shell_commands_spec_method(command string) string {
	return 'def install\n  ${command}\nend'
}

fn shell_commands_spec_reports(source string, corrected string, method_name string,
	good_args string) bool {
	analysis := shell_commands.analyze_shell_commands(source) or { return false }
	return analysis.offenses.len == 1 && analysis.offenses[0].message == 'Separate `${method_name}` commands into `${good_args}`' && analysis.offenses[0].replacement == good_args && analysis.corrected == corrected
}

fn shell_commands_spec_no_offense(source string) bool {
	analysis := shell_commands.analyze_shell_commands(source) or { return false }
	return analysis.offenses.len == 0 && analysis.corrected == source
}

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_shell_commands_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('RuboCop::Cop::Homebrew::ShellCommands', 'ShellCommands')
}

// Ruby it `it "reports and corrects an offense when `system` arguments should be separated" do` at line 10.
pub fn ruby_shell_commands_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(shell_commands_spec_reports(shell_commands_spec_method('system "foo bar"'), shell_commands_spec_method('system "foo", "bar"'), 'system', '"foo", "bar"'))
}

// Ruby method `install` at line 13.
pub fn ruby_shell_commands_spec_l13_d3_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('system "foo bar"'))
}

// Ruby method `install` at line 22.
pub fn ruby_shell_commands_spec_l22_d4_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('system "foo", "bar"'))
}

// Ruby it `it "reports and corrects an offense when `system` arguments involving interpolation should be separated" do` at line 29.
pub fn ruby_shell_commands_spec_l29_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(shell_commands_spec_reports(shell_commands_spec_method('system "#{bin}/foo bar"'), shell_commands_spec_method('system "#{bin}/foo", "bar"'), 'system', '"#{bin}/foo", "bar"'))
}

// Ruby method `install` at line 32.
pub fn ruby_shell_commands_spec_l32_d6_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('system "#{bin}/foo bar"'))
}

// Ruby method `install` at line 41.
pub fn ruby_shell_commands_spec_l41_d7_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('system "#{bin}/foo", "bar"'))
}

// Ruby it `it "reports no offenses when `system` with metacharacter arguments are called" do` at line 48.
pub fn ruby_shell_commands_spec_l48_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(shell_commands_spec_no_offense(shell_commands_spec_method('system "foo bar > baz"')))
}

// Ruby method `install` at line 51.
pub fn ruby_shell_commands_spec_l51_d9_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('system "foo bar > baz"'))
}

// Ruby it `it "reports no offenses when trailing arguments to `system` are unseparated" do` at line 58.
pub fn ruby_shell_commands_spec_l58_d10_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(shell_commands_spec_no_offense(shell_commands_spec_method('system "foo", "bar baz"')))
}

// Ruby method `install` at line 61.
pub fn ruby_shell_commands_spec_l61_d11_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('system "foo", "bar baz"'))
}

// Ruby it `it "reports no offenses when `Utils.popen` arguments are unseparated" do` at line 68.
pub fn ruby_shell_commands_spec_l68_d12_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(shell_commands_spec_no_offense(shell_commands_spec_method('Utils.popen("foo bar")')))
}

// Ruby method `install` at line 71.
pub fn ruby_shell_commands_spec_l71_d13_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.popen("foo bar")'))
}

// Ruby it `it "reports and corrects an offense when `Utils.popen_read` arguments are unseparated" do` at line 78.
pub fn ruby_shell_commands_spec_l78_d14_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(shell_commands_spec_reports(shell_commands_spec_method('Utils.popen_read("foo bar")'), shell_commands_spec_method('Utils.popen_read("foo", "bar")'), 'Utils.popen_read', '"foo", "bar"'))
}

// Ruby method `install` at line 81.
pub fn ruby_shell_commands_spec_l81_d15_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.popen_read("foo bar")'))
}

// Ruby method `install` at line 90.
pub fn ruby_shell_commands_spec_l90_d16_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.popen_read("foo", "bar")'))
}

// Ruby it `it "reports and corrects an offense when `Utils.safe_popen_read` arguments are unseparated" do` at line 97.
pub fn ruby_shell_commands_spec_l97_d17_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(shell_commands_spec_reports(shell_commands_spec_method('Utils.safe_popen_read("foo bar")'), shell_commands_spec_method('Utils.safe_popen_read("foo", "bar")'), 'Utils.safe_popen_read', '"foo", "bar"'))
}

// Ruby method `install` at line 100.
pub fn ruby_shell_commands_spec_l100_d18_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.safe_popen_read("foo bar")'))
}

// Ruby method `install` at line 109.
pub fn ruby_shell_commands_spec_l109_d19_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.safe_popen_read("foo", "bar")'))
}

// Ruby it `it "reports and corrects an offense when `Utils.popen_write` arguments are unseparated" do` at line 116.
pub fn ruby_shell_commands_spec_l116_d20_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(shell_commands_spec_reports(shell_commands_spec_method('Utils.popen_write("foo bar")'), shell_commands_spec_method('Utils.popen_write("foo", "bar")'), 'Utils.popen_write', '"foo", "bar"'))
}

// Ruby method `install` at line 119.
pub fn ruby_shell_commands_spec_l119_d21_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.popen_write("foo bar")'))
}

// Ruby method `install` at line 128.
pub fn ruby_shell_commands_spec_l128_d22_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.popen_write("foo", "bar")'))
}

// Ruby it `it "reports and corrects an offense when `Utils.safe_popen_write` arguments are unseparated" do` at line 135.
pub fn ruby_shell_commands_spec_l135_d23_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(shell_commands_spec_reports(shell_commands_spec_method('Utils.safe_popen_write("foo bar")'), shell_commands_spec_method('Utils.safe_popen_write("foo", "bar")'), 'Utils.safe_popen_write', '"foo", "bar"'))
}

// Ruby method `install` at line 138.
pub fn ruby_shell_commands_spec_l138_d24_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.safe_popen_write("foo bar")'))
}

// Ruby method `install` at line 147.
pub fn ruby_shell_commands_spec_l147_d25_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.safe_popen_write("foo", "bar")'))
}

// Ruby it `it "reports and corrects an offense when `Utils.popen_read` arguments with interpolation are unseparated" do` at line 154.
pub fn ruby_shell_commands_spec_l154_d26_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(shell_commands_spec_reports(shell_commands_spec_method('Utils.popen_read("#{bin}/foo bar")'), shell_commands_spec_method('Utils.popen_read("#{bin}/foo", "bar")'), 'Utils.popen_read', '"#{bin}/foo", "bar"'))
}

// Ruby method `install` at line 157.
pub fn ruby_shell_commands_spec_l157_d27_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.popen_read("#{bin}/foo bar")'))
}

// Ruby method `install` at line 166.
pub fn ruby_shell_commands_spec_l166_d28_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.popen_read("#{bin}/foo", "bar")'))
}

// Ruby it `it "reports no offenses when `Utils.popen_read` arguments with metacharacters are unseparated" do` at line 173.
pub fn ruby_shell_commands_spec_l173_d29_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(shell_commands_spec_no_offense(shell_commands_spec_method('Utils.popen_read("foo bar > baz")')))
}

// Ruby method `install` at line 176.
pub fn ruby_shell_commands_spec_l176_d30_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.popen_read("foo bar > baz")'))
}

// Ruby it `it "reports no offenses when trailing arguments to `Utils.popen_read` are unseparated" do` at line 183.
pub fn ruby_shell_commands_spec_l183_d31_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(shell_commands_spec_no_offense(shell_commands_spec_method('Utils.popen_read("foo", "bar baz")')))
}

// Ruby method `install` at line 186.
pub fn ruby_shell_commands_spec_l186_d32_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.popen_read("foo", "bar baz")'))
}

// Ruby it `it "reports and corrects an offense when `Utils.popen_read` arguments are unseparated after a shell env" do` at line 193.
pub fn ruby_shell_commands_spec_l193_d33_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(shell_commands_spec_reports(shell_commands_spec_method('Utils.popen_read({ "SHELL" => "bash"}, "foo bar")'), shell_commands_spec_method('Utils.popen_read({ "SHELL" => "bash"}, "foo", "bar")'), 'Utils.popen_read', '"foo", "bar"'))
}

// Ruby method `install` at line 196.
pub fn ruby_shell_commands_spec_l196_d34_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.popen_read({ "SHELL" => "bash"}, "foo bar")'))
}

// Ruby method `install` at line 205.
pub fn ruby_shell_commands_spec_l205_d35_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(shell_commands_spec_method('Utils.popen_read({ "SHELL" => "bash"}, "foo", "bar")'))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shell_commands"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::ShellCommands do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing shell commands" do
// 10:     it "reports and corrects an offense when `system` arguments should be separated" do
// 11:       expect_offense(<<~RUBY)
// 12:         class Foo < Formula
// 13:           def install
// 14:             system "foo bar"
// 15:                    ^^^^^^^^^ Homebrew/ShellCommands: Separate `system` commands into `"foo", "bar"`
// 16:           end
// 17:         end
// 18:       RUBY
// 19:
// 20:       expect_correction(<<~RUBY)
// 21:         class Foo < Formula
// 22:           def install
// 23:             system "foo", "bar"
// 24:           end
// 25:         end
// 26:       RUBY
// 27:     end
// 28:
// 29:     it "reports and corrects an offense when `system` arguments involving interpolation should be separated" do
// 30:       expect_offense(<<~'RUBY')
// 31:         class Foo < Formula
// 32:           def install
// 33:             system "#{bin}/foo bar"
// 34:                    ^^^^^^^^^^^^^^^^ Homebrew/ShellCommands: Separate `system` commands into `"#{bin}/foo", "bar"`
// 35:           end
// 36:         end
// 37:       RUBY
// 38:
// 39:       expect_correction(<<~'RUBY')
// 40:         class Foo < Formula
// 41:           def install
// 42:             system "#{bin}/foo", "bar"
// 43:           end
// 44:         end
// 45:       RUBY
// 46:     end
// 47:
// 48:     it "reports no offenses when `system` with metacharacter arguments are called" do
// 49:       expect_no_offenses(<<~RUBY)
// 50:         class Foo < Formula
// 51:           def install
// 52:             system "foo bar > baz"
// 53:           end
// 54:         end
// 55:       RUBY
// 56:     end
// 57:
// 58:     it "reports no offenses when trailing arguments to `system` are unseparated" do
// 59:       expect_no_offenses(<<~RUBY)
// 60:         class Foo < Formula
// 61:           def install
// 62:             system "foo", "bar baz"
// 63:           end
// 64:         end
// 65:       RUBY
// 66:     end
// 67:
// 68:     it "reports no offenses when `Utils.popen` arguments are unseparated" do
// 69:       expect_no_offenses(<<~RUBY)
// 70:         class Foo < Formula
// 71:           def install
// 72:             Utils.popen("foo bar")
// 73:           end
// 74:         end
// 75:       RUBY
// 76:     end
// 77:
// 78:     it "reports and corrects an offense when `Utils.popen_read` arguments are unseparated" do
// 79:       expect_offense(<<~RUBY)
// 80:         class Foo < Formula
// 81:           def install
// 82:             Utils.popen_read("foo bar")
// 83:                              ^^^^^^^^^ Homebrew/ShellCommands: Separate `Utils.popen_read` commands into `"foo", "bar"`
// 84:           end
// 85:         end
// 86:       RUBY
// 87:
// 88:       expect_correction(<<~RUBY)
// 89:         class Foo < Formula
// 90:           def install
// 91:             Utils.popen_read("foo", "bar")
// 92:           end
// 93:         end
// 94:       RUBY
// 95:     end
// 96:
// 97:     it "reports and corrects an offense when `Utils.safe_popen_read` arguments are unseparated" do
// 98:       expect_offense(<<~RUBY)
// 99:         class Foo < Formula
// 100:           def install
// 101:             Utils.safe_popen_read("foo bar")
// 102:                                   ^^^^^^^^^ Homebrew/ShellCommands: Separate `Utils.safe_popen_read` commands into `"foo", "bar"`
// 103:           end
// 104:         end
// 105:       RUBY
// 106:
// 107:       expect_correction(<<~RUBY)
// 108:         class Foo < Formula
// 109:           def install
// 110:             Utils.safe_popen_read("foo", "bar")
// 111:           end
// 112:         end
// 113:       RUBY
// 114:     end
// 115:
// 116:     it "reports and corrects an offense when `Utils.popen_write` arguments are unseparated" do
// 117:       expect_offense(<<~RUBY)
// 118:         class Foo < Formula
// 119:           def install
// 120:             Utils.popen_write("foo bar")
// 121:                               ^^^^^^^^^ Homebrew/ShellCommands: Separate `Utils.popen_write` commands into `"foo", "bar"`
// 122:           end
// 123:         end
// 124:       RUBY
// 125:
// 126:       expect_correction(<<~RUBY)
// 127:         class Foo < Formula
// 128:           def install
// 129:             Utils.popen_write("foo", "bar")
// 130:           end
// 131:         end
// 132:       RUBY
// 133:     end
// 134:
// 135:     it "reports and corrects an offense when `Utils.safe_popen_write` arguments are unseparated" do
// 136:       expect_offense(<<~RUBY)
// 137:         class Foo < Formula
// 138:           def install
// 139:             Utils.safe_popen_write("foo bar")
// 140:                                    ^^^^^^^^^ Homebrew/ShellCommands: Separate `Utils.safe_popen_write` commands into `"foo", "bar"`
// 141:           end
// 142:         end
// 143:       RUBY
// 144:
// 145:       expect_correction(<<~RUBY)
// 146:         class Foo < Formula
// 147:           def install
// 148:             Utils.safe_popen_write("foo", "bar")
// 149:           end
// 150:         end
// 151:       RUBY
// 152:     end
// 153:
// 154:     it "reports and corrects an offense when `Utils.popen_read` arguments with interpolation are unseparated" do
// 155:       expect_offense(<<~'RUBY')
// 156:         class Foo < Formula
// 157:           def install
// 158:             Utils.popen_read("#{bin}/foo bar")
// 159:                              ^^^^^^^^^^^^^^^^ Homebrew/ShellCommands: Separate `Utils.popen_read` commands into `"#{bin}/foo", "bar"`
// 160:           end
// 161:         end
// 162:       RUBY
// 163:
// 164:       expect_correction(<<~'RUBY')
// 165:         class Foo < Formula
// 166:           def install
// 167:             Utils.popen_read("#{bin}/foo", "bar")
// 168:           end
// 169:         end
// 170:       RUBY
// 171:     end
// 172:
// 173:     it "reports no offenses when `Utils.popen_read` arguments with metacharacters are unseparated" do
// 174:       expect_no_offenses(<<~RUBY)
// 175:         class Foo < Formula
// 176:           def install
// 177:             Utils.popen_read("foo bar > baz")
// 178:           end
// 179:         end
// 180:       RUBY
// 181:     end
// 182:
// 183:     it "reports no offenses when trailing arguments to `Utils.popen_read` are unseparated" do
// 184:       expect_no_offenses(<<~RUBY)
// 185:         class Foo < Formula
// 186:           def install
// 187:             Utils.popen_read("foo", "bar baz")
// 188:           end
// 189:         end
// 190:       RUBY
// 191:     end
// 192:
// 193:     it "reports and corrects an offense when `Utils.popen_read` arguments are unseparated after a shell env" do
// 194:       expect_offense(<<~RUBY)
// 195:         class Foo < Formula
// 196:           def install
// 197:             Utils.popen_read({ "SHELL" => "bash"}, "foo bar")
// 198:                                                    ^^^^^^^^^ Homebrew/ShellCommands: Separate `Utils.popen_read` commands into `"foo", "bar"`
// 199:           end
// 200:         end
// 201:       RUBY
// 202:
// 203:       expect_correction(<<~RUBY)
// 204:         class Foo < Formula
// 205:           def install
// 206:             Utils.popen_read({ "SHELL" => "bash"}, "foo", "bar")
// 207:           end
// 208:         end
// 209:       RUBY
// 210:     end
// 211:   end
// 212: end
