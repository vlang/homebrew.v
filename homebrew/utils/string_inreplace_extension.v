module utils

import brew_runtime

// Translated from Homebrew/brew `utils/string_inreplace_extension.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :errors` at line 11.
pub fn ruby_string_inreplace_extension_l11_d1_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby attr_accessor `attr_accessor :errors` at line 11.
pub fn ruby_string_inreplace_extension_l11_d2_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors=', ...args)
}

// Ruby attr_accessor `attr_accessor :inreplace_string` at line 14.
pub fn ruby_string_inreplace_extension_l14_d3_inreplace_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inreplace_string', ...args)
}

// Ruby attr_accessor `attr_accessor :inreplace_string` at line 14.
pub fn ruby_string_inreplace_extension_l14_d4_inreplace_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inreplace_string=', ...args)
}

// Ruby method `initialize(string)` at line 17.
pub fn ruby_string_inreplace_extension_l17_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `sub!(before, after, audit_result: true)` at line 26.
pub fn ruby_string_inreplace_extension_l26_d6_sub(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sub!', ...args)
}

// Ruby method `gsub!(before, after, audit_result: true)` at line 42.
pub fn ruby_string_inreplace_extension_l42_d7_gsub(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gsub!', ...args)
}

// Ruby method `change_make_var!(flag, new_value)` at line 54.
pub fn ruby_string_inreplace_extension_l54_d8_change_make_var(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('change_make_var!', ...args)
}

// Ruby method `remove_make_var!(flags)` at line 66.
pub fn ruby_string_inreplace_extension_l66_d9_remove_make_var(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('remove_make_var!', ...args)
}

// Ruby method `get_make_var(flag)` at line 81.
pub fn ruby_string_inreplace_extension_l81_d10_get_make_var(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get_make_var', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strong
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: # Used by the {Utils::Inreplace.inreplace} function.
// 7: class StringInreplaceExtension
// 8:   include Utils::Output::Mixin
// 9:
// 10:   sig { returns(T::Array[String]) }
// 11:   attr_accessor :errors
// 12:
// 13:   sig { returns(String) }
// 14:   attr_accessor :inreplace_string
// 15:
// 16:   sig { params(string: String).void }
// 17:   def initialize(string)
// 18:     @inreplace_string = string
// 19:     @errors = T.let([], T::Array[String])
// 20:   end
// 21:
// 22:   # Same as `String#sub!`, but warns if nothing was replaced.
// 23:   #
// 24:   # @api public
// 25:   sig { params(before: T.any(Regexp, String), after: String, audit_result: T::Boolean).returns(T.nilable(String)) }
// 26:   def sub!(before, after, audit_result: true)
// 27:     result = inreplace_string.sub!(before, after)
// 28:     errors << "expected replacement of #{before.inspect} with #{after.inspect}" if audit_result && result.nil?
// 29:     result
// 30:   end
// 31:
// 32:   # Same as `String#gsub!`, but warns if nothing was replaced.
// 33:   #
// 34:   # @api public
// 35:   sig {
// 36:     params(
// 37:       before:       T.any(Pathname, Regexp, String),
// 38:       after:        T.any(Pathname, String),
// 39:       audit_result: T::Boolean,
// 40:     ).returns(T.nilable(String))
// 41:   }
// 42:   def gsub!(before, after, audit_result: true)
// 43:     before = before.to_s if before.is_a?(Pathname)
// 44:     result = inreplace_string.gsub!(before, after.to_s)
// 45:     errors << "expected replacement of #{before.inspect} with #{after.inspect}" if audit_result && result.nil?
// 46:     result
// 47:   end
// 48:
// 49:   # Looks for Makefile style variable definitions and replaces the
// 50:   # value with "new_value", or removes the definition entirely.
// 51:   #
// 52:   # @api public
// 53:   sig { params(flag: String, new_value: T.any(String, Pathname)).void }
// 54:   def change_make_var!(flag, new_value)
// 55:     return if gsub!(/^#{Regexp.escape(flag)}[ \t]*[\\?+:!]?=[ \t]*((?:.*\\\n)*.*)$/,
// 56:                     "#{flag}=#{new_value}",
// 57:                     audit_result: false)
// 58:
// 59:     errors << "expected to change #{flag.inspect} to #{new_value.inspect}"
// 60:   end
// 61:
// 62:   # Removes variable assignments completely.
// 63:   #
// 64:   # @api public
// 65:   sig { params(flags: T.any(String, T::Array[String])).void }
// 66:   def remove_make_var!(flags)
// 67:     Array(flags).each do |flag|
// 68:       # Also remove trailing \n, if present.
// 69:       next if gsub!(/^#{Regexp.escape(flag)}[ \t]*[\\?+:!]?=(?:.*\\\n)*.*$\n?/,
// 70:                     "",
// 71:                     audit_result: false)
// 72:
// 73:       errors << "expected to remove #{flag.inspect}"
// 74:     end
// 75:   end
// 76:
// 77:   # Finds the specified variable, or raises an `ArgumentError` if it is not present.
// 78:   #
// 79:   # @api public
// 80:   sig { params(flag: String).returns(String) }
// 81:   def get_make_var(flag)
// 82:     inreplace_string[/^#{Regexp.escape(flag)}[ \t]*[\\?+:!]?=[ \t]*((?:.*\\\n)*.*)$/, 1] ||
// 83:       raise(ArgumentError, "expected to find make variable #{flag.inspect}")
// 84:   end
// 85: end
