module ast

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/ast/cask_block.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :block_node` at line 13.
pub fn ruby_cask_block_l13_d1_block_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('block_node', ...args)
}

// Ruby attr_reader `attr_reader :comments` at line 16.
pub fn ruby_cask_block_l16_d2_comments(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('comments', ...args)
}

// Ruby method `initialize(block_node, comments)` at line 19.
pub fn ruby_cask_block_l19_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `stanzas` at line 25.
pub fn ruby_cask_block_l25_d4_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stanzas', ...args)
}

// Ruby method `cask_node` at line 53.
pub fn ruby_cask_block_l53_d5_cask_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_node', ...args)
}

// Ruby def_delegator `def_delegator :cask_node, :block_body, :cask_body` at line 57.
pub fn ruby_cask_block_l57_d6_cask_body(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_body', ...args)
}

// Ruby method `header` at line 60.
pub fn ruby_cask_block_l60_d7_header(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('header', ...args)
}

// Ruby method `stanzas` at line 66.
pub fn ruby_cask_block_l66_d8_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stanzas', ...args)
}

// Ruby method `toplevel_stanzas` at line 75.
pub fn ruby_cask_block_l75_d9_toplevel_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('toplevel_stanzas', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "forwardable"
// 5:
// 6: module RuboCop
// 7:   module Cask
// 8:     module AST
// 9:       class StanzaBlock
// 10:         extend T::Helpers
// 11:
// 12:         sig { returns(RuboCop::AST::BlockNode) }
// 13:         attr_reader :block_node
// 14:
// 15:         sig { returns(T::Array[Parser::Source::Comment]) }
// 16:         attr_reader :comments
// 17:
// 18:         sig { params(block_node: RuboCop::AST::BlockNode, comments: T::Array[Parser::Source::Comment]).void }
// 19:         def initialize(block_node, comments)
// 20:           @block_node = block_node
// 21:           @comments = comments
// 22:         end
// 23:
// 24:         sig { returns(T::Array[Stanza]) }
// 25:         def stanzas
// 26:           return [] unless (block_body = block_node.block_body)
// 27:
// 28:           # If a block only contains one stanza, it is that stanza's direct parent, otherwise
// 29:           # stanzas are grouped in a nested block and the block is that nested block's parent.
// 30:           is_stanza = if block_body.begin_block?
// 31:             ->(node) { node.parent.parent == block_node }
// 32:           else
// 33:             ->(node) { node.parent == block_node }
// 34:           end
// 35:
// 36:           @stanzas ||= T.let(
// 37:             block_body.each_node
// 38:                       .select(&:stanza?)
// 39:                       .select(&is_stanza)
// 40:                       .map { |node| Stanza.new(node, comments) },
// 41:             T.nilable(T::Array[Stanza]),
// 42:           )
// 43:         end
// 44:       end
// 45:
// 46:       # This class wraps the AST block node that represents the entire cask
// 47:       # definition. It includes various helper methods to aid cops in their
// 48:       # analysis.
// 49:       class CaskBlock < StanzaBlock
// 50:         extend Forwardable
// 51:
// 52:         sig { returns(RuboCop::AST::BlockNode) }
// 53:         def cask_node
// 54:           block_node
// 55:         end
// 56:
// 57:         def_delegator :cask_node, :block_body, :cask_body
// 58:
// 59:         sig { returns(CaskHeader) }
// 60:         def header
// 61:           @header ||= T.let(CaskHeader.new(block_node.method_node), T.nilable(CaskHeader))
// 62:         end
// 63:
// 64:         # TODO: Use `StanzaBlock#stanzas` for all cops, where possible.
// 65:         sig { returns(T::Array[Stanza]) }
// 66:         def stanzas
// 67:           return [] unless cask_body
// 68:
// 69:           @stanzas ||= cask_body.each_node
// 70:                                 .select(&:stanza?)
// 71:                                 .map { |node| Stanza.new(node, comments) }
// 72:         end
// 73:
// 74:         sig { returns(T::Array[Stanza]) }
// 75:         def toplevel_stanzas
// 76:           # If a `cask` block only contains one stanza, it is that stanza's direct parent,
// 77:           # otherwise stanzas are grouped in a block and `cask` is that block's parent.
// 78:           is_toplevel_stanza = if cask_body.begin_block?
// 79:             ->(stanza) { stanza.parent_node.parent.cask_block? }
// 80:           else
// 81:             ->(stanza) { stanza.parent_node.cask_block? }
// 82:           end
// 83:
// 84:           @toplevel_stanzas ||= T.let(stanzas.select(&is_toplevel_stanza), T.nilable(T::Array[Stanza]))
// 85:         end
// 86:       end
// 87:     end
// 88:   end
// 89: end
