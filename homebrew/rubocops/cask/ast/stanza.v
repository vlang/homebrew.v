module ast

import ruby
import homebrew.rubocops.cask.constants as stanza_constants
import homebrew.rubocops.cask.extend as cask_extend

// Translated from Homebrew/brew `rubocops/cask/ast/stanza.rb`.
pub struct CaskAstComment {
pub:
	source    string
	begin_pos int
	end_pos   int
}

pub struct CaskAstStanza {
pub:
	node         cask_extend.CaskAstNode
	full_source  string
	all_comments []CaskAstComment
}

fn cask_ast_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn parse_cask_ast_comments(source string) []CaskAstComment {
	mut comments := []CaskAstComment{}
	mut line_start := 0
	for line_start <= source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		mut quote := u8(0)
		mut escaped := false
		for index, character in line.bytes() {
			if quote != 0 {
				if escaped {
					escaped = false
				} else if character == `\\` {
					escaped = true
				} else if character == quote {
					quote = 0
				}
			} else if character in [`'`, `"`] {
				quote = character
			} else if character == `#` {
				comments << CaskAstComment{
					source: line[index..]
					begin_pos: line_start + index
					end_pos: line_end
				}
				break
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return comments
}

fn cask_ast_node_value(node cask_extend.CaskAstNode) ruby.Value {
	type_name := match node.kind {
		'block' { 'RuboCop::AST::BlockNode' }
		'send' { 'RuboCop::AST::SendNode' }
		'lvasgn' { 'RuboCop::AST::LvasgnNode' }
		'begin' { 'RuboCop::AST::BeginNode' }
		else { 'RuboCop::AST::Node' }
	}
	return ruby.Value{
		type_name: type_name
		repr: node.source
		array_data: node.children.map(cask_ast_node_value(it))
		attributes: {
			'kind':         node.kind
			'method_name':  node.method_name
			'begin_pos':    node.expression.begin_pos.str()
			'end_pos':      node.expression.end_pos.str()
			'has_receiver': node.has_receiver.str()
		}
	}
}

fn cask_ast_comment_values(comments []CaskAstComment) ruby.Value {
	return ruby.array_value(comments.map(ruby.structured_value('Parser::Source::Comment', it.source, {
		'begin_pos': it.begin_pos.str()
		'end_pos':   it.end_pos.str()
	})))
}

fn cask_ast_stanza_from_source(source string) ?CaskAstStanza {
	root := cask_extend.parse_cask_ast_node(source)
	mut node := root
	if !cask_extend.stanza(node) {
		node = cask_ast_first_stanza(root) or { return none }
	}
	return CaskAstStanza{
		node: node
		full_source: source
		all_comments: parse_cask_ast_comments(source)
	}
}

fn cask_ast_first_stanza(node cask_extend.CaskAstNode) ?cask_extend.CaskAstNode {
	for child in node.children {
		if cask_extend.stanza(child) {
			return child
		}
		if nested := cask_ast_first_stanza(child) {
			return nested
		}
	}
	return none
}

pub fn cask_ast_stanza_name(stanza CaskAstStanza) string {
	if cask_extend.arch_variable(stanza.node) {
		return 'on_arch_conditional'
	}
	if cask_extend.system_variable(stanza.node) {
		return 'on_system_conditional'
	}
	return stanza.node.method_name
}

pub fn cask_ast_stanza_group(stanza CaskAstStanza) []string {
	groups := stanza_constants.stanza_group_hash()
	return groups[cask_ast_stanza_name(stanza)] or { []string{} }
}

pub fn cask_ast_stanza_index(stanza CaskAstStanza) ?int {
	name := cask_ast_stanza_name(stanza)
	for index, stanza_name in stanza_constants.stanza_order {
		if stanza_name == name {
			return index
		}
	}
	return none
}

fn cask_ast_line_end(source string, position int) int {
	if position >= source.len {
		return source.len
	}
	newline := source[position..].index_u8(`\n`)
	return if newline < 0 { source.len } else { position + newline }
}

pub fn cask_ast_stanza_comments(stanza CaskAstStanza) []CaskAstComment {
	mut comments := []CaskAstComment{}
	node_begin := stanza.node.expression.begin_pos
	node_end := stanza.node.expression.end_pos
	line_end := cask_ast_line_end(stanza.full_source, node_end)
	for comment in stanza.all_comments {
		if comment.begin_pos >= node_begin && comment.begin_pos <= line_end {
			comments << comment
		}
	}
	mut preceding := []CaskAstComment{}
	mut preceding_start := node_begin
	for index := stanza.all_comments.len - 1; index >= 0; index-- {
		comment := stanza.all_comments[index]
		if comment.end_pos > preceding_start {
			continue
		}
		between := stanza.full_source[comment.end_pos..preceding_start]
		if between.trim_space() != '' {
			break
		}
		preceding << comment
		preceding_start = comment.begin_pos
	}
	preceding.reverse_in_place()
	for comment in preceding {
		if !comments.any(it.begin_pos == comment.begin_pos) {
			comments << comment
		}
	}
	comments.sort(a.begin_pos < b.begin_pos)
	return comments
}

pub fn cask_ast_stanza_range(stanza CaskAstStanza, with_comments bool) (int, int) {
	mut begin_pos := stanza.node.expression.begin_pos
	mut end_pos := stanza.node.expression.end_pos
	if with_comments {
		for comment in cask_ast_stanza_comments(stanza) {
			if comment.begin_pos < begin_pos {
				begin_pos = comment.begin_pos
			}
			if comment.end_pos > end_pos {
				end_pos = comment.end_pos
			}
		}
	}
	return begin_pos, end_pos
}

fn cask_ast_range_value(stanza CaskAstStanza, with_comments bool) ruby.Value {
	begin_pos, end_pos := cask_ast_stanza_range(stanza, with_comments)
	return ruby.structured_value('Parser::Source::Range', stanza.full_source[begin_pos..end_pos], {
		'begin_pos': begin_pos.str()
		'end_pos':   end_pos.str()
		'source':    stanza.full_source[begin_pos..end_pos]
	})
}

fn cask_ast_stanza_value(stanza CaskAstStanza) ruby.Value {
	begin_pos, end_pos := cask_ast_stanza_range(stanza, false)
	return ruby.structured_value('RuboCop::Cask::AST::Stanza', cask_ast_stanza_name(stanza), {
		'stanza_name': cask_ast_stanza_name(stanza)
		'begin_pos':   begin_pos.str()
		'end_pos':     end_pos.str()
		'source':      stanza.full_source[begin_pos..end_pos]
		'comments':    cask_ast_stanza_comments(stanza).map(it.source).join('\n')
	})
}
