module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/class.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 20.
pub fn ruby_class_l20_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 37.
pub fn ruby_class_l37_d2_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby def_node_search `def_node_search :test_calls, <<~EOS` at line 67.
pub fn ruby_class_l67_d3_test_calls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('test_calls', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 77.
pub fn ruby_class_l77_d4_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
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
// 9:       # This cop makes sure that {Formula} is used as superclass.
// 10:       class ClassName < FormulaCop
// 11:         extend AutoCorrector
// 12:
// 13:         DEPRECATED_CLASSES = %w[
// 14:           GithubGistFormula
// 15:           ScriptFileFormula
// 16:           AmazonWebServicesFormula
// 17:         ].freeze
// 18:
// 19:         sig { override.params(formula_nodes: FormulaNodes).void }
// 20:         def audit_formula(formula_nodes)
// 21:           parent_class_node = formula_nodes.parent_class_node
// 22:
// 23:           parent_class = class_name(parent_class_node)
// 24:           return unless DEPRECATED_CLASSES.include?(parent_class)
// 25:
// 26:           problem "`#{parent_class}` is deprecated, use `Formula` instead" do |corrector|
// 27:             corrector.replace(parent_class_node.source_range, "Formula")
// 28:           end
// 29:         end
// 30:       end
// 31:
// 32:       # This cop makes sure that a `test` block contains a proper test.
// 33:       class Test < FormulaCop
// 34:         extend AutoCorrector
// 35:
// 36:         sig { override.params(formula_nodes: FormulaNodes).void }
// 37:         def audit_formula(formula_nodes)
// 38:           test = find_block(formula_nodes.body_node, :test)
// 39:           return unless test
// 40:
// 41:           if test.body.nil?
// 42:             problem "`test do` should not be empty"
// 43:             return
// 44:           end
// 45:
// 46:           problem "`test do` should contain a real test" if test.body.single_line? && test.body.source.to_s == "true"
// 47:
// 48:           test_calls(test) do |node, params|
// 49:             p1, p2 = params
// 50:             if (match = string_content(p1).match(%r{(/usr/local/(s?bin))}))
// 51:               offending_node(p1)
// 52:               problem "Use `\#{#{match[2]}}` instead of `#{match[1]}` in `#{node}`" do |corrector|
// 53:                 corrector.replace(p1.source_range, p1.source.sub(match[1], "\#{#{match[2]}}"))
// 54:               end
// 55:             end
// 56:
// 57:             if node == :shell_output && node_equals?(p2, 0)
// 58:               offending_node(p2)
// 59:               problem "Passing 0 to `shell_output` is redundant" do |corrector|
// 60:                 corrector.remove(range_with_surrounding_comma(range_with_surrounding_space(range: p2.source_range,
// 61:                                                                                            side:  :left)))
// 62:               end
// 63:             end
// 64:           end
// 65:         end
// 66:
// 67:         def_node_search :test_calls, <<~EOS
// 68:           (send nil? ${:system :shell_output :pipe_output} $...)
// 69:         EOS
// 70:       end
// 71:     end
// 72:
// 73:     module FormulaAuditStrict
// 74:       # This cop makes sure that a `test` block exists.
// 75:       class TestPresent < FormulaCop
// 76:         sig { override.params(formula_nodes: FormulaNodes).void }
// 77:         def audit_formula(formula_nodes)
// 78:           body_node = formula_nodes.body_node
// 79:           return if find_block(body_node, :test)
// 80:           return if find_node_method_by_name(body_node, :disable!)
// 81:
// 82:           offending_node(formula_nodes.class_node) if body_node.nil?
// 83:           problem "A `test do` test block should be added"
// 84:         end
// 85:       end
// 86:     end
// 87:   end
// 88: end
