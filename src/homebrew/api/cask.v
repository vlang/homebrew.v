module api

import brew_runtime

// Translated from Homebrew/brew `api/cask.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.cask_json(name)` at line 23.
pub fn ruby_cask_l23_d1_self_cask_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_json', ...args)
}

// Ruby method `self.fetch_cask_json!(name)` at line 30.
pub fn ruby_cask_l30_d2_self_fetch_cask_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.fetch_cask_json!', ...args)
}

// Ruby method `self.source_download(cask, download_queue: nil, enqueue: false)` at line 47.
pub fn ruby_cask_l47_d3_self_source_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.source_download', ...args)
}

// Ruby method `self.source_download_for(cask)` at line 62.
pub fn ruby_cask_l62_d4_self_source_download_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.source_download_for', ...args)
}

// Ruby method `self.source_download_cask(cask)` at line 80.
pub fn ruby_cask_l80_d5_self_source_download_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.source_download_cask', ...args)
}

// Ruby method `self.cached_json_file_path` at line 88.
pub fn ruby_cask_l88_d6_self_cached_json_file_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cached_json_file_path', ...args)
}

// Ruby method `self.fetch_api!(download_queue: nil, stale_seconds: nil, enqueue: false)` at line 96.
pub fn ruby_cask_l96_d7_self_fetch_api(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.fetch_api!', ...args)
}

// Ruby method `self.fetch_tap_migrations!(download_queue: nil, stale_seconds: nil, enqueue: false)` at line 104.
pub fn ruby_cask_l104_d8_self_fetch_tap_migrations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.fetch_tap_migrations!', ...args)
}

// Ruby method `self.download_and_cache_data!` at line 109.
pub fn ruby_cask_l109_d9_self_download_and_cache_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.download_and_cache_data!', ...args)
}

// Ruby method `self.all_casks` at line 128.
pub fn ruby_cask_l128_d10_self_all_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.all_casks', ...args)
}

// Ruby method `self.tap_migrations` at line 138.
pub fn ruby_cask_l138_d11_self_tap_migrations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.tap_migrations', ...args)
}

// Ruby method `self.write_names(regenerate: false)` at line 148.
pub fn ruby_cask_l148_d12_self_write_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.write_names', ...args)
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
