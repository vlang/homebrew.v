module ast

import ruby
import homebrew.rubocops.cask.extend as cask_extend

// Translated from Homebrew/brew `rubocops/cask/ast/cask_block.rb`.
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
