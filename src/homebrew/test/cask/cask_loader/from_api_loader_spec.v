module cask_loader

import brew_runtime

// Translated from Homebrew/brew `test/cask/cask_loader/from_api_loader_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:api_token) { "#{local_token}-api" }` at line 6.
pub fn ruby_from_api_loader_spec_l6_d1_api_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('api_token', ...args)
}

// Ruby let `let(:cask_from_source) { Cask::CaskLoader.load(local_token) }` at line 7.
pub fn ruby_from_api_loader_spec_l7_d2_cask_from_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_from_source', ...args)
}

// Ruby let `let(:cask_json) do` at line 8.
pub fn ruby_from_api_loader_spec_l8_d3_cask_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_json', ...args)
}

// Ruby let `let(:casks_from_api_hash) { { api_token => cask_json.except("token") } }` at line 15.
pub fn ruby_from_api_loader_spec_l15_d4_casks_from_api_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('casks_from_api_hash', ...args)
}

// Ruby let `let(:api_loader) { described_class.new(api_token, from_json: cask_json) }` at line 16.
pub fn ruby_from_api_loader_spec_l16_d5_api_loader(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('api_loader', ...args)
}

// Ruby let! `let!(:cask_from_internal_source) { Cask::CaskLoader.load(local_token) }` at line 30.
pub fn ruby_from_api_loader_spec_l30_d6_cask_from_internal_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_from_internal_source', ...args)
}

// Ruby let! `let!(:cask_internal_struct) do` at line 31.
pub fn ruby_from_api_loader_spec_l31_d7_cask_internal_struct(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_internal_struct', ...args)
}

// Ruby let `let(:internal_api_token) { "#{local_token}-internal-api" }` at line 36.
pub fn ruby_from_api_loader_spec_l36_d8_internal_api_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('internal_api_token', ...args)
}

// Ruby let `let(:internal_tap_git_head) { "abcdef1234567890abcdef1234567890abcdef12" }` at line 37.
pub fn ruby_from_api_loader_spec_l37_d9_internal_tap_git_head(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('internal_tap_git_head', ...args)
}

// Ruby let `let(:cask_internal_json) do` at line 38.
pub fn ruby_from_api_loader_spec_l38_d10_cask_internal_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_internal_json', ...args)
}

// Ruby let `let(:casks_from_internal_api_hash) { { internal_api_token => cask_internal_json.except("tap_git_head") } }` at line 46.
pub fn ruby_from_api_loader_spec_l46_d11_casks_from_internal_api_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('casks_from_internal_api_hash', ...args)
}

// Ruby let `let(:internal_api_loader) do` at line 47.
pub fn ruby_from_api_loader_spec_l47_d12_internal_api_loader(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('internal_api_loader', ...args)
}

// Ruby it `it "returns false" do` at line 69.
pub fn ruby_from_api_loader_spec_l69_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns a loader for valid token" do` at line 77.
pub fn ruby_from_api_loader_spec_l77_d14_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns a loader for valid full name" do` at line 83.
pub fn ruby_from_api_loader_spec_l83_d15_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:foo_tap) { Tap.fetch("homebrew", "foo") }` at line 90.
pub fn ruby_from_api_loader_spec_l90_d16_foo_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('foo_tap', ...args)
}

// Ruby it `it "returns the tap migration rename by old token" do` at line 100.
pub fn ruby_from_api_loader_spec_l100_d17_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the tap migration rename by old full name" do` at line 112.
pub fn ruby_from_api_loader_spec_l112_d18_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns a loader for valid token" do` at line 129.
pub fn ruby_from_api_loader_spec_l129_d19_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns a loader for valid full name" do` at line 135.
pub fn ruby_from_api_loader_spec_l135_d20_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:foo_tap) { Tap.fetch("homebrew", "foo") }` at line 142.
pub fn ruby_from_api_loader_spec_l142_d21_foo_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('foo_tap', ...args)
}

// Ruby it `it "returns the tap migration rename by old token" do` at line 152.
pub fn ruby_from_api_loader_spec_l152_d22_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the tap migration rename by old full name" do` at line 164.
pub fn ruby_from_api_loader_spec_l164_d23_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns nil for full name with invalid tap" do` at line 178.
pub fn ruby_from_api_loader_spec_l178_d24_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "handles greedy outdated checks for installed metadata without a URL" do` at line 184.
pub fn ruby_from_api_loader_spec_l184_d25_handles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handles', ...args)
}

// Ruby it `it "uses current API artifacts for installed metadata without receipt artifacts" do` at line 199.
pub fn ruby_from_api_loader_spec_l199_d26_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "does not read a malformed receipt when installed metadata is self-contained" do` at line 222.
pub fn ruby_from_api_loader_spec_l222_d27_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby let `let(:cask_from_api) { api_loader.load(config: nil) }` at line 247.
pub fn ruby_from_api_loader_spec_l247_d28_cask_from_api(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_from_api', ...args)
}

// Ruby let `let(:cask_from_internal_api) { internal_api_loader.load(config: nil) }` at line 248.
pub fn ruby_from_api_loader_spec_l248_d29_cask_from_internal_api(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_from_internal_api', ...args)
}

// Ruby it `it "loads from JSON API" do` at line 250.
pub fn ruby_from_api_loader_spec_l250_d30_loads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('loads', ...args)
}

// Ruby it `it "loads from internal JSON API" do` at line 259.
pub fn ruby_from_api_loader_spec_l259_d31_loads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('loads', ...args)
}

// Ruby it `it "runs the loaded steps" do` at line 303.
pub fn ruby_from_api_loader_spec_l303_d32_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runs', ...args)
}

// Ruby it `it "loads the selected language variation from both APIs" do` at line 339.
pub fn ruby_from_api_loader_spec_l339_d33_loads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('loads', ...args)
}

// Ruby it `it "keeps the source fallback for old API data" do` at line 353.
pub fn ruby_from_api_loader_spec_l353_d34_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::CaskLoader::FromAPILoader, :cask do
// 5:   shared_context "with API setup" do |local_token|
// 6:     let(:api_token) { "#{local_token}-api" }
// 7:     let(:cask_from_source) { Cask::CaskLoader.load(local_token) }
// 8:     let(:cask_json) do
// 9:       hash = cask_from_source.to_hash_with_variations
// 10:       # This value will always be present in the json API, but is skipped in tests
// 11:       hash["tap_git_head"] = "abcdef1234567890abcdef1234567890abcdef12"
// 12:       json = JSON.pretty_generate(hash)
// 13:       JSON.parse(json)
// 14:     end
// 15:     let(:casks_from_api_hash) { { api_token => cask_json.except("token") } }
// 16:     let(:api_loader) { described_class.new(api_token, from_json: cask_json) }
// 17:
// 18:     before do
// 19:       allow(Homebrew::API).to receive_messages(cask_tokens: casks_from_api_hash.keys, cask_renames: {})
// 20:       allow(Homebrew::API).to receive(:cask_token?) { |token| casks_from_api_hash.key?(token) }
// 21:       allow(Homebrew::API::Cask).to receive(:all_casks).and_return(casks_from_api_hash)
// 22:
// 23:       # The call to `Cask::CaskLoader.load` above sets the Tap cache prematurely.
// 24:       Tap.clear_cache
// 25:     end
// 26:   end
// 27:
// 28:   shared_context "with internal API setup" do |local_token|
// 29:     # Load the cask and generate its hash first before we enable internal API mode for the test body
// 30:     let!(:cask_from_internal_source) { Cask::CaskLoader.load(local_token) }
// 31:     let!(:cask_internal_struct) do
// 32:       hash_with_variations = cask_from_internal_source.to_hash_with_variations
// 33:       Homebrew::API::Cask::CaskStructGenerator.generate_cask_struct_hash(hash_with_variations)
// 34:     end
// 35:
// 36:     let(:internal_api_token) { "#{local_token}-internal-api" }
// 37:     let(:internal_tap_git_head) { "abcdef1234567890abcdef1234567890abcdef12" }
// 38:     let(:cask_internal_json) do
// 39:       hash = cask_internal_struct.serialize
// 40:       # This value must be manually added when loading from internal API contents directly
// 41:       hash["tap_git_head"] = internal_tap_git_head
// 42:       json = JSON.pretty_generate(hash)
// 43:       JSON.parse(json)
// 44:     end
// 45:     # let(:cask_structs_from_api_hash) { { internal_api_token => cask_internal_struct } }
// 46:     let(:casks_from_internal_api_hash) { { internal_api_token => cask_internal_json.except("tap_git_head") } }
// 47:     let(:internal_api_loader) do
// 48:       described_class.new(internal_api_token, from_json: cask_internal_json, from_internal_json: true)
// 49:     end
// 50:
// 51:     before do
// 52:       allow(Homebrew::API::Internal)
// 53:         .to receive_messages(cask_hashes:         casks_from_internal_api_hash,
// 54:                              cask_renames:        {},
// 55:                              cask_tap_migrations: {},
// 56:                              cask_tap_git_head:   internal_tap_git_head)
// 57:       allow(Homebrew::API::Internal).to receive(:cask_name?) { |token| casks_from_internal_api_hash.key?(token) }
// 58:       allow(Homebrew::API::Internal).to receive(:cask_hash) { |token| casks_from_internal_api_hash[token] }
// 59:
// 60:       # The call to `Cask::CaskLoader.load` above sets the Tap cache prematurely.
// 61:       Tap.clear_cache
// 62:     end
// 63:   end
// 64:
// 65:   describe ".try_new" do
// 66:     context "when not using the API", :no_api do
// 67:       include_context "with API setup", "test-opera"
// 68:
// 69:       it "returns false" do
// 70:         expect(described_class.try_new(api_token)).to be_nil
// 71:       end
// 72:     end
// 73:
// 74:     context "when using the API" do
// 75:       include_context "with API setup", "test-opera"
// 76:
// 77:       it "returns a loader for valid token" do
// 78:         expect(described_class.try_new(api_token))
// 79:           .to be_a(described_class)
// 80:           .and have_attributes(token: api_token)
// 81:       end
// 82:
// 83:       it "returns a loader for valid full name" do
// 84:         expect(described_class.try_new("homebrew/cask/#{api_token}"))
// 85:           .to be_a(described_class)
// 86:           .and have_attributes(token: api_token)
// 87:       end
// 88:
// 89:       context "with core tap migration renames" do
// 90:         let(:foo_tap) { Tap.fetch("homebrew", "foo") }
// 91:
// 92:         before do
// 93:           foo_tap.path.mkpath
// 94:         end
// 95:
// 96:         after do
// 97:           FileUtils.rm_rf foo_tap.path
// 98:         end
// 99:
// 100:         it "returns the tap migration rename by old token" do
// 101:           old_token = "#{api_token}-old"
// 102:           (foo_tap.path/"tap_migrations.json").write <<~JSON
// 103:             { "#{old_token}": "homebrew/cask/#{api_token}" }
// 104:           JSON
// 105:
// 106:           loader = Cask::CaskLoader::FromNameLoader.try_new(old_token)
// 107:           expect(loader).to be_a(described_class)
// 108:           expect(loader.token).to eq api_token
// 109:           expect(loader.path).not_to exist
// 110:         end
// 111:
// 112:         it "returns the tap migration rename by old full name" do
// 113:           old_token = "#{api_token}-old"
// 114:           (foo_tap.path/"tap_migrations.json").write <<~JSON
// 115:             { "#{old_token}": "homebrew/cask/#{api_token}" }
// 116:           JSON
// 117:
// 118:           loader = Cask::CaskLoader::FromTapLoader.try_new("#{foo_tap}/#{old_token}")
// 119:           expect(loader).to be_a(described_class)
// 120:           expect(loader.token).to eq api_token
// 121:           expect(loader.path).not_to exist
// 122:         end
// 123:       end
// 124:     end
// 125:
// 126:     context "when using the internal API" do
// 127:       include_context "with internal API setup", "test-opera"
// 128:
// 129:       it "returns a loader for valid token" do
// 130:         expect(described_class.try_new(internal_api_token))
// 131:           .to be_a(described_class)
// 132:           .and have_attributes(token: internal_api_token)
// 133:       end
// 134:
// 135:       it "returns a loader for valid full name" do
// 136:         expect(described_class.try_new("homebrew/cask/#{internal_api_token}"))
// 137:           .to be_a(described_class)
// 138:           .and have_attributes(token: internal_api_token)
// 139:       end
// 140:
// 141:       context "with core tap migration renames" do
// 142:         let(:foo_tap) { Tap.fetch("homebrew", "foo") }
// 143:
// 144:         before do
// 145:           foo_tap.path.mkpath
// 146:         end
// 147:
// 148:         after do
// 149:           FileUtils.rm_rf foo_tap.path
// 150:         end
// 151:
// 152:         it "returns the tap migration rename by old token" do
// 153:           old_token = "#{internal_api_token}-old"
// 154:           (foo_tap.path/"tap_migrations.json").write <<~JSON
// 155:             { "#{old_token}": "homebrew/cask/#{internal_api_token}" }
// 156:           JSON
// 157:
// 158:           loader = Cask::CaskLoader::FromNameLoader.try_new(old_token)
// 159:           expect(loader).to be_a(described_class)
// 160:           expect(loader.token).to eq internal_api_token
// 161:           expect(loader.path).not_to exist
// 162:         end
// 163:
// 164:         it "returns the tap migration rename by old full name" do
// 165:           old_token = "#{internal_api_token}-old"
// 166:           (foo_tap.path/"tap_migrations.json").write <<~JSON
// 167:             { "#{old_token}": "homebrew/cask/#{internal_api_token}" }
// 168:           JSON
// 169:
// 170:           loader = Cask::CaskLoader::FromTapLoader.try_new("#{foo_tap}/#{old_token}")
// 171:           expect(loader).to be_a(described_class)
// 172:           expect(loader.token).to eq internal_api_token
// 173:           expect(loader.path).not_to exist
// 174:         end
// 175:       end
// 176:     end
// 177:
// 178:     it "returns nil for full name with invalid tap" do
// 179:       expect(described_class.try_new("homebrew/foo/test-opera")).to be_nil
// 180:     end
// 181:   end
// 182:
// 183:   describe "#load" do
// 184:     it "handles greedy outdated checks for installed metadata without a URL" do
// 185:       token = "url-less-installed-cask"
// 186:       caskroom = mktmpdir
// 187:       allow(Cask::Caskroom).to receive(:path).and_return(caskroom)
// 188:       allow(Homebrew::API).to receive(:cask_token?).with(token).and_return(true)
// 189:       allow(Homebrew::API::Cask).to receive(:cask_json).with(token).and_return({ "artifacts" => [] })
// 190:       path = caskroom/token/".metadata/latest/20260713000000.000/Casks/#{token}.json"
// 191:       cask = described_class.new(token, from_json: {}, path:, from_installed_caskfile: true).load(config: nil)
// 192:       allow(cask).to receive(:installed_version).and_return("latest")
// 193:       cask.download_sha_path.dirname.mkpath
// 194:       cask.download_sha_path.write("old-download-sha")
// 195:
// 196:       expect(cask.outdated?(greedy: true)).to be(true)
// 197:     end
// 198:
// 199:     it "uses current API artifacts for installed metadata without receipt artifacts" do
// 200:       token = "receipt-less-installed-cask"
// 201:       caskroom = mktmpdir
// 202:       allow(Cask::Caskroom).to receive(:path).and_return(caskroom)
// 203:       allow(Homebrew::API).to receive(:cask_token?).with(token).and_return(true)
// 204:       allow(Homebrew::API::Cask).to receive(:cask_json).with(token).and_return({
// 205:         "artifacts" => [
// 206:           { "app" => ["Receipt-less.app"] },
// 207:           { "uninstall" => [{ "quit" => "com.example.receipt-less" }] },
// 208:           { "zap" => [{ "trash" => "~/Library/Preferences/com.example.receipt-less.plist" }] },
// 209:         ],
// 210:       })
// 211:       path = caskroom/token/".metadata/1.0/20260713000000.000/Casks/#{token}.json"
// 212:
// 213:       cask = described_class.new(token, from_json: {}, path:, from_installed_caskfile: true).load(config: nil)
// 214:
// 215:       expect(cask.artifacts_list(uninstall_only: true)).to eq([
// 216:         { uninstall: [{ quit: "com.example.receipt-less" }] },
// 217:         { app: ["Receipt-less.app"] },
// 218:         { zap: [{ trash: "~/Library/Preferences/com.example.receipt-less.plist" }] },
// 219:       ])
// 220:     end
// 221:
// 222:     it "does not read a malformed receipt when installed metadata is self-contained" do
// 223:       token = "self-contained-installed-cask"
// 224:       caskroom = mktmpdir
// 225:       allow(Cask::Caskroom).to receive(:path).and_return(caskroom)
// 226:       receipt = caskroom/token/".metadata/INSTALL_RECEIPT.json"
// 227:       receipt.dirname.mkpath
// 228:       receipt.write("{")
// 229:       path = caskroom/token/".metadata/1.0/20260713000000.000/Casks/#{token}.json"
// 230:
// 231:       cask = described_class.new(
// 232:         token,
// 233:         from_json:               {
// 234:           "version"   => "1.0",
// 235:           "artifacts" => [{ "app" => ["Self-contained.app"] }],
// 236:         },
// 237:         path:,
// 238:         from_installed_caskfile: true,
// 239:       ).load(config: nil)
// 240:
// 241:       expect(cask.artifacts_list(uninstall_only: true)).to eq([{ app: ["Self-contained.app"] }])
// 242:     end
// 243:
// 244:     shared_examples "loads from API" do |cask_token, caskfile_only:|
// 245:       include_context "with API setup", cask_token
// 246:       include_context "with internal API setup", cask_token
// 247:       let(:cask_from_api) { api_loader.load(config: nil) }
// 248:       let(:cask_from_internal_api) { internal_api_loader.load(config: nil) }
// 249:
// 250:       it "loads from JSON API" do
// 251:         expect(cask_from_api).to be_a(Cask::Cask)
// 252:         expect(cask_from_api.token).to eq(api_token)
// 253:         expect(cask_from_api.loaded_from_api?).to be(true)
// 254:         expect(cask_from_api.loaded_from_internal_api?).to be(false)
// 255:         expect(cask_from_api.caskfile_only?).to be(caskfile_only)
// 256:         expect(cask_from_api.sourcefile_path).to eq(Homebrew::API::Cask.cached_json_file_path)
// 257:       end
// 258:
// 259:       it "loads from internal JSON API" do
// 260:         expect(cask_from_internal_api).to be_a(Cask::Cask)
// 261:         expect(cask_from_internal_api.token).to eq(internal_api_token)
// 262:         expect(cask_from_internal_api.loaded_from_api?).to be(true)
// 263:         expect(cask_from_internal_api.loaded_from_internal_api?).to be(true)
// 264:         expect(cask_from_internal_api.caskfile_only?).to be(caskfile_only)
// 265:         expect(cask_from_internal_api.sourcefile_path).to eq(Homebrew::API::Internal.cached_packages_json_file_path)
// 266:       end
// 267:     end
// 268:
// 269:     context "with a binary stanza" do
// 270:       include_examples "loads from API", "with-binary", caskfile_only: false
// 271:     end
// 272:
// 273:     context "with cask dependencies" do
// 274:       include_examples "loads from API", "with-depends-on-cask-multiple", caskfile_only: false
// 275:     end
// 276:
// 277:     context "with formula dependencies" do
// 278:       include_examples "loads from API", "with-depends-on-formula-multiple", caskfile_only: false
// 279:     end
// 280:
// 281:     context "with macos dependencies" do
// 282:       include_examples "loads from API", "with-depends-on-macos-array", caskfile_only: false
// 283:     end
// 284:
// 285:     context "with an installer stanza" do
// 286:       include_examples "loads from API", "with-installer-script", caskfile_only: false
// 287:     end
// 288:
// 289:     context "with uninstall stanzas" do
// 290:       include_examples "loads from API", "with-uninstall-multi", caskfile_only: false
// 291:     end
// 292:
// 293:     context "with a zap stanza" do
// 294:       include_examples "loads from API", "with-zap", caskfile_only: false
// 295:     end
// 296:
// 297:     context "with install step stanzas" do
// 298:       include_examples "loads from API", "with-install-steps", caskfile_only: false
// 299:
// 300:       context "when running install steps loaded from internal JSON API" do
// 301:         include_context "with internal API setup", "with-install-steps"
// 302:
// 303:         it "runs the loaded steps" do
// 304:           cask = internal_api_loader.load(config: nil)
// 305:           cask.staged_path.mkpath
// 306:           cask.config_path.dirname.mkpath
// 307:           (cask.staged_path/"container").write "app"
// 308:           (cask.staged_path/"move-source").write "moved"
// 309:
// 310:           Cask::Installer.new(cask, command: NeverSudoSystemCommand).install_artifacts
// 311:
// 312:           expect(cask.staged_path/"Prepared").to be_a_directory
// 313:           expect(cask.staged_path/"Prepared/touched").to exist
// 314:           expect(cask.staged_path/"Prepared/moved").to exist
// 315:           expect(cask.staged_path/"PreparedLink").to be_a_symlink
// 316:         end
// 317:       end
// 318:     end
// 319:
// 320:     context "with a preflight stanza" do
// 321:       include_examples "loads from API", "with-preflight", caskfile_only: true
// 322:     end
// 323:
// 324:     context "with an uninstall-preflight stanza" do
// 325:       include_examples "loads from API", "with-uninstall-preflight", caskfile_only: true
// 326:     end
// 327:
// 328:     context "with a postflight stanza" do
// 329:       include_examples "loads from API", "with-postflight", caskfile_only: true
// 330:     end
// 331:
// 332:     context "with an uninstall-postflight stanza" do
// 333:       include_examples "loads from API", "with-uninstall-postflight", caskfile_only: true
// 334:     end
// 335:
// 336:     context "with a language stanza" do
// 337:       include_examples "loads from API", "with-languages", caskfile_only: false
// 338:
// 339:       it "loads the selected language variation from both APIs" do
// 340:         config = Cask::Config.new(explicit: { languages: ["zh"] })
// 341:         casks = [api_loader.load(config:), internal_api_loader.load(config:)]
// 342:
// 343:         expect(casks.map do |cask|
// 344:           [cask.language, cask.url.to_s, cask.sha256.to_s, cask.artifacts.first.to_args]
// 345:         end).to all(eq([
// 346:           "zh-CN",
// 347:           "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz",
// 348:           "fab685fabf73d5a9382581ce8698fce9408f5feaa49fa10d9bc6c510493300f5",
// 349:           ["Container.app"],
// 350:         ]))
// 351:       end
// 352:
// 353:       it "keeps the source fallback for old API data" do
// 354:         cask = described_class.new(api_token, from_json: cask_json.except("language_variations")).load(config: nil)
// 355:
// 356:         expect(cask).to be_caskfile_only
// 357:       end
// 358:     end
// 359:   end
// 360: end
