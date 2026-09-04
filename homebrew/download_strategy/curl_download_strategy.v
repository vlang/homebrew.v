module download_strategy

import ruby
import net.urllib
import os
import time

// Translated from Homebrew/brew `download_strategy/curl_download_strategy.rb`.

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
		file: new_abstract_file_download_strategy(url, name, version, meta)
		mirrors: meta.mirrors.clone()
		try_partial: true
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
		last_modified: metadata.last_modified
		has_last_modified: metadata.has_last_modified
		file_size: metadata.file_size
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
			url: url
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
		url: final_url
		basename: basename
		last_modified: last_modified
		has_last_modified: has_last_modified
		file_size: file_size
		has_file_size: has_file_size
		content_type: content_type
		is_redirection: is_redirection
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

pub fn (mut strategy CurlDownloadStrategy) fetch_to_temporary(url string, resolved_url string, timeout ?f64) !ruby.CommandResult {
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
		return error('HTTPS to HTTP redirect detected and `\$HOMEBREW_NO_INSECURE_REDIRECT` is set.')
	}
}

pub fn (mut strategy CurlDownloadStrategy) curl_download(resolved_url string, target string, timeout ?f64) !ruby.CommandResult {
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

pub fn (strategy &CurlDownloadStrategy) curl_output(arguments []string) !ruby.CommandResult {
	return strategy.run_curl(arguments)
}

pub fn (strategy &CurlDownloadStrategy) curl(arguments []string) !ruby.CommandResult {
	return strategy.run_curl(arguments)
}

fn (strategy &CurlDownloadStrategy) run_curl(arguments []string) !ruby.CommandResult {
	curl := ruby.find_executable('curl')!
	mut all_arguments := strategy.curl_args()
	all_arguments << strategy.curl_opts()
	if strategy.mirrors.len > 0 {
		all_arguments << ['--connect-timeout', '15']
	}
	all_arguments << strategy.expand_deferred_environment_args(arguments)
	result := ruby.run_command(curl, all_arguments)
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
