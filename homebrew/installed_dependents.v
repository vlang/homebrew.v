module homebrew

import brew_runtime

// Translated from Homebrew/brew `installed_dependents.rb`.
// The original source is retained below until every stub has a typed V body.

// InstalledDependentDependency is the portion of an installed formula receipt
// needed by InstalledDependents. A blank tap denotes the core tap, just as an
// unqualified `full_name` in a Homebrew Tab does.
pub struct InstalledDependentDependency {
pub:
	full_name string
	tap       string
}

// InstalledDependentKeg carries both the on-disk keg identity and the source
// identity Homebrew obtains from Formula#to_formula (or, when that fails, its
// Tab). Keeping the two identities separate is important for renamed formulae.
pub struct InstalledDependentKeg {
pub:
	id               string
	name             string
	version          string
	version_scheme   int
	optlinked        bool
	formula_resolved bool
	formula_name     string
	formula_tap      string
	tab_tap          string
}

pub struct InstalledDependentFormula {
pub:
	name                     string
	tap                      string
	display_name             string
	runtime_dependencies     []InstalledDependentDependency
	has_runtime_dependencies bool
	reliable_tab             bool
}

pub struct InstalledDependentCask {
pub:
	token                string
	display_name         string
	runtime_dependencies []InstalledDependentDependency
}

pub struct InstalledDependentsContext {
pub:
	kegs               []InstalledDependentKeg
	installed_formulae []InstalledDependentFormula
	installed_casks    []InstalledDependentCask
	excluded_casks     []string
}

pub struct InstalledDependentsResult {
pub:
	required_kegs []InstalledDependentKeg
	dependents    []string
}

fn installed_source_tap(tap string) string {
	return if tap == '' { 'homebrew/core' } else { tap }
}

fn installed_source_key(name string, tap string) string {
	return '${installed_source_tap(tap)}\0${name}'
}

fn installed_keg_source(keg InstalledDependentKeg) (string, string) {
	if keg.formula_resolved {
		name := if keg.formula_name == '' { keg.name } else { keg.formula_name }
		return name, installed_source_tap(keg.formula_tap)
	}
	return keg.name, installed_source_tap(keg.tab_tap)
}

fn installed_dependency_source(dependency InstalledDependentDependency) (string, string) {
	parts := dependency.full_name.split('/')
	if parts.len >= 3 {
		return parts.last(), parts[..parts.len - 1].join('/')
	}
	return dependency.full_name, installed_source_tap(dependency.tap)
}

fn compare_installed_keg_versions(left InstalledDependentKeg,
	right InstalledDependentKeg) int {
	if left.version_scheme != right.version_scheme {
		return if left.version_scheme < right.version_scheme { -1 } else { 1 }
	}
	left_version := new_version(left.version) or {
		return if left.version < right.version {
			-1
		} else if left.version > right.version { 1 } else { 0 }
	}
	right_version := new_version(right.version) or { return 1 }
	return left_version.compare_to(right_version)
}

fn dependency_matches_kegs(dependency InstalledDependentDependency,
	kegs_by_source map[string][]InstalledDependentKeg) []InstalledDependentKeg {
	name, tap := installed_dependency_source(dependency)
	matching := kegs_by_source[installed_source_key(name, tap)] or { return [] }
	if matching.len == 0 {
		return []
	}
	mut newest := matching[0]
	for keg in matching[1..] {
		if compare_installed_keg_versions(keg, newest) > 0 {
			newest = keg
		}
	}
	return [newest]
}

fn formula_dependency_matches_kegs(dependency InstalledDependentDependency,
	kegs_by_source map[string][]InstalledDependentKeg) []InstalledDependentKeg {
	name, tap := installed_dependency_source(dependency)
	matching := kegs_by_source[installed_source_key(name, tap)] or { return [] }
	// `missing_dependencies(hide:)` receives every opt-linked target keg name,
	// not just the newest keg that is ultimately returned. Renamed racks can
	// likewise resolve to the dependency's current source identity.
	if !matching.any(it.optlinked || (it.formula_name != '' && it.formula_name != it.name)) {
		return []
	}
	return dependency_matches_kegs(dependency, kegs_by_source)
}

// find_some_installed_dependents implements the source algorithm against an
// explicit snapshot of installed formulae and casks. The snapshot replaces the
// Homebrew global registries and makes graph traversal deterministic and testable.
pub fn find_some_installed_dependents(context InstalledDependentsContext) ?InstalledDependentsResult {
	mut kegs_by_source := map[string][]InstalledDependentKeg{}
	mut target_formulae := map[string]bool{}
	for keg in context.kegs {
		name, tap := installed_keg_source(keg)
		key := installed_source_key(name, tap)
		kegs_by_source[key] << keg
		if keg.formula_resolved {
			target_formulae[key] = true
		}
	}

	mut required_by_id := map[string]InstalledDependentKeg{}
	mut required_order := []string{}
	mut dependents := []string{}
	for formula in context.installed_formulae {
		formula_key := installed_source_key(formula.name, formula.tap)
		if formula_key in target_formulae || !formula.has_runtime_dependencies || !formula.reliable_tab {
			continue
		}
		mut required := []InstalledDependentKeg{}
		for dependency in formula.runtime_dependencies {
			required << formula_dependency_matches_kegs(dependency, kegs_by_source)
		}
		if required.len == 0 {
			continue
		}
		for keg in required {
			if keg.id !in required_by_id {
				required_order << keg.id
			}
			required_by_id[keg.id] = keg
		}
		dependents << if formula.display_name == '' { formula.name } else { formula.display_name }
	}

	for cask in context.installed_casks {
		if cask.token in context.excluded_casks {
			continue
		}
		mut required := []InstalledDependentKeg{}
		for dependency in cask.runtime_dependencies {
			required << dependency_matches_kegs(dependency, kegs_by_source)
		}
		if required.len == 0 {
			continue
		}
		for keg in required {
			if keg.id !in required_by_id {
				required_order << keg.id
			}
			required_by_id[keg.id] = keg
		}
		dependents << if cask.display_name == '' { cask.token } else { cask.display_name }
	}

	if required_by_id.len == 0 || dependents.len == 0 {
		return none
	}
	required_kegs := required_order.map(required_by_id[it])
	dependents.sort()
	return InstalledDependentsResult{
		required_kegs: required_kegs
		dependents: dependents
	}
}

pub fn installed_dependent_keg_value(keg InstalledDependentKeg) brew_runtime.Value {
	return brew_runtime.structured_value('Keg', keg.id, {
		'id':               keg.id
		'name':             keg.name
		'version':          keg.version
		'version_scheme':   keg.version_scheme.str()
		'optlinked':        keg.optlinked.str()
		'formula_resolved': keg.formula_resolved.str()
		'formula_name':     keg.formula_name
		'formula_tap':      keg.formula_tap
		'tab_tap':          keg.tab_tap
	})
}

fn installed_dependent_keg_from_value(value brew_runtime.Value) InstalledDependentKeg {
	return InstalledDependentKeg{
		id: value.attributes['id'] or { value.repr }
		name: value.attributes['name'] or { value.repr }
		version: value.attributes['version'] or { '0' }
		version_scheme: (value.attributes['version_scheme'] or { '0' }).int()
		optlinked: (value.attributes['optlinked'] or { 'false' }).bool()
		formula_resolved: (value.attributes['formula_resolved'] or { 'false' }).bool()
		formula_name: value.attributes['formula_name'] or { '' }
		formula_tap: value.attributes['formula_tap'] or { '' }
		tab_tap: value.attributes['tab_tap'] or { '' }
	}
}

fn installed_dependency_value(dependency InstalledDependentDependency) brew_runtime.Value {
	return brew_runtime.structured_value('Dependency', dependency.full_name, {
		'full_name': dependency.full_name
		'tap':       dependency.tap
	})
}

fn installed_dependency_from_value(value brew_runtime.Value) InstalledDependentDependency {
	return InstalledDependentDependency{
		full_name: value.attributes['full_name'] or { value.repr }
		tap: value.attributes['tap'] or { '' }
	}
}

pub fn installed_dependent_formula_value(formula InstalledDependentFormula) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Formula'
		repr: if formula.display_name == '' { formula.name } else { formula.display_name }
		attributes: {
			'name':                     formula.name
			'tap':                      formula.tap
			'display_name':             formula.display_name
			'has_runtime_dependencies': formula.has_runtime_dependencies.str()
			'reliable_tab':             formula.reliable_tab.str()
		}
		array_data: formula.runtime_dependencies.map(installed_dependency_value(it))
	}
}

fn installed_dependent_formula_from_value(value brew_runtime.Value) InstalledDependentFormula {
	return InstalledDependentFormula{
		name: value.attributes['name'] or { value.repr }
		tap: value.attributes['tap'] or { '' }
		display_name: value.attributes['display_name'] or { value.repr }
		has_runtime_dependencies: (value.attributes['has_runtime_dependencies'] or { 'false' }).bool()
		reliable_tab: (value.attributes['reliable_tab'] or { 'false' }).bool()
		runtime_dependencies: value.array_data.map(installed_dependency_from_value(it))
	}
}

pub fn installed_dependent_cask_value(cask InstalledDependentCask) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Cask::Cask'
		repr: if cask.display_name == '' { cask.token } else { cask.display_name }
		attributes: {
			'token':        cask.token
			'display_name': cask.display_name
		}
		array_data: cask.runtime_dependencies.map(installed_dependency_value(it))
	}
}

fn installed_dependent_cask_from_value(value brew_runtime.Value) InstalledDependentCask {
	return InstalledDependentCask{
		token: value.attributes['token'] or { value.repr }
		display_name: value.attributes['display_name'] or { value.repr }
		runtime_dependencies: value.array_data.map(installed_dependency_from_value(it))
	}
}

pub fn installed_dependents_context_value(context InstalledDependentsContext) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'InstalledDependents::Context'
		repr: 'installed dependents context'
		map_data: {
			'kegs':               brew_runtime.array_value(context.kegs.map(installed_dependent_keg_value(it)))
			'installed_formulae': brew_runtime.array_value(context.installed_formulae.map(installed_dependent_formula_value(it)))
			'installed_casks':    brew_runtime.array_value(context.installed_casks.map(installed_dependent_cask_value(it)))
			'excluded_casks':     brew_runtime.string_array_value(context.excluded_casks)
		}
	}
}

fn installed_dependents_context_from_value(value brew_runtime.Value) !InstalledDependentsContext {
	if value.type_name != 'InstalledDependents::Context' {
		return error('expected InstalledDependents::Context')
	}
	values := value.map_data.clone()
	return InstalledDependentsContext{
		kegs: (values['kegs'] or { brew_runtime.array_value([]) }).as_array()!.map(installed_dependent_keg_from_value(it))
		installed_formulae: (values['installed_formulae'] or { brew_runtime.array_value([]) }).as_array()!.map(installed_dependent_formula_from_value(it))
		installed_casks: (values['installed_casks'] or { brew_runtime.array_value([]) }).as_array()!.map(installed_dependent_cask_from_value(it))
		excluded_casks: (values['excluded_casks'] or { brew_runtime.string_array_value([]) }).as_string_array()!
	}
}

// Ruby method `find_some_installed_dependents(kegs, casks: [])` at line 26.
pub fn ruby_installed_dependents_l26_d1_find_some_installed_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'installed dependents context is required')
	}
	context := installed_dependents_context_from_value(args[0]) or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	result := find_some_installed_dependents(context) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.array_value([
		brew_runtime.array_value(result.required_kegs.map(installed_dependent_keg_value(it))),
		brew_runtime.string_array_value(result.dependents),
	])
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
