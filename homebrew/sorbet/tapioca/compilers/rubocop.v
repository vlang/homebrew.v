module compilers

import brew_runtime

// Translated from Homebrew/brew `sorbet/tapioca/compilers/rubocop.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.gather_constants` at line 14.
pub fn ruby_rubocop_l14_d1_self_gather_constants(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gather_constants', ...args)
}

// Ruby method `decorate` at line 29.
pub fn ruby_rubocop_l29_d2_decorate(args ...brew_runtime.Value) brew_runtime.Value {
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
// 9:     class RuboCop < Tapioca::Dsl::Compiler
// 10:       # This should be a module whose singleton class contains RuboCop::AST::NodePattern::Macros,
// 11:       #   but I don't know how to express that in Sorbet.
// 12:       ConstantType = type_member { { fixed: T::Module[T.anything] } }
// 13:       sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
// 14:       def self.gather_constants
// 15:         all_modules.select do |klass|
// 16:           next unless klass.singleton_class < ::RuboCop::AST::NodePattern::Macros
// 17:
// 18:           path = T.must(Object.const_source_location(klass.to_s)).fetch(0).to_s
// 19:           # exclude vendored code, to avoid contradicting their RBI files
// 20:           !path.include?("/vendor/bundle/ruby/") &&
// 21:             # exclude source code that already has an RBI file
// 22:             !File.exist?("#{path}i") &&
// 23:             # exclude source code that doesn't use the DSLs
// 24:             File.readlines(path).any?(/def_node_/)
// 25:         end
// 26:       end
// 27:
// 28:       sig { override.void }
// 29:       def decorate
// 30:         root.create_path(constant) do |klass|
// 31:           constant.instance_methods(false).each do |method_name|
// 32:             source_location = constant.instance_method(method_name).source_location
// 33:             next if source_location.nil?
// 34:
// 35:             source_file, source_line = source_location
// 36:             source = File.readlines(source_file).fetch(source_line - 1).lstrip
// 37:             # For more info on these DSLs:
// 38:             #   https://www.rubydoc.info/gems/rubocop-ast/RuboCop/AST/NodePattern/Macros
// 39:             #   https://github.com/rubocop/rubocop-ast/blob/HEAD/lib/rubocop/ast/node_pattern.rb
// 40:             #   https://github.com/rubocop/rubocop-ast/blob/HEAD/lib/rubocop/ast/node_pattern/method_definer.rb
// 41:             # The type signatures below could maybe be stronger, but I only wanted to avoid errors:
// 42:             case source
// 43:             when /\Adef_node_matcher/
// 44:               # https://github.com/Shopify/tapioca/blob/3341a9b/lib/tapioca/rbi_ext/model.rb#L89
// 45:               klass.create_method(
// 46:                 method_name.to_s,
// 47:                 parameters:  [
// 48:                   create_param("node", type: "RuboCop::AST::Node"),
// 49:                   create_kw_rest_param("kwargs", type: "T.untyped"),
// 50:                   create_block_param("block", type: "T.untyped"),
// 51:                 ],
// 52:                 return_type: "T.untyped",
// 53:               )
// 54:             when /\Adef_node_search/
// 55:               klass.create_method(
// 56:                 method_name.to_s,
// 57:                 parameters:  [
// 58:                   create_param("node", type: "RuboCop::AST::Node"),
// 59:                   create_rest_param("pattern", type: "T.any(String, Symbol)"),
// 60:                   create_kw_rest_param("kwargs", type: "T.untyped"),
// 61:                   create_block_param("block", type: "T.untyped"),
// 62:                 ],
// 63:                 return_type: method_name.to_s.end_with?("?") ? "T::Boolean" : "T.untyped",
// 64:               )
// 65:             end
// 66:           end
// 67:         end
// 68:       end
// 69:     end
// 70:   end
// 71: end
