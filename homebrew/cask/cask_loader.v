module cask

import homebrew.extend.env as env_sensitive
import net.urllib
import os
import x.json2

// Translated from Homebrew/brew `cask/cask_loader.rb`.
pub enum CaskLoaderKind {
	abstract_content
	content
	path
	uri
	tap
	instance
	api
	name
	installed_path
	null_loader
}

pub enum CaskLoaderReferenceKind {
	text
	path
	uri
	cask
}

pub enum CaskLoaderMigrationKind {
	none
	rename
	migration
}

pub enum CaskLoaderAvailability {
	unknown
	present
	absent
	failure
}

pub struct CaskLoaderArtifact {
pub:
	kind   string
	values []string
}

pub struct CaskLoaderTap {
pub:
	name               string
	path               string
	cask_dir           string
	formula_dir        string
	installed          bool = true
	core_tap           bool
	core_cask_tap      bool
	cask_renames       map[string]string
	tap_migrations     map[string]string
	cask_files_by_name map[string]string
}

pub struct CaskLoaderConfig {
pub:
	languages []string
}

pub struct CaskLoaderCask {
pub:
	token                    string
	version                  string
	sha256                   string
	url                      string
	names                    []string
	desc                     string
	homepage                 string
	artifacts                []CaskLoaderArtifact
	tap                      CaskLoaderTap
	has_tap                  bool
	source                   string
	sourcefile_path          string
	config                   CaskLoaderConfig
	loaded_from_api          bool
	loaded_from_internal_api bool
	tap_git_head             string
	url_specs                map[string]string
	uninstall_flight_blocks  bool
	evaluation_environment   map[string]string
	deprecated               bool
	disabled                 bool
	auto_updates             bool
	conflicts_with           []string
	renames                  map[string]string
	depends_on               map[string]string
	ignored_dependency_error string
	container_nested         string
	container_type           string
	caveats                  string
	caveats_rosetta          bool
	language                 string
	caskfile_only            bool
}

pub struct CaskLoaderReference {
pub:
	kind  CaskLoaderReferenceKind
	value string
	cask  CaskLoaderCask
}

pub struct CaskLoaderLocalisation {
pub:
	languages        []string
	value            string
	is_default       bool
	version          string
	sha256           string
	url              string
	names            []string
	desc             string
	homepage         string
	artifacts        []CaskLoaderArtifact
	has_artifacts    bool
	caveats          string
	caveats_rosetta  bool
	auto_updates     bool
	has_auto_updates bool
	deprecated       bool
	has_deprecated   bool
	disabled         bool
	has_disabled     bool
	conflicts_with   []string
	renames          map[string]string
	depends_on       map[string]string
	depends_on_error string
	container_nested string
	container_type   string
}

pub struct CaskLoaderApiSource {
pub:
	present           bool
	version           string
	sha256            string
	url               string
	names             []string
	desc              string
	homepage          string
	tap               string
	artifacts         []CaskLoaderArtifact
	has_artifacts     bool
	tap_git_head      string
	languages         []string
	language_versions map[string]string
	localisations     []CaskLoaderLocalisation
	url_specs         map[string]string
	deprecated        bool
	disabled          bool
	auto_updates      bool
	conflicts_with    []string
	renames           map[string]string
	depends_on        map[string]string
	depends_on_error  string
	container_nested  string
	container_type    string
	caveats           string
	caveats_rosetta   bool
	invalid_reason    string
	raw               string
}

pub struct CaskLoaderReceipt {
pub:
	valid                    bool = true
	version                  string
	tap                      CaskLoaderTap
	has_tap                  bool
	uninstall_artifacts      []CaskLoaderArtifact
	has_uninstall_artifacts  bool
	uninstall_flight_blocks  bool
	has_uninstall_flight_key bool
}

pub struct CaskLoaderEvaluation {
pub:
	cask            CaskLoaderCask
	valid           bool
	error_kind      string
	error_message   string
	failed          bool
	homebrew_failed bool
}

pub struct CaskLoaderLookupContext {
pub:
	forbid_packages_from_paths bool
	no_install_from_api        bool
	cache_path                 string
	cached_api_path            string
	cached_internal_api_path   string
	cached_packages_path       string
	core_cask_tap              CaskLoaderTap
	taps                       []CaskLoaderTap
	api_tokens                 []string
	api_renames                map[string]string
	installed_caskfiles        map[string]string
	installed_receipts         map[string]CaskLoaderReceipt
	source_download_taps       map[string]CaskLoaderTap
	api_membership             map[string]CaskLoaderAvailability
	api_sources                map[string]CaskLoaderApiSource
	api_artifacts              map[string][]CaskLoaderArtifact
	api_artifact_failures      []string
	api_artifact_failure_kinds map[string]string
	tap_artifacts              map[string][]CaskLoaderArtifact
	name_artifacts             map[string][]CaskLoaderArtifact
	load_casks                 map[string]CaskLoaderCask
	load_failures              []string
	recovery_invalid_tokens    []string
}

pub struct CaskLoaderLoadContext {
pub:
	lookup         CaskLoaderLookupContext
	evaluation     CaskLoaderEvaluation
	environment    map[string]string
	trusted        bool = true
	download_error bool
	internal_api   CaskLoaderApiSource
}

pub struct CaskLoaderTokenTapType {
pub:
	token     string
	tap       CaskLoaderTap
	type_name CaskLoaderMigrationKind
	old_token string
	new_token string
	warning   string
}

pub struct CaskLoaderTryResult {
pub:
	loader        CaskLoader
	found         bool
	error_message string
}

pub struct CaskLoader {
pub mut:
	kind                    CaskLoaderKind
	content                 string
	tap                     CaskLoaderTap
	has_tap                 bool
	config                  CaskLoaderConfig
	has_config              bool
	token                   string
	path                    string
	from_installed_caskfile bool
	api_fallback            bool = true
	url                     string
	name                    string
	cask                    CaskLoaderCask
	has_cask                bool
	from_json               CaskLoaderApiSource
	from_internal_json      bool
	sourcefile_path         string
	warning                 string
}

fn cask_loader_ref_text(ref CaskLoaderReference) string {
	return if ref.kind == .cask { ref.cask.token } else { ref.value }
}

fn cask_loader_valid_token(token string) bool {
	if token == '' {
		return false
	}
	return token.bytes().all(it.is_alnum() || it in [`_`, `+`, `-`, `.`, `@`])
}

fn cask_loader_tap_by_name(context CaskLoaderLookupContext, name string) ?CaskLoaderTap {
	if context.core_cask_tap.name.to_lower() == name.to_lower() {
		return context.core_cask_tap
	}
	for tap in context.taps {
		if tap.name.to_lower() == name.to_lower() {
			return tap
		}
	}
	return none
}

fn cask_loader_with_token(context CaskLoaderLookupContext, value string) ?(CaskLoaderTap, string) {
	parts := value.split('/')
	if parts.len != 3 || !cask_loader_valid_token(parts[2]) {
		return none
	}
	name := '${parts[0]}/${parts[1].trim_string_left('homebrew-')}'
	return cask_loader_tap_by_name(context, name) or {
		CaskLoaderTap{
			name: name.to_lower()
			path: os.join_path('/opt/homebrew/Library/Taps', parts[0], parts[1])
			cask_dir: os.join_path('/opt/homebrew/Library/Taps', parts[0], parts[1], 'Casks')
			installed: false
		}
	}, parts[2].to_lower()
}

fn cask_loader_content_match(content string) bool {
	trimmed := content.trim_space()
	if !trimmed.starts_with('cask') {
		return false
	}
	rest := trimmed[4..]
	if rest.starts_with('(') {
		close := rest.index(')') or { return false }
		token := rest[1..close].trim_space()
		return token.len >= 2 && token[0] in [`'`, `"`] && token[token.len - 1] == token[0] && rest[close + 1..].trim_space().starts_with('{') && rest.trim_space().ends_with('}')
	}
	if rest == '' || !rest[0].is_space() {
		return false
	}
	value := rest.trim_space()
	if value.len < 2 || value[0] !in [`'`, `"`] {
		return false
	}
	quote := value[0]
	close := value[1..].index_u8(quote)
	if close < 0 {
		return false
	}
	after_token := value[close + 2..]
	if after_token == '' || !after_token[0].is_space() {
		return false
	}
	tail := after_token.trim_space()
	if !tail.starts_with('do') || !tail.ends_with('end') || tail.len < 5 {
		return false
	}
	after_do := tail[2..tail.len - 3]
	return after_do != '' && (after_do[0].is_space() || after_do[0] == `;`)
}

fn cask_loader_extension(path string) string {
	base := os.base(path)
	dot := base.last_index('.') or { return '' }
	return base[dot..]
}

fn cask_loader_any_string(values map[string]json2.Any, key string) string {
	value := values[key] or { return '' }
	if value is json2.Null {
		return ''
	}
	return value.str()
}

fn cask_loader_any_strings(value json2.Any) []string {
	if value is json2.Null {
		return []
	}
	return value.as_array().map(if it is json2.Null { '' } else { it.str() })
}

fn cask_loader_any_bool(values map[string]json2.Any, key string) bool {
	value := values[key] or { return false }
	if value is bool {
		return value
	}
	return value.str() == 'true'
}

fn cask_loader_any_string_map(value json2.Any) map[string]string {
	if value is json2.Null {
		return {}
	}
	mut result := map[string]string{}
	for key, entry in value.as_map() {
		if entry !is json2.Null {
			result[key] = entry.str()
		}
	}
	return result
}

fn cask_loader_conflicts(value json2.Any) []string {
	if value is json2.Null {
		return []
	}
	mut conflicts := []string{}
	for _, entry in value.as_map() {
		if entry is []json2.Any {
			conflicts << cask_loader_any_strings(entry)
		} else if entry !is json2.Null {
			conflicts << entry.str()
		}
	}
	return conflicts
}

fn cask_loader_renames(value json2.Any) map[string]string {
	if value is json2.Null {
		return {}
	}
	mut renames := map[string]string{}
	for operation in value.as_array() {
		entry := operation.as_map()
		from := cask_loader_any_string(entry, 'from')
		to := cask_loader_any_string(entry, 'to')
		if from != '' && to != '' {
			renames[from] = to
		}
	}
	return renames
}

fn cask_loader_artifacts(value json2.Any) []CaskLoaderArtifact {
	if value is json2.Null {
		return []
	}
	mut artifacts := []CaskLoaderArtifact{}
	for item in value.as_array() {
		entries := item.as_map()
		for key, raw in entries {
			artifacts << CaskLoaderArtifact{
				kind: key
				values: if raw is json2.Null { []string{} } else { cask_loader_any_strings(raw) }
			}
		}
	}
	return artifacts
}

fn cask_loader_localisations(values map[string]json2.Any) []CaskLoaderLocalisation {
	raw_variations := values['language_variations'] or { return [] }
	if raw_variations is json2.Null {
		return []
	}
	mut localisations := []CaskLoaderLocalisation{}
	for raw_variation in raw_variations.as_array() {
		variation := raw_variation.as_map()
		mut overrides := variation.clone()
		if raw_overrides := variation['overrides'] {
			if raw_overrides !is json2.Null {
				overrides = raw_overrides.as_map()
			}
		}
		mut artifacts := []CaskLoaderArtifact{}
		mut has_artifacts := false
		if raw := overrides['artifacts'] {
			if raw !is json2.Null {
				artifacts = cask_loader_artifacts(raw)
				has_artifacts = true
			}
		}
		mut names := []string{}
		if raw := overrides['name'] {
			if raw !is json2.Null {
				names = cask_loader_any_strings(raw)
			}
		} else if raw := overrides['names'] {
			if raw !is json2.Null {
				names = cask_loader_any_strings(raw)
			}
		}
		mut conflicts := []string{}
		if raw := overrides['conflicts_with'] {
			conflicts = cask_loader_conflicts(raw)
		} else if raw := overrides['conflicts_with_args'] {
			conflicts = cask_loader_conflicts(raw)
		}
		mut renames := map[string]string{}
		if raw := overrides['rename'] {
			renames = cask_loader_renames(raw)
		}
		mut depends_on := map[string]string{}
		if raw := overrides['depends_on'] {
			depends_on = cask_loader_any_string_map(raw)
		} else if raw := overrides['depends_on_args'] {
			depends_on = cask_loader_any_string_map(raw)
		}
		mut container := map[string]string{}
		if raw := overrides['container'] {
			container = cask_loader_any_string_map(raw)
		} else if raw := overrides['container_args'] {
			container = cask_loader_any_string_map(raw)
		}
		localisations << CaskLoaderLocalisation{
			languages: if raw_languages := variation['languages'] {
				cask_loader_any_strings(raw_languages)
			} else {
				[]string{}
			}
			value: cask_loader_any_string(variation, 'value')
			is_default: cask_loader_any_bool(variation, 'default')
			version: cask_loader_any_string(overrides, 'version')
			sha256: cask_loader_any_string(overrides, 'sha256')
			url: cask_loader_any_string(overrides, 'url')
			names: names
			desc: cask_loader_any_string(overrides, 'desc')
			homepage: cask_loader_any_string(overrides, 'homepage')
			artifacts: artifacts
			has_artifacts: has_artifacts
			caveats: cask_loader_any_string(overrides, 'caveats')
			caveats_rosetta: cask_loader_any_bool(overrides, 'caveats_rosetta')
			auto_updates: cask_loader_any_bool(overrides, 'auto_updates')
			has_auto_updates: cask_loader_any_bool(overrides, 'auto_updates')
			deprecated: 'deprecate_args' in overrides
			has_deprecated: 'deprecate_args' in overrides
			disabled: 'disable_args' in overrides
			has_disabled: 'disable_args' in overrides
			conflicts_with: conflicts
			renames: renames
			depends_on: depends_on
			container_nested: container['nested'] or { '' }
			container_type: container['type'] or { '' }
		}
	}
	return localisations
}

fn cask_loader_parse_json(contents string) !CaskLoaderApiSource {
	decoded := json2.decode[json2.Any](contents)!
	if decoded !is map[string]json2.Any {
		return error('expected a JSON object')
	}
	values := decoded.as_map()
	mut invalid_reason := ''
	if conflicts := values['conflicts_with'] {
		if conflicts !is json2.Null && 'formula' in conflicts.as_map() {
			invalid_reason = 'Unknown key: :formula'
		}
	}
	mut artifacts := []CaskLoaderArtifact{}
	mut has_artifacts := false
	if raw := values['artifacts'] {
		if raw !is json2.Null {
			has_artifacts = true
			artifacts = cask_loader_artifacts(raw)
		}
	}
	mut names := []string{}
	if raw := values['name'] {
		if raw !is json2.Null {
			names = cask_loader_any_strings(raw)
		}
	}
	mut languages := []string{}
	if raw := values['languages'] {
		if raw !is json2.Null {
			languages = cask_loader_any_strings(raw)
		}
	}
	mut conflicts := []string{}
	if raw := values['conflicts_with'] {
		conflicts = cask_loader_conflicts(raw)
	} else if raw := values['conflicts_with_args'] {
		conflicts = cask_loader_conflicts(raw)
	}
	mut renames := map[string]string{}
	if raw := values['rename'] {
		renames = cask_loader_renames(raw)
	}
	mut depends_on := map[string]string{}
	if raw := values['depends_on'] {
		depends_on = cask_loader_any_string_map(raw)
	} else if raw := values['depends_on_args'] {
		depends_on = cask_loader_any_string_map(raw)
	}
	mut container := map[string]string{}
	if raw := values['container'] {
		container = cask_loader_any_string_map(raw)
	} else if raw := values['container_args'] {
		container = cask_loader_any_string_map(raw)
	}
	mut url_specs := map[string]string{}
	if raw := values['url_specs'] {
		url_specs = cask_loader_any_string_map(raw)
	}
	return CaskLoaderApiSource{
		present: true
		version: cask_loader_any_string(values, 'version')
		sha256: cask_loader_any_string(values, 'sha256')
		url: cask_loader_any_string(values, 'url')
		names: names
		desc: cask_loader_any_string(values, 'desc')
		homepage: cask_loader_any_string(values, 'homepage')
		tap: cask_loader_any_string(values, 'tap')
		artifacts: artifacts
		has_artifacts: has_artifacts
		tap_git_head: cask_loader_any_string(values, 'tap_git_head')
		languages: languages
		localisations: cask_loader_localisations(values)
		url_specs: url_specs
		deprecated: 'deprecate_args' in values
		disabled: 'disable_args' in values
		auto_updates: cask_loader_any_bool(values, 'auto_updates')
		conflicts_with: conflicts
		renames: renames
		depends_on: depends_on
		container_nested: container['nested'] or { '' }
		container_type: container['type'] or { '' }
		caveats: cask_loader_any_string(values, 'caveats')
		caveats_rosetta: cask_loader_any_bool(values, 'caveats_rosetta')
		invalid_reason: invalid_reason
		raw: contents
	}
}

fn cask_loader_mask_environment(values map[string]string) map[string]string {
	mut masked := values.clone()
	env_sensitive.clear_sensitive_environment(mut masked, ['HOMEBREW_GITHUB_API_TOKEN'], true)
	return masked
}

fn cask_loader_cask_from_evaluation(loader CaskLoader, config CaskLoaderConfig,
	evaluation CaskLoaderEvaluation, environment map[string]string) !CaskLoaderCask {
	if evaluation.failed {
		return error('${evaluation.error_kind}: ${evaluation.error_message}')
	}
	if !evaluation.valid {
		return error("CaskUnreadableError: '${loader.path}' does not contain a cask.")
	}
	mut cask := evaluation.cask
	cask = CaskLoaderCask{
		...cask
		source: loader.content
		sourcefile_path: loader.path
		config: config
		tap: loader.tap
		has_tap: loader.has_tap
		evaluation_environment: environment.clone()
	}
	return cask
}

fn cask_loader_lookup_cask(reference string, context CaskLoaderLookupContext) !CaskLoaderCask {
	if reference in context.load_failures {
		return error('CaskUnavailableError: ${reference}')
	}
	return context.load_casks[reference] or { error('CaskUnavailableError: ${reference}') }
}

fn cask_loader_load_selected(mut loader CaskLoader, config CaskLoaderConfig,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	return match loader.kind {
		.content { cask_loader_load_content(mut loader, config, context)! }
		.path, .installed_path { cask_loader_load_path(mut loader, config, context)! }
		.uri { cask_loader_load_uri(mut loader, config, context)! }
		.tap { cask_loader_load_tap(mut loader, config, context)! }
		.instance { cask_loader_load_instance(loader, config) }
		.api { cask_loader_load_api(loader, config, context)! }
		.null_loader { cask_loader_load_null(loader, config)! }
		else {
			return error('CaskError: No cask loader found for ${loader.token}')
		}
	}
}

// Ruby method `load(config:); end` at line 31.
pub fn cask_loader_load(mut loader CaskLoader, config CaskLoaderConfig,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	return cask_loader_load_selected(mut loader, config, context)
}

// Ruby attr_reader `attr_reader :content` at line 42.
pub fn cask_loader_content(loader CaskLoader) string {
	return loader.content
}

// Ruby attr_reader `attr_reader :tap` at line 45.
pub fn cask_loader_content_tap(loader CaskLoader) ?CaskLoaderTap {
	return if loader.has_tap { loader.tap } else { none }
}

// Ruby method `initialize` at line 48.
pub fn new_base_cask_loader() CaskLoader {
	return CaskLoader{ kind: .abstract_content }
}

// Ruby method `cask(header_token, **options, &block)` at line 63.
pub fn cask_loader_cask(loader CaskLoader, header_token string,
	definition CaskLoaderCask) CaskLoaderCask {
	return CaskLoaderCask{
		...definition
		token: header_token
		source: loader.content
		tap: loader.tap
		has_tap: loader.has_tap
		config: loader.config
	}
}

// Ruby method `self.try_new(ref, warn: false)` at line 74.
pub fn cask_loader_try_content(ref CaskLoaderReference) ?CaskLoader {
	if ref.kind == .cask || !cask_loader_content_match(cask_loader_ref_text(ref)) {
		return none
	}
	return new_content_cask_loader(cask_loader_ref_text(ref), none)
}

// Ruby method `initialize(content, tap: T.unsafe(nil))` at line 96.
pub fn new_content_cask_loader(content string, tap ?CaskLoaderTap) CaskLoader {
	mut loader := new_base_cask_loader()
	loader.kind = .content
	loader.content = content
	if actual := tap {
		loader.tap = actual
		loader.has_tap = true
	}
	return loader
}

// Ruby method `load(config:)` at line 104.
pub fn cask_loader_load_content(mut loader CaskLoader, config CaskLoaderConfig,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	loader.config = config
	loader.has_config = true
	masked := cask_loader_mask_environment(context.environment)
	return cask_loader_cask_from_evaluation(loader, config, context.evaluation, masked)
}

// Ruby method `self.try_new(ref, warn: false)` at line 119.
pub fn cask_loader_try_path(ref CaskLoaderReference,
	context CaskLoaderLookupContext) ?CaskLoader {
	if ref.kind !in [.text, .path] {
		return none
	}
	path := os.abs_path(ref.value)
	if !os.exists(path) || cask_loader_invalid_path(path, ['.rb', '.json']) || (!os.is_file(path) && !os.is_link(path)) {
		return none
	}
	return new_path_cask_loader(path, '', context)
}

// Ruby method `self.invalid_path?(pathname, valid_extnames: %w[.rb .json])` at line 137.
pub fn cask_loader_invalid_path(pathname string,
	valid_extnames []string) bool {
	return cask_loader_extension(pathname) !in valid_extnames || os.base(pathname) in [
		'INSTALL_RECEIPT.json',
		'sbom.spdx.json',
	]
}

// Ruby attr_reader `attr_reader :token` at line 145.
pub fn cask_loader_token(loader CaskLoader) string {
	return loader.token
}

// Ruby attr_reader `attr_reader :path` at line 148.
pub fn cask_loader_path(loader CaskLoader) string {
	return loader.path
}

// Ruby attr_writer `attr_writer :from_installed_caskfile` at line 151.
pub fn cask_loader_set_from_installed_caskfile(mut loader CaskLoader,
	from_installed_caskfile bool) {
	loader.from_installed_caskfile = from_installed_caskfile
}

// Ruby method `initialize(path, token: T.unsafe(nil))` at line 154.
pub fn new_path_cask_loader(path string, _ string,
	context CaskLoaderLookupContext) CaskLoader {
	absolute := os.abs_path(path)
	mut loader := new_base_cask_loader()
	loader.kind = .path
	loader.token = cask_loader_token_from_path(absolute)
	loader.path = absolute
	if tap := context.source_download_taps[absolute] {
		loader.tap = tap
		loader.has_tap = true
	}
	return loader
}

// Ruby method `load(config:)` at line 167.
pub fn cask_loader_load_path(mut loader CaskLoader, config CaskLoaderConfig,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	if !os.exists(loader.path) {
		return error("CaskUnavailableError: '${loader.path}' does not exist.")
	}
	if !os.is_readable(loader.path) {
		return error("CaskUnavailableError: '${loader.path}' is not readable.")
	}
	if !os.is_file(loader.path) {
		return error("CaskUnavailableError: '${loader.path}' is not a file.")
	}
	if !context.trusted {
		name := if loader.has_tap { loader.tap.name } else { loader.token }
		return error('UntrustedTapError: ${name}')
	}
	loader.content = os.read_file(loader.path)!
	loader.config = config
	loader.has_config = true
	if !cask_loader_invalid_path(loader.path, ['.json']) {
		source := cask_loader_parse_json(loader.content)!
		if loader.from_installed_caskfile || source.present {
			api_loader := new_api_cask_loader(loader.token, source, loader.path, loader.from_installed_caskfile, loader.path.ends_with('.internal.json'), loader.api_fallback, context.lookup)
			return cask_loader_load_api(api_loader, config, context) or {
				if loader.from_installed_caskfile && err.msg().contains('CaskInvalidError') {
					return error(err.msg().replace('CaskInvalidError', 'CaskUnreadableError'))
				}
				return err
			}
		}
	}
	masked := cask_loader_mask_environment(context.environment)
	return cask_loader_cask_from_evaluation(loader, config, context.evaluation, masked) or {
		if context.evaluation.error_kind in ['NameError', 'ArgumentError', 'ScriptError'] {
			return error('CaskUnreadableError: ${loader.token}: ${context.evaluation.error_message}')
		}
		if loader.from_installed_caskfile && err.msg().contains('CaskInvalidError') {
			return error(err.msg().replace('CaskInvalidError', 'CaskUnreadableError'))
		}
		return err
	}
}

// Ruby method `cask(header_token, **options, &block)` at line 231.
pub fn cask_loader_validate_cask(loader CaskLoader, header_token string,
	definition CaskLoaderCask) !CaskLoaderCask {
	if loader.token != header_token {
		return error("CaskTokenMismatchError: expected '${loader.token}', got '${header_token}'")
	}
	return CaskLoaderCask{
		...cask_loader_cask(loader, header_token, definition)
		sourcefile_path: loader.path
	}
}

// Ruby method `self.try_new(ref, warn: false)` at line 244.
pub fn cask_loader_try_uri(ref CaskLoaderReference,
	context CaskLoaderLookupContext) ?CaskLoader {
	if context.forbid_packages_from_paths {
		return none
	}
	raw := cask_loader_ref_text(ref)
	uri := urllib.parse(raw) or { return none }
	if uri.path == '' || (!raw.contains('://') && !raw.starts_with('file:')) {
		return none
	}
	return new_uri_cask_loader(raw, context)
}

// Ruby attr_reader `attr_reader :url` at line 266.
pub fn cask_loader_uri_url(loader CaskLoader) string {
	return loader.url
}

// Ruby attr_reader `attr_reader :name` at line 269.
pub fn cask_loader_uri_name(loader CaskLoader) string {
	return loader.name
}

// Ruby method `initialize(url)` at line 272.
pub fn new_uri_cask_loader(url string,
	context CaskLoaderLookupContext) CaskLoader {
	parsed := urllib.parse(url) or { panic('unexpected nil url.path') }
	name := os.base(parsed.path)
	mut loader := new_path_cask_loader(os.join_path(context.cache_path, name), '', context)
	loader.kind = .uri
	loader.url = url
	loader.name = name
	return loader
}

// Ruby method `load(config:)` at line 282.
pub fn cask_loader_load_uri(mut loader CaskLoader, config CaskLoaderConfig,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	os.mkdir_all(os.dir(loader.path))!
	parsed := urllib.parse(loader.url)!
	if parsed.scheme != 'file' {
		return error('UnsupportedInstallationMethod: Non-checksummed download of ${loader.name} formula file from an arbitrary URL is unsupported! `brew version-install` to install a formula file from your own custom tap instead.')
	}
	if context.download_error {
		return error('CaskUnavailableError: Failed to download ${loader.url}.')
	}
	source_path := parsed.path
	contents := os.read_file(source_path) or {
		return error('CaskUnavailableError: Failed to download ${loader.url}.')
	}
	os.write_file(loader.path, contents) or {
		return error('CaskUnavailableError: Failed to download ${loader.url}.')
	}
	return cask_loader_load_path(mut loader, config, context)
}

// Ruby attr_reader `attr_reader :tap` at line 306.
pub fn cask_loader_tap(loader CaskLoader) CaskLoaderTap {
	return loader.tap
}

// Ruby method `self.try_new(ref, warn: false)` at line 313.
pub fn cask_loader_try_tap(ref CaskLoaderReference, warn bool,
	context CaskLoaderLookupContext) ?CaskLoader {
	resolution := cask_loader_tap_cask_token_type(cask_loader_ref_text(ref), warn, context) or { return none }
	mut loader := cask_loader_loader_from_token_tap_type(resolution, context) or {
		return none
	}
	loader.warning = resolution.warning
	return loader
}

// Ruby method `self.loader_from_token_tap_type(token_tap_type)` at line 325.
pub fn cask_loader_loader_from_token_tap_type(resolution CaskLoaderTokenTapType,
	context CaskLoaderLookupContext) ?CaskLoader {
	if resolution.type_name == .migration && resolution.tap.core_cask_tap {
		if loader := cask_loader_try_api(CaskLoaderReference{
			kind: .text
			value: resolution.token
		}, false, context) {
			return loader
		}
	}
	return new_tap_cask_loader('${resolution.tap.name}/${resolution.token}', context) or {
		none
	}
}

// Ruby method `initialize(tapped_token)` at line 336.
pub fn new_tap_cask_loader(tapped_token string,
	context CaskLoaderLookupContext) !CaskLoader {
	tap, token := cask_loader_with_token(context, tapped_token) or {
		return error('unexpected nil Tap.with_cask_token')
	}
	path := cask_loader_find_cask_in_tap(token, tap)
	mut loader := new_path_cask_loader(path, '', context)
	loader.kind = .tap
	loader.tap = tap
	loader.has_tap = true
	return loader
}

// Ruby method `load(config:)` at line 347.
pub fn cask_loader_load_tap(mut loader CaskLoader, config CaskLoaderConfig,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	if !loader.tap.installed {
		return error('TapCaskUnavailableError: ${loader.tap.name}/${loader.token}; If you trust this tap')
	}
	return cask_loader_load_path(mut loader, config, context)
}

// Ruby method `self.try_new(ref, warn: false)` at line 362.
pub fn cask_loader_try_instance(ref CaskLoaderReference) ?CaskLoader {
	return if ref.kind == .cask { new_instance_cask_loader(ref.cask) } else { none }
}

// Ruby method `initialize(cask)` at line 367.
pub fn new_instance_cask_loader(cask CaskLoaderCask) CaskLoader {
	return CaskLoader{ kind: .instance, cask: cask, has_cask: true, token: cask.token }
}

// Ruby method `load(config:)` at line 373.
pub fn cask_loader_load_instance(loader CaskLoader, _ CaskLoaderConfig) CaskLoaderCask {
	return loader.cask
}

// Ruby attr_reader `attr_reader :token` at line 383.
pub fn cask_loader_api_token(loader CaskLoader) string {
	return loader.token
}

// Ruby attr_reader `attr_reader :path` at line 386.
pub fn cask_loader_api_path(loader CaskLoader) string {
	return loader.path
}

// Ruby attr_reader `attr_reader :from_json` at line 389.
pub fn cask_loader_api_source(loader CaskLoader) ?CaskLoaderApiSource {
	return if loader.from_json.present { loader.from_json } else { none }
}

// Ruby method `self.try_new(ref, warn: false)` at line 395.
pub fn cask_loader_try_api(ref CaskLoaderReference, warn bool,
	context CaskLoaderLookupContext) ?CaskLoader {
	if context.no_install_from_api || ref.kind != .text {
		return none
	}
	mut token := ref.value
	prefix := if token.to_lower().starts_with('homebrew/homebrew-cask/') {
		'homebrew/homebrew-cask/'
	} else if token.to_lower().starts_with('homebrew/cask/') {
		'homebrew/cask/'
	} else {
		''
	}
	if prefix != '' {
		token = token[prefix.len..]
	} else if token.contains('/') {
		return none
	}
	if !cask_loader_valid_token(token) || (token !in context.api_tokens && token !in context.api_renames) {
		return none
	}
	resolution := cask_loader_tap_cask_token_type('${context.core_cask_tap.name}/${token}', warn, context) or { return none }
	mut loader := new_api_cask_loader('${resolution.tap.name}/${resolution.token}', CaskLoaderApiSource{}, '', false, false, true, context)
	loader.warning = resolution.warning
	return loader
}

// Ruby method `initialize(token, from_json: T.unsafe(nil), path: nil, from_installed_caskfile: false,` at line 420.
pub fn new_api_cask_loader(raw_token string, from_json CaskLoaderApiSource,
	path string, from_installed_caskfile bool, from_internal_json bool, api_fallback bool,
	context CaskLoaderLookupContext) CaskLoader {
	mut token := raw_token
	lower_token := token.to_lower()
	for prefix in ['homebrew/homebrew-cask/', 'homebrew/cask/'] {
		if lower_token.starts_with(prefix) {
			token = token[prefix.len..]
			break
		}
	}
	sourcefile_path := if path != '' {
		path
	} else if from_json.present {
		if from_internal_json { context.cached_packages_path } else { context.cached_internal_api_path }
	} else {
		context.cached_api_path
	}
	return CaskLoader{
		kind: .api
		token: token
		path: if path != '' {
			path
		} else {
			cask_loader_default_path(token, context)
		}
		from_json: from_json
		from_installed_caskfile: from_installed_caskfile
		from_internal_json: from_internal_json
		api_fallback: api_fallback
		sourcefile_path: sourcefile_path
	}
}

// Ruby method `load(config:)` at line 442.
pub fn cask_loader_load_api(loader CaskLoader, config CaskLoaderConfig,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	if loader.from_json.present {
		return if loader.from_internal_json {
			cask_loader_load_from_internal_json(loader, config, loader.from_json, context)
		} else {
			cask_loader_load_from_json(loader, config, loader.from_json, context)
		}
	}
	return cask_loader_load_from_internal_api(loader, config, context)
}

// Ruby method `load_from_internal_api(config:)` at line 457.
pub fn cask_loader_load_from_internal_api(loader CaskLoader,
	config CaskLoaderConfig, context CaskLoaderLoadContext) !CaskLoaderCask {
	source := if context.internal_api.present {
		context.internal_api
	} else {
		context.lookup.api_sources[loader.token] or {
			return error("KeyError: key not found: '${loader.token}'")
		}
	}
	return cask_loader_load_from_struct(loader, config, source, source, source.tap_git_head, true, context.lookup)
}

// Ruby method `load_from_json(config:, api_source:)` at line 468.
pub fn cask_loader_load_from_json(loader CaskLoader, config CaskLoaderConfig,
	raw_source CaskLoaderApiSource, context CaskLoaderLoadContext) !CaskLoaderCask {
	mut source := raw_source
	if loader.from_installed_caskfile {
		if source.version == '' {
			parents := os.norm_path(loader.sourcefile_path).split(os.path_separator)
			if parents.len >= 4 {
				source = CaskLoaderApiSource{ ...source, version: parents[parents.len - 4] }
			}
		}
		if source.version == '' || !source.has_artifacts {
			receipt := cask_loader_load_installed_tab(CaskLoaderReference{
				kind: .text
				value: loader.token
			}, context.lookup)
			version := if source.version != '' { source.version } else { receipt.version }
			artifacts := if source.has_artifacts {
				source.artifacts
			} else {
				cask_loader_resolve_installed_artifacts(loader.token, receipt.uninstall_artifacts, receipt.has_uninstall_artifacts, if receipt.has_tap {
					receipt.tap
				} else {
					none
				}, loader.api_fallback, context.lookup)
			}
			source = CaskLoaderApiSource{ ...source, version: version, artifacts: artifacts, has_artifacts: true }
		}
	}
	return cask_loader_load_from_struct(loader, config, source, source, source.tap_git_head, false, context.lookup)
}

// Ruby method `load_from_internal_json(config:, api_source:)` at line 491.
pub fn cask_loader_load_from_internal_json(loader CaskLoader,
	config CaskLoaderConfig, source CaskLoaderApiSource,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	return cask_loader_load_from_struct(loader, config, source, CaskLoaderApiSource{ ...source, tap_git_head: '' }, source.tap_git_head, true, context.lookup)
}

// Ruby method `load_from_struct(config:, cask_struct:, api_source:, tap_git_head:, internal_api: false)` at line 508.
pub fn cask_loader_load_from_struct(loader CaskLoader,
	config CaskLoaderConfig, cask_struct CaskLoaderApiSource, api_source CaskLoaderApiSource,
	tap_git_head string, internal_api bool, context CaskLoaderLookupContext) !CaskLoaderCask {
	if cask_struct.invalid_reason != '' {
		return error('CaskInvalidError: ${cask_struct.invalid_reason}')
	}
	mut localised := cask_struct
	mut selected_localisation := CaskLoaderLocalisation{}
	mut has_selected_localisation := false
	for language in config.languages {
		normalised_language := language.replace('_', '-').to_lower()
		for localisation in cask_struct.localisations {
			if localisation.languages.any(it.replace('_', '-').to_lower() == normalised_language) {
				selected_localisation = localisation
				has_selected_localisation = true
				break
			}
		}
		if has_selected_localisation {
			break
		}
		for localisation in cask_struct.localisations {
			if normalised_language.split('-')[0] in localisation.languages.map(it.replace('_', '-').to_lower().split('-')[0]) {
				selected_localisation = localisation
				has_selected_localisation = true
				break
			}
		}
		if has_selected_localisation {
			break
		}
	}
	if !has_selected_localisation {
		for localisation in cask_struct.localisations {
			if localisation.is_default {
				selected_localisation = localisation
				has_selected_localisation = true
				break
			}
		}
	}
	if has_selected_localisation {
		variation := selected_localisation
		localised = CaskLoaderApiSource{
			...localised
			version: if variation.version != '' { variation.version } else { localised.version }
			sha256: if variation.sha256 != '' { variation.sha256 } else { localised.sha256 }
			url: if variation.url != '' { variation.url } else { localised.url }
			names: if variation.names.len > 0 {
				variation.names.clone()
			} else {
				localised.names.clone()
			}
			desc: if variation.desc != '' { variation.desc } else { localised.desc }
			homepage: if variation.homepage != '' { variation.homepage } else { localised.homepage }
			artifacts: if variation.has_artifacts {
				variation.artifacts.clone()
			} else {
				localised.artifacts.clone()
			}
			has_artifacts: variation.has_artifacts || localised.has_artifacts
			caveats: if variation.caveats != '' { variation.caveats } else { localised.caveats }
			caveats_rosetta: variation.caveats_rosetta || localised.caveats_rosetta
			auto_updates: if variation.has_auto_updates {
				variation.auto_updates
			} else {
				localised.auto_updates
			}
			deprecated: if variation.has_deprecated {
				variation.deprecated
			} else {
				localised.deprecated
			}
			disabled: if variation.has_disabled { variation.disabled } else { localised.disabled }
			conflicts_with: if variation.conflicts_with.len > 0 {
				variation.conflicts_with.clone()
			} else {
				localised.conflicts_with.clone()
			}
			renames: if variation.renames.len > 0 {
				variation.renames.clone()
			} else {
				localised.renames.clone()
			}
			depends_on: if variation.depends_on.len > 0 {
				variation.depends_on.clone()
			} else {
				localised.depends_on.clone()
			}
			depends_on_error: if variation.depends_on_error != '' {
				variation.depends_on_error
			} else {
				localised.depends_on_error
			}
			container_nested: if variation.container_nested != '' {
				variation.container_nested
			} else {
				localised.container_nested
			}
			container_type: if variation.container_type != '' {
				variation.container_type
			} else {
				localised.container_type
			}
		}
	} else {
		for language in config.languages {
			if version := cask_struct.language_versions[language] {
				localised = CaskLoaderApiSource{ ...localised, version: version }
				break
			}
		}
	}
	selected_language := if has_selected_localisation {
		if selected_localisation.value != '' {
			selected_localisation.value
		} else if selected_localisation.languages.len > 0 {
			selected_localisation.languages[0]
		} else {
			''
		}
	} else {
		''
	}
	caskfile_only := (cask_struct.languages.len > 0 && cask_struct.localisations.len == 0) || localised.artifacts.any(it.kind in [
		'preflight',
		'postflight',
		'uninstall_preflight',
		'uninstall_postflight',
	])
	mut tap := CaskLoaderTap{}
	mut has_tap := false
	if localised.tap != '' {
		tap = cask_loader_tap_by_name(context, localised.tap) or { CaskLoaderTap{ name: localised.tap } }
		has_tap = true
	}
	return CaskLoaderCask{
		token: loader.token
		version: localised.version
		sha256: localised.sha256
		url: localised.url
		names: localised.names.clone()
		desc: localised.desc
		homepage: localised.homepage
		artifacts: localised.artifacts.clone()
		tap: tap
		has_tap: has_tap
		source: api_source.raw
		sourcefile_path: loader.sourcefile_path
		config: config
		loaded_from_api: true
		loaded_from_internal_api: internal_api
		tap_git_head: tap_git_head
		url_specs: localised.url_specs.clone()
		deprecated: localised.deprecated
		disabled: localised.disabled
		auto_updates: localised.auto_updates
		conflicts_with: localised.conflicts_with.clone()
		renames: localised.renames.clone()
		depends_on: if localised.depends_on_error == '' {
			localised.depends_on.clone()
		} else {
			map[string]string{}
		}
		ignored_dependency_error: localised.depends_on_error
		container_nested: localised.container_nested
		container_type: localised.container_type
		caveats: localised.caveats
		caveats_rosetta: localised.caveats_rosetta
		language: selected_language
		caskfile_only: caskfile_only
	}
}

// Ruby method `self.try_new(ref, warn: false)` at line 592.
pub fn cask_loader_try_name(ref CaskLoaderReference, warn bool,
	context CaskLoaderLookupContext) CaskLoaderTryResult {
	if ref.kind != .text || !cask_loader_valid_token(ref.value) {
		return CaskLoaderTryResult{}
	}
	token := ref.value.to_lower()
	if context.core_cask_tap.installed {
		if resolution := cask_loader_tap_cask_token_type('${context.core_cask_tap.name}/${token}', false, context) {
			mut loader := cask_loader_loader_from_token_tap_type(resolution, context) or { CaskLoader{} }
			if warn && resolution.type_name in [.rename, .migration] && !(resolution.type_name == .migration && resolution.tap.core_tap) {
				loader.warning = 'Cask ${token} was renamed to ${if resolution.tap.core_cask_tap {
					resolution.token
				} else {
					'\${resolution.tap.name}/\${resolution.token}'
				}}.'
			}
			if loader.kind == .api || os.exists(loader.path) {
				return CaskLoaderTryResult{ loader: loader, found: true }
			}
		}
	}
	mut loaders := []CaskLoader{}
	for tap in context.taps {
		if !tap.installed || tap.core_cask_tap {
			continue
		}
		if loader := cask_loader_try_tap(CaskLoaderReference{
			kind: .text
			value: '${tap.name}/${token}'
		}, warn, context) {
			if loader.kind == .api || os.exists(loader.path) {
				if !loaders.any(it.path == loader.path) {
					loaders << loader
				}
			}
		}
	}
	if loaders.len == 1 {
		return CaskLoaderTryResult{ loader: loaders[0], found: true }
	}
	if loaders.len >= 2 {
		return CaskLoaderTryResult{ error_message: 'TapCaskAmbiguityError: ${token}' }
	}
	return CaskLoaderTryResult{}
}

// Ruby method `self.try_new(ref, warn: false, api_fallback: true)` at line 635.
pub fn cask_loader_try_installed_path(ref CaskLoaderReference, api_fallback bool,
	context CaskLoaderLookupContext) ?CaskLoader {
	token := if ref.kind == .text {
		ref.value
	} else if ref.kind == .path {
		cask_loader_token_from_path(ref.value)
	} else {
		return none
	}
	path := context.installed_caskfiles[token] or { return none }
	return new_installed_path_cask_loader(path, '', api_fallback, context)
}

// Ruby method `initialize(path, token: "", api_fallback: true)` at line 650.
pub fn new_installed_path_cask_loader(path string, token string, api_fallback bool,
	context CaskLoaderLookupContext) CaskLoader {
	mut loader := new_path_cask_loader(path, token, context)
	loader.kind = .installed_path
	receipt := context.installed_receipts[loader.token] or { CaskLoaderReceipt{} }
	if receipt.has_tap {
		loader.tap = receipt.tap
		loader.has_tap = true
	}
	loader.from_installed_caskfile = true
	loader.api_fallback = api_fallback
	return loader
}

// Ruby method `self.try_new(ref, warn: false)` at line 666.
pub fn cask_loader_try_null(ref CaskLoaderReference,
	context CaskLoaderLookupContext) ?CaskLoader {
	if ref.kind in [.cask, .uri] {
		return none
	}
	return new_null_cask_loader(ref.value, context)
}

// Ruby method `initialize(ref)` at line 674.
pub fn new_null_cask_loader(ref string,
	context CaskLoaderLookupContext) CaskLoader {
	token := os.base(ref).trim_string_right('.rb')
	mut loader := new_path_cask_loader(cask_loader_default_path(token, context), '', context)
	loader.kind = .null_loader
	return loader
}

// Ruby method `load(config:)` at line 680.
pub fn cask_loader_load_null(loader CaskLoader, _ CaskLoaderConfig) !CaskLoaderCask {
	return error('CaskUnavailableError: ${loader.token}: No Cask with this name exists.')
}

// Ruby method `self.path(ref)` at line 688.
pub fn cask_loader_path_for(ref CaskLoaderReference,
	context CaskLoaderLookupContext) !string {
	loader := cask_loader_for(ref, true, true, context)!
	return loader.path
}

// Ruby method `self.load(ref, config: nil, warn: true)` at line 698.
pub fn cask_loader_load_reference(ref CaskLoaderReference,
	config CaskLoaderConfig, warn bool, context CaskLoaderLoadContext) !CaskLoaderCask {
	if loaded := context.lookup.load_casks[cask_loader_ref_text(ref)] {
		return loaded
	}
	if cask_loader_ref_text(ref) in context.lookup.load_failures {
		return error('CaskUnavailableError: ${cask_loader_ref_text(ref)}')
	}
	mut loader := cask_loader_for(ref, false, warn, context.lookup)!
	return cask_loader_load_selected(mut loader, config, context)
}

// Ruby method `self.tap_cask_token_type(tapped_token, warn:)` at line 704.
pub fn cask_loader_tap_cask_token_type(tapped_token string, warn bool,
	context CaskLoaderLookupContext) ?CaskLoaderTokenTapType {
	tap_value, token_value := cask_loader_with_token(context, tapped_token) or { return none }
	mut tap := tap_value
	mut token := token_value
	mut type_name := CaskLoaderMigrationKind.none
	mut old_token := ''
	mut new_token := ''
	if renamed := tap.cask_renames[token] {
		old_token = if tap.core_cask_tap { token } else { tapped_token }
		token = renamed
		new_token = if tap.core_cask_tap { token } else { '${tap.name}/${token}' }
		type_name = .rename
	} else if migration := tap.tap_migrations[token] {
		mut new_tap := tap
		mut migrated_token := migration
		if migrated_tap, migrated_name := cask_loader_with_token(context, migration) {
			new_tap = migrated_tap
			migrated_token = migrated_name
		} else if migration.contains('/') {
			new_tap = cask_loader_tap_by_name(context, migration) or { CaskLoaderTap{ name: migration } }
			migrated_token = token
		}
		new_tapped_token := '${new_tap.name}/${migrated_token}'
		if tapped_token.to_lower() != new_tapped_token.to_lower() {
			old_token = if tap.core_cask_tap { token } else { tapped_token.to_lower() }
			resolution := cask_loader_tap_cask_token_type(new_tapped_token, false, context) or { return none }
			token = resolution.token
			tap = resolution.tap
			new_token = if new_tap.core_cask_tap { token } else { '${tap.name}/${token}' }
			type_name = .migration
		}
	}
	mut warning := ''
	if warn && old_token != '' && new_token != '' {
		destination := cask_loader_find_cask_in_tap(token, tap)
		destination_exists := os.exists(destination) || (tap.core_cask_tap && !context.no_install_from_api && token in context.api_tokens)
		if destination_exists {
			warning = 'Cask ${old_token} was renamed to ${new_token}.'
		}
	}
	return CaskLoaderTokenTapType{
		token: token
		tap: tap
		type_name: type_name
		old_token: old_token
		new_token: new_token
		warning: warning
	}
}

// Ruby method `self.for(ref, need_path: false, warn: true)` at line 755.
pub fn cask_loader_for(ref CaskLoaderReference, _ bool, warn bool,
	context CaskLoaderLookupContext) !CaskLoader {
	if loader := cask_loader_try_instance(ref) {
		return loader
	}
	if loader := cask_loader_try_content(ref) {
		return loader
	}
	if loader := cask_loader_try_uri(ref, context) {
		return loader
	}
	if loader := cask_loader_try_api(ref, warn, context) {
		return loader
	}
	if loader := cask_loader_try_tap(ref, warn, context) {
		return loader
	}
	name_result := cask_loader_try_name(ref, warn, context)
	if name_result.error_message != '' {
		return error(name_result.error_message)
	}
	if name_result.found {
		return name_result.loader
	}
	if loader := cask_loader_try_path(ref, context) {
		return loader
	}
	if loader := cask_loader_try_installed_path(ref, true, context) {
		return loader
	}
	if loader := cask_loader_try_null(ref, context) {
		return loader
	}
	return error('CaskError: No cask loader found for ${cask_loader_ref_text(ref)}')
}

// Ruby method `self.load_prefer_installed(ref, config: nil, warn: true)` at line 777.
pub fn cask_loader_load_prefer_installed(ref string,
	config CaskLoaderConfig, warn bool, context CaskLoaderLoadContext) !CaskLoaderCask {
	mut token := ref
	mut tap_name := ''
	if tap, parsed_token := cask_loader_with_token(context.lookup, ref) {
		tap_name = tap.name
		token = parsed_token
	} else if receipt := context.lookup.installed_receipts[ref] {
		if receipt.has_tap {
			tap_name = receipt.tap.name
		}
	}
	if tap_name == '' {
		return cask_loader_lookup_cask(token, context.lookup)
	}
	return cask_loader_lookup_cask('${tap_name}/${token}', context.lookup) or {
		cask_loader_lookup_cask(token, context.lookup)
	}
}

// Ruby method `self.load_from_installed_caskfile(path, config: nil, warn: true, api_fallback: true)` at line 798.
pub fn cask_loader_load_from_installed_caskfile(path string,
	config CaskLoaderConfig, warn bool, api_fallback bool,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	ref := CaskLoaderReference{ kind: .path, value: path }
	mut loader := cask_loader_try_installed_path(ref, api_fallback, context.lookup) or {
		new_null_cask_loader(path, context.lookup)
	}
	return if loader.kind == .null_loader {
		cask_loader_load_null(loader, config)
	} else {
		cask_loader_load_path(mut loader, config, context)
	}
}

// Ruby method `self.token_from_path(path)` at line 806.
pub fn cask_loader_token_from_path(path string) string {
	return os.base(path).trim_string_right(cask_loader_extension(path)).trim_string_right('.internal')
}

// Ruby method `self.installed_json_caskfile?(path)` at line 812.
pub fn cask_loader_installed_json_caskfile(path string) bool {
	return cask_loader_extension(path) == '.json' && !os.base(path).ends_with('.internal.json')
}

// Ruby method `self.load_installed_json(path)` at line 817.
pub fn cask_loader_load_installed_json(path string) ?CaskLoaderApiSource {
	if !cask_loader_installed_json_caskfile(path) {
		return none
	}
	contents := os.read_file(path) or { return none }
	return cask_loader_parse_json(contents) or { none }
}

// Ruby method `self.load_installed_tab(cask_or_token)` at line 827.
pub fn cask_loader_load_installed_tab(cask_or_token CaskLoaderReference,
	context CaskLoaderLookupContext) CaskLoaderReceipt {
	token := if cask_or_token.kind == .cask {
		cask_or_token.cask.token
	} else {
		cask_or_token.value
	}
	return context.installed_receipts[token] or { CaskLoaderReceipt{ valid: false } }
}

// Ruby method `self.resolve_installed_artifacts(token, artifacts, tap: nil, api_fallback: true)` at line 846.
pub fn cask_loader_resolve_installed_artifacts(token string,
	artifacts []CaskLoaderArtifact, has_artifacts bool, tap ?CaskLoaderTap,
	api_fallback bool, context CaskLoaderLookupContext) []CaskLoaderArtifact {
	if has_artifacts && artifacts.len > 0 {
		return artifacts.clone()
	}
	if !api_fallback {
		return []
	}
	mut result := []CaskLoaderArtifact{}
	if actual := tap {
		if !actual.core_cask_tap {
			result = context.tap_artifacts['${actual.name}/${token}'] or { []CaskLoaderArtifact{} }
		}
	} else if token in context.name_artifacts {
		result = context.name_artifacts[token].clone()
	}
	if result.len > 0 {
		return result
	}
	status := context.api_membership[token] or { CaskLoaderAvailability.unknown }
	failure_kind := context.api_artifact_failure_kinds[token] or { '' }
	if status == .absent || token in context.api_artifact_failures || failure_kind in [
		'ErrorDuringExecution',
		'SystemExit',
	] {
		return []
	}
	return context.api_artifacts[token] or { []CaskLoaderArtifact{} }
}

// Ruby method `self.recover_from_installed_caskfile(path, tab: nil, fallback_cask: nil, config: nil)` at line 888.
pub fn cask_loader_recover_from_installed_caskfile(path string,
	tab ?CaskLoaderReceipt, fallback_cask ?CaskLoaderCask, config CaskLoaderConfig,
	context CaskLoaderLookupContext) ?CaskLoaderCask {
	if os.base(os.dir(path)) != 'Casks' {
		return none
	}
	token := cask_loader_token_from_path(path)
	if token in context.recovery_invalid_tokens {
		return none
	}
	receipt := tab or {
		if fallback := fallback_cask {
			cask_loader_load_installed_tab(CaskLoaderReference{
				kind: .cask
				cask: fallback
			}, context)
		} else {
			cask_loader_load_installed_tab(CaskLoaderReference{
				kind: .text
				value: token
			}, context)
		}
	}
	if receipt.uninstall_flight_blocks {
		return none
	}
	if fallback := fallback_cask {
		if fallback.uninstall_flight_blocks {
			return none
		}
	}
	mut artifacts := if receipt.has_uninstall_artifacts && receipt.uninstall_artifacts.len > 0 {
		receipt.uninstall_artifacts.clone()
	} else {
		[]CaskLoaderArtifact{}
	}
	if artifacts.len == 0 {
		if fallback := fallback_cask {
			artifacts = fallback.artifacts.clone()
		}
	}
	if artifacts.len == 0 {
		artifacts = cask_loader_resolve_installed_artifacts(token, [], false, if receipt.has_tap {
			receipt.tap
		} else {
			none
		}, true, context)
	}
	parts := os.norm_path(path).split(os.path_separator)
	if parts.len < 4 {
		return none
	}
	version := parts[parts.len - 4]
	mut url_specs := map[string]string{}
	if fallback := fallback_cask {
		url_specs = fallback.url_specs.clone()
	}
	if source := cask_loader_load_installed_json(path) {
		if source.url_specs.len > 0 {
			url_specs = source.url_specs.clone()
		}
	}
	if version == '' {
		return none
	}
	return CaskLoaderCask{
		token: token
		version: version
		artifacts: artifacts
		config: config
		loaded_from_api: true
		sourcefile_path: path
		url_specs: url_specs
	}
}

// Ruby method `self.default_path(token)` at line 932.
pub fn cask_loader_default_path(token string,
	context CaskLoaderLookupContext) string {
	return cask_loader_find_cask_in_tap(token.to_lower(), context.core_cask_tap)
}

// Ruby method `self.find_cask_in_tap(token, tap)` at line 937.
pub fn cask_loader_find_cask_in_tap(token string,
	tap CaskLoaderTap) string {
	return tap.cask_files_by_name[token] or { os.join_path(tap.cask_dir, '${token}.rb') }
}
