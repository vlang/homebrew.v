module homebrew

import ruby
import homebrew.utils
import os

// Translated from Homebrew/brew `linkage_checker.rb`.
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
