module collection

import ruby
import math

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/ruby_non_concurrent_priority_queue.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum PriorityQueueOrder {
	max
	min
}

pub type PriorityQueueComparator = fn(ruby.Value, ruby.Value) int

pub type PriorityQueueEquality = fn(ruby.Value, ruby.Value) bool

fn compare_priority_values(left ruby.Value, right ruby.Value) int {
	if left.type_name in ['Integer', 'Float'] && right.type_name in ['Integer', 'Float'] {
		left_number := left.as_float() or { return 2 }
		right_number := right.as_float() or { return 2 }
		if math.is_nan(left_number) || math.is_nan(right_number) {
			return 2
		}
		return if left_number < right_number {
			-1
		} else if left_number > right_number { 1 } else { 0 }
	}
	if left.type_name == 'String' && right.type_name == 'String' {
		return if left.repr < right.repr {
			-1
		} else if left.repr > right.repr { 1 } else { 0 }
	}
	return 2
}

fn equal_priority_values(left ruby.Value, right ruby.Value) bool {
	if left.type_name in ['Integer', 'Float'] && right.type_name in ['Integer', 'Float'] {
		return left.as_float() or { return false } == right.as_float() or { return false }
	}
	if left.type_name != right.type_name {
		return false
	}
	return left.repr == right.repr && left.attributes == right.attributes
}

@[heap]
pub struct RubyNonConcurrentPriorityQueue {
	comparator PriorityQueueComparator = compare_priority_values
	equality   PriorityQueueEquality = equal_priority_values
pub:
	order PriorityQueueOrder
mut:
	queue  []ruby.Value
	length int
}

pub fn new_ruby_non_concurrent_priority_queue(order PriorityQueueOrder) RubyNonConcurrentPriorityQueue {
	mut result := RubyNonConcurrentPriorityQueue{
		order: order
	}
	result.clear()
	return result
}

pub fn new_ruby_non_concurrent_priority_queue_with_comparison(order PriorityQueueOrder, comparator PriorityQueueComparator, equality PriorityQueueEquality) RubyNonConcurrentPriorityQueue {
	mut result := RubyNonConcurrentPriorityQueue{
		order: order
		comparator: comparator
		equality: equality
	}
	result.clear()
	return result
}

pub fn priority_queue_from_list_values(list []ruby.Value, order PriorityQueueOrder) !RubyNonConcurrentPriorityQueue {
	mut queue := new_ruby_non_concurrent_priority_queue(order)
	for item in list {
		queue.push(item)!
	}
	return queue
}

pub fn (mut queue RubyNonConcurrentPriorityQueue) clear() bool {
	queue.queue = [ruby.object_value('NilClass', 'nil')]
	queue.length = 0
	return true
}

pub fn (mut queue RubyNonConcurrentPriorityQueue) delete(item ruby.Value) bool {
	if queue.empty() {
		return false
	}
	original_length := queue.length
	mut k := 1
	for k <= queue.length {
		if queue.equality(queue.queue[k], item) {
			queue.swap(k, queue.length)
			queue.length--
			if !queue.sink(k) {
				queue.swim(k)
			}
			queue.queue.pop()
		} else {
			k++
		}
	}
	return queue.length != original_length
}

pub fn (queue &RubyNonConcurrentPriorityQueue) empty() bool {
	return queue.length == 0
}

pub fn (queue &RubyNonConcurrentPriorityQueue) include(item ruby.Value) bool {
	for index in 1 .. queue.length + 1 {
		if queue.equality(queue.queue[index], item) {
			return true
		}
	}
	return false
}

pub fn (queue &RubyNonConcurrentPriorityQueue) size() int {
	return queue.length
}

pub fn (queue &RubyNonConcurrentPriorityQueue) peek() ruby.Value {
	return if queue.empty() { ruby.object_value('NilClass', 'nil') } else { queue.queue[1] }
}

pub fn (mut queue RubyNonConcurrentPriorityQueue) pop() ruby.Value {
	if queue.empty() {
		return ruby.object_value('NilClass', 'nil')
	}
	head := queue.queue[1]
	queue.swap(1, queue.length)
	queue.length--
	queue.sink(1)
	queue.queue.pop()
	return head
}

pub fn (mut queue RubyNonConcurrentPriorityQueue) push(item ruby.Value) !bool {
	if item.type_name == 'NilClass' {
		return error('cannot enqueue nil')
	}
	queue.length++
	queue.queue << item
	queue.swim(queue.length)
	return true
}

pub fn (mut queue RubyNonConcurrentPriorityQueue) swap(x int, y int) ruby.Value {
	temporary := queue.queue[x]
	queue.queue[x] = queue.queue[y]
	queue.queue[y] = temporary
	return temporary
}

pub fn (queue &RubyNonConcurrentPriorityQueue) ordered(x int, y int) bool {
	wanted := if queue.order == .min { -1 } else { 1 }
	return queue.comparator(queue.queue[x], queue.queue[y]) == wanted
}

pub fn (mut queue RubyNonConcurrentPriorityQueue) sink(start int) bool {
	mut success := false
	mut k := start
	for 2 * k <= queue.length {
		mut j := 2 * k
		if j < queue.length && !queue.ordered(j, j + 1) {
			j++
		}
		if queue.ordered(k, j) {
			break
		}
		queue.swap(k, j)
		success = true
		k = j
	}
	return success
}

pub fn (mut queue RubyNonConcurrentPriorityQueue) swim(start int) bool {
	mut success := false
	mut k := start
	for k > 1 && !queue.ordered(k / 2, k) {
		queue.swap(k, k / 2)
		k /= 2
		success = true
	}
	return success
}

@[heap]
struct PriorityQueueBoundaryState {
mut:
	queue RubyNonConcurrentPriorityQueue
}

fn priority_queue_order_from_value(value ruby.Value) PriorityQueueOrder {
	order := if item := value.map_data['order'] {
		item.as_string().trim_left(':')
	} else {
		value.as_string().trim_left(':')
	}
	return if order in ['min', 'low'] { .min } else { .max }
}

fn priority_queue_boundary_new(type_name string, order PriorityQueueOrder) ruby.Value {
	state := &PriorityQueueBoundaryState{
		queue: new_ruby_non_concurrent_priority_queue(order)
	}
	return ruby.structured_value(type_name, '#<${type_name}>', {
		'queue_address': u64(voidptr(state)).str()
		'order':         order.str()
	})
}

fn priority_queue_boundary_state(args []ruby.Value) &PriorityQueueBoundaryState {
	if args.len == 0 {
		panic('priority queue method requires a receiver')
	}
	address := (args[0].attribute('queue_address') or {
		panic('${args[0].type_name} has no translated priority queue state')
	}).u64()
	return unsafe { &PriorityQueueBoundaryState(voidptr(address)) }
}

fn priority_queue_boundary_initialize(type_name string, args []ruby.Value) ruby.Value {
	order := if args.len > 0 {
		priority_queue_order_from_value(args[0])
	} else {
		PriorityQueueOrder.max
	}
	return priority_queue_boundary_new(type_name, order)
}

fn priority_queue_boundary_from_list(type_name string, args []ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('from_list requires a list')
	}
	order := if args.len > 1 {
		priority_queue_order_from_value(args[1])
	} else {
		PriorityQueueOrder.max
	}
	receiver := priority_queue_boundary_new(type_name, order)
	mut state := priority_queue_boundary_state([receiver])
	for item in args[0].as_array() or { panic(err) } {
		state.queue.push(item) or { panic(err) }
	}
	return receiver
}

// Ruby method `initialize(opts = {})` at line 11.
pub fn ruby_ruby_non_concurrent_priority_queue_l11_d1_initialize(args ...ruby.Value) ruby.Value {
	return priority_queue_boundary_initialize('Concurrent::Collection::RubyNonConcurrentPriorityQueue', args)
}

// Ruby method `clear` at line 18.
pub fn ruby_ruby_non_concurrent_priority_queue_l18_d2_clear(args ...ruby.Value) ruby.Value {
	mut state := priority_queue_boundary_state(args)
	return ruby.bool_value(state.queue.clear())
}

// Ruby method `delete(item)` at line 25.
pub fn ruby_ruby_non_concurrent_priority_queue_l25_d3_delete(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('priority queue delete requires a receiver and item')
	}
	mut state := priority_queue_boundary_state(args)
	return ruby.bool_value(state.queue.delete(args[1]))
}

// Ruby method `empty?` at line 43.
pub fn ruby_ruby_non_concurrent_priority_queue_l43_d4_empty(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(priority_queue_boundary_state(args).queue.empty())
}

// Ruby method `include?(item)` at line 48.
pub fn ruby_ruby_non_concurrent_priority_queue_l48_d5_include(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('priority queue include? requires a receiver and item')
	}
	return ruby.bool_value(priority_queue_boundary_state(args).queue.include(args[1]))
}

// Ruby alias_method `alias_method :has_priority?, :include?` at line 51.
pub fn ruby_ruby_non_concurrent_priority_queue_l51_d6_has_priority(args ...ruby.Value) ruby.Value {
	return ruby_ruby_non_concurrent_priority_queue_l48_d5_include(...args)
}

// Ruby method `length` at line 54.
pub fn ruby_ruby_non_concurrent_priority_queue_l54_d7_length(args ...ruby.Value) ruby.Value {
	return ruby.int_value(priority_queue_boundary_state(args).queue.size())
}

// Ruby alias_method `alias_method :size, :length` at line 57.
pub fn ruby_ruby_non_concurrent_priority_queue_l57_d8_size(args ...ruby.Value) ruby.Value {
	return ruby_ruby_non_concurrent_priority_queue_l54_d7_length(...args)
}

// Ruby method `peek` at line 60.
pub fn ruby_ruby_non_concurrent_priority_queue_l60_d9_peek(args ...ruby.Value) ruby.Value {
	return priority_queue_boundary_state(args).queue.peek()
}

// Ruby method `pop` at line 65.
pub fn ruby_ruby_non_concurrent_priority_queue_l65_d10_pop(args ...ruby.Value) ruby.Value {
	mut state := priority_queue_boundary_state(args)
	return state.queue.pop()
}

// Ruby alias_method `alias_method :deq, :pop` at line 74.
pub fn ruby_ruby_non_concurrent_priority_queue_l74_d11_deq(args ...ruby.Value) ruby.Value {
	return ruby_ruby_non_concurrent_priority_queue_l65_d10_pop(...args)
}

// Ruby alias_method `alias_method :shift, :pop` at line 75.
pub fn ruby_ruby_non_concurrent_priority_queue_l75_d12_shift(args ...ruby.Value) ruby.Value {
	return ruby_ruby_non_concurrent_priority_queue_l65_d10_pop(...args)
}

// Ruby method `push(item)` at line 78.
pub fn ruby_ruby_non_concurrent_priority_queue_l78_d13_push(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('priority queue push requires a receiver and item')
	}
	mut state := priority_queue_boundary_state(args)
	return ruby.bool_value(state.queue.push(args[1]) or { panic(err) })
}

// Ruby alias_method `alias_method :<<, :push` at line 85.
pub fn ruby_ruby_non_concurrent_priority_queue_l85_d14_push(args ...ruby.Value) ruby.Value {
	return ruby_ruby_non_concurrent_priority_queue_l78_d13_push(...args)
}

// Ruby alias_method `alias_method :enq, :push` at line 86.
pub fn ruby_ruby_non_concurrent_priority_queue_l86_d15_enq(args ...ruby.Value) ruby.Value {
	return ruby_ruby_non_concurrent_priority_queue_l78_d13_push(...args)
}

// Ruby method `self.from_list(list, opts = {})` at line 89.
pub fn ruby_ruby_non_concurrent_priority_queue_l89_d16_self_from_list(args ...ruby.Value) ruby.Value {
	return priority_queue_boundary_from_list('Concurrent::Collection::RubyNonConcurrentPriorityQueue', args)
}

// Ruby method `swap(x, y)` at line 103.
pub fn ruby_ruby_non_concurrent_priority_queue_l103_d17_swap(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('priority queue swap requires a receiver and two indexes')
	}
	mut state := priority_queue_boundary_state(args)
	return state.queue.swap(int(args[1].as_int() or { panic(err) }), int(args[2].as_int() or {
		panic(err)
	}))
}

// Ruby method `ordered?(x, y)` at line 119.
pub fn ruby_ruby_non_concurrent_priority_queue_l119_d18_ordered(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('priority queue ordered? requires a receiver and two indexes')
	}
	state := priority_queue_boundary_state(args)
	return ruby.bool_value(state.queue.ordered(int(args[1].as_int() or { panic(err) }), int(args[2].as_int() or { panic(err) })))
}

// Ruby method `sink(k)` at line 128.
pub fn ruby_ruby_non_concurrent_priority_queue_l128_d19_sink(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('priority queue sink requires a receiver and index')
	}
	mut state := priority_queue_boundary_state(args)
	return ruby.bool_value(state.queue.sink(int(args[1].as_int() or { panic(err) })))
}

// Ruby method `swim(k)` at line 147.
pub fn ruby_ruby_non_concurrent_priority_queue_l147_d20_swim(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('priority queue swim requires a receiver and index')
	}
	mut state := priority_queue_boundary_state(args)
	return ruby.bool_value(state.queue.swim(int(args[1].as_int() or { panic(err) })))
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
