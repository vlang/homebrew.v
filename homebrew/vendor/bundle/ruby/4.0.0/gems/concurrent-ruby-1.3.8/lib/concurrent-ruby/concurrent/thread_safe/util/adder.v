module util

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/thread_safe/util/adder.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct Adder {
mut:
	lock sync.Mutex
	sum  i64
}

pub fn new_adder() &Adder {
	return &Adder{}
}

pub fn (mut adder Adder) add(value i64) {
	adder.lock.lock()
	adder.sum += value
	adder.lock.unlock()
}

pub fn (mut adder Adder) increment() {
	adder.add(1)
}

pub fn (mut adder Adder) decrement() {
	adder.add(-1)
}

pub fn (mut adder Adder) value() i64 {
	adder.lock.lock()
	defer {
		adder.lock.unlock()
	}
	return adder.sum
}

pub fn (mut adder Adder) reset() {
	adder.lock.lock()
	adder.sum = 0
	adder.lock.unlock()
}

pub fn new_adder_boundary_value() brew_runtime.Value {
	adder := new_adder()
	return brew_runtime.structured_value('Concurrent::ThreadSafe::Util::Adder', '#<Concurrent::ThreadSafe::Util::Adder>', {
		'adder_address': u64(voidptr(adder)).str()
	})
}

fn adder_boundary_receiver(args []brew_runtime.Value) &Adder {
	if args.len == 0 {
		panic('Adder method requires a receiver')
	}
	address := (args[0].attribute('adder_address') or {
		panic('${args[0].type_name} has no translated Adder state')
	}).u64()
	return unsafe { &Adder(voidptr(address)) }
}

// Ruby method `add(x)` at line 35.
pub fn ruby_adder_l35_d1_add(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Adder#add requires value')
	}
	mut adder := adder_boundary_receiver(args)
	adder.add(args[1].as_int() or { panic(err) })
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `increment` at line 45.
pub fn ruby_adder_l45_d2_increment(args ...brew_runtime.Value) brew_runtime.Value {
	mut adder := adder_boundary_receiver(args)
	adder.increment()
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `decrement` at line 49.
pub fn ruby_adder_l49_d3_decrement(args ...brew_runtime.Value) brew_runtime.Value {
	mut adder := adder_boundary_receiver(args)
	adder.decrement()
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `sum` at line 58.
pub fn ruby_adder_l58_d4_sum(args ...brew_runtime.Value) brew_runtime.Value {
	mut adder := adder_boundary_receiver(args)
	return brew_runtime.int_value(adder.value())
}

// Ruby method `reset` at line 68.
pub fn ruby_adder_l68_d5_reset(args ...brew_runtime.Value) brew_runtime.Value {
	mut adder := adder_boundary_receiver(args)
	adder.reset()
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/thread_safe/util'
// 2: require 'concurrent/thread_safe/util/striped64'
// 3:
// 4: module Concurrent
// 5:
// 6:   # @!visibility private
// 7:   module ThreadSafe
// 8:
// 9:     # @!visibility private
// 10:     module Util
// 11:
// 12:       # A Ruby port of the Doug Lea's jsr166e.LongAdder class version 1.8
// 13:       # available in public domain.
// 14:       #
// 15:       # Original source code available here:
// 16:       # http://gee.cs.oswego.edu/cgi-bin/viewcvs.cgi/jsr166/src/jsr166e/LongAdder.java?revision=1.8
// 17:       #
// 18:       # One or more variables that together maintain an initially zero
// 19:       # sum. When updates (method +add+) are contended across threads,
// 20:       # the set of variables may grow dynamically to reduce contention.
// 21:       # Method +sum+ returns the current total combined across the
// 22:       # variables maintaining the sum.
// 23:       #
// 24:       # This class is usually preferable to single +Atomic+ reference when
// 25:       # multiple threads update a common sum that is used for purposes such
// 26:       # as collecting statistics, not for fine-grained synchronization
// 27:       # control.  Under low update contention, the two classes have similar
// 28:       # characteristics. But under high contention, expected throughput of
// 29:       # this class is significantly higher, at the expense of higher space
// 30:       # consumption.
// 31:       #
// 32:       # @!visibility private
// 33:       class Adder < Striped64
// 34:         # Adds the given value.
// 35:         def add(x)
// 36:           if (current_cells = cells) || !cas_base_computed {|current_base| current_base + x}
// 37:             was_uncontended = true
// 38:             hash            = hash_code
// 39:             unless current_cells && (cell = current_cells.volatile_get_by_hash(hash)) && (was_uncontended = cell.cas_computed {|current_value| current_value + x})
// 40:               retry_update(x, hash, was_uncontended) {|current_value| current_value + x}
// 41:             end
// 42:           end
// 43:         end
// 44:
// 45:         def increment
// 46:           add(1)
// 47:         end
// 48:
// 49:         def decrement
// 50:           add(-1)
// 51:         end
// 52:
// 53:         # Returns the current sum.  The returned value is _NOT_ an
// 54:         # atomic snapshot: Invocation in the absence of concurrent
// 55:         # updates returns an accurate result, but concurrent updates that
// 56:         # occur while the sum is being calculated might not be
// 57:         # incorporated.
// 58:         def sum
// 59:           x = base
// 60:           if current_cells = cells
// 61:             current_cells.each do |cell|
// 62:               x += cell.value if cell
// 63:             end
// 64:           end
// 65:           x
// 66:         end
// 67:
// 68:         def reset
// 69:           internal_reset(0)
// 70:         end
// 71:       end
// 72:     end
// 73:   end
// 74: end
