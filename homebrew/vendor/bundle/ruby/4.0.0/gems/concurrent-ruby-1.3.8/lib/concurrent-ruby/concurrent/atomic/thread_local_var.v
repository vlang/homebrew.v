module atomic

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/thread_local_var.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct ThreadLocalVar {
mut:
	variable &LocalVariable
}

pub fn new_thread_local_var(default_value brew_runtime.Value) &ThreadLocalVar {
	mut storage := new_thread_locals()
	return new_thread_local_var_with_storage(mut storage, default_value)
}

pub fn new_thread_local_var_with_storage(mut storage LocalStorage, default_value brew_runtime.Value) &ThreadLocalVar {
	return &ThreadLocalVar{
		variable: new_local_variable(mut storage, default_value)
	}
}

pub fn new_thread_local_var_with_default_block(default_value brew_runtime.Value, default_block LocalDefaultBlock) !&ThreadLocalVar {
	mut storage := new_thread_locals()
	return new_thread_local_var_with_storage_and_default_block(mut storage, default_value, default_block)
}

pub fn new_thread_local_var_with_storage_and_default_block(mut storage LocalStorage, default_value brew_runtime.Value, default_block LocalDefaultBlock) !&ThreadLocalVar {
	return &ThreadLocalVar{
		variable: new_local_variable_with_default_block(mut storage, default_value, default_block)!
	}
}

pub fn (mut local ThreadLocalVar) value() !brew_runtime.Value {
	return local.variable.value()
}

pub fn (mut local ThreadLocalVar) set(value brew_runtime.Value) !brew_runtime.Value {
	return local.variable.set(value)
}

pub fn (mut local ThreadLocalVar) bind(value brew_runtime.Value, action LocalBindingBlock) !brew_runtime.Value {
	return local.variable.bind(value, action)
}

pub fn (mut local ThreadLocalVar) default_current() !brew_runtime.Value {
	return local.variable.default_current()
}

pub fn (mut local ThreadLocalVar) clear_current_context() {
	local.variable.clear_current_context()
}

pub fn (mut local ThreadLocalVar) free() {
	local.variable.free()
}

pub fn (local &ThreadLocalVar) slot_index() int {
	return local.variable.slot_index()
}

fn thread_local_var_boundary(local &ThreadLocalVar) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::ThreadLocalVar', '#<Concurrent::ThreadLocalVar>', {
		'thread_local_var_address': u64(voidptr(local)).str()
	})
}

fn thread_local_var_boundary_receiver(args []brew_runtime.Value) &ThreadLocalVar {
	if args.len == 0 {
		panic('ThreadLocalVar method requires a receiver')
	}
	address := (args[0].attribute('thread_local_var_address') or {
		panic('${args[0].type_name} has no translated thread-local state')
	}).u64()
	return unsafe { &ThreadLocalVar(voidptr(address)) }
}

// Ruby method `initialize(default = nil, &default_block)` at line 51.
pub fn ruby_thread_local_var_l51_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	default_value := if args.len > 0 { args[0] } else { local_nil_value() }
	mut storage := new_thread_locals()
	local := if args.len > 1 {
		&ThreadLocalVar{
			variable: new_local_variable_with_boundary_default(mut *storage, default_value, args[1]) or { panic(err) }
		}
	} else {
		new_thread_local_var_with_storage(mut storage, default_value)
	}
	return thread_local_var_boundary(local)
}

// Ruby method `value` at line 70.
pub fn ruby_thread_local_var_l70_d2_value(args ...brew_runtime.Value) brew_runtime.Value {
	mut local := thread_local_var_boundary_receiver(args)
	return local.value() or { panic(err) }
}

// Ruby method `value=(value)` at line 78.
pub fn ruby_thread_local_var_l78_d3_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('ThreadLocalVar#value= requires a value')
	}
	mut local := thread_local_var_boundary_receiver(args)
	return local.set(args[1]) or { panic(err) }
}

// Ruby method `bind(value)` at line 88.
pub fn ruby_thread_local_var_l88_d4_bind(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('ThreadLocalVar#bind requires a value')
	}
	if args.len < 3 {
		return local_nil_value()
	}
	mut local := thread_local_var_boundary_receiver(args)
	old_value := local.value() or { panic(err) }
	local.set(args[1]) or { panic(err) }
	defer {
		local.set(old_value) or {}
	}
	return args[2]
}

// Ruby method `default` at line 103.
pub fn ruby_thread_local_var_l103_d5_default(args ...brew_runtime.Value) brew_runtime.Value {
	mut local := thread_local_var_boundary_receiver(args)
	return local.default_current() or { panic(err) }
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/constants'
// 2: require_relative 'locals'
// 3:
// 4: module Concurrent
// 5:
// 6:   # A `ThreadLocalVar` is a variable where the value is different for each thread.
// 7:   # Each variable may have a default value, but when you modify the variable only
// 8:   # the current thread will ever see that change.
// 9:   #
// 10:   # This is similar to Ruby's built-in thread-local variables (`Thread#thread_variable_get`),
// 11:   # but with these major advantages:
// 12:   # * `ThreadLocalVar` has its own identity, it doesn't need a Symbol.
// 13:   # * Each Ruby's built-in thread-local variable leaks some memory forever (it's a Symbol held forever on the thread),
// 14:   #   so it's only OK to create a small amount of them.
// 15:   #   `ThreadLocalVar` has no such issue and it is fine to create many of them.
// 16:   # * Ruby's built-in thread-local variables leak forever the value set on each thread (unless set to nil explicitly).
// 17:   #   `ThreadLocalVar` automatically removes the mapping for each thread once the `ThreadLocalVar` instance is GC'd.
// 18:   #
// 19:   # @!macro thread_safe_variable_comparison
// 20:   #
// 21:   # @example
// 22:   #   v = ThreadLocalVar.new(14)
// 23:   #   v.value #=> 14
// 24:   #   v.value = 2
// 25:   #   v.value #=> 2
// 26:   #
// 27:   # @example
// 28:   #   v = ThreadLocalVar.new(14)
// 29:   #
// 30:   #   t1 = Thread.new do
// 31:   #     v.value #=> 14
// 32:   #     v.value = 1
// 33:   #     v.value #=> 1
// 34:   #   end
// 35:   #
// 36:   #   t2 = Thread.new do
// 37:   #     v.value #=> 14
// 38:   #     v.value = 2
// 39:   #     v.value #=> 2
// 40:   #   end
// 41:   #
// 42:   #   v.value #=> 14
// 43:   class ThreadLocalVar
// 44:     LOCALS = ThreadLocals.new
// 45:
// 46:     # Creates a thread local variable.
// 47:     #
// 48:     # @param [Object] default the default value when otherwise unset
// 49:     # @param [Proc] default_block Optional block that gets called to obtain the
// 50:     #   default value for each thread
// 51:     def initialize(default = nil, &default_block)
// 52:       if default && block_given?
// 53:         raise ArgumentError, "Cannot use both value and block as default value"
// 54:       end
// 55:
// 56:       if block_given?
// 57:         @default_block = default_block
// 58:         @default = nil
// 59:       else
// 60:         @default_block = nil
// 61:         @default = default
// 62:       end
// 63:
// 64:       @index = LOCALS.next_index(self)
// 65:     end
// 66:
// 67:     # Returns the value in the current thread's copy of this thread-local variable.
// 68:     #
// 69:     # @return [Object] the current value
// 70:     def value
// 71:       LOCALS.fetch(@index) { default }
// 72:     end
// 73:
// 74:     # Sets the current thread's copy of this thread-local variable to the specified value.
// 75:     #
// 76:     # @param [Object] value the value to set
// 77:     # @return [Object] the new value
// 78:     def value=(value)
// 79:       LOCALS.set(@index, value)
// 80:     end
// 81:
// 82:     # Bind the given value to thread local storage during
// 83:     # execution of the given block.
// 84:     #
// 85:     # @param [Object] value the value to bind
// 86:     # @yield the operation to be performed with the bound variable
// 87:     # @return [Object] the value
// 88:     def bind(value)
// 89:       if block_given?
// 90:         old_value = self.value
// 91:         self.value = value
// 92:         begin
// 93:           yield
// 94:         ensure
// 95:           self.value = old_value
// 96:         end
// 97:       end
// 98:     end
// 99:
// 100:     protected
// 101:
// 102:     # @!visibility private
// 103:     def default
// 104:       if @default_block
// 105:         self.value = @default_block.call
// 106:       else
// 107:         @default
// 108:       end
// 109:     end
// 110:   end
// 111: end
