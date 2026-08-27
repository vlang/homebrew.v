module utils

import brew_runtime

// Translated from Homebrew/brew `utils/topological_hash.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `tsort_with_cycles(&on_cycle)` at line 20.
pub fn ruby_topological_hash_l20_d1_tsort_with_cycles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tsort_with_cycles', ...args)
}

// Ruby method `self.graph_package_dependencies(packages, accumulator = TopologicalHash.new)` at line 46.
pub fn ruby_topological_hash_l46_d2_self_graph_package_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.graph_package_dependencies', ...args)
}

// Ruby method `tsort_each_node(&block)` at line 80.
pub fn ruby_topological_hash_l80_d3_tsort_each_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tsort_each_node', ...args)
}

// Ruby method `tsort_each_child(node, &block)` at line 85.
pub fn ruby_topological_hash_l85_d4_tsort_each_child(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tsort_each_child', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "tsort"
// 5:
// 6: module Utils
// 7:   # Cycle-tolerant ordering for graphs that include TSort.
// 8:   module CycleTolerantTSort
// 9:     extend T::Helpers
// 10:
// 11:     requires_ancestor { TSort }
// 12:
// 13:     # Orders nodes dependency-first like tsort but, unlike tsort, does not
// 14:     # raise on a cycle: yields cyclic components (size > 1) to the block and
// 15:     # returns the flattened component order.
// 16:     sig {
// 17:       params(on_cycle: T.proc.params(arg0: T::Array[T::Array[T.untyped]]).void)
// 18:         .returns(T::Array[T.untyped])
// 19:     }
// 20:     def tsort_with_cycles(&on_cycle)
// 21:       components = each_strongly_connected_component.to_a
// 22:       cycles = components.select { |component| component.size > 1 }
// 23:       yield(cycles) if cycles.any?
// 24:       components.flatten
// 25:     end
// 26:   end
// 27:
// 28:   # Topologically sortable hash map.
// 29:   class TopologicalHash < Hash
// 30:     extend T::Generic
// 31:     include TSort
// 32:     include CycleTolerantTSort
// 33:
// 34:     CaskOrFormula = T.type_alias { T.any(Cask::Cask, Formula) }
// 35:
// 36:     K = type_member { { fixed: CaskOrFormula } }
// 37:     V = type_member { { fixed: T::Array[CaskOrFormula] } }
// 38:     Elem = type_member(:out) { { fixed: [CaskOrFormula, T::Array[CaskOrFormula]] } }
// 39:
// 40:     sig {
// 41:       params(
// 42:         packages:    T.any(CaskOrFormula, T::Array[CaskOrFormula]),
// 43:         accumulator: TopologicalHash,
// 44:       ).returns(TopologicalHash)
// 45:     }
// 46:     def self.graph_package_dependencies(packages, accumulator = TopologicalHash.new)
// 47:       packages = Array(packages)
// 48:
// 49:       packages.each do |cask_or_formula|
// 50:         next if accumulator.key?(cask_or_formula)
// 51:
// 52:         case cask_or_formula
// 53:         when Cask::Cask
// 54:           formula_deps = cask_or_formula.depends_on
// 55:                                         .formula
// 56:                                         .map { |f| Formula[f] }
// 57:           cask_deps = cask_or_formula.depends_on
// 58:                                      .cask
// 59:                                      .map { |c| Cask::CaskLoader.load(c, config: nil) }
// 60:         when Formula
// 61:           formula_deps = cask_or_formula.deps
// 62:                                         .filter_map { |d| d.to_formula if !d.build? && !d.test? }
// 63:           cask_deps = cask_or_formula.requirements
// 64:                                      .filter_map(&:cask)
// 65:                                      .map { |c| Cask::CaskLoader.load(c, config: nil) }
// 66:         else
// 67:           T.absurd(cask_or_formula)
// 68:         end
// 69:
// 70:         accumulator[cask_or_formula] = formula_deps + cask_deps
// 71:
// 72:         graph_package_dependencies(formula_deps, accumulator)
// 73:         graph_package_dependencies(cask_deps, accumulator)
// 74:       end
// 75:
// 76:       accumulator
// 77:     end
// 78:
// 79:     sig { override.params(block: T.proc.params(arg0: K).void).void }
// 80:     def tsort_each_node(&block)
// 81:       each_key(&block)
// 82:     end
// 83:
// 84:     sig { override.params(node: K, block: T.proc.params(arg0: CaskOrFormula).void).returns(V) }
// 85:     def tsort_each_child(node, &block)
// 86:       fetch(node).each(&block)
// 87:     end
// 88:   end
// 89: end
