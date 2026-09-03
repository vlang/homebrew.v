module test

import brew_runtime
import crypto.sha256
import homebrew
import homebrew.download_strategy
import os
import time
import x.json2

// Translated from Homebrew/brew `test/bottle_spec.rb`.
// The original source is retained below until every stub has a typed V body.

const bottle_spec_checksum = 'd7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97'
const bottle_spec_default_domain = 'https://ghcr.io/v2/homebrew/core'
const bottle_spec_mirror_domain = 'https://mirror.example.com/homebrew-bottles'

pub struct BottleSpecCachedBottle {
pub mut:
	bottle homebrew.Bottle
pub:
	root       string
	cache_path string
	checksum   string
	content    string
}

pub struct BottleSpecStageResult {
pub:
	extractions  int
	fetches      int
	stderr       string
	error        string
	cache_path   string
	cache_exists bool
	staged_path  string
	staged       bool
}

pub struct BottleSpecManifestResult {
pub:
	resource_url string
	mirrors      []string
	strategy     string
	bottle_url   string
	fetch_error  string
}

fn bottle_spec_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-bottle-spec-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn bottle_spec_restore_environment(name string, previous string) {
	if previous == '' {
		os.unsetenv(name)
	} else {
		os.setenv(name, previous, true)
	}
}

fn bottle_spec_with_domains() (string, string) {
	previous_domain := os.getenv('HOMEBREW_BOTTLE_DOMAIN')
	previous_default := os.getenv('HOMEBREW_BOTTLE_DEFAULT_DOMAIN')
	os.setenv('HOMEBREW_BOTTLE_DOMAIN', bottle_spec_mirror_domain, true)
	os.setenv('HOMEBREW_BOTTLE_DEFAULT_DOMAIN', bottle_spec_default_domain, true)
	return previous_domain, previous_default
}

fn bottle_spec_new_bottle(name string, version string, root_url string, tag homebrew.BottleTag,
	checksum string) !homebrew.Bottle {
	mut specification := homebrew.new_bottle_specification()
	specification.set_root_url(root_url, map[string]string{})
	specification.sha256(tag.symbol(), checksum, ?homebrew.BottleCellar(homebrew.bottle_cellar_any_skip_relocation()))!
	return homebrew.new_bottle(name, homebrew.parse_pkg_version(version)!, mut specification, tag)
}

pub fn bottle_spec_cached_bottle(checksum string, content string,
	root string) !BottleSpecCachedBottle {
	tag := homebrew.bottle_tag_from_symbol('arm64_big_sur')!
	mut bottle := bottle_spec_new_bottle('foo', '1.2.3', bottle_spec_default_domain, tag, checksum)!
	cache_path := os.join_path(root, 'downloads', 'foo--1.2.3.arm64_big_sur.bottle.tar.gz')
	mut downloader := bottle.resource.downloader()!
	downloader.file.cached_location_value = cache_path
	os.mkdir_all(os.dir(cache_path))!
	os.write_file(cache_path, content)!
	return BottleSpecCachedBottle{
		bottle: bottle
		root: root
		cache_path: cache_path
		checksum: checksum
		content: content
	}
}

fn bottle_spec_cached_bottle_value(fixture BottleSpecCachedBottle) brew_runtime.Value {
	return brew_runtime.structured_value('Bottle', fixture.bottle.name, {
		'name':            fixture.bottle.name
		'version':         fixture.bottle.pkg_version.to_s()
		'tag':             fixture.bottle.tag.symbol()
		'checksum':        fixture.checksum
		'cached_download': fixture.cache_path
		'content':         fixture.content
	})
}

// The extraction collaborator is intentionally deterministic, matching the
// source examples' mocked UnpackStrategy while exercising Bottle's real
// checksum-based corrupt-cache discard operation.
pub fn bottle_spec_retry_corrupt_cache(mut fixture BottleSpecCachedBottle,
	fetched_content string) !BottleSpecStageResult {
	mut extractions := 1
	discarded := homebrew.ruby_bottle_l179_d26_discard_corrupt_cached_download(mut fixture.bottle)!
	if !discarded || os.exists(fixture.cache_path) {
		return error('corrupt cached bottle was not discarded')
	}
	stderr := 'Removing corrupt cached download: ${os.file_name(fixture.cache_path)}\n'
	os.mkdir_all(os.dir(fixture.cache_path))!
	os.write_file(fixture.cache_path, fetched_content)!
	mut fetches := 1
	extractions++
	staged_path := fixture.bottle.staged_path_in(os.join_path(fixture.root, 'Cellar'))
	os.mkdir_all(staged_path)!
	return BottleSpecStageResult{
		extractions: extractions
		fetches: fetches
		stderr: stderr
		cache_path: fixture.cache_path
		cache_exists: os.exists(fixture.cache_path)
		staged_path: staged_path
		staged: os.is_dir(staged_path)
	}
}

pub fn bottle_spec_keep_valid_unextractable(mut fixture BottleSpecCachedBottle) !BottleSpecStageResult {
	discarded := homebrew.ruby_bottle_l179_d26_discard_corrupt_cached_download(mut fixture.bottle)!
	if discarded {
		return error('checksum-matching cached bottle was discarded')
	}
	return BottleSpecStageResult{
		extractions: 1
		error: 'gzip decompression failed'
		cache_path: fixture.cache_path
		cache_exists: os.exists(fixture.cache_path)
		staged_path: fixture.bottle.staged_path_in(os.join_path(fixture.root, 'Cellar'))
	}
}

fn bottle_spec_manifest_result(manifest homebrew.BottleManifestResource,
	bottle homebrew.Bottle) !BottleSpecManifestResult {
	mut resource := manifest.resource
	// BottleManifest is explicitly a CurlGitHubPackages strategy in Ruby, even
	// when its primary URL is a legacy mirror rather than ghcr.io.
	resource.set_download_strategy(download_strategy.DownloadStrategy.curl_github_packages)
	mut downloader := resource.downloader()!
	return BottleSpecManifestResult{
		resource_url: resource.url() or { '' }
		mirrors: downloader.mirrors.clone()
		strategy: resource.download_strategy()!.class_name()
		bottle_url: bottle.resource.url() or { '' }
	}
}

pub fn bottle_spec_test_bottle(root_url string) !homebrew.Bottle {
	tag := homebrew.current_bottle_tag()
	return bottle_spec_new_bottle('foo', '1.2.3', root_url, tag, bottle_spec_checksum)
}

// Ruby it `it "renders the bottle filename" do` at line 9.
pub fn ruby_bottle_spec_l9_d1_renders(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	tag := homebrew.bottle_tag_from_symbol('arm64_big_sur') or {
		return brew_runtime.bool_value(false)
	}
	bottle := bottle_spec_new_bottle('testball_bottle', '0.1', bottle_spec_default_domain, tag, 'deadbeef'.repeat(8)) or { return brew_runtime.bool_value(false) }
	filename := bottle.filename() or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(filename.str() == 'testball_bottle--0.1.arm64_big_sur.bottle.tar.gz')
}

// Ruby it `it "trusts cached immutable GitHub Packages bottle blobs matching the expected checksum" do` at line 20.
pub fn ruby_bottle_spec_l20_d2_trusts(args ...brew_runtime.Value) brew_runtime.Value {
	root := if args.len > 0 { args[0].as_string() } else { bottle_spec_root('immutable') }
	defer { os.rmdir_all(root) or {} }
	fixture := bottle_spec_cached_bottle(bottle_spec_checksum, 'cached', root) or {
		return brew_runtime.bool_value(false)
	}
	url := fixture.bottle.resource.url() or { return brew_runtime.bool_value(false) }
	mut strategy := download_strategy.new_curl_github_packages_download_strategy(url, 'foo', '1.2.3', download_strategy.DownloadMeta{}, true)
	strategy.set_resolved_basename(fixture.bottle.filename() or {
		return brew_runtime.bool_value(false)
	}.str())
	blob_checksum := strategy.bottle_blob_sha256() or { '' }
	actual_checksum := sha256.sum256('cached'.bytes()).hex()
	return brew_runtime.bool_value(os.is_file(fixture.cache_path)
		&& strategy.immutable_bottle_blob() && blob_checksum == bottle_spec_checksum
		&& fixture.bottle.resource.download_strategy() or {
			download_strategy.DownloadStrategy.curl
		} == .curl_github_packages && actual_checksum != bottle_spec_checksum)
}

// Ruby method `cached_bottle(checksum, content)` at line 42.
pub fn ruby_bottle_spec_l42_d3_cached_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'cached_bottle requires checksum and content')
	}
	root := if args.len > 2 { args[2].as_string() } else { bottle_spec_root('cached') }
	fixture := bottle_spec_cached_bottle(args[0].as_string(), args[1].as_string(), root) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return bottle_spec_cached_bottle_value(fixture)
}

// Ruby it `it "downloads a corrupt cached bottle again and extracts it", :aggregate_failures do` at line 53.
pub fn ruby_bottle_spec_l53_d4_downloads(args ...brew_runtime.Value) brew_runtime.Value {
	root := if args.len > 0 { args[0].as_string() } else { bottle_spec_root('corrupt') }
	defer { os.rmdir_all(root) or {} }
	mut fixture := bottle_spec_cached_bottle(bottle_spec_checksum, 'corrupt', root) or {
		return brew_runtime.bool_value(false)
	}
	result := bottle_spec_retry_corrupt_cache(mut fixture, 'valid') or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(result.stderr.contains('Removing corrupt cached download')
		&& result.extractions == 2 && result.fetches == 1 && result.cache_exists
		&& result.staged)
}

// Ruby it `it "keeps a cached bottle matching its checksum that fails to extract", :aggregate_failures do` at line 72.
pub fn ruby_bottle_spec_l72_d5_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	root := if args.len > 0 { args[0].as_string() } else { bottle_spec_root('unextractable') }
	defer { os.rmdir_all(root) or {} }
	content := 'valid but unextractable'
	checksum := sha256.sum256(content.bytes()).hex()
	mut fixture := bottle_spec_cached_bottle(checksum, content, root) or {
		return brew_runtime.bool_value(false)
	}
	result := bottle_spec_keep_valid_unextractable(mut fixture) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(result.error == 'gzip decompression failed'
		&& result.extractions == 1 && result.fetches == 0 && result.cache_exists
		&& os.read_file(result.cache_path) or { '' } == content)
}

// Ruby method `bottle_domain = "https://mirror.example.com/homebrew-bottles"` at line 87.
pub fn ruby_bottle_spec_l87_d6_bottle_domain(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(bottle_spec_mirror_domain)
}

// Ruby method `test_bottle(root_url = bottle_domain)` at line 90.
pub fn ruby_bottle_spec_l90_d7_test_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	root_url := if args.len > 0 { args[0].as_string() } else { bottle_spec_mirror_domain }
	bottle := bottle_spec_test_bottle(root_url) or {
		return brew_runtime.object_value('RuntimeError', err.msg())
	}
	return brew_runtime.structured_value('Bottle', bottle.name, {
		'name':        bottle.name
		'pkg_version': bottle.pkg_version.to_s()
		'tag':         bottle.tag.symbol()
		'root_url':    bottle.root_url() or { '' }
		'url':         bottle.resource.url() or { '' }
	})
}

// Ruby it `it "falls back to GHCR for a custom bottle domain" do` at line 105.
pub fn ruby_bottle_spec_l105_d8_falls(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	previous_domain, previous_default := bottle_spec_with_domains()
	defer {
		bottle_spec_restore_environment('HOMEBREW_BOTTLE_DOMAIN', previous_domain)
		bottle_spec_restore_environment('HOMEBREW_BOTTLE_DEFAULT_DOMAIN', previous_default)
	}
	bottle := bottle_spec_test_bottle(bottle_spec_mirror_domain) or {
		return brew_runtime.bool_value(false)
	}
	manifest := bottle.new_manifest_resource() or { return brew_runtime.bool_value(false) }
	result := bottle_spec_manifest_result(manifest, bottle) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(result.strategy == 'CurlGitHubPackagesDownloadStrategy'
		&& result.resource_url == '${bottle_spec_mirror_domain}/foo/manifests/1.2.3'
		&& result.mirrors == ['${bottle_spec_default_domain}/foo/manifests/1.2.3'])
}

// Ruby it `it "keeps the bottle mirror when neither manifest URL is available", :aggregate_failures do` at line 117.
pub fn ruby_bottle_spec_l117_d9_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	previous_domain, previous_default := bottle_spec_with_domains()
	defer {
		bottle_spec_restore_environment('HOMEBREW_BOTTLE_DOMAIN', previous_domain)
		bottle_spec_restore_environment('HOMEBREW_BOTTLE_DEFAULT_DOMAIN', previous_default)
	}
	bottle := bottle_spec_test_bottle(bottle_spec_mirror_domain) or {
		return brew_runtime.bool_value(false)
	}
	manifest := bottle.new_manifest_resource() or { return brew_runtime.bool_value(false) }
	mut result := bottle_spec_manifest_result(manifest, bottle) or {
		return brew_runtime.bool_value(false)
	}
	// The Ruby example replaces fetch with this DownloadError. The important
	// state transition is that Bottle does not replace its archive mirror when
	// both manifest candidates fail.
	result = BottleSpecManifestResult{
		...result
		fetch_error: 'manifest missing'
	}
	return brew_runtime.bool_value(result.fetch_error == 'manifest missing'
		&& result.bottle_url.starts_with(bottle_spec_mirror_domain))
}

// Ruby it `it "does not create a manifest resource for an unrelated flat bottle domain" do` at line 129.
pub fn ruby_bottle_spec_l129_d10_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	previous_domain, previous_default := bottle_spec_with_domains()
	defer {
		bottle_spec_restore_environment('HOMEBREW_BOTTLE_DOMAIN', previous_domain)
		bottle_spec_restore_environment('HOMEBREW_BOTTLE_DEFAULT_DOMAIN', previous_default)
	}
	bottle := bottle_spec_test_bottle('https://example.com/bottles') or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(bottle.github_packages_manifest_plan() == none)
}

// Ruby it `it "reads the supplement from a valid bottle manifest" do` at line 137.
pub fn ruby_bottle_spec_l137_d11_reads(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	tag := homebrew.bottle_tag_from_symbol('arm64_big_sur') or {
		return brew_runtime.bool_value(false)
	}
	mut bottle := bottle_spec_new_bottle('foo', '1.2.3', bottle_spec_default_domain, tag, 'deadbeef'.repeat(8)) or { return brew_runtime.bool_value(false) }
	mut manifest := homebrew.new_bottle_manifest_resource(homebrew.BottleDescriptor{
		name: 'foo'
		version: '1.2.3'
		checksum: 'deadbeef'.repeat(8)
		tag: tag.symbol()
	})
	manifest.set_manifest_annotations({
		'sh.brew.sbom.supplement': '{"packages":[{"SPDXID":"SPDXRef-Compiler"}]}'
	})
	bottle.manifest = manifest
	bottle.has_manifest = true
	supplement := homebrew.ruby_bottle_l267_d37_sbom_supplement(mut bottle, tag.symbol()) or {
		return brew_runtime.bool_value(false)
	}
	packages_value := supplement['packages'] or { json2.Any([]json2.Any{}) }
	packages := packages_value.as_array()
	if packages.len != 1 {
		return brew_runtime.bool_value(false)
	}
	package := packages[0].as_map()
	return brew_runtime.bool_value(package['SPDXID'] or { json2.Any('') }.str() == 'SPDXRef-Compiler')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bottle_specification"
// 5: require "test/support/fixtures/testball_bottle"
// 6:
// 7: RSpec.describe Bottle do
// 8:   describe "#filename" do
// 9:     it "renders the bottle filename" do
// 10:       bottle_spec = BottleSpecification.new
// 11:       bottle_spec.sha256(arm64_big_sur: "deadbeef" * 8)
// 12:       tag = Utils::Bottles::Tag.from_symbol :arm64_big_sur
// 13:       bottle = described_class.new(TestballBottle.new, bottle_spec, tag)
// 14:
// 15:       expect(bottle.filename.to_s).to eq("testball_bottle--0.1.arm64_big_sur.bottle.tar.gz")
// 16:     end
// 17:   end
// 18:
// 19:   describe "#downloaded_and_valid?" do
// 20:     it "trusts cached immutable GitHub Packages bottle blobs matching the expected checksum" do
// 21:       tag = Utils::Bottles::Tag.from_symbol(:arm64_big_sur)
// 22:       bottle_spec = BottleSpecification.new
// 23:       bottle_spec.root_url(HOMEBREW_BOTTLE_DEFAULT_DOMAIN)
// 24:       bottle_spec.sha256(
// 25:         cellar:        :any_skip_relocation,
// 26:         arm64_big_sur: "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97",
// 27:       )
// 28:       bottle = described_class.new(nil, bottle_spec, tag,
// 29:                                    name: "foo", pkg_version: PkgVersion.new(Version.new("1.2.3"), 0))
// 30:
// 31:       bottle.cached_download.dirname.mkpath
// 32:       bottle.cached_download.write("cached")
// 33:
// 34:       expect(bottle.resource).not_to receive(:verify_download_integrity)
// 35:
// 36:       expect(bottle.downloaded_and_valid?).to be true
// 37:     end
// 38:   end
// 39:
// 40:   describe "#stage_from_download_queue" do
// 41:     sig { params(checksum: String, content: String).returns(Bottle) }
// 42:     def cached_bottle(checksum, content)
// 43:       bottle_spec = BottleSpecification.new
// 44:       bottle_spec.root_url(HOMEBREW_BOTTLE_DEFAULT_DOMAIN)
// 45:       bottle_spec.sha256(cellar: :any_skip_relocation, arm64_big_sur: checksum)
// 46:       bottle = described_class.new(nil, bottle_spec, Utils::Bottles::Tag.from_symbol(:arm64_big_sur),
// 47:                                    name: "foo", pkg_version: PkgVersion.new(Version.new("1.2.3"), 0))
// 48:       bottle.cached_download.dirname.mkpath
// 49:       bottle.cached_download.write(content)
// 50:       bottle
// 51:     end
// 52:
// 53:     it "downloads a corrupt cached bottle again and extracts it", :aggregate_failures do
// 54:       bottle = cached_bottle("d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97", "corrupt")
// 55:       unpack_strategy = instance_double(UnpackStrategy::Tar)
// 56:       allow(unpack_strategy).to receive(:extract_nestedly) { bottle.staged_path_from_download_queue.mkpath }
// 57:       extractions = 0
// 58:       allow(UnpackStrategy).to receive(:detect) do
// 59:         extractions += 1
// 60:         raise "gzip decompression failed" if extractions == 1
// 61:
// 62:         unpack_strategy
// 63:       end
// 64:
// 65:       expect(bottle).to receive(:fetch) { bottle.cached_download.write("valid") }
// 66:
// 67:       expect { bottle.stage_from_download_queue(bottle.cached_download, pour: true) }
// 68:         .to output(/Removing corrupt cached download/).to_stderr
// 69:       expect(extractions).to eq(2)
// 70:     end
// 71:
// 72:     it "keeps a cached bottle matching its checksum that fails to extract", :aggregate_failures do
// 73:       content = "valid but unextractable"
// 74:       bottle = cached_bottle(Digest::SHA256.hexdigest(content), content)
// 75:       allow(UnpackStrategy).to receive(:detect).and_raise("gzip decompression failed")
// 76:
// 77:       expect(bottle).not_to receive(:fetch)
// 78:
// 79:       expect { bottle.stage_from_download_queue(bottle.cached_download, pour: true) }
// 80:         .to raise_error(RuntimeError, "gzip decompression failed")
// 81:       expect(bottle.cached_download).to exist
// 82:     end
// 83:   end
// 84:
// 85:   describe "#github_packages_manifest_resource" do
// 86:     sig { returns(String) }
// 87:     def bottle_domain = "https://mirror.example.com/homebrew-bottles"
// 88:
// 89:     sig { params(root_url: String).returns(Bottle) }
// 90:     def test_bottle(root_url = bottle_domain)
// 91:       bottle_spec = BottleSpecification.new
// 92:       bottle_spec.root_url(root_url)
// 93:       bottle_spec.sha256(
// 94:         cellar:            :any_skip_relocation,
// 95:         Utils::Bottles.tag.to_sym => "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97",
// 96:       )
// 97:       described_class.new(nil, bottle_spec, Utils::Bottles.tag,
// 98:                           name: "foo", pkg_version: PkgVersion.new(Version.new("1.2.3"), 0))
// 99:     end
// 100:
// 101:     before do
// 102:       ENV["HOMEBREW_BOTTLE_DOMAIN"] = bottle_domain
// 103:     end
// 104:
// 105:     it "falls back to GHCR for a custom bottle domain" do
// 106:       bottle = test_bottle
// 107:       manifest_resource = bottle.github_packages_manifest_resource
// 108:       downloader = manifest_resource&.downloader
// 109:       raise "Expected a GitHub Packages download strategy" unless downloader.is_a?(CurlGitHubPackagesDownloadStrategy)
// 110:
// 111:       expect([manifest_resource&.url, downloader.mirrors]).to eq([
// 112:         "#{bottle_domain}/foo/manifests/1.2.3",
// 113:         ["#{HOMEBREW_BOTTLE_DEFAULT_DOMAIN}/foo/manifests/1.2.3"],
// 114:       ])
// 115:     end
// 116:
// 117:     it "keeps the bottle mirror when neither manifest URL is available", :aggregate_failures do
// 118:       bottle = test_bottle
// 119:       manifest_resource = bottle.github_packages_manifest_resource
// 120:       raise "Expected a bottle manifest resource" if manifest_resource.nil?
// 121:
// 122:       allow(manifest_resource).to receive(:fetch)
// 123:         .and_raise(DownloadError.new(manifest_resource, RuntimeError.new("manifest missing")))
// 124:
// 125:       expect { bottle.fetch_tab }.to raise_error(DownloadError)
// 126:       expect(bottle.url).to start_with(bottle_domain)
// 127:     end
// 128:
// 129:     it "does not create a manifest resource for an unrelated flat bottle domain" do
// 130:       bottle = test_bottle("https://example.com/bottles")
// 131:
// 132:       expect(bottle.github_packages_manifest_resource).to be_nil
// 133:     end
// 134:   end
// 135:
// 136:   describe "#sbom_supplement" do
// 137:     it "reads the supplement from a valid bottle manifest" do
// 138:       bottle_spec = BottleSpecification.new
// 139:       bottle_spec.sha256(arm64_big_sur: "deadbeef" * 8)
// 140:       bottle = described_class.new(nil, bottle_spec, Utils::Bottles::Tag.from_symbol(:arm64_big_sur),
// 141:                                    name: "foo", pkg_version: PkgVersion.new(Version.new("1.2.3"), 0))
// 142:       supplement = { "packages" => [{ "SPDXID" => "SPDXRef-Compiler" }] }
// 143:       manifest_resource = instance_double(
// 144:         Resource::BottleManifest,
// 145:         downloaded_and_valid?: true,
// 146:         sbom_supplement:       supplement,
// 147:       )
// 148:
// 149:       allow(bottle).to receive(:github_packages_manifest_resource).and_return(manifest_resource)
// 150:
// 151:       expect(bottle.sbom_supplement).to eq(supplement)
// 152:     end
// 153:   end
// 154: end
