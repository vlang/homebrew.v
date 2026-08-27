module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/proc.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(arg_types, returns)` at line 11.
pub fn ruby_proc_l11_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `arg_types` at line 16.
pub fn ruby_proc_l16_d2_arg_types(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arg_types', ...args)
}

// Ruby method `returns` at line 22.
pub fn ruby_proc_l22_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby method `build_type` at line 26.
pub fn ruby_proc_l26_d4_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_type', ...args)
}

// Ruby method `name` at line 33.
pub fn ruby_proc_l33_d5_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `valid?(obj)` at line 42.
pub fn ruby_proc_l42_d6_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `subtype_of_single?(other)` at line 47.
pub fn ruby_proc_l47_d7_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subtype_of_single?', ...args)
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
