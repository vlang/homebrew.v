module extend

import brew_runtime

// Translated from Homebrew/brew `test/support/extend/cachable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.included(klass)` at line 8.
pub fn ruby_cachable_l8_d1_self_included(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.included', ...args)
}

// Ruby method `self.extended(klass)` at line 16.
pub fn ruby_cachable_l16_d2_self_extended(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.extended', ...args)
}

// Ruby method `inherited(klass)` at line 25.
pub fn ruby_cachable_l25_d3_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inherited', ...args)
}

// Ruby method `self.class_list` at line 39.
pub fn ruby_cachable_l39_d4_self_class_list(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.class_list', ...args)
}

// Ruby method `self.clear_all_caches` at line 48.
pub fn ruby_cachable_l48_d5_self_clear_all_caches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.clear_all_caches', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: raise "This needs to be required before Cachable gets loaded normally." if defined?(Cachable)
// 5:
// 6: # Collect all classes that mix in Cachable so that those caches can be cleared in-between tests.
// 7: module Cachable
// 8:   private_class_method def self.included(klass)
// 9:     # It's difficult to backtrack from a singleton class to find the original class
// 10:     # and you can always just extend this module instead for equivalent behavior.
// 11:     raise ArgumentError, "Don't use Cachable with singleton classes" if klass.singleton_class?
// 12:
// 13:     super if defined?(super)
// 14:   end
// 15:
// 16:   private_class_method def self.extended(klass)
// 17:     Registry.class_list << klass
// 18:     # Ignore the `Formula` class that gets inherited from a lot and
// 19:     # that has caches that we don't need to clear on the class level.
// 20:     klass.extend(Inherited) if klass.name != "Formula"
// 21:     super if defined?(super)
// 22:   end
// 23:
// 24:   module Inherited
// 25:     def inherited(klass)
// 26:       # A class might inherit Cachable at the instance level
// 27:       # and in that case we just want to skip registering it.
// 28:       Registry.class_list << klass if klass.respond_to?(:clear_cache)
// 29:       super if defined?(super)
// 30:     end
// 31:   end
// 32:
// 33:   module Registry
// 34:     # A list of all classes that have been loaded into memory that mixin or
// 35:     # inherit `Cachable` at the class or module level.
// 36:     #
// 37:     # NOTE: Classes that inherit from `Formula` are excluded since it's not
// 38:     #       necessary to track and clear individual formula caches.
// 39:     def self.class_list
// 40:       @class_list ||= []
// 41:     end
// 42:
// 43:     # Clear the cache of every class or module that mixes in or inherits
// 44:     # `Cachable` at the class or module level.
// 45:     #
// 46:     # NOTE: Classes that inherit from `Formula` are excluded since it's not
// 47:     #       necessary to track and clear individual formula caches.
// 48:     def self.clear_all_caches
// 49:       class_list.each(&:clear_cache)
// 50:     end
// 51:   end
// 52: end
