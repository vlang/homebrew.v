module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/service.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 29.
pub fn ruby_service_l29_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
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
