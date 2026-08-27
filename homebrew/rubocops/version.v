module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/version.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 12.
pub fn ruby_version_l12_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
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
// 9:       # This cop makes sure that a `version` is in the correct format.
// 10:       class Version < FormulaCop
// 11:         sig { override.params(formula_nodes: FormulaNodes).void }
// 12:         def audit_formula(formula_nodes)
// 13:           version_node = find_node_method_by_name(formula_nodes.body_node, :version)
// 14:           return unless version_node
// 15:
// 16:           version = string_content(parameters(version_node).fetch(0))
// 17:
// 18:           problem "Version is set to an empty string" if version.empty?
// 19:
// 20:           problem "Version #{version} should not have a leading 'v'" if version.start_with?("v")
// 21:
// 22:           return unless version.match?(/_\d+$/)
// 23:
// 24:           problem "Version #{version} should not end with an underline and a number"
// 25:         end
// 26:       end
// 27:     end
// 28:   end
// 29: end
