module collection

import ruby
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/collection/copy_on_write_observer_set.rb`.
// The original source is retained below until every stub has a typed V body.
pub type ObserverCallback = fn([]ruby.Value) !

pub enum ObserverCopyMode {
	on_write
	on_notify
}

struct ObserverEntry {
	observer ruby.Value
	function string
	callback ?ObserverCallback
}

@[heap]
struct ObserverSetState {
	mode ObserverCopyMode
mut:
	lock      sync.Mutex
	observers map[string]ObserverEntry
}

@[heap]
pub struct ObserverSet {
mut:
	state &ObserverSetState
}

pub fn new_observer_set(mode ObserverCopyMode) &ObserverSet {
	return &ObserverSet{
		state: &ObserverSetState{
			mode: mode
			observers: map[string]ObserverEntry{}
		}
	}
}

fn observer_identity(observer ruby.Value) string {
	return observer.attributes['identity'] or { '${observer.type_name}:${observer.repr}' }
}

pub fn (mut set ObserverSet) add_observer(observer ruby.Value, function string, callback ?ObserverCallback) !ruby.Value {
	if observer.type_name == 'NilClass' && callback == none {
		return error('should pass observer as a first argument or block')
	}
	entry := ObserverEntry{
		observer: observer
		function: if callback == none { function } else { 'call' }
		callback: callback
	}
	key := observer_identity(observer)
	set.state.lock.lock()
	if set.state.mode == .on_write {
		mut copy := set.state.observers.clone()
		copy[key] = entry
		set.state.observers = copy.clone()
	} else {
		set.state.observers[key] = entry
	}
	set.state.lock.unlock()
	return observer
}

pub fn (mut set ObserverSet) delete_observer(observer ruby.Value) ruby.Value {
	key := observer_identity(observer)
	set.state.lock.lock()
	if set.state.mode == .on_write {
		mut copy := set.state.observers.clone()
		copy.delete(key)
		set.state.observers = copy.clone()
	} else {
		set.state.observers.delete(key)
	}
	set.state.lock.unlock()
	return observer
}

pub fn (mut set ObserverSet) delete_observers() {
	set.state.lock.lock()
	set.state.observers = map[string]ObserverEntry{}
	set.state.lock.unlock()
}

pub fn (mut set ObserverSet) count_observers() int {
	set.state.lock.lock()
	defer {
		set.state.lock.unlock()
	}
	return set.state.observers.len
}

fn (mut set ObserverSet) snapshot(clear bool) map[string]ObserverEntry {
	set.state.lock.lock()
	copy := set.state.observers.clone()
	if clear {
		set.state.observers = map[string]ObserverEntry{}
	}
	set.state.lock.unlock()
	return copy
}

pub fn (mut set ObserverSet) notify(args []ruby.Value, clear bool) ![]ruby.Value {
	entries := set.snapshot(clear)
	mut notified := []ruby.Value{cap: entries.len}
	for _, entry in entries {
		if callback := entry.callback {
			callback(args)!
		}
		notified << entry.observer
	}
	return notified
}

fn observer_entries_value(entries map[string]ObserverEntry) ruby.Value {
	mut encoded := map[string]ruby.Value{}
	for key, entry in entries {
		encoded[key] = ruby.structured_value(entry.observer.type_name, entry.observer.repr, {
			'function': entry.function
		})
	}
	return ruby.map_value(encoded)
}

fn observer_boundary_new(mode ObserverCopyMode, type_name string) ruby.Value {
	set := new_observer_set(mode)
	return ruby.structured_value(type_name, '#<${type_name}>', {
		'observer_set_address': u64(voidptr(set)).str()
	})
}

fn observer_boundary_receiver(args []ruby.Value) &ObserverSet {
	if args.len == 0 {
		panic('observer set method requires a receiver')
	}
	address := (args[0].attribute('observer_set_address') or {
		panic('${args[0].type_name} has no translated observer-set state')
	}).u64()
	return unsafe { &ObserverSet(voidptr(address)) }
}

fn observer_boundary_add(args []ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('add_observer requires observer')
	}
	mut set := observer_boundary_receiver(args)
	function := if args.len > 2 { args[2].as_string().trim_left(':') } else { 'update' }
	return set.add_observer(args[1], function, none) or { panic(err) }
}

// Ruby method `initialize` at line 13.
pub fn ruby_copy_on_write_observer_set_l13_d1_initialize(args ...ruby.Value) ruby.Value {
	return observer_boundary_new(.on_write, 'Concurrent::Collection::CopyOnWriteObserverSet')
}

// Ruby method `add_observer(observer = nil, func = :update, &block)` at line 19.
pub fn ruby_copy_on_write_observer_set_l19_d2_add_observer(args ...ruby.Value) ruby.Value {
	return observer_boundary_add(args)
}

// Ruby method `delete_observer(observer)` at line 40.
pub fn ruby_copy_on_write_observer_set_l40_d3_delete_observer(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('delete_observer requires observer')
	}
	mut set := observer_boundary_receiver(args)
	return set.delete_observer(args[1])
}

// Ruby method `delete_observers` at line 50.
pub fn ruby_copy_on_write_observer_set_l50_d4_delete_observers(args ...ruby.Value) ruby.Value {
	mut set := observer_boundary_receiver(args)
	set.delete_observers()
	return args[0]
}

// Ruby method `count_observers` at line 56.
pub fn ruby_copy_on_write_observer_set_l56_d5_count_observers(args ...ruby.Value) ruby.Value {
	mut set := observer_boundary_receiver(args)
	return ruby.int_value(set.count_observers())
}

// Ruby method `notify_observers(*args, &block)` at line 63.
pub fn ruby_copy_on_write_observer_set_l63_d6_notify_observers(args ...ruby.Value) ruby.Value {
	mut set := observer_boundary_receiver(args)
	set.notify(args[1..], false) or { panic(err) }
	return args[0]
}

// Ruby method `notify_and_delete_observers(*args, &block)` at line 72.
pub fn ruby_copy_on_write_observer_set_l72_d7_notify_and_delete_observers(args ...ruby.Value) ruby.Value {
	mut set := observer_boundary_receiver(args)
	set.notify(args[1..], true) or { panic(err) }
	return args[0]
}

// Ruby method `ns_initialize` at line 80.
pub fn ruby_copy_on_write_observer_set_l80_d8_ns_initialize(args ...ruby.Value) ruby.Value {
	mut set := observer_boundary_receiver(args)
	set.delete_observers()
	return args[0]
}

// Ruby method `notify_to(observers, *args)` at line 86.
pub fn ruby_copy_on_write_observer_set_l86_d9_notify_to(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `observers` at line 94.
pub fn ruby_copy_on_write_observer_set_l94_d10_observers(args ...ruby.Value) ruby.Value {
	mut set := observer_boundary_receiver(args)
	return observer_entries_value(set.snapshot(false))
}

// Ruby method `observers=(new_set)` at line 98.
pub fn ruby_copy_on_write_observer_set_l98_d11_observers(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('observers= requires observer map')
	}
	mut set := observer_boundary_receiver(args)
	values := args[1].as_map() or { panic(err) }
	set.delete_observers()
	for _, observer in values {
		function := observer.attributes['function'] or { 'update' }
		set.add_observer(observer, function, none) or { panic(err) }
	}
	return args[1]
}

// Ruby method `clear_observers_and_return_old` at line 102.
pub fn ruby_copy_on_write_observer_set_l102_d12_clear_observers_and_return_old(args ...ruby.Value) ruby.Value {
	mut set := observer_boundary_receiver(args)
	return observer_entries_value(set.snapshot(true))
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
