module private

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/decl_state.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.current` at line 5.
pub fn ruby_decl_state_l5_d1_self_current(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.current', ...args)
}

// Ruby method `self.current=(other)` at line 9.
pub fn ruby_decl_state_l9_d2_self_current(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.current=', ...args)
}

// Ruby attr_accessor `attr_accessor :active_declaration` at line 13.
pub fn ruby_decl_state_l13_d3_active_declaration(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('active_declaration', ...args)
}

// Ruby attr_accessor `attr_accessor :active_declaration` at line 13.
pub fn ruby_decl_state_l13_d4_active_declaration(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('active_declaration=', ...args)
}

// Ruby attr_accessor `attr_accessor :skip_on_method_added` at line 14.
pub fn ruby_decl_state_l14_d5_skip_on_method_added(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip_on_method_added', ...args)
}

// Ruby attr_accessor `attr_accessor :skip_on_method_added` at line 14.
pub fn ruby_decl_state_l14_d6_skip_on_method_added(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip_on_method_added=', ...args)
}

// Ruby attr_accessor `attr_accessor :previous_declaration` at line 15.
pub fn ruby_decl_state_l15_d7_previous_declaration(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('previous_declaration', ...args)
}

// Ruby attr_accessor `attr_accessor :previous_declaration` at line 15.
pub fn ruby_decl_state_l15_d8_previous_declaration(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('previous_declaration=', ...args)
}

// Ruby method `reset!` at line 17.
pub fn ruby_decl_state_l17_d9_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset!', ...args)
}

// Ruby method `consume!` at line 22.
pub fn ruby_decl_state_l22_d10_consume(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('consume!', ...args)
}

// Ruby method `without_on_method_added` at line 28.
pub fn ruby_decl_state_l28_d11_without_on_method_added(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('without_on_method_added', ...args)
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
