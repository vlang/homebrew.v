module collection

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/lock_free_stack.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct LockFreeStackNode {
pub:
	empty     bool
	following &LockFreeStackNode = unsafe { nil }
mut:
	value brew_runtime.Value
}

pub type StackHeadUpdate = fn(&LockFreeStackNode) &LockFreeStackNode

pub type StackEach = fn(brew_runtime.Value)

@[heap]
pub struct LockFreeStack {
mut:
	lock  sync.Mutex
	head  &LockFreeStackNode
	empty &LockFreeStackNode
}

fn lock_free_stack_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn new_lock_free_stack_empty_node() &LockFreeStackNode {
	return &LockFreeStackNode{
		empty: true
		value: lock_free_stack_nil_value()
	}
}

pub fn new_lock_free_stack_node(value brew_runtime.Value, next_node &LockFreeStackNode) &LockFreeStackNode {
	return &LockFreeStackNode{
		value: value
		following: next_node
	}
}

pub fn (node &LockFreeStackNode) next_node() &LockFreeStackNode {
	if node.empty {
		return node
	}
	return node.following
}

pub fn (mut node LockFreeStackNode) set_value(value brew_runtime.Value) brew_runtime.Value {
	node.value = value
	return value
}

pub fn new_lock_free_stack() &LockFreeStack {
	empty := new_lock_free_stack_empty_node()
	return &LockFreeStack{
		head: empty
		empty: empty
	}
}

pub fn lock_free_stack_of1(value brew_runtime.Value) &LockFreeStack {
	mut stack := new_lock_free_stack()
	stack.head = new_lock_free_stack_node(value, stack.empty)
	return stack
}

pub fn lock_free_stack_of2(value1 brew_runtime.Value, value2 brew_runtime.Value) &LockFreeStack {
	mut stack := new_lock_free_stack()
	second := new_lock_free_stack_node(value2, stack.empty)
	stack.head = new_lock_free_stack_node(value1, second)
	return stack
}

pub fn new_lock_free_stack_with_head(head &LockFreeStackNode) &LockFreeStack {
	empty := new_lock_free_stack_empty_node()
	return &LockFreeStack{
		head: head
		empty: empty
	}
}

pub fn (mut stack LockFreeStack) head_node() &LockFreeStackNode {
	stack.lock.lock()
	head := stack.head
	stack.lock.unlock()
	return head
}

pub fn (mut stack LockFreeStack) set_head(head &LockFreeStackNode) &LockFreeStackNode {
	stack.lock.lock()
	stack.head = head
	stack.lock.unlock()
	return head
}

pub fn (mut stack LockFreeStack) compare_and_set_head(expected &LockFreeStackNode, prospect &LockFreeStackNode) bool {
	stack.lock.lock()
	if stack.head == expected {
		stack.head = prospect
		stack.lock.unlock()
		return true
	}
	stack.lock.unlock()
	return false
}

pub fn (mut stack LockFreeStack) swap_head(prospect &LockFreeStackNode) &LockFreeStackNode {
	stack.lock.lock()
	previous := stack.head
	stack.head = prospect
	stack.lock.unlock()
	return previous
}

pub fn (mut stack LockFreeStack) update_head(action StackHeadUpdate) &LockFreeStackNode {
	for {
		current := stack.head_node()
		prospect := action(current)
		if stack.compare_and_set_head(current, prospect) {
			return prospect
		}
	}
	return stack.empty
}

pub fn (mut stack LockFreeStack) empty_with_head(head &LockFreeStackNode) bool {
	return head.empty
}

pub fn (mut stack LockFreeStack) is_empty() bool {
	return stack.empty_with_head(stack.head_node())
}

pub fn (mut stack LockFreeStack) compare_and_push(head &LockFreeStackNode, value brew_runtime.Value) bool {
	return stack.compare_and_set_head(head, new_lock_free_stack_node(value, head))
}

pub fn (mut stack LockFreeStack) push(value brew_runtime.Value) &LockFreeStack {
	for {
		current := stack.head_node()
		if stack.compare_and_push(current, value) {
			return stack
		}
	}
	return stack
}

pub fn (mut stack LockFreeStack) peek() &LockFreeStackNode {
	return stack.head_node()
}

pub fn (mut stack LockFreeStack) compare_and_pop(head &LockFreeStackNode) bool {
	return stack.compare_and_set_head(head, head.next_node())
}

pub fn (mut stack LockFreeStack) pop() brew_runtime.Value {
	for {
		current := stack.head_node()
		if stack.compare_and_pop(current) {
			return current.value
		}
	}
	return lock_free_stack_nil_value()
}

pub fn (mut stack LockFreeStack) compare_and_clear(head &LockFreeStackNode) bool {
	return stack.compare_and_set_head(head, stack.empty)
}

pub fn (mut stack LockFreeStack) values_from(head &LockFreeStackNode) []brew_runtime.Value {
	mut values := []brew_runtime.Value{}
	mut node_address := u64(voidptr(head))
	for {
		node := unsafe { &LockFreeStackNode(voidptr(node_address)) }
		if node.empty {
			break
		}
		values << node.value
		node_address = u64(voidptr(node.next_node()))
	}
	return values
}

pub fn (mut stack LockFreeStack) values() []brew_runtime.Value {
	return stack.values_from(stack.peek())
}

pub fn (mut stack LockFreeStack) each_from(head &LockFreeStackNode, action StackEach) &LockFreeStack {
	for value in stack.values_from(head) {
		action(value)
	}
	return stack
}

pub fn (mut stack LockFreeStack) clear() bool {
	for {
		current := stack.head_node()
		if current.empty {
			return false
		}
		if stack.compare_and_clear(current) {
			return true
		}
	}
	return false
}

pub fn (mut stack LockFreeStack) clear_if(head &LockFreeStackNode) bool {
	return stack.compare_and_clear(head)
}

pub fn (mut stack LockFreeStack) replace_if(head &LockFreeStackNode, new_head &LockFreeStackNode) bool {
	return stack.compare_and_set_head(head, new_head)
}

pub fn (mut stack LockFreeStack) clear_each(action StackEach) &LockFreeStack {
	for {
		current := stack.head_node()
		if current.empty {
			return stack
		}
		if stack.compare_and_clear(current) {
			return stack.each_from(current, action)
		}
	}
	return stack
}

pub fn (mut stack LockFreeStack) str() string {
	return '#<Concurrent::LockFreeStack ${stack.values().map(it.repr)}>'
}

fn lock_free_stack_node_boundary(node &LockFreeStackNode) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::LockFreeStack::Node', '#<Concurrent::LockFreeStack::Node>', {
		'lock_free_stack_node_address': u64(voidptr(node)).str()
	})
}

fn lock_free_stack_boundary(stack &LockFreeStack) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::LockFreeStack', '#<Concurrent::LockFreeStack>', {
		'lock_free_stack_address': u64(voidptr(stack)).str()
	})
}

fn lock_free_stack_node_from_value(value brew_runtime.Value) &LockFreeStackNode {
	if value.type_name == 'NilClass' {
		return new_lock_free_stack_empty_node()
	}
	address := (value.attribute('lock_free_stack_node_address') or {
		panic('${value.type_name} has no translated LockFreeStack::Node state')
	}).u64()
	return unsafe { &LockFreeStackNode(voidptr(address)) }
}

fn lock_free_stack_boundary_receiver(args []brew_runtime.Value) &LockFreeStack {
	if args.len == 0 {
		panic('LockFreeStack method requires a receiver')
	}
	address := (args[0].attribute('lock_free_stack_address') or {
		panic('${args[0].type_name} has no translated LockFreeStack state')
	}).u64()
	return unsafe { &LockFreeStack(voidptr(address)) }
}

// Ruby attr_reader `attr_reader :next_node` at line 14.
pub fn ruby_lock_free_stack_l14_d1_next_node(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('LockFreeStack::Node#next_node requires a receiver')
	}
	return lock_free_stack_node_boundary(lock_free_stack_node_from_value(args[0]).next_node())
}

// Ruby attr_reader `attr_reader :value` at line 17.
pub fn ruby_lock_free_stack_l17_d2_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('LockFreeStack::Node#value requires a receiver')
	}
	return lock_free_stack_node_from_value(args[0]).value
}

// Ruby attr_writer `attr_writer :value` at line 21.
pub fn ruby_lock_free_stack_l21_d3_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('LockFreeStack::Node#value= requires a value')
	}
	mut node := lock_free_stack_node_from_value(args[0])
	return node.set_value(args[1])
}

// Ruby method `initialize(value, next_node)` at line 23.
pub fn ruby_lock_free_stack_l23_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('LockFreeStack::Node.new requires value and next node')
	}
	return lock_free_stack_node_boundary(new_lock_free_stack_node(args[0], lock_free_stack_node_from_value(args[1])))
}

// Ruby alias_method `singleton_class.send :alias_method, :[], :new` at line 28.
pub fn ruby_lock_free_stack_l28_d5_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_lock_free_stack_l23_d4_initialize(...args)
}

// Ruby method `EMPTY.next_node` at line 33.
pub fn ruby_lock_free_stack_l33_d6_empty_next_node(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 0 {
		return args[0]
	}
	return lock_free_stack_node_boundary(new_lock_free_stack_empty_node())
}

// Ruby attr_atomic `attr_atomic(:head)` at line 37.
pub fn ruby_lock_free_stack_l37_d7_head(args ...brew_runtime.Value) brew_runtime.Value {
	mut stack := lock_free_stack_boundary_receiver(args)
	return lock_free_stack_node_boundary(stack.head_node())
}

// Ruby attr_atomic `attr_atomic(:head)` at line 37.
pub fn ruby_lock_free_stack_l37_d8_head(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('LockFreeStack#head= requires a node')
	}
	mut stack := lock_free_stack_boundary_receiver(args)
	return lock_free_stack_node_boundary(stack.set_head(lock_free_stack_node_from_value(args[1])))
}

// Ruby attr_atomic `attr_atomic(:head)` at line 37.
pub fn ruby_lock_free_stack_l37_d9_compare_and_set_head(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('compare_and_set_head requires expected and prospect nodes')
	}
	mut stack := lock_free_stack_boundary_receiver(args)
	return brew_runtime.bool_value(stack.compare_and_set_head(lock_free_stack_node_from_value(args[1]), lock_free_stack_node_from_value(args[2])))
}

// Ruby attr_atomic `attr_atomic(:head)` at line 37.
pub fn ruby_lock_free_stack_l37_d10_swap_head(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('swap_head requires a prospect node')
	}
	mut stack := lock_free_stack_boundary_receiver(args)
	return lock_free_stack_node_boundary(stack.swap_head(lock_free_stack_node_from_value(args[1])))
}

// Ruby attr_atomic `attr_atomic(:head)` at line 37.
pub fn ruby_lock_free_stack_l37_d11_update_head(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('update_head requires the translated block result node')
	}
	mut stack := lock_free_stack_boundary_receiver(args)
	return lock_free_stack_node_boundary(stack.set_head(lock_free_stack_node_from_value(args[1])))
}

// Ruby method `self.of1(value)` at line 41.
pub fn ruby_lock_free_stack_l41_d12_self_of1(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('LockFreeStack.of1 requires a value')
	}
	return lock_free_stack_boundary(lock_free_stack_of1(args[0]))
}

// Ruby method `self.of2(value1, value2)` at line 46.
pub fn ruby_lock_free_stack_l46_d13_self_of2(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('LockFreeStack.of2 requires two values')
	}
	return lock_free_stack_boundary(lock_free_stack_of2(args[0], args[1]))
}

// Ruby method `initialize(head = EMPTY)` at line 51.
pub fn ruby_lock_free_stack_l51_d14_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 0 && args[0].type_name == 'Concurrent::LockFreeStack::Node' {
		return lock_free_stack_boundary(new_lock_free_stack_with_head(lock_free_stack_node_from_value(args[0])))
	}
	return lock_free_stack_boundary(new_lock_free_stack())
}

// Ruby method `empty?(head = head())` at line 58.
pub fn ruby_lock_free_stack_l58_d15_empty(args ...brew_runtime.Value) brew_runtime.Value {
	mut stack := lock_free_stack_boundary_receiver(args)
	if args.len > 1 {
		return brew_runtime.bool_value(stack.empty_with_head(lock_free_stack_node_from_value(args[1])))
	}
	return brew_runtime.bool_value(stack.is_empty())
}

// Ruby method `compare_and_push(head, value)` at line 65.
pub fn ruby_lock_free_stack_l65_d16_compare_and_push(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('compare_and_push requires head and value')
	}
	mut stack := lock_free_stack_boundary_receiver(args)
	return brew_runtime.bool_value(stack.compare_and_push(lock_free_stack_node_from_value(args[1]), args[2]))
}

// Ruby method `push(value)` at line 71.
pub fn ruby_lock_free_stack_l71_d17_push(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('LockFreeStack#push requires a value')
	}
	mut stack := lock_free_stack_boundary_receiver(args)
	stack.push(args[1])
	return args[0]
}

// Ruby method `peek` at line 79.
pub fn ruby_lock_free_stack_l79_d18_peek(args ...brew_runtime.Value) brew_runtime.Value {
	mut stack := lock_free_stack_boundary_receiver(args)
	return lock_free_stack_node_boundary(stack.peek())
}

// Ruby method `compare_and_pop(head)` at line 85.
pub fn ruby_lock_free_stack_l85_d19_compare_and_pop(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('compare_and_pop requires a head node')
	}
	mut stack := lock_free_stack_boundary_receiver(args)
	return brew_runtime.bool_value(stack.compare_and_pop(lock_free_stack_node_from_value(args[1])))
}

// Ruby method `pop` at line 90.
pub fn ruby_lock_free_stack_l90_d20_pop(args ...brew_runtime.Value) brew_runtime.Value {
	mut stack := lock_free_stack_boundary_receiver(args)
	return stack.pop()
}

// Ruby method `compare_and_clear(head)` at line 99.
pub fn ruby_lock_free_stack_l99_d21_compare_and_clear(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('compare_and_clear requires a head node')
	}
	mut stack := lock_free_stack_boundary_receiver(args)
	return brew_runtime.bool_value(stack.compare_and_clear(lock_free_stack_node_from_value(args[1])))
}

// Ruby method `each(head = nil)` at line 107.
pub fn ruby_lock_free_stack_l107_d22_each(args ...brew_runtime.Value) brew_runtime.Value {
	mut stack := lock_free_stack_boundary_receiver(args)
	if args.len > 1 && args[1].type_name != 'NilClass' {
		return brew_runtime.array_value(stack.values_from(lock_free_stack_node_from_value(args[1])))
	}
	return brew_runtime.array_value(stack.values())
}

// Ruby method `clear` at line 118.
pub fn ruby_lock_free_stack_l118_d23_clear(args ...brew_runtime.Value) brew_runtime.Value {
	mut stack := lock_free_stack_boundary_receiver(args)
	return brew_runtime.bool_value(stack.clear())
}

// Ruby method `clear_if(head)` at line 128.
pub fn ruby_lock_free_stack_l128_d24_clear_if(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('clear_if requires a head node')
	}
	mut stack := lock_free_stack_boundary_receiver(args)
	return brew_runtime.bool_value(stack.clear_if(lock_free_stack_node_from_value(args[1])))
}

// Ruby method `replace_if(head, new_head)` at line 135.
pub fn ruby_lock_free_stack_l135_d25_replace_if(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('replace_if requires current and new head nodes')
	}
	mut stack := lock_free_stack_boundary_receiver(args)
	return brew_runtime.bool_value(stack.replace_if(lock_free_stack_node_from_value(args[1]), lock_free_stack_node_from_value(args[2])))
}

// Ruby method `clear_each(&block)` at line 142.
pub fn ruby_lock_free_stack_l142_d26_clear_each(args ...brew_runtime.Value) brew_runtime.Value {
	mut stack := lock_free_stack_boundary_receiver(args)
	stack.clear()
	return args[0]
}

// Ruby method `to_s` at line 154.
pub fn ruby_lock_free_stack_l154_d27_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	mut stack := lock_free_stack_boundary_receiver(args)
	return brew_runtime.string_value(stack.str())
}

// Ruby alias_method `alias_method :inspect, :to_s` at line 158.
pub fn ruby_lock_free_stack_l158_d28_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_lock_free_stack_l154_d27_to_s(...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/object'
// 2:
// 3: module Concurrent
// 4:
// 5:   # @!macro warn.edge
// 6:   class LockFreeStack < Synchronization::Object
// 7:
// 8:     safe_initialization!
// 9:
// 10:     class Node
// 11:       # TODO (pitr-ch 20-Dec-2016): Could be unified with Stack class?
// 12:
// 13:       # @return [Node]
// 14:       attr_reader :next_node
// 15:
// 16:       # @return [Object]
// 17:       attr_reader :value
// 18:
// 19:       # @!visibility private
// 20:       # allow to nil-ify to free GC when the entry is no longer relevant, not synchronised
// 21:       attr_writer :value
// 22:
// 23:       def initialize(value, next_node)
// 24:         @value     = value
// 25:         @next_node = next_node
// 26:       end
// 27:
// 28:       singleton_class.send :alias_method, :[], :new
// 29:     end
// 30:
// 31:     # The singleton for empty node
// 32:     EMPTY = Node[nil, nil]
// 33:     def EMPTY.next_node
// 34:       self
// 35:     end
// 36:
// 37:     attr_atomic(:head)
// 38:     private :head, :head=, :swap_head, :compare_and_set_head, :update_head
// 39:
// 40:     # @!visibility private
// 41:     def self.of1(value)
// 42:       new Node[value, EMPTY]
// 43:     end
// 44:
// 45:     # @!visibility private
// 46:     def self.of2(value1, value2)
// 47:       new Node[value1, Node[value2, EMPTY]]
// 48:     end
// 49:
// 50:     # @param [Node] head
// 51:     def initialize(head = EMPTY)
// 52:       super()
// 53:       self.head = head
// 54:     end
// 55:
// 56:     # @param [Node] head
// 57:     # @return [true, false]
// 58:     def empty?(head = head())
// 59:       head.equal? EMPTY
// 60:     end
// 61:
// 62:     # @param [Node] head
// 63:     # @param [Object] value
// 64:     # @return [true, false]
// 65:     def compare_and_push(head, value)
// 66:       compare_and_set_head head, Node[value, head]
// 67:     end
// 68:
// 69:     # @param [Object] value
// 70:     # @return [self]
// 71:     def push(value)
// 72:       while true
// 73:         current_head = head
// 74:         return self if compare_and_set_head current_head, Node[value, current_head]
// 75:       end
// 76:     end
// 77:
// 78:     # @return [Node]
// 79:     def peek
// 80:       head
// 81:     end
// 82:
// 83:     # @param [Node] head
// 84:     # @return [true, false]
// 85:     def compare_and_pop(head)
// 86:       compare_and_set_head head, head.next_node
// 87:     end
// 88:
// 89:     # @return [Object]
// 90:     def pop
// 91:       while true
// 92:         current_head = head
// 93:         return current_head.value if compare_and_set_head current_head, current_head.next_node
// 94:       end
// 95:     end
// 96:
// 97:     # @param [Node] head
// 98:     # @return [true, false]
// 99:     def compare_and_clear(head)
// 100:       compare_and_set_head head, EMPTY
// 101:     end
// 102:
// 103:     include Enumerable
// 104:
// 105:     # @param [Node] head
// 106:     # @return [self]
// 107:     def each(head = nil)
// 108:       return to_enum(:each, head) unless block_given?
// 109:       it = head || peek
// 110:       until it.equal?(EMPTY)
// 111:         yield it.value
// 112:         it = it.next_node
// 113:       end
// 114:       self
// 115:     end
// 116:
// 117:     # @return [true, false]
// 118:     def clear
// 119:       while true
// 120:         current_head = head
// 121:         return false if current_head == EMPTY
// 122:         return true if compare_and_set_head current_head, EMPTY
// 123:       end
// 124:     end
// 125:
// 126:     # @param [Node] head
// 127:     # @return [true, false]
// 128:     def clear_if(head)
// 129:       compare_and_set_head head, EMPTY
// 130:     end
// 131:
// 132:     # @param [Node] head
// 133:     # @param [Node] new_head
// 134:     # @return [true, false]
// 135:     def replace_if(head, new_head)
// 136:       compare_and_set_head head, new_head
// 137:     end
// 138:
// 139:     # @return [self]
// 140:     # @yield over the cleared stack
// 141:     # @yieldparam [Object] value
// 142:     def clear_each(&block)
// 143:       while true
// 144:         current_head = head
// 145:         return self if current_head == EMPTY
// 146:         if compare_and_set_head current_head, EMPTY
// 147:           each current_head, &block
// 148:           return self
// 149:         end
// 150:       end
// 151:     end
// 152:
// 153:     # @return [String] Short string representation.
// 154:     def to_s
// 155:       format '%s %s>', super[0..-2], to_a.to_s
// 156:     end
// 157:
// 158:     alias_method :inspect, :to_s
// 159:   end
// 160: end
