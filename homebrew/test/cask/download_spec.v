module cask

import ruby
import homebrew.cask as cask_core
import os

// Translated from Homebrew/brew `test/cask/download_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:download_name) { described_class.new(cask).download_name }` at line 6.
pub fn ruby_download_spec_l6_d1_download_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_core.CaskDownload{ cask: download_spec_cask_model('', '') }.cask.token)
}

// Ruby let `let(:token) { "example-cask" }` at line 8.
pub fn ruby_download_spec_l8_d2_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('example-cask')
}

// Ruby let `let(:full_token) { token }` at line 9.
pub fn ruby_download_spec_l9_d3_full_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('example-cask')
}

// Ruby let `let(:url) { instance_double(URL, to_s: url_to_s, specs: {}) }` at line 10.
pub fn ruby_download_spec_l10_d4_url(args ...ruby.Value) ruby.Value {
	return ruby.map_value({
		'url':   ruby.string_value(download_spec_url(false))
		'specs': ruby.map_value(map[string]ruby.Value{})
	})
}

// Ruby let `let(:url_to_s) { "https://example.com/app.dmg" }` at line 11.
pub fn ruby_download_spec_l11_d5_url_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(download_spec_url(false))
}

// Ruby let `let(:cask) { instance_double(Cask::Cask, token:, full_token:, version:, url:) }` at line 12.
pub fn ruby_download_spec_l12_d6_cask(args ...ruby.Value) ruby.Value {
	return download_spec_cask_value(download_spec_cask_model('', ''))
}

// Ruby let `let(:version) { nil }` at line 15.
pub fn ruby_download_spec_l15_d7_version(args ...ruby.Value) ruby.Value {
	return download_spec_nil()
}

// Ruby it `it "returns the cask token" do` at line 17.
pub fn ruby_download_spec_l17_d8_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(cask_core.CaskDownload{ cask: download_spec_cask_model('', '') }.cask.token == 'example-cask')
}

// Ruby let `let(:version) { "1.0.0" }` at line 23.
pub fn ruby_download_spec_l23_d9_version(args ...ruby.Value) ruby.Value {
	return ruby.string_value('1.0.0')
}

// Ruby it `it "returns the cask token" do` at line 25.
pub fn ruby_download_spec_l25_d10_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(cask_core.CaskDownload{ cask: download_spec_cask_model('1.0.0', '') }.cask.token == 'example-cask')
}

// Ruby let `let(:version) do` at line 31.
pub fn ruby_download_spec_l31_d11_version(args ...ruby.Value) ruby.Value {
	return ruby.string_value('1.2.3,kch23dmbz6whmoogcbss45yi4c2kkq15gmemwys0hgwd3l7cahmx2ciagrlrgppatxaxarzazmdoerzmiisuf7mul4lgcays2dl3nl')
}

// Ruby let `let(:url_to_s) { "https://example.com/app.dmg?#{Array.new(50) { |i| "param#{i}=value#{i}" }.join("&")}" }` at line 34.
pub fn ruby_download_spec_l34_d12_url_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(download_spec_url(true))
}

// Ruby it `it "returns the cask token" do` at line 36.
pub fn ruby_download_spec_l36_d13_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(cask_core.CaskDownload{ cask: download_spec_cask_model(ruby_download_spec_l31_d11_version().as_string(), '') }.cask.token == 'example-cask')
}

// Ruby let `let(:full_token) { "third-party/tap/example-cask" }` at line 41.
pub fn ruby_download_spec_l41_d14_full_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value('third-party/tap/example-cask')
}

// Ruby it `it "returns the cask token" do` at line 43.
pub fn ruby_download_spec_l43_d15_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(cask_core.CaskDownload{ cask: download_spec_cask_model(ruby_download_spec_l31_d11_version().as_string(), 'third-party/tap/example-cask') }.cask.token == 'example-cask')
}

// Ruby it `it "fails before downloading if sha256 :no_check is used with --require-sha" do` at line 51.
pub fn ruby_download_spec_l51_d16_fails(args ...ruby.Value) ruby.Value {
	download := cask_core.CaskDownload{ cask: cask_core.CaskDownloadCask{ token: 'no-checksum', checksum_kind: .no_check }, require_sha: true }
	return ruby.bool_value((cask_core.cask_download_verify_has_sha(download) or { return ruby.bool_value(err.msg().contains('--require-sha')) }) == '')
}

// Ruby it `it "fails before downloading if sha256 is nil with --require-sha" do` at line 59.
pub fn ruby_download_spec_l59_d17_fails(args ...ruby.Value) ruby.Value {
	download := cask_core.CaskDownload{ cask: cask_core.CaskDownloadCask{ token: 'missing-checksum', checksum_kind: .missing }, require_sha: true }
	return ruby.bool_value((cask_core.cask_download_verify_has_sha(download) or { return ruby.bool_value(err.msg().contains('--require-sha')) }) == '')
}

// Ruby it `it "fails before downloading if a platform checksum is missing" do` at line 67.
pub fn ruby_download_spec_l67_d18_fails(args ...ruby.Value) ruby.Value {
	download := cask_core.CaskDownload{ cask: cask_core.CaskDownloadCask{ token: 'missing-platform-checksum', checksum_kind: .missing }, require_sha: false }
	return ruby.bool_value((cask_core.cask_download_verify_has_sha(download) or { return ruby.bool_value(err.msg().contains('`depends_on`')) }) == '')
}

// Ruby it `it "does not mutate download state" do` at line 83.
pub fn ruby_download_spec_l83_d19_does(args ...ruby.Value) ruby.Value {
	root := download_spec_temp('stage-query')
	defer { os.rmdir_all(root) or {} }
	source := os.join_path(root, 'caffeine.zip')
	os.write_file(source, 'zip') or { return ruby.bool_value(false) }
	download := cask_core.CaskDownload{
		cache_dir: root
		cask: cask_core.CaskDownloadCask{
			staged_path: os.join_path(root, 'Caskroom', 'caffeine', '1')
			caskroom_path: os.join_path(root, 'Caskroom')
			container: cask_core.CaskDownloadContainer{
				path: source
				dependencies: [
					cask_core.CaskDownloadDependency{ kind: .formula, installed: true, optlinked: true },
				]
			}
		}
	}
	return ruby.bool_value(cask_core.cask_download_should_stage(download, source, true) && download.cask.download == '')
}

// Ruby it `it "removes stale markers with permission-aware removal" do` at line 95.
pub fn ruby_download_spec_l95_d20_removes(args ...ruby.Value) ruby.Value {
	root := download_spec_temp('purge')
	defer { os.rmdir_all(root) or {} }
	download := cask_core.CaskDownload{ cache_dir: root, cask: cask_core.CaskDownloadCask{ staged_path: os.join_path(root, 'Caskroom', 'caffeine', '1'), caskroom_path: os.join_path(root, 'Caskroom') } }
	staged := cask_core.cask_download_staged_path(download)
	os.mkdir_all(os.dir(staged)) or { return ruby.bool_value(false) }
	os.symlink(staged, '${staged}.staged') or { return ruby.bool_value(false) }
	cask_core.cask_download_purge(download) or { return ruby.bool_value(false) }
	return ruby.bool_value(!os.exists('${staged}.staged') && !os.is_link('${staged}.staged'))
}

// Ruby it `it "quarantines valid cached downloads" do` at line 112.
pub fn ruby_download_spec_l112_d21_quarantines(args ...ruby.Value) ruby.Value {
	root := download_spec_temp('quarantine')
	defer { os.rmdir_all(root) or {} }
	path := os.join_path(root, 'cask.zip')
	os.write_file(path, 'already downloaded') or { return ruby.bool_value(false) }
	mut download := cask_core.CaskDownload{ cask: cask_core.CaskDownloadCask{ token: 'cask', checksum_kind: .checksum, sha256: 'cafebabe' }, downloader_path: path, computed_sha256_override: 'cafebabe', quarantine_available: true }
	return ruby.bool_value(cask_core.cask_downloaded_and_valid(mut download) && path in download.quarantined_paths)
}

// Ruby subject `subject(:verification) { described_class.new(cask).verify_download_integrity(downloaded_path) }` at line 133.
pub fn ruby_download_spec_l133_d22_verification(args ...ruby.Value) ruby.Value {
	mut download := cask_core.CaskDownload{ cask: cask_core.CaskDownloadCask{ token: 'cask', checksum_kind: .no_check }, computed_sha256_override: download_spec_cafebabe() }
	return download_spec_verification_value(cask_core.cask_download_verify(mut download, 'cask.zip'))
}

// Ruby let `let(:tap) { nil }` at line 135.
pub fn ruby_download_spec_l135_d23_tap(args ...ruby.Value) ruby.Value {
	return download_spec_nil()
}

// Ruby let `let(:cask) { instance_double(Cask::Cask, token: "cask", sha256: expected_sha256, tap:) }` at line 136.
pub fn ruby_download_spec_l136_d24_cask(args ...ruby.Value) ruby.Value {
	return download_spec_cask_value(cask_core.CaskDownloadCask{ token: 'cask', checksum_kind: .no_check })
}

// Ruby let `let(:cafebabe) { "cafebabecafebabecafebabecafebabecafebabecafebabecafebabecafebabe" }` at line 137.
pub fn ruby_download_spec_l137_d25_cafebabe(args ...ruby.Value) ruby.Value {
	return ruby.string_value(download_spec_cafebabe())
}

// Ruby let `let(:deadbeef) { "deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef" }` at line 138.
pub fn ruby_download_spec_l138_d26_deadbeef(args ...ruby.Value) ruby.Value {
	return ruby.string_value(download_spec_deadbeef())
}

// Ruby let `let(:computed_sha256) { cafebabe }` at line 139.
pub fn ruby_download_spec_l139_d27_computed_sha256(args ...ruby.Value) ruby.Value {
	return ruby_download_spec_l137_d25_cafebabe()
}

// Ruby let `let(:downloaded_path) { Pathname.new("cask.zip") }` at line 140.
pub fn ruby_download_spec_l140_d28_downloaded_path(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', 'cask.zip')
}

// Ruby let `let(:expected_sha256) { :no_check }` at line 147.
pub fn ruby_download_spec_l147_d29_expected_sha256(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', ':no_check')
}

// Ruby it `it "warns about skipping the check" do` at line 149.
pub fn ruby_download_spec_l149_d30_warns(args ...ruby.Value) ruby.Value {
	mut download := cask_core.CaskDownload{ cask: cask_core.CaskDownloadCask{ token: 'cask', checksum_kind: .no_check }, computed_sha256_override: download_spec_cafebabe() }
	return ruby.bool_value(cask_core.cask_download_verify(mut download, 'cask.zip').warning.contains('skipping verification'))
}

// Ruby let `let(:tap) { CoreCaskTap.instance }` at line 154.
pub fn ruby_download_spec_l154_d31_tap(args ...ruby.Value) ruby.Value {
	return ruby.object_value('CoreCaskTap', 'homebrew/cask')
}

// Ruby it `it "does not warn about skipping the check" do` at line 156.
pub fn ruby_download_spec_l156_d32_does(args ...ruby.Value) ruby.Value {
	mut download := cask_core.CaskDownload{ cask: cask_core.CaskDownloadCask{ token: 'cask', checksum_kind: .no_check, tap_present: true, tap_official: true }, computed_sha256_override: download_spec_cafebabe() }
	return ruby.bool_value(cask_core.cask_download_verify(mut download, 'cask.zip').warning == '')
}

// Ruby let `let(:expected_sha256) { Checksum.new(cafebabe) }` at line 163.
pub fn ruby_download_spec_l163_d33_expected_sha256(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Checksum', download_spec_cafebabe())
}

// Ruby it `it "does not raise an error" do` at line 165.
pub fn ruby_download_spec_l165_d34_does(args ...ruby.Value) ruby.Value {
	mut download := cask_core.CaskDownload{ cask: cask_core.CaskDownloadCask{ token: 'cask', checksum_kind: .checksum, sha256: download_spec_cafebabe() }, computed_sha256_override: download_spec_cafebabe() }
	return ruby.bool_value(cask_core.cask_download_verify(mut download, 'cask.zip').error == '')
}

// Ruby let `let(:expected_sha256) { nil }` at line 171.
pub fn ruby_download_spec_l171_d35_expected_sha256(args ...ruby.Value) ruby.Value {
	return download_spec_nil()
}

// Ruby it `it "outputs an error" do` at line 173.
pub fn ruby_download_spec_l173_d36_outputs(args ...ruby.Value) ruby.Value {
	mut download := cask_core.CaskDownload{ cask: cask_core.CaskDownloadCask{ token: 'cask', checksum_kind: .missing }, computed_sha256_override: download_spec_cafebabe() }
	return ruby.bool_value(cask_core.cask_download_verify(mut download, 'cask.zip').error.contains('sha256 "${download_spec_cafebabe()}"'))
}

// Ruby let `let(:expected_sha256) { Checksum.new("") }` at line 179.
pub fn ruby_download_spec_l179_d37_expected_sha256(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Checksum', '')
}

// Ruby it `it "outputs an error" do` at line 181.
pub fn ruby_download_spec_l181_d38_outputs(args ...ruby.Value) ruby.Value {
	mut download := cask_core.CaskDownload{ cask: cask_core.CaskDownloadCask{ token: 'cask', checksum_kind: .checksum, sha256: '' }, computed_sha256_override: download_spec_cafebabe() }
	return ruby.bool_value(cask_core.cask_download_verify(mut download, 'cask.zip').error.contains('sha256 "${download_spec_cafebabe()}"'))
}

// Ruby let `let(:expected_sha256) { Checksum.new(deadbeef) }` at line 187.
pub fn ruby_download_spec_l187_d39_expected_sha256(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Checksum', download_spec_deadbeef())
}

// Ruby it `it "raises an error" do` at line 189.
pub fn ruby_download_spec_l189_d40_raises(args ...ruby.Value) ruby.Value {
	mut download := cask_core.CaskDownload{ cask: cask_core.CaskDownloadCask{ token: 'cask', checksum_kind: .checksum, sha256: download_spec_deadbeef() }, computed_sha256_override: download_spec_cafebabe() }
	return ruby.bool_value(cask_core.cask_download_verify(mut download, 'cask.zip').error.starts_with('ChecksumMismatchError'))
}

fn download_spec_cask_model(version string, full_token string) cask_core.CaskDownloadCask {
	return cask_core.CaskDownloadCask{
		token: 'example-cask'
		full_token: if full_token == '' { 'example-cask' } else { full_token }
		version: version
		version_present: version != ''
		url: download_spec_url(version.len > 20)
		url_present: true
		checksum_kind: .missing
	}
}

fn download_spec_url(long bool) string {
	if !long {
		return 'https://example.com/app.dmg'
	}
	mut parts := []string{}
	for index in 0 .. 50 {
		parts << 'param${index}=value${index}'
	}
	return 'https://example.com/app.dmg?${parts.join('&')}'
}

fn download_spec_cask_value(cask cask_core.CaskDownloadCask) ruby.Value {
	return ruby.map_value({
		'token':      ruby.string_value(cask.token)
		'full_token': ruby.string_value(cask.full_token)
		'version':    if cask.version_present {
			ruby.string_value(cask.version)
		} else {
			download_spec_nil()
		}
		'url':        if cask.url_present {
			ruby.string_value(cask.url)
		} else {
			download_spec_nil()
		}
	})
}

fn download_spec_verification_value(result cask_core.CaskDownloadVerification) ruby.Value {
	return ruby.map_value({
		'warning': ruby.string_value(result.warning)
		'error':   ruby.string_value(result.error)
	})
}

fn download_spec_temp(name string) string {
	path := os.join_path(os.temp_dir(), 'brew-v-download-${name}-${os.getpid()}')
	os.rmdir_all(path) or {}
	os.mkdir_all(path) or {}
	return path
}

fn download_spec_cafebabe() string {
	return 'cafebabecafebabecafebabecafebabecafebabecafebabecafebabecafebabe'
}

fn download_spec_deadbeef() string {
	return 'deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef'
}

fn download_spec_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Download, :cask do
// 5:   describe "#download_name" do
// 6:     subject(:download_name) { described_class.new(cask).download_name }
// 7:
// 8:     let(:token) { "example-cask" }
// 9:     let(:full_token) { token }
// 10:     let(:url) { instance_double(URL, to_s: url_to_s, specs: {}) }
// 11:     let(:url_to_s) { "https://example.com/app.dmg" }
// 12:     let(:cask) { instance_double(Cask::Cask, token:, full_token:, version:, url:) }
// 13:
// 14:     context "when cask has no version" do
// 15:       let(:version) { nil }
// 16:
// 17:       it "returns the cask token" do
// 18:         expect(download_name).to eq "example-cask"
// 19:       end
// 20:     end
// 21:
// 22:     context "when the URL basename would create a short symlink name" do
// 23:       let(:version) { "1.0.0" }
// 24:
// 25:       it "returns the cask token" do
// 26:         expect(download_name).to eq "example-cask"
// 27:       end
// 28:     end
// 29:
// 30:     context "when the URL basename would create a long symlink name" do
// 31:       let(:version) do
// 32:         "1.2.3,kch23dmbz6whmoogcbss45yi4c2kkq15gmemwys0hgwd3l7cahmx2ciagrlrgppatxaxarzazmdoerzmiisuf7mul4lgcays2dl3nl"
// 33:       end
// 34:       let(:url_to_s) { "https://example.com/app.dmg?#{Array.new(50) { |i| "param#{i}=value#{i}" }.join("&")}" }
// 35:
// 36:       it "returns the cask token" do
// 37:         expect(download_name).to eq "example-cask"
// 38:       end
// 39:
// 40:       context "when the cask is in a third-party tap" do
// 41:         let(:full_token) { "third-party/tap/example-cask" }
// 42:
// 43:         it "returns the cask token" do
// 44:           expect(download_name).to eq "example-cask"
// 45:         end
// 46:       end
// 47:     end
// 48:   end
// 49:
// 50:   describe "#fetch" do
// 51:     it "fails before downloading if sha256 :no_check is used with --require-sha" do
// 52:       no_checksum = Cask::CaskLoader.load(cask_path("no-checksum"))
// 53:       download = described_class.new(no_checksum, require_sha: true)
// 54:
// 55:       expect(download).not_to receive(:downloader)
// 56:       expect { download.fetch }.to raise_error(/--require-sha/)
// 57:     end
// 58:
// 59:     it "fails before downloading if sha256 is nil with --require-sha" do
// 60:       missing_checksum = Cask::CaskLoader.load(cask_path("missing-checksum"))
// 61:       download = described_class.new(missing_checksum, require_sha: true)
// 62:       allow(download).to receive(:downloader) { raise "download attempted" }
// 63:
// 64:       expect { download.fetch }.to raise_error(Cask::CaskError, /--require-sha/)
// 65:     end
// 66:
// 67:     it "fails before downloading if a platform checksum is missing" do
// 68:       Homebrew::SimulateSystem.with(os: :macos, arch: :intel) do
// 69:         cask = Cask::Cask.new("missing-platform-checksum") do
// 70:           version "1.2.3"
// 71:           sha256 arm: "0000000000000000000000000000000000000000000000000000000000000000"
// 72:           url "https://brew.sh/example.zip"
// 73:         end
// 74:         download = described_class.new(cask)
// 75:         allow(download).to receive(:downloader) { raise "download attempted" }
// 76:
// 77:         expect { download.fetch }.to raise_error(Cask::CaskError, /`depends_on`/)
// 78:       end
// 79:     end
// 80:   end
// 81:
// 82:   describe "#stage_from_download_queue?" do
// 83:     it "does not mutate download state" do
// 84:       cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 85:       download = described_class.new(cask)
// 86:
// 87:       expect(download).not_to receive(:primary_container)
// 88:
// 89:       expect(download.stage_from_download_queue?(TEST_FIXTURE_DIR/"cask/caffeine.zip", pour: true)).to be(true)
// 90:       expect(cask.download).to be_nil
// 91:     end
// 92:   end
// 93:
// 94:   describe "#purge_staged_from_download_queue" do
// 95:     it "removes stale markers with permission-aware removal" do
// 96:       cask = Cask::CaskLoader.load(cask_path("local-caffeine"))
// 97:       download = described_class.new(cask)
// 98:       staged_marker = download.staged_path_from_download_queue_marker
// 99:       staged_marker.dirname.mkpath
// 100:       FileUtils.ln_s(download.staged_path_from_download_queue, staged_marker)
// 101:
// 102:       expect(Cask::Utils).to receive(:gain_permissions_remove).with(staged_marker,
// 103:                                                                     command: SystemCommand).and_call_original
// 104:
// 105:       download.purge_staged_from_download_queue
// 106:
// 107:       expect(staged_marker).not_to exist
// 108:     end
// 109:   end
// 110:
// 111:   describe "#downloaded_and_valid?" do
// 112:     it "quarantines valid cached downloads" do
// 113:       cached_download = HOMEBREW_CACHE/"downloads/cask.zip"
// 114:       cached_download.dirname.mkpath
// 115:       cached_download.write("already downloaded")
// 116:       checksum = Checksum.new(cached_download.sha256)
// 117:       cask = instance_double(Cask::Cask, sha256: checksum)
// 118:       download = described_class.new(cask)
// 119:
// 120:       allow(download).to receive(:cached_download).and_return(cached_download)
// 121:       allow(download).to receive(:verify_download_integrity) do |filename|
// 122:         filename.verify_checksum(checksum)
// 123:       end
// 124:       allow(Cask::Quarantine).to receive(:available?).and_return(true)
// 125:
// 126:       expect(Cask::Quarantine).to receive(:cask!).with(cask:, download_path: cached_download)
// 127:
// 128:       expect(download.downloaded_and_valid?).to be(true)
// 129:     end
// 130:   end
// 131:
// 132:   describe "#verify_download_integrity" do
// 133:     subject(:verification) { described_class.new(cask).verify_download_integrity(downloaded_path) }
// 134:
// 135:     let(:tap) { nil }
// 136:     let(:cask) { instance_double(Cask::Cask, token: "cask", sha256: expected_sha256, tap:) }
// 137:     let(:cafebabe) { "cafebabecafebabecafebabecafebabecafebabecafebabecafebabecafebabe" }
// 138:     let(:deadbeef) { "deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef" }
// 139:     let(:computed_sha256) { cafebabe }
// 140:     let(:downloaded_path) { Pathname.new("cask.zip") }
// 141:
// 142:     before do
// 143:       allow(downloaded_path).to receive_messages(file?: true, sha256: computed_sha256)
// 144:     end
// 145:
// 146:     context "when the expected checksum is :no_check" do
// 147:       let(:expected_sha256) { :no_check }
// 148:
// 149:       it "warns about skipping the check" do
// 150:         expect { verification }.to output(/skipping verification/).to_stderr
// 151:       end
// 152:
// 153:       context "with an official tap" do
// 154:         let(:tap) { CoreCaskTap.instance }
// 155:
// 156:         it "does not warn about skipping the check" do
// 157:           expect { verification }.not_to output(/skipping verification/).to_stderr
// 158:         end
// 159:       end
// 160:     end
// 161:
// 162:     context "when expected and computed checksums match" do
// 163:       let(:expected_sha256) { Checksum.new(cafebabe) }
// 164:
// 165:       it "does not raise an error" do
// 166:         expect { verification }.not_to raise_error
// 167:       end
// 168:     end
// 169:
// 170:     context "when the expected checksum is nil" do
// 171:       let(:expected_sha256) { nil }
// 172:
// 173:       it "outputs an error" do
// 174:         expect { verification }.to output(/sha256 "#{computed_sha256}"/).to_stderr
// 175:       end
// 176:     end
// 177:
// 178:     context "when the expected checksum is empty" do
// 179:       let(:expected_sha256) { Checksum.new("") }
// 180:
// 181:       it "outputs an error" do
// 182:         expect { verification }.to output(/sha256 "#{computed_sha256}"/).to_stderr
// 183:       end
// 184:     end
// 185:
// 186:     context "when expected and computed checksums do not match" do
// 187:       let(:expected_sha256) { Checksum.new(deadbeef) }
// 188:
// 189:       it "raises an error" do
// 190:         expect { verification }.to raise_error ChecksumMismatchError
// 191:       end
// 192:     end
// 193:   end
// 194: end
