module api

import brew_runtime

// Translated from Homebrew/brew `api/formula.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.formula_json(name)` at line 23.
pub fn ruby_formula_l23_d1_self_formula_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_json', ...args)
}

// Ruby method `self.fetch_formula_json!(name)` at line 30.
pub fn ruby_formula_l30_d2_self_fetch_formula_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.fetch_formula_json!', ...args)
}

// Ruby method `self.source_download_path(formula, path, checksum: nil, download_queue: nil, enqueue: false)` at line 49.
pub fn ruby_formula_l49_d3_self_source_download_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.source_download_path', ...args)
}

// Ruby method `self.source_download(formula, download_queue: nil, enqueue: false)` at line 85.
pub fn ruby_formula_l85_d4_self_source_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.source_download', ...args)
}

// Ruby method `self.source_download_formula(formula)` at line 91.
pub fn ruby_formula_l91_d5_self_source_download_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.source_download_formula', ...args)
}

// Ruby method `self.cached_json_file_path` at line 120.
pub fn ruby_formula_l120_d6_self_cached_json_file_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cached_json_file_path', ...args)
}

// Ruby method `self.fetch_api!(download_queue: nil, stale_seconds: nil, enqueue: false)` at line 128.
pub fn ruby_formula_l128_d7_self_fetch_api(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.fetch_api!', ...args)
}

// Ruby method `self.fetch_tap_migrations!(download_queue: nil, stale_seconds: nil, enqueue: false)` at line 136.
pub fn ruby_formula_l136_d8_self_fetch_tap_migrations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.fetch_tap_migrations!', ...args)
}

// Ruby method `self.download_and_cache_data!` at line 141.
pub fn ruby_formula_l141_d9_self_download_and_cache_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.download_and_cache_data!', ...args)
}

// Ruby method `self.all_formulae` at line 162.
pub fn ruby_formula_l162_d10_self_all_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.all_formulae', ...args)
}

// Ruby method `self.all_aliases` at line 172.
pub fn ruby_formula_l172_d11_self_all_aliases(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.all_aliases', ...args)
}

// Ruby method `self.tap_migrations` at line 182.
pub fn ruby_formula_l182_d12_self_tap_migrations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.tap_migrations', ...args)
}

// Ruby method `self.write_names_and_aliases(regenerate: false)` at line 192.
pub fn ruby_formula_l192_d13_self_write_names_and_aliases(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.write_names_and_aliases', ...args)
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
