module test

import brew_runtime

// Translated from Homebrew/brew `test/sbom_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:sbom) { described_class.create(f, tab) }` at line 8.
pub fn ruby_sbom_spec_l8_d1_sbom(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sbom', ...args)
}

// Ruby let `let(:f) do` at line 12.
pub fn ruby_sbom_spec_l12_d2_f(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('f', ...args)
}

// Ruby let `let(:tab) { Tab.new }` at line 18.
pub fn ruby_sbom_spec_l18_d3_tab(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tab', ...args)
}

// Ruby it `it "returns true if valid" do` at line 20.
pub fn ruby_sbom_spec_l20_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:f) do` at line 25.
pub fn ruby_sbom_spec_l25_d5_f(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('f', ...args)
}

// Ruby let `let(:tab) do` at line 51.
pub fn ruby_sbom_spec_l51_d6_tab(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tab', ...args)
}

// Ruby it `it "returns true if valid" do` at line 89.
pub fn ruby_sbom_spec_l89_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "only emits relationships with defined SPDX IDs" do` at line 93.
pub fn ruby_sbom_spec_l93_d8_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('only', ...args)
}

// Ruby it `it "emits external patches as packages" do` at line 103.
pub fn ruby_sbom_spec_l103_d9_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "emits reproducible creation info" do` at line 115.
pub fn ruby_sbom_spec_l115_d10_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "emits bottle metadata when bottle filenames are available" do` at line 122.
pub fn ruby_sbom_spec_l122_d11_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "emits pkg:brew purl in externalRefs for source archive package" do` at line 135.
pub fn ruby_sbom_spec_l135_d12_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby let `let(:f) do` at line 150.
pub fn ruby_sbom_spec_l150_d13_f(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('f', ...args)
}

// Ruby it `it "emits both pkg:brew and upstream purl in externalRefs for source archive package" do` at line 165.
pub fn ruby_sbom_spec_l165_d14_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "omits host-specific packages when bottling" do` at line 183.
pub fn ruby_sbom_spec_l183_d15_omits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('omits', ...args)
}

// Ruby it `it "emits host-specific packages in a pour supplement" do` at line 200.
pub fn ruby_sbom_spec_l200_d16_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "builds a GitHub Packages manifest annotation supplement" do` at line 215.
pub fn ruby_sbom_spec_l215_d17_builds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('builds', ...args)
}

// Ruby it `it "updates only pour-time creation metadata" do` at line 243.
pub fn ruby_sbom_spec_l243_d18_updates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('updates', ...args)
}

// Ruby it `it "merges pour supplements without validating full SBOMs" do` at line 258.
pub fn ruby_sbom_spec_l258_d19_merges(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merges', ...args)
}

// Ruby it `it "skips malformed pour metadata SBOMs" do` at line 281.
pub fn ruby_sbom_spec_l281_d20_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "skips pour metadata SBOMs without creation info objects" do` at line 291.
pub fn ruby_sbom_spec_l291_d21_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "returns false" do` at line 308.
pub fn ruby_sbom_spec_l308_d22_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "percent-encodes @ in versioned formula names" do` at line 315.
pub fn ruby_sbom_spec_l315_d23_percent_encodes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('percent-encodes', ...args)
}

// Ruby it `it "omits the namespace for a bare formula name" do` at line 320.
pub fn ruby_sbom_spec_l320_d24_omits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('omits', ...args)
}

// Ruby it `it "omits the version segment when version is nil" do` at line 324.
pub fn ruby_sbom_spec_l324_d25_omits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('omits', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "sbom"
// 5:
// 6: RSpec.describe SBOM do
// 7:   describe "#schema_validation_errors" do
// 8:     subject(:sbom) { described_class.create(f, tab) }
// 9:
// 10:     before { ENV.delete("HOMEBREW_ENFORCE_SBOM") }
// 11:
// 12:     let(:f) do
// 13:       formula do
// 14:         T.bind(self, T.class_of(Formula))
// 15:         url "foo-1.0"
// 16:       end
// 17:     end
// 18:     let(:tab) { Tab.new }
// 19:
// 20:     it "returns true if valid" do
// 21:       expect(sbom.schema_validation_errors).to be_empty
// 22:     end
// 23:
// 24:     context "with a maximal SBOM" do
// 25:       let(:f) do
// 26:         formula do
// 27:           T.bind(self, T.class_of(Formula))
// 28:           homepage "https://brew.sh"
// 29:
// 30:           url "https://brew.sh/test-0.1.tbz"
// 31:           sha256 TEST_SHA256
// 32:
// 33:           patch do
// 34:             url "patch_macos"
// 35:             sha256 TEST_SHA256
// 36:           end
// 37:
// 38:           bottle do
// 39:             root_url "https://brew.sh/bottles"
// 40:             sha256 all: "9befdad158e59763fb0622083974a6252878019702d8c961e1bec3a5f5305339"
// 41:           end
// 42:
// 43:           # some random dependencies to test with
// 44:           depends_on "cmake" => :build
// 45:           depends_on "beanstalkd"
// 46:
// 47:           uses_from_macos "python" => :build
// 48:           uses_from_macos "zlib"
// 49:         end
// 50:       end
// 51:       let(:tab) do
// 52:         beanstalkd = formula "beanstalkd" do
// 53:           T.bind(self, T.class_of(Formula))
// 54:           url "one-1.1"
// 55:
// 56:           bottle do
// 57:             sha256 all: "ac4c0330b70dae06eaa8065bfbea78dda277699d1ae8002478017a1bd9cf1908"
// 58:           end
// 59:         end
// 60:
// 61:         zlib = formula "zlib" do
// 62:           T.bind(self, T.class_of(Formula))
// 63:           url "two-1.1"
// 64:
// 65:           bottle do
// 66:             sha256 all: "6a4642964fe5c4d1cc8cd3507541736d5b984e34a303a814ef550d4f2f8242f9"
// 67:           end
// 68:         end
// 69:
// 70:         runtime_dependencies = [beanstalkd, zlib]
// 71:         runtime_deps_hash = runtime_dependencies.map do |dep|
// 72:           {
// 73:             "full_name"         => dep.full_name,
// 74:             "version"           => dep.version.to_s,
// 75:             "revision"          => dep.revision,
// 76:             "pkg_version"       => dep.pkg_version.to_s,
// 77:             "declared_directly" => true,
// 78:           }
// 79:         end
// 80:         allow(Tab).to receive(:runtime_deps_hash).and_return(runtime_deps_hash)
// 81:         tab = Tab.create(f, DevelopmentTools.default_compiler, :libcxx)
// 82:
// 83:         allow(Formulary).to receive(:factory).with("beanstalkd").and_return(beanstalkd)
// 84:         allow(Formulary).to receive(:factory).with("zlib").and_return(zlib)
// 85:
// 86:         tab
// 87:       end
// 88:
// 89:       it "returns true if valid" do
// 90:         expect(sbom.schema_validation_errors).to be_empty
// 91:       end
// 92:
// 93:       it "only emits relationships with defined SPDX IDs" do
// 94:         spdx = sbom.to_spdx_sbom
// 95:         spdx_ids = Set.new(["SPDXRef-DOCUMENT"] + spdx[:packages].map { |package| package[:SPDXID] } +
// 96:                            spdx[:files].map { |file| file[:SPDXID] })
// 97:
// 98:         expect(spdx[:relationships].flat_map do |relation|
// 99:           [relation[:spdxElementId], relation[:relatedSpdxElement]]
// 100:         end).to all(satisfy { |spdx_id| spdx_ids.include?(spdx_id) })
// 101:       end
// 102:
// 103:       it "emits external patches as packages" do
// 104:         spdx = sbom.to_spdx_sbom
// 105:
// 106:         expect(spdx[:packages]).to include(
// 107:           hash_including(
// 108:             SPDXID:           "SPDXRef-Patch-formula_name-0",
// 109:             downloadLocation: "patch_macos",
// 110:             checksums:        [{ algorithm: "SHA256", checksumValue: TEST_SHA256 }],
// 111:           ),
// 112:         )
// 113:       end
// 114:
// 115:       it "emits reproducible creation info" do
// 116:         expect(sbom.to_spdx_sbom[:creationInfo]).to eq(
// 117:           created:  Time.at(tab.source_modified_time.to_i).utc.iso8601,
// 118:           creators: ["Tool: https://github.com/Homebrew/brew"],
// 119:         )
// 120:       end
// 121:
// 122:       it "emits bottle metadata when bottle filenames are available" do
// 123:         expect(sbom.to_spdx_sbom[:packages]).to include(
// 124:           hash_including(
// 125:             SPDXID:           "SPDXRef-Bottle-formula_name",
// 126:             downloadLocation: "https://brew.sh/bottles/formula_name-0.1.all.bottle.tar.gz",
// 127:             checksums:        [{
// 128:               algorithm:     "SHA256",
// 129:               checksumValue: "9befdad158e59763fb0622083974a6252878019702d8c961e1bec3a5f5305339",
// 130:             }],
// 131:           ),
// 132:         )
// 133:       end
// 134:
// 135:       it "emits pkg:brew purl in externalRefs for source archive package" do
// 136:         expect(sbom.to_spdx_sbom[:packages]).to include(
// 137:           hash_including(
// 138:             SPDXID:       "SPDXRef-Archive-formula_name-src",
// 139:             externalRefs: [{
// 140:               referenceCategory: "PACKAGE-MANAGER",
// 141:               referenceLocator:  "pkg:brew/homebrew/core/formula_name@0.1",
// 142:               referenceType:     "purl",
// 143:             }],
// 144:           ),
// 145:         )
// 146:       end
// 147:
// 148:       # NOTE: We don't package `requests`. This is here for testing upstream purl identification.
// 149:       context "with a PyPI source URL" do
// 150:         let(:f) do
// 151:           formula do
// 152:             T.bind(self, T.class_of(Formula))
// 153:             homepage "https://brew.sh"
// 154:
// 155:             url "https://files.pythonhosted.org/packages/d6/5d/47f0d014022a106f235948924b17f54c9356a815a51086082eeef7f3747d/requests-2.25.1.tar.gz"
// 156:             sha256 TEST_SHA256
// 157:
// 158:             bottle do
// 159:               root_url "https://brew.sh/bottles"
// 160:               sha256 all: "9befdad158e59763fb0622083974a6252878019702d8c961e1bec3a5f5305339"
// 161:             end
// 162:           end
// 163:         end
// 164:
// 165:         it "emits both pkg:brew and upstream purl in externalRefs for source archive package" do
// 166:           expect(sbom.to_spdx_sbom[:packages]).to include(
// 167:             hash_including(
// 168:               SPDXID:       "SPDXRef-Archive-formula_name-src",
// 169:               externalRefs: [{
// 170:                 referenceCategory: "PACKAGE-MANAGER",
// 171:                 referenceLocator:  "pkg:brew/homebrew/core/formula_name@2.25.1",
// 172:                 referenceType:     "purl",
// 173:               }, {
// 174:                 referenceCategory: "PACKAGE-MANAGER",
// 175:                 referenceLocator:  "pkg:pypi/requests@2.25.1",
// 176:                 referenceType:     "purl",
// 177:               }],
// 178:             ),
// 179:           )
// 180:         end
// 181:       end
// 182:
// 183:       it "omits host-specific packages when bottling" do
// 184:         spdx = sbom.to_spdx_sbom(bottling: true)
// 185:         package_ids = spdx[:packages].map { |package| package[:SPDXID] }
// 186:
// 187:         expect(package_ids).to contain_exactly(
// 188:           "SPDXRef-Archive-formula_name-src",
// 189:           "SPDXRef-Patch-formula_name-0",
// 190:         )
// 191:         expect(spdx[:relationships].flat_map do |relation|
// 192:           [relation[:spdxElementId], relation[:relatedSpdxElement]]
// 193:         end).to all(
// 194:           satisfy do |spdx_id|
// 195:             package_ids.include?(spdx_id) || spdx_id == "SPDXRef-File-formula_name"
// 196:           end,
// 197:         )
// 198:       end
// 199:
// 200:       it "emits host-specific packages in a pour supplement" do
// 201:         package_ids = sbom.to_spdx_supplement.fetch("packages").map { |package| package.fetch(:SPDXID) }
// 202:
// 203:         expect(package_ids).to include(
// 204:           "SPDXRef-Compiler",
// 205:           "SPDXRef-Stdlib",
// 206:           "SPDXRef-Package-SPDXRef-beanstalkd-1.1",
// 207:           "SPDXRef-Package-SPDXRef-zlib-1.1",
// 208:         )
// 209:         expect(package_ids).not_to include(
// 210:           "SPDXRef-Archive-formula_name-src",
// 211:           "SPDXRef-Patch-formula_name-0",
// 212:         )
// 213:       end
// 214:
// 215:       it "builds a GitHub Packages manifest annotation supplement" do
// 216:         annotation = described_class.github_packages_sbom_supplement_annotation(
// 217:           {
// 218:             "documentDescribes" => ["SPDXRef-Compiler"],
// 219:             "packages"          => [{ "SPDXID" => "SPDXRef-Compiler" }],
// 220:             "relationships"     => [],
// 221:           },
// 222:           formula_full_name: "formula_name",
// 223:           formula_name:      "formula_name",
// 224:           version:           Version.new("0.1"),
// 225:           tar_gz_sha256:     TEST_SHA256,
// 226:           root_url:          "https://ghcr.io/v2/homebrew/core",
// 227:           license:           "MIT",
// 228:           created_date:      "2026-05-10T00:00:00Z",
// 229:         )
// 230:         raise "missing annotation" if annotation.nil?
// 231:
// 232:         supplement = JSON.parse(annotation)
// 233:         bottle_package = supplement.fetch("packages").find do |package|
// 234:           package.fetch("SPDXID") == "SPDXRef-Bottle-formula_name"
// 235:         end
// 236:
// 237:         expect(bottle_package).to include(
// 238:           "checksums"        => [{ "algorithm" => "SHA256", "checksumValue" => TEST_SHA256 }],
// 239:           "downloadLocation" => "https://ghcr.io/v2/homebrew/core/formula_name/blobs/sha256:#{TEST_SHA256}",
// 240:         )
// 241:       end
// 242:
// 243:       it "updates only pour-time creation metadata" do
// 244:         spdxfile = mktmpdir/SBOM::FILENAME
// 245:         spdxfile.write(JSON.pretty_generate(sbom.to_spdx_sbom))
// 246:         original_spdx = JSON.parse(spdxfile.read)
// 247:
// 248:         described_class.update_pour_metadata(spdxfile, homebrew_version: "1.2.3", time: 1_720_189_863)
// 249:
// 250:         updated_spdx = JSON.parse(spdxfile.read)
// 251:         expect(updated_spdx.fetch("creationInfo")).to eq(
// 252:           "created"  => "2024-07-05T14:31:03Z",
// 253:           "creators" => ["Tool: https://github.com/Homebrew/brew@1.2.3"],
// 254:         )
// 255:         expect(updated_spdx.except("creationInfo")).to eq(original_spdx.except("creationInfo"))
// 256:       end
// 257:
// 258:       it "merges pour supplements without validating full SBOMs" do
// 259:         spdxfile = mktmpdir/SBOM::FILENAME
// 260:         spdxfile.write(JSON.pretty_generate(
// 261:                          "creationInfo"      => {},
// 262:                          "documentDescribes" => [],
// 263:                          "packages"          => [],
// 264:                          "relationships"     => [],
// 265:                        ))
// 266:         supplement = {
// 267:           "documentDescribes" => ["SPDXRef-Compiler"],
// 268:           "packages"          => [{ "SPDXID" => "SPDXRef-Compiler" }],
// 269:           "relationships"     => [{ "spdxElementId" => "SPDXRef-Compiler" }],
// 270:         }
// 271:
// 272:         described_class.update_pour_metadata(spdxfile, homebrew_version: "1.2.3", time: 1_720_189_863,
// 273:                                                        supplement:)
// 274:
// 275:         updated_spdx = JSON.parse(spdxfile.read)
// 276:         expect(updated_spdx.fetch("documentDescribes")).to eq(supplement.fetch("documentDescribes"))
// 277:         expect(updated_spdx.fetch("packages")).to eq(supplement.fetch("packages"))
// 278:         expect(updated_spdx.fetch("relationships")).to eq(supplement.fetch("relationships"))
// 279:       end
// 280:
// 281:       it "skips malformed pour metadata SBOMs" do
// 282:         spdxfile = mktmpdir/SBOM::FILENAME
// 283:         spdxfile.write("{")
// 284:
// 285:         expect do
// 286:           described_class.update_pour_metadata(spdxfile, homebrew_version: "1.2.3", time: 1_720_189_863)
// 287:         end.not_to raise_error
// 288:         expect(spdxfile.read).to eq("{")
// 289:       end
// 290:
// 291:       it "skips pour metadata SBOMs without creation info objects" do
// 292:         spdxfile = mktmpdir/SBOM::FILENAME
// 293:         spdxfile.write(JSON.pretty_generate("creationInfo" => []))
// 294:         original_spdx = spdxfile.read
// 295:
// 296:         expect do
// 297:           described_class.update_pour_metadata(spdxfile, homebrew_version: "1.2.3", time: 1_720_189_863)
// 298:         end.not_to raise_error
// 299:         expect(spdxfile.read).to eq(original_spdx)
// 300:       end
// 301:     end
// 302:
// 303:     context "with an invalid SBOM" do
// 304:       before do
// 305:         allow(sbom).to receive(:to_spdx_sbom).and_return({}) # fake an empty SBOM
// 306:       end
// 307:
// 308:       it "returns false" do
// 309:         expect(sbom.schema_validation_errors).not_to be_empty
// 310:       end
// 311:     end
// 312:   end
// 313:
// 314:   describe ".brew_purl" do
// 315:     it "percent-encodes @ in versioned formula names" do
// 316:       expect(described_class.brew_purl("homebrew/core/python@3.12", "3.12.8"))
// 317:         .to eq("pkg:brew/homebrew/core/python%403.12@3.12.8")
// 318:     end
// 319:
// 320:     it "omits the namespace for a bare formula name" do
// 321:       expect(described_class.brew_purl("zlib", "1.3.1")).to eq("pkg:brew/zlib@1.3.1")
// 322:     end
// 323:
// 324:     it "omits the version segment when version is nil" do
// 325:       expect(described_class.brew_purl("homebrew/core/foo", nil)).to eq("pkg:brew/homebrew/core/foo")
// 326:     end
// 327:   end
// 328: end
