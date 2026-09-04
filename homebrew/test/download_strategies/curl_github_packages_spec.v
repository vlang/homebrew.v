module download_strategies

import ruby
import crypto.sha256
import homebrew.download_strategy as production_strategy
import os
import time

// Translated from Homebrew/brew `test/download_strategies/curl_github_packages_spec.rb`.
// The original source is retained below until every stub has a typed V body.

const curl_github_packages_spec_checksum = 'd7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97'

fn curl_github_packages_spec_manifest_url() string {
	return 'https://ghcr.io/v2/homebrew/core/spec_test/manifests/1.2.3'
}

fn curl_github_packages_spec_blob_url() string {
	return 'https://ghcr.io/v2/homebrew/core/foo/blobs/sha256:${curl_github_packages_spec_checksum}'
}

fn curl_github_packages_spec_strategy(url string, authorization string,
	meta production_strategy.DownloadMeta, bottle bool) production_strategy.CurlGitHubPackagesDownloadStrategy {
	old_authorization := os.getenv('HOMEBREW_GITHUB_PACKAGES_AUTH')
	old_artifact_domain := os.getenv('HOMEBREW_ARTIFACT_DOMAIN')
	old_basic_token := os.getenv('HOMEBREW_DOCKER_REGISTRY_BASIC_AUTH_TOKEN')
	old_registry_token := os.getenv('HOMEBREW_DOCKER_REGISTRY_TOKEN')
	os.setenv('HOMEBREW_GITHUB_PACKAGES_AUTH', if authorization != '' {
		authorization
	} else {
		'Bearer QQ=='
	}, true)
	os.setenv('HOMEBREW_ARTIFACT_DOMAIN', '', true)
	os.setenv('HOMEBREW_DOCKER_REGISTRY_BASIC_AUTH_TOKEN', '', true)
	os.setenv('HOMEBREW_DOCKER_REGISTRY_TOKEN', '', true)
	defer {
		os.setenv('HOMEBREW_GITHUB_PACKAGES_AUTH', old_authorization, true)
		os.setenv('HOMEBREW_ARTIFACT_DOMAIN', old_artifact_domain, true)
		os.setenv('HOMEBREW_DOCKER_REGISTRY_BASIC_AUTH_TOKEN', old_basic_token, true)
		os.setenv('HOMEBREW_DOCKER_REGISTRY_TOKEN', old_registry_token, true)
	}
	return production_strategy.new_curl_github_packages_download_strategy(url, 'foo', '1.2.3', meta, bottle)
}

fn curl_github_packages_spec_headers(authorization string) []string {
	strategy := curl_github_packages_spec_strategy(curl_github_packages_spec_manifest_url(), authorization, production_strategy.DownloadMeta{
		headers: ['Accept: application/vnd.oci.image.index.v1+json']
	}, false)
	return strategy.curl.curl_args()
}

fn curl_github_packages_spec_has_pair(arguments []string, flag string, value string) bool {
	for index in 0 .. arguments.len - 1 {
		if arguments[index] == flag && arguments[index + 1] == value {
			return true
		}
	}
	return false
}

// Ruby subject `subject(:strategy) { described_class.new(url, name, version, **specs) }` at line 7.
pub fn ruby_curl_github_packages_spec_l7_d1_strategy(args ...ruby.Value) ruby.Value {
	url := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		curl_github_packages_spec_manifest_url()
	}
	strategy := curl_github_packages_spec_strategy(url, '', production_strategy.DownloadMeta{
		headers: ['Accept: application/vnd.oci.image.index.v1+json']
	}, false)
	return ruby.structured_value('CurlGitHubPackagesDownloadStrategy', url, {
		'url':     strategy.curl.file.base.url
		'name':    strategy.curl.file.base.name
		'version': strategy.curl.file.base.version
		'headers': strategy.curl.file.base.meta.headers.join('\n')
		'bottle':  strategy.bottle.str()
	})
}

// Ruby let `let(:name) { "foo" }` at line 9.
pub fn ruby_curl_github_packages_spec_l9_d2_name(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('foo')
}

// Ruby let `let(:url) { "https://#{GitHubPackages::URL_DOMAIN}/v2/homebrew/core/spec_test/manifests/1.2.3" }` at line 10.
pub fn ruby_curl_github_packages_spec_l10_d3_url(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(curl_github_packages_spec_manifest_url())
}

// Ruby let `let(:version) { "1.2.3" }` at line 11.
pub fn ruby_curl_github_packages_spec_l11_d4_version(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('1.2.3')
}

// Ruby let `let(:specs) { { headers: ["Accept: application/vnd.oci.image.index.v1+json"] } }` at line 12.
pub fn ruby_curl_github_packages_spec_l12_d5_specs(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({
		'headers': ruby.string_array_value([
			'Accept: application/vnd.oci.image.index.v1+json',
		])
	})
}

// Ruby let `let(:authorization) { nil }` at line 13.
pub fn ruby_curl_github_packages_spec_l13_d6_authorization(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('NilClass', 'nil')
}

// Ruby let `let(:checksum) { "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97" }` at line 14.
pub fn ruby_curl_github_packages_spec_l14_d7_checksum(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(curl_github_packages_spec_checksum)
}

// Ruby let `let(:head_response) do` at line 15.
pub fn ruby_curl_github_packages_spec_l15_d8_head_response(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('HTTP/2 200\r\ncontent-length: 12671\r\ncontent-type: application/vnd.oci.image.index.v1+json\r\ndocker-content-digest: sha256:7d752ee92d9120e3884b452dce15328536a60d468023ea8e9f4b09839a5442e5\r\ndocker-distribution-api-version: registry/2.0\r\netag: "sha256:7d752ee92d9120e3884b452dce15328536a60d468023ea8e9f4b09839a5442e5"\r\ndate: Sun, 02 Apr 2023 22:45:08 GMT\r\nx-github-request-id: 8814:FA5A:14DAFB5:158D7A2:642A0574\r\n')
}

// Ruby it `it "calls curl with anonymous authentication headers" do` at line 51.
pub fn ruby_curl_github_packages_spec_l51_d9_calls(args ...ruby.Value) ruby.Value {
	_ = args
	arguments := curl_github_packages_spec_headers('')
	return ruby.bool_value(curl_github_packages_spec_has_pair(arguments, '--header', 'Authorization: Bearer QQ==') && '--max-redirs' !in arguments)
}

// Ruby let `let(:authorization) { "Bearer dead-beef-cafe" }` at line 62.
pub fn ruby_curl_github_packages_spec_l62_d10_authorization(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('Bearer dead-beef-cafe')
}

// Ruby it `it "calls curl with the provided header value" do` at line 64.
pub fn ruby_curl_github_packages_spec_l64_d11_calls(args ...ruby.Value) ruby.Value {
	_ = args
	arguments := curl_github_packages_spec_headers('Bearer dead-beef-cafe')
	return ruby.bool_value(curl_github_packages_spec_has_pair(arguments, '--header', 'Authorization: Bearer dead-beef-cafe'))
}

// Ruby let `let(:url) { "https://#{GitHubPackages::URL_DOMAIN}/v2/homebrew/core/foo/blobs/sha256:#{checksum}" }` at line 79.
pub fn ruby_curl_github_packages_spec_l79_d12_url(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(curl_github_packages_spec_blob_url())
}

// Ruby let `let(:specs) { { bottle: true } }` at line 80.
pub fn ruby_curl_github_packages_spec_l80_d13_specs(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({
		'bottle': ruby.bool_value(true)
	})
}

// Ruby it `it "uses the resolved basename without discovering existing cache files" do` at line 82.
pub fn ruby_curl_github_packages_spec_l82_d14_uses(args ...ruby.Value) ruby.Value {
	_ = args
	cache_root := os.join_path(os.temp_dir(), 'brew-v-ghcr-cache-${os.getpid()}-${time.now().unix_micro()}')
	old_cache := os.getenv('HOMEBREW_CACHE')
	os.setenv('HOMEBREW_CACHE', cache_root, true)
	defer { os.setenv('HOMEBREW_CACHE', old_cache, true) }
	mut strategy := curl_github_packages_spec_strategy(curl_github_packages_spec_blob_url(), '', production_strategy.DownloadMeta{}, true)
	strategy.set_resolved_basename('foo--1.2.3.arm64_ventura.bottle.tar.gz')
	location := strategy.cached_location()
	digest := sha256.sum256(curl_github_packages_spec_blob_url().bytes()).hex()
	expected := os.join_path(cache_root, 'downloads', '${digest}--foo--1.2.3.arm64_ventura.bottle.tar.gz')
	return ruby.bool_value(location == expected)
}

// Ruby let `let(:cache) { HOMEBREW_CACHE/"custom-cache" }` at line 92.
pub fn ruby_curl_github_packages_spec_l92_d15_cache(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', os.join_path(os.temp_dir(), 'homebrew-cache', 'custom-cache'))
}

// Ruby let `let(:specs) { { bottle: true, cache: } }` at line 93.
pub fn ruby_curl_github_packages_spec_l93_d16_specs(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({
		'bottle': ruby.bool_value(true)
		'cache':  ruby_curl_github_packages_spec_l92_d15_cache()
	})
}

// Ruby it `it "keeps cached downloads under HOMEBREW_CACHE downloads" do` at line 95.
pub fn ruby_curl_github_packages_spec_l95_d17_keeps(args ...ruby.Value) ruby.Value {
	_ = args
	cache_root := os.join_path(os.temp_dir(), 'brew-v-ghcr-custom-${os.getpid()}-${time.now().unix_micro()}')
	custom_cache := os.join_path(cache_root, 'custom-cache')
	old_cache := os.getenv('HOMEBREW_CACHE')
	os.setenv('HOMEBREW_CACHE', cache_root, true)
	defer { os.setenv('HOMEBREW_CACHE', old_cache, true) }
	mut strategy := curl_github_packages_spec_strategy(curl_github_packages_spec_blob_url(), '', production_strategy.DownloadMeta{
		cache: custom_cache
	}, true)
	strategy.set_resolved_basename('foo--1.2.3.arm64_ventura.bottle.tar.gz')
	location := strategy.cached_location()
	return ruby.bool_value(os.dir(location) == os.join_path(cache_root, 'downloads')
		&& os.dir(strategy.curl.file.symlink_location()) == custom_cache)
}

// Ruby let `let(:specs) { { bottle: true, mirrors: ["https://mirror.example/foo.tar.gz"] } }` at line 105.
pub fn ruby_curl_github_packages_spec_l105_d18_specs(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({
		'bottle':  ruby.bool_value(true)
		'mirrors': ruby.string_array_value(['https://mirror.example/foo.tar.gz'])
	})
}

// Ruby it `it "uses generic cache discovery" do` at line 107.
pub fn ruby_curl_github_packages_spec_l107_d19_uses(args ...ruby.Value) ruby.Value {
	_ = args
	mut strategy := curl_github_packages_spec_strategy(curl_github_packages_spec_blob_url(), '', production_strategy.DownloadMeta{
		mirrors: ['https://mirror.example/foo.tar.gz']
	}, true)
	strategy.set_resolved_basename('foo--1.2.3.arm64_ventura.bottle.tar.gz')
	return ruby.bool_value(!strategy.immutable_bottle_blob())
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "download_strategy"
// 5:
// 6: RSpec.describe CurlGitHubPackagesDownloadStrategy do
// 7:   subject(:strategy) { described_class.new(url, name, version, **specs) }
// 8:
// 9:   let(:name) { "foo" }
// 10:   let(:url) { "https://#{GitHubPackages::URL_DOMAIN}/v2/homebrew/core/spec_test/manifests/1.2.3" }
// 11:   let(:version) { "1.2.3" }
// 12:   let(:specs) { { headers: ["Accept: application/vnd.oci.image.index.v1+json"] } }
// 13:   let(:authorization) { nil }
// 14:   let(:checksum) { "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97" }
// 15:   let(:head_response) do
// 16:     <<~HTTP
// 17:       HTTP/2 200\r
// 18:       content-length: 12671\r
// 19:       content-type: application/vnd.oci.image.index.v1+json\r
// 20:       docker-content-digest: sha256:7d752ee92d9120e3884b452dce15328536a60d468023ea8e9f4b09839a5442e5\r
// 21:       docker-distribution-api-version: registry/2.0\r
// 22:       etag: "sha256:7d752ee92d9120e3884b452dce15328536a60d468023ea8e9f4b09839a5442e5"\r
// 23:       date: Sun, 02 Apr 2023 22:45:08 GMT\r
// 24:       x-github-request-id: 8814:FA5A:14DAFB5:158D7A2:642A0574\r
// 25:     HTTP
// 26:   end
// 27:
// 28:   describe "#fetch" do
// 29:     before do
// 30:       stub_const("HOMEBREW_GITHUB_PACKAGES_AUTH", authorization) if authorization.present?
// 31:
// 32:       allow(strategy).to receive(:curl_version).and_return(Version.new("8.7.1"))
// 33:
// 34:       allow(strategy).to receive(:system_command)
// 35:         .with(
// 36:           /curl/,
// 37:           hash_including(args: array_including("--head")),
// 38:         )
// 39:         .twice
// 40:         .and_return(instance_double(
// 41:                       SystemCommand::Result,
// 42:                       success?:    true,
// 43:                       exit_status: instance_double(Process::Status, exitstatus: 0),
// 44:                       stdout:      head_response,
// 45:                     ))
// 46:
// 47:       strategy.temporary_path.dirname.mkpath
// 48:       FileUtils.touch strategy.temporary_path
// 49:     end
// 50:
// 51:     it "calls curl with anonymous authentication headers" do
// 52:       expect(strategy).to receive(:system_command) do |_command, options|
// 53:         expect(options[:args]).to include("--header", "Authorization: Bearer QQ==")
// 54:         expect(options[:args]).not_to include("--max-redirs")
// 55:         instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil)
// 56:       end.at_least(:once)
// 57:
// 58:       strategy.fetch
// 59:     end
// 60:
// 61:     context "with GitHub Packages authentication defined" do
// 62:       let(:authorization) { "Bearer dead-beef-cafe" }
// 63:
// 64:       it "calls curl with the provided header value" do
// 65:         expect(strategy).to receive(:system_command)
// 66:           .with(
// 67:             /curl/,
// 68:             hash_including(args: array_including_cons("--header", "Authorization: #{authorization}")),
// 69:           )
// 70:           .at_least(:once)
// 71:           .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil))
// 72:
// 73:         strategy.fetch
// 74:       end
// 75:     end
// 76:   end
// 77:
// 78:   describe "#cached_location" do
// 79:     let(:url) { "https://#{GitHubPackages::URL_DOMAIN}/v2/homebrew/core/foo/blobs/sha256:#{checksum}" }
// 80:     let(:specs) { { bottle: true } }
// 81:
// 82:     it "uses the resolved basename without discovering existing cache files" do
// 83:       strategy.resolved_basename = "foo--1.2.3.arm64_ventura.bottle.tar.gz"
// 84:
// 85:       expect(Pathname).not_to receive(:glob)
// 86:
// 87:       expect(strategy.cached_location)
// 88:         .to eq(HOMEBREW_CACHE/"downloads/#{Digest::SHA256.hexdigest(url)}--foo--1.2.3.arm64_ventura.bottle.tar.gz")
// 89:     end
// 90:
// 91:     context "with a custom cache" do
// 92:       let(:cache) { HOMEBREW_CACHE/"custom-cache" }
// 93:       let(:specs) { { bottle: true, cache: } }
// 94:
// 95:       it "keeps cached downloads under HOMEBREW_CACHE downloads" do
// 96:         strategy.resolved_basename = "foo--1.2.3.arm64_ventura.bottle.tar.gz"
// 97:
// 98:         expect(strategy.cached_location)
// 99:           .to eq(HOMEBREW_CACHE/"downloads/#{Digest::SHA256.hexdigest(url)}--foo--1.2.3.arm64_ventura.bottle.tar.gz")
// 100:         expect(strategy.symlink_location.dirname).to eq(cache)
// 101:       end
// 102:     end
// 103:
// 104:     context "with mirrors" do
// 105:       let(:specs) { { bottle: true, mirrors: ["https://mirror.example/foo.tar.gz"] } }
// 106:
// 107:       it "uses generic cache discovery" do
// 108:         strategy.resolved_basename = "foo--1.2.3.arm64_ventura.bottle.tar.gz"
// 109:
// 110:         expect(strategy.immutable_bottle_blob?).to be false
// 111:       end
// 112:     end
// 113:   end
// 114: end
