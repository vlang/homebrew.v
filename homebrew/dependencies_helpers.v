module homebrew

// Translated from Homebrew/brew `dependencies_helpers.rb`.
// The original source is retained below until every stub has a typed V body.

// DependablePredicate is the typed equivalent of the predicate symbols passed
// to the Ruby helpers (for example, `:required?` and `:satisfied?`).
pub enum DependablePredicate {
	required
	recommended
	implicit
	build
	test
	optional
	satisfied
}

pub fn (predicate DependablePredicate) ruby_name() string {
	return '${predicate}?'
}

pub struct DependenciesHelperArgs {
pub:
	include_implicit bool
	include_build    bool
	include_test     bool
	include_optional bool
	skip_recommended bool
	missing          bool
}

pub struct DependenciesHelperSelection {
pub:
	includes []DependablePredicate
	ignores  []DependablePredicate
}

pub fn args_includes_ignores(options DependenciesHelperArgs) DependenciesHelperSelection {
	mut includes := [DependablePredicate.required, .recommended]
	if options.include_implicit {
		includes << .implicit
	}
	if options.include_build {
		includes << .build
	}
	if options.include_test {
		includes << .test
	}
	if options.include_optional {
		includes << .optional
	}
	mut ignores := []DependablePredicate{}
	if options.skip_recommended {
		ignores << .recommended
	}
	if options.missing {
		ignores << .satisfied
	}
	return DependenciesHelperSelection{
		includes: includes
		ignores: ignores
	}
}

pub enum DependenciesHelperDependableKind {
	dependency
	requirement
}

// DependenciesHelperDependable retains the concrete Dependency or Requirement
// while supplying the context-dependent result of `satisfied?`.
pub struct DependenciesHelperDependable {
pub:
	kind        DependenciesHelperDependableKind
	dependency  Dependency
	requirement Requirement
	satisfied   bool
}

pub fn dependency_dependable(dependency Dependency, satisfied bool) DependenciesHelperDependable {
	return DependenciesHelperDependable{
		kind: .dependency
		dependency: dependency
		satisfied: satisfied
	}
}

pub fn requirement_dependable(requirement Requirement, satisfied bool) DependenciesHelperDependable {
	return DependenciesHelperDependable{
		kind: .requirement
		requirement: requirement
		satisfied: satisfied
	}
}

fn requirement_has_symbol_tag(requirement Requirement, name string) bool {
	return requirement.tags.any(it.kind == .symbol && it.value == name)
}

fn (dependable DependenciesHelperDependable) matches(predicate DependablePredicate) bool {
	if predicate == .satisfied {
		return dependable.satisfied
	}
	return match dependable.kind {
		.dependency {
			match predicate {
				.required { dependable.dependency.required() }
				.recommended { dependable.dependency.recommended() }
				.implicit { dependable.dependency.implicit() }
				.build { dependable.dependency.build() }
				.test { dependable.dependency.test() }
				.optional { dependable.dependency.optional() }
				.satisfied { dependable.satisfied }
			}
		}
		.requirement {
			match predicate {
				.required {
					!requirement_has_symbol_tag(dependable.requirement, 'build')
						&& !requirement_has_symbol_tag(dependable.requirement, 'test')
						&& !requirement_has_symbol_tag(dependable.requirement, 'optional')
						&& !requirement_has_symbol_tag(dependable.requirement, 'recommended')
				}
				.recommended { requirement_has_symbol_tag(dependable.requirement, 'recommended') }
				.implicit { requirement_has_symbol_tag(dependable.requirement, 'implicit') }
				.build { requirement_has_symbol_tag(dependable.requirement, 'build') }
				.test { requirement_has_symbol_tag(dependable.requirement, 'test') }
				.optional { requirement_has_symbol_tag(dependable.requirement, 'optional') }
				.satisfied { dependable.satisfied }
			}
		}
	}
}

pub fn select_includes(dependables []DependenciesHelperDependable,
	ignores []DependablePredicate, includes []DependablePredicate) []DependenciesHelperDependable {
	mut selected := []DependenciesHelperDependable{}
	for dependable in dependables {
		if ignores.any(dependable.matches(it)) {
			continue
		}
		if includes.any(dependable.matches(it)) {
			selected << dependable
		}
	}
	return selected
}

pub struct DependenciesHelperDependencyEdge {
pub:
	dependency     Dependency
	satisfied      bool
	tap_installed  bool = true
	recursive_node string
}

pub struct DependenciesHelperRequirementEntry {
pub:
	requirement Requirement
	satisfied   bool
}

pub struct DependenciesHelperNode {
pub:
	name         string
	full_name    string
	class_name   string = 'Formula'
	dependencies []DependenciesHelperDependencyEdge
	requirements []DependenciesHelperRequirementEntry
}

pub struct DependenciesHelperGraph {
pub:
	nodes map[string]DependenciesHelperNode
}

pub enum DependenciesHelperRecursiveClass {
	dependency
	requirement
}

pub struct DependenciesHelperRecursiveResult {
pub:
	cache_key    string
	dependencies []Dependency
	requirements []Requirement
}

fn predicate_array_inspect(predicates []DependablePredicate) string {
	mut names := []string{cap: predicates.len}
	for predicate in predicates {
		names << ':${predicate.ruby_name()}'
	}
	return '[${names.join(', ')}]'
}

pub fn recursive_includes_cache_key(includes []DependablePredicate,
	ignores []DependablePredicate) string {
	return 'recursive_includes_${predicate_array_inspect(includes)}_${predicate_array_inspect(ignores)}'
}

fn dependable_is_included(dependable DependenciesHelperDependable, at_root bool,
	includes []DependablePredicate, ignores []DependablePredicate) bool {
	if ignores.any(dependable.matches(it)) {
		return false
	}
	for include in includes {
		// Ruby intentionally ignores a `test?` match below the root dependent.
		if include == .test && !at_root {
			continue
		}
		if dependable.matches(include) {
			return true
		}
	}
	return false
}

fn collect_recursive_dependencies(node DependenciesHelperNode, root_name string,
	graph DependenciesHelperGraph, includes []DependablePredicate,
	ignores []DependablePredicate, mut stack []string, mut result []Dependency) ! {
	stack << node.name
	defer {
		stack = stack[..stack.len - 1].clone()
	}
	for edge in node.dependencies {
		dependable := dependency_dependable(edge.dependency, edge.satisfied)
		if !dependable_is_included(dependable, node.name == root_name, includes, ignores) {
			continue
		}
		// KEEP_BUT_PRUNE_RECURSIVE_DEPS: retain an unavailable tapped formula,
		// but never attempt to resolve its children.
		if edge.dependency.tap != '' && !edge.tap_installed {
			result << edge.dependency
			continue
		}
		if edge.recursive_node == '' {
			result << edge.dependency
			continue
		}
		if edge.recursive_node in stack {
			continue
		}
		child := graph.nodes[edge.recursive_node] or {
			return error('Formula unavailable: ${edge.dependency.name}')
		}
		collect_recursive_dependencies(child, root_name, graph, includes, ignores, mut stack, mut result)!
		full_name := if child.full_name != '' { child.full_name } else { child.name }
		result << edge.dependency.duplicate_with_formula_name(full_name)
	}
}

fn append_included_requirements(node DependenciesHelperNode, at_root bool,
	includes []DependablePredicate, ignores []DependablePredicate, mut result []Requirement) {
	for entry in node.requirements {
		dependable := requirement_dependable(entry.requirement, entry.satisfied)
		if dependable_is_included(dependable, at_root, includes, ignores) {
			result << entry.requirement
		}
	}
}

fn collect_recursive_requirements(node DependenciesHelperNode, root_name string,
	graph DependenciesHelperGraph, includes []DependablePredicate,
	ignores []DependablePredicate, mut stack []string, mut result []Requirement, include_self bool) ! {
	stack << node.name
	defer {
		stack = stack[..stack.len - 1].clone()
	}
	if include_self {
		append_included_requirements(node, node.name == root_name, includes, ignores, mut result)
	}
	for edge in node.dependencies {
		if edge.recursive_node == '' || (edge.dependency.tap != '' && !edge.tap_installed)
			|| edge.recursive_node in stack {
			continue
		}
		child := graph.nodes[edge.recursive_node] or {
			return error('Formula unavailable: ${edge.dependency.name}')
		}
		// Requirement.expand visits root requirements first, followed by the
		// dependency expansion order (deepest child before its parent).
		collect_recursive_requirements(child, root_name, graph, includes, ignores, mut stack, mut result, false)!
		append_included_requirements(child, false, includes, ignores, mut result)
	}
}

pub fn recursive_includes(kind DependenciesHelperRecursiveClass, root DependenciesHelperNode,
	graph DependenciesHelperGraph, includes []DependablePredicate,
	ignores []DependablePredicate) !DependenciesHelperRecursiveResult {
	cache_key := recursive_includes_cache_key(includes, ignores)
	mut stack := []string{}
	match kind {
		.dependency {
			mut dependencies := []Dependency{}
			collect_recursive_dependencies(root, root.name, graph, includes, ignores, mut stack, mut dependencies)!
			return DependenciesHelperRecursiveResult{
				cache_key: cache_key
				dependencies: merge_repeated_dependencies(dependencies)
			}
		}
		.requirement {
			mut requirements := []Requirement{}
			collect_recursive_requirements(root, root.name, graph, includes, ignores, mut stack, mut requirements, true)!
			return DependenciesHelperRecursiveResult{
				cache_key: cache_key
				requirements: requirements
			}
		}
	}
}

pub fn recursive_dep_includes(root DependenciesHelperNode, graph DependenciesHelperGraph,
	includes []DependablePredicate, ignores []DependablePredicate) ![]Dependency {
	return (recursive_includes(.dependency, root, graph, includes, ignores)!).dependencies
}

pub fn recursive_req_includes(root DependenciesHelperNode, graph DependenciesHelperGraph,
	includes []DependablePredicate, ignores []DependablePredicate) ![]Requirement {
	return (recursive_includes(.requirement, root, graph, includes, ignores)!).requirements
}

pub enum DependenciesHelperInputKind {
	formula
	cask
	unsupported
}

pub struct DependenciesHelperDependentInput {
pub:
	kind             DependenciesHelperInputKind
	formula          Formula
	cask             CaskDependentCask
	cask_graph       CaskDependentGraph
	unsupported_type string
}

pub fn formula_dependent_input(formula Formula) DependenciesHelperDependentInput {
	return DependenciesHelperDependentInput{
		kind: .formula
		formula: formula
	}
}

pub fn cask_dependent_input(cask CaskDependentCask,
	graph CaskDependentGraph) DependenciesHelperDependentInput {
	return DependenciesHelperDependentInput{
		kind: .cask
		cask: cask
		cask_graph: graph
	}
}

pub fn unsupported_dependent_input(type_name string) DependenciesHelperDependentInput {
	return DependenciesHelperDependentInput{
		kind: .unsupported
		unsupported_type: type_name
	}
}

pub struct DependenciesHelperDependent {
pub:
	kind           DependenciesHelperInputKind
	formula        Formula
	cask_dependent CaskDependent
}

pub fn (dependent DependenciesHelperDependent) name() string {
	return match dependent.kind {
		.formula { dependent.formula.name() }
		.cask { dependent.cask_dependent.name() }
		.unsupported { '' }
	}
}

pub fn (dependent DependenciesHelperDependent) full_name() string {
	return match dependent.kind {
		.formula { dependent.formula.full_name() }
		.cask { dependent.cask_dependent.full_name() }
		.unsupported { '' }
	}
}

pub fn (dependent DependenciesHelperDependent) deps() []Dependency {
	return match dependent.kind {
		.formula { dependent.formula.deps() }
		.cask { dependent.cask_dependent.deps().map(new_dependency(it.name, []string{})) }
		.unsupported { []Dependency{} }
	}
}

pub fn (dependent DependenciesHelperDependent) runtime_dependencies() []Dependency {
	return match dependent.kind {
		.formula { dependent.formula.deps().filter(!it.build() && !it.test()) }
		.cask {
			dependent.cask_dependent.runtime_dependencies(false, false).map(new_dependency(it.name, []string{}))
		}
		.unsupported { []Dependency{} }
	}
}

pub fn (dependent DependenciesHelperDependent) requirements() []string {
	return match dependent.kind {
		.formula { dependent.formula.requirement_values.clone() }
		.cask { dependent.cask_dependent.requirements().map(it.name) }
		.unsupported { []string{} }
	}
}

pub fn (dependent DependenciesHelperDependent) recursive_dependencies() []Dependency {
	return match dependent.kind {
		.formula { dependent.formula.deps() }
		.cask {
			dependent.cask_dependent.recursive_dependencies().map(new_dependency(it.name, []string{}))
		}
		.unsupported { []Dependency{} }
	}
}

pub fn (dependent DependenciesHelperDependent) recursive_requirements() []string {
	return match dependent.kind {
		.formula { dependent.formula.requirement_values.clone() }
		.cask { dependent.cask_dependent.recursive_requirements().map(it.name) }
		.unsupported { []string{} }
	}
}

pub fn (dependent DependenciesHelperDependent) any_version_installed() bool {
	return match dependent.kind {
		.formula { dependent.formula.any_version_installed() }
		.cask { dependent.cask_dependent.any_version_installed() }
		.unsupported { false }
	}
}

pub fn (dependent DependenciesHelperDependent) responds_to(method string) bool {
	_ = dependent
	return method in ['name', 'full_name', 'runtime_dependencies', 'deps', 'requirements',
		'recursive_dependencies', 'recursive_requirements', 'any_version_installed?']
}

pub fn dependents(inputs []DependenciesHelperDependentInput) ![]DependenciesHelperDependent {
	mut result := []DependenciesHelperDependent{cap: inputs.len}
	for input in inputs {
		match input.kind {
			.formula {
				result << DependenciesHelperDependent{
					kind: .formula
					formula: input.formula
				}
			}
			.cask {
				result << DependenciesHelperDependent{
					kind: .cask
					cask_dependent: new_cask_dependent(input.cask, input.cask_graph)
				}
			}
			.unsupported {
				type_name := if input.unsupported_type != '' {
					input.unsupported_type
				} else {
					'Unknown'
				}
				return error('Unsupported type: ${type_name}')
			}
		}
	}
	return result
}

// Ruby method `args_includes_ignores(args)` at line 8.
pub fn ruby_dependencies_helpers_l8_d1_args_includes_ignores(args DependenciesHelperArgs) DependenciesHelperSelection {
	return args_includes_ignores(args)
}

// Ruby method `recursive_dep_includes(root_dependent, includes, ignores)` at line 26.
pub fn ruby_dependencies_helpers_l26_d2_recursive_dep_includes(root DependenciesHelperNode,
	graph DependenciesHelperGraph, includes []DependablePredicate,
	ignores []DependablePredicate) ![]Dependency {
	return recursive_dep_includes(root, graph, includes, ignores)
}

// Ruby method `recursive_req_includes(root_dependent, includes, ignores)` at line 34.
pub fn ruby_dependencies_helpers_l34_d3_recursive_req_includes(root DependenciesHelperNode,
	graph DependenciesHelperGraph, includes []DependablePredicate,
	ignores []DependablePredicate) ![]Requirement {
	return recursive_req_includes(root, graph, includes, ignores)
}

// Ruby method `recursive_includes(klass, root_dependent, includes, ignores)` at line 46.
pub fn ruby_dependencies_helpers_l46_d4_recursive_includes(kind DependenciesHelperRecursiveClass,
	root DependenciesHelperNode, graph DependenciesHelperGraph, includes []DependablePredicate,
	ignores []DependablePredicate) !DependenciesHelperRecursiveResult {
	return recursive_includes(kind, root, graph, includes, ignores)
}

// Ruby method `select_includes(dependables, ignores, includes)` at line 71.
pub fn ruby_dependencies_helpers_l71_d5_select_includes(dependables []DependenciesHelperDependable,
	ignores []DependablePredicate, includes []DependablePredicate) []DependenciesHelperDependable {
	return select_includes(dependables, ignores, includes)
}

// Ruby method `dependents(formulae_or_casks)` at line 83.
pub fn ruby_dependencies_helpers_l83_d6_dependents(inputs []DependenciesHelperDependentInput) ![]DependenciesHelperDependent {
	return dependents(inputs)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask_dependent"
// 5:
// 6: # Helper functions for dependencies.
// 7: module DependenciesHelpers
// 8:   def args_includes_ignores(args)
// 9:     includes = [:required?, :recommended?] # included by default
// 10:     includes << :implicit? if args.include_implicit?
// 11:     includes << :build? if args.include_build?
// 12:     includes << :test? if args.include_test?
// 13:     includes << :optional? if args.include_optional?
// 14:
// 15:     ignores = []
// 16:     ignores << :recommended? if args.skip_recommended?
// 17:     ignores << :satisfied? if args.missing?
// 18:
// 19:     [includes, ignores]
// 20:   end
// 21:
// 22:   sig {
// 23:     params(root_dependent: T.any(Formula, CaskDependent), includes: T::Array[Symbol], ignores: T::Array[Symbol])
// 24:       .returns(T::Array[Dependency])
// 25:   }
// 26:   def recursive_dep_includes(root_dependent, includes, ignores)
// 27:     T.cast(recursive_includes(Dependency, root_dependent, includes, ignores), T::Array[Dependency])
// 28:   end
// 29:
// 30:   sig {
// 31:     params(root_dependent: T.any(Formula, CaskDependent), includes: T::Array[Symbol], ignores: T::Array[Symbol])
// 32:       .returns(Requirements)
// 33:   }
// 34:   def recursive_req_includes(root_dependent, includes, ignores)
// 35:     T.cast(recursive_includes(Requirement, root_dependent, includes, ignores), Requirements)
// 36:   end
// 37:
// 38:   sig {
// 39:     params(
// 40:       klass:          T.any(T.class_of(Dependency), T.class_of(Requirement)),
// 41:       root_dependent: T.any(Formula, CaskDependent),
// 42:       includes:       T::Array[Symbol],
// 43:       ignores:        T::Array[Symbol],
// 44:     ).returns(T.any(T::Array[Dependency], Requirements))
// 45:   }
// 46:   def recursive_includes(klass, root_dependent, includes, ignores)
// 47:     cache_key = "recursive_includes_#{includes}_#{ignores}"
// 48:
// 49:     klass.expand(root_dependent, cache_key:) do |dependent, dep|
// 50:       next Dependable::PRUNE if ignores.any? { |ignore| dep.public_send(ignore) }
// 51:       next Dependable::PRUNE if includes.none? do |include|
// 52:         # Ignore indirect test dependencies
// 53:         next if include == :test? && dependent != root_dependent
// 54:
// 55:         dep.public_send(include)
// 56:       end
// 57:
// 58:       # If a tap isn't installed, we can't find the dependencies of one of
// 59:       # its formulae and an exception will be thrown if we try.
// 60:       next Dependable::KEEP_BUT_PRUNE_RECURSIVE_DEPS if klass == Dependency && (tap = dep.tap) && !tap.installed?
// 61:     end
// 62:   end
// 63:
// 64:   sig {
// 65:     params(
// 66:       dependables: T.any(Dependencies, Requirements, T::Array[Dependency], T::Array[Requirement]),
// 67:       ignores:     T::Array[Symbol],
// 68:       includes:    T::Array[Symbol],
// 69:     ).returns(T::Array[T.any(Dependency, Requirement)])
// 70:   }
// 71:   def select_includes(dependables, ignores, includes)
// 72:     dependables.select do |dep|
// 73:       next false if ignores.any? { |ignore| dep.public_send(ignore) }
// 74:
// 75:       includes.any? { |include| dep.public_send(include) }
// 76:     end
// 77:   end
// 78:
// 79:   sig {
// 80:     params(formulae_or_casks: T::Array[T.any(Formula, Keg, Cask::Cask)])
// 81:       .returns(T::Array[T.any(Formula, CaskDependent)])
// 82:   }
// 83:   def dependents(formulae_or_casks)
// 84:     formulae_or_casks.map do |formula_or_cask|
// 85:       case formula_or_cask
// 86:       when Formula then formula_or_cask
// 87:       when Cask::Cask then CaskDependent.new(formula_or_cask)
// 88:       else
// 89:         raise TypeError, "Unsupported type: #{formula_or_cask.class}"
// 90:       end
// 91:     end
// 92:   end
// 93: end
