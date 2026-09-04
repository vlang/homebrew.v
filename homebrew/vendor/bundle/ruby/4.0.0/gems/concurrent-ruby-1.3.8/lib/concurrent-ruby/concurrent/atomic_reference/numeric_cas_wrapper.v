module atomic_reference

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic_reference/numeric_cas_wrapper.rb`.
// The original source is retained below until every stub has a typed V body.
fn numeric_compare_and_set_from_args(args []ruby.Value) bool {
	if args.len < 3 {
		return false
	}
	actual := args[0]
	expected := args[1]
	if is_numeric_value(expected) {
		return numeric_values_match(actual, expected)
	}
	return boundary_values_identical(actual, expected)
}

// Ruby method `compare_and_set(old_value, new_value)` at line 10.
pub fn ruby_numeric_cas_wrapper_l10_d1_compare_and_set(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(numeric_compare_and_set_from_args(args))
}

// Ruby alias_method `alias_method :compare_and_swap, :compare_and_set` at line 33.
pub fn ruby_numeric_cas_wrapper_l33_d2_compare_and_swap(args ...ruby.Value) ruby.Value {
	return ruby_numeric_cas_wrapper_l10_d1_compare_and_set(...args)
}

// Original Ruby source (line-for-line):
// 1: module Concurrent
// 2:
// 3:   # Special "compare and set" handling of numeric values.
// 4:   #
// 5:   # @!visibility private
// 6:   # @!macro internal_implementation_note
// 7:   module AtomicNumericCompareAndSetWrapper
// 8:
// 9:     # @!macro atomic_reference_method_compare_and_set
// 10:     def compare_and_set(old_value, new_value)
// 11:       if old_value.kind_of? Numeric
// 12:         # NaN is never == to itself; match it explicitly so #update can terminate.
// 13:         expected_nan = old_value.respond_to?(:nan?) && old_value.nan?
// 14:         while true
// 15:           old = get
// 16:
// 17:           return false unless old.kind_of? Numeric
// 18:
// 19:           if expected_nan
// 20:             return false unless old.respond_to?(:nan?) && old.nan?
// 21:           else
// 22:             return false unless old == old_value
// 23:           end
// 24:
// 25:           result = _compare_and_set(old, new_value)
// 26:           return result if result
// 27:         end
// 28:       else
// 29:         _compare_and_set(old_value, new_value)
// 30:       end
// 31:     end
// 32:
// 33:     alias_method :compare_and_swap, :compare_and_set
// 34:
// 35:   end
// 36: end
