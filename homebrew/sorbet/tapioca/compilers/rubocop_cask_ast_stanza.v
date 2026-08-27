module compilers

import brew_runtime

// Translated from Homebrew/brew `sorbet/tapioca/compilers/rubocop_cask_ast_stanza.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.gather_constants = [::RuboCop::Cask::AST::Stanza]` at line 13.
pub fn ruby_rubocop_cask_ast_stanza_l13_d1_self_gather_constants(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gather_constants', ...args)
}

// Ruby method `decorate` at line 16.
pub fn ruby_rubocop_cask_ast_stanza_l16_d2_decorate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decorate', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocop"
// 5: require_relative "../../../rubocops"
// 6:
// 7: module Tapioca
// 8:   module Compilers
// 9:     class Stanza < Tapioca::Dsl::Compiler
// 10:       ConstantType = type_member { { fixed: T::Module[T.anything] } }
// 11:
// 12:       sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
// 13:       def self.gather_constants = [::RuboCop::Cask::AST::Stanza]
// 14:
// 15:       sig { override.void }
// 16:       def decorate
// 17:         root.create_module(T.must(constant.name)) do |mod|
// 18:           ::RuboCop::Cask::Constants::STANZA_ORDER.each do |stanza|
// 19:             mod.create_method("#{stanza}?", return_type: "T::Boolean", class_method: false)
// 20:           end
// 21:         end
// 22:       end
// 23:     end
// 24:   end
// 25: end
