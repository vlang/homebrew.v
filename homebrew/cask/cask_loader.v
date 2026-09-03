module cask

import homebrew.extend.env as env_sensitive
import net.urllib
import os
import x.json2

// Translated from Homebrew/brew `cask/cask_loader.rb`.
// The original source is retained below until every stub has a typed V body.
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
				cask_loader_any_strings(raw_languages)} else {
				[]string{}}
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
		.content { ruby_cask_loader_l104_d8_load(mut loader, config, context)! }
		.path, .installed_path { ruby_cask_loader_l167_d15_load(mut loader, config, context)! }
		.uri { ruby_cask_loader_l282_d21_load(mut loader, config, context)! }
		.tap { ruby_cask_loader_l347_d26_load(mut loader, config, context)! }
		.instance { ruby_cask_loader_l373_d29_load(loader, config) }
		.api { ruby_cask_loader_l442_d35_load(loader, config, context)! }
		.null_loader { ruby_cask_loader_l680_d45_load(loader, config)! }
		else {
			return error('CaskError: No cask loader found for ${loader.token}')
		}
	}
}

// Ruby method `load(config:); end` at line 31.
pub fn ruby_cask_loader_l31_d1_load(mut loader CaskLoader, config CaskLoaderConfig,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	return cask_loader_load_selected(mut loader, config, context)
}

// Ruby attr_reader `attr_reader :content` at line 42.
pub fn ruby_cask_loader_l42_d2_content(loader CaskLoader) string {
	return loader.content
}

// Ruby attr_reader `attr_reader :tap` at line 45.
pub fn ruby_cask_loader_l45_d3_tap(loader CaskLoader) ?CaskLoaderTap {
	return if loader.has_tap { loader.tap } else { none }
}

// Ruby method `initialize` at line 48.
pub fn ruby_cask_loader_l48_d4_initialize() CaskLoader {
	return CaskLoader{ kind: .abstract_content }
}

// Ruby method `cask(header_token, **options, &block)` at line 63.
pub fn ruby_cask_loader_l63_d5_cask(loader CaskLoader, header_token string,
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
pub fn ruby_cask_loader_l74_d6_self_try_new(ref CaskLoaderReference) ?CaskLoader {
	if ref.kind == .cask || !cask_loader_content_match(cask_loader_ref_text(ref)) {
		return none
	}
	return ruby_cask_loader_l96_d7_initialize(cask_loader_ref_text(ref), none)
}

// Ruby method `initialize(content, tap: T.unsafe(nil))` at line 96.
pub fn ruby_cask_loader_l96_d7_initialize(content string, tap ?CaskLoaderTap) CaskLoader {
	mut loader := ruby_cask_loader_l48_d4_initialize()
	loader.kind = .content
	loader.content = content
	if actual := tap {
		loader.tap = actual
		loader.has_tap = true
	}
	return loader
}

// Ruby method `load(config:)` at line 104.
pub fn ruby_cask_loader_l104_d8_load(mut loader CaskLoader, config CaskLoaderConfig,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	loader.config = config
	loader.has_config = true
	masked := cask_loader_mask_environment(context.environment)
	return cask_loader_cask_from_evaluation(loader, config, context.evaluation, masked)
}

// Ruby method `self.try_new(ref, warn: false)` at line 119.
pub fn ruby_cask_loader_l119_d9_self_try_new(ref CaskLoaderReference,
	context CaskLoaderLookupContext) ?CaskLoader {
	if ref.kind !in [.text, .path] {
		return none
	}
	path := os.abs_path(ref.value)
	if !os.exists(path) || ruby_cask_loader_l137_d10_self_invalid_path(path, ['.rb', '.json']) || (!os.is_file(path) && !os.is_link(path)) {
		return none
	}
	return ruby_cask_loader_l154_d14_initialize(path, '', context)
}

// Ruby method `self.invalid_path?(pathname, valid_extnames: %w[.rb .json])` at line 137.
pub fn ruby_cask_loader_l137_d10_self_invalid_path(pathname string,
	valid_extnames []string) bool {
	return cask_loader_extension(pathname) !in valid_extnames || os.base(pathname) in [
		'INSTALL_RECEIPT.json',
		'sbom.spdx.json',
	]
}

// Ruby attr_reader `attr_reader :token` at line 145.
pub fn ruby_cask_loader_l145_d11_token(loader CaskLoader) string {
	return loader.token
}

// Ruby attr_reader `attr_reader :path` at line 148.
pub fn ruby_cask_loader_l148_d12_path(loader CaskLoader) string {
	return loader.path
}

// Ruby attr_writer `attr_writer :from_installed_caskfile` at line 151.
pub fn ruby_cask_loader_l151_d13_from_installed_caskfile(mut loader CaskLoader,
	from_installed_caskfile bool) {
	loader.from_installed_caskfile = from_installed_caskfile
}

// Ruby method `initialize(path, token: T.unsafe(nil))` at line 154.
pub fn ruby_cask_loader_l154_d14_initialize(path string, _ string,
	context CaskLoaderLookupContext) CaskLoader {
	absolute := os.abs_path(path)
	mut loader := ruby_cask_loader_l48_d4_initialize()
	loader.kind = .path
	loader.token = ruby_cask_loader_l806_d52_self_token_from_path(absolute)
	loader.path = absolute
	if tap := context.source_download_taps[absolute] {
		loader.tap = tap
		loader.has_tap = true
	}
	return loader
}

// Ruby method `load(config:)` at line 167.
pub fn ruby_cask_loader_l167_d15_load(mut loader CaskLoader, config CaskLoaderConfig,
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
	if !ruby_cask_loader_l137_d10_self_invalid_path(loader.path, ['.json']) {
		source := cask_loader_parse_json(loader.content)!
		if loader.from_installed_caskfile || source.present {
			api_loader := ruby_cask_loader_l420_d34_initialize(loader.token, source, loader.path, loader.from_installed_caskfile, loader.path.ends_with('.internal.json'), loader.api_fallback, context.lookup)
			return ruby_cask_loader_l442_d35_load(api_loader, config, context) or {
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
pub fn ruby_cask_loader_l231_d16_cask(loader CaskLoader, header_token string,
	definition CaskLoaderCask) !CaskLoaderCask {
	if loader.token != header_token {
		return error("CaskTokenMismatchError: expected '${loader.token}', got '${header_token}'")
	}
	return CaskLoaderCask{
		...ruby_cask_loader_l63_d5_cask(loader, header_token, definition)
		sourcefile_path: loader.path
	}
}

// Ruby method `self.try_new(ref, warn: false)` at line 244.
pub fn ruby_cask_loader_l244_d17_self_try_new(ref CaskLoaderReference,
	context CaskLoaderLookupContext) ?CaskLoader {
	if context.forbid_packages_from_paths {
		return none
	}
	raw := cask_loader_ref_text(ref)
	uri := urllib.parse(raw) or { return none }
	if uri.path == '' || (!raw.contains('://') && !raw.starts_with('file:')) {
		return none
	}
	return ruby_cask_loader_l272_d20_initialize(raw, context)
}

// Ruby attr_reader `attr_reader :url` at line 266.
pub fn ruby_cask_loader_l266_d18_url(loader CaskLoader) string {
	return loader.url
}

// Ruby attr_reader `attr_reader :name` at line 269.
pub fn ruby_cask_loader_l269_d19_name(loader CaskLoader) string {
	return loader.name
}

// Ruby method `initialize(url)` at line 272.
pub fn ruby_cask_loader_l272_d20_initialize(url string,
	context CaskLoaderLookupContext) CaskLoader {
	parsed := urllib.parse(url) or { panic('unexpected nil url.path') }
	name := os.base(parsed.path)
	mut loader := ruby_cask_loader_l154_d14_initialize(os.join_path(context.cache_path, name), '', context)
	loader.kind = .uri
	loader.url = url
	loader.name = name
	return loader
}

// Ruby method `load(config:)` at line 282.
pub fn ruby_cask_loader_l282_d21_load(mut loader CaskLoader, config CaskLoaderConfig,
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
	return ruby_cask_loader_l167_d15_load(mut loader, config, context)
}

// Ruby attr_reader `attr_reader :tap` at line 306.
pub fn ruby_cask_loader_l306_d22_tap(loader CaskLoader) CaskLoaderTap {
	return loader.tap
}

// Ruby method `self.try_new(ref, warn: false)` at line 313.
pub fn ruby_cask_loader_l313_d23_self_try_new(ref CaskLoaderReference, warn bool,
	context CaskLoaderLookupContext) ?CaskLoader {
	resolution := ruby_cask_loader_l704_d48_self_tap_cask_token_type(cask_loader_ref_text(ref), warn, context) or { return none }
	mut loader := ruby_cask_loader_l325_d24_self_loader_from_token_tap_type(resolution, context) or {
		return none
	}
	loader.warning = resolution.warning
	return loader
}

// Ruby method `self.loader_from_token_tap_type(token_tap_type)` at line 325.
pub fn ruby_cask_loader_l325_d24_self_loader_from_token_tap_type(resolution CaskLoaderTokenTapType,
	context CaskLoaderLookupContext) ?CaskLoader {
	if resolution.type_name == .migration && resolution.tap.core_cask_tap {
		if loader := ruby_cask_loader_l395_d33_self_try_new(CaskLoaderReference{
			kind: .text
			value: resolution.token
		}, false, context) {
			return loader
		}
	}
	return ruby_cask_loader_l336_d25_initialize('${resolution.tap.name}/${resolution.token}', context) or {
		none
	}
}

// Ruby method `initialize(tapped_token)` at line 336.
pub fn ruby_cask_loader_l336_d25_initialize(tapped_token string,
	context CaskLoaderLookupContext) !CaskLoader {
	tap, token := cask_loader_with_token(context, tapped_token) or {
		return error('unexpected nil Tap.with_cask_token')
	}
	path := ruby_cask_loader_l937_d59_self_find_cask_in_tap(token, tap)
	mut loader := ruby_cask_loader_l154_d14_initialize(path, '', context)
	loader.kind = .tap
	loader.tap = tap
	loader.has_tap = true
	return loader
}

// Ruby method `load(config:)` at line 347.
pub fn ruby_cask_loader_l347_d26_load(mut loader CaskLoader, config CaskLoaderConfig,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	if !loader.tap.installed {
		return error('TapCaskUnavailableError: ${loader.tap.name}/${loader.token}; If you trust this tap')
	}
	return ruby_cask_loader_l167_d15_load(mut loader, config, context)
}

// Ruby method `self.try_new(ref, warn: false)` at line 362.
pub fn ruby_cask_loader_l362_d27_self_try_new(ref CaskLoaderReference) ?CaskLoader {
	return if ref.kind == .cask { ruby_cask_loader_l367_d28_initialize(ref.cask) } else { none }
}

// Ruby method `initialize(cask)` at line 367.
pub fn ruby_cask_loader_l367_d28_initialize(cask CaskLoaderCask) CaskLoader {
	return CaskLoader{ kind: .instance, cask: cask, has_cask: true, token: cask.token }
}

// Ruby method `load(config:)` at line 373.
pub fn ruby_cask_loader_l373_d29_load(loader CaskLoader, _ CaskLoaderConfig) CaskLoaderCask {
	return loader.cask
}

// Ruby attr_reader `attr_reader :token` at line 383.
pub fn ruby_cask_loader_l383_d30_token(loader CaskLoader) string {
	return loader.token
}

// Ruby attr_reader `attr_reader :path` at line 386.
pub fn ruby_cask_loader_l386_d31_path(loader CaskLoader) string {
	return loader.path
}

// Ruby attr_reader `attr_reader :from_json` at line 389.
pub fn ruby_cask_loader_l389_d32_from_json(loader CaskLoader) ?CaskLoaderApiSource {
	return if loader.from_json.present { loader.from_json } else { none }
}

// Ruby method `self.try_new(ref, warn: false)` at line 395.
pub fn ruby_cask_loader_l395_d33_self_try_new(ref CaskLoaderReference, warn bool,
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
	resolution := ruby_cask_loader_l704_d48_self_tap_cask_token_type('${context.core_cask_tap.name}/${token}', warn, context) or { return none }
	mut loader := ruby_cask_loader_l420_d34_initialize('${resolution.tap.name}/${resolution.token}', CaskLoaderApiSource{}, '', false, false, true, context)
	loader.warning = resolution.warning
	return loader
}

// Ruby method `initialize(token, from_json: T.unsafe(nil), path: nil, from_installed_caskfile: false,` at line 420.
pub fn ruby_cask_loader_l420_d34_initialize(raw_token string, from_json CaskLoaderApiSource,
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
			path} else {
			ruby_cask_loader_l932_d58_self_default_path(token, context)}
		from_json: from_json
		from_installed_caskfile: from_installed_caskfile
		from_internal_json: from_internal_json
		api_fallback: api_fallback
		sourcefile_path: sourcefile_path
	}
}

// Ruby method `load(config:)` at line 442.
pub fn ruby_cask_loader_l442_d35_load(loader CaskLoader, config CaskLoaderConfig,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	if loader.from_json.present {
		return if loader.from_internal_json {
			ruby_cask_loader_l491_d38_load_from_internal_json(loader, config, loader.from_json, context)
		} else {
			ruby_cask_loader_l468_d37_load_from_json(loader, config, loader.from_json, context)
		}
	}
	return ruby_cask_loader_l457_d36_load_from_internal_api(loader, config, context)
}

// Ruby method `load_from_internal_api(config:)` at line 457.
pub fn ruby_cask_loader_l457_d36_load_from_internal_api(loader CaskLoader,
	config CaskLoaderConfig, context CaskLoaderLoadContext) !CaskLoaderCask {
	source := if context.internal_api.present {
		context.internal_api
	} else {
		context.lookup.api_sources[loader.token] or {
			return error("KeyError: key not found: '${loader.token}'")
		}
	}
	return ruby_cask_loader_l508_d39_load_from_struct(loader, config, source, source, source.tap_git_head, true, context.lookup)
}

// Ruby method `load_from_json(config:, api_source:)` at line 468.
pub fn ruby_cask_loader_l468_d37_load_from_json(loader CaskLoader, config CaskLoaderConfig,
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
			receipt := ruby_cask_loader_l827_d55_self_load_installed_tab(CaskLoaderReference{
				kind: .text
				value: loader.token
			}, context.lookup)
			version := if source.version != '' { source.version } else { receipt.version }
			artifacts := if source.has_artifacts {
				source.artifacts
			} else {
				ruby_cask_loader_l846_d56_self_resolve_installed_artifacts(loader.token, receipt.uninstall_artifacts, receipt.has_uninstall_artifacts, if receipt.has_tap {
					receipt.tap
				} else {
					none
				}, loader.api_fallback, context.lookup)
			}
			source = CaskLoaderApiSource{ ...source, version: version, artifacts: artifacts, has_artifacts: true }
		}
	}
	return ruby_cask_loader_l508_d39_load_from_struct(loader, config, source, source, source.tap_git_head, false, context.lookup)
}

// Ruby method `load_from_internal_json(config:, api_source:)` at line 491.
pub fn ruby_cask_loader_l491_d38_load_from_internal_json(loader CaskLoader,
	config CaskLoaderConfig, source CaskLoaderApiSource,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	return ruby_cask_loader_l508_d39_load_from_struct(loader, config, source, CaskLoaderApiSource{ ...source, tap_git_head: '' }, source.tap_git_head, true, context.lookup)
}

// Ruby method `load_from_struct(config:, cask_struct:, api_source:, tap_git_head:, internal_api: false)` at line 508.
pub fn ruby_cask_loader_l508_d39_load_from_struct(loader CaskLoader,
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
			localised.depends_on.clone()} else {
			map[string]string{}}
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
pub fn ruby_cask_loader_l592_d40_self_try_new(ref CaskLoaderReference, warn bool,
	context CaskLoaderLookupContext) CaskLoaderTryResult {
	if ref.kind != .text || !cask_loader_valid_token(ref.value) {
		return CaskLoaderTryResult{}
	}
	token := ref.value.to_lower()
	if context.core_cask_tap.installed {
		if resolution := ruby_cask_loader_l704_d48_self_tap_cask_token_type('${context.core_cask_tap.name}/${token}', false, context) {
			mut loader := ruby_cask_loader_l325_d24_self_loader_from_token_tap_type(resolution, context) or { CaskLoader{} }
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
		if loader := ruby_cask_loader_l313_d23_self_try_new(CaskLoaderReference{
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
pub fn ruby_cask_loader_l635_d41_self_try_new(ref CaskLoaderReference, api_fallback bool,
	context CaskLoaderLookupContext) ?CaskLoader {
	token := if ref.kind == .text {
		ref.value
	} else if ref.kind == .path {
		ruby_cask_loader_l806_d52_self_token_from_path(ref.value)
	} else {
		return none
	}
	path := context.installed_caskfiles[token] or { return none }
	return ruby_cask_loader_l650_d42_initialize(path, '', api_fallback, context)
}

// Ruby method `initialize(path, token: "", api_fallback: true)` at line 650.
pub fn ruby_cask_loader_l650_d42_initialize(path string, token string, api_fallback bool,
	context CaskLoaderLookupContext) CaskLoader {
	mut loader := ruby_cask_loader_l154_d14_initialize(path, token, context)
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
pub fn ruby_cask_loader_l666_d43_self_try_new(ref CaskLoaderReference,
	context CaskLoaderLookupContext) ?CaskLoader {
	if ref.kind in [.cask, .uri] {
		return none
	}
	return ruby_cask_loader_l674_d44_initialize(ref.value, context)
}

// Ruby method `initialize(ref)` at line 674.
pub fn ruby_cask_loader_l674_d44_initialize(ref string,
	context CaskLoaderLookupContext) CaskLoader {
	token := os.base(ref).trim_string_right('.rb')
	mut loader := ruby_cask_loader_l154_d14_initialize(ruby_cask_loader_l932_d58_self_default_path(token, context), '', context)
	loader.kind = .null_loader
	return loader
}

// Ruby method `load(config:)` at line 680.
pub fn ruby_cask_loader_l680_d45_load(loader CaskLoader, _ CaskLoaderConfig) !CaskLoaderCask {
	return error('CaskUnavailableError: ${loader.token}: No Cask with this name exists.')
}

// Ruby method `self.path(ref)` at line 688.
pub fn ruby_cask_loader_l688_d46_self_path(ref CaskLoaderReference,
	context CaskLoaderLookupContext) !string {
	loader := ruby_cask_loader_l755_d49_self_for(ref, true, true, context)!
	return loader.path
}

// Ruby method `self.load(ref, config: nil, warn: true)` at line 698.
pub fn ruby_cask_loader_l698_d47_self_load(ref CaskLoaderReference,
	config CaskLoaderConfig, warn bool, context CaskLoaderLoadContext) !CaskLoaderCask {
	if loaded := context.lookup.load_casks[cask_loader_ref_text(ref)] {
		return loaded
	}
	if cask_loader_ref_text(ref) in context.lookup.load_failures {
		return error('CaskUnavailableError: ${cask_loader_ref_text(ref)}')
	}
	mut loader := ruby_cask_loader_l755_d49_self_for(ref, false, warn, context.lookup)!
	return cask_loader_load_selected(mut loader, config, context)
}

// Ruby method `self.tap_cask_token_type(tapped_token, warn:)` at line 704.
pub fn ruby_cask_loader_l704_d48_self_tap_cask_token_type(tapped_token string, warn bool,
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
			resolution := ruby_cask_loader_l704_d48_self_tap_cask_token_type(new_tapped_token, false, context) or { return none }
			token = resolution.token
			tap = resolution.tap
			new_token = if new_tap.core_cask_tap { token } else { '${tap.name}/${token}' }
			type_name = .migration
		}
	}
	mut warning := ''
	if warn && old_token != '' && new_token != '' {
		destination := ruby_cask_loader_l937_d59_self_find_cask_in_tap(token, tap)
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
pub fn ruby_cask_loader_l755_d49_self_for(ref CaskLoaderReference, _ bool, warn bool,
	context CaskLoaderLookupContext) !CaskLoader {
	if loader := ruby_cask_loader_l362_d27_self_try_new(ref) {
		return loader
	}
	if loader := ruby_cask_loader_l74_d6_self_try_new(ref) {
		return loader
	}
	if loader := ruby_cask_loader_l244_d17_self_try_new(ref, context) {
		return loader
	}
	if loader := ruby_cask_loader_l395_d33_self_try_new(ref, warn, context) {
		return loader
	}
	if loader := ruby_cask_loader_l313_d23_self_try_new(ref, warn, context) {
		return loader
	}
	name_result := ruby_cask_loader_l592_d40_self_try_new(ref, warn, context)
	if name_result.error_message != '' {
		return error(name_result.error_message)
	}
	if name_result.found {
		return name_result.loader
	}
	if loader := ruby_cask_loader_l119_d9_self_try_new(ref, context) {
		return loader
	}
	if loader := ruby_cask_loader_l635_d41_self_try_new(ref, true, context) {
		return loader
	}
	if loader := ruby_cask_loader_l666_d43_self_try_new(ref, context) {
		return loader
	}
	return error('CaskError: No cask loader found for ${cask_loader_ref_text(ref)}')
}

// Ruby method `self.load_prefer_installed(ref, config: nil, warn: true)` at line 777.
pub fn ruby_cask_loader_l777_d50_self_load_prefer_installed(ref string,
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
pub fn ruby_cask_loader_l798_d51_self_load_from_installed_caskfile(path string,
	config CaskLoaderConfig, warn bool, api_fallback bool,
	context CaskLoaderLoadContext) !CaskLoaderCask {
	ref := CaskLoaderReference{ kind: .path, value: path }
	mut loader := ruby_cask_loader_l635_d41_self_try_new(ref, api_fallback, context.lookup) or {
		ruby_cask_loader_l674_d44_initialize(path, context.lookup)
	}
	return if loader.kind == .null_loader {
		ruby_cask_loader_l680_d45_load(loader, config)
	} else {
		ruby_cask_loader_l167_d15_load(mut loader, config, context)
	}
}

// Ruby method `self.token_from_path(path)` at line 806.
pub fn ruby_cask_loader_l806_d52_self_token_from_path(path string) string {
	return os.base(path).trim_string_right(cask_loader_extension(path)).trim_string_right('.internal')
}

// Ruby method `self.installed_json_caskfile?(path)` at line 812.
pub fn ruby_cask_loader_l812_d53_self_installed_json_caskfile(path string) bool {
	return cask_loader_extension(path) == '.json' && !os.base(path).ends_with('.internal.json')
}

// Ruby method `self.load_installed_json(path)` at line 817.
pub fn ruby_cask_loader_l817_d54_self_load_installed_json(path string) ?CaskLoaderApiSource {
	if !ruby_cask_loader_l812_d53_self_installed_json_caskfile(path) {
		return none
	}
	contents := os.read_file(path) or { return none }
	return cask_loader_parse_json(contents) or { none }
}

// Ruby method `self.load_installed_tab(cask_or_token)` at line 827.
pub fn ruby_cask_loader_l827_d55_self_load_installed_tab(cask_or_token CaskLoaderReference,
	context CaskLoaderLookupContext) CaskLoaderReceipt {
	token := if cask_or_token.kind == .cask {
		cask_or_token.cask.token
	} else {
		cask_or_token.value
	}
	return context.installed_receipts[token] or { CaskLoaderReceipt{ valid: false } }
}

// Ruby method `self.resolve_installed_artifacts(token, artifacts, tap: nil, api_fallback: true)` at line 846.
pub fn ruby_cask_loader_l846_d56_self_resolve_installed_artifacts(token string,
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
pub fn ruby_cask_loader_l888_d57_self_recover_from_installed_caskfile(path string,
	tab ?CaskLoaderReceipt, fallback_cask ?CaskLoaderCask, config CaskLoaderConfig,
	context CaskLoaderLookupContext) ?CaskLoaderCask {
	if os.base(os.dir(path)) != 'Casks' {
		return none
	}
	token := ruby_cask_loader_l806_d52_self_token_from_path(path)
	if token in context.recovery_invalid_tokens {
		return none
	}
	receipt := tab or {
		if fallback := fallback_cask {
			ruby_cask_loader_l827_d55_self_load_installed_tab(CaskLoaderReference{
				kind: .cask
				cask: fallback
			}, context)
		} else {
			ruby_cask_loader_l827_d55_self_load_installed_tab(CaskLoaderReference{
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
		artifacts = ruby_cask_loader_l846_d56_self_resolve_installed_artifacts(token, [], false, if receipt.has_tap {
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
	if source := ruby_cask_loader_l817_d54_self_load_installed_json(path) {
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
pub fn ruby_cask_loader_l932_d58_self_default_path(token string,
	context CaskLoaderLookupContext) string {
	return ruby_cask_loader_l937_d59_self_find_cask_in_tap(token.to_lower(), context.core_cask_tap)
}

// Ruby method `self.find_cask_in_tap(token, tap)` at line 937.
pub fn ruby_cask_loader_l937_d59_self_find_cask_in_tap(token string,
	tap CaskLoaderTap) string {
	return tap.cask_files_by_name[token] or { os.join_path(tap.cask_dir, '${token}.rb') }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/cache"
// 5: require "cask/cask"
// 6: require "uri"
// 7: require "utils/curl"
// 8: require "utils/output"
// 9: require "utils/path"
// 10: require "extend/hash/keys"
// 11: require "extend/ENV/sensitive"
// 12: require "api"
// 13: require "trust"
// 14:
// 15: module Cask
// 16:   # Loads a cask from various sources.
// 17:   module CaskLoader
// 18:     extend Context
// 19:     extend ::Utils::Output::Mixin
// 20:
// 21:     ALLOWED_URL_SCHEMES = %w[file].freeze
// 22:     private_constant :ALLOWED_URL_SCHEMES
// 23:
// 24:     module ILoader
// 25:       extend T::Helpers
// 26:       include ::Utils::Output::Mixin
// 27:
// 28:       interface!
// 29:
// 30:       sig { abstract.params(config: T.nilable(Config)).returns(Cask) }
// 31:       def load(config:); end
// 32:     end
// 33:
// 34:     # Loads a cask from a string.
// 35:     class AbstractContentLoader
// 36:       include ILoader
// 37:       extend T::Helpers
// 38:
// 39:       abstract!
// 40:
// 41:       sig { returns(String) }
// 42:       attr_reader :content
// 43:
// 44:       sig { overridable.returns(T.nilable(Tap)) }
// 45:       attr_reader :tap
// 46:
// 47:       sig { void }
// 48:       def initialize
// 49:         @content = T.let("", String)
// 50:         @tap = T.let(nil, T.nilable(Tap))
// 51:         @config = T.let(nil, T.nilable(Config))
// 52:       end
// 53:
// 54:       private
// 55:
// 56:       sig {
// 57:         overridable.params(
// 58:           header_token: String,
// 59:           options:      T.untyped,
// 60:           block:        T.nilable(T.proc.bind(DSL).void),
// 61:         ).returns(Cask)
// 62:       }
// 63:       def cask(header_token, **options, &block)
// 64:         Cask.new(header_token, source: content, tap:, **options, config: @config, &block)
// 65:       end
// 66:     end
// 67:
// 68:     # Loads a cask from a string.
// 69:     class FromContentLoader < AbstractContentLoader
// 70:       sig {
// 71:         params(ref: T.any(Pathname, String, Cask, URI::Generic), warn: T::Boolean)
// 72:           .returns(T.nilable(T.attached_class))
// 73:       }
// 74:       def self.try_new(ref, warn: false)
// 75:         return if ref.is_a?(Cask)
// 76:
// 77:         content = ref.to_str
// 78:
// 79:         # Cache compiled regex
// 80:         @regex ||= T.let(
// 81:           begin
// 82:             token  = /(?:"[^"]*"|'[^']*')/
// 83:             curly  = /\(\s*#{token.source}\s*\)\s*\{.*\}/
// 84:             do_end = /\s+#{token.source}\s+do(?:\s*;\s*|\s+).*end/
// 85:             /\A\s*cask(?:#{curly.source}|#{do_end.source})\s*\Z/m
// 86:           end,
// 87:           T.nilable(Regexp),
// 88:         )
// 89:
// 90:         return unless content.match?(@regex)
// 91:
// 92:         new(content)
// 93:       end
// 94:
// 95:       sig { params(content: String, tap: Tap).void }
// 96:       def initialize(content, tap: T.unsafe(nil))
// 97:         super()
// 98:
// 99:         @content = T.let(content.dup.force_encoding("UTF-8"), String)
// 100:         @tap = T.let(tap, T.nilable(Tap))
// 101:       end
// 102:
// 103:       sig { override.params(config: T.nilable(Config)).returns(Cask) }
// 104:       def load(config:)
// 105:         @config = config
// 106:
// 107:         ENV.clear_sensitive_environment_for_eval! do
// 108:           instance_eval(content, __FILE__, __LINE__)
// 109:         end
// 110:       end
// 111:     end
// 112:
// 113:     # Loads a cask from a path.
// 114:     class FromPathLoader < AbstractContentLoader
// 115:       sig {
// 116:         overridable.params(ref: T.any(String, Pathname, Cask, URI::Generic), warn: T::Boolean)
// 117:                    .returns(T.nilable(T.attached_class))
// 118:       }
// 119:       def self.try_new(ref, warn: false)
// 120:         path = case ref
// 121:         when String
// 122:           Pathname(ref)
// 123:         when Pathname
// 124:           ref
// 125:         else
// 126:           return
// 127:         end
// 128:
// 129:         return unless path.expand_path.exist?
// 130:         return if invalid_path?(path)
// 131:         return unless ::Utils::Path.loadable_package_path?(path, :cask)
// 132:
// 133:         new(path)
// 134:       end
// 135:
// 136:       sig { params(pathname: Pathname, valid_extnames: T::Array[String]).returns(T::Boolean) }
// 137:       def self.invalid_path?(pathname, valid_extnames: %w[.rb .json])
// 138:         return true if valid_extnames.exclude?(pathname.extname)
// 139:
// 140:         @invalid_basenames ||= T.let(%w[INSTALL_RECEIPT.json sbom.spdx.json].freeze, T.nilable(T::Array[String]))
// 141:         @invalid_basenames.include?(pathname.basename.to_s)
// 142:       end
// 143:
// 144:       sig { returns(String) }
// 145:       attr_reader :token
// 146:
// 147:       sig { returns(Pathname) }
// 148:       attr_reader :path
// 149:
// 150:       sig { params(from_installed_caskfile: T::Boolean).void }
// 151:       attr_writer :from_installed_caskfile
// 152:
// 153:       sig { params(path: T.any(Pathname, String), token: String).void }
// 154:       def initialize(path, token: T.unsafe(nil))
// 155:         super()
// 156:
// 157:         path = Pathname(path).expand_path
// 158:
// 159:         @token = T.let(CaskLoader.token_from_path(path), String)
// 160:         @path = T.let(path, Pathname)
// 161:         @tap = T.let(Tap.from_path(path) || Homebrew::API.tap_from_source_download(path), T.nilable(Tap))
// 162:         @from_installed_caskfile = T.let(false, T::Boolean)
// 163:         @api_fallback = T.let(true, T::Boolean)
// 164:       end
// 165:
// 166:       sig { override.params(config: T.nilable(Config)).returns(Cask) }
// 167:       def load(config:)
// 168:         raise CaskUnavailableError.new(token, "'#{path}' does not exist.")  unless path.exist?
// 169:         raise CaskUnavailableError.new(token, "'#{path}' is not readable.") unless path.readable?
// 170:         raise CaskUnavailableError.new(token, "'#{path}' is not a file.")   unless path.file?
// 171:
// 172:         Homebrew::Trust.require_trusted_cask!(token, path)
// 173:
// 174:         @content = path.read(encoding: "UTF-8")
// 175:         @config = config
// 176:
// 177:         if !self.class.invalid_path?(path, valid_extnames: %w[.json]) &&
// 178:            (from_json = JSON.parse(@content)) &&
// 179:            from_json.is_a?(Hash) &&
// 180:            (@from_installed_caskfile || from_json.present?)
// 181:           begin
// 182:             from_internal_json = path.to_s.end_with?(".internal.json")
// 183:             return FromAPILoader.new(
// 184:               token,
// 185:               from_json:,
// 186:               path:,
// 187:               from_installed_caskfile: @from_installed_caskfile,
// 188:               from_internal_json:,
// 189:               api_fallback:            @api_fallback,
// 190:             ).load(config:)
// 191:           rescue CaskInvalidError => e
// 192:             if @from_installed_caskfile
// 193:               error = CaskUnreadableError.new(token, e.reason)
// 194:               error.set_backtrace e.backtrace
// 195:               raise error
// 196:             end
// 197:             raise
// 198:           end
// 199:         end
// 200:
// 201:         begin
// 202:           ENV.clear_sensitive_environment_for_eval! do
// 203:             instance_eval(content, path.to_s).tap do |cask|
// 204:               raise CaskUnreadableError.new(token, "'#{path}' does not contain a cask.") unless cask.is_a?(Cask)
// 205:             end
// 206:           end
// 207:         rescue NameError, ArgumentError, ScriptError => e
// 208:           error = CaskUnreadableError.new(token, e.message)
// 209:           error.set_backtrace e.backtrace
// 210:           raise error
// 211:         rescue CaskInvalidError => e # e.g. NoMethodError from removed DSL methods, wrapped
// 212:           # as CaskInvalidError by Cask#refresh before reaching here.
// 213:           if @from_installed_caskfile
// 214:             error = CaskUnreadableError.new(token, e.reason)
// 215:             error.set_backtrace e.backtrace
// 216:             raise error
// 217:           end
// 218:           raise
// 219:         end
// 220:       end
// 221:
// 222:       private
// 223:
// 224:       sig {
// 225:         override.params(
// 226:           header_token: String,
// 227:           options:      T.untyped,
// 228:           block:        T.nilable(T.proc.bind(DSL).void),
// 229:         ).returns(Cask)
// 230:       }
// 231:       def cask(header_token, **options, &block)
// 232:         raise CaskTokenMismatchError.new(token, header_token) if token != header_token
// 233:
// 234:         super(header_token, **options, sourcefile_path: path, &block)
// 235:       end
// 236:     end
// 237:
// 238:     # Loads a cask from a URI.
// 239:     class FromURILoader < FromPathLoader
// 240:       sig {
// 241:         override.params(ref: T.any(String, Pathname, Cask, URI::Generic), warn: T::Boolean)
// 242:                 .returns(T.nilable(T.attached_class))
// 243:       }
// 244:       def self.try_new(ref, warn: false)
// 245:         return if Homebrew::EnvConfig.forbid_packages_from_paths?
// 246:
// 247:         # Cache compiled regex
// 248:         @uri_regex ||= T.let(
// 249:           begin
// 250:             uri_regex = ::URI::RFC2396_PARSER.make_regexp
// 251:             Regexp.new("\\A#{uri_regex.source}\\Z", uri_regex.options)
// 252:           end,
// 253:           T.nilable(Regexp),
// 254:         )
// 255:
// 256:         uri = ref.to_s
// 257:         return unless uri.match?(@uri_regex)
// 258:
// 259:         uri = URI(uri)
// 260:         return unless uri.path
// 261:
// 262:         new(uri)
// 263:       end
// 264:
// 265:       sig { returns(URI::Generic) }
// 266:       attr_reader :url
// 267:
// 268:       sig { returns(String) }
// 269:       attr_reader :name
// 270:
// 271:       sig { params(url: T.any(URI::Generic, String)).void }
// 272:       def initialize(url)
// 273:         @url = T.let(URI(url), URI::Generic)
// 274:         url_path = @url.path
// 275:         raise "unexpected nil url.path" unless url_path
// 276:
// 277:         @name = T.let(File.basename(url_path), String)
// 278:         super Cache.path/name
// 279:       end
// 280:
// 281:       sig { override.params(config: T.nilable(Config)).returns(Cask) }
// 282:       def load(config:)
// 283:         path.dirname.mkpath
// 284:
// 285:         if ALLOWED_URL_SCHEMES.exclude?(url.scheme)
// 286:           raise UnsupportedInstallationMethod,
// 287:                 "Non-checksummed download of #{name} formula file from an arbitrary URL is unsupported! " \
// 288:                 "`brew version-install` to install a formula file from your own custom tap " \
// 289:                 "instead."
// 290:         end
// 291:
// 292:         begin
// 293:           ohai "Downloading #{url}"
// 294:           ::Utils::Curl.curl_download url.to_s, to: path
// 295:         rescue ErrorDuringExecution
// 296:           raise CaskUnavailableError.new(token, "Failed to download #{Formatter.url(url)}.")
// 297:         end
// 298:
// 299:         super
// 300:       end
// 301:     end
// 302:
// 303:     # Loads a cask from a specific tap.
// 304:     class FromTapLoader < FromPathLoader
// 305:       sig { override.returns(Tap) }
// 306:       attr_reader :tap
// 307:
// 308:       sig {
// 309:         override(allow_incompatible: true) # rubocop:todo Sorbet/AllowIncompatibleOverride
// 310:           .params(ref: T.any(String, Pathname, Cask, URI::Generic), warn: T::Boolean)
// 311:           .returns(T.nilable(T.any(T.attached_class, FromAPILoader)))
// 312:       }
// 313:       def self.try_new(ref, warn: false)
// 314:         ref = ref.to_s
// 315:
// 316:         return unless (token_tap_type = CaskLoader.tap_cask_token_type(ref, warn:))
// 317:
// 318:         loader_from_token_tap_type(token_tap_type)
// 319:       end
// 320:
// 321:       sig {
// 322:         params(token_tap_type: [String, Tap, T.nilable(Symbol)])
// 323:           .returns(T.nilable(T.any(T.attached_class, FromAPILoader)))
// 324:       }
// 325:       def self.loader_from_token_tap_type(token_tap_type)
// 326:         token, tap, type = token_tap_type
// 327:
// 328:         if type == :migration && tap.core_cask_tap? && (loader = FromAPILoader.try_new(token))
// 329:           loader
// 330:         else
// 331:           new("#{tap}/#{token}")
// 332:         end
// 333:       end
// 334:
// 335:       sig { params(tapped_token: String).void }
// 336:       def initialize(tapped_token)
// 337:         tap_with_token = Tap.with_cask_token(tapped_token)
// 338:         raise "unexpected nil Tap.with_cask_token" unless tap_with_token
// 339:
// 340:         tap, token = tap_with_token
// 341:         cask = CaskLoader.find_cask_in_tap(token, tap)
// 342:         super cask
// 343:         @tap = T.let(tap, Tap)
// 344:       end
// 345:
// 346:       sig { override.params(config: T.nilable(Config)).returns(Cask) }
// 347:       def load(config:)
// 348:         raise TapCaskUnavailableError.new(tap, token) unless tap.installed?
// 349:
// 350:         super
// 351:       end
// 352:     end
// 353:
// 354:     # Loads a cask from an existing {Cask} instance.
// 355:     class FromInstanceLoader
// 356:       include ILoader
// 357:
// 358:       sig {
// 359:         params(ref: T.any(String, Pathname, Cask, URI::Generic), warn: T::Boolean)
// 360:           .returns(T.nilable(FromInstanceLoader))
// 361:       }
// 362:       def self.try_new(ref, warn: false)
// 363:         new(ref) if ref.is_a?(Cask)
// 364:       end
// 365:
// 366:       sig { params(cask: Cask).void }
// 367:       def initialize(cask)
// 368:         @cask = cask
// 369:       end
// 370:
// 371:       # This is a false positive incompatibililty warning, due to Kernel#load being overridden.
// 372:       sig { override(allow_incompatible: true).params(config: T.nilable(Config)).returns(Cask) } # rubocop:disable Sorbet/AllowIncompatibleOverride
// 373:       def load(config:)
// 374:         @cask
// 375:       end
// 376:     end
// 377:
// 378:     # Loads a cask from the JSON API.
// 379:     class FromAPILoader
// 380:       include ILoader
// 381:
// 382:       sig { returns(String) }
// 383:       attr_reader :token
// 384:
// 385:       sig { returns(Pathname) }
// 386:       attr_reader :path
// 387:
// 388:       sig { returns(T.nilable(T::Hash[String, T.untyped])) }
// 389:       attr_reader :from_json
// 390:
// 391:       sig {
// 392:         params(ref: T.any(String, Pathname, Cask, URI::Generic), warn: T::Boolean)
// 393:           .returns(T.nilable(FromAPILoader))
// 394:       }
// 395:       def self.try_new(ref, warn: false)
// 396:         return if Homebrew::EnvConfig.no_install_from_api?
// 397:         return unless ref.is_a?(String)
// 398:         return unless (token = ref[HOMEBREW_DEFAULT_TAP_CASK_REGEX, :token])
// 399:         if !Homebrew::API.cask_token?(token) &&
// 400:            !Homebrew::API.cask_renames.key?(token)
// 401:           return
// 402:         end
// 403:
// 404:         ref = "#{CoreCaskTap.instance}/#{token}"
// 405:
// 406:         token, tap, = CaskLoader.tap_cask_token_type(ref, warn:)
// 407:         new("#{tap}/#{token}")
// 408:       end
// 409:
// 410:       sig {
// 411:         params(
// 412:           token:                   String,
// 413:           from_json:               T.nilable(T::Hash[String, T.untyped]),
// 414:           path:                    T.nilable(Pathname),
// 415:           from_installed_caskfile: T::Boolean,
// 416:           from_internal_json:      T::Boolean,
// 417:           api_fallback:            T::Boolean,
// 418:         ).void
// 419:       }
// 420:       def initialize(token, from_json: T.unsafe(nil), path: nil, from_installed_caskfile: false,
// 421:                      from_internal_json: false, api_fallback: true)
// 422:         @token = T.let(token.sub(%r{^homebrew/(?:homebrew-)?cask/}i, ""), String)
// 423:         @sourcefile_path = T.let(
// 424:           if path
// 425:             path
// 426:           elsif from_json
// 427:             from_internal_json ? Homebrew::API::Internal.cached_packages_json_file_path : Homebrew::API::Cask.cached_json_file_path
// 428:           else
// 429:             Homebrew::API.cached_cask_json_file_path
// 430:           end,
// 431:           Pathname,
// 432:         )
// 433:         @path = T.let(path || CaskLoader.default_path(@token), Pathname)
// 434:         @from_json = from_json
// 435:         @from_installed_caskfile = from_installed_caskfile
// 436:         @from_internal_json = from_internal_json
// 437:         @api_fallback = api_fallback
// 438:       end
// 439:
// 440:       # This is a false positive incompatibililty warning, due to Kernel#load being overridden.
// 441:       sig { override(allow_incompatible: true).params(config: T.nilable(Config)).returns(Cask) } # rubocop:disable Sorbet/AllowIncompatibleOverride
// 442:       def load(config:)
// 443:         if (api_source = from_json)
// 444:           if @from_internal_json
// 445:             load_from_internal_json(config:, api_source:)
// 446:           else
// 447:             load_from_json(config:, api_source:)
// 448:           end
// 449:         else
// 450:           load_from_internal_api(config:)
// 451:         end
// 452:       end
// 453:
// 454:       private
// 455:
// 456:       sig { params(config: T.nilable(Config)).returns(Cask) }
// 457:       def load_from_internal_api(config:)
// 458:         cask_struct = Homebrew::API::Internal.cask_struct(token)
// 459:         api_source = Homebrew::API::Internal.cask_hash(token)
// 460:         raise KeyError, "key not found: #{token.inspect}" if api_source.nil?
// 461:
// 462:         tap_git_head = Homebrew::API::Internal.cask_tap_git_head
// 463:
// 464:         load_from_struct(config:, cask_struct:, api_source:, tap_git_head:, internal_api: true)
// 465:       end
// 466:
// 467:       sig { params(config: T.nilable(Config), api_source: T::Hash[String, T.untyped]).returns(Cask) }
// 468:       def load_from_json(config:, api_source:)
// 469:         if @from_installed_caskfile
// 470:           api_source = api_source.dup
// 471:           api_source["version"] = api_source["version"].presence
// 472:           api_source["version"] ||= @sourcefile_path.dirname.dirname.dirname.basename.to_s.presence
// 473:           if api_source["version"].nil? || api_source["artifacts"].nil?
// 474:             installed_tab = CaskLoader.load_installed_tab(token)
// 475:             api_source["version"] ||= installed_tab.version.presence
// 476:             api_source["artifacts"] ||= CaskLoader.resolve_installed_artifacts(
// 477:               token, installed_tab.uninstall_artifacts, tap: installed_tab.tap, api_fallback: @api_fallback
// 478:             )
// 479:           end
// 480:         end
// 481:
// 482:         tap_git_head = api_source["tap_git_head"]
// 483:         cask_struct = Homebrew::API::Cask::CaskStructGenerator.generate_cask_struct_hash(
// 484:           api_source, ignore_types: @from_installed_caskfile
// 485:         )
// 486:
// 487:         load_from_struct(config:, cask_struct:, api_source:, tap_git_head:)
// 488:       end
// 489:
// 490:       sig { params(config: T.nilable(Config), api_source: T::Hash[String, T.untyped]).returns(Cask) }
// 491:       def load_from_internal_json(config:, api_source:)
// 492:         api_source = api_source.dup
// 493:         tap_git_head = api_source.delete("tap_git_head")
// 494:         cask_struct = Homebrew::API::CaskStruct.deserialize(api_source)
// 495:
// 496:         load_from_struct(config:, cask_struct:, api_source:, tap_git_head:, internal_api: true)
// 497:       end
// 498:
// 499:       sig {
// 500:         params(
// 501:           config:       T.nilable(Config),
// 502:           cask_struct:  Homebrew::API::CaskStruct,
// 503:           api_source:   T::Hash[String, T.untyped],
// 504:           tap_git_head: T.nilable(String),
// 505:           internal_api: T::Boolean,
// 506:         ).returns(Cask)
// 507:       }
// 508:       def load_from_struct(config:, cask_struct:, api_source:, tap_git_head:, internal_api: false)
// 509:         cask_options = {
// 510:           loaded_from_api:          true,
// 511:           loaded_from_internal_api: internal_api,
// 512:           api_source:,
// 513:           sourcefile_path:          @sourcefile_path,
// 514:           source:                   JSON.pretty_generate(api_source),
// 515:           config:,
// 516:           loader:                   self,
// 517:         }
// 518:
// 519:         if (tap_string = cask_struct.tap_string)
// 520:           cask_options[:tap] = Tap.fetch(tap_string)
// 521:         end
// 522:
// 523:         api_cask = Cask.new(token, **cask_options) do
// 524:           localised_cask_struct = if cask_struct.language_variations.empty?
// 525:             cask_struct
// 526:           else
// 527:             cask_struct.localise(cask.config.languages)
// 528:           end
// 529:
// 530:           version localised_cask_struct.version
// 531:           sha256 localised_cask_struct.sha256
// 532:
// 533:           url(*localised_cask_struct.url_args, **localised_cask_struct.url_kwargs)
// 534:           localised_cask_struct.names.each do |cask_name|
// 535:             name cask_name
// 536:           end
// 537:           desc localised_cask_struct.desc if localised_cask_struct.desc?
// 538:           homepage localised_cask_struct.homepage if localised_cask_struct.homepage?
// 539:
// 540:           deprecate!(**localised_cask_struct.deprecate_args) if localised_cask_struct.deprecate?
// 541:           disable!(**localised_cask_struct.disable_args) if localised_cask_struct.disable?
// 542:
// 543:           auto_updates localised_cask_struct.auto_updates if localised_cask_struct.auto_updates?
// 544:           conflicts_with(**localised_cask_struct.conflicts_with_args) if localised_cask_struct.conflicts?
// 545:
// 546:           localised_cask_struct.renames.each do |from, to|
// 547:             rename from, to
// 548:           end
// 549:
// 550:           if localised_cask_struct.depends_on?
// 551:             args = localised_cask_struct.depends_on_args
// 552:             begin
// 553:               depends_on(**args)
// 554:             rescue MacOSVersion::Error => e
// 555:               odebug "Ignored invalid macOS version dependency in cask '#{token}': #{args.inspect} (#{e.message})"
// 556:               nil
// 557:             end
// 558:           end
// 559:
// 560:           if localised_cask_struct.container?
// 561:             container(nested: localised_cask_struct.container_args[:nested],
// 562:                       type:   localised_cask_struct.container_args[:type])
// 563:           end
// 564:
// 565:           localised_cask_struct.artifacts(appdir:).each do |key, args, kwargs, block|
// 566:             send(key, *args, **kwargs, &block)
// 567:           end
// 568:
// 569:           caveats T.must(localised_cask_struct.caveats(appdir:)) if localised_cask_struct.caveats?
// 570:
// 571:           if localised_cask_struct.caveats_rosetta
// 572:             caveats do
// 573:               # Dynamically defined via `caveat :requires_rosetta` — Sorbet can't resolve it.
// 574:               T.unsafe(self).requires_rosetta
// 575:             end
// 576:           end
// 577:         end
// 578:         api_cask.populate_from_api!(cask_struct, tap_git_head:)
// 579:         api_cask
// 580:       end
// 581:     end
// 582:
// 583:     # Loader which tries loading casks from tap paths, failing
// 584:     # if the same token exists in multiple taps.
// 585:     class FromNameLoader < FromTapLoader
// 586:       extend ::Utils::Output::Mixin
// 587:
// 588:       sig {
// 589:         override.params(ref: T.any(String, Pathname, Cask, URI::Generic), warn: T::Boolean)
// 590:                 .returns(T.nilable(T.any(T.attached_class, FromAPILoader)))
// 591:       }
// 592:       def self.try_new(ref, warn: false)
// 593:         return unless ref.is_a?(String)
// 594:         return unless ref.match?(/\A#{HOMEBREW_TAP_CASK_TOKEN_REGEX}\Z/o)
// 595:
// 596:         token = ref.downcase
// 597:
// 598:         # If it exists in the default tap, never treat it as ambiguous with another tap.
// 599:         if (core_cask_tap = CoreCaskTap.instance).installed? && (token_tap_type = CaskLoader.tap_cask_token_type(
// 600:           "#{core_cask_tap}/#{token}", warn: false
// 601:         ))
// 602:           migrated_token, migrated_tap, type = token_tap_type
// 603:
// 604:           if warn && [:rename, :migration].include?(type) &&
// 605:              !(type == :migration && migrated_tap.core_tap?)
// 606:             opoo "Cask #{token} was renamed to " \
// 607:                  "#{migrated_tap.core_cask_tap? ? migrated_token : "#{migrated_tap}/#{migrated_token}"}."
// 608:           end
// 609:
// 610:           if (core_cask_loader = loader_from_token_tap_type(token_tap_type))&.path&.exist?
// 611:             return core_cask_loader
// 612:           end
// 613:         end
// 614:
// 615:         loaders = Tap.select { |tap| tap.installed? && !tap.core_cask_tap? }
// 616:                      .filter_map { |tap| super("#{tap}/#{token}", warn:) }
// 617:                      .uniq(&:path)
// 618:                      .select { |loader| loader.is_a?(FromAPILoader) || loader.path.exist? }
// 619:
// 620:         case loaders.count
// 621:         when 1
// 622:           loaders.first
// 623:         when 2..Float::INFINITY
// 624:           raise TapCaskAmbiguityError.new(token, loaders)
// 625:         end
// 626:       end
// 627:     end
// 628:
// 629:     # Loader which loads a cask from the installed cask file.
// 630:     class FromInstalledPathLoader < FromPathLoader
// 631:       sig {
// 632:         override.params(ref: T.any(String, Pathname, Cask, URI::Generic), warn: T::Boolean,
// 633:                         api_fallback: T::Boolean).returns(T.nilable(T.attached_class))
// 634:       }
// 635:       def self.try_new(ref, warn: false, api_fallback: true)
// 636:         token = if ref.is_a?(String)
// 637:           ref
// 638:         elsif ref.is_a?(Pathname)
// 639:           CaskLoader.token_from_path(ref)
// 640:         end
// 641:         return unless token
// 642:
// 643:         possible_installed_cask = Cask.new(token)
// 644:         return unless (installed_caskfile = possible_installed_cask.installed_caskfile)
// 645:
// 646:         new(installed_caskfile, api_fallback:)
// 647:       end
// 648:
// 649:       sig { params(path: T.any(Pathname, String), token: String, api_fallback: T::Boolean).void }
// 650:       def initialize(path, token: "", api_fallback: true)
// 651:         super(path, token:)
// 652:
// 653:         installed_tap = Cask.new(@token).tab.tap
// 654:         @tap = installed_tap if installed_tap
// 655:         @from_installed_caskfile = T.let(true, T::Boolean)
// 656:         @api_fallback = api_fallback
// 657:       end
// 658:     end
// 659:
// 660:     # Pseudo-loader which raises an error when trying to load the corresponding cask.
// 661:     class NullLoader < FromPathLoader
// 662:       sig {
// 663:         override.params(ref: T.any(String, Pathname, Cask, URI::Generic), warn: T::Boolean)
// 664:                 .returns(T.nilable(T.attached_class))
// 665:       }
// 666:       def self.try_new(ref, warn: false)
// 667:         return if ref.is_a?(Cask)
// 668:         return if ref.is_a?(URI::Generic)
// 669:
// 670:         new(ref)
// 671:       end
// 672:
// 673:       sig { params(ref: T.any(String, Pathname)).void }
// 674:       def initialize(ref)
// 675:         token = File.basename(ref, ".rb")
// 676:         super CaskLoader.default_path(token)
// 677:       end
// 678:
// 679:       sig { override.params(config: T.nilable(Config)).returns(Cask) }
// 680:       def load(config:)
// 681:         raise CaskUnavailableError.new(token, "No Cask with this name exists.")
// 682:       end
// 683:     end
// 684:
// 685:     # NOTE: Using `WithoutRuntime` to avoid Sorbet wrapping this method,
// 686:     # which would interfere with RSpec mocking of this class method.
// 687:     T::Sig::WithoutRuntime.sig { params(ref: T.any(String, Pathname, Cask, URI::Generic)).returns(Pathname) }
// 688:     def self.path(ref)
// 689:       T.cast(self.for(ref, need_path: true), T.any(FromAPILoader, FromPathLoader)).path
// 690:     end
// 691:
// 692:     # NOTE: Using `WithoutRuntime` to avoid Sorbet wrapping this method,
// 693:     # which would interfere with RSpec mocking of this class method.
// 694:     T::Sig::WithoutRuntime.sig {
// 695:       params(ref: T.any(String, Symbol, Pathname, Cask, URI::Generic), config: T.nilable(Config),
// 696:              warn: T::Boolean).returns(Cask)
// 697:     }
// 698:     def self.load(ref, config: nil, warn: true)
// 699:       normalized_ref = ref.is_a?(Symbol) ? ref.to_s : ref
// 700:       self.for(normalized_ref, warn:).load(config:)
// 701:     end
// 702:
// 703:     sig { params(tapped_token: String, warn: T::Boolean).returns(T.nilable([String, Tap, T.nilable(Symbol)])) }
// 704:     def self.tap_cask_token_type(tapped_token, warn:)
// 705:       return unless (tap_with_token = Tap.with_cask_token(tapped_token))
// 706:
// 707:       tap, token = tap_with_token
// 708:
// 709:       type = nil
// 710:
// 711:       if (new_token = tap.cask_renames[token].presence)
// 712:         old_token = tap.core_cask_tap? ? token : tapped_token
// 713:         token = new_token
// 714:         new_token = tap.core_cask_tap? ? token : "#{tap}/#{token}"
// 715:         type = :rename
// 716:       elsif (new_tap_name = tap.tap_migrations[token].presence)
// 717:         new_tap, new_token = Tap.with_cask_token(new_tap_name)
// 718:         unless new_tap
// 719:           if new_tap_name.include?("/")
// 720:             new_tap = Tap.fetch(new_tap_name)
// 721:             new_token = token
// 722:           else
// 723:             new_tap = tap
// 724:             new_token = new_tap_name
// 725:           end
// 726:         end
// 727:         new_tapped_token = "#{new_tap}/#{new_token}"
// 728:
// 729:         if tapped_token != new_tapped_token
// 730:           old_token = tap.core_cask_tap? ? token : tapped_token
// 731:           return unless (token_tap_type = tap_cask_token_type(new_tapped_token, warn: false))
// 732:
// 733:           token, tap, = token_tap_type
// 734:           new_token = new_tap.core_cask_tap? ? token : "#{tap}/#{token}"
// 735:           type = :migration
// 736:         end
// 737:       end
// 738:
// 739:       if warn && old_token && new_token
// 740:         destination_exists = find_cask_in_tap(token, tap).exist? ||
// 741:                              (tap.core_cask_tap? && !Homebrew::EnvConfig.no_install_from_api? &&
// 742:                               Homebrew::API.cask_token?(token))
// 743:         opoo "Cask #{old_token} was renamed to #{new_token}." if destination_exists
// 744:       end
// 745:
// 746:       [token, tap, type]
// 747:     end
// 748:
// 749:     # NOTE: Using `WithoutRuntime` to avoid Sorbet wrapping this method,
// 750:     # which would interfere with RSpec mocking of this class method.
// 751:     T::Sig::WithoutRuntime.sig {
// 752:       params(ref: T.any(String, Pathname, Cask, URI::Generic), need_path: T::Boolean, warn: T::Boolean)
// 753:         .returns(ILoader)
// 754:     }
// 755:     def self.for(ref, need_path: false, warn: true)
// 756:       [
// 757:         FromInstanceLoader,
// 758:         FromContentLoader,
// 759:         FromURILoader,
// 760:         FromAPILoader,
// 761:         FromTapLoader,
// 762:         FromNameLoader,
// 763:         FromPathLoader,
// 764:         FromInstalledPathLoader,
// 765:         NullLoader,
// 766:       ].each do |loader_class|
// 767:         if (loader = loader_class.try_new(ref, warn:))
// 768:           $stderr.puts "#{$PROGRAM_NAME} (#{loader.class}): loading #{ref}" if verbose? && debug?
// 769:           return loader
// 770:         end
// 771:       end
// 772:
// 773:       raise CaskError, "No cask loader found for #{ref.inspect}"
// 774:     end
// 775:
// 776:     sig { params(ref: String, config: T.nilable(Config), warn: T::Boolean).returns(Cask) }
// 777:     def self.load_prefer_installed(ref, config: nil, warn: true)
// 778:       tap, token = Tap.with_cask_token(ref)
// 779:       token ||= ref
// 780:       tap ||= Cask.new(ref).tab.tap
// 781:
// 782:       if tap.nil?
// 783:         self.load(token, config:, warn:)
// 784:       else
// 785:         begin
// 786:           self.load("#{tap}/#{token}", config:, warn:)
// 787:         rescue CaskUnavailableError
// 788:           # cask may be migrated to different tap. Try to search in all taps.
// 789:           self.load(token, config:, warn:)
// 790:         end
// 791:       end
// 792:     end
// 793:
// 794:     sig {
// 795:       params(path: Pathname, config: T.nilable(Config), warn: T::Boolean, api_fallback: T::Boolean)
// 796:         .returns(Cask)
// 797:     }
// 798:     def self.load_from_installed_caskfile(path, config: nil, warn: true, api_fallback: true)
// 799:       loader = FromInstalledPathLoader.try_new(path, warn:, api_fallback:)
// 800:       loader ||= NullLoader.new(path)
// 801:
// 802:       loader.load(config:)
// 803:     end
// 804:
// 805:     sig { params(path: Pathname).returns(String) }
// 806:     def self.token_from_path(path)
// 807:       path.basename(path.extname).basename(".internal").to_s
// 808:     end
// 809:
// 810:     # Legacy `.internal.json` files contain full API data rather than the compact installed JSON format.
// 811:     sig { params(path: Pathname).returns(T::Boolean) }
// 812:     def self.installed_json_caskfile?(path)
// 813:       path.extname == ".json" && !path.basename.to_s.end_with?(".internal.json")
// 814:     end
// 815:
// 816:     sig { params(path: Pathname).returns(T.nilable(T::Hash[String, T.untyped])) }
// 817:     def self.load_installed_json(path)
// 818:       return unless installed_json_caskfile?(path)
// 819:
// 820:       json = JSON.parse(path.read)
// 821:       json if json.is_a?(Hash)
// 822:     rescue JSON::ParserError
// 823:       nil
// 824:     end
// 825:
// 826:     sig { params(cask_or_token: T.any(Cask, String)).returns(Tab) }
// 827:     def self.load_installed_tab(cask_or_token)
// 828:       cask = if cask_or_token.is_a?(Cask)
// 829:         cask_or_token
// 830:       else
// 831:         Cask.new(cask_or_token)
// 832:       end
// 833:       cask.tab
// 834:     rescue JSON::ParserError, NoMethodError, TypeError
// 835:       Tab.empty
// 836:     end
// 837:
// 838:     sig {
// 839:       params(
// 840:         token:        String,
// 841:         artifacts:    T.nilable(T::Array[T::Hash[T.any(String, Symbol), T.anything]]),
// 842:         tap:          T.nilable(Tap),
// 843:         api_fallback: T::Boolean,
// 844:       ).returns(T::Array[T::Hash[T.any(String, Symbol), T.anything]])
// 845:     }
// 846:     def self.resolve_installed_artifacts(token, artifacts, tap: nil, api_fallback: true)
// 847:       artifacts = artifacts.presence
// 848:       return artifacts if artifacts
// 849:       return [] unless api_fallback
// 850:
// 851:       artifacts ||= begin
// 852:         tap_loader = (FromNameLoader.try_new(token, warn: false) if tap.nil? && FromAPILoader.try_new(token).nil?)
// 853:
// 854:         if tap && !tap.core_cask_tap?
// 855:           load("#{tap}/#{token}", warn: false).artifacts_list(uninstall_only: true)
// 856:         elsif tap_loader
// 857:           tap_loader.load(config: nil).artifacts_list(uninstall_only: true)
// 858:         end
// 859:       rescue CaskError, MethodDeprecatedError, JSON::ParserError, ErrorDuringExecution, SystemExit
// 860:         nil
// 861:       end
// 862:
// 863:       # API fetch failures must not abort best-effort installed metadata recovery. Skip the
// 864:       # per-cask endpoint only when the token is definitively absent from the current API;
// 865:       # a membership-check failure is treated as unknown so recovery still tries the endpoint.
// 866:       artifacts ||= begin
// 867:         definitely_absent = begin
// 868:           !Homebrew::API.cask_token?(token)
// 869:         rescue ErrorDuringExecution, SystemExit
// 870:           false
// 871:         end
// 872:         Homebrew::API::Cask.cask_json(token)["artifacts"] unless definitely_absent
// 873:       rescue ErrorDuringExecution, SystemExit
// 874:         nil
// 875:       end
// 876:       artifacts ||= []
// 877:       artifacts
// 878:     end
// 879:
// 880:     sig {
// 881:       params(
// 882:         path:          Pathname,
// 883:         tab:           T.nilable(Tab),
// 884:         fallback_cask: T.nilable(Cask),
// 885:         config:        T.nilable(Config),
// 886:       ).returns(T.nilable(Cask))
// 887:     }
// 888:     def self.recover_from_installed_caskfile(path, tab: nil, fallback_cask: nil, config: nil)
// 889:       # Only installed metadata has the versioned path layout used to rebuild the cask below.
// 890:       return if path.dirname.basename.to_s != "Casks"
// 891:
// 892:       # Read any usable receipt, while retaining the current cask as a fallback for missing receipt data.
// 893:       token = token_from_path(path)
// 894:       tab ||= load_installed_tab(fallback_cask || token)
// 895:
// 896:       # Ruby uninstall flight blocks cannot be represented by installed JSON and must not be approximated.
// 897:       return if tab.uninstall_flight_blocks
// 898:       return if fallback_cask&.uninstall_flight_blocks?
// 899:
// 900:       # Prefer exact receipt artifacts, then the current cask and finally the current source definition.
// 901:       artifacts = tab.uninstall_artifacts.presence
// 902:       artifacts ||= fallback_cask.artifacts_list(uninstall_only: true) if fallback_cask
// 903:       artifacts ||= resolve_installed_artifacts(token, nil, tap: tab.tap)
// 904:
// 905:       # Rebuild the installed version from its metadata directory and retain current source path information.
// 906:       api_source = {
// 907:         "version"   => path.dirname.dirname.dirname.basename.to_s,
// 908:         "artifacts" => artifacts,
// 909:       }
// 910:       api_source["url_specs"] ||= fallback_cask.to_installed_json_hash["url_specs"] if fallback_cask
// 911:
// 912:       # Prefer the installed JSON's source path because it belongs to the installed version.
// 913:       if (source_json = load_installed_json(path))
// 914:         source_url_specs = source_json["url_specs"]
// 915:         api_source["url_specs"] = source_url_specs if source_url_specs.is_a?(Hash)
// 916:       end
// 917:
// 918:       # Load through the installed-JSON path so reconstructed artifacts have normal installed paths and behaviour.
// 919:       recovered_cask = FromAPILoader.new(
// 920:         token,
// 921:         from_json:               api_source,
// 922:         path:,
// 923:         from_installed_caskfile: true,
// 924:       ).load(config:)
// 925:       recovered_cask unless recovered_cask.uninstall_flight_blocks?
// 926:     rescue CaskInvalidError, CaskUnavailableError, MethodDeprecatedError, JSON::ParserError
// 927:       # Recovery is best effort; callers treat nil as an unavailable installed cask and use their existing fallback.
// 928:       nil
// 929:     end
// 930:
// 931:     sig { params(token: T.any(String, Symbol)).returns(Pathname) }
// 932:     def self.default_path(token)
// 933:       find_cask_in_tap(token.to_s.downcase, CoreCaskTap.instance)
// 934:     end
// 935:
// 936:     sig { params(token: String, tap: Tap).returns(Pathname) }
// 937:     def self.find_cask_in_tap(token, tap)
// 938:       filename = "#{token}.rb"
// 939:
// 940:       tap.cask_files_by_name.fetch(token, tap.cask_dir/filename)
// 941:     end
// 942:   end
// 943: end
