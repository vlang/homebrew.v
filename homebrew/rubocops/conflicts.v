module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/conflicts.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 17.
pub fn ruby_conflicts_l17_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
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
// 9:       # This cop audits versioned formulae for `conflicts_with`.
// 10:       class Conflicts < FormulaCop
// 11:         extend AutoCorrector
// 12:
// 13:         MSG = "Versioned formulae should not use `conflicts_with`. " \
// 14:               "Use `keg_only :versioned_formula` instead."
// 15:
// 16:         sig { override.params(formula_nodes: FormulaNodes).void }
// 17:         def audit_formula(formula_nodes)
// 18:           return if (body_node = formula_nodes.body_node).nil?
// 19:
// 20:           find_method_calls_by_name(body_node, :conflicts_with).each do |conflicts_with_call|
// 21:             next unless parameters(conflicts_with_call).last.respond_to? :values
// 22:
// 23:             reason = T.cast(parameters(conflicts_with_call).fetch(-1), RuboCop::AST::HashNode).values.first
// 24:             offending_node(reason)
// 25:             name = Regexp.new(T.must(@formula_name), Regexp::IGNORECASE)
// 26:             reason_text = string_content(reason).sub(name, "")
// 27:             first_word = reason_text.split.fetch(0)
// 28:
// 29:             if reason_text.match?(/\A[A-Z]/)
// 30:               problem "'#{first_word}' from the `conflicts_with` reason " \
// 31:                       "should be '#{first_word.downcase}'." do |corrector|
// 32:                 reason_text[0] = T.must(reason_text[0]).downcase
// 33:                 corrector.replace(reason.source_range, "\"#{reason_text}\"")
// 34:               end
// 35:             end
// 36:             next unless reason_text.end_with?(".")
// 37:
// 38:             problem "`conflicts_with` reason should not end with a period." do |corrector|
// 39:               corrector.replace(reason.source_range, "\"#{reason_text.chop}\"")
// 40:             end
// 41:           end
// 42:
// 43:           return unless versioned_formula?
// 44:
// 45:           if !tap_style_exception?(:versioned_formulae_conflicts_allowlist) && method_called_ever?(body_node,
// 46:                                                                                                    :conflicts_with)
// 47:             problem MSG do |corrector|
// 48:               corrector.replace(T.must(@offensive_node).source_range, "keg_only :versioned_formula")
// 49:             end
// 50:           end
// 51:         end
// 52:       end
// 53:     end
// 54:   end
// 55: end
