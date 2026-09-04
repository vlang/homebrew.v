module compilers

import ruby
import homebrew.api

// Translated from Homebrew/brew `sorbet/tapioca/compilers/api_structs.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn api_structs_compiler_decoration(constant_name string) TapiocaDecoration {
	predicates := if constant_name.ends_with('CaskStruct') {
		api.cask_struct_predicate_names
	} else {
		api.formula_struct_predicate_names
	}
	return TapiocaDecoration{
		constant_name: constant_name
		kind: 'class'
		methods: predicates.map(TapiocaGeneratedMethod{
			name: '${it}?'
			return_type: 'T::Boolean'
			class_method: false
		})
	}
}

// Ruby method `self.gather_constants = [::Homebrew::API::FormulaStruct, ::Homebrew::API::CaskStruct]` at line 14.
pub fn ruby_api_structs_l14_d1_self_gather_constants(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.array_value([
		ruby.object_value('Class', 'Homebrew::API::FormulaStruct'),
		ruby.object_value('Class', 'Homebrew::API::CaskStruct'),
	])
}

// Ruby method `decorate` at line 17.
pub fn ruby_api_structs_l17_d2_decorate(args ...ruby.Value) ruby.Value {
	constant_name := if args.len > 0 { args[0].as_string() } else { 'Homebrew::API::FormulaStruct' }
	return tapioca_decoration_value(api_structs_compiler_decoration(constant_name))
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
