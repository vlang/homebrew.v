module standalone

import ruby

// Translated from Homebrew/brew `standalone/sorbet.rb`.
// The original source is retained below until every stub has a typed V body.
pub type RecursiveValidator = fn(ruby.Value) bool

fn recursively_valid(value ruby.Value, validator RecursiveValidator) bool {
	return validator(value)
}

fn no_checks_value(value ruby.Value, _type ruby.Value, _checked bool) ruby.Value {
	return value
}

// Ruby method `valid?(obj) = recursively_valid?(obj)` at line 17.
pub fn ruby_sorbet_l17_d1_valid(obj ruby.Value, validator RecursiveValidator) bool {
	return recursively_valid(obj, validator)
}

// Ruby method `valid?(obj) = recursively_valid?(obj)` at line 21.
pub fn ruby_sorbet_l21_d2_valid(obj ruby.Value, validator RecursiveValidator) bool {
	return recursively_valid(obj, validator)
}

// Ruby method `valid?(obj) = recursively_valid?(obj)` at line 25.
pub fn ruby_sorbet_l25_d3_valid(obj ruby.Value, validator RecursiveValidator) bool {
	return recursively_valid(obj, validator)
}

// Ruby method `valid?(obj) = recursively_valid?(obj)` at line 29.
pub fn ruby_sorbet_l29_d4_valid(obj ruby.Value, validator RecursiveValidator) bool {
	return recursively_valid(obj, validator)
}

// Ruby method `valid?(obj) = recursively_valid?(obj)` at line 33.
pub fn ruby_sorbet_l33_d5_valid(obj ruby.Value, validator RecursiveValidator) bool {
	return recursively_valid(obj, validator)
}

// Ruby method `valid?(obj) = recursively_valid?(obj)` at line 37.
pub fn ruby_sorbet_l37_d6_valid(obj ruby.Value, validator RecursiveValidator) bool {
	return recursively_valid(obj, validator)
}

// Ruby method `valid?(obj) = recursively_valid?(obj)` at line 41.
pub fn ruby_sorbet_l41_d7_valid(obj ruby.Value, validator RecursiveValidator) bool {
	return recursively_valid(obj, validator)
}

// Ruby method `valid?(obj) = recursively_valid?(obj)` at line 45.
pub fn ruby_sorbet_l45_d8_valid(obj ruby.Value, validator RecursiveValidator) bool {
	return recursively_valid(obj, validator)
}

// Ruby method `valid?(obj) = recursively_valid?(obj)` at line 49.
pub fn ruby_sorbet_l49_d9_valid(obj ruby.Value, validator RecursiveValidator) bool {
	return recursively_valid(obj, validator)
}

// Ruby method `valid?(obj) = recursively_valid?(obj)` at line 53.
pub fn ruby_sorbet_l53_d10_valid(obj ruby.Value, validator RecursiveValidator) bool {
	return recursively_valid(obj, validator)
}

// Ruby method `valid?(obj) = recursively_valid?(obj)` at line 57.
pub fn ruby_sorbet_l57_d11_valid(obj ruby.Value, validator RecursiveValidator) bool {
	return recursively_valid(obj, validator)
}

// Ruby method `cast(value, _type, checked: false)` at line 69.
pub fn ruby_sorbet_l69_d12_cast(value ruby.Value, type_value ruby.Value,
	checked bool) ruby.Value {
	return no_checks_value(value, type_value, checked)
}

// Ruby method `let(value, _type, checked: false)` at line 73.
pub fn ruby_sorbet_l73_d13_let(value ruby.Value, type_value ruby.Value,
	checked bool) ruby.Value {
	return no_checks_value(value, type_value, checked)
}

// Ruby method `bind(value, _type, checked: false)` at line 77.
pub fn ruby_sorbet_l77_d14_bind(value ruby.Value, type_value ruby.Value,
	checked bool) ruby.Value {
	return no_checks_value(value, type_value, checked)
}

// Ruby method `assert_type!(value, _type, checked: false)` at line 81.
pub fn ruby_sorbet_l81_d15_assert_type(value ruby.Value, type_value ruby.Value,
	checked bool) ruby.Value {
	return no_checks_value(value, type_value, checked)
}

// Ruby method `sig(arg0 = nil, &blk); end` at line 94.
pub fn ruby_sorbet_l94_d16_sig(_arg0 ?ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "sorbet-runtime"
// 5: require "extend/module"
// 6:
// 7: # Disable runtime checking unless enabled.
// 8: # In the future we should consider not doing this monkey patch,
// 9: # if assured that there is no performance hit from removing this.
// 10: # There are mechanisms to achieve a middle ground (`default_checked_level`).
// 11: if ENV["HOMEBREW_SORBET_RUNTIME"]
// 12:   T::Configuration.enable_final_checks_on_hooks
// 13:   if ENV["HOMEBREW_SORBET_RECURSIVE"] == "1"
// 14:     module T
// 15:       module Types
// 16:         class FixedArray < Base
// 17:           def valid?(obj) = recursively_valid?(obj)
// 18:         end
// 19:
// 20:         class FixedHash < Base
// 21:           def valid?(obj) = recursively_valid?(obj)
// 22:         end
// 23:
// 24:         class Intersection < Base
// 25:           def valid?(obj) = recursively_valid?(obj)
// 26:         end
// 27:
// 28:         class TypedArray < TypedEnumerable
// 29:           def valid?(obj) = recursively_valid?(obj)
// 30:         end
// 31:
// 32:         class TypedEnumerable < Base
// 33:           def valid?(obj) = recursively_valid?(obj)
// 34:         end
// 35:
// 36:         class TypedEnumeratorChain < TypedEnumerable
// 37:           def valid?(obj) = recursively_valid?(obj)
// 38:         end
// 39:
// 40:         class TypedEnumeratorLazy < TypedEnumerable
// 41:           def valid?(obj) = recursively_valid?(obj)
// 42:         end
// 43:
// 44:         class TypedHash < TypedEnumerable
// 45:           def valid?(obj) = recursively_valid?(obj)
// 46:         end
// 47:
// 48:         class TypedRange < TypedEnumerable
// 49:           def valid?(obj) = recursively_valid?(obj)
// 50:         end
// 51:
// 52:         class TypedSet < TypedEnumerable
// 53:           def valid?(obj) = recursively_valid?(obj)
// 54:         end
// 55:
// 56:         class Union < Base
// 57:           def valid?(obj) = recursively_valid?(obj)
// 58:         end
// 59:       end
// 60:     end
// 61:   end
// 62: else
// 63:   # Redefine `T.let`, etc. to return the value without dispatching to
// 64:   # sorbet-runtime at all: these methods are called often enough (e.g. for
// 65:   # every `Pathname` allocation) that even the disabled-check dispatch is
// 66:   # measurable.
// 67:   # @private
// 68:   module TNoChecks
// 69:     def cast(value, _type, checked: false)
// 70:       value
// 71:     end
// 72:
// 73:     def let(value, _type, checked: false)
// 74:       value
// 75:     end
// 76:
// 77:     def bind(value, _type, checked: false)
// 78:       value
// 79:     end
// 80:
// 81:     def assert_type!(value, _type, checked: false)
// 82:       value
// 83:     end
// 84:   end
// 85:
// 86:   # @private
// 87:   module T
// 88:     class << self
// 89:       prepend TNoChecks
// 90:     end
// 91:
// 92:     # Redefine `T.sig` to be a no-op.
// 93:     module Sig
// 94:       def sig(arg0 = nil, &blk); end
// 95:     end
// 96:   end
// 97:
// 98:   # For any cases the above doesn't handle: make sure we don't let TypeError slip through.
// 99:   T::Configuration.call_validation_error_handler = ->(signature, opts) {}
// 100:   T::Configuration.inline_type_error_handler = ->(error, opts) {}
// 101: end
