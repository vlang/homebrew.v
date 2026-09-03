module api

import brew_runtime
import os

// Translated from Homebrew/brew `api/internal.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.effective_tag` at line 20.
pub fn ruby_internal_l20_d1_self_effective_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(internal_effective_tag(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `self.fallback_tag` at line 25.
pub fn ruby_internal_l25_d2_self_fallback_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(internal_fallback_tag(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}, if args.len > 1 { args[1].as_string() } else { '' }))
}

// Ruby method `self.packages_endpoint` at line 30.
pub fn ruby_internal_l30_d3_self_packages_endpoint(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(internal_packages_endpoint(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `self.formula_struct(name)` at line 35.
pub fn ruby_internal_l35_d4_self_formula_struct(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return internal_error_value('ArgumentError', 'formula_struct requires name and formula hash')
	}
	return formula_struct_value(internal_formula_struct(args[0].as_string(), args[1].map_data.clone(), if args.len > 2 {
		args[2].as_string()
	} else {
		'arm64_sonoma'
	}) or { return internal_error_value('RuntimeError', err.msg()) })
}

// Ruby method `self.cask_struct(name)` at line 50.
pub fn ruby_internal_l50_d5_self_cask_struct(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return internal_error_value('ArgumentError', 'cask_struct requires name and cask hash')
	}
	return cask_struct_value(internal_cask_struct(args[0].as_string(), args[1].map_data.clone()) or { return internal_error_value('RuntimeError', err.msg()) })
}

// Ruby method `self.cached_packages_json_file_path` at line 65.
pub fn ruby_internal_l65_d6_self_cached_packages_json_file_path(args ...brew_runtime.Value) brew_runtime.Value {
	cache_dir := if args.len > 0 {
		args[0].as_string()
	} else {
		os.join_path(os.temp_dir(), 'homebrew-api')
	}
	tag := if args.len > 1 { args[1].as_string() } else { internal_effective_tag('') }
	return brew_runtime.object_value('Pathname', internal_cached_packages_json_file_path(cache_dir, tag))
}

// Ruby method `self.fetch_packages_api!(download_queue: nil, stale_seconds: nil, enqueue: false)` at line 73.
pub fn ruby_internal_l73_d7_self_fetch_packages_api(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	result := internal_fetch_packages_api(mut state, args.len > 1 && args[1].bool_data) or { return internal_error_value('ErrorDuringExecution', err.msg()) }
	return internal_fetch_result_value(result)
}

// Ruby method `self.cached_packages_index(stale_seconds:, enqueue:)` at line 96.
pub fn ruby_internal_l96_d8_self_cached_packages_index(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return internal_nil_value()
	}
	target := args[0].as_string()
	index := internal_cached_packages_index(target, args.len > 1 && args[1].bool_data) or { return internal_nil_value() }
	return packages_index_value(index)
}

// Ruby method `self.download_and_cache_data!` at line 115.
pub fn ruby_internal_l115_d9_self_download_and_cache_data(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	return brew_runtime.bool_value(internal_download_and_cache_data(mut state) or { return internal_error_value('ErrorDuringExecution', err.msg()) })
}

// Ruby method `self.cache_parsed_packages!(json_contents)` at line 130.
pub fn ruby_internal_l130_d10_self_cache_parsed_packages(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return internal_error_value('ArgumentError', 'cache_parsed_packages! requires JSON contents')
	}
	mut state := InternalApiState{}
	internal_cache_parsed_packages(mut state, args[0])
	return internal_state_value(state)
}

// Ruby method `self.materialize_packages_index!` at line 146.
pub fn ruby_internal_l146_d11_self_materialize_packages_index(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	internal_materialize_packages_index(mut state) or { return internal_error_value('PackagesIndex::Invalid', err.msg()) }
	return internal_state_value(state)
}

// Ruby method `self.data_loaded?` at line 159.
pub fn ruby_internal_l159_d12_self_data_loaded(args ...brew_runtime.Value) brew_runtime.Value {
	state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	return brew_runtime.bool_value(internal_data_loaded(state))
}

// Ruby method `self.ensure_formula_data!` at line 164.
pub fn ruby_internal_l164_d13_self_ensure_formula_data(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	internal_ensure_formula_data(mut state) or { return internal_error_value('ErrorDuringExecution', err.msg()) }
	return internal_state_value(state)
}

// Ruby method `self.ensure_cask_data!` at line 172.
pub fn ruby_internal_l172_d14_self_ensure_cask_data(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	internal_ensure_cask_data(mut state) or { return internal_error_value('ErrorDuringExecution', err.msg()) }
	return internal_state_value(state)
}

// Ruby method `self.packages_value(key)` at line 180.
pub fn ruby_internal_l180_d15_self_packages_value(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return internal_error_value('ArgumentError', 'packages_value requires state and key')
	}
	mut state := internal_state_from_value(args[0])
	return internal_packages_value(mut state, args[1].as_string()) or { internal_error_value('PackagesIndex::Invalid', err.msg()) }
}

// Ruby method `self.write_formula_names_and_aliases(regenerate: false)` at line 190.
pub fn ruby_internal_l190_d16_self_write_formula_names_and_aliases(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	internal_write_formula_names_and_aliases(mut state, args.len > 1 && args[1].bool_data) or { return internal_error_value('SystemCallError', err.msg()) }
	return internal_state_value(state)
}

// Ruby method `self.write_cask_names(regenerate: false)` at line 199.
pub fn ruby_internal_l199_d17_self_write_cask_names(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	internal_write_cask_names(mut state, args.len > 1 && args[1].bool_data) or { return internal_error_value('SystemCallError', err.msg()) }
	return internal_state_value(state)
}

// Ruby method `self.formula_hashes_cached?` at line 209.
pub fn ruby_internal_l209_d18_self_formula_hashes_cached(args ...brew_runtime.Value) brew_runtime.Value {
	state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	return brew_runtime.bool_value(internal_data_loaded(state))
}

// Ruby method `self.formula_hashes` at line 214.
pub fn ruby_internal_l214_d19_self_formula_hashes(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	return brew_runtime.map_value(internal_formula_hashes(mut state) or { return internal_error_value('RuntimeError', err.msg()) })
}

// Ruby method `self.formula_hash(name)` at line 222.
pub fn ruby_internal_l222_d20_self_formula_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return internal_error_value('ArgumentError', 'formula_hash requires state and name')
	}
	mut state := internal_state_from_value(args[0])
	result := internal_formula_hash(mut state, args[1].as_string()) or { return internal_error_value('PackagesIndex::Invalid', err.msg()) }
	return if result.present { result.value } else { internal_nil_value() }
}

// Ruby method `self.formula_names` at line 235.
pub fn ruby_internal_l235_d21_self_formula_names(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	return brew_runtime.string_array_value(internal_formula_names(mut state) or { return internal_error_value('RuntimeError', err.msg()) })
}

// Ruby method `self.formula_name?(name)` at line 243.
pub fn ruby_internal_l243_d22_self_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	mut state := internal_state_from_value(args[0])
	return brew_runtime.bool_value(internal_formula_name(mut state, args[1].as_string()) or { false })
}

// Ruby method `self.formula_aliases` at line 251.
pub fn ruby_internal_l251_d23_self_formula_aliases(args ...brew_runtime.Value) brew_runtime.Value {
	return internal_string_map_boundary(args, 'formula_aliases')
}

// Ruby method `self.formula_renames` at line 257.
pub fn ruby_internal_l257_d24_self_formula_renames(args ...brew_runtime.Value) brew_runtime.Value {
	return internal_string_map_boundary(args, 'formula_renames')
}

// Ruby method `self.formula_tap_migrations` at line 263.
pub fn ruby_internal_l263_d25_self_formula_tap_migrations(args ...brew_runtime.Value) brew_runtime.Value {
	return internal_string_map_boundary(args, 'formula_tap_migrations')
}

// Ruby method `self.formula_tap_git_head` at line 269.
pub fn ruby_internal_l269_d26_self_formula_tap_git_head(args ...brew_runtime.Value) brew_runtime.Value {
	return internal_string_boundary(args, 'formula_tap_git_head')
}

// Ruby method `self.cask_hashes` at line 275.
pub fn ruby_internal_l275_d27_self_cask_hashes(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	return brew_runtime.map_value(internal_cask_hashes(mut state) or { return internal_error_value('RuntimeError', err.msg()) })
}

// Ruby method `self.cask_hash(name)` at line 283.
pub fn ruby_internal_l283_d28_self_cask_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return internal_error_value('ArgumentError', 'cask_hash requires state and name')
	}
	mut state := internal_state_from_value(args[0])
	result := internal_cask_hash(mut state, args[1].as_string()) or { return internal_error_value('PackagesIndex::Invalid', err.msg()) }
	return if result.present { result.value } else { internal_nil_value() }
}

// Ruby method `self.cask_names` at line 296.
pub fn ruby_internal_l296_d29_self_cask_names(args ...brew_runtime.Value) brew_runtime.Value {
	mut state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	return brew_runtime.string_array_value(internal_cask_names(mut state) or { return internal_error_value('RuntimeError', err.msg()) })
}

// Ruby method `self.cask_name?(name)` at line 304.
pub fn ruby_internal_l304_d30_self_cask_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	mut state := internal_state_from_value(args[0])
	return brew_runtime.bool_value(internal_cask_name(mut state, args[1].as_string()) or { false })
}

// Ruby method `self.cask_renames` at line 312.
pub fn ruby_internal_l312_d31_self_cask_renames(args ...brew_runtime.Value) brew_runtime.Value {
	return internal_string_map_boundary(args, 'cask_renames')
}

// Ruby method `self.cask_tap_migrations` at line 318.
pub fn ruby_internal_l318_d32_self_cask_tap_migrations(args ...brew_runtime.Value) brew_runtime.Value {
	return internal_string_map_boundary(args, 'cask_tap_migrations')
}

// Ruby method `self.cask_tap_git_head` at line 324.
pub fn ruby_internal_l324_d33_self_cask_tap_git_head(args ...brew_runtime.Value) brew_runtime.Value {
	return internal_string_boundary(args, 'cask_tap_git_head')
}

pub struct InternalFetchResult {
pub:
	indexed bool
	index   PackagesIndex
	parsed  brew_runtime.Value
	updated bool
}

pub struct InternalApiState {
pub mut:
	effective_tag           string
	fallback_tag            string
	cache_dir               string
	fetch_payload           string
	fetch_updated           bool
	fetch_http_status       int
	failed                  bool
	sidecar_verified        bool = true
	packages_index_present  bool
	packages_index          PackagesIndex
	formula_hashes_present  bool
	cask_hashes_present     bool
	formula_hashes          map[string]brew_runtime.Value
	cask_hashes             map[string]brew_runtime.Value
	formula_structs         map[string]FormulaStruct
	cask_structs            map[string]CaskStruct
	values                  map[string]brew_runtime.Value
	written_formula_names   []string
	written_formula_aliases map[string]string
	written_cask_names      []string
}

pub fn internal_effective_tag(tag string) string {
	return if tag == '' { 'arm64_sonoma' } else { tag }
}

pub fn internal_fallback_tag(effective string, fallback string) string {
	return if fallback == '' { internal_effective_tag(effective) } else { fallback }
}

pub fn internal_packages_endpoint(tag string) string {
	return 'internal/packages.${internal_effective_tag(tag)}.jws.json'
}

pub fn internal_cached_packages_json_file_path(cache_dir string, tag string) string {
	return os.join_path(cache_dir, internal_packages_endpoint(tag))
}

pub fn internal_formula_struct(name string, hash map[string]brew_runtime.Value, bottle_tag string) !FormulaStruct {
	if hash.len == 0 {
		return error('No formula found for ${name}')
	}
	return formula_struct_deserialize(hash, internal_effective_tag(bottle_tag), ApiStructPaths{})
}

pub fn internal_cask_struct(name string, hash map[string]brew_runtime.Value) !CaskStruct {
	if hash.len == 0 {
		return error('No cask found for ${name}')
	}
	return cask_struct_deserialize(hash, ApiStructPaths{})
}

pub fn internal_state_formula_struct(mut state InternalApiState, name string) !FormulaStruct {
	if cached := state.formula_structs[name] {
		return cached
	}
	result := internal_formula_hash(mut state, name)!
	if !result.present {
		return error('No formula found for ${name}')
	}
	created := formula_struct_deserialize(result.value.map_data.clone(), internal_effective_tag(state.effective_tag), ApiStructPaths{})
	state.formula_structs[name] = created
	return created
}

pub fn internal_state_cask_struct(mut state InternalApiState, name string) !CaskStruct {
	if cached := state.cask_structs[name] {
		return cached
	}
	result := internal_cask_hash(mut state, name)!
	if !result.present {
		return error('No cask found for ${name}')
	}
	created := cask_struct_deserialize(result.value.map_data.clone(), ApiStructPaths{})
	state.cask_structs[name] = created
	return created
}

pub fn internal_cached_packages_index(target string, verified bool) ?PackagesIndex {
	if !verified || !os.exists(target) || !os.exists('${target}.payload') {
		return none
	}
	contents := os.read_file('${target}.payload') or { return none }
	newline := contents.index_u8(`\n`)
	if newline < 0 {
		return none
	}
	header := brew_runtime.parse_json_value(contents[..newline]) or { return none }
	if header.type_name != 'Hash' {
		return none
	}
	stat := packages_source_stat(target) or { return none }
	if (header.map_data['source_size'] or { brew_runtime.int_value(-1) }).int_data != stat.size || (header.map_data['source_mtime_ns'] or { brew_runtime.int_value(-1) }).int_data != stat.mtime_ns {
		return none
	}
	payload := contents[newline + 1..]
	if loaded := packages_index_load(target, payload, stat) {
		return loaded
	}
	parsed := brew_runtime.parse_json_value(payload) or { return none }
	if parsed.type_name != 'Hash' {
		return none
	}
	packages_index_write(target, payload, parsed, stat, false) or { return none }
	return none
}

pub fn internal_fetch_packages_api(mut state InternalApiState, enqueue bool) !InternalFetchResult {
	target := internal_cached_packages_json_file_path(state.cache_dir, state.effective_tag)
	if !enqueue {
		if index := internal_cached_packages_index(target, state.sidecar_verified) {
			return InternalFetchResult{ indexed: true, index: index }
		}
		if os.exists('${target}.payload') && state.sidecar_verified {
			contents := os.read_file('${target}.payload')!
			newline := contents.index_u8(`\n`)
			if newline >= 0 {
				parsed := brew_runtime.parse_json_value(contents[newline + 1..])!
				return InternalFetchResult{ parsed: parsed }
			}
		}
	}
	if state.fetch_http_status == 404 && internal_effective_tag(state.effective_tag) != internal_fallback_tag(state.effective_tag, state.fallback_tag) {
		state.effective_tag = internal_fallback_tag(state.effective_tag, state.fallback_tag)
		state.failed = false
	}
	if state.fetch_http_status != 0 && state.fetch_http_status != 200 {
		return error('HTTP status: ${state.fetch_http_status}')
	}
	if state.fetch_payload == '' {
		return error('packages API returned no payload')
	}
	return InternalFetchResult{ parsed: brew_runtime.parse_json_value(state.fetch_payload)!, updated: state.fetch_updated }
}

pub fn internal_download_and_cache_data(mut state InternalApiState) !bool {
	result := internal_fetch_packages_api(mut state, false)!
	state.formula_structs = map[string]FormulaStruct{}
	state.cask_structs = map[string]CaskStruct{}
	if result.indexed {
		state.packages_index = result.index
		state.packages_index_present = true
		state.formula_hashes_present = false
		state.cask_hashes_present = false
	} else {
		internal_cache_parsed_packages(mut state, result.parsed)
	}
	return result.updated
}

pub fn internal_cache_parsed_packages(mut state InternalApiState, json_contents brew_runtime.Value) {
	state.packages_index_present = false
	for key in ['formula_aliases', 'formula_renames', 'cask_renames', 'formula_tap_git_head',
		'cask_tap_git_head', 'formula_tap_migrations', 'cask_tap_migrations'] {
		state.values[key] = json_contents.map_data[key] or { internal_nil_value() }
	}
	state.formula_hashes = internal_value_map(json_contents.map_data['formulae'] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	state.cask_hashes = internal_value_map(json_contents.map_data['casks'] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	state.formula_hashes_present = true
	state.cask_hashes_present = true
}

pub fn internal_materialize_packages_index(mut state InternalApiState) ! {
	if !state.packages_index_present {
		return
	}
	index := state.packages_index
	parsed := brew_runtime.parse_json_value(index.payload)!
	if parsed.type_name != 'Hash' {
		return error('packages payload must contain a Hash')
	}
	internal_cache_parsed_packages(mut state, parsed)
	target := internal_cached_packages_json_file_path(state.cache_dir, state.effective_tag)
	if target != '' && os.exists(target) {
		packages_index_write(target, index.payload, parsed, index.source_stat, false)!
	}
}

pub fn internal_data_loaded(state InternalApiState) bool {
	return state.formula_hashes_present || state.packages_index_present
}

pub fn internal_ensure_formula_data(mut state InternalApiState) ! {
	if internal_data_loaded(state) {
		return
	}
	updated := internal_download_and_cache_data(mut state)!
	internal_write_formula_names_and_aliases(mut state, updated)!
}

pub fn internal_ensure_cask_data(mut state InternalApiState) ! {
	if internal_data_loaded(state) {
		return
	}
	updated := internal_download_and_cache_data(mut state)!
	internal_write_cask_names(mut state, updated)!
}

pub fn internal_packages_value(mut state InternalApiState, key string) !brew_runtime.Value {
	if cached := state.values[key] {
		return cached
	}
	if !state.packages_index_present {
		return internal_nil_value()
	}
	result := packages_index_top_level_value(state.packages_index, key) or {
		internal_materialize_packages_index(mut state)!
		return state.values[key] or { internal_nil_value() }
	}
	value := if result.present { result.value } else { internal_nil_value() }
	state.values[key] = value
	return value
}

pub fn internal_write_formula_names_and_aliases(mut state InternalApiState, regenerate bool) ! {
	if !internal_data_loaded(state) { internal_download_and_cache_data(mut state)! }
	state.written_formula_names = internal_formula_names(mut state)!
	aliases := internal_packages_value(mut state, 'formula_aliases')!
	state.written_formula_aliases = internal_string_map(aliases)
	if state.cache_dir != '' {
		internal_write_lines(os.join_path(state.cache_dir, 'internal', 'formula_names.txt'), regenerate, state.written_formula_names)!
		mut alias_lines := []string{}
		for alias_name, real_name in state.written_formula_aliases {
			alias_lines << '${alias_name}|${real_name}'
		}
		internal_write_lines(os.join_path(state.cache_dir, 'internal', 'formula_aliases.txt'), regenerate, alias_lines)!
		internal_write_executables(os.join_path(state.cache_dir, 'internal', 'executables.txt'), regenerate, internal_formula_hashes(mut state)!)!
	}
}

pub fn internal_write_cask_names(mut state InternalApiState, regenerate bool) ! {
	if !internal_data_loaded(state) { internal_download_and_cache_data(mut state)! }
	state.written_cask_names = internal_cask_names(mut state)!
	if state.cache_dir != '' {
		internal_write_lines(os.join_path(state.cache_dir, 'internal', 'cask_names.txt'), regenerate, state.written_cask_names)!
	}
}

pub fn internal_formula_hashes(mut state InternalApiState) !map[string]brew_runtime.Value {
	internal_ensure_formula_data(mut state)!
	if !state.formula_hashes_present { internal_materialize_packages_index(mut state)! }
	return state.formula_hashes.clone()
}

pub fn internal_formula_hash(mut state InternalApiState, name string) !PackageValueResult {
	internal_ensure_formula_data(mut state)!
	if state.formula_hashes_present {
		if value := state.formula_hashes[name] {
			return PackageValueResult{ present: true, value: value }
		}
		return PackageValueResult{}
	}
	return packages_index_formula_hash(state.packages_index, name) or {
		internal_materialize_packages_index(mut state)!
		if value := state.formula_hashes[name] {
			return PackageValueResult{ present: true, value: value }
		}
		return PackageValueResult{}
	}
}

pub fn internal_formula_names(mut state InternalApiState) ![]string {
	internal_ensure_formula_data(mut state)!
	return if state.formula_hashes_present {
		state.formula_hashes.keys()
	} else {
		packages_index_formula_names(state.packages_index)
	}
}

pub fn internal_formula_name(mut state InternalApiState, name string) !bool {
	internal_ensure_formula_data(mut state)!
	return if state.formula_hashes_present {
		name in state.formula_hashes
	} else {
		packages_index_formula_name(state.packages_index, name)
	}
}

pub fn internal_cask_hashes(mut state InternalApiState) !map[string]brew_runtime.Value {
	internal_ensure_cask_data(mut state)!
	if !state.cask_hashes_present { internal_materialize_packages_index(mut state)! }
	return state.cask_hashes.clone()
}

pub fn internal_cask_hash(mut state InternalApiState, name string) !PackageValueResult {
	internal_ensure_cask_data(mut state)!
	if state.cask_hashes_present {
		if value := state.cask_hashes[name] {
			return PackageValueResult{ present: true, value: value }
		}
		return PackageValueResult{}
	}
	return packages_index_cask_hash(state.packages_index, name) or {
		internal_materialize_packages_index(mut state)!
		if value := state.cask_hashes[name] {
			return PackageValueResult{ present: true, value: value }
		}
		return PackageValueResult{}
	}
}

pub fn internal_cask_names(mut state InternalApiState) ![]string {
	internal_ensure_cask_data(mut state)!
	return if state.cask_hashes_present {
		state.cask_hashes.keys()
	} else {
		packages_index_cask_names(state.packages_index)
	}
}

pub fn internal_cask_name(mut state InternalApiState, name string) !bool {
	internal_ensure_cask_data(mut state)!
	return if state.cask_hashes_present {
		name in state.cask_hashes
	} else {
		packages_index_cask_name(state.packages_index, name)
	}
}

fn internal_write_lines(path string, regenerate bool, lines []string) ! {
	if os.exists(path) && !regenerate {
		return
	}
	mut sorted := lines.clone()
	sorted.sort()
	os.mkdir_all(os.dir(path))!
	os.write_file(path, sorted.join('\n'))!
}

fn internal_write_executables(path string, regenerate bool, formulae map[string]brew_runtime.Value) ! {
	if os.exists(path) && !regenerate {
		return
	}
	mut lines := []string{}
	for name, formula in formulae {
		executables := (formula.map_data['executables'] or { continue }).as_array() or { continue }
		if executables.len > 0 { lines << '${name}:${executables.map(it.as_string()).join(' ')}' }
	}
	lines.sort()
	os.mkdir_all(os.dir(path))!
	os.write_file(path, if lines.len > 0 { '${lines.join('\n')}\n' } else { '' })!
}

fn internal_state_from_value(value brew_runtime.Value) InternalApiState {
	values := if value.type_name == 'Hash' {
		value.map_data.clone()
	} else {
		map[string]brew_runtime.Value{}
	}
	mut state := InternalApiState{
		effective_tag: (values['effective_tag'] or { brew_runtime.string_value('') }).as_string()
		fallback_tag: (values['fallback_tag'] or { brew_runtime.string_value('') }).as_string()
		cache_dir: (values['cache_dir'] or { brew_runtime.string_value('') }).as_string()
		fetch_payload: (values['fetch_payload'] or { brew_runtime.string_value('') }).as_string()
		fetch_updated: (values['fetch_updated'] or { brew_runtime.bool_value(false) }).bool_data
		fetch_http_status: int((values['fetch_http_status'] or { brew_runtime.int_value(0) }).int_data)
		sidecar_verified: (values['sidecar_verified'] or { brew_runtime.bool_value(true) }).bool_data
		values: values.clone()
	}
	if formulae := values['formulae'] {
		state.formula_hashes = internal_value_map(formulae)
		state.formula_hashes_present = true
	}
	if casks := values['casks'] {
		state.cask_hashes = internal_value_map(casks)
		state.cask_hashes_present = true
	}
	return state
}

fn internal_state_value(state InternalApiState) brew_runtime.Value {
	mut values := state.values.clone()
	values['effective_tag'] = brew_runtime.string_value(state.effective_tag)
	values['formulae'] = brew_runtime.map_value(state.formula_hashes)
	values['casks'] = brew_runtime.map_value(state.cask_hashes)
	values['data_loaded'] = brew_runtime.bool_value(internal_data_loaded(state))
	return brew_runtime.map_value(values)
}

// internal_state_value_for_test exposes the same generic adapter used by the
// retained wrappers while keeping the mutable runtime API fully typed.
pub fn internal_state_value_for_test(parsed brew_runtime.Value, cache_dir string) brew_runtime.Value {
	mut values := parsed.map_data.clone()
	values['cache_dir'] = brew_runtime.string_value(cache_dir)
	values['effective_tag'] = brew_runtime.string_value('arm64_sonoma')
	values['fetch_payload'] = brew_runtime.string_value(brew_runtime.json_value_to_string(parsed))
	return brew_runtime.map_value(values)
}

fn internal_fetch_result_value(result InternalFetchResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'indexed': brew_runtime.bool_value(result.indexed)
		'updated': brew_runtime.bool_value(result.updated)
		'parsed':  result.parsed
	})
}

fn internal_value_map(value brew_runtime.Value) map[string]brew_runtime.Value {
	return if value.type_name == 'Hash' {
		value.map_data.clone()
	} else {
		map[string]brew_runtime.Value{}
	}
}

fn internal_string_map(value brew_runtime.Value) map[string]string {
	mut result := map[string]string{}
	for key, item in internal_value_map(value) {
		result[key] = item.as_string()
	}
	return result
}

fn internal_string_map_value(values map[string]string) brew_runtime.Value {
	mut result := map[string]brew_runtime.Value{}
	for key, value in values {
		result[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(result)
}

fn internal_string_map_boundary(args []brew_runtime.Value, key string) brew_runtime.Value {
	mut state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	return internal_string_map_value(internal_string_map(internal_packages_value(mut state, key) or { return internal_error_value('RuntimeError', err.msg()) }))
}

fn internal_string_boundary(args []brew_runtime.Value, key string) brew_runtime.Value {
	mut state := internal_state_from_value(args[0] or { brew_runtime.map_value(map[string]brew_runtime.Value{}) })
	return internal_packages_value(mut state, key) or { internal_error_value('RuntimeError', err.msg()) }
}

fn internal_error_value(kind string, message string) brew_runtime.Value {
	return brew_runtime.object_value(kind, message)
}

fn internal_nil_value() brew_runtime.Value {
	return brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
}

fn formula_struct_value(formula FormulaStruct) brew_runtime.Value {
	return brew_runtime.map_value(formula.serialize('arm64_sonoma'))
}

fn cask_struct_value(cask CaskStruct) brew_runtime.Value {
	return brew_runtime.map_value(cask.serialize())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cachable"
// 5: require "api"
// 6: require "api/packages_index"
// 7:
// 8: module Homebrew
// 9:   module API
// 10:     # Helper functions for using the JSON internal API.
// 11:     module Internal
// 12:       extend T::Generic
// 13:       extend Cachable
// 14:
// 15:       Cache = type_template { { fixed: T::Hash[String, T.untyped] } }
// 16:
// 17:       private_class_method :cache
// 18:
// 19:       sig { returns(Utils::Bottles::Tag) }
// 20:       private_class_method def self.effective_tag
// 21:         @effective_tag ||= T.let(SimulateSystem.current_tag, T.nilable(Utils::Bottles::Tag))
// 22:       end
// 23:
// 24:       sig { returns(Utils::Bottles::Tag) }
// 25:       private_class_method def self.fallback_tag
// 26:         effective_tag
// 27:       end
// 28:
// 29:       sig { returns(String) }
// 30:       private_class_method def self.packages_endpoint
// 31:         "internal/packages.#{effective_tag}.jws.json"
// 32:       end
// 33:
// 34:       sig { params(name: String).returns(Homebrew::API::FormulaStruct) }
// 35:       def self.formula_struct(name)
// 36:         return cache["formula_structs"][name] if cache.key?("formula_structs") && cache["formula_structs"].key?(name)
// 37:
// 38:         hash = formula_hash(name)
// 39:         raise "No formula found for #{name}" unless hash
// 40:
// 41:         struct = Homebrew::API::FormulaStruct.deserialize(hash, bottle_tag: effective_tag)
// 42:
// 43:         cache["formula_structs"] ||= {}
// 44:         cache["formula_structs"][name] = struct
// 45:
// 46:         struct
// 47:       end
// 48:
// 49:       sig { params(name: String).returns(Homebrew::API::CaskStruct) }
// 50:       def self.cask_struct(name)
// 51:         return cache["cask_structs"][name] if cache.key?("cask_structs") && cache["cask_structs"].key?(name)
// 52:
// 53:         hash = cask_hash(name)
// 54:         raise "No cask found for #{name}" unless hash
// 55:
// 56:         struct = Homebrew::API::CaskStruct.deserialize(hash)
// 57:
// 58:         cache["cask_structs"] ||= {}
// 59:         cache["cask_structs"][name] = struct
// 60:
// 61:         struct
// 62:       end
// 63:
// 64:       sig { returns(Pathname) }
// 65:       def self.cached_packages_json_file_path
// 66:         HOMEBREW_CACHE_API/packages_endpoint
// 67:       end
// 68:
// 69:       sig {
// 70:         params(download_queue: DownloadQueueType, stale_seconds: T.nilable(Integer), enqueue: T::Boolean)
// 71:           .returns([T.any(T::Hash[String, T.untyped], Homebrew::API::PackagesIndex), T::Boolean])
// 72:       }
// 73:       def self.fetch_packages_api!(download_queue: nil, stale_seconds: nil, enqueue: false)
// 74:         old_failed = Homebrew.failed?
// 75:         json_contents, updated = begin
// 76:           cached_packages_index(stale_seconds:, enqueue:) ||
// 77:             Homebrew::API.fetch_json_api_file(packages_endpoint, stale_seconds:, download_queue:, enqueue:)
// 78:         rescue ErrorDuringExecution => e
// 79:           raise if e.stderr.exclude?("HTTP status: 404") || effective_tag == fallback_tag
// 80:
// 81:           @effective_tag = fallback_tag
// 82:           Homebrew.failed = old_failed
// 83:           retry
// 84:         end
// 85:
// 86:         [T.cast(json_contents, T.any(T::Hash[String, T.untyped], Homebrew::API::PackagesIndex)), updated]
// 87:       end
// 88:
// 89:       # Serves a fresh cached packages payload through its byte-offset index
// 90:       # so only the entries that get used are parsed, building the index
// 91:       # after a full parse when it is missing or stale.
// 92:       sig {
// 93:         params(stale_seconds: T.nilable(Integer), enqueue: T::Boolean)
// 94:           .returns(T.nilable([T.any(T::Hash[String, T.untyped], Homebrew::API::PackagesIndex), T::Boolean]))
// 95:       }
// 96:       private_class_method def self.cached_packages_index(stale_seconds:, enqueue:)
// 97:         return if enqueue
// 98:
// 99:         cached = Homebrew::API.cached_internal_packages_payload(packages_endpoint, stale_seconds:)
// 100:         return if cached.nil?
// 101:
// 102:         payload, source_stat = cached
// 103:         target = cached_packages_json_file_path
// 104:         index = Homebrew::API::PackagesIndex.load(target, payload:, source_stat:)
// 105:         return [index, false] if index
// 106:
// 107:         parsed = JSON.parse(payload, freeze: true)
// 108:         return unless parsed.is_a?(Hash)
// 109:
// 110:         Homebrew::API::PackagesIndex.write!(target, payload:, parsed:, source_stat:)
// 111:         [parsed, false]
// 112:       end
// 113:
// 114:       sig { returns(T::Boolean) }
// 115:       def self.download_and_cache_data!
// 116:         json_contents, updated = fetch_packages_api!
// 117:         cache["formula_structs"] = {}
// 118:         cache["cask_structs"] = {}
// 119:         if json_contents.is_a?(Homebrew::API::PackagesIndex)
// 120:           cache["packages_index"] = json_contents
// 121:         else
// 122:           cache_parsed_packages!(json_contents)
// 123:         end
// 124:
// 125:         updated
// 126:       end
// 127:       private_class_method :download_and_cache_data!
// 128:
// 129:       sig { params(json_contents: T::Hash[String, T.untyped]).void }
// 130:       private_class_method def self.cache_parsed_packages!(json_contents)
// 131:         cache.delete("packages_index")
// 132:         cache["formula_aliases"] = json_contents["formula_aliases"]
// 133:         cache["formula_renames"] = json_contents["formula_renames"]
// 134:         cache["cask_renames"] = json_contents["cask_renames"]
// 135:         cache["formula_tap_git_head"] = json_contents["formula_tap_git_head"]
// 136:         cache["cask_tap_git_head"] = json_contents["cask_tap_git_head"]
// 137:         cache["formula_tap_migrations"] = json_contents["formula_tap_migrations"]
// 138:         cache["cask_tap_migrations"] = json_contents["cask_tap_migrations"]
// 139:         cache["formula_hashes"] = json_contents["formulae"]
// 140:         cache["cask_hashes"] = json_contents["casks"]
// 141:       end
// 142:
// 143:       # Replaces a cached index with fully parsed payload data, for callers
// 144:       # that need every entry or when index validation fails.
// 145:       sig { void }
// 146:       private_class_method def self.materialize_packages_index!
// 147:         index = cache.delete("packages_index")
// 148:         return unless index.is_a?(Homebrew::API::PackagesIndex)
// 149:
// 150:         parsed = JSON.parse(index.payload, freeze: true)
// 151:         return unless parsed.is_a?(Hash)
// 152:
// 153:         cache_parsed_packages!(parsed)
// 154:         Homebrew::API::PackagesIndex.write!(cached_packages_json_file_path, payload: index.payload, parsed:,
// 155:                                             source_stat: index.source_stat)
// 156:       end
// 157:
// 158:       sig { returns(T::Boolean) }
// 159:       private_class_method def self.data_loaded?
// 160:         cache.key?("formula_hashes") || cache.key?("packages_index")
// 161:       end
// 162:
// 163:       sig { void }
// 164:       private_class_method def self.ensure_formula_data!
// 165:         return if data_loaded?
// 166:
// 167:         updated = download_and_cache_data!
// 168:         write_formula_names_and_aliases(regenerate: updated)
// 169:       end
// 170:
// 171:       sig { void }
// 172:       private_class_method def self.ensure_cask_data!
// 173:         return if data_loaded?
// 174:
// 175:         updated = download_and_cache_data!
// 176:         write_cask_names(regenerate: updated)
// 177:       end
// 178:
// 179:       sig { params(key: String).returns(T.untyped) }
// 180:       private_class_method def self.packages_value(key)
// 181:         return cache[key] if cache.key?(key)
// 182:
// 183:         cache[key] = cache["packages_index"].top_level_value(key)
// 184:       rescue Homebrew::API::PackagesIndex::Invalid
// 185:         materialize_packages_index!
// 186:         cache[key]
// 187:       end
// 188:
// 189:       sig { params(regenerate: T::Boolean).void }
// 190:       def self.write_formula_names_and_aliases(regenerate: false)
// 191:         download_and_cache_data! unless data_loaded?
// 192:
// 193:         Homebrew::API.write_names_file!("formula", regenerate:) { formula_names }
// 194:         Homebrew::API.write_aliases_file!("formula", regenerate:) { formula_aliases }
// 195:         Homebrew::API.write_executables_file!(regenerate:, source: cached_packages_json_file_path) { formula_hashes }
// 196:       end
// 197:
// 198:       sig { params(regenerate: T::Boolean).void }
// 199:       def self.write_cask_names(regenerate: false)
// 200:         download_and_cache_data! unless data_loaded?
// 201:
// 202:         Homebrew::API.write_names_file!("cask", regenerate:) { cask_names }
// 203:       end
// 204:
// 205:       # Whether internal packages API data is already loaded, as full hashes
// 206:       # or a byte-offset index, so callers can use it opportunistically
// 207:       # without triggering a download and full JSON parse.
// 208:       sig { returns(T::Boolean) }
// 209:       def self.formula_hashes_cached?
// 210:         data_loaded?
// 211:       end
// 212:
// 213:       sig { returns(T::Hash[String, T::Hash[String, T.untyped]]) }
// 214:       def self.formula_hashes
// 215:         ensure_formula_data!
// 216:         materialize_packages_index! unless cache.key?("formula_hashes")
// 217:
// 218:         cache["formula_hashes"]
// 219:       end
// 220:
// 221:       sig { params(name: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 222:       def self.formula_hash(name)
// 223:         ensure_formula_data!
// 224:         return cache["formula_hashes"][name] if cache.key?("formula_hashes")
// 225:
// 226:         begin
// 227:           cache["packages_index"].formula_hash(name)
// 228:         rescue Homebrew::API::PackagesIndex::Invalid
// 229:           materialize_packages_index!
// 230:           cache["formula_hashes"][name]
// 231:         end
// 232:       end
// 233:
// 234:       sig { returns(T::Array[String]) }
// 235:       def self.formula_names
// 236:         ensure_formula_data!
// 237:         return cache["formula_hashes"].keys if cache.key?("formula_hashes")
// 238:
// 239:         cache["packages_index"].formula_names
// 240:       end
// 241:
// 242:       sig { params(name: String).returns(T::Boolean) }
// 243:       def self.formula_name?(name)
// 244:         ensure_formula_data!
// 245:         return cache["formula_hashes"].key?(name) if cache.key?("formula_hashes")
// 246:
// 247:         cache["packages_index"].formula_name?(name)
// 248:       end
// 249:
// 250:       sig { returns(T::Hash[String, String]) }
// 251:       def self.formula_aliases
// 252:         ensure_formula_data!
// 253:         packages_value("formula_aliases")
// 254:       end
// 255:
// 256:       sig { returns(T::Hash[String, String]) }
// 257:       def self.formula_renames
// 258:         ensure_formula_data!
// 259:         packages_value("formula_renames")
// 260:       end
// 261:
// 262:       sig { returns(T::Hash[String, String]) }
// 263:       def self.formula_tap_migrations
// 264:         ensure_formula_data!
// 265:         packages_value("formula_tap_migrations")
// 266:       end
// 267:
// 268:       sig { returns(String) }
// 269:       def self.formula_tap_git_head
// 270:         ensure_formula_data!
// 271:         packages_value("formula_tap_git_head")
// 272:       end
// 273:
// 274:       sig { returns(T::Hash[String, T::Hash[String, T.untyped]]) }
// 275:       def self.cask_hashes
// 276:         ensure_cask_data!
// 277:         materialize_packages_index! unless cache.key?("cask_hashes")
// 278:
// 279:         cache["cask_hashes"]
// 280:       end
// 281:
// 282:       sig { params(name: String).returns(T.nilable(T::Hash[String, T.untyped])) }
// 283:       def self.cask_hash(name)
// 284:         ensure_cask_data!
// 285:         return cache["cask_hashes"][name] if cache.key?("cask_hashes")
// 286:
// 287:         begin
// 288:           cache["packages_index"].cask_hash(name)
// 289:         rescue Homebrew::API::PackagesIndex::Invalid
// 290:           materialize_packages_index!
// 291:           cache["cask_hashes"][name]
// 292:         end
// 293:       end
// 294:
// 295:       sig { returns(T::Array[String]) }
// 296:       def self.cask_names
// 297:         ensure_cask_data!
// 298:         return cache["cask_hashes"].keys if cache.key?("cask_hashes")
// 299:
// 300:         cache["packages_index"].cask_names
// 301:       end
// 302:
// 303:       sig { params(name: String).returns(T::Boolean) }
// 304:       def self.cask_name?(name)
// 305:         ensure_cask_data!
// 306:         return cache["cask_hashes"].key?(name) if cache.key?("cask_hashes")
// 307:
// 308:         cache["packages_index"].cask_name?(name)
// 309:       end
// 310:
// 311:       sig { returns(T::Hash[String, String]) }
// 312:       def self.cask_renames
// 313:         ensure_cask_data!
// 314:         packages_value("cask_renames")
// 315:       end
// 316:
// 317:       sig { returns(T::Hash[String, String]) }
// 318:       def self.cask_tap_migrations
// 319:         ensure_cask_data!
// 320:         packages_value("cask_tap_migrations")
// 321:       end
// 322:
// 323:       sig { returns(String) }
// 324:       def self.cask_tap_git_head
// 325:         ensure_cask_data!
// 326:         packages_value("cask_tap_git_head")
// 327:       end
// 328:     end
// 329:   end
// 330: end
// 331:
// 332: require "extend/os/api/internal"
