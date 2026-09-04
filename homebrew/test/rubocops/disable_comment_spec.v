module rubocops

import ruby
import homebrew.rubocops as disable_comment_core

// Translated from Homebrew/brew `test/rubocops/disable_comment_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "registers an offense and corrects" do` at line 8.
pub fn ruby_disable_comment_spec_l8_d1_registers(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	correction := if args.len > 1 { args[1].as_string() } else { '' }
	message := if args.len > 2 { args[2].as_string() } else { '' }
	offenses := disable_comment_core.audit_disable_comments(source)
	return ruby.bool_value(offenses.len == 1 && offenses[0].message == message && correction == source)
}

// Ruby it `it "registers an offense" do` at line 20.
pub fn ruby_disable_comment_spec_l20_d2_registers(args ...ruby.Value) ruby.Value {
	source := 'def something; end\n# rubocop:disable Naming/AccessorMethodName\ndef get_decrypted_io; end\n'
	offenses := disable_comment_core.audit_disable_comments(source)
	return ruby.bool_value(offenses.len == 1 && offenses[0].comment.text == '# rubocop:disable Naming/AccessorMethodName' && offenses[0].message == disable_comment_core.disable_comment_message)
}

// Ruby method `something; end` at line 22.
pub fn ruby_disable_comment_spec_l22_d3_something(args ...ruby.Value) ruby.Value {
	return ruby.string_value('def something; end')
}

// Ruby method `get_decrypted_io; end` at line 25.
pub fn ruby_disable_comment_spec_l25_d4_get_decrypted_io(args ...ruby.Value) ruby.Value {
	return ruby.string_value('def get_decrypted_io; end')
}

// Ruby it `it "registers an offense if the comment is empty" do` at line 29.
pub fn ruby_disable_comment_spec_l29_d5_registers(args ...ruby.Value) ruby.Value {
	source := 'def something; end\n#\n# rubocop:disable Naming/AccessorMethodName\ndef get_decrypted_io; end\n'
	offenses := disable_comment_core.audit_disable_comments(source)
	return ruby.bool_value(offenses.len == 1 && offenses[0].comment.line == 3 && offenses[0].message == disable_comment_core.disable_comment_message)
}

// Ruby method `something; end` at line 31.
pub fn ruby_disable_comment_spec_l31_d6_something(args ...ruby.Value) ruby.Value {
	return ruby_disable_comment_spec_l22_d3_something(...args)
}

// Ruby method `get_decrypted_io; end` at line 35.
pub fn ruby_disable_comment_spec_l35_d7_get_decrypted_io(args ...ruby.Value) ruby.Value {
	return ruby_disable_comment_spec_l25_d4_get_decrypted_io(...args)
}

// Ruby it `it "doesn't register an offense" do` at line 39.
pub fn ruby_disable_comment_spec_l39_d8_doesn(args ...ruby.Value) ruby.Value {
	source := 'def something; end\n# This is a upstream name that we cannot change.\n# rubocop:disable Naming/AccessorMethodName\ndef get_decrypted_io; end\n'
	return ruby.bool_value(disable_comment_core.audit_disable_comments(source).len == 0)
}

// Ruby method `something; end` at line 41.
pub fn ruby_disable_comment_spec_l41_d9_something(args ...ruby.Value) ruby.Value {
	return ruby_disable_comment_spec_l22_d3_something(...args)
}

// Ruby method `get_decrypted_io; end` at line 44.
pub fn ruby_disable_comment_spec_l44_d10_get_decrypted_io(args ...ruby.Value) ruby.Value {
	return ruby_disable_comment_spec_l25_d4_get_decrypted_io(...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/disable_comment"
// 5:
// 6: RSpec.describe RuboCop::Cop::DisableComment, :config do
// 7:   shared_examples "offense" do |source, correction, message|
// 8:     it "registers an offense and corrects" do
// 9:       expect_offense(<<~RUBY, source:, message:)
// 10:         #{source}
// 11:         ^{source} #{message}
// 12:       RUBY
// 13:
// 14:       expect_correction(<<~RUBY)
// 15:         #{correction}
// 16:       RUBY
// 17:     end
// 18:   end
// 19:
// 20:   it "registers an offense" do
// 21:     expect_offense(<<~RUBY)
// 22:       def something; end
// 23:       # rubocop:disable Naming/AccessorMethodName
// 24:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add a clarifying comment to the RuboCop disable comment
// 25:       def get_decrypted_io; end
// 26:     RUBY
// 27:   end
// 28:
// 29:   it "registers an offense if the comment is empty" do
// 30:     expect_offense(<<~RUBY)
// 31:       def something; end
// 32:       #
// 33:       # rubocop:disable Naming/AccessorMethodName
// 34:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add a clarifying comment to the RuboCop disable comment
// 35:       def get_decrypted_io; end
// 36:     RUBY
// 37:   end
// 38:
// 39:   it "doesn't register an offense" do
// 40:     expect_no_offenses(<<~RUBY)
// 41:       def something; end
// 42:       # This is a upstream name that we cannot change.
// 43:       # rubocop:disable Naming/AccessorMethodName
// 44:       def get_decrypted_io; end
// 45:     RUBY
// 46:   end
// 47: end
