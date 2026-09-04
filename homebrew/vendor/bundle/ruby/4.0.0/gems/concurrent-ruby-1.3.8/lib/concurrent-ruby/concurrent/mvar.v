module concurrent

import ruby
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/mvar.rb`.
// The original source is retained below until every stub has a typed V body.
pub type MVarTransform = fn(ruby.Value) !ruby.Value

pub type MVarBorrow = fn(ruby.Value) !ruby.Value

pub type MVarCopy = fn(ruby.Value) ruby.Value

pub type MVarSynchronized = fn() !ruby.Value

pub enum MVarResultKind {
	value
	empty
	timeout
}

pub struct MVarResult {
pub:
	kind  MVarResultKind
	value ruby.Value
}

pub struct MVarOptions {
pub:
	dup_on_deref    bool
	freeze_on_deref bool
	copy_on_deref   ?MVarCopy
}

@[heap]
struct MVarState {
	mutex           &sync.Mutex
	empty_condition &sync.Cond
	full_condition  &sync.Cond
	options         MVarOptions
mut:
	value     ruby.Value
	has_value bool
}

@[heap]
pub struct MVar {
mut:
	state &MVarState
}

fn mvar_empty_value() ruby.Value {
	return ruby.object_value('Concurrent::MVar::EMPTY', '#<Object:Concurrent::MVar::EMPTY>')
}

fn mvar_timeout_value() ruby.Value {
	return ruby.object_value('Concurrent::MVar::TIMEOUT', '#<Object:Concurrent::MVar::TIMEOUT>')
}

fn mvar_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn mvar_is_empty_sentinel(value ruby.Value) bool {
	return value.type_name == 'Concurrent::MVar::EMPTY'
}

fn mvar_duplicate_value(value ruby.Value) ruby.Value {
	return ruby.Value{
		type_name: value.type_name
		repr: value.repr
		bool_data: value.bool_data
		int_data: value.int_data
		float_data: value.float_data
		string_array_data: value.string_array_data.clone()
		array_data: value.array_data.clone()
		map_data: value.map_data.clone()
		attributes: value.attributes.clone()
	}
}

fn mvar_apply_deref_options(value ruby.Value, options MVarOptions) ruby.Value {
	if value.type_name == 'NilClass' || mvar_is_empty_sentinel(value) {
		return value
	}
	mut result := value
	if copy_fn := options.copy_on_deref {
		result = copy_fn(result)
	}
	if options.dup_on_deref {
		result = mvar_duplicate_value(result)
	}
	// Boundary values are immutable, so Ruby's freeze operation is already
	// satisfied after the copy and duplicate operations above.
	return result
}

pub fn new_mvar(initial ?ruby.Value, options MVarOptions) &MVar {
	mutex := sync.new_mutex()
	if value := initial {
		return &MVar{
			state: &MVarState{
				mutex: mutex
				empty_condition: sync.new_cond(mutex)
				full_condition: sync.new_cond(mutex)
				options: options
				value: value
				has_value: !mvar_is_empty_sentinel(value)
			}
		}
	}
	return &MVar{
		state: &MVarState{
			mutex: mutex
			empty_condition: sync.new_cond(mutex)
			full_condition: sync.new_cond(mutex)
			options: options
			value: mvar_empty_value()
		}
	}
}

fn (mut mvar MVar) wait_locked(for_full bool, timeout ?time.Duration) bool {
	condition_holds := fn [mut mvar, for_full] () bool {
		return if for_full { !mvar.state.has_value } else { mvar.state.has_value }
	}
	if duration := timeout {
		deadline := time.sys_mono_now() + u64(if duration > 0 { duration } else { 0 })
		for condition_holds() {
			now := time.sys_mono_now()
			if now >= deadline {
				return false
			}
			remaining := deadline - now
			sleep_for := if remaining < u64(time.millisecond) {
				time.Duration(remaining)
			} else {
				time.millisecond
			}
			mvar.state.mutex.unlock()
			time.sleep(sleep_for)
			mvar.state.mutex.lock()
		}
		return true
	}
	condition := if for_full { mvar.state.full_condition } else { mvar.state.empty_condition }
	for condition_holds() {
		condition.wait()
	}
	return true
}

pub fn (mut mvar MVar) take(timeout ?time.Duration) MVarResult {
	mvar.state.mutex.lock()
	defer {
		mvar.state.mutex.unlock()
	}
	if !mvar.wait_locked(true, timeout) || !mvar.state.has_value {
		return MVarResult{ kind: .timeout, value: mvar_timeout_value() }
	}
	value := mvar.state.value
	mvar.state.value = mvar_empty_value()
	mvar.state.has_value = false
	mvar.state.empty_condition.signal()
	return MVarResult{ kind: .value, value: mvar_apply_deref_options(value, mvar.state.options) }
}

pub fn (mut mvar MVar) borrow(timeout ?time.Duration, block MVarBorrow) MVarResult {
	mvar.state.mutex.lock()
	defer {
		mvar.state.mutex.unlock()
	}
	if !mvar.wait_locked(true, timeout) || !mvar.state.has_value {
		return MVarResult{ kind: .timeout, value: mvar_timeout_value() }
	}
	value := block(mvar.state.value) or { panic(err) }
	return MVarResult{ kind: .value, value: value }
}

pub fn (mut mvar MVar) borrow_value(timeout ?time.Duration) MVarResult {
	return mvar.borrow(timeout, fn (value ruby.Value) !ruby.Value {
		return value
	})
}

pub fn (mut mvar MVar) put(value ruby.Value, timeout ?time.Duration) MVarResult {
	mvar.state.mutex.lock()
	defer {
		mvar.state.mutex.unlock()
	}
	if !mvar.wait_locked(false, timeout) || mvar.state.has_value {
		return MVarResult{ kind: .timeout, value: mvar_timeout_value() }
	}
	mvar.state.value = value
	mvar.state.has_value = !mvar_is_empty_sentinel(value)
	mvar.state.full_condition.signal()
	return MVarResult{ kind: .value, value: mvar_apply_deref_options(value, mvar.state.options) }
}

pub fn (mut mvar MVar) modify(timeout ?time.Duration, block MVarTransform) MVarResult {
	mvar.state.mutex.lock()
	defer {
		mvar.state.mutex.unlock()
	}
	if !mvar.wait_locked(true, timeout) || !mvar.state.has_value {
		return MVarResult{ kind: .timeout, value: mvar_timeout_value() }
	}
	old_value := mvar.state.value
	new_value := block(old_value) or { panic(err) }
	mvar.state.value = new_value
	mvar.state.has_value = !mvar_is_empty_sentinel(new_value)
	mvar.state.full_condition.signal()
	return MVarResult{ kind: .value, value: mvar_apply_deref_options(old_value, mvar.state.options) }
}

pub fn (mut mvar MVar) modify_to(timeout ?time.Duration, prospect ruby.Value) MVarResult {
	return mvar.modify(timeout, fn [prospect] (_ ruby.Value) !ruby.Value {
		return prospect
	})
}

pub fn (mut mvar MVar) try_take() MVarResult {
	mvar.state.mutex.lock()
	defer {
		mvar.state.mutex.unlock()
	}
	if !mvar.state.has_value {
		return MVarResult{ kind: .empty, value: mvar_empty_value() }
	}
	value := mvar.state.value
	mvar.state.value = mvar_empty_value()
	mvar.state.has_value = false
	mvar.state.empty_condition.signal()
	return MVarResult{ kind: .value, value: mvar_apply_deref_options(value, mvar.state.options) }
}

pub fn (mut mvar MVar) try_put(value ruby.Value) bool {
	mvar.state.mutex.lock()
	defer {
		mvar.state.mutex.unlock()
	}
	if mvar.state.has_value {
		return false
	}
	mvar.state.value = value
	mvar.state.has_value = !mvar_is_empty_sentinel(value)
	mvar.state.full_condition.signal()
	return true
}

pub fn (mut mvar MVar) set(value ruby.Value) MVarResult {
	mvar.state.mutex.lock()
	old_value := mvar.state.value
	old_kind := if mvar.state.has_value { MVarResultKind.value } else { MVarResultKind.empty }
	mvar.state.value = value
	mvar.state.has_value = !mvar_is_empty_sentinel(value)
	mvar.state.full_condition.signal()
	mvar.state.mutex.unlock()
	return MVarResult{ kind: old_kind, value: mvar_apply_deref_options(old_value, mvar.state.options) }
}

pub fn (mut mvar MVar) modify_now(block MVarTransform) MVarResult {
	mvar.state.mutex.lock()
	old_value := mvar.state.value
	old_kind := if mvar.state.has_value { MVarResultKind.value } else { MVarResultKind.empty }
	new_value := block(old_value) or {
		mvar.state.mutex.unlock()
		panic(err)
	}
	mvar.state.value = new_value
	mvar.state.has_value = !mvar_is_empty_sentinel(new_value)
	if mvar.state.has_value {
		mvar.state.full_condition.signal()
	} else {
		mvar.state.empty_condition.signal()
	}
	mvar.state.mutex.unlock()
	return MVarResult{ kind: old_kind, value: mvar_apply_deref_options(old_value, mvar.state.options) }
}

pub fn (mut mvar MVar) modify_now_to(prospect ruby.Value) MVarResult {
	return mvar.modify_now(fn [prospect] (_ ruby.Value) !ruby.Value {
		return prospect
	})
}

pub fn (mut mvar MVar) empty() bool {
	mvar.state.mutex.lock()
	is_empty := !mvar.state.has_value
	mvar.state.mutex.unlock()
	return is_empty
}

pub fn (mut mvar MVar) full() bool {
	return !mvar.empty()
}

pub fn (mut mvar MVar) value() MVarResult {
	mvar.state.mutex.lock()
	defer {
		mvar.state.mutex.unlock()
	}
	if !mvar.state.has_value {
		return MVarResult{ kind: .empty, value: mvar_empty_value() }
	}
	return MVarResult{ kind: .value, value: mvar_apply_deref_options(mvar.state.value, mvar.state.options) }
}

pub fn (mut mvar MVar) synchronize(block MVarSynchronized) !ruby.Value {
	mvar.state.mutex.lock()
	defer {
		mvar.state.mutex.unlock()
	}
	return block()
}

fn mvar_options_from_value(value ruby.Value) MVarOptions {
	if value.type_name != 'Hash' {
		return MVarOptions{}
	}
	options := value.as_map() or { return MVarOptions{} }
	dup_on_deref := if 'dup_on_deref' in options {
		options['dup_on_deref'].as_bool() or { false }
	} else if 'dup' in options {
		options['dup'].as_bool() or { false }
	} else {
		false
	}
	freeze_on_deref := if 'freeze_on_deref' in options {
		options['freeze_on_deref'].as_bool() or { false }
	} else if 'freeze' in options {
		options['freeze'].as_bool() or { false }
	} else {
		false
	}
	return MVarOptions{ dup_on_deref: dup_on_deref, freeze_on_deref: freeze_on_deref }
}

fn mvar_boundary_timeout(args []ruby.Value, index int) ?time.Duration {
	if index >= args.len || args[index].type_name == 'NilClass' {
		return none
	}
	seconds := args[index].as_float() or { panic(err) }
	return time.Duration(seconds * f64(time.second))
}

fn mvar_boundary_value(mvar &MVar) ruby.Value {
	return ruby.structured_value('Concurrent::MVar', '#<Concurrent::MVar>', {
		'mvar_address': u64(voidptr(mvar)).str()
	})
}

fn mvar_boundary_receiver(args []ruby.Value) &MVar {
	if args.len == 0 {
		panic('MVar method requires a receiver')
	}
	address := (args[0].attribute('mvar_address') or {
		panic('${args[0].type_name} has no translated MVar state')
	}).u64()
	return unsafe { &MVar(voidptr(address)) }
}

// Ruby method `initialize(value = EMPTY, opts = {})` at line 54.
pub fn ruby_mvar_l54_d1_initialize(args ...ruby.Value) ruby.Value {
	initial := if args.len > 0 { ?ruby.Value(args[0]) } else { ?ruby.Value(none) }
	options := if args.len > 1 { mvar_options_from_value(args[1]) } else { MVarOptions{} }
	return mvar_boundary_value(new_mvar(initial, options))
}

// Ruby method `take(timeout = nil)` at line 66.
pub fn ruby_mvar_l66_d2_take(args ...ruby.Value) ruby.Value {
	mut mvar := mvar_boundary_receiver(args)
	return mvar.take(mvar_boundary_timeout(args, 1)).value
}

// Ruby method `borrow(timeout = nil)` at line 86.
pub fn ruby_mvar_l86_d3_borrow(args ...ruby.Value) ruby.Value {
	mut mvar := mvar_boundary_receiver(args)
	result := mvar.borrow_value(mvar_boundary_timeout(args, 1))
	if result.kind == .timeout {
		return result.value
	}
	return if args.len > 2 { args[2] } else { result.value }
}

// Ruby method `put(value, timeout = nil)` at line 103.
pub fn ruby_mvar_l103_d4_put(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MVar#put requires a value')
	}
	mut mvar := mvar_boundary_receiver(args)
	return mvar.put(args[1], mvar_boundary_timeout(args, 2)).value
}

// Ruby method `modify(timeout = nil)` at line 123.
pub fn ruby_mvar_l123_d5_modify(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('MVar#modify requires a translated block result')
	}
	mut mvar := mvar_boundary_receiver(args)
	return mvar.modify_to(mvar_boundary_timeout(args, 1), args[2]).value
}

// Ruby method `try_take!` at line 142.
pub fn ruby_mvar_l142_d6_try_take(args ...ruby.Value) ruby.Value {
	mut mvar := mvar_boundary_receiver(args)
	return mvar.try_take().value
}

// Ruby method `try_put!(value)` at line 156.
pub fn ruby_mvar_l156_d7_try_put(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MVar#try_put! requires a value')
	}
	mut mvar := mvar_boundary_receiver(args)
	return ruby.bool_value(mvar.try_put(args[1]))
}

// Ruby method `set!(value)` at line 169.
pub fn ruby_mvar_l169_d8_set(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MVar#set! requires a value')
	}
	mut mvar := mvar_boundary_receiver(args)
	return mvar.set(args[1]).value
}

// Ruby method `modify!` at line 179.
pub fn ruby_mvar_l179_d9_modify(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MVar#modify! requires a translated block result')
	}
	mut mvar := mvar_boundary_receiver(args)
	return mvar.modify_now_to(args[1]).value
}

// Ruby method `empty?` at line 195.
pub fn ruby_mvar_l195_d10_empty(args ...ruby.Value) ruby.Value {
	mut mvar := mvar_boundary_receiver(args)
	return ruby.bool_value(mvar.empty())
}

// Ruby method `full?` at line 200.
pub fn ruby_mvar_l200_d11_full(args ...ruby.Value) ruby.Value {
	mut mvar := mvar_boundary_receiver(args)
	return ruby.bool_value(mvar.full())
}

// Ruby method `synchronize(&block)` at line 206.
pub fn ruby_mvar_l206_d12_synchronize(args ...ruby.Value) ruby.Value {
	// The typed `synchronize` method accepts a V callback. The generic boundary
	// preserves Ruby's block result as its final translated argument.
	mut mvar := mvar_boundary_receiver(args)
	value := if args.len > 1 { args[args.len - 1] } else { mvar_nil_value() }
	return mvar.synchronize(fn [value] () !ruby.Value {
		return value
	}) or { panic(err) }
}

// Ruby method `unlocked_empty?` at line 212.
pub fn ruby_mvar_l212_d13_unlocked_empty(args ...ruby.Value) ruby.Value {
	mut mvar := mvar_boundary_receiver(args)
	return ruby.bool_value(mvar.empty())
}

// Ruby method `unlocked_full?` at line 216.
pub fn ruby_mvar_l216_d14_unlocked_full(args ...ruby.Value) ruby.Value {
	mut mvar := mvar_boundary_receiver(args)
	return ruby.bool_value(mvar.full())
}

// Ruby method `wait_for_full(timeout)` at line 220.
pub fn ruby_mvar_l220_d15_wait_for_full(args ...ruby.Value) ruby.Value {
	mut mvar := mvar_boundary_receiver(args)
	mvar.state.mutex.lock()
	mvar.wait_locked(true, mvar_boundary_timeout(args, 1))
	mvar.state.mutex.unlock()
	return mvar_nil_value()
}

// Ruby method `wait_for_empty(timeout)` at line 224.
pub fn ruby_mvar_l224_d16_wait_for_empty(args ...ruby.Value) ruby.Value {
	mut mvar := mvar_boundary_receiver(args)
	mvar.state.mutex.lock()
	mvar.wait_locked(false, mvar_boundary_timeout(args, 1))
	mvar.state.mutex.unlock()
	return mvar_nil_value()
}

// Ruby method `wait_while(condition, timeout)` at line 228.
pub fn ruby_mvar_l228_d17_wait_while(args ...ruby.Value) ruby.Value {
	mut mvar := mvar_boundary_receiver(args)
	for_full := if args.len > 1 { args[1].as_string() != 'empty' } else { true }
	mvar.state.mutex.lock()
	mvar.wait_locked(for_full, mvar_boundary_timeout(args, 2))
	mvar.state.mutex.unlock()
	return mvar_nil_value()
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/concern/dereferenceable'
// 2: require 'concurrent/synchronization/object'
// 3:
// 4: module Concurrent
// 5:
// 6:   # An `MVar` is a synchronized single element container. They are empty or
// 7:   # contain one item. Taking a value from an empty `MVar` blocks, as does
// 8:   # putting a value into a full one. You can either think of them as blocking
// 9:   # queue of length one, or a special kind of mutable variable.
// 10:   #
// 11:   # On top of the fundamental `#put` and `#take` operations, we also provide a
// 12:   # `#modify` that is atomic with respect to operations on the same instance.
// 13:   # These operations all support timeouts.
// 14:   #
// 15:   # We also support non-blocking operations `#try_put!` and `#try_take!`, a
// 16:   # `#set!` that ignores existing values, a `#value` that returns the value
// 17:   # without removing it or returns `MVar::EMPTY`, and a `#modify!` that yields
// 18:   # `MVar::EMPTY` if the `MVar` is empty and can be used to set `MVar::EMPTY`.
// 19:   # You shouldn't use these operations in the first instance.
// 20:   #
// 21:   # `MVar` is a [Dereferenceable](Dereferenceable).
// 22:   #
// 23:   # `MVar` is related to M-structures in Id, `MVar` in Haskell and `SyncVar` in Scala.
// 24:   #
// 25:   # Note that unlike the original Haskell paper, our `#take` is blocking. This is how
// 26:   # Haskell and Scala do it today.
// 27:   #
// 28:   # @!macro copy_options
// 29:   #
// 30:   # ## See Also
// 31:   #
// 32:   # 1. P. Barth, R. Nikhil, and Arvind. [M-Structures: Extending a parallel, non- strict, functional language with state](http://dl.acm.org/citation.cfm?id=652538). In Proceedings of the 5th
// 33:   #    ACM Conference on Functional Programming Languages and Computer Architecture (FPCA), 1991.
// 34:   #
// 35:   # 2. S. Peyton Jones, A. Gordon, and S. Finne. [Concurrent Haskell](http://dl.acm.org/citation.cfm?id=237794).
// 36:   #    In Proceedings of the 23rd Symposium on Principles of Programming Languages
// 37:   #    (PoPL), 1996.
// 38:   class MVar < Synchronization::Object
// 39:     include Concern::Dereferenceable
// 40:     safe_initialization!
// 41:
// 42:     # Unique value that represents that an `MVar` was empty
// 43:     EMPTY = ::Object.new
// 44:
// 45:     # Unique value that represents that an `MVar` timed out before it was able
// 46:     # to produce a value.
// 47:     TIMEOUT = ::Object.new
// 48:
// 49:     # Create a new `MVar`, either empty or with an initial value.
// 50:     #
// 51:     # @param [Hash] opts the options controlling how the future will be processed
// 52:     #
// 53:     # @!macro deref_options
// 54:     def initialize(value = EMPTY, opts = {})
// 55:       @value = value
// 56:       @mutex = Mutex.new
// 57:       @empty_condition = ConditionVariable.new
// 58:       @full_condition = ConditionVariable.new
// 59:       set_deref_options(opts)
// 60:     end
// 61:
// 62:     # Remove the value from an `MVar`, leaving it empty, and blocking if there
// 63:     # isn't a value. A timeout can be set to limit the time spent blocked, in
// 64:     # which case it returns `TIMEOUT` if the time is exceeded.
// 65:     # @return [Object] the value that was taken, or `TIMEOUT`
// 66:     def take(timeout = nil)
// 67:       @mutex.synchronize do
// 68:         wait_for_full(timeout)
// 69:
// 70:         # If we timed out we'll still be empty
// 71:         if unlocked_full?
// 72:           value = @value
// 73:           @value = EMPTY
// 74:           @empty_condition.signal
// 75:           apply_deref_options(value)
// 76:         else
// 77:           TIMEOUT
// 78:         end
// 79:       end
// 80:     end
// 81:
// 82:     # acquires lock on the from an `MVAR`, yields the value to provided block,
// 83:     # and release lock. A timeout can be set to limit the time spent blocked,
// 84:     # in which case it returns `TIMEOUT` if the time is exceeded.
// 85:     # @return [Object] the value returned by the block, or `TIMEOUT`
// 86:     def borrow(timeout = nil)
// 87:       @mutex.synchronize do
// 88:         wait_for_full(timeout)
// 89:
// 90:         # If we timed out we'll still be empty
// 91:         if unlocked_full?
// 92:           yield @value
// 93:         else
// 94:           TIMEOUT
// 95:         end
// 96:       end
// 97:     end
// 98:
// 99:     # Put a value into an `MVar`, blocking if there is already a value until
// 100:     # it is empty. A timeout can be set to limit the time spent blocked, in
// 101:     # which case it returns `TIMEOUT` if the time is exceeded.
// 102:     # @return [Object] the value that was put, or `TIMEOUT`
// 103:     def put(value, timeout = nil)
// 104:       @mutex.synchronize do
// 105:         wait_for_empty(timeout)
// 106:
// 107:         # If we timed out we won't be empty
// 108:         if unlocked_empty?
// 109:           @value = value
// 110:           @full_condition.signal
// 111:           apply_deref_options(value)
// 112:         else
// 113:           TIMEOUT
// 114:         end
// 115:       end
// 116:     end
// 117:
// 118:     # Atomically `take`, yield the value to a block for transformation, and then
// 119:     # `put` the transformed value. Returns the pre-transform value. A timeout can
// 120:     # be set to limit the time spent blocked, in which case it returns `TIMEOUT`
// 121:     # if the time is exceeded.
// 122:     # @return [Object] the pre-transform value, or `TIMEOUT`
// 123:     def modify(timeout = nil)
// 124:       raise ArgumentError.new('no block given') unless block_given?
// 125:
// 126:       @mutex.synchronize do
// 127:         wait_for_full(timeout)
// 128:
// 129:         # If we timed out we'll still be empty
// 130:         if unlocked_full?
// 131:           value = @value
// 132:           @value = yield value
// 133:           @full_condition.signal
// 134:           apply_deref_options(value)
// 135:         else
// 136:           TIMEOUT
// 137:         end
// 138:       end
// 139:     end
// 140:
// 141:     # Non-blocking version of `take`, that returns `EMPTY` instead of blocking.
// 142:     def try_take!
// 143:       @mutex.synchronize do
// 144:         if unlocked_full?
// 145:           value = @value
// 146:           @value = EMPTY
// 147:           @empty_condition.signal
// 148:           apply_deref_options(value)
// 149:         else
// 150:           EMPTY
// 151:         end
// 152:       end
// 153:     end
// 154:
// 155:     # Non-blocking version of `put`, that returns whether or not it was successful.
// 156:     def try_put!(value)
// 157:       @mutex.synchronize do
// 158:         if unlocked_empty?
// 159:           @value = value
// 160:           @full_condition.signal
// 161:           true
// 162:         else
// 163:           false
// 164:         end
// 165:       end
// 166:     end
// 167:
// 168:     # Non-blocking version of `put` that will overwrite an existing value.
// 169:     def set!(value)
// 170:       @mutex.synchronize do
// 171:         old_value = @value
// 172:         @value = value
// 173:         @full_condition.signal
// 174:         apply_deref_options(old_value)
// 175:       end
// 176:     end
// 177:
// 178:     # Non-blocking version of `modify` that will yield with `EMPTY` if there is no value yet.
// 179:     def modify!
// 180:       raise ArgumentError.new('no block given') unless block_given?
// 181:
// 182:       @mutex.synchronize do
// 183:         value = @value
// 184:         @value = yield value
// 185:         if unlocked_empty?
// 186:           @empty_condition.signal
// 187:         else
// 188:           @full_condition.signal
// 189:         end
// 190:         apply_deref_options(value)
// 191:       end
// 192:     end
// 193:
// 194:     # Returns if the `MVar` is currently empty.
// 195:     def empty?
// 196:       @mutex.synchronize { @value == EMPTY }
// 197:     end
// 198:
// 199:     # Returns if the `MVar` currently contains a value.
// 200:     def full?
// 201:       !empty?
// 202:     end
// 203:
// 204:     protected
// 205:
// 206:     def synchronize(&block)
// 207:       @mutex.synchronize(&block)
// 208:     end
// 209:
// 210:     private
// 211:
// 212:     def unlocked_empty?
// 213:       @value == EMPTY
// 214:     end
// 215:
// 216:     def unlocked_full?
// 217:       ! unlocked_empty?
// 218:     end
// 219:
// 220:     def wait_for_full(timeout)
// 221:       wait_while(@full_condition, timeout) { unlocked_empty? }
// 222:     end
// 223:
// 224:     def wait_for_empty(timeout)
// 225:       wait_while(@empty_condition, timeout) { unlocked_full? }
// 226:     end
// 227:
// 228:     def wait_while(condition, timeout)
// 229:       if timeout.nil?
// 230:         while yield
// 231:           condition.wait(@mutex)
// 232:         end
// 233:       else
// 234:         stop = Concurrent.monotonic_time + timeout
// 235:         while yield && timeout > 0.0
// 236:           condition.wait(@mutex, timeout)
// 237:           timeout = stop - Concurrent.monotonic_time
// 238:         end
// 239:       end
// 240:     end
// 241:   end
// 242: end
