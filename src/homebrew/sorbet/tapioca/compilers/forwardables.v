module compilers

import brew_runtime

// Translated from Homebrew/brew `sorbet/tapioca/compilers/forwardables.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.gather_constants` at line 26.
pub fn ruby_forwardables_l26_d1_self_gather_constants(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gather_constants', ...args)
}

// Ruby method `decorate` at line 34.
pub fn ruby_forwardables_l34_d2_decorate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decorate', ...args)
}

// Ruby method `compile_forwardable_method(klass, method, class_method: false)` at line 46.
pub fn ruby_forwardables_l46_d3_compile_forwardable_method(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compile_forwardable_method', ...args)
}

// Ruby method `return_type(klass, name)` at line 61.
pub fn ruby_forwardables_l61_d4_return_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('return_type', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "../../../global"
// 5: require "sorbet/tapioca/utils"
// 6: require "utils/ast"
// 7:
// 8: module Tapioca
// 9:   module Compilers
// 10:     class Forwardables < Tapioca::Dsl::Compiler
// 11:       FORWARDABLE_FILENAME = "forwardable.rb"
// 12:       ARRAY_METHODS = ["to_a", "to_ary"].freeze
// 13:       HASH_METHODS = ["to_h", "to_hash"].freeze
// 14:       STRING_METHODS = ["to_s", "to_str", "to_json"].freeze
// 15:       # Use this to override the default return type of a forwarded method:
// 16:       RETURN_TYPE_OVERRIDES = T.let({
// 17:         "::Cask::Cask" => {
// 18:           "on_system_block_min_os" => "T.nilable(MacOSVersion)",
// 19:           "url"                    => "T.nilable(::Cask::URL)",
// 20:         },
// 21:       }.freeze, T::Hash[String, T::Hash[String, String]])
// 22:
// 23:       ConstantType = type_member { { fixed: T::Module[T.anything] } }
// 24:
// 25:       sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
// 26:       def self.gather_constants
// 27:         Homebrew::Tapioca::Utils.named_objects_with_module(Forwardable).reject do |obj|
// 28:           # Avoid duplicate stubs for forwardables that are defined in vendored gems
// 29:           Object.const_source_location(T.must(obj.name))&.first&.include?("vendor/bundle/ruby")
// 30:         end
// 31:       end
// 32:
// 33:       sig { override.void }
// 34:       def decorate
// 35:         root.create_path(constant) do |klass|
// 36:           Homebrew::Tapioca::Utils.methods_from_file(constant, FORWARDABLE_FILENAME)
// 37:                                   .each { |method| compile_forwardable_method(klass, method) }
// 38:           Homebrew::Tapioca::Utils.methods_from_file(constant, FORWARDABLE_FILENAME, class_methods: true)
// 39:                                   .each { |method| compile_forwardable_method(klass, method, class_method: true) }
// 40:         end
// 41:       end
// 42:
// 43:       private
// 44:
// 45:       sig { params(klass: RBI::Scope, method: T.any(Method, UnboundMethod), class_method: T::Boolean).void }
// 46:       def compile_forwardable_method(klass, method, class_method: false)
// 47:         name = method.name.to_s
// 48:         return_type = return_type(klass.to_s, name)
// 49:         klass.create_method(
// 50:           name,
// 51:           parameters:   [
// 52:             create_rest_param("args", type: "T.untyped"),
// 53:             create_block_param("block", type: "T.untyped"),
// 54:           ],
// 55:           return_type:,
// 56:           class_method:,
// 57:         )
// 58:       end
// 59:
// 60:       sig { params(klass: String, name: String).returns(String) }
// 61:       def return_type(klass, name)
// 62:         if (override = RETURN_TYPE_OVERRIDES.dig(klass, name)) then override
// 63:         elsif name.end_with?("?") then "T::Boolean"
// 64:         elsif ARRAY_METHODS.include?(name) then "Array"
// 65:         elsif HASH_METHODS.include?(name) then "Hash"
// 66:         elsif STRING_METHODS.include?(name) then "String"
// 67:         else
// 68:           "T.untyped"
// 69:         end
// 70:       end
// 71:     end
// 72:   end
// 73: end
