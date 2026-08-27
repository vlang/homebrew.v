module compilers

import brew_runtime

// Translated from Homebrew/brew `sorbet/tapioca/compilers/tty.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.gather_constants = [::Tty]` at line 13.
pub fn ruby_tty_l13_d1_self_gather_constants(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gather_constants', ...args)
}

// Ruby method `decorate` at line 16.
pub fn ruby_tty_l16_d2_decorate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decorate', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "../../../global"
// 5: require "utils/tty"
// 6:
// 7: module Tapioca
// 8:   module Compilers
// 9:     class Tty < Tapioca::Dsl::Compiler
// 10:       ConstantType = type_member { { fixed: T::Module[T.anything] } }
// 11:
// 12:       sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
// 13:       def self.gather_constants = [::Tty]
// 14:
// 15:       sig { override.void }
// 16:       def decorate
// 17:         root.create_module(T.must(constant.name)) do |mod|
// 18:           dynamic_methods = ::Tty::COLOR_CODES.keys + ::Tty::STYLE_CODES.keys + ::Tty::SPECIAL_CODES.keys
// 19:
// 20:           dynamic_methods.each do |method|
// 21:             mod.create_method(method.to_s, return_type: "String", class_method: true)
// 22:           end
// 23:         end
// 24:       end
// 25:     end
// 26:   end
// 27: end
