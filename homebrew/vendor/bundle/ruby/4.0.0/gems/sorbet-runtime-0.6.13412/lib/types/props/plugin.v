module props

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/plugin.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `included(child)` at line 9.
pub fn ruby_plugin_l9_d1_included(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('included', ...args)
}

// Ruby method `self.apply_class_methods(plugin, target)` at line 21.
pub fn ruby_plugin_l21_d2_self_apply_class_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.apply_class_methods', ...args)
}

// Ruby method `self.apply_decorator_methods(plugin, target)` at line 29.
pub fn ruby_plugin_l29_d3_self_apply_decorator_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.apply_decorator_methods', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: false
// 3:
// 4: module T::Props::Plugin
// 5:   include T::Props
// 6:   extend T::Helpers
// 7:
// 8:   module ClassMethods
// 9:     def included(child)
// 10:       super
// 11:       child.plugin(self)
// 12:     end
// 13:   end
// 14:   mixes_in_class_methods(ClassMethods)
// 15:
// 16:   module Private
// 17:     # These need to be non-instance methods so we can use them without prematurely creating the
// 18:     # child decorator in `model_inherited` (see comments there for details).
// 19:     #
// 20:     # The dynamic constant access below forces this file to be `typed: false`
// 21:     def self.apply_class_methods(plugin, target)
// 22:       if plugin.const_defined?('ClassMethods')
// 23:         # FIXME: This will break preloading, selective test execution, etc if `mod::ClassMethods`
// 24:         # is ever defined in a separate file from `mod`.
// 25:         target.extend(plugin::ClassMethods)
// 26:       end
// 27:     end
// 28:
// 29:     def self.apply_decorator_methods(plugin, target)
// 30:       if plugin.const_defined?('DecoratorMethods')
// 31:         # FIXME: This will break preloading, selective test execution, etc if `mod::DecoratorMethods`
// 32:         # is ever defined in a separate file from `mod`.
// 33:         target.extend(plugin::DecoratorMethods)
// 34:       end
// 35:     end
// 36:   end
// 37: end
