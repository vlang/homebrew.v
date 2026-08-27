module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atom.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_atomic `attr_atomic(:value)` at line 99.
pub fn ruby_atom_l99_d1_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value', ...args)
}

// Ruby attr_atomic `attr_atomic(:value)` at line 99.
pub fn ruby_atom_l99_d2_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value=', ...args)
}

// Ruby attr_atomic `attr_atomic(:value)` at line 99.
pub fn ruby_atom_l99_d3_compare_and_set_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compare_and_set_value', ...args)
}

// Ruby attr_atomic `attr_atomic(:value)` at line 99.
pub fn ruby_atom_l99_d4_swap_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('swap_value', ...args)
}

// Ruby attr_atomic `attr_atomic(:value)` at line 99.
pub fn ruby_atom_l99_d5_update_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('update_value', ...args)
}

// Ruby alias_method `alias_method :deref, :value` at line 102.
pub fn ruby_atom_l102_d6_deref(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deref', ...args)
}

// Ruby method `initialize(value, opts = {})` at line 121.
pub fn ruby_atom_l121_d7_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `swap(*args)` at line 157.
pub fn ruby_atom_l157_d8_swap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('swap', ...args)
}

// Ruby method `compare_and_set(old_value, new_value)` at line 181.
pub fn ruby_atom_l181_d9_compare_and_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compare_and_set', ...args)
}

// Ruby method `reset(new_value)` at line 198.
pub fn ruby_atom_l198_d10_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset', ...args)
}

// Ruby method `valid?(new_value)` at line 216.
pub fn ruby_atom_l216_d11_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/atomic/atomic_reference'
// 2: require 'concurrent/collection/copy_on_notify_observer_set'
// 3: require 'concurrent/concern/observable'
// 4: require 'concurrent/synchronization/object'
// 5:
// 6: # @!macro thread_safe_variable_comparison
// 7: #
// 8: #   ## Thread-safe Variable Classes
// 9: #
// 10: #   Each of the thread-safe variable classes is designed to solve a different
// 11: #   problem. In general:
// 12: #
// 13: #   * *{Concurrent::Agent}:* Shared, mutable variable providing independent,
// 14: #     uncoordinated, *asynchronous* change of individual values. Best used when
// 15: #     the value will undergo frequent, complex updates. Suitable when the result
// 16: #     of an update does not need to be known immediately.
// 17: #   * *{Concurrent::Atom}:* Shared, mutable variable providing independent,
// 18: #     uncoordinated, *synchronous* change of individual values. Best used when
// 19: #     the value will undergo frequent reads but only occasional, though complex,
// 20: #     updates. Suitable when the result of an update must be known immediately.
// 21: #   * *{Concurrent::AtomicReference}:* A simple object reference that can be updated
// 22: #     atomically. Updates are synchronous but fast. Best used when updates a
// 23: #     simple set operations. Not suitable when updates are complex.
// 24: #     {Concurrent::AtomicBoolean} and {Concurrent::AtomicFixnum} are similar
// 25: #     but optimized for the given data type.
// 26: #   * *{Concurrent::Exchanger}:* Shared, stateless synchronization point. Used
// 27: #     when two or more threads need to exchange data. The threads will pair then
// 28: #     block on each other until the exchange is complete.
// 29: #   * *{Concurrent::MVar}:* Shared synchronization point. Used when one thread
// 30: #     must give a value to another, which must take the value. The threads will
// 31: #     block on each other until the exchange is complete.
// 32: #   * *{Concurrent::ThreadLocalVar}:* Shared, mutable, isolated variable which
// 33: #     holds a different value for each thread which has access. Often used as
// 34: #     an instance variable in objects which must maintain different state
// 35: #     for different threads.
// 36: #   * *{Concurrent::TVar}:* Shared, mutable variables which provide
// 37: #     *coordinated*, *synchronous*, change of *many* stated. Used when multiple
// 38: #     value must change together, in an all-or-nothing transaction.
// 39:
// 40:
// 41: module Concurrent
// 42:
// 43:   # Atoms provide a way to manage shared, synchronous, independent state.
// 44:   #
// 45:   # An atom is initialized with an initial value and an optional validation
// 46:   # proc. At any time the value of the atom can be synchronously and safely
// 47:   # changed. If a validator is given at construction then any new value
// 48:   # will be checked against the validator and will be rejected if the
// 49:   # validator returns false or raises an exception.
// 50:   #
// 51:   # There are two ways to change the value of an atom: {#compare_and_set} and
// 52:   # {#swap}. The former will set the new value if and only if it validates and
// 53:   # the current value matches the new value. The latter will atomically set the
// 54:   # new value to the result of running the given block if and only if that
// 55:   # value validates.
// 56:   #
// 57:   # ## Example
// 58:   #
// 59:   # ```
// 60:   # def next_fibonacci(set = nil)
// 61:   #   return [0, 1] if set.nil?
// 62:   #   set + [set[-2..-1].reduce{|sum,x| sum + x }]
// 63:   # end
// 64:   #
// 65:   # # create an atom with an initial value
// 66:   # atom = Concurrent::Atom.new(next_fibonacci)
// 67:   #
// 68:   # # send a few update requests
// 69:   # 5.times do
// 70:   #   atom.swap{|set| next_fibonacci(set) }
// 71:   # end
// 72:   #
// 73:   # # get the current value
// 74:   # atom.value #=> [0, 1, 1, 2, 3, 5, 8]
// 75:   # ```
// 76:   #
// 77:   # ## Observation
// 78:   #
// 79:   # Atoms support observers through the {Concurrent::Observable} mixin module.
// 80:   # Notification of observers occurs every time the value of the Atom changes.
// 81:   # When notified the observer will receive three arguments: `time`, `old_value`,
// 82:   # and `new_value`. The `time` argument is the time at which the value change
// 83:   # occurred. The `old_value` is the value of the Atom when the change began
// 84:   # The `new_value` is the value to which the Atom was set when the change
// 85:   # completed. Note that `old_value` and `new_value` may be the same. This is
// 86:   # not an error. It simply means that the change operation returned the same
// 87:   # value.
// 88:   #
// 89:   # Unlike in Clojure, `Atom` cannot participate in {Concurrent::TVar} transactions.
// 90:   #
// 91:   # @!macro thread_safe_variable_comparison
// 92:   #
// 93:   # @see http://clojure.org/atoms Clojure Atoms
// 94:   # @see http://clojure.org/state Values and Change - Clojure's approach to Identity and State
// 95:   class Atom < Synchronization::Object
// 96:     include Concern::Observable
// 97:
// 98:     safe_initialization!
// 99:     attr_atomic(:value)
// 100:     private :value=, :swap_value, :compare_and_set_value, :update_value
// 101:     public :value
// 102:     alias_method :deref, :value
// 103:
// 104:     # @!method value
// 105:     #   The current value of the atom.
// 106:     #
// 107:     #   @return [Object] The current value.
// 108:
// 109:     # Create a new atom with the given initial value.
// 110:     #
// 111:     # @param [Object] value The initial value
// 112:     # @param [Hash] opts The options used to configure the atom
// 113:     # @option opts [Proc] :validator (nil) Optional proc used to validate new
// 114:     #   values. It must accept one and only one argument which will be the
// 115:     #   intended new value. The validator will return true if the new value
// 116:     #   is acceptable else return false (preferably) or raise an exception.
// 117:     #
// 118:     # @!macro deref_options
// 119:     #
// 120:     # @raise [ArgumentError] if the validator is not a `Proc` (when given)
// 121:     def initialize(value, opts = {})
// 122:       super()
// 123:       @Validator     = opts.fetch(:validator, -> v { true })
// 124:       self.observers = Collection::CopyOnNotifyObserverSet.new
// 125:       self.value     = value
// 126:     end
// 127:
// 128:     # Atomically swaps the value of atom using the given block. The current
// 129:     # value will be passed to the block, as will any arguments passed as
// 130:     # arguments to the function. The new value will be validated against the
// 131:     # (optional) validator proc given at construction. If validation fails the
// 132:     # value will not be changed.
// 133:     #
// 134:     # Internally, {#swap} reads the current value, applies the block to it, and
// 135:     # attempts to compare-and-set it in. Since another thread may have changed
// 136:     # the value in the intervening time, it may have to retry, and does so in a
// 137:     # spin loop. The net effect is that the value will always be the result of
// 138:     # the application of the supplied block to a current value, atomically.
// 139:     # However, because the block might be called multiple times, it must be free
// 140:     # of side effects.
// 141:     #
// 142:     # @note The given block may be called multiple times, and thus should be free
// 143:     #   of side effects.
// 144:     #
// 145:     # @param [Object] args Zero or more arguments passed to the block.
// 146:     #
// 147:     # @yield [value, args] Calculates a new value for the atom based on the
// 148:     #   current value and any supplied arguments.
// 149:     # @yieldparam value [Object] The current value of the atom.
// 150:     # @yieldparam args [Object] All arguments passed to the function, in order.
// 151:     # @yieldreturn [Object] The intended new value of the atom.
// 152:     #
// 153:     # @return [Object] The final value of the atom after all operations and
// 154:     #   validations are complete.
// 155:     #
// 156:     # @raise [ArgumentError] When no block is given.
// 157:     def swap(*args)
// 158:       raise ArgumentError.new('no block given') unless block_given?
// 159:
// 160:       loop do
// 161:         old_value = value
// 162:         new_value = yield(old_value, *args)
// 163:         begin
// 164:           break old_value unless valid?(new_value)
// 165:           break new_value if compare_and_set(old_value, new_value)
// 166:         rescue
// 167:           break old_value
// 168:         end
// 169:       end
// 170:     end
// 171:
// 172:     # Atomically sets the value of atom to the new value if and only if the
// 173:     # current value of the atom is identical to the old value and the new
// 174:     # value successfully validates against the (optional) validator given
// 175:     # at construction.
// 176:     #
// 177:     # @param [Object] old_value The expected current value.
// 178:     # @param [Object] new_value The intended new value.
// 179:     #
// 180:     # @return [Boolean] True if the value is changed else false.
// 181:     def compare_and_set(old_value, new_value)
// 182:       if valid?(new_value) && compare_and_set_value(old_value, new_value)
// 183:         observers.notify_observers(Time.now, old_value, new_value)
// 184:         true
// 185:       else
// 186:         false
// 187:       end
// 188:     end
// 189:
// 190:     # Atomically sets the value of atom to the new value without regard for the
// 191:     # current value so long as the new value successfully validates against the
// 192:     # (optional) validator given at construction.
// 193:     #
// 194:     # @param [Object] new_value The intended new value.
// 195:     #
// 196:     # @return [Object] The final value of the atom after all operations and
// 197:     #   validations are complete.
// 198:     def reset(new_value)
// 199:       old_value = value
// 200:       if valid?(new_value)
// 201:         self.value = new_value
// 202:         observers.notify_observers(Time.now, old_value, new_value)
// 203:         new_value
// 204:       else
// 205:         old_value
// 206:       end
// 207:     end
// 208:
// 209:     private
// 210:
// 211:     # Is the new value valid?
// 212:     #
// 213:     # @param [Object] new_value The intended new value.
// 214:     # @return [Boolean] false if the validator function returns false or raises
// 215:     #   an exception else true
// 216:     def valid?(new_value)
// 217:       @Validator.call(new_value)
// 218:     rescue
// 219:       false
// 220:     end
// 221:   end
// 222: end
