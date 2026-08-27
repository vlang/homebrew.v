module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/generic.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `[](*types)` at line 11.
pub fn ruby_generic_l11_d1_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('[]', ...args)
}

// Ruby method `type_member(variance=:invariant, &blk)` at line 15.
pub fn ruby_generic_l15_d2_type_member(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type_member', ...args)
}

// Ruby method `type_template(variance=:invariant, &blk)` at line 19.
pub fn ruby_generic_l19_d3_type_template(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type_template', ...args)
}

// Ruby method `has_attached_class!(variance=:invariant, &blk); end` at line 23.
pub fn ruby_generic_l23_d4_has_attached_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('has_attached_class!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # Use as a mixin with extend (`extend T::Generic`).
// 5: module T::Generic
// 6:   include T::Helpers
// 7:   include Kernel
// 8:
// 9:   ### Class/Module Helpers ###
// 10:
// 11:   def [](*types)
// 12:     self
// 13:   end
// 14:
// 15:   def type_member(variance=:invariant, &blk)
// 16:     T::Types::TypeMember.new(variance)
// 17:   end
// 18:
// 19:   def type_template(variance=:invariant, &blk)
// 20:     T::Types::TypeTemplate.new(variance)
// 21:   end
// 22:
// 23:   def has_attached_class!(variance=:invariant, &blk); end
// 24: end
