module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/resource_requires_dependencies.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 14.
pub fn ruby_resource_requires_dependencies_l14_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
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
// 9:       # This cop audits Python formulae that include certain resources
// 10:       # to ensure that they also have the correct `uses_from_macos`
// 11:       # dependencies.
// 12:       class ResourceRequiresDependencies < FormulaCop
// 13:         sig { override.params(formula_nodes: FormulaNodes).void }
// 14:         def audit_formula(formula_nodes)
// 15:           return if (body_node = formula_nodes.body_node).nil?
// 16:
// 17:           resource_nodes = find_every_method_call_by_name(body_node, :resource)
// 18:           return if resource_nodes.empty?
// 19:
// 20:           %w[bcrypt lxml pynacl pyyaml].each do |resource_name|
// 21:             found = resource_nodes.find { |node| node.arguments&.first&.str_content == resource_name }
// 22:             next unless found
// 23:
// 24:             uses_from_macos_nodes = find_every_method_call_by_name(body_node, :uses_from_macos)
// 25:             depends_on_nodes = find_every_method_call_by_name(body_node, :depends_on)
// 26:             uses_from_macos_or_depends_on = (uses_from_macos_nodes + depends_on_nodes).filter_map do |node|
// 27:               if (dep = node.arguments.first).hash_type?
// 28:                 dep_types = dep.values.first
// 29:                 dep_types = dep_types.array_type? ? dep_types.values : [dep_types]
// 30:                 dep.keys.first.str_content if dep_types.select(&:sym_type?).map(&:value).include?(:build)
// 31:               else
// 32:                 dep.str_content
// 33:               end
// 34:             end
// 35:
// 36:             required_deps = case resource_name
// 37:             when "bcrypt"
// 38:               kind = "depends_on"
// 39:               ["pkgconf", "rust"]
// 40:             when "lxml"
// 41:               kind = depends_on?(:linux) ? "depends_on" : "uses_from_macos"
// 42:               ["libxml2", "libxslt"]
// 43:             when "pynacl"
// 44:               kind = "depends_on"
// 45:               ["libsodium"]
// 46:             when "pyyaml"
// 47:               kind = "depends_on"
// 48:               ["libyaml"]
// 49:             else
// 50:               []
// 51:             end
// 52:             next if required_deps.all? { |dep| uses_from_macos_or_depends_on.include?(dep) }
// 53:
// 54:             @offensive_node = found
// 55:             problem "Add `#{kind}` lines above for #{required_deps.map { |req| "`\"#{req}\"`" }.join(" and ")}."
// 56:           end
// 57:         end
// 58:       end
// 59:     end
// 60:   end
// 61: end
