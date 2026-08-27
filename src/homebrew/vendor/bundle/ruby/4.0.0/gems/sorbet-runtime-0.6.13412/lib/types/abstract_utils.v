module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/abstract_utils.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.abstract_module?(mod)` at line 14.
pub fn ruby_abstract_utils_l14_d1_self_abstract_module(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.abstract_module?', ...args)
}

// Ruby method `self.abstract_method?(method)` at line 18.
pub fn ruby_abstract_utils_l18_d2_self_abstract_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.abstract_method?', ...args)
}

// Ruby method `self.abstract_methods_for(mod)` at line 25.
pub fn ruby_abstract_utils_l25_d3_self_abstract_methods_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.abstract_methods_for', ...args)
}

// Ruby method `self.declared_abstract_methods_for(mod)` at line 39.
pub fn ruby_abstract_utils_l39_d4_self_declared_abstract_methods_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.declared_abstract_methods_for', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::AbstractUtils
// 5:   Methods = T::Private::Methods
// 6:
// 7:   # Returns whether a module is declared as abstract. After the module is finished being declared,
// 8:   # this is equivalent to whether it has any abstract methods that haven't been implemented
// 9:   # (because we validate that and raise an error otherwise).
// 10:   #
// 11:   # Note that checking `mod.is_a?(Abstract::Hooks)` is not a safe substitute for this method; when
// 12:   # a class extends `Abstract::Hooks`, all of its subclasses, including the eventual concrete
// 13:   # ones, will still have `Abstract::Hooks` as an ancestor.
// 14:   def self.abstract_module?(mod)
// 15:     !T::Private::Abstract::Data.get(mod, :abstract_type).nil?
// 16:   end
// 17:
// 18:   def self.abstract_method?(method)
// 19:     signature = Methods.signature_for_method(method)
// 20:     signature&.mode == Methods::Modes.abstract
// 21:   end
// 22:
// 23:   # Given a module, returns the set of methods declared as abstract (in itself or ancestors)
// 24:   # that have not been implemented.
// 25:   def self.abstract_methods_for(mod)
// 26:     declared_methods = declared_abstract_methods_for(mod)
// 27:     declared_methods.select do |declared_method|
// 28:       actual_method = mod.instance_method(declared_method.name)
// 29:       # Note that in the case where an abstract method is overridden by another abstract method,
// 30:       # this method will return them both. This is intentional to ensure we validate the final
// 31:       # implementation against all declarations of an abstract method (they might not all have the
// 32:       # same signature).
// 33:       abstract_method?(actual_method)
// 34:     end
// 35:   end
// 36:
// 37:   # Given a module, returns the set of methods declared as abstract (in itself or ancestors)
// 38:   # regardless of whether they have been implemented.
// 39:   def self.declared_abstract_methods_for(mod)
// 40:     methods = []
// 41:     mod.ancestors.each do |ancestor|
// 42:       ancestor_methods = ancestor.private_instance_methods(false) + ancestor.instance_methods(false)
// 43:       ancestor_methods.each do |method_name|
// 44:         method = ancestor.instance_method(method_name)
// 45:         methods << method if abstract_method?(method)
// 46:       end
// 47:     end
// 48:     methods
// 49:   end
// 50: end
