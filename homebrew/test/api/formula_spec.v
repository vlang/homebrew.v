module api

import brew_runtime

// Translated from Homebrew/brew `test/api/formula_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cache_dir) { mktmpdir }` at line 8.
pub fn ruby_formula_spec_l8_d1_cache_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cache_dir', ...args)
}

// Ruby let `let(:source_cache_dir) { mktmpdir }` at line 9.
pub fn ruby_formula_spec_l9_d2_source_cache_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source_cache_dir', ...args)
}

// Ruby method `mock_curl_download(stdout:)` at line 18.
pub fn ruby_formula_spec_l18_d3_mock_curl_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mock_curl_download', ...args)
}

// Ruby let `let(:formulae_json) do` at line 28.
pub fn ruby_formula_spec_l28_d4_formulae_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formulae_json', ...args)
}

// Ruby let `let(:formulae_hash) do` at line 46.
pub fn ruby_formula_spec_l46_d5_formulae_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formulae_hash', ...args)
}

// Ruby let `let(:formulae_aliases) do` at line 57.
pub fn ruby_formula_spec_l57_d6_formulae_aliases(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formulae_aliases', ...args)
}

// Ruby it `it "returns the expected formula JSON list" do` at line 65.
pub fn ruby_formula_spec_l65_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the expected formula alias list" do` at line 71.
pub fn ruby_formula_spec_l71_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "writes formula executables from the formula JSON list" do` at line 77.
pub fn ruby_formula_spec_l77_d9_writes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('writes', ...args)
}

// Ruby it `it "removes the executables database if formula JSON has no executable entries" do` at line 84.
pub fn ruby_formula_spec_l84_d10_removes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('removes', ...args)
}

// Ruby it `it "does not download the executables database while reading formula JSON" do` at line 108.
pub fn ruby_formula_spec_l108_d11_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby let `let(:f) { Testball.new }` at line 130.
pub fn ruby_formula_spec_l130_d12_f(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('f', ...args)
}

// Ruby it `it "forces re-download when symlink_location exists but is not a symlink" do` at line 139.
pub fn ruby_formula_spec_l139_d13_forces(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('forces', ...args)
}

// Ruby it `it "skips download when symlink_location is a valid symlink" do` at line 149.
pub fn ruby_formula_spec_l149_d14_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby let `let(:f) { Testball.new }` at line 163.
pub fn ruby_formula_spec_l163_d15_f(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('f', ...args)
}

// Ruby it `it "raises CannotInstallFormulaError when source file is missing" do` at line 172.
pub fn ruby_formula_spec_l172_d16_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "loads formula from symlink_location when source file exists" do` at line 183.
pub fn ruby_formula_spec_l183_d17_loads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('loads', ...args)
}

// Ruby it `it "loads local patch files from API source cache" do` at line 199.
pub fn ruby_formula_spec_l199_d18_loads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('loads', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "api"
// 5: require "test/support/fixtures/testball"
// 6:
// 7: RSpec.describe Homebrew::API::Formula do
// 8:   let(:cache_dir) { mktmpdir }
// 9:   let(:source_cache_dir) { mktmpdir }
// 10:
// 11:   before do
// 12:     stub_const("HOMEBREW_CACHE", cache_dir)
// 13:     stub_const("Homebrew::API::HOMEBREW_CACHE_API", cache_dir)
// 14:     stub_const("Homebrew::API::HOMEBREW_CACHE_API_SOURCE", source_cache_dir)
// 15:     described_class.clear_cache
// 16:   end
// 17:
// 18:   def mock_curl_download(stdout:)
// 19:     allow(Utils::Curl).to receive(:curl_download) do |*_args, **kwargs|
// 20:       kwargs[:to].write stdout
// 21:     end
// 22:     allow(Homebrew::API).to receive(:verify_and_parse_jws) do |json_data|
// 23:       [true, json_data]
// 24:     end
// 25:   end
// 26:
// 27:   describe "::all_formulae" do
// 28:     let(:formulae_json) do
// 29:       <<~EOS
// 30:         [{
// 31:           "name": "foo",
// 32:           "url": "https://brew.sh/foo",
// 33:           "aliases": ["foo-alias1", "foo-alias2"],
// 34:           "executables": ["foo-bin", "food"]
// 35:         }, {
// 36:           "name": "bar",
// 37:           "url": "https://brew.sh/bar",
// 38:           "aliases": ["bar-alias"]
// 39:         }, {
// 40:           "name": "baz",
// 41:           "url": "https://brew.sh/baz",
// 42:           "aliases": []
// 43:         }]
// 44:       EOS
// 45:     end
// 46:     let(:formulae_hash) do
// 47:       {
// 48:         "foo" => {
// 49:           "url"         => "https://brew.sh/foo",
// 50:           "aliases"     => ["foo-alias1", "foo-alias2"],
// 51:           "executables" => ["foo-bin", "food"],
// 52:         },
// 53:         "bar" => { "url" => "https://brew.sh/bar", "aliases" => ["bar-alias"] },
// 54:         "baz" => { "url" => "https://brew.sh/baz", "aliases" => [] },
// 55:       }
// 56:     end
// 57:     let(:formulae_aliases) do
// 58:       {
// 59:         "foo-alias1" => "foo",
// 60:         "foo-alias2" => "foo",
// 61:         "bar-alias"  => "bar",
// 62:       }
// 63:     end
// 64:
// 65:     it "returns the expected formula JSON list" do
// 66:       mock_curl_download stdout: formulae_json
// 67:       formulae_output = described_class.all_formulae
// 68:       expect(formulae_output).to eq formulae_hash
// 69:     end
// 70:
// 71:     it "returns the expected formula alias list" do
// 72:       mock_curl_download stdout: formulae_json
// 73:       aliases_output = described_class.all_aliases
// 74:       expect(aliases_output).to eq formulae_aliases
// 75:     end
// 76:
// 77:     it "writes formula executables from the formula JSON list" do
// 78:       mock_curl_download stdout: formulae_json
// 79:       described_class.write_names_and_aliases
// 80:
// 81:       expect((cache_dir/"internal/executables.txt").read).to eq("foo:foo-bin food\n")
// 82:     end
// 83:
// 84:     it "removes the executables database if formula JSON has no executable entries" do
// 85:       allow(Utils::Curl).to receive(:curl_download) do |*args, **kwargs|
// 86:         raise "unexpected download URL: #{args.last}" unless args.last.end_with?("formula.jws.json")
// 87:
// 88:         kwargs[:to].write <<~JSON
// 89:           [{
// 90:             "name": "foo",
// 91:             "url": "https://brew.sh/foo",
// 92:             "aliases": []
// 93:           }]
// 94:         JSON
// 95:       end
// 96:       expect(Homebrew::API).not_to receive(:download_executables_file_from_github_packages!)
// 97:       allow(Homebrew::API).to receive(:verify_and_parse_jws) do |json_data|
// 98:         [true, json_data]
// 99:       end
// 100:       (cache_dir/"internal").mkpath
// 101:       (cache_dir/"internal/executables.txt").write "foo:foo-bin\n"
// 102:
// 103:       described_class.write_names_and_aliases
// 104:
// 105:       expect(cache_dir/"internal/executables.txt").not_to exist
// 106:     end
// 107:
// 108:     it "does not download the executables database while reading formula JSON" do
// 109:       allow(Utils::Curl).to receive(:curl_download) do |*args, **kwargs|
// 110:         raise "unexpected download URL: #{args.last}" unless args.last.end_with?("formula.jws.json")
// 111:
// 112:         kwargs[:to].write <<~JSON
// 113:           [{
// 114:             "name": "foo",
// 115:             "url": "https://brew.sh/foo",
// 116:             "aliases": []
// 117:           }]
// 118:         JSON
// 119:       end
// 120:       allow(Homebrew::API).to receive(:verify_and_parse_jws) do |json_data|
// 121:         [true, json_data]
// 122:       end
// 123:
// 124:       expect(described_class.all_formulae).to eq("foo" => { "url" => "https://brew.sh/foo", "aliases" => [] })
// 125:       expect(cache_dir/"internal/executables.txt").not_to exist
// 126:     end
// 127:   end
// 128:
// 129:   describe "::source_download" do
// 130:     let(:f) { Testball.new }
// 131:
// 132:     before do
// 133:       allow(Homebrew::API).to receive(:formula_names).and_return([])
// 134:       allow(f).to receive_messages(ruby_source_path: "Formula/testball.rb", tap_git_head: "abc123",
// 135:                                    ruby_source_checksum: nil)
// 136:       allow(f).to receive(:tap).and_return(CoreTap.instance)
// 137:     end
// 138:
// 139:     it "forces re-download when symlink_location exists but is not a symlink" do
// 140:       regular_file = mktmpdir/"testball.rb"
// 141:       regular_file.write("not a symlink")
// 142:
// 143:       allow_any_instance_of(Homebrew::API::SourceDownload).to receive(:symlink_location).and_return(regular_file)
// 144:       expect_any_instance_of(Homebrew::API::SourceDownload).to receive(:fetch)
// 145:
// 146:       described_class.source_download(f)
// 147:     end
// 148:
// 149:     it "skips download when symlink_location is a valid symlink" do
// 150:       target = mktmpdir/"testball_target.rb"
// 151:       target.write("content")
// 152:       symlink = mktmpdir/"testball.rb"
// 153:       FileUtils.ln_s(target, symlink)
// 154:
// 155:       allow_any_instance_of(Homebrew::API::SourceDownload).to receive(:symlink_location).and_return(symlink)
// 156:       expect_any_instance_of(Homebrew::API::SourceDownload).not_to receive(:fetch)
// 157:
// 158:       described_class.source_download(f)
// 159:     end
// 160:   end
// 161:
// 162:   describe "::source_download_formula" do
// 163:     let(:f) { Testball.new }
// 164:
// 165:     before do
// 166:       allow(Homebrew::API).to receive(:formula_names).and_return([])
// 167:       allow(f).to receive_messages(ruby_source_path: "Formula/testball.rb", tap_git_head: "abc123",
// 168:                                    ruby_source_checksum: nil)
// 169:       allow(f).to receive(:tap).and_return(CoreTap.instance)
// 170:     end
// 171:
// 172:     it "raises CannotInstallFormulaError when source file is missing" do
// 173:       allow_any_instance_of(Homebrew::API::SourceDownload).to receive(:fetch)
// 174:       allow_any_instance_of(Homebrew::API::SourceDownload).to receive(:symlink_location).and_return(
// 175:         Pathname("/nonexistent/path/testball.rb"),
// 176:       )
// 177:
// 178:       expect do
// 179:         described_class.source_download_formula(f)
// 180:       end.to raise_error(CannotInstallFormulaError, /source code not found/)
// 181:     end
// 182:
// 183:     it "loads formula from symlink_location when source file exists" do
// 184:       source_path = (mktmpdir/"testball.rb")
// 185:       source_path.write <<~RUBY
// 186:         class Testball < Formula
// 187:           url "https://brew.sh/testball-0.1.tar.gz"
// 188:         end
// 189:       RUBY
// 190:
// 191:       allow_any_instance_of(Homebrew::API::SourceDownload).to receive(:fetch)
// 192:       allow_any_instance_of(Homebrew::API::SourceDownload).to receive(:symlink_location).and_return(source_path)
// 193:
// 194:       result = described_class.source_download_formula(f)
// 195:       expect(result).to be_a(Formula)
// 196:       expect(result.name).to eq("testball")
// 197:     end
// 198:
// 199:     it "loads local patch files from API source cache" do
// 200:       source_path = source_cache_dir/"Homebrew/homebrew-core/abc123/Formula/testball.rb"
// 201:       source_path.dirname.mkpath
// 202:       cached_source_path = cache_dir/"downloads/testball.rb"
// 203:       cached_source_path.dirname.mkpath
// 204:       cached_source_path.write <<~RUBY
// 205:         class Testball < Formula
// 206:           url "https://brew.sh/testball-0.1.tar.gz"
// 207:
// 208:           patch do
// 209:             file "patches/noop-a.diff"
// 210:           end
// 211:         end
// 212:       RUBY
// 213:       FileUtils.ln_s cached_source_path.relative_path_from(source_path.dirname), source_path
// 214:
// 215:       allow_any_instance_of(Homebrew::API::SourceDownload).to receive(:fetch) do |download|
// 216:         next if download.symlink_location.basename.to_s != "noop-a.diff"
// 217:
// 218:         cached_patch_path = download.downloader.cached_location
// 219:         cached_patch_path.dirname.mkpath
// 220:         cached_patch_path.write("patch contents")
// 221:         download.downloader.create_symlink_to_cached_download(cached_patch_path)
// 222:       end
// 223:
// 224:       result = described_class.source_download_formula(f)
// 225:
// 226:       expect(result.patchlist.fetch(0).contents).to eq("patch contents")
// 227:     end
// 228:   end
// 229: end
