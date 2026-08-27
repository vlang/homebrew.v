module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/options.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 15.
pub fn ruby_options_l15_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
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
// 9:       # This cop audits `option`s in formulae.
// 10:       class Options < FormulaCop
// 11:         DEP_OPTION = "Formulae in homebrew/core should not use `deprecated_option`."
// 12:         OPTION = "Formulae in homebrew/core should not use `option`."
// 13:
// 14:         sig { override.params(formula_nodes: FormulaNodes).void }
// 15:         def audit_formula(formula_nodes)
// 16:           return if (body_node = formula_nodes.body_node).nil?
// 17:
// 18:           option_call_nodes = find_every_method_call_by_name(body_node, :option)
// 19:           option_call_nodes.each do |option_call|
// 20:             option = parameters(option_call).fetch(0)
// 21:             offending_node(option_call)
// 22:             option = string_content(option)
// 23:
// 24:             unless /with(out)?-/.match?(option)
// 25:               problem "Options should begin with `with` or `without`. " \
// 26:                       "Migrate '--#{option}' with `deprecated_option`."
// 27:             end
// 28:
// 29:             next unless option =~ /^with(out)?-(?:checks?|tests)$/
// 30:             next if depends_on?("check", :optional, :recommended)
// 31:
// 32:             problem "Use '--with#{Regexp.last_match(1)}-test' instead of '--#{option}'. " \
// 33:                     "Migrate '--#{option}' with `deprecated_option`."
// 34:           end
// 35:
// 36:           return if formula_tap != "homebrew-core"
// 37:
// 38:           problem DEP_OPTION if method_called_ever?(body_node, :deprecated_option)
// 39:           problem OPTION if method_called_ever?(body_node, :option)
// 40:         end
// 41:       end
// 42:     end
// 43:   end
// 44: end
