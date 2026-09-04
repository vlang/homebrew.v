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
	cache map[string]ruby.Value
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
	data    ruby.Value
	updated bool
}

pub struct ApiFetchFilesResult {
pub:
	api_updated bool
	enqueued    bool
	fetched     bool
	shutdown    bool
}

fn api_nil_value() ruby.Value {
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn api_error_value(kind string, message string) ruby.Value {
	return ruby.structured_value(kind, message, {
		'message': message
	})
}

pub fn api_value_from_json(value json2.Any) ruby.Value {
	return ruby.json_value_from_any(value)
}

pub fn api_value_to_json(value ruby.Value) json2.Any {
	return ruby.json_any_from_value(value)
}

pub fn api_parse_json(contents string) !ruby.Value {
	return ruby.parse_json_value(contents)
}

pub fn api_fetch(endpoint string, mut config ApiFetchConfig) !ruby.Value {
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

fn api_fetch_config_from_value(value ruby.Value) ApiFetchConfig {
	mut config := ApiFetchConfig{}
	if value.type_name != 'Hash' {
		return config
	}
	values := value.map_data.clone()
	if domain := values['api_domain'] {
		config = ApiFetchConfig{
			...config
			api_domain: domain.as_string()
		}
	}
	if domain := values['default_domain'] {
		config = ApiFetchConfig{
			...config
			default_domain: domain.as_string()
		}
	}
	if cached := values['cache'] {
		config.cache = cached.map_data.clone()
	}
	if primary := values['primary'] {
		config = ApiFetchConfig{
			...config
			primary: ApiCurlOutput{
				stdout: primary.map_data['stdout'] or { api_nil_value() }.as_string()
				success: (primary.map_data['success'] or { ruby.bool_value(false) }).bool_data
			}
		}
	}
	if fallback := values['fallback'] {
		config = ApiFetchConfig{
			...config
			fallback: ApiCurlOutput{
				stdout: fallback.map_data['stdout'] or { api_nil_value() }.as_string()
				success: (fallback.map_data['success'] or { ruby.bool_value(false) }).bool_data
			}
		}
	}
	return config
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

fn api_fetch_json_config_from_value(endpoint string, value ruby.Value) ApiFetchJsonConfig {
	values := value.map_data.clone()
	mut attempts := []ApiDownloadAttempt{}
	attempt_values := values['download_attempts'] or { api_nil_value() }
	for attempt in attempt_values.array_data {
		attempts << ApiDownloadAttempt{
			url: (attempt.map_data['url'] or { ruby.string_value('') }).as_string()
			stdout: (attempt.map_data['stdout'] or { ruby.string_value('') }).as_string()
			success: (attempt.map_data['success'] or { ruby.bool_value(false) }).bool_data
		}
	}
	return ApiFetchJsonConfig{
		api_domain: (values['api_domain'] or { ruby.string_value(api_default_domain) }).as_string()
		default_domain: (values['default_domain'] or { ruby.string_value(api_default_domain) }).as_string()
		target: (values['target'] or { ruby.string_value(api_cache_path(endpoint)) }).as_string()
		stale_seconds: if stale := values['stale_seconds'] {
			if stale.type_name == 'Integer' { ?i64(stale.int_data) } else { none }
		} else {
			none
		}
		now: (values['now'] or { ruby.int_value(time.now().unix()) }).int_data
		running_as_root: (values['running_as_root'] or { ruby.bool_value(false) }).bool_data
		insecure_download: (values['insecure_download'] or { ruby.bool_value(false) }).bool_data
		enqueue: (values['enqueue'] or { ruby.bool_value(false) }).bool_data
		download_attempts: attempts
		curl_retries: int((values['curl_retries'] or { ruby.int_value(0) }).int_data)
		signature_verified: (values['signature_verified'] or { ruby.bool_value(true) }).bool_data
		payload_cache_signature_verified: (values['payload_cache_signature_verified'] or {
			ruby.bool_value(true)
		}).bool_data
		has_signature_result: (values['has_signature_result'] or { ruby.bool_value(true) }).bool_data
	}
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

fn api_fetch_json_result_value(result ApiFetchJsonResult) ruby.Value {
	return ruby.array_value([
		result.data,
		ruby.bool_value(result.updated),
	])
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
			data: ruby.map_value({})
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
pub fn ruby_api_l194_d4_self_merge_variations(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name != 'Hash' {
		return api_nil_value()
	}
	mut json := args[0].map_data.clone()
	variations := json['variations'] or { return args[0] }
	tag := if args.len > 1 { args[1].as_string() } else { api_current_tag() }
	if variation := variations.map_data[tag] {
		if variation.map_data.len > 0 {
			for key, value in variation.map_data {
				json[key] = value
			}
		}
	}
	json.delete('variations')
	return ruby.map_value(json)
}

fn api_current_tag() string {
	return ruby.environment_value('HOMEBREW_SIMULATE_TAG')
}

pub fn api_fetch_files_result(config map[string]ruby.Value) ApiFetchFilesResult {
	target := (config['target'] or { ruby.string_value(api_cache_path('internal/packages.json')) }).as_string()
	stale := if value := config['stale_seconds'] {
		if value.type_name == 'Integer' { ?i64(value.int_data) } else { none }
	} else if (config['api_updated'] or { ruby.bool_value(false) }).bool_data || (config['no_auto_update'] or { ruby.bool_value(false) }).bool_data {
		none
	} else {
		?i64(api_default_stale_seconds)
	}
	root := (config['running_as_root'] or { ruby.bool_value(false) }).bool_data
	now := (config['now'] or { ruby.int_value(time.now().unix()) }).int_data
	if os.exists(target) && os.file_size(target) > 0 && api_skip_download(target, stale, root, now) {
		return ApiFetchFilesResult{
			api_updated: true
		}
	}
	return ApiFetchFilesResult{
		api_updated: true
		enqueued: true
		fetched: (config['fetch_succeeded'] or { ruby.bool_value(true) }).bool_data
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

pub fn api_write_executables_file(target string, source string, regenerate bool, formulae map[string]ruby.Value) !bool {
	if !regenerate && os.exists(target) && os.exists(source) && os.file_last_mod_unix(source) <= os.file_last_mod_unix(target) {
		return false
	}
	mut lines := []string{}
	for name, formula in formulae {
		executables_value := formula.map_data['executables'] or { continue }
		executables := executables_value.as_array() or { continue }
		if executables.len > 0 {
			lines << '${name}:${executables.map(it.as_string()).join(' ')}'
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

fn api_homebrew_jws_signature(json_data ruby.Value) ?ruby.Value {
	signatures := (json_data.map_data['signatures'] or { return none }).as_array() or { return none }
	for signature in signatures {
		header := signature.map_data['header'] or { continue }
		if (header.map_data['kid'] or { api_nil_value() }).as_string() == 'homebrew-1' {
			return signature
		}
	}
	return none
}

fn api_verify_and_parse_jws(json_data ruby.Value, signature_verified bool, has_signature_result bool) !ruby.Value {
	signature := api_homebrew_jws_signature(json_data) or { return error('key not found') }
	payload := (json_data.map_data['payload'] or { ruby.string_value('') }).as_string()
	protected := (signature.map_data['protected'] or { ruby.string_value('') }).as_string()
	signature_b64 := (signature.map_data['signature'] or { ruby.string_value('') }).as_string()
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
	if header_value.type_name != 'Hash' || (header_value.map_data['alg'] or { api_nil_value() }).as_string() != 'PS512' || (header_value.map_data['b64'] or { ruby.bool_value(true) }).type_name != 'Bool' || (header_value.map_data['b64'] or { ruby.bool_value(true) }).bool_data {
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

fn api_jws_source_fingerprint(target string) !ruby.Value {
	stat := os.stat(target)!
	return ruby.map_value({
		'source_size':     ruby.int_value(stat.size)
		'source_mtime_ns': ruby.int_value(stat.mtime * 1_000_000_000)
	})
}

fn api_cached_jws_payload(target string, signature_verified bool, has_signature_result bool) ?ruby.Value {
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
	if header.type_name != 'Hash' {
		return none
	}
	for key in ['source_size', 'source_mtime_ns'] {
		if (header.map_data[key] or { api_nil_value() }).int_data != (expected.map_data[key] or {
			api_nil_value()
		}).int_data {
			return none
		}
	}
	protected := header.map_data['protected'] or { return none }
	signature := header.map_data['signature'] or { return none }
	if protected.type_name != 'String' || signature.type_name != 'String' {
		return none
	}
	payload := contents[newline + 1..]
	verification := api_verify_jws_signature(protected.as_string(), signature.as_string(), payload, signature_verified, has_signature_result) or { return none }
	if verification != '' {
		return none
	}
	return payload
}

fn api_write_jws_payload_cache(target string, json_data ruby.Value, running_as_root bool) ! {
	root := os.dir(os.dir(target))
	if !api_jws_payload_cacheable(target, root) || running_as_root || json_data.type_name != 'Hash' {
		return
	}
	signature := api_homebrew_jws_signature(json_data) or { return }
	payload := json_data.map_data['payload'] or { return }
	protected := signature.map_data['protected'] or { return }
	signature_b64 := signature.map_data['signature'] or { return }
	if payload.type_name != 'String' || protected.type_name != 'String' || signature_b64.type_name != 'String' {
		return
	}
	fingerprint := api_jws_source_fingerprint(target)!
	header := json2.encode(json2.Any({
		'protected':       json2.Any(protected.as_string())
		'signature':       json2.Any(signature_b64.as_string())
		'source_size':     json2.Any(fingerprint.map_data['source_size'].int_data)
		'source_mtime_ns': json2.Any(fingerprint.map_data['source_mtime_ns'].int_data)
	}))
	temporary := '${target}.payload.tmp'
	os.write_file(temporary, '${header}\n${payload.as_string()}')!
	os.mv(temporary, '${target}.payload')!
}

pub fn api_urlsafe_decode64(value string) !string {
	if value.len % 4 == 1 || value.bytes().any(!(it.is_alnum() || it == `-` || it == `_` || it == `=`)) {
		return error('invalid base64')
	}
	return base64.url_decode_str(value)
}

pub fn api_with_no_api_env_value(no_install_from_api bool, block fn () ruby.Value) ruby.Value {
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
