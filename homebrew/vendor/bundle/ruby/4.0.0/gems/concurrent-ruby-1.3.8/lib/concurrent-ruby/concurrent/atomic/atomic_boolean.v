module atomic

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/atomic_boolean.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `to_s` at line 121.
pub fn ruby_atomic_boolean_l121_d1_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby alias_method `alias_method :inspect, :to_s` at line 125.
pub fn ruby_atomic_boolean_l125_d2_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/native_extension_loader' # load native parts first
// 2:
// 3: require 'concurrent/atomic/mutex_atomic_boolean'
// 4:
// 5: module Concurrent
// 6:
// 7:   ###################################################################
// 8:
// 9:   # @!macro atomic_boolean_method_initialize
// 10:   #
// 11:   #   Creates a new `AtomicBoolean` with the given initial value.
// 12:   #
// 13:   #   @param [Boolean] initial the initial value
// 14:
// 15:   # @!macro atomic_boolean_method_value_get
// 16:   #
// 17:   #   Retrieves the current `Boolean` value.
// 18:   #
// 19:   #   @return [Boolean] the current value
// 20:
// 21:   # @!macro atomic_boolean_method_value_set
// 22:   #
// 23:   #   Explicitly sets the value.
// 24:   #
// 25:   #   @param [Boolean] value the new value to be set
// 26:   #
// 27:   #   @return [Boolean] the current value
// 28:
// 29:   # @!macro atomic_boolean_method_true_question
// 30:   #
// 31:   #   Is the current value `true`
// 32:   #
// 33:   #   @return [Boolean] true if the current value is `true`, else false
// 34:
// 35:   # @!macro atomic_boolean_method_false_question
// 36:   #
// 37:   #   Is the current value `false`
// 38:   #
// 39:   #   @return [Boolean] true if the current value is `false`, else false
// 40:
// 41:   # @!macro atomic_boolean_method_make_true
// 42:   #
// 43:   #   Explicitly sets the value to true.
// 44:   #
// 45:   #   @return [Boolean] true if value has changed, otherwise false
// 46:
// 47:   # @!macro atomic_boolean_method_make_false
// 48:   #
// 49:   #   Explicitly sets the value to false.
// 50:   #
// 51:   #   @return [Boolean] true if value has changed, otherwise false
// 52:
// 53:   ###################################################################
// 54:
// 55:   # @!macro atomic_boolean_public_api
// 56:   #
// 57:   #   @!method initialize(initial = false)
// 58:   #     @!macro  atomic_boolean_method_initialize
// 59:   #
// 60:   #   @!method value
// 61:   #     @!macro  atomic_boolean_method_value_get
// 62:   #
// 63:   #   @!method value=(value)
// 64:   #     @!macro  atomic_boolean_method_value_set
// 65:   #
// 66:   #   @!method true?
// 67:   #     @!macro  atomic_boolean_method_true_question
// 68:   #
// 69:   #   @!method false?
// 70:   #     @!macro  atomic_boolean_method_false_question
// 71:   #
// 72:   #   @!method make_true
// 73:   #     @!macro  atomic_boolean_method_make_true
// 74:   #
// 75:   #   @!method make_false
// 76:   #     @!macro  atomic_boolean_method_make_false
// 77:
// 78:   ###################################################################
// 79:
// 80:   # @!visibility private
// 81:   # @!macro internal_implementation_note
// 82:   AtomicBooleanImplementation = case
// 83:                                 when Concurrent.on_cruby? && Concurrent.c_extensions_loaded?
// 84:                                   CAtomicBoolean
// 85:                                 when Concurrent.on_jruby?
// 86:                                   JavaAtomicBoolean
// 87:                                 else
// 88:                                   MutexAtomicBoolean
// 89:                                 end
// 90:   private_constant :AtomicBooleanImplementation
// 91:
// 92:   # @!macro atomic_boolean
// 93:   #
// 94:   #   A boolean value that can be updated atomically. Reads and writes to an atomic
// 95:   #   boolean and thread-safe and guaranteed to succeed. Reads and writes may block
// 96:   #   briefly but no explicit locking is required.
// 97:   #
// 98:   #   @!macro thread_safe_variable_comparison
// 99:   #
// 100:   #   Performance:
// 101:   #
// 102:   #   ```
// 103:   #   Testing with ruby 2.1.2
// 104:   #   Testing with Concurrent::MutexAtomicBoolean...
// 105:   #     2.790000   0.000000   2.790000 (  2.791454)
// 106:   #   Testing with Concurrent::CAtomicBoolean...
// 107:   #     0.740000   0.000000   0.740000 (  0.740206)
// 108:   #
// 109:   #   Testing with jruby 1.9.3
// 110:   #   Testing with Concurrent::MutexAtomicBoolean...
// 111:   #     5.240000   2.520000   7.760000 (  3.683000)
// 112:   #   Testing with Concurrent::JavaAtomicBoolean...
// 113:   #     3.340000   0.010000   3.350000 (  0.855000)
// 114:   #   ```
// 115:   #
// 116:   #   @see http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/atomic/AtomicBoolean.html java.util.concurrent.atomic.AtomicBoolean
// 117:   #
// 118:   # @!macro atomic_boolean_public_api
// 119:   class AtomicBoolean < AtomicBooleanImplementation
// 120:     # @return [String] Short string representation.
// 121:     def to_s
// 122:       format '%s value:%s>', super[0..-2], value
// 123:     end
// 124:
// 125:     alias_method :inspect, :to_s
// 126:   end
// 127: end
