module atomic

import ruby
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/mutex_atomic_boolean.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct MutexAtomicBoolean {
mut:
	lock  sync.Mutex
	value bool
}

pub fn new_mutex_atomic_boolean(initial bool) &MutexAtomicBoolean {
	return &MutexAtomicBoolean{
		value: initial
	}
}

pub fn (mut flag MutexAtomicBoolean) get() bool {
	flag.lock.lock()
	defer {
		flag.lock.unlock()
	}
	return flag.value
}

pub fn (mut flag MutexAtomicBoolean) set(value bool) bool {
	flag.lock.lock()
	flag.value = value
	flag.lock.unlock()
	return value
}

pub fn (mut flag MutexAtomicBoolean) make(value bool) bool {
	flag.lock.lock()
	changed := flag.value != value
	flag.value = value
	flag.lock.unlock()
	return changed
}

fn atomic_boolean_boundary_truthy(value ruby.Value) bool {
	if value.type_name == 'NilClass' {
		return false
	}
	if value.type_name == 'Bool' {
		return value.as_bool() or { false }
	}
	return true
}

fn mutex_atomic_boolean_boundary_new(initial bool) ruby.Value {
	flag := new_mutex_atomic_boolean(initial)
	return ruby.structured_value('Concurrent::MutexAtomicBoolean', '#<Concurrent::MutexAtomicBoolean>', {
		'atomic_boolean_address': u64(voidptr(flag)).str()
	})
}

fn mutex_atomic_boolean_boundary_receiver(args []ruby.Value) &MutexAtomicBoolean {
	if args.len == 0 {
		panic('MutexAtomicBoolean method requires a receiver')
	}
	address := (args[0].attribute('atomic_boolean_address') or {
		panic('${args[0].type_name} has no translated atomic boolean state')
	}).u64()
	return unsafe { &MutexAtomicBoolean(voidptr(address)) }
}

// Ruby method `initialize(initial = false)` at line 12.
pub fn ruby_mutex_atomic_boolean_l12_d1_initialize(args ...ruby.Value) ruby.Value {
	initial := if args.len > 0 { atomic_boolean_boundary_truthy(args[0]) } else { false }
	return mutex_atomic_boolean_boundary_new(initial)
}

// Ruby method `value` at line 19.
pub fn ruby_mutex_atomic_boolean_l19_d2_value(args ...ruby.Value) ruby.Value {
	mut flag := mutex_atomic_boolean_boundary_receiver(args)
	return ruby.bool_value(flag.get())
}

// Ruby method `value=(value)` at line 24.
pub fn ruby_mutex_atomic_boolean_l24_d3_value(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MutexAtomicBoolean#value= requires value')
	}
	mut flag := mutex_atomic_boolean_boundary_receiver(args)
	return ruby.bool_value(flag.set(atomic_boolean_boundary_truthy(args[1])))
}

// Ruby method `true?` at line 29.
pub fn ruby_mutex_atomic_boolean_l29_d4_true(args ...ruby.Value) ruby.Value {
	return ruby_mutex_atomic_boolean_l19_d2_value(...args)
}

// Ruby method `false?` at line 34.
pub fn ruby_mutex_atomic_boolean_l34_d5_false(args ...ruby.Value) ruby.Value {
	mut flag := mutex_atomic_boolean_boundary_receiver(args)
	return ruby.bool_value(!flag.get())
}

// Ruby method `make_true` at line 39.
pub fn ruby_mutex_atomic_boolean_l39_d6_make_true(args ...ruby.Value) ruby.Value {
	mut flag := mutex_atomic_boolean_boundary_receiver(args)
	return ruby.bool_value(flag.make(true))
}

// Ruby method `make_false` at line 44.
pub fn ruby_mutex_atomic_boolean_l44_d7_make_false(args ...ruby.Value) ruby.Value {
	mut flag := mutex_atomic_boolean_boundary_receiver(args)
	return ruby.bool_value(flag.make(false))
}

// Ruby method `synchronize` at line 51.
pub fn ruby_mutex_atomic_boolean_l51_d8_synchronize(args ...ruby.Value) ruby.Value {
	mut flag := mutex_atomic_boolean_boundary_receiver(args)
	flag.lock.lock()
	value := if args.len > 1 { args[1] } else { ruby.bool_value(flag.value) }
	flag.lock.unlock()
	return value
}

// Ruby method `ns_make_value(value)` at line 62.
pub fn ruby_mutex_atomic_boolean_l62_d9_ns_make_value(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('MutexAtomicBoolean#ns_make_value requires value')
	}
	mut flag := mutex_atomic_boolean_boundary_receiver(args)
	return ruby.bool_value(flag.make(atomic_boolean_boundary_truthy(args[1])))
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/safe_initialization'
// 2:
// 3: module Concurrent
// 4:
// 5:   # @!macro atomic_boolean
// 6:   # @!visibility private
// 7:   # @!macro internal_implementation_note
// 8:   class MutexAtomicBoolean
// 9:     extend Concurrent::Synchronization::SafeInitialization
// 10:
// 11:     # @!macro atomic_boolean_method_initialize
// 12:     def initialize(initial = false)
// 13:       super()
// 14:       @Lock = ::Mutex.new
// 15:       @value = !!initial
// 16:     end
// 17:
// 18:     # @!macro atomic_boolean_method_value_get
// 19:     def value
// 20:       synchronize { @value }
// 21:     end
// 22:
// 23:     # @!macro atomic_boolean_method_value_set
// 24:     def value=(value)
// 25:       synchronize { @value = !!value }
// 26:     end
// 27:
// 28:     # @!macro atomic_boolean_method_true_question
// 29:     def true?
// 30:       synchronize { @value }
// 31:     end
// 32:
// 33:     # @!macro atomic_boolean_method_false_question
// 34:     def false?
// 35:       synchronize { !@value }
// 36:     end
// 37:
// 38:     # @!macro atomic_boolean_method_make_true
// 39:     def make_true
// 40:       synchronize { ns_make_value(true) }
// 41:     end
// 42:
// 43:     # @!macro atomic_boolean_method_make_false
// 44:     def make_false
// 45:       synchronize { ns_make_value(false) }
// 46:     end
// 47:
// 48:     protected
// 49:
// 50:     # @!visibility private
// 51:     def synchronize
// 52:       if @Lock.owned?
// 53:         yield
// 54:       else
// 55:         @Lock.synchronize { yield }
// 56:       end
// 57:     end
// 58:
// 59:     private
// 60:
// 61:     # @!visibility private
// 62:     def ns_make_value(value)
// 63:       old = @value
// 64:       @value = value
// 65:       old != @value
// 66:     end
// 67:   end
// 68: end
