module cask

import ruby
import homebrew.rubocops.cask.ast as cask_ast
import homebrew.rubocops.cask.constants as stanza_constants

// Translated from Homebrew/brew `rubocops/cask/stanza_order.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct StanzaOrderProblem {
pub:
	stanza      string
	begin_pos   int
	end_pos     int
	message     string
	replacement string
	scope_begin int
	depth       int
}

fn stanza_order_index(name string) int {
	for index, stanza in stanza_constants.stanza_order {
		if stanza == name {
			return index
		}
	}
	return stanza_constants.stanza_order.len
}

pub fn sort_cask_stanza_names(names []string) []string {
	mut ordered := []string{}
	for name in names {
		index := stanza_order_index(name)
		mut inserted := false
		for position, existing in ordered {
			if stanza_order_index(existing) > index {
				ordered.insert(position, name)
				inserted = true
				break
			}
		}
		if !inserted {
			ordered << name
		}
	}
	return ordered
}

fn stanza_order_sorted(stanzas []cask_ast.CaskAstStanza) []cask_ast.CaskAstStanza {
	mut ordered := []cask_ast.CaskAstStanza{}
	for stanza in stanzas {
		index := stanza_order_index(cask_ast.cask_ast_stanza_name(stanza))
		mut inserted := false
		for position, existing in ordered {
			if stanza_order_index(cask_ast.cask_ast_stanza_name(existing)) > index {
				ordered.insert(position, stanza)
				inserted = true
				break
			}
		}
		if !inserted {
			ordered << stanza
		}
	}
	return ordered
}

fn stanza_order_source_with_comments(stanza cask_ast.CaskAstStanza) string {
	begin_pos, end_pos := cask_ast.cask_ast_stanza_range(stanza, true)
	return stanza.full_source[begin_pos..end_pos]
}

fn stanza_order_same(first cask_ast.CaskAstStanza, second cask_ast.CaskAstStanza) bool {
	return first.node.kind == second.node.kind && first.node.method_name == second.node.method_name && first.node.source == second.node.source
}

fn stanza_order_column(source string, position int) int {
	line_start := source[..position].last_index('\n') or { -1 }
	return position - line_start - 1
}

fn stanza_order_dedent_block(source string, indent int) string {
	if indent == 0 {
		return source
	}
	lines := source.split('\n')
	mut result := []string{cap: lines.len}
	for index, line in lines {
		if index == 0 || line.trim_space() == '' {
			result << line
		} else {
			result << line[if line.len < indent { line.len } else { indent }..]
		}
	}
	return result.join('\n')
}

fn stanza_order_reindent_block(source string, indent int) string {
	if indent == 0 {
		return source
	}
	padding := ' '.repeat(indent)
	lines := source.split('\n')
	mut result := []string{cap: lines.len}
	for index, line in lines {
		result << if index == 0 || line.trim_space() == '' { line } else { padding + line }
	}
	return result.join('\n')
}

fn stanza_order_absolute_position(source string, position int, scope_begin int, removed_indent int) int {
	return scope_begin + position + source[..position].count('\n') * removed_indent
}

fn stanza_order_audit_scope(source string, scope_begin int, removed_indent int, depth int) []StanzaOrderProblem {
	block := cask_ast.parse_cask_ast_stanza_block(source, false) or {
		return []StanzaOrderProblem{}
	}
	stanzas := cask_ast.cask_ast_block_stanzas(block, false)
	ordered := stanza_order_sorted(stanzas)
	mut problems := []StanzaOrderProblem{}
	for index, stanza_before in stanzas {
		stanza_after := ordered[index]
		if stanza_order_same(stanza_before, stanza_after) {
			continue
		}
		begin_pos, end_pos := cask_ast.cask_ast_stanza_range(stanza_before, true)
		name := cask_ast.cask_ast_stanza_name(stanza_before)
		problems << StanzaOrderProblem{
			stanza: name
			begin_pos: stanza_order_absolute_position(source, begin_pos, scope_begin, removed_indent)
			end_pos: stanza_order_absolute_position(source, end_pos, scope_begin, removed_indent)
			message: '`${name}` stanza out of order'
			replacement: stanza_order_source_with_comments(stanza_after)
			scope_begin: scope_begin
			depth: depth
		}
	}
	for stanza in stanzas {
		if stanza.node.kind != 'block' || stanza.node.method_name !in stanza_constants.on_system_methods {
			continue
		}
		raw_nested := stanza.full_source[stanza.node.expression.begin_pos..stanza.node.expression.end_pos]
		local_indent := stanza_order_column(source, stanza.node.expression.begin_pos)
		nested_source := stanza_order_dedent_block(raw_nested, local_indent)
		nested_begin := stanza_order_absolute_position(source, stanza.node.expression.begin_pos, scope_begin, removed_indent)
		problems << stanza_order_audit_scope(nested_source, nested_begin, removed_indent + local_indent, depth + 1)
	}
	return problems
}

pub fn audit_cask_stanza_order(source string) []StanzaOrderProblem {
	return stanza_order_audit_scope(source, 0, 0, 0)
}

fn stanza_order_correct_scope(source string) string {
	block := cask_ast.parse_cask_ast_stanza_block(source, false) or { return source }
	mut corrected := source
	mut nested_replacements := []StanzaOrderProblem{}
	for stanza in cask_ast.cask_ast_block_stanzas(block, false) {
		if stanza.node.kind != 'block' || stanza.node.method_name !in stanza_constants.on_system_methods {
			continue
		}
		raw_nested := stanza.full_source[stanza.node.expression.begin_pos..stanza.node.expression.end_pos]
		indent := stanza_order_column(corrected, stanza.node.expression.begin_pos)
		nested_source := stanza_order_dedent_block(raw_nested, indent)
		nested := stanza_order_correct_scope(nested_source)
		if nested != nested_source {
			nested_replacements << StanzaOrderProblem{
				begin_pos: stanza.node.expression.begin_pos
				end_pos: stanza.node.expression.end_pos
				replacement: stanza_order_reindent_block(nested, indent)
			}
		}
	}
	nested_replacements.sort(a.begin_pos > b.begin_pos)
	for replacement in nested_replacements {
		corrected = corrected[..replacement.begin_pos] + replacement.replacement + corrected[replacement.end_pos..]
	}
	block_after_nested := cask_ast.parse_cask_ast_stanza_block(corrected, false) or { return corrected }
	stanzas := cask_ast.cask_ast_block_stanzas(block_after_nested, false)
	ordered := stanza_order_sorted(stanzas)
	mut replacements := []StanzaOrderProblem{}
	for index, stanza_before in stanzas {
		stanza_after := ordered[index]
		if stanza_order_same(stanza_before, stanza_after) {
			continue
		}
		begin_pos, end_pos := cask_ast.cask_ast_stanza_range(stanza_before, true)
		replacements << StanzaOrderProblem{
			begin_pos: begin_pos
			end_pos: end_pos
			replacement: stanza_order_source_with_comments(stanza_after)
		}
	}
	replacements.sort(a.begin_pos > b.begin_pos)
	for replacement in replacements {
		corrected = corrected[..replacement.begin_pos] + replacement.replacement + corrected[replacement.end_pos..]
	}
	return corrected
}

pub fn correct_cask_stanza_order(source string) string {
	return stanza_order_correct_scope(source)
}

fn stanza_order_problem_value(problem StanzaOrderProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Offense', problem.message, {
		'stanza':      problem.stanza
		'begin_pos':   problem.begin_pos.str()
		'end_pos':     problem.end_pos.str()
		'message':     problem.message
		'replacement': problem.replacement
	})
}

// Ruby method `on_cask_stanza_block(stanza_block)` at line 19.
pub fn ruby_stanza_order_l19_d1_on_cask_stanza_block(args ...ruby.Value) ruby.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return ruby.array_value(audit_cask_stanza_order(source).map(stanza_order_problem_value(it)))
}

// Ruby method `on_new_investigation` at line 47.
pub fn ruby_stanza_order_l47_d2_on_new_investigation(args ...ruby.Value) ruby.Value {
	return ruby.array_value([]ruby.Value{})
}

// Ruby method `sort_stanzas(stanzas)` at line 56.
pub fn ruby_stanza_order_l56_d3_sort_stanzas(args ...ruby.Value) ruby.Value {
	names := if args.len > 0 { args[0].string_array_data } else { []string{} }
	return ruby.string_array_value(sort_cask_stanza_names(names))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "forwardable"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module Cask
// 9:       # This cop checks that a cask's stanzas are ordered correctly, including nested within `on_*` blocks.
// 10:       # @see https://docs.brew.sh/Cask-Cookbook#stanza-order
// 11:       class StanzaOrder < Base
// 12:         include IgnoredNode
// 13:         extend AutoCorrector
// 14:         include CaskHelp
// 15:
// 16:         MESSAGE = "`%<stanza>s` stanza out of order"
// 17:
// 18:         sig { override.params(stanza_block: RuboCop::Cask::AST::StanzaBlock).void }
// 19:         def on_cask_stanza_block(stanza_block)
// 20:           stanzas = stanza_block.stanzas
// 21:           ordered_stanzas = sort_stanzas(stanzas)
// 22:
// 23:           return if stanzas == ordered_stanzas
// 24:
// 25:           stanzas.zip(ordered_stanzas).each do |stanza_before, stanza_after|
// 26:             next if stanza_before == stanza_after
// 27:
// 28:             add_offense(
// 29:               stanza_before.method_node,
// 30:               message: format(MESSAGE, stanza: stanza_before.stanza_name),
// 31:             ) do |corrector|
// 32:               next if part_of_ignored_node?(stanza_before.method_node)
// 33:               raise "unexpected nil value for stanza_after" unless stanza_after
// 34:
// 35:               corrector.replace(
// 36:                 stanza_before.source_range_with_comments,
// 37:                 stanza_after.source_with_comments,
// 38:               )
// 39:
// 40:               # Ignore node so that nested content is not auto-corrected and clobbered.
// 41:               ignore_node(stanza_before.method_node)
// 42:             end
// 43:           end
// 44:         end
// 45:
// 46:         sig { override.void }
// 47:         def on_new_investigation
// 48:           super
// 49:
// 50:           ignored_nodes.clear
// 51:         end
// 52:
// 53:         private
// 54:
// 55:         sig { params(stanzas: T::Array[RuboCop::Cask::AST::Stanza]).returns(T::Array[RuboCop::Cask::AST::Stanza]) }
// 56:         def sort_stanzas(stanzas)
// 57:           stanzas.sort do |stanza1, stanza2|
// 58:             i1 = stanza1.stanza_index
// 59:             i2 = stanza2.stanza_index
// 60:
// 61:             if i1 == i2
// 62:               i1 = stanzas.index(stanza1)
// 63:               i2 = stanzas.index(stanza2)
// 64:             end
// 65:             raise "unexpected nil value for i1" unless i1
// 66:             raise "unexpected nil value for i2" unless i2
// 67:
// 68:             i1 - i2
// 69:           end
// 70:         end
// 71:       end
// 72:     end
// 73:   end
// 74: end
