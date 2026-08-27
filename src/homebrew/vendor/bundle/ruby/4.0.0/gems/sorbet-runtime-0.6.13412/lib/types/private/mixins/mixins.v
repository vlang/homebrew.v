module mixins

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/mixins/mixins.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `included(other)` at line 6.
pub fn ruby_mixins_l6_d1_included(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('included', ...args)
}

// Ruby method `self.declare_mixes_in_class_methods(mixin, class_methods)` at line 14.
pub fn ruby_mixins_l14_d2_self_declare_mixes_in_class_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.declare_mixes_in_class_methods', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private
// 5:   module MixesInClassMethods
// 6:     def included(other)
// 7:       mods = Abstract::Data.get(self, :class_methods_mixins)
// 8:       mods.each { |mod| other.extend(mod) }
// 9:       super
// 10:     end
// 11:   end
// 12:
// 13:   module Mixins
// 14:     def self.declare_mixes_in_class_methods(mixin, class_methods)
// 15:       if mixin.is_a?(Class)
// 16:         raise "Classes cannot be used as mixins, and so mixes_in_class_methods cannot be used on a Class."
// 17:       end
// 18:
// 19:       if Abstract::Data.key?(mixin, :class_methods_mixins)
// 20:         class_methods = Abstract::Data.get(mixin, :class_methods_mixins) + class_methods
// 21:       end
// 22:
// 23:       mixin.singleton_class.include(MixesInClassMethods)
// 24:       Abstract::Data.set(mixin, :class_methods_mixins, class_methods)
// 25:     end
// 26:   end
// 27: end
