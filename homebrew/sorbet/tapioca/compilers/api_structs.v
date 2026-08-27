module compilers

import brew_runtime

// Translated from Homebrew/brew `sorbet/tapioca/compilers/api_structs.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.gather_constants = [::Homebrew::API::FormulaStruct, ::Homebrew::API::CaskStruct]` at line 14.
pub fn ruby_api_structs_l14_d1_self_gather_constants(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gather_constants', ...args)
}

// Ruby method `decorate` at line 17.
pub fn ruby_api_structs_l17_d2_decorate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decorate', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "../../../global"
// 5: require "api/formula_struct"
// 6: require "api/cask_struct"
// 7:
// 8: module Tapioca
// 9:   module Compilers
// 10:     class ApiStructs < Tapioca::Dsl::Compiler
// 11:       ConstantType = type_member { { fixed: T.class_of(T::Struct) } }
// 12:
// 13:       sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
// 14:       def self.gather_constants = [::Homebrew::API::FormulaStruct, ::Homebrew::API::CaskStruct]
// 15:
// 16:       sig { override.void }
// 17:       def decorate
// 18:         root.create_class(T.must(constant.name)) do |klass|
// 19:           # `constant` is one of the gathered structs, resolved at runtime.
// 20:           # rubocop:disable Sorbet/ConstantsFromStrings
// 21:           constant.const_get(:PREDICATES).each do |predicate_name|
// 22:             klass.create_method("#{predicate_name}?", return_type: "T::Boolean")
// 23:           end
// 24:           # rubocop:enable Sorbet/ConstantsFromStrings
// 25:         end
// 26:       end
// 27:     end
// 28:   end
// 29: end
