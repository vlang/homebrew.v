module rubocops

import ruby
import homebrew.rubocops as move_to_extend_os_core

// Translated from Homebrew/brew `test/rubocops/move_to_extend_os_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_move_to_extend_os_spec_l7_d1_cop(args ...ruby.Value) ruby.Value {
	return ruby.object_value('RuboCop::Cop::Homebrew::MoveToExtendOS', 'Homebrew/MoveToExtendOS')
}

// Ruby it `it "registers an offense when using `OS.linux?`" do` at line 9.
pub fn ruby_move_to_extend_os_spec_l9_d2_registers() bool {
	offenses := move_to_extend_os_core.audit_move_to_extend_os('OS.linux?', 'example.rb')
	return offenses.len == 1 && offenses[0].begin_pos == 0 && offenses[0].end_pos == 9 && offenses[0].message == move_to_extend_os_core.move_to_extend_os_non_extend_message
}

// Ruby it `it "registers an offense when using `OS.mac?`" do` at line 16.
pub fn ruby_move_to_extend_os_spec_l16_d3_registers() bool {
	offenses := move_to_extend_os_core.audit_move_to_extend_os('OS.mac?', 'example.rb')
	return offenses.len == 1 && offenses[0].begin_pos == 0 && offenses[0].end_pos == 7 && offenses[0].message == move_to_extend_os_core.move_to_extend_os_non_extend_message
}

// Ruby it `it "allows `OS.linux?` in requirements" do` at line 23.
pub fn ruby_move_to_extend_os_spec_l23_d4_allows() bool {
	return move_to_extend_os_core.audit_move_to_extend_os('OS.linux?', 'Library/Homebrew/requirements/linux_requirement.rb').len == 0
}

// Ruby it `it "allows `OS.mac?` in tests" do` at line 29.
pub fn ruby_move_to_extend_os_spec_l29_d5_allows() bool {
	return move_to_extend_os_core.audit_move_to_extend_os('OS.mac?', 'Library/Homebrew/test/example_spec.rb').len == 0
}

// Ruby it `it "allows OS checks in the OS loader" do` at line 35.
pub fn ruby_move_to_extend_os_spec_l35_d6_allows() bool {
	return move_to_extend_os_core.audit_move_to_extend_os('OS.mac?', 'Library/Homebrew/os.rb').len == 0
}

// Ruby it `it "registers an offense when using `OS.linux?`" do` at line 42.
pub fn ruby_move_to_extend_os_spec_l42_d7_registers() bool {
	offenses := move_to_extend_os_core.audit_move_to_extend_os('OS.linux?', 'Library/Homebrew/extend/os/mac/foo.rb')
	return offenses.len == 1 && offenses[0].message == "Don't use `OS.linux?` in `extend/os/mac`, it is always `false`."
}

// Ruby it `it "registers an offense when using `OS.mac?`" do` at line 49.
pub fn ruby_move_to_extend_os_spec_l49_d8_registers() bool {
	offenses := move_to_extend_os_core.audit_move_to_extend_os('OS.mac?', 'Library/Homebrew/extend/os/mac/foo.rb')
	return offenses.len == 1 && offenses[0].message == "Don't use `OS.mac?` in `extend/os/mac`, it is always `true`."
}

// Ruby it `it "registers an offense when using `OS.mac?`" do` at line 58.
pub fn ruby_move_to_extend_os_spec_l58_d9_registers() bool {
	offenses := move_to_extend_os_core.audit_move_to_extend_os('OS.mac?', 'Library/Homebrew/extend/os/linux/foo.rb')
	return offenses.len == 1 && offenses[0].message == "Don't use `OS.mac?` in `extend/os/linux`, it is always `false`."
}

// Ruby it `it "registers an offense when using `OS.linux?`" do` at line 65.
pub fn ruby_move_to_extend_os_spec_l65_d10_registers() bool {
	offenses := move_to_extend_os_core.audit_move_to_extend_os('OS.linux?', 'Library/Homebrew/extend/os/linux/foo.rb')
	return offenses.len == 1 && offenses[0].message == "Don't use `OS.linux?` in `extend/os/linux`, it is always `true`."
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/move_to_extend_os"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::MoveToExtendOS do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "registers an offense when using `OS.linux?`" do
// 10:     expect_offense(<<~RUBY)
// 11:       OS.linux?
// 12:       ^^^^^^^^^ Homebrew/MoveToExtendOS: Move `OS.linux?` and `OS.mac?` calls to `extend/os`.
// 13:     RUBY
// 14:   end
// 15:
// 16:   it "registers an offense when using `OS.mac?`" do
// 17:     expect_offense(<<~RUBY)
// 18:       OS.mac?
// 19:       ^^^^^^^ Homebrew/MoveToExtendOS: Move `OS.linux?` and `OS.mac?` calls to `extend/os`.
// 20:     RUBY
// 21:   end
// 22:
// 23:   it "allows `OS.linux?` in requirements" do
// 24:     expect_no_offenses(<<~RUBY, "Library/Homebrew/requirements/linux_requirement.rb")
// 25:       OS.linux?
// 26:     RUBY
// 27:   end
// 28:
// 29:   it "allows `OS.mac?` in tests" do
// 30:     expect_no_offenses(<<~RUBY, "Library/Homebrew/test/example_spec.rb")
// 31:       OS.mac?
// 32:     RUBY
// 33:   end
// 34:
// 35:   it "allows OS checks in the OS loader" do
// 36:     expect_no_offenses(<<~RUBY, "Library/Homebrew/os.rb")
// 37:       OS.mac?
// 38:     RUBY
// 39:   end
// 40:
// 41:   context "when in extend/os/mac" do
// 42:     it "registers an offense when using `OS.linux?`" do
// 43:       expect_offense(<<~RUBY, "Library/Homebrew/extend/os/mac/foo.rb")
// 44:         OS.linux?
// 45:         ^^^^^^^^^ Homebrew/MoveToExtendOS: Don't use `OS.linux?` in `extend/os/mac`, it is always `false`.
// 46:       RUBY
// 47:     end
// 48:
// 49:     it "registers an offense when using `OS.mac?`" do
// 50:       expect_offense(<<~RUBY, "Library/Homebrew/extend/os/mac/foo.rb")
// 51:         OS.mac?
// 52:         ^^^^^^^ Homebrew/MoveToExtendOS: Don't use `OS.mac?` in `extend/os/mac`, it is always `true`.
// 53:       RUBY
// 54:     end
// 55:   end
// 56:
// 57:   context "when in extend/os/linux" do
// 58:     it "registers an offense when using `OS.mac?`" do
// 59:       expect_offense(<<~RUBY, "Library/Homebrew/extend/os/linux/foo.rb")
// 60:         OS.mac?
// 61:         ^^^^^^^ Homebrew/MoveToExtendOS: Don't use `OS.mac?` in `extend/os/linux`, it is always `false`.
// 62:       RUBY
// 63:     end
// 64:
// 65:     it "registers an offense when using `OS.linux?`" do
// 66:       expect_offense(<<~RUBY, "Library/Homebrew/extend/os/linux/foo.rb")
// 67:         OS.linux?
// 68:         ^^^^^^^^^ Homebrew/MoveToExtendOS: Don't use `OS.linux?` in `extend/os/linux`, it is always `true`.
// 69:       RUBY
// 70:     end
// 71:   end
// 72: end
