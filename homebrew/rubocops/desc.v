module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/desc.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 17.
pub fn ruby_desc_l17_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5: require "rubocops/shared/desc_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module FormulaAudit
// 10:       # This cop audits `desc` in formulae.
// 11:       # See the {DescHelper} module for details of the checks.
// 12:       class Desc < FormulaCop
// 13:         include DescHelper
// 14:         extend AutoCorrector
// 15:
// 16:         sig { override.params(formula_nodes: FormulaNodes).void }
// 17:         def audit_formula(formula_nodes)
// 18:           body_node = formula_nodes.body_node
// 19:
// 20:           @name = T.let(@formula_name, T.nilable(String))
// 21:           desc_call = find_node_method_by_name(body_node, :desc)
// 22:           offending_node(formula_nodes.class_node) if body_node.nil?
// 23:           audit_desc(:formula, @name, desc_call)
// 24:         end
// 25:       end
// 26:     end
// 27:   end
// 28: end
