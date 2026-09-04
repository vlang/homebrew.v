module homebrew

import ruby
import crypto.md5
import crypto.sha256
import homebrew.api
import os
import time

// Translated from Homebrew/brew `formulary.rb`.
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
				formulary_version_from_url(stable_url)
			} else {
				''
			}
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
			ruby.join_path(prefix, 'Cellar')
		} else {
			cellar
		}
		api: api.FormulaLookupConfig{
			api_base_url: if api_domain == '' {
				api.default_formula_lookup_config().api_base_url
			} else {
				api_domain
			}
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

// Ruby method `self.load_formula(name, path, contents, namespace, flags:, ignore_errors:)` at line 123.
pub fn formulary_load_formula(name string, path string, contents string, namespace string,
	flags []string, ignore_errors bool, context FormularyLoadContext) !FormularyLoadedClass {
	mut effective := context
	if ignore_errors && context.evaluation_error in ['NameError', 'ArgumentError',
		'MethodDeprecatedError', 'MacOSVersion::Error'] {
		effective = FormularyLoadContext{ ...context, ignorable_error: true }
	}
	return formulary_class_from_contents(name, path, contents, namespace, flags, effective)
}

// Ruby method `self.load_formula_from_path(name, path, flags:, ignore_errors:)` at line 210.
pub fn formulary_load_formula_from_path(mut cache FormularyPlatformCache, name string,
	path string, flags []string, ignore_errors bool, context FormularyLoadContext) !FormularyLoadedClass {
	contents := os.read_file(path)!
	namespace := 'FormulaNamespace${formula_namespace_key(path, 'host', 'host')}'
	loaded := formulary_load_formula(name, path, contents, namespace, flags, ignore_errors, context)!
	cache.path_classes[path] = loaded
	return loaded
}

// Ruby method `self.load_formula_from_struct!(name, formula_struct, api_source:, tap_git_head:, flags:, internal_api: false)` at line 228.
pub fn formulary_load_formula_from_struct(mut cache FormularyPlatformCache, name string,
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

// Ruby method `load_file(flags:, ignore_errors:)` at line 520.
pub fn formulary_load_file(mut cache FormularyPlatformCache, loader FormularyLoader,
	flags []string, ignore_errors bool, context FormularyLoadContext) !FormularyLoadedClass {
	if !os.is_file(loader.path) {
		return error('FormulaUnavailableError: ${loader.name}')
	}
	return formulary_load_formula_from_path(mut cache, loader.name, loader.path, flags, ignore_errors, context)
}

// Ruby method `initialize(bottle_name, warn: false)` at line 544.
pub fn new_bottle_formulary_loader(input FormularyLoaderInput) FormularyLoader {
	name := input.bottle_name
	if name == '' || input.bottle_version == '' {
		return FormularyLoader{
			kind: .bottle
			bottle_path: if input.resolved_path != '' {
				input.resolved_path
			} else {
				os.abs_path(input.ref)
			}
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
			input.resolved_path
		} else {
			os.abs_path(input.ref)
		}
		cellar_formula_path: cellar_path
	}
}

// Ruby method `initialize(path, alias_path: nil, tap: nil)` at line 630.
pub fn new_path_formulary_loader(path string, alias_path string,
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

// Ruby method `initialize(url, from: nil)` at line 671.
pub fn new_uri_formulary_loader(url string, from string, cache_formula_dir string) FormularyLoader {
	path_component := url.all_after('://').all_after('/')
	filename := os.base(path_component)
	if path_component == '' || filename == '' {
		return FormularyLoader{ kind: .uri, url: url, from: from, error_message: 'URL has no path component' }
	}
	return FormularyLoader{ kind: .uri, name: filename.trim_string_right('.rb'), path: os.join_path(cache_formula_dir, filename), url: url, from: from }
}

// Ruby method `self.loader_from_name_tap_type(name_tap_type)` at line 726.
pub fn formulary_loader_from_name_tap_type(resolution TapFormulaNameType) FormularyLoader {
	path := formulary_find_formula_in_tap(resolution.name, resolution.tap, false, false)
	if resolution.type_name == 'migration' && resolution.tap.core_tap && resolution.name in resolution.tap.api_formula_names {
		return new_api_formulary_loader(resolution.name, resolution.tap, resolution.alias_name)
	}
	return new_tap_formulary_loader(resolution.name, path, resolution.tap, resolution.alias_name)
}

// Ruby method `initialize(name, path, tap:, alias_name: nil)` at line 738.
pub fn new_tap_formulary_loader(name string, path string, tap FormularyTap,
	alias_name string) FormularyLoader {
	alias_path := if alias_name != '' { os.join_path(tap.alias_dir, alias_name) } else { '' }
	return FormularyLoader{ kind: .tap, name: name, path: path, alias_path: alias_path, tap: tap, has_tap: true }
}

// Ruby method `initialize(ref)` at line 867.
pub fn new_null_formulary_loader(ref string, core_formula_dir string) FormularyLoader {
	name := os.base(ref).trim_string_right('.rb')
	return FormularyLoader{ kind: .null_loader, name: name, path: core_formula_path(name, core_formula_dir), error_message: 'FormulaUnavailableError: ${name}' }
}

// Ruby method `initialize(name, path, contents, tap: nil)` at line 893.
pub fn new_contents_formulary_loader(name string, path string, contents string,
	tap ?FormularyTap) FormularyLoader {
	if actual := tap {
		return FormularyLoader{ kind: .contents, name: name, path: path, contents: contents, tap: actual, has_tap: true }
	}
	return FormularyLoader{ kind: .contents, name: name, path: path, contents: contents }
}

// Ruby method `klass(flags:, ignore_errors:)` at line 899.
pub fn formulary_klass(loader FormularyLoader, flags []string,
	ignore_errors bool, context FormularyLoadContext) !FormularyLoadedClass {
	namespace := 'FormulaNamespace${md5.sum(loader.contents.bytes()).hex()}'
	return formulary_load_formula(loader.name, loader.path, loader.contents, namespace, flags, ignore_errors, context)
}

// Ruby method `initialize(name, tap: nil, alias_name: nil)` at line 931.
pub fn new_api_formulary_loader(name string, tap FormularyTap,
	alias_name string) FormularyLoader {
	alias_path := if alias_name != '' { os.join_path(tap.alias_dir, alias_name) } else { '' }
	return FormularyLoader{ kind: .api, name: name, path: formulary_find_formula_in_tap(name, tap, true, true), alias_path: alias_path, tap: tap, has_tap: true }
}

// Ruby method `load_from_api(flags:)` at line 946.
pub fn formulary_load_from_api(mut cache FormularyPlatformCache, loader FormularyLoader,
	formula_struct api.FormulaStruct, api_source string, tap_git_head string, flags []string, prefix string,
	cellar string, home_directory string) !FormularyLoadedClass {
	if api_source == '' {
		return error('FormulaUnavailableError: ${loader.name}')
	}
	return formulary_load_formula_from_struct(mut cache, loader.name, formula_struct, api_source, tap_git_head, flags, true, prefix, cellar, home_directory)
}

// Ruby method `self.from_contents(` at line 1119.
pub fn formulary_from_contents(name string, path string, contents string,
	spec string, alias_path string, tap ?FormularyTap, force_bottle bool, flags []string,
	ignore_errors bool, context FormularyLoadContext) !Formula {
	loader := new_contents_formulary_loader(name, path, contents, tap)
	loaded := formulary_klass(loader, flags, ignore_errors, context)!
	return formulary_loader_formula(FormularyLoader{ ...loader, loaded_class: loaded }, spec, alias_path, force_bottle, flags)
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
	path := formulary_find_formula_in_tap(name, tap, true, true)
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
pub fn formulary_resolve_tap_formula_name(tapped_name string,
	tap FormularyTap, taps []FormularyTap, warn bool) ?TapFormulaNameType {
	return formulary_tap_formula_name_type(tapped_name, tap, taps, warn, 0)
}

// Ruby method `self.find_formula_in_tap(name, tap)` at line 1256.
pub fn formulary_find_formula_in_tap(name string, tap FormularyTap,
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
