module homebrew

import ruby

// Translated from Homebrew/brew `installed_dependents.rb`.

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
	return '${installed_source_tap(tap)}\x00${name}'
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

pub fn installed_dependent_keg_value(keg InstalledDependentKeg) ruby.Value {
	return ruby.structured_value('Keg', keg.id, {
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

fn installed_dependent_keg_from_value(value ruby.Value) InstalledDependentKeg {
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

fn installed_dependency_value(dependency InstalledDependentDependency) ruby.Value {
	return ruby.structured_value('Dependency', dependency.full_name, {
		'full_name': dependency.full_name
		'tap':       dependency.tap
	})
}

fn installed_dependency_from_value(value ruby.Value) InstalledDependentDependency {
	return InstalledDependentDependency{
		full_name: value.attributes['full_name'] or { value.repr }
		tap: value.attributes['tap'] or { '' }
	}
}

pub fn installed_dependent_formula_value(formula InstalledDependentFormula) ruby.Value {
	return ruby.Value{
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

fn installed_dependent_formula_from_value(value ruby.Value) InstalledDependentFormula {
	return InstalledDependentFormula{
		name: value.attributes['name'] or { value.repr }
		tap: value.attributes['tap'] or { '' }
		display_name: value.attributes['display_name'] or { value.repr }
		has_runtime_dependencies: (value.attributes['has_runtime_dependencies'] or { 'false' }).bool()
		reliable_tab: (value.attributes['reliable_tab'] or { 'false' }).bool()
		runtime_dependencies: value.array_data.map(installed_dependency_from_value(it))
	}
}

pub fn installed_dependent_cask_value(cask InstalledDependentCask) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Cask'
		repr: if cask.display_name == '' { cask.token } else { cask.display_name }
		attributes: {
			'token':        cask.token
			'display_name': cask.display_name
		}
		array_data: cask.runtime_dependencies.map(installed_dependency_value(it))
	}
}

fn installed_dependent_cask_from_value(value ruby.Value) InstalledDependentCask {
	return InstalledDependentCask{
		token: value.attributes['token'] or { value.repr }
		display_name: value.attributes['display_name'] or { value.repr }
		runtime_dependencies: value.array_data.map(installed_dependency_from_value(it))
	}
}

pub fn installed_dependents_context_value(context InstalledDependentsContext) ruby.Value {
	return ruby.Value{
		type_name: 'InstalledDependents::Context'
		repr: 'installed dependents context'
		map_data: {
			'kegs':               ruby.array_value(context.kegs.map(installed_dependent_keg_value(it)))
			'installed_formulae': ruby.array_value(context.installed_formulae.map(installed_dependent_formula_value(it)))
			'installed_casks':    ruby.array_value(context.installed_casks.map(installed_dependent_cask_value(it)))
			'excluded_casks':     ruby.string_array_value(context.excluded_casks)
		}
	}
}

fn installed_dependents_context_from_value(value ruby.Value) !InstalledDependentsContext {
	if value.type_name != 'InstalledDependents::Context' {
		return error('expected InstalledDependents::Context')
	}
	values := value.map_data.clone()
	return InstalledDependentsContext{
		kegs: (values['kegs'] or { ruby.array_value([]) }).as_array()!.map(installed_dependent_keg_from_value(it))
		installed_formulae: (values['installed_formulae'] or { ruby.array_value([]) }).as_array()!.map(installed_dependent_formula_from_value(it))
		installed_casks: (values['installed_casks'] or { ruby.array_value([]) }).as_array()!.map(installed_dependent_cask_from_value(it))
		excluded_casks: (values['excluded_casks'] or { ruby.string_array_value([]) }).as_string_array()!
	}
}
