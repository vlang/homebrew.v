module ast

import ruby
import homebrew.rubocops.cask.extend as cask_extend

// Translated from Homebrew/brew `rubocops/cask/ast/cask_block.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CaskAstStanzaBlock {
pub:
	block_node  cask_extend.CaskAstNode
	full_source string
	comments    []CaskAstComment
	is_cask     bool
}

fn cask_ast_find_cask_block(node cask_extend.CaskAstNode) ?cask_extend.CaskAstNode {
	if cask_extend.cask_block(node) {
		return node
	}
	for child in node.children {
		if found := cask_ast_find_cask_block(child) {
			return found
		}
	}
	return none
}

pub fn parse_cask_ast_stanza_block(source string, require_cask bool) ?CaskAstStanzaBlock {
	root := cask_extend.parse_cask_ast_node(source)
	block := if require_cask {
		cask_ast_find_cask_block(root) or { return none }
	} else if root.kind == 'block' {
		root
	} else {
		return none
	}
	return CaskAstStanzaBlock{
		block_node: block
		full_source: source
		comments: parse_cask_ast_comments(source)
		is_cask: cask_extend.cask_block(block)
	}
}

fn cask_ast_direct_stanza_nodes(block cask_extend.CaskAstNode) []cask_extend.CaskAstNode {
	mut result := []cask_extend.CaskAstNode{}
	for child in block.children {
		if cask_extend.stanza(child) {
			result << child
		}
	}
	return result
}

fn cask_ast_all_stanza_nodes(node cask_extend.CaskAstNode) []cask_extend.CaskAstNode {
	mut result := []cask_extend.CaskAstNode{}
	for child in node.children {
		if cask_extend.stanza(child) {
			result << child
		}
		result << cask_ast_all_stanza_nodes(child)
	}
	return result
}

pub fn cask_ast_block_stanzas(block CaskAstStanzaBlock, all_descendants bool) []CaskAstStanza {
	nodes := if all_descendants {
		cask_ast_all_stanza_nodes(block.block_node)
	} else {
		cask_ast_direct_stanza_nodes(block.block_node)
	}
	return nodes.map(CaskAstStanza{
		node: it
		full_source: block.full_source
		all_comments: block.comments.clone()
	})
}

fn cask_ast_stanzas_value(stanzas []CaskAstStanza) ruby.Value {
	return ruby.array_value(stanzas.map(cask_ast_stanza_value(it)))
}

fn cask_ast_block_value(block CaskAstStanzaBlock, type_name string) ruby.Value {
	return ruby.structured_value(type_name, block.block_node.source, {
		'kind':        block.block_node.kind
		'method_name': block.block_node.method_name
		'begin_pos':   block.block_node.expression.begin_pos.str()
		'end_pos':     block.block_node.expression.end_pos.str()
		'comments':    block.comments.map(it.source).join('\n')
	})
}

// Ruby attr_reader `attr_reader :block_node` at line 13.
pub fn ruby_cask_block_l13_d1_block_node(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	block := parse_cask_ast_stanza_block(source, false) or { return cask_ast_nil() }
	return cask_ast_node_value(block.block_node)
}

// Ruby attr_reader `attr_reader :comments` at line 16.
pub fn ruby_cask_block_l16_d2_comments(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return cask_ast_comment_values(parse_cask_ast_comments(source))
}

// Ruby method `initialize(block_node, comments)` at line 19.
pub fn ruby_cask_block_l19_d3_initialize(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	block := parse_cask_ast_stanza_block(source, false) or { return cask_ast_nil() }
	return cask_ast_block_value(block, 'RuboCop::Cask::AST::StanzaBlock')
}

// Ruby method `stanzas` at line 25.
pub fn ruby_cask_block_l25_d4_stanzas(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	block := parse_cask_ast_stanza_block(source, false) or {
		return ruby.array_value([]ruby.Value{})
	}
	return cask_ast_stanzas_value(cask_ast_block_stanzas(block, false))
}

// Ruby method `cask_node` at line 53.
pub fn ruby_cask_block_l53_d5_cask_node(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	block := parse_cask_ast_stanza_block(source, true) or { return cask_ast_nil() }
	return cask_ast_node_value(block.block_node)
}

// Ruby def_delegator `def_delegator :cask_node, :block_body, :cask_body` at line 57.
pub fn ruby_cask_block_l57_d6_cask_body(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	block := parse_cask_ast_stanza_block(source, true) or { return cask_ast_nil() }
	body := cask_extend.block_body(block.block_node) or { return cask_ast_nil() }
	return cask_ast_node_value(body)
}

// Ruby method `header` at line 60.
pub fn ruby_cask_block_l60_d7_header(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	header := parse_cask_header(source) or { return cask_ast_nil() }
	return ruby.structured_value('RuboCop::Cask::AST::CaskHeader', header.cask_token, {
		'method_source': header.method_source
		'begin_pos':     header.begin_pos.str()
		'end_pos':       header.end_pos.str()
		'cask_token':    header.cask_token
		'hash_source':   header.hash_source
	})
}

// Ruby method `stanzas` at line 66.
pub fn ruby_cask_block_l66_d8_stanzas(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	block := parse_cask_ast_stanza_block(source, true) or {
		return ruby.array_value([]ruby.Value{})
	}
	return cask_ast_stanzas_value(cask_ast_block_stanzas(block, true))
}

// Ruby method `toplevel_stanzas` at line 75.
pub fn ruby_cask_block_l75_d9_toplevel_stanzas(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	block := parse_cask_ast_stanza_block(source, true) or {
		return ruby.array_value([]ruby.Value{})
	}
	return cask_ast_stanzas_value(cask_ast_block_stanzas(block, false))
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
