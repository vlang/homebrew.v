module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/deprecate_disable.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 14.
pub fn ruby_deprecate_disable_l14_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby def_node_search `def_node_search :date, <<~EOS` at line 34.
pub fn ruby_deprecate_disable_l34_d2_date(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('date', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 46.
pub fn ruby_deprecate_disable_l46_d3_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby def_node_search `def_node_search :reason, <<~EOS` at line 86.
pub fn ruby_deprecate_disable_l86_d4_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reason', ...args)
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
// 9:       # This cop audits `deprecate!` and `disable!` dates.
// 10:       class DeprecateDisableDate < FormulaCop
// 11:         extend AutoCorrector
// 12:
// 13:         sig { override.params(formula_nodes: FormulaNodes).void }
// 14:         def audit_formula(formula_nodes)
// 15:           body_node = formula_nodes.body_node
// 16:
// 17:           [:deprecate!, :disable!].each do |method|
// 18:             node = find_node_method_by_name(body_node, method)
// 19:
// 20:             next if node.nil?
// 21:
// 22:             date(node) do |date_node|
// 23:               Date.iso8601(string_content(date_node))
// 24:             rescue ArgumentError
// 25:               fixed_date_string = Date.parse(string_content(date_node)).iso8601
// 26:               @offensive_node = date_node
// 27:               problem "Use `#{fixed_date_string}` to comply with ISO 8601" do |corrector|
// 28:                 corrector.replace(date_node.source_range, "\"#{fixed_date_string}\"")
// 29:               end
// 30:             end
// 31:           end
// 32:         end
// 33:
// 34:         def_node_search :date, <<~EOS
// 35:           (pair (sym :date) $str)
// 36:         EOS
// 37:       end
// 38:
// 39:       # This cop audits `deprecate!` and `disable!` reasons.
// 40:       class DeprecateDisableReason < FormulaCop
// 41:         extend AutoCorrector
// 42:
// 43:         PUNCTUATION_MARKS = %w[. ! ?].freeze
// 44:
// 45:         sig { override.params(formula_nodes: FormulaNodes).void }
// 46:         def audit_formula(formula_nodes)
// 47:           body_node = formula_nodes.body_node
// 48:
// 49:           [:deprecate!, :disable!].each do |method|
// 50:             node = find_node_method_by_name(body_node, method)
// 51:
// 52:             next if node.nil?
// 53:
// 54:             reason_found = T.let(false, T::Boolean)
// 55:             reason(node) do |reason_node|
// 56:               reason_found = true
// 57:               next if reason_node.sym_type?
// 58:
// 59:               @offensive_node = reason_node
// 60:               reason_string = string_content(reason_node)
// 61:
// 62:               if reason_string.start_with?("it ")
// 63:                 problem "Do not start the reason with `it`" do |corrector|
// 64:                   corrector.replace(@offensive_node.source_range, "\"#{reason_string[3..]}\"")
// 65:                 end
// 66:               end
// 67:
// 68:               if PUNCTUATION_MARKS.include?(reason_string[-1])
// 69:                 problem "Do not end the reason with a punctuation mark" do |corrector|
// 70:                   corrector.replace(@offensive_node.source_range, "\"#{reason_string.chop}\"")
// 71:                 end
// 72:               end
// 73:             end
// 74:
// 75:             next if reason_found
// 76:
// 77:             case method
// 78:             when :deprecate!
// 79:               problem 'Add a reason for deprecation: `deprecate! because: "..."`'
// 80:             when :disable!
// 81:               problem 'Add a reason for disabling: `disable! because: "..."`'
// 82:             end
// 83:           end
// 84:         end
// 85:
// 86:         def_node_search :reason, <<~EOS
// 87:           (pair (sym :because) ${str sym})
// 88:         EOS
// 89:       end
// 90:     end
// 91:   end
// 92: end
