module utility

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/utility/native_integer.rb`.
// The original source is retained below until every stub has a typed V body.
pub const native_integer_min = i64(-4_611_686_018_427_387_904)
pub const native_integer_max = i64(4_611_686_018_427_387_903)

pub fn ensure_upper_bound(value i64) !i64 {
	if value > native_integer_max {
		return error('${value} is greater than the maximum value of ${native_integer_max}')
	}
	return value
}

pub fn ensure_lower_bound(value i64) !i64 {
	if value < native_integer_min {
		return error('${value} is less than the maximum value of ${native_integer_min}')
	}
	return value
}

pub fn ensure_integer_value(value ruby.Value) !i64 {
	if value.type_name != 'Integer' {
		return error('${value.as_string()} is not an Integer')
	}
	return value.as_int()
}

pub fn ensure_integer_and_bounds(value ruby.Value) !i64 {
	integer := ensure_integer_value(value)!
	ensure_upper_bound(integer)!
	return ensure_lower_bound(integer)
}

pub fn ensure_positive(value i64) !i64 {
	if value < 0 {
		return error('${value} cannot be negative')
	}
	return value
}

pub fn ensure_positive_and_no_zero(value i64) !i64 {
	if value < 1 {
		return error('${value} cannot be negative or zero')
	}
	return value
}

fn required_integer_arg(args []ruby.Value) i64 {
	if args.len == 0 {
		panic('integer value is required')
	}
	return ensure_integer_value(args[0]) or { panic('ArgumentError: ${err}') }
}

// Ruby method `ensure_upper_bound(value)` at line 10.
pub fn ruby_native_integer_l10_d1_ensure_upper_bound(args ...ruby.Value) ruby.Value {
	return ruby.int_value(ensure_upper_bound(required_integer_arg(args)) or {
		panic('RangeError: ${err}')
	})
}

// Ruby method `ensure_lower_bound(value)` at line 17.
pub fn ruby_native_integer_l17_d2_ensure_lower_bound(args ...ruby.Value) ruby.Value {
	return ruby.int_value(ensure_lower_bound(required_integer_arg(args)) or {
		panic('RangeError: ${err}')
	})
}

// Ruby method `ensure_integer(value)` at line 24.
pub fn ruby_native_integer_l24_d3_ensure_integer(args ...ruby.Value) ruby.Value {
	return ruby.int_value(required_integer_arg(args))
}

// Ruby method `ensure_integer_and_bounds(value)` at line 31.
pub fn ruby_native_integer_l31_d4_ensure_integer_and_bounds(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('integer value is required')
	}
	return ruby.int_value(ensure_integer_and_bounds(args[0]) or { panic(err) })
}

// Ruby method `ensure_positive(value)` at line 37.
pub fn ruby_native_integer_l37_d5_ensure_positive(args ...ruby.Value) ruby.Value {
	return ruby.int_value(ensure_positive(required_integer_arg(args)) or {
		panic('ArgumentError: ${err}')
	})
}

// Ruby method `ensure_positive_and_no_zero(value)` at line 44.
pub fn ruby_native_integer_l44_d6_ensure_positive_and_no_zero(args ...ruby.Value) ruby.Value {
	return ruby.int_value(ensure_positive_and_no_zero(required_integer_arg(args)) or {
		panic('ArgumentError: ${err}')
	})
}

// Original Ruby source (line-for-line):
// 1: module Concurrent
// 2:   # @!visibility private
// 3:   module Utility
// 4:     # @private
// 5:     module NativeInteger
// 6:       # http://stackoverflow.com/questions/535721/ruby-max-integer
// 7:       MIN_VALUE = -(2**(0.size * 8 - 2))
// 8:       MAX_VALUE = (2**(0.size * 8 - 2) - 1)
// 9:
// 10:       def ensure_upper_bound(value)
// 11:         if value > MAX_VALUE
// 12:           raise RangeError.new("#{value} is greater than the maximum value of #{MAX_VALUE}")
// 13:         end
// 14:         value
// 15:       end
// 16:
// 17:       def ensure_lower_bound(value)
// 18:         if value < MIN_VALUE
// 19:           raise RangeError.new("#{value} is less than the maximum value of #{MIN_VALUE}")
// 20:         end
// 21:         value
// 22:       end
// 23:
// 24:       def ensure_integer(value)
// 25:         unless value.is_a?(Integer)
// 26:           raise ArgumentError.new("#{value} is not an Integer")
// 27:         end
// 28:         value
// 29:       end
// 30:
// 31:       def ensure_integer_and_bounds(value)
// 32:         ensure_integer value
// 33:         ensure_upper_bound value
// 34:         ensure_lower_bound value
// 35:       end
// 36:
// 37:       def ensure_positive(value)
// 38:         if value < 0
// 39:           raise ArgumentError.new("#{value} cannot be negative")
// 40:         end
// 41:         value
// 42:       end
// 43:
// 44:       def ensure_positive_and_no_zero(value)
// 45:         if value < 1
// 46:           raise ArgumentError.new("#{value} cannot be negative or zero")
// 47:         end
// 48:         value
// 49:       end
// 50:
// 51:       extend self
// 52:     end
// 53:   end
// 54: end
