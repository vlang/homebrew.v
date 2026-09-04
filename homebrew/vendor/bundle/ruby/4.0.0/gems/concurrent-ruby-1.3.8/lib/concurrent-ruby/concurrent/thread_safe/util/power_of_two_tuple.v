module util

import ruby
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/thread_safe/util/power_of_two_tuple.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct PowerOfTwoTuple {
pub:
	size int
mut:
	lock   sync.RwMutex
	values []ruby.Value
	set    []bool
}

pub fn new_power_of_two_tuple(size int) !&PowerOfTwoTuple {
	if size <= 0 || (size & (size - 1)) != 0 {
		return error('size must be a power of 2 (${size} provided)')
	}
	return &PowerOfTwoTuple{
		size: size
		values: []ruby.Value{len: size}
		set: []bool{len: size}
	}
}

pub fn (tuple &PowerOfTwoTuple) hash_to_index(hash i64) int {
	return int((i64(tuple.size) - 1) & hash)
}

pub fn (mut tuple PowerOfTwoTuple) get_by_hash(hash i64) ?ruby.Value {
	index := tuple.hash_to_index(hash)
	tuple.lock.rlock()
	defer {
		tuple.lock.runlock()
	}
	if !tuple.set[index] {
		return none
	}
	return tuple.values[index]
}

pub fn (mut tuple PowerOfTwoTuple) set_by_hash(hash i64, value ruby.Value) ruby.Value {
	index := tuple.hash_to_index(hash)
	tuple.lock.lock()
	tuple.values[index] = value
	tuple.set[index] = true
	tuple.lock.unlock()
	return value
}

pub fn (tuple &PowerOfTwoTuple) next_in_size_table() !&PowerOfTwoTuple {
	return new_power_of_two_tuple(tuple.size * 2)
}

fn power_tuple_boundary_new(size int) ruby.Value {
	tuple := new_power_of_two_tuple(size) or { panic(err) }
	return ruby.structured_value('Concurrent::ThreadSafe::Util::PowerOfTwoTuple', '#<Concurrent::ThreadSafe::Util::PowerOfTwoTuple>', {
		'power_tuple_address': u64(voidptr(tuple)).str()
		'size':                size.str()
	})
}

fn power_tuple_boundary_receiver(args []ruby.Value) &PowerOfTwoTuple {
	if args.len == 0 {
		panic('PowerOfTwoTuple method requires a receiver')
	}
	address := (args[0].attribute('power_tuple_address') or {
		panic('${args[0].type_name} has no translated PowerOfTwoTuple state')
	}).u64()
	return unsafe { &PowerOfTwoTuple(voidptr(address)) }
}

// Ruby method `initialize(size)` at line 15.
pub fn ruby_power_of_two_tuple_l15_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('PowerOfTwoTuple#initialize requires size')
	}
	return power_tuple_boundary_new(int(args[0].as_int() or { panic(err) }))
}

// Ruby method `hash_to_index(hash)` at line 20.
pub fn ruby_power_of_two_tuple_l20_d2_hash_to_index(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('PowerOfTwoTuple#hash_to_index requires hash')
	}
	tuple := power_tuple_boundary_receiver(args)
	return ruby.int_value(tuple.hash_to_index(args[1].as_int() or { panic(err) }))
}

// Ruby method `volatile_get_by_hash(hash)` at line 24.
pub fn ruby_power_of_two_tuple_l24_d3_volatile_get_by_hash(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('PowerOfTwoTuple#volatile_get_by_hash requires hash')
	}
	mut tuple := power_tuple_boundary_receiver(args)
	return tuple.get_by_hash(args[1].as_int() or { panic(err) }) or {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby method `volatile_set_by_hash(hash, value)` at line 28.
pub fn ruby_power_of_two_tuple_l28_d4_volatile_set_by_hash(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('PowerOfTwoTuple#volatile_set_by_hash requires hash and value')
	}
	mut tuple := power_tuple_boundary_receiver(args)
	return tuple.set_by_hash(args[1].as_int() or { panic(err) }, args[2])
}

// Ruby method `next_in_size_table` at line 32.
pub fn ruby_power_of_two_tuple_l32_d5_next_in_size_table(args ...ruby.Value) ruby.Value {
	tuple := power_tuple_boundary_receiver(args)
	next := tuple.next_in_size_table() or { panic(err) }
	return ruby.structured_value('Concurrent::ThreadSafe::Util::PowerOfTwoTuple', '#<Concurrent::ThreadSafe::Util::PowerOfTwoTuple>', {
		'power_tuple_address': u64(voidptr(next)).str()
		'size':                next.size.str()
	})
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/thread_safe/util'
// 2: require 'concurrent/tuple'
// 3:
// 4: module Concurrent
// 5:
// 6:   # @!visibility private
// 7:   module ThreadSafe
// 8:
// 9:     # @!visibility private
// 10:     module Util
// 11:
// 12:       # @!visibility private
// 13:       class PowerOfTwoTuple < Concurrent::Tuple
// 14:
// 15:         def initialize(size)
// 16:           raise ArgumentError, "size must be a power of 2 (#{size.inspect} provided)" unless size > 0 && size & (size - 1) == 0
// 17:           super(size)
// 18:         end
// 19:
// 20:         def hash_to_index(hash)
// 21:           (size - 1) & hash
// 22:         end
// 23:
// 24:         def volatile_get_by_hash(hash)
// 25:           volatile_get(hash_to_index(hash))
// 26:         end
// 27:
// 28:         def volatile_set_by_hash(hash, value)
// 29:           volatile_set(hash_to_index(hash), value)
// 30:         end
// 31:
// 32:         def next_in_size_table
// 33:           self.class.new(size << 1)
// 34:         end
// 35:       end
// 36:     end
// 37:   end
// 38: end
