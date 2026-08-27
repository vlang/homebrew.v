module concern

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/concern/observable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `add_observer(observer = nil, func = :update, &block)` at line 61.
pub fn ruby_observable_l61_d1_add_observer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('add_observer', ...args)
}

// Ruby method `with_observer(observer = nil, func = :update, &block)` at line 70.
pub fn ruby_observable_l70_d2_with_observer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('with_observer', ...args)
}

// Ruby method `delete_observer(observer)` at line 82.
pub fn ruby_observable_l82_d3_delete_observer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delete_observer', ...args)
}

// Ruby method `delete_observers` at line 91.
pub fn ruby_observable_l91_d4_delete_observers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delete_observers', ...args)
}

// Ruby method `count_observers` at line 101.
pub fn ruby_observable_l101_d5_count_observers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('count_observers', ...args)
}

// Ruby attr_accessor `attr_accessor :observers` at line 107.
pub fn ruby_observable_l107_d6_observers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('observers', ...args)
}

// Ruby attr_accessor `attr_accessor :observers` at line 107.
pub fn ruby_observable_l107_d7_observers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('observers=', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/collection/copy_on_notify_observer_set'
// 2: require 'concurrent/collection/copy_on_write_observer_set'
// 3:
// 4: module Concurrent
// 5:   module Concern
// 6:
// 7:     # The [observer pattern](http://en.wikipedia.org/wiki/Observer_pattern) is one
// 8:     # of the most useful design patterns.
// 9:     #
// 10:     # The workflow is very simple:
// 11:     # - an `observer` can register itself to a `subject` via a callback
// 12:     # - many `observers` can be registered to the same `subject`
// 13:     # - the `subject` notifies all registered observers when its status changes
// 14:     # - an `observer` can deregister itself when is no more interested to receive
// 15:     #     event notifications
// 16:     #
// 17:     # In a single threaded environment the whole pattern is very easy: the
// 18:     # `subject` can use a simple data structure to manage all its subscribed
// 19:     # `observer`s and every `observer` can react directly to every event without
// 20:     # caring about synchronization.
// 21:     #
// 22:     # In a multi threaded environment things are more complex. The `subject` must
// 23:     # synchronize the access to its data structure and to do so currently we're
// 24:     # using two specialized ObserverSet: {Concurrent::Concern::CopyOnWriteObserverSet}
// 25:     # and {Concurrent::Concern::CopyOnNotifyObserverSet}.
// 26:     #
// 27:     # When implementing and `observer` there's a very important rule to remember:
// 28:     # **there are no guarantees about the thread that will execute the callback**
// 29:     #
// 30:     # Let's take this example
// 31:     # ```
// 32:     # class Observer
// 33:     #   def initialize
// 34:     #     @count = 0
// 35:     #   end
// 36:     #
// 37:     #   def update
// 38:     #     @count += 1
// 39:     #   end
// 40:     # end
// 41:     #
// 42:     # obs = Observer.new
// 43:     # [obj1, obj2, obj3, obj4].each { |o| o.add_observer(obs) }
// 44:     # # execute [obj1, obj2, obj3, obj4]
// 45:     # ```
// 46:     #
// 47:     # `obs` is wrong because the variable `@count` can be accessed by different
// 48:     # threads at the same time, so it should be synchronized (using either a Mutex
// 49:     # or an AtomicFixum)
// 50:     module Observable
// 51:
// 52:       # @!macro observable_add_observer
// 53:       #
// 54:       #   Adds an observer to this set. If a block is passed, the observer will be
// 55:       #   created by this method and no other params should be passed.
// 56:       #
// 57:       #   @param [Object] observer the observer to add
// 58:       #   @param [Symbol] func the function to call on the observer during notification.
// 59:       #     Default is :update
// 60:       #   @return [Object] the added observer
// 61:       def add_observer(observer = nil, func = :update, &block)
// 62:         observers.add_observer(observer, func, &block)
// 63:       end
// 64:
// 65:       # As `#add_observer` but can be used for chaining.
// 66:       #
// 67:       # @param [Object] observer the observer to add
// 68:       # @param [Symbol] func the function to call on the observer during notification.
// 69:       # @return [Observable] self
// 70:       def with_observer(observer = nil, func = :update, &block)
// 71:         add_observer(observer, func, &block)
// 72:         self
// 73:       end
// 74:
// 75:       # @!macro observable_delete_observer
// 76:       #
// 77:       #   Remove `observer` as an observer on this object so that it will no
// 78:       #   longer receive notifications.
// 79:       #
// 80:       #   @param [Object] observer the observer to remove
// 81:       #   @return [Object] the deleted observer
// 82:       def delete_observer(observer)
// 83:         observers.delete_observer(observer)
// 84:       end
// 85:
// 86:       # @!macro observable_delete_observers
// 87:       #
// 88:       #   Remove all observers associated with this object.
// 89:       #
// 90:       #   @return [Observable] self
// 91:       def delete_observers
// 92:         observers.delete_observers
// 93:         self
// 94:       end
// 95:
// 96:       # @!macro observable_count_observers
// 97:       #
// 98:       #   Return the number of observers associated with this object.
// 99:       #
// 100:       #   @return [Integer] the observers count
// 101:       def count_observers
// 102:         observers.count_observers
// 103:       end
// 104:
// 105:       protected
// 106:
// 107:       attr_accessor :observers
// 108:     end
// 109:   end
// 110: end
