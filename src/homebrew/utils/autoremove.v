module utils

import brew_runtime

// Translated from Homebrew/brew `utils/autoremove.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `removable_formulae(formulae, casks)` at line 15.
pub fn ruby_autoremove_l15_d1_removable_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('removable_formulae', ...args)
}

// Ruby method `cask_dependent_formula_names(casks, formulae)` at line 25.
pub fn ruby_autoremove_l25_d2_cask_dependent_formula_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_dependent_formula_names', ...args)
}

// Ruby method `bottled_formulae_with_no_formula_dependents(formulae)` at line 56.
pub fn ruby_autoremove_l56_d3_bottled_formulae_with_no_formula_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bottled_formulae_with_no_formula_dependents', ...args)
}

// Ruby method `unused_formulae_with_no_formula_dependents(formulae)` at line 94.
pub fn ruby_autoremove_l94_d4_unused_formulae_with_no_formula_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unused_formulae_with_no_formula_dependents', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   # Helper function for finding autoremovable formulae.
// 6:   #
// 7:   # @private
// 8:   module Autoremove
// 9:     class << self
// 10:       # An array of {Formula} without {Formula} or {Cask}
// 11:       # dependents that weren't installed on request and without
// 12:       # build dependencies for {Formula} installed from source.
// 13:       # @private
// 14:       sig { params(formulae: T::Array[Formula], casks: T::Array[Cask::Cask]).returns(T::Array[Formula]) }
// 15:       def removable_formulae(formulae, casks)
// 16:         unused_formulae = unused_formulae_with_no_formula_dependents(formulae)
// 17:         cask_dep_names = cask_dependent_formula_names(casks, formulae)
// 18:         unused_formulae.reject { |f| cask_dep_names.intersect?(f.possible_names) }
// 19:       end
// 20:
// 21:       # A set of names for all installed {Formula} objects that are {Cask} formula
// 22:       # dependencies (direct or transitive).
// 23:       # @private
// 24:       sig { params(casks: T::Array[Cask::Cask], formulae: T::Array[Formula]).returns(T::Set[String]) }
// 25:       def cask_dependent_formula_names(casks, formulae)
// 26:         formulae_by_name = formulae.to_h { |f| [f.name, f] }
// 27:         names = casks.flat_map { |cask| cask.depends_on.formula }.flat_map do |name|
// 28:           base = Utils.name_from_full_name(name)
// 29:           f = formulae_by_name[base]
// 30:           next [] unless f
// 31:
// 32:           tab = f.any_installed_keg&.tab
// 33:           dep_names = if (tab_deps = T.cast(tab&.runtime_dependencies,
// 34:                                             T.nilable(T::Array[T::Hash[String, T.untyped]])))
// 35:             # Use tab data to avoid Formulary.resolve for each dependency.
// 36:             tab_deps.filter_map do |dep|
// 37:               full_name = dep["full_name"]
// 38:               next unless full_name
// 39:
// 40:               Utils.name_from_full_name(full_name)
// 41:             end
// 42:           else
// 43:             # Fallback for pre-1.1.6 installations without tab runtime_dependencies.
// 44:             f.installed_runtime_formula_dependencies.map(&:name)
// 45:           end
// 46:           [base, *dep_names]
// 47:         end
// 48:         names.to_set
// 49:       end
// 50:
// 51:       # An array of all installed bottled {Formula} without runtime {Formula}
// 52:       # dependents for bottles and without build {Formula} dependents
// 53:       # for those built from source.
// 54:       # @private
// 55:       sig { params(formulae: T::Array[Formula]).returns(T::Array[Formula]) }
// 56:       def bottled_formulae_with_no_formula_dependents(formulae)
// 57:         names_to_keep = T.let(Set.new, T::Set[String])
// 58:         formulae.each do |formula|
// 59:           tab = formula.any_installed_keg&.tab
// 60:           if (tab_deps = T.cast(tab&.runtime_dependencies, T.nilable(T::Array[T::Hash[String, T.untyped]])))
// 61:             # Use tab data to avoid Formulary.resolve for each dependency.
// 62:             tab_deps.each do |dep|
// 63:               full_name = dep["full_name"]
// 64:               next unless full_name
// 65:
// 66:               names_to_keep.add(Utils.name_from_full_name(full_name))
// 67:             end
// 68:           else
// 69:             # Fallback for pre-1.1.6 installations without tab runtime_dependencies.
// 70:             formula.installed_runtime_formula_dependencies.each { |f| names_to_keep.add(f.name) }
// 71:           end
// 72:
// 73:           if tab
// 74:             # Ignore build dependencies when the formula is a bottle
// 75:             next if tab.poured_from_bottle
// 76:
// 77:             # Keep the formula if it was built from source
// 78:             names_to_keep.add(formula.name)
// 79:           end
// 80:
// 81:           formula.deps.select(&:build?).each do |dep|
// 82:             names_to_keep.add(dep.to_formula.name)
// 83:           rescue FormulaUnavailableError
// 84:             # do nothing
// 85:           end
// 86:         end
// 87:         formulae.reject { |f| names_to_keep.intersect?(f.possible_names) }
// 88:       end
// 89:
// 90:       # Recursive function that returns an array of {Formula} without
// 91:       # {Formula} dependents that weren't installed on request.
// 92:       # @private
// 93:       sig { params(formulae: T::Array[Formula]).returns(T::Array[Formula]) }
// 94:       def unused_formulae_with_no_formula_dependents(formulae)
// 95:         unused_formulae = bottled_formulae_with_no_formula_dependents(formulae).select do |f|
// 96:           tab = f.any_installed_keg&.tab
// 97:           next unless tab
// 98:           next unless tab.installed_on_request_present?
// 99:
// 100:           tab.installed_on_request == false
// 101:         end
// 102:
// 103:         unless unused_formulae.empty?
// 104:           unused_formulae += unused_formulae_with_no_formula_dependents(formulae - unused_formulae)
// 105:         end
// 106:
// 107:         unused_formulae
// 108:       end
// 109:     end
// 110:   end
// 111: end
