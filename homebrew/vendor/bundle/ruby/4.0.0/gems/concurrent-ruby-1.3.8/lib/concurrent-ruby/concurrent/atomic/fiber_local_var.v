module atomic

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/fiber_local_var.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(default = nil, &default_block)` at line 49.
pub fn ruby_fiber_local_var_l49_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `value` at line 68.
pub fn ruby_fiber_local_var_l68_d2_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value', ...args)
}

// Ruby method `value=(value)` at line 76.
pub fn ruby_fiber_local_var_l76_d3_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value=', ...args)
}

// Ruby method `bind(value)` at line 86.
pub fn ruby_fiber_local_var_l86_d4_bind(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bind', ...args)
}

// Ruby method `default` at line 101.
pub fn ruby_fiber_local_var_l101_d5_default(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/constants'
// 2: require_relative 'locals'
// 3:
// 4: module Concurrent
// 5:
// 6:   # A `FiberLocalVar` is a variable where the value is different for each fiber.
// 7:   # Each variable may have a default value, but when you modify the variable only
// 8:   # the current fiber will ever see that change.
// 9:   #
// 10:   # This is similar to Ruby's built-in fiber-local variables (`Thread.current[:name]`),
// 11:   # but with these major advantages:
// 12:   # * `FiberLocalVar` has its own identity, it doesn't need a Symbol.
// 13:   # * Each Ruby's built-in fiber-local variable leaks some memory forever (it's a Symbol held forever on the fiber),
// 14:   #   so it's only OK to create a small amount of them.
// 15:   #   `FiberLocalVar` has no such issue and it is fine to create many of them.
// 16:   # * Ruby's built-in fiber-local variables leak forever the value set on each fiber (unless set to nil explicitly).
// 17:   #   `FiberLocalVar` automatically removes the mapping for each fiber once the `FiberLocalVar` instance is GC'd.
// 18:   #
// 19:   # @example
// 20:   #   v = FiberLocalVar.new(14)
// 21:   #   v.value #=> 14
// 22:   #   v.value = 2
// 23:   #   v.value #=> 2
// 24:   #
// 25:   # @example
// 26:   #   v = FiberLocalVar.new(14)
// 27:   #
// 28:   #   Fiber.new do
// 29:   #     v.value #=> 14
// 30:   #     v.value = 1
// 31:   #     v.value #=> 1
// 32:   #   end.resume
// 33:   #
// 34:   #   Fiber.new do
// 35:   #     v.value #=> 14
// 36:   #     v.value = 2
// 37:   #     v.value #=> 2
// 38:   #   end.resume
// 39:   #
// 40:   #   v.value #=> 14
// 41:   class FiberLocalVar
// 42:     LOCALS = FiberLocals.new
// 43:
// 44:     # Creates a fiber local variable.
// 45:     #
// 46:     # @param [Object] default the default value when otherwise unset
// 47:     # @param [Proc] default_block Optional block that gets called to obtain the
// 48:     #   default value for each fiber
// 49:     def initialize(default = nil, &default_block)
// 50:       if default && block_given?
// 51:         raise ArgumentError, "Cannot use both value and block as default value"
// 52:       end
// 53:
// 54:       if block_given?
// 55:         @default_block = default_block
// 56:         @default = nil
// 57:       else
// 58:         @default_block = nil
// 59:         @default = default
// 60:       end
// 61:
// 62:       @index = LOCALS.next_index(self)
// 63:     end
// 64:
// 65:     # Returns the value in the current fiber's copy of this fiber-local variable.
// 66:     #
// 67:     # @return [Object] the current value
// 68:     def value
// 69:       LOCALS.fetch(@index) { default }
// 70:     end
// 71:
// 72:     # Sets the current fiber's copy of this fiber-local variable to the specified value.
// 73:     #
// 74:     # @param [Object] value the value to set
// 75:     # @return [Object] the new value
// 76:     def value=(value)
// 77:       LOCALS.set(@index, value)
// 78:     end
// 79:
// 80:     # Bind the given value to fiber local storage during
// 81:     # execution of the given block.
// 82:     #
// 83:     # @param [Object] value the value to bind
// 84:     # @yield the operation to be performed with the bound variable
// 85:     # @return [Object] the value
// 86:     def bind(value)
// 87:       if block_given?
// 88:         old_value = self.value
// 89:         self.value = value
// 90:         begin
// 91:           yield
// 92:         ensure
// 93:           self.value = old_value
// 94:         end
// 95:       end
// 96:     end
// 97:
// 98:     protected
// 99:
// 100:     # @!visibility private
// 101:     def default
// 102:       if @default_block
// 103:         self.value = @default_block.call
// 104:       else
// 105:         @default
// 106:       end
// 107:     end
// 108:   end
// 109: end
