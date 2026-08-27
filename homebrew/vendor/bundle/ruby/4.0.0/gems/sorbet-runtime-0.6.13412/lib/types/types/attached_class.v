module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/types/attached_class.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(); end` at line 11.
pub fn ruby_attached_class_l11_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `build_type` at line 13.
pub fn ruby_attached_class_l13_d2_build_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_type', ...args)
}

// Ruby method `name` at line 18.
pub fn ruby_attached_class_l18_d3_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `valid?(obj)` at line 23.
pub fn ruby_attached_class_l23_d4_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid?', ...args)
}

// Ruby method `subtype_of_single?(other)` at line 28.
pub fn ruby_attached_class_l28_d5_subtype_of_single(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subtype_of_single?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Types
// 5:   # Modeling AttachedClass properly at runtime would require additional
// 6:   # tracking, so at runtime we permit all values and rely on the static checker.
// 7:   # As AttachedClass is modeled statically as a type member on every singleton
// 8:   # class, this is consistent with the runtime behavior for all type members.
// 9:   class AttachedClassType < Base
// 10:
// 11:     def initialize(); end
// 12:
// 13:     def build_type
// 14:       nil
// 15:     end
// 16:
// 17:     # overrides Base
// 18:     def name
// 19:       "T.attached_class"
// 20:     end
// 21:
// 22:     # overrides Base
// 23:     def valid?(obj)
// 24:       true
// 25:     end
// 26:
// 27:     # overrides Base
// 28:     private def subtype_of_single?(other)
// 29:       case other
// 30:       when AttachedClassType
// 31:         true
// 32:       else
// 33:         false
// 34:       end
// 35:     end
// 36:
// 37:     module Private
// 38:       INSTANCE = AttachedClassType.new.freeze
// 39:     end
// 40:   end
// 41: end
