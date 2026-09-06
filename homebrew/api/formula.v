module api

import ruby
import net.http
import os
import time
import x.json2

// Translated from Homebrew/brew `api/formula.rb`.
pub enum PackageKind {
	formula
	cask
	keg
	unavailable
}

pub struct PackageReference {
pub:
	kind                     PackageKind
	name                     string
	full_name                string
	tap                      string
	alias_name               string
	description              string
	license                  string
	homepage                 string
	stable_version           string
	head_version             string
	source_url               string
	source_checksum          string
	revision                 int
	version_scheme           int
	bottle_available         bool
	bottle_tags              []string
	bottle_files             map[string]FormulaApiBottleFile
	bottle_rebuild           int
	dependencies             []string
	build_dependencies       []string
	test_dependencies        []string
	recommended_dependencies []string
	optional_dependencies    []string
	oldnames                 []string
	aliases                  []string
	versioned_formulae       []string
	tap_git_head             string
	ruby_source_path         string
	ruby_source_checksum     string
	keg_only                 bool
	deprecated               bool
	deprecation_reason       string
	disabled                 bool
	disable_reason           string
	loaded_from_api          bool
	local_path               string
	core_tap                 bool
	core_cask_tap            bool
	tap_installed            bool
	error_message            string
}

pub struct FormulaLookupConfig {
pub:
	api_base_url         string
	cache_directory      string
	without_api          bool
	formula_json_by_name map[string]string
	aliases              map[string]string
}

pub struct FormulaApiVersions {
pub:
	stable string
	head   string
	bottle bool
}

pub struct FormulaApiStableUrl {
pub:
	url      string
	checksum string
}

pub struct FormulaApiUrls {
pub:
	stable FormulaApiStableUrl
}

pub struct FormulaApiSourceChecksum {
pub:
	sha256 string
}

pub struct FormulaApiBottleFile {
pub:
	cellar string
	url    string
	sha256 string
}

pub struct FormulaApiBottleStable {
pub:
	rebuild int
	files   map[string]FormulaApiBottleFile
}

pub struct FormulaApiBottle {
pub:
	stable FormulaApiBottleStable
}

pub struct FormulaApiDocument {
pub:
	name                     string
	full_name                string
	tap                      string
	oldnames                 []string
	aliases                  []string
	versioned_formulae       []string
	desc                     string
	license                  string
	homepage                 string
	versions                 FormulaApiVersions
	urls                     FormulaApiUrls
	bottle                   FormulaApiBottle
	revision                 int
	version_scheme           int
	build_dependencies       []string
	dependencies             []string
	test_dependencies        []string
	recommended_dependencies []string
	optional_dependencies    []string
	tap_git_head             string
	ruby_source_path         string
	ruby_source_checksum     FormulaApiSourceChecksum
	keg_only                 bool
	deprecated               bool
	deprecation_reason       ?string
	disabled                 bool
	disable_reason           ?string
}

pub struct FormulaApiAliasDocument {
pub:
	name     string
	oldnames []string
	aliases  []string
}

const formula_default_api_filename = 'formula.jws.json'

pub struct FormulaApiFetchResult {
pub:
	data    ruby.Value
	updated bool
}

pub struct FormulaSource {
pub:
	name                 string
	full_name            string
	ruby_source_path     string
	ruby_source_checksum string
	tap_git_head         string
	tap_full_name        string
	active_spec          string
	alias_path           string
	build_flags          []string
}

pub struct LoadedFormulaSource {
pub:
	name          string
	full_name     string
	path          string
	contents      string
	active_spec   string
	alias_path    string
	build_flags   []string
	local_patches map[string]string
}

@[heap]
pub struct FormulaApiState {
pub mut:
	cache_directory         string
	source_cache_directory  string
	fetch_results           map[string]FormulaApiFetchResult
	formula_json_cache      map[string]map[string]ruby.Value
	formulae                map[string]map[string]ruby.Value
	formulae_loaded         bool
	aliases                 map[string]string
	renames                 map[string]string
	tap_migrations          map[string]ruby.Value
	tap_migrations_loaded   bool
	fetched_endpoints       []string
	last_stale_seconds      ?i64
	last_fetch_enqueued     bool
	queued_downloads        []SourceDownload
	fetched_downloads       []SourceDownload
	written_names           []string
	written_aliases         map[string]string
	names_regenerated       bool
	aliases_regenerated     bool
	executables_regenerated bool
	names_file              string
	aliases_file            string
	executables_file        string
}

pub fn new_formula_api_state(cache_directory string, source_cache_directory string) FormulaApiState {
	return FormulaApiState{
		cache_directory: cache_directory
		source_cache_directory: source_cache_directory
	}
}

fn formula_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn formula_value_strings(value ruby.Value) []string {
	if value.string_array_data.len > 0 {
		return value.string_array_data.clone()
	}
	return value.array_data.map(it.as_string())
}

fn formula_fetch_json_api_file(mut state FormulaApiState, endpoint string, stale_seconds ?i64,
	enqueue bool) !FormulaApiFetchResult {
	state.fetched_endpoints << endpoint
	state.last_stale_seconds = stale_seconds
	state.last_fetch_enqueued = enqueue
	if result := state.fetch_results[endpoint] {
		return result
	}
	path := os.join_path(state.cache_directory, endpoint)
	if !os.is_file(path) {
		return error('No cached or injected API response for ${endpoint}')
	}
	return FormulaApiFetchResult{
		data: ruby.parse_json_value(os.read_file(path)!)!
	}
}

pub fn formula_fetch_formula_json(mut state FormulaApiState, name string) ! {
	endpoint := 'formula/${name}.json'
	result := formula_fetch_json_api_file(mut state, endpoint, none, false)!
	mut json_formula := result.data
	if !result.updated {
		json_formula = ruby.parse_json_value(os.read_file(os.join_path(state.cache_directory, endpoint))!)!
	}
	if json_formula.type_name != 'Hash' {
		return error('${endpoint} did not contain a formula JSON object')
	}
	state.formula_json_cache[name] = json_formula.map_data.clone()
}

fn valid_formula_source_path(path string) bool {
	if path.trim_space() == '' || path.ends_with('/') || path.starts_with('/') {
		return false
	}
	mut components := []string{}
	for component in path.split('/') {
		if component == '' || component == '.' {
			continue
		}
		if component == '..' {
			if components.len == 0 {
				return false
			}
			components.delete_last()
			continue
		}
		components << component
	}
	return components.len > 0
}

fn clean_formula_source_path(path string) string {
	mut components := []string{}
	for component in path.split('/') {
		if component == '' || component == '.' {
			continue
		}
		if component == '..' {
			components.delete_last()
		} else {
			components << component
		}
	}
	return components.join('/')
}

pub fn formula_source_download_path(mut state FormulaApiState, formula FormulaSource, path string,
	checksum ?string, enqueue bool) !SourceDownload {
	if !valid_formula_source_path(path) {
		return error('API source path must be a relative path within the repository.')
	}
	clean_path := clean_formula_source_path(path)
	git_head := if formula.tap_git_head == '' { 'HEAD' } else { formula.tap_git_head }
	tap := if formula.tap_full_name == '' {
		'Homebrew/homebrew-core'
	} else {
		formula.tap_full_name
	}
	cache := os.join_path(state.source_cache_directory, tap, git_head, os.dir(clean_path))
	download := new_source_download('https://raw.githubusercontent.com/${tap}/${git_head}/${clean_path}', checksum, [], cache, cache)
	location := source_download_strategy_symlink_location(download.downloader)
	if enqueue {
		state.queued_downloads << download
	} else if !os.exists(location) || !os.is_link(location) {
		state.fetched_downloads << download
	}
	return download
}

pub fn formula_source_download(mut state FormulaApiState, formula FormulaSource,
	enqueue bool) !SourceDownload {
	path := if formula.ruby_source_path == '' {
		'Formula/${formula.name}.rb'
	} else {
		formula.ruby_source_path
	}
	checksum := if formula.ruby_source_checksum == '' {
		?string(none)
	} else {
		?string(formula.ruby_source_checksum)
	}
	return formula_source_download_path(mut state, formula, path, checksum, enqueue)
}

fn formula_local_patch_paths(contents string) []string {
	mut paths := []string{}
	for line in contents.split_into_lines() {
		trimmed := line.trim_space()
		if !trimmed.starts_with('file ') {
			continue
		}
		quote := if trimmed.contains('"') { `"` } else { `'` }
		start := trimmed.index_u8(quote)
		if start < 0 {
			continue
		}
		rest := trimmed[start + 1..]
		end := rest.index_u8(quote)
		if end >= 0 {
			paths << rest[..end]
		}
	}
	return paths
}

pub fn formula_source_download_formula(mut state FormulaApiState,
	formula FormulaSource) !LoadedFormulaSource {
	download := formula_source_download(mut state, formula, false)!
	location := source_download_strategy_symlink_location(download.downloader)
	if !os.exists(location) {
		full_name := if formula.full_name == '' { formula.name } else { formula.full_name }
		return error('${full_name} source code not found at ${location}. Try `rm -rf \$(brew --cache)/api-source` and retrying.')
	}
	contents := os.read_file(location)!
	mut local_patches := map[string]string{}
	for patch_path in formula_local_patch_paths(contents) {
		patch_download := formula_source_download_path(mut state, formula, patch_path, none, false)!
		patch_location := source_download_strategy_symlink_location(patch_download.downloader)
		local_patches[patch_path] = os.read_file(patch_location)!
	}
	return LoadedFormulaSource{
		name: formula.name
		full_name: if formula.full_name == '' { formula.name } else { formula.full_name }
		path: location
		contents: contents
		active_spec: formula.active_spec
		alias_path: formula.alias_path
		build_flags: formula.build_flags.clone()
		local_patches: local_patches
	}
}

pub fn formula_cached_json_file_path(state FormulaApiState) string {
	return os.join_path(state.cache_directory, formula_default_api_filename)
}

pub fn formula_fetch_api(mut state FormulaApiState, stale_seconds ?i64,
	enqueue bool) !FormulaApiFetchResult {
	return formula_fetch_json_api_file(mut state, formula_default_api_filename, stale_seconds, enqueue)
}

pub fn formula_fetch_tap_migrations(mut state FormulaApiState, stale_seconds ?i64,
	enqueue bool) !FormulaApiFetchResult {
	return formula_fetch_json_api_file(mut state, 'formula_tap_migrations.jws.json', stale_seconds, enqueue)
}

pub fn formula_download_and_cache_data(mut state FormulaApiState) !bool {
	result := formula_fetch_api(mut state, none, false)!
	if result.data.type_name != 'Array' {
		return error('${formula_default_api_filename} did not contain an array')
	}
	state.aliases = map[string]string{}
	state.renames = map[string]string{}
	state.formulae = map[string]map[string]ruby.Value{}
	for json_formula in result.data.array_data {
		if json_formula.type_name != 'Hash' {
			return error('${formula_default_api_filename} contained a non-object entry')
		}
		name := (json_formula.map_data['name'] or {
			return error('${formula_default_api_filename} entry is missing name')
		}).as_string()
		for alias_name in formula_value_strings(json_formula.map_data['aliases'] or {
			ruby.string_array_value([])
		}) {
			state.aliases[alias_name] = name
		}
		if oldnames := json_formula.map_data['oldnames'] {
			for oldname in formula_value_strings(oldnames) {
				state.renames[oldname] = name
			}
		} else if oldname := json_formula.map_data['oldname'] {
			if oldname.type_name != 'NilClass' && oldname.as_string() != '' {
				state.renames[oldname.as_string()] = name
			}
		}
		mut formula_data := json_formula.map_data.clone()
		formula_data.delete('name')
		state.formulae[name] = formula_data.clone()
	}
	state.formulae_loaded = true
	return result.updated
}

fn formula_write_lines(path string, regenerate bool, lines []string, final_newline bool) ! {
	if os.exists(path) && !regenerate {
		return
	}
	mut sorted := lines.clone()
	sorted.sort()
	os.mkdir_all(os.dir(path))!
	contents := if final_newline && sorted.len > 0 {
		'${sorted.join('\n')}\n'
	} else {
		sorted.join('\n')
	}
	os.write_file(path, contents)!
}

fn formula_write_executables(path string, regenerate bool,
	formulae map[string]map[string]ruby.Value) ! {
	mut lines := []string{}
	for name, formula_data in formulae {
		executables_value := formula_data['executables'] or { continue }
		executables := formula_value_strings(executables_value)
		if executables.len > 0 {
			lines << '${name}:${executables.join(' ')}'
		}
	}
	if lines.len == 0 {
		if os.exists(path) {
			os.rm(path)!
		}
		return
	}
	formula_write_lines(path, regenerate, lines, true)!
}

pub fn formula_write_names_and_aliases(mut state FormulaApiState, regenerate bool) ! {
	if !state.formulae_loaded {
		formula_download_and_cache_data(mut state)!
	}
	mut names := state.formulae.keys()
	names.sort()
	state.written_names = names
	state.written_aliases = state.aliases.clone()
	state.names_regenerated = regenerate
	state.aliases_regenerated = regenerate
	state.executables_regenerated = regenerate
	names_path := if state.names_file == '' {
		os.join_path(state.cache_directory, 'internal', 'formula_names.txt')
	} else {
		state.names_file
	}
	aliases_path := if state.aliases_file == '' {
		os.join_path(state.cache_directory, 'internal', 'formula_aliases.txt')
	} else {
		state.aliases_file
	}
	executables_path := if state.executables_file == '' {
		os.join_path(state.cache_directory, 'internal', 'executables.txt')
	} else {
		state.executables_file
	}
	formula_write_lines(names_path, regenerate, names, false)!
	mut alias_lines := []string{}
	for alias_name, real_name in state.aliases {
		alias_lines << '${alias_name}|${real_name}'
	}
	formula_write_lines(aliases_path, regenerate, alias_lines, false)!
	formula_write_executables(executables_path, regenerate, state.formulae)!
}

pub fn formula_all_aliases(mut state FormulaApiState) !map[string]string {
	if !state.formulae_loaded {
		updated := formula_download_and_cache_data(mut state)!
		formula_write_names_and_aliases(mut state, updated)!
	}
	return state.aliases.clone()
}

pub fn formula_tap_migrations(mut state FormulaApiState) !map[string]ruby.Value {
	if !state.tap_migrations_loaded {
		result := formula_fetch_tap_migrations(mut state, none, false)!
		if result.data.type_name != 'Hash' {
			return error('formula_tap_migrations.jws.json did not contain an object')
		}
		state.tap_migrations = result.data.map_data.clone()
		state.tap_migrations_loaded = true
	}
	return state.tap_migrations.clone()
}

pub fn default_formula_lookup_config() FormulaLookupConfig {
	return FormulaLookupConfig{
		api_base_url: 'https://formulae.brew.sh/api'
	}
}

fn formula_api_base_url(config FormulaLookupConfig) string {
	if config.api_base_url.len > 0 {
		return config.api_base_url.trim_string_right('/')
	}
	return default_formula_lookup_config().api_base_url
}

fn valid_formula_api_name(name string) bool {
	if name.len == 0 {
		return false
	}
	for character in name.bytes() {
		if !(character.is_alnum() || character in [`-`, `_`, `.`, `+`, `@`]) {
			return false
		}
	}
	return true
}

fn canonical_api_name(name string) !string {
	mut candidate := name
	if candidate.starts_with('homebrew/core/') {
		candidate = candidate.all_after_last('/')
	} else if candidate.contains('/') {
		return error('unimplemented Ruby function `Formulary::FromTapLoader.try_new` for non-core formula `${name}`')
	}
	candidate = candidate.trim_string_right('.rb').to_lower()
	if !valid_formula_api_name(candidate) {
		return error('invalid formula name: ${name}')
	}
	return candidate
}

pub fn decode_formula_reference(contents string) !PackageReference {
	document := json2.decode[FormulaApiDocument](contents)!
	if document.name.len == 0 {
		return error('formula JSON is missing `name`')
	}
	full_name := if document.full_name.len > 0 { document.full_name } else { document.name }
	tap := if document.tap.len > 0 { document.tap } else { 'homebrew/core' }
	return PackageReference{
		kind: .formula
		name: document.name
		full_name: full_name
		tap: tap
		description: document.desc
		license: document.license
		homepage: document.homepage
		stable_version: document.versions.stable
		head_version: document.versions.head
		source_url: document.urls.stable.url
		source_checksum: document.urls.stable.checksum
		revision: document.revision
		version_scheme: document.version_scheme
		bottle_available: document.versions.bottle
		bottle_tags: document.bottle.stable.files.keys()
		bottle_files: document.bottle.stable.files
		bottle_rebuild: document.bottle.stable.rebuild
		dependencies: document.dependencies
		build_dependencies: document.build_dependencies
		test_dependencies: document.test_dependencies
		recommended_dependencies: document.recommended_dependencies
		optional_dependencies: document.optional_dependencies
		oldnames: document.oldnames
		aliases: document.aliases
		versioned_formulae: document.versioned_formulae
		tap_git_head: document.tap_git_head
		ruby_source_path: document.ruby_source_path
		ruby_source_checksum: document.ruby_source_checksum.sha256
		keg_only: document.keg_only
		deprecated: document.deprecated
		deprecation_reason: document.deprecation_reason or { '' }
		disabled: document.disabled
		disable_reason: document.disable_reason or { '' }
		loaded_from_api: true
		core_tap: tap == 'homebrew/core'
		tap_installed: tap == 'homebrew/core'
	}
}

pub fn decode_local_formula_metadata(contents string, path string) !PackageReference {
	decoded := decode_formula_reference(contents)!
	return PackageReference{
		...decoded
		loaded_from_api: false
		local_path: path
	}
}

// The source answers formula metadata out of `HOMEBREW_CACHE/api`, refreshing an
// entry only once it is older than HOMEBREW_API_AUTO_UPDATE_SECS and never while
// HOMEBREW_NO_AUTO_UPDATE is set. Resolving without that cache reached the
// network once per formula in a dependency graph.
const formula_api_auto_update_default_seconds = i64(450)

// formula_api_cache_root resolves the same directory `HOMEBREW_API_CACHE` names
// for the source, falling back to Homebrew's own default cache location.
fn formula_api_cache_root(cache_directory string) string {
	if cache_directory.len > 0 {
		return cache_directory
	}
	if configured := non_empty_environment_value('HOMEBREW_API_CACHE') {
		return configured
	}
	if cache := non_empty_environment_value('HOMEBREW_CACHE') {
		return os.join_path(cache, 'api')
	}
	home := os.home_dir()
	if home.len == 0 {
		return ''
	}
	$if macos {
		return os.join_path(home, 'Library', 'Caches', 'Homebrew', 'api')
	} $else {
		base := non_empty_environment_value('XDG_CACHE_HOME') or { os.join_path(home, '.cache') }
		return os.join_path(base, 'Homebrew', 'api')
	}
}

fn non_empty_environment_value(name string) ?string {
	value := ruby.environment_value(name)
	return if value.len > 0 { value } else { none }
}

fn formula_api_auto_update_seconds() i64 {
	if ruby.environment_value('HOMEBREW_NO_AUTO_UPDATE').len > 0 {
		return -1
	}
	configured := ruby.environment_value('HOMEBREW_API_AUTO_UPDATE_SECS')
	if configured.len == 0 {
		return formula_api_auto_update_default_seconds
	}
	return configured.i64()
}

// formula_api_cache_fresh applies the source's staleness window. A negative
// window means auto-update is off and any cached entry is served.
fn formula_api_cache_fresh(path string) bool {
	window := formula_api_auto_update_seconds()
	if window < 0 {
		return true
	}
	information := os.stat(path) or { return false }
	age := time.now().unix() - information.mtime
	return age >= 0 && age < window
}

fn cached_formula_json_path(name string, cache_directory string) ?string {
	root := formula_api_cache_root(cache_directory)
	if root.len == 0 {
		return none
	}
	candidates := [
		os.join_path(root, 'formula', '${name}.json'),
		os.join_path(root, '${name}.json'),
	]
	for candidate in candidates {
		if os.is_file(candidate) && formula_api_cache_fresh(candidate) {
			return candidate
		}
	}
	return none
}

// write_cached_formula_json stores a fetched response where the source's own API
// cache keeps it, so a later run and the rest of this one are served from disk.
fn write_cached_formula_json(name string, cache_directory string, contents string) {
	root := formula_api_cache_root(cache_directory)
	if root.len == 0 {
		return
	}
	directory := os.join_path(root, 'formula')
	os.mkdir_all(directory) or { return }
	target := os.join_path(directory, '${name}.json')
	// Write through a temporary name so a concurrent reader never sees a partial
	// response at the cached path.
	temporary := '${target}.${os.getpid()}.incomplete'
	os.write_file(temporary, contents) or { return }
	os.mv(temporary, target) or { os.rm(temporary) or {} }
}

fn fetch_formula_endpoint(name string, config FormulaLookupConfig) !string {
	url := '${formula_api_base_url(config)}/formula/${name}.json'
	response := http.get(url)!
	if response.status_code != 200 {
		return error('formula API request failed for `${name}`: HTTP ${response.status_code}')
	}
	write_cached_formula_json(name, config.cache_directory, response.body)
	return response.body
}

pub fn fetch_formula_aliases(config FormulaLookupConfig) !map[string]string {
	response := http.get('${formula_api_base_url(config)}/formula.json')!
	if response.status_code != 200 {
		return error('formula API index request failed: HTTP ${response.status_code}')
	}
	documents := json2.decode[[]FormulaApiAliasDocument](response.body)!
	mut aliases := map[string]string{}
	for document in documents {
		for alias_name in document.aliases {
			aliases[alias_name] = document.name
		}
		for old_name in document.oldnames {
			aliases[old_name] = document.name
		}
	}
	return aliases
}

// formula_json implements the source's per-formula lookup order with explicit
// injectable JSON/cache inputs for deterministic callers and tests.
pub fn formula_json(name string, config FormulaLookupConfig) !string {
	requested_name := canonical_api_name(name)!
	canonical_name := config.aliases[requested_name] or { requested_name }
	if contents := config.formula_json_by_name[canonical_name] {
		return contents
	}
	if path := cached_formula_json_path(canonical_name, config.cache_directory) {
		return os.read_file(path)!
	}
	if config.without_api {
		return error('formula unavailable without API: ${name}')
	}
	return fetch_formula_endpoint(canonical_name, config)
}

pub fn resolve_formula_reference(name string, config FormulaLookupConfig) !PackageReference {
	requested_name := canonical_api_name(name)!
	mut canonical_name := config.aliases[requested_name] or { requested_name }
	mut contents := formula_json(canonical_name, config) or {
		if config.without_api || config.api_base_url.starts_with('file:') {
			return err
		}
		aliases := fetch_formula_aliases(config) or { return err }
		canonical_name = aliases[requested_name] or { return err }
		fetch_formula_endpoint(canonical_name, config)!
	}
	mut reference := decode_formula_reference(contents)!
	if requested_name != reference.name {
		reference = PackageReference{
			...reference
			alias_name: requested_name
		}
	}
	return reference
}
