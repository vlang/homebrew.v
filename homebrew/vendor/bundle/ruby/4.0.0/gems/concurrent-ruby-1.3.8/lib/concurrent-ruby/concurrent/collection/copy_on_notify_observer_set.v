module collection

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/copy_on_notify_observer_set.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 14.
pub fn ruby_copy_on_notify_observer_set_l14_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return observer_boundary_new(.on_notify, 'Concurrent::Collection::CopyOnNotifyObserverSet')
}

// Ruby method `add_observer(observer = nil, func = :update, &block)` at line 20.
pub fn ruby_copy_on_notify_observer_set_l20_d2_add_observer(args ...brew_runtime.Value) brew_runtime.Value {
	return observer_boundary_add(args)
}

// Ruby method `delete_observer(observer)` at line 39.
pub fn ruby_copy_on_notify_observer_set_l39_d3_delete_observer(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('delete_observer requires observer')
	}
	mut set := observer_boundary_receiver(args)
	return set.delete_observer(args[1])
}

// Ruby method `delete_observers` at line 47.
pub fn ruby_copy_on_notify_observer_set_l47_d4_delete_observers(args ...brew_runtime.Value) brew_runtime.Value {
	mut set := observer_boundary_receiver(args)
	set.delete_observers()
	return args[0]
}

// Ruby method `count_observers` at line 55.
pub fn ruby_copy_on_notify_observer_set_l55_d5_count_observers(args ...brew_runtime.Value) brew_runtime.Value {
	mut set := observer_boundary_receiver(args)
	return brew_runtime.int_value(set.count_observers())
}

// Ruby method `notify_observers(*args, &block)` at line 62.
pub fn ruby_copy_on_notify_observer_set_l62_d6_notify_observers(args ...brew_runtime.Value) brew_runtime.Value {
	mut set := observer_boundary_receiver(args)
	set.notify(args[1..], false) or { panic(err) }
	return args[0]
}

// Ruby method `notify_and_delete_observers(*args, &block)` at line 72.
pub fn ruby_copy_on_notify_observer_set_l72_d7_notify_and_delete_observers(args ...brew_runtime.Value) brew_runtime.Value {
	mut set := observer_boundary_receiver(args)
	set.notify(args[1..], true) or { panic(err) }
	return args[0]
}

// Ruby method `ns_initialize` at line 80.
pub fn ruby_copy_on_notify_observer_set_l80_d8_ns_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	mut set := observer_boundary_receiver(args)
	set.delete_observers()
	return args[0]
}

// Ruby method `duplicate_and_clear_observers` at line 86.
pub fn ruby_copy_on_notify_observer_set_l86_d9_duplicate_and_clear_observers(args ...brew_runtime.Value) brew_runtime.Value {
	mut set := observer_boundary_receiver(args)
	return observer_entries_value(set.snapshot(true))
}

// Ruby method `duplicate_observers` at line 94.
pub fn ruby_copy_on_notify_observer_set_l94_d10_duplicate_observers(args ...brew_runtime.Value) brew_runtime.Value {
	mut set := observer_boundary_receiver(args)
	return observer_entries_value(set.snapshot(false))
}

// Ruby method `notify_to(observers, *args)` at line 98.
pub fn ruby_copy_on_notify_observer_set_l98_d11_notify_to(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/synchronization/lockable_object'
// 2:
// 3: module Concurrent
// 4:   module Collection
// 5:
// 6:     # A thread safe observer set implemented using copy-on-read approach:
// 7:     # observers are added and removed from a thread safe collection; every time
// 8:     # a notification is required the internal data structure is copied to
// 9:     # prevent concurrency issues
// 10:     #
// 11:     # @api private
// 12:     class CopyOnNotifyObserverSet < Synchronization::LockableObject
// 13:
// 14:       def initialize
// 15:         super()
// 16:         synchronize { ns_initialize }
// 17:       end
// 18:
// 19:       # @!macro observable_add_observer
// 20:       def add_observer(observer = nil, func = :update, &block)
// 21:         if observer.nil? && block.nil?
// 22:           raise ArgumentError, 'should pass observer as a first argument or block'
// 23:         elsif observer && block
// 24:           raise ArgumentError.new('cannot provide both an observer and a block')
// 25:         end
// 26:
// 27:         if block
// 28:           observer = block
// 29:           func     = :call
// 30:         end
// 31:
// 32:         synchronize do
// 33:           @observers[observer] = func
// 34:           observer
// 35:         end
// 36:       end
// 37:
// 38:       # @!macro observable_delete_observer
// 39:       def delete_observer(observer)
// 40:         synchronize do
// 41:           @observers.delete(observer)
// 42:           observer
// 43:         end
// 44:       end
// 45:
// 46:       # @!macro observable_delete_observers
// 47:       def delete_observers
// 48:         synchronize do
// 49:           @observers.clear
// 50:           self
// 51:         end
// 52:       end
// 53:
// 54:       # @!macro observable_count_observers
// 55:       def count_observers
// 56:         synchronize { @observers.count }
// 57:       end
// 58:
// 59:       # Notifies all registered observers with optional args
// 60:       # @param [Object] args arguments to be passed to each observer
// 61:       # @return [CopyOnWriteObserverSet] self
// 62:       def notify_observers(*args, &block)
// 63:         observers = duplicate_observers
// 64:         notify_to(observers, *args, &block)
// 65:         self
// 66:       end
// 67:
// 68:       # Notifies all registered observers with optional args and deletes them.
// 69:       #
// 70:       # @param [Object] args arguments to be passed to each observer
// 71:       # @return [CopyOnWriteObserverSet] self
// 72:       def notify_and_delete_observers(*args, &block)
// 73:         observers = duplicate_and_clear_observers
// 74:         notify_to(observers, *args, &block)
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
// 86:       def duplicate_and_clear_observers
// 87:         synchronize do
// 88:           observers = @observers.dup
// 89:           @observers.clear
// 90:           observers
// 91:         end
// 92:       end
// 93:
// 94:       def duplicate_observers
// 95:         synchronize { @observers.dup }
// 96:       end
// 97:
// 98:       def notify_to(observers, *args)
// 99:         raise ArgumentError.new('cannot give arguments and a block') if block_given? && !args.empty?
// 100:         observers.each do |observer, function|
// 101:           args = yield if block_given?
// 102:           observer.send(function, *args)
// 103:         end
// 104:       end
// 105:     end
// 106:   end
// 107: end
