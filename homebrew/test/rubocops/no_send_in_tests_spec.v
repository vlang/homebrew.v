module rubocops

import homebrew.rubocops as no_send_core

// Translated from Homebrew/brew `test/rubocops/no_send_in_tests_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn no_send_in_tests_spec_offense(source string, method string, message string) bool {
	offenses := no_send_core.audit_no_send_in_tests(source)
	return offenses.len == 1 && source[offenses[0].begin_pos..offenses[0].end_pos] == method && offenses[0].call.method == method && offenses[0].message == message
}

// Ruby it `it "registers an offense when using `send` with a static method name" do` at line 7.
pub fn ruby_no_send_in_tests_spec_l7_d1_registers() bool {
	return no_send_in_tests_spec_offense('formula.send(:active_spec)', 'send', 'Make the method public and call it directly instead of using `send` in tests.')
}

// Ruby it `it "registers an offense when using `send` without a receiver" do` at line 14.
pub fn ruby_no_send_in_tests_spec_l14_d2_registers() bool {
	return no_send_in_tests_spec_offense('send(:generate_runners!)', 'send', 'Make the method public and call it directly instead of using `send` in tests.')
}

// Ruby it `it "registers an offense when using `__send__`" do` at line 21.
pub fn ruby_no_send_in_tests_spec_l21_d3_registers() bool {
	return no_send_in_tests_spec_offense('formula.__send__(:active_spec)', '__send__', 'Make the method public and call it directly instead of using `__send__` in tests.')
}

// Ruby it `it "registers an offense when using `send` with a safe navigation operator" do` at line 28.
pub fn ruby_no_send_in_tests_spec_l28_d4_registers() bool {
	offenses := no_send_core.audit_no_send_in_tests('formula&.send(:active_spec)')
	return offenses.len == 1 && offenses[0].call.safe_navigation && offenses[0].begin_pos == 'formula&.'.len && offenses[0].end_pos == 'formula&.send'.len && offenses[0].message == 'Make the method public and call it directly instead of using `send` in tests.'
}

// Ruby it `it "registers an offense when using `send` with a dynamic method name" do` at line 35.
pub fn ruby_no_send_in_tests_spec_l35_d5_registers() bool {
	return no_send_in_tests_spec_offense(r'formula.send(:"#{action}_network_access!")', 'send', 'Use `public_send` instead of `send` in tests; `send` bypasses method visibility.')
}

// Ruby it `it "registers an offense when using `public_send` with a static method name" do` at line 42.
pub fn ruby_no_send_in_tests_spec_l42_d6_registers() bool {
	return no_send_in_tests_spec_offense('formula.public_send(:active_spec)', 'public_send', no_send_core.no_send_in_tests_public_send_message)
}

// Ruby it `it "registers an offense when using `public_send` with a static string method name" do` at line 49.
pub fn ruby_no_send_in_tests_spec_l49_d7_registers() bool {
	return no_send_in_tests_spec_offense('formula.public_send("active_spec")', 'public_send', no_send_core.no_send_in_tests_public_send_message)
}

// Ruby it `it "registers an offense when using `public_send` with a static setter method name" do` at line 56.
pub fn ruby_no_send_in_tests_spec_l56_d8_registers() bool {
	return no_send_in_tests_spec_offense('formula.public_send(:name=, "foo")', 'public_send', no_send_core.no_send_in_tests_public_send_message)
}

// Ruby it `it "registers an offense when using `public_send` with a static index method name" do` at line 63.
pub fn ruby_no_send_in_tests_spec_l63_d9_registers() bool {
	return no_send_in_tests_spec_offense('config.public_send(:[], :key)', 'public_send', no_send_core.no_send_in_tests_public_send_message)
}

// Ruby it `it "registers an offense when using `public_send` with a static index setter method name" do` at line 70.
pub fn ruby_no_send_in_tests_spec_l70_d10_registers() bool {
	return no_send_in_tests_spec_offense('config.public_send(:[]=, :key, "value")', 'public_send', no_send_core.no_send_in_tests_public_send_message)
}

// Ruby it `it "registers an offense when using `send` with a static operator method name" do` at line 77.
pub fn ruby_no_send_in_tests_spec_l77_d11_registers() bool {
	return no_send_in_tests_spec_offense('formula.send(:<<, "value")', 'send', 'Make the method public and call it directly instead of using `send` in tests.')
}

// Ruby it `it "does not register an offense when using `public_send` with a dynamic method name" do` at line 84.
pub fn ruby_no_send_in_tests_spec_l84_d12_does() bool {
	return no_send_core.audit_no_send_in_tests(r'subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)').len == 0
}

// Ruby it `it "does not register an offense when using `public_send` with a variable method name" do` at line 90.
pub fn ruby_no_send_in_tests_spec_l90_d13_does() bool {
	return no_send_core.audit_no_send_in_tests('described_class.public_send(method_name, TEST_TMPDIR, safe: false)').len == 0
}

// Ruby it `it "does not register an offense when using `public_send` with a method name that has no call syntax" do` at line 96.
pub fn ruby_no_send_in_tests_spec_l96_d14_does() bool {
	return no_send_core.audit_no_send_in_tests('subject.public_send(:"gcc-9")').len == 0
}

// Ruby it `it "does not register an offense for a direct method call" do` at line 102.
pub fn ruby_no_send_in_tests_spec_l102_d15_does() bool {
	return no_send_core.audit_no_send_in_tests('formula.active_spec').len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/no_send_in_tests"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::NoSendInTests, :config do
// 7:   it "registers an offense when using `send` with a static method name" do
// 8:     expect_offense(<<~RUBY)
// 9:       formula.send(:active_spec)
// 10:               ^^^^ Make the method public and call it directly instead of using `send` in tests.
// 11:     RUBY
// 12:   end
// 13:
// 14:   it "registers an offense when using `send` without a receiver" do
// 15:     expect_offense(<<~RUBY)
// 16:       send(:generate_runners!)
// 17:       ^^^^ Make the method public and call it directly instead of using `send` in tests.
// 18:     RUBY
// 19:   end
// 20:
// 21:   it "registers an offense when using `__send__`" do
// 22:     expect_offense(<<~RUBY)
// 23:       formula.__send__(:active_spec)
// 24:               ^^^^^^^^ Make the method public and call it directly instead of using `__send__` in tests.
// 25:     RUBY
// 26:   end
// 27:
// 28:   it "registers an offense when using `send` with a safe navigation operator" do
// 29:     expect_offense(<<~RUBY)
// 30:       formula&.send(:active_spec)
// 31:                ^^^^ Make the method public and call it directly instead of using `send` in tests.
// 32:     RUBY
// 33:   end
// 34:
// 35:   it "registers an offense when using `send` with a dynamic method name" do
// 36:     expect_offense(<<~'RUBY')
// 37:       formula.send(:"#{action}_network_access!")
// 38:               ^^^^ Use `public_send` instead of `send` in tests; `send` bypasses method visibility.
// 39:     RUBY
// 40:   end
// 41:
// 42:   it "registers an offense when using `public_send` with a static method name" do
// 43:     expect_offense(<<~RUBY)
// 44:       formula.public_send(:active_spec)
// 45:               ^^^^^^^^^^^ Call the method directly instead of using `public_send` with a static method name.
// 46:     RUBY
// 47:   end
// 48:
// 49:   it "registers an offense when using `public_send` with a static string method name" do
// 50:     expect_offense(<<~RUBY)
// 51:       formula.public_send("active_spec")
// 52:               ^^^^^^^^^^^ Call the method directly instead of using `public_send` with a static method name.
// 53:     RUBY
// 54:   end
// 55:
// 56:   it "registers an offense when using `public_send` with a static setter method name" do
// 57:     expect_offense(<<~RUBY)
// 58:       formula.public_send(:name=, "foo")
// 59:               ^^^^^^^^^^^ Call the method directly instead of using `public_send` with a static method name.
// 60:     RUBY
// 61:   end
// 62:
// 63:   it "registers an offense when using `public_send` with a static index method name" do
// 64:     expect_offense(<<~RUBY)
// 65:       config.public_send(:[], :key)
// 66:              ^^^^^^^^^^^ Call the method directly instead of using `public_send` with a static method name.
// 67:     RUBY
// 68:   end
// 69:
// 70:   it "registers an offense when using `public_send` with a static index setter method name" do
// 71:     expect_offense(<<~RUBY)
// 72:       config.public_send(:[]=, :key, "value")
// 73:              ^^^^^^^^^^^ Call the method directly instead of using `public_send` with a static method name.
// 74:     RUBY
// 75:   end
// 76:
// 77:   it "registers an offense when using `send` with a static operator method name" do
// 78:     expect_offense(<<~RUBY)
// 79:       formula.send(:<<, "value")
// 80:               ^^^^ Make the method public and call it directly instead of using `send` in tests.
// 81:     RUBY
// 82:   end
// 83:
// 84:   it "does not register an offense when using `public_send` with a dynamic method name" do
// 85:     expect_no_offenses(<<~'RUBY')
// 86:       subject.public_send(:"#{artifact_dsl_key}_phase", command: fake_system_command)
// 87:     RUBY
// 88:   end
// 89:
// 90:   it "does not register an offense when using `public_send` with a variable method name" do
// 91:     expect_no_offenses(<<~RUBY)
// 92:       described_class.public_send(method_name, TEST_TMPDIR, safe: false)
// 93:     RUBY
// 94:   end
// 95:
// 96:   it "does not register an offense when using `public_send` with a method name that has no call syntax" do
// 97:     expect_no_offenses(<<~RUBY)
// 98:       subject.public_send(:"gcc-9")
// 99:     RUBY
// 100:   end
// 101:
// 102:   it "does not register an offense for a direct method call" do
// 103:     expect_no_offenses(<<~RUBY)
// 104:       formula.active_spec
// 105:     RUBY
// 106:   end
// 107: end
