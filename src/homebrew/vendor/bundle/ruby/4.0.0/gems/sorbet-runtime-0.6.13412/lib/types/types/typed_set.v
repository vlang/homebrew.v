module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/typed_set.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `underlying_class` at line 11.
pub fn ruby_typed_set_l11_d1_underlying_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('underlying_class', ...args)
}

// Ruby method `name` at line 16.
pub fn ruby_typed_set_l16_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `recursively_valid?(obj)` at line 21.
pub fn ruby_typed_set_l21_d3_recursively_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursively_valid?', ...args)
}

// Ruby method `valid?(obj)` at line 26.
pub fn ruby_typed_set_l26_d4_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `new(...)` at line 30.
pub fn ruby_typed_set_l30_d5_new(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new', ...args)
}

// Ruby method `initialize` at line 35.
pub fn ruby_typed_set_l35_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `valid?(obj)` at line 39.
pub fn ruby_typed_set_l39_d7_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   class TypedSet < TypedEnumerable
// 6:     # We can reference `Set` directly without a load guard: as of Ruby 3.2 it
// 7:     # ships as a default-autoloaded constant (Ruby registers `autoload :Set,
// 8:     # "set"`), so the first reference here transparently loads it. Ruby 3.3 --
// 9:     # the most recently supported release -- keeps this behavior, and Ruby 3.1
// 10:     # and earlier (which required an explicit `require "set"`) are past EOL.
// 11:     def underlying_class
// 12:       Set
// 13:     end
// 14:
// 15:     # overrides Base
// 16:     def name
// 17:       "T::Set[#{type.name}]"
// 18:     end
// 19:
// 20:     # overrides Base
// 21:     def recursively_valid?(obj)
// 22:       obj.is_a?(Set) && super
// 23:     end
// 24:
// 25:     # overrides Base
// 26:     def valid?(obj)
// 27:       obj.is_a?(Set)
// 28:     end
// 29:
// 30:     def new(...)
// 31:       Set.new(...)
// 32:     end
// 33:
// 34:     class Untyped < TypedSet
// 35:       def initialize
// 36:         super(T::Types::Untyped::Private::INSTANCE)
// 37:       end
// 38:
// 39:       def valid?(obj)
// 40:         obj.is_a?(Set)
// 41:       end
// 42:     end
// 43:   end
// 44: end
