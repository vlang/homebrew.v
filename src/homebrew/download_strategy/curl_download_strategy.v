module download_strategy

import brew_runtime

// Translated from Homebrew/brew `download_strategy/curl_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :mirrors` at line 14.
pub fn ruby_curl_download_strategy_l14_d1_mirrors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mirrors', ...args)
}

// Ruby method `initialize(url, name, version, **meta)` at line 17.
pub fn ruby_curl_download_strategy_l17_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `fetch(timeout: nil)` at line 37.
pub fn ruby_curl_download_strategy_l37_d3_fetch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetch', ...args)
}

// Ruby method `total_size` at line 147.
pub fn ruby_curl_download_strategy_l147_d4_total_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('total_size', ...args)
}

// Ruby method `clear_cache` at line 152.
pub fn ruby_curl_download_strategy_l152_d5_clear_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clear_cache', ...args)
}

// Ruby method `resolved_time_file_size(timeout: nil)` at line 158.
pub fn ruby_curl_download_strategy_l158_d6_resolved_time_file_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolved_time_file_size', ...args)
}

// Ruby method `allow_deferred_environment_expansion!` at line 164.
pub fn ruby_curl_download_strategy_l164_d7_allow_deferred_environment_expansion(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allow_deferred_environment_expansion!', ...args)
}

// Ruby method `_curl_args` at line 171.
pub fn ruby_curl_download_strategy_l171_d8_curl_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('_curl_args', ...args)
}

// Ruby method `resolved_url_and_basename(timeout: nil)` at line 192.
pub fn ruby_curl_download_strategy_l192_d9_resolved_url_and_basename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolved_url_and_basename', ...args)
}

// Ruby method `resolve_url_basename_time_file_size(url, timeout: nil)` at line 198.
pub fn ruby_curl_download_strategy_l198_d10_resolve_url_basename_time_file_size(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolve_url_basename_time_file_size', ...args)
}

// Ruby method `_fetch(url:, resolved_url:, timeout:)` at line 280.
pub fn ruby_curl_download_strategy_l280_d11_fetch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('_fetch', ...args)
}

// Ruby method `ensure_no_insecure_redirect!(url:, resolved_url:)` at line 289.
pub fn ruby_curl_download_strategy_l289_d12_ensure_no_insecure_redirect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ensure_no_insecure_redirect!', ...args)
}

// Ruby method `_curl_download(resolved_url, to, timeout)` at line 301.
pub fn ruby_curl_download_strategy_l301_d13_curl_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('_curl_download', ...args)
}

// Ruby method `expand_deferred_environment_args(args)` at line 306.
pub fn ruby_curl_download_strategy_l306_d14_expand_deferred_environment_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expand_deferred_environment_args', ...args)
}

// Ruby method `_curl_opts` at line 315.
pub fn ruby_curl_download_strategy_l315_d15_curl_opts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('_curl_opts', ...args)
}

// Ruby method `curl_output(*args, **options)` at line 320.
pub fn ruby_curl_download_strategy_l320_d16_curl_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('curl_output', ...args)
}

// Ruby method `curl(*args, print_stdout: true, **options)` at line 328.
pub fn ruby_curl_download_strategy_l328_d17_curl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('curl', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Strategy for downloading files using `curl`.
// 5: #
// 6: # @api public
// 7: class CurlDownloadStrategy < AbstractFileDownloadStrategy
// 8:   include Utils::Curl
// 9:
// 10:   # url, basename, time, file_size, content_type, is_redirection
// 11:   URLMetadata = T.type_alias { [String, String, T.nilable(Time), T.nilable(Integer), T.nilable(String), T::Boolean] }
// 12:
// 13:   sig { returns(T::Array[String]) }
// 14:   attr_reader :mirrors
// 15:
// 16:   sig { params(url: String, name: String, version: T.nilable(T.any(String, Version)), meta: T.untyped).void }
// 17:   def initialize(url, name, version, **meta)
// 18:     @try_partial = T.let(true, T::Boolean)
// 19:     @expand_deferred_environment = T.let(false, T::Boolean)
// 20:     @mirrors = T.let(meta.fetch(:mirrors, []), T::Array[String])
// 21:     @file_size = T.let(nil, T.nilable(Integer))
// 22:     @last_modified = T.let(nil, T.nilable(Time))
// 23:
// 24:     # Merge `:header` with `:headers`.
// 25:     if (header = meta.delete(:header))
// 26:       meta[:headers] ||= []
// 27:       meta[:headers] << header
// 28:     end
// 29:
// 30:     super
// 31:   end
// 32:
// 33:   # Download and cache the file at {#cached_location}.
// 34:   #
// 35:   # @api public
// 36:   sig { override.params(timeout: T.nilable(T.any(Float, Integer))).void }
// 37:   def fetch(timeout: nil)
// 38:     end_time = Time.now + timeout if timeout
// 39:
// 40:     download_lock = DownloadLock.new(temporary_path)
// 41:     begin
// 42:       download_lock.lock_or_wait(quiet: quiet?, timeout: Utils::Timer.remaining(end_time))
// 43:
// 44:       urls = [url, *mirrors]
// 45:
// 46:       if (domain = Homebrew::EnvConfig.artifact_domain)
// 47:         domain = domain.chomp("/")
// 48:         # If the artifact domain already contains the Docker Registry API's
// 49:         # `/v2/` path (e.g. an OCI registry proxying ghcr.io under a repository
// 50:         # prefix: https://mirror.example.com/v2/ghcr-io), skip the `v2/` from
// 51:         # the original URL rather than producing a duplicate `/v2/`.
// 52:         # Keep this in sync with the portable-ruby URL handling in
// 53:         # Library/Homebrew/cmd/vendor-install.sh.
// 54:         domain_contains_v2 = %r{\Ahttps?://[^/]+/v2(?:/|\z)}.match?(domain)
// 55:
// 56:         artifact_urls = urls.map do |u|
// 57:           if domain_contains_v2
// 58:             u.sub(%r{^https?://#{GitHubPackages::URL_DOMAIN}/v2/}o, "#{domain}/")
// 59:           else
// 60:             u.sub(%r{^https?://#{GitHubPackages::URL_DOMAIN}/}o, "#{domain}/")
// 61:           end
// 62:         end
// 63:
// 64:         urls = if Homebrew::EnvConfig.artifact_domain_no_fallback?
// 65:           artifact_urls
// 66:         else
// 67:           # Interleave: try artifact domain first, then original for each URL that was rewritten.
// 68:           combined = []
// 69:           artifact_urls.zip(urls).each do |artifact_url, original_url|
// 70:             combined << artifact_url
// 71:             combined << original_url if original_url != artifact_url
// 72:           end
// 73:           combined
// 74:         end
// 75:       end
// 76:
// 77:       begin
// 78:         url = T.must(urls.shift)
// 79:
// 80:         ohai "Downloading #{url}"
// 81:
// 82:         cached_location_valid = cached_location.exist?
// 83:
// 84:         resolved_url, _, last_modified, @file_size, content_type, is_redirection = begin
// 85:           resolve_url_basename_time_file_size(url, timeout: Utils::Timer.remaining!(end_time))
// 86:         rescue ErrorDuringExecution
// 87:           raise unless cached_location_valid
// 88:         end
// 89:         @last_modified = last_modified
// 90:
// 91:         # Caller-supplied headers (e.g. tokens) are no longer valid after a
// 92:         # redirect to another host, and `Authorization` after any redirect.
// 93:         if is_redirection
// 94:           if resolved_url && URI(url).host != URI(resolved_url).host
// 95:             meta.delete(:headers)
// 96:           else
// 97:             meta[:headers]&.delete_if { |header| header.start_with?("Authorization") }
// 98:           end
// 99:         end
// 100:
// 101:         # The cached location is no longer fresh if either:
// 102:         # - Last-Modified value is newer than the file's timestamp
// 103:         # - Content-Length value is different than the file's size
// 104:         if cached_location_valid && (!content_type.is_a?(String) || !content_type.start_with?("text/"))
// 105:           if last_modified && last_modified > cached_location.mtime
// 106:             ohai "Ignoring #{cached_location}",
// 107:                  "Cached modified time #{cached_location.mtime.iso8601} is before " \
// 108:                  "Last-Modified header: #{last_modified.iso8601}"
// 109:             cached_location_valid = false
// 110:           end
// 111:           if @file_size&.nonzero? && @file_size != cached_location.size
// 112:             ohai "Ignoring #{cached_location}",
// 113:                  "Cached size #{cached_location.size} differs from " \
// 114:                  "Content-Length header: #{@file_size}"
// 115:             cached_location_valid = false
// 116:           end
// 117:         end
// 118:
// 119:         if cached_location_valid
// 120:           puts "Already downloaded: #{cached_location}"
// 121:         else
// 122:           begin
// 123:             _fetch(url:, resolved_url: T.must(resolved_url), timeout: Utils::Timer.remaining!(end_time))
// 124:           rescue ErrorDuringExecution => e
// 125:             clean_stderr = strip_progress_bar(Tty.collapse_carriage_returns(e.stderr)).strip
// 126:             raise CurlDownloadStrategyError.new(url, clean_stderr)
// 127:           end
// 128:           cached_location.dirname.mkpath
// 129:           temporary_path.rename(cached_location.to_s)
// 130:         end
// 131:
// 132:         create_symlink_to_cached_download(cached_location)
// 133:       rescue CurlDownloadStrategyError
// 134:         raise if urls.empty?
// 135:
// 136:         puts "Trying a mirror..."
// 137:         retry
// 138:       rescue Timeout::Error => e
// 139:         raise Timeout::Error, "Timed out downloading #{self.url}: #{e}"
// 140:       end
// 141:     ensure
// 142:       download_lock.unlock(unlink: true)
// 143:     end
// 144:   end
// 145:
// 146:   sig { override.returns(T.nilable(Integer)) }
// 147:   def total_size
// 148:     @file_size
// 149:   end
// 150:
// 151:   sig { override.void }
// 152:   def clear_cache
// 153:     super
// 154:     rm_rf(temporary_path)
// 155:   end
// 156:
// 157:   sig { params(timeout: T.nilable(T.any(Float, Integer))).returns([T.nilable(Time), Integer]) }
// 158:   def resolved_time_file_size(timeout: nil)
// 159:     _, _, time, file_size, = resolve_url_basename_time_file_size(url, timeout:)
// 160:     [time, T.must(file_size)]
// 161:   end
// 162:
// 163:   sig { void }
// 164:   def allow_deferred_environment_expansion!
// 165:     @expand_deferred_environment = true
// 166:   end
// 167:
// 168:   # Curl options to be always passed to curl,
// 169:   # with raw head calls (`curl --head`) or with actual `fetch`.
// 170:   sig { returns(T::Array[String]) }
// 171:   def _curl_args
// 172:     args = []
// 173:
// 174:     args += ["-b", meta.fetch(:cookies).map { |k, v| "#{k}=#{v}" }.join(";")] if meta.key?(:cookies)
// 175:
// 176:     args += ["-e", meta.fetch(:referer)] if meta.key?(:referer)
// 177:
// 178:     args += ["--user", meta.fetch(:user)] if meta.key?(:user)
// 179:
// 180:     if meta.fetch(:headers, []).any? { |header| header.include?(EnvSensitive::DEFERRED_PLACEHOLDER_PREFIX) }
// 181:       args += ["--max-redirs", "0"]
// 182:     end
// 183:
// 184:     args += expand_deferred_environment_args(meta.fetch(:headers, [])).flat_map { |h| ["--header", h.strip] }
// 185:
// 186:     args
// 187:   end
// 188:
// 189:   private
// 190:
// 191:   sig { params(timeout: T.nilable(T.any(Float, Integer))).returns([String, String]) }
// 192:   def resolved_url_and_basename(timeout: nil)
// 193:     resolved_url, basename, = resolve_url_basename_time_file_size(url, timeout: nil)
// 194:     [resolved_url, basename]
// 195:   end
// 196:
// 197:   sig { overridable.params(url: String, timeout: T.nilable(T.any(Float, Integer))).returns(URLMetadata) }
// 198:   def resolve_url_basename_time_file_size(url, timeout: nil)
// 199:     @resolved_info_cache ||= T.let({}, T.nilable(T::Hash[String, URLMetadata]))
// 200:     return @resolved_info_cache.fetch(url) if @resolved_info_cache.include?(url)
// 201:
// 202:     begin
// 203:       parsed_output = curl_headers(url.to_s, wanted_headers: ["content-disposition"], timeout:)
// 204:     rescue ErrorDuringExecution
// 205:       return [url, parse_basename(url), nil, nil, nil, false]
// 206:     end
// 207:
// 208:     parsed_headers = parsed_output.fetch(:responses).map { |r| r.fetch(:headers) }
// 209:
// 210:     final_url = curl_response_follow_redirections(parsed_output.fetch(:responses), url)
// 211:
// 212:     content_disposition_parser = Mechanize::HTTP::ContentDispositionParser.new
// 213:
// 214:     parse_content_disposition = lambda do |line|
// 215:       next unless (content_disposition = content_disposition_parser.parse(line.sub(/; *$/, ""), true))
// 216:
// 217:       filename = nil
// 218:
// 219:       if (filename_with_encoding = content_disposition.parameters["filename*"])
// 220:         encoding, encoded_filename = filename_with_encoding.split("''", 2)
// 221:         # If the `filename*` has incorrectly added double quotes, e.g.
// 222:         #   content-disposition: attachment; filename="myapp-1.2.3.pkg"; filename*=UTF-8''"myapp-1.2.3.pkg"
// 223:         # Then the encoded_filename will come back as the empty string, in which case we should fall back to the
// 224:         # `filename` parameter.
// 225:         if encoding.present? && encoded_filename.present?
// 226:           filename = URI.decode_www_form_component(encoded_filename).encode(encoding)
// 227:         end
// 228:       end
// 229:
// 230:       filename = content_disposition.filename if filename.blank?
// 231:       next if filename.blank?
// 232:
// 233:       # Servers may include '/' in their Content-Disposition filename header. Take only the basename of this, because:
// 234:       # - Unpacking code assumes this is a single file - not something living in a subdirectory.
// 235:       # - Directory traversal attacks are possible without limiting this to just the basename.
// 236:       File.basename(filename)
// 237:     end
// 238:
// 239:     filenames = parsed_headers.flat_map do |headers|
// 240:       next [] unless (header = headers["content-disposition"])
// 241:
// 242:       [*parse_content_disposition.call("Content-Disposition: #{header}")]
// 243:     end
// 244:
// 245:     time =  parsed_headers
// 246:             .flat_map { |headers| [*headers["last-modified"]] }
// 247:             .filter_map do |t|
// 248:               t.match?(/^\d+$/) ? Time.at(t.to_i) : Time.parse(t)
// 249:             rescue ArgumentError # When `Time.parse` gets a badly formatted date.
// 250:               nil
// 251:             end
// 252:
// 253:     file_size = parsed_headers
// 254:                 .flat_map { |headers| [*headers["content-length"]&.to_i] }
// 255:                 .last
// 256:
// 257:     # Fallback to content-range header if content-length is not available.
// 258:     # Content-Range format: "bytes start-end/total" or "bytes */total" or "bytes start-end/*"
// 259:     if file_size.nil? || file_size.zero?
// 260:       file_size = parsed_headers
// 261:                   .flat_map { |headers| [*headers["content-range"]] }
// 262:                   .filter_map { |range| Integer(range.split("/").last, 10, exception: false) }
// 263:                   .last
// 264:     end
// 265:
// 266:     content_type = parsed_headers
// 267:                    .flat_map { |headers| [*headers["content-type"]] }
// 268:                    .last
// 269:
// 270:     is_redirection = url != final_url
// 271:     basename = filenames.last || parse_basename(final_url, search_query: !is_redirection)
// 272:
// 273:     @resolved_info_cache[url] = [final_url, basename, time.last, file_size, content_type, is_redirection]
// 274:   end
// 275:
// 276:   sig {
// 277:     overridable.params(url: String, resolved_url: String, timeout: T.nilable(T.any(Float, Integer)))
// 278:                .returns(T.nilable(SystemCommand::Result))
// 279:   }
// 280:   def _fetch(url:, resolved_url:, timeout:)
// 281:     ohai "Downloading from #{resolved_url}" if url != resolved_url
// 282:
// 283:     ensure_no_insecure_redirect!(url:, resolved_url:)
// 284:
// 285:     _curl_download resolved_url, temporary_path, timeout
// 286:   end
// 287:
// 288:   sig { params(url: String, resolved_url: String).void }
// 289:   def ensure_no_insecure_redirect!(url:, resolved_url:)
// 290:     return unless insecure_redirect?(url:, resolved_url:)
// 291:
// 292:     error_message = "HTTPS to HTTP redirect detected and `$HOMEBREW_NO_INSECURE_REDIRECT` is set."
// 293:     $stderr.puts error_message unless quiet?
// 294:     raise CurlDownloadStrategyError.new(url, error_message)
// 295:   end
// 296:
// 297:   sig {
// 298:     params(resolved_url: String, to: T.any(Pathname, String), timeout: T.nilable(T.any(Float, Integer)))
// 299:       .returns(T.nilable(SystemCommand::Result))
// 300:   }
// 301:   def _curl_download(resolved_url, to, timeout)
// 302:     curl_download resolved_url, to:, try_partial: @try_partial, timeout:
// 303:   end
// 304:
// 305:   sig { params(args: T::Array[String]).returns(T::Array[String]) }
// 306:   def expand_deferred_environment_args(args)
// 307:     return args unless @expand_deferred_environment
// 308:
// 309:     with_context(deferred_environment_expansion: true) do
// 310:       args.map { |arg| ENV.expand_deferred_environment(arg) }
// 311:     end
// 312:   end
// 313:
// 314:   sig { returns(T::Hash[Symbol, T.any(String, Symbol)]) }
// 315:   def _curl_opts
// 316:     meta.slice(:user_agent)
// 317:   end
// 318:
// 319:   sig { override.params(args: String, options: T.untyped).returns(SystemCommand::Result) }
// 320:   def curl_output(*args, **options)
// 321:     super(*_curl_args, *expand_deferred_environment_args(args), **_curl_opts, **options)
// 322:   end
// 323:
// 324:   sig {
// 325:     override.params(args: String, print_stdout: T.any(T::Boolean, Symbol), options: T.untyped)
// 326:             .returns(SystemCommand::Result)
// 327:   }
// 328:   def curl(*args, print_stdout: true, **options)
// 329:     options[:connect_timeout] = 15 unless mirrors.empty?
// 330:     super(*_curl_args, *expand_deferred_environment_args(args), **_curl_opts, **command_output_options, **options)
// 331:   end
// 332: end
