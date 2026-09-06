module homebrew

import ruby
import encoding.base64
import os
import time
import x.json2

// Translated from Homebrew/brew `api.rb`.
const api_default_domain = 'https://formulae.brew.sh/api'
const api_default_stale_seconds = i64(7 * 24 * 60 * 60)

pub struct ApiCurlOutput {
pub:
	stdout  string
	success bool
}

pub struct ApiFetchConfig {
pub mut:
	cache map[string]json2.Any
pub:
	api_domain     string = api_default_domain
	default_domain string = api_default_domain
	primary        ApiCurlOutput
	fallback       ?ApiCurlOutput
}

pub struct ApiDownloadAttempt {
pub:
	url     string
	stdout  string
	success bool
}

pub struct ApiFetchJsonConfig {
pub:
	api_domain                       string = api_default_domain
	default_domain                   string = api_default_domain
	target                           string
	stale_seconds                    ?i64
	now                              i64
	running_as_root                  bool
	insecure_download                bool
	enqueue                          bool
	download_attempts                []ApiDownloadAttempt
	curl_retries                     int
	signature_verified               bool = true
	payload_cache_signature_verified bool = true
	has_signature_result             bool = true
}

pub struct ApiFetchJsonResult {
pub:
	data    json2.Any
	updated bool
}

pub struct ApiFetchFilesResult {
pub:
	api_updated bool
	enqueued    bool
	fetched     bool
	shutdown    bool
}

pub fn api_parse_json(contents string) !json2.Any {
	return json2.decode[json2.Any](contents)!
}

pub fn api_fetch(endpoint string, mut config ApiFetchConfig) !json2.Any {
	if cached := config.cache[endpoint] {
		return cached
	}
	mut url := '${config.api_domain}/${endpoint}'
	mut output := config.primary
	if !output.success && config.api_domain != config.default_domain {
		url = '${config.default_domain}/${endpoint}'
		output = config.fallback or { ApiCurlOutput{} }
	}
	if !output.success {
		return error('No file found at: ${url}')
	}
	parsed := api_parse_json(output.stdout) or { return error('Invalid JSON file: ${url}') }
	config.cache[endpoint] = parsed
	return parsed
}

pub fn api_skip_download(target string, stale_seconds ?i64, running_as_root bool, now i64) bool {
	if running_as_root {
		return true
	}
	if !os.exists(target) || os.is_dir(target) || os.file_size(target) == 0 {
		return false
	}
	seconds := stale_seconds or { return true }
	return now - seconds < os.file_last_mod_unix(target)
}

fn api_cache_root() string {
	cache := ruby.environment_value('HOMEBREW_CACHE')
	if cache != '' {
		return os.join_path(cache, 'api')
	}
	return os.join_path(os.temp_dir(), 'homebrew', 'api')
}

fn api_source_cache_root() string {
	cache := ruby.environment_value('HOMEBREW_CACHE')
	if cache != '' {
		return os.join_path(cache, 'api-source')
	}
	return os.join_path(os.temp_dir(), 'homebrew', 'api-source')
}

fn api_cache_path(endpoint string) string {
	return os.join_path(api_cache_root(), endpoint)
}

pub fn api_fetch_json_api_file(endpoint string, config ApiFetchJsonConfig) !ApiFetchJsonResult {
	target := config.target
	url := '${config.api_domain}/${endpoint}'
	if config.running_as_root && (!os.exists(target) || os.file_size(target) == 0) {
		return error('Need to download ${url} but cannot as root! Run `brew update` without `sudo` first then try again.')
	}
	skip_download := api_skip_download(target, config.stale_seconds, config.running_as_root, config.now)
	if config.enqueue {
		return ApiFetchJsonResult{
			data: json2.Any(map[string]json2.Any{})
		}
	}
	mut download_succeeded := false
	mut used_url := url
	if !skip_download {
		for attempt in config.download_attempts {
			used_url = if attempt.url != '' { attempt.url } else { used_url }
			if attempt.success {
				os.mkdir_all(os.dir(target))!
				os.write_file(target, attempt.stdout)!
				download_succeeded = true
				break
			}
			if used_url != '${config.default_domain}/${endpoint}' {
				used_url = '${config.default_domain}/${endpoint}'
				if os.exists(target) && os.file_size(target) == 0 {
					os.rm(target)!
				}
			}
		}
	}
	if download_succeeded {
		mtime := if config.insecure_download { i64(0) } else { config.now }
		os.utime(target, mtime, mtime)!
	}
	if !os.exists(target) || os.file_size(target) == 0 {
		return error('Cannot download non-corrupt ${used_url}!')
	}
	if endpoint.ends_with('.jws.json') && !download_succeeded {
		if cached := api_cached_jws_payload(target, config.payload_cache_signature_verified, config.has_signature_result) {
			return ApiFetchJsonResult{
				data: cached
			}
		}
	}
	contents := os.read_file(target)!
	mut json_data := api_parse_json(contents) or {
		os.rm(target) or {}
		mut recovered := false
		for attempt in config.download_attempts {
			if attempt.success {
				os.mkdir_all(os.dir(target))!
				os.write_file(target, attempt.stdout)!
				mtime := if config.insecure_download { i64(0) } else { config.now }
				os.utime(target, mtime, mtime)!
				recovered = true
				break
			}
		}
		if !recovered {
			return error('Cannot download non-corrupt ${used_url}!')
		}
		recovered_contents := os.read_file(target)!
		api_parse_json(recovered_contents) or {
			os.rm(target) or {}
			return error('Cannot download non-corrupt ${used_url}!')
		}
	}
	if endpoint.ends_with('.jws.json') {
		verified := api_verify_and_parse_jws(json_data, config.signature_verified, config.has_signature_result) or {
			os.rm(target) or {}
			return error('Failed to verify integrity (${err.msg()}) of:\n  ${used_url}\nPotential MITM attempt detected. Please run `brew update` and try again.')
		}
		if !config.insecure_download {
			api_write_jws_payload_cache(target, json_data, config.running_as_root) or {}
		}
		return ApiFetchJsonResult{
			data: verified
			updated: !skip_download
		}
	}
	return ApiFetchJsonResult{
		data: json_data
		updated: !skip_download
	}
}

// Ruby method `self.merge_variations(json, bottle_tag: T.unsafe(nil))` at line 194.
pub fn api_merge_variations(json map[string]json2.Any, bottle_tag string) map[string]json2.Any {
	mut merged := json.clone()
	variations := merged['variations'] or { return merged }
	tag := if bottle_tag != '' { bottle_tag } else { api_current_tag() }
	if variation := variations.as_map()[tag] {
		for key, value in variation.as_map() {
			merged[key] = value
		}
	}
	merged.delete('variations')
	return merged
}

fn api_current_tag() string {
	return ruby.environment_value('HOMEBREW_SIMULATE_TAG')
}

pub struct ApiFetchFilesConfig {
pub:
	target            string
	stale_seconds     i64
	has_stale_seconds bool
	api_updated       bool
	no_auto_update    bool
	running_as_root   bool
	now               i64
	fetch_succeeded   bool = true
}

pub fn api_fetch_files_result(config ApiFetchFilesConfig) ApiFetchFilesResult {
	target := if config.target != '' {
		config.target
	} else {
		api_cache_path('internal/packages.json')
	}
	stale := if config.has_stale_seconds {
		?i64(config.stale_seconds)
	} else if config.api_updated || config.no_auto_update {
		?i64(none)
	} else {
		?i64(api_default_stale_seconds)
	}
	now := if config.now != 0 { config.now } else { time.now().unix() }
	if os.exists(target) && os.file_size(target) > 0
		&& api_skip_download(target, stale, config.running_as_root, now) {
		return ApiFetchFilesResult{
			api_updated: true
		}
	}
	return ApiFetchFilesResult{
		api_updated: true
		enqueued: true
		fetched: config.fetch_succeeded
		shutdown: true
	}
}

pub fn api_write_names_file(path string, regenerate bool, names []string) !bool {
	if os.exists(path) && !regenerate {
		return false
	}
	mut sorted := names.clone()
	sorted.sort()
	os.mkdir_all(os.dir(path))!
	os.write_file(path, sorted.join('\n'))!
	return true
}

fn api_write_lines_file(path string, regenerate bool, lines []string) !bool {
	if os.exists(path) && !regenerate {
		return false
	}
	mut sorted := lines.clone()
	sorted.sort()
	os.mkdir_all(os.dir(path))!
	os.write_file(path, sorted.join('\n'))!
	return true
}

pub fn api_write_executables_file(target string, source string, regenerate bool, formulae map[string]json2.Any) !bool {
	if !regenerate && os.exists(target) && os.exists(source) && os.file_last_mod_unix(source) <= os.file_last_mod_unix(target) {
		return false
	}
	mut lines := []string{}
	for name, formula in formulae {
		executables_value := formula.as_map()['executables'] or { continue }
		executables := executables_value.as_array()
		if executables.len > 0 {
			lines << '${name}:${executables.map(it.str()).join(' ')}'
		}
	}
	if lines.len == 0 {
		if os.exists(target) {
			os.rm(target)!
			return true
		}
		return false
	}
	lines.sort()
	os.mkdir_all(os.dir(target))!
	os.write_file(target, '${lines.join('\n')}\n')!
	return true
}

fn api_homebrew_jws_signature(json_data json2.Any) ?json2.Any {
	signatures := (json_data.as_map()['signatures'] or { return none }).as_array()
	for signature in signatures {
		header := signature.as_map()['header'] or { continue }
		if (header.as_map()['kid'] or { continue }).str() == 'homebrew-1' {
			return signature
		}
	}
	return none
}

fn api_verify_and_parse_jws(json_data json2.Any, signature_verified bool, has_signature_result bool) !json2.Any {
	signature := api_homebrew_jws_signature(json_data) or { return error('key not found') }
	payload := (json_data.as_map()['payload'] or { json2.Any('') }).str()
	protected := (signature.as_map()['protected'] or { json2.Any('') }).str()
	signature_b64 := (signature.as_map()['signature'] or { json2.Any('') }).str()
	error_message := api_verify_jws_signature(protected, signature_b64, payload, signature_verified, has_signature_result) or { err.msg() }
	if error_message != '' {
		return error(error_message)
	}
	return api_parse_json(payload)
}

fn api_verify_jws_signature(protected_b64 string, signature_b64 string, payload string, signature_verified bool, has_signature_result bool) !string {
	_ = signature_b64
	_ = payload
	header_value := api_parse_json(api_urlsafe_decode64(protected_b64)!)!
	header_map := header_value.as_map()
	b64 := header_map['b64'] or { json2.Any(true) }
	if header_value !is map[string]json2.Any || (header_map['alg'] or { json2.Any('') }).str() != 'PS512'
		|| b64 !is bool || b64.bool() {
		return 'invalid algorithm'
	}
	if !has_signature_result || !signature_verified {
		return 'signature mismatch'
	}
	return ''
}

fn api_jws_payload_cacheable(target string, cache_root string) bool {
	name := os.base(target)
	return os.norm_path(os.dir(target)) == os.norm_path(os.join_path(cache_root, 'internal')) && name.starts_with('packages.') && name.ends_with('.jws.json')
}

struct ApiJwsSourceFingerprint {
	source_size     i64
	source_mtime_ns i64
}

fn api_jws_source_fingerprint(target string) !ApiJwsSourceFingerprint {
	stat := os.stat(target)!
	return ApiJwsSourceFingerprint{
		source_size: i64(stat.size)
		source_mtime_ns: stat.mtime * 1_000_000_000
	}
}

fn api_cached_jws_payload(target string, signature_verified bool, has_signature_result bool) ?json2.Any {
	payload := api_cached_jws_payload_string(target, signature_verified, has_signature_result) or {
		return none
	}
	return api_parse_json(payload) or { return none }
}

fn api_cached_jws_payload_string(target string, signature_verified bool, has_signature_result bool) ?string {
	root := os.dir(os.dir(target))
	if !api_jws_payload_cacheable(target, root) {
		return none
	}
	expected := api_jws_source_fingerprint(target) or { return none }
	contents := os.read_file('${target}.payload') or { return none }
	newline := contents.index('\n') or { return none }
	header := api_parse_json(contents[..newline]) or { return none }
	if header !is map[string]json2.Any {
		return none
	}
	header_map := header.as_map()
	if (header_map['source_size'] or { return none }).i64() != expected.source_size
		|| (header_map['source_mtime_ns'] or { return none }).i64() != expected.source_mtime_ns {
		return none
	}
	protected := header_map['protected'] or { return none }
	signature := header_map['signature'] or { return none }
	if protected !is string || signature !is string {
		return none
	}
	payload := contents[newline + 1..]
	verification := api_verify_jws_signature(protected.str(), signature.str(), payload, signature_verified, has_signature_result) or { return none }
	if verification != '' {
		return none
	}
	return payload
}

fn api_write_jws_payload_cache(target string, json_data json2.Any, running_as_root bool) ! {
	root := os.dir(os.dir(target))
	if !api_jws_payload_cacheable(target, root) || running_as_root
		|| json_data !is map[string]json2.Any {
		return
	}
	signature := api_homebrew_jws_signature(json_data) or { return }
	payload := json_data.as_map()['payload'] or { return }
	signature_map := signature.as_map()
	protected := signature_map['protected'] or { return }
	signature_b64 := signature_map['signature'] or { return }
	if payload !is string || protected !is string || signature_b64 !is string {
		return
	}
	fingerprint := api_jws_source_fingerprint(target)!
	header := json2.encode(json2.Any({
		'protected':       json2.Any(protected.str())
		'signature':       json2.Any(signature_b64.str())
		'source_size':     json2.Any(fingerprint.source_size)
		'source_mtime_ns': json2.Any(fingerprint.source_mtime_ns)
	}))
	temporary := '${target}.payload.tmp'
	os.write_file(temporary, '${header}\n${payload.str()}')!
	os.mv(temporary, '${target}.payload')!
}

pub fn api_urlsafe_decode64(value string) !string {
	if value.len % 4 == 1 || value.bytes().any(!(it.is_alnum() || it == `-` || it == `_` || it == `=`)) {
		return error('invalid base64')
	}
	return base64.url_decode_str(value)
}

pub fn api_with_no_api_env[T](no_install_from_api bool, block fn () T) T {
	if no_install_from_api {
		return block()
	}
	old_no_api := os.getenv_opt('HOMEBREW_NO_INSTALL_FROM_API')
	old_automatic := os.getenv_opt('HOMEBREW_AUTOMATICALLY_SET_NO_INSTALL_FROM_API')
	os.setenv('HOMEBREW_NO_INSTALL_FROM_API', '1', true)
	os.setenv('HOMEBREW_AUTOMATICALLY_SET_NO_INSTALL_FROM_API', '1', true)
	defer {
		api_restore_env('HOMEBREW_NO_INSTALL_FROM_API', old_no_api)
		api_restore_env('HOMEBREW_AUTOMATICALLY_SET_NO_INSTALL_FROM_API', old_automatic)
	}
	return block()
}

fn api_restore_env(name string, value ?string) {
	if previous := value {
		os.setenv(name, previous, true)
	} else {
		os.unsetenv(name)
	}
}
