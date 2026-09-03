module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/type_variable.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct TypeVariable {
pub:
	variance string
}

pub fn new_type_variable(variance string) !&TypeVariable {
	normalized := variance.trim_string_left(':')
	if normalized !in ['in', 'out', 'invariant'] {
		return error('invalid variance ${variance}')
	}
	return &TypeVariable{
		variance: normalized
	}
}

pub fn (_ &TypeVariable) build_type() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn (_ &TypeVariable) valid(_ brew_runtime.Value) bool {
	return true
}

pub fn (_ &TypeVariable) subtype_of_single(_ brew_runtime.Value) bool {
	return true
}

pub fn (_ &TypeVariable) name() string {
	return 'T.untyped'
}

fn type_variable_value(variable &TypeVariable) brew_runtime.Value {
	return brew_runtime.structured_value('T::Types::TypeVariable', variable.name(), {
		'type_variable_address': u64(voidptr(variable)).str()
		'variance':              variable.variance
	})
}

fn type_variable_from_args(args []brew_runtime.Value) &TypeVariable {
	if args.len == 0 {
		panic('TypeVariable method requires a receiver')
	}
	address := args[0].attribute('type_variable_address') or { panic('invalid TypeVariable receiver') }
	return unsafe { &TypeVariable(voidptr(address.u64())) }
}

// Ruby attr_reader `attr_reader :variance` at line 8.
pub fn ruby_type_variable_l8_d1_variance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', ':${type_variable_from_args(args).variance}')
}

// Ruby method `initialize(variance)` at line 12.
pub fn ruby_type_variable_l12_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('TypeVariable#initialize requires a variance')
	}
	if args[0].type_name == 'Hash' {
		panic('Pass bounds using a block. Got: ${args[0].as_string()}')
	}
	return type_variable_value(new_type_variable(args[0].as_string()) or { panic(err) })
}

// Ruby method `build_type` at line 22.
pub fn ruby_type_variable_l22_d3_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return type_variable_from_args(args).build_type()
}

// Ruby method `valid?(obj)` at line 26.
pub fn ruby_type_variable_l26_d4_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(true)
}

// Ruby method `subtype_of_single?(type)` at line 30.
pub fn ruby_type_variable_l30_d5_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(true)
}

// Ruby method `name` at line 34.
pub fn ruby_type_variable_l34_d6_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(type_variable_from_args(args).name())
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # Since we do type erasure at runtime, this just validates the variance and
// 6:   # provides some syntax for the static type checker
// 7:   class TypeVariable < Base
// 8:     attr_reader :variance
// 9:
// 10:     VALID_VARIANCES = %i[in out invariant].freeze
// 11:
// 12:     def initialize(variance)
// 13:       case variance
// 14:       when Hash then raise ArgumentError.new("Pass bounds using a block. Got: #{variance}")
// 15:       when *VALID_VARIANCES then nil
// 16:       else
// 17:         raise TypeError.new("invalid variance #{variance}")
// 18:       end
// 19:       @variance = variance
// 20:     end
// 21:
// 22:     def build_type
// 23:       nil
// 24:     end
// 25:
// 26:     def valid?(obj)
// 27:       true
// 28:     end
// 29:
// 30:     def subtype_of_single?(type)
// 31:       true
// 32:     end
// 33:
// 34:     def name
// 35:       Untyped.new.name
// 36:     end
// 37:   end
// 38: end
