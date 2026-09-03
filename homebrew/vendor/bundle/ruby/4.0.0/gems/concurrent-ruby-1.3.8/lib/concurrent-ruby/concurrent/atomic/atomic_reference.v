module atomic

import brew_runtime
import math
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/atomic_reference.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct AtomicReference {
mut:
	lock  sync.Mutex
	value brew_runtime.Value
}

pub fn new_atomic_reference(value brew_runtime.Value) &AtomicReference {
	return &AtomicReference{
		value: value
	}
}

pub fn (mut reference AtomicReference) get() brew_runtime.Value {
	reference.lock.lock()
	value := reference.value
	reference.lock.unlock()
	return value
}

pub fn (mut reference AtomicReference) set(value brew_runtime.Value) brew_runtime.Value {
	reference.lock.lock()
	reference.value = value
	reference.lock.unlock()
	return value
}

pub fn (mut reference AtomicReference) get_and_set(value brew_runtime.Value) brew_runtime.Value {
	reference.lock.lock()
	old_value := reference.value
	reference.value = value
	reference.lock.unlock()
	return old_value
}

fn atomic_numeric_value(value brew_runtime.Value) ?f64 {
	if value.type_name != 'Integer' && value.type_name != 'Float' {
		return none
	}
	return value.as_float() or { return none }
}

fn atomic_values_match(actual brew_runtime.Value, expected brew_runtime.Value) bool {
	if expected_numeric := atomic_numeric_value(expected) {
		actual_numeric := atomic_numeric_value(actual) or { return false }
		if math.is_nan(expected_numeric) {
			return math.is_nan(actual_numeric)
		}
		return actual_numeric == expected_numeric
	}
	return actual.type_name == expected.type_name && actual.repr == expected.repr
}

pub fn (mut reference AtomicReference) compare_and_set(expected brew_runtime.Value, value brew_runtime.Value) bool {
	reference.lock.lock()
	if atomic_values_match(reference.value, expected) {
		reference.value = value
		reference.lock.unlock()
		return true
	}
	reference.lock.unlock()
	return false
}

pub fn (mut reference AtomicReference) description(super_description string) string {
	base := if super_description.ends_with('>') {
		super_description[..super_description.len - 1]
	} else {
		super_description
	}
	return '${base} value:${reference.get().repr}>'
}

fn atomic_reference_compare_from_args(args []brew_runtime.Value) bool {
	return args.len >= 3 && atomic_values_match(args[0], args[1])
}

// Ruby alias_method `alias_method :_compare_and_set, :compare_and_set_reference` at line 39.
pub fn ruby_atomic_reference_l39_d1_compare_and_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(atomic_reference_compare_from_args(args))
}

// Ruby alias_method `alias_method :compare_and_swap, :compare_and_set` at line 44.
pub fn ruby_atomic_reference_l44_d2_compare_and_swap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(atomic_reference_compare_from_args(args))
}

// Ruby alias_method `alias_method :value, :get` at line 46.
pub fn ruby_atomic_reference_l46_d3_value(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 { args[0] } else { brew_runtime.object_value('NilClass', 'nil') }
}

// Ruby alias_method `alias_method :value=, :set` at line 47.
pub fn ruby_atomic_reference_l47_d4_value(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 0 {
		args[args.len - 1]
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby alias_method `alias_method :swap, :get_and_set` at line 48.
pub fn ruby_atomic_reference_l48_d5_swap(args ...brew_runtime.Value) brew_runtime.Value {
	return if args.len > 1 { args[0] } else { brew_runtime.object_value('NilClass', 'nil') }
}

// Ruby method `to_s` at line 136.
pub fn ruby_atomic_reference_l136_d6_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('AtomicReference#to_s requires superclass description and value')
	}
	base := if args[0].as_string().ends_with('>') {
		args[0].as_string()[..args[0].as_string().len - 1]
	} else {
		args[0].as_string()
	}
	return brew_runtime.string_value('${base} value:${args[1].repr}>')
}

// Ruby alias_method `alias_method :inspect, :to_s` at line 140.
pub fn ruby_atomic_reference_l140_d7_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_atomic_reference_l136_d6_to_s(...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/native_extension_loader' # load native parts first
// 2:
// 3: require 'concurrent/atomic_reference/atomic_direct_update'
// 4: require 'concurrent/atomic_reference/numeric_cas_wrapper'
// 5: require 'concurrent/atomic_reference/mutex_atomic'
// 6:
// 7: # Shim for TruffleRuby::AtomicReference
// 8: if Concurrent.on_truffleruby? && !defined?(TruffleRuby::AtomicReference)
// 9:   # @!visibility private
// 10:   module TruffleRuby
// 11:     AtomicReference = Truffle::AtomicReference
// 12:   end
// 13: end
// 14:
// 15: module Concurrent
// 16:
// 17:   # @!macro internal_implementation_note
// 18:   AtomicReferenceImplementation = case
// 19:                                   when Concurrent.on_cruby? && Concurrent.c_extensions_loaded?
// 20:                                     # @!visibility private
// 21:                                     # @!macro internal_implementation_note
// 22:                                     class CAtomicReference
// 23:                                       include AtomicDirectUpdate
// 24:                                       include AtomicNumericCompareAndSetWrapper
// 25:                                     end
// 26:                                     CAtomicReference
// 27:                                   when Concurrent.on_jruby?
// 28:                                     # @!visibility private
// 29:                                     # @!macro internal_implementation_note
// 30:                                     class JavaAtomicReference
// 31:                                       include AtomicDirectUpdate
// 32:                                       include AtomicNumericCompareAndSetWrapper
// 33:                                     end
// 34:                                     JavaAtomicReference
// 35:                                   when Concurrent.on_truffleruby?
// 36:                                     class TruffleRubyAtomicReference < TruffleRuby::AtomicReference
// 37:                                       include AtomicDirectUpdate
// 38:                                       if private_method_defined?(:compare_and_set_reference)
// 39:                                         alias_method :_compare_and_set, :compare_and_set_reference
// 40:                                         private :_compare_and_set
// 41:                                         include AtomicNumericCompareAndSetWrapper
// 42:                                       else
// 43:                                         # AtomicNumericCompareAndSetWrapper behavior already in TruffleRuby::AtomicReference
// 44:                                         alias_method :compare_and_swap, :compare_and_set
// 45:                                       end
// 46:                                       alias_method :value, :get
// 47:                                       alias_method :value=, :set
// 48:                                       alias_method :swap, :get_and_set
// 49:                                     end
// 50:                                     TruffleRubyAtomicReference
// 51:                                   else
// 52:                                     MutexAtomicReference
// 53:                                   end
// 54:   private_constant :AtomicReferenceImplementation
// 55:
// 56:   # An object reference that may be updated atomically. All read and write
// 57:   # operations have java volatile semantic.
// 58:   #
// 59:   # @!macro thread_safe_variable_comparison
// 60:   #
// 61:   # @see http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/atomic/AtomicReference.html
// 62:   # @see http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/atomic/package-summary.html
// 63:   #
// 64:   # @!method initialize(value = nil)
// 65:   #   @!macro atomic_reference_method_initialize
// 66:   #     @param [Object] value The initial value.
// 67:   #
// 68:   # @!method get
// 69:   #   @!macro atomic_reference_method_get
// 70:   #     Gets the current value.
// 71:   #     @return [Object] the current value
// 72:   #
// 73:   # @!method set(new_value)
// 74:   #   @!macro atomic_reference_method_set
// 75:   #     Sets to the given value.
// 76:   #     @param [Object] new_value the new value
// 77:   #     @return [Object] the new value
// 78:   #
// 79:   # @!method get_and_set(new_value)
// 80:   #   @!macro atomic_reference_method_get_and_set
// 81:   #     Atomically sets to the given value and returns the old value.
// 82:   #     @param [Object] new_value the new value
// 83:   #     @return [Object] the old value
// 84:   #
// 85:   # @!method compare_and_set(old_value, new_value)
// 86:   #   @!macro atomic_reference_method_compare_and_set
// 87:   #
// 88:   #     Atomically sets the value to the given updated value if
// 89:   #     the current value == the expected value.
// 90:   #
// 91:   #     @param [Object] old_value the expected value
// 92:   #     @param [Object] new_value the new value
// 93:   #
// 94:   #     @return [Boolean] `true` if successful. A `false` return indicates
// 95:   #     that the actual value was not equal to the expected value.
// 96:   #
// 97:   # @!method update
// 98:   #   Pass the current value to the given block, replacing it
// 99:   #   with the block's result. May retry if the value changes
// 100:   #   during the block's execution.
// 101:   #
// 102:   #   @yield [Object] Calculate a new value for the atomic reference using
// 103:   #     given (old) value
// 104:   #   @yieldparam [Object] old_value the starting value of the atomic reference
// 105:   #   @return [Object] the new value
// 106:   #
// 107:   # @!method try_update
// 108:   #   Pass the current value to the given block, replacing it
// 109:   #   with the block's result. Return nil if the update fails.
// 110:   #
// 111:   #   @yield [Object] Calculate a new value for the atomic reference using
// 112:   #     given (old) value
// 113:   #   @yieldparam [Object] old_value the starting value of the atomic reference
// 114:   #   @note This method was altered to avoid raising an exception by default.
// 115:   #     Instead, this method now returns `nil` in case of failure. For more info,
// 116:   #     please see: https://github.com/ruby-concurrency/concurrent-ruby/pull/336
// 117:   #   @return [Object] the new value, or nil if update failed
// 118:   #
// 119:   # @!method try_update!
// 120:   #   Pass the current value to the given block, replacing it
// 121:   #   with the block's result. Raise an exception if the update
// 122:   #   fails.
// 123:   #
// 124:   #   @yield [Object] Calculate a new value for the atomic reference using
// 125:   #     given (old) value
// 126:   #   @yieldparam [Object] old_value the starting value of the atomic reference
// 127:   #   @note This behavior mimics the behavior of the original
// 128:   #     `AtomicReference#try_update` API. The reason this was changed was to
// 129:   #     avoid raising exceptions (which are inherently slow) by default. For more
// 130:   #     info: https://github.com/ruby-concurrency/concurrent-ruby/pull/336
// 131:   #   @return [Object] the new value
// 132:   #   @raise [Concurrent::ConcurrentUpdateError] if the update fails
// 133:   class AtomicReference < AtomicReferenceImplementation
// 134:
// 135:     # @return [String] Short string representation.
// 136:     def to_s
// 137:       format '%s value:%s>', super[0..-2], get
// 138:     end
// 139:
// 140:     alias_method :inspect, :to_s
// 141:   end
// 142: end
