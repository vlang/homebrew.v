module rubocops

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/io_read_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_io_read_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports an offense when `IO.read` is used with a pipe character" do` at line 9.
pub fn ruby_io_read_spec_l9_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "does not report an offense when `IO.read` is used without a pipe character" do` at line 16.
pub fn ruby_io_read_spec_l16_d3_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "reports an offense when `IO.read` is used with untrustworthy input" do` at line 22.
pub fn ruby_io_read_spec_l22_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when `IO.read` is used with a dynamic string starting with a pipe character" do` at line 30.
pub fn ruby_io_read_spec_l30_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when `IO.read` is used with a dynamic string at the start" do` at line 38.
pub fn ruby_io_read_spec_l38_d6_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "does not report an offense when `IO.read` is used with a dynamic string safely" do` at line 46.
pub fn ruby_io_read_spec_l46_d7_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "reports an offense when `IO.read` is used with a concatenated string starting with a pipe character" do` at line 53.
pub fn ruby_io_read_spec_l53_d8_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports an offense when `IO.read` is used with a concatenated string starting with untrustworthy input" do` at line 61.
pub fn ruby_io_read_spec_l61_d9_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "does not report an offense when `IO.read` is used with a concatenated string safely" do` at line 69.
pub fn ruby_io_read_spec_l69_d10_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/io_read"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::IORead do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   it "reports an offense when `IO.read` is used with a pipe character" do
// 10:     expect_offense(<<~RUBY)
// 11:       IO.read("|echo test")
// 12:       ^^^^^^^^^^^^^^^^^^^^^ Homebrew/IORead: The use of `IO.read` is a security risk.
// 13:     RUBY
// 14:   end
// 15:
// 16:   it "does not report an offense when `IO.read` is used without a pipe character" do
// 17:     expect_no_offenses(<<~RUBY)
// 18:       IO.read("file.txt")
// 19:     RUBY
// 20:   end
// 21:
// 22:   it "reports an offense when `IO.read` is used with untrustworthy input" do
// 23:     expect_offense(<<~RUBY)
// 24:       input = "input value from an unknown source"
// 25:       IO.read(input)
// 26:       ^^^^^^^^^^^^^^ Homebrew/IORead: The use of `IO.read` is a security risk.
// 27:     RUBY
// 28:   end
// 29:
// 30:   it "reports an offense when `IO.read` is used with a dynamic string starting with a pipe character" do
// 31:     expect_offense(<<~'RUBY')
// 32:       input = "test"
// 33:       IO.read("|echo #{input}")
// 34:       ^^^^^^^^^^^^^^^^^^^^^^^^^ Homebrew/IORead: The use of `IO.read` is a security risk.
// 35:     RUBY
// 36:   end
// 37:
// 38:   it "reports an offense when `IO.read` is used with a dynamic string at the start" do
// 39:     expect_offense(<<~'RUBY')
// 40:       input = "|echo test"
// 41:       IO.read("#{input}.txt")
// 42:       ^^^^^^^^^^^^^^^^^^^^^^^ Homebrew/IORead: The use of `IO.read` is a security risk.
// 43:     RUBY
// 44:   end
// 45:
// 46:   it "does not report an offense when `IO.read` is used with a dynamic string safely" do
// 47:     expect_no_offenses(<<~'RUBY')
// 48:       input = "test"
// 49:       IO.read("somefile#{input}.txt")
// 50:     RUBY
// 51:   end
// 52:
// 53:   it "reports an offense when `IO.read` is used with a concatenated string starting with a pipe character" do
// 54:     expect_offense(<<~RUBY)
// 55:       input = "|echo test"
// 56:       IO.read("|echo " + input)
// 57:       ^^^^^^^^^^^^^^^^^^^^^^^^^ Homebrew/IORead: The use of `IO.read` is a security risk.
// 58:     RUBY
// 59:   end
// 60:
// 61:   it "reports an offense when `IO.read` is used with a concatenated string starting with untrustworthy input" do
// 62:     expect_offense(<<~RUBY)
// 63:       input = "|echo test"
// 64:       IO.read(input + ".txt")
// 65:       ^^^^^^^^^^^^^^^^^^^^^^^ Homebrew/IORead: The use of `IO.read` is a security risk.
// 66:     RUBY
// 67:   end
// 68:
// 69:   it "does not report an offense when `IO.read` is used with a concatenated string safely" do
// 70:     expect_no_offenses(<<~RUBY)
// 71:       input = "test"
// 72:       IO.read("somefile" + input + ".txt")
// 73:     RUBY
// 74:   end
// 75: end
