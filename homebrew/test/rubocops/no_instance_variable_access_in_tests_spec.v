module rubocops

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/no_instance_variable_access_in_tests_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "registers an offense when using `instance_variable_get`" do` at line 7.
pub fn ruby_no_instance_variable_access_in_tests_spec_l7_d1_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby attr_reader `^^^^^^^^^^^^^^^^^^^^^ Use a public `attr_reader`/`attr_writer` (or an existing accessor) instead of `instance_variable_get` in tests.` at line 10.
pub fn ruby_no_instance_variable_access_in_tests_spec_l10_d2_attr_reader_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attr_reader_dynamic', ...args)
}

// Ruby it `it "registers an offense when using `instance_variable_set`" do` at line 14.
pub fn ruby_no_instance_variable_access_in_tests_spec_l14_d3_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby attr_reader `^^^^^^^^^^^^^^^^^^^^^ Use a public `attr_reader`/`attr_writer` (or an existing accessor) instead of `instance_variable_set` in tests.` at line 17.
pub fn ruby_no_instance_variable_access_in_tests_spec_l17_d4_attr_reader_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attr_reader_dynamic', ...args)
}

// Ruby it `it "registers an offense when using `instance_variable_set` without a receiver" do` at line 21.
pub fn ruby_no_instance_variable_access_in_tests_spec_l21_d5_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby attr_reader `^^^^^^^^^^^^^^^^^^^^^ Use a public `attr_reader`/`attr_writer` (or an existing accessor) instead of `instance_variable_set` in tests.` at line 24.
pub fn ruby_no_instance_variable_access_in_tests_spec_l24_d6_attr_reader_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attr_reader_dynamic', ...args)
}

// Ruby it `it "registers an offense when using `instance_variable_get` with a dynamic name" do` at line 28.
pub fn ruby_no_instance_variable_access_in_tests_spec_l28_d7_registers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('registers', ...args)
}

// Ruby attr_reader `^^^^^^^^^^^^^^^^^^^^^ Use a public `attr_reader`/`attr_writer` (or an existing accessor) instead of `instance_variable_get` in tests.` at line 31.
pub fn ruby_no_instance_variable_access_in_tests_spec_l31_d8_attr_reader_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attr_reader_dynamic', ...args)
}

// Ruby it `it "does not register an offense when using `instance_variable_defined?`" do` at line 35.
pub fn ruby_no_instance_variable_access_in_tests_spec_l35_d9_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not register an offense for direct accessor calls" do` at line 41.
pub fn ruby_no_instance_variable_access_in_tests_spec_l41_d10_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/no_instance_variable_access_in_tests"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::NoInstanceVariableAccessInTests, :config do
// 7:   it "registers an offense when using `instance_variable_get`" do
// 8:     expect_offense(<<~RUBY)
// 9:       formula.instance_variable_get(:@tap)
// 10:               ^^^^^^^^^^^^^^^^^^^^^ Use a public `attr_reader`/`attr_writer` (or an existing accessor) instead of `instance_variable_get` in tests.
// 11:     RUBY
// 12:   end
// 13:
// 14:   it "registers an offense when using `instance_variable_set`" do
// 15:     expect_offense(<<~RUBY)
// 16:       formula.instance_variable_set(:@tap, CoreTap.instance)
// 17:               ^^^^^^^^^^^^^^^^^^^^^ Use a public `attr_reader`/`attr_writer` (or an existing accessor) instead of `instance_variable_set` in tests.
// 18:     RUBY
// 19:   end
// 20:
// 21:   it "registers an offense when using `instance_variable_set` without a receiver" do
// 22:     expect_offense(<<~RUBY)
// 23:       instance_variable_set(:@staged_path, tmp_staged)
// 24:       ^^^^^^^^^^^^^^^^^^^^^ Use a public `attr_reader`/`attr_writer` (or an existing accessor) instead of `instance_variable_set` in tests.
// 25:     RUBY
// 26:   end
// 27:
// 28:   it "registers an offense when using `instance_variable_get` with a dynamic name" do
// 29:     expect_offense(<<~RUBY)
// 30:       pathname.instance_variable_get(ivar)
// 31:                ^^^^^^^^^^^^^^^^^^^^^ Use a public `attr_reader`/`attr_writer` (or an existing accessor) instead of `instance_variable_get` in tests.
// 32:     RUBY
// 33:   end
// 34:
// 35:   it "does not register an offense when using `instance_variable_defined?`" do
// 36:     expect_no_offenses(<<~RUBY)
// 37:       described_class.instance_variable_defined?(:@version)
// 38:     RUBY
// 39:   end
// 40:
// 41:   it "does not register an offense for direct accessor calls" do
// 42:     expect_no_offenses(<<~RUBY)
// 43:       formula.tap = CoreTap.instance
// 44:     RUBY
// 45:   end
// 46: end
