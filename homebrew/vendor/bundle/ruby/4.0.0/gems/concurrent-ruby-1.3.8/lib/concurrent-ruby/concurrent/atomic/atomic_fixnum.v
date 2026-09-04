module atomic

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/atomic_fixnum.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn atomic_fixnum_description(super_description string, value i64) string {
	base := if super_description.len > 0 {
		super_description[..super_description.len - 1]
	} else {
		super_description
	}
	return '${base} value:${value}>'
}

fn atomic_fixnum_description_from_args(args []ruby.Value) string {
	if args.len >= 2 {
		return atomic_fixnum_description(args[0].as_string(), args[1].as_int() or {
			panic(err)
		})
	}
	if args.len == 1 {
		return atomic_fixnum_description(args[0].attribute('super') or {
			panic('AtomicFixnum#to_s requires the superclass description')
		}, (args[0].attribute('value') or {
			panic('AtomicFixnum#to_s requires the current value')
		}).i64())
	}
	panic('AtomicFixnum#to_s requires a receiver or superclass description and value')
}

// Ruby method `to_s` at line 138.
pub fn ruby_atomic_fixnum_l138_d1_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(atomic_fixnum_description_from_args(args))
}

// Ruby alias_method `alias_method :inspect, :to_s` at line 142.
pub fn ruby_atomic_fixnum_l142_d2_inspect(args ...ruby.Value) ruby.Value {
	return ruby_atomic_fixnum_l138_d1_to_s(...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/native_extension_loader' # load native parts first
// 2:
// 3: require 'concurrent/atomic/mutex_atomic_fixnum'
// 4:
// 5: module Concurrent
// 6:
// 7:   ###################################################################
// 8:
// 9:   # @!macro atomic_fixnum_method_initialize
// 10:   #
// 11:   #   Creates a new `AtomicFixnum` with the given initial value.
// 12:   #
// 13:   #   @param [Fixnum] initial the initial value
// 14:   #   @raise [ArgumentError] if the initial value is not a `Fixnum`
// 15:
// 16:   # @!macro atomic_fixnum_method_value_get
// 17:   #
// 18:   #   Retrieves the current `Fixnum` value.
// 19:   #
// 20:   #   @return [Fixnum] the current value
// 21:
// 22:   # @!macro atomic_fixnum_method_value_set
// 23:   #
// 24:   #   Explicitly sets the value.
// 25:   #
// 26:   #   @param [Fixnum] value the new value to be set
// 27:   #
// 28:   #   @return [Fixnum] the current value
// 29:   #
// 30:   #   @raise [ArgumentError] if the new value is not a `Fixnum`
// 31:
// 32:   # @!macro atomic_fixnum_method_increment
// 33:   #
// 34:   #   Increases the current value by the given amount (defaults to 1).
// 35:   #
// 36:   #   @param [Fixnum] delta the amount by which to increase the current value
// 37:   #
// 38:   #   @return [Fixnum] the current value after incrementation
// 39:
// 40:   # @!macro atomic_fixnum_method_decrement
// 41:   #
// 42:   #   Decreases the current value by the given amount (defaults to 1).
// 43:   #
// 44:   #   @param [Fixnum] delta the amount by which to decrease the current value
// 45:   #
// 46:   #   @return [Fixnum] the current value after decrementation
// 47:
// 48:   # @!macro atomic_fixnum_method_compare_and_set
// 49:   #
// 50:   #   Atomically sets the value to the given updated value if the current
// 51:   #   value == the expected value.
// 52:   #
// 53:   #   @param [Fixnum] expect the expected value
// 54:   #   @param [Fixnum] update the new value
// 55:   #
// 56:   #   @return [Boolean] true if the value was updated else false
// 57:
// 58:   # @!macro atomic_fixnum_method_update
// 59:   #
// 60:   #   Pass the current value to the given block, replacing it
// 61:   #   with the block's result. May retry if the value changes
// 62:   #   during the block's execution.
// 63:   #
// 64:   #   @yield [Object] Calculate a new value for the atomic reference using
// 65:   #     given (old) value
// 66:   #   @yieldparam [Object] old_value the starting value of the atomic reference
// 67:   #
// 68:   #   @return [Object] the new value
// 69:
// 70:   ###################################################################
// 71:
// 72:   # @!macro atomic_fixnum_public_api
// 73:   #
// 74:   #   @!method initialize(initial = 0)
// 75:   #     @!macro atomic_fixnum_method_initialize
// 76:   #
// 77:   #   @!method value
// 78:   #     @!macro atomic_fixnum_method_value_get
// 79:   #
// 80:   #   @!method value=(value)
// 81:   #     @!macro atomic_fixnum_method_value_set
// 82:   #
// 83:   #   @!method increment(delta = 1)
// 84:   #     @!macro atomic_fixnum_method_increment
// 85:   #
// 86:   #   @!method decrement(delta = 1)
// 87:   #     @!macro atomic_fixnum_method_decrement
// 88:   #
// 89:   #   @!method compare_and_set(expect, update)
// 90:   #     @!macro atomic_fixnum_method_compare_and_set
// 91:   #
// 92:   #   @!method update
// 93:   #     @!macro atomic_fixnum_method_update
// 94:
// 95:   ###################################################################
// 96:
// 97:   # @!visibility private
// 98:   # @!macro internal_implementation_note
// 99:   AtomicFixnumImplementation = case
// 100:                                when Concurrent.on_cruby? && Concurrent.c_extensions_loaded?
// 101:                                  CAtomicFixnum
// 102:                                when Concurrent.on_jruby?
// 103:                                  JavaAtomicFixnum
// 104:                                else
// 105:                                  MutexAtomicFixnum
// 106:                                end
// 107:   private_constant :AtomicFixnumImplementation
// 108:
// 109:   # @!macro atomic_fixnum
// 110:   #
// 111:   #   A numeric value that can be updated atomically. Reads and writes to an atomic
// 112:   #   fixnum and thread-safe and guaranteed to succeed. Reads and writes may block
// 113:   #   briefly but no explicit locking is required.
// 114:   #
// 115:   #   @!macro thread_safe_variable_comparison
// 116:   #
// 117:   #   Performance:
// 118:   #
// 119:   #   ```
// 120:   #   Testing with ruby 2.1.2
// 121:   #   Testing with Concurrent::MutexAtomicFixnum...
// 122:   #     3.130000   0.000000   3.130000 (  3.136505)
// 123:   #   Testing with Concurrent::CAtomicFixnum...
// 124:   #     0.790000   0.000000   0.790000 (  0.785550)
// 125:   #
// 126:   #   Testing with jruby 1.9.3
// 127:   #   Testing with Concurrent::MutexAtomicFixnum...
// 128:   #     5.460000   2.460000   7.920000 (  3.715000)
// 129:   #   Testing with Concurrent::JavaAtomicFixnum...
// 130:   #     4.520000   0.030000   4.550000 (  1.187000)
// 131:   #   ```
// 132:   #
// 133:   #   @see http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/atomic/AtomicLong.html java.util.concurrent.atomic.AtomicLong
// 134:   #
// 135:   # @!macro atomic_fixnum_public_api
// 136:   class AtomicFixnum < AtomicFixnumImplementation
// 137:     # @return [String] Short string representation.
// 138:     def to_s
// 139:       format '%s value:%s>', super[0..-2], value
// 140:     end
// 141:
// 142:     alias_method :inspect, :to_s
// 143:   end
// 144: end
