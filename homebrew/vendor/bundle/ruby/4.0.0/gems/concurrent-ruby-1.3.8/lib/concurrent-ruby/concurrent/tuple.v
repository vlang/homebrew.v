module concurrent

import ruby
import math
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/tuple.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct Tuple {
pub:
	size int
mut:
	lock   sync.RwMutex
	values []ruby.Value
}

fn tuple_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn tuple_values_equal(left ruby.Value, right ruby.Value) bool {
	if right.type_name == 'Integer' || right.type_name == 'Float' {
		if left.type_name != 'Integer' && left.type_name != 'Float' {
			return false
		}
		left_numeric := left.as_float() or { return false }
		right_numeric := right.as_float() or { return false }
		if math.is_nan(right_numeric) {
			return math.is_nan(left_numeric)
		}
		return left_numeric == right_numeric
	}
	return left.type_name == right.type_name && left.repr == right.repr
}

pub fn new_tuple(size int) !&Tuple {
	if size < 0 {
		return error('negative array size')
	}
	return &Tuple{
		size: size
		values: []ruby.Value{len: size, init: tuple_nil_value()}
	}
}

pub fn (mut tuple Tuple) get(index int) ?ruby.Value {
	if index < 0 || index >= tuple.size {
		return none
	}
	tuple.lock.rlock()
	defer {
		tuple.lock.runlock()
	}
	return tuple.values[index]
}

pub fn (mut tuple Tuple) set(index int, value ruby.Value) ?ruby.Value {
	if index < 0 || index >= tuple.size {
		return none
	}
	tuple.lock.lock()
	tuple.values[index] = value
	tuple.lock.unlock()
	return value
}

pub fn (mut tuple Tuple) compare_and_set(index int, old_value ruby.Value, new_value ruby.Value) bool {
	if index < 0 || index >= tuple.size {
		return false
	}
	tuple.lock.lock()
	if tuple_values_equal(tuple.values[index], old_value) {
		tuple.values[index] = new_value
		tuple.lock.unlock()
		return true
	}
	tuple.lock.unlock()
	return false
}

pub fn (mut tuple Tuple) values() []ruby.Value {
	tuple.lock.rlock()
	defer {
		tuple.lock.runlock()
	}
	return tuple.values.clone()
}

fn tuple_boundary_new(size int) ruby.Value {
	tuple := new_tuple(size) or { panic(err) }
	return ruby.structured_value('Concurrent::Tuple', '#<Concurrent::Tuple>', {
		'tuple_address': u64(voidptr(tuple)).str()
		'size':          size.str()
	})
}

fn tuple_boundary_receiver(args []ruby.Value) &Tuple {
	if args.len == 0 {
		panic('Tuple method requires a receiver')
	}
	address := (args[0].attribute('tuple_address') or {
		panic('${args[0].type_name} has no translated Tuple state')
	}).u64()
	return unsafe { &Tuple(voidptr(address)) }
}

// Ruby attr_reader `attr_reader :size` at line 24.
pub fn ruby_tuple_l24_d1_size(args ...ruby.Value) ruby.Value {
	tuple := tuple_boundary_receiver(args)
	return ruby.int_value(tuple.size)
}

// Ruby method `initialize(size)` at line 29.
pub fn ruby_tuple_l29_d2_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Tuple#initialize requires size')
	}
	return tuple_boundary_new(int(args[0].as_int() or { panic(err) }))
}

// Ruby method `get(i)` at line 43.
pub fn ruby_tuple_l43_d3_get(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Tuple#get requires index')
	}
	mut tuple := tuple_boundary_receiver(args)
	return tuple.get(int(args[1].as_int() or { panic(err) })) or { tuple_nil_value() }
}

// Ruby alias_method `alias_method :volatile_get, :get` at line 47.
pub fn ruby_tuple_l47_d4_volatile_get(args ...ruby.Value) ruby.Value {
	return ruby_tuple_l43_d3_get(...args)
}

// Ruby method `set(i, value)` at line 55.
pub fn ruby_tuple_l55_d5_set(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('Tuple#set requires index and value')
	}
	mut tuple := tuple_boundary_receiver(args)
	return tuple.set(int(args[1].as_int() or { panic(err) }), args[2]) or { tuple_nil_value() }
}

// Ruby alias_method `alias_method :volatile_set, :set` at line 59.
pub fn ruby_tuple_l59_d6_volatile_set(args ...ruby.Value) ruby.Value {
	return ruby_tuple_l55_d5_set(...args)
}

// Ruby method `compare_and_set(i, old_value, new_value)` at line 69.
pub fn ruby_tuple_l69_d7_compare_and_set(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('Tuple#compare_and_set requires index, old value and new value')
	}
	mut tuple := tuple_boundary_receiver(args)
	return ruby.bool_value(tuple.compare_and_set(int(args[1].as_int() or { panic(err) }), args[2], args[3]))
}

// Ruby alias_method `alias_method :cas, :compare_and_set` at line 73.
pub fn ruby_tuple_l73_d8_cas(args ...ruby.Value) ruby.Value {
	return ruby_tuple_l69_d7_compare_and_set(...args)
}

// Ruby method `each` at line 78.
pub fn ruby_tuple_l78_d9_each(args ...ruby.Value) ruby.Value {
	mut tuple := tuple_boundary_receiver(args)
	return ruby.array_value(tuple.values())
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/atomic/atomic_reference'
// 2:
// 3: module Concurrent
// 4:
// 5:   # A fixed size array with volatile (synchronized, thread safe) getters/setters.
// 6:   # Mixes in Ruby's `Enumerable` module for enhanced search, sort, and traversal.
// 7:   #
// 8:   # @example
// 9:   #   tuple = Concurrent::Tuple.new(16)
// 10:   #
// 11:   #   tuple.set(0, :foo)                   #=> :foo  | volatile write
// 12:   #   tuple.get(0)                         #=> :foo  | volatile read
// 13:   #   tuple.compare_and_set(0, :foo, :bar) #=> true  | strong CAS
// 14:   #   tuple.cas(0, :foo, :baz)             #=> false | strong CAS
// 15:   #   tuple.get(0)                         #=> :bar  | volatile read
// 16:   #
// 17:   # @see https://en.wikipedia.org/wiki/Tuple Tuple entry at Wikipedia
// 18:   # @see http://www.erlang.org/doc/reference_manual/data_types.html#id70396 Erlang Tuple
// 19:   # @see http://ruby-doc.org/core-2.2.2/Enumerable.html Enumerable
// 20:   class Tuple
// 21:     include Enumerable
// 22:
// 23:     # The (fixed) size of the tuple.
// 24:     attr_reader :size
// 25:
// 26:     # Create a new tuple of the given size.
// 27:     #
// 28:     # @param [Integer] size the number of elements in the tuple
// 29:     def initialize(size)
// 30:       @size = size
// 31:       @tuple = tuple = ::Array.new(size)
// 32:       i = 0
// 33:       while i < size
// 34:         tuple[i] = Concurrent::AtomicReference.new
// 35:         i += 1
// 36:       end
// 37:     end
// 38:
// 39:     # Get the value of the element at the given index.
// 40:     #
// 41:     # @param [Integer] i the index from which to retrieve the value
// 42:     # @return [Object] the value at the given index or nil if the index is out of bounds
// 43:     def get(i)
// 44:       return nil if i >= @size || i < 0
// 45:       @tuple[i].get
// 46:     end
// 47:     alias_method :volatile_get, :get
// 48:
// 49:     # Set the element at the given index to the given value
// 50:     #
// 51:     # @param [Integer] i the index for the element to set
// 52:     # @param [Object] value the value to set at the given index
// 53:     #
// 54:     # @return [Object] the new value of the element at the given index or nil if the index is out of bounds
// 55:     def set(i, value)
// 56:       return nil if i >= @size || i < 0
// 57:       @tuple[i].set(value)
// 58:     end
// 59:     alias_method :volatile_set, :set
// 60:
// 61:     # Set the value at the given index to the new value if and only if the current
// 62:     # value matches the given old value.
// 63:     #
// 64:     # @param [Integer] i the index for the element to set
// 65:     # @param [Object] old_value the value to compare against the current value
// 66:     # @param [Object] new_value the value to set at the given index
// 67:     #
// 68:     # @return [Boolean] true if the value at the given element was set else false
// 69:     def compare_and_set(i, old_value, new_value)
// 70:       return false if i >= @size || i < 0
// 71:       @tuple[i].compare_and_set(old_value, new_value)
// 72:     end
// 73:     alias_method :cas, :compare_and_set
// 74:
// 75:     # Calls the given block once for each element in self, passing that element as a parameter.
// 76:     #
// 77:     # @yieldparam [Object] ref the `Concurrent::AtomicReference` object at the current index
// 78:     def each
// 79:       @tuple.each {|ref| yield ref.get}
// 80:     end
// 81:   end
// 82: end
