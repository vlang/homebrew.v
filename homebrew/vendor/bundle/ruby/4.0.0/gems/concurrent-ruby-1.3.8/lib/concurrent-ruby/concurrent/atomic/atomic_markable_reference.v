module atomic

import brew_runtime
import math
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/atomic_markable_reference.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct MarkablePair {
pub:
	value brew_runtime.Value
	mark  bool
}

pub struct MarkableSnapshot {
pub:
	pair    MarkablePair
	version u64
}

pub struct MarkableUpdateResult {
pub:
	updated bool
	pair    MarkablePair
}

pub type MarkableUpdate = fn(brew_runtime.Value, bool) !MarkablePair

@[heap]
pub struct AtomicMarkableReference {
mut:
	lock    sync.Mutex
	pair    MarkablePair
	version u64
}

fn markable_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

pub fn new_atomic_markable_reference(value brew_runtime.Value, mark bool) &AtomicMarkableReference {
	return &AtomicMarkableReference{
		pair: MarkablePair{
			value: value
			mark: mark
		}
	}
}

pub fn (mut reference AtomicMarkableReference) snapshot() MarkableSnapshot {
	reference.lock.lock()
	defer {
		reference.lock.unlock()
	}
	return MarkableSnapshot{
		pair: reference.pair
		version: reference.version
	}
}

fn markable_values_match(actual brew_runtime.Value, expected brew_runtime.Value) bool {
	if expected.type_name == 'Integer' || expected.type_name == 'Float' {
		if actual.type_name != 'Integer' && actual.type_name != 'Float' {
			return false
		}
		actual_number := actual.as_float() or { return false }
		expected_number := expected.as_float() or { return false }
		if math.is_nan(expected_number) {
			return math.is_nan(actual_number)
		}
		return actual_number == expected_number
	}
	// Generic boundary values retain translated object identity when available.
	if expected_identity := expected.attributes['identity'] {
		return actual.attributes['identity'] == expected_identity
	}
	return actual.type_name == expected.type_name && actual.repr == expected.repr
}

pub fn (mut reference AtomicMarkableReference) compare_and_set(expected_value brew_runtime.Value, new_value brew_runtime.Value, expected_mark bool, new_mark bool) bool {
	reference.lock.lock()
	defer {
		reference.lock.unlock()
	}
	if reference.pair.mark != expected_mark || !markable_values_match(reference.pair.value, expected_value) {
		return false
	}
	reference.pair = MarkablePair{
		value: new_value
		mark: new_mark
	}
	reference.version++
	return true
}

pub fn (mut reference AtomicMarkableReference) compare_and_set_snapshot(expected MarkableSnapshot, prospect MarkablePair) bool {
	reference.lock.lock()
	defer {
		reference.lock.unlock()
	}
	if reference.version != expected.version {
		return false
	}
	reference.pair = prospect
	reference.version++
	return true
}

pub fn (mut reference AtomicMarkableReference) set(value brew_runtime.Value, mark bool) MarkablePair {
	reference.lock.lock()
	reference.pair = MarkablePair{
		value: value
		mark: mark
	}
	reference.version++
	pair := reference.pair
	reference.lock.unlock()
	return pair
}

pub fn (mut reference AtomicMarkableReference) swap(prospect MarkablePair) MarkableSnapshot {
	reference.lock.lock()
	old := MarkableSnapshot{
		pair: reference.pair
		version: reference.version
	}
	reference.pair = prospect
	reference.version++
	reference.lock.unlock()
	return old
}

pub fn (mut reference AtomicMarkableReference) update(action MarkableUpdate) !MarkablePair {
	for {
		old := reference.snapshot()
		prospect := action(old.pair.value, old.pair.mark)!
		if reference.compare_and_set_snapshot(old, prospect) {
			return prospect
		}
	}
	return error('unreachable')
}

pub fn (mut reference AtomicMarkableReference) try_update(action MarkableUpdate) !MarkableUpdateResult {
	old := reference.snapshot()
	prospect := action(old.pair.value, old.pair.mark)!
	if !reference.compare_and_set_snapshot(old, prospect) {
		return MarkableUpdateResult{
			updated: false
			pair: old.pair
		}
	}
	return MarkableUpdateResult{
		updated: true
		pair: prospect
	}
}

fn markable_pair_value(pair MarkablePair, address u64, version u64) brew_runtime.Value {
	values := [pair.value, brew_runtime.bool_value(pair.mark)]
	return brew_runtime.Value{
		type_name: 'Array'
		repr: values.map(it.repr).str()
		array_data: values
		attributes: {
			'markable_address': address.str()
			'version':          version.str()
		}
	}
}

fn markable_pair_from_value(value brew_runtime.Value) MarkablePair {
	values := value.as_array() or { panic('markable reference requires a two-element Array') }
	if values.len < 2 {
		panic('markable reference requires a two-element Array')
	}
	return MarkablePair{
		value: values[0]
		mark: values[1].as_bool() or { panic(err) }
	}
}

fn markable_boundary_new(value brew_runtime.Value, mark bool) brew_runtime.Value {
	reference := new_atomic_markable_reference(value, mark)
	return brew_runtime.structured_value('Concurrent::AtomicMarkableReference', '#<Concurrent::AtomicMarkableReference>', {
		'markable_address': u64(voidptr(reference)).str()
	})
}

fn markable_boundary_receiver(args []brew_runtime.Value) &AtomicMarkableReference {
	if args.len == 0 {
		panic('AtomicMarkableReference method requires a receiver')
	}
	address := (args[0].attribute('markable_address') or {
		panic('${args[0].type_name} has no translated AtomicMarkableReference state')
	}).u64()
	return unsafe { &AtomicMarkableReference(voidptr(address)) }
}

fn markable_boundary_snapshot(mut reference &AtomicMarkableReference) brew_runtime.Value {
	snapshot := reference.snapshot()
	return markable_pair_value(snapshot.pair, u64(voidptr(reference)), snapshot.version)
}

// Ruby attr_atomic `attr_atomic(:reference)` at line 12.
pub fn ruby_atomic_markable_reference_l12_d1_reference(args ...brew_runtime.Value) brew_runtime.Value {
	mut reference := markable_boundary_receiver(args)
	return markable_boundary_snapshot(mut reference)
}

// Ruby attr_atomic `attr_atomic(:reference)` at line 12.
pub fn ruby_atomic_markable_reference_l12_d2_reference(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('AtomicMarkableReference#reference= requires pair')
	}
	mut reference := markable_boundary_receiver(args)
	pair := markable_pair_from_value(args[1])
	return markable_pair_value(reference.set(pair.value, pair.mark), u64(voidptr(reference)), reference.snapshot().version)
}

// Ruby attr_atomic `attr_atomic(:reference)` at line 12.
pub fn ruby_atomic_markable_reference_l12_d3_compare_and_set_reference(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('compare_and_set_reference requires current and prospect pairs')
	}
	mut reference := markable_boundary_receiver(args)
	expected := MarkableSnapshot{
		pair: markable_pair_from_value(args[1])
		version: (args[1].attribute('version') or { return brew_runtime.bool_value(false) }).u64()
	}
	return brew_runtime.bool_value(reference.compare_and_set_snapshot(expected, markable_pair_from_value(args[2])))
}

// Ruby attr_atomic `attr_atomic(:reference)` at line 12.
pub fn ruby_atomic_markable_reference_l12_d4_swap_reference(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('swap_reference requires prospect pair')
	}
	mut reference := markable_boundary_receiver(args)
	old := reference.swap(markable_pair_from_value(args[1]))
	return markable_pair_value(old.pair, u64(voidptr(reference)), old.version)
}

// Ruby attr_atomic `attr_atomic(:reference)` at line 12.
pub fn ruby_atomic_markable_reference_l12_d5_update_reference(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('update_reference requires translated block result')
	}
	mut reference := markable_boundary_receiver(args)
	pair := markable_pair_from_value(args[1])
	return markable_pair_value(reference.set(pair.value, pair.mark), u64(voidptr(reference)), reference.snapshot().version)
}

// Ruby method `initialize(value = nil, mark = false)` at line 15.
pub fn ruby_atomic_markable_reference_l15_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	value := if args.len > 0 { args[0] } else { markable_nil_value() }
	mark := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	return markable_boundary_new(value, mark)
}

// Ruby method `compare_and_set(expected_val, new_val, expected_mark, new_mark)` at line 33.
pub fn ruby_atomic_markable_reference_l33_d7_compare_and_set(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 5 {
		panic('compare_and_set requires expected/new values and marks')
	}
	mut reference := markable_boundary_receiver(args)
	return brew_runtime.bool_value(reference.compare_and_set(args[1], args[2], args[3].as_bool() or {
		panic(err)
	}, args[4].as_bool() or { panic(err) }))
}

// Ruby alias_method `alias_method :compare_and_swap, :compare_and_set` at line 59.
pub fn ruby_atomic_markable_reference_l59_d8_compare_and_swap(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_atomic_markable_reference_l33_d7_compare_and_set(...args)
}

// Ruby method `get` at line 64.
pub fn ruby_atomic_markable_reference_l64_d9_get(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_atomic_markable_reference_l12_d1_reference(...args)
}

// Ruby method `value` at line 71.
pub fn ruby_atomic_markable_reference_l71_d10_value(args ...brew_runtime.Value) brew_runtime.Value {
	mut reference := markable_boundary_receiver(args)
	return reference.snapshot().pair.value
}

// Ruby method `mark` at line 78.
pub fn ruby_atomic_markable_reference_l78_d11_mark(args ...brew_runtime.Value) brew_runtime.Value {
	mut reference := markable_boundary_receiver(args)
	return brew_runtime.bool_value(reference.snapshot().pair.mark)
}

// Ruby alias_method `alias_method :marked?, :mark` at line 82.
pub fn ruby_atomic_markable_reference_l82_d12_marked(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_atomic_markable_reference_l78_d11_mark(...args)
}

// Ruby method `set(new_val, new_mark)` at line 91.
pub fn ruby_atomic_markable_reference_l91_d13_set(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('AtomicMarkableReference#set requires value and mark')
	}
	mut reference := markable_boundary_receiver(args)
	pair := reference.set(args[1], args[2].as_bool() or { panic(err) })
	return markable_pair_value(pair, u64(voidptr(reference)), reference.snapshot().version)
}

// Ruby method `update` at line 105.
pub fn ruby_atomic_markable_reference_l105_d14_update(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('AtomicMarkableReference#update requires translated value and mark')
	}
	return ruby_atomic_markable_reference_l91_d13_set(...args)
}

// Ruby method `try_update!` at line 128.
pub fn ruby_atomic_markable_reference_l128_d15_try_update(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('AtomicMarkableReference#try_update! requires translated value and mark')
	}
	return ruby_atomic_markable_reference_l91_d13_set(...args)
}

// Ruby method `try_update` at line 152.
pub fn ruby_atomic_markable_reference_l152_d16_try_update(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('AtomicMarkableReference#try_update requires translated value and mark')
	}
	return ruby_atomic_markable_reference_l91_d13_set(...args)
}

// Ruby method `immutable_array(*args)` at line 163.
pub fn ruby_atomic_markable_reference_l163_d17_immutable_array(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(args)
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
