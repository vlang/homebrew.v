module homebrew

import brew_runtime

// Translated from Homebrew/brew `api.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.fetch(endpoint)` at line 34.
pub fn ruby_api_l34_d1_self_fetch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.fetch', ...args)
}

// Ruby method `self.skip_download?(target:, stale_seconds:)` at line 52.
pub fn ruby_api_l52_d2_self_skip_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.skip_download?', ...args)
}

// Ruby method `self.fetch_json_api_file(endpoint, target: HOMEBREW_CACHE_API/endpoint,` at line 69.
pub fn ruby_api_l69_d3_self_fetch_json_api_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.fetch_json_api_file', ...args)
}

// Ruby method `self.merge_variations(json, bottle_tag: T.unsafe(nil))` at line 194.
pub fn ruby_api_l194_d4_self_merge_variations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.merge_variations', ...args)
}

// Ruby method `self.fetch_api_files!` at line 208.
pub fn ruby_api_l208_d5_self_fetch_api_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.fetch_api_files!', ...args)
}

// Ruby method `self.write_names_and_aliases` at line 240.
pub fn ruby_api_l240_d6_self_write_names_and_aliases(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.write_names_and_aliases', ...args)
}

// Ruby method `self.write_names_file!(type, regenerate:, &names)` at line 246.
pub fn ruby_api_l246_d7_self_write_names_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.write_names_file!', ...args)
}

// Ruby method `self.write_aliases_file!(type, regenerate:, &aliases)` at line 261.
pub fn ruby_api_l261_d8_self_write_aliases_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.write_aliases_file!', ...args)
}

// Ruby method `self.write_executables_file!(regenerate:, source:, &formulae)` at line 282.
pub fn ruby_api_l282_d9_self_write_executables_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.write_executables_file!', ...args)
}

// Ruby method `self.download_executables_file_from_github_packages!(target)` at line 314.
pub fn ruby_api_l314_d10_self_download_executables_file_from_github_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.download_executables_file_from_github_packages!',
		...args)
}

// Ruby method `self.verify_and_parse_jws(json_data)` at line 357.
pub fn ruby_api_l357_d11_self_verify_and_parse_jws(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.verify_and_parse_jws', ...args)
}

// Ruby method `self.homebrew_jws_signature(json_data)` at line 370.
pub fn ruby_api_l370_d12_self_homebrew_jws_signature(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.homebrew_jws_signature', ...args)
}

// Ruby method `self.verify_jws_signature(protected_b64, signature_b64, payload)` at line 377.
pub fn ruby_api_l377_d13_self_verify_jws_signature(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.verify_jws_signature', ...args)
}

// Ruby method `self.jws_public_key_pem` at line 396.
pub fn ruby_api_l396_d14_self_jws_public_key_pem(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.jws_public_key_pem', ...args)
}

// Ruby method `self.jws_payload_cache_path(target)` at line 401.
pub fn ruby_api_l401_d15_self_jws_payload_cache_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.jws_payload_cache_path', ...args)
}

// Ruby method `self.jws_payload_cacheable?(target)` at line 410.
pub fn ruby_api_l410_d16_self_jws_payload_cacheable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.jws_payload_cacheable?', ...args)
}

// Ruby method `self.jws_source_fingerprint(stat)` at line 418.
pub fn ruby_api_l418_d17_self_jws_source_fingerprint(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.jws_source_fingerprint', ...args)
}

// Ruby method `self.cached_internal_packages_payload(endpoint, stale_seconds:)` at line 433.
pub fn ruby_api_l433_d18_self_cached_internal_packages_payload(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cached_internal_packages_payload', ...args)
}

// Ruby method `self.cached_jws_payload(target)` at line 453.
pub fn ruby_api_l453_d19_self_cached_jws_payload(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cached_jws_payload', ...args)
}

// Ruby method `self.cached_jws_payload_string(target, source_stat:)` at line 463.
pub fn ruby_api_l463_d20_self_cached_jws_payload_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cached_jws_payload_string', ...args)
}

// Ruby method `self.write_jws_payload_index_cache(target, json_data, parsed:, source_stat:)` at line 498.
pub fn ruby_api_l498_d21_self_write_jws_payload_index_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.write_jws_payload_index_cache', ...args)
}

// Ruby method `self.write_jws_payload_cache(target, json_data, source_stat:)` at line 512.
pub fn ruby_api_l512_d22_self_write_jws_payload_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.write_jws_payload_cache', ...args)
}

// Ruby method `self.urlsafe_decode64(value)` at line 546.
pub fn ruby_api_l546_d23_self_urlsafe_decode64(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.urlsafe_decode64', ...args)
}

// Ruby method `self.tap_from_source_download(path)` at line 551.
pub fn ruby_api_l551_d24_self_tap_from_source_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.tap_from_source_download', ...args)
}

// Ruby method `self.formula_names` at line 563.
pub fn ruby_api_l563_d25_self_formula_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_names', ...args)
}

// Ruby method `self.formula_name?(name)` at line 568.
pub fn ruby_api_l568_d26_self_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_name?', ...args)
}

// Ruby method `self.formula_aliases` at line 573.
pub fn ruby_api_l573_d27_self_formula_aliases(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_aliases', ...args)
}

// Ruby method `self.formula_renames` at line 578.
pub fn ruby_api_l578_d28_self_formula_renames(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_renames', ...args)
}

// Ruby method `self.formula_tap_migrations` at line 583.
pub fn ruby_api_l583_d29_self_formula_tap_migrations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formula_tap_migrations', ...args)
}

// Ruby method `self.cask_tokens` at line 588.
pub fn ruby_api_l588_d30_self_cask_tokens(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_tokens', ...args)
}

// Ruby method `self.cask_token?(token)` at line 593.
pub fn ruby_api_l593_d31_self_cask_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_token?', ...args)
}

// Ruby method `self.cask_renames` at line 598.
pub fn ruby_api_l598_d32_self_cask_renames(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_renames', ...args)
}

// Ruby method `self.cask_tap_migrations` at line 603.
pub fn ruby_api_l603_d33_self_cask_tap_migrations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask_tap_migrations', ...args)
}

// Ruby method `self.cached_cask_json_file_path` at line 608.
pub fn ruby_api_l608_d34_self_cached_cask_json_file_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cached_cask_json_file_path', ...args)
}

// Ruby method `self.with_no_api_env(&block)` at line 614.
pub fn ruby_api_l614_d35_self_with_no_api_env(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.with_no_api_env', ...args)
}

// Ruby method `self.with_no_api_env_if_needed(condition, &block)` at line 626.
pub fn ruby_api_l626_d36_self_with_no_api_env_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.with_no_api_env_if_needed', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "api/analytics"
// 5: require "utils/output"
// 6:
// 7: # Runtime signature checks happen before lazy method-body requires run.
// 8: require "download_queue" if ENV["HOMEBREW_SORBET_RUNTIME"]
// 9:
// 10: module Homebrew
// 11:   # Helper functions for using Homebrew's formulae.brew.sh API.
// 12:   module API
// 13:     DownloadQueueType = T.type_alias { T.nilable(Homebrew::DownloadQueue) }
// 14:
// 15:     require "api/cask"
// 16:     require "api/formula"
// 17:     require "api/internal"
// 18:     require "api/formula_struct"
// 19:     require "api/cask_struct"
// 20:     require "api/packages_index"
// 21:
// 22:     extend Utils::Output::Mixin
// 23:
// 24:     extend T::Generic
// 25:     extend Cachable
// 26:
// 27:     Cache = type_template { { fixed: T::Hash[String, T.untyped] } }
// 28:
// 29:     HOMEBREW_CACHE_API = T.let((HOMEBREW_CACHE/"api").freeze, Pathname)
// 30:     HOMEBREW_CACHE_API_SOURCE = T.let((HOMEBREW_CACHE/"api-source").freeze, Pathname)
// 31:     DEFAULT_API_STALE_SECONDS = T.let(7 * 24 * 60 * 60, Integer) # 7 days
// 32:
// 33:     sig { params(endpoint: String).returns(T::Hash[String, T.untyped]) }
// 34:     def self.fetch(endpoint)
// 35:       return cache[endpoint] if cache.present? && cache.key?(endpoint)
// 36:
// 37:       api_url = "#{Homebrew::EnvConfig.api_domain}/#{endpoint}"
// 38:       output = Utils::Curl.curl_output("--fail", api_url)
// 39:       if !output.success? && Homebrew::EnvConfig.api_domain != HOMEBREW_API_DEFAULT_DOMAIN
// 40:         # Fall back to the default API domain and try again
// 41:         api_url = "#{HOMEBREW_API_DEFAULT_DOMAIN}/#{endpoint}"
// 42:         output = Utils::Curl.curl_output("--fail", api_url)
// 43:       end
// 44:       raise ArgumentError, "No file found at: #{Tty.underline}#{api_url}#{Tty.reset}" unless output.success?
// 45:
// 46:       cache[endpoint] = JSON.parse(output.stdout, freeze: true)
// 47:     rescue JSON::ParserError
// 48:       raise ArgumentError, "Invalid JSON file: #{Tty.underline}#{api_url}#{Tty.reset}"
// 49:     end
// 50:
// 51:     sig { params(target: Pathname, stale_seconds: T.nilable(Integer)).returns(T::Boolean) }
// 52:     def self.skip_download?(target:, stale_seconds:)
// 53:       return true if Homebrew.running_as_root_but_not_owned_by_root?
// 54:       return false if !target.exist? || target.empty?
// 55:       return true unless stale_seconds
// 56:
// 57:       (Time.now - stale_seconds) < target.mtime
// 58:     end
// 59:
// 60:     sig {
// 61:       params(
// 62:         endpoint:       String,
// 63:         target:         Pathname,
// 64:         stale_seconds:  T.nilable(Integer),
// 65:         download_queue: DownloadQueueType,
// 66:         enqueue:        T::Boolean,
// 67:       ).returns([T.any(T::Array[T.untyped], T::Hash[String, T.untyped]), T::Boolean])
// 68:     }
// 69:     def self.fetch_json_api_file(endpoint, target: HOMEBREW_CACHE_API/endpoint,
// 70:                                  stale_seconds: nil, download_queue: nil,
// 71:                                  enqueue: false)
// 72:       # Lazy-load dependency.
// 73:       require "development_tools"
// 74:
// 75:       retry_count = 0
// 76:       url = "#{Homebrew::EnvConfig.api_domain}/#{endpoint}"
// 77:       default_url = "#{HOMEBREW_API_DEFAULT_DOMAIN}/#{endpoint}"
// 78:
// 79:       if Homebrew.running_as_root_but_not_owned_by_root? &&
// 80:          (!target.exist? || target.empty?)
// 81:         odie "Need to download #{url} but cannot as root! Run `brew update` without `sudo` first then try again."
// 82:       end
// 83:
// 84:       curl_args = Utils::Curl.curl_args(retries: 0) + [
// 85:         "--compressed",
// 86:         "--speed-limit", ENV.fetch("HOMEBREW_CURL_SPEED_LIMIT"),
// 87:         "--speed-time", ENV.fetch("HOMEBREW_CURL_SPEED_TIME"),
// 88:         # This is a Curl format token, not a Ruby one.
// 89:         # rubocop:disable Style/FormatStringToken
// 90:         "--write-out", "%{stderr}HTTP status: %{http_code}"
// 91:         # rubocop:enable Style/FormatStringToken
// 92:       ]
// 93:
// 94:       insecure_download = DevelopmentTools.ca_file_substitution_required? ||
// 95:                           DevelopmentTools.curl_substitution_required?
// 96:       skip_download = skip_download?(target:, stale_seconds:)
// 97:
// 98:       if enqueue
// 99:         unless skip_download
// 100:           require "download_queue"
// 101:           require "api/json_download"
// 102:           download_queue ||= Homebrew.default_download_queue
// 103:           download = Homebrew::API::JSONDownload.new(endpoint, target:, stale_seconds:)
// 104:           download_queue.enqueue(download)
// 105:         end
// 106:         return [{}, false]
// 107:       end
// 108:
// 109:       json_data, from_payload_cache = begin
// 110:         download_succeeded = T.let(false, T::Boolean)
// 111:         begin
// 112:           args = curl_args.dup
// 113:           args.prepend("--time-cond", target.to_s) if target.exist? && !target.empty?
// 114:           if insecure_download
// 115:             opoo DevelopmentTools.insecure_download_warning(endpoint)
// 116:             args.append("--insecure")
// 117:           end
// 118:           unless skip_download
// 119:             ohai "Downloading #{url}" if $stdout.tty? && !Context.current.quiet?
// 120:             # Disable retries here, we handle them ourselves below.
// 121:             Utils::Curl.curl_download(*args, url, to: target, retries: 0, show_error: false)
// 122:             download_succeeded = true
// 123:           end
// 124:         rescue ErrorDuringExecution
// 125:           if url == default_url
// 126:             raise unless target.exist?
// 127:             raise if target.empty?
// 128:           elsif retry_count.zero? || !target.exist? || target.empty?
// 129:             # Fall back to the default API domain and try again
// 130:             # This block will be executed only once, because we set `url` to `default_url`
// 131:             url = default_url
// 132:             target.unlink if target.exist? && target.empty?
// 133:             skip_download = false
// 134:
// 135:             retry
// 136:           end
// 137:
// 138:           opoo "#{target.basename}: update failed, falling back to cached version."
// 139:         end
// 140:
// 141:         # Only refresh the cache mtime after a successful curl revalidation/download.
// 142:         # Touching after a failed download would mark a stale cache as fresh and
// 143:         # cause `skip_download?` to short-circuit subsequent retries until cleanup.
// 144:         if download_succeeded
// 145:           mtime = insecure_download ? Time.new(1970, 1, 1) : Time.now
// 146:           FileUtils.touch(target, mtime:)
// 147:         end
// 148:
// 149:         payload_data = cached_jws_payload(target) if endpoint.end_with?(".jws.json") && !download_succeeded
// 150:         if payload_data
// 151:           [payload_data, true]
// 152:         else
// 153:           # Stat before reading: fingerprinting a concurrently-replaced file
// 154:           # against these bytes would poison the payload cache.
// 155:           source_stat = target.stat
// 156:           # Can use `target.read` again when/if https://github.com/sorbet/sorbet/pull/8999 is merged/released.
// 157:           [JSON.parse(File.read(target, encoding: Encoding::UTF_8), freeze: true), false]
// 158:         end
// 159:       rescue JSON::ParserError
// 160:         target.unlink
// 161:         retry_count += 1
// 162:         skip_download = false
// 163:         odie "Cannot download non-corrupt #{url}!" if retry_count > Homebrew::EnvConfig.curl_retries.to_i
// 164:
// 165:         retry
// 166:       end
// 167:
// 168:       if endpoint.end_with?(".jws.json") && !from_payload_cache
// 169:         success, data = verify_and_parse_jws(json_data)
// 170:         unless success
// 171:           target.unlink
// 172:           odie <<~EOS
// 173:             Failed to verify integrity (#{data}) of:
// 174:               #{url}
// 175:             Potential MITM attempt detected. Please run `brew update` and try again.
// 176:           EOS
// 177:         end
// 178:         # Skip on insecure downloads: their pinned 1970 mtime would make the
// 179:         # source fingerprint ambiguous (and they always re-download anyway).
// 180:         if source_stat && !insecure_download
// 181:           write_jws_payload_cache(target, json_data, source_stat:)
// 182:           write_jws_payload_index_cache(target, json_data, parsed: data, source_stat:)
// 183:         end
// 184:         [data, !skip_download]
// 185:       else
// 186:         [json_data, !skip_download]
// 187:       end
// 188:     end
// 189:
// 190:     sig {
// 191:       params(json:       T::Hash[String, T.untyped],
// 192:              bottle_tag: ::Utils::Bottles::Tag).returns(T::Hash[String, T.untyped])
// 193:     }
// 194:     def self.merge_variations(json, bottle_tag: T.unsafe(nil))
// 195:       return json unless json.key?("variations")
// 196:
// 197:       bottle_tag ||= Homebrew::SimulateSystem.current_tag
// 198:
// 199:       if (variation = json.dig("variations", bottle_tag.to_s).presence) ||
// 200:          (variation = json.dig("variations", bottle_tag.to_sym).presence)
// 201:         json = json.merge(variation)
// 202:       end
// 203:
// 204:       json.except("variations")
// 205:     end
// 206:
// 207:     sig { void }
// 208:     def self.fetch_api_files!
// 209:       stale_seconds = if ENV["HOMEBREW_API_UPDATED"].present? ||
// 210:                          (Homebrew::EnvConfig.no_auto_update? && !Homebrew::EnvConfig.force_api_auto_update?)
// 211:         nil
// 212:       elsif Homebrew.auto_update_command?
// 213:         Homebrew::EnvConfig.api_auto_update_secs.to_i
// 214:       else
// 215:         DEFAULT_API_STALE_SECONDS
// 216:       end
// 217:
// 218:       # The internal API is now always used; read this only to surface its deprecation.
// 219:       Homebrew::EnvConfig.use_internal_api?
// 220:       target = Internal.cached_packages_json_file_path
// 221:       if target.exist? && !target.empty? && skip_download?(target:, stale_seconds:)
// 222:         ENV["HOMEBREW_API_UPDATED"] = "1"
// 223:         return
// 224:       end
// 225:
// 226:       require "download_queue"
// 227:       download_queue = Homebrew::DownloadQueue.new
// 228:       Homebrew::API::Internal.fetch_packages_api!(download_queue:, stale_seconds:, enqueue: true)
// 229:
// 230:       ENV["HOMEBREW_API_UPDATED"] = "1"
// 231:
// 232:       begin
// 233:         download_queue.fetch(heading: "Downloading Homebrew API data")
// 234:       ensure
// 235:         download_queue.shutdown
// 236:       end
// 237:     end
// 238:
// 239:     sig { void }
// 240:     def self.write_names_and_aliases
// 241:       Homebrew::API::Internal.write_formula_names_and_aliases
// 242:       Homebrew::API::Internal.write_cask_names
// 243:     end
// 244:
// 245:     sig { params(type: String, regenerate: T::Boolean, names: T.proc.returns(T::Array[String])).returns(T::Boolean) }
// 246:     def self.write_names_file!(type, regenerate:, &names)
// 247:       names_path = HOMEBREW_CACHE_API/"#{type}_names.txt"
// 248:       if !names_path.exist? || regenerate
// 249:         names_path.unlink if names_path.exist?
// 250:         names_path.write(yield.sort.join("\n"))
// 251:         return true
// 252:       end
// 253:
// 254:       false
// 255:     end
// 256:
// 257:     sig {
// 258:       params(type: String, regenerate: T::Boolean,
// 259:              aliases: T.proc.returns(T::Hash[String, String])).returns(T::Boolean)
// 260:     }
// 261:     def self.write_aliases_file!(type, regenerate:, &aliases)
// 262:       aliases_path = HOMEBREW_CACHE_API/"#{type}_aliases.txt"
// 263:       if !aliases_path.exist? || regenerate
// 264:         aliases_text = yield.map do |alias_name, real_name|
// 265:           "#{alias_name}|#{real_name}"
// 266:         end
// 267:         aliases_path.unlink if aliases_path.exist?
// 268:         aliases_path.write(aliases_text.sort.join("\n"))
// 269:         return true
// 270:       end
// 271:
// 272:       false
// 273:     end
// 274:
// 275:     sig {
// 276:       params(
// 277:         regenerate: T::Boolean,
// 278:         source:     Pathname,
// 279:         formulae:   T.proc.returns(T::Hash[String, T::Hash[String, T.untyped]]),
// 280:       ).returns(T::Boolean)
// 281:     }
// 282:     def self.write_executables_file!(regenerate:, source:, &formulae)
// 283:       executables_path = HOMEBREW_CACHE_API/"internal/executables.txt"
// 284:       # The file is derived only from the API data in `source`, so it stays
// 285:       # current until that file next changes or is revalidated.
// 286:       executables_mtime, source_mtime = [executables_path, source].map do |path|
// 287:         path.mtime
// 288:       rescue Errno::ENOENT
// 289:         nil
// 290:       end
// 291:       return false if !regenerate && executables_mtime && source_mtime && source_mtime <= executables_mtime
// 292:
// 293:       executables_lines = yield.filter_map do |name, hash|
// 294:         executables = T.cast(hash["executables"], T.nilable(T::Array[String]))
// 295:         next if executables.blank?
// 296:
// 297:         "#{name}:#{executables.join(" ")}"
// 298:       end
// 299:       if executables_lines.empty?
// 300:         begin
// 301:           executables_path.unlink
// 302:           return true
// 303:         rescue Errno::ENOENT
// 304:           return false
// 305:         end
// 306:       end
// 307:
// 308:       executables_path.dirname.mkpath
// 309:       executables_path.write("#{executables_lines.sort.join("\n")}\n")
// 310:       true
// 311:     end
// 312:
// 313:     sig { params(target: Pathname).returns(T::Boolean) }
// 314:     def self.download_executables_file_from_github_packages!(target)
// 315:       github_packages_url = "https://ghcr.io/v2/homebrew/command-not-found/executables"
// 316:       manifest_args = [
// 317:         "--fail", "--location",
// 318:         "--header", "Accept: application/vnd.oci.image.manifest.v1+json",
// 319:         "#{github_packages_url}/manifests/latest"
// 320:       ]
// 321:       if HOMEBREW_GITHUB_PACKAGES_AUTH.present?
// 322:         manifest_args.insert(-2, "--header", "Authorization: #{HOMEBREW_GITHUB_PACKAGES_AUTH}")
// 323:       end
// 324:
// 325:       manifest_output = Utils::Curl.curl_output(*manifest_args, show_error: false)
// 326:       return false unless manifest_output.success?
// 327:
// 328:       manifest = JSON.parse(manifest_output.stdout)
// 329:       layers = T.cast(manifest.fetch("layers"), T::Array[T::Hash[String, T.untyped]])
// 330:       layer = layers.find do |candidate|
// 331:         candidate.dig("annotations", "org.opencontainers.image.title") == target.basename.to_s
// 332:       end
// 333:       return false if layer.nil?
// 334:
// 335:       digest = T.cast(layer["digest"], T.nilable(String))
// 336:       return false if digest.blank?
// 337:
// 338:       download_args = ["--fail"]
// 339:       if HOMEBREW_GITHUB_PACKAGES_AUTH.present?
// 340:         download_args += ["--header", "Authorization: #{HOMEBREW_GITHUB_PACKAGES_AUTH}"]
// 341:       end
// 342:       download_args << "#{github_packages_url}/blobs/#{digest}"
// 343:       target.dirname.mkpath
// 344:       Utils::Curl.curl_download(*download_args, to: target, show_error: false)
// 345:       FileUtils.touch(target)
// 346:       true
// 347:     rescue ErrorDuringExecution, JSON::ParserError, KeyError, TypeError
// 348:       target.unlink if target.exist? && target.empty?
// 349:
// 350:       false
// 351:     end
// 352:
// 353:     sig {
// 354:       params(json_data: T::Hash[String, T.untyped])
// 355:         .returns([T::Boolean, T.any(String, T::Array[T.untyped], T::Hash[String, T.untyped])])
// 356:     }
// 357:     private_class_method def self.verify_and_parse_jws(json_data)
// 358:       homebrew_signature = homebrew_jws_signature(json_data)
// 359:       return false, "key not found" if homebrew_signature.nil?
// 360:
// 361:       payload = json_data["payload"].to_s
// 362:       error = verify_jws_signature(homebrew_signature["protected"].to_s, homebrew_signature["signature"].to_s,
// 363:                                    payload)
// 364:       return false, error if error
// 365:
// 366:       [true, JSON.parse(payload, freeze: true)]
// 367:     end
// 368:
// 369:     sig { params(json_data: T::Hash[String, T.untyped]).returns(T.nilable(T::Hash[String, T.untyped])) }
// 370:     private_class_method def self.homebrew_jws_signature(json_data)
// 371:       signatures = json_data["signatures"]
// 372:       signatures&.find { |signature| signature.dig("header", "kid") == "homebrew-1" }
// 373:     end
// 374:
// 375:     # Returns a short error description or `nil` if the signature verifies.
// 376:     sig { params(protected_b64: String, signature_b64: String, payload: String).returns(T.nilable(String)) }
// 377:     private_class_method def self.verify_jws_signature(protected_b64, signature_b64, payload)
// 378:       header = JSON.parse(urlsafe_decode64(protected_b64))
// 379:       if !header.is_a?(Hash) || header["alg"] != "PS512" || header["b64"] != false # NOTE: nil has a meaning of true
// 380:         return "invalid algorithm"
// 381:       end
// 382:
// 383:       require "openssl"
// 384:
// 385:       pubkey = OpenSSL::PKey::RSA.new(jws_public_key_pem)
// 386:       return "signature mismatch" unless pubkey.verify_pss("SHA512",
// 387:                                                            urlsafe_decode64(signature_b64),
// 388:                                                            "#{protected_b64}.#{payload}",
// 389:                                                            salt_length: :digest,
// 390:                                                            mgf1_hash:   "SHA512")
// 391:
// 392:       nil
// 393:     end
// 394:
// 395:     sig { returns(String) }
// 396:     private_class_method def self.jws_public_key_pem
// 397:       (HOMEBREW_LIBRARY_PATH/"api/homebrew-1.pem").read
// 398:     end
// 399:
// 400:     sig { params(target: Pathname).returns(Pathname) }
// 401:     private_class_method def self.jws_payload_cache_path(target)
// 402:       Pathname("#{target}.payload")
// 403:     end
// 404:
// 405:     # Payload sidecars are only maintained for the internal packages files:
// 406:     # `brew cleanup --scrub` and `update.sh` only prune sidecars matching
// 407:     # `internal/packages.*.jws.json*` and the other `.jws.json` endpoints
// 408:     # are re-downloaded whenever they are used.
// 409:     sig { params(target: Pathname).returns(T::Boolean) }
// 410:     private_class_method def self.jws_payload_cacheable?(target)
// 411:       target.dirname == HOMEBREW_CACHE_API/"internal" &&
// 412:         target.basename.to_s.match?(/\Apackages\..*\.jws\.json\z/)
// 413:     end
// 414:
// 415:     # The size and modification time identify which envelope a cached
// 416:     # payload was extracted from.
// 417:     sig { params(stat: File::Stat).returns(T::Hash[String, Integer]) }
// 418:     private_class_method def self.jws_source_fingerprint(stat)
// 419:       {
// 420:         "source_size"     => stat.size,
// 421:         "source_mtime_ns" => (stat.mtime.to_r * 1_000_000_000).to_i,
// 422:       }
// 423:     end
// 424:
// 425:     # Returns the verified raw payload bytes, and the envelope stat they were
// 426:     # validated against, for an internal packages endpoint served entirely
// 427:     # from a fresh cached envelope's sidecar. Returns nil when a download,
// 428:     # revalidation or envelope parse is needed instead.
// 429:     sig {
// 430:       params(endpoint: String, stale_seconds: T.nilable(Integer))
// 431:         .returns(T.nilable([String, File::Stat]))
// 432:     }
// 433:     def self.cached_internal_packages_payload(endpoint, stale_seconds:)
// 434:       target = HOMEBREW_CACHE_API/endpoint
// 435:       return unless jws_payload_cacheable?(target)
// 436:       return if !target.exist? || target.empty?
// 437:       return unless skip_download?(target:, stale_seconds:)
// 438:
// 439:       source_stat = target.stat
// 440:       payload = cached_jws_payload_string(target, source_stat:)
// 441:       return if payload.nil?
// 442:
// 443:       [payload, source_stat]
// 444:     rescue SystemCallError
// 445:       nil
// 446:     end
// 447:
// 448:     # Loads the signed payload of a `.jws.json` file from the sidecar cache
// 449:     # written after a previous verification, if it still matches the file.
// 450:     # The signature is verified on every load; only re-parsing the much
// 451:     # larger envelope is skipped.
// 452:     sig { params(target: Pathname).returns(T.nilable(T.any(T::Array[T.untyped], T::Hash[String, T.untyped]))) }
// 453:     private_class_method def self.cached_jws_payload(target)
// 454:       payload = cached_jws_payload_string(target, source_stat: target.stat)
// 455:       return if payload.nil?
// 456:
// 457:       JSON.parse(payload, freeze: true)
// 458:     rescue SystemCallError, JSON::ParserError
// 459:       nil
// 460:     end
// 461:
// 462:     sig { params(target: Pathname, source_stat: File::Stat).returns(T.nilable(String)) }
// 463:     private_class_method def self.cached_jws_payload_string(target, source_stat:)
// 464:       return unless jws_payload_cacheable?(target)
// 465:
// 466:       expected_fingerprint = jws_source_fingerprint(source_stat)
// 467:
// 468:       jws_payload_cache_path(target).open("rb") do |file|
// 469:         header_line = file.gets
// 470:         next if header_line.nil?
// 471:
// 472:         header = JSON.parse(header_line)
// 473:         next unless header.is_a?(Hash)
// 474:         # Check the fingerprint before reading the payload so a stale
// 475:         # sidecar does not cost a wasted multi-megabyte read.
// 476:         next if expected_fingerprint.any? { |key, value| header[key] != value }
// 477:
// 478:         protected_b64 = header["protected"]
// 479:         signature_b64 = header["signature"]
// 480:         next if !protected_b64.is_a?(String) || !signature_b64.is_a?(String)
// 481:
// 482:         payload = file.read.force_encoding(Encoding::UTF_8)
// 483:         next unless verify_jws_signature(protected_b64, signature_b64, payload).nil?
// 484:
// 485:         payload
// 486:       end
// 487:     rescue SystemCallError, ArgumentError, JSON::ParserError
// 488:       nil
// 489:     end
// 490:
// 491:     # Writes the packages byte-offset index beside the payload sidecar so
// 492:     # later loads can parse only the entries they need.
// 493:     sig {
// 494:       params(target: Pathname, json_data: T.any(T::Array[T.untyped], T::Hash[String, T.untyped]),
// 495:              parsed: T.any(String, T::Array[T.untyped], T::Hash[String, T.untyped]),
// 496:              source_stat: File::Stat).void
// 497:     }
// 498:     private_class_method def self.write_jws_payload_index_cache(target, json_data, parsed:, source_stat:)
// 499:       return unless jws_payload_cacheable?(target)
// 500:       return unless json_data.is_a?(Hash)
// 501:
// 502:       payload = json_data["payload"]
// 503:       return if !payload.is_a?(String) || !parsed.is_a?(Hash)
// 504:
// 505:       PackagesIndex.write!(target, payload:, parsed:, source_stat:)
// 506:     end
// 507:
// 508:     sig {
// 509:       params(target: Pathname, json_data: T.any(T::Array[T.untyped], T::Hash[String, T.untyped]),
// 510:              source_stat: File::Stat).void
// 511:     }
// 512:     private_class_method def self.write_jws_payload_cache(target, json_data, source_stat:)
// 513:       return unless jws_payload_cacheable?(target)
// 514:       # Never write to a user-owned cache as root, matching `skip_download?`.
// 515:       return if Homebrew.running_as_root_but_not_owned_by_root?
// 516:       return unless json_data.is_a?(Hash)
// 517:
// 518:       homebrew_signature = homebrew_jws_signature(json_data)
// 519:       return if homebrew_signature.nil?
// 520:
// 521:       payload = json_data["payload"]
// 522:       protected_b64 = homebrew_signature["protected"]
// 523:       signature_b64 = homebrew_signature["signature"]
// 524:       return if !payload.is_a?(String) || !protected_b64.is_a?(String) || !signature_b64.is_a?(String)
// 525:
// 526:       header = JSON.generate({
// 527:         "protected" => protected_b64,
// 528:         "signature" => signature_b64,
// 529:         **jws_source_fingerprint(source_stat),
// 530:       })
// 531:       payload_cache_path = jws_payload_cache_path(target)
// 532:       temporary_path = Pathname("#{payload_cache_path}.tmp")
// 533:       begin
// 534:         temporary_path.open("wb") do |file|
// 535:           file.write(header, "\n", payload)
// 536:         end
// 537:         File.rename(temporary_path, payload_cache_path)
// 538:       ensure
// 539:         temporary_path.unlink if temporary_path.exist?
// 540:       end
// 541:     rescue SystemCallError
// 542:       nil
// 543:     end
// 544:
// 545:     sig { params(value: String).returns(String) }
// 546:     private_class_method def self.urlsafe_decode64(value)
// 547:       value.tr("-_", "+/").ljust((value.length + 3) & ~3, "=").unpack1("m0")
// 548:     end
// 549:
// 550:     sig { params(path: Pathname).returns(T.nilable(Tap)) }
// 551:     def self.tap_from_source_download(path)
// 552:       path = path.expand_path
// 553:       source_relative_path = path.relative_path_from(Homebrew::API::HOMEBREW_CACHE_API_SOURCE)
// 554:       return if source_relative_path.to_s.start_with?("../")
// 555:
// 556:       org, repo = source_relative_path.each_filename.first(2)
// 557:       return if org.blank? || repo.blank?
// 558:
// 559:       Tap.fetch(org, repo)
// 560:     end
// 561:
// 562:     sig { returns(T::Array[String]) }
// 563:     def self.formula_names
// 564:       Homebrew::API::Internal.formula_names
// 565:     end
// 566:
// 567:     sig { params(name: String).returns(T::Boolean) }
// 568:     def self.formula_name?(name)
// 569:       Homebrew::API::Internal.formula_name?(name)
// 570:     end
// 571:
// 572:     sig { returns(T::Hash[String, String]) }
// 573:     def self.formula_aliases
// 574:       Homebrew::API::Internal.formula_aliases
// 575:     end
// 576:
// 577:     sig { returns(T::Hash[String, String]) }
// 578:     def self.formula_renames
// 579:       Homebrew::API::Internal.formula_renames
// 580:     end
// 581:
// 582:     sig { returns(T::Hash[String, String]) }
// 583:     def self.formula_tap_migrations
// 584:       Homebrew::API::Internal.formula_tap_migrations
// 585:     end
// 586:
// 587:     sig { returns(T::Array[String]) }
// 588:     def self.cask_tokens
// 589:       Homebrew::API::Internal.cask_names
// 590:     end
// 591:
// 592:     sig { params(token: String).returns(T::Boolean) }
// 593:     def self.cask_token?(token)
// 594:       Homebrew::API::Internal.cask_name?(token)
// 595:     end
// 596:
// 597:     sig { returns(T::Hash[String, String]) }
// 598:     def self.cask_renames
// 599:       Homebrew::API::Internal.cask_renames
// 600:     end
// 601:
// 602:     sig { returns(T::Hash[String, String]) }
// 603:     def self.cask_tap_migrations
// 604:       Homebrew::API::Internal.cask_tap_migrations
// 605:     end
// 606:
// 607:     sig { returns(Pathname) }
// 608:     def self.cached_cask_json_file_path
// 609:       Homebrew::API::Internal.cached_packages_json_file_path
// 610:     end
// 611:   end
// 612:
// 613:   sig { type_parameters(:U).params(block: T.proc.returns(T.type_parameter(:U))).returns(T.type_parameter(:U)) }
// 614:   def self.with_no_api_env(&block)
// 615:     return yield if Homebrew::EnvConfig.no_install_from_api?
// 616:
// 617:     with_env(HOMEBREW_NO_INSTALL_FROM_API: "1", HOMEBREW_AUTOMATICALLY_SET_NO_INSTALL_FROM_API: "1", &block)
// 618:   end
// 619:
// 620:   sig {
// 621:     type_parameters(:U).params(
// 622:       condition: T::Boolean,
// 623:       block:     T.proc.returns(T.type_parameter(:U)),
// 624:     ).returns(T.type_parameter(:U))
// 625:   }
// 626:   def self.with_no_api_env_if_needed(condition, &block)
// 627:     return yield unless condition
// 628:
// 629:     with_no_api_env(&block)
// 630:   end
// 631: end
