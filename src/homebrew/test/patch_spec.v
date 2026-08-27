module test

import brew_runtime

// Translated from Homebrew/brew `test/patch_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:patch) { described_class.create(:p2, nil) }` at line 9.
pub fn ruby_patch_spec_l9_d1_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch', ...args)
}

// Ruby specify `specify(:aggregate_failures) do` at line 11.
pub fn ruby_patch_spec_l11_d2_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aggregate_failures', ...args)
}

// Ruby it `it(:strip) { expect(patch.strip).to eq(:p2) }` at line 16.
pub fn ruby_patch_spec_l16_d3_strip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strip', ...args)
}

// Ruby subject `subject(:patch) { described_class.create(:p0, "foo") }` at line 20.
pub fn ruby_patch_spec_l20_d4_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch', ...args)
}

// Ruby it `it { is_expected.to be_a StringPatch }` at line 22.
pub fn ruby_patch_spec_l22_d5_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby it `it(:strip) { expect(patch.strip).to eq(:p0) }` at line 23.
pub fn ruby_patch_spec_l23_d6_strip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strip', ...args)
}

// Ruby subject `subject(:patch) { described_class.create("foo", nil) }` at line 27.
pub fn ruby_patch_spec_l27_d7_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch', ...args)
}

// Ruby it `it { is_expected.to be_a StringPatch }` at line 29.
pub fn ruby_patch_spec_l29_d8_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby it `it(:strip) { expect(patch.strip).to eq(:p1) }` at line 30.
pub fn ruby_patch_spec_l30_d9_strip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strip', ...args)
}

// Ruby subject `subject(:patch) { described_class.create(:p0, :DATA) }` at line 34.
pub fn ruby_patch_spec_l34_d10_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch', ...args)
}

// Ruby it `it { is_expected.to be_a DATAPatch }` at line 36.
pub fn ruby_patch_spec_l36_d11_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby it `it(:strip) { expect(patch.strip).to eq(:p0) }` at line 37.
pub fn ruby_patch_spec_l37_d12_strip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strip', ...args)
}

// Ruby subject `subject(:patch) { described_class.create(:DATA, nil) }` at line 41.
pub fn ruby_patch_spec_l41_d13_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch', ...args)
}

// Ruby it `it { is_expected.to be_a DATAPatch }` at line 43.
pub fn ruby_patch_spec_l43_d14_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby it `it(:strip) { expect(patch.strip).to eq(:p1) }` at line 44.
pub fn ruby_patch_spec_l44_d15_strip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strip', ...args)
}

// Ruby subject `subject(:patch) { described_class.create(:p0, nil) { file "Patches/foo.diff" } }` at line 48.
pub fn ruby_patch_spec_l48_d16_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch', ...args)
}

// Ruby specify `specify(:aggregate_failures) do` at line 50.
pub fn ruby_patch_spec_l50_d17_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aggregate_failures', ...args)
}

// Ruby it `it(:strip) { expect(patch.strip).to eq(:p0) }` at line 55.
pub fn ruby_patch_spec_l55_d18_strip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strip', ...args)
}

// Ruby it `it(:inspect) { expect(patch.inspect).to eq('#<LocalPatch: :p0 "Patches/foo.diff">') }` at line 56.
pub fn ruby_patch_spec_l56_d19_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Ruby it `it "rejects blank local file patch paths" do` at line 59.
pub fn ruby_patch_spec_l59_d20_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "rejects current directory local file patch paths" do` at line 65.
pub fn ruby_patch_spec_l65_d21_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "rejects parent directory local file patch paths" do` at line 71.
pub fn ruby_patch_spec_l71_d22_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "rejects local file patch paths ending in a slash" do` at line 77.
pub fn ruby_patch_spec_l77_d23_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "rejects local file patches outside the repository" do` at line 83.
pub fn ruby_patch_spec_l83_d24_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "rejects absolute local file patches" do` at line 89.
pub fn ruby_patch_spec_l89_d25_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "rejects local file patches with URLs" do` at line 95.
pub fn ruby_patch_spec_l95_d26_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "rejects local file patches with sha256" do` at line 104.
pub fn ruby_patch_spec_l104_d27_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "accepts local file patches with directory" do` at line 113.
pub fn ruby_patch_spec_l113_d28_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "rejects local file patches with apply" do` at line 123.
pub fn ruby_patch_spec_l123_d29_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "extracts and normalises CVE identifiers from strings" do` at line 134.
pub fn ruby_patch_spec_l134_d30_extracts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extracts', ...args)
}

// Ruby it `it "returns an empty array when nothing matches" do` at line 144.
pub fn ruby_patch_spec_l144_d31_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "classifies CVE, GHSA and OSV identifiers as security and everything else as defect" do` at line 150.
pub fn ruby_patch_spec_l150_d32_classifies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('classifies', ...args)
}

// Ruby it `it "allows targets that stay within the source tree" do` at line 159.
pub fn ruby_patch_spec_l159_d33_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "allows /dev/null headers for added or deleted files" do` at line 175.
pub fn ruby_patch_spec_l175_d34_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "allows a context diff whose selected target stays within the source tree" do` at line 188.
pub fn ruby_patch_spec_l188_d35_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "rejects an Index header that escapes via `..`", :needs_macos do` at line 206.
pub fn ruby_patch_spec_l206_d36_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby it `it "merges explicit resolves with CVEs inferred from url and apply paths" do` at line 222.
pub fn ruby_patch_spec_l222_d37_merges(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merges', ...args)
}

// Ruby it `it "carries explicit resolves through to a local file patch and infers from the file path" do` at line 231.
pub fn ruby_patch_spec_l231_d38_carries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('carries', ...args)
}

// Ruby it `it "stores a valid type on an external patch" do` at line 241.
pub fn ruby_patch_spec_l241_d39_stores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stores', ...args)
}

// Ruby it `it "carries type through to a local file patch" do` at line 249.
pub fn ruby_patch_spec_l249_d40_carries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('carries', ...args)
}

// Ruby it `it "rejects invalid types" do` at line 257.
pub fn ruby_patch_spec_l257_d41_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejects', ...args)
}

// Ruby subject `subject(:patch) { described_class.create(:p2, nil) }` at line 268.
pub fn ruby_patch_spec_l268_d42_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch', ...args)
}

// Ruby it `it(:resource) { expect(patch.resource).to be_a Resource::Patch }` at line 271.
pub fn ruby_patch_spec_l271_d43_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resource', ...args)
}

// Ruby specify `specify(:aggregate_failures) do` at line 273.
pub fn ruby_patch_spec_l273_d44_aggregate_failures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aggregate_failures', ...args)
}

// Ruby it `it "returns applied patch files" do` at line 279.
pub fn ruby_patch_spec_l279_d45_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby subject `subject(:patch) { described_class.new(:p1) { url "file:///my.patch" } }` at line 295.
pub fn ruby_patch_spec_l295_d46_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch', ...args)
}

// Ruby it `it(:url) { expect(patch.url).to eq("file:///my.patch") }` at line 298.
pub fn ruby_patch_spec_l298_d47_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby it `it(:inspect) { expect(patch.inspect).to eq('#<ExternalPatch: :p1 "file:///my.patch">') }` at line 302.
pub fn ruby_patch_spec_l302_d48_inspect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inspect', ...args)
}

// Ruby it `it(:cached_download) { expect(patch.cached_download).to eq("/tmp/foo.tar.gz") }` at line 310.
pub fn ruby_patch_spec_l310_d49_cached_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cached_download', ...args)
}

// Ruby it `it "applies a patch whose target stays within the source tree" do` at line 315.
pub fn ruby_patch_spec_l315_d50_applies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('applies', ...args)
}

// Ruby it `it "refuses to apply a patch whose target escapes the source tree" do` at line 332.
pub fn ruby_patch_spec_l332_d51_refuses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('refuses', ...args)
}

// Ruby it `it "does not let a Perforce target escape the source tree" do` at line 348.
pub fn ruby_patch_spec_l348_d52_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not let a standard target escape the source tree" do` at line 363.
pub fn ruby_patch_spec_l363_d53_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not let an absolute target escape the source tree" do` at line 379.
pub fn ruby_patch_spec_l379_d54_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not let one escaping target in a multi-file patch escape the source tree" do` at line 397.
pub fn ruby_patch_spec_l397_d55_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "patch"
// 5:
// 6: RSpec.describe Patch do
// 7:   describe "#create" do
// 8:     context "with a simple patch" do
// 9:       subject(:patch) { described_class.create(:p2, nil) }
// 10:
// 11:       specify(:aggregate_failures) do
// 12:         expect(patch).to be_a ExternalPatch
// 13:         expect(patch).to be_external
// 14:       end
// 15:
// 16:       it(:strip) { expect(patch.strip).to eq(:p2) }
// 17:     end
// 18:
// 19:     context "with a string patch" do
// 20:       subject(:patch) { described_class.create(:p0, "foo") }
// 21:
// 22:       it { is_expected.to be_a StringPatch }
// 23:       it(:strip) { expect(patch.strip).to eq(:p0) }
// 24:     end
// 25:
// 26:     context "with a string patch without strip" do
// 27:       subject(:patch) { described_class.create("foo", nil) }
// 28:
// 29:       it { is_expected.to be_a StringPatch }
// 30:       it(:strip) { expect(patch.strip).to eq(:p1) }
// 31:     end
// 32:
// 33:     context "with a data patch" do
// 34:       subject(:patch) { described_class.create(:p0, :DATA) }
// 35:
// 36:       it { is_expected.to be_a DATAPatch }
// 37:       it(:strip) { expect(patch.strip).to eq(:p0) }
// 38:     end
// 39:
// 40:     context "with a data patch without strip" do
// 41:       subject(:patch) { described_class.create(:DATA, nil) }
// 42:
// 43:       it { is_expected.to be_a DATAPatch }
// 44:       it(:strip) { expect(patch.strip).to eq(:p1) }
// 45:     end
// 46:
// 47:     context "with a local file patch" do
// 48:       subject(:patch) { described_class.create(:p0, nil) { file "Patches/foo.diff" } }
// 49:
// 50:       specify(:aggregate_failures) do
// 51:         expect(patch).to be_a LocalPatch
// 52:         expect(patch).not_to be_external
// 53:       end
// 54:
// 55:       it(:strip) { expect(patch.strip).to eq(:p0) }
// 56:       it(:inspect) { expect(patch.inspect).to eq('#<LocalPatch: :p0 "Patches/foo.diff">') }
// 57:     end
// 58:
// 59:     it "rejects blank local file patch paths" do
// 60:       expect do
// 61:         described_class.create(:p1, nil) { file "" }
// 62:       end.to raise_error(ArgumentError, "Patch file must be a relative path within the repository.")
// 63:     end
// 64:
// 65:     it "rejects current directory local file patch paths" do
// 66:       expect do
// 67:         described_class.create(:p1, nil) { file "." }
// 68:       end.to raise_error(ArgumentError, "Patch file must be a relative path within the repository.")
// 69:     end
// 70:
// 71:     it "rejects parent directory local file patch paths" do
// 72:       expect do
// 73:         described_class.create(:p1, nil) { file ".." }
// 74:       end.to raise_error(ArgumentError, "Patch file must be a relative path within the repository.")
// 75:     end
// 76:
// 77:     it "rejects local file patch paths ending in a slash" do
// 78:       expect do
// 79:         described_class.create(:p1, nil) { file "Patches/" }
// 80:       end.to raise_error(ArgumentError, "Patch file must be a relative path within the repository.")
// 81:     end
// 82:
// 83:     it "rejects local file patches outside the repository" do
// 84:       expect do
// 85:         described_class.create(:p1, nil) { file "../foo.diff" }
// 86:       end.to raise_error(ArgumentError, "Patch file must be a relative path within the repository.")
// 87:     end
// 88:
// 89:     it "rejects absolute local file patches" do
// 90:       expect do
// 91:         described_class.create(:p1, nil) { file "/tmp/foo.diff" }
// 92:       end.to raise_error(ArgumentError, "Patch file must be a relative path within the repository.")
// 93:     end
// 94:
// 95:     it "rejects local file patches with URLs" do
// 96:       expect do
// 97:         described_class.create(:p1, nil) do
// 98:           file "Patches/foo.diff"
// 99:           url "https://brew.sh/foo.diff"
// 100:         end
// 101:       end.to raise_error(ArgumentError, "Patch cannot have both `file` and `url`.")
// 102:     end
// 103:
// 104:     it "rejects local file patches with sha256" do
// 105:       expect do
// 106:         described_class.create(:p1, nil) do
// 107:           file "Patches/foo.diff"
// 108:           sha256 "63376b8fdd6613a91976106d9376069274191860cd58f039b29ff16de1925621"
// 109:         end
// 110:       end.to raise_error(ArgumentError, "Patch cannot use `sha256` with `file`.")
// 111:     end
// 112:
// 113:     it "accepts local file patches with directory" do
// 114:       patch = described_class.create(:p1, nil) do
// 115:         file "Patches/foo.diff"
// 116:         directory "subdir"
// 117:       end
// 118:
// 119:       expect(patch).to be_a LocalPatch
// 120:       expect(T.cast(patch, LocalPatch).directory).to eq("subdir")
// 121:     end
// 122:
// 123:     it "rejects local file patches with apply" do
// 124:       expect do
// 125:         described_class.create(:p1, nil) do
// 126:           file "Patches/foo.diff"
// 127:           apply "foo.diff"
// 128:         end
// 129:       end.to raise_error(ArgumentError, "Patch cannot use `apply` with `file`.")
// 130:     end
// 131:   end
// 132:
// 133:   describe ".extract_cves" do
// 134:     it "extracts and normalises CVE identifiers from strings" do
// 135:       result = described_class.extract_cves(
// 136:         "patches/any/CVE-2024-2961.patch",
// 137:         "patches/28-cve-2022-0529-and-cve-2022-0530.patch",
// 138:         "patches/any/CVE-2024-33601_33602.patch",
// 139:         "https://example.com/fix.diff",
// 140:       )
// 141:       expect(result).to eq(%w[CVE-2024-2961 CVE-2022-0529 CVE-2022-0530 CVE-2024-33601])
// 142:     end
// 143:
// 144:     it "returns an empty array when nothing matches" do
// 145:       expect(described_class.extract_cves("foo", "bar.patch")).to eq([])
// 146:     end
// 147:   end
// 148:
// 149:   describe ".resolves_type" do
// 150:     it "classifies CVE, GHSA and OSV identifiers as security and everything else as defect" do
// 151:       expect(described_class.resolves_type("CVE-2024-1234")).to eq("security")
// 152:       expect(described_class.resolves_type("GHSA-xr7r-f8xq-vfvv")).to eq("security")
// 153:       expect(described_class.resolves_type("OSV-2023-298")).to eq("security")
// 154:       expect(described_class.resolves_type("https://github.com/foo/bar/issues/1")).to eq("defect")
// 155:     end
// 156:   end
// 157:
// 158:   describe ".ensure_targets_within!" do
// 159:     it "allows targets that stay within the source tree" do
// 160:       mktmpdir do |base|
// 161:         (base/"src").mkpath
// 162:         (base/"src/foo.c").write("old\n")
// 163:         patch = <<~EOS
// 164:           --- a/src/foo.c
// 165:           +++ b/src/foo.c
// 166:           @@ -1 +1 @@
// 167:           -old
// 168:           +new
// 169:         EOS
// 170:
// 171:         expect { described_class.ensure_targets_within!(patch, strip: :p1, base:) }.not_to raise_error
// 172:       end
// 173:     end
// 174:
// 175:     it "allows /dev/null headers for added or deleted files" do
// 176:       mktmpdir do |base|
// 177:         patch = <<~EOS
// 178:           --- /dev/null
// 179:           +++ b/new.c
// 180:           @@ -0,0 +1 @@
// 181:           +new
// 182:         EOS
// 183:
// 184:         expect { described_class.ensure_targets_within!(patch, strip: :p1, base:) }.not_to raise_error
// 185:       end
// 186:     end
// 187:
// 188:     it "allows a context diff whose selected target stays within the source tree" do
// 189:       mktmpdir do |base|
// 190:         (base/"lib/sh").mkpath
// 191:         (base/"lib/sh/foo.c").write("old\n")
// 192:         patch = <<~EOS
// 193:           *** ../pkg-1.0-patched/lib/sh/foo.c	2024-01-01
// 194:           --- lib/sh/foo.c	2024-01-01
// 195:           ***************
// 196:           *** 1 ****
// 197:           ! old
// 198:           --- 1 ----
// 199:           ! new
// 200:         EOS
// 201:
// 202:         expect { described_class.ensure_targets_within!(patch, strip: :p0, base:) }.not_to raise_error
// 203:       end
// 204:     end
// 205:
// 206:     it "rejects an Index header that escapes via `..`", :needs_macos do
// 207:       mktmpdir do |base|
// 208:         patch = <<~EOS
// 209:           Index: a/../escape.txt
// 210:           ===================================================================
// 211:           @@ -0,0 +1 @@
// 212:           +owned
// 213:         EOS
// 214:
// 215:         expect { described_class.ensure_targets_within!(patch, strip: :p1, base:) }
// 216:           .to raise_error(/escapes the staged source tree/)
// 217:       end
// 218:     end
// 219:   end
// 220:
// 221:   describe "#resolves" do
// 222:     it "merges explicit resolves with CVEs inferred from url and apply paths" do
// 223:       patch = T.cast(described_class.create(:p1, nil) do
// 224:         url "https://example.com/CVE-2024-1111.patch"
// 225:         apply "patches/cve-2024-2222.patch"
// 226:         resolves "CVE-2024-3333"
// 227:       end, ExternalPatch)
// 228:       expect(patch.resolves).to eq(["CVE-2024-3333", "CVE-2024-1111", "CVE-2024-2222"])
// 229:     end
// 230:
// 231:     it "carries explicit resolves through to a local file patch and infers from the file path" do
// 232:       patch = T.cast(described_class.create(:p1, nil) do
// 233:         file "Patches/CVE-2024-1234.diff"
// 234:         resolves "CVE-2024-5678"
// 235:       end, LocalPatch)
// 236:       expect(patch.resolves).to eq(["CVE-2024-5678", "CVE-2024-1234"])
// 237:     end
// 238:   end
// 239:
// 240:   describe "#type" do
// 241:     it "stores a valid type on an external patch" do
// 242:       patch = T.cast(described_class.create(:p1, nil) do
// 243:         url "https://example.com/foo.diff"
// 244:         type :backport
// 245:       end, ExternalPatch)
// 246:       expect(patch.type).to eq(:backport)
// 247:     end
// 248:
// 249:     it "carries type through to a local file patch" do
// 250:       patch = T.cast(described_class.create(:p1, nil) do
// 251:         file "Patches/foo.diff"
// 252:         type :unofficial
// 253:       end, LocalPatch)
// 254:       expect(patch.type).to eq(:unofficial)
// 255:     end
// 256:
// 257:     it "rejects invalid types" do
// 258:       expect do
// 259:         described_class.create(:p1, nil) do
// 260:           url "https://example.com/foo.diff"
// 261:           type :hotfix
// 262:         end
// 263:       end.to raise_error(ArgumentError, /Patch type must be one of/)
// 264:     end
// 265:   end
// 266:
// 267:   describe "#patch_files" do
// 268:     subject(:patch) { described_class.create(:p2, nil) }
// 269:
// 270:     context "when the patch is empty" do
// 271:       it(:resource) { expect(patch.resource).to be_a Resource::Patch }
// 272:
// 273:       specify(:aggregate_failures) do
// 274:         expect(patch.patch_files).to eq(patch.resource.patch_files)
// 275:         expect(patch.patch_files).to eq([])
// 276:       end
// 277:     end
// 278:
// 279:     it "returns applied patch files" do
// 280:       patch.resource.apply("patch1.diff")
// 281:       expect(patch.patch_files).to eq(["patch1.diff"])
// 282:
// 283:       patch.resource.apply("patch2.diff", "patch3.diff")
// 284:       expect(patch.patch_files).to eq(["patch1.diff", "patch2.diff", "patch3.diff"])
// 285:
// 286:       patch.resource.apply(["patch4.diff", "patch5.diff"])
// 287:       expect(patch.patch_files.count).to eq(5)
// 288:
// 289:       patch.resource.apply("patch4.diff", ["patch5.diff", "patch6.diff"], "patch7.diff")
// 290:       expect(patch.patch_files.count).to eq(7)
// 291:     end
// 292:   end
// 293:
// 294:   describe ExternalPatch do
// 295:     subject(:patch) { described_class.new(:p1) { url "file:///my.patch" } }
// 296:
// 297:     describe "#url" do
// 298:       it(:url) { expect(patch.url).to eq("file:///my.patch") }
// 299:     end
// 300:
// 301:     describe "#inspect" do
// 302:       it(:inspect) { expect(patch.inspect).to eq('#<ExternalPatch: :p1 "file:///my.patch">') }
// 303:     end
// 304:
// 305:     describe "#cached_download" do
// 306:       before do
// 307:         allow(patch.resource).to receive(:cached_download).and_return("/tmp/foo.tar.gz")
// 308:       end
// 309:
// 310:       it(:cached_download) { expect(patch.cached_download).to eq("/tmp/foo.tar.gz") }
// 311:     end
// 312:   end
// 313:
// 314:   describe StringPatch do
// 315:     it "applies a patch whose target stays within the source tree" do
// 316:       patch = described_class.new(:p1, <<~EOS)
// 317:         --- a/foo
// 318:         +++ b/foo
// 319:         @@ -1 +1 @@
// 320:         -old
// 321:         +new
// 322:       EOS
// 323:       mktmpdir do |dir|
// 324:         (dir/"source").mkpath
// 325:         (dir/"source/foo").write("old\n")
// 326:         Dir.chdir(dir/"source") { patch.apply }
// 327:
// 328:         expect((dir/"source/foo").read).to eq("new\n")
// 329:       end
// 330:     end
// 331:
// 332:     it "refuses to apply a patch whose target escapes the source tree" do
// 333:       patch = described_class.new(:p1, <<~EOS)
// 334:         Index: a/../evil
// 335:         ===================================================================
// 336:         @@ -0,0 +1 @@
// 337:         +owned
// 338:       EOS
// 339:       mktmpdir do |dir|
// 340:         (dir/"source").mkpath
// 341:         Dir.chdir(dir/"source") do
// 342:           expect { patch.apply }.to raise_error(StandardError)
// 343:         end
// 344:         expect(dir/"evil").not_to exist
// 345:       end
// 346:     end
// 347:
// 348:     it "does not let a Perforce target escape the source tree" do
// 349:       patch = described_class.new(:p1, <<~EOS)
// 350:         ==== a/../evil ====
// 351:         @@ -0,0 +1 @@
// 352:         +owned
// 353:       EOS
// 354:       mktmpdir do |dir|
// 355:         (dir/"source").mkpath
// 356:         Dir.chdir(dir/"source") do
// 357:           expect { patch.apply }.to raise_error(StandardError)
// 358:         end
// 359:         expect(dir/"evil").not_to exist
// 360:       end
// 361:     end
// 362:
// 363:     it "does not let a standard target escape the source tree" do
// 364:       patch = described_class.new(:p1, <<~EOS)
// 365:         --- a/../evil
// 366:         +++ b/../evil
// 367:         @@ -0,0 +1 @@
// 368:         +owned
// 369:       EOS
// 370:       mktmpdir do |dir|
// 371:         (dir/"source").mkpath
// 372:         Dir.chdir(dir/"source") do
// 373:           expect { patch.apply }.to raise_error(StandardError)
// 374:         end
// 375:         expect(dir/"evil").not_to exist
// 376:       end
// 377:     end
// 378:
// 379:     it "does not let an absolute target escape the source tree" do
// 380:       mktmpdir do |dir|
// 381:         (dir/"source").mkpath
// 382:         escape = dir/"evil"
// 383:         patch = described_class.new(:p0, <<~EOS)
// 384:           Index: #{escape}
// 385:           ===================================================================
// 386:           @@ -0,0 +1 @@
// 387:           +owned
// 388:         EOS
// 389:
// 390:         Dir.chdir(dir/"source") do
// 391:           expect { patch.apply }.to raise_error(StandardError)
// 392:         end
// 393:         expect(escape).not_to exist
// 394:       end
// 395:     end
// 396:
// 397:     it "does not let one escaping target in a multi-file patch escape the source tree" do
// 398:       patch = described_class.new(:p1, <<~EOS)
// 399:         --- a/decoy.c
// 400:         +++ b/decoy.c
// 401:         @@ -1 +1 @@
// 402:         -old
// 403:         +new
// 404:         Index: a/../evil
// 405:         ===================================================================
// 406:         @@ -0,0 +1 @@
// 407:         +owned
// 408:       EOS
// 409:       mktmpdir do |dir|
// 410:         (dir/"source").mkpath
// 411:         (dir/"source/decoy.c").write("old\n")
// 412:         Dir.chdir(dir/"source") do
// 413:           expect { patch.apply }.to raise_error(StandardError)
// 414:         end
// 415:         expect(dir/"evil").not_to exist
// 416:       end
// 417:     end
// 418:   end
// 419: end
