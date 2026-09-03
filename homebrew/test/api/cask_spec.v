module api

import brew_runtime
import homebrew.api as cask_api
import os
import time

// Translated from Homebrew/brew `test/api/cask_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn cask_spec_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn cask_spec_error_value(message string) brew_runtime.Value {
	return brew_runtime.structured_value('RuntimeError', message, {
		'message': message
	})
}

pub fn cask_spec_cache_dir() !string {
	path := os.join_path(os.temp_dir(), 'brew-v-api-cask-spec-${os.getpid()}-${time.now().unix_micro()}')
	os.mkdir_all(path)!
	return path
}

pub fn cask_spec_casks_json() string {
	return '[{\n  "token": "foo",\n  "url": "https://brew.sh/foo"\n}, {\n  "token": "bar",\n  "url": "https://brew.sh/bar"\n}]\n'
}

pub fn cask_spec_casks_hash() map[string]map[string]brew_runtime.Value {
	return {
		'foo': {
			'url': brew_runtime.string_value('https://brew.sh/foo')
		}
		'bar': {
			'url': brew_runtime.string_value('https://brew.sh/bar')
		}
	}
}

pub fn cask_spec_mock_curl_download(stdout string, mut state cask_api.CaskApiState) ! {
	state.fetch_results['cask.jws.json'] = cask_api.CaskApiFetchResult{
		data: brew_runtime.parse_json_value(stdout)!
		updated: true
	}
}

pub fn cask_spec_cask() cask_api.CaskSource {
	return cask_api.CaskSource{
		token: 'everything'
		ruby_source_path: 'Casks/everything.rb'
		ruby_source_checksum: '00ae1ae330365f3d6e4387776f67a9c4b096da3d4546bd0827b5dcafa985234e'
		tap_git_head: 'abcdef1234567890abcdef1234567890abcdef12'
		tap_full_name: 'Homebrew/homebrew-cask'
		config: brew_runtime.object_value('NilClass', 'nil')
	}
}

fn cask_spec_value_equal(left brew_runtime.Value, right brew_runtime.Value) bool {
	if left.type_name != right.type_name {
		return false
	}
	if left.type_name == 'Hash' {
		if left.map_data.len != right.map_data.len {
			return false
		}
		for key, value in left.map_data {
			other := right.map_data[key] or { return false }
			if !cask_spec_value_equal(value, other) {
				return false
			}
		}
		return true
	}
	if left.type_name == 'Array' {
		left_values := left.as_array() or { return false }
		right_values := right.as_array() or { return false }
		if left_values.len != right_values.len {
			return false
		}
		for index, value in left_values {
			if !cask_spec_value_equal(value, right_values[index]) {
				return false
			}
		}
		return true
	}
	return left.repr == right.repr && left.bool_data == right.bool_data && left.int_data == right.int_data
}

fn cask_spec_maps_equal(left map[string]map[string]brew_runtime.Value,
	right map[string]map[string]brew_runtime.Value) bool {
	if left.len != right.len {
		return false
	}
	for key, values in left {
		other := (right[key] or { return false }).clone()
		if !cask_spec_value_equal(brew_runtime.map_value(values), brew_runtime.map_value(other)) {
			return false
		}
	}
	return true
}

pub fn cask_spec_returns_expected_list() bool {
	cache_dir := cask_spec_cache_dir() or { return false }
	defer {
		os.rmdir_all(cache_dir) or {}
	}
	mut state := cask_api.new_cask_api_state(cache_dir, os.join_path(cache_dir, 'api-source'))
	cask_spec_mock_curl_download(cask_spec_casks_json(), mut state) or { return false }
	actual := cask_api.cask_all_casks(mut state) or { return false }
	return cask_spec_maps_equal(actual, cask_spec_casks_hash())
}

pub fn cask_spec_source_download_is_correct() bool {
	mut state := cask_api.new_cask_api_state('/tmp/homebrew-api-cask', '/tmp/homebrew-api-cask-source')
	download := cask_api.cask_source_download(mut state, cask_spec_cask(), false)
	return download.url == 'https://raw.githubusercontent.com/Homebrew/homebrew-cask/abcdef1234567890abcdef1234567890abcdef12/Casks/everything.rb' && (download.checksum or { '' }) == '00ae1ae330365f3d6e4387776f67a9c4b096da3d4546bd0827b5dcafa985234e'
}

// Ruby let `let(:cache_dir) { mktmpdir }` at line 7.
pub fn ruby_cask_spec_l7_d1_cache_dir(args ...brew_runtime.Value) brew_runtime.Value {
	path := cask_spec_cache_dir() or { return cask_spec_error_value(err.msg()) }
	return brew_runtime.object_value('Pathname', path)
}

// Ruby method `mock_curl_download(stdout:)` at line 13.
pub fn ruby_cask_spec_l13_d2_mock_curl_download(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return cask_spec_error_value('mock_curl_download requires Cask API state and stdout')
	}
	if 'cask_api_state_address' !in args[0].attributes {
		return cask_spec_error_value('mock_curl_download requires translated Cask API state')
	}
	mut state := unsafe {
		&cask_api.CaskApiState(voidptr(args[0].attributes['cask_api_state_address'].u64()))
	}
	cask_spec_mock_curl_download(args[1].as_string(), mut state) or {
		return cask_spec_error_value(err.msg())
	}
	return cask_spec_nil_value()
}

// Ruby let `let(:casks_json) do` at line 23.
pub fn ruby_cask_spec_l23_d3_casks_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(cask_spec_casks_json())
}

// Ruby let `let(:casks_hash) do` at line 34.
pub fn ruby_cask_spec_l34_d4_casks_hash(args ...brew_runtime.Value) brew_runtime.Value {
	mut values := map[string]brew_runtime.Value{}
	for token, cask in cask_spec_casks_hash() {
		values[token] = brew_runtime.map_value(cask)
	}
	return brew_runtime.map_value(values)
}

// Ruby it `it "returns the expected cask JSON list" do` at line 41.
pub fn ruby_cask_spec_l41_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(cask_spec_returns_expected_list())
}

// Ruby let `let(:cask) do` at line 49.
pub fn ruby_cask_spec_l49_d6_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_api.cask_source_boundary(cask_spec_cask())
}

// Ruby it `it "specifies the correct URL and sha256" do` at line 75.
pub fn ruby_cask_spec_l75_d7_specifies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(cask_spec_source_download_is_correct())
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "api"
// 5:
// 6: RSpec.describe Homebrew::API::Cask do
// 7:   let(:cache_dir) { mktmpdir }
// 8:
// 9:   before do
// 10:     stub_const("Homebrew::API::HOMEBREW_CACHE_API", cache_dir)
// 11:   end
// 12:
// 13:   def mock_curl_download(stdout:)
// 14:     allow(Utils::Curl).to receive(:curl_download) do |*_args, **kwargs|
// 15:       kwargs[:to].write stdout
// 16:     end
// 17:     allow(Homebrew::API).to receive(:verify_and_parse_jws) do |json_data|
// 18:       [true, json_data]
// 19:     end
// 20:   end
// 21:
// 22:   describe "::all_casks" do
// 23:     let(:casks_json) do
// 24:       <<~EOS
// 25:         [{
// 26:           "token": "foo",
// 27:           "url": "https://brew.sh/foo"
// 28:         }, {
// 29:           "token": "bar",
// 30:           "url": "https://brew.sh/bar"
// 31:         }]
// 32:       EOS
// 33:     end
// 34:     let(:casks_hash) do
// 35:       {
// 36:         "foo" => { "url" => "https://brew.sh/foo" },
// 37:         "bar" => { "url" => "https://brew.sh/bar" },
// 38:       }
// 39:     end
// 40:
// 41:     it "returns the expected cask JSON list" do
// 42:       mock_curl_download stdout: casks_json
// 43:       casks_output = described_class.all_casks
// 44:       expect(casks_output).to eq casks_hash
// 45:     end
// 46:   end
// 47:
// 48:   describe "::source_download", :needs_macos do
// 49:     let(:cask) do
// 50:       cask = Cask::CaskLoader::FromAPILoader.new(
// 51:         "everything",
// 52:         from_json: JSON.parse((TEST_FIXTURE_DIR/"cask/everything.json").read.strip),
// 53:       ).load(config: nil)
// 54:       cask
// 55:     end
// 56:
// 57:     before do
// 58:       allow(Homebrew::API).to receive(:fetch_json_api_file).and_return([{
// 59:         "formulae"               => {},
// 60:         "casks"                  => {},
// 61:         "formula_aliases"        => {},
// 62:         "formula_renames"        => {},
// 63:         "cask_renames"           => {},
// 64:         "formula_tap_git_head"   => "",
// 65:         "cask_tap_git_head"      => "",
// 66:         "formula_tap_migrations" => {},
// 67:         "cask_tap_migrations"    => {},
// 68:       }, true])
// 69:       allow_any_instance_of(Homebrew::API::SourceDownload).to receive(:fetch)
// 70:       allow_any_instance_of(Homebrew::API::SourceDownload).to receive(:symlink_location).and_return(
// 71:         TEST_FIXTURE_DIR/"cask/Casks/everything.rb",
// 72:       )
// 73:     end
// 74:
// 75:     it "specifies the correct URL and sha256" do
// 76:       expect(Homebrew::API::SourceDownload).to receive(:new).with(
// 77:         "https://raw.githubusercontent.com/Homebrew/homebrew-cask/abcdef1234567890abcdef1234567890abcdef12/Casks/everything.rb",
// 78:         Checksum.new("00ae1ae330365f3d6e4387776f67a9c4b096da3d4546bd0827b5dcafa985234e"),
// 79:         any_args,
// 80:       ).and_call_original
// 81:       described_class.source_download(cask)
// 82:     end
// 83:   end
// 84: end
