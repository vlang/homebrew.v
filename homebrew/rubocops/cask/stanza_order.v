module cask

import ruby
import homebrew.rubocops.cask.ast as cask_ast
import homebrew.rubocops.cask.constants as stanza_constants

// Translated from Homebrew/brew `rubocops/cask/stanza_order.rb`.
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
