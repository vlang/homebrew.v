module cli

import brew_runtime

// Translated from Homebrew/brew `cli/error.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(arg1, arg2, missing: false)` at line 10.
pub fn ruby_error_l10_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(args)` at line 22.
pub fn ruby_error_l22_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(arg1, arg2)` at line 30.
pub fn ruby_error_l30_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(maximum, types: [])` at line 37.
pub fn ruby_error_l37_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(minimum, types: [])` at line 53.
pub fn ruby_error_l53_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(minimum, types: [])` at line 64.
pub fn ruby_error_l64_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/formatter"
// 5:
// 6: module Homebrew
// 7:   module CLI
// 8:     class OptionConstraintError < UsageError
// 9:       sig { params(arg1: String, arg2: String, missing: T::Boolean).void }
// 10:       def initialize(arg1, arg2, missing: false)
// 11:         message = if missing
// 12:           "`#{arg2}` cannot be passed without `#{arg1}`."
// 13:         else
// 14:           "`#{arg1}` and `#{arg2}` should be passed together."
// 15:         end
// 16:         super message
// 17:       end
// 18:     end
// 19:
// 20:     class OptionConflictError < UsageError
// 21:       sig { params(args: T::Array[String]).void }
// 22:       def initialize(args)
// 23:         args_list = args.map { Formatter.option(it) }.join(" and ")
// 24:         super "Options #{args_list} are mutually exclusive."
// 25:       end
// 26:     end
// 27:
// 28:     class InvalidConstraintError < UsageError
// 29:       sig { params(arg1: String, arg2: String).void }
// 30:       def initialize(arg1, arg2)
// 31:         super "`#{arg1}` and `#{arg2}` cannot be mutually exclusive and mutually dependent simultaneously."
// 32:       end
// 33:     end
// 34:
// 35:     class MaxNamedArgumentsError < UsageError
// 36:       sig { params(maximum: Integer, types: T::Array[Symbol]).void }
// 37:       def initialize(maximum, types: [])
// 38:         super case maximum
// 39:         when 0
// 40:           "This command does not take named arguments."
// 41:         else
// 42:           types << :named if types.empty?
// 43:           arg_types = types.map { |type| type.to_s.tr("_", " ") }
// 44:                            .to_sentence two_words_connector: " or ", last_word_connector: " or "
// 45:
// 46:           "This command does not take more than #{maximum} #{arg_types} #{Utils.pluralize("argument", maximum)}."
// 47:         end
// 48:       end
// 49:     end
// 50:
// 51:     class MinNamedArgumentsError < UsageError
// 52:       sig { params(minimum: Integer, types: T::Array[Symbol]).void }
// 53:       def initialize(minimum, types: [])
// 54:         types << :named if types.empty?
// 55:         arg_types = types.map { |type| type.to_s.tr("_", " ") }
// 56:                          .to_sentence two_words_connector: " or ", last_word_connector: " or "
// 57:
// 58:         super "This command requires at least #{minimum} #{arg_types} #{Utils.pluralize("argument", minimum)}."
// 59:       end
// 60:     end
// 61:
// 62:     class NumberOfNamedArgumentsError < UsageError
// 63:       sig { params(minimum: Integer, types: T::Array[Symbol]).void }
// 64:       def initialize(minimum, types: [])
// 65:         types << :named if types.empty?
// 66:         arg_types = types.map { |type| type.to_s.tr("_", " ") }
// 67:                          .to_sentence two_words_connector: " or ", last_word_connector: " or "
// 68:
// 69:         super "This command requires exactly #{minimum} #{arg_types} #{Utils.pluralize("argument", minimum)}."
// 70:       end
// 71:     end
// 72:   end
// 73: end
