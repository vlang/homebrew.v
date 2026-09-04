module collection

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/java_non_concurrent_priority_queue.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct JavaNonConcurrentPriorityQueue {
mut:
	queue RubyNonConcurrentPriorityQueue
}

pub fn new_java_non_concurrent_priority_queue(order PriorityQueueOrder) JavaNonConcurrentPriorityQueue {
	return JavaNonConcurrentPriorityQueue{
		queue: new_ruby_non_concurrent_priority_queue(order)
	}
}

pub fn java_priority_queue_from_list(list []ruby.Value, order PriorityQueueOrder) !JavaNonConcurrentPriorityQueue {
	mut queue := new_java_non_concurrent_priority_queue(order)
	for item in list {
		queue.push(item)!
	}
	return queue
}

pub fn (mut queue JavaNonConcurrentPriorityQueue) clear() bool {
	return queue.queue.clear()
}

pub fn (mut queue JavaNonConcurrentPriorityQueue) delete(item ruby.Value) bool {
	return queue.queue.delete(item)
}

pub fn (queue &JavaNonConcurrentPriorityQueue) empty() bool {
	return queue.queue.empty()
}

pub fn (queue &JavaNonConcurrentPriorityQueue) include(item ruby.Value) bool {
	return queue.queue.include(item)
}

pub fn (queue &JavaNonConcurrentPriorityQueue) size() int {
	return queue.queue.size()
}

pub fn (queue &JavaNonConcurrentPriorityQueue) peek() ruby.Value {
	return queue.queue.peek()
}

pub fn (mut queue JavaNonConcurrentPriorityQueue) pop() ruby.Value {
	return queue.queue.pop()
}

pub fn (mut queue JavaNonConcurrentPriorityQueue) push(item ruby.Value) !bool {
	return queue.queue.push(item)
}

// Ruby method `initialize(opts = {})` at line 14.
pub fn ruby_java_non_concurrent_priority_queue_l14_d1_initialize(args ...ruby.Value) ruby.Value {
	return priority_queue_boundary_initialize('Concurrent::Collection::JavaNonConcurrentPriorityQueue', args)
}

// Ruby method `clear` at line 24.
pub fn ruby_java_non_concurrent_priority_queue_l24_d2_clear(args ...ruby.Value) ruby.Value {
	return ruby_ruby_non_concurrent_priority_queue_l18_d2_clear(...args)
}

// Ruby method `delete(item)` at line 30.
pub fn ruby_java_non_concurrent_priority_queue_l30_d3_delete(args ...ruby.Value) ruby.Value {
	return ruby_ruby_non_concurrent_priority_queue_l25_d3_delete(...args)
}

// Ruby method `empty?` at line 39.
pub fn ruby_java_non_concurrent_priority_queue_l39_d4_empty(args ...ruby.Value) ruby.Value {
	return ruby_ruby_non_concurrent_priority_queue_l43_d4_empty(...args)
}

// Ruby method `include?(item)` at line 44.
pub fn ruby_java_non_concurrent_priority_queue_l44_d5_include(args ...ruby.Value) ruby.Value {
	return ruby_ruby_non_concurrent_priority_queue_l48_d5_include(...args)
}

// Ruby alias_method `alias_method :has_priority?, :include?` at line 47.
pub fn ruby_java_non_concurrent_priority_queue_l47_d6_has_priority(args ...ruby.Value) ruby.Value {
	return ruby_java_non_concurrent_priority_queue_l44_d5_include(...args)
}

// Ruby method `length` at line 50.
pub fn ruby_java_non_concurrent_priority_queue_l50_d7_length(args ...ruby.Value) ruby.Value {
	return ruby_ruby_non_concurrent_priority_queue_l54_d7_length(...args)
}

// Ruby alias_method `alias_method :size, :length` at line 53.
pub fn ruby_java_non_concurrent_priority_queue_l53_d8_size(args ...ruby.Value) ruby.Value {
	return ruby_java_non_concurrent_priority_queue_l50_d7_length(...args)
}

// Ruby method `peek` at line 56.
pub fn ruby_java_non_concurrent_priority_queue_l56_d9_peek(args ...ruby.Value) ruby.Value {
	return ruby_ruby_non_concurrent_priority_queue_l60_d9_peek(...args)
}

// Ruby method `pop` at line 61.
pub fn ruby_java_non_concurrent_priority_queue_l61_d10_pop(args ...ruby.Value) ruby.Value {
	return ruby_ruby_non_concurrent_priority_queue_l65_d10_pop(...args)
}

// Ruby alias_method `alias_method :deq, :pop` at line 64.
pub fn ruby_java_non_concurrent_priority_queue_l64_d11_deq(args ...ruby.Value) ruby.Value {
	return ruby_java_non_concurrent_priority_queue_l61_d10_pop(...args)
}

// Ruby alias_method `alias_method :shift, :pop` at line 65.
pub fn ruby_java_non_concurrent_priority_queue_l65_d12_shift(args ...ruby.Value) ruby.Value {
	return ruby_java_non_concurrent_priority_queue_l61_d10_pop(...args)
}

// Ruby method `push(item)` at line 68.
pub fn ruby_java_non_concurrent_priority_queue_l68_d13_push(args ...ruby.Value) ruby.Value {
	return ruby_ruby_non_concurrent_priority_queue_l78_d13_push(...args)
}

// Ruby alias_method `alias_method :<<, :push` at line 72.
pub fn ruby_java_non_concurrent_priority_queue_l72_d14_push(args ...ruby.Value) ruby.Value {
	return ruby_java_non_concurrent_priority_queue_l68_d13_push(...args)
}

// Ruby alias_method `alias_method :enq, :push` at line 73.
pub fn ruby_java_non_concurrent_priority_queue_l73_d15_enq(args ...ruby.Value) ruby.Value {
	return ruby_java_non_concurrent_priority_queue_l68_d13_push(...args)
}

// Ruby method `self.from_list(list, opts = {})` at line 76.
pub fn ruby_java_non_concurrent_priority_queue_l76_d16_self_from_list(args ...ruby.Value) ruby.Value {
	return priority_queue_boundary_from_list('Concurrent::Collection::JavaNonConcurrentPriorityQueue', args)
}

// Original Ruby source (line-for-line):
// 1: if Concurrent.on_jruby?
// 2:
// 3:   module Concurrent
// 4:     module Collection
// 5:
// 6:
// 7:       # @!macro priority_queue
// 8:       #
// 9:       # @!visibility private
// 10:       # @!macro internal_implementation_note
// 11:       class JavaNonConcurrentPriorityQueue
// 12:
// 13:         # @!macro priority_queue_method_initialize
// 14:         def initialize(opts = {})
// 15:           order = opts.fetch(:order, :max)
// 16:           if [:min, :low].include?(order)
// 17:             @queue = java.util.PriorityQueue.new(11) # 11 is the default initial capacity
// 18:           else
// 19:             @queue = java.util.PriorityQueue.new(11, java.util.Collections.reverseOrder())
// 20:           end
// 21:         end
// 22:
// 23:         # @!macro priority_queue_method_clear
// 24:         def clear
// 25:           @queue.clear
// 26:           true
// 27:         end
// 28:
// 29:         # @!macro priority_queue_method_delete
// 30:         def delete(item)
// 31:           found = false
// 32:           while @queue.remove(item) do
// 33:             found = true
// 34:           end
// 35:           found
// 36:         end
// 37:
// 38:         # @!macro priority_queue_method_empty
// 39:         def empty?
// 40:           @queue.size == 0
// 41:         end
// 42:
// 43:         # @!macro priority_queue_method_include
// 44:         def include?(item)
// 45:           @queue.contains(item)
// 46:         end
// 47:         alias_method :has_priority?, :include?
// 48:
// 49:         # @!macro priority_queue_method_length
// 50:         def length
// 51:           @queue.size
// 52:         end
// 53:         alias_method :size, :length
// 54:
// 55:         # @!macro priority_queue_method_peek
// 56:         def peek
// 57:           @queue.peek
// 58:         end
// 59:
// 60:         # @!macro priority_queue_method_pop
// 61:         def pop
// 62:           @queue.poll
// 63:         end
// 64:         alias_method :deq, :pop
// 65:         alias_method :shift, :pop
// 66:
// 67:         # @!macro priority_queue_method_push
// 68:         def push(item)
// 69:           raise ArgumentError.new('cannot enqueue nil') if item.nil?
// 70:           @queue.add(item)
// 71:         end
// 72:         alias_method :<<, :push
// 73:         alias_method :enq, :push
// 74:
// 75:         # @!macro priority_queue_method_from_list
// 76:         def self.from_list(list, opts = {})
// 77:           queue = new(opts)
// 78:           list.each{|item| queue << item }
// 79:           queue
// 80:         end
// 81:       end
// 82:     end
// 83:   end
// 84: end
