module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/no_autobump.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 17.
pub fn ruby_no_autobump_l17_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby def_node_search `def_node_search :reason, <<~EOS` at line 35.
pub fn ruby_no_autobump_l35_d2_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reason', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5: require "rubocops/shared/no_autobump_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module FormulaAudit
// 10:       # This cop audits `no_autobump!` reason.
// 11:       # See the {NoAutobumpHelper} module for details of the checks.
// 12:       class NoAutobump < FormulaCop
// 13:         include NoAutobumpHelper
// 14:         extend AutoCorrector
// 15:
// 16:         sig { override.params(formula_nodes: FormulaNodes).void }
// 17:         def audit_formula(formula_nodes)
// 18:           body_node = formula_nodes.body_node
// 19:           no_autobump_call = find_node_method_by_name(body_node, :no_autobump!)
// 20:
// 21:           return if no_autobump_call.nil?
// 22:
// 23:           reason_found = T.let(false, T::Boolean)
// 24:           reason(no_autobump_call) do |reason_node|
// 25:             reason_found = true
// 26:             offending_node(reason_node)
// 27:             audit_no_autobump(:formula, reason_node)
// 28:           end
// 29:
// 30:           return if reason_found
// 31:
// 32:           problem 'Add a reason for exclusion from autobump: `no_autobump! because: "..."`'
// 33:         end
// 34:
// 35:         def_node_search :reason, <<~EOS
// 36:           (pair (sym :because) ${str sym})
// 37:         EOS
// 38:       end
// 39:     end
// 40:   end
// 41: end
