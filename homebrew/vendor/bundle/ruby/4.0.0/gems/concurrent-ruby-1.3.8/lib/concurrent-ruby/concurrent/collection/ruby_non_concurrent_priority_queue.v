module collection

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/ruby_non_concurrent_priority_queue.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(opts = {})` at line 11.
pub fn ruby_ruby_non_concurrent_priority_queue_l11_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `clear` at line 18.
pub fn ruby_ruby_non_concurrent_priority_queue_l18_d2_clear(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clear', ...args)
}

// Ruby method `delete(item)` at line 25.
pub fn ruby_ruby_non_concurrent_priority_queue_l25_d3_delete(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delete', ...args)
}

// Ruby method `empty?` at line 43.
pub fn ruby_ruby_non_concurrent_priority_queue_l43_d4_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('empty?', ...args)
}

// Ruby method `include?(item)` at line 48.
pub fn ruby_ruby_non_concurrent_priority_queue_l48_d5_include(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('include?', ...args)
}

// Ruby alias_method `alias_method :has_priority?, :include?` at line 51.
pub fn ruby_ruby_non_concurrent_priority_queue_l51_d6_has_priority(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('has_priority?', ...args)
}

// Ruby method `length` at line 54.
pub fn ruby_ruby_non_concurrent_priority_queue_l54_d7_length(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('length', ...args)
}

// Ruby alias_method `alias_method :size, :length` at line 57.
pub fn ruby_ruby_non_concurrent_priority_queue_l57_d8_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('size', ...args)
}

// Ruby method `peek` at line 60.
pub fn ruby_ruby_non_concurrent_priority_queue_l60_d9_peek(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('peek', ...args)
}

// Ruby method `pop` at line 65.
pub fn ruby_ruby_non_concurrent_priority_queue_l65_d10_pop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pop', ...args)
}

// Ruby alias_method `alias_method :deq, :pop` at line 74.
pub fn ruby_ruby_non_concurrent_priority_queue_l74_d11_deq(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deq', ...args)
}

// Ruby alias_method `alias_method :shift, :pop` at line 75.
pub fn ruby_ruby_non_concurrent_priority_queue_l75_d12_shift(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shift', ...args)
}

// Ruby method `push(item)` at line 78.
pub fn ruby_ruby_non_concurrent_priority_queue_l78_d13_push(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('push', ...args)
}

// Ruby alias_method `alias_method :<<, :push` at line 85.
pub fn ruby_ruby_non_concurrent_priority_queue_l85_d14_push(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('push', ...args)
}

// Ruby alias_method `alias_method :enq, :push` at line 86.
pub fn ruby_ruby_non_concurrent_priority_queue_l86_d15_enq(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('enq', ...args)
}

// Ruby method `self.from_list(list, opts = {})` at line 89.
pub fn ruby_ruby_non_concurrent_priority_queue_l89_d16_self_from_list(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_list', ...args)
}

// Ruby method `swap(x, y)` at line 103.
pub fn ruby_ruby_non_concurrent_priority_queue_l103_d17_swap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('swap', ...args)
}

// Ruby method `ordered?(x, y)` at line 119.
pub fn ruby_ruby_non_concurrent_priority_queue_l119_d18_ordered(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ordered?', ...args)
}

// Ruby method `sink(k)` at line 128.
pub fn ruby_ruby_non_concurrent_priority_queue_l128_d19_sink(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sink', ...args)
}

// Ruby method `swim(k)` at line 147.
pub fn ruby_ruby_non_concurrent_priority_queue_l147_d20_swim(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('swim', ...args)
}

// Original Ruby source (line-for-line):
// 1: module Concurrent
// 2:   module Collection
// 3:
// 4:     # @!macro priority_queue
// 5:     #
// 6:     # @!visibility private
// 7:     # @!macro internal_implementation_note
// 8:     class RubyNonConcurrentPriorityQueue
// 9:
// 10:       # @!macro priority_queue_method_initialize
// 11:       def initialize(opts = {})
// 12:         order = opts.fetch(:order, :max)
// 13:         @comparator = [:min, :low].include?(order) ? -1 : 1
// 14:         clear
// 15:       end
// 16:
// 17:       # @!macro priority_queue_method_clear
// 18:       def clear
// 19:         @queue = [nil]
// 20:         @length = 0
// 21:         true
// 22:       end
// 23:
// 24:       # @!macro priority_queue_method_delete
// 25:       def delete(item)
// 26:         return false if empty?
// 27:         original_length = @length
// 28:         k = 1
// 29:         while k <= @length
// 30:           if @queue[k] == item
// 31:             swap(k, @length)
// 32:             @length -= 1
// 33:             sink(k) || swim(k)
// 34:             @queue.pop
// 35:           else
// 36:             k += 1
// 37:           end
// 38:         end
// 39:         @length != original_length
// 40:       end
// 41:
// 42:       # @!macro priority_queue_method_empty
// 43:       def empty?
// 44:         size == 0
// 45:       end
// 46:
// 47:       # @!macro priority_queue_method_include
// 48:       def include?(item)
// 49:         @queue.include?(item)
// 50:       end
// 51:       alias_method :has_priority?, :include?
// 52:
// 53:       # @!macro priority_queue_method_length
// 54:       def length
// 55:         @length
// 56:       end
// 57:       alias_method :size, :length
// 58:
// 59:       # @!macro priority_queue_method_peek
// 60:       def peek
// 61:         empty? ? nil : @queue[1]
// 62:       end
// 63:
// 64:       # @!macro priority_queue_method_pop
// 65:       def pop
// 66:         return nil if empty?
// 67:         max = @queue[1]
// 68:         swap(1, @length)
// 69:         @length -= 1
// 70:         sink(1)
// 71:         @queue.pop
// 72:         max
// 73:       end
// 74:       alias_method :deq, :pop
// 75:       alias_method :shift, :pop
// 76:
// 77:       # @!macro priority_queue_method_push
// 78:       def push(item)
// 79:         raise ArgumentError.new('cannot enqueue nil') if item.nil?
// 80:         @length += 1
// 81:         @queue << item
// 82:         swim(@length)
// 83:         true
// 84:       end
// 85:       alias_method :<<, :push
// 86:       alias_method :enq, :push
// 87:
// 88:       #   @!macro priority_queue_method_from_list
// 89:       def self.from_list(list, opts = {})
// 90:         queue = new(opts)
// 91:         list.each{|item| queue << item }
// 92:         queue
// 93:       end
// 94:
// 95:       private
// 96:
// 97:       # Exchange the values at the given indexes within the internal array.
// 98:       #
// 99:       # @param [Integer] x the first index to swap
// 100:       # @param [Integer] y the second index to swap
// 101:       #
// 102:       # @!visibility private
// 103:       def swap(x, y)
// 104:         temp = @queue[x]
// 105:         @queue[x] = @queue[y]
// 106:         @queue[y] = temp
// 107:       end
// 108:
// 109:       # Are the items at the given indexes ordered based on the priority
// 110:       # order specified at construction?
// 111:       #
// 112:       # @param [Integer] x the first index from which to retrieve a comparable value
// 113:       # @param [Integer] y the second index from which to retrieve a comparable value
// 114:       #
// 115:       # @return [Boolean] true if the two elements are in the correct priority order
// 116:       #   else false
// 117:       #
// 118:       # @!visibility private
// 119:       def ordered?(x, y)
// 120:         (@queue[x] <=> @queue[y]) == @comparator
// 121:       end
// 122:
// 123:       # Percolate down to maintain heap invariant.
// 124:       #
// 125:       # @param [Integer] k the index at which to start the percolation
// 126:       #
// 127:       # @!visibility private
// 128:       def sink(k)
// 129:         success = false
// 130:
// 131:         while (j = (2 * k)) <= @length do
// 132:           j += 1 if j < @length && ! ordered?(j, j+1)
// 133:           break if ordered?(k, j)
// 134:           swap(k, j)
// 135:           success = true
// 136:           k = j
// 137:         end
// 138:
// 139:         success
// 140:       end
// 141:
// 142:       # Percolate up to maintain heap invariant.
// 143:       #
// 144:       # @param [Integer] k the index at which to start the percolation
// 145:       #
// 146:       # @!visibility private
// 147:       def swim(k)
// 148:         success = false
// 149:
// 150:         while k > 1 && ! ordered?(k/2, k) do
// 151:           swap(k, k/2)
// 152:           k = k/2
// 153:           success = true
// 154:         end
// 155:
// 156:         success
// 157:       end
// 158:     end
// 159:   end
// 160: end
