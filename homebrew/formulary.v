module homebrew

import ruby
import crypto.md5
import crypto.sha256
import homebrew.api
import os
import time

// Translated from Homebrew/brew `formulary.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum FormulaLoaderKind {
	api
	local_json
	local_ruby
	tap
	uri
	bottle
	path
	name
	keg
	cache
	contents
	json_contents
	null_loader
	unavailable
}

pub struct FormulaLoaderDecision {
pub:
	kind FormulaLoaderKind
	name string
	path string
}

pub struct FormularyLoadedClass {
pub:
	name                            string
	class_name                      string
	path                            string
	namespace                       string
	contents                        string
	flags                           []string
	reference                       api.PackageReference
	post_install_defined            bool
	caveats                         string
	tap_git_head                    string
	oldnames                        []string
	aliases                         []string
	versioned_formulae_names        []string
	ruby_source_path                string
	ruby_source_checksum            string
	loaded_from_api                 bool
	loaded_from_internal_api        bool
	printed_output                  string
	post_install_steps              []string
	post_install_steps_defined      bool
	keg_only_reason                 string
	conflicts                       []string
	link_overwrite_paths            []string
	service_block                   string
	deprecation_date                string
	deprecation_replacement_formula string
	deprecation_replacement_cask    string
	disable_date                    string
	disable_replacement_formula     string
	disable_replacement_cask        string
	patches                         []string
	requirements                    []string
}

pub struct FormularyPlatformCache {
pub mut:
	enabled      bool
	path_classes map[string]FormularyLoadedClass
	api_classes  map[string]FormularyLoadedClass
	factory      map[string]Formula
}

pub struct FormularyLoadContext {
pub:
	disable_load_formula bool
	trusted              bool = true
	evaluation_error     string
	ignorable_error      bool
	class_constants      []string
	printed_output       string
}

pub struct FormularyTap {
pub:
	name                     string
	path                     string
	formula_dir              string
	alias_dir                string
	core_tap                 bool
	core_cask_tap            bool
	installed                bool = true
	issues_url               string
	aliases                  map[string]string
	formula_renames          map[string]string
	tap_migrations           map[string]string
	formula_files_by_name    map[string]string
	api_formula_names        []string
	new_formula_subdirectory map[string]string
}

pub struct TapFormulaNameType {
pub:
	name       string
	tap        FormularyTap
	type_name  string
	alias_name string
	old_name   string
	new_name   string
	warning    string
}

pub struct FormularyLoader {
pub:
	available           bool = true
	kind                FormulaLoaderKind
	name                string
	path                string
	alias_path          string
	tap                 FormularyTap
	has_tap             bool
	url                 string
	from                string
	contents            string
	loaded_class        FormularyLoadedClass
	bottle_path         string
	cellar_formula_path string
	error_message       string
	warning             string
}

pub struct FormularyLoaderInput {
pub:
	ref                   string
	from                  string
	warn                  bool
	forbid_paths          bool
	exists                bool
	is_file               bool
	is_symlink            bool
	resolved_path         string
	loadable_formula_path bool
	tap                   FormularyTap
	has_tap               bool
	api_tap_name          string
	bottle_extension      bool
	bottle_name           string
	bottle_full_name      string
	bottle_version        string
	cache_formula_dir     string
	prefix                string
	cellar                string
	core_formula_dir      string
	api_enabled           bool = true
	api_formula_names     []string
	api_aliases           map[string]string
	api_renames           map[string]string
	installed_taps        []FormularyTap
	keg_name              string
	keg_formula_path      string
	keg_tap               FormularyTap
	keg_exists            bool
}

fn formulary_extract_quoted(contents string, directive string) string {
	for line in contents.split_into_lines() {
		trimmed := line.trim_space()
		if !trimmed.starts_with('${directive} ') {
			continue
		}
		value := trimmed.all_after('${directive} ').trim_space()
		if value.len >= 2 && ((value[0] == `"` && value[value.len - 1] == `"`) || (value[0] == `'` && value[value.len - 1] == `'`)) {
			return value[1..value.len - 1]
		}
	}
	return ''
}

fn formulary_class_from_contents(name string, path string, contents string, namespace string,
	flags []string, context FormularyLoadContext) !FormularyLoadedClass {
	if context.disable_load_formula {
		return error('Formula loading disabled by `\$HOMEBREW_DISABLE_LOAD_FORMULA`!')
	}
	if !context.trusted {
		return error('UntrustedTapError: refusing to load ${name}')
	}
	if context.evaluation_error != '' && !(context.ignorable_error && context.evaluation_error in [
		'NameError',
		'ArgumentError',
		'MethodDeprecatedError',
		'MacOSVersion::Error',
	]) {
		return error('FormulaUnreadableError: ${name}: ${context.evaluation_error}')
	}
	class_name := formula_class_name(name)
	class_declaration := 'class ${class_name} < Formula'
	if !contents.contains(class_declaration) && class_name !in context.class_constants {
		return error('FormulaClassUnavailableError: Expected to find class ${class_name} in ${path}')
	}
	stable_url := formulary_extract_quoted(contents, 'url')
	head_url := formulary_extract_quoted(contents, 'head')
	checksum := formulary_extract_quoted(contents, 'sha256')
	return FormularyLoadedClass{
		name: name
		class_name: class_name
		path: path
		namespace: namespace
		contents: contents
		flags: flags.clone()
		printed_output: context.printed_output.trim_space()
		reference: api.PackageReference{
			kind: .formula
			name: name
			full_name: name
			stable_version: if stable_url != '' {
				formulary_version_from_url(stable_url)} else {
				''}
			head_version: if head_url != '' { 'HEAD' } else { '' }
			source_url: stable_url
			source_checksum: checksum
			local_path: path
		}
	}
}

fn formulary_version_from_url(url string) string {
	parts := url.replace('.tar.gz', '').replace('.tgz', '').replace('.tbz', '').split('-')
	return if parts.len > 1 { parts.last() } else { '' }
}

struct FormularyDependencyGroups {
mut:
	runtime     []string
	build       []string
	test        []string
	recommended []string
	optional    []string
}

fn formulary_append_unique(mut values []string, value string) {
	if value != '' && value !in values { values << value }
}

fn formulary_dependency_tags(value ruby.Value) []string {
	if value.type_name == 'Array' {
		items := value.as_array() or { return []string{} }
		return items.map(it.as_string().trim_string_left(':'))
	}
	return [value.as_string().trim_string_left(':')]
}

fn formulary_dependency_groups(values []ruby.Value,
	uses_from_macos []api.ApiStructArgPair) FormularyDependencyGroups {
	mut groups := FormularyDependencyGroups{}
	for value in values {
		if value.type_name != 'Hash' {
			formulary_append_unique(mut groups.runtime, value.as_string())
			continue
		}
		entries := value.as_map() or { continue }
		for name, tags_value in entries {
			tags := formulary_dependency_tags(tags_value)
			if 'build' in tags {
				formulary_append_unique(mut groups.build, name)
			} else if 'test' in tags {
				formulary_append_unique(mut groups.test, name)
			} else if 'recommended' in tags {
				formulary_append_unique(mut groups.recommended, name)
			} else if 'optional' in tags {
				formulary_append_unique(mut groups.optional, name)
			} else {
				formulary_append_unique(mut groups.runtime, name)
			}
		}
	}
	for pair in uses_from_macos {
		name := pair.first.as_string()
		formulary_append_unique(mut groups.runtime, name)
	}
	return groups
}

fn formulary_value_string(values map[string]ruby.Value, key string) string {
	return (values[key] or { ruby.string_value('') }).as_string().trim_string_left(':')
}

fn formulary_action_active(present bool, date string) bool {
	if !present {
		return false
	}
	return date == '' || date <= time.now().format_ss()[..10]
}

fn formulary_arg_pair_strings(values []api.ApiStructArgPair) []string {
	mut result := []string{}
	for pair in values {
		first := pair.first.as_string().trim_string_left(':')
		second := pair.second.as_string().trim_string_left(':')
		result << if second == '' { first } else { '${first}: ${second}' }
	}
	return result
}

fn formulary_patch_resolutions(values []ruby.Value) []string {
	mut resolutions := []string{}
	for value in values {
		patch := value.as_map() or { continue }
		resolved_values := (patch['resolves'] or { continue }).as_array() or { continue }
		for resolved_value in resolved_values {
			resolved := resolved_value.as_map() or { continue }
			id := (resolved['id'] or { continue }).as_string()
			if id != '' { resolutions << id }
		}
	}
	return resolutions
}

fn formulary_loader_formula(loader FormularyLoader, spec string, alias_path string,
	force_bottle bool, flags []string) !Formula {
	if loader.error_message != '' {
		return error(loader.error_message)
	}
	mut reference := loader.loaded_class.reference
	if reference.name == '' {
		return error('FormulaUnavailableError: ${loader.name}')
	}
	if loader.has_tap && reference.tap == '' {
		reference = api.PackageReference{
			...reference
			tap: loader.tap.name
			full_name: if loader.tap.core_tap {
				loader.name
			} else {
				'${loader.tap.name}/${loader.name}'
			}
			core_tap: loader.tap.core_tap
			tap_installed: loader.tap.installed
		}
	}
	return new_formula(FormulaConfig{
		reference: reference
		active_spec: spec
		alias_path: if alias_path != '' { alias_path } else { loader.alias_path }
		force_bottle: force_bottle
		build: new_build_options(new_options(...flags), Options{})
		options: Options{}
		loaded_from_internal_api: loader.loaded_class.loaded_from_internal_api
		post_install_steps: loader.loaded_class.post_install_steps
		post_install_steps_defined: loader.loaded_class.post_install_steps_defined
		keg_only_reason: loader.loaded_class.keg_only_reason
		conflicts: loader.loaded_class.conflicts
		link_overwrite_paths: loader.loaded_class.link_overwrite_paths
		service_block: loader.loaded_class.service_block
		deprecation_date: loader.loaded_class.deprecation_date
		deprecation_replacement_formula: loader.loaded_class.deprecation_replacement_formula
		deprecation_replacement_cask: loader.loaded_class.deprecation_replacement_cask
		disable_date: loader.loaded_class.disable_date
		disable_replacement_formula: loader.loaded_class.disable_replacement_formula
		disable_replacement_cask: loader.loaded_class.disable_replacement_cask
		patches: loader.loaded_class.patches
		requirements: loader.loaded_class.requirements
	})
}

pub struct FormularyLookupConfig {
pub:
	formula_directory string
	api               api.FormulaLookupConfig
	prefix            string
	cellar            string
}

pub fn default_formulary_lookup_config() FormularyLookupConfig {
	prefix := ruby.environment_value('HOMEBREW_PREFIX')
	cellar := ruby.environment_value('HOMEBREW_CELLAR')
	api_cache := ruby.environment_value('HOMEBREW_API_CACHE')
	without_api := ruby.environment_value('HOMEBREW_NO_INSTALL_FROM_API') != ''
	api_domain := ruby.environment_value('HOMEBREW_API_DOMAIN')
	return FormularyLookupConfig{
		formula_directory: ruby.environment_value('HOMEBREW_CORE_FORMULA_DIR')
		prefix: prefix
		cellar: if cellar == '' && prefix != '' {
			ruby.join_path(prefix, 'Cellar')} else {
			cellar}
		api: api.FormulaLookupConfig{
			api_base_url: if api_domain == '' {
				api.default_formula_lookup_config().api_base_url} else {
				api_domain}
			cache_directory: api_cache
			without_api: without_api
		}
	}
}

pub fn formula_namespace_key(identifier string, current_os string, current_arch string) string {
	return sha256.sum256('${current_os}_${current_arch}:${identifier}'.bytes()).hex()
}

pub fn replace_formula_placeholders(value string, prefix string, cellar string,
	home_directory string) string {
	return value.replace(r'$HOMEBREW_PREFIX', prefix).replace(r'$HOMEBREW_CELLAR', cellar).replace(r'/$HOME', home_directory)
}

pub fn formula_class_name(name string) string {
	if name.len == 0 {
		return ''
	}
	mut source := name.to_lower()
	mut output := source[..1].to_upper()
	mut capitalise_next := false
	for character in source[1..].bytes() {
		if character in [`-`, `_`, `.`, ` `, `\t`, `\n`, `\r`] {
			capitalise_next = true
			continue
		}
		if character == `+` {
			output += 'x'
			capitalise_next = false
			continue
		}
		text := character.ascii_str()
		output += if capitalise_next { text.to_upper() } else { text }
		capitalise_next = false
	}
	mut at_index := 1
	for at_index + 1 < output.len {
		if output[at_index] == `@` && output[at_index - 1] != `@` && output[at_index + 1].is_digit() {
			output = '${output[..at_index]}AT${output[at_index + 1..]}'
			break
		}
		at_index++
	}
	return output
}

pub fn core_formula_subdirectory(name string) string {
	if name.starts_with('lib') {
		return 'lib'
	}
	if name.len == 0 {
		return ''
	}
	return name[..1]
}

pub fn core_formula_path(name string, formula_directory string) string {
	canonical_name := name.to_lower().trim_string_right('.rb')
	return os.join_path(formula_directory, core_formula_subdirectory(canonical_name), '${canonical_name}.rb')
}

pub fn select_formula_loader(ref string, config FormularyLookupConfig) FormulaLoaderDecision {
	if ref.starts_with('http://') || ref.starts_with('https://') || ref.starts_with('file://') {
		return FormulaLoaderDecision{
			kind: .uri
			name: ref
			path: ref
		}
	}
	if os.is_file(ref) {
		return FormulaLoaderDecision{
			kind: if ref.ends_with('.json') { .local_json } else { .local_ruby }
			name: os.file_name(ref).trim_string_right('.json').trim_string_right('.rb')
			path: os.abs_path(ref)
		}
	}
	if ref.contains('/') && !ref.starts_with('homebrew/core/') {
		return FormulaLoaderDecision{
			kind: .tap
			name: ref.all_after_last('/')
		}
	}
	name := ref.all_after_last('/').trim_string_right('.rb').to_lower()
	if config.formula_directory.len > 0 {
		path := core_formula_path(name, config.formula_directory)
		if os.is_file(path) {
			return FormulaLoaderDecision{
				kind: .local_ruby
				name: name
				path: path
			}
		}
	}
	return FormulaLoaderDecision{
		kind: .api
		name: name
	}
}

pub fn formulary_factory_reference(ref string, config FormularyLookupConfig) !api.PackageReference {
	loader := select_formula_loader(ref, config)
	return match loader.kind {
		.api {
			api.resolve_formula_reference(loader.name, config.api)!
		}
		.local_json {
			api.decode_local_formula_metadata(os.read_file(loader.path)!, loader.path)!
		}
		.local_ruby {
			contents := os.read_file(loader.path)!
			loaded := formulary_class_from_contents(loader.name, loader.path, contents, 'FormulaNamespace${formula_namespace_key(loader.path, 'host', 'host')}', [], FormularyLoadContext{})!
			loaded.reference
		}
		.tap {
			return error('TapFormulaUnavailableError: ${ref}')
		}
		.uri {
			if !ref.starts_with('file://') {
				return error('Non-checksummed download of ${os.base(ref).trim_string_right('.rb')} formula file from an arbitrary URL is unsupported! Use `brew version-install` to install a formula file from your own custom tap instead.')
			}
			path := ref.trim_string_left('file://')
			name := os.base(path).trim_string_right('.rb')
			contents := os.read_file(path)!
			loaded := formulary_class_from_contents(name, path, contents, 'FormulaNamespace${formula_namespace_key(path, 'host', 'host')}', [], FormularyLoadContext{})!
			loaded.reference
		}
		.bottle, .path, .name, .keg, .cache, .contents, .json_contents, .null_loader {
			return error('FormulaUnavailableError: ${ref}')
		}
		.unavailable {
			return error('FormulaUnavailableError: ${ref}')
		}
	}
}

pub fn resolve_formulary_reference(ref string, config FormularyLookupConfig) !api.PackageReference {
	// The Ruby resolve path first uses factory for explicit references and then
	// reconciles installed racks. Rack/Tab handling is a separate Keg boundary;
	// an uninstalled formula retains the factory result.
	return formulary_factory_reference(ref, config)
}

pub fn formulary_factory(ref string, spec string, alias_path string, force_bottle bool,
	flags []string, config FormularyLookupConfig) !Formula {
	reference := formulary_factory_reference(ref, config)!
	mut formula := new_formula(FormulaConfig{
		reference: reference
		prefix: config.prefix
		cellar: config.cellar
		active_spec: spec
		alias_path: alias_path
		force_bottle: force_bottle
		build: new_build_options(new_options(...flags), Options{})
		options: Options{}
	})!
	formula.build = new_build_options(new_options(...flags), formula.options())
	return formula
}

pub fn formulary_factory_default(ref string) !Formula {
	return formulary_factory(ref, '', '', false, []string{}, default_formulary_lookup_config())
}

fn apply_installed_tab(mut formula Formula, tab Tab) Formula {
	used := remap_tab_deprecated_options(formula.deprecated_options(), tab.used_options())
	if formula.options().empty() {
		formula.options_value = used.plus(tab.unused_options())
	}
	formula.build = new_build_options(used, formula.options())
	return formula
}

pub fn formulary_from_keg(keg Keg, spec string, alias_path string, force_bottle bool,
	flags []string, config FormularyLookupConfig) !Formula {
	tab := keg.tab()!
	active_spec := if spec == '' { tab.spec() } else { spec.trim_left(':') }
	formula_name := os.base(keg.rack())
	mut path_config := FormularyLookupConfig{
		...config
		prefix: keg.prefix
		cellar: keg.cellar
	}
	mut formula := if tab.tap_name() == '' {
		formulary_factory(formula_name, active_spec, alias_path, force_bottle, flags, path_config)!
	} else {
		formulary_factory('${tab.tap_name()}/${formula_name}', active_spec, alias_path, force_bottle, flags, path_config) or {
			formulary_factory(formula_name, active_spec, alias_path, force_bottle, flags, path_config)!
		}
	}
	formula = apply_installed_tab(mut formula, tab)
	if formula.head() {
		installed_version := keg.version()!
		if installed_version.head() {
			formula.reference = api.PackageReference{
				...formula.reference
				head_version: installed_version.version.to_s()
			}
		}
	}
	return formula
}

pub fn formulary_from_keg_default(keg Keg) !Formula {
	return formulary_from_keg(keg, '', '', false, []string{}, default_formulary_lookup_config())
}

pub fn formulary_from_rack(rack string, spec string, alias_path string, force_bottle bool,
	flags []string, config FormularyLookupConfig) !Formula {
	prefix := if config.prefix == '' {
		ruby.environment_value('HOMEBREW_PREFIX')
	} else {
		config.prefix
	}
	cellar := if config.cellar == '' {
		if prefix == '' { os.dir(rack) } else { ruby.join_path(prefix, 'Cellar') }
	} else {
		config.cellar
	}
	if keg := keg_from_rack_with_paths(rack, cellar, prefix) {
		return formulary_from_keg(keg, spec, alias_path, force_bottle, flags, config)
	}
	return formulary_factory(os.base(rack), spec, alias_path, force_bottle, flags, config)
}

pub fn formulary_to_rack(ref string, config FormularyLookupConfig) !string {
	cellar := if config.cellar == '' {
		prefix := if config.prefix == '' {
			ruby.environment_value('HOMEBREW_PREFIX')
		} else {
			config.prefix
		}
		ruby.join_path(prefix, 'Cellar')
	} else {
		config.cellar
	}
	direct := ruby.join_path(cellar, os.base(ref).trim_string_right('.rb').trim_string_right('.json'))
	if ruby.is_dir(direct) {
		return ruby.real_path(direct)
	}
	canonical := formulary_factory_reference(ref, config)!.name
	return ruby.real_path(ruby.join_path(cellar, canonical))
}

pub fn formulary_resolve(ref string, spec string, force_bottle bool, flags []string,
	config FormularyLookupConfig) !Formula {
	mut formula := if ref.contains('/') || ruby.path_exists(ref) {
		mut explicit := formulary_factory(ref, spec, '', force_bottle, flags, config)!
		if explicit.any_version_installed() {
			tab := tab_for_formula(explicit)
			resolved_spec := if spec == '' { tab.spec() } else { spec.trim_left(':') }
			if (resolved_spec == 'stable' && explicit.reference.stable_version != '') || (resolved_spec == 'head' && explicit.reference.head_version != '') {
				explicit.active_spec = resolved_spec
			}
			explicit = apply_installed_tab(mut explicit, tab)
		}
		explicit
	} else {
		rack := formulary_to_rack(ref, config)!
		formulary_from_rack(rack, spec, '', force_bottle, flags, config)!
	}
	formula.follow_installed_alias = false
	return formula
}

pub fn formulary_resolve_default(ref string) !Formula {
	return formulary_resolve(ref, '', false, []string{}, default_formulary_lookup_config())
}

fn collect_runtime_dependency_formulae(dependencies []Dependency, config FormularyLookupConfig,
	mut formulae []Formula, mut visited map[string]bool) ! {
	for dependency in dependencies {
		if dependency.build() || dependency.test() || dependency.optional() {
			continue
		}
		if dependency.name in visited {
			continue
		}
		visited[dependency.name] = true
		formula := dependency_to_formula(dependency, false, config)!
		collect_runtime_dependency_formulae(formula.deps(), config, mut formulae, mut visited)!
		formulae << formula
	}
}

pub fn formulary_runtime_dependency_formulae(formula Formula,
	config FormularyLookupConfig) ![]Formula {
	mut formulae := []Formula{}
	mut visited := map[string]bool{}
	collect_runtime_dependency_formulae(formula.deps(), config, mut formulae, mut visited)!
	return formulae
}

// Ruby method `self.enable_factory_cache!` at line 38.
pub fn ruby_formulary_l38_d1_self_enable_factory_cache(mut cache FormularyPlatformCache) {
	cache.enabled = true
}

// Ruby method `self.factory_cached?` at line 45.
pub fn ruby_formulary_l45_d2_self_factory_cached(cache FormularyPlatformCache) bool {
	return cache.enabled
}

// Ruby method `self.platform_cache_tag` at line 50.
pub fn ruby_formulary_l50_d3_self_platform_cache_tag(current_os string, current_arch string) string {
	return '${current_os}_${current_arch}'
}

// Ruby method `self.platform_cache` at line 62.
pub fn ruby_formulary_l62_d4_self_platform_cache(cache FormularyPlatformCache) FormularyPlatformCache {
	return cache
}

// Ruby method `self.factory_cache` at line 67.
pub fn ruby_formulary_l67_d5_self_factory_cache(cache FormularyPlatformCache) map[string]Formula {
	return cache.factory.clone()
}

// Ruby method `self.formula_class_defined_from_path?(path)` at line 73.
pub fn ruby_formulary_l73_d6_self_formula_class_defined_from_path(cache FormularyPlatformCache, path string) bool {
	return path in cache.path_classes
}

// Ruby method `self.formula_class_defined_from_api?(name)` at line 78.
pub fn ruby_formulary_l78_d7_self_formula_class_defined_from_api(cache FormularyPlatformCache, name string) bool {
	return name in cache.api_classes
}

// Ruby method `self.formula_class_get_from_path(path)` at line 83.
pub fn ruby_formulary_l83_d8_self_formula_class_get_from_path(cache FormularyPlatformCache, path string) !FormularyLoadedClass {
	return cache.path_classes[path] or { error('key not found: ${path}') }
}

// Ruby method `self.formula_class_get_from_api(name)` at line 88.
pub fn ruby_formulary_l88_d9_self_formula_class_get_from_api(cache FormularyPlatformCache, name string) !FormularyLoadedClass {
	return cache.api_classes[name] or { error('key not found: ${name}') }
}

// Ruby method `self.clear_cache` at line 93.
pub fn ruby_formulary_l93_d10_self_clear_cache(mut cache FormularyPlatformCache) {
	cache.path_classes.clear()
	cache.api_classes.clear()
}

// Ruby method `self.load_formula(name, path, contents, namespace, flags:, ignore_errors:)` at line 123.
pub fn ruby_formulary_l123_d11_self_load_formula(name string, path string, contents string, namespace string,
	flags []string, ignore_errors bool, context FormularyLoadContext) !FormularyLoadedClass {
	mut effective := context
	if ignore_errors && context.evaluation_error in ['NameError', 'ArgumentError',
		'MethodDeprecatedError', 'MacOSVersion::Error'] {
		effective = FormularyLoadContext{ ...context, ignorable_error: true }
	}
	return formulary_class_from_contents(name, path, contents, namespace, flags, effective)
}

// Ruby method `self.namespace_key(identifier)` at line 193.
pub fn ruby_formulary_l193_d12_self_namespace_key(identifier string, current_os string,
	current_arch string) string {
	return formula_namespace_key(identifier, current_os, current_arch)
}

// Ruby method `self.replace_placeholders(string)` at line 200.
pub fn ruby_formulary_l200_d13_self_replace_placeholders(value string, prefix string, cellar string,
	home_directory string) string {
	return replace_formula_placeholders(value, prefix, cellar, home_directory)
}

// Ruby method `self.load_formula_from_path(name, path, flags:, ignore_errors:)` at line 210.
pub fn ruby_formulary_l210_d14_self_load_formula_from_path(mut cache FormularyPlatformCache, name string,
	path string, flags []string, ignore_errors bool, context FormularyLoadContext) !FormularyLoadedClass {
	contents := os.read_file(path)!
	namespace := 'FormulaNamespace${formula_namespace_key(path, 'host', 'host')}'
	loaded := ruby_formulary_l123_d11_self_load_formula(name, path, contents, namespace, flags, ignore_errors, context)!
	cache.path_classes[path] = loaded
	return loaded
}

// Ruby method `self.load_formula_from_struct!(name, formula_struct, api_source:, tap_git_head:, flags:, internal_api: false)` at line 228.
pub fn ruby_formulary_l228_d15_self_load_formula_from_struct(mut cache FormularyPlatformCache, name string,
	formula_struct api.FormulaStruct, api_source string, tap_git_head string, flags []string, internal_api bool,
	prefix string, cellar string, home_directory string) FormularyLoadedClass {
	stable_url := formula_struct.stable_url_args.first.as_string()
	head_url := formula_struct.head_url_args.first.as_string()
	checksum := formula_struct.stable_checksum or { '' }
	caveats_value := formula_struct.caveats or { '' }
	dependencies := formulary_dependency_groups(formula_struct.stable_dependencies, formula_struct.stable_uses_from_macos)
	deprecation_date := formulary_value_string(formula_struct.deprecate_args, 'date')
	deprecation_reason := formulary_value_string(formula_struct.deprecate_args, 'because')
	disable_date := formulary_value_string(formula_struct.disable_args, 'date')
	disable_reason := formulary_value_string(formula_struct.disable_args, 'because')
	conflicts := formula_struct.conflicts.map(it.first.as_string())
	post_install_steps := formula_struct.post_install_steps.map(it.as_string())
	keg_only_reason := if formula_struct.keg_only_args.len > 0 {
		formula_struct.keg_only_args[0].as_string().trim_string_left(':')
	} else {
		''
	}
	loaded := FormularyLoadedClass{
		name: name
		class_name: formula_class_name(name)
		namespace: 'FormulaNamespaceAPI${formula_namespace_key(api_source, 'api', 'api')}'
		flags: flags.clone()
		loaded_from_api: true
		loaded_from_internal_api: internal_api
		post_install_defined: formula_struct.post_install_defined
		caveats: replace_formula_placeholders(caveats_value, prefix, cellar, home_directory)
		tap_git_head: tap_git_head
		oldnames: formula_struct.oldnames.clone()
		aliases: formula_struct.aliases.clone()
		versioned_formulae_names: formula_struct.versioned_formulae.clone()
		ruby_source_path: 'Formula/${core_formula_subdirectory(name)}/${name.to_lower()}.rb'
		ruby_source_checksum: formula_struct.ruby_source_checksum.to_lower()
		post_install_steps: post_install_steps
		post_install_steps_defined: post_install_steps.len > 0
		keg_only_reason: keg_only_reason
		conflicts: conflicts
		link_overwrite_paths: formula_struct.link_overwrite_paths.clone()
		service_block: formulary_arg_pair_strings(formula_struct.service_args).join('\n')
		deprecation_date: deprecation_date
		deprecation_replacement_formula: formulary_value_string(formula_struct.deprecate_args, 'replacement_formula')
		deprecation_replacement_cask: formulary_value_string(formula_struct.deprecate_args, 'replacement_cask')
		disable_date: disable_date
		disable_replacement_formula: formulary_value_string(formula_struct.disable_args, 'replacement_formula')
		disable_replacement_cask: formulary_value_string(formula_struct.disable_args, 'replacement_cask')
		patches: formulary_patch_resolutions(formula_struct.stable_patches)
		reference: api.PackageReference{
			kind: .formula
			name: name
			full_name: name
			description: formula_struct.desc
			homepage: formula_struct.homepage
			license: formula_struct.license
			stable_version: formula_struct.stable_version
			head_version: if formula_struct.predicates.head { 'HEAD' } else { '' }
			source_url: stable_url
			source_checksum: checksum
			revision: formula_struct.revision
			version_scheme: formula_struct.version_scheme
			bottle_available: formula_struct.predicates.bottle
			dependencies: dependencies.runtime
			build_dependencies: dependencies.build
			test_dependencies: dependencies.test
			recommended_dependencies: dependencies.recommended
			optional_dependencies: dependencies.optional
			oldnames: formula_struct.oldnames.clone()
			aliases: formula_struct.aliases.clone()
			versioned_formulae: formula_struct.versioned_formulae.clone()
			tap_git_head: tap_git_head
			ruby_source_path: 'Formula/${core_formula_subdirectory(name)}/${name.to_lower()}.rb'
			ruby_source_checksum: formula_struct.ruby_source_checksum.to_lower()
			keg_only: formula_struct.predicates.keg_only
			deprecated: formulary_action_active(formula_struct.predicates.deprecate, deprecation_date)
			deprecation_reason: deprecation_reason
			disabled: formulary_action_active(formula_struct.predicates.disable, disable_date)
			disable_reason: disable_reason
			loaded_from_api: true
		}
	}
	cache.api_classes[name] = loaded
	_ = head_url
	return loaded
}

// Ruby define_method `define_method(:install) do` at line 343.
pub fn ruby_formulary_l343_d16_install(_ FormularyLoadedClass) ! {
	return error('Cannot build from source from abstract formula.')
}

// Ruby define_method `define_method(:post_install_defined?) do` at line 348.
pub fn ruby_formulary_l348_d17_post_install_defined(loaded FormularyLoadedClass) bool {
	return loaded.post_install_defined
}

// Ruby define_method `define_method(:caveats) do` at line 364.
pub fn ruby_formulary_l364_d18_caveats(loaded FormularyLoadedClass) string {
	return loaded.caveats
}

// Ruby define_method `define_method(:tap_git_head) do` at line 369.
pub fn ruby_formulary_l369_d19_tap_git_head(loaded FormularyLoadedClass) string {
	return loaded.tap_git_head
}

// Ruby define_method `define_method(:oldnames) do` at line 374.
pub fn ruby_formulary_l374_d20_oldnames(loaded FormularyLoadedClass) []string {
	return loaded.oldnames.clone()
}

// Ruby define_method `define_method(:aliases) do` at line 379.
pub fn ruby_formulary_l379_d21_aliases(loaded FormularyLoadedClass) []string {
	return loaded.aliases.clone()
}

// Ruby define_method `define_method(:versioned_formulae_names) do` at line 384.
pub fn ruby_formulary_l384_d22_versioned_formulae_names(loaded FormularyLoadedClass) []string {
	return loaded.versioned_formulae_names.clone()
}

// Ruby define_method `define_method(:ruby_source_path) do` at line 389.
pub fn ruby_formulary_l389_d23_ruby_source_path(loaded FormularyLoadedClass) string {
	return loaded.ruby_source_path
}

// Ruby define_method `define_method(:ruby_source_checksum) do` at line 394.
pub fn ruby_formulary_l394_d24_ruby_source_checksum(loaded FormularyLoadedClass) ?string {
	return if loaded.ruby_source_checksum == '' { none } else { loaded.ruby_source_checksum }
}

// Ruby method `self.resolve(` at line 409.
pub fn ruby_formulary_l409_d25_self_resolve(ref string,
	config FormularyLookupConfig) !Formula {
	return formulary_resolve(ref, '', false, []string{}, config)
}

// Ruby method `self.ensure_utf8_encoding(io)` at line 447.
pub fn ruby_formulary_l447_d26_self_ensure_utf8_encoding(contents string) !string {
	return contents
}

// Ruby method `self.class_s(name)` at line 452.
pub fn ruby_formulary_l452_d27_self_class_s(name string) string {
	return formula_class_name(name)
}

// Ruby attr_reader `attr_reader :name` at line 468.
pub fn ruby_formulary_l468_d28_name(loader FormularyLoader) string {
	return loader.name
}

// Ruby attr_reader `attr_reader :path` at line 472.
pub fn ruby_formulary_l472_d29_path(loader FormularyLoader) string {
	return loader.path
}

// Ruby attr_reader `attr_reader :alias_path` at line 476.
pub fn ruby_formulary_l476_d30_alias_path(loader FormularyLoader) ?string {
	return if loader.alias_path == '' { none } else { loader.alias_path }
}

// Ruby attr_reader `attr_reader :tap` at line 480.
pub fn ruby_formulary_l480_d31_tap(loader FormularyLoader) ?FormularyTap {
	return if loader.has_tap { loader.tap } else { none }
}

// Ruby method `initialize(name, path, alias_path: nil, tap: nil)` at line 485.
pub fn ruby_formulary_l485_d32_initialize(name string, path string, alias_path string,
	tap ?FormularyTap) FormularyLoader {
	if actual := tap {
		return FormularyLoader{ kind: .path, name: name, path: path, alias_path: alias_path, tap: actual, has_tap: true }
	}
	return FormularyLoader{ kind: .path, name: name, path: path, alias_path: alias_path }
}

// Ruby method `get_formula(spec, alias_path: nil, force_bottle: false, flags: [], ignore_errors: false)` at line 504.
pub fn ruby_formulary_l504_d33_get_formula(loader FormularyLoader, spec string, alias_path string,
	force_bottle bool, flags []string, _ bool) !Formula {
	return formulary_loader_formula(loader, spec, alias_path, force_bottle, flags)
}

// Ruby method `klass(flags:, ignore_errors:)` at line 512.
pub fn ruby_formulary_l512_d34_klass(mut cache FormularyPlatformCache, loader FormularyLoader,
	flags []string, ignore_errors bool, context FormularyLoadContext) !FormularyLoadedClass {
	if loader.path in cache.path_classes {
		return cache.path_classes[loader.path]
	}
	return ruby_formulary_l520_d35_load_file(mut cache, loader, flags, ignore_errors, context)
}

// Ruby method `load_file(flags:, ignore_errors:)` at line 520.
pub fn ruby_formulary_l520_d35_load_file(mut cache FormularyPlatformCache, loader FormularyLoader,
	flags []string, ignore_errors bool, context FormularyLoadContext) !FormularyLoadedClass {
	if !os.is_file(loader.path) {
		return error('FormulaUnavailableError: ${loader.name}')
	}
	return ruby_formulary_l210_d14_self_load_formula_from_path(mut cache, loader.name, loader.path, flags, ignore_errors, context)
}

// Ruby method `self.try_new(ref, from: nil, warn: false)` at line 535.
pub fn ruby_formulary_l535_d36_self_try_new(input FormularyLoaderInput) ?FormularyLoader {
	if input.forbid_paths || !input.bottle_extension || !input.exists {
		return none
	}
	return ruby_formulary_l544_d37_initialize(input)
}

// Ruby method `initialize(bottle_name, warn: false)` at line 544.
pub fn ruby_formulary_l544_d37_initialize(input FormularyLoaderInput) FormularyLoader {
	name := input.bottle_name
	if name == '' || input.bottle_version == '' {
		return FormularyLoader{
			kind: .bottle
			bottle_path: if input.resolved_path != '' {
				input.resolved_path} else {
				os.abs_path(input.ref)}
			error_message: 'BottleFormulaUnavailableError: ${input.ref}'
		}
	}
	full_name := if input.bottle_full_name != '' { input.bottle_full_name } else { name }
	tap_name := full_name.all_before_last('/')
	has_tap := full_name.contains('/')
	tap := if has_tap { FormularyTap{ name: tap_name } } else { input.tap }
	fallback_path := core_formula_path(name, input.core_formula_dir)
	version := input.bottle_version
	cellar_path := os.join_path(input.cellar, name, version, '.brew', '${name}.rb')
	return FormularyLoader{
		kind: .bottle
		name: name
		path: fallback_path
		tap: tap
		has_tap: has_tap || input.has_tap
		bottle_path: if input.resolved_path != '' {
			input.resolved_path} else {
			os.abs_path(input.ref)}
		cellar_formula_path: cellar_path
	}
}

// Ruby method `get_formula(spec, alias_path: nil, force_bottle: false, flags: [], ignore_errors: false)` at line 571.
pub fn ruby_formulary_l571_d38_get_formula(loader FormularyLoader, fallback FormularyLoader,
	spec string, alias_path string, force_bottle bool, flags []string) !Formula {
	mut formula := formulary_loader_formula(loader, spec, alias_path, force_bottle, flags) or {
		formulary_loader_formula(fallback, spec, alias_path, force_bottle, flags)!
	}
	formula.local_bottle_path = loader.bottle_path
	return formula
}

// Ruby method `self.try_new(ref, from: nil, warn: false)` at line 600.
pub fn ruby_formulary_l600_d39_self_try_new(input FormularyLoaderInput) ?FormularyLoader {
	if !input.exists || !input.loadable_formula_path || !input.ref.ends_with('.rb') {
		return none
	}
	mut path := if input.resolved_path != '' { input.resolved_path } else { os.abs_path(input.ref) }
	mut alias_path := ''
	mut tap := input.tap
	mut has_tap := input.has_tap
	if has_tap && input.is_symlink {
		alias_path = os.abs_path(input.ref)
		path = input.resolved_path
	} else if !has_tap && input.api_tap_name != '' {
		tap = FormularyTap{ name: input.api_tap_name }
		has_tap = true
	}
	return ruby_formulary_l630_d40_initialize(path, alias_path, if has_tap { tap } else { none })
}

// Ruby method `initialize(path, alias_path: nil, tap: nil)` at line 630.
pub fn ruby_formulary_l630_d40_initialize(path string, alias_path string,
	tap ?FormularyTap) FormularyLoader {
	expanded := os.abs_path(path)
	name := os.base(expanded).trim_string_right('.rb')
	mut accepted_alias := alias_path
	if actual := tap {
		if accepted_alias != '' && os.dir(os.abs_path(accepted_alias)) != os.abs_path(actual.alias_dir) {
			accepted_alias = ''
		}
		return FormularyLoader{ kind: .path, name: name, path: expanded, alias_path: accepted_alias, tap: actual, has_tap: true }
	}
	return FormularyLoader{ kind: .path, name: name, path: expanded, alias_path: '' }
}

// Ruby method `self.try_new(ref, from: nil, warn: false)` at line 648.
pub fn ruby_formulary_l648_d41_self_try_new(input FormularyLoaderInput) ?FormularyLoader {
	if input.forbid_paths {
		return none
	}
	uri := input.ref
	if !uri.contains('://') {
		return none
	}
	scheme := uri.all_before('://')
	rest := uri.all_after('://')
	if scheme == '' || !rest.contains('/') {
		return none
	}
	return ruby_formulary_l671_d43_initialize(uri, input.from, input.cache_formula_dir)
}

// Ruby attr_reader `attr_reader :url` at line 668.
pub fn ruby_formulary_l668_d42_url(loader FormularyLoader) string {
	return loader.url
}

// Ruby method `initialize(url, from: nil)` at line 671.
pub fn ruby_formulary_l671_d43_initialize(url string, from string, cache_formula_dir string) FormularyLoader {
	path_component := url.all_after('://').all_after('/')
	filename := os.base(path_component)
	if path_component == '' || filename == '' {
		return FormularyLoader{ kind: .uri, url: url, from: from, error_message: 'URL has no path component' }
	}
	return FormularyLoader{ kind: .uri, name: filename.trim_string_right('.rb'), path: os.join_path(cache_formula_dir, filename), url: url, from: from }
}

// Ruby method `load_file(flags:, ignore_errors:)` at line 682.
pub fn ruby_formulary_l682_d44_load_file(mut cache FormularyPlatformCache, loader FormularyLoader,
	downloaded_contents string, flags []string, ignore_errors bool,
	context FormularyLoadContext) !FormularyLoadedClass {
	scheme := loader.url.all_before('://')
	if scheme != 'file' {
		return error('Non-checksummed download of ${loader.name} formula file from an arbitrary URL is unsupported! Use `brew version-install` to install a formula file from your own custom tap instead.')
	}
	namespace := 'FormulaNamespace${formula_namespace_key(loader.path, 'host', 'host')}'
	loaded := ruby_formulary_l123_d11_self_load_formula(loader.name, loader.path, downloaded_contents, namespace, flags, ignore_errors, context)!
	cache.path_classes[loader.path] = loaded
	return loaded
}

// Ruby attr_reader `attr_reader :tap` at line 705.
pub fn ruby_formulary_l705_d45_tap(loader FormularyLoader) FormularyTap {
	return loader.tap
}

// Ruby attr_reader `attr_reader :path` at line 708.
pub fn ruby_formulary_l708_d46_path(loader FormularyLoader) string {
	return loader.path
}

// Ruby method `self.try_new(ref, from: nil, warn: false)` at line 714.
pub fn ruby_formulary_l714_d47_self_try_new(resolution ?TapFormulaNameType) ?FormularyLoader {
	if actual := resolution {
		return ruby_formulary_l726_d48_self_loader_from_name_tap_type(actual)
	}
	return none
}

// Ruby method `self.loader_from_name_tap_type(name_tap_type)` at line 726.
pub fn ruby_formulary_l726_d48_self_loader_from_name_tap_type(resolution TapFormulaNameType) FormularyLoader {
	path := ruby_formulary_l1256_d78_self_find_formula_in_tap(resolution.name, resolution.tap, false, false)
	if resolution.type_name == 'migration' && resolution.tap.core_tap && resolution.name in resolution.tap.api_formula_names {
		return ruby_formulary_l931_d62_initialize(resolution.name, resolution.tap, resolution.alias_name)
	}
	return ruby_formulary_l738_d49_initialize(resolution.name, path, resolution.tap, resolution.alias_name)
}

// Ruby method `initialize(name, path, tap:, alias_name: nil)` at line 738.
pub fn ruby_formulary_l738_d49_initialize(name string, path string, tap FormularyTap,
	alias_name string) FormularyLoader {
	alias_path := if alias_name != '' { os.join_path(tap.alias_dir, alias_name) } else { '' }
	return FormularyLoader{ kind: .tap, name: name, path: path, alias_path: alias_path, tap: tap, has_tap: true }
}

// Ruby method `get_formula(spec, alias_path: nil, force_bottle: false, flags: [], ignore_errors: false)` at line 754.
pub fn ruby_formulary_l754_d50_get_formula(loader FormularyLoader, spec string,
	alias_path string, force_bottle bool, flags []string) !Formula {
	return formulary_loader_formula(loader, spec, alias_path, force_bottle, flags) or {
		return error('TapFormulaUnavailableError: ${loader.tap.name}/${loader.name}: ${err.msg()}')
	}
}

// Ruby method `load_file(flags:, ignore_errors:)` at line 765.
pub fn ruby_formulary_l765_d51_load_file(mut cache FormularyPlatformCache, loader FormularyLoader,
	flags []string, ignore_errors bool, context FormularyLoadContext) !FormularyLoadedClass {
	return ruby_formulary_l520_d35_load_file(mut cache, loader, flags, ignore_errors, context) or {
		return error('${err.msg()} (${loader.tap.issues_url})')
	}
}

// Ruby method `self.try_new(ref, from: nil, warn: false)` at line 781.
pub fn ruby_formulary_l781_d52_self_try_new(input FormularyLoaderInput,
	core_resolution ?TapFormulaNameType) !FormularyLoader {
	if input.ref == '' || input.ref.contains(' ') || input.ref.contains('://') || input.ref.contains('/') {
		return FormularyLoader{ available: false }
	}
	name := input.ref.to_lower()
	if core := core_resolution {
		loader := ruby_formulary_l726_d48_self_loader_from_name_tap_type(core)
		if loader.kind == .api || os.exists(loader.path) {
			return loader
		}
	}
	mut loaders := []FormularyLoader{}
	for tap in input.installed_taps {
		if !tap.installed || tap.core_tap {
			continue
		}
		resolution := ruby_formulary_l1173_d75_self_tap_formula_name_type('${tap.name}/${name}', tap, input.installed_taps, input.warn) or { continue }
		loader := ruby_formulary_l726_d48_self_loader_from_name_tap_type(resolution)
		if os.exists(loader.path) && !loaders.any(it.path == loader.path) { loaders << loader }
	}
	if loaders.len == 1 {
		return loaders[0]
	}
	if loaders.len >= 2 {
		return error('TapFormulaAmbiguityError: ${name}')
	}
	return FormularyLoader{ available: false }
}

// Ruby method `self.try_new(ref, from: nil, warn: false)` at line 824.
pub fn ruby_formulary_l824_d53_self_try_new(input FormularyLoaderInput) ?FormularyLoader {
	if !input.keg_exists || input.keg_formula_path == '' {
		return none
	}
	return FormularyLoader{ kind: .keg, name: input.keg_name, path: input.keg_formula_path, tap: input.keg_tap, has_tap: input.keg_tap.name != '' }
}

// Ruby method `self.try_new(ref, from: nil, warn: false)` at line 845.
pub fn ruby_formulary_l845_d54_self_try_new(input FormularyLoaderInput) ?FormularyLoader {
	path := os.join_path(input.cache_formula_dir, '${input.ref}.rb')
	if !os.is_file(path) {
		return none
	}
	return FormularyLoader{ kind: .cache, name: input.ref, path: path }
}

// Ruby method `self.try_new(ref, from: nil, warn: false)` at line 860.
pub fn ruby_formulary_l860_d55_self_try_new(ref string, is_uri bool,
	core_formula_dir string) ?FormularyLoader {
	if is_uri {
		return none
	}
	return ruby_formulary_l867_d56_initialize(ref, core_formula_dir)
}

// Ruby method `initialize(ref)` at line 867.
pub fn ruby_formulary_l867_d56_initialize(ref string, core_formula_dir string) FormularyLoader {
	name := os.base(ref).trim_string_right('.rb')
	return FormularyLoader{ kind: .null_loader, name: name, path: core_formula_path(name, core_formula_dir), error_message: 'FormulaUnavailableError: ${name}' }
}

// Ruby method `get_formula(_spec, alias_path: nil, force_bottle: false, flags: [], ignore_errors: false)` at line 881.
pub fn ruby_formulary_l881_d57_get_formula(loader FormularyLoader) !Formula {
	return error('FormulaUnavailableError: ${loader.name}')
}

// Ruby attr_reader `attr_reader :contents` at line 890.
pub fn ruby_formulary_l890_d58_contents(loader FormularyLoader) string {
	return loader.contents
}

// Ruby method `initialize(name, path, contents, tap: nil)` at line 893.
pub fn ruby_formulary_l893_d59_initialize(name string, path string, contents string,
	tap ?FormularyTap) FormularyLoader {
	if actual := tap {
		return FormularyLoader{ kind: .contents, name: name, path: path, contents: contents, tap: actual, has_tap: true }
	}
	return FormularyLoader{ kind: .contents, name: name, path: path, contents: contents }
}

// Ruby method `klass(flags:, ignore_errors:)` at line 899.
pub fn ruby_formulary_l899_d60_klass(loader FormularyLoader, flags []string,
	ignore_errors bool, context FormularyLoadContext) !FormularyLoadedClass {
	namespace := 'FormulaNamespace${md5.sum(loader.contents.bytes()).hex()}'
	return ruby_formulary_l123_d11_self_load_formula(loader.name, loader.path, loader.contents, namespace, flags, ignore_errors, context)
}

// Ruby method `self.try_new(ref, from: nil, warn: false)` at line 911.
pub fn ruby_formulary_l911_d61_self_try_new(input FormularyLoaderInput,
	core_tap FormularyTap) ?FormularyLoader {
	if !input.api_enabled || input.ref == '' || input.ref.contains('://') || input.ref.contains(' ') {
		return none
	}
	mut name := input.ref.to_lower().all_after_last('/')
	if name !in input.api_formula_names && name !in input.api_aliases && name !in input.api_renames {
		return none
	}
	alias_name := if name in input.api_aliases { name } else { '' }
	if canonical := input.api_aliases[name] {
		name = canonical
	}
	if renamed := input.api_renames[name] {
		name = renamed
	}
	return ruby_formulary_l931_d62_initialize(name, core_tap, alias_name)
}

// Ruby method `initialize(name, tap: nil, alias_name: nil)` at line 931.
pub fn ruby_formulary_l931_d62_initialize(name string, tap FormularyTap,
	alias_name string) FormularyLoader {
	alias_path := if alias_name != '' { os.join_path(tap.alias_dir, alias_name) } else { '' }
	return FormularyLoader{ kind: .api, name: name, path: ruby_formulary_l1256_d78_self_find_formula_in_tap(name, tap, true, true), alias_path: alias_path, tap: tap, has_tap: true }
}

// Ruby method `klass(flags:, ignore_errors:)` at line 938.
pub fn ruby_formulary_l938_d63_klass(mut cache FormularyPlatformCache, loader FormularyLoader,
	formula_struct api.FormulaStruct, api_source string, tap_git_head string, flags []string, prefix string,
	cellar string, home_directory string) !FormularyLoadedClass {
	if loader.name !in cache.api_classes {
		ruby_formulary_l946_d64_load_from_api(mut cache, loader, formula_struct, api_source, tap_git_head, flags, prefix, cellar, home_directory)!
	}
	return cache.api_classes[loader.name] or { error('FormulaUnavailableError: ${loader.name}') }
}

// Ruby method `load_from_api(flags:)` at line 946.
pub fn ruby_formulary_l946_d64_load_from_api(mut cache FormularyPlatformCache, loader FormularyLoader,
	formula_struct api.FormulaStruct, api_source string, tap_git_head string, flags []string, prefix string,
	cellar string, home_directory string) !FormularyLoadedClass {
	if api_source == '' {
		return error('FormulaUnavailableError: ${loader.name}')
	}
	return ruby_formulary_l228_d15_self_load_formula_from_struct(mut cache, loader.name, formula_struct, api_source, tap_git_head, flags, true, prefix, cellar, home_directory)
}

// Ruby method `initialize(name, contents, tap: nil, alias_name: nil)` at line 961.
pub fn ruby_formulary_l961_d65_initialize(name string, contents string, tap FormularyTap,
	alias_name string) FormularyLoader {
	base := ruby_formulary_l931_d62_initialize(name, tap, alias_name)
	return FormularyLoader{ ...base, kind: .json_contents, contents: contents }
}

// Ruby method `load_from_api(flags:)` at line 969.
pub fn ruby_formulary_l969_d66_load_from_api(mut cache FormularyPlatformCache, loader FormularyLoader,
	formula_struct api.FormulaStruct, tap_git_head string, flags []string, prefix string,
	cellar string, home_directory string) FormularyLoadedClass {
	return ruby_formulary_l228_d15_self_load_formula_from_struct(mut cache, loader.name, formula_struct, loader.contents, tap_git_head, flags, false, prefix, cellar, home_directory)
}

// Ruby method `self.factory(` at line 997.
pub fn ruby_formulary_l997_d67_self_factory(ref string,
	config FormularyLookupConfig) !Formula {
	return formulary_factory(ref, '', '', false, []string{}, config)
}

// Ruby method `self.from_rack(rack, spec = nil, alias_path: nil, force_bottle: false, flags: [], keg: Keg.from_rack(rack))` at line 1035.
pub fn ruby_formulary_l1035_d68_self_from_rack(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Formulary.from_rack requires a rack') }
	spec := if args.len > 1 && args[1].type_name != 'NilClass' { args[1].as_string() } else { '' }
	formula := formulary_from_rack(args[0].as_string(), spec, '', false, []string{}, default_formulary_lookup_config()) or { panic(err) }
	return formula_boundary_value(formula)
}

// Ruby method `self.keg_only?(rack)` at line 1051.
pub fn ruby_formulary_l1051_d69_self_keg_only(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Formulary.keg_only? requires a rack') }
	formula := formulary_from_rack(args[0].as_string(), '', '', false, []string{}, default_formulary_lookup_config()) or { return ruby.bool_value(false) }
	return ruby.bool_value(formula.keg_only())
}

// Ruby method `self.from_keg(` at line 1068.
pub fn ruby_formulary_l1068_d70_self_from_keg(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Formulary.from_keg requires a Keg') }
	keg := keg_from_boundary(args[0])
	spec := if args.len > 1 && args[1].type_name != 'NilClass' { args[1].as_string() } else { '' }
	formula := formulary_from_keg(keg, spec, '', false, []string{}, default_formulary_lookup_config()) or { panic(err) }
	return formula_boundary_value(formula)
}

// Ruby method `self.from_contents(` at line 1119.
pub fn ruby_formulary_l1119_d71_self_from_contents(name string, path string, contents string,
	spec string, alias_path string, tap ?FormularyTap, force_bottle bool, flags []string,
	ignore_errors bool, context FormularyLoadContext) !Formula {
	loader := ruby_formulary_l893_d59_initialize(name, path, contents, tap)
	loaded := ruby_formulary_l899_d60_klass(loader, flags, ignore_errors, context)!
	return formulary_loader_formula(FormularyLoader{ ...loader, loaded_class: loaded }, spec, alias_path, force_bottle, flags)
}

// Ruby method `self.to_rack(ref)` at line 1135.
pub fn ruby_formulary_l1135_d72_self_to_rack(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Formulary.to_rack requires a reference') }
	path := formulary_to_rack(args[0].as_string(), default_formulary_lookup_config()) or {
		panic(err)
	}
	return ruby.object_value('Pathname', path)
}

// Ruby method `self.canonical_name(ref)` at line 1156.
pub fn ruby_formulary_l1156_d73_self_canonical_name(ref string,
	config FormularyLookupConfig) !string {
	return formulary_factory_reference(ref, config)!.name
}

// Ruby method `self.path(ref)` at line 1165.
pub fn ruby_formulary_l1165_d74_self_path(ref string, config FormularyLookupConfig) string {
	loader := select_formula_loader(ref, config)
	if loader.path.len > 0 {
		return loader.path
	}
	return core_formula_path(loader.name, config.formula_directory)
}

fn formulary_find_tap(name string, initial FormularyTap,
	taps []FormularyTap) ?FormularyTap {
	if initial.name == name {
		return initial
	}
	for tap in taps {
		if tap.name == name {
			return tap
		}
	}
	return none
}

fn formulary_tap_formula_name_type(tapped_name string, initial FormularyTap,
	taps []FormularyTap, warn bool, depth int) ?TapFormulaNameType {
	if depth > 32 {
		return none
	}
	parts := tapped_name.split('/')
	if parts.len < 3 {
		return none
	}
	tap_name := parts[..parts.len - 1].join('/')
	mut tap := formulary_find_tap(tap_name, initial, taps) or { return none }
	mut name := parts.last()
	mut type_name := ''
	mut alias_name := ''
	mut old_name := ''
	mut new_name := ''
	alias_key := if tap.core_tap { name } else { '${tap.name}/${name}' }
	if possible_alias := tap.aliases[alias_key] {
		alias_name = name
		name = possible_alias.all_after_last('/')
		type_name = 'alias'
	} else if renamed := tap.formula_renames[name] {
		old_name = if tap.core_tap { name } else { tapped_name }
		name = renamed
		new_name = if tap.core_tap { name } else { '${tap.name}/${name}' }
		type_name = 'rename'
	} else if migrated := tap.tap_migrations[name] {
		mut migrated_tap := tap
		mut migrated_name := name
		migrated_parts := migrated.split('/')
		if migrated_parts.len >= 3 {
			candidate_name := migrated_parts[..migrated_parts.len - 1].join('/')
			migrated_tap = formulary_find_tap(candidate_name, initial, taps) or {
				FormularyTap{ name: candidate_name }
			}
			migrated_name = migrated_parts.last()
		} else if migrated.contains('/') {
			migrated_tap = formulary_find_tap(migrated, initial, taps) or {
				FormularyTap{ name: migrated }
			}
		} else {
			migrated_name = migrated
		}
		new_tapped := '${migrated_tap.name}/${migrated_name}'
		if tapped_name != new_tapped {
			resolved := formulary_tap_formula_name_type(new_tapped, migrated_tap, taps, false, depth + 1) or {
				return TapFormulaNameType{ name: migrated_name, tap: migrated_tap, type_name: 'migration' }
			}
			old_name = if tap.core_tap { name } else { tapped_name }
			name = resolved.name
			tap = resolved.tap
			new_name = if tap.core_tap { name } else { '${tap.name}/${name}' }
			type_name = 'migration'
		}
	}
	path := ruby_formulary_l1256_d78_self_find_formula_in_tap(name, tap, true, true)
	destination_exists := os.exists(path) || (tap.core_tap && name in tap.api_formula_names)
	warning := if warn && old_name != '' && new_name != '' && destination_exists {
		'Formula ${old_name} was renamed to ${new_name}.'
	} else {
		''
	}
	return TapFormulaNameType{
		name: name
		tap: tap
		type_name: type_name
		alias_name: alias_name
		old_name: old_name
		new_name: new_name
		warning: warning
	}
}

// Ruby method `self.tap_formula_name_type(tapped_name, warn:)` at line 1173.
pub fn ruby_formulary_l1173_d75_self_tap_formula_name_type(tapped_name string,
	tap FormularyTap, taps []FormularyTap, warn bool) ?TapFormulaNameType {
	return formulary_tap_formula_name_type(tapped_name, tap, taps, warn, 0)
}

// Ruby method `self.loader_for(ref, from: nil, warn: true)` at line 1230.
pub fn ruby_formulary_l1230_d76_self_loader_for(ref string,
	config FormularyLookupConfig) FormulaLoaderDecision {
	return select_formula_loader(ref, config)
}

// Ruby method `self.core_path(name)` at line 1251.
pub fn ruby_formulary_l1251_d77_self_core_path(name string, formula_directory string) string {
	return core_formula_path(name, formula_directory)
}

// Ruby method `self.find_formula_in_tap(name, tap)` at line 1256.
pub fn ruby_formulary_l1256_d78_self_find_formula_in_tap(name string, tap FormularyTap,
	api_hashes_cached bool, api_install_enabled bool) string {
	filename := if name.ends_with('.rb') { name } else { '${name}.rb' }
	plain_name := name.trim_string_right('.rb')
	if tap.core_tap && api_install_enabled && api_hashes_cached && plain_name in tap.api_formula_names {
		subdirectory := tap.new_formula_subdirectory[plain_name] or {
			core_formula_subdirectory(plain_name)
		}
		return os.join_path(tap.formula_dir, subdirectory, '${plain_name.to_lower()}.rb')
	}
	return tap.formula_files_by_name[plain_name] or { os.join_path(tap.formula_dir, filename) }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "digest/sha2"
// 5: require "uri"
// 6: require "cachable"
// 7: require "tab"
// 8: require "utils"
// 9: require "utils/bottles"
// 10: require "utils/output"
// 11: require "utils/path"
// 12: require "service"
// 13: require "trust"
// 14: require "utils/curl"
// 15: require "extend/hash/deep_transform_values"
// 16: require "extend/hash/keys"
// 17: require "extend/ENV/sensitive"
// 18: require "tap"
// 19:
// 20: # The {Formulary} is responsible for creating instances of {Formula}.
// 21: # It is not meant to be used directly from formulae.
// 22: module Formulary
// 23:   extend Context
// 24:   extend T::Generic
// 25:   extend Cachable
// 26:   extend Utils::Output::Mixin
// 27:   include Utils::Output::Mixin
// 28:
// 29:   Cache = type_template { { fixed: T::Hash[String, T.untyped] } }
// 30:
// 31:   ALLOWED_URL_SCHEMES = %w[file].freeze
// 32:   private_constant :ALLOWED_URL_SCHEMES
// 33:
// 34:   # Enable the factory cache.
// 35:   #
// 36:   # @api internal
// 37:   sig { void }
// 38:   def self.enable_factory_cache!
// 39:     @factory_cache_enabled = T.let(true, T.nilable(TrueClass))
// 40:     cache[platform_cache_tag] ||= {}
// 41:     cache[platform_cache_tag][:formulary_factory] ||= {}
// 42:   end
// 43:
// 44:   sig { returns(T::Boolean) }
// 45:   def self.factory_cached?
// 46:     !!@factory_cache_enabled
// 47:   end
// 48:
// 49:   sig { returns(String) }
// 50:   def self.platform_cache_tag
// 51:     "#{Homebrew::SimulateSystem.current_os}_#{Homebrew::SimulateSystem.current_arch}"
// 52:   end
// 53:   private_class_method :platform_cache_tag
// 54:
// 55:   sig {
// 56:     returns({
// 57:       api:               T.nilable(T::Hash[String, T.class_of(Formula)]),
// 58:       formulary_factory: T.nilable(T::Hash[String, Formula]),
// 59:       path:              T.nilable(T::Hash[String, T.class_of(Formula)]),
// 60:     })
// 61:   }
// 62:   def self.platform_cache
// 63:     cache[platform_cache_tag] ||= {}
// 64:   end
// 65:
// 66:   sig { returns(T::Hash[String, Formula]) }
// 67:   def self.factory_cache
// 68:     cache[platform_cache_tag] ||= {}
// 69:     cache[platform_cache_tag][:formulary_factory] ||= {}
// 70:   end
// 71:
// 72:   sig { params(path: T.any(String, Pathname)).returns(T::Boolean) }
// 73:   def self.formula_class_defined_from_path?(path)
// 74:     platform_cache.key?(:path) && platform_cache.fetch(:path).key?(path.to_s)
// 75:   end
// 76:
// 77:   sig { params(name: String).returns(T::Boolean) }
// 78:   def self.formula_class_defined_from_api?(name)
// 79:     platform_cache.key?(:api) && platform_cache.fetch(:api).key?(name)
// 80:   end
// 81:
// 82:   sig { params(path: T.any(String, Pathname)).returns(T.class_of(Formula)) }
// 83:   def self.formula_class_get_from_path(path)
// 84:     platform_cache.fetch(:path).fetch(path.to_s)
// 85:   end
// 86:
// 87:   sig { params(name: String).returns(T.class_of(Formula)) }
// 88:   def self.formula_class_get_from_api(name)
// 89:     platform_cache.fetch(:api).fetch(name)
// 90:   end
// 91:
// 92:   sig { void }
// 93:   def self.clear_cache
// 94:     platform_cache.each do |type, cached_objects|
// 95:       next if type == :formulary_factory
// 96:
// 97:       cached_objects.each_value do |klass|
// 98:         class_name = klass.name
// 99:
// 100:         # Already removed from namespace.
// 101:         next if class_name.nil?
// 102:
// 103:         namespace = Utils.deconstantize(class_name)
// 104:         next if Utils.deconstantize(namespace) != name
// 105:
// 106:         remove_const(Utils.demodulize(namespace).to_sym)
// 107:       end
// 108:     end
// 109:
// 110:     super
// 111:   end
// 112:
// 113:   sig {
// 114:     params(
// 115:       name:          String,
// 116:       path:          Pathname,
// 117:       contents:      String,
// 118:       namespace:     String,
// 119:       flags:         T::Array[String],
// 120:       ignore_errors: T::Boolean,
// 121:     ).returns(T.class_of(Formula))
// 122:   }
// 123:   def self.load_formula(name, path, contents, namespace, flags:, ignore_errors:)
// 124:     raise "Formula loading disabled by `$HOMEBREW_DISABLE_LOAD_FORMULA`!" if Homebrew::EnvConfig.disable_load_formula?
// 125:
// 126:     Homebrew::Trust.require_trusted_formula!(name, path)
// 127:
// 128:     require "formula"
// 129:     require "stringio"
// 130:
// 131:     # Capture stdout to prevent formulae from printing to stdout unexpectedly.
// 132:     old_stdout = $stdout
// 133:     $stdout = StringIO.new
// 134:
// 135:     mod = Module.new
// 136:     namespace = namespace.to_sym
// 137:     remove_const(namespace) if const_defined?(namespace)
// 138:     const_set(namespace, mod)
// 139:
// 140:     eval_formula = lambda do
// 141:       # Set `BUILD_FLAGS` in the formula's namespace so we can
// 142:       # access them from within the formula's class scope.
// 143:       mod.const_set(:BUILD_FLAGS, flags)
// 144:       mod.module_eval(contents, path.to_s)
// 145:     rescue NameError, ArgumentError, ScriptError, MethodDeprecatedError, MacOSVersion::Error => e
// 146:       remove_const(namespace)
// 147:       raise FormulaUnreadableError.new(name, e)
// 148:     end
// 149:     ENV.clear_sensitive_environment_for_eval! do
// 150:       if ignore_errors
// 151:         require "ignorable"
// 152:
// 153:         on_ignorable = lambda do |e|
// 154:           case e
// 155:           when NameError, ArgumentError, MethodDeprecatedError, MacOSVersion::Error then :ignore
// 156:           else :raise
// 157:           end
// 158:         end
// 159:         Ignorable.hook_raise(on_ignorable:, &eval_formula)
// 160:       else
// 161:         eval_formula.call
// 162:       end
// 163:     end
// 164:
// 165:     class_name = class_s(name)
// 166:
// 167:     # The formula's class name and module constants are only known at runtime.
// 168:     # rubocop:disable Sorbet/ConstantsFromStrings
// 169:     begin
// 170:       mod.const_get(class_name)
// 171:     rescue NameError => e
// 172:       class_list = mod.constants
// 173:                       .map { |const_name| mod.const_get(const_name) }
// 174:                       .grep(Class)
// 175:       new_exception = FormulaClassUnavailableError.new(name, path, class_name, class_list)
// 176:       remove_const(namespace)
// 177:       raise new_exception, "", e.backtrace
// 178:     end
// 179:     # rubocop:enable Sorbet/ConstantsFromStrings
// 180:   ensure
// 181:     # TODO: Make printing to stdout an error so that we can print a tap name.
// 182:     #       See discussion at https://github.com/Homebrew/brew/pull/20226#discussion_r2195886888
// 183:     if old_stdout && $stdout.respond_to?(:string) && (printed_to_stdout = $stdout.string.strip.presence)
// 184:       opoo <<~WARNING
// 185:         Formula #{name} attempted to print the following while being loaded:
// 186:         #{printed_to_stdout}
// 187:       WARNING
// 188:     end
// 189:     $stdout = old_stdout if old_stdout
// 190:   end
// 191:
// 192:   sig { params(identifier: String).returns(String) }
// 193:   def self.namespace_key(identifier)
// 194:     Digest::SHA2.hexdigest(
// 195:       "#{Homebrew::SimulateSystem.current_os}_#{Homebrew::SimulateSystem.current_arch}:#{identifier}",
// 196:     )
// 197:   end
// 198:
// 199:   sig { params(string: String).returns(String) }
// 200:   def self.replace_placeholders(string)
// 201:     string.gsub(HOMEBREW_PREFIX_PLACEHOLDER, HOMEBREW_PREFIX)
// 202:           .gsub(HOMEBREW_CELLAR_PLACEHOLDER, HOMEBREW_CELLAR)
// 203:           .gsub(HOMEBREW_HOME_PLACEHOLDER, Dir.home)
// 204:   end
// 205:
// 206:   sig {
// 207:     params(name: String, path: Pathname, flags: T::Array[String], ignore_errors: T::Boolean)
// 208:       .returns(T.class_of(Formula))
// 209:   }
// 210:   def self.load_formula_from_path(name, path, flags:, ignore_errors:)
// 211:     contents = path.open("r") { |f| ensure_utf8_encoding(f).read }
// 212:     namespace = "FormulaNamespace#{namespace_key(path.to_s)}"
// 213:     klass = load_formula(name, path, contents, namespace, flags:, ignore_errors:)
// 214:     platform_cache[:path] ||= {}
// 215:     platform_cache.fetch(:path)[path.to_s] = klass
// 216:   end
// 217:
// 218:   sig {
// 219:     params(
// 220:       name:           String,
// 221:       formula_struct: Homebrew::API::FormulaStruct,
// 222:       api_source:     T::Hash[String, T.untyped],
// 223:       tap_git_head:   String,
// 224:       flags:          T::Array[String],
// 225:       internal_api:   T::Boolean,
// 226:     ).returns(T.class_of(Formula))
// 227:   }
// 228:   def self.load_formula_from_struct!(name, formula_struct, api_source:, tap_git_head:, flags:, internal_api: false)
// 229:     namespace = :"FormulaNamespaceAPI#{namespace_key(api_source.to_json)}"
// 230:
// 231:     mod = Module.new
// 232:     remove_const(namespace) if const_defined?(namespace)
// 233:     const_set(namespace, mod)
// 234:
// 235:     mod.const_set(:BUILD_FLAGS, flags)
// 236:
// 237:     class_name = class_s(name)
// 238:     ruby_source_path = "Formula/#{CoreTap.instance.new_formula_subdirectory(name)}/#{name.downcase}.rb"
// 239:
// 240:     klass = Class.new(::Formula) do
// 241:       @loaded_from_api = T.let(true, T.nilable(T::Boolean))
// 242:       @loaded_from_internal_api = T.let(internal_api, T.nilable(T::Boolean))
// 243:       @api_source = T.let(api_source, T.nilable(T::Hash[String, T.untyped]))
// 244:
// 245:       desc formula_struct.desc
// 246:       homepage formula_struct.homepage
// 247:       license formula_struct.license
// 248:       revision formula_struct.revision
// 249:       version_scheme formula_struct.version_scheme
// 250:
// 251:       if formula_struct.stable?
// 252:         stable do
// 253:           url(*formula_struct.stable_url_args)
// 254:           version formula_struct.stable_version
// 255:           if (checksum = formula_struct.stable_checksum)
// 256:             sha256 checksum
// 257:           end
// 258:
// 259:           formula_struct.stable_patches.each do |patch_hash|
// 260:             patch patch_hash.fetch("strip", patch_hash[:strip]).to_sym do
// 261:               T.bind(self, Resource::Patch)
// 262:
// 263:               if (patch_url = patch_hash.fetch("url", patch_hash[:url]))
// 264:                 url patch_url
// 265:                 if (patch_sha256 = patch_hash.fetch("sha256", patch_hash[:sha256]))
// 266:                   sha256 patch_sha256
// 267:                 end
// 268:                 apply patch_hash.fetch("apply", patch_hash[:apply]) if patch_hash.fetch("apply", patch_hash[:apply])
// 269:                 if (patch_directory = patch_hash.fetch("directory", patch_hash[:directory]))
// 270:                   directory patch_directory
// 271:                 end
// 272:               elsif (patch_file = patch_hash.fetch("file", patch_hash[:file]))
// 273:                 file patch_file
// 274:               end
// 275:
// 276:               if (patch_resolves = patch_hash.fetch("resolves", patch_hash[:resolves]))
// 277:                 resolves(*patch_resolves.map { |resolved| resolved.fetch("id", resolved[:id]) })
// 278:               end
// 279:             end
// 280:           end
// 281:
// 282:           formula_struct.stable_dependencies.each do |dep|
// 283:             depends_on dep
// 284:           end
// 285:
// 286:           formula_struct.stable_uses_from_macos.each do |args|
// 287:             uses_from_macos(*args)
// 288:           end
// 289:         end
// 290:       end
// 291:
// 292:       if formula_struct.head?
// 293:         head do
// 294:           url(*formula_struct.head_url_args)
// 295:
// 296:           formula_struct.head_dependencies.each do |dep|
// 297:             depends_on dep
// 298:           end
// 299:
// 300:           formula_struct.head_uses_from_macos.each do |args|
// 301:             uses_from_macos(*args)
// 302:           end
// 303:         end
// 304:       end
// 305:
// 306:       no_autobump!(**formula_struct.no_autobump_args) if formula_struct.no_autobump?
// 307:
// 308:       if formula_struct.bottle?
// 309:         bottle do
// 310:           if Homebrew::EnvConfig.bottle_domain_custom?
// 311:             root_url Homebrew::EnvConfig.bottle_domain
// 312:           else
// 313:             root_url HOMEBREW_BOTTLE_DEFAULT_DOMAIN
// 314:           end
// 315:           rebuild formula_struct.bottle_rebuild
// 316:           formula_struct.bottle_checksums.each do |args|
// 317:             sha256(**args)
// 318:           end
// 319:         end
// 320:       end
// 321:
// 322:       pour_bottle?(**formula_struct.pour_bottle_args) if formula_struct.pour_bottle?
// 323:
// 324:       keg_only(*formula_struct.keg_only_args) if formula_struct.keg_only?
// 325:
// 326:       deprecate!(**formula_struct.deprecate_args) if formula_struct.deprecate?
// 327:       disable!(**formula_struct.disable_args) if formula_struct.disable?
// 328:
// 329:       formula_struct.conflicts.each do |name, args|
// 330:         conflicts_with(name, **args)
// 331:       end
// 332:
// 333:       formula_struct.link_overwrite_paths.each do |path|
// 334:         link_overwrite path
// 335:       end
// 336:
// 337:       @post_install_steps = T.let(
// 338:         formula_struct.post_install_steps,
// 339:         T.nilable(Homebrew::InstallSteps::Steps),
// 340:       )
// 341:       @post_install_steps_defined = T.let(formula_struct.post_install_steps.present?, T.nilable(T::Boolean))
// 342:
// 343:       define_method(:install) do
// 344:         raise NotImplementedError, "Cannot build from source from abstract formula."
// 345:       end
// 346:
// 347:       @post_install_defined_boolean = T.let(formula_struct.post_install_defined, T.nilable(T::Boolean))
// 348:       define_method(:post_install_defined?) do
// 349:         self.class.instance_variable_get(:@post_install_defined_boolean)
// 350:       end
// 351:
// 352:       if formula_struct.service?
// 353:         service do
// 354:           run(*formula_struct.service_run_args, **formula_struct.service_run_kwargs) if formula_struct.service_run?
// 355:           name(**formula_struct.service_name_args) if formula_struct.service_name?
// 356:
// 357:           formula_struct.service_args.each do |key, arg|
// 358:             public_send(key, arg)
// 359:           end
// 360:         end
// 361:       end
// 362:
// 363:       @caveats_string = T.let(formula_struct.caveats, T.nilable(String))
// 364:       define_method(:caveats) do
// 365:         self.class.instance_variable_get(:@caveats_string)
// 366:       end
// 367:
// 368:       @tap_git_head_string = T.let(tap_git_head, T.nilable(String))
// 369:       define_method(:tap_git_head) do
// 370:         self.class.instance_variable_get(:@tap_git_head_string)
// 371:       end
// 372:
// 373:       @oldnames_array = T.let(formula_struct.oldnames, T.nilable(T::Array[String]))
// 374:       define_method(:oldnames) do
// 375:         self.class.instance_variable_get(:@oldnames_array)
// 376:       end
// 377:
// 378:       @aliases_array = T.let(formula_struct.aliases, T.nilable(T::Array[String]))
// 379:       define_method(:aliases) do
// 380:         self.class.instance_variable_get(:@aliases_array)
// 381:       end
// 382:
// 383:       @versioned_formulae_array = T.let(formula_struct.versioned_formulae, T.nilable(T::Array[String]))
// 384:       define_method(:versioned_formulae_names) do
// 385:         self.class.instance_variable_get(:@versioned_formulae_array)
// 386:       end
// 387:
// 388:       @ruby_source_path_string = T.let(ruby_source_path, T.nilable(String))
// 389:       define_method(:ruby_source_path) do
// 390:         self.class.instance_variable_get(:@ruby_source_path_string)
// 391:       end
// 392:
// 393:       @ruby_source_checksum_string = T.let(formula_struct.ruby_source_checksum, T.nilable(String))
// 394:       define_method(:ruby_source_checksum) do
// 395:         checksum = self.class.instance_variable_get(:@ruby_source_checksum_string)
// 396:         Checksum.new(checksum) if checksum
// 397:       end
// 398:     end
// 399:
// 400:     mod.const_set(class_name, klass)
// 401:
// 402:     platform_cache[:api] ||= {}
// 403:     platform_cache.fetch(:api)[name] = klass
// 404:   end
// 405:
// 406:   sig {
// 407:     params(name: String, spec: T.nilable(Symbol), force_bottle: T::Boolean, flags: T::Array[String]).returns(Formula)
// 408:   }
// 409:   def self.resolve(
// 410:     name,
// 411:     spec: nil,
// 412:     force_bottle: false,
// 413:     flags: []
// 414:   )
// 415:     if name.include?("/") || File.exist?(name)
// 416:       f = factory(name, *spec, force_bottle:, flags:)
// 417:       if f.any_version_installed?
// 418:         tab = Tab.for_formula(f)
// 419:         resolved_spec = spec || tab.spec
// 420:         f.active_spec = resolved_spec if f.public_send(resolved_spec)
// 421:         f.build = tab
// 422:         if f.head? && tab.tabfile
// 423:           k = Keg.new(T.must(tab.tabfile).parent)
// 424:           f.version.update_commit(k.version.version.commit) if k.version.head?
// 425:         end
// 426:       end
// 427:     else
// 428:       rack = to_rack(name)
// 429:       alias_path = factory(name, force_bottle:, flags:).alias_path
// 430:       f = from_rack(rack, *spec, alias_path:, force_bottle:, flags:)
// 431:     end
// 432:
// 433:     # If this formula was installed with an alias that has since changed,
// 434:     # then it was specified explicitly in ARGV. (Using the alias would
// 435:     # instead have found the new formula.)
// 436:     #
// 437:     # Because of this, the user is referring to this specific formula,
// 438:     # not any formula targeted by the same alias, so in this context
// 439:     # the formula shouldn't be considered outdated if the alias used to
// 440:     # install it has changed.
// 441:     f.follow_installed_alias = false
// 442:
// 443:     f
// 444:   end
// 445:
// 446:   sig { params(io: IO).returns(IO) }
// 447:   def self.ensure_utf8_encoding(io)
// 448:     io.set_encoding(Encoding::UTF_8)
// 449:   end
// 450:
// 451:   sig { params(name: String).returns(String) }
// 452:   def self.class_s(name)
// 453:     class_name = name.capitalize
// 454:     class_name.gsub!(/[-_.\s]([a-zA-Z0-9])/) { T.must(Regexp.last_match(1)).upcase }
// 455:     class_name.tr!("+", "x")
// 456:     class_name.sub!(/(.)@(\d)/, "\\1AT\\2")
// 457:     class_name
// 458:   end
// 459:
// 460:   # A {FormulaLoader} returns instances of formulae.
// 461:   # Subclasses implement loaders for particular sources of formulae.
// 462:   class FormulaLoader
// 463:     include Context
// 464:     include Utils::Output::Mixin
// 465:
// 466:     # The formula's name.
// 467:     sig { returns(String) }
// 468:     attr_reader :name
// 469:
// 470:     # The formula file's path.
// 471:     sig { returns(Pathname) }
// 472:     attr_reader :path
// 473:
// 474:     # The name used to install the formula.
// 475:     sig { returns(T.nilable(T.any(Pathname, String))) }
// 476:     attr_reader :alias_path
// 477:
// 478:     # The formula's tap (`nil` if it should be implicitly determined).
// 479:     sig { returns(T.nilable(Tap)) }
// 480:     attr_reader :tap
// 481:
// 482:     sig {
// 483:       params(name: String, path: Pathname, alias_path: T.nilable(T.any(Pathname, String)), tap: T.nilable(Tap)).void
// 484:     }
// 485:     def initialize(name, path, alias_path: nil, tap: nil)
// 486:       @name = name
// 487:       @path = path
// 488:       @alias_path = alias_path
// 489:       @tap = tap
// 490:     end
// 491:
// 492:     # Gets the formula instance.
// 493:     # `alias_path` can be overridden here in case an alias was used to refer to
// 494:     # a formula that was loaded in another way.
// 495:     sig {
// 496:       overridable.params(
// 497:         spec:          Symbol,
// 498:         alias_path:    T.nilable(T.any(Pathname, String)),
// 499:         force_bottle:  T::Boolean,
// 500:         flags:         T::Array[String],
// 501:         ignore_errors: T::Boolean,
// 502:       ).returns(Formula)
// 503:     }
// 504:     def get_formula(spec, alias_path: nil, force_bottle: false, flags: [], ignore_errors: false)
// 505:       alias_path ||= self.alias_path
// 506:       alias_path = Pathname(alias_path) if alias_path.is_a?(String)
// 507:       klass(flags:, ignore_errors:)
// 508:         .new(name, path, spec, alias_path:, tap:, force_bottle:)
// 509:     end
// 510:
// 511:     sig { overridable.params(flags: T::Array[String], ignore_errors: T::Boolean).returns(T.class_of(Formula)) }
// 512:     def klass(flags:, ignore_errors:)
// 513:       load_file(flags:, ignore_errors:) unless Formulary.formula_class_defined_from_path?(path)
// 514:       Formulary.formula_class_get_from_path(path)
// 515:     end
// 516:
// 517:     private
// 518:
// 519:     sig { overridable.params(flags: T::Array[String], ignore_errors: T::Boolean).void }
// 520:     def load_file(flags:, ignore_errors:)
// 521:       raise FormulaUnavailableError, name unless path.file?
// 522:
// 523:       Formulary.load_formula_from_path(name, path, flags:, ignore_errors:)
// 524:     end
// 525:   end
// 526:
// 527:   # Loads a formula from a bottle.
// 528:   class FromBottleLoader < FormulaLoader
// 529:     include Utils::Output::Mixin
// 530:
// 531:     sig {
// 532:       params(ref: T.any(String, Pathname, URI::Generic), from: T.nilable(Symbol), warn: T::Boolean)
// 533:         .returns(T.nilable(T.attached_class))
// 534:     }
// 535:     def self.try_new(ref, from: nil, warn: false)
// 536:       return if Homebrew::EnvConfig.forbid_packages_from_paths?
// 537:
// 538:       ref = ref.to_s
// 539:
// 540:       new(ref) if HOMEBREW_BOTTLES_EXTNAME_REGEX.match?(ref) && File.exist?(ref)
// 541:     end
// 542:
// 543:     sig { params(bottle_name: String, warn: T::Boolean).void }
// 544:     def initialize(bottle_name, warn: false)
// 545:       @bottle_path = T.let(Pathname(bottle_name).realpath, Pathname)
// 546:       name, full_name = Utils::Bottles.resolve_formula_names(@bottle_path)
// 547:       tap, = Tap.with_formula_name(full_name)
// 548:
// 549:       # We might not have tap information with --only-json-tab bottles.
// 550:       # In this scenario we make a best effort guess, assuming Homebrew/core
// 551:       # unless we find it in another tap we have installed.
// 552:       fallback_path = Formulary.path(full_name)
// 553:       tap ||= Tap.from_path(fallback_path)
// 554:
// 555:       # Mimic a Cellar path to simulate relaxed deprecation behaviour shared with postinstalls.
// 556:       version = Utils::Bottles.resolve_version(@bottle_path)
// 557:       @cellar_formula_path = T.let(HOMEBREW_CELLAR/name/version/".brew"/"#{name}.rb", Pathname)
// 558:
// 559:       super name, fallback_path, tap:
// 560:     end
// 561:
// 562:     sig {
// 563:       override.params(
// 564:         spec:          Symbol,
// 565:         alias_path:    T.nilable(T.any(Pathname, String)),
// 566:         force_bottle:  T::Boolean,
// 567:         flags:         T::Array[String],
// 568:         ignore_errors: T::Boolean,
// 569:       ).returns(Formula)
// 570:     }
// 571:     def get_formula(spec, alias_path: nil, force_bottle: false, flags: [], ignore_errors: false)
// 572:       formula = begin
// 573:         contents = Utils::Bottles.formula_contents(@bottle_path, name:)
// 574:         Formulary.from_contents(name, @cellar_formula_path, contents, spec,
// 575:                                 tap:, force_bottle:, flags:, ignore_errors:)
// 576:       rescue FormulaUnreadableError => e
// 577:         opoo <<~EOS
// 578:           Unreadable formula in #{@bottle_path}:
// 579:           #{e}
// 580:         EOS
// 581:         super
// 582:       rescue BottleFormulaUnavailableError => e
// 583:         opoo <<~EOS
// 584:           #{e}
// 585:           Falling back to non-bottle formula.
// 586:         EOS
// 587:         super
// 588:       end
// 589:       formula.local_bottle_path = @bottle_path
// 590:       formula
// 591:     end
// 592:   end
// 593:
// 594:   # Loads formulae from disk using a path.
// 595:   class FromPathLoader < FormulaLoader
// 596:     sig {
// 597:       params(ref: T.any(String, Pathname, URI::Generic), from: T.nilable(Symbol), warn: T::Boolean)
// 598:         .returns(T.nilable(T.attached_class))
// 599:     }
// 600:     def self.try_new(ref, from: nil, warn: false)
// 601:       path = case ref
// 602:       when String
// 603:         Pathname(ref)
// 604:       when Pathname
// 605:         ref
// 606:       else
// 607:         return
// 608:       end
// 609:
// 610:       return unless path.expand_path.exist?
// 611:       return unless ::Utils::Path.loadable_package_path?(path, :formula)
// 612:
// 613:       if (tap = Tap.from_path(path))
// 614:         # Only treat symlinks in taps as aliases.
// 615:         if path.symlink?
// 616:           alias_path = path
// 617:           path = alias_path.resolved_path
// 618:         end
// 619:       else
// 620:         # Don't treat cache symlinks as aliases.
// 621:         tap = Homebrew::API.tap_from_source_download(path)
// 622:       end
// 623:
// 624:       return if path.extname != ".rb"
// 625:
// 626:       new(path, alias_path:, tap:)
// 627:     end
// 628:
// 629:     sig { params(path: T.any(Pathname, String), alias_path: T.nilable(Pathname), tap: T.nilable(Tap)).void }
// 630:     def initialize(path, alias_path: nil, tap: nil)
// 631:       path = Pathname(path).expand_path
// 632:       name = path.basename(".rb").to_s
// 633:       alias_path = alias_path&.expand_path
// 634:       alias_dir = alias_path&.dirname
// 635:
// 636:       alias_path = nil if alias_dir != tap&.alias_dir
// 637:
// 638:       super(name, path, alias_path:, tap:)
// 639:     end
// 640:   end
// 641:
// 642:   # Loads formula from a URI.
// 643:   class FromURILoader < FormulaLoader
// 644:     sig {
// 645:       params(ref: T.any(String, Pathname, URI::Generic), from: T.nilable(Symbol), warn: T::Boolean)
// 646:         .returns(T.nilable(T.attached_class))
// 647:     }
// 648:     def self.try_new(ref, from: nil, warn: false)
// 649:       return if Homebrew::EnvConfig.forbid_packages_from_paths?
// 650:
// 651:       # Cache compiled regex
// 652:       @uri_regex ||= T.let(begin
// 653:         uri_regex = ::URI::RFC2396_PARSER.make_regexp
// 654:         Regexp.new("\\A#{uri_regex.source}\\Z", uri_regex.options)
// 655:       end, T.nilable(Regexp))
// 656:
// 657:       uri = ref.to_s
// 658:       return unless uri.match?(@uri_regex)
// 659:
// 660:       uri = URI(uri)
// 661:       return unless uri.path
// 662:       return unless uri.scheme.present?
// 663:
// 664:       new(uri, from:)
// 665:     end
// 666:
// 667:     sig { returns(T.any(URI::Generic, String)) }
// 668:     attr_reader :url
// 669:
// 670:     sig { params(url: T.any(URI::Generic, String), from: T.nilable(Symbol)).void }
// 671:     def initialize(url, from: nil)
// 672:       @url = url
// 673:       @from = from
// 674:       uri_path = URI(url).path
// 675:       raise ArgumentError, "URL has no path component" unless uri_path
// 676:
// 677:       formula = File.basename(uri_path, ".rb")
// 678:       super formula, HOMEBREW_CACHE_FORMULA/File.basename(uri_path)
// 679:     end
// 680:
// 681:     sig { override.params(flags: T::Array[String], ignore_errors: T::Boolean).void }
// 682:     def load_file(flags:, ignore_errors:)
// 683:       url_scheme = URI(url).scheme
// 684:       if ALLOWED_URL_SCHEMES.exclude?(url_scheme)
// 685:         raise UnsupportedInstallationMethod,
// 686:               "Non-checksummed download of #{name} formula file from an arbitrary URL is unsupported! " \
// 687:               "Use `brew version-install` to install a formula file from your own custom tap " \
// 688:               "instead."
// 689:       end
// 690:       HOMEBREW_CACHE_FORMULA.mkpath
// 691:       FileUtils.rm_f(path)
// 692:       Utils::Curl.curl_download url.to_s, to: path
// 693:       super
// 694:     rescue MethodDeprecatedError => e
// 695:       if (match_data = url.to_s.match(%r{github.com/(?<user>[\w-]+)/(?<repo>[\w-]+)/}).presence)
// 696:         e.issues_url = "https://github.com/#{match_data[:user]}/#{match_data[:repo]}/issues/new"
// 697:       end
// 698:       raise
// 699:     end
// 700:   end
// 701:
// 702:   # Loads tapped formulae.
// 703:   class FromTapLoader < FormulaLoader
// 704:     sig { returns(Tap) }
// 705:     attr_reader :tap
// 706:
// 707:     sig { returns(Pathname) }
// 708:     attr_reader :path
// 709:
// 710:     sig {
// 711:       params(ref: T.any(String, Pathname, URI::Generic), from: T.nilable(Symbol), warn: T::Boolean)
// 712:         .returns(T.nilable(T.attached_class))
// 713:     }
// 714:     def self.try_new(ref, from: nil, warn: false)
// 715:       ref = ref.to_s
// 716:
// 717:       return unless (name_tap_type = Formulary.tap_formula_name_type(ref, warn:))
// 718:
// 719:       loader_from_name_tap_type(name_tap_type)
// 720:     end
// 721:
// 722:     sig {
// 723:       params(name_tap_type: [String, Tap, T.nilable(Symbol), T.nilable(String)])
// 724:         .returns(T.nilable(T.attached_class))
// 725:     }
// 726:     def self.loader_from_name_tap_type(name_tap_type)
// 727:       name, tap, type, alias_name = name_tap_type
// 728:       path = Formulary.find_formula_in_tap(name, tap)
// 729:
// 730:       if type == :migration && tap.core_tap? && (loader = FromAPILoader.try_new(name))
// 731:         T.cast(loader, T.attached_class)
// 732:       else
// 733:         new(name, path, tap:, alias_name:)
// 734:       end
// 735:     end
// 736:
// 737:     sig { params(name: String, path: Pathname, tap: Tap, alias_name: T.nilable(String)).void }
// 738:     def initialize(name, path, tap:, alias_name: nil)
// 739:       alias_path = tap.alias_dir/alias_name if alias_name
// 740:
// 741:       super(name, path, alias_path:, tap:)
// 742:       @tap = tap
// 743:     end
// 744:
// 745:     sig {
// 746:       override.params(
// 747:         spec:          Symbol,
// 748:         alias_path:    T.nilable(T.any(Pathname, String)),
// 749:         force_bottle:  T::Boolean,
// 750:         flags:         T::Array[String],
// 751:         ignore_errors: T::Boolean,
// 752:       ).returns(Formula)
// 753:     }
// 754:     def get_formula(spec, alias_path: nil, force_bottle: false, flags: [], ignore_errors: false)
// 755:       super
// 756:     rescue FormulaUnreadableError => e
// 757:       raise TapFormulaUnreadableError.new(tap, name, e.formula_error), "", e.backtrace
// 758:     rescue FormulaClassUnavailableError => e
// 759:       raise TapFormulaClassUnavailableError.new(tap, name, e.path, e.class_name, e.class_list), "", e.backtrace
// 760:     rescue FormulaUnavailableError => e
// 761:       raise TapFormulaUnavailableError.new(tap, name), "", e.backtrace
// 762:     end
// 763:
// 764:     sig { override.params(flags: T::Array[String], ignore_errors: T::Boolean).void }
// 765:     def load_file(flags:, ignore_errors:)
// 766:       super
// 767:     rescue MethodDeprecatedError => e
// 768:       e.issues_url = tap.issues_url || tap.to_s
// 769:       raise
// 770:     end
// 771:   end
// 772:
// 773:   # Loads a formula from a name, as long as it exists only in a single tap.
// 774:   class FromNameLoader < FromTapLoader
// 775:     extend ::Utils::Output::Mixin
// 776:
// 777:     sig {
// 778:       override.params(ref: T.any(String, Pathname, URI::Generic), from: T.nilable(Symbol), warn: T::Boolean)
// 779:               .returns(T.nilable(T.attached_class))
// 780:     }
// 781:     def self.try_new(ref, from: nil, warn: false)
// 782:       return unless ref.is_a?(String)
// 783:       return unless ref.match?(/\A#{HOMEBREW_TAP_FORMULA_NAME_REGEX}\Z/o)
// 784:
// 785:       name = ref.downcase
// 786:
// 787:       # If it exists in the default tap, never treat it as ambiguous with another tap.
// 788:       if (core_tap = CoreTap.instance).installed? && (name_tap_type = Formulary.tap_formula_name_type(
// 789:         "#{core_tap}/#{name}", warn: false
// 790:       ))
// 791:         migrated_name, migrated_tap, type = name_tap_type
// 792:
// 793:         if warn && [:rename, :migration].include?(type) &&
// 794:            !(type == :migration && migrated_tap.core_cask_tap?)
// 795:           opoo "Formula #{name} was renamed to " \
// 796:                "#{migrated_tap.core_tap? ? migrated_name : "#{migrated_tap}/#{migrated_name}"}."
// 797:         end
// 798:
// 799:         if (core_loader = loader_from_name_tap_type(name_tap_type))&.path&.exist?
// 800:           return core_loader
// 801:         end
// 802:       end
// 803:
// 804:       loaders = Tap.select { |tap| tap.installed? && !tap.core_tap? }
// 805:                    .filter_map { |tap| super("#{tap}/#{name}", warn:) }
// 806:                    .uniq(&:path)
// 807:                    .select { |loader| loader.is_a?(FromAPILoader) || loader.path.exist? }
// 808:
// 809:       case loaders.count
// 810:       when 1
// 811:         loaders.first
// 812:       when 2..Float::INFINITY
// 813:         raise TapFormulaAmbiguityError.new(name, loaders)
// 814:       end
// 815:     end
// 816:   end
// 817:
// 818:   # Loads a formula from a formula file in a keg.
// 819:   class FromKegLoader < FormulaLoader
// 820:     sig {
// 821:       params(ref: T.any(String, Pathname, URI::Generic), from: T.nilable(Symbol), warn: T::Boolean)
// 822:         .returns(T.nilable(T.attached_class))
// 823:     }
// 824:     def self.try_new(ref, from: nil, warn: false)
// 825:       ref = ref.to_s
// 826:
// 827:       keg_directory = HOMEBREW_PREFIX/"opt/#{ref}"
// 828:       return unless keg_directory.directory?
// 829:
// 830:       # The formula file in `.brew` will use the canonical name, whereas `ref` can be an alias.
// 831:       # Use `Keg#name` to get the canonical name.
// 832:       keg = Keg.new(keg_directory)
// 833:       return unless (keg_formula = keg_directory/".brew/#{keg.name}.rb").file?
// 834:
// 835:       new(keg.name, keg_formula, tap: keg.tab.tap)
// 836:     end
// 837:   end
// 838:
// 839:   # Loads a formula from a cached formula file.
// 840:   class FromCacheLoader < FormulaLoader
// 841:     sig {
// 842:       params(ref: T.any(String, Pathname, URI::Generic), from: T.nilable(Symbol), warn: T::Boolean)
// 843:         .returns(T.nilable(T.attached_class))
// 844:     }
// 845:     def self.try_new(ref, from: nil, warn: false)
// 846:       ref = ref.to_s
// 847:
// 848:       return unless (cached_formula = HOMEBREW_CACHE_FORMULA/"#{ref}.rb").file?
// 849:
// 850:       new(ref, cached_formula)
// 851:     end
// 852:   end
// 853:
// 854:   # Pseudo-loader which will raise a {FormulaUnavailableError} when trying to load the corresponding formula.
// 855:   class NullLoader < FormulaLoader
// 856:     sig {
// 857:       params(ref: T.any(String, Pathname, URI::Generic), from: T.nilable(Symbol), warn: T::Boolean)
// 858:         .returns(T.nilable(T.attached_class))
// 859:     }
// 860:     def self.try_new(ref, from: nil, warn: false)
// 861:       return if ref.is_a?(URI::Generic)
// 862:
// 863:       new(ref)
// 864:     end
// 865:
// 866:     sig { params(ref: T.any(String, Pathname)).void }
// 867:     def initialize(ref)
// 868:       name = File.basename(ref, ".rb")
// 869:       super name, Formulary.core_path(name)
// 870:     end
// 871:
// 872:     sig {
// 873:       override.params(
// 874:         _spec:         Symbol,
// 875:         alias_path:    T.nilable(T.any(Pathname, String)),
// 876:         force_bottle:  T::Boolean,
// 877:         flags:         T::Array[String],
// 878:         ignore_errors: T::Boolean,
// 879:       ).returns(Formula)
// 880:     }
// 881:     def get_formula(_spec, alias_path: nil, force_bottle: false, flags: [], ignore_errors: false)
// 882:       raise FormulaUnavailableError, name
// 883:     end
// 884:   end
// 885:
// 886:   # Load formulae directly from their contents.
// 887:   class FormulaContentsLoader < FormulaLoader
// 888:     # The formula's contents.
// 889:     sig { returns(String) }
// 890:     attr_reader :contents
// 891:
// 892:     sig { params(name: String, path: Pathname, contents: String, tap: T.nilable(Tap)).void }
// 893:     def initialize(name, path, contents, tap: nil)
// 894:       @contents = contents
// 895:       super name, path, tap:
// 896:     end
// 897:
// 898:     sig { override.params(flags: T::Array[String], ignore_errors: T::Boolean).returns(T.class_of(Formula)) }
// 899:     def klass(flags:, ignore_errors:)
// 900:       namespace = "FormulaNamespace#{Digest::MD5.hexdigest(contents.to_s)}"
// 901:       Formulary.load_formula(name, path, contents, namespace, flags:, ignore_errors:)
// 902:     end
// 903:   end
// 904:
// 905:   # Load a formula from the API.
// 906:   class FromAPILoader < FormulaLoader
// 907:     sig {
// 908:       params(ref: T.any(String, Pathname, URI::Generic), from: T.nilable(Symbol), warn: T::Boolean)
// 909:         .returns(T.nilable(T.attached_class))
// 910:     }
// 911:     def self.try_new(ref, from: nil, warn: false)
// 912:       return if Homebrew::EnvConfig.no_install_from_api?
// 913:       return unless ref.is_a?(String)
// 914:       return unless (name = ref[HOMEBREW_DEFAULT_TAP_FORMULA_REGEX, :name])
// 915:       if !Homebrew::API.formula_name?(name) &&
// 916:          !Homebrew::API.formula_aliases.key?(name) &&
// 917:          !Homebrew::API.formula_renames.key?(name)
// 918:         return
// 919:       end
// 920:
// 921:       ref = "#{CoreTap.instance}/#{name}"
// 922:
// 923:       return unless (name_tap_type = Formulary.tap_formula_name_type(ref, warn:))
// 924:
// 925:       name, tap, _type, alias_name = name_tap_type
// 926:
// 927:       new(name, tap:, alias_name:)
// 928:     end
// 929:
// 930:     sig { params(name: String, tap: T.nilable(Tap), alias_name: T.nilable(String)).void }
// 931:     def initialize(name, tap: nil, alias_name: nil)
// 932:       alias_path = CoreTap.instance.alias_dir/alias_name if alias_name
// 933:
// 934:       super(name, Formulary.core_path(name), alias_path:, tap:)
// 935:     end
// 936:
// 937:     sig { override.params(flags: T::Array[String], ignore_errors: T::Boolean).returns(T.class_of(Formula)) }
// 938:     def klass(flags:, ignore_errors:)
// 939:       load_from_api(flags:) unless Formulary.formula_class_defined_from_api?(name)
// 940:       Formulary.formula_class_get_from_api(name)
// 941:     end
// 942:
// 943:     private
// 944:
// 945:     sig { overridable.params(flags: T::Array[String]).void }
// 946:     def load_from_api(flags:)
// 947:       formula_struct = Homebrew::API::Internal.formula_struct(name)
// 948:       api_source = Homebrew::API::Internal.formula_hash(name)
// 949:       tap_git_head = Homebrew::API::Internal.formula_tap_git_head
// 950:
// 951:       raise FormulaUnavailableError, name if api_source.nil?
// 952:
// 953:       Formulary.load_formula_from_struct!(name, formula_struct, api_source:, tap_git_head:, flags:,
// 954:                                           internal_api: true)
// 955:     end
// 956:   end
// 957:
// 958:   # Load formulae directly from their JSON contents.
// 959:   class FormulaJSONContentsLoader < FromAPILoader
// 960:     sig { params(name: String, contents: T::Hash[String, T.untyped], tap: T.nilable(Tap), alias_name: T.nilable(String)).void }
// 961:     def initialize(name, contents, tap: nil, alias_name: nil)
// 962:       @contents = contents
// 963:       super(name, tap: tap, alias_name: alias_name)
// 964:     end
// 965:
// 966:     private
// 967:
// 968:     sig { override.params(flags: T::Array[String]).void }
// 969:     def load_from_api(flags:)
// 970:       tap_git_head = @contents.fetch("tap_git_head", "")
// 971:       formula_struct = Homebrew::API::Formula::FormulaStructGenerator.generate_formula_struct_hash(@contents)
// 972:       Formulary.load_formula_from_struct!(name, formula_struct, api_source: @contents, tap_git_head:, flags:)
// 973:     end
// 974:   end
// 975:
// 976:   # Return a {Formula} instance for the given reference.
// 977:   # `ref` is a string containing:
// 978:   #
// 979:   # * a formula name
// 980:   # * a formula pathname
// 981:   # * a formula URL
// 982:   # * a local bottle reference
// 983:   #
// 984:   # @api internal
// 985:   sig {
// 986:     params(
// 987:       ref:           T.any(Pathname, String),
// 988:       spec:          Symbol,
// 989:       alias_path:    T.nilable(T.any(Pathname, String)),
// 990:       from:          T.nilable(Symbol),
// 991:       warn:          T::Boolean,
// 992:       force_bottle:  T::Boolean,
// 993:       flags:         T::Array[String],
// 994:       ignore_errors: T::Boolean,
// 995:     ).returns(Formula)
// 996:   }
// 997:   def self.factory(
// 998:     ref,
// 999:     spec = :stable,
// 1000:     alias_path: nil,
// 1001:     from: nil,
// 1002:     warn: false,
// 1003:     force_bottle: false,
// 1004:     flags: [],
// 1005:     ignore_errors: false
// 1006:   )
// 1007:     cache_key = "#{ref}-#{spec}-#{alias_path}-#{from}"
// 1008:     return factory_cache.fetch(cache_key) if factory_cached? && factory_cache.key?(cache_key)
// 1009:
// 1010:     loader = loader_for(ref, from:, warn:)
// 1011:     formula = loader.get_formula(spec, alias_path:, force_bottle:, flags:, ignore_errors:)
// 1012:
// 1013:     factory_cache[cache_key] ||= formula if factory_cached?
// 1014:
// 1015:     formula
// 1016:   end
// 1017:
// 1018:   # Return a {Formula} instance for the given rack.
// 1019:   #
// 1020:   # @param spec when nil, will auto resolve the formula's spec.
// 1021:   # @param alias_path will be used if the formula is found not to be
// 1022:   #   installed and discarded if it is installed because the `alias_path` used
// 1023:   #   to install the formula will be set instead.
// 1024:   sig {
// 1025:     params(
// 1026:       rack:         Pathname,
// 1027:       # Automatically resolves the formula's spec if not specified.
// 1028:       spec:         T.nilable(Symbol),
// 1029:       alias_path:   T.nilable(T.any(Pathname, String)),
// 1030:       force_bottle: T::Boolean,
// 1031:       flags:        T::Array[String],
// 1032:       keg:          T.nilable(Keg),
// 1033:     ).returns(Formula)
// 1034:   }
// 1035:   def self.from_rack(rack, spec = nil, alias_path: nil, force_bottle: false, flags: [], keg: Keg.from_rack(rack))
// 1036:     options = {
// 1037:       alias_path:,
// 1038:       force_bottle:,
// 1039:       flags:,
// 1040:     }.compact
// 1041:
// 1042:     if keg
// 1043:       from_keg(keg, *spec, **options)
// 1044:     else
// 1045:       factory(rack.basename.to_s, *spec, from: :rack, warn: false, **options)
// 1046:     end
// 1047:   end
// 1048:
// 1049:   # Return whether given rack is keg-only.
// 1050:   sig { params(rack: Pathname).returns(T::Boolean) }
// 1051:   def self.keg_only?(rack)
// 1052:     Formulary.from_rack(rack).keg_only?
// 1053:   rescue FormulaUnavailableError, TapFormulaAmbiguityError
// 1054:     false
// 1055:   end
// 1056:
// 1057:   # Return a {Formula} instance for the given keg.
// 1058:   sig {
// 1059:     params(
// 1060:       keg:          Keg,
// 1061:       # Automatically resolves the formula's spec if not specified.
// 1062:       spec:         T.nilable(Symbol),
// 1063:       alias_path:   T.nilable(T.any(Pathname, String)),
// 1064:       force_bottle: T::Boolean,
// 1065:       flags:        T::Array[String],
// 1066:     ).returns(Formula)
// 1067:   }
// 1068:   def self.from_keg(
// 1069:     keg,
// 1070:     spec = nil,
// 1071:     alias_path: nil,
// 1072:     force_bottle: false,
// 1073:     flags: []
// 1074:   )
// 1075:     tab = keg.tab
// 1076:     tap = tab.tap
// 1077:     spec ||= tab.spec
// 1078:
// 1079:     formula_name = keg.rack.basename.to_s
// 1080:
// 1081:     options = {
// 1082:       alias_path:,
// 1083:       from:         :keg,
// 1084:       warn:         false,
// 1085:       force_bottle:,
// 1086:       flags:,
// 1087:     }.compact
// 1088:
// 1089:     f = if tap.nil?
// 1090:       factory(formula_name, spec, **options)
// 1091:     else
// 1092:       begin
// 1093:         factory("#{tap}/#{formula_name}", spec, **options)
// 1094:       rescue FormulaUnavailableError
// 1095:         # formula may be migrated to different tap. Try to search in core and all taps.
// 1096:         factory(formula_name, spec, **options)
// 1097:       end
// 1098:     end
// 1099:     f.build = tab
// 1100:     T.cast(f.build, Tab).used_options = Tab.remap_deprecated_options(f.deprecated_options, tab.used_options).as_flags
// 1101:     f.version.update_commit(keg.version.version.commit) if f.head? && keg.version.head?
// 1102:     f
// 1103:   end
// 1104:
// 1105:   # Return a {Formula} instance directly from contents.
// 1106:   sig {
// 1107:     params(
// 1108:       name:          String,
// 1109:       path:          Pathname,
// 1110:       contents:      String,
// 1111:       spec:          Symbol,
// 1112:       alias_path:    T.nilable(Pathname),
// 1113:       tap:           T.nilable(Tap),
// 1114:       force_bottle:  T::Boolean,
// 1115:       flags:         T::Array[String],
// 1116:       ignore_errors: T::Boolean,
// 1117:     ).returns(Formula)
// 1118:   }
// 1119:   def self.from_contents(
// 1120:     name,
// 1121:     path,
// 1122:     contents,
// 1123:     spec = :stable,
// 1124:     alias_path: nil,
// 1125:     tap: nil,
// 1126:     force_bottle: false,
// 1127:     flags: [],
// 1128:     ignore_errors: false
// 1129:   )
// 1130:     FormulaContentsLoader.new(name, path, contents, tap:)
// 1131:                          .get_formula(spec, alias_path:, force_bottle:, flags:, ignore_errors:)
// 1132:   end
// 1133:
// 1134:   sig { params(ref: String).returns(Pathname) }
// 1135:   def self.to_rack(ref)
// 1136:     # If using a fully-scoped reference, check the formula can be resolved to
// 1137:     # reject a bogus reference like `fake/tap/hello`. An untrusted tap is no
// 1138:     # barrier to uninstalling an installed formula: this error only fires once
// 1139:     # the formula file exists and is raised before the file is evaluated.
// 1140:     begin
// 1141:       factory(ref) if ref.include? "/"
// 1142:     rescue Homebrew::UntrustedTapError
// 1143:       nil
// 1144:     end
// 1145:
// 1146:     # Check whether the rack with the given name exists.
// 1147:     if (rack = HOMEBREW_CELLAR/File.basename(ref, ".rb")).directory?
// 1148:       return rack.resolved_path
// 1149:     end
// 1150:
// 1151:     # Use canonical name to locate rack.
// 1152:     (HOMEBREW_CELLAR/canonical_name(ref)).resolved_path
// 1153:   end
// 1154:
// 1155:   sig { params(ref: String).returns(String) }
// 1156:   def self.canonical_name(ref)
// 1157:     loader_for(ref).name
// 1158:   rescue TapFormulaAmbiguityError
// 1159:     # If there are multiple tap formulae with the name of ref,
// 1160:     # then ref is the canonical name
// 1161:     ref.downcase
// 1162:   end
// 1163:
// 1164:   sig { params(ref: String).returns(Pathname) }
// 1165:   def self.path(ref)
// 1166:     loader_for(ref).path
// 1167:   end
// 1168:
// 1169:   sig {
// 1170:     params(tapped_name: String, warn: T::Boolean)
// 1171:       .returns(T.nilable([String, Tap, T.nilable(Symbol), T.nilable(String)]))
// 1172:   }
// 1173:   def self.tap_formula_name_type(tapped_name, warn:)
// 1174:     return unless (tap_with_name = Tap.with_formula_name(tapped_name))
// 1175:
// 1176:     tap, name = tap_with_name
// 1177:
// 1178:     type = nil
// 1179:     alias_name = nil
// 1180:
// 1181:     # FIXME: Remove the need to do this here.
// 1182:     alias_table_key = tap.core_tap? ? name : "#{tap}/#{name}"
// 1183:
// 1184:     if (possible_alias = tap.alias_table[alias_table_key].presence)
// 1185:       alias_name = name
// 1186:       # FIXME: Remove the need to split the name and instead make
// 1187:       #        the alias table only contain short names.
// 1188:       name = Utils.name_from_full_name(possible_alias)
// 1189:       type = :alias
// 1190:     elsif (new_name = tap.formula_renames[name].presence)
// 1191:       old_name = tap.core_tap? ? name : tapped_name
// 1192:       name = new_name
// 1193:       new_name = tap.core_tap? ? name : "#{tap}/#{name}"
// 1194:       type = :rename
// 1195:     elsif (new_tap_name = tap.tap_migrations[name].presence)
// 1196:       new_tap, new_name = Tap.with_formula_name(new_tap_name)
// 1197:       unless new_tap
// 1198:         if new_tap_name.include?("/")
// 1199:           new_tap = Tap.fetch(new_tap_name)
// 1200:           new_name = name
// 1201:         else
// 1202:           new_tap = tap
// 1203:           new_name = new_tap_name
// 1204:         end
// 1205:       end
// 1206:       new_tapped_name = "#{new_tap}/#{new_name}"
// 1207:
// 1208:       if tapped_name != new_tapped_name
// 1209:         old_name = tap.core_tap? ? name : tapped_name
// 1210:         return unless (name_tap_type = tap_formula_name_type(new_tapped_name, warn: false))
// 1211:
// 1212:         name, tap, = name_tap_type
// 1213:
// 1214:         new_name = new_tap.core_tap? ? name : "#{tap}/#{name}"
// 1215:         type = :migration
// 1216:       end
// 1217:     end
// 1218:
// 1219:     if warn && old_name && new_name
// 1220:       destination_exists = find_formula_in_tap(name, tap).exist? ||
// 1221:                            (tap.core_tap? && !Homebrew::EnvConfig.no_install_from_api? &&
// 1222:                             Homebrew::API.formula_name?(name))
// 1223:       opoo "Formula #{old_name} was renamed to #{new_name}." if destination_exists
// 1224:     end
// 1225:
// 1226:     [name, tap, type, alias_name]
// 1227:   end
// 1228:
// 1229:   sig { params(ref: T.any(String, Pathname), from: T.nilable(Symbol), warn: T::Boolean).returns(FormulaLoader) }
// 1230:   def self.loader_for(ref, from: nil, warn: true)
// 1231:     [
// 1232:       FromBottleLoader,
// 1233:       FromURILoader,
// 1234:       FromAPILoader,
// 1235:       FromTapLoader,
// 1236:       FromPathLoader,
// 1237:       FromNameLoader,
// 1238:       FromKegLoader,
// 1239:       FromCacheLoader,
// 1240:     ].each do |loader_class|
// 1241:       if (loader = loader_class.try_new(ref, from:, warn:))
// 1242:         $stderr.puts "#{$PROGRAM_NAME} (#{loader_class}): loading #{ref}" if verbose? && debug?
// 1243:         return loader
// 1244:       end
// 1245:     end
// 1246:
// 1247:     NullLoader.new(ref)
// 1248:   end
// 1249:
// 1250:   sig { params(name: String).returns(Pathname) }
// 1251:   def self.core_path(name)
// 1252:     find_formula_in_tap(name.to_s.downcase, CoreTap.instance)
// 1253:   end
// 1254:
// 1255:   sig { params(name: String, tap: Tap).returns(Pathname) }
// 1256:   def self.find_formula_in_tap(name, tap)
// 1257:     filename = if name.end_with?(".rb")
// 1258:       name
// 1259:     else
// 1260:       "#{name}.rb"
// 1261:     end
// 1262:
// 1263:     # For API-known formulae the sharded path can be computed directly,
// 1264:     # avoiding building a map of ~8500 `Pathname`s for a single lookup.
// 1265:     # Only use already-loaded API data to avoid triggering downloads here.
// 1266:     if tap.is_a?(CoreTap) && !Homebrew::EnvConfig.no_install_from_api? &&
// 1267:        Homebrew::API::Internal.formula_hashes_cached? && Homebrew::API.formula_name?(name)
// 1268:       return tap.formula_dir/tap.new_formula_subdirectory(name)/"#{name.downcase}.rb"
// 1269:     end
// 1270:
// 1271:     tap.formula_files_by_name.fetch(name, tap.formula_dir/filename)
// 1272:   end
// 1273: end
