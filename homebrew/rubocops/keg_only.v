module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/keg_only.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 14.
pub fn ruby_keg_only_l14_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `autocorrect(node)` at line 51.
pub fn ruby_keg_only_l51_d2_autocorrect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autocorrect', ...args)
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
// 9:       # This cop makes sure that a `keg_only` reason has the correct format.
// 10:       class KegOnly < FormulaCop
// 11:         extend AutoCorrector
// 12:
// 13:         sig { override.params(formula_nodes: FormulaNodes).void }
// 14:         def audit_formula(formula_nodes)
// 15:           keg_only_node = find_node_method_by_name(formula_nodes.body_node, :keg_only)
// 16:           return unless keg_only_node
// 17:
// 18:           allowlist = %w[
// 19:             Apple
// 20:             macOS
// 21:             OS
// 22:             Homebrew
// 23:             Xcode
// 24:             GPG
// 25:             GNOME
// 26:             BSD
// 27:             Firefox
// 28:           ].freeze
// 29:
// 30:           reason = parameters(keg_only_node).fetch(0)
// 31:           @offensive_node = reason
// 32:           name = Regexp.new(T.must(@formula_name), Regexp::IGNORECASE)
// 33:           reason = string_content(reason).sub(name, "")
// 34:           first_word = reason.split.fetch(0)
// 35:
// 36:           if /\A[A-Z]/.match?(reason) && !reason.start_with?(*allowlist)
// 37:             problem "'#{first_word}' from the `keg_only` reason should be '#{first_word.downcase}'." do |corrector|
// 38:               reason[0] = T.must(reason[0]).downcase # reason[0] must exist because of the regexp match
// 39:               corrector.replace(@offensive_node.source_range, "\"#{reason}\"")
// 40:             end
// 41:           end
// 42:
// 43:           return unless reason.end_with?(".")
// 44:
// 45:           problem "`keg_only` reason should not end with a period." do |corrector|
// 46:             corrector.replace(@offensive_node.source_range, "\"#{reason.chop}\"")
// 47:           end
// 48:         end
// 49:
// 50:         sig { params(node: RuboCop::AST::Node).void }
// 51:         def autocorrect(node)
// 52:           lambda do |corrector|
// 53:             reason = string_content(node)
// 54:             raise "unexpected empty reason" unless reason[0]
// 55:
// 56:             reason[0] = T.must(reason[0]).downcase # reason[0] must exist because of the previous line
// 57:             reason = reason.delete_suffix(".")
// 58:             corrector.replace(node.source_range, "\"#{reason}\"")
// 59:           end
// 60:         end
// 61:       end
// 62:     end
// 63:   end
// 64: end
