module test

import brew_runtime

// Translated from Homebrew/brew `test/api_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:text) { "foo" }` at line 8.
pub fn ruby_api_spec_l8_d1_text(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('text', ...args)
}

// Ruby let `let(:json) { '{"foo":"bar"}' }` at line 9.
pub fn ruby_api_spec_l9_d2_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('json', ...args)
}

// Ruby let `let(:json_hash) { JSON.parse(json) }` at line 10.
pub fn ruby_api_spec_l10_d3_json_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('json_hash', ...args)
}

// Ruby let `let(:json_invalid) { '{"foo":"bar"' }` at line 11.
pub fn ruby_api_spec_l11_d4_json_invalid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('json_invalid', ...args)
}

// Ruby method `mock_curl_output(stdout: "", success: true)` at line 13.
pub fn ruby_api_spec_l13_d5_mock_curl_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mock_curl_output', ...args)
}

// Ruby method `mock_curl_download(stdout:)` at line 18.
pub fn ruby_api_spec_l18_d6_mock_curl_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mock_curl_download', ...args)
}

// Ruby it `it "fetches a JSON file" do` at line 25.
pub fn ruby_api_spec_l25_d7_fetches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetches', ...args)
}

// Ruby it `it "raises an error if the file does not exist" do` at line 31.
pub fn ruby_api_spec_l31_d8_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises an error if the JSON file is invalid" do` at line 36.
pub fn ruby_api_spec_l36_d9_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "returns true for a core formula name" do` at line 47.
pub fn ruby_api_spec_l47_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false for an unknown name" do` at line 51.
pub fn ruby_api_spec_l51_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns true for a core cask token" do` at line 61.
pub fn ruby_api_spec_l61_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false for an unknown token" do` at line 65.
pub fn ruby_api_spec_l65_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let! `let!(:cache_dir) { mktmpdir }` at line 71.
pub fn ruby_api_spec_l71_d14_cache_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cache_dir', ...args)
}

// Ruby it `it "fetches a JSON file" do` at line 77.
pub fn ruby_api_spec_l77_d15_fetches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetches', ...args)
}

// Ruby it `it "updates an existing JSON file" do` at line 83.
pub fn ruby_api_spec_l83_d16_updates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('updates', ...args)
}

// Ruby it `it "raises an error if the JSON file is invalid" do` at line 89.
pub fn ruby_api_spec_l89_d17_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "does not refresh the cache mtime when the download fails" do` at line 96.
pub fn ruby_api_spec_l96_d18_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "refreshes the cache mtime when a fallback to the default API domain succeeds" do` at line 115.
pub fn ruby_api_spec_l115_d19_refreshes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('refreshes', ...args)
}

// Ruby method `self.jws_test_key` at line 146.
pub fn ruby_api_spec_l146_d20_self_jws_test_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.jws_test_key', ...args)
}

// Ruby let! `let!(:cache_dir) { mktmpdir }` at line 150.
pub fn ruby_api_spec_l150_d21_cache_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cache_dir', ...args)
}

// Ruby let `let(:target) { cache_dir/"internal/packages.test.jws.json" }` at line 151.
pub fn ruby_api_spec_l151_d22_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target', ...args)
}

// Ruby let `let(:payload_cache) { cache_dir/"internal/packages.test.jws.json.payload" }` at line 152.
pub fn ruby_api_spec_l152_d23_payload_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('payload_cache', ...args)
}

// Ruby let `let(:private_key) { self.class.jws_test_key }` at line 153.
pub fn ruby_api_spec_l153_d24_private_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('private_key', ...args)
}

// Ruby let `let(:protected_b64) { urlsafe_encode64('{"alg":"PS512","b64":false}') }` at line 154.
pub fn ruby_api_spec_l154_d25_protected_b64(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('protected_b64', ...args)
}

// Ruby method `urlsafe_encode64(value)` at line 156.
pub fn ruby_api_spec_l156_d26_urlsafe_encode64(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('urlsafe_encode64', ...args)
}

// Ruby method `sign_payload(payload)` at line 160.
pub fn ruby_api_spec_l160_d27_sign_payload(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sign_payload', ...args)
}

// Ruby method `envelope_json(payload, signature: sign_payload(payload))` at line 166.
pub fn ruby_api_spec_l166_d28_envelope_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('envelope_json', ...args)
}

// Ruby method `write_payload_cache(payload, signature: sign_payload(payload))` at line 177.
pub fn ruby_api_spec_l177_d29_write_payload_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_payload_cache', ...args)
}

// Ruby method `fetch_target` at line 188.
pub fn ruby_api_spec_l188_d30_fetch_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetch_target', ...args)
}

// Ruby it `it "verifies the envelope and writes a payload cache" do` at line 199.
pub fn ruby_api_spec_l199_d31_verifies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('verifies', ...args)
}

// Ruby it `it "does not write a payload cache for endpoints without one" do` at line 204.
pub fn ruby_api_spec_l204_d32_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "loads a current payload cache instead of the envelope" do` at line 214.
pub fn ruby_api_spec_l214_d33_loads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('loads', ...args)
}

// Ruby it `it "falls back to the envelope when the payload cache does not match the file" do` at line 219.
pub fn ruby_api_spec_l219_d34_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "falls back to the envelope when the payload cache signature does not verify" do` at line 225.
pub fn ruby_api_spec_l225_d35_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "falls back to the envelope when the payload cache is corrupt" do` at line 230.
pub fn ruby_api_spec_l230_d36_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "falls back to the envelope when the payload cache header is not a JSON object" do` at line 235.
pub fn ruby_api_spec_l235_d37_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "raises when the envelope signature does not verify" do` at line 240.
pub fn ruby_api_spec_l240_d38_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "does not initialise downloads when the API cache is current" do` at line 248.
pub fn ruby_api_spec_l248_d39_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "handles a missing API cache before refusing root downloads" do` at line 258.
pub fn ruby_api_spec_l258_d40_handles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handles', ...args)
}

// Ruby it `it "decodes unpadded URL-safe base64" do` at line 270.
pub fn ruby_api_spec_l270_d41_decodes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('decodes', ...args)
}

// Ruby it `it "rejects invalid base64" do` at line 274.
pub fn ruby_api_spec_l274_d42_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "downloads executables.txt from the GitHub Packages OCI artifact" do` at line 280.
pub fn ruby_api_spec_l280_d43_downloads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('downloads', ...args)
}

// Ruby let `let(:cache_dir) { mktmpdir }` at line 313.
pub fn ruby_api_spec_l313_d44_cache_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cache_dir', ...args)
}

// Ruby let `let(:target) { cache_dir/"internal/executables.txt" }` at line 314.
pub fn ruby_api_spec_l314_d45_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target', ...args)
}

// Ruby let `let(:source) { cache_dir/"internal/packages.jws.json" }` at line 315.
pub fn ruby_api_spec_l315_d46_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source', ...args)
}

// Ruby let `let(:formulae) { { "foo" => { "executables" => ["foo-bin"] } } }` at line 316.
pub fn ruby_api_spec_l316_d47_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formulae', ...args)
}

// Ruby method `write_executables_file!(regenerate:)` at line 318.
pub fn ruby_api_spec_l318_d48_write_executables_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_executables_file!', ...args)
}

// Ruby it `it "writes the executables database when it does not exist" do` at line 328.
pub fn ruby_api_spec_l328_d49_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Ruby it `it "does not rebuild an executables database newer than its source when not regenerating" do` at line 333.
pub fn ruby_api_spec_l333_d50_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "rebuilds the executables database when the source is newer" do` at line 341.
pub fn ruby_api_spec_l341_d51_rebuilds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rebuilds', ...args)
}

// Ruby it `it "rewrites the executables database when regenerating" do` at line 349.
pub fn ruby_api_spec_l349_d52_rewrites(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rewrites', ...args)
}

// Ruby let `let(:api_cache_root) { Homebrew::API::HOMEBREW_CACHE_API_SOURCE }` at line 359.
pub fn ruby_api_spec_l359_d53_api_cache_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('api_cache_root', ...args)
}

// Ruby let `let(:cache_path) do` at line 360.
pub fn ruby_api_spec_l360_d54_cache_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cache_path', ...args)
}

// Ruby it `it "returns the corresponding tap" do` at line 365.
pub fn ruby_api_spec_l365_d55_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:api_cache_root) { mktmpdir }` at line 371.
pub fn ruby_api_spec_l371_d56_api_cache_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('api_cache_root', ...args)
}

// Ruby it `it "returns nil" do` at line 373.
pub fn ruby_api_spec_l373_d57_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns nil" do` at line 379.
pub fn ruby_api_spec_l379_d58_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:arm64_sequoia_tag) { Utils::Bottles::Tag.new(system: :sequoia, arch: :arm) }` at line 386.
pub fn ruby_api_spec_l386_d59_arm64_sequoia_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arm64_sequoia_tag', ...args)
}

// Ruby let `let(:sonoma_tag) { Utils::Bottles::Tag.new(system: :sonoma, arch: :intel) }` at line 387.
pub fn ruby_api_spec_l387_d60_sonoma_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sonoma_tag', ...args)
}

// Ruby let `let(:x86_64_linux_tag) { Utils::Bottles::Tag.new(system: :linux, arch: :intel) }` at line 388.
pub fn ruby_api_spec_l388_d61_x86_64_linux_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('x86_64_linux_tag', ...args)
}

// Ruby let `let(:json) do` at line 390.
pub fn ruby_api_spec_l390_d62_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('json', ...args)
}

// Ruby let `let(:arm64_sequoia_result) do` at line 402.
pub fn ruby_api_spec_l402_d63_arm64_sequoia_result(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arm64_sequoia_result', ...args)
}

// Ruby let `let(:sonoma_result) do` at line 410.
pub fn ruby_api_spec_l410_d64_sonoma_result(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sonoma_result', ...args)
}

// Ruby it `it "returns the original JSON if no variations are found" do` at line 418.
pub fn ruby_api_spec_l418_d65_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the original JSON if no variations are found for the current system" do` at line 423.
pub fn ruby_api_spec_l423_d66_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the original JSON without the variations if no matching variation is found" do` at line 428.
pub fn ruby_api_spec_l428_d67_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the original JSON without the variations if no matching variation is found for the current system" do` at line 433.
pub fn ruby_api_spec_l433_d68_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the JSON with the matching variation applied from a string key" do` at line 440.
pub fn ruby_api_spec_l440_d69_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the JSON with the matching variation applied from a string key for the current system" do` at line 445.
pub fn ruby_api_spec_l445_d70_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the JSON with the matching variation applied from a symbol key" do` at line 452.
pub fn ruby_api_spec_l452_d71_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the JSON with the matching variation applied from a symbol key for the current system" do` at line 457.
pub fn ruby_api_spec_l457_d72_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
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
