module rubocops

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/compact_blank_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "registers and corrects an offense when using `reject { |e| e.blank? }`" do` at line 7.
pub fn ruby_compact_blank_spec_l7_d1_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "registers and corrects an offense when using `reject(&:blank?)`" do` at line 18.
pub fn ruby_compact_blank_spec_l18_d2_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "registers and corrects an offense when using `delete_if { |e| e.blank? }`" do` at line 29.
pub fn ruby_compact_blank_spec_l29_d3_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "registers and corrects an offense when using `delete_if(&:blank?)`" do` at line 40.
pub fn ruby_compact_blank_spec_l40_d4_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "registers and corrects an offense when using `reject! { |e| e.blank? }`" do` at line 51.
pub fn ruby_compact_blank_spec_l51_d5_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "registers and corrects an offense when using `reject!(&:blank?)`" do` at line 62.
pub fn ruby_compact_blank_spec_l62_d6_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "registers and corrects an offense when using `reject(&:blank?)` in block" do` at line 73.
pub fn ruby_compact_blank_spec_l73_d7_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby it `it "does not register an offense when using `compact_blank`" do` at line 84.
pub fn ruby_compact_blank_spec_l84_d8_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not register an offense when using `compact_blank!`" do` at line 90.
pub fn ruby_compact_blank_spec_l90_d9_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not register an offense when using `reject { |k, v| k.blank? }`" do` at line 96.
pub fn ruby_compact_blank_spec_l96_d10_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not register an offense when using the receiver of `blank?` is not a block variable" do` at line 102.
pub fn ruby_compact_blank_spec_l102_d11_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby method `foo(arg)` at line 104.
pub fn ruby_compact_blank_spec_l104_d12_foo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('foo', ...args)
}

// Ruby it `it "does not register an offense when using `reject { |e| e.empty? }`" do` at line 110.
pub fn ruby_compact_blank_spec_l110_d13_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/compact_blank"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::CompactBlank, :config do
// 7:   it "registers and corrects an offense when using `reject { |e| e.blank? }`" do
// 8:     expect_offense(<<~RUBY)
// 9:       collection.reject { |e| e.blank? }
// 10:                  ^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
// 11:     RUBY
// 12:
// 13:     expect_correction(<<~RUBY)
// 14:       collection.compact_blank
// 15:     RUBY
// 16:   end
// 17:
// 18:   it "registers and corrects an offense when using `reject(&:blank?)`" do
// 19:     expect_offense(<<~RUBY)
// 20:       collection.reject(&:blank?)
// 21:                  ^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
// 22:     RUBY
// 23:
// 24:     expect_correction(<<~RUBY)
// 25:       collection.compact_blank
// 26:     RUBY
// 27:   end
// 28:
// 29:   it "registers and corrects an offense when using `delete_if { |e| e.blank? }`" do
// 30:     expect_offense(<<~RUBY)
// 31:       collection.delete_if { |e| e.blank? }
// 32:                  ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank!` instead.
// 33:     RUBY
// 34:
// 35:     expect_correction(<<~RUBY)
// 36:       collection.compact_blank!
// 37:     RUBY
// 38:   end
// 39:
// 40:   it "registers and corrects an offense when using `delete_if(&:blank?)`" do
// 41:     expect_offense(<<~RUBY)
// 42:       collection.delete_if(&:blank?)
// 43:                  ^^^^^^^^^^^^^^^^^^^ Use `compact_blank!` instead.
// 44:     RUBY
// 45:
// 46:     expect_correction(<<~RUBY)
// 47:       collection.compact_blank!
// 48:     RUBY
// 49:   end
// 50:
// 51:   it "registers and corrects an offense when using `reject! { |e| e.blank? }`" do
// 52:     expect_offense(<<~RUBY)
// 53:       collection.reject! { |e| e.blank? }
// 54:                  ^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact_blank!` instead.
// 55:     RUBY
// 56:
// 57:     expect_correction(<<~RUBY)
// 58:       collection.compact_blank!
// 59:     RUBY
// 60:   end
// 61:
// 62:   it "registers and corrects an offense when using `reject!(&:blank?)`" do
// 63:     expect_offense(<<~RUBY)
// 64:       collection.reject!(&:blank?)
// 65:                  ^^^^^^^^^^^^^^^^^ Use `compact_blank!` instead.
// 66:     RUBY
// 67:
// 68:     expect_correction(<<~RUBY)
// 69:       collection.compact_blank!
// 70:     RUBY
// 71:   end
// 72:
// 73:   it "registers and corrects an offense when using `reject(&:blank?)` in block" do
// 74:     expect_offense(<<~RUBY)
// 75:       hash.transform_values { |value| value.reject(&:blank?) }
// 76:                                             ^^^^^^^^^^^^^^^^ Use `compact_blank` instead.
// 77:     RUBY
// 78:
// 79:     expect_correction(<<~RUBY)
// 80:       hash.transform_values { |value| value.compact_blank }
// 81:     RUBY
// 82:   end
// 83:
// 84:   it "does not register an offense when using `compact_blank`" do
// 85:     expect_no_offenses(<<~RUBY)
// 86:       collection.compact_blank
// 87:     RUBY
// 88:   end
// 89:
// 90:   it "does not register an offense when using `compact_blank!`" do
// 91:     expect_no_offenses(<<~RUBY)
// 92:       collection.compact_blank!
// 93:     RUBY
// 94:   end
// 95:
// 96:   it "does not register an offense when using `reject { |k, v| k.blank? }`" do
// 97:     expect_no_offenses(<<~RUBY)
// 98:       collection.reject { |k, v| k.blank? }
// 99:     RUBY
// 100:   end
// 101:
// 102:   it "does not register an offense when using the receiver of `blank?` is not a block variable" do
// 103:     expect_no_offenses(<<~RUBY)
// 104:       def foo(arg)
// 105:         collection.reject { |_| arg.blank? }
// 106:       end
// 107:     RUBY
// 108:   end
// 109:
// 110:   it "does not register an offense when using `reject { |e| e.empty? }`" do
// 111:     expect_no_offenses(<<~RUBY)
// 112:       collection.reject { |e| e.empty? }
// 113:     RUBY
// 114:   end
// 115: end
