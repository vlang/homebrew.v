module linux

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/dependency_collector.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `gcc_dep_if_needed(related_formula_names)` at line 10.
pub fn ruby_dependency_collector_l10_d1_gcc_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gcc_dep_if_needed', ...args)
}

// Ruby method `glibc_dep_if_needed(related_formula_names)` at line 22.
pub fn ruby_dependency_collector_l22_d2_glibc_dep_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('glibc_dep_if_needed', ...args)
}

// Ruby method `global_dep_tree` at line 33.
pub fn ruby_dependency_collector_l33_d3_global_dep_tree(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('global_dep_tree', ...args)
}

// Ruby method `init_global_dep_tree_if_needed!` at line 44.
pub fn ruby_dependency_collector_l44_d4_init_global_dep_tree_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('init_global_dep_tree_if_needed!', ...args)
}

// Ruby method `formula_for(name)` at line 57.
pub fn ruby_dependency_collector_l57_d5_formula_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_for', ...args)
}

// Ruby method `global_deps_for(name)` at line 65.
pub fn ruby_dependency_collector_l65_d6_global_deps_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('global_deps_for', ...args)
}

// Ruby method `building_global_dep_tree!` at line 88.
pub fn ruby_dependency_collector_l88_d7_building_global_dep_tree(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('building_global_dep_tree!', ...args)
}

// Ruby method `built_global_dep_tree!` at line 93.
pub fn ruby_dependency_collector_l93_d8_built_global_dep_tree(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('built_global_dep_tree!', ...args)
}

// Ruby method `building_global_dep_tree?` at line 98.
pub fn ruby_dependency_collector_l98_d9_building_global_dep_tree(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('building_global_dep_tree?', ...args)
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
