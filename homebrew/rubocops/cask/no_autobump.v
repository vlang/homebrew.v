module cask

import brew_runtime
import homebrew.rubocops as formula_no_autobump_core
import homebrew.rubocops.@shared as no_autobump_shared

// Translated from Homebrew/brew `rubocops/cask/no_autobump.rb`.
// The original source is retained below until every stub has a typed V body.
pub const cask_no_autobump_missing_reason_message = 'Add a reason for exclusion from autobump: `no_autobump! because: "..."`'

fn cask_no_autobump_opens_block(line string) bool {
	code := line.all_before('#').trim_space()
	if code.ends_with(' do') || code.contains(' do |') {
		return true
	}
	for keyword in ['if ', 'unless ', 'case ', 'begin', 'while ', 'until ', 'for ', 'def ', 'class '] {
		if code == keyword.trim_space() || code.starts_with(keyword) {
			return true
		}
	}
	return false
}

pub fn cask_no_autobump_stanzas(source string) []formula_no_autobump_core.NoAutobumpCall {
	mut stanzas := []formula_no_autobump_core.NoAutobumpCall{}
	mut depth := 0
	mut in_cask := false
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		trimmed := line.all_before('#').trim_space()
		if !in_cask {
			if trimmed.starts_with('cask ') && cask_no_autobump_opens_block(trimmed) {
				in_cask = true
				depth = 1
			}
		} else {
			if trimmed == 'end' || trimmed.starts_with('end ') {
				depth--
				if depth == 0 {
					in_cask = false
				}
			} else {
				if depth == 1 && trimmed.starts_with('no_autobump!') && (trimmed.len == 'no_autobump!'.len || trimmed['no_autobump!'.len] in [
					` `,
					`\t`,
					`(`,
				]) {
					indent := line.len - line.trim_left(' \t').len
					call := formula_no_autobump_core.find_no_autobump_call(line) or {
						formula_no_autobump_core.NoAutobumpCall{}
					}
					stanzas << formula_no_autobump_core.NoAutobumpCall{
						...call
						begin_pos: line_start + call.begin_pos
						end_pos: line_start + call.end_pos
						reason_begin: if call.has_reason {
							line_start + call.reason_begin
						} else {
							line_start + indent
						}
						reason_end: if call.has_reason {
							line_start + call.reason_end
						} else {
							line_start + indent
						}
					}
				}
				if cask_no_autobump_opens_block(trimmed) {
					depth++
				}
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return stanzas
}

pub fn audit_cask_no_autobump(source string) []no_autobump_shared.NoAutobumpReasonProblem {
	mut problems := []no_autobump_shared.NoAutobumpReasonProblem{}
	for call in cask_no_autobump_stanzas(source) {
		if !call.has_reason {
			problems << no_autobump_shared.NoAutobumpReasonProblem{
				kind: 'missing_reason'
				begin_pos: call.begin_pos
				end_pos: call.end_pos
				message: cask_no_autobump_missing_reason_message
			}
			continue
		}
		problems << no_autobump_shared.audit_no_autobump_reason(call.reason, call.reason_symbol, call.reason_begin, call.reason_end)
	}
	return problems
}

pub fn correct_cask_no_autobump(source string) string {
	mut problems := audit_cask_no_autobump(source).filter(it.replacement != '')
	problems.sort(a.begin_pos > b.begin_pos)
	mut corrected := source
	mut last_begin := source.len + 1
	for problem in problems {
		if problem.end_pos > last_begin {
			continue
		}
		corrected = corrected[..problem.begin_pos] + problem.replacement + corrected[problem.end_pos..]
		last_begin = problem.begin_pos
	}
	return corrected
}

fn cask_no_autobump_problem_value(problem no_autobump_shared.NoAutobumpReasonProblem) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':        problem.kind
		'reason':      problem.reason
		'is_symbol':   problem.is_symbol.str()
		'begin_pos':   problem.begin_pos.str()
		'end_pos':     problem.end_pos.str()
		'message':     problem.message
		'replacement': problem.replacement
	})
}

fn cask_no_autobump_stanza_value(call formula_no_autobump_core.NoAutobumpCall) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cask::AST::Stanza', 'no_autobump!', {
		'name':          'no_autobump!'
		'begin_pos':     call.begin_pos.str()
		'end_pos':       call.end_pos.str()
		'has_reason':    call.has_reason.str()
		'reason':        call.reason
		'reason_symbol': call.reason_symbol.str()
	})
}

// Ruby method `on_cask(cask_block)` at line 19.
pub fn ruby_no_autobump_l19_d1_on_cask(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.array_value(audit_cask_no_autobump(source).map(cask_no_autobump_problem_value(it)))
}

// Ruby attr_reader `attr_reader :cask_block` at line 40.
pub fn ruby_no_autobump_l40_d2_cask_block(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.structured_value('RuboCop::Cask::AST::CaskBlock', source, {
		'source':                source
		'toplevel_stanza_count': cask_no_autobump_stanzas(source).len.str()
	})
}

// Ruby def_delegators `def_delegators :cask_block, :toplevel_stanzas` at line 42.
pub fn ruby_no_autobump_l42_d3_toplevel_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.array_value(cask_no_autobump_stanzas(source).map(cask_no_autobump_stanza_value(it)))
}

// Ruby def_node_search `def_node_search :reason, <<~EOS` at line 44.
pub fn ruby_no_autobump_l44_d4_reason(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	call := formula_no_autobump_core.find_no_autobump_call(source) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	if !call.has_reason {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.structured_value(if call.reason_symbol { 'Symbol' } else { 'String' }, call.reason, {
		'begin_pos': call.reason_begin.str()
		'end_pos':   call.reason_end.str()
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "forwardable"
// 5: require "rubocops/shared/no_autobump_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module Cask
// 10:       # This cop audits `no_autobump!` reason.
// 11:       # See the {NoAutobumpHelper} module for details of the checks.
// 12:       class NoAutobump < Base
// 13:         extend Forwardable
// 14:         extend AutoCorrector
// 15:         include CaskHelp
// 16:         include NoAutobumpHelper
// 17:
// 18:         sig { override.params(cask_block: RuboCop::Cask::AST::CaskBlock).void }
// 19:         def on_cask(cask_block)
// 20:           @cask_block = T.let(cask_block, T.nilable(RuboCop::Cask::AST::CaskBlock))
// 21:
// 22:           toplevel_stanzas.select(&:no_autobump?).each do |stanza|
// 23:             no_autobump_node = stanza.stanza_node
// 24:
// 25:             reason_found = T.let(false, T::Boolean)
// 26:             reason(no_autobump_node) do |reason_node|
// 27:               reason_found = true
// 28:               audit_no_autobump(:cask, reason_node)
// 29:             end
// 30:
// 31:             next if reason_found
// 32:
// 33:             problem 'Add a reason for exclusion from autobump: `no_autobump! because: "..."`'
// 34:           end
// 35:         end
// 36:
// 37:         private
// 38:
// 39:         sig { returns(T.nilable(RuboCop::Cask::AST::CaskBlock)) }
// 40:         attr_reader :cask_block
// 41:
// 42:         def_delegators :cask_block, :toplevel_stanzas
// 43:
// 44:         def_node_search :reason, <<~EOS
// 45:           (pair (sym :because) ${str sym})
// 46:         EOS
// 47:       end
// 48:     end
// 49:   end
// 50: end
