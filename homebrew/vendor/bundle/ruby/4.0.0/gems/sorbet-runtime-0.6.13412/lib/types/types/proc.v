module types

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/proc.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct ProcType {
pub:
	arg_types    map[string]ruby.Value
	returns_type ruby.Value
}

pub fn new_proc_type(arg_types map[string]ruby.Value, returns_type ruby.Value) &ProcType {
	return &ProcType{
		arg_types: arg_types.clone()
		returns_type: returns_type
	}
}

fn proc_type_name(value ruby.Value) string {
	return value.attribute('name') or { value.as_string() }
}

fn proc_type_subtype(left ruby.Value, right ruby.Value) bool {
	left_name := proc_type_name(left)
	right_name := proc_type_name(right)
	if left_name == right_name || right_name in ['T.anything', 'T.untyped'] {
		return true
	}
	supertypes := left.attribute('supertypes') or { return false }
	return supertypes.split(',').map(it.trim_space()).any(it == right_name)
}

pub fn (_ &ProcType) build_type() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn (proc_type &ProcType) name() string {
	mut args := []string{}
	for key, value in proc_type.arg_types {
		args << '${key}: ${proc_type_name(value)}'
	}
	return 'T.proc.params(${args.join(', ')}).returns(${proc_type_name(proc_type.returns_type)})'
}

pub fn (_ &ProcType) valid(value ruby.Value) bool {
	return value.type_name == 'Proc'
}

pub fn (proc_type &ProcType) subtype_of_single(other &ProcType) bool {
	if proc_type.arg_types.len != other.arg_types.len {
		return false
	}
	left_values := proc_type.arg_types.values()
	right_values := other.arg_types.values()
	for index, left in left_values {
		// Proc parameters are contravariant.
		if !proc_type_subtype(right_values[index], left) {
			return false
		}
	}
	// Proc return values are covariant.
	return proc_type_subtype(proc_type.returns_type, other.returns_type)
}

fn proc_type_value(proc_type &ProcType) ruby.Value {
	return ruby.Value{
		type_name: 'T::Types::Proc'
		repr: proc_type.name()
		map_data: {
			'arg_types': ruby.map_value(proc_type.arg_types)
			'returns':   proc_type.returns_type
		}
		attributes: {
			'proc_type_address': u64(voidptr(proc_type)).str()
		}
	}
}

fn proc_type_from_args(args []ruby.Value) &ProcType {
	if args.len == 0 {
		panic('Proc type method requires a receiver')
	}
	address := args[0].attribute('proc_type_address') or { panic('invalid Proc type receiver') }
	return unsafe { &ProcType(voidptr(address.u64())) }
}

// Ruby method `initialize(arg_types, returns)` at line 11.
pub fn ruby_proc_l11_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Proc#initialize requires argument and return types')
	}
	return proc_type_value(new_proc_type(args[0].as_map() or { panic(err.msg()) }, args[1]))
}

// Ruby method `arg_types` at line 16.
pub fn ruby_proc_l16_d2_arg_types(args ...ruby.Value) ruby.Value {
	return ruby.map_value(proc_type_from_args(args).arg_types)
}

// Ruby method `returns` at line 22.
pub fn ruby_proc_l22_d3_returns(args ...ruby.Value) ruby.Value {
	return proc_type_from_args(args).returns_type
}

// Ruby method `build_type` at line 26.
pub fn ruby_proc_l26_d4_build_type(args ...ruby.Value) ruby.Value {
	return proc_type_from_args(args).build_type()
}

// Ruby method `name` at line 33.
pub fn ruby_proc_l33_d5_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(proc_type_from_args(args).name())
}

// Ruby method `valid?(obj)` at line 42.
pub fn ruby_proc_l42_d6_valid(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Proc#valid? requires an object')
	}
	return ruby.bool_value(proc_type_from_args(args).valid(args[1]))
}

// Ruby method `subtype_of_single?(other)` at line 47.
pub fn ruby_proc_l47_d7_subtype_of_single(args ...ruby.Value) ruby.Value {
	if args.len < 2 || args[1].type_name != 'T::Types::Proc' {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(proc_type_from_args(args).subtype_of_single(proc_type_from_args(args[1..])))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # Defines the type of a proc (a ruby callable). At runtime, only
// 6:   # validates that the value is a `::Proc`.
// 7:   #
// 8:   # At present, we only support fixed-arity procs with no optional or
// 9:   # keyword arguments.
// 10:   class Proc < Base
// 11:     def initialize(arg_types, returns)
// 12:       @inner_arg_types = arg_types
// 13:       @inner_returns = returns
// 14:     end
// 15:
// 16:     def arg_types
// 17:       @arg_types ||= @inner_arg_types.transform_values do |raw_type|
// 18:         T::Utils.coerce(raw_type)
// 19:       end
// 20:     end
// 21:
// 22:     def returns
// 23:       @returns ||= T::Utils.coerce(@inner_returns)
// 24:     end
// 25:
// 26:     def build_type
// 27:       arg_types
// 28:       returns
// 29:       nil
// 30:     end
// 31:
// 32:     # overrides Base
// 33:     def name
// 34:       args = []
// 35:       arg_types.each do |k, v|
// 36:         args << "#{k}: #{v.name}"
// 37:       end
// 38:       "T.proc.params(#{args.join(', ')}).returns(#{returns})"
// 39:     end
// 40:
// 41:     # overrides Base
// 42:     def valid?(obj)
// 43:       obj.is_a?(::Proc)
// 44:     end
// 45:
// 46:     # overrides Base
// 47:     private def subtype_of_single?(other)
// 48:       case other
// 49:       when self.class
// 50:         if arg_types.size != other.arg_types.size
// 51:           return false
// 52:         end
// 53:         arg_types.values.zip(other.arg_types.values).all? do |a, b|
// 54:           !b.nil? && b.subtype_of?(a)
// 55:         end && returns.subtype_of?(other.returns)
// 56:       else
// 57:         false
// 58:       end
// 59:     end
// 60:   end
// 61: end
