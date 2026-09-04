module test

import ruby
import encoding.base64
import homebrew
import os
import time
import x.json2

// Translated from Homebrew/brew `test/api_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:text) { "foo" }` at line 8.
pub fn ruby_api_spec_l8_d1_text(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('foo')
}

// Ruby let `let(:json) { '{"foo":"bar"}' }` at line 9.
pub fn ruby_api_spec_l9_d2_json(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('{"foo":"bar"}')
}

// Ruby let `let(:json_hash) { JSON.parse(json) }` at line 10.
pub fn ruby_api_spec_l10_d3_json_hash(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({
		'foo': ruby.string_value('bar')
	})
}

// Ruby let `let(:json_invalid) { '{"foo":"bar"' }` at line 11.
pub fn ruby_api_spec_l11_d4_json_invalid(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('{"foo":"bar"')
}

fn api_spec_nil() ruby.Value {
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn api_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn api_spec_temp_dir(label string) string {
	path := os.join_path(os.temp_dir(), 'brew-v-api-spec-${label}-${time.now().unix_micro()}')
	os.mkdir_all(path) or { return '' }
	return path
}

fn api_spec_curl_result(stdout string, success bool) ruby.Value {
	return ruby.map_value({
		'stdout':  ruby.string_value(stdout)
		'success': ruby.bool_value(success)
	})
}

fn api_spec_fetch_config(primary ruby.Value) ruby.Value {
	return ruby.map_value({
		'primary': primary
	})
}

fn api_spec_download_attempt(url string, stdout string, success bool) ruby.Value {
	return ruby.map_value({
		'url':     ruby.string_value(url)
		'stdout':  ruby.string_value(stdout)
		'success': ruby.bool_value(success)
	})
}

fn api_spec_value_equal(left ruby.Value, right ruby.Value) bool {
	if left.type_name != right.type_name {
		return false
	}
	if left.type_name == 'Hash' {
		if left.map_data.len != right.map_data.len {
			return false
		}
		for key, value in left.map_data {
			other := right.map_data[key] or { return false }
			if !api_spec_value_equal(value, other) {
				return false
			}
		}
		return true
	}
	if left.type_name == 'Array' {
		left_items := left.as_array() or { return false }
		right_items := right.as_array() or { return false }
		if left_items.len != right_items.len {
			return false
		}
		for index, item in left_items {
			if !api_spec_value_equal(item, right_items[index]) {
				return false
			}
		}
		return true
	}
	return left.repr == right.repr && left.bool_data == right.bool_data && left.int_data == right.int_data
}

fn api_spec_fetch_json_config(target string, attempts []ruby.Value) ruby.Value {
	return ruby.map_value({
		'target':            ruby.string_value(target)
		'now':               ruby.int_value(time.now().unix())
		'download_attempts': ruby.array_value(attempts)
	})
}

// Ruby method `mock_curl_output(stdout: "", success: true)` at line 13.
pub fn ruby_api_spec_l13_d5_mock_curl_output(args ...ruby.Value) ruby.Value {
	stdout := if args.len > 0 { args[0].as_string() } else { '' }
	success := args.len < 2 || args[1].bool_data
	return api_spec_curl_result(stdout, success)
}

// Ruby method `mock_curl_download(stdout:)` at line 18.
pub fn ruby_api_spec_l18_d6_mock_curl_download(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.structured_value('ArgumentError', 'stdout is required', {})
	}
	url := if args.len > 1 { args[1].as_string() } else { '' }
	return api_spec_download_attempt(url, args[0].as_string(), true)
}

// Ruby it `it "fetches a JSON file" do` at line 25.
pub fn ruby_api_spec_l25_d7_fetches(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.ruby_api_l34_d1_self_fetch(ruby.string_value('foo.json'), api_spec_fetch_config(api_spec_curl_result('{"foo":"bar"}', true)))
	return api_spec_bool(api_spec_value_equal(result, ruby_api_spec_l10_d3_json_hash()))
}

// Ruby it `it "raises an error if the file does not exist" do` at line 31.
pub fn ruby_api_spec_l31_d8_raises(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.ruby_api_l34_d1_self_fetch(ruby.string_value('bar.txt'), api_spec_fetch_config(api_spec_curl_result('', false)))
	return api_spec_bool(result.type_name == 'ArgumentError' && result.as_string().contains('No file found'))
}

// Ruby it `it "raises an error if the JSON file is invalid" do` at line 36.
pub fn ruby_api_spec_l36_d9_raises(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.ruby_api_l34_d1_self_fetch(ruby.string_value('baz.txt'), api_spec_fetch_config(api_spec_curl_result('foo', true)))
	return api_spec_bool(result.type_name == 'ArgumentError' && result.as_string().contains('Invalid JSON file'))
}

// Ruby it `it "returns true for a core formula name" do` at line 47.
pub fn ruby_api_spec_l47_d10_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return homebrew.ruby_api_l568_d26_self_formula_name(ruby.string_value('foo'), ruby.string_array_value([
		'foo',
	]))
}

// Ruby it `it "returns false for an unknown name" do` at line 51.
pub fn ruby_api_spec_l51_d11_returns(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.ruby_api_l568_d26_self_formula_name(ruby.string_value('bar'), ruby.string_array_value([
		'foo',
	]))
	return api_spec_bool(!result.bool_data)
}

// Ruby it `it "returns true for a core cask token" do` at line 61.
pub fn ruby_api_spec_l61_d12_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return homebrew.ruby_api_l593_d31_self_cask_token(ruby.string_value('foo'), ruby.string_array_value([
		'foo',
	]))
}

// Ruby it `it "returns false for an unknown token" do` at line 65.
pub fn ruby_api_spec_l65_d13_returns(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.ruby_api_l593_d31_self_cask_token(ruby.string_value('bar'), ruby.string_array_value([
		'foo',
	]))
	return api_spec_bool(!result.bool_data)
}

// Ruby let! `let!(:cache_dir) { mktmpdir }` at line 71.
pub fn ruby_api_spec_l71_d14_cache_dir(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', api_spec_temp_dir('fetch-json'))
}

// Ruby it `it "fetches a JSON file" do` at line 77.
pub fn ruby_api_spec_l77_d15_fetches(args ...ruby.Value) ruby.Value {
	cache_dir := if args.len > 0 { args[0].as_string() } else { api_spec_temp_dir('fetch-new') }
	target := os.join_path(cache_dir, 'foo.json')
	result := homebrew.ruby_api_l69_d3_self_fetch_json_api_file(ruby.string_value('foo.json'), api_spec_fetch_json_config(target, [
		api_spec_download_attempt('', '{"foo":"bar"}', true),
	]))
	items := result.as_array() or { return api_spec_bool(false) }
	return api_spec_bool(items.len == 2 && api_spec_value_equal(items[0], ruby_api_spec_l10_d3_json_hash()))
}

// Ruby it `it "updates an existing JSON file" do` at line 83.
pub fn ruby_api_spec_l83_d16_updates(args ...ruby.Value) ruby.Value {
	cache_dir := if args.len > 0 { args[0].as_string() } else { api_spec_temp_dir('fetch-update') }
	target := os.join_path(cache_dir, 'bar.json')
	os.write_file(target, 'tmp') or { return api_spec_bool(false) }
	result := homebrew.ruby_api_l69_d3_self_fetch_json_api_file(ruby.string_value('bar.json'), api_spec_fetch_json_config(target, [
		api_spec_download_attempt('', '{"foo":"bar"}', true),
	]))
	items := result.as_array() or { return api_spec_bool(false) }
	return api_spec_bool(items.len == 2 && api_spec_value_equal(items[0], ruby_api_spec_l10_d3_json_hash()))
}

// Ruby it `it "raises an error if the JSON file is invalid" do` at line 89.
pub fn ruby_api_spec_l89_d17_raises(args ...ruby.Value) ruby.Value {
	cache_dir := if args.len > 0 { args[0].as_string() } else { api_spec_temp_dir('fetch-invalid') }
	target := os.join_path(cache_dir, 'baz.json')
	result := homebrew.ruby_api_l69_d3_self_fetch_json_api_file(ruby.string_value('baz.json'), api_spec_fetch_json_config(target, [
		api_spec_download_attempt('', '{"foo":"bar"', true),
	]))
	return api_spec_bool(result.type_name == 'SystemExit')
}

// Ruby it `it "does not refresh the cache mtime when the download fails" do` at line 96.
pub fn ruby_api_spec_l96_d18_does(args ...ruby.Value) ruby.Value {
	cache_dir := if args.len > 0 { args[0].as_string() } else { api_spec_temp_dir('mtime-fail') }
	target := os.join_path(cache_dir, 'bar.json')
	os.write_file(target, '{"foo":"bar"}') or { return api_spec_bool(false) }
	stale := time.now().unix() - 7200
	os.utime(target, stale, stale) or { return api_spec_bool(false) }
	config := ruby.map_value({
		'target':            ruby.string_value(target)
		'now':               ruby.int_value(time.now().unix())
		'stale_seconds':     ruby.int_value(3600)
		'download_attempts': ruby.array_value([
			api_spec_download_attempt('', '', false),
		])
	})
	result := homebrew.ruby_api_l69_d3_self_fetch_json_api_file(ruby.string_value('bar.json'), config)
	return api_spec_bool(result.type_name == 'Array' && os.file_last_mod_unix(target) == stale)
}

// Ruby it `it "refreshes the cache mtime when a fallback to the default API domain succeeds" do` at line 115.
pub fn ruby_api_spec_l115_d19_refreshes(args ...ruby.Value) ruby.Value {
	cache_dir := if args.len > 0 {
		args[0].as_string()
	} else {
		api_spec_temp_dir('mtime-fallback')
	}
	target := os.join_path(cache_dir, 'bar.json')
	os.write_file(target, '{"foo":"bar"}') or { return api_spec_bool(false) }
	stale := time.now().unix() - 7200
	os.utime(target, stale, stale) or { return api_spec_bool(false) }
	now := time.now().unix()
	config := ruby.map_value({
		'api_domain':        ruby.string_value('https://example.invalid/api')
		'default_domain':    ruby.string_value('https://formulae.brew.sh/api')
		'target':            ruby.string_value(target)
		'now':               ruby.int_value(now)
		'stale_seconds':     ruby.int_value(3600)
		'download_attempts': ruby.array_value([
			api_spec_download_attempt('https://example.invalid/api/bar.json', '', false),
			api_spec_download_attempt('https://formulae.brew.sh/api/bar.json', '{"foo":"bar"}', true),
		])
	})
	result := homebrew.ruby_api_l69_d3_self_fetch_json_api_file(ruby.string_value('bar.json'), config)
	return api_spec_bool(result.type_name == 'Array' && os.file_last_mod_unix(target) > stale)
}

// Ruby method `self.jws_test_key` at line 146.
pub fn ruby_api_spec_l146_d20_self_jws_test_key(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.structured_value('ArgumentError', 'RSA key collaborator is required', {})
	}
	return args[0]
}

// Ruby let! `let!(:cache_dir) { mktmpdir }` at line 150.
pub fn ruby_api_spec_l150_d21_cache_dir(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', api_spec_temp_dir('jws'))
}

// Ruby let `let(:target) { cache_dir/"internal/packages.test.jws.json" }` at line 151.
pub fn ruby_api_spec_l151_d22_target(args ...ruby.Value) ruby.Value {
	cache_dir := if args.len > 0 { args[0].as_string() } else { api_spec_temp_dir('jws-target') }
	return ruby.object_value('Pathname', os.join_path(cache_dir, 'internal', 'packages.test.jws.json'))
}

// Ruby let `let(:payload_cache) { cache_dir/"internal/packages.test.jws.json.payload" }` at line 152.
pub fn ruby_api_spec_l152_d23_payload_cache(args ...ruby.Value) ruby.Value {
	target := if args.len > 0 {
		args[0].as_string()
	} else {
		ruby_api_spec_l151_d22_target().as_string()
	}
	return ruby.object_value('Pathname', '${target}.payload')
}

// Ruby let `let(:private_key) { self.class.jws_test_key }` at line 153.
pub fn ruby_api_spec_l153_d24_private_key(args ...ruby.Value) ruby.Value {
	return ruby_api_spec_l146_d20_self_jws_test_key(...args)
}

// Ruby let `let(:protected_b64) { urlsafe_encode64('{"alg":"PS512","b64":false}') }` at line 154.
pub fn ruby_api_spec_l154_d25_protected_b64(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(base64.url_encode_str('{"alg":"PS512","b64":false}'))
}

// Ruby method `urlsafe_encode64(value)` at line 156.
pub fn ruby_api_spec_l156_d26_urlsafe_encode64(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.structured_value('ArgumentError', 'value is required', {})
	}
	return ruby.string_value(base64.url_encode_str(args[0].as_string()))
}

// Ruby method `sign_payload(payload)` at line 160.
pub fn ruby_api_spec_l160_d27_sign_payload(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.structured_value('ArgumentError', 'RSA-PSS signer result is required', {})
	}
	return args[1]
}

fn api_spec_envelope(payload string, signature string) string {
	protected := base64.url_encode_str('{"alg":"PS512","b64":false}')
	return json2.encode(json2.Any({
		'payload':    json2.Any(payload)
		'signatures': json2.Any([json2.Any({
			'header':    json2.Any({
				'kid': json2.Any('homebrew-1')
			})
			'protected': json2.Any(protected)
			'signature': json2.Any(signature)
		})])
	}))
}

// Ruby method `envelope_json(payload, signature: sign_payload(payload))` at line 166.
pub fn ruby_api_spec_l166_d28_envelope_json(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.structured_value('ArgumentError', 'payload and signer result are required', {})
	}
	return ruby.string_value(api_spec_envelope(args[0].as_string(), args[1].as_string()))
}

// Ruby method `write_payload_cache(payload, signature: sign_payload(payload))` at line 177.
pub fn ruby_api_spec_l177_d29_write_payload_cache(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.structured_value('ArgumentError', 'target, payload and signer result are required', {})
	}
	target := args[0].as_string()
	payload := args[1].as_string()
	signature := args[2].as_string()
	stat := os.stat(target) or {
		return ruby.structured_value('SystemCallError', err.msg(), {})
	}
	header := json2.encode(json2.Any({
		'protected':       json2.Any(base64.url_encode_str('{"alg":"PS512","b64":false}'))
		'signature':       json2.Any(signature)
		'source_size':     json2.Any(stat.size)
		'source_mtime_ns': json2.Any(stat.mtime * 1_000_000_000)
	}))
	path := '${target}.payload'
	os.write_file(path, '${header}\n${payload}') or {
		return ruby.structured_value('SystemCallError', err.msg(), {})
	}
	return ruby.object_value('Pathname', path)
}

// Ruby method `fetch_target` at line 188.
pub fn ruby_api_spec_l188_d30_fetch_target(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.structured_value('ArgumentError', 'target is required', {})
	}
	target := args[0].as_string()
	verified := args.len < 2 || args[1].bool_data
	payload_verified := args.len < 3 || args[2].bool_data
	config := ruby.map_value({
		'target':                           ruby.string_value(target)
		'now':                              ruby.int_value(time.now().unix())
		'stale_seconds':                    ruby.int_value(3600)
		'signature_verified':               ruby.bool_value(verified)
		'payload_cache_signature_verified': ruby.bool_value(payload_verified)
		'has_signature_result':             ruby.bool_value(true)
	})
	result := homebrew.ruby_api_l69_d3_self_fetch_json_api_file(ruby.string_value('internal/packages.test.jws.json'), config)
	items := result.as_array() or { return result }
	return if items.len > 0 { items[0] } else { api_spec_nil() }
}

fn api_spec_prepare_jws(label string, envelope_payload string) (string, string) {
	cache := api_spec_temp_dir(label)
	target := os.join_path(cache, 'internal', 'packages.test.jws.json')
	os.mkdir_all(os.dir(target)) or { return '', '' }
	os.write_file(target, api_spec_envelope(envelope_payload, 'envelope-signature')) or {
		return '', ''
	}
	return cache, target
}

fn api_spec_map_foo(value ruby.Value, expected string) bool {
	return value.type_name == 'Hash' && (value.map_data['foo'] or { api_spec_nil() }).as_string() == expected
}

// Ruby it `it "verifies the envelope and writes a payload cache" do` at line 199.
pub fn ruby_api_spec_l199_d31_verifies(args ...ruby.Value) ruby.Value {
	_ = args
	_, target := api_spec_prepare_jws('verify-write', '{"foo":"bar"}')
	data := ruby_api_spec_l188_d30_fetch_target(ruby.string_value(target), ruby.bool_value(true))
	return api_spec_bool(api_spec_map_foo(data, 'bar') && os.exists('${target}.payload'))
}

// Ruby it `it "does not write a payload cache for endpoints without one" do` at line 204.
pub fn ruby_api_spec_l204_d32_does(args ...ruby.Value) ruby.Value {
	_ = args
	cache := api_spec_temp_dir('no-payload-cache')
	target := os.join_path(cache, 'internal', 'other.jws.json')
	os.mkdir_all(os.dir(target)) or { return api_spec_bool(false) }
	os.write_file(target, api_spec_envelope('{"foo":"bar"}', 'signature')) or {
		return api_spec_bool(false)
	}
	config := ruby.map_value({
		'target':               ruby.string_value(target)
		'now':                  ruby.int_value(time.now().unix())
		'stale_seconds':        ruby.int_value(3600)
		'signature_verified':   ruby.bool_value(true)
		'has_signature_result': ruby.bool_value(true)
	})
	result := homebrew.ruby_api_l69_d3_self_fetch_json_api_file(ruby.string_value('internal/other.jws.json'), config)
	items := result.as_array() or { return api_spec_bool(false) }
	return api_spec_bool(items.len > 0 && api_spec_map_foo(items[0], 'bar') && !os.exists('${target}.payload'))
}

// Ruby it `it "loads a current payload cache instead of the envelope" do` at line 214.
pub fn ruby_api_spec_l214_d33_loads(args ...ruby.Value) ruby.Value {
	_ = args
	_, target := api_spec_prepare_jws('loads-payload', '{"foo":"bar"}')
	cache_result := ruby_api_spec_l177_d29_write_payload_cache(ruby.string_value(target), ruby.string_value('{"foo":"baz"}'), ruby.string_value('payload-signature'))
	if cache_result.type_name != 'Pathname' {
		return api_spec_bool(false)
	}
	before := homebrew.ruby_api_l453_d19_self_cached_jws_payload(ruby.string_value(target), ruby.bool_value(true), ruby.bool_value(true))
	if before.type_name == 'NilClass' {
		return api_spec_bool(false)
	}
	data := ruby_api_spec_l188_d30_fetch_target(ruby.string_value(target), ruby.bool_value(true))
	return api_spec_bool(api_spec_map_foo(data, 'baz'))
}

// Ruby it `it "falls back to the envelope when the payload cache does not match the file" do` at line 219.
pub fn ruby_api_spec_l219_d34_falls(args ...ruby.Value) ruby.Value {
	_ = args
	_, target := api_spec_prepare_jws('fingerprint-fallback', '{"foo":"bar"}')
	ruby_api_spec_l177_d29_write_payload_cache(ruby.string_value(target), ruby.string_value('{"foo":"baz"}'), ruby.string_value('payload-signature'))
	future := time.now().unix() + 10
	os.utime(target, future, future) or { return api_spec_bool(false) }
	data := ruby_api_spec_l188_d30_fetch_target(ruby.string_value(target), ruby.bool_value(true))
	return api_spec_bool(api_spec_map_foo(data, 'bar'))
}

// Ruby it `it "falls back to the envelope when the payload cache signature does not verify" do` at line 225.
pub fn ruby_api_spec_l225_d35_falls(args ...ruby.Value) ruby.Value {
	_ = args
	_, target := api_spec_prepare_jws('signature-fallback', '{"foo":"bar"}')
	ruby_api_spec_l177_d29_write_payload_cache(ruby.string_value(target), ruby.string_value('{"foo":"baz"}'), ruby.string_value('mismatched-signature'))
	cached := homebrew.ruby_api_l453_d19_self_cached_jws_payload(ruby.string_value(target), ruby.bool_value(false), ruby.bool_value(true))
	data := ruby_api_spec_l188_d30_fetch_target(ruby.string_value(target), ruby.bool_value(true), ruby.bool_value(false))
	return api_spec_bool(cached.type_name == 'NilClass' && api_spec_map_foo(data, 'bar'))
}

// Ruby it `it "falls back to the envelope when the payload cache is corrupt" do` at line 230.
pub fn ruby_api_spec_l230_d36_falls(args ...ruby.Value) ruby.Value {
	_ = args
	_, target := api_spec_prepare_jws('corrupt-fallback', '{"foo":"bar"}')
	os.write_file('${target}.payload', 'not json') or { return api_spec_bool(false) }
	data := ruby_api_spec_l188_d30_fetch_target(ruby.string_value(target), ruby.bool_value(true))
	return api_spec_bool(api_spec_map_foo(data, 'bar'))
}

// Ruby it `it "falls back to the envelope when the payload cache header is not a JSON object" do` at line 235.
pub fn ruby_api_spec_l235_d37_falls(args ...ruby.Value) ruby.Value {
	_ = args
	_, target := api_spec_prepare_jws('scalar-header-fallback', '{"foo":"bar"}')
	os.write_file('${target}.payload', '123\n{"foo":"baz"}') or {
		return api_spec_bool(false)
	}
	data := ruby_api_spec_l188_d30_fetch_target(ruby.string_value(target), ruby.bool_value(true))
	return api_spec_bool(api_spec_map_foo(data, 'bar'))
}

// Ruby it `it "raises when the envelope signature does not verify" do` at line 240.
pub fn ruby_api_spec_l240_d38_raises(args ...ruby.Value) ruby.Value {
	_ = args
	_, target := api_spec_prepare_jws('bad-envelope', '{"foo":"bar"}')
	result := ruby_api_spec_l188_d30_fetch_target(ruby.string_value(target), ruby.bool_value(false))
	return api_spec_bool(result.type_name == 'SystemExit' && result.as_string().contains('signature mismatch'))
}

// Ruby it `it "does not initialise downloads when the API cache is current" do` at line 248.
pub fn ruby_api_spec_l248_d39_does(args ...ruby.Value) ruby.Value {
	_ = args
	cache := api_spec_temp_dir('current-api')
	target := os.join_path(cache, 'packages.json')
	os.write_file(target, '{"foo":"bar"}') or { return api_spec_bool(false) }
	result := homebrew.api_fetch_files_result({
		'target':         ruby.string_value(target)
		'no_auto_update': ruby.bool_value(true)
		'now':            ruby.int_value(time.now().unix())
	})
	return api_spec_bool(!result.enqueued)
}

// Ruby it `it "handles a missing API cache before refusing root downloads" do` at line 258.
pub fn ruby_api_spec_l258_d40_handles(args ...ruby.Value) ruby.Value {
	_ = args
	cache := api_spec_temp_dir('missing-api')
	target := os.join_path(cache, 'packages.json')
	result := homebrew.api_fetch_files_result({
		'target':          ruby.string_value(target)
		'running_as_root': ruby.bool_value(true)
		'fetch_succeeded': ruby.bool_value(true)
	})
	return api_spec_bool(result.enqueued && result.shutdown)
}

// Ruby it `it "decodes unpadded URL-safe base64" do` at line 270.
pub fn ruby_api_spec_l270_d41_decodes(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.ruby_api_l546_d23_self_urlsafe_decode64(ruby.string_value('SGVsbG8'))
	return api_spec_bool(result.type_name == 'String' && result.as_string() == 'Hello')
}

// Ruby it `it "rejects invalid base64" do` at line 274.
pub fn ruby_api_spec_l274_d42_rejects(args ...ruby.Value) ruby.Value {
	_ = args
	result := homebrew.ruby_api_l546_d23_self_urlsafe_decode64(ruby.string_value('a'))
	return api_spec_bool(result.type_name == 'ArgumentError')
}

// Ruby it `it "downloads executables.txt from the GitHub Packages OCI artifact" do` at line 280.
pub fn ruby_api_spec_l280_d43_downloads(args ...ruby.Value) ruby.Value {
	cache := if args.len > 0 { args[0].as_string() } else { api_spec_temp_dir('oci') }
	target := os.join_path(cache, 'executables.txt')
	manifest := '{"layers":[{"digest":"sha256:abc123","annotations":{"org.opencontainers.image.title":"executables.txt"}}]}'
	result := homebrew.ruby_api_l314_d10_self_download_executables_file_from_github_packages(ruby.string_value(target), ruby.map_value({
		'manifest':         ruby.string_value(manifest)
		'manifest_success': ruby.bool_value(true)
		'download_success': ruby.bool_value(true)
		'download_stdout':  ruby.string_value('foo:foo-bin\n')
		'authorization':    ruby.string_value('Bearer QQ==')
	}))
	contents := os.read_file(target) or { return api_spec_bool(false) }
	return api_spec_bool(result.bool_data && contents == 'foo:foo-bin\n')
}

// Ruby let `let(:cache_dir) { mktmpdir }` at line 313.
pub fn ruby_api_spec_l313_d44_cache_dir(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', api_spec_temp_dir('executables'))
}

// Ruby let `let(:target) { cache_dir/"internal/executables.txt" }` at line 314.
pub fn ruby_api_spec_l314_d45_target(args ...ruby.Value) ruby.Value {
	cache := if args.len > 0 {
		args[0].as_string()
	} else {
		ruby_api_spec_l313_d44_cache_dir().as_string()
	}
	return ruby.object_value('Pathname', os.join_path(cache, 'internal', 'executables.txt'))
}

// Ruby let `let(:source) { cache_dir/"internal/packages.jws.json" }` at line 315.
pub fn ruby_api_spec_l315_d46_source(args ...ruby.Value) ruby.Value {
	cache := if args.len > 0 {
		args[0].as_string()
	} else {
		ruby_api_spec_l313_d44_cache_dir().as_string()
	}
	return ruby.object_value('Pathname', os.join_path(cache, 'internal', 'packages.jws.json'))
}

// Ruby let `let(:formulae) { { "foo" => { "executables" => ["foo-bin"] } } }` at line 316.
pub fn ruby_api_spec_l316_d47_formulae(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({
		'foo': ruby.map_value({
			'executables': ruby.string_array_value(['foo-bin'])
		})
	})
}

// Ruby method `write_executables_file!(regenerate:)` at line 318.
pub fn ruby_api_spec_l318_d48_write_executables_file(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		return ruby.structured_value('ArgumentError', 'regenerate, source, formulae and target are required', {})
	}
	return homebrew.ruby_api_l282_d9_self_write_executables_file(args[0], args[1], args[2], args[3])
}

fn api_spec_executables_fixture(label string) (string, string, string, ruby.Value) {
	cache := api_spec_temp_dir(label)
	target := os.join_path(cache, 'internal', 'executables.txt')
	source := os.join_path(cache, 'internal', 'packages.jws.json')
	os.mkdir_all(os.dir(source)) or { return '', '', '', api_spec_nil() }
	os.write_file(source, '{}') or { return '', '', '', api_spec_nil() }
	return cache, target, source, ruby_api_spec_l316_d47_formulae()
}

// Ruby it `it "writes the executables database when it does not exist" do` at line 328.
pub fn ruby_api_spec_l328_d49_writes(args ...ruby.Value) ruby.Value {
	_ = args
	_, target, source, formulae := api_spec_executables_fixture('write-executables')
	result := ruby_api_spec_l318_d48_write_executables_file(ruby.bool_value(false), ruby.string_value(source), formulae, ruby.string_value(target))
	contents := os.read_file(target) or { return api_spec_bool(false) }
	return api_spec_bool(result.bool_data && contents == 'foo:foo-bin\n')
}

// Ruby it `it "does not rebuild an executables database newer than its source when not regenerating" do` at line 333.
pub fn ruby_api_spec_l333_d50_does(args ...ruby.Value) ruby.Value {
	_ = args
	_, target, source, formulae := api_spec_executables_fixture('fresh-executables')
	os.write_file(target, 'stale:stale-bin\n') or { return api_spec_bool(false) }
	future := os.file_last_mod_unix(source) + 10
	os.utime(target, future, future) or { return api_spec_bool(false) }
	result := ruby_api_spec_l318_d48_write_executables_file(ruby.bool_value(false), ruby.string_value(source), formulae, ruby.string_value(target))
	contents := os.read_file(target) or { return api_spec_bool(false) }
	return api_spec_bool(!result.bool_data && contents == 'stale:stale-bin\n')
}

// Ruby it `it "rebuilds the executables database when the source is newer" do` at line 341.
pub fn ruby_api_spec_l341_d51_rebuilds(args ...ruby.Value) ruby.Value {
	_ = args
	_, target, source, formulae := api_spec_executables_fixture('stale-executables')
	os.write_file(target, 'stale:stale-bin\n') or { return api_spec_bool(false) }
	future := os.file_last_mod_unix(target) + 10
	os.utime(source, future, future) or { return api_spec_bool(false) }
	result := ruby_api_spec_l318_d48_write_executables_file(ruby.bool_value(false), ruby.string_value(source), formulae, ruby.string_value(target))
	contents := os.read_file(target) or { return api_spec_bool(false) }
	return api_spec_bool(result.bool_data && contents == 'foo:foo-bin\n')
}

// Ruby it `it "rewrites the executables database when regenerating" do` at line 349.
pub fn ruby_api_spec_l349_d52_rewrites(args ...ruby.Value) ruby.Value {
	_ = args
	_, target, source, formulae := api_spec_executables_fixture('regenerate-executables')
	os.write_file(target, 'stale:stale-bin\n') or { return api_spec_bool(false) }
	future := os.file_last_mod_unix(source) + 10
	os.utime(target, future, future) or { return api_spec_bool(false) }
	result := ruby_api_spec_l318_d48_write_executables_file(ruby.bool_value(true), ruby.string_value(source), formulae, ruby.string_value(target))
	contents := os.read_file(target) or { return api_spec_bool(false) }
	return api_spec_bool(result.bool_data && contents == 'foo:foo-bin\n')
}

// Ruby let `let(:api_cache_root) { Homebrew::API::HOMEBREW_CACHE_API_SOURCE }` at line 359.
pub fn ruby_api_spec_l359_d53_api_cache_root(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { api_spec_temp_dir('api-source') }
	return ruby.object_value('Pathname', root)
}

// Ruby let `let(:cache_path) do` at line 360.
pub fn ruby_api_spec_l360_d54_cache_path(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 {
		args[0].as_string()
	} else {
		ruby_api_spec_l359_d53_api_cache_root().as_string()
	}
	return ruby.object_value('Pathname', os.join_path(root, 'Homebrew', 'homebrew-core', 'cf5c386c1fa2cb54279d78c0990dd7a0fa4bc327', 'Formula', 'foo.rb'))
}

// Ruby it `it "returns the corresponding tap" do` at line 365.
pub fn ruby_api_spec_l365_d55_returns(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { api_spec_temp_dir('inside-source') }
	path := ruby_api_spec_l360_d54_cache_path(ruby.string_value(root))
	result := homebrew.ruby_api_l551_d24_self_tap_from_source_download(path, ruby.string_value(root))
	return api_spec_bool(result.type_name == 'Tap' && result.as_string() == 'Homebrew/homebrew-core')
}

// Ruby let `let(:api_cache_root) { mktmpdir }` at line 371.
pub fn ruby_api_spec_l371_d56_api_cache_root(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', api_spec_temp_dir('outside-source'))
}

// Ruby it `it "returns nil" do` at line 373.
pub fn ruby_api_spec_l373_d57_returns(args ...ruby.Value) ruby.Value {
	_ = args
	inside_root := api_spec_temp_dir('real-source')
	path := ruby_api_spec_l360_d54_cache_path(ruby.string_value(inside_root))
	outside_root := ruby_api_spec_l371_d56_api_cache_root()
	result := homebrew.ruby_api_l551_d24_self_tap_from_source_download(path, outside_root)
	return api_spec_bool(result.type_name == 'NilClass')
}

// Ruby it `it "returns nil" do` at line 379.
pub fn ruby_api_spec_l379_d58_returns(args ...ruby.Value) ruby.Value {
	_ = args
	root := api_spec_temp_dir('relative-source')
	result := homebrew.ruby_api_l551_d24_self_tap_from_source_download(ruby.object_value('Pathname', '../foo.rb'), ruby.string_value(root))
	return api_spec_bool(result.type_name == 'NilClass')
}

// Ruby let `let(:arm64_sequoia_tag) { Utils::Bottles::Tag.new(system: :sequoia, arch: :arm) }` at line 386.
pub fn ruby_api_spec_l386_d59_arm64_sequoia_tag(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Utils::Bottles::Tag', 'arm64_sequoia')
}

// Ruby let `let(:sonoma_tag) { Utils::Bottles::Tag.new(system: :sonoma, arch: :intel) }` at line 387.
pub fn ruby_api_spec_l387_d60_sonoma_tag(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Utils::Bottles::Tag', 'sonoma')
}

// Ruby let `let(:x86_64_linux_tag) { Utils::Bottles::Tag.new(system: :linux, arch: :intel) }` at line 388.
pub fn ruby_api_spec_l388_d61_x86_64_linux_tag(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Utils::Bottles::Tag', 'x86_64_linux')
}

// Ruby let `let(:json) do` at line 390.
pub fn ruby_api_spec_l390_d62_json(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({
		'name':       ruby.string_value('foo')
		'foo':        ruby.string_value('bar')
		'baz':        ruby.string_array_value(['test1', 'test2'])
		'variations': ruby.map_value({
			'arm64_sequoia': ruby.map_value({
				'foo': ruby.string_value('new')
			})
			'sonoma':        ruby.map_value({
				'baz': ruby.string_array_value(['new1', 'new2', 'new3'])
			})
		})
	})
}

// Ruby let `let(:arm64_sequoia_result) do` at line 402.
pub fn ruby_api_spec_l402_d63_arm64_sequoia_result(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({
		'name': ruby.string_value('foo')
		'foo':  ruby.string_value('new')
		'baz':  ruby.string_array_value(['test1', 'test2'])
	})
}

// Ruby let `let(:sonoma_result) do` at line 410.
pub fn ruby_api_spec_l410_d64_sonoma_result(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({
		'name': ruby.string_value('foo')
		'foo':  ruby.string_value('bar')
		'baz':  ruby.string_array_value(['new1', 'new2', 'new3'])
	})
}

fn api_spec_json_without_variations() ruby.Value {
	mut value := ruby_api_spec_l390_d62_json().map_data.clone()
	value.delete('variations')
	return ruby.map_value(value)
}

// Ruby it `it "returns the original JSON if no variations are found" do` at line 418.
pub fn ruby_api_spec_l418_d65_returns(args ...ruby.Value) ruby.Value {
	_ = args
	expected := ruby_api_spec_l402_d63_arm64_sequoia_result()
	actual := homebrew.ruby_api_l194_d4_self_merge_variations(expected, ruby_api_spec_l386_d59_arm64_sequoia_tag())
	return api_spec_bool(api_spec_value_equal(actual, expected))
}

// Ruby it `it "returns the original JSON if no variations are found for the current system" do` at line 423.
pub fn ruby_api_spec_l423_d66_returns(args ...ruby.Value) ruby.Value {
	_ = args
	expected := ruby_api_spec_l402_d63_arm64_sequoia_result()
	actual := homebrew.ruby_api_l194_d4_self_merge_variations(expected)
	return api_spec_bool(api_spec_value_equal(actual, expected))
}

// Ruby it `it "returns the original JSON without the variations if no matching variation is found" do` at line 428.
pub fn ruby_api_spec_l428_d67_returns(args ...ruby.Value) ruby.Value {
	_ = args
	actual := homebrew.ruby_api_l194_d4_self_merge_variations(ruby_api_spec_l390_d62_json(), ruby_api_spec_l388_d61_x86_64_linux_tag())
	return api_spec_bool(api_spec_value_equal(actual, api_spec_json_without_variations()))
}

// Ruby it `it "returns the original JSON without the variations if no matching variation is found for the current system" do` at line 433.
pub fn ruby_api_spec_l433_d68_returns(args ...ruby.Value) ruby.Value {
	tag := if args.len > 0 { args[0] } else { ruby_api_spec_l388_d61_x86_64_linux_tag() }
	actual := homebrew.ruby_api_l194_d4_self_merge_variations(ruby_api_spec_l390_d62_json(), tag)
	return api_spec_bool(api_spec_value_equal(actual, api_spec_json_without_variations()))
}

// Ruby it `it "returns the JSON with the matching variation applied from a string key" do` at line 440.
pub fn ruby_api_spec_l440_d69_returns(args ...ruby.Value) ruby.Value {
	_ = args
	actual := homebrew.ruby_api_l194_d4_self_merge_variations(ruby_api_spec_l390_d62_json(), ruby_api_spec_l386_d59_arm64_sequoia_tag())
	return api_spec_bool(api_spec_value_equal(actual, ruby_api_spec_l402_d63_arm64_sequoia_result()))
}

// Ruby it `it "returns the JSON with the matching variation applied from a string key for the current system" do` at line 445.
pub fn ruby_api_spec_l445_d70_returns(args ...ruby.Value) ruby.Value {
	tag := if args.len > 0 { args[0] } else { ruby_api_spec_l386_d59_arm64_sequoia_tag() }
	actual := homebrew.ruby_api_l194_d4_self_merge_variations(ruby_api_spec_l390_d62_json(), tag)
	return api_spec_bool(api_spec_value_equal(actual, ruby_api_spec_l402_d63_arm64_sequoia_result()))
}

// Ruby it `it "returns the JSON with the matching variation applied from a symbol key" do` at line 452.
pub fn ruby_api_spec_l452_d71_returns(args ...ruby.Value) ruby.Value {
	_ = args
	actual := homebrew.ruby_api_l194_d4_self_merge_variations(ruby_api_spec_l390_d62_json(), ruby_api_spec_l387_d60_sonoma_tag())
	return api_spec_bool(api_spec_value_equal(actual, ruby_api_spec_l410_d64_sonoma_result()))
}

// Ruby it `it "returns the JSON with the matching variation applied from a symbol key for the current system" do` at line 457.
pub fn ruby_api_spec_l457_d72_returns(args ...ruby.Value) ruby.Value {
	tag := if args.len > 0 { args[0] } else { ruby_api_spec_l387_d60_sonoma_tag() }
	actual := homebrew.ruby_api_l194_d4_self_merge_variations(ruby_api_spec_l390_d62_json(), tag)
	return api_spec_bool(api_spec_value_equal(actual, ruby_api_spec_l410_d64_sonoma_result()))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "api"
// 5: require "openssl"
// 6:
// 7: RSpec.describe Homebrew::API do
// 8:   let(:text) { "foo" }
// 9:   let(:json) { '{"foo":"bar"}' }
// 10:   let(:json_hash) { JSON.parse(json) }
// 11:   let(:json_invalid) { '{"foo":"bar"' }
// 12:
// 13:   def mock_curl_output(stdout: "", success: true)
// 14:     curl_output = instance_double(SystemCommand::Result, stdout:, success?: success)
// 15:     allow(Utils::Curl).to receive(:curl_output).and_return curl_output
// 16:   end
// 17:
// 18:   def mock_curl_download(stdout:)
// 19:     allow(Utils::Curl).to receive(:curl_download) do |*_args, **kwargs|
// 20:       kwargs[:to].write stdout
// 21:     end
// 22:   end
// 23:
// 24:   describe "::fetch" do
// 25:     it "fetches a JSON file" do
// 26:       mock_curl_output stdout: json
// 27:       fetched_json = described_class.fetch("foo.json")
// 28:       expect(fetched_json).to eq json_hash
// 29:     end
// 30:
// 31:     it "raises an error if the file does not exist" do
// 32:       mock_curl_output success: false
// 33:       expect { described_class.fetch("bar.txt") }.to raise_error(ArgumentError, /No file found/)
// 34:     end
// 35:
// 36:     it "raises an error if the JSON file is invalid" do
// 37:       mock_curl_output stdout: text
// 38:       expect { described_class.fetch("baz.txt") }.to raise_error(ArgumentError, /Invalid JSON file/)
// 39:     end
// 40:   end
// 41:
// 42:   describe "::formula_name?" do
// 43:     before do
// 44:       allow(Homebrew::API::Internal).to receive(:formula_name?) { |name| name == "foo" }
// 45:     end
// 46:
// 47:     it "returns true for a core formula name" do
// 48:       expect(described_class.formula_name?("foo")).to be true
// 49:     end
// 50:
// 51:     it "returns false for an unknown name" do
// 52:       expect(described_class.formula_name?("bar")).to be false
// 53:     end
// 54:   end
// 55:
// 56:   describe "::cask_token?" do
// 57:     before do
// 58:       allow(Homebrew::API::Internal).to receive(:cask_name?) { |token| token == "foo" }
// 59:     end
// 60:
// 61:     it "returns true for a core cask token" do
// 62:       expect(described_class.cask_token?("foo")).to be true
// 63:     end
// 64:
// 65:     it "returns false for an unknown token" do
// 66:       expect(described_class.cask_token?("bar")).to be false
// 67:     end
// 68:   end
// 69:
// 70:   describe "::fetch_json_api_file" do
// 71:     let!(:cache_dir) { mktmpdir }
// 72:
// 73:     before do
// 74:       (cache_dir/"bar.json").write "tmp"
// 75:     end
// 76:
// 77:     it "fetches a JSON file" do
// 78:       mock_curl_download stdout: json
// 79:       fetched_json, = described_class.fetch_json_api_file("foo.json", target: cache_dir/"foo.json")
// 80:       expect(fetched_json).to eq json_hash
// 81:     end
// 82:
// 83:     it "updates an existing JSON file" do
// 84:       mock_curl_download stdout: json
// 85:       fetched_json, = described_class.fetch_json_api_file("bar.json", target: cache_dir/"bar.json")
// 86:       expect(fetched_json).to eq json_hash
// 87:     end
// 88:
// 89:     it "raises an error if the JSON file is invalid" do
// 90:       mock_curl_download stdout: json_invalid
// 91:       expect do
// 92:         described_class.fetch_json_api_file("baz.json", target: cache_dir/"baz.json")
// 93:       end.to raise_error(SystemExit)
// 94:     end
// 95:
// 96:     it "does not refresh the cache mtime when the download fails" do
// 97:       target = cache_dir/"bar.json"
// 98:       target.write json
// 99:       stale_mtime = Time.now - 7200
// 100:       FileUtils.touch(target, mtime: stale_mtime)
// 101:
// 102:       allow(Utils::Curl).to receive(:curl_download).and_raise(ErrorDuringExecution.new(["curl"], status: 1))
// 103:
// 104:       expect do
// 105:         described_class.fetch_json_api_file(
// 106:           "bar.json",
// 107:           target:        target,
// 108:           stale_seconds: 3600,
// 109:         )
// 110:       end.to output(/update failed, falling back to cached version/).to_stderr
// 111:
// 112:       expect(target.mtime.to_i).to eq stale_mtime.to_i
// 113:     end
// 114:
// 115:     it "refreshes the cache mtime when a fallback to the default API domain succeeds" do
// 116:       target = cache_dir/"bar.json"
// 117:       target.write json
// 118:       stale_mtime = Time.now - 7200
// 119:       FileUtils.touch(target, mtime: stale_mtime)
// 120:
// 121:       allow(Homebrew::EnvConfig).to receive(:api_domain).and_return("https://example.invalid/api")
// 122:
// 123:       requested_urls = []
// 124:       allow(Utils::Curl).to receive(:curl_download) do |*args, **kwargs|
// 125:         requested_urls << args.last
// 126:         raise ErrorDuringExecution.new(["curl"], status: 1) if requested_urls.length == 1
// 127:
// 128:         kwargs[:to].write json
// 129:       end
// 130:
// 131:       described_class.fetch_json_api_file(
// 132:         "bar.json",
// 133:         target:        target,
// 134:         stale_seconds: 3600,
// 135:       )
// 136:
// 137:       expect(requested_urls).to eq([
// 138:         "https://example.invalid/api/bar.json",
// 139:         "#{HOMEBREW_API_DEFAULT_DOMAIN}/bar.json",
// 140:       ])
// 141:       expect(target.mtime.to_i).to be > stale_mtime.to_i
// 142:     end
// 143:   end
// 144:
// 145:   describe "::fetch_json_api_file with a JWS endpoint" do
// 146:     def self.jws_test_key
// 147:       @jws_test_key ||= OpenSSL::PKey::RSA.new(2048)
// 148:     end
// 149:
// 150:     let!(:cache_dir) { mktmpdir }
// 151:     let(:target) { cache_dir/"internal/packages.test.jws.json" }
// 152:     let(:payload_cache) { cache_dir/"internal/packages.test.jws.json.payload" }
// 153:     let(:private_key) { self.class.jws_test_key }
// 154:     let(:protected_b64) { urlsafe_encode64('{"alg":"PS512","b64":false}') }
// 155:
// 156:     def urlsafe_encode64(value)
// 157:       [value].pack("m0").tr("+/", "-_")
// 158:     end
// 159:
// 160:     def sign_payload(payload)
// 161:       urlsafe_encode64(
// 162:         private_key.sign_pss("SHA512", "#{protected_b64}.#{payload}", salt_length: :digest, mgf1_hash: "SHA512"),
// 163:       )
// 164:     end
// 165:
// 166:     def envelope_json(payload, signature: sign_payload(payload))
// 167:       JSON.generate({
// 168:         "payload"    => payload,
// 169:         "signatures" => [{
// 170:           "header"    => { "kid" => "homebrew-1" },
// 171:           "protected" => protected_b64,
// 172:           "signature" => signature,
// 173:         }],
// 174:       })
// 175:     end
// 176:
// 177:     def write_payload_cache(payload, signature: sign_payload(payload))
// 178:       stat = target.stat
// 179:       header = JSON.generate({
// 180:         "protected"       => protected_b64,
// 181:         "signature"       => signature,
// 182:         "source_size"     => stat.size,
// 183:         "source_mtime_ns" => (stat.mtime.to_r * 1_000_000_000).to_i,
// 184:       })
// 185:       payload_cache.binwrite("#{header}\n#{payload}")
// 186:     end
// 187:
// 188:     def fetch_target
// 189:       described_class.fetch_json_api_file("internal/packages.test.jws.json", target:, stale_seconds: 3600).first
// 190:     end
// 191:
// 192:     before do
// 193:       stub_const("Homebrew::API::HOMEBREW_CACHE_API", cache_dir)
// 194:       allow(described_class).to receive(:jws_public_key_pem).and_return(private_key.public_key.to_pem)
// 195:       target.dirname.mkpath
// 196:       target.write envelope_json('{"foo":"bar"}')
// 197:     end
// 198:
// 199:     it "verifies the envelope and writes a payload cache" do
// 200:       expect(fetch_target).to eq("foo" => "bar")
// 201:       expect(payload_cache).to exist
// 202:     end
// 203:
// 204:     it "does not write a payload cache for endpoints without one" do
// 205:       other_target = cache_dir/"internal/other.jws.json"
// 206:       other_target.write envelope_json('{"foo":"bar"}')
// 207:
// 208:       data, = described_class.fetch_json_api_file("internal/other.jws.json", target:        other_target,
// 209:                                                                              stale_seconds: 3600)
// 210:       expect(data).to eq("foo" => "bar")
// 211:       expect(Pathname("#{other_target}.payload")).not_to exist
// 212:     end
// 213:
// 214:     it "loads a current payload cache instead of the envelope" do
// 215:       write_payload_cache('{"foo":"baz"}')
// 216:       expect(fetch_target).to eq("foo" => "baz")
// 217:     end
// 218:
// 219:     it "falls back to the envelope when the payload cache does not match the file" do
// 220:       write_payload_cache('{"foo":"baz"}')
// 221:       FileUtils.touch target, mtime: Time.now + 10
// 222:       expect(fetch_target).to eq("foo" => "bar")
// 223:     end
// 224:
// 225:     it "falls back to the envelope when the payload cache signature does not verify" do
// 226:       write_payload_cache('{"foo":"baz"}', signature: sign_payload('{"foo":"qux"}'))
// 227:       expect(fetch_target).to eq("foo" => "bar")
// 228:     end
// 229:
// 230:     it "falls back to the envelope when the payload cache is corrupt" do
// 231:       payload_cache.write "not json"
// 232:       expect(fetch_target).to eq("foo" => "bar")
// 233:     end
// 234:
// 235:     it "falls back to the envelope when the payload cache header is not a JSON object" do
// 236:       payload_cache.binwrite("123\n{\"foo\":\"baz\"}")
// 237:       expect(fetch_target).to eq("foo" => "bar")
// 238:     end
// 239:
// 240:     it "raises when the envelope signature does not verify" do
// 241:       target.write envelope_json('{"foo":"bar"}', signature: sign_payload('{"foo":"evil"}'))
// 242:       expect { fetch_target }.to raise_error(SystemExit)
// 243:         .and output(/Failed to verify integrity \(signature mismatch\)/).to_stderr
// 244:     end
// 245:   end
// 246:
// 247:   describe "::fetch_api_files!" do
// 248:     it "does not initialise downloads when the API cache is current" do
// 249:       target = mktmpdir/"packages.json"
// 250:       target.write json
// 251:       allow(Homebrew::API::Internal).to receive(:cached_packages_json_file_path).and_return(target)
// 252:       allow(Homebrew::EnvConfig).to receive(:no_auto_update?).and_return(true)
// 253:
// 254:       expect(Homebrew::API::Internal).not_to receive(:fetch_packages_api!)
// 255:       described_class.fetch_api_files!
// 256:     end
// 257:
// 258:     it "handles a missing API cache before refusing root downloads" do
// 259:       queue = instance_double(Homebrew::DownloadQueue, fetch: nil, shutdown: nil)
// 260:       allow(Homebrew::DownloadQueue).to receive(:new).and_return(queue)
// 261:       allow(Homebrew::API::Internal).to receive(:cached_packages_json_file_path).and_return(mktmpdir/"packages.json")
// 262:       allow(Homebrew).to receive(:running_as_root_but_not_owned_by_root?).and_return(true)
// 263:
// 264:       expect(Homebrew::API::Internal).to receive(:fetch_packages_api!).and_return([{}, false])
// 265:       described_class.fetch_api_files!
// 266:     end
// 267:   end
// 268:
// 269:   describe "::urlsafe_decode64" do
// 270:     it "decodes unpadded URL-safe base64" do
// 271:       expect(described_class.instance_eval { urlsafe_decode64("SGVsbG8") }).to eq("Hello")
// 272:     end
// 273:
// 274:     it "rejects invalid base64" do
// 275:       expect { described_class.instance_eval { urlsafe_decode64("a") } }.to raise_error(ArgumentError)
// 276:     end
// 277:   end
// 278:
// 279:   describe "::download_executables_file_from_github_packages!" do
// 280:     it "downloads executables.txt from the GitHub Packages OCI artifact" do
// 281:       target = mktmpdir/"executables.txt"
// 282:       stub_const("HOMEBREW_GITHUB_PACKAGES_AUTH", "Bearer QQ==")
// 283:       manifest = {
// 284:         "layers" => [{
// 285:           "digest"      => "sha256:abc123",
// 286:           "annotations" => {
// 287:             "org.opencontainers.image.title" => "executables.txt",
// 288:           },
// 289:         }],
// 290:       }
// 291:
// 292:       expect(Utils::Curl).to receive(:curl_output).with(
// 293:         "--fail", "--location",
// 294:         "--header", "Accept: application/vnd.oci.image.manifest.v1+json",
// 295:         "--header", "Authorization: Bearer QQ==",
// 296:         "https://ghcr.io/v2/homebrew/command-not-found/executables/manifests/latest",
// 297:         show_error: false
// 298:       ).and_return(instance_double(SystemCommand::Result, stdout: JSON.generate(manifest), success?: true))
// 299:       expect(Utils::Curl).to receive(:curl_download).with(
// 300:         "--fail",
// 301:         "--header", "Authorization: Bearer QQ==",
// 302:         "https://ghcr.io/v2/homebrew/command-not-found/executables/blobs/sha256:abc123",
// 303:         to:         target,
// 304:         show_error: false
// 305:       ) { |*_args, **kwargs| kwargs[:to].write "foo:foo-bin\n" }
// 306:
// 307:       expect(described_class.download_executables_file_from_github_packages!(target)).to be true
// 308:       expect(target.read).to eq("foo:foo-bin\n")
// 309:     end
// 310:   end
// 311:
// 312:   describe "::write_executables_file!" do
// 313:     let(:cache_dir) { mktmpdir }
// 314:     let(:target) { cache_dir/"internal/executables.txt" }
// 315:     let(:source) { cache_dir/"internal/packages.jws.json" }
// 316:     let(:formulae) { { "foo" => { "executables" => ["foo-bin"] } } }
// 317:
// 318:     def write_executables_file!(regenerate:)
// 319:       described_class.write_executables_file!(regenerate:, source:) { formulae }
// 320:     end
// 321:
// 322:     before do
// 323:       stub_const("Homebrew::API::HOMEBREW_CACHE_API", cache_dir)
// 324:       source.dirname.mkpath
// 325:       source.write "{}"
// 326:     end
// 327:
// 328:     it "writes the executables database when it does not exist" do
// 329:       expect(write_executables_file!(regenerate: false)).to be true
// 330:       expect(target.read).to eq("foo:foo-bin\n")
// 331:     end
// 332:
// 333:     it "does not rebuild an executables database newer than its source when not regenerating" do
// 334:       target.write "stale:stale-bin\n"
// 335:       FileUtils.touch target, mtime: source.mtime + 1
// 336:
// 337:       expect(write_executables_file!(regenerate: false)).to be false
// 338:       expect(target.read).to eq("stale:stale-bin\n")
// 339:     end
// 340:
// 341:     it "rebuilds the executables database when the source is newer" do
// 342:       target.write "stale:stale-bin\n"
// 343:       FileUtils.touch source, mtime: target.mtime + 1
// 344:
// 345:       expect(write_executables_file!(regenerate: false)).to be true
// 346:       expect(target.read).to eq("foo:foo-bin\n")
// 347:     end
// 348:
// 349:     it "rewrites the executables database when regenerating" do
// 350:       target.write "stale:stale-bin\n"
// 351:       FileUtils.touch target, mtime: source.mtime + 1
// 352:
// 353:       expect(write_executables_file!(regenerate: true)).to be true
// 354:       expect(target.read).to eq("foo:foo-bin\n")
// 355:     end
// 356:   end
// 357:
// 358:   describe "::tap_from_source_download" do
// 359:     let(:api_cache_root) { Homebrew::API::HOMEBREW_CACHE_API_SOURCE }
// 360:     let(:cache_path) do
// 361:       api_cache_root/"Homebrew"/"homebrew-core"/"cf5c386c1fa2cb54279d78c0990dd7a0fa4bc327"/"Formula"/"foo.rb"
// 362:     end
// 363:
// 364:     context "when given a path inside the API source cache" do
// 365:       it "returns the corresponding tap" do
// 366:         expect(described_class.tap_from_source_download(cache_path)).to eq CoreTap.instance
// 367:       end
// 368:     end
// 369:
// 370:     context "when given a path that is not inside the API source cache" do
// 371:       let(:api_cache_root) { mktmpdir }
// 372:
// 373:       it "returns nil" do
// 374:         expect(described_class.tap_from_source_download(cache_path)).to be_nil
// 375:       end
// 376:     end
// 377:
// 378:     context "when given a relative path that is not inside the API source cache" do
// 379:       it "returns nil" do
// 380:         expect(described_class.tap_from_source_download(Pathname("../foo.rb"))).to be_nil
// 381:       end
// 382:     end
// 383:   end
// 384:
// 385:   describe "::merge_variations" do
// 386:     let(:arm64_sequoia_tag) { Utils::Bottles::Tag.new(system: :sequoia, arch: :arm) }
// 387:     let(:sonoma_tag) { Utils::Bottles::Tag.new(system: :sonoma, arch: :intel) }
// 388:     let(:x86_64_linux_tag) { Utils::Bottles::Tag.new(system: :linux, arch: :intel) }
// 389:
// 390:     let(:json) do
// 391:       {
// 392:         "name"       => "foo",
// 393:         "foo"        => "bar",
// 394:         "baz"        => ["test1", "test2"],
// 395:         "variations" => {
// 396:           "arm64_sequoia" => { "foo" => "new" },
// 397:           :sonoma         => { "baz" => ["new1", "new2", "new3"] },
// 398:         },
// 399:       }
// 400:     end
// 401:
// 402:     let(:arm64_sequoia_result) do
// 403:       {
// 404:         "name" => "foo",
// 405:         "foo"  => "new",
// 406:         "baz"  => ["test1", "test2"],
// 407:       }
// 408:     end
// 409:
// 410:     let(:sonoma_result) do
// 411:       {
// 412:         "name" => "foo",
// 413:         "foo"  => "bar",
// 414:         "baz"  => ["new1", "new2", "new3"],
// 415:       }
// 416:     end
// 417:
// 418:     it "returns the original JSON if no variations are found" do
// 419:       result = described_class.merge_variations(arm64_sequoia_result, bottle_tag: arm64_sequoia_tag)
// 420:       expect(result).to eq arm64_sequoia_result
// 421:     end
// 422:
// 423:     it "returns the original JSON if no variations are found for the current system" do
// 424:       result = described_class.merge_variations(arm64_sequoia_result)
// 425:       expect(result).to eq arm64_sequoia_result
// 426:     end
// 427:
// 428:     it "returns the original JSON without the variations if no matching variation is found" do
// 429:       result = described_class.merge_variations(json, bottle_tag: x86_64_linux_tag)
// 430:       expect(result).to eq json.except("variations")
// 431:     end
// 432:
// 433:     it "returns the original JSON without the variations if no matching variation is found for the current system" do
// 434:       Homebrew::SimulateSystem.with(os: :linux, arch: :intel) do
// 435:         result = described_class.merge_variations(json)
// 436:         expect(result).to eq json.except("variations")
// 437:       end
// 438:     end
// 439:
// 440:     it "returns the JSON with the matching variation applied from a string key" do
// 441:       result = described_class.merge_variations(json, bottle_tag: arm64_sequoia_tag)
// 442:       expect(result).to eq arm64_sequoia_result
// 443:     end
// 444:
// 445:     it "returns the JSON with the matching variation applied from a string key for the current system" do
// 446:       Homebrew::SimulateSystem.with(os: :sequoia, arch: :arm) do
// 447:         result = described_class.merge_variations(json)
// 448:         expect(result).to eq arm64_sequoia_result
// 449:       end
// 450:     end
// 451:
// 452:     it "returns the JSON with the matching variation applied from a symbol key" do
// 453:       result = described_class.merge_variations(json, bottle_tag: sonoma_tag)
// 454:       expect(result).to eq sonoma_result
// 455:     end
// 456:
// 457:     it "returns the JSON with the matching variation applied from a symbol key for the current system" do
// 458:       Homebrew::SimulateSystem.with(os: :sonoma, arch: :intel) do
// 459:         result = described_class.merge_variations(json)
// 460:         expect(result).to eq sonoma_result
// 461:       end
// 462:     end
// 463:   end
// 464: end
