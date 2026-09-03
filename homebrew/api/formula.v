module api

import brew_runtime
import net.http
import os
import x.json2

// Translated from Homebrew/brew `api/formula.rb`.
// The original source is retained below until every stub has a typed V body.
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
	data    brew_runtime.Value
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
	formula_json_cache      map[string]map[string]brew_runtime.Value
	formulae                map[string]map[string]brew_runtime.Value
	formulae_loaded         bool
	aliases                 map[string]string
	renames                 map[string]string
	tap_migrations          map[string]brew_runtime.Value
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

fn formula_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn formula_error_value(kind string, message string) brew_runtime.Value {
	return brew_runtime.structured_value(kind, message, {
		'message': message
	})
}

fn formula_value_strings(value brew_runtime.Value) []string {
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
		data: brew_runtime.parse_json_value(os.read_file(path)!)!
	}
}

pub fn formula_json_from_state(mut state FormulaApiState, name string) !map[string]brew_runtime.Value {
	if cached := state.formula_json_cache[name] {
		return cached.clone()
	}
	formula_fetch_formula_json(mut state, name)!
	return (state.formula_json_cache[name] or {
		return error('No formula JSON found for ${name}')
	}).clone()
}

pub fn formula_fetch_formula_json(mut state FormulaApiState, name string) ! {
	endpoint := 'formula/${name}.json'
	result := formula_fetch_json_api_file(mut state, endpoint, none, false)!
	mut json_formula := result.data
	if !result.updated {
		json_formula = brew_runtime.parse_json_value(os.read_file(os.join_path(state.cache_directory, endpoint))!)!
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
	state.formulae = map[string]map[string]brew_runtime.Value{}
	for json_formula in result.data.array_data {
		if json_formula.type_name != 'Hash' {
			return error('${formula_default_api_filename} contained a non-object entry')
		}
		name := (json_formula.map_data['name'] or {
			return error('${formula_default_api_filename} entry is missing name')
		}).as_string()
		for alias_name in formula_value_strings(json_formula.map_data['aliases'] or {
			brew_runtime.string_array_value([])
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
	formulae map[string]map[string]brew_runtime.Value) ! {
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

pub fn formula_all_formulae(mut state FormulaApiState) !map[string]map[string]brew_runtime.Value {
	if !state.formulae_loaded {
		updated := formula_download_and_cache_data(mut state)!
		formula_write_names_and_aliases(mut state, updated)!
	}
	return state.formulae.clone()
}

pub fn formula_all_aliases(mut state FormulaApiState) !map[string]string {
	if !state.formulae_loaded {
		updated := formula_download_and_cache_data(mut state)!
		formula_write_names_and_aliases(mut state, updated)!
	}
	return state.aliases.clone()
}

pub fn formula_tap_migrations(mut state FormulaApiState) !map[string]brew_runtime.Value {
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

fn cached_formula_json_path(name string, cache_directory string) ?string {
	if cache_directory.len == 0 {
		return none
	}
	candidates := [
		os.join_path(cache_directory, 'formula', '${name}.json'),
		os.join_path(cache_directory, '${name}.json'),
	]
	for candidate in candidates {
		if os.is_file(candidate) {
			return candidate
		}
	}
	return none
}

fn fetch_formula_endpoint(name string, config FormulaLookupConfig) !string {
	url := '${formula_api_base_url(config)}/formula/${name}.json'
	response := http.get(url)!
	if response.status_code != 200 {
		return error('formula API request failed for `${name}`: HTTP ${response.status_code}')
	}
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

pub fn formula_api_state_boundary(state &FormulaApiState) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::API::Formula', '', {
		'formula_api_state_address': u64(voidptr(state)).str()
	})
}

pub fn formula_source_boundary(formula FormulaSource) brew_runtime.Value {
	return brew_runtime.structured_value('Formula', formula.name, {
		'name':                 formula.name
		'full_name':            formula.full_name
		'ruby_source_path':     formula.ruby_source_path
		'ruby_source_checksum': formula.ruby_source_checksum
		'tap_git_head':         formula.tap_git_head
		'tap_full_name':        formula.tap_full_name
		'active_spec':          formula.active_spec
		'alias_path':           formula.alias_path
		'build_flags':          formula.build_flags.join('\x1f')
	})
}

fn formula_state_from_args(args []brew_runtime.Value, method string) &FormulaApiState {
	if args.len == 0 || 'formula_api_state_address' !in args[0].attributes {
		panic('API::Formula.${method} requires translated Formula API state')
	}
	return unsafe {
		&FormulaApiState(voidptr(args[0].attributes['formula_api_state_address'].u64()))
	}
}

fn formula_source_from_value(value brew_runtime.Value) FormulaSource {
	return FormulaSource{
		name: value.attributes['name'] or { value.repr }
		full_name: value.attributes['full_name'] or { value.repr }
		ruby_source_path: value.attributes['ruby_source_path'] or { '' }
		ruby_source_checksum: value.attributes['ruby_source_checksum'] or { '' }
		tap_git_head: value.attributes['tap_git_head'] or { '' }
		tap_full_name: value.attributes['tap_full_name'] or { '' }
		active_spec: value.attributes['active_spec'] or { '' }
		alias_path: value.attributes['alias_path'] or { '' }
		build_flags: if (value.attributes['build_flags'] or { '' }) == '' {
			[]string{}
		} else {
			value.attributes['build_flags'].split('\x1f')
		}
	}
}

fn formula_download_value(download SourceDownload) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::API::SourceDownload', download.url, {
		'url':              download.url
		'sha256':           download.checksum or { '' }
		'cache':            download.downloader.cache
		'symlink_location': source_download_strategy_symlink_location(download.downloader)
	})
}

fn loaded_formula_value(formula LoadedFormulaSource) brew_runtime.Value {
	mut patches := map[string]brew_runtime.Value{}
	for path, contents in formula.local_patches {
		patches[path] = brew_runtime.string_value(contents)
	}
	return brew_runtime.Value{
		type_name: 'Formula'
		repr: formula.name
		map_data: patches
		attributes: {
			'name':        formula.name
			'full_name':   formula.full_name
			'path':        formula.path
			'contents':    formula.contents
			'active_spec': formula.active_spec
			'alias_path':  formula.alias_path
			'build_flags': formula.build_flags.join('\x1f')
		}
	}
}

fn formulae_map_value(values map[string]map[string]brew_runtime.Value) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for key, value in values {
		result[key] = brew_runtime.map_value(value)
	}
	return brew_runtime.map_value(result)
}

fn formula_string_map_value(values map[string]string) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for key, value in values {
		result[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(result)
}

// Ruby method `self.formula_json(name)` at line 23.
pub fn ruby_formula_l23_d1_self_formula_json(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := formula_state_from_args(args, 'formula_json')
	if args.len < 2 {
		return formula_error_value('ArgumentError', 'name is required')
	}
	return brew_runtime.map_value(formula_json_from_state(mut state, args[1].as_string()) or {
		return formula_error_value('RuntimeError', err.msg())
	})
}

// Ruby method `self.fetch_formula_json!(name)` at line 30.
pub fn ruby_formula_l30_d2_self_fetch_formula_json(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := formula_state_from_args(args, 'fetch_formula_json!')
	if args.len < 2 {
		return formula_error_value('ArgumentError', 'name is required')
	}
	formula_fetch_formula_json(mut state, args[1].as_string()) or {
		return formula_error_value('RuntimeError', err.msg())
	}
	return formula_nil_value()
}

// Ruby method `self.source_download_path(formula, path, checksum: nil, download_queue: nil, enqueue: false)` at line 49.
pub fn ruby_formula_l49_d3_self_source_download_path(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := formula_state_from_args(args, 'source_download_path')
	if args.len < 3 {
		return formula_error_value('ArgumentError', 'formula and path are required')
	}
	checksum := if args.len > 3 && args[3].type_name != 'NilClass' {
		?string(args[3].as_string())
	} else {
		?string(none)
	}
	enqueue := args.len > 4 && args[args.len - 1].type_name == 'Bool' && args[args.len - 1].bool_data
	download := formula_source_download_path(mut state, formula_source_from_value(args[1]), args[2].as_string(), checksum, enqueue) or {
		return formula_error_value('ArgumentError', err.msg())
	}
	return formula_download_value(download)
}

// Ruby method `self.source_download(formula, download_queue: nil, enqueue: false)` at line 85.
pub fn ruby_formula_l85_d4_self_source_download(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := formula_state_from_args(args, 'source_download')
	if args.len < 2 {
		return formula_error_value('ArgumentError', 'formula is required')
	}
	enqueue := args.len > 2 && args[args.len - 1].type_name == 'Bool' && args[args.len - 1].bool_data
	download := formula_source_download(mut state, formula_source_from_value(args[1]), enqueue) or {
		return formula_error_value('RuntimeError', err.msg())
	}
	return formula_download_value(download)
}

// Ruby method `self.source_download_formula(formula)` at line 91.
pub fn ruby_formula_l91_d5_self_source_download_formula(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := formula_state_from_args(args, 'source_download_formula')
	if args.len < 2 {
		return formula_error_value('ArgumentError', 'formula is required')
	}
	loaded := formula_source_download_formula(mut state, formula_source_from_value(args[1])) or {
		return formula_error_value('CannotInstallFormulaError', err.msg())
	}
	return loaded_formula_value(loaded)
}

// Ruby method `self.cached_json_file_path` at line 120.
pub fn ruby_formula_l120_d6_self_cached_json_file_path(args ...brew_runtime.Value) brew_runtime.Value {
	state := formula_state_from_args(args, 'cached_json_file_path')
	return brew_runtime.object_value('Pathname', formula_cached_json_file_path(state))
}

// Ruby method `self.fetch_api!(download_queue: nil, stale_seconds: nil, enqueue: false)` at line 128.
pub fn ruby_formula_l128_d7_self_fetch_api(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := formula_state_from_args(args, 'fetch_api!')
	stale_seconds := if args.len > 1 && args[1].type_name == 'Integer' {
		?i64(args[1].int_data)
	} else {
		none
	}
	enqueue := args.len > 2 && args[2].bool_data
	result := formula_fetch_api(mut state, stale_seconds, enqueue) or {
		return formula_error_value('RuntimeError', err.msg())
	}
	return brew_runtime.array_value([result.data, brew_runtime.bool_value(result.updated)])
}

// Ruby method `self.fetch_tap_migrations!(download_queue: nil, stale_seconds: nil, enqueue: false)` at line 136.
pub fn ruby_formula_l136_d8_self_fetch_tap_migrations(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := formula_state_from_args(args, 'fetch_tap_migrations!')
	stale_seconds := if args.len > 1 && args[1].type_name == 'Integer' {
		?i64(args[1].int_data)
	} else {
		none
	}
	enqueue := args.len > 2 && args[2].bool_data
	result := formula_fetch_tap_migrations(mut state, stale_seconds, enqueue) or {
		return formula_error_value('RuntimeError', err.msg())
	}
	return brew_runtime.array_value([result.data, brew_runtime.bool_value(result.updated)])
}

// Ruby method `self.download_and_cache_data!` at line 141.
pub fn ruby_formula_l141_d9_self_download_and_cache_data(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := formula_state_from_args(args, 'download_and_cache_data!')
	return brew_runtime.bool_value(formula_download_and_cache_data(mut state) or {
		return formula_error_value('RuntimeError', err.msg())
	})
}

// Ruby method `self.all_formulae` at line 162.
pub fn ruby_formula_l162_d10_self_all_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := formula_state_from_args(args, 'all_formulae')
	return formulae_map_value(formula_all_formulae(mut state) or {
		return formula_error_value('RuntimeError', err.msg())
	})
}

// Ruby method `self.all_aliases` at line 172.
pub fn ruby_formula_l172_d11_self_all_aliases(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := formula_state_from_args(args, 'all_aliases')
	return formula_string_map_value(formula_all_aliases(mut state) or {
		return formula_error_value('RuntimeError', err.msg())
	})
}

// Ruby method `self.tap_migrations` at line 182.
pub fn ruby_formula_l182_d12_self_tap_migrations(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := formula_state_from_args(args, 'tap_migrations')
	return brew_runtime.map_value(formula_tap_migrations(mut state) or {
		return formula_error_value('RuntimeError', err.msg())
	})
}

// Ruby method `self.write_names_and_aliases(regenerate: false)` at line 192.
pub fn ruby_formula_l192_d13_self_write_names_and_aliases(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := formula_state_from_args(args, 'write_names_and_aliases')
	regenerate := args.len > 1 && args[1].bool_data
	formula_write_names_and_aliases(mut state, regenerate) or {
		return formula_error_value('RuntimeError', err.msg())
	}
	return formula_nil_value()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cachable"
// 5: require "api"
// 6: require "api/source_download"
// 7: require "api/formula/formula_struct_generator"
// 8:
// 9: module Homebrew
// 10:   module API
// 11:     # Helper functions for using the formula JSON API.
// 12:     module Formula
// 13:       extend T::Generic
// 14:       extend Cachable
// 15:
// 16:       Cache = type_template { { fixed: T::Hash[String, T.untyped] } }
// 17:
// 18:       DEFAULT_API_FILENAME = "formula.jws.json"
// 19:
// 20:       private_class_method :cache
// 21:
// 22:       sig { params(name: String).returns(T::Hash[String, T.untyped]) }
// 23:       def self.formula_json(name)
// 24:         fetch_formula_json! name if !cache.key?("formula_json") || !cache.fetch("formula_json").key?(name)
// 25:
// 26:         cache.fetch("formula_json").fetch(name)
// 27:       end
// 28:
// 29:       sig { params(name: String).void }
// 30:       def self.fetch_formula_json!(name)
// 31:         endpoint = "formula/#{name}.json"
// 32:         json_formula, updated = Homebrew::API.fetch_json_api_file endpoint
// 33:
// 34:         json_formula = JSON.parse((HOMEBREW_CACHE_API/endpoint).read) unless updated
// 35:
// 36:         cache["formula_json"] ||= {}
// 37:         cache["formula_json"][name] = json_formula
// 38:       end
// 39:
// 40:       sig {
// 41:         params(
// 42:           formula:        ::Formula,
// 43:           path:           String,
// 44:           checksum:       T.nilable(Checksum),
// 45:           download_queue: DownloadQueueType,
// 46:           enqueue:        T::Boolean,
// 47:         ).returns(Homebrew::API::SourceDownload)
// 48:       }
// 49:       def self.source_download_path(formula, path, checksum: nil, download_queue: nil, enqueue: false)
// 50:         require "local_patch"
// 51:
// 52:         unless LocalPatch.valid_path?(path)
// 53:           raise ArgumentError, "API source path must be a relative path within the repository."
// 54:         end
// 55:
// 56:         path = Pathname(path).cleanpath
// 57:
// 58:         git_head = formula.tap_git_head || "HEAD"
// 59:         tap = formula.tap&.full_name || "Homebrew/homebrew-core"
// 60:
// 61:         download = Homebrew::API::SourceDownload.new(
// 62:           "https://raw.githubusercontent.com/#{tap}/#{git_head}/#{path}",
// 63:           checksum,
// 64:           cache: HOMEBREW_CACHE_API_SOURCE/"#{tap}/#{git_head}"/path.dirname,
// 65:         )
// 66:
// 67:         if enqueue
// 68:           require "download_queue"
// 69:           download_queue ||= Homebrew.default_download_queue
// 70:           download_queue.enqueue(download)
// 71:         elsif !download.symlink_location.exist? || !download.symlink_location.symlink?
// 72:           download.fetch
// 73:         end
// 74:
// 75:         download
// 76:       end
// 77:
// 78:       sig {
// 79:         params(
// 80:           formula:        ::Formula,
// 81:           download_queue: DownloadQueueType,
// 82:           enqueue:        T::Boolean,
// 83:         ).returns(Homebrew::API::SourceDownload)
// 84:       }
// 85:       def self.source_download(formula, download_queue: nil, enqueue: false)
// 86:         path = formula.ruby_source_path || "Formula/#{formula.name}.rb"
// 87:         source_download_path(formula, path, checksum: formula.ruby_source_checksum, download_queue:, enqueue:)
// 88:       end
// 89:
// 90:       sig { params(formula: ::Formula).returns(::Formula) }
// 91:       def self.source_download_formula(formula)
// 92:         download = source_download(formula)
// 93:
// 94:         unless download.symlink_location.exist?
// 95:           raise CannotInstallFormulaError,
// 96:                 "#{formula.full_name} source code not found at #{download.symlink_location}. " \
// 97:                 "Try `rm -rf $(brew --cache)/api-source` and retrying."
// 98:         end
// 99:
// 100:         source_formula = with_env(HOMEBREW_INTERNAL_ALLOW_PACKAGES_FROM_PATHS: "1") do
// 101:           Formulary.factory(download.symlink_location,
// 102:                             formula.active_spec_sym,
// 103:                             alias_path: formula.alias_path,
// 104:                             flags:      formula.class.build_flags)
// 105:         end
// 106:
// 107:         source_formula.resources.each do |resource|
// 108:           resource.patches.grep(LocalPatch) do |patch|
// 109:             source_download_path(formula, patch.file.to_s)
// 110:           end
// 111:         end
// 112:         source_formula.patchlist.grep(LocalPatch) do |patch|
// 113:           source_download_path(formula, patch.file.to_s)
// 114:         end
// 115:
// 116:         source_formula
// 117:       end
// 118:
// 119:       sig { returns(Pathname) }
// 120:       def self.cached_json_file_path
// 121:         HOMEBREW_CACHE_API/DEFAULT_API_FILENAME
// 122:       end
// 123:
// 124:       sig {
// 125:         params(download_queue: DownloadQueueType, stale_seconds: T.nilable(Integer), enqueue: T::Boolean)
// 126:           .returns([T.any(T::Array[T.untyped], T::Hash[String, T.untyped]), T::Boolean])
// 127:       }
// 128:       def self.fetch_api!(download_queue: nil, stale_seconds: nil, enqueue: false)
// 129:         Homebrew::API.fetch_json_api_file DEFAULT_API_FILENAME, stale_seconds:, download_queue:, enqueue:
// 130:       end
// 131:
// 132:       sig {
// 133:         params(download_queue: DownloadQueueType, stale_seconds: T.nilable(Integer), enqueue: T::Boolean)
// 134:           .returns([T.any(T::Array[T.untyped], T::Hash[String, T.untyped]), T::Boolean])
// 135:       }
// 136:       def self.fetch_tap_migrations!(download_queue: nil, stale_seconds: nil, enqueue: false)
// 137:         Homebrew::API.fetch_json_api_file "formula_tap_migrations.jws.json", stale_seconds:, download_queue:, enqueue:
// 138:       end
// 139:
// 140:       sig { returns(T::Boolean) }
// 141:       def self.download_and_cache_data!
// 142:         json_formulae, updated = fetch_api!
// 143:
// 144:         cache["aliases"] = {}
// 145:         cache["renames"] = {}
// 146:         cache["formulae"] = json_formulae.to_h do |json_formula|
// 147:           json_formula["aliases"].each do |alias_name|
// 148:             cache["aliases"][alias_name] = json_formula["name"]
// 149:           end
// 150:           (json_formula["oldnames"] || [json_formula["oldname"]].compact).each do |oldname|
// 151:             cache["renames"][oldname] = json_formula["name"]
// 152:           end
// 153:
// 154:           [json_formula["name"], json_formula.except("name")]
// 155:         end
// 156:
// 157:         updated
// 158:       end
// 159:       private_class_method :download_and_cache_data!
// 160:
// 161:       sig { returns(T::Hash[String, T.untyped]) }
// 162:       def self.all_formulae
// 163:         unless cache.key?("formulae")
// 164:           json_updated = download_and_cache_data!
// 165:           write_names_and_aliases(regenerate: json_updated)
// 166:         end
// 167:
// 168:         cache.fetch("formulae")
// 169:       end
// 170:
// 171:       sig { returns(T::Hash[String, String]) }
// 172:       def self.all_aliases
// 173:         unless cache.key?("aliases")
// 174:           json_updated = download_and_cache_data!
// 175:           write_names_and_aliases(regenerate: json_updated)
// 176:         end
// 177:
// 178:         cache.fetch("aliases")
// 179:       end
// 180:
// 181:       sig { returns(T::Hash[String, T.untyped]) }
// 182:       def self.tap_migrations
// 183:         unless cache.key?("tap_migrations")
// 184:           json_migrations, = fetch_tap_migrations!
// 185:           cache["tap_migrations"] = json_migrations
// 186:         end
// 187:
// 188:         cache.fetch("tap_migrations")
// 189:       end
// 190:
// 191:       sig { params(regenerate: T::Boolean).void }
// 192:       def self.write_names_and_aliases(regenerate: false)
// 193:         download_and_cache_data! unless cache.key?("formulae")
// 194:
// 195:         Homebrew::API.write_names_file!("formula", regenerate:) { all_formulae.keys }
// 196:         Homebrew::API.write_aliases_file!("formula", regenerate:) { all_aliases }
// 197:         Homebrew::API.write_executables_file!(regenerate:, source: cached_json_file_path) { all_formulae }
// 198:       end
// 199:     end
// 200:   end
// 201: end
