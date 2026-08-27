module collection

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/copy_on_write_observer_set.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 13.
pub fn ruby_copy_on_write_observer_set_l13_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `add_observer(observer = nil, func = :update, &block)` at line 19.
pub fn ruby_copy_on_write_observer_set_l19_d2_add_observer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('add_observer', ...args)
}

// Ruby method `delete_observer(observer)` at line 40.
pub fn ruby_copy_on_write_observer_set_l40_d3_delete_observer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delete_observer', ...args)
}

// Ruby method `delete_observers` at line 50.
pub fn ruby_copy_on_write_observer_set_l50_d4_delete_observers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delete_observers', ...args)
}

// Ruby method `count_observers` at line 56.
pub fn ruby_copy_on_write_observer_set_l56_d5_count_observers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('count_observers', ...args)
}

// Ruby method `notify_observers(*args, &block)` at line 63.
pub fn ruby_copy_on_write_observer_set_l63_d6_notify_observers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('notify_observers', ...args)
}

// Ruby method `notify_and_delete_observers(*args, &block)` at line 72.
pub fn ruby_copy_on_write_observer_set_l72_d7_notify_and_delete_observers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('notify_and_delete_observers', ...args)
}

// Ruby method `ns_initialize` at line 80.
pub fn ruby_copy_on_write_observer_set_l80_d8_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_initialize', ...args)
}

// Ruby method `notify_to(observers, *args)` at line 86.
pub fn ruby_copy_on_write_observer_set_l86_d9_notify_to(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('notify_to', ...args)
}

// Ruby method `observers` at line 94.
pub fn ruby_copy_on_write_observer_set_l94_d10_observers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('observers', ...args)
}

// Ruby method `observers=(new_set)` at line 98.
pub fn ruby_copy_on_write_observer_set_l98_d11_observers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('observers=', ...args)
}

// Ruby method `clear_observers_and_return_old` at line 102.
pub fn ruby_copy_on_write_observer_set_l102_d12_clear_observers_and_return_old(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clear_observers_and_return_old', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/lockable_object'
// 2:
// 3: module Concurrent
// 4:   module Collection
// 5:
// 6:     # A thread safe observer set implemented using copy-on-write approach:
// 7:     # every time an observer is added or removed the whole internal data structure is
// 8:     # duplicated and replaced with a new one.
// 9:     #
// 10:     # @api private
// 11:     class CopyOnWriteObserverSet < Synchronization::LockableObject
// 12:
// 13:       def initialize
// 14:         super()
// 15:         synchronize { ns_initialize }
// 16:       end
// 17:
// 18:       # @!macro observable_add_observer
// 19:       def add_observer(observer = nil, func = :update, &block)
// 20:         if observer.nil? && block.nil?
// 21:           raise ArgumentError, 'should pass observer as a first argument or block'
// 22:         elsif observer && block
// 23:           raise ArgumentError.new('cannot provide both an observer and a block')
// 24:         end
// 25:
// 26:         if block
// 27:           observer = block
// 28:           func = :call
// 29:         end
// 30:
// 31:         synchronize do
// 32:           new_observers = @observers.dup
// 33:           new_observers[observer] = func
// 34:           @observers = new_observers
// 35:           observer
// 36:         end
// 37:       end
// 38:
// 39:       # @!macro observable_delete_observer
// 40:       def delete_observer(observer)
// 41:         synchronize do
// 42:           new_observers = @observers.dup
// 43:           new_observers.delete(observer)
// 44:           @observers = new_observers
// 45:           observer
// 46:         end
// 47:       end
// 48:
// 49:       # @!macro observable_delete_observers
// 50:       def delete_observers
// 51:         self.observers = {}
// 52:         self
// 53:       end
// 54:
// 55:       # @!macro observable_count_observers
// 56:       def count_observers
// 57:         observers.count
// 58:       end
// 59:
// 60:       # Notifies all registered observers with optional args
// 61:       # @param [Object] args arguments to be passed to each observer
// 62:       # @return [CopyOnWriteObserverSet] self
// 63:       def notify_observers(*args, &block)
// 64:         notify_to(observers, *args, &block)
// 65:         self
// 66:       end
// 67:
// 68:       # Notifies all registered observers with optional args and deletes them.
// 69:       #
// 70:       # @param [Object] args arguments to be passed to each observer
// 71:       # @return [CopyOnWriteObserverSet] self
// 72:       def notify_and_delete_observers(*args, &block)
// 73:         old = clear_observers_and_return_old
// 74:         notify_to(old, *args, &block)
// 75:         self
// 76:       end
// 77:
// 78:       protected
// 79:
// 80:       def ns_initialize
// 81:         @observers = {}
// 82:       end
// 83:
// 84:       private
// 85:
// 86:       def notify_to(observers, *args)
// 87:         raise ArgumentError.new('cannot give arguments and a block') if block_given? && !args.empty?
// 88:         observers.each do |observer, function|
// 89:           args = yield if block_given?
// 90:           observer.send(function, *args)
// 91:         end
// 92:       end
// 93:
// 94:       def observers
// 95:         synchronize { @observers }
// 96:       end
// 97:
// 98:       def observers=(new_set)
// 99:         synchronize { @observers = new_set }
// 100:       end
// 101:
// 102:       def clear_observers_and_return_old
// 103:         synchronize do
// 104:           old_observers = @observers
// 105:           @observers = {}
// 106:           old_observers
// 107:         end
// 108:       end
// 109:     end
// 110:   end
// 111: end
