module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/helpers.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `abstract!` at line 11.
pub fn ruby_helpers_l11_d1_abstract(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('abstract!', ...args)
}

// Ruby method `interface!` at line 22.
pub fn ruby_helpers_l22_d2_interface(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('interface!', ...args)
}

// Ruby method `final!` at line 26.
pub fn ruby_helpers_l26_d3_final(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('final!', ...args)
}

// Ruby method `sealed!` at line 30.
pub fn ruby_helpers_l30_d4_sealed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sealed!', ...args)
}

// Ruby method `mixes_in_class_methods(mod, *mods)` at line 43.
pub fn ruby_helpers_l43_d5_mixes_in_class_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mixes_in_class_methods', ...args)
}

// Ruby method `requires_ancestor(&block); end` at line 62.
pub fn ruby_helpers_l62_d6_requires_ancestor(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('requires_ancestor', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # Use as a mixin with extend (`extend T::Helpers`).
// 5: # Docs at https://sorbet.org/docs/
// 6: module T::Helpers
// 7:   Private = T::Private
// 8:
// 9:   ### Class/Module Helpers ###
// 10:
// 11:   def abstract!
// 12:     if defined?(super)
// 13:       # This is to play nicely with Rails' AbstractController::Base,
// 14:       # which also defines an `abstract!` method.
// 15:       # https://api.rubyonrails.org/classes/AbstractController/Base.html#method-c-abstract-21
// 16:       super
// 17:     end
// 18:
// 19:     Private::Abstract::Declare.declare_abstract(self, type: :abstract)
// 20:   end
// 21:
// 22:   def interface!
// 23:     Private::Abstract::Declare.declare_abstract(self, type: :interface)
// 24:   end
// 25:
// 26:   def final!
// 27:     Private::Final.declare(self)
// 28:   end
// 29:
// 30:   def sealed!
// 31:     Private::Sealed.declare(self, Kernel.caller(1..1)&.first&.split(':')&.first)
// 32:   end
// 33:
// 34:   # Causes a mixin to also mix in class methods from the named module.
// 35:   #
// 36:   # Nearly equivalent to
// 37:   #
// 38:   #  def self.included(other)
// 39:   #    other.extend(mod)
// 40:   #  end
// 41:   #
// 42:   # Except that it is statically analyzed by sorbet.
// 43:   def mixes_in_class_methods(mod, *mods)
// 44:     Private::Mixins.declare_mixes_in_class_methods(self, [mod].concat(mods))
// 45:   end
// 46:
// 47:   # Specify an inclusion or inheritance requirement for `self`.
// 48:   #
// 49:   # Example:
// 50:   #
// 51:   #   module MyHelper
// 52:   #     extend T::Helpers
// 53:   #
// 54:   #     requires_ancestor { Kernel }
// 55:   #   end
// 56:   #
// 57:   #   class MyClass < BasicObject # error: `MyClass` must include `Kernel` (required by `MyHelper`)
// 58:   #     include MyHelper
// 59:   #   end
// 60:   #
// 61:   # TODO: implement the checks in sorbet-runtime.
// 62:   def requires_ancestor(&block); end
// 63: end
