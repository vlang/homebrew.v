module extend

import brew_runtime
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

fn node_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn node_kind_from_value(value brew_runtime.Value) string {
	if kind := value.attributes['kind'] {
		return match kind {
			'method_call' { 'send' }
			'block_call' { 'block' }
			'begin_node' { 'begin' }
			'local_assignment' { 'lvasgn' }
			else { kind }
		}
	}
	return match value.type_name {
		'RuboCop::AST::SendNode' { 'send' }
		'RuboCop::AST::BlockNode' { 'block' }
		'RuboCop::AST::LvasgnNode' { 'lvasgn' }
		'RuboCop::AST::AsgnNode' {
			if node_is_assignment(value.repr) { 'lvasgn' } else { 'other' }
		}
		'RuboCop::AST::BeginNode' { 'begin' }
		else { 'other' }
	}
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

fn node_ancestor_values(value brew_runtime.Value) []CaskNodeAncestor {
	mut ancestors := []CaskNodeAncestor{}
	if encoded := value.attributes['ancestors'] {
		for item in encoded.split('>') {
			parts := item.split(':')
			ancestors << CaskNodeAncestor{
				kind: if parts.len > 1 { parts[0] } else { 'block' }
				method_name: parts.last()
			}
		}
	} else if encoded := value.attributes['ancestry'] {
		items := encoded.split('>')
		limit := if items.len > 0 && items.last() == (value.attributes['name'] or { '' }) {
			items.len - 1
		} else {
			items.len
		}
		for item in items[..limit] {
			ancestors << CaskNodeAncestor{
				kind: 'block'
				method_name: item
			}
		}
	}
	return ancestors
}

fn node_from_value(value brew_runtime.Value) CaskAstNode {
	if value.type_name == 'String' {
		return parse_cask_ast_node(value.as_string())
	}
	mut kind := node_kind_from_value(value)
	mut method_name := value.attributes['method_name'] or {
		value.attributes['name'] or { '' }
	}
	mut has_receiver := (value.attributes['has_receiver'] or { 'false' }).bool()
	if kind == 'lvasgn' || node_is_assignment(value.repr) {
		kind = 'lvasgn'
		if rhs_method := value.attributes['rhs_method_name'] {
			method_name = rhs_method
			has_receiver = (value.attributes['rhs_has_receiver'] or { 'false' }).bool()
		} else {
			method_name, has_receiver = node_assignment_method(value.repr)
		}
	} else if method_name == '' {
		method_name, has_receiver = node_method_from_source(value.repr, false)
	}
	mut child_values := value.array_data.clone()
	if child_values.len == 0 {
		if body := value.map_data['body'] {
			child_values = body.as_array() or { [] }
		}
	}
	mut children := []CaskAstNode{}
	for child in child_values {
		children << node_from_value(child)
	}
	begin_pos := (value.attributes['begin_pos'] or { '0' }).int()
	end_pos := (value.attributes['end_pos'] or { value.repr.len.str() }).int()
	heredoc_begin := (value.attributes['heredoc_end_begin'] or { '0' }).int()
	heredoc_finish := (value.attributes['heredoc_end_end'] or { '0' }).int()
	return CaskAstNode{
		kind: kind
		method_name: method_name
		source: value.repr
		expression: CaskNodeRange{
			begin_pos: begin_pos
			end_pos: end_pos
		}
		children: children
		ancestors: node_ancestor_values(value)
		has_receiver: has_receiver
		location_type: value.attributes['location_type'] or {
			value.attributes['loc_type'] or {
				if value.type_name.contains('Heredoc') { value.type_name } else { '' }
			}
		}
		heredoc_end: CaskNodeRange{
			begin_pos: heredoc_begin
			end_pos: heredoc_finish
		}
		has_heredoc_end: heredoc_finish > heredoc_begin
	}
}

fn node_to_value(node CaskAstNode) brew_runtime.Value {
	type_name := match node.kind {
		'send' { 'RuboCop::AST::SendNode' }
		'block' { 'RuboCop::AST::BlockNode' }
		'lvasgn' { 'RuboCop::AST::LvasgnNode' }
		'begin' { 'RuboCop::AST::BeginNode' }
		else { 'RuboCop::AST::Node' }
	}
	ancestor_text := node.ancestors.map('${it.kind}:${it.method_name}').join('>')
	return brew_runtime.Value{
		type_name: type_name
		repr: node.source
		array_data: node.children.map(node_to_value(it))
		attributes: {
			'kind':              node.kind
			'name':              node.method_name
			'method_name':       node.method_name
			'begin_pos':         node.expression.begin_pos.str()
			'end_pos':           node.expression.end_pos.str()
			'has_receiver':      node.has_receiver.str()
			'ancestors':         ancestor_text
			'location_type':     node.location_type
			'heredoc_end_begin': node.heredoc_end.begin_pos.str()
			'heredoc_end_end':   node.heredoc_end.end_pos.str()
			'has_heredoc_end':   node.has_heredoc_end.str()
		}
	}
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

fn node_range_value(source string, source_range CaskNodeRange) brew_runtime.Value {
	mut relative_begin := source_range.begin_pos
	mut relative_end := source_range.end_pos
	if relative_begin < 0 || relative_begin > source.len {
		relative_begin = 0
	}
	if relative_end < relative_begin || relative_end > source.len {
		relative_end = source.len
	}
	return brew_runtime.structured_value('Parser::Source::Range', source[relative_begin..relative_end], {
		'begin_pos': source_range.begin_pos.str()
		'end_pos':   source_range.end_pos.str()
	})
}

// Ruby def_node_matcher `def_node_matcher :method_node, "{$(send ...) (block $(send ...) ...)}"` at line 10.
pub fn ruby_node_l10_d1_method_node(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return node_nil()
	}
	result := method_node(node_from_value(args[0])) or { return node_nil() }
	return node_to_value(result)
}

// Ruby def_node_matcher `def_node_matcher :block_body,  "(block _ _ $_)"` at line 11.
pub fn ruby_node_l11_d2_block_body(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return node_nil()
	}
	result := block_body(node_from_value(args[0])) or { return node_nil() }
	return node_to_value(result)
}

// Ruby def_node_matcher `def_node_matcher :cask_block?, "(block (send nil? :cask ...) args ...)"` at line 12.
pub fn ruby_node_l12_d3_cask_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && cask_block(node_from_value(args[0])))
}

// Ruby def_node_matcher `def_node_matcher :on_system_block?` at line 13.
pub fn ruby_node_l13_d4_on_system_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && on_system_block(node_from_value(args[0])))
}

// Ruby def_node_matcher `def_node_matcher :arch_variable?` at line 15.
pub fn ruby_node_l15_d5_arch_variable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && arch_variable(node_from_value(args[0])))
}

// Ruby def_node_matcher `def_node_matcher :system_variable?` at line 16.
pub fn ruby_node_l16_d6_system_variable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && system_variable(node_from_value(args[0])))
}

// Ruby def_node_matcher `def_node_matcher :begin_block?` at line 17.
pub fn ruby_node_l17_d7_begin_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && begin_block(node_from_value(args[0])))
}

// Ruby method `cask_on_system_block?` at line 20.
pub fn ruby_node_l20_d8_cask_on_system_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && cask_on_system_block(node_from_value(args[0])))
}

// Ruby method `stanza?` at line 25.
pub fn ruby_node_l25_d9_stanza(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && stanza(node_from_value(args[0])))
}

// Ruby method `heredoc?` at line 37.
pub fn ruby_node_l37_d10_heredoc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 0 && heredoc(node_from_value(args[0])))
}

// Ruby method `location_expression` at line 42.
pub fn ruby_node_l42_d11_location_expression(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return node_range_value('', CaskNodeRange{})
	}
	node := node_from_value(args[0])
	return node_range_value(node.source, location_expression(node))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module AST
// 6:     # Extensions for RuboCop's AST Node class.
// 7:     class Node
// 8:       include RuboCop::Cask::Constants
// 9:
// 10:       def_node_matcher :method_node, "{$(send ...) (block $(send ...) ...)}"
// 11:       def_node_matcher :block_body,  "(block _ _ $_)"
// 12:       def_node_matcher :cask_block?, "(block (send nil? :cask ...) args ...)"
// 13:       def_node_matcher :on_system_block?,
// 14:                        "(block (send nil? {#{ON_SYSTEM_METHODS.map(&:inspect).join(" ")}} ...) args ...)"
// 15:       def_node_matcher :arch_variable?, "(lvasgn _ (send nil? :on_arch_conditional ...))"
// 16:       def_node_matcher :system_variable?, "(lvasgn _ (send nil? :on_system_conditional ...))"
// 17:       def_node_matcher :begin_block?, "(begin ...)"
// 18:
// 19:       sig { returns(T::Boolean) }
// 20:       def cask_on_system_block?
// 21:         (on_system_block? && each_ancestor.any?(&:cask_block?)) || false
// 22:       end
// 23:
// 24:       sig { returns(T::Boolean) }
// 25:       def stanza?
// 26:         return true if arch_variable?
// 27:         return true if system_variable?
// 28:
// 29:         case self
// 30:         when RuboCop::AST::BlockNode, RuboCop::AST::SendNode
// 31:           ON_SYSTEM_METHODS.include?(method_name) || STANZA_ORDER.include?(method_name)
// 32:         else false
// 33:         end
// 34:       end
// 35:
// 36:       sig { returns(T::Boolean) }
// 37:       def heredoc?
// 38:         loc.is_a?(Parser::Source::Map::Heredoc)
// 39:       end
// 40:
// 41:       sig { returns(Parser::Source::Range) }
// 42:       def location_expression
// 43:         base_expression = loc.expression
// 44:         descendants.select(&:heredoc?).reduce(base_expression) do |expr, node|
// 45:           expr.join(node.loc.heredoc_end)
// 46:         end
// 47:       end
// 48:     end
// 49:   end
// 50: end
