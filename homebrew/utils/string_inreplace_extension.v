module utils

import brew_runtime
import regex

// Translated from Homebrew/brew `utils/string_inreplace_extension.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :errors` at line 11.
pub fn ruby_string_inreplace_extension_l11_d1_errors(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_array_value([])
	}
	return brew_runtime.string_array_value(string_inreplace_extension_from_value(args[0]).errors)
}

// Ruby attr_accessor `attr_accessor :errors` at line 11.
pub fn ruby_string_inreplace_extension_l11_d2_errors(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return string_inreplace_extension_value(new_string_inreplace_extension(''))
	}
	mut extension := string_inreplace_extension_from_value(args[0])
	if args.len > 1 {
		extension.errors = string_inreplace_value_strings(args[1])
	}
	return string_inreplace_extension_value(extension)
}

// Ruby attr_accessor `attr_accessor :inreplace_string` at line 14.
pub fn ruby_string_inreplace_extension_l14_d3_inreplace_string(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.string_value('')
	}
	return brew_runtime.string_value(string_inreplace_extension_from_value(args[0]).inreplace_string)
}

// Ruby attr_accessor `attr_accessor :inreplace_string` at line 14.
pub fn ruby_string_inreplace_extension_l14_d4_inreplace_string(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return string_inreplace_extension_value(new_string_inreplace_extension(''))
	}
	mut extension := string_inreplace_extension_from_value(args[0])
	if args.len > 1 {
		extension.inreplace_string = args[1].as_string()
	}
	return string_inreplace_extension_value(extension)
}

// Ruby method `initialize(string)` at line 17.
pub fn ruby_string_inreplace_extension_l17_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	contents := if args.len > 0 { args[0].as_string() } else { '' }
	return string_inreplace_extension_value(new_string_inreplace_extension(contents))
}

// Ruby method `sub!(before, after, audit_result: true)` at line 26.
pub fn ruby_string_inreplace_extension_l26_d6_sub(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('ArgumentError', 'before and after are required')
	}
	mut extension := string_inreplace_extension_from_value(args[0])
	audit_result := if args.len > 3 { args[3].as_bool() or { true } } else { true }
	if args[1].type_name == 'Regexp' {
		result := extension.sub_regex(args[1].as_string(), args[2].as_string(), audit_result) or {
			return brew_runtime.object_value('RegexpError', err.msg())
		}
		if result.replaced {
			return string_inreplace_mutation_value(extension, result.value)
		}
		return string_inreplace_mutation_value(extension, none)
	}
	return string_inreplace_mutation_value(extension, extension.sub(args[1].as_string(), args[2].as_string(), audit_result))
}

// Ruby method `gsub!(before, after, audit_result: true)` at line 42.
pub fn ruby_string_inreplace_extension_l42_d7_gsub(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('ArgumentError', 'before and after are required')
	}
	mut extension := string_inreplace_extension_from_value(args[0])
	audit_result := if args.len > 3 { args[3].as_bool() or { true } } else { true }
	if args[1].type_name == 'Regexp' {
		result := extension.gsub_regex(args[1].as_string(), args[2].as_string(), audit_result) or {
			return brew_runtime.object_value('RegexpError', err.msg())
		}
		if result.replaced {
			return string_inreplace_mutation_value(extension, result.value)
		}
		return string_inreplace_mutation_value(extension, none)
	}
	return string_inreplace_mutation_value(extension, extension.gsub(args[1].as_string(), args[2].as_string(), audit_result))
}

// Ruby method `change_make_var!(flag, new_value)` at line 54.
pub fn ruby_string_inreplace_extension_l54_d8_change_make_var(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('ArgumentError', 'flag and new_value are required')
	}
	mut extension := string_inreplace_extension_from_value(args[0])
	extension.change_make_var(args[1].as_string(), args[2].as_string())
	return string_inreplace_extension_value(extension)
}

// Ruby method `remove_make_var!(flags)` at line 66.
pub fn ruby_string_inreplace_extension_l66_d9_remove_make_var(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'flags are required')
	}
	mut extension := string_inreplace_extension_from_value(args[0])
	extension.remove_make_var(string_inreplace_value_strings(args[1]))
	return string_inreplace_extension_value(extension)
}

// Ruby method `get_make_var(flag)` at line 81.
pub fn ruby_string_inreplace_extension_l81_d10_get_make_var(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'flag is required')
	}
	extension := string_inreplace_extension_from_value(args[0])
	value := extension.get_make_var(args[1].as_string()) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	return brew_runtime.string_value(value)
}

// StringInreplaceExtension is the concrete mutable counterpart of the Ruby
// String wrapper. The generic ruby_* functions only serialise this state when a
// translated caller still crosses a Value boundary.
pub struct StringInreplaceExtension {
pub mut:
	inreplace_string string
	errors           []string
}

pub struct StringInreplaceRegexResult {
pub:
	replaced bool
	value    string
}

pub fn new_string_inreplace_extension(contents string) StringInreplaceExtension {
	return StringInreplaceExtension{
		inreplace_string: contents
	}
}

pub fn (mut extension StringInreplaceExtension) sub(before string, after string,
	audit_result bool) ?string {
	index := extension.inreplace_string.index(before) or {
		if audit_result {
			extension.errors << string_inreplace_replacement_error(before, after, false)
		}
		return none
	}
	extension.inreplace_string = extension.inreplace_string[..index] + after + extension.inreplace_string[index + before.len..]
	return extension.inreplace_string
}

pub fn (mut extension StringInreplaceExtension) gsub(before string, after string,
	audit_result bool) ?string {
	if !extension.inreplace_string.contains(before) {
		if audit_result {
			extension.errors << string_inreplace_replacement_error(before, after, false)
		}
		return none
	}
	extension.inreplace_string = extension.inreplace_string.replace(before, after)
	return extension.inreplace_string
}

pub fn (mut extension StringInreplaceExtension) sub_regex(pattern string, after string,
	audit_result bool) !StringInreplaceRegexResult {
	mut expression := regex.regex_opt(pattern)!
	start, end := expression.find(extension.inreplace_string)
	if start < 0 || end < start {
		if audit_result {
			extension.errors << string_inreplace_replacement_error(pattern, after, true)
		}
		return StringInreplaceRegexResult{}
	}
	replacement := string_inreplace_regex_replacement(expression, extension.inreplace_string, after)
	extension.inreplace_string = extension.inreplace_string[..start] + replacement + extension.inreplace_string[end..]
	return StringInreplaceRegexResult{
		replaced: true
		value: extension.inreplace_string
	}
}

pub fn (mut extension StringInreplaceExtension) gsub_regex(pattern string, after string,
	audit_result bool) !StringInreplaceRegexResult {
	mut expression := regex.regex_opt(pattern)!
	start, _ := expression.find(extension.inreplace_string)
	if start < 0 {
		if audit_result {
			extension.errors << string_inreplace_replacement_error(pattern, after, true)
		}
		return StringInreplaceRegexResult{}
	}
	mut v_replacement := after
	for capture in 1 .. 10 {
		v_replacement = v_replacement.replace('\\${capture}', '\\${capture - 1}')
	}
	extension.inreplace_string = expression.replace(extension.inreplace_string, v_replacement)
	return StringInreplaceRegexResult{
		replaced: true
		value: extension.inreplace_string
	}
}

pub fn (mut extension StringInreplaceExtension) change_make_var(flag string,
	new_value string) bool {
	mut buffer := new_inreplace_buffer(extension.inreplace_string)
	buffer.errors = extension.errors.clone()
	result := buffer.change_make_var(flag, new_value)
	extension.inreplace_string = buffer.inreplace_string
	extension.errors = buffer.errors.clone()
	return result
}

pub fn (mut extension StringInreplaceExtension) remove_make_var(flags []string) bool {
	mut buffer := new_inreplace_buffer(extension.inreplace_string)
	buffer.errors = extension.errors.clone()
	result := buffer.remove_make_var(flags)
	extension.inreplace_string = buffer.inreplace_string
	extension.errors = buffer.errors.clone()
	return result
}

pub fn (extension StringInreplaceExtension) get_make_var(flag string) !string {
	mut buffer := new_inreplace_buffer(extension.inreplace_string)
	return buffer.get_make_var(flag)
}

fn string_inreplace_inspect(value string) string {
	return '"${value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')}"'
}

fn string_inreplace_replacement_error(before string, after string, regexp bool) string {
	before_inspect := if regexp { '/${before}/' } else { string_inreplace_inspect(before) }
	return 'expected replacement of ${before_inspect} with ${string_inreplace_inspect(after)}'
}

fn string_inreplace_regex_replacement(expression regex.RE, contents string,
	replacement string) string {
	mut result := replacement
	for capture in 1 .. 10 {
		result = result.replace('\\${capture}', expression.get_group_by_id(contents, capture - 1))
	}
	return result
}

fn string_inreplace_extension_value(extension StringInreplaceExtension) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'StringInreplaceExtension'
		repr: extension.inreplace_string
		map_data: {
			'inreplace_string': brew_runtime.string_value(extension.inreplace_string)
			'errors':           brew_runtime.string_array_value(extension.errors)
		}
	}
}

fn string_inreplace_mutation_value(extension StringInreplaceExtension,
	result ?string) brew_runtime.Value {
	mut value := string_inreplace_extension_value(extension)
	mut values := value.map_data.clone()
	values['result'] = if replacement := result {
		brew_runtime.string_value(replacement)
	} else {
		brew_runtime.object_value('NilClass', '')
	}
	return brew_runtime.Value{
		...value
		map_data: values
	}
}

fn string_inreplace_extension_from_value(value brew_runtime.Value) StringInreplaceExtension {
	contents := if nested := value.map_data['inreplace_string'] {
		nested.as_string()
	} else {
		value.as_string()
	}
	errors := if nested := value.map_data['errors'] {
		string_inreplace_value_strings(nested)
	} else {
		[]string{}
	}
	return StringInreplaceExtension{
		inreplace_string: contents
		errors: errors
	}
}

fn string_inreplace_value_strings(value brew_runtime.Value) []string {
	if value.type_name == 'String' {
		return [value.as_string()]
	}
	if strings := value.as_string_array() {
		if strings.len > 0 {
			return strings
		}
	}
	if values := value.as_array() {
		return values.map(it.as_string())
	}
	return []string{}
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
