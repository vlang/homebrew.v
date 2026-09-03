module utils

// Translated from Homebrew/brew `utils/topological_hash.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct TopologicalHash {
mut:
	nodes []string
	graph map[string][]string
}

pub fn new_topological_hash() TopologicalHash {
	return TopologicalHash{}
}

pub fn (mut graph TopologicalHash) set(node string, children []string) {
	if node !in graph.graph {
		graph.nodes << node
	}
	graph.graph[node] = children.clone()
}

pub fn (graph &TopologicalHash) has(node string) bool {
	return node in graph.graph
}

pub fn (graph &TopologicalHash) each_node() []string {
	return graph.nodes.clone()
}

pub fn (graph &TopologicalHash) each_child(node string) ![]string {
	if node !in graph.graph {
		return error('key not found: ${node}')
	}
	return graph.graph[node].clone()
}

struct TopologicalSccState {
mut:
	next_index int
	indices    map[string]int
	lowlinks   map[string]int
	stack      []string
	on_stack   map[string]bool
	components [][]string
}

fn (graph &TopologicalHash) visit_strongly_connected(node string,
	mut state TopologicalSccState) ! {
	index := state.next_index
	state.next_index++
	state.indices[node] = index
	state.lowlinks[node] = index
	state.stack << node
	state.on_stack[node] = true
	for child in graph.each_child(node)! {
		if child !in graph.graph {
			return error('key not found: ${child}')
		}
		if child !in state.indices {
			graph.visit_strongly_connected(child, mut state)!
			if state.lowlinks[child] < state.lowlinks[node] {
				state.lowlinks[node] = state.lowlinks[child]
			}
		} else if state.on_stack[child] && state.indices[child] < state.lowlinks[node] {
			state.lowlinks[node] = state.indices[child]
		}
	}
	if state.lowlinks[node] != state.indices[node] {
		return
	}
	mut component := []string{}
	for state.stack.len > 0 {
		member := state.stack.pop()
		state.on_stack[member] = false
		component << member
		if member == node {
			break
		}
	}
	component.reverse_in_place()
	state.components << component
}

pub fn (graph &TopologicalHash) strongly_connected_components() ![][]string {
	mut state := TopologicalSccState{}
	for node in graph.nodes {
		if node !in state.indices {
			graph.visit_strongly_connected(node, mut state)!
		}
	}
	return state.components
}

fn (graph &TopologicalHash) component_is_cycle(component []string) bool {
	if component.len > 1 {
		return true
	}
	return component.len == 1 && component[0] in graph.graph[component[0]]
}

pub fn (graph &TopologicalHash) tsort() ![]string {
	components := graph.strongly_connected_components()!
	for component in components {
		if graph.component_is_cycle(component) {
			return error('topological sort failed: cyclic graph')
		}
	}
	mut sorted := []string{}
	for component in components {
		sorted << component
	}
	return sorted
}

pub fn (graph &TopologicalHash) tsort_with_cycles(on_cycle fn([][]string)) ![]string {
	components := graph.strongly_connected_components()!
	cycles := components.filter(it.len > 1)
	if cycles.len > 0 {
		on_cycle(cycles)
	}
	mut sorted := []string{}
	for component in components {
		sorted << component
	}
	return sorted
}

pub enum TopologicalPackageKind {
	formula
	cask
}

pub struct TopologicalDependency {
pub:
	name  string
	build bool
	test  bool
}

pub struct TopologicalPackage {
pub:
	name                 string
	kind                 TopologicalPackageKind
	formula_dependencies []TopologicalDependency
	cask_dependencies    []string
}

fn graph_package_dependency_names(package TopologicalPackage) ([]string, []string) {
	formula_dependencies := if package.kind == .formula {
		package.formula_dependencies.filter(!it.build && !it.test).map(it.name)
	} else {
		package.formula_dependencies.map(it.name)
	}
	return formula_dependencies, package.cask_dependencies.clone()
}

fn graph_package_dependencies_into(packages []TopologicalPackage,
	catalog map[string]TopologicalPackage, mut accumulator TopologicalHash) ! {
	for package in packages {
		if accumulator.has(package.name) {
			continue
		}
		formula_names, cask_names := graph_package_dependency_names(package)
		mut dependencies := formula_names.clone()
		dependencies << cask_names
		accumulator.set(package.name, dependencies)
		mut formula_dependencies := []TopologicalPackage{cap: formula_names.len}
		for name in formula_names {
			if name !in catalog {
				return error('formula dependency not found: ${name}')
			}
			formula_dependencies << catalog[name]
		}
		mut cask_dependencies := []TopologicalPackage{cap: cask_names.len}
		for name in cask_names {
			if name !in catalog {
				return error('cask dependency not found: ${name}')
			}
			cask_dependencies << catalog[name]
		}
		graph_package_dependencies_into(formula_dependencies, catalog, mut accumulator)!
		graph_package_dependencies_into(cask_dependencies, catalog, mut accumulator)!
	}
}

pub fn graph_package_dependencies(packages []TopologicalPackage,
	catalog map[string]TopologicalPackage) !TopologicalHash {
	mut accumulator := new_topological_hash()
	graph_package_dependencies_into(packages, catalog, mut accumulator)!
	return accumulator
}

// Ruby method `tsort_with_cycles(&on_cycle)` at line 20.
pub fn ruby_topological_hash_l20_d1_tsort_with_cycles(graph TopologicalHash,
	on_cycle fn([][]string)) ![]string {
	return graph.tsort_with_cycles(on_cycle)
}

// Ruby method `self.graph_package_dependencies(packages, accumulator = TopologicalHash.new)` at line 46.
pub fn ruby_topological_hash_l46_d2_self_graph_package_dependencies(packages []TopologicalPackage,
	catalog map[string]TopologicalPackage) !TopologicalHash {
	return graph_package_dependencies(packages, catalog)
}

// Ruby method `tsort_each_node(&block)` at line 80.
pub fn ruby_topological_hash_l80_d3_tsort_each_node(graph TopologicalHash) []string {
	return graph.each_node()
}

// Ruby method `tsort_each_child(node, &block)` at line 85.
pub fn ruby_topological_hash_l85_d4_tsort_each_child(graph TopologicalHash,
	node string) ![]string {
	return graph.each_child(node)
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
