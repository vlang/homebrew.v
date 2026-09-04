module api

import ruby
import os

// Translated from Homebrew/brew `api/cask.rb`.
const cask_default_api_domain = 'https://formulae.brew.sh/api'
const cask_default_api_filename = 'cask.jws.json'

pub struct CaskApiFetchResult {
pub:
	data    ruby.Value
	updated bool
}

pub struct CaskSource {
pub:
	token                string
	ruby_source_path     string
	ruby_source_checksum string
	tap_git_head         string
	tap_full_name        string
	config               ruby.Value
}

pub struct LoadedCaskSource {
pub:
	token    string
	path     string
	contents string
	config   ruby.Value
}

@[heap]
pub struct CaskApiState {
pub mut:
	cache_directory        string
	source_cache_directory string
	api_domain             string = cask_default_api_domain
	fetch_results          map[string]CaskApiFetchResult
	cask_json_cache        map[string]map[string]ruby.Value
	casks                  map[string]map[string]ruby.Value
	casks_loaded           bool
	renames                map[string]string
	tap_migrations         map[string]ruby.Value
	tap_migrations_loaded  bool
	fetched_endpoints      []string
	last_stale_seconds     ?i64
	last_fetch_enqueued    bool
	queued_downloads       []SourceDownload
	fetched_downloads      []SourceDownload
	written_names          []string
	names_regenerated      bool
	names_file             string
}

pub fn new_cask_api_state(cache_directory string, source_cache_directory string) CaskApiState {
	return CaskApiState{
		cache_directory: cache_directory
		source_cache_directory: source_cache_directory
	}
}

fn cask_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn cask_error_value(kind string, message string) ruby.Value {
	return ruby.structured_value(kind, message, {
		'message': message
	})
}

fn cask_value_strings(value ruby.Value) []string {
	if value.string_array_data.len > 0 {
		return value.string_array_data.clone()
	}
	return value.array_data.map(it.as_string())
}

fn cask_fetch_json_api_file(mut state CaskApiState, endpoint string, stale_seconds ?i64,
	enqueue bool) !CaskApiFetchResult {
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
	return CaskApiFetchResult{
		data: ruby.parse_json_value(os.read_file(path)!)!
	}
}

pub fn cask_json(mut state CaskApiState, name string) !map[string]ruby.Value {
	if cached := state.cask_json_cache[name] {
		return cached.clone()
	}
	fetch_cask_json(mut state, name)!
	return (state.cask_json_cache[name] or { return error('No cask JSON found for ${name}') }).clone()
}

pub fn fetch_cask_json(mut state CaskApiState, name string) ! {
	endpoint := 'cask/${name}.json'
	result := cask_fetch_json_api_file(mut state, endpoint, none, false)!
	mut json_cask := result.data
	if !result.updated {
		path := os.join_path(state.cache_directory, endpoint)
		json_cask = ruby.parse_json_value(os.read_file(path)!)!
	}
	if json_cask.type_name != 'Hash' {
		return error('${endpoint} did not contain a cask JSON object')
	}
	state.cask_json_cache[name] = json_cask.map_data.clone()
}

pub fn cask_source_download_for(state CaskApiState, cask CaskSource) SourceDownload {
	git_head := if cask.tap_git_head == '' { 'HEAD' } else { cask.tap_git_head }
	tap := if cask.tap_full_name == '' { 'Homebrew/homebrew-cask' } else { cask.tap_full_name }
	api_domain := if state.api_domain == '' {
		cask_default_api_domain
	} else {
		state.api_domain.trim_string_right('/')
	}
	cache := os.join_path(state.source_cache_directory, tap, git_head, 'Cask')
	checksum := if cask.ruby_source_checksum == '' {
		?string(none)
	} else {
		?string(cask.ruby_source_checksum)
	}
	return new_source_download(
		'https://raw.githubusercontent.com/${tap}/${git_head}/${cask.ruby_source_path}',
		checksum,
		['${api_domain}/cask-source/${os.base(cask.ruby_source_path)}'],
		cache,
		cache,
	)
}

pub fn cask_source_download(mut state CaskApiState, cask CaskSource, enqueue bool) SourceDownload {
	download := cask_source_download_for(state, cask)
	if enqueue {
		state.queued_downloads << download
	} else if !os.exists(source_download_strategy_symlink_location(download.downloader)) {
		state.fetched_downloads << download
	}
	return download
}

pub fn cask_source_download_cask(mut state CaskApiState, cask CaskSource) !LoadedCaskSource {
	download := cask_source_download(mut state, cask, false)
	path := source_download_strategy_symlink_location(download.downloader)
	return LoadedCaskSource{
		token: cask.token
		path: path
		contents: os.read_file(path)!
		config: cask.config
	}
}

pub fn cask_cached_json_file_path(state CaskApiState) string {
	return os.join_path(state.cache_directory, cask_default_api_filename)
}

pub fn cask_fetch_api(mut state CaskApiState, stale_seconds ?i64,
	enqueue bool) !CaskApiFetchResult {
	return cask_fetch_json_api_file(mut state, cask_default_api_filename, stale_seconds, enqueue)
}

pub fn cask_fetch_tap_migrations(mut state CaskApiState, stale_seconds ?i64,
	enqueue bool) !CaskApiFetchResult {
	return cask_fetch_json_api_file(mut state, 'cask_tap_migrations.jws.json', stale_seconds, enqueue)
}

pub fn cask_download_and_cache_data(mut state CaskApiState) !bool {
	result := cask_fetch_api(mut state, none, false)!
	if result.data.type_name != 'Array' {
		return error('${cask_default_api_filename} did not contain an array')
	}
	state.renames = map[string]string{}
	state.casks = map[string]map[string]ruby.Value{}
	for json_cask in result.data.array_data {
		if json_cask.type_name != 'Hash' {
			return error('${cask_default_api_filename} contained a non-object entry')
		}
		token_value := json_cask.map_data['token'] or {
			return error('${cask_default_api_filename} entry is missing token')
		}
		token := token_value.as_string()
		for old_token in cask_value_strings(json_cask.map_data['old_tokens'] or {
			ruby.string_array_value([])
		}) {
			state.renames[old_token] = token
		}
		mut cask_data := json_cask.map_data.clone()
		cask_data.delete('token')
		state.casks[token] = cask_data.clone()
	}
	state.casks_loaded = true
	return result.updated
}

pub fn cask_all_casks(mut state CaskApiState) !map[string]map[string]ruby.Value {
	if !state.casks_loaded {
		updated := cask_download_and_cache_data(mut state)!
		cask_write_names(mut state, updated)!
	}
	return state.casks.clone()
}

pub fn cask_tap_migrations(mut state CaskApiState) !map[string]ruby.Value {
	if !state.tap_migrations_loaded {
		result := cask_fetch_tap_migrations(mut state, none, false)!
		if result.data.type_name != 'Hash' {
			return error('cask_tap_migrations.jws.json did not contain an object')
		}
		state.tap_migrations = result.data.map_data.clone()
		state.tap_migrations_loaded = true
	}
	return state.tap_migrations.clone()
}

pub fn cask_write_names(mut state CaskApiState, regenerate bool) ! {
	if !state.casks_loaded {
		cask_download_and_cache_data(mut state)!
	}
	mut names := state.casks.keys()
	names.sort()
	state.written_names = names
	state.names_regenerated = regenerate
	if state.names_file != '' {
		os.mkdir_all(os.dir(state.names_file))!
		contents := if names.len == 0 { '' } else { '${names.join('\n')}\n' }
		os.write_file(state.names_file, contents)!
	}
}

pub fn cask_api_state_boundary(state &CaskApiState) ruby.Value {
	return ruby.structured_value('Homebrew::API::Cask', '', {
		'cask_api_state_address': u64(voidptr(state)).str()
	})
}

pub fn cask_source_boundary(cask CaskSource) ruby.Value {
	return ruby.structured_value('Cask::Cask', cask.token, {
		'token':                cask.token
		'ruby_source_path':     cask.ruby_source_path
		'ruby_source_checksum': cask.ruby_source_checksum
		'tap_git_head':         cask.tap_git_head
		'tap_full_name':        cask.tap_full_name
		'config_type':          cask.config.type_name
		'config_repr':          cask.config.repr
	})
}

fn cask_state_from_args(args []ruby.Value, method string) &CaskApiState {
	if args.len == 0 || 'cask_api_state_address' !in args[0].attributes {
		panic('API::Cask.${method} requires translated Cask API state')
	}
	return unsafe { &CaskApiState(voidptr(args[0].attributes['cask_api_state_address'].u64())) }
}

fn cask_source_from_value(value ruby.Value) CaskSource {
	return CaskSource{
		token: value.attributes['token'] or { value.repr }
		ruby_source_path: value.attributes['ruby_source_path'] or { '' }
		ruby_source_checksum: value.attributes['ruby_source_checksum'] or { '' }
		tap_git_head: value.attributes['tap_git_head'] or { '' }
		tap_full_name: value.attributes['tap_full_name'] or { '' }
		config: ruby.object_value(value.attributes['config_type'] or { 'NilClass' }, value.attributes['config_repr'] or { 'nil' })
	}
}

fn cask_source_download_value(download SourceDownload) ruby.Value {
	return ruby.structured_value('Homebrew::API::SourceDownload', download.url, {
		'url':              download.url
		'sha256':           download.checksum or { '' }
		'mirror':           if download.mirrors.len > 0 { download.mirrors[0] } else { '' }
		'cache':            download.downloader.cache
		'symlink_location': source_download_strategy_symlink_location(download.downloader)
	})
}

fn cask_loaded_source_value(loaded LoadedCaskSource) ruby.Value {
	return ruby.structured_value('Cask::Cask', loaded.token, {
		'token':    loaded.token
		'path':     loaded.path
		'contents': loaded.contents
		'config':   loaded.config.repr
	})
}

fn cask_map_value(values map[string]map[string]ruby.Value) ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in values {
		result[key] = ruby.map_value(value)
	}
	return ruby.map_value(result)
}
