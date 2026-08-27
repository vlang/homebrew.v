module private

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/final.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `inherited(arg)` at line 6.
pub fn ruby_final_l6_d1_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inherited', ...args)
}

// Ruby method `included(arg)` at line 13.
pub fn ruby_final_l13_d2_included(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('included', ...args)
}

// Ruby method `extended(arg)` at line 18.
pub fn ruby_final_l18_d3_extended(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extended', ...args)
}

// Ruby method `self.declare(mod)` at line 24.
pub fn ruby_final_l24_d4_self_declare(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.declare', ...args)
}

// Ruby method `self.final_module?(mod)` at line 43.
pub fn ruby_final_l43_d5_self_final_module(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.final_module?', ...args)
}

// Ruby method `self.mark_as_final_module(mod)` at line 47.
pub fn ruby_final_l47_d6_self_mark_as_final_module(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.mark_as_final_module', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Final
// 5:   module NoInherit
// 6:     def inherited(arg)
// 7:       super(arg)
// 8:       Kernel.raise "#{self} was declared as final and cannot be inherited"
// 9:     end
// 10:   end
// 11:
// 12:   module NoIncludeExtend
// 13:     def included(arg)
// 14:       super(arg)
// 15:       Kernel.raise "#{self} was declared as final and cannot be included"
// 16:     end
// 17:
// 18:     def extended(arg)
// 19:       super(arg)
// 20:       Kernel.raise "#{self} was declared as final and cannot be extended"
// 21:     end
// 22:   end
// 23:
// 24:   def self.declare(mod)
// 25:     if !mod.is_a?(Module)
// 26:       raise "#{mod} is not a class or module and cannot be declared as final with `final!`"
// 27:     end
// 28:     if final_module?(mod)
// 29:       raise "#{mod} was already declared as final and cannot be re-declared as final"
// 30:     end
// 31:     if T::AbstractUtils.abstract_module?(mod)
// 32:       raise "#{mod} was already declared as abstract and cannot be declared as final"
// 33:     end
// 34:     if T::Private::Sealed.sealed_module?(mod)
// 35:       raise "#{mod} was already declared as sealed and cannot be declared as final"
// 36:     end
// 37:     mod.extend(mod.is_a?(Class) ? NoInherit : NoIncludeExtend)
// 38:     mark_as_final_module(mod)
// 39:     mark_as_final_module(mod.singleton_class)
// 40:     T::Private::Methods.install_hooks(mod)
// 41:   end
// 42:
// 43:   def self.final_module?(mod)
// 44:     mod.instance_variable_defined?(:@sorbet_final_module)
// 45:   end
// 46:
// 47:   private_class_method def self.mark_as_final_module(mod)
// 48:     mod.instance_variable_set(:@sorbet_final_module, true)
// 49:   end
// 50: end
