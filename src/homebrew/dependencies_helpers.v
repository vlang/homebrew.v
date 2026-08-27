module homebrew

import brew_runtime

// Translated from Homebrew/brew `dependencies_helpers.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `args_includes_ignores(args)` at line 8.
pub fn ruby_dependencies_helpers_l8_d1_args_includes_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('args_includes_ignores', ...args)
}

// Ruby method `recursive_dep_includes(root_dependent, includes, ignores)` at line 26.
pub fn ruby_dependencies_helpers_l26_d2_recursive_dep_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursive_dep_includes', ...args)
}

// Ruby method `recursive_req_includes(root_dependent, includes, ignores)` at line 34.
pub fn ruby_dependencies_helpers_l34_d3_recursive_req_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursive_req_includes', ...args)
}

// Ruby method `recursive_includes(klass, root_dependent, includes, ignores)` at line 46.
pub fn ruby_dependencies_helpers_l46_d4_recursive_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursive_includes', ...args)
}

// Ruby method `select_includes(dependables, ignores, includes)` at line 71.
pub fn ruby_dependencies_helpers_l71_d5_select_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('select_includes', ...args)
}

// Ruby method `dependents(formulae_or_casks)` at line 83.
pub fn ruby_dependencies_helpers_l83_d6_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependents', ...args)
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
