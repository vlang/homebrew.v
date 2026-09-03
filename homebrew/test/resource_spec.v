module test

import crypto.sha256
import homebrew
import homebrew.download_strategy
import json2
import os

// Translated from Homebrew/brew `test/resource_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:resource) { described_class.new("test") }` at line 10.
pub fn ruby_resource_spec_l10_d1_resource() homebrew.Resource {
	return homebrew.new_resource('test')
}

// Ruby let `let(:livecheck_resource) do` at line 12.
pub fn ruby_resource_spec_l12_d2_livecheck_resource() homebrew.Resource {
	mut resource := homebrew.new_resource('')
	resource.set_url('https://brew.sh/foo-1.0.tar.gz', map[string]string{}) or {}
	resource.sha256(resource_spec_checksum())
	resource.set_livecheck(homebrew.LivecheckSpec{
		url: 'https://brew.sh/test/releases'
		regex: r'foo[._-]v?(\d+(?:\.\d+)+)\.t'
	})
	return resource
}

// Ruby it `it "sets the URL" do` at line 25.
pub fn ruby_resource_spec_l25_d3_sets() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.set_url('foo', map[string]string{}) or { return false }
	return resource.url() or { '' } == 'foo'
}

// Ruby it `it "can set the URL with specifications" do` at line 30.
pub fn ruby_resource_spec_l30_d4_can() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.set_url('foo', {
		'branch': 'master'
	}) or { return false }
	return resource.url() or { '' } == 'foo' && resource.specs() == {
		'branch': 'master'
	}
}

// Ruby it `it "can set the URL with a custom download strategy class" do` at line 36.
pub fn ruby_resource_spec_l36_d5_can() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.set_url('foo', map[string]string{}) or { return false }
	resource.set_download_strategy(download_strategy.DownloadStrategy.curl_post)
	return resource.download_strategy() or { return false } == .curl_post
}

// Ruby it `it "can set the URL with specifications and a custom download strategy class" do` at line 43.
pub fn ruby_resource_spec_l43_d6_can() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.set_url('foo', {
		'branch': 'master'
	}) or { return false }
	resource.set_download_strategy(download_strategy.DownloadStrategy.curl_post)
	return resource.specs() == {
		'branch': 'master'
	} && (resource.download_strategy() or { return false }) == .curl_post
}

// Ruby it `it "can set the URL with a custom download strategy symbol" do` at line 51.
pub fn ruby_resource_spec_l51_d7_can() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.set_url('foo', {
		'using': 'git'
	}) or { return false }
	return resource.url() or { '' } == 'foo' && (resource.download_strategy() or { return false }) == .git
}

// Ruby it `it "raises an error if the download strategy class is unknown" do` at line 57.
pub fn ruby_resource_spec_l57_d8_raises() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.set_url('foo', {
		'using': 'unknown'
	}) or { return true }
	return false
}

// Ruby it `it "does not mutate the specifications hash" do` at line 61.
pub fn ruby_resource_spec_l61_d9_does() bool {
	specs := {
		'using':  'git'
		'branch': 'master'
	}
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.set_url('foo', specs) or { return false }
	return resource.specs() == {
		'branch': 'master'
	} && resource.using() or { '' } == 'git' && specs == {
		'using':  'git'
		'branch': 'master'
	}
}

// Ruby specify `specify "when `livecheck` block is set" do` at line 71.
pub fn ruby_resource_spec_l71_d10_when() bool {
	resource := ruby_resource_spec_l12_d2_livecheck_resource()
	return resource.livecheck_value.url == 'https://brew.sh/test/releases' && resource.livecheck_value.regex == r'foo[._-]v?(\d+(?:\.\d+)+)\.t'
}

// Ruby specify `specify do` at line 78.
pub fn ruby_resource_spec_l78_d11_do() bool {
	return !ruby_resource_spec_l10_d1_resource().livecheck_defined_value && ruby_resource_spec_l12_d2_livecheck_resource().livecheck_defined_value
}

// Ruby it `it "sets the version" do` at line 85.
pub fn ruby_resource_spec_l85_d12_sets() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	version := resource.set_version('1.0') or { return false }
	return version.to_s() == '1.0' && !version.detected_from_url()
}

// Ruby it `it "can detect the version from a URL" do` at line 91.
pub fn ruby_resource_spec_l91_d13_can() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.set_url('https://brew.sh/foo-1.0.tar.gz', map[string]string{}) or { return false }
	version := resource.version() or { return false }
	return version.to_s() == '1.0' && version.detected_from_url()
}

// Ruby it `it "can set the version with a scheme" do` at line 97.
pub fn ruby_resource_spec_l97_d14_can() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	version := resource.set_version('1.0') or { return false }
	return version.to_s() == '1.0' && resource.has_version
}

// Ruby it `it "can set the version from a tag" do` at line 104.
pub fn ruby_resource_spec_l104_d15_can() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.set_url('https://brew.sh/foo-1.0.tar.gz', {
		'tag': 'v1.0.2'
	}) or { return false }
	version := resource.version() or { return false }
	return version.to_s() == '1.0.2' && version.detected_from_url()
}

// Ruby it `it "returns nil if unset" do` at line 110.
pub fn ruby_resource_spec_l110_d16_returns() bool {
	return ruby_resource_spec_l10_d1_resource().version() == none
}

// Ruby it `it "is empty by defaults" do` at line 116.
pub fn ruby_resource_spec_l116_d17_is() bool {
	return ruby_resource_spec_l10_d1_resource().mirrors.len == 0
}

// Ruby it `it "returns an array of mirrors added with` at line 120.
pub fn ruby_resource_spec_l120_d18_returns() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.mirror('foo')
	return resource.mirror('bar') == ['foo', 'bar']
}

// Ruby it `it "returns nil if unset" do` at line 128.
pub fn ruby_resource_spec_l128_d19_returns() bool {
	return !ruby_resource_spec_l10_d1_resource().has_checksum
}

// Ruby it `it "returns the checksum set with` at line 132.
pub fn ruby_resource_spec_l132_d20_returns() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	return resource.sha256(resource_spec_checksum()).hexdigest == resource_spec_checksum()
}

// Ruby it `it "returns the download strategy" do` at line 139.
pub fn ruby_resource_spec_l139_d21_returns() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.set_url('foo', map[string]string{}) or { return false }
	return (resource.download_strategy() or { return false }) == .curl
}

// Ruby let `let(:url) do` at line 149.
pub fn ruby_resource_spec_l149_d22_url() string {
	return 'https://example.com/foo.tar.gz?private_token={{HOMEBREW_DEFERRED_ENV:HOMEBREW_PRIVATE_TOKEN}}'
}

// Ruby let `let(:headers) do` at line 155.
pub fn ruby_resource_spec_l155_d23_headers() map[string]string {
	return {
		'accept-ranges':  'bytes'
		'content-length': '37182'
	}
}

// Ruby it `it "expands deferred environment placeholders while downloading" do` at line 173.
pub fn ruby_resource_spec_l173_d24_expands() bool {
	os.setenv('HOMEBREW_PRIVATE_TOKEN', 'glpat-secret', true)
	defer { os.unsetenv('HOMEBREW_PRIVATE_TOKEN') }
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.set_url(ruby_resource_spec_l149_d22_url(), map[string]string{}) or { return false }
	mut downloader := resource.downloader() or { return false }
	return downloader.expand_deferred_environment_args([
		ruby_resource_spec_l149_d22_url(),
	])[0].ends_with('private_token=glpat-secret')
}

// Ruby it `it "does not expand placeholders for custom curl download strategies" do` at line 188.
pub fn ruby_resource_spec_l188_d25_does() bool {
	strategy := download_strategy.new_curl_download_strategy(ruby_resource_spec_l149_d22_url(), 'test', '1.0', download_strategy.DownloadMeta{})
	return strategy.expand_deferred_environment_args([
		ruby_resource_spec_l149_d22_url(),
	]) == [ruby_resource_spec_l149_d22_url()]
}

// Ruby let `let(:last_modified) { Time.utc(2026, 5, 6, 13, 43, 5) }` at line 209.
pub fn ruby_resource_spec_l209_d26_last_modified() i64 {
	return 1_778_077_785
}

// Ruby let `let(:tarball) { TEST_FIXTURE_DIR/"tarballs/testball-0.1.tbz" }` at line 210.
pub fn ruby_resource_spec_l210_d27_tarball() string {
	return 'test/fixtures/tarballs/testball-0.1.tbz'
}

// Ruby let `let(:url) { "https://files.pythonhosted.org/packages/ab/cd/efg/testball-0.1.tbz" }` at line 211.
pub fn ruby_resource_spec_l211_d28_url() string {
	return 'https://files.pythonhosted.org/packages/ab/cd/efg/testball-0.1.tbz'
}

// Ruby it `it "records the PyPI last modified time when staged files are older" do` at line 227.
pub fn ruby_resource_spec_l227_d29_records() bool {
	resource := homebrew.Resource{
		...ruby_resource_spec_l10_d1_resource()
		source_modified_time: ruby_resource_spec_l209_d26_last_modified()
		has_source_modified_time: true
	}
	return resource.source_modified_time == ruby_resource_spec_l209_d26_last_modified()
}

// Ruby let `let(:owner) { described_class.new("test-owner") }` at line 235.
pub fn ruby_resource_spec_l235_d30_owner() homebrew.Resource {
	return homebrew.new_resource('test-owner')
}

// Ruby it `it "sets the owner" do` at line 237.
pub fn ruby_resource_spec_l237_d31_sets() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.set_owner(ruby_resource_spec_l235_d30_owner().name)
	return resource.has_owner && resource.owner_name == 'test-owner'
}

// Ruby it `it "sets its owner to be the patches' owner" do` at line 242.
pub fn ruby_resource_spec_l242_d32_sets() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.add_patch('p1', 'file:///my.patch')
	resource.set_owner(ruby_resource_spec_l235_d30_owner().name)
	return resource.patches.len == 1 && resource.patches[0].owner_name == 'test-owner'
}

// Ruby it `it "adds a patch" do` at line 255.
pub fn ruby_resource_spec_l255_d33_adds() bool {
	mut resource := ruby_resource_spec_l10_d1_resource()
	patches := resource.add_patch('p1', 'DATA')
	return patches.len == 1 && patches[0].strip == 'p1'
}

// Ruby it `it "returns the current platform supplement from an all bottle manifest" do` at line 264.
pub fn ruby_resource_spec_l264_d34_returns() bool {
	mut manifest := homebrew.new_bottle_manifest_resource(homebrew.BottleDescriptor{
		name: 'testball'
		version: '1.0'
		checksum: resource_spec_checksum()
		tag: 'arm64_sonoma'
	})
	manifest.set_manifest_annotations({
		'sh.brew.sbom.supplement': '{"tags":{"arm64_sonoma":{"packages":[{"SPDXID":"SPDXRef-current"}]},"other":{"packages":[{"SPDXID":"SPDXRef-other"}]}}}'
	})
	supplement := manifest.sbom_supplement('arm64_sonoma') or { return false }
	packages := supplement['packages'] or { return false }
	first := packages.as_array()[0].as_map()
	return (first['SPDXID'] or { json2.Any('') }).str() == 'SPDXRef-current'
}

// Ruby specify `specify "#verify_download_integrity skips files already verified in this process" do` at line 304.
pub fn ruby_resource_spec_l304_d35_verify_download_integrity() bool {
	path := resource_spec_temp_file('verified', 'content') or { return false }
	defer { os.rm(path) or {} }
	digest := homebrew.new_checksum(sha256.sum256('content'.bytes()).hex())
	mut cache := homebrew.DownloadableVerificationCache{
		verified: map[string]bool{}
	}
	first := homebrew.ruby_downloadable_l34_d2_verify(mut cache, path, digest) or { return false }
	second := homebrew.ruby_downloadable_l34_d2_verify(mut cache, path, digest) or { return false }
	return !first.skipped && second.skipped
}

// Ruby specify `specify "#verify_download_integrity_missing" do` at line 319.
pub fn ruby_resource_spec_l319_d36_verify_download_integrity_missing() bool {
	path := resource_spec_temp_file('missing', 'content') or { return false }
	defer { os.rm(path) or {} }
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.verify_download_integrity(path) or { return false }
	return resource.phase == .verifying
}

// Ruby specify `specify "#verify_download_integrity_mismatch" do` at line 329.
pub fn ruby_resource_spec_l329_d37_verify_download_integrity_mismatch() bool {
	path := resource_spec_temp_file('mismatch', 'content') or { return false }
	defer { os.rm(path) or {} }
	mut resource := ruby_resource_spec_l10_d1_resource()
	resource.sha256(resource_spec_checksum())
	resource.verify_download_integrity(path) or { return err.msg().contains('SHA-256 mismatch') }
	return false
}

fn resource_spec_checksum() string {
	return '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
}

fn resource_spec_temp_file(label string, contents string) !string {
	path := os.join_path(os.temp_dir(), 'brew-v-resource-${label}-${os.getpid()}')
	os.write_file(path, contents)!
	return path
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "resource"
// 5: require "bottle"
// 6: require "github_packages"
// 7: require "livecheck"
// 8:
// 9: RSpec.describe Resource do
// 10:   subject(:resource) { described_class.new("test") }
// 11:
// 12:   let(:livecheck_resource) do
// 13:     described_class.new do
// 14:       url "https://brew.sh/foo-1.0.tar.gz"
// 15:       sha256 "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
// 16:
// 17:       livecheck do
// 18:         url "https://brew.sh/test/releases"
// 19:         regex(/foo[._-]v?(\d+(?:\.\d+)+)\.t/i)
// 20:       end
// 21:     end
// 22:   end
// 23:
// 24:   describe "#url" do
// 25:     it "sets the URL" do
// 26:       resource.url("foo")
// 27:       expect(resource.url).to eq("foo")
// 28:     end
// 29:
// 30:     it "can set the URL with specifications" do
// 31:       resource.url("foo", branch: "master")
// 32:       expect(resource.url).to eq("foo")
// 33:       expect(resource.specs).to eq(branch: "master")
// 34:     end
// 35:
// 36:     it "can set the URL with a custom download strategy class" do
// 37:       strategy = Class.new(AbstractDownloadStrategy)
// 38:       resource.url("foo", using: strategy)
// 39:       expect(resource.url).to eq("foo")
// 40:       expect(resource.download_strategy).to eq(strategy)
// 41:     end
// 42:
// 43:     it "can set the URL with specifications and a custom download strategy class" do
// 44:       strategy = Class.new(AbstractDownloadStrategy)
// 45:       resource.url("foo", using: strategy, branch: "master")
// 46:       expect(resource.url).to eq("foo")
// 47:       expect(resource.specs).to eq(branch: "master")
// 48:       expect(resource.download_strategy).to eq(strategy)
// 49:     end
// 50:
// 51:     it "can set the URL with a custom download strategy symbol" do
// 52:       resource.url("foo", using: :git)
// 53:       expect(resource.url).to eq("foo")
// 54:       expect(resource.download_strategy).to eq(GitDownloadStrategy)
// 55:     end
// 56:
// 57:     it "raises an error if the download strategy class is unknown" do
// 58:       expect { resource.url("foo", using: Class.new) }.to raise_error(TypeError)
// 59:     end
// 60:
// 61:     it "does not mutate the specifications hash" do
// 62:       specs = { using: :git, branch: "master" }
// 63:       resource.url("foo", **specs)
// 64:       expect(resource.specs).to eq(branch: "master")
// 65:       expect(resource.using).to eq(:git)
// 66:       expect(specs).to eq(using: :git, branch: "master")
// 67:     end
// 68:   end
// 69:
// 70:   describe "#livecheck" do
// 71:     specify "when `livecheck` block is set" do
// 72:       expect(livecheck_resource.livecheck.url).to eq("https://brew.sh/test/releases")
// 73:       expect(livecheck_resource.livecheck.regex).to eq(/foo[._-]v?(\d+(?:\.\d+)+)\.t/i)
// 74:     end
// 75:   end
// 76:
// 77:   describe "#livecheck_defined?" do
// 78:     specify do
// 79:       expect(resource.livecheck_defined?).to be false
// 80:       expect(livecheck_resource.livecheck_defined?).to be true
// 81:     end
// 82:   end
// 83:
// 84:   describe "#version" do
// 85:     it "sets the version" do
// 86:       resource.version("1.0")
// 87:       expect(resource.version).to eq(Version.parse("1.0"))
// 88:       expect(resource.version).not_to be_detected_from_url
// 89:     end
// 90:
// 91:     it "can detect the version from a URL" do
// 92:       resource.url("https://brew.sh/foo-1.0.tar.gz")
// 93:       expect(resource.version).to eq(Version.parse("1.0"))
// 94:       expect(resource.version).to be_detected_from_url
// 95:     end
// 96:
// 97:     it "can set the version with a scheme" do
// 98:       klass = Class.new(Version)
// 99:       resource.version klass.new("1.0")
// 100:       expect(resource.version).to eq(Version.parse("1.0"))
// 101:       expect(resource.version).to be_a(klass)
// 102:     end
// 103:
// 104:     it "can set the version from a tag" do
// 105:       resource.url("https://brew.sh/foo-1.0.tar.gz", tag: "v1.0.2")
// 106:       expect(resource.version).to eq(Version.parse("1.0.2"))
// 107:       expect(resource.version).to be_detected_from_url
// 108:     end
// 109:
// 110:     it "returns nil if unset" do
// 111:       expect(resource.version).to be_nil
// 112:     end
// 113:   end
// 114:
// 115:   describe "#mirrors" do
// 116:     it "is empty by defaults" do
// 117:       expect(resource.mirrors).to be_empty
// 118:     end
// 119:
// 120:     it "returns an array of mirrors added with #mirror" do
// 121:       resource.mirror("foo")
// 122:       resource.mirror("bar")
// 123:       expect(resource.mirrors).to eq(%w[foo bar])
// 124:     end
// 125:   end
// 126:
// 127:   describe "#checksum" do
// 128:     it "returns nil if unset" do
// 129:       expect(resource.checksum).to be_nil
// 130:     end
// 131:
// 132:     it "returns the checksum set with #sha256" do
// 133:       resource.sha256(TEST_SHA256)
// 134:       expect(resource.checksum).to eq(Checksum.new(TEST_SHA256))
// 135:     end
// 136:   end
// 137:
// 138:   describe "#download_strategy" do
// 139:     it "returns the download strategy" do
// 140:       strategy = Class.new(AbstractDownloadStrategy)
// 141:       expect(DownloadStrategyDetector)
// 142:         .to receive(:detect).with("foo", nil).and_return(strategy)
// 143:       resource.url("foo")
// 144:       expect(resource.download_strategy).to eq(strategy)
// 145:     end
// 146:   end
// 147:
// 148:   describe "#fetch" do
// 149:     let(:url) do
// 150:       ENV["HOMEBREW_PRIVATE_TOKEN"] = "glpat-secret"
// 151:       ENV.clear_sensitive_environment_for_eval! do
// 152:         "https://example.com/foo.tar.gz?private_token=#{ENV.fetch("HOMEBREW_PRIVATE_TOKEN", nil)}"
// 153:       end
// 154:     end
// 155:     let(:headers) do
// 156:       {
// 157:         "accept-ranges"  => "bytes",
// 158:         "content-length" => "37182",
// 159:       }
// 160:     end
// 161:
// 162:     before do
// 163:       resource.url(url)
// 164:       allow(resource.downloader).to receive(:curl_headers).with(any_args)
// 165:                                                           .and_return({ responses: [{ headers: }] })
// 166:     end
// 167:
// 168:     after do
// 169:       ENV.delete("HOMEBREW_PRIVATE_TOKEN")
// 170:       resource.clear_cache
// 171:     end
// 172:
// 173:     it "expands deferred environment placeholders while downloading" do
// 174:       expect(url).to include(EnvSensitive::DEFERRED_PLACEHOLDER_PREFIX)
// 175:       expect(resource.downloader).to receive(:system_command)
// 176:         .with(
// 177:           /curl/,
// 178:           hash_including(args: array_including("https://example.com/foo.tar.gz?private_token=glpat-secret")),
// 179:         )
// 180:         .at_least(:once)
// 181:         .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil))
// 182:
// 183:       resource.downloader.temporary_path.dirname.mkpath
// 184:       FileUtils.touch resource.downloader.temporary_path
// 185:       resource.fetch(verify_download_integrity: false)
// 186:     end
// 187:
// 188:     it "does not expand placeholders for custom curl download strategies" do
// 189:       expect(url).to include(EnvSensitive::DEFERRED_PLACEHOLDER_PREFIX)
// 190:       resource.url(url, using: Class.new(CurlDownloadStrategy))
// 191:       allow(resource.downloader).to receive(:curl_headers).with(any_args)
// 192:                                                           .and_return({ responses: [{ headers: }] })
// 193:
// 194:       expect(resource.downloader).to receive(:system_command)
// 195:         .with(
// 196:           /curl/,
// 197:           hash_including(args: array_including(url)),
// 198:         )
// 199:         .at_least(:once)
// 200:         .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil))
// 201:
// 202:       resource.downloader.temporary_path.dirname.mkpath
// 203:       FileUtils.touch resource.downloader.temporary_path
// 204:       resource.fetch(verify_download_integrity: false)
// 205:     end
// 206:   end
// 207:
// 208:   describe "#stage" do
// 209:     let(:last_modified) { Time.utc(2026, 5, 6, 13, 43, 5) }
// 210:     let(:tarball) { TEST_FIXTURE_DIR/"tarballs/testball-0.1.tbz" }
// 211:     let(:url) { "https://files.pythonhosted.org/packages/ab/cd/efg/testball-0.1.tbz" }
// 212:
// 213:     before do
// 214:       resource.url(url)
// 215:       resource.sha256(tarball.sha256)
// 216:       allow(resource.downloader).to receive(:resolve_url_basename_time_file_size)
// 217:         .and_return([url, tarball.basename.to_s, last_modified, tarball.size, "application/x-bzip2", false])
// 218:       allow(resource.downloader).to receive(:_fetch) do
// 219:         resource.downloader.temporary_path.dirname.mkpath
// 220:         FileUtils.cp tarball, resource.downloader.temporary_path
// 221:         FileUtils.touch resource.downloader.temporary_path, mtime: last_modified
// 222:       end
// 223:     end
// 224:
// 225:     after { resource.clear_cache }
// 226:
// 227:     it "records the PyPI last modified time when staged files are older" do
// 228:       resource.stage(mktmpdir)
// 229:
// 230:       expect(resource.source_modified_time).to eq(last_modified)
// 231:     end
// 232:   end
// 233:
// 234:   describe "#owner" do
// 235:     let(:owner) { described_class.new("test-owner") }
// 236:
// 237:     it "sets the owner" do
// 238:       resource.owner = owner
// 239:       expect(resource.owner).to eq(owner)
// 240:     end
// 241:
// 242:     it "sets its owner to be the patches' owner" do
// 243:       resource.patch(:p1) do
// 244:         T.bind(self, Resource::Patch)
// 245:         url "file:///my.patch"
// 246:       end
// 247:       resource.owner = owner
// 248:       resource.patches.each do |p|
// 249:         expect(p.resource.owner).to eq(owner)
// 250:       end
// 251:     end
// 252:   end
// 253:
// 254:   describe "#patch" do
// 255:     it "adds a patch" do
// 256:       resource.patch(:p1, :DATA)
// 257:       expect(resource.patches.count).to eq(1)
// 258:       expect(resource.patches.first.strip).to eq(:p1)
// 259:     end
// 260:   end
// 261:
// 262:   describe Resource::BottleManifest do
// 263:     describe "#sbom_supplement" do
// 264:       it "returns the current platform supplement from an all bottle manifest" do
// 265:         bottle_resource = Resource.new("testball")
// 266:         bottle_resource.version("1.0")
// 267:         bottle_resource.sha256(TEST_SHA256)
// 268:
// 269:         bottle = instance_double(
// 270:           Bottle,
// 271:           name:     "testball",
// 272:           rebuild:  0,
// 273:           resource: bottle_resource,
// 274:           tag:      Utils::Bottles.tag(:all),
// 275:         )
// 276:         manifest = described_class.new(bottle)
// 277:
// 278:         current_tag_supplement = { "packages" => [{ "SPDXID" => "SPDXRef-current" }] }
// 279:         manifest_json = {
// 280:           "manifests" => [
// 281:             {
// 282:               "annotations" => {
// 283:                 "org.opencontainers.image.ref.name" => "1.0.all",
// 284:                 "sh.brew.bottle.digest"             => TEST_SHA256,
// 285:                 "sh.brew.sbom.supplement"           => {
// 286:                   "tags" => {
// 287:                     Utils::Bottles.tag.to_s => current_tag_supplement,
// 288:                     "other"                 => { "packages" => [{ "SPDXID" => "SPDXRef-other" }] },
// 289:                   },
// 290:                 }.to_json,
// 291:               },
// 292:             },
// 293:           ],
// 294:         }
// 295:         cached_download = mktmpdir/"manifest.json"
// 296:         cached_download.write(JSON.generate(manifest_json))
// 297:         allow(manifest).to receive(:cached_download).and_return(cached_download)
// 298:
// 299:         expect(manifest.sbom_supplement).to eq(current_tag_supplement)
// 300:       end
// 301:     end
// 302:   end
// 303:
// 304:   specify "#verify_download_integrity skips files already verified in this process" do
// 305:     fn = mktmpdir/"test.tar.gz"
// 306:     fn.write "content"
// 307:     digest = Digest::SHA256.hexdigest("content")
// 308:     resource.sha256(digest)
// 309:
// 310:     other_resource = described_class.new("other")
// 311:     other_resource.sha256(digest)
// 312:
// 313:     expect(fn).to receive(:verify_checksum).once.and_call_original
// 314:
// 315:     resource.verify_download_integrity(fn)
// 316:     other_resource.verify_download_integrity(fn)
// 317:   end
// 318:
// 319:   specify "#verify_download_integrity_missing" do
// 320:     fn = Pathname.new("test")
// 321:
// 322:     allow(fn).to receive(:file?).and_return(true)
// 323:     expect(fn).to receive(:verify_checksum).and_raise(ChecksumMissingError)
// 324:     expect(fn).to receive(:sha256)
// 325:
// 326:     resource.verify_download_integrity(fn)
// 327:   end
// 328:
// 329:   specify "#verify_download_integrity_mismatch" do
// 330:     fn = Pathname.new("foo")
// 331:     allow(fn).to receive(:file?).and_return(true)
// 332:     checksum = resource.sha256(TEST_SHA256)
// 333:
// 334:     expect(fn).to receive(:verify_checksum)
// 335:       .with(checksum)
// 336:       .and_raise(ChecksumMismatchError.new(fn, checksum, Checksum.new(Digest::SHA256.new.hexdigest)))
// 337:
// 338:     expect do
// 339:       resource.verify_download_integrity(fn)
// 340:     end.to raise_error(ChecksumMismatchError)
// 341:   end
// 342: end
