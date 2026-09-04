module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/types/type_alias.rb`.
// The original source is retained below until every stub has a typed V body.
pub type TypeAliasCallable = fn() ruby.Value

@[heap]
pub struct TypeAlias {
	callable TypeAliasCallable @[required]
pub:
	default_checked_level string = 'always'
	check_tests           bool
mut:
	checked_level   ?string
	aliased_cache   ?ruby.Value
	effective_cache ?ruby.Value
}

pub fn new_type_alias(callable TypeAliasCallable) &TypeAlias {
	return new_type_alias_with_runtime(callable, 'always', false)
}

pub fn new_type_alias_with_runtime(callable TypeAliasCallable, default_checked_level string,
	check_tests bool) &TypeAlias {
	return &TypeAlias{
		callable: callable
		default_checked_level: default_checked_level
		check_tests: check_tests
	}
}

pub fn new_type_alias_from_value(value ruby.Value) &TypeAlias {
	return new_type_alias(fn [value] () ruby.Value {
		return value
	})
}

pub fn (mut alias TypeAlias) checked(level string) ! {
	if _ := alias.checked_level {
		return error("You can't call .checked multiple times on a type alias.")
	}
	clean_level := level.trim_string_left(':')
	if clean_level !in ['always', 'tests', 'never'] {
		return error("Invalid `checked` level '${clean_level}'. Use one of: ['always', 'tests', 'never'].")
	}
	alias.checked_level = clean_level
}

pub fn (_ &TypeAlias) build_type() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn (mut alias TypeAlias) aliased_type() ruby.Value {
	if cached := alias.aliased_cache {
		return cached
	}
	value := alias.callable()
	alias.aliased_cache = value
	return value
}

pub fn (mut alias TypeAlias) effective_aliased_type() ruby.Value {
	if cached := alias.effective_cache {
		return cached
	}
	real_type := alias.aliased_type()
	level := alias.checked_level or { alias.default_checked_level }
	value := if level == 'always' || (level == 'tests' && alias.check_tests) {
		real_type
	} else {
		ruby.object_value('T::Types::Anything', 'T.anything')
	}
	alias.effective_cache = value
	return value
}

pub fn (mut alias TypeAlias) name() string {
	return alias.aliased_type().attribute('name') or { alias.aliased_type().as_string() }
}

fn alias_value_valid(type_value ruby.Value, object ruby.Value) bool {
	if type_value.type_name in ['T::Types::Anything', 'T::Types::Untyped'] {
		return true
	}
	if type_value.type_name == 'T::Types::Union' {
		return type_value.array_data.any(alias_value_valid(it, object))
	}
	expected := type_value.attribute('raw_type') or { type_value.as_string() }
	if object.type_name == expected {
		return true
	}
	ancestors := object.attribute('ancestors') or { return false }
	return ancestors.split(',').map(it.trim_space()).any(it == expected)
}

pub fn (mut alias TypeAlias) recursively_valid(object ruby.Value) bool {
	return alias_value_valid(alias.effective_aliased_type(), object)
}

pub fn (mut alias TypeAlias) valid(object ruby.Value) bool {
	return alias_value_valid(alias.effective_aliased_type(), object)
}

fn type_alias_value(alias &TypeAlias) ruby.Value {
	return ruby.structured_value('T::Private::Types::TypeAlias', '<type alias>', {
		'type_alias_address': u64(voidptr(alias)).str()
	})
}

fn type_alias_from_args(args []ruby.Value) &TypeAlias {
	if args.len == 0 {
		panic('TypeAlias method requires a receiver')
	}
	address := args[0].attribute('type_alias_address') or { panic('invalid TypeAlias receiver') }
	return unsafe { &TypeAlias(voidptr(address.u64())) }
}

// Ruby method `initialize(callable)` at line 8.
pub fn ruby_type_alias_l8_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('TypeAlias#initialize requires a callable result')
	}
	return type_alias_value(new_type_alias_from_value(args[0]))
}

// Ruby method `checked(level)` at line 13.
pub fn ruby_type_alias_l13_d2_checked(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TypeAlias#checked requires a level')
	}
	mut alias := type_alias_from_args(args)
	alias.checked(args[1].as_string()) or { panic(err) }
	return args[0]
}

// Ruby method `build_type` at line 24.
pub fn ruby_type_alias_l24_d3_build_type(args ...ruby.Value) ruby.Value {
	return type_alias_from_args(args).build_type()
}

// Ruby method `aliased_type` at line 28.
pub fn ruby_type_alias_l28_d4_aliased_type(args ...ruby.Value) ruby.Value {
	mut alias := type_alias_from_args(args)
	return alias.aliased_type()
}

// Ruby method `effective_aliased_type` at line 32.
pub fn ruby_type_alias_l32_d5_effective_aliased_type(args ...ruby.Value) ruby.Value {
	mut alias := type_alias_from_args(args)
	return alias.effective_aliased_type()
}

// Ruby method `name` at line 45.
pub fn ruby_type_alias_l45_d6_name(args ...ruby.Value) ruby.Value {
	mut alias := type_alias_from_args(args)
	return ruby.string_value(alias.name())
}

// Ruby method `recursively_valid?(obj)` at line 50.
pub fn ruby_type_alias_l50_d7_recursively_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TypeAlias#recursively_valid? requires an object')
	}
	mut alias := type_alias_from_args(args)
	return ruby.bool_value(alias.recursively_valid(args[1]))
}

// Ruby method `valid?(obj)` at line 55.
pub fn ruby_type_alias_l55_d8_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('TypeAlias#valid? requires an object')
	}
	mut alias := type_alias_from_args(args)
	return ruby.bool_value(alias.valid(args[1]))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Types
// 5:   # Wraps a proc for a type alias to defer its evaluation.
// 6:   class TypeAlias < T::Types::Base
// 7:
// 8:     def initialize(callable)
// 9:       @callable = callable
// 10:       @checked_level = nil
// 11:     end
// 12:
// 13:     def checked(level)
// 14:       if !@checked_level.nil?
// 15:         raise "You can't call .checked multiple times on a type alias."
// 16:       end
// 17:       if !T::Private::RuntimeLevels::LEVELS.include?(level)
// 18:         raise ArgumentError.new("Invalid `checked` level '#{level}'. Use one of: #{T::Private::RuntimeLevels::LEVELS}.")
// 19:       end
// 20:       @checked_level = level
// 21:       self
// 22:     end
// 23:
// 24:     def build_type
// 25:       nil
// 26:     end
// 27:
// 28:     def aliased_type
// 29:       @aliased_type ||= T::Utils.coerce(@callable.call)
// 30:     end
// 31:
// 32:     def effective_aliased_type
// 33:       @effective_aliased_type ||= begin
// 34:         real_type = aliased_type
// 35:         level = @checked_level.nil? ? T::Private::RuntimeLevels.default_checked_level : @checked_level
// 36:         if level == :always || (level == :tests && T::Private::RuntimeLevels.check_tests?)
// 37:           real_type
// 38:         else
// 39:           T::Types::Anything::Private::INSTANCE
// 40:         end
// 41:       end
// 42:     end
// 43:
// 44:     # overrides Base
// 45:     def name
// 46:       aliased_type.name
// 47:     end
// 48:
// 49:     # overrides Base
// 50:     def recursively_valid?(obj)
// 51:       effective_aliased_type.recursively_valid?(obj)
// 52:     end
// 53:
// 54:     # overrides Base
// 55:     def valid?(obj)
// 56:       effective_aliased_type.valid?(obj)
// 57:     end
// 58:   end
// 59: end
