module homebrew

import brew_runtime
import json2
import os
import time

// Translated from Homebrew/brew `tab.rb`.
// The original source is retained below until every stub has a typed V body.
pub const tab_filename = 'INSTALL_RECEIPT.json'

pub struct RuntimeDependencyReceipt {
pub:
	full_name                 string
	version                   string
	revision                  int
	has_revision              bool
	bottle_rebuild            int
	has_bottle_rebuild        bool
	pkg_version               string
	declared_directly         bool
	has_declared_directly     bool
	compatibility_version     int
	has_compatibility_version bool
}

pub struct TabConfig {
pub:
	homebrew_version             string
	has_homebrew_version         bool
	tabfile                      string
	loaded_from_api              bool
	has_loaded_from_api          bool
	loaded_from_internal_api     bool
	has_loaded_from_internal_api bool
	installed_on_request         bool
	has_installed_on_request     bool
	time                         i64
	has_time                     bool
	arch                         string
	has_arch                     bool
	source                       map[string]json2.Any
	built_on                     map[string]json2.Any
	has_built_on                 bool
	runtime_dependencies         []RuntimeDependencyReceipt
	has_runtime_dependencies     bool
	poured_from_bottle           bool
	has_poured_from_bottle       bool
	built_as_bottle              bool
	has_built_as_bottle          bool
	stdlib                       string
	aliases                      []string
	has_aliases                  bool
	used_options                 []string
	unused_options               []string
	compiler                     string
	source_modified_time         i64
	has_source_modified_time     bool
	tapped_from                  string
	changed_files                []string
	has_changed_files            bool
}

pub struct Tab {
pub mut:
	installed_on_request         bool
	installed_on_request_present bool
	homebrew_version             string
	has_homebrew_version         bool
	tabfile                      string
	loaded_from_api              bool
	has_loaded_from_api          bool
	loaded_from_internal_api     bool
	has_loaded_from_internal_api bool
	time                         i64
	has_time                     bool
	arch                         string
	has_arch                     bool
	source                       map[string]json2.Any
	built_on                     map[string]json2.Any
	has_built_on                 bool
	runtime_dependency_entries   []RuntimeDependencyReceipt
	has_runtime_dependencies     bool
	poured_from_bottle           bool
	has_poured_from_bottle       bool
	built_as_bottle              bool
	has_built_as_bottle          bool
	stdlib                       string
	aliases                      []string
	has_aliases                  bool
	used_option_flags            []string
	unused_option_flags          []string
	compiler_value               string
	source_modified_time_value   i64
	has_source_modified_time     bool
	tapped_from                  string
	changed_files                []string
	has_changed_files            bool
}

pub fn new_tab(config TabConfig) Tab {
	return Tab{
		installed_on_request: config.installed_on_request
		installed_on_request_present: config.has_installed_on_request
		homebrew_version: config.homebrew_version
		has_homebrew_version: config.has_homebrew_version
		tabfile: config.tabfile
		loaded_from_api: config.loaded_from_api
		has_loaded_from_api: config.has_loaded_from_api
		loaded_from_internal_api: config.loaded_from_internal_api
		has_loaded_from_internal_api: config.has_loaded_from_internal_api
		time: config.time
		has_time: config.has_time
		arch: config.arch
		has_arch: config.has_arch
		source: config.source.clone()
		built_on: config.built_on.clone()
		has_built_on: config.has_built_on
		runtime_dependency_entries: config.runtime_dependencies.clone()
		has_runtime_dependencies: config.has_runtime_dependencies
		poured_from_bottle: config.poured_from_bottle
		has_poured_from_bottle: config.has_poured_from_bottle
		built_as_bottle: config.built_as_bottle
		has_built_as_bottle: config.has_built_as_bottle
		stdlib: config.stdlib
		aliases: config.aliases.clone()
		has_aliases: config.has_aliases
		used_option_flags: config.used_options.clone()
		unused_option_flags: config.unused_options.clone()
		compiler_value: config.compiler
		source_modified_time_value: config.source_modified_time
		has_source_modified_time: config.has_source_modified_time
		tapped_from: config.tapped_from
		changed_files: config.changed_files.clone()
		has_changed_files: config.has_changed_files
	}
}

fn current_homebrew_version() string {
	version := os.getenv('HOMEBREW_VERSION')
	return if version == '' { '0.0.0' } else { version }
}

fn current_tab_architecture() string {
	$if arm64 {
		return 'arm64'
	} $else $if amd64 {
		return 'x86_64'
	} $else {
		return 'unknown'
	}
}

pub fn abstract_tab_create_for_formula(formula Formula) Tab {
	return abstract_tab_create_from_metadata(formula.loaded_from_api(), false, formula.tap, formula.reference.tap_git_head)
}

pub fn abstract_tab_create_from_metadata(loaded_from_api bool, loaded_from_internal_api bool,
	tap_name string, tap_git_head string) Tab {
	return new_tab(TabConfig{
		homebrew_version: current_homebrew_version()
		has_homebrew_version: true
		loaded_from_api: loaded_from_api
		has_loaded_from_api: true
		loaded_from_internal_api: loaded_from_internal_api
		has_loaded_from_internal_api: true
		installed_on_request: false
		has_installed_on_request: true
		time: time.now().unix()
		has_time: true
		arch: current_tab_architecture()
		has_arch: true
		source: {
			'tap':          if tap_name == '' { json2.null } else { json2.Any(tap_name) }
			'tap_git_head': if tap_git_head == '' {
				json2.null} else {
				json2.Any(tap_git_head)}
		}
		built_on: map[string]json2.Any{}
		has_built_on: true
	})
}

pub fn formula_to_runtime_dependency_receipt(formula Formula, declared_deps []string) RuntimeDependencyReceipt {
	version := formula.version() or { null_version() }
	pkg_version := formula.pkg_version() or { new_pkg_version(version, formula.reference.revision) }
	return RuntimeDependencyReceipt{
		full_name: formula.full_name()
		version: version.to_s()
		revision: formula.reference.revision
		has_revision: true
		pkg_version: pkg_version.to_s()
		declared_directly: formula.full_name() in declared_deps
		has_declared_directly: true
		compatibility_version: formula.compatibility_version
		has_compatibility_version: formula.has_compatibility_version
	}
}

pub fn tab_create_for_formula(formula Formula, runtime_dependencies []Formula, compiler string,
	stdlib string, source_revision ...string) Tab {
	mut tab := abstract_tab_create_for_formula(formula)
	declared_dependencies := formula.deps().map(it.name)
	tab.used_option_flags = formula.build.used_options().as_flags()
	tab.unused_option_flags = formula.build.unused_options().as_flags()
	tab.tabfile = brew_runtime.join_path(formula.prefix(), tab_filename)
	tab.built_as_bottle = formula.build.bottle()
	tab.has_built_as_bottle = true
	tab.poured_from_bottle = false
	tab.has_poured_from_bottle = true
	tab.source_modified_time_value = formula.source_modified_time
	tab.has_source_modified_time = true
	tab.compiler_value = if compiler == '' { default_tab_compiler() } else { compiler }
	tab.stdlib = stdlib
	tab.aliases = formula.aliases()
	tab.has_aliases = true
	tab.runtime_dependency_entries = runtime_dependencies.map(formula_to_runtime_dependency_receipt(it, declared_dependencies))
	tab.has_runtime_dependencies = true
	tab.source['spec'] = json2.Any(formula.active_spec)
	tab.source['path'] = json2.Any(formula.specified_path())
	tab.source['versions'] = json2.Any({
		'stable':                if formula.reference.stable_version == '' {
			json2.null
		} else {
			json2.Any(formula.reference.stable_version)
		}
		'head':                  if formula.reference.head_version == '' {
			json2.null
		} else {
			json2.Any(formula.reference.head_version)
		}
		'version_scheme':        json2.Any(formula.reference.version_scheme)
		'compatibility_version': if formula.has_compatibility_version {
			json2.Any(formula.compatibility_version)
		} else {
			json2.null
		}
	})
	if source_revision.len > 0 && source_revision[0] != '' {
		tab.source['scm_revision'] = json2.Any(source_revision[0])
	}
	return tab
}

pub fn tab_for_formula(formula Formula) Tab {
	mut paths := []string{}
	if formula.optlinked() && brew_runtime.is_dir(formula.opt_prefix()) {
		paths << brew_runtime.real_path(formula.opt_prefix())
	}
	if brew_runtime.is_link(formula.linked_keg()) && brew_runtime.is_dir(formula.linked_keg()) {
		paths << brew_runtime.real_path(formula.linked_keg())
	}
	installed := formula.installed_prefixes()
	if installed.len == 1 { paths << installed[0] }
	paths << formula.latest_installed_prefix()
	for path in paths {
		receipt := brew_runtime.join_path(path, tab_filename)
		if brew_runtime.is_file(receipt) {
			mut result := tab_from_file(receipt) or { break }
			result.used_option_flags = remap_tab_deprecated_options(formula.deprecated_options(), result.used_options()).as_flags()
			return result
		}
	}
	mut result := empty_tab()
	result.unused_option_flags = formula.options().as_flags()
	result.source = {
		'path':         json2.Any(formula.specified_path())
		'tap':          if formula.tap == '' { json2.null } else { json2.Any(formula.tap) }
		'tap_git_head': if formula.reference.tap_git_head == '' {
			json2.null
		} else {
			json2.Any(formula.reference.tap_git_head)
		}
		'spec':         json2.Any(formula.active_spec)
		'versions':     json2.Any({
			'stable':         if formula.reference.stable_version == '' {
				json2.null
			} else {
				json2.Any(formula.reference.stable_version)
			}
			'head':           if formula.reference.head_version == '' {
				json2.null
			} else {
				json2.Any(formula.reference.head_version)
			}
			'version_scheme': json2.Any(formula.reference.version_scheme)
		})
	}
	return result
}

pub fn default_tab_compiler() string {
	$if macos {
		return 'clang'
	} $else {
		return 'gcc'
	}
}

pub fn empty_tab() Tab {
	return new_tab(TabConfig{
		homebrew_version: current_homebrew_version()
		has_homebrew_version: true
		has_installed_on_request: true
		has_loaded_from_api: true
		has_loaded_from_internal_api: true
		source: {
			'path':         json2.null
			'tap':          json2.null
			'tap_git_head': json2.null
			'spec':         json2.Any('stable')
			'versions':     json2.Any(empty_tab_source_versions())
		}
		has_built_on: true
		has_runtime_dependencies: false
		has_built_as_bottle: true
		has_poured_from_bottle: true
		has_aliases: true
		compiler: default_tab_compiler()
		has_source_modified_time: true
	})
}

pub fn empty_tab_source_versions() map[string]json2.Any {
	return {
		'stable':                json2.null
		'head':                  json2.null
		'version_scheme':        json2.Any(0)
		'compatibility_version': json2.null
	}
}

fn tab_any_string(attributes map[string]json2.Any, key string) (string, bool) {
	value := attributes[key] or { return '', false }
	if value is json2.Null {
		return '', false
	}
	return value.str(), true
}

fn tab_any_bool(attributes map[string]json2.Any, key string) (bool, bool) {
	value := attributes[key] or { return false, false }
	if value is json2.Null {
		return false, false
	}
	return value.bool(), true
}

fn tab_any_i64(attributes map[string]json2.Any, key string) (i64, bool) {
	value := attributes[key] or { return 0, false }
	if value is json2.Null {
		return 0, false
	}
	return value.i64(), true
}

fn tab_any_strings(attributes map[string]json2.Any, key string) ([]string, bool) {
	value := attributes[key] or { return []string{}, false }
	if value is json2.Null {
		return []string{}, false
	}
	return value.as_array().map(it.str()), true
}

fn runtime_dependency_from_any(value json2.Any) RuntimeDependencyReceipt {
	attributes := value.as_map()
	full_name, _ := tab_any_string(attributes, 'full_name')
	version, _ := tab_any_string(attributes, 'version')
	revision, has_revision := tab_any_i64(attributes, 'revision')
	bottle_rebuild, has_bottle_rebuild := tab_any_i64(attributes, 'bottle_rebuild')
	pkg_version, _ := tab_any_string(attributes, 'pkg_version')
	declared_directly, has_declared_directly := tab_any_bool(attributes, 'declared_directly')
	compatibility_version, has_compatibility_version := tab_any_i64(attributes, 'compatibility_version')
	return RuntimeDependencyReceipt{
		full_name: full_name
		version: version
		revision: int(revision)
		has_revision: has_revision
		bottle_rebuild: int(bottle_rebuild)
		has_bottle_rebuild: has_bottle_rebuild
		pkg_version: pkg_version
		declared_directly: declared_directly
		has_declared_directly: has_declared_directly
		compatibility_version: int(compatibility_version)
		has_compatibility_version: has_compatibility_version
	}
}

pub fn tab_from_json(content string, path string) !Tab {
	decoded := json2.decode[json2.Any](content) or { return error('Cannot parse ${path}: ${err}') }
	attributes := decoded.as_map()
	homebrew_version, has_homebrew_version := tab_any_string(attributes, 'homebrew_version')
	loaded_from_api, has_loaded_from_api := tab_any_bool(attributes, 'loaded_from_api')
	loaded_from_internal_api, has_loaded_from_internal_api := tab_any_bool(attributes, 'loaded_from_internal_api')
	installed_on_request, has_installed_on_request := tab_any_bool(attributes, 'installed_on_request')
	install_time, has_time := tab_any_i64(attributes, 'time')
	arch, has_arch := tab_any_string(attributes, 'arch')
	poured_from_bottle, has_poured_from_bottle := tab_any_bool(attributes, 'poured_from_bottle')
	built_as_bottle, has_built_as_bottle := tab_any_bool(attributes, 'built_as_bottle')
	stdlib, _ := tab_any_string(attributes, 'stdlib')
	aliases, has_aliases := tab_any_strings(attributes, 'aliases')
	used_options, _ := tab_any_strings(attributes, 'used_options')
	unused_options, _ := tab_any_strings(attributes, 'unused_options')
	compiler, _ := tab_any_string(attributes, 'compiler')
	source_modified_time, has_source_modified_time := tab_any_i64(attributes, 'source_modified_time')
	tapped_from, _ := tab_any_string(attributes, 'tapped_from')
	changed_files, has_changed_files := tab_any_strings(attributes, 'changed_files')
	mut runtime_dependencies := []RuntimeDependencyReceipt{}
	mut has_runtime_dependencies := false
	if runtime_any := attributes['runtime_dependencies'] {
		if runtime_any !is json2.Null {
			has_runtime_dependencies = true
			runtime_dependencies = runtime_any.as_array().map(runtime_dependency_from_any(it))
		}
	}
	mut tab := new_tab(TabConfig{
		homebrew_version: homebrew_version
		has_homebrew_version: has_homebrew_version
		tabfile: path
		loaded_from_api: loaded_from_api
		has_loaded_from_api: has_loaded_from_api
		loaded_from_internal_api: loaded_from_internal_api
		has_loaded_from_internal_api: has_loaded_from_internal_api
		installed_on_request: installed_on_request
		has_installed_on_request: has_installed_on_request
		time: install_time
		has_time: has_time
		arch: arch
		has_arch: has_arch
		source: (attributes['source'] or { json2.Any(map[string]json2.Any{}) }).as_map()
		built_on: (attributes['built_on'] or {
			json2.Any(map[string]json2.Any{})}).as_map()
		has_built_on: 'built_on' in attributes
		runtime_dependencies: runtime_dependencies
		has_runtime_dependencies: has_runtime_dependencies
		poured_from_bottle: poured_from_bottle
		has_poured_from_bottle: has_poured_from_bottle
		built_as_bottle: built_as_bottle
		has_built_as_bottle: has_built_as_bottle
		stdlib: stdlib
		aliases: aliases
		has_aliases: has_aliases
		used_options: used_options
		unused_options: unused_options
		compiler: compiler
		source_modified_time: source_modified_time
		has_source_modified_time: has_source_modified_time
		tapped_from: tapped_from
		changed_files: changed_files
		has_changed_files: has_changed_files
	})
	tab.normalize_from_file(path)!
	return tab
}

pub fn tab_from_file(path string) !Tab {
	content := brew_runtime.read_file(path)!
	if content.trim_space() == '' {
		mut tab := empty_tab()
		tab.tabfile = path
		return tab
	}
	return tab_from_json(content, path)
}

pub fn tab_for_keg(path string) !Tab {
	receipt_path := brew_runtime.join_path(path, tab_filename)
	mut tab := if brew_runtime.is_file(receipt_path) {
		tab_from_file(receipt_path)!
	} else {
		empty_tab()
	}
	tab.tabfile = receipt_path
	return tab
}

fn (mut tab Tab) normalize_from_file(path string) ! {
	if tab.tapped_from != '' && tab.tapped_from != 'path or URL' {
		tab.set_tap(tab.tapped_from)
	}
	if tab.tap_name() in ['mxcl/master', 'Homebrew/homebrew'] {
		tab.set_tap('homebrew/core')
	}
	if 'spec' !in tab.source {
		parent := os.base(os.dir(path))
		version := parse_pkg_version(parent)!
		tab.source['spec'] = json2.Any(if version.head() { 'head' } else { 'stable' })
	}
	if 'versions' !in tab.source {
		tab.source['versions'] = json2.Any(empty_tab_source_versions())
	}
	mut versions := tab.versions()
	for spec in ['stable', 'head'] {
		if value := versions[spec] {
			if value.str() == '' {
				versions[spec] = json2.null
			}
		}
	}
	tab.source['versions'] = json2.Any(versions)
}

pub fn (tab Tab) parsed_homebrew_version() Version {
	if !tab.has_homebrew_version {
		return null_version()
	}
	return new_version(tab.homebrew_version) or { null_version() }
}

pub fn (tab Tab) tap_name() string {
	value := tab.source['tap'] or { return '' }
	if value is json2.Null {
		return ''
	}
	return value.str()
}

pub fn (mut tab Tab) set_tap(tap string) {
	tab.source['tap'] = if tap == '' { json2.null } else { json2.Any(tap) }
}

pub fn (tab Tab) used_options() Options {
	return new_options(...tab.used_option_flags)
}

pub fn (tab Tab) unused_options() Options {
	return new_options(...tab.unused_option_flags)
}

pub fn (tab Tab) any_args_or_options() bool {
	return !tab.used_options().empty() || !tab.unused_options().empty()
}

pub fn (tab Tab) includes(option string) bool {
	return tab.used_options().contains(option)
}

pub fn (tab Tab) with(name string) bool {
	return tab.includes('with-${name}') || tab.unused_options().contains('without-${name}')
}

pub fn (tab Tab) with_dependency(dependency Dependency) bool {
	return dependency.option_names().any(tab.with(it))
}

pub fn (tab Tab) without(name string) bool {
	return !tab.with(name)
}

pub fn (tab Tab) head() bool {
	return tab.spec() == 'head'
}

pub fn (tab Tab) stable() bool {
	return tab.spec() == 'stable'
}

pub fn (tab Tab) compiler() string {
	return if tab.compiler_value == '' { default_tab_compiler() } else { tab.compiler_value }
}

pub fn (tab Tab) runtime_dependencies() ?[]RuntimeDependencyReceipt {
	minimum := new_version('1.1.6') or { return none }
	if !tab.has_runtime_dependencies || tab.parsed_homebrew_version().compare_to(minimum) < 0 {
		return none
	}
	return tab.runtime_dependency_entries.clone()
}

pub fn (tab Tab) cxxstdlib() CxxStdlib {
	return create_cxxstdlib(tab.stdlib, tab.compiler()) or {
		create_cxxstdlib('', tab.compiler()) or { CxxStdlib{} }
	}
}

pub fn (tab Tab) built_bottle() bool {
	return tab.built_as_bottle && !tab.poured_from_bottle
}

pub fn (tab Tab) bottle() bool {
	return tab.built_as_bottle
}

pub fn (tab Tab) spec() string {
	return (tab.source['spec'] or { json2.Any('stable') }).str()
}

pub fn (tab Tab) versions() map[string]json2.Any {
	return (tab.source['versions'] or { json2.Any(empty_tab_source_versions()) }).as_map()
}

pub fn (tab Tab) stable_version() ?Version {
	value := tab.versions()['stable'] or { return none }
	if value is json2.Null || value.str() == '' {
		return none
	}
	return new_version(value.str()) or { return none }
}

pub fn (tab Tab) head_version() ?Version {
	value := tab.versions()['head'] or { return none }
	if value is json2.Null || value.str() == '' {
		return none
	}
	return new_version(value.str()) or { return none }
}

pub fn (tab Tab) version_scheme() int {
	return (tab.versions()['version_scheme'] or { json2.Any(0) }).int()
}

pub fn (tab Tab) source_modified_time() i64 {
	return tab.source_modified_time_value
}

fn runtime_dependency_to_any(dependency RuntimeDependencyReceipt) json2.Any {
	mut attributes := map[string]json2.Any{}
	attributes['full_name'] = json2.Any(dependency.full_name)
	attributes['version'] = json2.Any(dependency.version)
	if dependency.has_revision {
		attributes['revision'] = json2.Any(dependency.revision)
	}
	if dependency.has_bottle_rebuild {
		attributes['bottle_rebuild'] = json2.Any(dependency.bottle_rebuild)
	}
	if dependency.pkg_version != '' {
		attributes['pkg_version'] = json2.Any(dependency.pkg_version)
	}
	if dependency.has_declared_directly {
		attributes['declared_directly'] = json2.Any(dependency.declared_directly)
	}
	if dependency.has_compatibility_version {
		attributes['compatibility_version'] = json2.Any(dependency.compatibility_version)
	}
	return json2.Any(attributes)
}

fn strings_to_any(values []string) json2.Any {
	return json2.Any(values.map(json2.Any(it)))
}

pub fn (tab Tab) json_attributes() map[string]json2.Any {
	mut attributes := map[string]json2.Any{}
	attributes['homebrew_version'] = if tab.has_homebrew_version {
		json2.Any(tab.homebrew_version)
	} else {
		json2.null
	}
	attributes['used_options'] = strings_to_any(tab.used_options().as_flags())
	attributes['unused_options'] = strings_to_any(tab.unused_options().as_flags())
	attributes['built_as_bottle'] = if tab.has_built_as_bottle {
		json2.Any(tab.built_as_bottle)
	} else {
		json2.null
	}
	attributes['poured_from_bottle'] = if tab.has_poured_from_bottle {
		json2.Any(tab.poured_from_bottle)
	} else {
		json2.null
	}
	attributes['loaded_from_api'] = if tab.has_loaded_from_api {
		json2.Any(tab.loaded_from_api)
	} else {
		json2.null
	}
	attributes['loaded_from_internal_api'] = if tab.has_loaded_from_internal_api {
		json2.Any(tab.loaded_from_internal_api)
	} else {
		json2.null
	}
	attributes['installed_on_request'] = json2.Any(tab.installed_on_request)
	attributes['changed_files'] = if tab.has_changed_files {
		strings_to_any(tab.changed_files)
	} else {
		json2.null
	}
	attributes['time'] = if tab.has_time { json2.Any(tab.time) } else { json2.null }
	attributes['source_modified_time'] = json2.Any(tab.source_modified_time())
	attributes['compiler'] = json2.Any(tab.compiler())
	attributes['aliases'] = if tab.has_aliases { strings_to_any(tab.aliases) } else { json2.null }
	attributes['runtime_dependencies'] = if dependencies := tab.runtime_dependencies() {
		json2.Any(dependencies.map(runtime_dependency_to_any(it)))
	} else {
		json2.null
	}
	attributes['source'] = json2.Any(tab.source)
	attributes['arch'] = if tab.has_arch { json2.Any(tab.arch) } else { json2.null }
	attributes['built_on'] = if tab.has_built_on { json2.Any(tab.built_on) } else { json2.null }
	if tab.stdlib != '' {
		attributes['stdlib'] = json2.Any(tab.stdlib)
	}
	return attributes
}

pub fn (tab Tab) to_json() string {
	return json2.encode(json2.Any(tab.json_attributes()), prettify: true)
}

pub fn (tab Tab) bottle_attributes() map[string]json2.Any {
	mut attributes := map[string]json2.Any{}
	attributes['homebrew_version'] = if tab.has_homebrew_version {
		json2.Any(tab.homebrew_version)
	} else {
		json2.null
	}
	attributes['changed_files'] = if tab.has_changed_files {
		strings_to_any(tab.changed_files)
	} else {
		json2.null
	}
	attributes['source_modified_time'] = json2.Any(tab.source_modified_time())
	attributes['compiler'] = json2.Any(tab.compiler())
	attributes['runtime_dependencies'] = if dependencies := tab.runtime_dependencies() {
		json2.Any(dependencies.map(runtime_dependency_to_any(it)))
	} else {
		json2.null
	}
	attributes['arch'] = if tab.has_arch { json2.Any(tab.arch) } else { json2.null }
	attributes['built_on'] = if tab.has_built_on { json2.Any(tab.built_on) } else { json2.null }
	if tab.stdlib != '' {
		attributes['stdlib'] = json2.Any(tab.stdlib)
	}
	if revision := tab.source['scm_revision'] {
		if revision !is json2.Null && revision.str() != '' {
			attributes['source'] = json2.Any({
				'scm_revision': revision
			})
		}
	}
	return attributes
}

pub fn (tab Tab) write() ! {
	if tab.tabfile == '' {
		return error('No tabfile to write to')
	}
	temporary := '${tab.tabfile}.tmp-${os.getpid()}'
	os.write_file(temporary, tab.to_json())!
	os.rename(temporary, tab.tabfile)!
}

pub fn (tab Tab) str() string {
	mut parts := [
		if tab.poured_from_bottle { 'Poured from bottle' } else { 'Built from source' },
	]
	if tab.loaded_from_internal_api {
		parts << 'using the internal formulae.brew.sh API'
	} else if tab.loaded_from_api {
		parts << 'using the formulae.brew.sh API'
	}
	if tab.has_time {
		parts << 'on ${time.unix(tab.time).format_ss().replace(' ', ' at ')}'
	}
	if !tab.used_options().empty() {
		parts << 'with:'
		parts << tab.used_options().to_array().map(it.str()).join(' ')
	}
	return parts.join(' ')
}

pub fn remap_tab_deprecated_options(deprecated []DeprecatedOption, options Options) Options {
	mut result := options
	for deprecated_option in deprecated {
		for option in result.to_array() {
			if option.name == deprecated_option.old {
				result = result.minus(new_options(option.flag))
				mut replacement := new_options(deprecated_option.current)
				result = result.plus(replacement)
				break
			}
		}
	}
	return result
}

pub fn tab_boundary_value(tab Tab) brew_runtime.Value {
	return brew_runtime.structured_value('Tab', tab.to_json(), {
		'json': tab.to_json()
	})
}

pub fn tab_from_boundary(value brew_runtime.Value) Tab {
	if value.type_name != 'Tab' {
		panic('expected Tab, got ${value.type_name}')
	}
	content := value.attribute('json') or { value.as_string() }
	return tab_from_json(content, '') or { panic(err) }
}

fn tab_boundary_receiver(args []brew_runtime.Value, method string) Tab {
	if args.len == 0 {
		panic('Tab#${method} requires a receiver')
	}
	return tab_from_boundary(args[0])
}

// Ruby attr_accessor `attr_accessor :installed_on_request` at line 29.
pub fn ruby_tab_l29_d1_installed_on_request(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(tab_boundary_receiver(args, 'installed_on_request').installed_on_request)
}

// Ruby attr_accessor `attr_accessor :installed_on_request` at line 29.
pub fn ruby_tab_l29_d2_installed_on_request(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_boundary_receiver(args, 'installed_on_request=')
	if args.len < 2 { panic('installed_on_request= requires a value') }
	tab.installed_on_request = args[1].as_bool() or { panic(err) }
	tab.installed_on_request_present = true
	return tab_boundary_value(tab)
}

// Ruby attr_accessor `attr_accessor :homebrew_version` at line 32.
pub fn ruby_tab_l32_d3_homebrew_version(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_boundary_receiver(args, 'homebrew_version')
	return if tab.has_homebrew_version {
		brew_runtime.string_value(tab.homebrew_version)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby attr_accessor `attr_accessor :homebrew_version` at line 32.
pub fn ruby_tab_l32_d4_homebrew_version(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_boundary_receiver(args, 'homebrew_version=')
	if args.len < 2 { panic('homebrew_version= requires a value') }
	tab.has_homebrew_version = args[1].type_name != 'NilClass'
	tab.homebrew_version = if tab.has_homebrew_version { args[1].as_string() } else { '' }
	return tab_boundary_value(tab)
}

// Ruby attr_accessor `attr_accessor :tabfile` at line 35.
pub fn ruby_tab_l35_d5_tabfile(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_boundary_receiver(args, 'tabfile')
	return if tab.tabfile == '' {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		brew_runtime.string_value(tab.tabfile)
	}
}

// Ruby attr_accessor `attr_accessor :tabfile` at line 35.
pub fn ruby_tab_l35_d6_tabfile(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_boundary_receiver(args, 'tabfile=')
	if args.len < 2 { panic('tabfile= requires a value') }
	tab.tabfile = if args[1].type_name == 'NilClass' { '' } else { args[1].as_string() }
	return tab_boundary_value(tab)
}

// Ruby attr_accessor `attr_accessor :loaded_from_api` at line 38.
pub fn ruby_tab_l38_d7_loaded_from_api(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_boundary_receiver(args, 'loaded_from_api')
	return if tab.has_loaded_from_api {
		brew_runtime.bool_value(tab.loaded_from_api)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby attr_accessor `attr_accessor :loaded_from_api` at line 38.
pub fn ruby_tab_l38_d8_loaded_from_api(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_boundary_receiver(args, 'loaded_from_api=')
	if args.len < 2 { panic('loaded_from_api= requires a value') }
	tab.has_loaded_from_api = args[1].type_name != 'NilClass'
	tab.loaded_from_api = if tab.has_loaded_from_api {
		args[1].as_bool() or { panic(err) }
	} else {
		false
	}
	return tab_boundary_value(tab)
}

// Ruby attr_accessor `attr_accessor :loaded_from_internal_api` at line 41.
pub fn ruby_tab_l41_d9_loaded_from_internal_api(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_boundary_receiver(args, 'loaded_from_internal_api')
	return if tab.has_loaded_from_internal_api {
		brew_runtime.bool_value(tab.loaded_from_internal_api)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby attr_accessor `attr_accessor :loaded_from_internal_api` at line 41.
pub fn ruby_tab_l41_d10_loaded_from_internal_api(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_boundary_receiver(args, 'loaded_from_internal_api=')
	if args.len < 2 { panic('loaded_from_internal_api= requires a value') }
	tab.has_loaded_from_internal_api = args[1].type_name != 'NilClass'
	tab.loaded_from_internal_api = if tab.has_loaded_from_internal_api {
		args[1].as_bool() or {
			panic(err)
		}
	} else {
		false
	}
	return tab_boundary_value(tab)
}

// Ruby attr_accessor `attr_accessor :time` at line 44.
pub fn ruby_tab_l44_d11_time(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_boundary_receiver(args, 'time')
	return if tab.has_time {
		brew_runtime.int_value(tab.time)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby attr_accessor `attr_accessor :time` at line 44.
pub fn ruby_tab_l44_d12_time(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_boundary_receiver(args, 'time=')
	if args.len < 2 { panic('time= requires a value') }
	tab.has_time = args[1].type_name != 'NilClass'
	tab.time = if tab.has_time { args[1].as_int() or { panic(err) } } else { 0 }
	return tab_boundary_value(tab)
}

// Ruby attr_accessor `attr_accessor :arch` at line 47.
pub fn ruby_tab_l47_d13_arch(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_boundary_receiver(args, 'arch')
	return if tab.has_arch {
		brew_runtime.string_value(tab.arch)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby attr_accessor `attr_accessor :arch` at line 47.
pub fn ruby_tab_l47_d14_arch(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_boundary_receiver(args, 'arch=')
	if args.len < 2 { panic('arch= requires a value') }
	tab.has_arch = args[1].type_name != 'NilClass'
	tab.arch = if tab.has_arch { args[1].as_string() } else { '' }
	return tab_boundary_value(tab)
}

// Ruby attr_accessor `attr_accessor :source` at line 50.
pub fn ruby_tab_l50_d15_source(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_boundary_receiver(args, 'source')
	return brew_runtime.object_value('Hash', json2.encode(json2.Any(tab.source)))
}

// Ruby attr_accessor `attr_accessor :source` at line 50.
pub fn ruby_tab_l50_d16_source(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_boundary_receiver(args, 'source=')
	if args.len < 2 { panic('source= requires a value') }
	tab.source = json2.decode[json2.Any](args[1].as_string()) or { panic(err) }.as_map()
	return tab_boundary_value(tab)
}

// Ruby attr_accessor `attr_accessor :built_on` at line 53.
pub fn ruby_tab_l53_d17_built_on(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_boundary_receiver(args, 'built_on')
	return if tab.has_built_on {
		brew_runtime.object_value('Hash', json2.encode(json2.Any(tab.built_on)))
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby attr_accessor `attr_accessor :built_on` at line 53.
pub fn ruby_tab_l53_d18_built_on(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_boundary_receiver(args, 'built_on=')
	if args.len < 2 { panic('built_on= requires a value') }
	tab.has_built_on = args[1].type_name != 'NilClass'
	tab.built_on = if tab.has_built_on {
		(json2.decode[json2.Any](args[1].as_string()) or { panic(err) }).as_map()
	} else {
		map[string]json2.Any{}
	}
	return tab_boundary_value(tab)
}

// Ruby attr_accessor `attr_accessor :runtime_dependencies` at line 59.
pub fn ruby_tab_l59_d19_runtime_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_boundary_receiver(args, 'runtime_dependencies')
	return if dependencies := tab.runtime_dependencies() {
		brew_runtime.object_value('Array', json2.encode(dependencies.map(runtime_dependency_to_any(it))))
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby attr_accessor `attr_accessor :runtime_dependencies` at line 59.
pub fn ruby_tab_l59_d20_runtime_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_boundary_receiver(args, 'runtime_dependencies=')
	if args.len < 2 { panic('runtime_dependencies= requires a value') }
	tab.has_runtime_dependencies = args[1].type_name != 'NilClass'
	if tab.has_runtime_dependencies {
		decoded := json2.decode[json2.Any](args[1].as_string()) or { panic(err) }
		tab.runtime_dependency_entries = decoded.as_array().map(runtime_dependency_from_any(it))
	}
	return tab_boundary_value(tab)
}

// Ruby method `initialize(homebrew_version: nil, tabfile: nil, loaded_from_api: nil, loaded_from_internal_api: nil,` at line 76.
pub fn ruby_tab_l76_d21_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return tab_boundary_value(new_tab(TabConfig{}))
	}
	if args[0].type_name == 'Hash' {
		return tab_boundary_value(tab_from_json(args[0].as_string(), '') or {
			panic(err)
		})
	}
	panic('AbstractTab#initialize expects translated keyword attributes')
}

// Ruby method `self.create(formula_or_cask)` at line 94.
pub fn ruby_tab_l94_d22_self_create(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('AbstractTab.create requires a Formula or Cask') }
	if args[0].type_name == 'Formula' {
		return tab_boundary_value(abstract_tab_create_for_formula(formula_from_boundary(args[0])))
	}
	if args[0].type_name != 'Cask' {
		panic('AbstractTab.create requires a Formula or Cask')
	}
	loaded_from_api := (args[0].attribute('loaded_from_api') or { 'false' }).bool()
	loaded_from_internal_api := (args[0].attribute('loaded_from_internal_api') or { 'false' }).bool()
	tap_name := args[0].attribute('tap') or { '' }
	tap_git_head := args[0].attribute('tap_git_head') or { '' }
	return tab_boundary_value(abstract_tab_create_from_metadata(loaded_from_api, loaded_from_internal_api, tap_name, tap_git_head))
}

// Ruby method `self.from_file(path)` at line 114.
pub fn ruby_tab_l114_d23_self_from_file(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('AbstractTab.from_file requires a path') }
	return tab_boundary_value(tab_from_file(args[0].as_string()) or { panic(err) })
}

// Ruby method `self.from_file_content(content, path)` at line 125.
pub fn ruby_tab_l125_d24_self_from_file_content(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('AbstractTab.from_file_content requires content and path') }
	return tab_boundary_value(tab_from_json(args[0].as_string(), args[1].as_string()) or {
		panic(err)
	})
}

// Ruby method `self.empty` at line 137.
pub fn ruby_tab_l137_d25_self_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return tab_boundary_value(empty_tab())
}

// Ruby method `self.formula_to_dep_hash(formula, declared_deps)` at line 156.
pub fn ruby_tab_l156_d26_self_formula_to_dep_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 || args[0].type_name != 'Formula' {
		panic('AbstractTab.formula_to_dep_hash requires Formula and declared dependencies')
	}
	receipt := formula_to_runtime_dependency_receipt(formula_from_boundary(args[0]), args[1].as_string_array() or {
		panic(err)
	})
	return brew_runtime.object_value('Hash', json2.encode(runtime_dependency_to_any(receipt)))
}

// Ruby method `parsed_homebrew_version` at line 170.
pub fn ruby_tab_l170_d27_parsed_homebrew_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Version', tab_boundary_receiver(args, 'parsed_homebrew_version').parsed_homebrew_version().to_s())
}

// Ruby method `installed_on_request_present? = @installed_on_request_present` at line 178.
pub fn ruby_tab_l178_d28_installed_on_request_present(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(tab_boundary_receiver(args, 'installed_on_request_present?').installed_on_request_present)
}

// Ruby method `tap` at line 181.
pub fn ruby_tab_l181_d29_tap(args ...brew_runtime.Value) brew_runtime.Value {
	tap := tab_boundary_receiver(args, 'tap').tap_name()
	return if tap == '' {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		brew_runtime.object_value('Tap', tap)
	}
}

// Ruby method `tap=(tap)` at line 187.
pub fn ruby_tab_l187_d30_tap(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_boundary_receiver(args, 'tap=')
	if args.len < 2 { panic('tap= requires a value') }
	tab.set_tap(if args[1].type_name == 'NilClass' { '' } else { args[1].as_string() })
	return tab_boundary_value(tab)
}

// Ruby method `write` at line 193.
pub fn ruby_tab_l193_d31_write(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_boundary_receiver(args, 'write')
	tab.write() or { panic(err) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cxxstdlib"
// 5: require "options"
// 6: require "json"
// 7: require "development_tools"
// 8: require "cachable"
// 9:
// 10: # Rather than calling `new` directly, use one of the class methods like {Tab.create}.
// 11: class AbstractTab
// 12:   extend T::Generic
// 13:   extend Cachable
// 14:   extend T::Helpers
// 15:
// 16:   Cache = type_template { { fixed: T::Hash[T.any(Pathname, String), T.untyped] } }
// 17:
// 18:   FILENAME = "INSTALL_RECEIPT.json"
// 19:
// 20:   RuntimeDependencies = T.type_alias do
// 21:     T.nilable(T.any(T::Array[String], T::Array[T::Hash[String, T.untyped]], T::Hash[String, T.untyped],
// 22:                     T::Hash[Symbol, T.untyped]))
// 23:   end
// 24:
// 25:   # Check whether the formula or cask was installed on request.
// 26:   #
// 27:   # @api internal
// 28:   sig { returns(T::Boolean) }
// 29:   attr_accessor :installed_on_request
// 30:
// 31:   sig { returns(T.nilable(String)) }
// 32:   attr_accessor :homebrew_version
// 33:
// 34:   sig { returns(T.nilable(Pathname)) }
// 35:   attr_accessor :tabfile
// 36:
// 37:   sig { returns(T.nilable(T::Boolean)) }
// 38:   attr_accessor :loaded_from_api
// 39:
// 40:   sig { returns(T.nilable(T::Boolean)) }
// 41:   attr_accessor :loaded_from_internal_api
// 42:
// 43:   sig { returns(T.nilable(Integer)) }
// 44:   attr_accessor :time
// 45:
// 46:   sig { returns(T.nilable(T.any(String, Symbol))) }
// 47:   attr_accessor :arch
// 48:
// 49:   sig { returns(T::Hash[String, T.untyped]) }
// 50:   attr_accessor :source
// 51:
// 52:   sig { returns(T.nilable(T::Hash[String, T.untyped])) }
// 53:   attr_accessor :built_on
// 54:
// 55:   # Returns the formula or cask runtime dependencies.
// 56:   #
// 57:   # @api internal
// 58:   sig { returns(RuntimeDependencies) }
// 59:   attr_accessor :runtime_dependencies
// 60:
// 61:   # Unrecognised attributes are ignored so that receipts written by other
// 62:   # Homebrew versions (e.g. the long-removed `installed_as_dependency`) still load.
// 63:   sig {
// 64:     params(homebrew_version:         T.nilable(String),
// 65:            tabfile:                  T.nilable(T.any(Pathname, String)),
// 66:            loaded_from_api:          T.nilable(T::Boolean),
// 67:            loaded_from_internal_api: T.nilable(T::Boolean),
// 68:            installed_on_request:     T.nilable(T::Boolean),
// 69:            time:                     T.nilable(Integer),
// 70:            arch:                     T.nilable(T.any(String, Symbol)),
// 71:            source:                   T.nilable(T::Hash[String, T.untyped]),
// 72:            built_on:                 T.nilable(T::Hash[String, T.untyped]),
// 73:            runtime_dependencies:     RuntimeDependencies,
// 74:            _unknown:                 T.anything).void
// 75:   }
// 76:   def initialize(homebrew_version: nil, tabfile: nil, loaded_from_api: nil, loaded_from_internal_api: nil,
// 77:                  installed_on_request: nil, time: nil, arch: nil, source: nil, built_on: nil,
// 78:                  runtime_dependencies: nil, **_unknown)
// 79:     @installed_on_request = T.let(installed_on_request || false, T::Boolean)
// 80:     @installed_on_request_present = T.let(!installed_on_request.nil?, T::Boolean)
// 81:     @homebrew_version = homebrew_version
// 82:     @tabfile = T.let(tabfile.nil? ? nil : Pathname(tabfile), T.nilable(Pathname))
// 83:     @loaded_from_api = loaded_from_api
// 84:     @loaded_from_internal_api = loaded_from_internal_api
// 85:     @time = time
// 86:     @arch = arch
// 87:     @source = T.let(source || {}, T::Hash[String, T.untyped])
// 88:     @built_on = built_on
// 89:     @runtime_dependencies = runtime_dependencies
// 90:   end
// 91:
// 92:   # Instantiates a {Tab} for a new installation of a formula or cask.
// 93:   sig { params(formula_or_cask: T.any(Formula, Cask::Cask)).returns(T.attached_class) }
// 94:   def self.create(formula_or_cask)
// 95:     new(
// 96:       homebrew_version:         HOMEBREW_VERSION,
// 97:       installed_on_request:     false,
// 98:       loaded_from_api:          formula_or_cask.loaded_from_api?,
// 99:       loaded_from_internal_api: formula_or_cask.loaded_from_internal_api?,
// 100:       time:                     Time.now.to_i,
// 101:       arch:                     Hardware::CPU.arch,
// 102:       source:                   {
// 103:         "tap"          => formula_or_cask.tap&.name,
// 104:         "tap_git_head" => formula_or_cask.tap_git_head,
// 105:       },
// 106:       built_on:                 DevelopmentTools.build_system_info,
// 107:     )
// 108:   end
// 109:
// 110:   # Returns the {Tab} for a formula or cask install receipt at `path`.
// 111:   #
// 112:   # NOTE: Results are cached.
// 113:   sig { params(path: T.any(Pathname, String)).returns(T.attached_class) }
// 114:   def self.from_file(path)
// 115:     cache.fetch(path) do |p|
// 116:       content = File.read(p)
// 117:       return empty if content.blank?
// 118:
// 119:       cache[p] = from_file_content(content, p)
// 120:     end
// 121:   end
// 122:
// 123:   # Like {from_file}, but bypass the cache.
// 124:   sig { params(content: String, path: T.any(Pathname, String)).returns(T.attached_class) }
// 125:   def self.from_file_content(content, path)
// 126:     attributes = begin
// 127:       JSON.parse(content)
// 128:     rescue JSON::ParserError => e
// 129:       raise e, "Cannot parse #{path}: #{e}", e.backtrace
// 130:     end
// 131:     attributes["tabfile"] = path
// 132:
// 133:     new(**attributes.transform_keys(&:to_sym))
// 134:   end
// 135:
// 136:   sig { returns(T.attached_class) }
// 137:   def self.empty
// 138:     new(
// 139:       homebrew_version:         HOMEBREW_VERSION,
// 140:       installed_on_request:     false,
// 141:       loaded_from_api:          false,
// 142:       loaded_from_internal_api: false,
// 143:       time:                     nil,
// 144:       runtime_dependencies:     nil,
// 145:       arch:                     nil,
// 146:       source:                   {
// 147:         "path"         => nil,
// 148:         "tap"          => nil,
// 149:         "tap_git_head" => nil,
// 150:       },
// 151:       built_on:                 DevelopmentTools.build_system_info,
// 152:     )
// 153:   end
// 154:
// 155:   sig { params(formula: Formula, declared_deps: T::Array[String]).returns(T::Hash[String, T.untyped]) }
// 156:   def self.formula_to_dep_hash(formula, declared_deps)
// 157:     {
// 158:       "full_name"             => formula.full_name,
// 159:       "version"               => formula.version.to_s,
// 160:       "revision"              => formula.revision,
// 161:       "bottle_rebuild"        => formula.bottle&.rebuild,
// 162:       "pkg_version"           => formula.pkg_version.to_s,
// 163:       "declared_directly"     => declared_deps.include?(formula.full_name),
// 164:       "compatibility_version" => formula.compatibility_version,
// 165:     }.compact
// 166:   end
// 167:   private_class_method :formula_to_dep_hash
// 168:
// 169:   sig { returns(Version) }
// 170:   def parsed_homebrew_version
// 171:     homebrew_version = self.homebrew_version
// 172:     return Version::NULL if homebrew_version.nil?
// 173:
// 174:     Version.new(homebrew_version)
// 175:   end
// 176:
// 177:   sig { returns(T::Boolean) }
// 178:   def installed_on_request_present? = @installed_on_request_present
// 179:
// 180:   sig { returns(T.nilable(Tap)) }
// 181:   def tap
// 182:     tap_name = source["tap"]
// 183:     Tap.fetch(tap_name) if tap_name
// 184:   end
// 185:
// 186:   sig { params(tap: T.nilable(T.any(Tap, String))).void }
// 187:   def tap=(tap)
// 188:     tap_name = tap.is_a?(Tap) ? tap.name : tap
// 189:     source["tap"] = tap_name
// 190:   end
// 191:
// 192:   sig { void }
// 193:   def write
// 194:     tfile = tabfile
// 195:     raise "No tabfile to write to" unless tfile
// 196:
// 197:     self.class.cache[tfile] = self
// 198:     tfile.atomic_write(to_json)
// 199:   end
// 200: end
// 201: require "tab/tab"
