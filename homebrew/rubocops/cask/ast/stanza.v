module ast

import brew_runtime
import homebrew.rubocops.cask.constants as stanza_constants
import homebrew.rubocops.cask.extend as cask_extend

// Translated from Homebrew/brew `rubocops/cask/ast/stanza.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn cask_ast_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
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

fn cask_ast_node_value(node cask_extend.CaskAstNode) brew_runtime.Value {
	type_name := match node.kind {
		'block' { 'RuboCop::AST::BlockNode' }
		'send' { 'RuboCop::AST::SendNode' }
		'lvasgn' { 'RuboCop::AST::LvasgnNode' }
		'begin' { 'RuboCop::AST::BeginNode' }
		else { 'RuboCop::AST::Node' }
	}
	return brew_runtime.Value{
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

fn cask_ast_comment_values(comments []CaskAstComment) brew_runtime.Value {
	return brew_runtime.array_value(comments.map(brew_runtime.structured_value('Parser::Source::Comment', it.source, {
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

fn cask_ast_range_value(stanza CaskAstStanza, with_comments bool) brew_runtime.Value {
	begin_pos, end_pos := cask_ast_stanza_range(stanza, with_comments)
	return brew_runtime.structured_value('Parser::Source::Range', stanza.full_source[begin_pos..end_pos], {
		'begin_pos': begin_pos.str()
		'end_pos':   end_pos.str()
		'source':    stanza.full_source[begin_pos..end_pos]
	})
}

fn cask_ast_stanza_value(stanza CaskAstStanza) brew_runtime.Value {
	begin_pos, end_pos := cask_ast_stanza_range(stanza, false)
	return brew_runtime.structured_value('RuboCop::Cask::AST::Stanza', cask_ast_stanza_name(stanza), {
		'stanza_name': cask_ast_stanza_name(stanza)
		'begin_pos':   begin_pos.str()
		'end_pos':     end_pos.str()
		'source':      stanza.full_source[begin_pos..end_pos]
		'comments':    cask_ast_stanza_comments(stanza).map(it.source).join('\n')
	})
}

// Ruby method `initialize(method_node, all_comments)` at line 21.
pub fn ruby_stanza_l21_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	stanza := cask_ast_stanza_from_source(source) or { return cask_ast_nil() }
	return cask_ast_stanza_value(stanza)
}

// Ruby attr_reader `attr_reader :method_node` at line 27.
pub fn ruby_stanza_l27_d2_method_node(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	stanza := cask_ast_stanza_from_source(source) or { return cask_ast_nil() }
	return cask_ast_node_value(stanza.node)
}

// Ruby alias `alias stanza_node method_node` at line 28.
pub fn ruby_stanza_l28_d3_stanza_node(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_stanza_l27_d2_method_node(...args)
}

// Ruby attr_reader `attr_reader :all_comments` at line 31.
pub fn ruby_stanza_l31_d4_all_comments(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return cask_ast_comment_values(parse_cask_ast_comments(source))
}

// Ruby def_delegator `def_delegator :stanza_node, :parent, :parent_node` at line 33.
pub fn ruby_stanza_l33_d5_parent_node(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	stanza := cask_ast_stanza_from_source(source) or { return cask_ast_nil() }
	if stanza.node.ancestors.len == 0 {
		return cask_ast_nil()
	}
	ancestor := stanza.node.ancestors.last()
	return brew_runtime.structured_value('RuboCop::AST::Node', ancestor.method_name, {
		'kind':        ancestor.kind
		'method_name': ancestor.method_name
	})
}

// Ruby def_delegator `def_delegator :stanza_node, :arch_variable?` at line 34.
pub fn ruby_stanza_l34_d6_arch_variable(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	stanza := cask_ast_stanza_from_source(source) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(cask_extend.arch_variable(stanza.node))
}

// Ruby def_delegator `def_delegator :stanza_node, :system_variable?` at line 35.
pub fn ruby_stanza_l35_d7_system_variable(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	stanza := cask_ast_stanza_from_source(source) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(cask_extend.system_variable(stanza.node))
}

// Ruby def_delegator `def_delegator :stanza_node, :on_system_block?` at line 36.
pub fn ruby_stanza_l36_d8_on_system_block(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	stanza := cask_ast_stanza_from_source(source) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(cask_extend.on_system_block(stanza.node))
}

// Ruby method `source_range` at line 39.
pub fn ruby_stanza_l39_d9_source_range(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	stanza := cask_ast_stanza_from_source(source) or { return cask_ast_nil() }
	return cask_ast_range_value(stanza, false)
}

// Ruby method `source_range_with_comments` at line 44.
pub fn ruby_stanza_l44_d10_source_range_with_comments(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	stanza := cask_ast_stanza_from_source(source) or { return cask_ast_nil() }
	return cask_ast_range_value(stanza, true)
}

// Ruby def_delegator `def_delegator :source_range, :source` at line 50.
pub fn ruby_stanza_l50_d11_source(args ...brew_runtime.Value) brew_runtime.Value {
	value := ruby_stanza_l39_d9_source_range(...args)
	return if value.type_name == 'NilClass' {
		value
	} else {
		brew_runtime.string_value(value.attributes['source'])
	}
}

// Ruby def_delegator `def_delegator :source_range_with_comments, :source, :source_with_comments` at line 51.
pub fn ruby_stanza_l51_d12_source_with_comments(args ...brew_runtime.Value) brew_runtime.Value {
	value := ruby_stanza_l44_d10_source_range_with_comments(...args)
	return if value.type_name == 'NilClass' {
		value
	} else {
		brew_runtime.string_value(value.attributes['source'])
	}
}

// Ruby method `stanza_name` at line 55.
pub fn ruby_stanza_l55_d13_stanza_name(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	stanza := cask_ast_stanza_from_source(source) or { return cask_ast_nil() }
	return brew_runtime.string_value(cask_ast_stanza_name(stanza))
}

// Ruby method `stanza_group` at line 64.
pub fn ruby_stanza_l64_d14_stanza_group(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	stanza := cask_ast_stanza_from_source(source) or { return cask_ast_nil() }
	group := cask_ast_stanza_group(stanza)
	return if group.len == 0 { cask_ast_nil() } else { brew_runtime.string_array_value(group) }
}

// Ruby method `stanza_index` at line 69.
pub fn ruby_stanza_l69_d15_stanza_index(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	stanza := cask_ast_stanza_from_source(source) or { return cask_ast_nil() }
	index := cask_ast_stanza_index(stanza) or { return cask_ast_nil() }
	return brew_runtime.int_value(index)
}

// Ruby method `same_group?(other)` at line 74.
pub fn ruby_stanza_l74_d16_same_group(args ...brew_runtime.Value) brew_runtime.Value {
	first_source := if args.len > 0 { args[0].as_string() } else { '' }
	second_source := if args.len > 1 { args[1].as_string() } else { '' }
	first := cask_ast_stanza_from_source(first_source) or { return brew_runtime.bool_value(false) }
	second := cask_ast_stanza_from_source(second_source) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(cask_ast_stanza_group(first) == cask_ast_stanza_group(second))
}

// Ruby method `comments` at line 79.
pub fn ruby_stanza_l79_d17_comments(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	stanza := cask_ast_stanza_from_source(source) or { return brew_runtime.array_value([]brew_runtime.Value{}) }
	return cask_ast_comment_values(cask_ast_stanza_comments(stanza))
}

// Ruby method `comments_hash` at line 89.
pub fn ruby_stanza_l89_d18_comments_hash(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	comments := parse_cask_ast_comments(source)
	mut values := map[string]brew_runtime.Value{}
	for comment in comments {
		values['${comment.begin_pos}:${comment.end_pos}'] = brew_runtime.string_value(comment.source)
	}
	return brew_runtime.map_value(values)
}

// Ruby method `==(other)` at line 97.
pub fn ruby_stanza_l97_d19_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	first_source := if args.len > 0 { args[0].as_string() } else { '' }
	second_source := if args.len > 1 { args[1].as_string() } else { '' }
	first := cask_ast_stanza_from_source(first_source) or { return brew_runtime.bool_value(false) }
	second := cask_ast_stanza_from_source(second_source) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(first.node.kind == second.node.kind && first.node.method_name == second.node.method_name && first.node.source == second.node.source)
}

// Ruby alias `alias eql? ==` at line 100.
pub fn ruby_stanza_l100_d20_eql(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_stanza_l97_d19_anonymous(...args)
}

// Ruby method `#{stanza_name.to_s.chomp("!")}?               # def url?` at line 104.
pub fn ruby_stanza_l104_d21_stanza_name_to_s_chomp(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	queried_name := if args.len > 1 { args[1].as_string().trim_right('!') } else { '' }
	stanza := cask_ast_stanza_from_source(source) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(cask_ast_stanza_name(stanza).trim_right('!') == queried_name)
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
// 9:       # This class wraps the AST send/block node that encapsulates the method
// 10:       # call that comprises the stanza. It includes various helper methods to
// 11:       # aid cops in their analysis.
// 12:       class Stanza
// 13:         extend Forwardable
// 14:
// 15:         sig {
// 16:           params(
// 17:             method_node:  T.any(RuboCop::AST::AsgnNode, RuboCop::AST::BlockNode, RuboCop::AST::SendNode),
// 18:             all_comments: T::Array[T.any(String, Parser::Source::Comment)],
// 19:           ).void
// 20:         }
// 21:         def initialize(method_node, all_comments)
// 22:           @method_node = method_node
// 23:           @all_comments = all_comments
// 24:         end
// 25:
// 26:         sig { returns(T.any(RuboCop::AST::AsgnNode, RuboCop::AST::BlockNode, RuboCop::AST::SendNode)) }
// 27:         attr_reader :method_node
// 28:         alias stanza_node method_node
// 29:
// 30:         sig { returns(T::Array[T.any(Parser::Source::Comment, String)]) }
// 31:         attr_reader :all_comments
// 32:
// 33:         def_delegator :stanza_node, :parent, :parent_node
// 34:         def_delegator :stanza_node, :arch_variable?
// 35:         def_delegator :stanza_node, :system_variable?
// 36:         def_delegator :stanza_node, :on_system_block?
// 37:
// 38:         sig { returns(Parser::Source::Range) }
// 39:         def source_range
// 40:           stanza_node.location_expression
// 41:         end
// 42:
// 43:         sig { returns(Parser::Source::Range) }
// 44:         def source_range_with_comments
// 45:           comments.reduce(source_range) do |range, comment|
// 46:             range.join(comment.loc.expression)
// 47:           end
// 48:         end
// 49:
// 50:         def_delegator :source_range, :source
// 51:         def_delegator :source_range_with_comments, :source,
// 52:                       :source_with_comments
// 53:
// 54:         sig { returns(Symbol) }
// 55:         def stanza_name
// 56:           return :on_arch_conditional if arch_variable?
// 57:           return :on_system_conditional if system_variable?
// 58:           return stanza_node.method_node&.method_name if stanza_node.block_type?
// 59:
// 60:           T.cast(stanza_node, RuboCop::AST::SendNode).method_name
// 61:         end
// 62:
// 63:         sig { returns(T.nilable(T::Array[Symbol])) }
// 64:         def stanza_group
// 65:           Constants::STANZA_GROUP_HASH[stanza_name]
// 66:         end
// 67:
// 68:         sig { returns(T.nilable(Integer)) }
// 69:         def stanza_index
// 70:           Constants::STANZA_ORDER.index(stanza_name)
// 71:         end
// 72:
// 73:         sig { params(other: Stanza).returns(T::Boolean) }
// 74:         def same_group?(other)
// 75:           stanza_group == other.stanza_group
// 76:         end
// 77:
// 78:         sig { returns(T::Array[Parser::Source::Comment]) }
// 79:         def comments
// 80:           @comments ||= T.let(
// 81:             stanza_node.each_node.reduce([]) do |comments, node|
// 82:               comments | comments_hash[node.loc]
// 83:             end,
// 84:             T.nilable(T::Array[Parser::Source::Comment]),
// 85:           )
// 86:         end
// 87:
// 88:         sig { returns(T::Hash[Parser::Source::Map, T::Array[Parser::Source::Comment]]) }
// 89:         def comments_hash
// 90:           @comments_hash ||= T.let(
// 91:             Parser::Source::Comment.associate_locations(stanza_node.parent, all_comments),
// 92:             T.nilable(T::Hash[Parser::Source::Map, T::Array[Parser::Source::Comment]]),
// 93:           )
// 94:         end
// 95:
// 96:         sig { params(other: T.untyped).returns(T::Boolean) }
// 97:         def ==(other)
// 98:           self.class == other.class && stanza_node == other.stanza_node
// 99:         end
// 100:         alias eql? ==
// 101:
// 102:         Constants::STANZA_ORDER.each do |stanza_name|
// 103:           class_eval <<-RUBY, __FILE__, __LINE__ + 1
// 104:             def #{stanza_name.to_s.chomp("!")}?               # def url?
// 105:               stanza_name == :#{stanza_name}                  #   stanza_name == :url
// 106:             end                                               # end
// 107:           RUBY
// 108:         end
// 109:       end
// 110:     end
// 111:   end
// 112: end
