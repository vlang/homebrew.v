module linux

import ruby

pub const linux_dependency_collector_glibc = 'glibc'
pub const linux_dependency_collector_gcc = 'gcc'

// LinuxCollectorDependency retains the dependency predicates used while walking
// the global GCC/glibc trees. A test dependency is ignored unless it is also a
// build dependency, matching Dependency#test? && !Dependency#build? in Ruby.
pub struct LinuxCollectorDependency {
pub:
	name string
	tags []string
}

pub fn (dependency LinuxCollectorDependency) test() bool {
	return ':test' in dependency.tags || 'test' in dependency.tags
}

pub fn (dependency LinuxCollectorDependency) build() bool {
	return ':build' in dependency.tags || 'build' in dependency.tags
}

pub struct LinuxCollectorFormula {
pub:
	name string
	deps []LinuxCollectorDependency
}

// LinuxDependencyCollectorState makes Ruby's class-level tree and instance
// memoization explicit. Callers that need class-variable sharing retain and pass
// the same state pointer to each translated collector boundary.
pub struct LinuxDependencyCollectorState {
pub:
	needs_build_formulae bool
	needs_libc_formula   bool
	gcc_formula          string = linux_dependency_collector_gcc
	formulae             map[string]LinuxCollectorFormula
pub mut:
	global_dep_tree          map[string][]string
	building_global_dep_tree bool
	formula_cache            map[string]LinuxCollectorFormula
	global_deps_cache        map[string][]string
	resolving_formulae       []string
}

pub fn new_linux_dependency_collector(needs_build_formulae bool, needs_libc_formula bool,
	formulae map[string]LinuxCollectorFormula) &LinuxDependencyCollectorState {
	mut collector := &LinuxDependencyCollectorState{
		needs_build_formulae: needs_build_formulae
		needs_libc_formula: needs_libc_formula
		formulae: formulae.clone()
	}
	collector.init_global_dep_tree_if_needed()
	return collector
}

pub fn (mut collector LinuxDependencyCollectorState) formula_for(name string) ?LinuxCollectorFormula {
	if name in collector.formula_cache {
		return collector.formula_cache[name]
	}
	if name !in collector.formulae {
		return none
	}
	formula := collector.formulae[name]
	collector.formula_cache[name] = formula
	return formula
}

fn linux_dependency_collector_append_unique(mut values []string, additions []string) {
	for addition in additions {
		if addition !in values {
			values << addition
		}
	}
}

pub fn (mut collector LinuxDependencyCollectorState) global_deps_for(name string) []string {
	if name in collector.global_deps_cache {
		return collector.global_deps_cache[name].clone()
	}
	// Homebrew rejects circular formula dependencies elsewhere. Keeping a local
	// recursion guard makes this boundary total when used independently.
	if name in collector.resolving_formulae {
		return []string{}
	}
	collector.resolving_formulae << name
	formula := collector.formula_for(name) or {
		collector.resolving_formulae.delete(collector.resolving_formulae.len - 1)
		collector.global_deps_cache[name] = []string{}
		return []string{}
	}
	mut dependencies := []string{}
	for dependency in formula.deps {
		if dependency.test() && !dependency.build() {
			continue
		}
		linux_dependency_collector_append_unique(mut dependencies, [dependency.name])
		transitive := collector.global_deps_for(dependency.name)
		linux_dependency_collector_append_unique(mut dependencies, transitive)
	}
	collector.resolving_formulae.delete(collector.resolving_formulae.len - 1)
	collector.global_deps_cache[name] = dependencies.clone()
	return dependencies
}

pub fn (mut collector LinuxDependencyCollectorState) building_global_dep_tree_start() {
	collector.building_global_dep_tree = true
}

pub fn (mut collector LinuxDependencyCollectorState) building_global_dep_tree_finish() {
	collector.building_global_dep_tree = false
}

pub fn (collector LinuxDependencyCollectorState) is_building_global_dep_tree() bool {
	return collector.building_global_dep_tree
}

pub fn (mut collector LinuxDependencyCollectorState) init_global_dep_tree_if_needed() {
	if collector.is_building_global_dep_tree() || !collector.needs_build_formulae {
		return
	}
	gcc := if collector.gcc_formula == '' {
		linux_dependency_collector_gcc
	} else {
		collector.gcc_formula
	}
	if linux_dependency_collector_glibc in collector.global_dep_tree
		&& gcc in collector.global_dep_tree {
		return
	}
	collector.building_global_dep_tree_start()
	glibc_dependencies := collector.global_deps_for(linux_dependency_collector_glibc)
	collector.global_dep_tree[linux_dependency_collector_glibc] = glibc_dependencies.clone()
	mut gcc_dependencies := collector.global_deps_for(gcc)
	linux_dependency_collector_append_unique(mut gcc_dependencies, [
		linux_dependency_collector_glibc,
	])
	linux_dependency_collector_append_unique(mut gcc_dependencies, glibc_dependencies)
	collector.global_dep_tree[gcc] = gcc_dependencies
	collector.building_global_dep_tree_finish()
}

fn linux_dependency_collector_intersects(values []string, related []string) bool {
	return values.any(it in related)
}

pub fn (mut collector LinuxDependencyCollectorState) gcc_dep_if_needed(related_formula_names []string) ?LinuxCollectorDependency {
	if !collector.needs_build_formulae || collector.is_building_global_dep_tree() {
		return none
	}
	gcc := if collector.gcc_formula == '' {
		linux_dependency_collector_gcc
	} else {
		collector.gcc_formula
	}
	if gcc in related_formula_names {
		return none
	}
	if gcc in collector.global_dep_tree
		&& linux_dependency_collector_intersects(collector.global_dep_tree[gcc], related_formula_names) {
		return none
	}
	collector.formula_for(gcc) or { return none }
	return LinuxCollectorDependency{
		name: gcc
		tags: [':implicit']
	}
}

pub fn (mut collector LinuxDependencyCollectorState) glibc_dep_if_needed(related_formula_names []string) ?LinuxCollectorDependency {
	if !collector.needs_libc_formula || collector.is_building_global_dep_tree() {
		return none
	}
	if linux_dependency_collector_glibc in related_formula_names {
		return none
	}
	if linux_dependency_collector_glibc in collector.global_dep_tree
		&& linux_dependency_collector_intersects(collector.global_dep_tree[linux_dependency_collector_glibc], related_formula_names) {
		return none
	}
	collector.formula_for(linux_dependency_collector_glibc) or { return none }
	return LinuxCollectorDependency{
		name: linux_dependency_collector_glibc
		tags: [':implicit']
	}
}

pub fn linux_dependency_collector_value(collector &LinuxDependencyCollectorState) ruby.Value {
	return ruby.structured_value('LinuxDependencyCollector', 'DependencyCollector', {
		'collector_address': u64(voidptr(collector)).str()
	})
}

fn linux_dependency_collector_from_value(value ruby.Value) &LinuxDependencyCollectorState {
	address := value.attributes['collector_address'] or { panic('invalid LinuxDependencyCollector') }
	return unsafe { &LinuxDependencyCollectorState(voidptr(address.u64())) }
}

fn linux_dependency_collector_from_args(args []ruby.Value) (&LinuxDependencyCollectorState, int) {
	if args.len > 0 && args[0].type_name == 'LinuxDependencyCollector' {
		return linux_dependency_collector_from_value(args[0]), 1
	}
	return new_linux_dependency_collector(false, false, map[string]LinuxCollectorFormula{}), 0
}

fn linux_dependency_collector_names(value ruby.Value) []string {
	if value.type_name == 'Array' {
		return value.as_array() or { [] }.map(it.as_string())
	}
	if value.type_name in ['String', 'Symbol'] {
		return [value.as_string()]
	}
	return []string{}
}

fn linux_collector_dependency_value(dependency LinuxCollectorDependency) ruby.Value {
	return ruby.structured_value('Dependency', dependency.name, {
		'name': dependency.name
		'tags': dependency.tags.join(',')
	})
}

fn linux_collector_formula_value(formula LinuxCollectorFormula) ruby.Value {
	return ruby.structured_value('Formula', formula.name, {
		'name': formula.name
		'deps': formula.deps.map(it.name).join(',')
	})
}

fn linux_global_dep_tree_value(tree map[string][]string) ruby.Value {
	mut values := map[string]ruby.Value{}
	for name, dependencies in tree {
		values[name] = ruby.string_array_value(dependencies)
	}
	return ruby.map_value(values)
}

// Translated from Homebrew/brew `extend/os/linux/dependency_collector.rb`.
