module homebrew

import brew_runtime

// Translated from Homebrew/brew `warnings.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `warn(message, category: nil)` at line 8.
pub fn ruby_warnings_l8_d1_warn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warn', ...args)
}

// Ruby method `self.ignore(*warnings, &_block)` at line 28.
pub fn ruby_warnings_l28_d2_self_ignore(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ignore', ...args)
}

// Ruby method `self.ignored?(message)` at line 43.
pub fn ruby_warnings_l43_d3_self_ignored(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ignored?', ...args)
}

// Ruby method `self.ignored_warnings` at line 48.
pub fn ruby_warnings_l48_d4_self_ignored_warnings(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ignored_warnings', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Helper module for handling warnings.
// 5: module Warnings
// 6:   module Filter
// 7:     sig { params(message: String, category: T.nilable(Symbol)).void }
// 8:     def warn(message, category: nil)
// 9:       return if Warnings.ignored?(message)
// 10:
// 11:       super
// 12:     end
// 13:   end
// 14:
// 15:   COMMON_WARNINGS = T.let({
// 16:     parser_syntax: [
// 17:       %r{warning: parser/current is loading parser/ruby\d+, which recognizes},
// 18:       /warning: \d+\.\d+\.\d+-compliant syntax, but you are running \d+\.\d+\.\d+\./,
// 19:       %r{warning: please see https://github\.com/whitequark/parser#compatibility-with-ruby-mri\.},
// 20:     ],
// 21:   }.freeze, T::Hash[Symbol, T::Array[Regexp]])
// 22:   private_constant :COMMON_WARNINGS
// 23:
// 24:   IGNORED_WARNINGS_KEY = :homebrew_ignored_warnings
// 25:   private_constant :IGNORED_WARNINGS_KEY
// 26:
// 27:   sig { params(warnings: T.any(Symbol, Regexp), _block: T.proc.void).void }
// 28:   def self.ignore(*warnings, &_block)
// 29:     warnings = warnings.flat_map do |warning|
// 30:       warning.is_a?(Symbol) ? COMMON_WARNINGS.fetch(warning) : warning
// 31:     end
// 32:
// 33:     previous_warnings = ignored_warnings
// 34:     Thread.current.thread_variable_set(IGNORED_WARNINGS_KEY, previous_warnings + warnings)
// 35:     begin
// 36:       yield
// 37:     ensure
// 38:       Thread.current.thread_variable_set(IGNORED_WARNINGS_KEY, previous_warnings)
// 39:     end
// 40:   end
// 41:
// 42:   sig { params(message: String).returns(T::Boolean) }
// 43:   def self.ignored?(message)
// 44:     ignored_warnings.any? { |warning| warning.match?(message) }
// 45:   end
// 46:
// 47:   sig { returns(T::Array[Regexp]) }
// 48:   def self.ignored_warnings
// 49:     Thread.current.thread_variable_get(IGNORED_WARNINGS_KEY) || []
// 50:   end
// 51:   private_class_method :ignored_warnings
// 52:
// 53:   Warning.singleton_class.prepend(Filter)
// 54:   private_constant :Filter
// 55: end
