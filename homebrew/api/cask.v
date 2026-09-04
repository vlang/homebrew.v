module api

import ruby
import os

// Translated from Homebrew/brew `api/cask.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `self.cask_json(name)` at line 23.
pub fn ruby_cask_l23_d1_self_cask_json(args ...ruby.Value) ruby.Value {
	mut state := cask_state_from_args(args, 'cask_json')
	if args.len < 2 {
		return cask_error_value('ArgumentError', 'name is required')
	}
	return ruby.map_value(cask_json(mut state, args[1].as_string()) or {
		return cask_error_value('RuntimeError', err.msg())
	})
}

// Ruby method `self.fetch_cask_json!(name)` at line 30.
pub fn ruby_cask_l30_d2_self_fetch_cask_json(args ...ruby.Value) ruby.Value {
	mut state := cask_state_from_args(args, 'fetch_cask_json!')
	if args.len < 2 {
		return cask_error_value('ArgumentError', 'name is required')
	}
	fetch_cask_json(mut state, args[1].as_string()) or {
		return cask_error_value('RuntimeError', err.msg())
	}
	return cask_nil_value()
}

// Ruby method `self.source_download(cask, download_queue: nil, enqueue: false)` at line 47.
pub fn ruby_cask_l47_d3_self_source_download(args ...ruby.Value) ruby.Value {
	mut state := cask_state_from_args(args, 'source_download')
	if args.len < 2 {
		return cask_error_value('ArgumentError', 'cask is required')
	}
	enqueue := args.len > 2 && args[args.len - 1].type_name == 'Bool' && args[args.len - 1].bool_data
	return cask_source_download_value(cask_source_download(mut state, cask_source_from_value(args[1]), enqueue))
}

// Ruby method `self.source_download_for(cask)` at line 62.
pub fn ruby_cask_l62_d4_self_source_download_for(args ...ruby.Value) ruby.Value {
	state := cask_state_from_args(args, 'source_download_for')
	if args.len < 2 {
		return cask_error_value('ArgumentError', 'cask is required')
	}
	return cask_source_download_value(cask_source_download_for(state, cask_source_from_value(args[1])))
}

// Ruby method `self.source_download_cask(cask)` at line 80.
pub fn ruby_cask_l80_d5_self_source_download_cask(args ...ruby.Value) ruby.Value {
	mut state := cask_state_from_args(args, 'source_download_cask')
	if args.len < 2 {
		return cask_error_value('ArgumentError', 'cask is required')
	}
	loaded := cask_source_download_cask(mut state, cask_source_from_value(args[1])) or {
		return cask_error_value('RuntimeError', err.msg())
	}
	return cask_loaded_source_value(loaded)
}

// Ruby method `self.cached_json_file_path` at line 88.
pub fn ruby_cask_l88_d6_self_cached_json_file_path(args ...ruby.Value) ruby.Value {
	state := cask_state_from_args(args, 'cached_json_file_path')
	return ruby.object_value('Pathname', cask_cached_json_file_path(state))
}

// Ruby method `self.fetch_api!(download_queue: nil, stale_seconds: nil, enqueue: false)` at line 96.
pub fn ruby_cask_l96_d7_self_fetch_api(args ...ruby.Value) ruby.Value {
	mut state := cask_state_from_args(args, 'fetch_api!')
	stale_seconds := if args.len > 1 && args[1].type_name == 'Integer' {
		?i64(args[1].int_data)
	} else {
		none
	}
	enqueue := args.len > 2 && args[2].bool_data
	result := cask_fetch_api(mut state, stale_seconds, enqueue) or {
		return cask_error_value('RuntimeError', err.msg())
	}
	return ruby.array_value([result.data, ruby.bool_value(result.updated)])
}

// Ruby method `self.fetch_tap_migrations!(download_queue: nil, stale_seconds: nil, enqueue: false)` at line 104.
pub fn ruby_cask_l104_d8_self_fetch_tap_migrations(args ...ruby.Value) ruby.Value {
	mut state := cask_state_from_args(args, 'fetch_tap_migrations!')
	stale_seconds := if args.len > 1 && args[1].type_name == 'Integer' {
		?i64(args[1].int_data)
	} else {
		none
	}
	enqueue := args.len > 2 && args[2].bool_data
	result := cask_fetch_tap_migrations(mut state, stale_seconds, enqueue) or {
		return cask_error_value('RuntimeError', err.msg())
	}
	return ruby.array_value([result.data, ruby.bool_value(result.updated)])
}

// Ruby method `self.download_and_cache_data!` at line 109.
pub fn ruby_cask_l109_d9_self_download_and_cache_data(args ...ruby.Value) ruby.Value {
	mut state := cask_state_from_args(args, 'download_and_cache_data!')
	return ruby.bool_value(cask_download_and_cache_data(mut state) or {
		return cask_error_value('RuntimeError', err.msg())
	})
}

// Ruby method `self.all_casks` at line 128.
pub fn ruby_cask_l128_d10_self_all_casks(args ...ruby.Value) ruby.Value {
	mut state := cask_state_from_args(args, 'all_casks')
	return cask_map_value(cask_all_casks(mut state) or {
		return cask_error_value('RuntimeError', err.msg())
	})
}

// Ruby method `self.tap_migrations` at line 138.
pub fn ruby_cask_l138_d11_self_tap_migrations(args ...ruby.Value) ruby.Value {
	mut state := cask_state_from_args(args, 'tap_migrations')
	return ruby.map_value(cask_tap_migrations(mut state) or {
		return cask_error_value('RuntimeError', err.msg())
	})
}

// Ruby method `self.write_names(regenerate: false)` at line 148.
pub fn ruby_cask_l148_d12_self_write_names(args ...ruby.Value) ruby.Value {
	mut state := cask_state_from_args(args, 'write_names')
	regenerate := args.len > 1 && args[1].bool_data
	cask_write_names(mut state, regenerate) or {
		return cask_error_value('RuntimeError', err.msg())
	}
	return cask_nil_value()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cachable"
// 5: require "api"
// 6: require "api/source_download"
// 7: require "api/cask/cask_struct_generator"
// 8:
// 9: module Homebrew
// 10:   module API
// 11:     # Helper functions for using the cask JSON API.
// 12:     module Cask
// 13:       extend T::Generic
// 14:       extend Cachable
// 15:
// 16:       Cache = type_template { { fixed: T::Hash[String, T.untyped] } }
// 17:
// 18:       DEFAULT_API_FILENAME = "cask.jws.json"
// 19:
// 20:       private_class_method :cache
// 21:
// 22:       sig { params(name: String).returns(T::Hash[String, T.untyped]) }
// 23:       def self.cask_json(name)
// 24:         fetch_cask_json! name if !cache.key?("cask_json") || !cache.fetch("cask_json").key?(name)
// 25:
// 26:         cache.fetch("cask_json").fetch(name)
// 27:       end
// 28:
// 29:       sig { params(name: String).void }
// 30:       def self.fetch_cask_json!(name)
// 31:         endpoint = "cask/#{name}.json"
// 32:         json_cask, updated = Homebrew::API.fetch_json_api_file endpoint
// 33:
// 34:         json_cask = JSON.parse((HOMEBREW_CACHE_API/endpoint).read) unless updated
// 35:
// 36:         cache["cask_json"] ||= {}
// 37:         cache["cask_json"][name] = json_cask
// 38:       end
// 39:
// 40:       sig {
// 41:         params(
// 42:           cask:           ::Cask::Cask,
// 43:           download_queue: DownloadQueueType,
// 44:           enqueue:        T::Boolean,
// 45:         ).returns(Homebrew::API::SourceDownload)
// 46:       }
// 47:       def self.source_download(cask, download_queue: nil, enqueue: false)
// 48:         download = source_download_for(cask)
// 49:
// 50:         if enqueue
// 51:           require "download_queue"
// 52:           download_queue ||= Homebrew.default_download_queue
// 53:           download_queue.enqueue(download)
// 54:         elsif !download.symlink_location.exist?
// 55:           download.fetch
// 56:         end
// 57:
// 58:         download
// 59:       end
// 60:
// 61:       sig { params(cask: ::Cask::Cask).returns(Homebrew::API::SourceDownload) }
// 62:       def self.source_download_for(cask)
// 63:         path = cask.ruby_source_path.to_s
// 64:         sha256 = cask.ruby_source_checksum[:sha256]
// 65:         checksum = Checksum.new(sha256) if sha256
// 66:         git_head = cask.tap_git_head || "HEAD"
// 67:         tap = cask.tap&.full_name || "Homebrew/homebrew-cask"
// 68:
// 69:         Homebrew::API::SourceDownload.new(
// 70:           "https://raw.githubusercontent.com/#{tap}/#{git_head}/#{path}",
// 71:           checksum,
// 72:           mirrors: [
// 73:             "#{HOMEBREW_API_DEFAULT_DOMAIN}/cask-source/#{File.basename(path)}",
// 74:           ],
// 75:           cache:   HOMEBREW_CACHE_API_SOURCE/"#{tap}/#{git_head}/Cask",
// 76:         )
// 77:       end
// 78:
// 79:       sig { params(cask: ::Cask::Cask).returns(::Cask::Cask) }
// 80:       def self.source_download_cask(cask)
// 81:         download = source_download(cask)
// 82:
// 83:         ::Cask::CaskLoader::FromPathLoader.new(download.symlink_location)
// 84:                                           .load(config: cask.config)
// 85:       end
// 86:
// 87:       sig { returns(Pathname) }
// 88:       def self.cached_json_file_path
// 89:         HOMEBREW_CACHE_API/DEFAULT_API_FILENAME
// 90:       end
// 91:
// 92:       sig {
// 93:         params(download_queue: DownloadQueueType, stale_seconds: T.nilable(Integer), enqueue: T::Boolean)
// 94:           .returns([T.any(T::Array[T.untyped], T::Hash[String, T.untyped]), T::Boolean])
// 95:       }
// 96:       def self.fetch_api!(download_queue: nil, stale_seconds: nil, enqueue: false)
// 97:         Homebrew::API.fetch_json_api_file DEFAULT_API_FILENAME, stale_seconds:, download_queue:, enqueue:
// 98:       end
// 99:
// 100:       sig {
// 101:         params(download_queue: DownloadQueueType, stale_seconds: T.nilable(Integer), enqueue: T::Boolean)
// 102:           .returns([T.any(T::Array[T.untyped], T::Hash[String, T.untyped]), T::Boolean])
// 103:       }
// 104:       def self.fetch_tap_migrations!(download_queue: nil, stale_seconds: nil, enqueue: false)
// 105:         Homebrew::API.fetch_json_api_file "cask_tap_migrations.jws.json", stale_seconds:, download_queue:, enqueue:
// 106:       end
// 107:
// 108:       sig { returns(T::Boolean) }
// 109:       def self.download_and_cache_data!
// 110:         json_casks, updated = fetch_api!
// 111:
// 112:         cache["renames"] = {}
// 113:         cache["casks"] = json_casks.to_h do |json_cask|
// 114:           token = json_cask["token"]
// 115:
// 116:           json_cask.fetch("old_tokens", []).each do |old_token|
// 117:             cache["renames"][old_token] = token
// 118:           end
// 119:
// 120:           [token, json_cask.except("token")]
// 121:         end
// 122:
// 123:         updated
// 124:       end
// 125:       private_class_method :download_and_cache_data!
// 126:
// 127:       sig { returns(T::Hash[String, T::Hash[String, T.untyped]]) }
// 128:       def self.all_casks
// 129:         unless cache.key?("casks")
// 130:           json_updated = download_and_cache_data!
// 131:           write_names(regenerate: json_updated)
// 132:         end
// 133:
// 134:         cache.fetch("casks")
// 135:       end
// 136:
// 137:       sig { returns(T::Hash[String, T.untyped]) }
// 138:       def self.tap_migrations
// 139:         unless cache.key?("tap_migrations")
// 140:           json_migrations, = fetch_tap_migrations!
// 141:           cache["tap_migrations"] = json_migrations
// 142:         end
// 143:
// 144:         cache.fetch("tap_migrations")
// 145:       end
// 146:
// 147:       sig { params(regenerate: T::Boolean).void }
// 148:       def self.write_names(regenerate: false)
// 149:         download_and_cache_data! unless cache.key?("casks")
// 150:
// 151:         Homebrew::API.write_names_file!("cask", regenerate:) { all_casks.keys }
// 152:       end
// 153:     end
// 154:   end
// 155: end
