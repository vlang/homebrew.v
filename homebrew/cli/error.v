module cli

import brew_runtime

// Translated from Homebrew/brew `cli/error.rb`.
// The original source is retained below until every stub has a typed V body.

fn sentence(items []string, connector string) string {
	if items.len == 0 {
		return ''
	}
	if items.len == 1 {
		return items[0]
	}
	if items.len == 2 {
		return '${items[0]} ${connector} ${items[1]}'
	}
	return '${items[..items.len - 1].join(', ')}, ${connector} ${items.last()}'
}

fn argument_types(types []string) string {
	mut actual_types := types.clone()
	if actual_types.len == 0 {
		actual_types << 'named'
	}
	return sentence(actual_types.map(it.replace('_', ' ')), 'or')
}

fn plural_argument(count int) string {
	return if count == 1 { 'argument' } else { 'arguments' }
}

pub fn option_constraint_error(arg1 string, arg2 string, missing bool) IError {
	if missing {
		return error('`${arg2}` cannot be passed without `${arg1}`.')
	}
	return error('`${arg1}` and `${arg2}` should be passed together.')
}

pub fn option_conflict_error(options []string) IError {
	formatted := options.map('`${it}`')
	return error('Options ${sentence(formatted, 'and')} are mutually exclusive.')
}

pub fn invalid_constraint_error(arg1 string, arg2 string) IError {
	return error('`${arg1}` and `${arg2}` cannot be mutually exclusive and mutually dependent simultaneously.')
}

pub fn max_named_arguments_error(maximum int, types []string) IError {
	if maximum == 0 {
		return error('This command does not take named arguments.')
	}
	return error('This command does not take more than ${maximum} ${argument_types(types)} ${plural_argument(maximum)}.')
}

pub fn min_named_arguments_error(minimum int, types []string) IError {
	return error('This command requires at least ${minimum} ${argument_types(types)} ${plural_argument(minimum)}.')
}

pub fn number_of_named_arguments_error(number int, types []string) IError {
	return error('This command requires exactly ${number} ${argument_types(types)} ${plural_argument(number)}.')
}

fn cli_error_value(type_name string, value IError) brew_runtime.Value {
	return brew_runtime.structured_value(type_name, value.msg(), {
		'message': value.msg()
	})
}

fn cli_error_types(args []brew_runtime.Value, index int) []string {
	return if args.len > index {
		args[index].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
}

// Ruby method `initialize(arg1, arg2, missing: false)` at line 10.
pub fn ruby_error_l10_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	arg1 := if args.len > 0 { args[0].as_string() } else { '' }
	arg2 := if args.len > 1 { args[1].as_string() } else { '' }
	missing := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	return cli_error_value('Homebrew::CLI::OptionConstraintError', option_constraint_error(arg1, arg2, missing))
}

// Ruby method `initialize(args)` at line 22.
pub fn ruby_error_l22_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	options := if args.len > 0 { args[0].as_string_array() or { []string{} } } else { []string{} }
	return cli_error_value('Homebrew::CLI::OptionConflictError', option_conflict_error(options))
}

// Ruby method `initialize(arg1, arg2)` at line 30.
pub fn ruby_error_l30_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	arg1 := if args.len > 0 { args[0].as_string() } else { '' }
	arg2 := if args.len > 1 { args[1].as_string() } else { '' }
	return cli_error_value('Homebrew::CLI::InvalidConstraintError', invalid_constraint_error(arg1, arg2))
}

// Ruby method `initialize(maximum, types: [])` at line 37.
pub fn ruby_error_l37_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	maximum := if args.len > 0 { int(args[0].as_int() or { 0 }) } else { 0 }
	return cli_error_value('Homebrew::CLI::MaxNamedArgumentsError', max_named_arguments_error(maximum, cli_error_types(args, 1)))
}

// Ruby method `initialize(minimum, types: [])` at line 53.
pub fn ruby_error_l53_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	minimum := if args.len > 0 { int(args[0].as_int() or { 0 }) } else { 0 }
	return cli_error_value('Homebrew::CLI::MinNamedArgumentsError', min_named_arguments_error(minimum, cli_error_types(args, 1)))
}

// Ruby method `initialize(minimum, types: [])` at line 64.
pub fn ruby_error_l64_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	number := if args.len > 0 { int(args[0].as_int() or { 0 }) } else { 0 }
	return cli_error_value('Homebrew::CLI::NumberOfNamedArgumentsError', number_of_named_arguments_error(number, cli_error_types(args, 1)))
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
