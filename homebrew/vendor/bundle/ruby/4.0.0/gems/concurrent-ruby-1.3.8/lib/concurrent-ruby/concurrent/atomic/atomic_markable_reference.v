module atomic

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/atomic_markable_reference.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_atomic `attr_atomic(:reference)` at line 12.
pub fn ruby_atomic_markable_reference_l12_d1_reference(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reference', ...args)
}

// Ruby attr_atomic `attr_atomic(:reference)` at line 12.
pub fn ruby_atomic_markable_reference_l12_d2_reference(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reference=', ...args)
}

// Ruby attr_atomic `attr_atomic(:reference)` at line 12.
pub fn ruby_atomic_markable_reference_l12_d3_compare_and_set_reference(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compare_and_set_reference', ...args)
}

// Ruby attr_atomic `attr_atomic(:reference)` at line 12.
pub fn ruby_atomic_markable_reference_l12_d4_swap_reference(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('swap_reference', ...args)
}

// Ruby attr_atomic `attr_atomic(:reference)` at line 12.
pub fn ruby_atomic_markable_reference_l12_d5_update_reference(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('update_reference', ...args)
}

// Ruby method `initialize(value = nil, mark = false)` at line 15.
pub fn ruby_atomic_markable_reference_l15_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `compare_and_set(expected_val, new_val, expected_mark, new_mark)` at line 33.
pub fn ruby_atomic_markable_reference_l33_d7_compare_and_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compare_and_set', ...args)
}

// Ruby alias_method `alias_method :compare_and_swap, :compare_and_set` at line 59.
pub fn ruby_atomic_markable_reference_l59_d8_compare_and_swap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compare_and_swap', ...args)
}

// Ruby method `get` at line 64.
pub fn ruby_atomic_markable_reference_l64_d9_get(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get', ...args)
}

// Ruby method `value` at line 71.
pub fn ruby_atomic_markable_reference_l71_d10_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value', ...args)
}

// Ruby method `mark` at line 78.
pub fn ruby_atomic_markable_reference_l78_d11_mark(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mark', ...args)
}

// Ruby alias_method `alias_method :marked?, :mark` at line 82.
pub fn ruby_atomic_markable_reference_l82_d12_marked(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('marked?', ...args)
}

// Ruby method `set(new_val, new_mark)` at line 91.
pub fn ruby_atomic_markable_reference_l91_d13_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set', ...args)
}

// Ruby method `update` at line 105.
pub fn ruby_atomic_markable_reference_l105_d14_update(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('update', ...args)
}

// Ruby method `try_update!` at line 128.
pub fn ruby_atomic_markable_reference_l128_d15_try_update(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('try_update!', ...args)
}

// Ruby method `try_update` at line 152.
pub fn ruby_atomic_markable_reference_l152_d16_try_update(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('try_update', ...args)
}

// Ruby method `immutable_array(*args)` at line 163.
pub fn ruby_atomic_markable_reference_l163_d17_immutable_array(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('immutable_array', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/errors'
// 2: require 'concurrent/synchronization/object'
// 3:
// 4: module Concurrent
// 5:   # An atomic reference which maintains an object reference along with a mark bit
// 6:   # that can be updated atomically.
// 7:   #
// 8:   # @see http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/atomic/AtomicMarkableReference.html
// 9:   #   java.util.concurrent.atomic.AtomicMarkableReference
// 10:   class AtomicMarkableReference < ::Concurrent::Synchronization::Object
// 11:
// 12:     attr_atomic(:reference)
// 13:     private :reference, :reference=, :swap_reference, :compare_and_set_reference, :update_reference
// 14:
// 15:     def initialize(value = nil, mark = false)
// 16:       super()
// 17:       self.reference = immutable_array(value, mark)
// 18:     end
// 19:
// 20:     # Atomically sets the value and mark to the given updated value and
// 21:     # mark given both:
// 22:     #   - the current value == the expected value &&
// 23:     #   - the current mark == the expected mark
// 24:     #
// 25:     # @param [Object] expected_val the expected value
// 26:     # @param [Object] new_val the new value
// 27:     # @param [Boolean] expected_mark the expected mark
// 28:     # @param [Boolean] new_mark the new mark
// 29:     #
// 30:     # @return [Boolean] `true` if successful. A `false` return indicates
// 31:     # that the actual value was not equal to the expected value or the
// 32:     # actual mark was not equal to the expected mark
// 33:     def compare_and_set(expected_val, new_val, expected_mark, new_mark)
// 34:       # Memoize a valid reference to the current AtomicReference for
// 35:       # later comparison.
// 36:       current             = reference
// 37:       curr_val, curr_mark = current
// 38:
// 39:       # Ensure that that the expected marks match.
// 40:       return false unless expected_mark == curr_mark
// 41:
// 42:       if expected_val.is_a? Numeric
// 43:         # If the object is a numeric, we need to ensure we are comparing
// 44:         # the numerical values
// 45:         return false unless expected_val == curr_val
// 46:       else
// 47:         # Otherwise, we need to ensure we are comparing the object identity.
// 48:         # Theoretically, this could be incorrect if a user monkey-patched
// 49:         # `Object#equal?`, but they should know that they are playing with
// 50:         # fire at that point.
// 51:         return false unless expected_val.equal? curr_val
// 52:       end
// 53:
// 54:       prospect = immutable_array(new_val, new_mark)
// 55:
// 56:       compare_and_set_reference current, prospect
// 57:     end
// 58:
// 59:     alias_method :compare_and_swap, :compare_and_set
// 60:
// 61:     # Gets the current reference and marked values.
// 62:     #
// 63:     # @return [Array] the current reference and marked values
// 64:     def get
// 65:       reference
// 66:     end
// 67:
// 68:     # Gets the current value of the reference
// 69:     #
// 70:     # @return [Object] the current value of the reference
// 71:     def value
// 72:       reference[0]
// 73:     end
// 74:
// 75:     # Gets the current marked value
// 76:     #
// 77:     # @return [Boolean] the current marked value
// 78:     def mark
// 79:       reference[1]
// 80:     end
// 81:
// 82:     alias_method :marked?, :mark
// 83:
// 84:     # _Unconditionally_ sets to the given value of both the reference and
// 85:     # the mark.
// 86:     #
// 87:     # @param [Object] new_val the new value
// 88:     # @param [Boolean] new_mark the new mark
// 89:     #
// 90:     # @return [Array] both the new value and the new mark
// 91:     def set(new_val, new_mark)
// 92:       self.reference = immutable_array(new_val, new_mark)
// 93:     end
// 94:
// 95:     # Pass the current value and marked state to the given block, replacing it
// 96:     # with the block's results. May retry if the value changes during the
// 97:     # block's execution.
// 98:     #
// 99:     # @yield [Object] Calculate a new value and marked state for the atomic
// 100:     #   reference using given (old) value and (old) marked
// 101:     # @yieldparam [Object] old_val the starting value of the atomic reference
// 102:     # @yieldparam [Boolean] old_mark the starting state of marked
// 103:     #
// 104:     # @return [Array] the new value and new mark
// 105:     def update
// 106:       loop do
// 107:         old_val, old_mark = reference
// 108:         new_val, new_mark = yield old_val, old_mark
// 109:
// 110:         if compare_and_set old_val, new_val, old_mark, new_mark
// 111:           return immutable_array(new_val, new_mark)
// 112:         end
// 113:       end
// 114:     end
// 115:
// 116:     # Pass the current value to the given block, replacing it
// 117:     # with the block's result. Raise an exception if the update
// 118:     # fails.
// 119:     #
// 120:     # @yield [Object] Calculate a new value and marked state for the atomic
// 121:     #   reference using given (old) value and (old) marked
// 122:     # @yieldparam [Object] old_val the starting value of the atomic reference
// 123:     # @yieldparam [Boolean] old_mark the starting state of marked
// 124:     #
// 125:     # @return [Array] the new value and marked state
// 126:     #
// 127:     # @raise [Concurrent::ConcurrentUpdateError] if the update fails
// 128:     def try_update!
// 129:       old_val, old_mark = reference
// 130:       new_val, new_mark = yield old_val, old_mark
// 131:
// 132:       unless compare_and_set old_val, new_val, old_mark, new_mark
// 133:         fail ::Concurrent::ConcurrentUpdateError,
// 134:              'AtomicMarkableReference: Update failed due to race condition.',
// 135:              'Note: If you would like to guarantee an update, please use ' +
// 136:                  'the `AtomicMarkableReference#update` method.'
// 137:       end
// 138:
// 139:       immutable_array(new_val, new_mark)
// 140:     end
// 141:
// 142:     # Pass the current value to the given block, replacing it with the
// 143:     # block's result. Simply return nil if update fails.
// 144:     #
// 145:     # @yield [Object] Calculate a new value and marked state for the atomic
// 146:     #   reference using given (old) value and (old) marked
// 147:     # @yieldparam [Object] old_val the starting value of the atomic reference
// 148:     # @yieldparam [Boolean] old_mark the starting state of marked
// 149:     #
// 150:     # @return [Array] the new value and marked state, or nil if
// 151:     # the update failed
// 152:     def try_update
// 153:       old_val, old_mark = reference
// 154:       new_val, new_mark = yield old_val, old_mark
// 155:
// 156:       return unless compare_and_set old_val, new_val, old_mark, new_mark
// 157:
// 158:       immutable_array(new_val, new_mark)
// 159:     end
// 160:
// 161:     private
// 162:
// 163:     def immutable_array(*args)
// 164:       args.freeze
// 165:     end
// 166:   end
// 167: end
