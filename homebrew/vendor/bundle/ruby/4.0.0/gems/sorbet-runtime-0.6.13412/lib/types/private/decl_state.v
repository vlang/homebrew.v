module private

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/decl_state.rb`.
// The original source is retained below until every stub has a typed V body.
pub type DeclStateAction = fn(mut DeclState) !brew_runtime.Value

@[heap]
pub struct DeclState {
mut:
	active_declaration   brew_runtime.Value
	skip_on_method_added bool
	previous_declaration brew_runtime.Value
}

@[heap]
struct DeclStateThreads {
	mutex &sync.Mutex = sync.new_mutex()
mut:
	states map[u64]&DeclState
}

fn new_decl_state() &DeclState {
	return &DeclState{
		active_declaration: brew_runtime.object_value('NilClass', 'nil')
		previous_declaration: brew_runtime.object_value('NilClass', 'nil')
	}
}

fn new_decl_state_threads() &DeclStateThreads {
	return &DeclStateThreads{}
}

const decl_state_threads_global = new_decl_state_threads()

pub fn current_decl_state() &DeclState {
	mut threads := unsafe { &DeclStateThreads(decl_state_threads_global) }
	thread_id := sync.thread_id()
	threads.mutex.lock()
	defer {
		threads.mutex.unlock()
	}
	if state := threads.states[thread_id] {
		return state
	}
	state := new_decl_state()
	threads.states[thread_id] = state
	return state
}

pub fn set_current_decl_state(state &DeclState) {
	mut threads := unsafe { &DeclStateThreads(decl_state_threads_global) }
	threads.mutex.lock()
	threads.states[sync.thread_id()] = state
	threads.mutex.unlock()
}

pub fn (mut state DeclState) reset() {
	state.active_declaration = brew_runtime.object_value('NilClass', 'nil')
	state.previous_declaration = brew_runtime.object_value('NilClass', 'nil')
}

pub fn (mut state DeclState) consume() brew_runtime.Value {
	state.previous_declaration = state.active_declaration
	state.active_declaration = brew_runtime.object_value('NilClass', 'nil')
	return state.previous_declaration
}

pub fn (mut state DeclState) without_on_method_added(action DeclStateAction) !brew_runtime.Value {
	old_value := state.skip_on_method_added
	state.skip_on_method_added = true
	defer {
		state.skip_on_method_added = old_value
	}
	return action(mut state)!
}

fn decl_state_value(state &DeclState) brew_runtime.Value {
	return brew_runtime.structured_value('T::Private::DeclState', '#<T::Private::DeclState>', {
		'decl_state_address': u64(voidptr(state)).str()
	})
}

fn decl_state_from_value(value brew_runtime.Value) &DeclState {
	address := value.attribute('decl_state_address') or { panic('invalid DeclState receiver') }
	return unsafe { &DeclState(voidptr(address.u64())) }
}

fn decl_state_from_args(args []brew_runtime.Value) &DeclState {
	if args.len == 0 {
		panic('DeclState method requires a receiver')
	}
	return decl_state_from_value(args[0])
}

// Ruby method `self.current` at line 5.
pub fn ruby_decl_state_l5_d1_self_current(args ...brew_runtime.Value) brew_runtime.Value {
	return decl_state_value(current_decl_state())
}

// Ruby method `self.current=(other)` at line 9.
pub fn ruby_decl_state_l9_d2_self_current(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('DeclState.current= requires a state')
	}
	state := decl_state_from_value(args[0])
	set_current_decl_state(state)
	return args[0]
}

// Ruby attr_accessor `attr_accessor :active_declaration` at line 13.
pub fn ruby_decl_state_l13_d3_active_declaration(args ...brew_runtime.Value) brew_runtime.Value {
	return decl_state_from_args(args).active_declaration
}

// Ruby attr_accessor `attr_accessor :active_declaration` at line 13.
pub fn ruby_decl_state_l13_d4_active_declaration(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('DeclState#active_declaration= requires a value')
	}
	mut state := decl_state_from_args(args)
	state.active_declaration = args[1]
	return args[1]
}

// Ruby attr_accessor `attr_accessor :skip_on_method_added` at line 14.
pub fn ruby_decl_state_l14_d5_skip_on_method_added(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(decl_state_from_args(args).skip_on_method_added)
}

// Ruby attr_accessor `attr_accessor :skip_on_method_added` at line 14.
pub fn ruby_decl_state_l14_d6_skip_on_method_added(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('DeclState#skip_on_method_added= requires a value')
	}
	mut state := decl_state_from_args(args)
	state.skip_on_method_added = args[1].as_bool() or { panic(err.msg()) }
	return args[1]
}

// Ruby attr_accessor `attr_accessor :previous_declaration` at line 15.
pub fn ruby_decl_state_l15_d7_previous_declaration(args ...brew_runtime.Value) brew_runtime.Value {
	return decl_state_from_args(args).previous_declaration
}

// Ruby attr_accessor `attr_accessor :previous_declaration` at line 15.
pub fn ruby_decl_state_l15_d8_previous_declaration(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('DeclState#previous_declaration= requires a value')
	}
	mut state := decl_state_from_args(args)
	state.previous_declaration = args[1]
	return args[1]
}

// Ruby method `reset!` at line 17.
pub fn ruby_decl_state_l17_d9_reset(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := decl_state_from_args(args)
	state.reset()
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `consume!` at line 22.
pub fn ruby_decl_state_l22_d10_consume(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := decl_state_from_args(args)
	return state.consume()
}

// Ruby method `without_on_method_added` at line 28.
pub fn ruby_decl_state_l28_d11_without_on_method_added(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := decl_state_from_args(args)
	old_value := state.skip_on_method_added
	state.skip_on_method_added = true
	result := if args.len > 1 { args[1] } else { brew_runtime.object_value('NilClass', 'nil') }
	state.skip_on_method_added = old_value
	return result
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: class T::Private::DeclState
// 5:   def self.current
// 6:     Thread.current[:opus_types__decl_state] ||= self.new
// 7:   end
// 8:
// 9:   def self.current=(other)
// 10:     Thread.current[:opus_types__decl_state] = other
// 11:   end
// 12:
// 13:   attr_accessor :active_declaration
// 14:   attr_accessor :skip_on_method_added
// 15:   attr_accessor :previous_declaration
// 16:
// 17:   def reset!
// 18:     self.active_declaration = nil
// 19:     @previous_declaration = nil
// 20:   end
// 21:
// 22:   def consume!
// 23:     @previous_declaration = self.active_declaration
// 24:     self.active_declaration = nil
// 25:     @previous_declaration
// 26:   end
// 27:
// 28:   def without_on_method_added
// 29:     begin
// 30:       # explicit 'self' is needed here
// 31:       old_value = self.skip_on_method_added
// 32:       self.skip_on_method_added = true
// 33:       yield
// 34:     ensure
// 35:       self.skip_on_method_added = old_value
// 36:     end
// 37:   end
// 38: end
