module api

import brew_runtime

// Translated from Homebrew/brew `test/api/cask_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cache_dir) { mktmpdir }` at line 7.
pub fn ruby_cask_spec_l7_d1_cache_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cache_dir', ...args)
}

// Ruby method `mock_curl_download(stdout:)` at line 13.
pub fn ruby_cask_spec_l13_d2_mock_curl_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mock_curl_download', ...args)
}

// Ruby let `let(:casks_json) do` at line 23.
pub fn ruby_cask_spec_l23_d3_casks_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('casks_json', ...args)
}

// Ruby let `let(:casks_hash) do` at line 34.
pub fn ruby_cask_spec_l34_d4_casks_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('casks_hash', ...args)
}

// Ruby it `it "returns the expected cask JSON list" do` at line 41.
pub fn ruby_cask_spec_l41_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:cask) do` at line 49.
pub fn ruby_cask_spec_l49_d6_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "specifies the correct URL and sha256" do` at line 75.
pub fn ruby_cask_spec_l75_d7_specifies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('specifies', ...args)
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
