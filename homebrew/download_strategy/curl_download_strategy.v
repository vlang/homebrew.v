module download_strategy

import brew_runtime
import net.urllib
import os
import time

// Translated from Homebrew/brew `download_strategy/curl_download_strategy.rb`.
// The original source is retained below until every stub has a typed V body.

const deferred_environment_prefix = '{{HOMEBREW_DEFERRED_ENV:'
const deferred_environment_suffix = '}}'

// UrlMetadata is the typed equivalent of CurlDownloadStrategy::URLMetadata.
pub struct UrlMetadata {
pub:
	url               string
	basename          string
	last_modified     i64
	has_last_modified bool
	file_size         i64
	has_file_size     bool
	content_type      string
	is_redirection    bool
}

pub struct ResolvedTimeFileSize {
pub:
	last_modified     i64
	has_last_modified bool
	file_size         i64
}

// CurlDownloadStrategy translates Homebrew's file downloader without invoking
// It never invokes Ruby or a native brew backend.
pub struct CurlDownloadStrategy {
pub mut:
	file                        AbstractFileDownloadStrategy
	mirrors                     []string
	try_partial                 bool
	expand_deferred_environment bool
	file_size                   i64
	has_file_size               bool
	last_modified               i64
	has_last_modified           bool
	resolved_info_cache         map[string]UrlMetadata
}

pub fn new_curl_download_strategy(url string, name string, version string, source_meta DownloadMeta) CurlDownloadStrategy {
	mut meta := source_meta
	if meta.header != '' {
		meta.headers << meta.header
		meta.header = ''
	}
	return CurlDownloadStrategy{
		file:                new_abstract_file_download_strategy(url, name, version, meta)
		mirrors:             meta.mirrors.clone()
		try_partial:         true
		resolved_info_cache: map[string]UrlMetadata{}
	}
}

pub fn (mut strategy CurlDownloadStrategy) cached_location() string {
	if strategy.file.cached_location_value != '' {
		return strategy.file.cached_location_value
	}
	metadata := strategy.resolve_url_basename_time_file_size(strategy.file.base.url, none)
	return strategy.file.cached_location_with_basename(metadata.basename)
}

pub fn (mut strategy CurlDownloadStrategy) temporary_path() string {
	return '${strategy.cached_location()}.incomplete'
}

// candidate_urls translates mirror order and the optional ghcr.io artifact
// domain rewrite/fallback interleaving.
pub fn (strategy &CurlDownloadStrategy) candidate_urls() []string {
	mut urls := [strategy.file.base.url]
	urls << strategy.mirrors
	domain_setting := if strategy.file.base.meta.artifact_domain != '' {
		strategy.file.base.meta.artifact_domain
	} else {
		os.getenv('HOMEBREW_ARTIFACT_DOMAIN')
	}
	if domain_setting == '' {
		return urls
	}
	domain := domain_setting.trim_right('/')
	mut artifact_urls := []string{cap: urls.len}
	for url in urls {
		artifact_urls << rewrite_artifact_url(url, domain)
	}
	no_fallback := strategy.file.base.meta.artifact_domain_no_fallback
		|| environment_truthy('HOMEBREW_ARTIFACT_DOMAIN_NO_FALLBACK')
	if no_fallback {
		return artifact_urls
	}
	mut combined := []string{cap: urls.len * 2}
	for index, original in urls {
		artifact := artifact_urls[index]
		combined << artifact
		if artifact != original {
			combined << original
		}
	}
	return combined
}

fn rewrite_artifact_url(url string, domain string) string {
	mut suffix := ''
	if url.starts_with('https://ghcr.io/') {
		suffix = url['https://ghcr.io/'.len..]
	} else if url.starts_with('http://ghcr.io/') {
		suffix = url['http://ghcr.io/'.len..]
	} else {
		return url
	}
	if artifact_domain_contains_v2(domain) && suffix.starts_with('v2/') {
		suffix = suffix['v2/'.len..]
	}
	return '${domain}/${suffix}'
}

fn artifact_domain_contains_v2(domain string) bool {
	parsed := urllib.parse(domain) or { return false }
	return parsed.path == '/v2' || parsed.path.starts_with('/v2/')
}

fn environment_truthy(name string) bool {
	return os.getenv(name).to_lower() in ['1', 'true', 'yes', 'on']
}

// fetch downloads and caches from the primary URL or each mirror in order.
pub fn (mut strategy CurlDownloadStrategy) fetch(timeout ?f64) ! {
	started := time.now()
	temporary := strategy.temporary_path()
	os.mkdir_all(os.dir(temporary))!
	lock_directory := '${temporary}.lock'
	strategy.acquire_download_lock(lock_directory, started, timeout)!
	defer {
		if os.is_dir(lock_directory) {
			os.rmdir(lock_directory) or {}
		}
	}
	urls := strategy.candidate_urls()
	mut last_error := ''
	for index, candidate in urls {
		remaining_value := remaining_timeout(started, timeout)!
		remaining := if remaining_value < 0 { ?f64(none) } else { ?f64(remaining_value) }
		strategy.file.base.ohai('Downloading ${candidate}')
		cached := strategy.cached_location()
		mut cached_valid := os.is_file(cached)
		metadata := strategy.resolve_url_basename_time_file_size(candidate, remaining)
		strategy.file_size = metadata.file_size
		strategy.has_file_size = metadata.has_file_size
		strategy.last_modified = metadata.last_modified
		strategy.has_last_modified = metadata.has_last_modified
		if metadata.is_redirection {
			original_host := url_host(candidate)
			resolved_host := url_host(metadata.url)
			if original_host != resolved_host {
				strategy.file.base.meta.headers.clear()
			} else {
				strategy.file.base.meta.headers =
					strategy.file.base.meta.headers.filter(!it.starts_with('Authorization'))
			}
		}
		if cached_valid && !metadata.content_type.starts_with('text/') {
			if metadata.has_last_modified && metadata.last_modified > os.file_last_mod_unix(cached) {
				cached_valid = false
			}
			if metadata.has_file_size && metadata.file_size != 0
				&& metadata.file_size != i64(os.file_size(cached)) {
				cached_valid = false
			}
		}
		if cached_valid {
			strategy.file.base.puts('Already downloaded: ${cached}')
		} else {
			strategy.fetch_to_temporary(candidate, metadata.url, remaining) or {
				last_error = err.msg()
				if index + 1 < urls.len {
					strategy.file.base.puts('Trying a mirror...')
					continue
				}
				return error('Failed to download ${strategy.file.base.url}: ${last_error}')
			}
			os.mkdir_all(os.dir(cached))!
			if os.exists(cached) {
				remove_path(cached)!
			}
			os.rename(strategy.temporary_path(), cached)!
		}
		strategy.file.create_symlink_to_cached_download(cached)!
		return
	}
	return error('Failed to download ${strategy.file.base.url}: ${last_error}')
}

fn (mut strategy CurlDownloadStrategy) acquire_download_lock(lock_directory string, started time.Time, timeout ?f64) ! {
	for {
		os.mkdir(lock_directory) or {
			if !os.exists(lock_directory) {
				return error('unable to create download lock ${lock_directory}: ${err}')
			}
			_ = remaining_timeout(started, timeout)!
			time.sleep(50 * time.millisecond)
			continue
		}
		return
	}
}

fn remaining_timeout(started time.Time, timeout ?f64) !f64 {
	if limit := timeout {
		elapsed := f64(time.since(started)) / f64(time.second)
		remaining := limit - elapsed
		if remaining <= 0 {
			return error('download timed out')
		}
		return remaining
	}
	return -1
}

pub fn (strategy &CurlDownloadStrategy) total_size() ?i64 {
	if strategy.has_file_size {
		return strategy.file_size
	}
	return none
}

pub fn (mut strategy CurlDownloadStrategy) clear_cache() ! {
	cached := strategy.cached_location()
	strategy.file.base.clear_cache(cached)!
	remove_path('${cached}.incomplete')!
}

pub fn (mut strategy CurlDownloadStrategy) resolved_time_file_size(timeout ?f64) !ResolvedTimeFileSize {
	metadata := strategy.resolve_url_basename_time_file_size(strategy.file.base.url, timeout)
	if !metadata.has_file_size {
		return error('download size could not be determined')
	}
	return ResolvedTimeFileSize{
		last_modified:     metadata.last_modified
		has_last_modified: metadata.has_last_modified
		file_size:         metadata.file_size
	}
}

pub fn (mut strategy CurlDownloadStrategy) allow_deferred_environment_expansion() {
	strategy.expand_deferred_environment = true
}

// curl_args returns options always passed to raw head calls and downloads.
pub fn (strategy &CurlDownloadStrategy) curl_args() []string {
	mut arguments := []string{}
	if strategy.file.base.meta.cookies.len > 0 {
		mut cookies := []string{cap: strategy.file.base.meta.cookies.len}
		for key, value in strategy.file.base.meta.cookies {
			cookies << '${key}=${value}'
		}
		arguments << ['-b', cookies.join(';')]
	}
	if strategy.file.base.meta.referer != '' {
		arguments << ['-e', strategy.file.base.meta.referer]
	}
	if strategy.file.base.meta.user != '' {
		arguments << ['--user', strategy.file.base.meta.user]
	}
	if strategy.file.base.meta.headers.any(it.contains(deferred_environment_prefix)) {
		arguments << ['--max-redirs', '0']
	}
	for header in strategy.expand_deferred_environment_args(strategy.file.base.meta.headers) {
		arguments << ['--header', header.trim_space()]
	}
	return arguments
}

pub fn (mut strategy CurlDownloadStrategy) resolved_url_and_basename(timeout ?f64) (string, string) {
	metadata := strategy.resolve_url_basename_time_file_size(strategy.file.base.url, timeout)
	return metadata.url, metadata.basename
}

// resolve_url_basename_time_file_size uses curl's response headers and final
// effective URL, retaining every redirect response for source-order selection.
pub fn (mut strategy CurlDownloadStrategy) resolve_url_basename_time_file_size(url string, timeout ?f64) UrlMetadata {
	if cached := strategy.resolved_info_cache[url] {
		return cached
	}
	mut arguments := ['--silent', '--show-error', '--head', '--location', '--dump-header', '-',
		'--output', '/dev/null', '--write-out', '\n__BREW_EFFECTIVE_URL__:%{url_effective}\n']
	if limit := timeout {
		arguments << ['--max-time', format_timeout(limit)]
	}
	arguments << url
	result := strategy.curl_output(arguments) or {
		return UrlMetadata{
			url:      url
			basename: parse_basename(url, true)
		}
	}
	metadata := parse_curl_metadata(url, result.output)
	strategy.resolved_info_cache[url] = metadata
	return metadata
}

fn parse_curl_metadata(original_url string, output string) UrlMetadata {
	mut responses := []map[string]string{}
	mut current := map[string]string{}
	mut final_url := original_url
	for raw_line in output.split_into_lines() {
		line := raw_line.trim_right('\r')
		if line.starts_with('__BREW_EFFECTIVE_URL__:') {
			final_url = line.all_after(':').trim_space()
			continue
		}
		if line.starts_with('HTTP/') {
			if current.len > 0 {
				responses << current
			}
			current = map[string]string{}
			continue
		}
		colon := line.index(':') or { continue }
		key := line[..colon].trim_space().to_lower()
		if key != '' {
			current[key] = line[colon + 1..].trim_space()
		}
	}
	if current.len > 0 {
		responses << current
	}
	mut basename := ''
	mut last_modified := i64(0)
	mut has_last_modified := false
	mut file_size := i64(0)
	mut has_file_size := false
	mut content_type := ''
	mut content_range := ''
	for headers in responses {
		if disposition := headers['content-disposition'] {
			if filename := content_disposition_header_filename(disposition) {
				basename = filename
			}
		}
		if modified := headers['last-modified'] {
			if parsed := parse_http_time(modified) {
				last_modified = parsed
				has_last_modified = true
			}
		}
		if length := headers['content-length'] {
			if length != '' && length.bytes().all(it.is_digit()) {
				file_size = length.i64()
				has_file_size = true
			}
		}
		if range := headers['content-range'] {
			content_range = range
		}
		if content := headers['content-type'] {
			content_type = content
		}
	}
	if !has_file_size || file_size == 0 {
		if total := content_range_total(content_range) {
			file_size = total
			has_file_size = true
		}
	}
	is_redirection := original_url != final_url
	if basename == '' {
		basename = parse_basename(final_url, !is_redirection)
	}
	return UrlMetadata{
		url:               final_url
		basename:          basename
		last_modified:     last_modified
		has_last_modified: has_last_modified
		file_size:         file_size
		has_file_size:     has_file_size
		content_type:      content_type
		is_redirection:    is_redirection
	}
}

// parse_curl_header_metadata exposes the source-derived response parser for
// concrete strategy tests and future curl strategy subclasses.
pub fn parse_curl_header_metadata(original_url string, output string) UrlMetadata {
	return parse_curl_metadata(original_url, output)
}

fn parse_http_time(value string) ?i64 {
	if value.bytes().all(it.is_digit()) {
		return value.i64()
	}
	parsed := time.parse_rfc2616(value) or {
		fallback := time.parse_rfc2822(value) or { return none }
		return fallback.unix()
	}
	return parsed.unix()
}

fn content_range_total(value string) ?i64 {
	if value == '' || !value.contains('/') {
		return none
	}
	total := value.all_after_last('/').trim_space()
	if total == '' || total == '*' || !total.bytes().all(it.is_digit()) {
		return none
	}
	return total.i64()
}

fn content_disposition_header_filename(value string) ?string {
	mut regular_filename := ''
	parameters := value.split(';')
	if parameters.len < 2 {
		return none
	}
	for raw_parameter in parameters[1..] {
		parameter := raw_parameter.trim_space()
		lower := parameter.to_lower()
		if lower.starts_with('filename*=') {
			mut encoded := parameter['filename*='.len..].trim_space().trim('"')
			parts := encoded.split_nth("''", 2)
			if parts.len == 2 && parts[0] != '' && parts[1] != '' {
				encoded = parts[1].trim('"')
				decoded := urllib.query_unescape(encoded) or { encoded }
				return os.file_name(decoded)
			}
		} else if lower.starts_with('filename=') {
			regular_filename = parameter['filename='.len..].trim_space().trim('"').trim("'")
		}
	}
	if regular_filename != '' {
		return os.file_name(regular_filename)
	}
	return none
}

pub fn (mut strategy CurlDownloadStrategy) fetch_to_temporary(url string, resolved_url string, timeout ?f64) !brew_runtime.CommandResult {
	if url != resolved_url {
		strategy.file.base.ohai('Downloading from ${resolved_url}')
	}
	strategy.ensure_no_insecure_redirect(url, resolved_url)!
	return strategy.curl_download(resolved_url, strategy.temporary_path(), timeout)
}

pub fn (strategy &CurlDownloadStrategy) ensure_no_insecure_redirect(url string, resolved_url string) ! {
	blocked := strategy.file.base.meta.no_insecure_redirect
		|| environment_truthy('HOMEBREW_NO_INSECURE_REDIRECT')
	if blocked && url.starts_with('https://') && resolved_url.starts_with('http://') {
		return error('HTTPS to HTTP redirect detected and `$HOMEBREW_NO_INSECURE_REDIRECT` is set.')
	}
}

pub fn (mut strategy CurlDownloadStrategy) curl_download(resolved_url string, target string, timeout ?f64) !brew_runtime.CommandResult {
	mut arguments := ['--remote-time', '--output', target]
	if strategy.try_partial {
		arguments << ['--continue-at', '-']
	}
	arguments << ['--location', resolved_url]
	if limit := timeout {
		arguments << ['--max-time', format_timeout(limit)]
	}
	return strategy.curl(arguments)
}

pub fn (strategy &CurlDownloadStrategy) expand_deferred_environment_args(arguments []string) []string {
	if !strategy.expand_deferred_environment {
		return arguments.clone()
	}
	return arguments.map(expand_deferred_environment(it))
}

fn expand_deferred_environment(value string) string {
	mut result := value
	for result.contains(deferred_environment_prefix) {
		start := result.index(deferred_environment_prefix) or { break }
		name_start := start + deferred_environment_prefix.len
		relative_end := result[name_start..].index(deferred_environment_suffix) or { break }
		end := name_start + relative_end
		name := result[name_start..end]
		if !name.starts_with('HOMEBREW_') || !name.bytes().all(it.is_alnum() || it == `_`) {
			break
		}
		result = result[..start] + os.getenv(name) + result[end + deferred_environment_suffix.len..]
	}
	return result
}

pub fn (strategy &CurlDownloadStrategy) curl_opts() []string {
	if strategy.file.base.meta.user_agent == '' {
		return []
	}
	user_agent := if strategy.file.base.meta.user_agent == 'fake' {
		'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15'
	} else {
		strategy.file.base.meta.user_agent
	}
	return ['--user-agent', user_agent]
}

pub fn (strategy &CurlDownloadStrategy) curl_output(arguments []string) !brew_runtime.CommandResult {
	return strategy.run_curl(arguments)
}

pub fn (strategy &CurlDownloadStrategy) curl(arguments []string) !brew_runtime.CommandResult {
	return strategy.run_curl(arguments)
}

fn (strategy &CurlDownloadStrategy) run_curl(arguments []string) !brew_runtime.CommandResult {
	curl := brew_runtime.find_executable('curl')!
	mut all_arguments := strategy.curl_args()
	all_arguments << strategy.curl_opts()
	if strategy.mirrors.len > 0 {
		all_arguments << ['--connect-timeout', '15']
	}
	all_arguments << strategy.expand_deferred_environment_args(arguments)
	result := brew_runtime.run_command(curl, all_arguments)
	if result.exit_code != 0 {
		return error(result.output.trim_space())
	}
	return result
}

fn format_timeout(value f64) string {
	if value == f64(i64(value)) {
		return i64(value).str()
	}
	return '${value:.3f}'
}

fn url_host(raw_url string) string {
	parsed := urllib.parse(raw_url) or { return '' }
	return parsed.host
}

// Source entrypoint translations.
// Ruby attr_reader `attr_reader :mirrors` at line 14.
pub fn ruby_curl_download_strategy_l14_d1_mirrors(strategy &CurlDownloadStrategy) []string {
	return strategy.mirrors.clone()
}

// Ruby method `initialize(url, name, version, **meta)` at line 17.
pub fn ruby_curl_download_strategy_l17_d2_initialize(url string, name string, version string, meta DownloadMeta) CurlDownloadStrategy {
	return new_curl_download_strategy(url, name, version, meta)
}

// Ruby method `fetch(timeout: nil)` at line 37.
pub fn ruby_curl_download_strategy_l37_d3_fetch(mut strategy CurlDownloadStrategy, timeout ?f64) ! {
	strategy.fetch(timeout)!
}

// Ruby method `total_size` at line 147.
pub fn ruby_curl_download_strategy_l147_d4_total_size(strategy &CurlDownloadStrategy) ?i64 {
	return strategy.total_size()
}

// Ruby method `clear_cache` at line 152.
pub fn ruby_curl_download_strategy_l152_d5_clear_cache(mut strategy CurlDownloadStrategy) ! {
	strategy.clear_cache()!
}

// Ruby method `resolved_time_file_size(timeout: nil)` at line 158.
pub fn ruby_curl_download_strategy_l158_d6_resolved_time_file_size(mut strategy CurlDownloadStrategy, timeout ?f64) !ResolvedTimeFileSize {
	return strategy.resolved_time_file_size(timeout)
}

// Ruby method `allow_deferred_environment_expansion!` at line 164.
pub fn ruby_curl_download_strategy_l164_d7_allow_deferred_environment_expansion(mut strategy CurlDownloadStrategy) {
	strategy.allow_deferred_environment_expansion()
}

// Ruby method `_curl_args` at line 171.
pub fn ruby_curl_download_strategy_l171_d8_curl_args(strategy &CurlDownloadStrategy) []string {
	return strategy.curl_args()
}

// Ruby method `resolved_url_and_basename(timeout: nil)` at line 192.
pub fn ruby_curl_download_strategy_l192_d9_resolved_url_and_basename(mut strategy CurlDownloadStrategy, timeout ?f64) (string, string) {
	return strategy.resolved_url_and_basename(timeout)
}

// Ruby method `resolve_url_basename_time_file_size(url, timeout: nil)` at line 198.
pub fn ruby_curl_download_strategy_l198_d10_resolve_url_basename_time_file_size(mut strategy CurlDownloadStrategy, url string, timeout ?f64) UrlMetadata {
	return strategy.resolve_url_basename_time_file_size(url, timeout)
}

// Ruby method `_fetch(url:, resolved_url:, timeout:)` at line 280.
pub fn ruby_curl_download_strategy_l280_d11_fetch(mut strategy CurlDownloadStrategy, url string, resolved_url string, timeout ?f64) !brew_runtime.CommandResult {
	return strategy.fetch_to_temporary(url, resolved_url, timeout)
}

// Ruby method `ensure_no_insecure_redirect!(url:, resolved_url:)` at line 289.
pub fn ruby_curl_download_strategy_l289_d12_ensure_no_insecure_redirect(strategy &CurlDownloadStrategy, url string, resolved_url string) ! {
	strategy.ensure_no_insecure_redirect(url, resolved_url)!
}

// Ruby method `_curl_download(resolved_url, to, timeout)` at line 301.
pub fn ruby_curl_download_strategy_l301_d13_curl_download(mut strategy CurlDownloadStrategy, resolved_url string, target string, timeout ?f64) !brew_runtime.CommandResult {
	return strategy.curl_download(resolved_url, target, timeout)
}

// Ruby method `expand_deferred_environment_args(args)` at line 306.
pub fn ruby_curl_download_strategy_l306_d14_expand_deferred_environment_args(strategy &CurlDownloadStrategy, arguments []string) []string {
	return strategy.expand_deferred_environment_args(arguments)
}

// Ruby method `_curl_opts` at line 315.
pub fn ruby_curl_download_strategy_l315_d15_curl_opts(strategy &CurlDownloadStrategy) []string {
	return strategy.curl_opts()
}

// Ruby method `curl_output(*args, **options)` at line 320.
pub fn ruby_curl_download_strategy_l320_d16_curl_output(strategy &CurlDownloadStrategy, arguments []string) !brew_runtime.CommandResult {
	return strategy.curl_output(arguments)
}

// Ruby method `curl(*args, print_stdout: true, **options)` at line 328.
pub fn ruby_curl_download_strategy_l328_d17_curl(strategy &CurlDownloadStrategy, arguments []string) !brew_runtime.CommandResult {
	return strategy.curl(arguments)
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
