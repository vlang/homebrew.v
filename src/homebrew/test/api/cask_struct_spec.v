module api

import brew_runtime

// Translated from Homebrew/brew `test/api/cask_struct_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "constructs a valid struct from a hash with all field types" do` at line 8.
pub fn ruby_cask_struct_spec_l8_d1_constructs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('constructs', ...args)
}

// Ruby it `it "ignores unknown/extra keys" do` at line 39.
pub fn ruby_cask_struct_spec_l39_d2_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "defaults all predicates to false for a minimal struct" do` at line 53.
pub fn ruby_cask_struct_spec_l53_d3_defaults(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('defaults', ...args)
}

// Ruby it `it "returns true when the corresponding _present field is set" do` at line 66.
pub fn ruby_cask_struct_spec_l66_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "replaces placeholders in artifact arguments" do` at line 86.
pub fn ruby_cask_struct_spec_l86_d5_replaces(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replaces', ...args)
}

// Ruby it `it "replaces placeholders in caveats string" do` at line 101.
pub fn ruby_cask_struct_spec_l101_d6_replaces(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replaces', ...args)
}

// Ruby it `it "returns nil when raw_caveats is nil" do` at line 114.
pub fn ruby_cask_struct_spec_l114_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "selects matching locale groups and falls back to the default" do` at line 126.
pub fn ruby_cask_struct_spec_l126_d8_selects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('selects', ...args)
}

// Ruby specify `specify "#serialize_artifact_args", :aggregate_failures do` at line 158.
pub fn ruby_cask_struct_spec_l158_d9_serialize_artifact_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#serialize_artifact_args', ...args)
}

// Ruby it `it "preserves zero values in serialized artifact arguments" do` at line 172.
pub fn ruby_cask_struct_spec_l172_d10_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "preserves false values in serialized artifact arguments" do` at line 198.
pub fn ruby_cask_struct_spec_l198_d11_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby specify `specify "::deserialize_artifact_args", :aggregate_failures do` at line 222.
pub fn ruby_cask_struct_spec_l222_d12_deserialize_artifact_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('::deserialize_artifact_args', ...args)
}

// Ruby it `it "populates predicate fields to false when not specified" do` at line 249.
pub fn ruby_cask_struct_spec_l249_d13_populates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('populates', ...args)
}

// Ruby it `it "populates special predicate fields", :aggregate_failures do` at line 263.
pub fn ruby_cask_struct_spec_l263_d14_populates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('populates', ...args)
}

// Ruby it `it "reconstructs an equivalent struct after serialize then deserialize", :needs_macos do` at line 288.
pub fn ruby_cask_struct_spec_l288_d15_reconstructs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reconstructs', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "api"
// 5:
// 6: RSpec.describe Homebrew::API::CaskStruct do
// 7:   describe "::from_hash" do
// 8:     it "constructs a valid struct from a hash with all field types" do
// 9:       hash = {
// 10:         "sha256"               => "abc123",
// 11:         "version"              => "1.0.0",
// 12:         "ruby_source_checksum" => { sha256: "def456" },
// 13:         "names"                => ["Test Cask"],
// 14:         "desc"                 => "A test cask",
// 15:         "homepage"             => "https://example.com",
// 16:         "auto_updates"         => true,
// 17:         "languages"            => ["en"],
// 18:         "url_args"             => ["https://example.com/file.dmg"],
// 19:         "url_kwargs"           => { user_agent: ":fake" },
// 20:         "conflicts_with_args"  => { cask: ["other-cask"] },
// 21:         "depends_on_args"      => { macos: ">= :catalina" },
// 22:         "container_args"       => { type: :zip },
// 23:         "deprecate_args"       => { date: "2025-01-01", because: :discontinued },
// 24:         "raw_artifacts"        => [[:app, ["Test.app"], {}, nil]],
// 25:         "raw_caveats"          => "Requires restart.",
// 26:       }
// 27:
// 28:       struct = described_class.from_hash(hash)
// 29:
// 30:       expect(struct.sha256).to eq("abc123")
// 31:       expect(struct.version).to eq("1.0.0")
// 32:       expect(struct.names).to eq(["Test Cask"])
// 33:       expect(struct.desc).to eq("A test cask")
// 34:       expect(struct.homepage).to eq("https://example.com")
// 35:       expect(struct.auto_updates).to be(true)
// 36:       expect(struct.languages).to eq(["en"])
// 37:     end
// 38:
// 39:     it "ignores unknown/extra keys" do
// 40:       hash = {
// 41:         "sha256"               => "abc123",
// 42:         "version"              => "1.0.0",
// 43:         "ruby_source_checksum" => { sha256: "def456" },
// 44:         "totally_unknown_key"  => "should be ignored",
// 45:         "another_unknown"      => 42,
// 46:       }
// 47:
// 48:       expect { described_class.from_hash(hash) }.not_to raise_error
// 49:     end
// 50:   end
// 51:
// 52:   describe "predicate methods" do
// 53:     it "defaults all predicates to false for a minimal struct" do
// 54:       struct = described_class.new(
// 55:         sha256:               "abc123",
// 56:         version:              "1.0.0",
// 57:         ruby_source_checksum: { sha256: "def456" },
// 58:       )
// 59:
// 60:       Homebrew::API::CaskStruct::PREDICATES.each do |predicate|
// 61:         expect(struct.public_send(:"#{predicate}?")).to be(false),
// 62:                                                         "expected #{predicate}? to default to false"
// 63:       end
// 64:     end
// 65:
// 66:     it "returns true when the corresponding _present field is set" do
// 67:       present_fields = Homebrew::API::CaskStruct::PREDICATES.to_h do |predicate|
// 68:         [:"#{predicate}_present", true]
// 69:       end
// 70:
// 71:       struct = described_class.new(
// 72:         sha256:               "abc123",
// 73:         version:              "1.0.0",
// 74:         ruby_source_checksum: { sha256: "def456" },
// 75:         **present_fields,
// 76:       )
// 77:
// 78:       Homebrew::API::CaskStruct::PREDICATES.each do |predicate|
// 79:         expect(struct.public_send(:"#{predicate}?")).to be(true),
// 80:                                                         "expected #{predicate}? to be true"
// 81:       end
// 82:     end
// 83:   end
// 84:
// 85:   describe "#artifacts" do
// 86:     it "replaces placeholders in artifact arguments" do
// 87:       struct = described_class.new(
// 88:         sha256:               "abc123",
// 89:         version:              "1.0.0",
// 90:         ruby_source_checksum: { sha256: "def456" },
// 91:         raw_artifacts:        [[:app, ["#{HOMEBREW_CASK_APPDIR_PLACEHOLDER}/Test.app"], {}, nil]],
// 92:       )
// 93:
// 94:       result = struct.artifacts(appdir: "/Applications")
// 95:
// 96:       expect(result).to eq([[:app, ["/Applications/Test.app"], {}, nil]])
// 97:     end
// 98:   end
// 99:
// 100:   describe "#caveats" do
// 101:     it "replaces placeholders in caveats string" do
// 102:       struct = described_class.new(
// 103:         sha256:               "abc123",
// 104:         version:              "1.0.0",
// 105:         ruby_source_checksum: { sha256: "def456" },
// 106:         raw_caveats:          "Installed to #{HOMEBREW_PREFIX_PLACEHOLDER}/bin",
// 107:       )
// 108:
// 109:       result = struct.caveats(appdir: "/Applications")
// 110:
// 111:       expect(result).to eq("Installed to #{HOMEBREW_PREFIX}/bin")
// 112:     end
// 113:
// 114:     it "returns nil when raw_caveats is nil" do
// 115:       struct = described_class.new(
// 116:         sha256:               "abc123",
// 117:         version:              "1.0.0",
// 118:         ruby_source_checksum: { sha256: "def456" },
// 119:       )
// 120:
// 121:       expect(struct.caveats(appdir: "/Applications")).to be_nil
// 122:     end
// 123:   end
// 124:
// 125:   describe "#localise" do
// 126:     it "selects matching locale groups and falls back to the default" do
// 127:       struct = described_class.new(
// 128:         sha256:              "english",
// 129:         version:             "1.0.0",
// 130:         url_args:            ["https://example.com/en.dmg"],
// 131:         language_variations: [
// 132:           {
// 133:             languages: ["zh", "CN"],
// 134:             value:     "zh-CN",
// 135:             overrides: {
// 136:               "sha256"   => "chinese",
// 137:               "url_args" => ["https://example.com/zh.dmg"],
// 138:               "names"    => [":Chinese"],
// 139:             },
// 140:           },
// 141:           { languages: ["en"], default: true, value: "en-US", overrides: {} },
// 142:         ],
// 143:       )
// 144:
// 145:       chinese = struct.localise(["zh-Hans-CN"])
// 146:       default = struct.localise(["fr"])
// 147:
// 148:       expect([
// 149:         [chinese.sha256, chinese.url_args, chinese.names, struct.language(["zh-Hans-CN"])],
// 150:         [default.sha256, default.url_args, struct.language(["fr"])],
// 151:       ]).to eq([
// 152:         ["chinese", ["https://example.com/zh.dmg"], [":Chinese"], "zh-CN"],
// 153:         ["english", ["https://example.com/en.dmg"], "en-US"],
// 154:       ])
// 155:     end
// 156:   end
// 157:
// 158:   specify "#serialize_artifact_args", :aggregate_failures do
// 159:     struct = described_class.new(
// 160:       sha256:               "abc123",
// 161:       version:              "1.0.0",
// 162:       ruby_source_checksum: { sha256: "def456" },
// 163:     )
// 164:
// 165:     expect(struct.serialize_artifact_args([:preflight, [], {}, -> {}]))
// 166:       .to eq([:preflight, [], {}, :empty_block])
// 167:
// 168:     expect(struct.serialize_artifact_args([:preflight, ["foo"], { bar: "baz" }, nil]))
// 169:       .to eq([:preflight, ["foo"], { bar: "baz" }, nil])
// 170:   end
// 171:
// 172:   it "preserves zero values in serialized artifact arguments" do
// 173:     struct = described_class.new(
// 174:       sha256:               "abc123",
// 175:       version:              "1.0.0",
// 176:       ruby_source_checksum: { sha256: "def456" },
// 177:       raw_artifacts:        [
// 178:         [
// 179:           :pkg,
// 180:           ["Test.pkg"],
// 181:           { choices: [{ choiceIdentifier: "choice1", choiceAttribute: "selected", attributeSetting: 0 }] },
// 182:           nil,
// 183:         ],
// 184:       ],
// 185:     )
// 186:
// 187:     expect(struct.serialize.fetch("raw_artifacts"))
// 188:       .to eq([
// 189:         [
// 190:           ":pkg",
// 191:           ["Test.pkg"],
// 192:           { ":choices" => [{ ":choiceIdentifier" => "choice1", ":choiceAttribute" => "selected",
// 193:                              ":attributeSetting" => 0 }] },
// 194:         ],
// 195:       ])
// 196:   end
// 197:
// 198:   it "preserves false values in serialized artifact arguments" do
// 199:     struct = described_class.new(
// 200:       sha256:               "abc123",
// 201:       version:              "1.0.0",
// 202:       ruby_source_checksum: { sha256: "def456" },
// 203:       raw_artifacts:        [
// 204:         [
// 205:           :uninstall,
// 206:           [],
// 207:           { script: { executable: "/usr/bin/pkill", must_succeed: false } },
// 208:           nil,
// 209:         ],
// 210:       ],
// 211:     )
// 212:
// 213:     expect(struct.serialize.fetch("raw_artifacts"))
// 214:       .to eq([
// 215:         [
// 216:           ":uninstall",
// 217:           { ":script" => { ":executable" => "/usr/bin/pkill", ":must_succeed" => false } },
// 218:         ],
// 219:       ])
// 220:   end
// 221:
// 222:   specify "::deserialize_artifact_args", :aggregate_failures do
// 223:     expect(described_class.deserialize_artifact_args([:foo]))
// 224:       .to eq([:foo, [], {}, nil])
// 225:
// 226:     expect(described_class.deserialize_artifact_args([:foo, ["abc", "def"]]))
// 227:       .to eq([:foo, ["abc", "def"], {}, nil])
// 228:
// 229:     expect(described_class.deserialize_artifact_args([:foo, { ghi: "jkl" }]))
// 230:       .to eq([:foo, [], { ghi: "jkl" }, nil])
// 231:
// 232:     expect(described_class.deserialize_artifact_args([:foo, :empty_block]))
// 233:       .to eq([:foo, [], {}, Homebrew::API::CaskStruct::EMPTY_BLOCK])
// 234:
// 235:     expect(described_class.deserialize_artifact_args([:foo, ["abc", "def"], { ghi: "jkl" }]))
// 236:       .to eq([:foo, ["abc", "def"], { ghi: "jkl" }, nil])
// 237:
// 238:     expect(described_class.deserialize_artifact_args([:foo, ["abc", "def"], :empty_block]))
// 239:       .to eq([:foo, ["abc", "def"], {}, Homebrew::API::CaskStruct::EMPTY_BLOCK])
// 240:
// 241:     expect(described_class.deserialize_artifact_args([:foo, { ghi: "jkl" }, :empty_block]))
// 242:       .to eq([:foo, [], { ghi: "jkl" }, Homebrew::API::CaskStruct::EMPTY_BLOCK])
// 243:
// 244:     expect(described_class.deserialize_artifact_args([:foo, ["abc", "def"], { ghi: "jkl" }, :empty_block]))
// 245:       .to eq([:foo, ["abc", "def"], { ghi: "jkl" }, Homebrew::API::CaskStruct::EMPTY_BLOCK])
// 246:   end
// 247:
// 248:   describe "::deserialize" do
// 249:     it "populates predicate fields to false when not specified" do
// 250:       hash = {
// 251:         "sha256"               => "abc123",
// 252:         "version"              => "1.0.0",
// 253:         "ruby_source_checksum" => { sha256: "def456" },
// 254:       }
// 255:
// 256:       struct = described_class.deserialize(hash)
// 257:
// 258:       Homebrew::API::CaskStruct::PREDICATES.each do |predicate|
// 259:         expect(struct.public_send(:"#{predicate}?")).to be false
// 260:       end
// 261:     end
// 262:
// 263:     it "populates special predicate fields", :aggregate_failures do
// 264:       hash = {
// 265:         "auto_updates"         => true,
// 266:         "raw_caveats"          => "Some caveats",
// 267:         "conflicts_with_args"  => { cask: ["other-cask"] },
// 268:         "container_args"       => { type: :zip },
// 269:         "depends_on_args"      => { macos: ">= :catalina" },
// 270:         "deprecate_args"       => { date: "2025-01-01", because: :unmaintained },
// 271:         "desc"                 => "A description",
// 272:         "disable_args"         => { date: "2025-01-01", because: :unmaintained },
// 273:         "homepage"             => "https://example.com",
// 274:         "sha256"               => "abc123",
// 275:         "version"              => "1.0.0",
// 276:         "ruby_source_checksum" => { sha256: "def456" },
// 277:       }
// 278:
// 279:       struct = described_class.deserialize(hash)
// 280:
// 281:       Homebrew::API::CaskStruct::PREDICATES.each do |predicate|
// 282:         expect(struct.public_send(:"#{predicate}?")).to be true
// 283:       end
// 284:     end
// 285:   end
// 286:
// 287:   describe "serialize/deserialize round-trip" do
// 288:     it "reconstructs an equivalent struct after serialize then deserialize", :needs_macos do
// 289:       original = described_class.new(
// 290:         auto_updates:         true,
// 291:         conflicts_with_args:  { cask: ["other-cask"] },
// 292:         container_args:       { nested: nil, type: :zip },
// 293:         depends_on_args:      { macos: ">= :catalina" },
// 294:         deprecate_args:       { date: "2025-01-01", because: :unmaintained },
// 295:         desc:                 "A description",
// 296:         disable_args:         { date: "2025-01-01", because: :unmaintained },
// 297:         homepage:             "https://example.com",
// 298:         languages:            ["en"],
// 299:         names:                ["Test Cask"],
// 300:         raw_artifacts:        [[:app, ["#{HOMEBREW_CASK_APPDIR_PLACEHOLDER}/Test.app"], {}, nil]],
// 301:         raw_caveats:          "Some caveats",
// 302:         renames:              [["Old Name", "New Name"]],
// 303:         ruby_source_checksum: { sha256: "def456" },
// 304:         ruby_source_path:     "/path/to/source",
// 305:         sha256:               "abc123",
// 306:         tap_string:           "homebrew/cask",
// 307:         url_args:             ["https://example.com/file.dmg"],
// 308:         url_kwargs:           { user_agent: ":fake" },
// 309:         version:              "1.0.0",
// 310:       )
// 311:
// 312:       serialized = original.serialize
// 313:       restored = described_class.deserialize(serialized)
// 314:
// 315:       expect(restored).to eq(original)
// 316:     end
// 317:   end
// 318: end
