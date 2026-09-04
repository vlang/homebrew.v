module homebrew

import ruby
import homebrew.utils
import os

// Translated from Homebrew/brew `linkage_checker.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct LinkageFile {
pub:
	path                         string
	dynamically_linked_libraries []string
	rpaths                       []string
	dylib                        bool
	binary_executable            bool
	mach_o_bundle                bool
	arch_compatible              bool = true
}

pub struct LinkageOwner {
pub:
	name string
	tap  string
}

pub struct LinkageCheckerConfig {
pub:
	files                    []LinkageFile
	owners                   map[string]LinkageOwner
	cached_keg_files_dylibs  map[string][]string
	shared_cache_dylibs      []string
	formula_dependencies     []Dependency
	recursive_dependencies   []string
	dependencies_with_bin    []string
	dependencies_without_bin []string
}

pub struct LinkageCheckerStore {
pub:
	keg_path string
pub mut:
	keg_files_dylibs map[string][]string
	exists           bool
}

pub fn new_linkage_checker_store(keg_path string,
	keg_files_dylibs map[string][]string) LinkageCheckerStore {
	return LinkageCheckerStore{
		keg_path: keg_path
		keg_files_dylibs: clone_linkage_map(keg_files_dylibs)
		exists: keg_files_dylibs.len > 0
	}
}

pub fn (store LinkageCheckerStore) fetch_keg_files_dylibs() map[string][]string {
	if !store.exists {
		return map[string][]string{}
	}
	return clone_linkage_map(store.keg_files_dylibs)
}

pub fn (mut store LinkageCheckerStore) delete() {
	store.keg_files_dylibs.clear()
	store.exists = false
}

pub fn (mut store LinkageCheckerStore) update(keg_files_dylibs map[string][]string) {
	store.keg_files_dylibs = clone_linkage_map(keg_files_dylibs)
	store.exists = true
}

pub struct LinkageFormulaDepsResult {
pub:
	indirect_deps           []string
	undeclared_deps         []string
	unnecessary_deps        []string
	version_conflict_deps   []string
	no_linkage_deps         []string
	unexpected_linkage_deps []string
}

@[heap]
pub struct LinkageChecker {
pub:
	keg     Keg
	formula ?Formula
pub mut:
	store                    LinkageCheckerStore
	system_dylibs            []string
	broken_dylibs            []string
	variable_dylibs          []string
	brewed_dylibs            map[string][]string
	reverse_links            map[string][]string
	broken_deps              map[string][]string
	indirect_deps            []string
	undeclared_deps          []string
	unnecessary_deps         []string
	no_linkage_deps          []string
	unexpected_linkage_deps  []string
	unwanted_system_dylibs   []string
	version_conflict_deps    []string
	files_missing_rpaths     []string
	executable_path_dylibs   []string
	printed_output           []string
	warnings                 []string
	files                    []LinkageFile
	owners                   map[string]LinkageOwner
	shared_cache_dylibs      []string
	formula_dependencies     []Dependency
	recursive_dependencies   []string
	dependencies_with_bin    []string
	dependencies_without_bin []string
	brewed_dylib_order       []string
}

fn clone_linkage_map(values map[string][]string) map[string][]string {
	mut cloned := map[string][]string{}
	for key, items in values {
		cloned[key] = items.clone()
	}
	return cloned
}

fn linkage_append_unique(mut values []string, value string) {
	if value !in values {
		values << value
	}
}

fn linkage_map_append_unique(mut values map[string][]string, key string, value string) {
	mut entries := values[key].clone()
	linkage_append_unique(mut entries, value)
	values[key] = entries
}

fn linkage_file_is_candidate(file LinkageFile) bool {
	return file.arch_compatible && (file.dylib || file.binary_executable || file.mach_o_bundle)
}

fn scanned_linkage_file(path string) LinkageFile {
	libraries := utils.dynamically_linked_libraries(path)
	return LinkageFile{
		path: path
		dynamically_linked_libraries: libraries
		dylib: libraries.len > 0 && !os.is_executable(path)
		binary_executable: os.is_executable(path)
		arch_compatible: true
	}
}

pub fn new_linkage_checker(keg Keg, formula ?Formula, config LinkageCheckerConfig,
	rebuild_cache bool) &LinkageChecker {
	mut selected_formula := ?Formula(none)
	if supplied_formula := formula {
		selected_formula = supplied_formula
	} else if resolved_formula := formulary_from_keg_default(keg) {
		selected_formula = resolved_formula
	}
	mut checker := &LinkageChecker{
		keg: keg
		formula: selected_formula
		store: new_linkage_checker_store(keg.path, config.cached_keg_files_dylibs)
		brewed_dylibs: map[string][]string{}
		reverse_links: map[string][]string{}
		broken_deps: map[string][]string{}
		files: config.files.clone()
		owners: config.owners.clone()
		shared_cache_dylibs: config.shared_cache_dylibs.clone()
		formula_dependencies: config.formula_dependencies.clone()
		recursive_dependencies: config.recursive_dependencies.clone()
		dependencies_with_bin: config.dependencies_with_bin.clone()
		dependencies_without_bin: config.dependencies_without_bin.clone()
	}
	if formula == none && selected_formula == none {
		checker.warnings << 'Formula unavailable: ${keg.name}'
	}
	checker.check_dylibs(rebuild_cache)
	return checker
}

fn (checker LinkageChecker) file_metadata(path string) LinkageFile {
	for file in checker.files {
		if file.path == path {
			return file
		}
	}
	return scanned_linkage_file(path)
}

fn (checker LinkageChecker) collect_keg_files_dylibs() map[string][]string {
	mut found := map[string][]string{}
	if checker.files.len > 0 {
		for file in checker.files {
			if linkage_file_is_candidate(file) {
				found[file.path] = file.dynamically_linked_libraries.clone()
			}
		}
		return found
	}
	for path in checker.keg.find() {
		if os.is_link(path) || os.is_dir(path) || !os.is_file(path) {
			continue
		}
		file := scanned_linkage_file(path)
		if linkage_file_is_candidate(file) {
			found[path] = file.dynamically_linked_libraries.clone()
		}
	}
	return found
}

fn (mut checker LinkageChecker) record_brewed_dylib(owner LinkageOwner, dylib string) {
	full_name := if owner.tap == '' || owner.tap == 'homebrew/core' {
		owner.name
	} else {
		'${owner.tap}/${owner.name}'
	}
	if full_name !in checker.brewed_dylibs {
		checker.brewed_dylib_order << full_name
	}
	linkage_map_append_unique(mut checker.brewed_dylibs, full_name, dylib)
}

fn (mut checker LinkageChecker) classify_existing_dylib(dylib string) bool {
	if owner := checker.owners[dylib] {
		checker.record_brewed_dylib(owner, dylib)
		return true
	}
	if !os.exists(dylib) {
		return false
	}
	real_dylib := ruby.real_path(dylib)
	cellar_prefix := checker.keg.cellar.trim_right('/') + '/'
	if !real_dylib.starts_with(cellar_prefix) {
		linkage_append_unique(mut checker.system_dylibs, dylib)
		return true
	}
	owner_keg := keg_for_path(real_dylib, checker.keg.cellar, checker.keg.prefix) or {
		linkage_append_unique(mut checker.system_dylibs, dylib)
		return true
	}
	tab := owner_keg.tab() or { empty_tab() }
	checker.record_brewed_dylib(LinkageOwner{
		name: owner_keg.name
		tap: tab.tap_name()
	}, dylib)
	return true
}

pub fn (checker LinkageChecker) dylib_to_dep(dylib string) ?string {
	prefix := checker.keg.prefix.trim_right('/')
	if prefix == '' || !dylib.starts_with('${prefix}/') {
		return none
	}
	parts := dylib[prefix.len + 1..].split('/')
	if parts.len < 3 || parts[0] !in ['opt', 'Cellar'] || parts[1] == '' {
		return none
	}
	for character in parts[1] {
		if !character.is_alnum() && character !in [`_`, `+`, `-`, `.`, `@`] {
			return none
		}
	}
	return parts[1]
}

fn linkage_python_version(value string) bool {
	parts := value.split('.')
	return parts.len == 2 && parts[0] != '' && parts[1] != '' && parts[0].bytes().all(it.is_digit()) && parts[1].bytes().all(it.is_digit())
}

pub fn (checker LinkageChecker) broken_dylibs_allowed(file string) bool {
	formula := checker.formula or { return false }
	formula_prefix := ruby.real_path(formula.prefix()).trim_right('/')
	if formula.name() == 'julia' {
		return file.starts_with('${formula_prefix}/share/julia/compiled/')
	}
	if formula.name() != 'cyan' {
		return false
	}
	python_root := '${formula_prefix}/libexec/lib/python'
	if !file.starts_with(python_root) {
		return false
	}
	remainder := file[python_root.len..]
	version := remainder.all_before('/')
	return linkage_python_version(version) && remainder.all_after('/').starts_with('site-packages/cyan/extras/')
}

pub fn (checker LinkageChecker) dylib_found_in_shared_cache(dylib string) bool {
	return dylib in checker.shared_cache_dylibs
}

pub fn (checker LinkageChecker) harmless_broken_link(dylib string) bool {
	return dylib in ['/usr/lib/libgcc_s_ppc64.1.dylib', '/opt/local/lib/libgcc/libgcc_s.1.dylib',
		'${checker.keg.prefix.trim_right('/')}/opt/llvm/lib/libc++.1.dylib']
}

pub fn (checker LinkageChecker) system_framework(dylib string) bool {
	return dylib.starts_with('/System/Library/Frameworks/')
}

pub fn (mut checker LinkageChecker) check_dylibs(rebuild_cache bool) {
	mut keg_files_dylibs := map[string][]string{}
	if rebuild_cache {
		checker.store.delete()
	} else {
		keg_files_dylibs = checker.store.fetch_keg_files_dylibs()
	}
	keg_files_dylibs_was_empty := keg_files_dylibs.len == 0
	if keg_files_dylibs_was_empty {
		keg_files_dylibs = checker.collect_keg_files_dylibs()
	}
	mut checked_dylibs := []string{}
	mut files := keg_files_dylibs.keys()
	files.sort()
	for file_path in files {
		file := checker.file_metadata(file_path)
		mut file_has_any_rpath_dylibs := false
		for dylib in keg_files_dylibs[file_path] {
			linkage_map_append_unique(mut checker.reverse_links, dylib, file_path)
			if !file_has_any_rpath_dylibs && dylib.starts_with('@rpath/') {
				file_has_any_rpath_dylibs = true
				if file.rpaths.len == 0 && !checker.broken_dylibs_allowed(file_path) {
					checker.files_missing_rpaths << file_path
				}
			}
			if dylib in checked_dylibs {
				continue
			}
			checked_dylibs << dylib
			if dylib.starts_with('@rpath') {
				linkage_append_unique(mut checker.variable_dylibs, dylib)
				continue
			}
			if dylib.starts_with('@executable_path') && !file.binary_executable {
				checker.executable_path_dylibs << dylib
				continue
			}
			if checker.classify_existing_dylib(dylib) {
				continue
			}
			if checker.harmless_broken_link(dylib) {
				continue
			}
			if dep := checker.dylib_to_dep(dylib) {
				linkage_map_append_unique(mut checker.broken_deps, dep, dylib)
			} else if checker.dylib_found_in_shared_cache(dylib) {
				linkage_append_unique(mut checker.system_dylibs, dylib)
			} else if !checker.system_framework(dylib) && !checker.broken_dylibs_allowed(file_path) {
				linkage_append_unique(mut checker.broken_dylibs, dylib)
			}
		}
	}
	if dependency_results := checker.check_formula_deps() {
		checker.indirect_deps = dependency_results.indirect_deps
		checker.undeclared_deps = dependency_results.undeclared_deps
		checker.unnecessary_deps = dependency_results.unnecessary_deps
		checker.version_conflict_deps = dependency_results.version_conflict_deps
		checker.no_linkage_deps = dependency_results.no_linkage_deps
		checker.unexpected_linkage_deps = dependency_results.unexpected_linkage_deps
	}
	if keg_files_dylibs_was_empty {
		checker.store.update(keg_files_dylibs)
	}
}

pub fn sort_linkage_formula_full_names(mut values []string) {
	values.sort_with_compare(fn (left &string, right &string) int {
		if left.contains('/') && !right.contains('/') {
			return 1
		}
		if !left.contains('/') && right.contains('/') {
			return -1
		}
		return if left < right {
			-1
		} else if left > right { 1 } else { 0 }
	})
}

fn linkage_remove_values(values []string, removed []string) []string {
	return values.filter(it !in removed)
}

fn (checker LinkageChecker) dependency_has_bin(full_name string) bool {
	name := name_from_full_name(full_name)
	if full_name in checker.dependencies_with_bin || name in checker.dependencies_with_bin {
		return true
	}
	if full_name in checker.dependencies_without_bin || name in checker.dependencies_without_bin {
		return false
	}
	formula := formulary_factory_default(full_name) or { return false }
	return os.is_dir(os.join_path(formula.prefix(), 'bin'))
}

pub fn (checker LinkageChecker) check_formula_deps() ?LinkageFormulaDepsResult {
	formula := checker.formula or { return none }
	dependencies := if checker.formula_dependencies.len > 0 {
		checker.formula_dependencies.clone()
	} else {
		formula.deps()
	}
	mut declared_deps_full_names := []string{}
	mut no_linkage_deps_full_names := []string{}
	for dependency in dependencies {
		if dependency.build() || dependency.test() || ((dependency.optional() || dependency.recommended()) && !formula.build.with_any(dependency.option_names())) {
			continue
		}
		declared_deps_full_names << dependency.name
		if dependency.no_linkage() {
			no_linkage_deps_full_names << dependency.name
		}
	}
	declared_deps_names := declared_deps_full_names.map(name_from_full_name(it))
	no_linkage_deps_names := no_linkage_deps_full_names.map(name_from_full_name(it))
	mut recursive_deps := checker.recursive_dependencies.map(name_from_full_name(it))
	if recursive_deps.len == 0 {
		recursive_deps = formula_runtime_dependencies(formula, true, false).map(name_from_full_name(it.name))
	}
	mut indirect_deps := []string{}
	mut undeclared_deps := []string{}
	mut unexpected_linkage_deps := []string{}
	for full_name in checker.brewed_dylib_order {
		name := name_from_full_name(full_name)
		if name == formula.name() {
			continue
		}
		if name in no_linkage_deps_names {
			unexpected_linkage_deps << full_name
			continue
		}
		if name in recursive_deps {
			if name !in declared_deps_names {
				indirect_deps << full_name
			}
		} else {
			undeclared_deps << full_name
		}
	}
	sort_linkage_formula_full_names(mut indirect_deps)
	sort_linkage_formula_full_names(mut undeclared_deps)
	sort_linkage_formula_full_names(mut unexpected_linkage_deps)
	mut unnecessary_deps := declared_deps_full_names.filter(!checker.dependency_has_bin(it) && name_from_full_name(it) !in checker.brewed_dylib_order.map(name_from_full_name(it)))
	unnecessary_deps = linkage_remove_values(unnecessary_deps, no_linkage_deps_full_names)
	mut missing_deps := []string{}
	for _, dylibs in checker.broken_deps {
		for dylib in dylibs {
			if dependency := checker.dylib_to_dep(dylib) {
				linkage_append_unique(mut missing_deps, dependency)
			}
		}
	}
	unnecessary_deps = linkage_remove_values(unnecessary_deps, missing_deps)
	mut versions := map[string][]string{}
	mut version_conflict_deps := []string{}
	for linkage in checker.brewed_dylib_order {
		name := name_from_full_name(linkage)
		unversioned_name := name.all_before('@')
		linkage_map_append_unique(mut versions, unversioned_name, name)
		if versions[unversioned_name].len >= 2 {
			for version in versions[unversioned_name] {
				linkage_append_unique(mut version_conflict_deps, version)
			}
		}
	}
	return LinkageFormulaDepsResult{
		indirect_deps: indirect_deps
		undeclared_deps: undeclared_deps
		unnecessary_deps: unnecessary_deps
		version_conflict_deps: version_conflict_deps
		no_linkage_deps: no_linkage_deps_full_names
		unexpected_linkage_deps: unexpected_linkage_deps
	}
}

fn format_linkage_items(label string, values []string,
	grouped map[string][]string) ?string {
	if values.len == 0 && grouped.len == 0 {
		return none
	}
	mut output := ['${label}:']
	if grouped.len > 0 {
		mut labels := grouped.keys()
		labels.sort()
		for list_label in labels {
			mut items := grouped[list_label].clone()
			items.sort()
			for item in items {
				output << '${item} (${list_label})'
			}
		}
	} else {
		mut sorted := values.clone()
		sorted.sort()
		output << sorted
	}
	return output.join('\n  ')
}

pub fn (mut checker LinkageChecker) display_items(label string, values []string,
	grouped map[string][]string, puts_output bool) ?string {
	output := format_linkage_items(label, values, grouped) or { return none }
	checker.printed_output << output
	if puts_output {
		println(output)
	}
	return output
}

pub fn (mut checker LinkageChecker) display_normal_output() {
	checker.display_items('System libraries', checker.system_dylibs.clone(), map[string][]string{}, true)
	checker.display_items('Homebrew libraries', []string{}, checker.brewed_dylibs.clone(), true)
	checker.display_items('Indirect dependencies with linkage', checker.indirect_deps.clone(), map[string][]string{}, true)
	checker.display_items('@rpath-referenced libraries', checker.variable_dylibs.clone(), map[string][]string{}, true)
	checker.display_items('Missing libraries', checker.broken_dylibs.clone(), map[string][]string{}, true)
	checker.display_items('Broken dependencies', []string{}, checker.broken_deps.clone(), true)
	checker.display_items('Undeclared dependencies with linkage', checker.undeclared_deps.clone(), map[string][]string{}, true)
	checker.display_items('Dependencies with no linkage', checker.unnecessary_deps.clone(), map[string][]string{}, true)
	checker.display_items('Homebrew dependencies not requiring linkage', checker.no_linkage_deps.clone(), map[string][]string{}, true)
	checker.display_items('Unexpected linkage for no_linkage dependencies', checker.unexpected_linkage_deps.clone(), map[string][]string{}, true)
	checker.display_items('Unwanted system libraries', checker.unwanted_system_dylibs.clone(), map[string][]string{}, true)
	checker.display_items('Files with missing rpath', checker.files_missing_rpaths.clone(), map[string][]string{}, true)
	checker.display_items('@executable_path references in libraries', checker.executable_path_dylibs.clone(), map[string][]string{}, true)
}

pub fn (mut checker LinkageChecker) display_reverse_output() ?string {
	if checker.reverse_links.len == 0 {
		return none
	}
	mut dylibs := checker.reverse_links.keys()
	dylibs.sort()
	mut groups := []string{}
	for dylib in dylibs {
		mut lines := [dylib]
		for file in checker.reverse_links[dylib] {
			keg_prefix := checker.keg.path.trim_right('/') + '/'
			unprefixed := if file.starts_with(keg_prefix) { file[keg_prefix.len..] } else { file }
			lines << '  ${unprefixed}'
		}
		groups << lines.join('\n')
	}
	output := groups.join('\n\n')
	checker.printed_output << output
	println(output)
	return output
}

pub fn (mut checker LinkageChecker) display_test_output(puts_output bool, strict bool) {
	checker.display_items('Missing libraries', checker.broken_dylibs.clone(), map[string][]string{}, puts_output)
	checker.display_items('Broken dependencies', []string{}, checker.broken_deps.clone(), puts_output)
	checker.display_items('Unwanted system libraries', checker.unwanted_system_dylibs.clone(), map[string][]string{}, puts_output)
	checker.display_items('Conflicting libraries', checker.version_conflict_deps.clone(), map[string][]string{}, puts_output)
	checker.display_items('Indirect dependencies with linkage', checker.indirect_deps.clone(), map[string][]string{}, puts_output)
	checker.display_items('Unexpected linkage for no_linkage dependencies', checker.unexpected_linkage_deps.clone(), map[string][]string{}, puts_output)
	if !strict {
		return
	}
	checker.display_items('Undeclared dependencies with linkage', checker.undeclared_deps.clone(), map[string][]string{}, puts_output)
	checker.display_items('Files with missing rpath', checker.files_missing_rpaths.clone(), map[string][]string{}, puts_output)
	checker.display_items('@executable_path references in libraries', checker.executable_path_dylibs.clone(), map[string][]string{}, puts_output)
}

pub fn (checker LinkageChecker) broken_library_linkage(test bool, strict bool) !bool {
	if strict && !test {
		return error('Strict linkage checking requires test mode to be enabled.')
	}
	if checker.broken_deps.len > 0 || checker.broken_dylibs.len > 0 {
		return true
	}
	if test && (checker.unwanted_system_dylibs.len > 0 || checker.version_conflict_deps.len > 0 || checker.indirect_deps.len > 0 || checker.unexpected_linkage_deps.len > 0) {
		return true
	}
	return strict && (checker.undeclared_deps.len > 0 || checker.files_missing_rpaths.len > 0 || checker.executable_path_dylibs.len > 0)
}

pub fn (mut checker LinkageChecker) resolve_formula(keg Keg) ?Formula {
	formula := formulary_from_keg_default(keg) or {
		checker.warnings << 'Formula unavailable: ${keg.name}'
		return none
	}
	return formula
}

fn linkage_checker_value(checker &LinkageChecker) ruby.Value {
	return ruby.structured_value('LinkageChecker', checker.keg.path, {
		'linkage_checker_address': u64(voidptr(checker)).str()
	})
}

fn linkage_checker_from_value(value ruby.Value) &LinkageChecker {
	address := value.attributes['linkage_checker_address'] or {
		panic('invalid LinkageChecker receiver')
	}
	return unsafe { &LinkageChecker(voidptr(address.u64())) }
}

pub fn linkage_checker_boundary(checker &LinkageChecker) ruby.Value {
	return linkage_checker_value(checker)
}

pub fn linkage_checker_keg_boundary(keg Keg,
	config &LinkageCheckerConfig) ruby.Value {
	return ruby.structured_value('Keg', keg.path, {
		'path':                           keg.path
		'prefix':                         keg.prefix
		'cellar':                         keg.cellar
		'name':                           keg.name
		'linkage_checker_config_address': u64(voidptr(config)).str()
	})
}

fn linkage_checker_keg_from_value(value ruby.Value) Keg {
	path := value.attribute('path') or { value.as_string() }
	prefix := value.attribute('prefix') or { ruby.environment_value('HOMEBREW_PREFIX') }
	cellar := value.attribute('cellar') or { os.join_path(prefix, 'Cellar') }
	return new_keg_with_paths(path, cellar, prefix) or { panic(err) }
}

fn linkage_config_from_keg_value(value ruby.Value) LinkageCheckerConfig {
	address := value.attributes['linkage_checker_config_address'] or {
		return LinkageCheckerConfig{}
	}
	return unsafe { *&LinkageCheckerConfig(voidptr(address.u64())) }
}

fn linkage_checker_keg_value(keg Keg) ruby.Value {
	return ruby.structured_value('Keg', keg.path, {
		'path':   keg.path
		'prefix': keg.prefix
		'cellar': keg.cellar
		'name':   keg.name
	})
}

fn linkage_string_map_value(values map[string][]string) ruby.Value {
	mut mapped := map[string]ruby.Value{}
	for key, entries in values {
		mapped[key] = ruby.string_array_value(entries)
	}
	return ruby.map_value(mapped)
}

fn linkage_bool_argument(args []ruby.Value, index int, fallback bool) bool {
	if index >= args.len {
		return fallback
	}
	return args[index].as_bool() or { args[index].as_string() == 'true' }
}

// Ruby attr_reader `attr_reader :keg` at line 14.
pub fn ruby_linkage_checker_l14_d1_keg(args ...ruby.Value) ruby.Value {
	return linkage_checker_keg_value(linkage_checker_from_value(args[0]).keg)
}

// Ruby attr_reader `attr_reader :formula` at line 17.
pub fn ruby_linkage_checker_l17_d2_formula(args ...ruby.Value) ruby.Value {
	formula := linkage_checker_from_value(args[0]).formula or {
		return ruby.object_value('NilClass', 'nil')
	}
	return formula_boundary_value(formula)
}

// Ruby attr_reader `attr_reader :store` at line 20.
pub fn ruby_linkage_checker_l20_d3_store(args ...ruby.Value) ruby.Value {
	store := linkage_checker_from_value(args[0]).store
	return ruby.structured_value('LinkageCacheStore', store.keg_path, {
		'keg_path': store.keg_path
		'exists':   store.exists.str()
	})
}

// Ruby attr_reader `attr_reader :indirect_deps, :undeclared_deps, :unwanted_system_dylibs` at line 23.
pub fn ruby_linkage_checker_l23_d4_indirect_deps(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(linkage_checker_from_value(args[0]).indirect_deps)
}

// Ruby attr_reader `attr_reader :indirect_deps, :undeclared_deps, :unwanted_system_dylibs` at line 23.
pub fn ruby_linkage_checker_l23_d5_undeclared_deps(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(linkage_checker_from_value(args[0]).undeclared_deps)
}

// Ruby attr_reader `attr_reader :indirect_deps, :undeclared_deps, :unwanted_system_dylibs` at line 23.
pub fn ruby_linkage_checker_l23_d6_unwanted_system_dylibs(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(linkage_checker_from_value(args[0]).unwanted_system_dylibs)
}

// Ruby attr_reader `attr_reader :system_dylibs, :broken_dylibs` at line 26.
pub fn ruby_linkage_checker_l26_d7_system_dylibs(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(linkage_checker_from_value(args[0]).system_dylibs)
}

// Ruby attr_reader `attr_reader :system_dylibs, :broken_dylibs` at line 26.
pub fn ruby_linkage_checker_l26_d8_broken_dylibs(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(linkage_checker_from_value(args[0]).broken_dylibs)
}

// Ruby attr_reader `attr_reader :broken_deps` at line 29.
pub fn ruby_linkage_checker_l29_d9_broken_deps(args ...ruby.Value) ruby.Value {
	return linkage_string_map_value(linkage_checker_from_value(args[0]).broken_deps)
}

// Ruby method `initialize(keg, formula = nil, cache_db:, rebuild_cache: false)` at line 38.
pub fn ruby_linkage_checker_l38_d10_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('LinkageChecker#initialize requires a keg')
	}
	keg := linkage_checker_keg_from_value(args[0])
	mut formula := ?Formula(none)
	if args.len > 1 && args[1].type_name == 'Formula' {
		formula = formula_from_boundary(args[1])
	}
	mut rebuild_cache := false
	if args.len > 2 && args[2].type_name == 'Hash' {
		options := args[2].as_map() or { map[string]ruby.Value{} }
		if value := options['rebuild_cache'] {
			rebuild_cache = value.as_bool() or { false }
		}
	}
	return linkage_checker_value(new_linkage_checker(keg, formula, linkage_config_from_keg_value(args[0]), rebuild_cache))
}

// Ruby method `display_normal_output` at line 63.
pub fn ruby_linkage_checker_l63_d11_display_normal_output(args ...ruby.Value) ruby.Value {
	mut checker := linkage_checker_from_value(args[0])
	checker.display_normal_output()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `display_reverse_output` at line 80.
pub fn ruby_linkage_checker_l80_d12_display_reverse_output(args ...ruby.Value) ruby.Value {
	mut checker := linkage_checker_from_value(args[0])
	checker.display_reverse_output()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `display_test_output(puts_output: true, strict: false)` at line 95.
pub fn ruby_linkage_checker_l95_d13_display_test_output(args ...ruby.Value) ruby.Value {
	mut checker := linkage_checker_from_value(args[0])
	checker.display_test_output(linkage_bool_argument(args, 1, true), linkage_bool_argument(args, 2, false))
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `broken_library_linkage?(test: false, strict: false)` at line 110.
pub fn ruby_linkage_checker_l110_d14_broken_library_linkage(args ...ruby.Value) ruby.Value {
	checker := linkage_checker_from_value(args[0])
	broken := checker.broken_library_linkage(linkage_bool_argument(args, 1, false), linkage_bool_argument(args, 2, false)) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return ruby.bool_value(broken)
}

// Ruby method `dylib_to_dep(dylib)` at line 124.
pub fn ruby_linkage_checker_l124_d15_dylib_to_dep(args ...ruby.Value) ruby.Value {
	dependency := linkage_checker_from_value(args[0]).dylib_to_dep(args[1].as_string()) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(dependency)
}

// Ruby method `broken_dylibs_allowed?(file)` at line 130.
pub fn ruby_linkage_checker_l130_d16_broken_dylibs_allowed(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(linkage_checker_from_value(args[0]).broken_dylibs_allowed(args[1].as_string()))
}

// Ruby method `check_dylibs(rebuild_cache:)` at line 147.
pub fn ruby_linkage_checker_l147_d17_check_dylibs(args ...ruby.Value) ruby.Value {
	mut checker := linkage_checker_from_value(args[0])
	checker.check_dylibs(linkage_bool_argument(args, 1, false))
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `dylib_found_in_shared_cache?(_dylib)` at line 245.
pub fn ruby_linkage_checker_l245_d18_dylib_found_in_shared_cache(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(linkage_checker_from_value(args[0]).dylib_found_in_shared_cache(args[1].as_string()))
}

// Ruby method `check_formula_deps` at line 253.
pub fn ruby_linkage_checker_l253_d19_check_formula_deps(args ...ruby.Value) ruby.Value {
	result := linkage_checker_from_value(args[0]).check_formula_deps() or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.array_value([
		ruby.string_array_value(result.indirect_deps),
		ruby.string_array_value(result.undeclared_deps),
		ruby.string_array_value(result.unnecessary_deps),
		ruby.string_array_value(result.version_conflict_deps),
		ruby.string_array_value(result.no_linkage_deps),
		ruby.string_array_value(result.unexpected_linkage_deps),
	])
}

// Ruby method `sort_by_formula_full_name!(arr)` at line 336.
pub fn ruby_linkage_checker_l336_d20_sort_by_formula_full_name(args ...ruby.Value) ruby.Value {
	mut values := args[1].as_string_array() or { []string{} }
	sort_linkage_formula_full_names(mut values)
	return ruby.string_array_value(values)
}

// Ruby method `harmless_broken_link?(dylib)` at line 351.
pub fn ruby_linkage_checker_l351_d21_harmless_broken_link(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(linkage_checker_from_value(args[0]).harmless_broken_link(args[1].as_string()))
}

// Ruby method `system_framework?(dylib)` at line 364.
pub fn ruby_linkage_checker_l364_d22_system_framework(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(linkage_checker_from_value(args[0]).system_framework(args[1].as_string()))
}

// Ruby method `display_items(label, things, puts_output: true)` at line 376.
pub fn ruby_linkage_checker_l376_d23_display_items(args ...ruby.Value) ruby.Value {
	mut checker := linkage_checker_from_value(args[0])
	label := args[1].as_string()
	things := args[2]
	mut values := []string{}
	mut grouped := map[string][]string{}
	if things.type_name == 'Hash' {
		for key, value in things.as_map() or { map[string]ruby.Value{} } {
			grouped[key] = value.as_string_array() or { []string{} }
		}
	} else {
		values = things.as_string_array() or { []string{} }
	}
	output := checker.display_items(label, values, grouped, linkage_bool_argument(args, 3, true)) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(output)
}

// Ruby method `resolve_formula(keg)` at line 395.
pub fn ruby_linkage_checker_l395_d24_resolve_formula(args ...ruby.Value) ruby.Value {
	mut checker := linkage_checker_from_value(args[0])
	keg := if args.len > 1 { linkage_checker_keg_from_value(args[1]) } else { checker.keg }
	formula := checker.resolve_formula(keg) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return formula_boundary_value(formula)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "keg"
// 5: require "formula"
// 6: require "linkage_cache_store"
// 7: require "utils/output"
// 8:
// 9: # Check for broken/missing linkage in a formula's keg.
// 10: class LinkageChecker
// 11:   include Utils::Output::Mixin
// 12:
// 13:   sig { returns(Keg) }
// 14:   attr_reader :keg
// 15:
// 16:   sig { returns(T.nilable(Formula)) }
// 17:   attr_reader :formula
// 18:
// 19:   sig { returns(LinkageCacheStore) }
// 20:   attr_reader :store
// 21:
// 22:   sig { returns(T::Array[String]) }
// 23:   attr_reader :indirect_deps, :undeclared_deps, :unwanted_system_dylibs
// 24:
// 25:   sig { returns(T::Set[String]) }
// 26:   attr_reader :system_dylibs, :broken_dylibs
// 27:
// 28:   sig { returns(T::Hash[String, T::Array[String]]) }
// 29:   attr_reader :broken_deps
// 30:
// 31:   sig {
// 32:     params(
// 33:       keg: Keg, formula: T.nilable(Formula),
// 34:       cache_db: CacheStoreDatabase[String, T::Hash[T.any(String, Symbol), T.anything]],
// 35:       rebuild_cache: T::Boolean
// 36:     ).void
// 37:   }
// 38:   def initialize(keg, formula = nil, cache_db:, rebuild_cache: false)
// 39:     @keg = keg
// 40:     @formula = T.let(formula || resolve_formula(keg), T.nilable(Formula))
// 41:     @store = T.let(LinkageCacheStore.new(keg.to_s, cache_db), LinkageCacheStore)
// 42:
// 43:     @system_dylibs    = T.let(Set.new, T::Set[String])
// 44:     @broken_dylibs    = T.let(Set.new, T::Set[String])
// 45:     @variable_dylibs  = T.let(Set.new, T::Set[String])
// 46:     @brewed_dylibs    = T.let({}, T::Hash[String, T::Set[String]])
// 47:     @reverse_links    = T.let({}, T::Hash[String, T::Set[String]])
// 48:     @broken_deps      = T.let({}, T::Hash[String, T::Array[String]])
// 49:     @indirect_deps    = T.let([], T::Array[String])
// 50:     @undeclared_deps  = T.let([], T::Array[String])
// 51:     @unnecessary_deps = T.let([], T::Array[String])
// 52:     @no_linkage_deps  = T.let([], T::Array[String])
// 53:     @unexpected_linkage_deps = T.let([], T::Array[String])
// 54:     @unwanted_system_dylibs = T.let([], T::Array[String])
// 55:     @version_conflict_deps = T.let([], T::Array[String])
// 56:     @files_missing_rpaths = T.let([], T::Array[String])
// 57:     @executable_path_dylibs = T.let([], T::Array[String])
// 58:
// 59:     check_dylibs(rebuild_cache:)
// 60:   end
// 61:
// 62:   sig { void }
// 63:   def display_normal_output
// 64:     display_items "System libraries", @system_dylibs
// 65:     display_items "Homebrew libraries", @brewed_dylibs
// 66:     display_items "Indirect dependencies with linkage", @indirect_deps
// 67:     display_items "@rpath-referenced libraries", @variable_dylibs
// 68:     display_items "Missing libraries", @broken_dylibs
// 69:     display_items "Broken dependencies", @broken_deps
// 70:     display_items "Undeclared dependencies with linkage", @undeclared_deps
// 71:     display_items "Dependencies with no linkage", @unnecessary_deps
// 72:     display_items "Homebrew dependencies not requiring linkage", @no_linkage_deps
// 73:     display_items "Unexpected linkage for no_linkage dependencies", @unexpected_linkage_deps
// 74:     display_items "Unwanted system libraries", @unwanted_system_dylibs
// 75:     display_items "Files with missing rpath", @files_missing_rpaths
// 76:     display_items "@executable_path references in libraries", @executable_path_dylibs
// 77:   end
// 78:
// 79:   sig { void }
// 80:   def display_reverse_output
// 81:     return if @reverse_links.empty?
// 82:
// 83:     sorted = @reverse_links.sort
// 84:     sorted.each do |dylib, files|
// 85:       puts dylib
// 86:       files.each do |f|
// 87:         unprefixed = f.to_s.delete_prefix "#{keg}/"
// 88:         puts "  #{unprefixed}"
// 89:       end
// 90:       puts if dylib != sorted.last&.first
// 91:     end
// 92:   end
// 93:
// 94:   sig { params(puts_output: T::Boolean, strict: T::Boolean).void }
// 95:   def display_test_output(puts_output: true, strict: false)
// 96:     display_items("Missing libraries", @broken_dylibs, puts_output:)
// 97:     display_items("Broken dependencies", @broken_deps, puts_output:)
// 98:     display_items("Unwanted system libraries", @unwanted_system_dylibs, puts_output:)
// 99:     display_items("Conflicting libraries", @version_conflict_deps, puts_output:)
// 100:     display_items("Indirect dependencies with linkage", @indirect_deps, puts_output:)
// 101:     display_items("Unexpected linkage for no_linkage dependencies", @unexpected_linkage_deps, puts_output:)
// 102:     return unless strict
// 103:
// 104:     display_items("Undeclared dependencies with linkage", @undeclared_deps, puts_output:)
// 105:     display_items("Files with missing rpath", @files_missing_rpaths, puts_output:)
// 106:     display_items "@executable_path references in libraries", @executable_path_dylibs, puts_output:
// 107:   end
// 108:
// 109:   sig { params(test: T::Boolean, strict: T::Boolean).returns(T::Boolean) }
// 110:   def broken_library_linkage?(test: false, strict: false)
// 111:     raise ArgumentError, "Strict linkage checking requires test mode to be enabled." if strict && !test
// 112:
// 113:     issues = [@broken_deps, @broken_dylibs]
// 114:     if test
// 115:       issues += [@unwanted_system_dylibs, @version_conflict_deps, @indirect_deps, @unexpected_linkage_deps]
// 116:       issues += [@undeclared_deps, @files_missing_rpaths, @executable_path_dylibs] if strict
// 117:     end
// 118:     issues.any?(&:present?)
// 119:   end
// 120:
// 121:   private
// 122:
// 123:   sig { params(dylib: String).returns(T.nilable(String)) }
// 124:   def dylib_to_dep(dylib)
// 125:     dylib =~ %r{#{Regexp.escape(HOMEBREW_PREFIX)}/(opt|Cellar)/([\w+-.@]+)/}o
// 126:     Regexp.last_match(2)
// 127:   end
// 128:
// 129:   sig { params(file: String).returns(T::Boolean) }
// 130:   def broken_dylibs_allowed?(file)
// 131:     formula = self.formula
// 132:     return false if formula.nil?
// 133:
// 134:     case formula.name
// 135:     when "julia"
// 136:       file.start_with?("#{formula.prefix.realpath}/share/julia/compiled/")
// 137:     when "cyan"
// 138:       file.match?(
// 139:         %r{\A#{Regexp.escape(formula.prefix.realpath.to_s)}/libexec/lib/python\d+\.\d+/site-packages/cyan/extras/},
// 140:       )
// 141:     else
// 142:       false
// 143:     end
// 144:   end
// 145:
// 146:   sig { params(rebuild_cache: T::Boolean).void }
// 147:   def check_dylibs(rebuild_cache:)
// 148:     keg_files_dylibs = nil
// 149:
// 150:     if rebuild_cache
// 151:       store.delete!
// 152:     else
// 153:       keg_files_dylibs = store.fetch(:keg_files_dylibs)
// 154:     end
// 155:
// 156:     keg_files_dylibs_was_empty = false
// 157:     keg_files_dylibs ||= {}
// 158:     if keg_files_dylibs.empty?
// 159:       keg_files_dylibs_was_empty = true
// 160:       @keg.find do |file|
// 161:         next if file.symlink? || file.directory?
// 162:
// 163:         file = begin
// 164:           BinaryPathname.wrap(file)
// 165:         rescue NotImplementedError
// 166:           next
// 167:         end
// 168:
// 169:         next if !file.dylib? && !file.binary_executable? && !file.mach_o_bundle?
// 170:         next unless file.arch_compatible?(Hardware::CPU.arch)
// 171:
// 172:         # weakly loaded dylibs may not actually exist on disk, so skip them
// 173:         # when checking for broken linkage
// 174:         keg_files_dylibs[file] =
// 175:           file.dynamically_linked_libraries(except: :DYLIB_USE_WEAK_LINK)
// 176:       end
// 177:     end
// 178:
// 179:     checked_dylibs = Set.new
// 180:
// 181:     keg_files_dylibs.each do |file, dylibs|
// 182:       file_has_any_rpath_dylibs = T.let(false, T::Boolean)
// 183:       dylibs.each do |dylib|
// 184:         (@reverse_links[dylib] ||= Set.new) << file
// 185:
// 186:         # Files that link @rpath-prefixed dylibs must include at
// 187:         # least one rpath in order to resolve it.
// 188:         if !file_has_any_rpath_dylibs && (dylib.start_with? "@rpath/")
// 189:           file_has_any_rpath_dylibs = true
// 190:           pathname = Pathname(file)
// 191:           @files_missing_rpaths << file if pathname.rpaths.empty? && !broken_dylibs_allowed?(file.to_s)
// 192:         end
// 193:
// 194:         next if checked_dylibs.include? dylib
// 195:
// 196:         checked_dylibs << dylib
// 197:
// 198:         if dylib.start_with? "@rpath"
// 199:           @variable_dylibs << dylib
// 200:           next
// 201:         elsif dylib.start_with?("@executable_path") && !Pathname(file).binary_executable?
// 202:           @executable_path_dylibs << dylib
// 203:           next
// 204:         end
// 205:
// 206:         begin
// 207:           owner = Keg.for(Pathname(dylib))
// 208:         rescue NotAKegError
// 209:           @system_dylibs << dylib
// 210:         rescue Errno::ENOENT
// 211:           next if harmless_broken_link?(dylib)
// 212:
// 213:           if (dep = dylib_to_dep(dylib))
// 214:             broken_dep = (@broken_deps[dep] ||= [])
// 215:             broken_dep << dylib unless broken_dep.include?(dylib)
// 216:           elsif dylib_found_in_shared_cache?(dylib)
// 217:             # In macOS Big Sur and later, system libraries do not exist on-disk and instead exist in a cache.
// 218:             @system_dylibs << dylib
// 219:           elsif !system_framework?(dylib) && !broken_dylibs_allowed?(file.to_s)
// 220:             @broken_dylibs << dylib
// 221:           end
// 222:         else
// 223:           tap = owner.tab.tap
// 224:           f = if tap.nil? || tap.core_tap?
// 225:             owner.name
// 226:           else
// 227:             "#{tap}/#{owner.name}"
// 228:           end
// 229:           (@brewed_dylibs[f] ||= Set.new) << dylib
// 230:         end
// 231:       end
// 232:     end
// 233:
// 234:     if (check_formula_deps = self.check_formula_deps)
// 235:       @indirect_deps, @undeclared_deps, @unnecessary_deps,
// 236:         @version_conflict_deps, @no_linkage_deps, @unexpected_linkage_deps = check_formula_deps
// 237:     end
// 238:
// 239:     return unless keg_files_dylibs_was_empty
// 240:
// 241:     store.update!(keg_files_dylibs:)
// 242:   end
// 243:
// 244:   sig { params(_dylib: String).returns(T::Boolean) }
// 245:   def dylib_found_in_shared_cache?(_dylib)
// 246:     false
// 247:   end
// 248:
// 249:   sig {
// 250:     returns(T.nilable([T::Array[String], T::Array[String], T::Array[String],
// 251:                        T::Array[String], T::Array[String], T::Array[String]]))
// 252:   }
// 253:   def check_formula_deps
// 254:     formula = self.formula
// 255:     return if formula.nil?
// 256:
// 257:     filter_out = proc do |dep|
// 258:       next true if dep.build? || dep.test?
// 259:
// 260:       (dep.optional? || dep.recommended?) && formula.build.without?(dep)
// 261:     end
// 262:
// 263:     declared_deps_full_names = formula.deps
// 264:                                       .reject { |dep| filter_out.call(dep) }
// 265:                                       .map(&:name)
// 266:     declared_deps_names = declared_deps_full_names.map do |dep|
// 267:       Utils.name_from_full_name(dep)
// 268:     end
// 269:
// 270:     # Get dependencies marked with :no_linkage
// 271:     no_linkage_deps_full_names = formula.deps
// 272:                                         .reject { |dep| filter_out.call(dep) }
// 273:                                         .select(&:no_linkage?)
// 274:                                         .map(&:name)
// 275:     no_linkage_deps_names = no_linkage_deps_full_names.map do |dep|
// 276:       Utils.name_from_full_name(dep)
// 277:     end
// 278:
// 279:     recursive_deps = formula.runtime_formula_dependencies(undeclared: false)
// 280:                             .map(&:name)
// 281:
// 282:     indirect_deps = []
// 283:     undeclared_deps = []
// 284:     unexpected_linkage_deps = []
// 285:     @brewed_dylibs.each_key do |full_name|
// 286:       name = Utils.name_from_full_name(full_name)
// 287:       next if name == formula.name
// 288:
// 289:       # Check if this is a no_linkage dependency with unexpected linkage
// 290:       if no_linkage_deps_names.include?(name)
// 291:         unexpected_linkage_deps << full_name
// 292:         next
// 293:       end
// 294:
// 295:       if recursive_deps.include?(name)
// 296:         indirect_deps << full_name unless declared_deps_names.include?(name)
// 297:       else
// 298:         undeclared_deps << full_name
// 299:       end
// 300:     end
// 301:
// 302:     sort_by_formula_full_name!(indirect_deps)
// 303:     sort_by_formula_full_name!(undeclared_deps)
// 304:     sort_by_formula_full_name!(unexpected_linkage_deps)
// 305:
// 306:     unnecessary_deps = declared_deps_full_names.reject do |full_name|
// 307:       next true if Formula[full_name].bin.directory?
// 308:
// 309:       name = Utils.name_from_full_name(full_name)
// 310:       @brewed_dylibs.keys.map { |l| Utils.name_from_full_name(l) }.include?(name)
// 311:     end
// 312:
// 313:     # Remove no_linkage dependencies from unnecessary_deps since they're expected not to have linkage
// 314:     unnecessary_deps -= no_linkage_deps_full_names
// 315:
// 316:     missing_deps = @broken_deps.values.flatten.map { |d| dylib_to_dep(d) }
// 317:     unnecessary_deps -= missing_deps
// 318:
// 319:     version_hash = {}
// 320:     version_conflict_deps = Set.new
// 321:     @brewed_dylibs.each_key do |l|
// 322:       name = Utils.name_from_full_name(l)
// 323:       unversioned_name, = name.split("@")
// 324:       version_hash[unversioned_name] ||= Set.new
// 325:       version_hash[unversioned_name] << name
// 326:       next if version_hash[unversioned_name].length < 2
// 327:
// 328:       version_conflict_deps += version_hash[unversioned_name]
// 329:     end
// 330:
// 331:     [indirect_deps, undeclared_deps,
// 332:      unnecessary_deps, version_conflict_deps.to_a, no_linkage_deps_full_names, unexpected_linkage_deps]
// 333:   end
// 334:
// 335:   sig { params(arr: T::Array[String]).void }
// 336:   def sort_by_formula_full_name!(arr)
// 337:     arr.sort! do |a, b|
// 338:       if a.include?("/") && b.exclude?("/")
// 339:         1
// 340:       elsif a.exclude?("/") && b.include?("/")
// 341:         -1
// 342:       else
// 343:         (a <=> b).to_i
// 344:       end
// 345:     end
// 346:   end
// 347:
// 348:   # Whether or not dylib is a harmless broken link, meaning that it's
// 349:   # okay to skip (and not report) as broken.
// 350:   sig { params(dylib: String).returns(T::Boolean) }
// 351:   def harmless_broken_link?(dylib)
// 352:     # libgcc_s_* is referenced by programs that use the Java Service Wrapper,
// 353:     # and is harmless on x86(_64) machines
// 354:     # dyld will fall back to Apple libc++ if LLVM's is not available.
// 355:     [
// 356:       "/usr/lib/libgcc_s_ppc64.1.dylib",
// 357:       "/opt/local/lib/libgcc/libgcc_s.1.dylib",
// 358:       # TODO: Report linkage with `/usr/lib/libc++.1.dylib` when this link is broken.
// 359:       "#{HOMEBREW_PREFIX}/opt/llvm/lib/libc++.1.dylib",
// 360:     ].include?(dylib)
// 361:   end
// 362:
// 363:   sig { params(dylib: String).returns(T::Boolean) }
// 364:   def system_framework?(dylib)
// 365:     dylib.start_with?("/System/Library/Frameworks/")
// 366:   end
// 367:
// 368:   # Display a list of things.
// 369:   sig {
// 370:     params(
// 371:       label:       String,
// 372:       things:      T.any(T::Array[String], T::Set[String], T::Hash[String, T::Enumerable[String]]),
// 373:       puts_output: T::Boolean,
// 374:     ).returns(T.nilable(String))
// 375:   }
// 376:   def display_items(label, things, puts_output: true)
// 377:     return if things.empty?
// 378:
// 379:     output = ["#{label}:"]
// 380:     if things.is_a? Hash
// 381:       things.sort.each do |list_label, items|
// 382:         items.sort.each do |item|
// 383:           output << "#{item} (#{list_label})"
// 384:         end
// 385:       end
// 386:     else
// 387:       output.concat(things.sort)
// 388:     end
// 389:     output = output.join("\n  ")
// 390:     puts output if puts_output
// 391:     output
// 392:   end
// 393:
// 394:   sig { params(keg: Keg).returns(T.nilable(Formula)) }
// 395:   def resolve_formula(keg)
// 396:     Formulary.from_keg(keg)
// 397:   rescue FormulaUnavailableError
// 398:     opoo "Formula unavailable: #{keg.name}"
// 399:     nil
// 400:   end
// 401: end
// 402:
// 403: require "extend/os/linkage_checker"
