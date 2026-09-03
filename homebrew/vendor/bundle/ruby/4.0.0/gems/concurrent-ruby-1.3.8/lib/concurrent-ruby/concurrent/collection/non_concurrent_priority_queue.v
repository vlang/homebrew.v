module collection

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/non_concurrent_priority_queue.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct NonConcurrentPriorityQueue {
mut:
	queue RubyNonConcurrentPriorityQueue
}

pub fn new_non_concurrent_priority_queue(order PriorityQueueOrder) NonConcurrentPriorityQueue {
	return NonConcurrentPriorityQueue{
		queue: new_ruby_non_concurrent_priority_queue(order)
	}
}

pub fn non_concurrent_priority_queue_from_list(list []brew_runtime.Value, order PriorityQueueOrder) !NonConcurrentPriorityQueue {
	mut queue := new_non_concurrent_priority_queue(order)
	for item in list {
		queue.push(item)!
	}
	return queue
}

pub fn (mut queue NonConcurrentPriorityQueue) clear() bool {
	return queue.queue.clear()
}

pub fn (mut queue NonConcurrentPriorityQueue) delete(item brew_runtime.Value) bool {
	return queue.queue.delete(item)
}

pub fn (queue &NonConcurrentPriorityQueue) empty() bool {
	return queue.queue.empty()
}

pub fn (queue &NonConcurrentPriorityQueue) include(item brew_runtime.Value) bool {
	return queue.queue.include(item)
}

pub fn (queue &NonConcurrentPriorityQueue) size() int {
	return queue.queue.size()
}

pub fn (queue &NonConcurrentPriorityQueue) peek() brew_runtime.Value {
	return queue.queue.peek()
}

pub fn (mut queue NonConcurrentPriorityQueue) pop() brew_runtime.Value {
	return queue.queue.pop()
}

pub fn (mut queue NonConcurrentPriorityQueue) push(item brew_runtime.Value) !bool {
	return queue.queue.push(item)
}

// Ruby alias_method `alias_method :has_priority?, :include?` at line 52.
pub fn ruby_non_concurrent_priority_queue_l52_d1_has_priority(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_ruby_non_concurrent_priority_queue_l48_d5_include(...args)
}

// Ruby alias_method `alias_method :size, :length` at line 54.
pub fn ruby_non_concurrent_priority_queue_l54_d2_size(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_ruby_non_concurrent_priority_queue_l54_d7_length(...args)
}

// Ruby alias_method `alias_method :deq, :pop` at line 56.
pub fn ruby_non_concurrent_priority_queue_l56_d3_deq(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_ruby_non_concurrent_priority_queue_l65_d10_pop(...args)
}

// Ruby alias_method `alias_method :shift, :pop` at line 57.
pub fn ruby_non_concurrent_priority_queue_l57_d4_shift(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_ruby_non_concurrent_priority_queue_l65_d10_pop(...args)
}

// Ruby alias_method `alias_method :<<, :push` at line 59.
pub fn ruby_non_concurrent_priority_queue_l59_d5_push(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_ruby_non_concurrent_priority_queue_l78_d13_push(...args)
}

// Ruby alias_method `alias_method :enq, :push` at line 60.
pub fn ruby_non_concurrent_priority_queue_l60_d6_enq(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_ruby_non_concurrent_priority_queue_l78_d13_push(...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/engine'
// 2: require 'concurrent/collection/java_non_concurrent_priority_queue'
// 3: require 'concurrent/collection/ruby_non_concurrent_priority_queue'
// 4:
// 5: module Concurrent
// 6:   module Collection
// 7:
// 8:     # @!visibility private
// 9:     # @!macro internal_implementation_note
// 10:     NonConcurrentPriorityQueueImplementation = case
// 11:                                                when Concurrent.on_jruby?
// 12:                                                  JavaNonConcurrentPriorityQueue
// 13:                                                else
// 14:                                                  RubyNonConcurrentPriorityQueue
// 15:                                                end
// 16:     private_constant :NonConcurrentPriorityQueueImplementation
// 17:
// 18:     # @!macro priority_queue
// 19:     #
// 20:     #   A queue collection in which the elements are sorted based on their
// 21:     #   comparison (spaceship) operator `<=>`. Items are added to the queue
// 22:     #   at a position relative to their priority. On removal the element
// 23:     #   with the "highest" priority is removed. By default the sort order is
// 24:     #   from highest to lowest, but a lowest-to-highest sort order can be
// 25:     #   set on construction.
// 26:     #
// 27:     #   The API is based on the `Queue` class from the Ruby standard library.
// 28:     #
// 29:     #   The pure Ruby implementation, `RubyNonConcurrentPriorityQueue` uses a heap algorithm
// 30:     #   stored in an array. The algorithm is based on the work of Robert Sedgewick
// 31:     #   and Kevin Wayne.
// 32:     #
// 33:     #   The JRuby native implementation is a thin wrapper around the standard
// 34:     #   library `java.util.NonConcurrentPriorityQueue`.
// 35:     #
// 36:     #   When running under JRuby the class `NonConcurrentPriorityQueue` extends `JavaNonConcurrentPriorityQueue`.
// 37:     #   When running under all other interpreters it extends `RubyNonConcurrentPriorityQueue`.
// 38:     #
// 39:     #   @note This implementation is *not* thread safe.
// 40:     #
// 41:     #   @see http://en.wikipedia.org/wiki/Priority_queue
// 42:     #   @see http://ruby-doc.org/stdlib-2.0.0/libdoc/thread/rdoc/Queue.html
// 43:     #
// 44:     #   @see http://algs4.cs.princeton.edu/24pq/index.php#2.6
// 45:     #   @see http://algs4.cs.princeton.edu/24pq/MaxPQ.java.html
// 46:     #
// 47:     #   @see http://docs.oracle.com/javase/7/docs/api/java/util/PriorityQueue.html
// 48:     #
// 49:     # @!visibility private
// 50:     class NonConcurrentPriorityQueue < NonConcurrentPriorityQueueImplementation
// 51:
// 52:       alias_method :has_priority?, :include?
// 53:
// 54:       alias_method :size, :length
// 55:
// 56:       alias_method :deq, :pop
// 57:       alias_method :shift, :pop
// 58:
// 59:       alias_method :<<, :push
// 60:       alias_method :enq, :push
// 61:
// 62:       # @!method initialize(opts = {})
// 63:       #   @!macro priority_queue_method_initialize
// 64:       #
// 65:       #     Create a new priority queue with no items.
// 66:       #
// 67:       #     @param [Hash] opts the options for creating the queue
// 68:       #     @option opts [Symbol] :order (:max) dictates the order in which items are
// 69:       #       stored: from highest to lowest when `:max` or `:high`; from lowest to
// 70:       #       highest when `:min` or `:low`
// 71:
// 72:       # @!method clear
// 73:       #   @!macro priority_queue_method_clear
// 74:       #
// 75:       #     Removes all of the elements from this priority queue.
// 76:
// 77:       # @!method delete(item)
// 78:       #   @!macro priority_queue_method_delete
// 79:       #
// 80:       #     Deletes all items from `self` that are equal to `item`.
// 81:       #
// 82:       #     @param [Object] item the item to be removed from the queue
// 83:       #     @return [Object] true if the item is found else false
// 84:
// 85:       # @!method empty?
// 86:       #   @!macro priority_queue_method_empty
// 87:       #
// 88:       #     Returns `true` if `self` contains no elements.
// 89:       #
// 90:       #     @return [Boolean] true if there are no items in the queue else false
// 91:
// 92:       # @!method include?(item)
// 93:       #   @!macro priority_queue_method_include
// 94:       #
// 95:       #     Returns `true` if the given item is present in `self` (that is, if any
// 96:       #     element == `item`), otherwise returns false.
// 97:       #
// 98:       #     @param [Object] item the item to search for
// 99:       #
// 100:       #     @return [Boolean] true if the item is found else false
// 101:
// 102:       # @!method length
// 103:       #   @!macro priority_queue_method_length
// 104:       #
// 105:       #     The current length of the queue.
// 106:       #
// 107:       #     @return [Fixnum] the number of items in the queue
// 108:
// 109:       # @!method peek
// 110:       #   @!macro priority_queue_method_peek
// 111:       #
// 112:       #     Retrieves, but does not remove, the head of this queue, or returns `nil`
// 113:       #     if this queue is empty.
// 114:       #
// 115:       #     @return [Object] the head of the queue or `nil` when empty
// 116:
// 117:       # @!method pop
// 118:       #   @!macro priority_queue_method_pop
// 119:       #
// 120:       #     Retrieves and removes the head of this queue, or returns `nil` if this
// 121:       #     queue is empty.
// 122:       #
// 123:       #     @return [Object] the head of the queue or `nil` when empty
// 124:
// 125:       # @!method push(item)
// 126:       #   @!macro priority_queue_method_push
// 127:       #
// 128:       #     Inserts the specified element into this priority queue.
// 129:       #
// 130:       #     @param [Object] item the item to insert onto the queue
// 131:
// 132:       # @!method self.from_list(list, opts = {})
// 133:       #   @!macro priority_queue_method_from_list
// 134:       #
// 135:       #     Create a new priority queue from the given list.
// 136:       #
// 137:       #     @param [Enumerable] list the list to build the queue from
// 138:       #     @param [Hash] opts the options for creating the queue
// 139:       #
// 140:       #     @return [NonConcurrentPriorityQueue] the newly created and populated queue
// 141:     end
// 142:   end
// 143: end
