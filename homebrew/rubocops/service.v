module rubocops

import brew_runtime
import homebrew.utils

// Translated from Homebrew/brew `rubocops/service.rb`.
// The original source is retained below until every stub has a typed V body.
pub const service_required_method_calls = ['run', 'name']
pub const service_cellar_paths = ['bin', 'libexec', 'pkgshare', 'prefix', 'sbin', 'share']

pub struct ServiceMethodCall {
pub:
	name      string
	begin_pos int
	end_pos   int
	line      int
	column    int
}

pub struct ServiceOffense {
pub:
	kind        string
	method      string
	begin_pos   int
	end_pos     int
	line        int
	column      int
	message     string
	replacement string
}

struct ServiceEdit {
	begin_pos   int
	end_pos     int
	replacement string
}

fn service_line(source string, position int) int {
	mut line := 1
	limit := if position < source.len { position } else { source.len }
	for character in source[..limit].bytes() {
		if character == `\n` {
			line++
		}
	}
	return line
}

fn service_column(source string, position int) int {
	limit := if position < source.len { position } else { source.len }
	return limit - ((source[..limit].last_index('\n') or { -1 }) + 1)
}

fn service_identifier_byte(character u8) bool {
	return character.is_alnum() || character in [`_`, `!`, `?`]
}

fn service_next_code_byte(source string, start int, limit int) int {
	mut position := start
	for position < limit && source[position].is_space() {
		position++
	}
	return position
}

fn service_previous_code_byte(source string, start int, limit int) int {
	mut position := start - 1
	for position >= limit && source[position].is_space() {
		position--
	}
	return position
}

fn service_skip_quoted(source string, start int, limit int) int {
	quote := source[start]
	mut position := start + 1
	mut escaped := false
	for position < limit {
		character := source[position]
		if escaped {
			escaped = false
		} else if character == `\\` {
			escaped = true
		} else if character == quote {
			return position + 1
		}
		position++
	}
	return limit
}

fn service_local_names(source string, start int, limit int) []string {
	mut locals := []string{}
	mut position := start
	mut block_parameters := false
	for position < limit {
		character := source[position]
		if character in [`'`, `\"`] {
			position = service_skip_quoted(source, position, limit)
			continue
		}
		if character == `#` {
			position = source.index_after('\n', position) or { limit }
			continue
		}
		if character == `|` {
			block_parameters = !block_parameters
			position++
			continue
		}
		if !(character.is_letter() || character == `_`) {
			position++
			continue
		}
		begin := position
		position++
		for position < limit && service_identifier_byte(source[position]) {
			position++
		}
		name := source[begin..position]
		if block_parameters {
			if name !in locals {
				locals << name
			}
			continue
		}
		next := service_next_code_byte(source, position, limit)
		if next < limit && source[next] == `=` && (next + 1 >= limit || source[next + 1] !in [
			`=`,
			`>`,
		]) {
			previous := service_previous_code_byte(source, begin, start)
			if previous < start || source[previous] !in [`.`, `:`, `@`, `$`] {
				if name !in locals {
					locals << name
				}
			}
		}
	}
	return locals
}

fn service_keyword(name string) bool {
	return name in ['BEGIN', 'END', '__FILE__', '__LINE__', '__ENCODING__', 'alias', 'and', 'begin',
		'break', 'case', 'class', 'def', 'defined?', 'do', 'else', 'elsif', 'end', 'ensure', 'false',
		'for', 'if', 'in', 'module', 'next', 'nil', 'not', 'or', 'redo', 'rescue', 'retry', 'return',
		'self', 'super', 'then', 'true', 'undef', 'unless', 'until', 'when', 'while', 'yield']
}

fn service_method_calls(source string, start int, limit int) []ServiceMethodCall {
	locals := service_local_names(source, start, limit)
	mut calls := []ServiceMethodCall{}
	mut position := start
	mut block_parameters := false
	for position < limit {
		character := source[position]
		if character in [`'`, `\"`] {
			position = service_skip_quoted(source, position, limit)
			continue
		}
		if character == `#` {
			position = source.index_after('\n', position) or { limit }
			continue
		}
		if character == `|` {
			block_parameters = !block_parameters
			position++
			continue
		}
		if !(character.is_letter() || character == `_`) {
			position++
			continue
		}
		begin := position
		position++
		for position < limit && service_identifier_byte(source[position]) {
			position++
		}
		name := source[begin..position]
		if block_parameters || service_keyword(name) || name[0].is_capital() {
			continue
		}
		previous := service_previous_code_byte(source, begin, start)
		next := service_next_code_byte(source, position, limit)
		if (previous >= start && source[previous] in [`@`, `$`]) || (previous >= start && source[previous] == `:` && (previous == start || source[previous - 1] != `:`)) || (next < limit && source[next] == `:` && (next + 1 >= limit || source[next + 1] != `:`)) || (next < limit && source[next] == `=` && (next + 1 >= limit || source[next + 1] !in [
			`=`,
			`>`,
		])) {
			continue
		}
		has_receiver := previous >= start && (source[previous] == `.` || (source[previous] == `:` && previous > start && source[previous - 1] == `:`))
		if !has_receiver && name in locals && (next >= limit || source[next] != `(`) {
			continue
		}
		calls << ServiceMethodCall{
			name: name
			begin_pos: begin
			end_pos: position
			line: service_line(source, begin)
			column: service_column(source, begin)
		}
	}
	return calls
}

fn service_formula_body_nodes(root utils.AstNode) []utils.AstNode {
	if root.kind == 'class' {
		return root.children
	}
	if root.kind == 'begin' {
		for node in root.children {
			if node.kind == 'class' && node.source.all_before('\n').contains('< Formula') {
				return node.children
			}
		}
		return root.children
	}
	return [root]
}

fn service_block(source string) ?utils.AstNode {
	if !source.contains('service') || source.trim_space() == '' {
		return none
	}
	_, root := utils.ast_process_source(source)
	for node in service_formula_body_nodes(root) {
		if node.kind == 'block_call' && node.name == 'service' {
			return node
		}
	}
	return none
}

fn service_header_end(source string, block utils.AstNode) int {
	line_end := source.index_after('\n', block.source_range.begin_pos) or { block.source_range.end_pos }
	mut end := if line_end < block.source_range.end_pos {
		line_end
	} else {
		block.source_range.end_pos
	}
	for end > block.source_range.begin_pos && source[end - 1].is_space() {
		end--
	}
	return end
}

fn service_opt_path(path string) string {
	return match path {
		'bin' { 'opt_bin' }
		'libexec' { 'opt_libexec' }
		'pkgshare' { 'opt_pkgshare' }
		'prefix' { 'opt_prefix' }
		'sbin' { 'opt_sbin' }
		'share' { 'opt_share' }
		else { '' }
	}
}

fn service_method_list(methods []string) string {
	mut symbols := []string{cap: methods.len}
	for method in methods {
		symbols << ':${method}'
	}
	return '[${symbols.join(', ')}]'
}

pub fn audit_service_block(source string) []ServiceOffense {
	block := service_block(source) or { return [] }
	calls := service_method_calls(source, block.body_range.begin_pos, block.body_range.end_pos)
	mut grouped := map[string][]ServiceMethodCall{}
	mut method_names := []string{}
	for call in calls {
		if call.name !in grouped {
			method_names << call.name
		}
		grouped[call.name] << call
	}
	mut offenses := []ServiceOffense{}
	header_end := service_header_end(source, block)
	header_line := service_line(source, block.source_range.begin_pos)
	header_column := service_column(source, block.source_range.begin_pos)
	if !method_names.any(it in service_required_method_calls) {
		offenses << ServiceOffense{
			kind: 'missing_required_method'
			begin_pos: block.source_range.begin_pos
			end_pos: header_end
			line: header_line
			column: header_column
			message: 'Service blocks require `run` or `name` to be defined.'
		}
	} else if 'run' !in grouped {
		other_method_calls := method_names.filter(it !in ['name', 'require_root'])
		if other_method_calls.len > 0 {
			offenses << ServiceOffense{
				kind: 'missing_run'
				begin_pos: block.source_range.begin_pos
				end_pos: header_end
				line: header_line
				column: header_column
				message: '`run` must be defined to use methods other than `name` like ${service_method_list(other_method_calls)}.'
			}
		}
	}
	for path in service_cellar_paths {
		opt_path := service_opt_path(path)
		for call in grouped[path] {
			offenses << ServiceOffense{
				kind: 'cellar_path'
				method: path
				begin_pos: call.begin_pos
				end_pos: call.end_pos
				line: call.line
				column: call.column
				message: 'Use `${opt_path}` instead of `${path}` in service blocks.'
				replacement: opt_path
			}
		}
	}
	return offenses
}

pub fn correct_service_block(source string) string {
	mut edits := audit_service_block(source).filter(it.replacement != '').map(ServiceEdit{
		begin_pos: it.begin_pos
		end_pos: it.end_pos
		replacement: it.replacement
	})
	edits.sort(a.begin_pos > b.begin_pos)
	mut corrected := source
	for edit in edits {
		corrected = corrected[..edit.begin_pos] + edit.replacement + corrected[edit.end_pos..]
	}
	return corrected
}

fn service_offense_value(offense ServiceOffense) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Offense', offense.message, {
		'kind':        offense.kind
		'method':      offense.method
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'line':        offense.line.str()
		'column':      offense.column.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 29.
pub fn ruby_service_l29_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.array_value(audit_service_block(source).map(service_offense_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module FormulaAudit
// 9:       # This cop audits the service block.
// 10:       class Service < FormulaCop
// 11:         extend AutoCorrector
// 12:
// 13:         CELLAR_PATH_AUDIT_CORRECTIONS = T.let(
// 14:           {
// 15:             bin:      :opt_bin,
// 16:             libexec:  :opt_libexec,
// 17:             pkgshare: :opt_pkgshare,
// 18:             prefix:   :opt_prefix,
// 19:             sbin:     :opt_sbin,
// 20:             share:    :opt_share,
// 21:           }.freeze,
// 22:           T::Hash[Symbol, Symbol],
// 23:         )
// 24:
// 25:         # At least one of these methods must be defined in a service block.
// 26:         REQUIRED_METHOD_CALLS = [:run, :name].freeze
// 27:
// 28:         sig { override.params(formula_nodes: FormulaNodes).void }
// 29:         def audit_formula(formula_nodes)
// 30:           service_node = find_block(formula_nodes.body_node, :service)
// 31:           return if service_node.blank?
// 32:
// 33:           method_calls = service_node.each_descendant(:send).group_by(&:method_name)
// 34:           method_calls.delete(:service)
// 35:
// 36:           # NOTE: Solving the first problem here might solve the second one too
// 37:           #       so we don't show both of them at the same time.
// 38:           if !method_calls.keys.intersect?(REQUIRED_METHOD_CALLS)
// 39:             offending_node(service_node)
// 40:             problem "Service blocks require `run` or `name` to be defined."
// 41:           elsif !method_calls.key?(:run)
// 42:             other_method_calls = method_calls.keys - [:name, :require_root]
// 43:             if other_method_calls.any?
// 44:               offending_node(service_node)
// 45:               problem "`run` must be defined to use methods other than `name` like #{other_method_calls}."
// 46:             end
// 47:           end
// 48:
// 49:           # This check ensures that Cellar paths like `bin` are not referenced
// 50:           # because their `opt_` variants are more portable and work with the API.
// 51:           CELLAR_PATH_AUDIT_CORRECTIONS.each do |path, opt_path|
// 52:             next unless method_calls.key?(path)
// 53:
// 54:             method_calls.fetch(path).each do |node|
// 55:               offending_node(node)
// 56:               problem "Use `#{opt_path}` instead of `#{path}` in service blocks." do |corrector|
// 57:                 corrector.replace(node.source_range, opt_path)
// 58:               end
// 59:             end
// 60:           end
// 61:         end
// 62:       end
// 63:     end
// 64:   end
// 65: end
