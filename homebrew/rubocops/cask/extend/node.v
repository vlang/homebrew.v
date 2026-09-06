module extend

import homebrew.rubocops.cask.constants as stanza_constants
import homebrew.utils

// Translated from Homebrew/brew `rubocops/cask/extend/node.rb` at
// df30fd34cc7132abfb8dbe3b1d046e3d48a57d00.
pub struct CaskNodeRange {
pub:
	begin_pos int
	end_pos   int
}

pub struct CaskNodeAncestor {
pub:
	kind         string
	method_name  string
	has_receiver bool
}

pub struct CaskAstNode {
pub:
	kind            string
	method_name     string
	source          string
	expression      CaskNodeRange
	children        []CaskAstNode
	ancestors       []CaskNodeAncestor
	has_receiver    bool
	location_type   string
	heredoc_end     CaskNodeRange
	has_heredoc_end bool
}

fn node_method_from_source(source string, assignment bool) (string, bool) {
	mut text := source.all_before('\n').all_before('#').trim_space()
	if assignment {
		equals := text.index('=') or { return '', false }
		text = text[equals + 1..].trim_space()
	}
	if text == '' {
		return '', false
	}
	mut end := 0
	for end < text.len {
		character := text[end]
		if !(character.is_alnum() || character in [`_`, `!`, `?`, `.`, `:`, `&`]) {
			break
		}
		end++
	}
	if end == 0 {
		return '', false
	}
	full_name := text[..end]
	mut normalized := full_name.replace('&.', '.').trim_left(':')
	parts := normalized.split('.')
	normalized = parts.last()
	return normalized, parts.len > 1
}

fn node_assignment_method(source string) (string, bool) {
	return node_method_from_source(source, true)
}

fn node_is_assignment(source string) bool {
	line := source.all_before('\n').all_before('#')
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
			continue
		}
		if character == `"` || character == `'` {
			quote = character
			continue
		}
		if character == `=` && (index + 1 >= line.len || line[index + 1] !in [`=`, `>`, `~`]) && (index == 0 || line[index - 1] !in [
			`=`,
			`!`,
			`<`,
			`>`,
			`|`,
			`&`,
			`+`,
			`-`,
			`*`,
			`/`,
			`%`,
			`^`,
		]) {
			left := line[..index].trim_space()
			if left == '' || !((left[0] >= `a` && left[0] <= `z`) || left[0] == `_`) {
				return false
			}
			return left.bytes().all(it.is_alnum() || it == `_`)
		}
	}
	return false
}

fn node_descriptor(node CaskAstNode) CaskNodeAncestor {
	return CaskNodeAncestor{
		kind: node.kind
		method_name: node.method_name
		has_receiver: node.has_receiver
	}
}

fn node_from_utils(value utils.AstNode, ancestors []CaskNodeAncestor) CaskAstNode {
	mut kind := match value.kind {
		'method_call' { 'send' }
		'block_call' { 'block' }
		'begin' { 'begin' }
		else { value.kind }
	}
	mut method_name := value.name
	mut has_receiver := value.has_receiver
	if node_is_assignment(value.source) {
		kind = 'lvasgn'
		method_name, has_receiver = node_assignment_method(value.source)
	}
	mut node := CaskAstNode{
		kind: kind
		method_name: method_name
		source: value.source
		expression: CaskNodeRange{
			begin_pos: value.source_range.begin_pos
			end_pos: value.source_range.end_pos
		}
		ancestors: ancestors.clone()
		has_receiver: has_receiver
		location_type: 'Parser::Source::Map'
	}
	mut child_ancestors := ancestors.clone()
	child_ancestors << node_descriptor(node)
	mut children := []CaskAstNode{}
	for child in value.children {
		children << node_from_utils(child, child_ancestors)
	}
	return CaskAstNode{
		...node
		children: children
	}
}

pub fn parse_cask_ast_node(source string) CaskAstNode {
	first_line := source.all_before('\n')
	parse_source := if heredoc_markers_in_line(first_line).len > 0 {
		first_line
	} else {
		source
	}
	_, parsed := utils.ast_process_source(parse_source)
	mut node := node_from_utils(parsed, [])
	// A heredoc's parser expression ends at the call expression, while the source
	// supplied at this boundary commonly includes the heredoc body as well.
	if parse_source != source && node.expression.begin_pos == 0 {
		node = CaskAstNode{
			...node
			source: source
		}
	}
	return node
}

pub fn method_node(node CaskAstNode) ?CaskAstNode {
	if node.kind == 'send' {
		return node
	}
	if node.kind != 'block' {
		return none
	}
	header := node.source.all_before('\n').all_before('#').trim_space()
	do_position := header.last_index(' do') or { header.len }
	method_source := header[..do_position].trim_right(' \t')
	return CaskAstNode{
		kind: 'send'
		method_name: node.method_name
		source: method_source
		expression: CaskNodeRange{
			begin_pos: node.expression.begin_pos
			end_pos: node.expression.begin_pos + method_source.len
		}
		ancestors: node.ancestors.clone()
		has_receiver: node.has_receiver
		location_type: 'Parser::Source::Map::Send'
	}
}

pub fn block_body(node CaskAstNode) ?CaskAstNode {
	if node.kind != 'block' || node.children.len == 0 {
		return none
	}
	if node.children.len == 1 {
		return node.children[0]
	}
	first := node.children[0]
	last := node.children.last()
	mut body_ancestors := node.ancestors.clone()
	body_ancestors << node_descriptor(node)
	return CaskAstNode{
		kind: 'begin'
		method_name: 'begin'
		source: node.children.map(it.source).join('\n')
		expression: CaskNodeRange{
			begin_pos: first.expression.begin_pos
			end_pos: last.expression.end_pos
		}
		children: node.children.clone()
		ancestors: body_ancestors
		location_type: 'Parser::Source::Map::Collection'
	}
}

pub fn cask_block(node CaskAstNode) bool {
	return node.kind == 'block' && node.method_name == 'cask' && !node.has_receiver
}

pub fn on_system_block(node CaskAstNode) bool {
	return node.kind == 'block' && !node.has_receiver && node.method_name in stanza_constants.on_system_methods
}

pub fn arch_variable(node CaskAstNode) bool {
	return node.kind == 'lvasgn' && !node.has_receiver && node.method_name == 'on_arch_conditional'
}

pub fn system_variable(node CaskAstNode) bool {
	return node.kind == 'lvasgn' && !node.has_receiver && node.method_name == 'on_system_conditional'
}

pub fn begin_block(node CaskAstNode) bool {
	return node.kind == 'begin'
}

pub fn cask_on_system_block(node CaskAstNode) bool {
	if !on_system_block(node) {
		return false
	}
	return node.ancestors.any(it.kind == 'block' && it.method_name == 'cask' && !it.has_receiver)
}

pub fn stanza(node CaskAstNode) bool {
	if arch_variable(node) || system_variable(node) {
		return true
	}
	if node.kind != 'block' && node.kind != 'send' {
		return false
	}
	return node.method_name in stanza_constants.on_system_methods || node.method_name in stanza_constants.stanza_order
}

pub fn heredoc(node CaskAstNode) bool {
	return node.location_type == 'Parser::Source::Map::Heredoc' || node.location_type.ends_with('::Heredoc')
}

fn node_descendants(node CaskAstNode) []CaskAstNode {
	mut result := []CaskAstNode{}
	for child in node.children {
		result << child
		result << node_descendants(child)
	}
	return result
}

fn heredoc_markers_in_line(line string) []string {
	mut markers := []string{}
	mut position := 0
	mut quote := u8(0)
	mut escaped := false
	for position < line.len {
		character := line[position]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if character == quote {
				quote = 0
			}
			position++
			continue
		}
		if character == `#` {
			break
		}
		if character in [`'`, `"`] || character == u8(96) {
			quote = character
			position++
			continue
		}
		if character != `<` || position + 1 >= line.len || line[position + 1] != `<` {
			position++
			continue
		}
		position += 2
		if position < line.len && line[position] in [`~`, `-`] {
			position++
		}
		for position < line.len && line[position].is_space() {
			position++
		}
		mut marker_quote := u8(0)
		if position < line.len && (line[position] in [`'`, `"`] || line[position] == u8(96)) {
			marker_quote = line[position]
			position++
		}
		start := position
		for position < line.len && (line[position].is_alnum() || line[position] == `_`) {
			position++
		}
		if position > start && (marker_quote == 0 || (position < line.len && line[position] == marker_quote)) {
			markers << line[start..position]
		}
		if marker_quote != 0 && position < line.len && line[position] == marker_quote {
			position++
		}
	}
	return markers
}

fn heredoc_ranges_from_source(source string, offset int) []CaskNodeRange {
	mut result := []CaskNodeRange{}
	lines := source.split_into_lines()
	mut line_offsets := []int{cap: lines.len}
	mut cursor := 0
	for line in lines {
		line_offsets << cursor
		cursor += line.len + 1
	}
	for line_index, line in lines {
		for marker in heredoc_markers_in_line(line) {
			for end_line in line_index + 1 .. lines.len {
				if lines[end_line].trim_space() == marker {
					marker_start := line_offsets[end_line] + (lines[end_line].index(marker) or { 0 })
					result << CaskNodeRange{
						begin_pos: offset + marker_start
						end_pos: offset + marker_start + marker.len
					}
					break
				}
			}
		}
	}
	return result
}

pub fn location_expression(node CaskAstNode) CaskNodeRange {
	mut expression := node.expression
	for descendant in node_descendants(node) {
		if heredoc(descendant) && descendant.has_heredoc_end {
			if descendant.heredoc_end.begin_pos < expression.begin_pos {
				expression = CaskNodeRange{
					begin_pos: descendant.heredoc_end.begin_pos
					end_pos: expression.end_pos
				}
			}
			if descendant.heredoc_end.end_pos > expression.end_pos {
				expression = CaskNodeRange{
					begin_pos: expression.begin_pos
					end_pos: descendant.heredoc_end.end_pos
				}
			}
		}
	}
	for heredoc_end in heredoc_ranges_from_source(node.source, node.expression.begin_pos) {
		if heredoc_end.end_pos > expression.end_pos {
			expression = CaskNodeRange{
				begin_pos: expression.begin_pos
				end_pos: heredoc_end.end_pos
			}
		}
	}
	return expression
}
