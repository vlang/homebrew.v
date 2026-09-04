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
// The original source is retained below until every stub has a typed V body.

// Ruby method `gcc_dep_if_needed(related_formula_names)` at line 10.
pub fn ruby_dependency_collector_l10_d1_gcc_dep_if_needed(args ...ruby.Value) ruby.Value {
	mut collector, offset := linux_dependency_collector_from_args(args)
	related := if args.len > offset {
		linux_dependency_collector_names(args[offset])
	} else {
		[]string{}
	}
	if dependency := collector.gcc_dep_if_needed(related) {
		return linux_collector_dependency_value(dependency)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `glibc_dep_if_needed(related_formula_names)` at line 22.
pub fn ruby_dependency_collector_l22_d2_glibc_dep_if_needed(args ...ruby.Value) ruby.Value {
	mut collector, offset := linux_dependency_collector_from_args(args)
	related := if args.len > offset {
		linux_dependency_collector_names(args[offset])
	} else {
		[]string{}
	}
	if dependency := collector.glibc_dep_if_needed(related) {
		return linux_collector_dependency_value(dependency)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `global_dep_tree` at line 33.
pub fn ruby_dependency_collector_l33_d3_global_dep_tree(args ...ruby.Value) ruby.Value {
	collector, _ := linux_dependency_collector_from_args(args)
	return linux_global_dep_tree_value(collector.global_dep_tree)
}

// Ruby method `init_global_dep_tree_if_needed!` at line 44.
pub fn ruby_dependency_collector_l44_d4_init_global_dep_tree_if_needed(args ...ruby.Value) ruby.Value {
	mut collector, _ := linux_dependency_collector_from_args(args)
	collector.init_global_dep_tree_if_needed()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `formula_for(name)` at line 57.
pub fn ruby_dependency_collector_l57_d5_formula_for(args ...ruby.Value) ruby.Value {
	mut collector, offset := linux_dependency_collector_from_args(args)
	if args.len <= offset {
		panic('formula_for requires a name')
	}
	if formula := collector.formula_for(args[offset].as_string()) {
		return linux_collector_formula_value(formula)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `global_deps_for(name)` at line 65.
pub fn ruby_dependency_collector_l65_d6_global_deps_for(args ...ruby.Value) ruby.Value {
	mut collector, offset := linux_dependency_collector_from_args(args)
	if args.len <= offset {
		panic('global_deps_for requires a name')
	}
	return ruby.string_array_value(collector.global_deps_for(args[offset].as_string()))
}

// Ruby method `building_global_dep_tree!` at line 88.
pub fn ruby_dependency_collector_l88_d7_building_global_dep_tree(args ...ruby.Value) ruby.Value {
	mut collector, _ := linux_dependency_collector_from_args(args)
	collector.building_global_dep_tree_start()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `built_global_dep_tree!` at line 93.
pub fn ruby_dependency_collector_l93_d8_built_global_dep_tree(args ...ruby.Value) ruby.Value {
	mut collector, _ := linux_dependency_collector_from_args(args)
	collector.building_global_dep_tree_finish()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `building_global_dep_tree?` at line 98.
pub fn ruby_dependency_collector_l98_d9_building_global_dep_tree(args ...ruby.Value) ruby.Value {
	collector, _ := linux_dependency_collector_from_args(args)
	return ruby.bool_value(collector.is_building_global_dep_tree())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/linux/glibc"
// 5:
// 6: module OS
// 7:   module Linux
// 8:     module DependencyCollector
// 9:       sig { params(related_formula_names: T::Set[String]).returns(T.nilable(Dependency)) }
// 10:       def gcc_dep_if_needed(related_formula_names)
// 11:         # gcc is required for libgcc_s.so.1 if glibc or gcc are too old
// 12:         return unless ::DevelopmentTools.needs_build_formulae?
// 13:         return if building_global_dep_tree?
// 14:         return if related_formula_names.include?(GCC)
// 15:         return if global_dep_tree[GCC]&.intersect?(related_formula_names)
// 16:         return unless formula_for(GCC)
// 17:
// 18:         Dependency.new(GCC, [:implicit])
// 19:       end
// 20:
// 21:       sig { params(related_formula_names: T::Set[String]).returns(T.nilable(Dependency)) }
// 22:       def glibc_dep_if_needed(related_formula_names)
// 23:         return unless ::DevelopmentTools.needs_libc_formula?
// 24:         return if building_global_dep_tree?
// 25:         return if related_formula_names.include?(GLIBC)
// 26:         return if global_dep_tree[GLIBC]&.intersect?(related_formula_names)
// 27:         return unless formula_for(GLIBC)
// 28:
// 29:         Dependency.new(GLIBC, [:implicit])
// 30:       end
// 31:
// 32:       sig { returns(T::Hash[String, T::Set[String]]) }
// 33:       def global_dep_tree
// 34:         @@global_dep_tree
// 35:       end
// 36:
// 37:       private
// 38:
// 39:       GLIBC = "glibc"
// 40:       GCC = OS::LINUX_PREFERRED_GCC_RUNTIME_FORMULA
// 41:       private_constant :GLIBC, :GCC
// 42:
// 43:       sig { void }
// 44:       def init_global_dep_tree_if_needed!
// 45:         return if building_global_dep_tree?
// 46:         return unless ::DevelopmentTools.needs_build_formulae?
// 47:         return if global_dep_tree.key?(GLIBC) && global_dep_tree.key?(GCC)
// 48:
// 49:         building_global_dep_tree!
// 50:         global_dep_tree[GLIBC] = Set.new(global_deps_for(GLIBC))
// 51:         # gcc depends on glibc
// 52:         global_dep_tree[GCC] = Set.new([*global_deps_for(GCC), GLIBC, *@@global_dep_tree[GLIBC]])
// 53:         built_global_dep_tree!
// 54:       end
// 55:
// 56:       sig { params(name: String).returns(T.nilable(::Formula)) }
// 57:       def formula_for(name)
// 58:         @formula_for ||= T.let({}, T.nilable(T::Hash[String, ::Formula]))
// 59:         @formula_for[name] ||= ::Formula[name]
// 60:       rescue FormulaUnavailableError
// 61:         nil
// 62:       end
// 63:
// 64:       sig { params(name: String).returns(T::Array[String]) }
// 65:       def global_deps_for(name)
// 66:         @global_deps_for ||= T.let({}, T.nilable(T::Hash[String, T::Array[String]]))
// 67:         # Always strip out glibc and gcc from all parts of dependency tree when
// 68:         # we're calculating their dependency trees. Other parts of Homebrew will
// 69:         # catch any circular dependencies.
// 70:         @global_deps_for[name] ||= if (formula = formula_for(name))
// 71:           formula.deps.filter_map do |dep|
// 72:             next if dep.test? && !dep.build?
// 73:
// 74:             [dep.name, *global_deps_for(dep.name)].compact
// 75:           end.flatten.uniq
// 76:         else
// 77:           []
// 78:         end
// 79:       end
// 80:
// 81:       # Use class variables to avoid this expensive logic needing to be done more
// 82:       # than once.
// 83:       # rubocop:disable Style/ClassVars
// 84:       @@global_dep_tree = T.let({}, T::Hash[String, T::Set[String]])
// 85:       @@building_global_dep_tree = T.let(false, T::Boolean)
// 86:
// 87:       sig { void }
// 88:       def building_global_dep_tree!
// 89:         @@building_global_dep_tree = true
// 90:       end
// 91:
// 92:       sig { void }
// 93:       def built_global_dep_tree!
// 94:         @@building_global_dep_tree = false
// 95:       end
// 96:
// 97:       sig { returns(T::Boolean) }
// 98:       def building_global_dep_tree?
// 99:         @@building_global_dep_tree.present?
// 100:       end
// 101:       # rubocop:enable Style/ClassVars
// 102:     end
// 103:   end
// 104: end
// 105:
// 106: DependencyCollector.prepend(OS::Linux::DependencyCollector)
