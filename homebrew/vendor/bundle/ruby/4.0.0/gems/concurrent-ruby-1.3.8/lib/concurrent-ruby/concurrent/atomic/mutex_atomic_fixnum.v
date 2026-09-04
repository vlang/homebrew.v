module atomic

import ruby
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/mutex_atomic_fixnum.rb`.
// The original source is retained below until every stub has a typed V body.
pub type AtomicFixnumUpdate = fn(i64) !i64

const atomic_fixnum_min = i64(-4_611_686_018_427_387_904)
const atomic_fixnum_max = i64(4_611_686_018_427_387_903)

@[heap]
pub struct MutexAtomicFixnum {
mut:
	lock  sync.Mutex
	value i64
}

fn validate_atomic_fixnum(value i64) !i64 {
	if value < atomic_fixnum_min || value > atomic_fixnum_max {
		return error('${value} is outside the native integer range')
	}
	return value
}

pub fn new_mutex_atomic_fixnum(initial i64) !&MutexAtomicFixnum {
	validate_atomic_fixnum(initial)!
	return &MutexAtomicFixnum{
		value: initial
	}
}

pub fn (mut number MutexAtomicFixnum) get() i64 {
	number.lock.lock()
	defer {
		number.lock.unlock()
	}
	return number.value
}

pub fn (mut number MutexAtomicFixnum) set(value i64) !i64 {
	validate_atomic_fixnum(value)!
	number.lock.lock()
	number.value = value
	number.lock.unlock()
	return value
}

pub fn (mut number MutexAtomicFixnum) increment(delta i64) !i64 {
	validate_atomic_fixnum(delta)!
	number.lock.lock()
	defer {
		number.lock.unlock()
	}
	return number.set_locked(number.value + delta)
}

pub fn (mut number MutexAtomicFixnum) decrement(delta i64) !i64 {
	validate_atomic_fixnum(delta)!
	number.lock.lock()
	defer {
		number.lock.unlock()
	}
	return number.set_locked(number.value - delta)
}

fn (mut number MutexAtomicFixnum) set_locked(value i64) !i64 {
	validate_atomic_fixnum(value)!
	number.value = value
	return value
}

pub fn (mut number MutexAtomicFixnum) compare_and_set(expected i64, update i64) !bool {
	validate_atomic_fixnum(update)!
	number.lock.lock()
	defer {
		number.lock.unlock()
	}
	if number.value != expected {
		return false
	}
	number.value = update
	return true
}

pub fn (mut number MutexAtomicFixnum) update(action AtomicFixnumUpdate) !i64 {
	number.lock.lock()
	defer {
		number.lock.unlock()
	}
	return number.set_locked(action(number.value)!)
}

fn atomic_fixnum_boundary_new(initial i64) ruby.Value {
	number := new_mutex_atomic_fixnum(initial) or { panic(err) }
	return ruby.structured_value('Concurrent::MutexAtomicFixnum', '#<Concurrent::MutexAtomicFixnum>', {
		'atomic_fixnum_address': u64(voidptr(number)).str()
	})
}

fn atomic_fixnum_boundary_receiver(args []ruby.Value) &MutexAtomicFixnum {
	if args.len == 0 {
		panic('MutexAtomicFixnum method requires a receiver')
	}
	address := (args[0].attribute('atomic_fixnum_address') or {
		panic('${args[0].type_name} has no translated atomic fixnum state')
	}).u64()
	return unsafe { &MutexAtomicFixnum(voidptr(address)) }
}

fn atomic_fixnum_boundary_integer(value ruby.Value) i64 {
	return match value.type_name {
		'Integer' { value.as_int() or { panic(err) } }
		'Float' { i64(value.as_float() or { panic(err) }) }
		else { value.as_string().i64() }
	}
}

// Ruby method `initialize(initial = 0)` at line 13.
pub fn ruby_mutex_atomic_fixnum_l13_d1_initialize(args ...ruby.Value) ruby.Value {
	initial := if args.len > 0 { args[0].as_int() or { panic(err) } } else { i64(0) }
	return atomic_fixnum_boundary_new(initial)
}

// Ruby method `value` at line 20.
pub fn ruby_mutex_atomic_fixnum_l20_d2_value(args ...ruby.Value) ruby.Value {
	mut number := atomic_fixnum_boundary_receiver(args)
	return ruby.int_value(number.get())
}

// Ruby method `value=(value)` at line 25.
pub fn ruby_mutex_atomic_fixnum_l25_d3_value(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MutexAtomicFixnum#value= requires value')
	}
	mut number := atomic_fixnum_boundary_receiver(args)
	return ruby.int_value(number.set(args[1].as_int() or { panic(err) }) or { panic(err) })
}

// Ruby method `increment(delta = 1)` at line 30.
pub fn ruby_mutex_atomic_fixnum_l30_d4_increment(args ...ruby.Value) ruby.Value {
	mut number := atomic_fixnum_boundary_receiver(args)
	delta := if args.len > 1 { atomic_fixnum_boundary_integer(args[1]) } else { i64(1) }
	return ruby.int_value(number.increment(delta) or { panic(err) })
}

// Ruby alias_method `alias_method :up, :increment` at line 34.
pub fn ruby_mutex_atomic_fixnum_l34_d5_up(args ...ruby.Value) ruby.Value {
	return ruby_mutex_atomic_fixnum_l30_d4_increment(...args)
}

// Ruby method `decrement(delta = 1)` at line 37.
pub fn ruby_mutex_atomic_fixnum_l37_d6_decrement(args ...ruby.Value) ruby.Value {
	mut number := atomic_fixnum_boundary_receiver(args)
	delta := if args.len > 1 { atomic_fixnum_boundary_integer(args[1]) } else { i64(1) }
	return ruby.int_value(number.decrement(delta) or { panic(err) })
}

// Ruby alias_method `alias_method :down, :decrement` at line 41.
pub fn ruby_mutex_atomic_fixnum_l41_d7_down(args ...ruby.Value) ruby.Value {
	return ruby_mutex_atomic_fixnum_l37_d6_decrement(...args)
}

// Ruby method `compare_and_set(expect, update)` at line 44.
pub fn ruby_mutex_atomic_fixnum_l44_d8_compare_and_set(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('MutexAtomicFixnum#compare_and_set requires expected and update')
	}
	mut number := atomic_fixnum_boundary_receiver(args)
	return ruby.bool_value(number.compare_and_set(atomic_fixnum_boundary_integer(args[1]), atomic_fixnum_boundary_integer(args[2])) or { panic(err) })
}

// Ruby method `update` at line 56.
pub fn ruby_mutex_atomic_fixnum_l56_d9_update(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MutexAtomicFixnum#update requires translated block result')
	}
	mut number := atomic_fixnum_boundary_receiver(args)
	return ruby.int_value(number.set(args[1].as_int() or { panic(err) }) or { panic(err) })
}

// Ruby method `synchronize` at line 65.
pub fn ruby_mutex_atomic_fixnum_l65_d10_synchronize(args ...ruby.Value) ruby.Value {
	mut number := atomic_fixnum_boundary_receiver(args)
	number.lock.lock()
	value := if args.len > 1 { args[1] } else { ruby.int_value(number.value) }
	number.lock.unlock()
	return value
}

// Ruby method `ns_set(value)` at line 76.
pub fn ruby_mutex_atomic_fixnum_l76_d11_ns_set(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MutexAtomicFixnum#ns_set requires value')
	}
	mut number := atomic_fixnum_boundary_receiver(args)
	return ruby.int_value(number.set(args[1].as_int() or { panic(err) }) or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/safe_initialization'
// 2: require 'concurrent/utility/native_integer'
// 3:
// 4: module Concurrent
// 5:
// 6:   # @!macro atomic_fixnum
// 7:   # @!visibility private
// 8:   # @!macro internal_implementation_note
// 9:   class MutexAtomicFixnum
// 10:     extend Concurrent::Synchronization::SafeInitialization
// 11:
// 12:     # @!macro atomic_fixnum_method_initialize
// 13:     def initialize(initial = 0)
// 14:       super()
// 15:       @Lock = ::Mutex.new
// 16:       ns_set(initial)
// 17:     end
// 18:
// 19:     # @!macro atomic_fixnum_method_value_get
// 20:     def value
// 21:       synchronize { @value }
// 22:     end
// 23:
// 24:     # @!macro atomic_fixnum_method_value_set
// 25:     def value=(value)
// 26:       synchronize { ns_set(value) }
// 27:     end
// 28:
// 29:     # @!macro atomic_fixnum_method_increment
// 30:     def increment(delta = 1)
// 31:       synchronize { ns_set(@value + delta.to_i) }
// 32:     end
// 33:
// 34:     alias_method :up, :increment
// 35:
// 36:     # @!macro atomic_fixnum_method_decrement
// 37:     def decrement(delta = 1)
// 38:       synchronize { ns_set(@value - delta.to_i) }
// 39:     end
// 40:
// 41:     alias_method :down, :decrement
// 42:
// 43:     # @!macro atomic_fixnum_method_compare_and_set
// 44:     def compare_and_set(expect, update)
// 45:       synchronize do
// 46:         if @value == expect.to_i
// 47:           @value = update.to_i
// 48:           true
// 49:         else
// 50:           false
// 51:         end
// 52:       end
// 53:     end
// 54:
// 55:     # @!macro atomic_fixnum_method_update
// 56:     def update
// 57:       synchronize do
// 58:         @value = yield @value
// 59:       end
// 60:     end
// 61:
// 62:     protected
// 63:
// 64:     # @!visibility private
// 65:     def synchronize
// 66:       if @Lock.owned?
// 67:         yield
// 68:       else
// 69:         @Lock.synchronize { yield }
// 70:       end
// 71:     end
// 72:
// 73:     private
// 74:
// 75:     # @!visibility private
// 76:     def ns_set(value)
// 77:       Utility::NativeInteger.ensure_integer_and_bounds value
// 78:       @value = value
// 79:     end
// 80:   end
// 81: end
