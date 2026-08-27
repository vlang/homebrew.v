module ast

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/ast/cask_header.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(method_node)` at line 11.
pub fn ruby_cask_header_l11_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby attr_reader `attr_reader :method_node` at line 16.
pub fn ruby_cask_header_l16_d2_method_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_node', ...args)
}

// Ruby method `source_range` at line 19.
pub fn ruby_cask_header_l19_d3_source_range(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_range', ...args)
}

// Ruby method `cask_token` at line 24.
pub fn ruby_cask_header_l24_d4_cask_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_token', ...args)
}

// Ruby method `hash_node` at line 29.
pub fn ruby_cask_header_l29_d5_hash_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hash_node', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cask
// 6:     module AST
// 7:       # This class wraps the AST method node that represents the cask header. It
// 8:       # includes various helper methods to aid cops in their analysis.
// 9:       class CaskHeader
// 10:         sig { params(method_node: T.all(RuboCop::AST::Node, RuboCop::AST::ParameterizedNode::RestArguments)).void }
// 11:         def initialize(method_node)
// 12:           @method_node = method_node
// 13:         end
// 14:
// 15:         sig { returns(T.all(RuboCop::AST::Node, RuboCop::AST::ParameterizedNode::RestArguments)) }
// 16:         attr_reader :method_node
// 17:
// 18:         sig { returns(Parser::Source::Range) }
// 19:         def source_range
// 20:           @source_range ||= T.let(method_node.loc.expression, T.nilable(Parser::Source::Range))
// 21:         end
// 22:
// 23:         sig { returns(String) }
// 24:         def cask_token
// 25:           @cask_token ||= T.let(method_node.first_argument.str_content, T.nilable(String))
// 26:         end
// 27:
// 28:         sig { returns(T.all(RuboCop::AST::Node, RuboCop::AST::ParameterizedNode::RestArguments)) }
// 29:         def hash_node
// 30:           @hash_node ||= T.let(method_node.each_child_node(:hash).first, T.nilable(RuboCop::AST::Node))
// 31:         end
// 32:       end
// 33:     end
// 34:   end
// 35: end
