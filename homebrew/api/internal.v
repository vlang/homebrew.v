module api

import ruby
import os

// Translated from Homebrew/brew `api/internal.rb`.

pub struct InternalFetchResult {
pub:
	indexed bool
	index   PackagesIndex
	parsed  ruby.Value
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
	formula_hashes          map[string]ruby.Value
	cask_hashes             map[string]ruby.Value
	formula_structs         map[string]FormulaStruct
	cask_structs            map[string]CaskStruct
	values                  map[string]ruby.Value
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
	header := ruby.parse_json_value(contents[..newline]) or { return none }
	if header.type_name != 'Hash' {
		return none
	}
	stat := packages_source_stat(target) or { return none }
	if (header.map_data['source_size'] or { ruby.int_value(-1) }).int_data != stat.size || (header.map_data['source_mtime_ns'] or { ruby.int_value(-1) }).int_data != stat.mtime_ns {
		return none
	}
	payload := contents[newline + 1..]
	if loaded := packages_index_load(target, payload, stat) {
		return loaded
	}
	parsed := ruby.parse_json_value(payload) or { return none }
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
				parsed := ruby.parse_json_value(contents[newline + 1..])!
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
	return InternalFetchResult{ parsed: ruby.parse_json_value(state.fetch_payload)!, updated: state.fetch_updated }
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

pub fn internal_cache_parsed_packages(mut state InternalApiState, json_contents ruby.Value) {
	state.packages_index_present = false
	for key in ['formula_aliases', 'formula_renames', 'cask_renames', 'formula_tap_git_head',
		'cask_tap_git_head', 'formula_tap_migrations', 'cask_tap_migrations'] {
		state.values[key] = json_contents.map_data[key] or { internal_nil_value() }
	}
	state.formula_hashes = internal_value_map(json_contents.map_data['formulae'] or { ruby.map_value(map[string]ruby.Value{}) })
	state.cask_hashes = internal_value_map(json_contents.map_data['casks'] or { ruby.map_value(map[string]ruby.Value{}) })
	state.formula_hashes_present = true
	state.cask_hashes_present = true
}

pub fn internal_materialize_packages_index(mut state InternalApiState) ! {
	if !state.packages_index_present {
		return
	}
	index := state.packages_index
	parsed := ruby.parse_json_value(index.payload)!
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

pub fn internal_packages_value(mut state InternalApiState, key string) !ruby.Value {
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

pub fn internal_formula_hashes(mut state InternalApiState) !map[string]ruby.Value {
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

fn internal_write_executables(path string, regenerate bool, formulae map[string]ruby.Value) ! {
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

fn internal_value_map(value ruby.Value) map[string]ruby.Value {
	return if value.type_name == 'Hash' {
		value.map_data.clone()
	} else {
		map[string]ruby.Value{}
	}
}

fn internal_string_map(value ruby.Value) map[string]string {
	mut result := map[string]string{}
	for key, item in internal_value_map(value) {
		result[key] = item.as_string()
	}
	return result
}

fn internal_nil_value() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}
