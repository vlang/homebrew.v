module utils

// Translated from Homebrew/brew `utils/topological_hash.rb`.
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

pub fn (graph &TopologicalHash) tsort_with_cycles(on_cycle fn ([][]string)) ![]string {
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
