module homebrew

import brew_runtime

// Translated from Homebrew/brew `installed_dependents.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `find_some_installed_dependents(kegs, casks: [])` at line 26.
pub fn ruby_installed_dependents_l26_d1_find_some_installed_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('find_some_installed_dependents', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask_dependent"
// 5:
// 6: # Helper functions for installed dependents.
// 7: module InstalledDependents
// 8:   module_function
// 9:
// 10:   # Given an array of kegs, this method will try to find some other kegs
// 11:   # or casks that depend on them. If it does, it returns:
// 12:   #
// 13:   # - some kegs in the passed array that have installed dependents
// 14:   # - some installed dependents of those kegs.
// 15:   #
// 16:   # If it doesn't, it returns nil.
// 17:   #
// 18:   # Note that nil will be returned if the only installed dependents of the
// 19:   # passed kegs are other kegs in the array or casks present in the casks
// 20:   # parameter.
// 21:   #
// 22:   # For efficiency, we don't bother trying to get complete data.
// 23:   sig {
// 24:     params(kegs: T::Array[Keg], casks: T::Array[Cask::Cask]).returns(T.nilable([T::Array[Keg], T::Array[String]]))
// 25:   }
// 26:   def find_some_installed_dependents(kegs, casks: [])
// 27:     keg_names = kegs.select(&:optlinked?).map(&:name)
// 28:     keg_formulae = []
// 29:     kegs_by_source = kegs.group_by do |keg|
// 30:       # First, attempt to resolve the keg to a formula
// 31:       # to get up-to-date name and tap information.
// 32:       f = keg.to_formula
// 33:       keg_formulae << f
// 34:       [f.name, f.tap]
// 35:     rescue
// 36:       # If the formula for the keg can't be found,
// 37:       # fall back to the information in the tab.
// 38:       [keg.name, keg.tab.tap]
// 39:     end
// 40:
// 41:     all_required_kegs = Set.new
// 42:     all_dependents = []
// 43:
// 44:     # Don't include dependencies of kegs that were in the given array.
// 45:     dependents_to_check = (Formula.installed - keg_formulae) + (Cask::Caskroom.casks - casks)
// 46:
// 47:     dependents_to_check.each do |dependent|
// 48:       required = case dependent
// 49:       when Formula
// 50:         dependent.missing_dependencies(hide: keg_names).filter_map do |d|
// 51:           d.to_installed_formula
// 52:         rescue FormulaUnavailableError
// 53:           nil
// 54:         end
// 55:       when Cask::Cask
// 56:         # When checking for cask dependents, we don't care about missing or non-runtime dependencies
// 57:         CaskDependent.new(dependent).runtime_dependencies.map(&:to_installed_formula)
// 58:       end
// 59:
// 60:       required_kegs = required.filter_map do |f|
// 61:         f_kegs = kegs_by_source[[f.name, f.tap]]
// 62:         next unless f_kegs
// 63:
// 64:         f_kegs.max_by(&:scheme_and_version)
// 65:       end
// 66:
// 67:       next if required_kegs.empty?
// 68:
// 69:       all_required_kegs += required_kegs
// 70:       all_dependents << dependent.to_s
// 71:     end
// 72:
// 73:     return if all_required_kegs.empty?
// 74:     return if all_dependents.empty?
// 75:
// 76:     [all_required_kegs.to_a, all_dependents.sort]
// 77:   end
// 78: end
