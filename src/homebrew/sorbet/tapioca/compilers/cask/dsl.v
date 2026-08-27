module cask

import brew_runtime

// Translated from Homebrew/brew `sorbet/tapioca/compilers/cask/dsl.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.gather_constants = [Cask::DSL]` at line 13.
pub fn ruby_dsl_l13_d1_self_gather_constants(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gather_constants', ...args)
}

// Ruby method `decorate` at line 16.
pub fn ruby_dsl_l16_d2_decorate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decorate', ...args)
}

// Ruby method `block_type(dsl_class)` at line 57.
pub fn ruby_dsl_l57_d3_block_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('block_type', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "../../../../global"
// 5: require "cask/cask"
// 6:
// 7: module Tapioca
// 8:   module Compilers
// 9:     class CaskDsl < Tapioca::Dsl::Compiler
// 10:       ConstantType = type_member { { fixed: T::Module[T.anything] } }
// 11:
// 12:       sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
// 13:       def self.gather_constants = [Cask::DSL]
// 14:
// 15:       sig { override.void }
// 16:       def decorate
// 17:         root.create_path(constant) do |klass|
// 18:           Cask::DSL::ORDINARY_ARTIFACT_CLASSES.each do |artifact|
// 19:             klass.create_method(
// 20:               artifact.dsl_key.to_s,
// 21:               parameters:  [
// 22:                 create_rest_param("args", type: "T.anything"),
// 23:                 create_kw_rest_param("kwargs", type: "T.anything"),
// 24:               ],
// 25:               return_type: "void",
// 26:             )
// 27:           end
// 28:
// 29:           Cask::DSL::ARTIFACT_BLOCK_CLASSES.each do |artifact|
// 30:             [artifact.dsl_key, artifact.uninstall_dsl_key].each do |dsl_key|
// 31:               dsl_class = artifact.class_for_dsl_key(dsl_key).to_s
// 32:               klass.create_method(
// 33:                 dsl_key.to_s,
// 34:                 parameters:  [create_block_param("block", type: block_type(dsl_class))],
// 35:                 return_type: "void",
// 36:               )
// 37:             end
// 38:           end
// 39:
// 40:           Cask::DSL::INSTALL_STEP_ARTIFACT_CLASSES.each do |artifact|
// 41:             klass.create_method(
// 42:               artifact.dsl_key.to_s,
// 43:               parameters:  [
// 44:                 create_opt_param("steps", type: "T.anything", default: "nil"),
// 45:                 create_kw_rest_param("kwargs", type: "T.anything"),
// 46:                 create_block_param("block", type: block_type("Homebrew::InstallSteps::DSL")),
// 47:               ],
// 48:               return_type: "void",
// 49:             )
// 50:           end
// 51:         end
// 52:       end
// 53:
// 54:       private
// 55:
// 56:       sig { params(dsl_class: String).returns(String) }
// 57:       def block_type(dsl_class)
// 58:         "T.nilable(T.proc.bind(#{dsl_class}).params(dsl: #{dsl_class}).void)"
// 59:       end
// 60:     end
// 61:   end
// 62: end
