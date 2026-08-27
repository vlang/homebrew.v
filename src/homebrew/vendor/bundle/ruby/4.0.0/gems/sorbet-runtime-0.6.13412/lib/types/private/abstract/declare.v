module abstract

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/abstract/declare.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.declare_abstract(mod, type:)` at line 8.
pub fn ruby_declare_l8_d1_self_declare_abstract(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.declare_abstract', ...args)
}

// Ruby define_singleton_method `mod.send(:define_singleton_method, :new) do |*args, &blk|` at line 36.
pub fn ruby_declare_l36_d2_new(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new', ...args)
}

// Ruby alias_method `mod.singleton_class.send(:alias_method, :new, :new)` at line 46.
pub fn ruby_declare_l46_d3_new(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Abstract::Declare
// 5:   Abstract = T::Private::Abstract
// 6:   AbstractUtils = T::AbstractUtils
// 7:
// 8:   def self.declare_abstract(mod, type:)
// 9:     if AbstractUtils.abstract_module?(mod)
// 10:       raise "#{mod} is already declared as abstract"
// 11:     end
// 12:     if T::Private::Final.final_module?(mod)
// 13:       raise "#{mod} was already declared as final and cannot be declared as abstract"
// 14:     end
// 15:
// 16:     Abstract::Data.set(mod, :can_have_abstract_methods, true)
// 17:     Abstract::Data.set(mod.singleton_class, :can_have_abstract_methods, true)
// 18:     Abstract::Data.set(mod, :abstract_type, type)
// 19:
// 20:     mod.extend(Abstract::Hooks)
// 21:
// 22:     if mod.is_a?(Class)
// 23:       if type == :interface
// 24:         # Since `interface!` is just `abstract!` with some extra validation, we could technically
// 25:         # allow this, but it's unclear there are good use cases, and it might be confusing.
// 26:         raise "Classes can't be interfaces. Use `abstract!` instead of `interface!`."
// 27:       end
// 28:
// 29:       if Object.instance_method(:method).bind_call(mod, :new).owner == mod
// 30:         raise "You must call `abstract!` *before* defining a `new` method"
// 31:       end
// 32:
// 33:       # Don't need to silence warnings via without_ruby_warnings when calling
// 34:       # define_method because of the guard above
// 35:
// 36:       mod.send(:define_singleton_method, :new) do |*args, &blk|
// 37:         result = super(*args, &blk)
// 38:         if result.instance_of?(mod)
// 39:           raise "#{mod} is declared as abstract; it cannot be instantiated"
// 40:         end
// 41:         result
// 42:       end
// 43:
// 44:       # Ruby doesn not emit "method redefined" warnings for aliased methods
// 45:       # (more robust than undef_method that would create a small window in which the method doesn't exist)
// 46:       mod.singleton_class.send(:alias_method, :new, :new)
// 47:
// 48:       if mod.singleton_class.respond_to?(:ruby2_keywords, true)
// 49:         mod.singleton_class.send(:ruby2_keywords, :new)
// 50:       end
// 51:     end
// 52:   end
// 53: end
