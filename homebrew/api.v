module homebrew

import ruby
import encoding.base64
import os
import time
import x.json2

// Translated from Homebrew/brew `api.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `self.fetch(endpoint)` at line 34.
pub fn ruby_api_l34_d1_self_fetch(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return api_error_value('ArgumentError', 'endpoint is required')
	}
	mut config := if args.len > 1 { api_fetch_config_from_value(args[1]) } else { ApiFetchConfig{} }
	return api_fetch(args[0].as_string(), mut config) or {
		api_error_value('ArgumentError', err.msg())
	}
}

// Ruby method `self.skip_download?(target:, stale_seconds:)` at line 52.
pub fn ruby_api_l52_d2_self_skip_download(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	target := args[0].as_string()
	stale_seconds := if args.len > 1 && args[1].type_name == 'Integer' {
		?i64(args[1].int_data)
	} else {
		none
	}
	running_as_root := args.len > 2 && args[2].bool_data
	now := if args.len > 3 && args[3].type_name == 'Integer' {
		args[3].int_data
	} else {
		time.now().unix()
	}
	return ruby.bool_value(api_skip_download(target, stale_seconds, running_as_root, now))
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
			if stale.type_name == 'Integer' { ?i64(stale.int_data) } else { none }} else {
			none}
		now: (values['now'] or { ruby.int_value(time.now().unix()) }).int_data
		running_as_root: (values['running_as_root'] or { ruby.bool_value(false) }).bool_data
		insecure_download: (values['insecure_download'] or { ruby.bool_value(false) }).bool_data
		enqueue: (values['enqueue'] or { ruby.bool_value(false) }).bool_data
		download_attempts: attempts
		curl_retries: int((values['curl_retries'] or { ruby.int_value(0) }).int_data)
		signature_verified: (values['signature_verified'] or { ruby.bool_value(true) }).bool_data
		payload_cache_signature_verified: (values['payload_cache_signature_verified'] or {
			ruby.bool_value(true)}).bool_data
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

// Ruby method `self.fetch_json_api_file(endpoint, target: HOMEBREW_CACHE_API/endpoint,` at line 69.
pub fn ruby_api_l69_d3_self_fetch_json_api_file(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return api_error_value('ArgumentError', 'endpoint is required')
	}
	endpoint := args[0].as_string()
	config := if args.len > 1 {
		api_fetch_json_config_from_value(endpoint, args[1])
	} else {
		ApiFetchJsonConfig{
			target: api_cache_path(endpoint)
			now: time.now().unix()
		}
	}
	result := api_fetch_json_api_file(endpoint, config) or {
		return api_error_value('SystemExit', err.msg())
	}
	return api_fetch_json_result_value(result)
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

// Ruby method `self.fetch_api_files!` at line 208.
pub fn ruby_api_l208_d5_self_fetch_api_files(args ...ruby.Value) ruby.Value {
	config := if args.len > 0 { args[0].map_data } else { map[string]ruby.Value{} }
	_ = api_fetch_files_result(config)
	return api_nil_value()
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

// Ruby method `self.write_names_and_aliases` at line 240.
pub fn ruby_api_l240_d6_self_write_names_and_aliases(args ...ruby.Value) ruby.Value {
	return if args.len > 1 { args[1] } else { api_nil_value() }
}

// Ruby method `self.write_names_file!(type, regenerate:, &names)` at line 246.
pub fn ruby_api_l246_d7_self_write_names_file(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return api_error_value('ArgumentError', 'type, regenerate and names are required')
	}
	type_name := args[0].as_string()
	regenerate := args[1].bool_data
	names := args[2].as_array() or { return api_error_value('TypeError', err.msg()) }
	path := if args.len > 3 {
		args[3].as_string()
	} else {
		os.join_path(api_cache_root(), '${type_name}_names.txt')
	}
	return ruby.bool_value(api_write_names_file(path, regenerate, names.map(it.as_string())) or {
		return api_error_value('SystemCallError', err.msg())
	})
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

// Ruby method `self.write_aliases_file!(type, regenerate:, &aliases)` at line 261.
pub fn ruby_api_l261_d8_self_write_aliases_file(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return api_error_value('ArgumentError', 'type, regenerate and aliases are required')
	}
	type_name := args[0].as_string()
	regenerate := args[1].bool_data
	aliases := args[2].map_data.clone()
	path := if args.len > 3 {
		args[3].as_string()
	} else {
		os.join_path(api_cache_root(), '${type_name}_aliases.txt')
	}
	mut lines := []string{}
	for alias_name, real_name in aliases {
		lines << '${alias_name}|${real_name.as_string()}'
	}
	return ruby.bool_value(api_write_lines_file(path, regenerate, lines) or {
		return api_error_value('SystemCallError', err.msg())
	})
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

// Ruby method `self.write_executables_file!(regenerate:, source:, &formulae)` at line 282.
pub fn ruby_api_l282_d9_self_write_executables_file(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return api_error_value('ArgumentError', 'regenerate, source and formulae are required')
	}
	regenerate := args[0].bool_data
	source := args[1].as_string()
	formulae := args[2].map_data.clone()
	target := if args.len > 3 {
		args[3].as_string()
	} else {
		os.join_path(api_cache_root(), 'internal', 'executables.txt')
	}
	return ruby.bool_value(api_write_executables_file(target, source, regenerate, formulae) or {
		return api_error_value('SystemCallError', err.msg())
	})
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

// Ruby method `self.download_executables_file_from_github_packages!(target)` at line 314.
pub fn ruby_api_l314_d10_self_download_executables_file_from_github_packages(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	target := args[0].as_string()
	config := args[1].map_data.clone()
	manifest_output := config['manifest'] or { return ruby.bool_value(false) }
	if !(config['manifest_success'] or { ruby.bool_value(true) }).bool_data {
		return ruby.bool_value(false)
	}
	manifest := api_parse_json(manifest_output.as_string()) or {
		return ruby.bool_value(false)
	}
	layers := (manifest.map_data['layers'] or { api_nil_value() }).as_array() or {
		return ruby.bool_value(false)
	}
	mut digest := ''
	for layer in layers {
		annotations := layer.map_data['annotations'] or { continue }
		title := annotations.map_data['org.opencontainers.image.title'] or { continue }
		if title.as_string() == os.base(target) {
			digest = (layer.map_data['digest'] or { api_nil_value() }).as_string()
			break
		}
	}
	if digest == '' || !(config['download_success'] or { ruby.bool_value(true) }).bool_data {
		return ruby.bool_value(false)
	}
	os.mkdir_all(os.dir(target)) or { return ruby.bool_value(false) }
	os.write_file(target, (config['download_stdout'] or { ruby.string_value('') }).as_string()) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(true)
}

// Ruby method `self.verify_and_parse_jws(json_data)` at line 357.
pub fn ruby_api_l357_d11_self_verify_and_parse_jws(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([ruby.bool_value(false),
			ruby.string_value('key not found')])
	}
	verified := args.len < 2 || args[1].bool_data
	has_result := args.len < 3 || args[2].bool_data
	data := api_verify_and_parse_jws(args[0], verified, has_result) or {
		return ruby.array_value([ruby.bool_value(false),
			ruby.string_value(err.msg())])
	}
	return ruby.array_value([ruby.bool_value(true), data])
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

// Ruby method `self.homebrew_jws_signature(json_data)` at line 370.
pub fn ruby_api_l370_d12_self_homebrew_jws_signature(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return api_nil_value()
	}
	return api_homebrew_jws_signature(args[0]) or { api_nil_value() }
}

// Ruby method `self.verify_jws_signature(protected_b64, signature_b64, payload)` at line 377.
pub fn ruby_api_l377_d13_self_verify_jws_signature(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.string_value('invalid algorithm')
	}
	verified := args.len < 4 || args[3].bool_data
	has_result := args.len < 5 || args[4].bool_data
	message := api_verify_jws_signature(args[0].as_string(), args[1].as_string(), args[2].as_string(), verified, has_result) or { err.msg() }
	return if message == '' { api_nil_value() } else { ruby.string_value(message) }
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

// Ruby method `self.jws_public_key_pem` at line 396.
pub fn ruby_api_l396_d14_self_jws_public_key_pem(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 { args[0].as_string() } else { os.join_path('api', 'homebrew-1.pem') }
	return ruby.string_value(os.read_file(path) or { return api_error_value('SystemCallError', err.msg()) })
}

// Ruby method `self.jws_payload_cache_path(target)` at line 401.
pub fn ruby_api_l401_d15_self_jws_payload_cache_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return api_nil_value()
	}
	return ruby.object_value('Pathname', '${args[0].as_string()}.payload')
}

// Ruby method `self.jws_payload_cacheable?(target)` at line 410.
pub fn ruby_api_l410_d16_self_jws_payload_cacheable(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	root := if args.len > 1 { args[1].as_string() } else { api_cache_root() }
	return ruby.bool_value(api_jws_payload_cacheable(args[0].as_string(), root))
}

fn api_jws_payload_cacheable(target string, cache_root string) bool {
	name := os.base(target)
	return os.norm_path(os.dir(target)) == os.norm_path(os.join_path(cache_root, 'internal')) && name.starts_with('packages.') && name.ends_with('.jws.json')
}

// Ruby method `self.jws_source_fingerprint(stat)` at line 418.
pub fn ruby_api_l418_d17_self_jws_source_fingerprint(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return api_nil_value()
	}
	if args[0].type_name == 'Hash' {
		return ruby.map_value({
			'source_size':     args[0].map_data['size'] or { ruby.int_value(0) }
			'source_mtime_ns': ruby.int_value((args[0].map_data['mtime'] or { ruby.int_value(0) }).int_data * 1_000_000_000)
		})
	}
	return api_jws_source_fingerprint(args[0].as_string()) or { api_nil_value() }
}

fn api_jws_source_fingerprint(target string) !ruby.Value {
	stat := os.stat(target)!
	return ruby.map_value({
		'source_size':     ruby.int_value(stat.size)
		'source_mtime_ns': ruby.int_value(stat.mtime * 1_000_000_000)
	})
}

// Ruby method `self.cached_internal_packages_payload(endpoint, stale_seconds:)` at line 433.
pub fn ruby_api_l433_d18_self_cached_internal_packages_payload(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return api_nil_value()
	}
	endpoint := args[0].as_string()
	stale := if args.len > 1 && args[1].type_name == 'Integer' {
		?i64(args[1].int_data)
	} else {
		none
	}
	root := if args.len > 2 { args[2].as_string() } else { api_cache_root() }
	target := os.join_path(root, endpoint)
	now := if args.len > 3 { args[3].int_data } else { time.now().unix() }
	if !api_jws_payload_cacheable(target, root) || !os.exists(target) || os.file_size(target) == 0 || !api_skip_download(target, stale, false, now) {
		return api_nil_value()
	}
	payload := api_cached_jws_payload_string(target, true, true) or { return api_nil_value() }
	return ruby.array_value([
		ruby.string_value(payload),
		api_jws_source_fingerprint(target) or { api_nil_value() },
	])
}

// Ruby method `self.cached_jws_payload(target)` at line 453.
pub fn ruby_api_l453_d19_self_cached_jws_payload(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return api_nil_value()
	}
	verified := args.len < 2 || args[1].bool_data
	has_result := args.len < 3 || args[2].bool_data
	return api_cached_jws_payload(args[0].as_string(), verified, has_result) or { api_nil_value() }
}

fn api_cached_jws_payload(target string, signature_verified bool, has_signature_result bool) ?ruby.Value {
	payload := api_cached_jws_payload_string(target, signature_verified, has_signature_result) or {
		return none
	}
	return api_parse_json(payload) or { return none }
}

// Ruby method `self.cached_jws_payload_string(target, source_stat:)` at line 463.
pub fn ruby_api_l463_d20_self_cached_jws_payload_string(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return api_nil_value()
	}
	verified := args.len < 2 || args[1].bool_data
	has_result := args.len < 3 || args[2].bool_data
	return ruby.string_value(api_cached_jws_payload_string(args[0].as_string(), verified, has_result) or { return api_nil_value() })
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
			api_nil_value()}).int_data {
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

// Ruby method `self.write_jws_payload_index_cache(target, json_data, parsed:, source_stat:)` at line 498.
pub fn ruby_api_l498_d21_self_write_jws_payload_index_cache(args ...ruby.Value) ruby.Value {
	if args.len < 3 || args[1].type_name != 'Hash' || args[2].type_name != 'Hash' {
		return api_nil_value()
	}
	payload := args[1].map_data['payload'] or { return api_nil_value() }
	if payload.type_name != 'String' {
		return api_nil_value()
	}
	_ = payload
	return api_nil_value()
}

// Ruby method `self.write_jws_payload_cache(target, json_data, source_stat:)` at line 512.
pub fn ruby_api_l512_d22_self_write_jws_payload_cache(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return api_nil_value()
	}
	running_as_root := args.len > 2 && args[2].bool_data
	api_write_jws_payload_cache(args[0].as_string(), args[1], running_as_root) or {
		return api_nil_value()
	}
	return api_nil_value()
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

// Ruby method `self.urlsafe_decode64(value)` at line 546.
pub fn ruby_api_l546_d23_self_urlsafe_decode64(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return api_error_value('ArgumentError', 'value is required')
	}
	return ruby.string_value(api_urlsafe_decode64(args[0].as_string()) or {
		return api_error_value('ArgumentError', err.msg())
	})
}

pub fn api_urlsafe_decode64(value string) !string {
	if value.len % 4 == 1 || value.bytes().any(!(it.is_alnum() || it == `-` || it == `_` || it == `=`)) {
		return error('invalid base64')
	}
	return base64.url_decode_str(value)
}

// Ruby method `self.tap_from_source_download(path)` at line 551.
pub fn ruby_api_l551_d24_self_tap_from_source_download(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return api_nil_value()
	}
	root := if args.len > 1 {
		os.abs_path(args[1].as_string())
	} else {
		os.abs_path(api_source_cache_root())
	}
	path := os.abs_path(args[0].as_string())
	prefix := root.trim_right(os.path_separator) + os.path_separator
	if !path.starts_with(prefix) {
		return api_nil_value()
	}
	relative := path[prefix.len..]
	parts := relative.split(os.path_separator)
	if parts.len < 2 || parts[0] == '' || parts[1] == '' {
		return api_nil_value()
	}
	return ruby.structured_value('Tap', '${parts[0]}/${parts[1]}', {
		'user': parts[0]
		'repo': parts[1]
	})
}

// Ruby method `self.formula_names` at line 563.
pub fn ruby_api_l563_d25_self_formula_names(args ...ruby.Value) ruby.Value {
	return if args.len > 0 { args[0] } else { ruby.array_value([]) }
}

// Ruby method `self.formula_name?(name)` at line 568.
pub fn ruby_api_l568_d26_self_formula_name(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	names := args[1].as_array() or { return ruby.bool_value(false) }
	return ruby.bool_value(args[0].as_string() in names.map(it.as_string()))
}

// Ruby method `self.formula_aliases` at line 573.
pub fn ruby_api_l573_d27_self_formula_aliases(args ...ruby.Value) ruby.Value {
	return if args.len > 0 { args[0] } else { ruby.map_value({}) }
}

// Ruby method `self.formula_renames` at line 578.
pub fn ruby_api_l578_d28_self_formula_renames(args ...ruby.Value) ruby.Value {
	return if args.len > 0 { args[0] } else { ruby.map_value({}) }
}

// Ruby method `self.formula_tap_migrations` at line 583.
pub fn ruby_api_l583_d29_self_formula_tap_migrations(args ...ruby.Value) ruby.Value {
	return if args.len > 0 { args[0] } else { ruby.map_value({}) }
}

// Ruby method `self.cask_tokens` at line 588.
pub fn ruby_api_l588_d30_self_cask_tokens(args ...ruby.Value) ruby.Value {
	return if args.len > 0 { args[0] } else { ruby.array_value([]) }
}

// Ruby method `self.cask_token?(token)` at line 593.
pub fn ruby_api_l593_d31_self_cask_token(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	names := args[1].as_array() or { return ruby.bool_value(false) }
	return ruby.bool_value(args[0].as_string() in names.map(it.as_string()))
}

// Ruby method `self.cask_renames` at line 598.
pub fn ruby_api_l598_d32_self_cask_renames(args ...ruby.Value) ruby.Value {
	return if args.len > 0 { args[0] } else { ruby.map_value({}) }
}

// Ruby method `self.cask_tap_migrations` at line 603.
pub fn ruby_api_l603_d33_self_cask_tap_migrations(args ...ruby.Value) ruby.Value {
	return if args.len > 0 { args[0] } else { ruby.map_value({}) }
}

// Ruby method `self.cached_cask_json_file_path` at line 608.
pub fn ruby_api_l608_d34_self_cached_cask_json_file_path(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		args[0]
	} else {
		ruby.object_value('Pathname', api_cache_path('internal/packages.json'))
	}
}

// Ruby method `self.with_no_api_env(&block)` at line 614.
pub fn ruby_api_l614_d35_self_with_no_api_env(args ...ruby.Value) ruby.Value {
	no_install := args.len > 0 && args[0].bool_data
	result := if args.len > 1 { args[1] } else { api_nil_value() }
	return api_with_no_api_env_value(no_install, fn [result] () ruby.Value {
		return result
	})
}

pub fn api_with_no_api_env_value(no_install_from_api bool, block fn() ruby.Value) ruby.Value {
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

// Ruby method `self.with_no_api_env_if_needed(condition, &block)` at line 626.
pub fn ruby_api_l626_d36_self_with_no_api_env_if_needed(args ...ruby.Value) ruby.Value {
	condition := args.len > 0 && args[0].bool_data
	no_install := args.len > 1 && args[1].bool_data
	result := if args.len > 2 { args[2] } else { api_nil_value() }
	if !condition {
		return result
	}
	return api_with_no_api_env_value(no_install, fn [result] () ruby.Value {
		return result
	})
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
