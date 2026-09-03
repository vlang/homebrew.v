module atomic_reference

import brew_runtime
import math
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic_reference/mutex_atomic.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct MutexAtomicReference {
mut:
	lock  sync.Mutex
	value brew_runtime.Value
}

pub fn new_mutex_atomic_reference(value brew_runtime.Value) &MutexAtomicReference {
	return &MutexAtomicReference{
		value: value
	}
}

pub fn (mut reference MutexAtomicReference) get() brew_runtime.Value {
	reference.lock.lock()
	value := reference.value
	reference.lock.unlock()
	return value
}

pub fn (mut reference MutexAtomicReference) set(new_value brew_runtime.Value) brew_runtime.Value {
	reference.lock.lock()
	reference.value = new_value
	reference.lock.unlock()
	return new_value
}

pub fn (mut reference MutexAtomicReference) get_and_set(new_value brew_runtime.Value) brew_runtime.Value {
	reference.lock.lock()
	old_value := reference.value
	reference.value = new_value
	reference.lock.unlock()
	return old_value
}

fn is_numeric_value(value brew_runtime.Value) bool {
	return value.type_name == 'Integer' || value.type_name == 'Float'
}

fn numeric_values_match(actual brew_runtime.Value, expected brew_runtime.Value) bool {
	if !is_numeric_value(actual) || !is_numeric_value(expected) {
		return false
	}
	actual_number := actual.as_float() or { return false }
	expected_number := expected.as_float() or { return false }
	if math.is_nan(expected_number) {
		return math.is_nan(actual_number)
	}
	return actual_number == expected_number
}

fn boundary_values_identical(actual brew_runtime.Value, expected brew_runtime.Value) bool {
	if actual.type_name != expected.type_name {
		return false
	}
	floats_match := actual.float_data == expected.float_data || (math.is_nan(actual.float_data) && math.is_nan(expected.float_data))
	return actual.repr == expected.repr && actual.bool_data == expected.bool_data && actual.int_data == expected.int_data && floats_match
}

pub fn (mut reference MutexAtomicReference) compare_and_set_reference(expected brew_runtime.Value, new_value brew_runtime.Value) bool {
	reference.lock.lock()
	if boundary_values_identical(reference.value, expected) {
		reference.value = new_value
		reference.lock.unlock()
		return true
	}
	reference.lock.unlock()
	return false
}

pub fn (mut reference MutexAtomicReference) compare_and_set(expected brew_runtime.Value, new_value brew_runtime.Value) bool {
	if !is_numeric_value(expected) {
		return reference.compare_and_set_reference(expected, new_value)
	}
	for {
		old_value := reference.get()
		if !numeric_values_match(old_value, expected) {
			return false
		}
		if reference.compare_and_set_reference(old_value, new_value) {
			return true
		}
	}
	return false
}

pub fn (mut reference MutexAtomicReference) update(updater fn(brew_runtime.Value) brew_runtime.Value) brew_runtime.Value {
	for {
		old_value := reference.get()
		new_value := updater(old_value)
		if reference.compare_and_set(old_value, new_value) {
			return new_value
		}
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn (mut reference MutexAtomicReference) try_update(updater fn(brew_runtime.Value) brew_runtime.Value) ?brew_runtime.Value {
	old_value := reference.get()
	new_value := updater(old_value)
	if !reference.compare_and_set(old_value, new_value) {
		return none
	}
	return new_value
}

pub fn (mut reference MutexAtomicReference) try_update_or_error(updater fn(brew_runtime.Value) brew_runtime.Value) !brew_runtime.Value {
	return reference.try_update(updater) or { return error('Update failed') }
}

fn nil_boundary_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `initialize(value = nil)` at line 15.
pub fn ruby_mutex_atomic_l15_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 { args[0] } else { nil_boundary_value() }
}

// Ruby method `get` at line 22.
pub fn ruby_mutex_atomic_l22_d2_get(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 { args[0] } else { nil_boundary_value() }
}

// Ruby alias_method `alias_method :value, :get` at line 25.
pub fn ruby_mutex_atomic_l25_d3_value(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_mutex_atomic_l22_d2_get(...args)
}

// Ruby method `set(new_value)` at line 28.
pub fn ruby_mutex_atomic_l28_d4_set(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 { args[args.len - 1] } else { nil_boundary_value() }
}

// Ruby alias_method `alias_method :value=, :set` at line 31.
pub fn ruby_mutex_atomic_l31_d5_value(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_mutex_atomic_l28_d4_set(...args)
}

// Ruby method `get_and_set(new_value)` at line 34.
pub fn ruby_mutex_atomic_l34_d6_get_and_set(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 1 { args[0] } else { nil_boundary_value() }
}

// Ruby alias_method `alias_method :swap, :get_and_set` at line 41.
pub fn ruby_mutex_atomic_l41_d7_swap(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_mutex_atomic_l34_d6_get_and_set(...args)
}

// Ruby method `_compare_and_set(old_value, new_value)` at line 44.
pub fn ruby_mutex_atomic_l44_d8_compare_and_set(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(boundary_values_identical(args[0], args[1]))
}

// Ruby method `synchronize` at line 58.
pub fn ruby_mutex_atomic_l58_d9_synchronize(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 { args[args.len - 1] } else { nil_boundary_value() }
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/atomic_reference/atomic_direct_update'
// 2: require 'concurrent/atomic_reference/numeric_cas_wrapper'
// 3: require 'concurrent/synchronization/safe_initialization'
// 4:
// 5: module Concurrent
// 6:
// 7:   # @!visibility private
// 8:   # @!macro internal_implementation_note
// 9:   class MutexAtomicReference
// 10:     extend Concurrent::Synchronization::SafeInitialization
// 11:     include AtomicDirectUpdate
// 12:     include AtomicNumericCompareAndSetWrapper
// 13:
// 14:     # @!macro atomic_reference_method_initialize
// 15:     def initialize(value = nil)
// 16:       super()
// 17:       @Lock = ::Mutex.new
// 18:       @value = value
// 19:     end
// 20:
// 21:     # @!macro atomic_reference_method_get
// 22:     def get
// 23:       synchronize { @value }
// 24:     end
// 25:     alias_method :value, :get
// 26:
// 27:     # @!macro atomic_reference_method_set
// 28:     def set(new_value)
// 29:       synchronize { @value = new_value }
// 30:     end
// 31:     alias_method :value=, :set
// 32:
// 33:     # @!macro atomic_reference_method_get_and_set
// 34:     def get_and_set(new_value)
// 35:       synchronize do
// 36:         old_value = @value
// 37:         @value = new_value
// 38:         old_value
// 39:       end
// 40:     end
// 41:     alias_method :swap, :get_and_set
// 42:
// 43:     # @!macro atomic_reference_method_compare_and_set
// 44:     private def _compare_and_set(old_value, new_value)
// 45:       synchronize do
// 46:         if @value.equal? old_value
// 47:           @value = new_value
// 48:           true
// 49:         else
// 50:           false
// 51:         end
// 52:       end
// 53:     end
// 54:
// 55:     protected
// 56:
// 57:     # @!visibility private
// 58:     def synchronize
// 59:       if @Lock.owned?
// 60:         yield
// 61:       else
// 62:         @Lock.synchronize { yield }
// 63:       end
// 64:     end
// 65:   end
// 66: end
