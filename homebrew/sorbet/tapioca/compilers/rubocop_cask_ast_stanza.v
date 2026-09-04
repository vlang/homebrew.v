module compilers

import ruby
import homebrew.rubocops.cask.constants as stanza_constants

// Translated from Homebrew/brew `sorbet/tapioca/compilers/rubocop_cask_ast_stanza.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct TapiocaGeneratedMethod {
pub:
	name         string
	return_type  string
	class_method bool
	parameters   []string
}

pub struct TapiocaDecoration {
pub:
	constant_name string
	kind          string
	methods       []TapiocaGeneratedMethod
}

pub fn stanza_compiler_decoration(constant_name string) TapiocaDecoration {
	return TapiocaDecoration{
		constant_name: constant_name
		kind: 'module'
		methods: stanza_constants.stanza_order.map(TapiocaGeneratedMethod{
			name: '${it}?'
			return_type: 'T::Boolean'
			class_method: false
		})
	}
}

fn tapioca_decoration_value(decoration TapiocaDecoration) ruby.Value {
	return ruby.map_value({
		'constant_name': ruby.string_value(decoration.constant_name)
		'kind':          ruby.string_value(decoration.kind)
		'methods':       ruby.array_value(decoration.methods.map(ruby.map_value({
			'name':         ruby.string_value(it.name)
			'return_type':  ruby.string_value(it.return_type)
			'class_method': ruby.bool_value(it.class_method)
			'parameters':   ruby.string_array_value(it.parameters)
		})))
	})
}

// Ruby method `self.gather_constants = [::RuboCop::Cask::AST::Stanza]` at line 13.
pub fn ruby_rubocop_cask_ast_stanza_l13_d1_self_gather_constants(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.array_value([
		ruby.object_value('Module', 'RuboCop::Cask::AST::Stanza'),
	])
}

// Ruby method `decorate` at line 16.
pub fn ruby_rubocop_cask_ast_stanza_l16_d2_decorate(args ...ruby.Value) ruby.Value {
	constant_name := if args.len > 0 { args[0].as_string() } else { 'RuboCop::Cask::AST::Stanza' }
	return tapioca_decoration_value(stanza_compiler_decoration(constant_name))
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
