module api

import ruby
import homebrew.api as brew_api

// Translated from Homebrew/brew `test/api/cask_struct_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "constructs a valid struct from a hash with all field types" do` at line 8.
pub fn ruby_cask_struct_spec_l8_d1_constructs() bool {
	mut hash := cask_struct_spec_minimal_hash()
	hash['names'] = ruby.string_array_value(['Test Cask'])
	hash['desc'] = ruby.string_value('A test cask')
	hash['homepage'] = ruby.string_value('https://example.com')
	hash['auto_updates'] = ruby.bool_value(true)
	hash['languages'] = ruby.string_array_value(['en'])
	hash['url_args'] = ruby.string_array_value(['https://example.com/file.dmg'])
	hash['url_kwargs'] = ruby.map_value({
		'user_agent': ruby.string_value(':fake')
	})
	hash['conflicts_with_args'] = ruby.map_value({
		'cask': ruby.string_array_value(['other-cask'])
	})
	hash['depends_on_args'] = ruby.map_value({
		'macos': ruby.string_value('>= :catalina')
	})
	hash['container_args'] = ruby.map_value({
		'type': ruby.object_value('Symbol', ':zip')
	})
	hash['deprecate_args'] = ruby.map_value({
		'date': ruby.string_value('2025-01-01')
	})
	hash['raw_artifacts'] = ruby.array_value([cask_struct_spec_artifact_value('app', [
		ruby.string_value('Test.app'),
	], {}, false)])
	hash['raw_caveats'] = ruby.string_value('Requires restart.')
	cask := brew_api.cask_struct_from_hash(hash, cask_struct_spec_paths(), false)
	desc := cask.desc or { '' }
	homepage := cask.homepage or { '' }
	return cask.sha256 == 'abc123' && cask.version == '1.0.0' && cask.names == [
		'Test Cask',
	] && desc == 'A test cask' && homepage == 'https://example.com' && cask.auto_updates && cask.languages == [
		'en',
	]
}

// Ruby it `it "ignores unknown/extra keys" do` at line 39.
pub fn ruby_cask_struct_spec_l39_d2_ignores() bool {
	mut hash := cask_struct_spec_minimal_hash()
	hash['totally_unknown_key'] = ruby.string_value('should be ignored')
	hash['another_unknown'] = ruby.int_value(42)
	cask := brew_api.cask_struct_from_hash(hash, cask_struct_spec_paths(), false)
	serialized := cask.serialize()
	return cask.sha256 == 'abc123' && 'totally_unknown_key' !in serialized && 'another_unknown' !in serialized
}

// Ruby it `it "defaults all predicates to false for a minimal struct" do` at line 53.
pub fn ruby_cask_struct_spec_l53_d3_defaults() bool {
	cask := cask_struct_spec_minimal()
	return brew_api.cask_struct_predicate_names.all(!cask.predicate(it))
}

// Ruby it `it "returns true when the corresponding _present field is set" do` at line 66.
pub fn ruby_cask_struct_spec_l66_d4_returns() bool {
	mut hash := cask_struct_spec_minimal_hash()
	for name in brew_api.cask_struct_predicate_names {
		hash['${name}_present'] = ruby.bool_value(true)
	}
	cask := brew_api.cask_struct_from_hash(hash, cask_struct_spec_paths(), false)
	return brew_api.cask_struct_predicate_names.all(cask.predicate(it))
}

// Ruby it `it "replaces placeholders in artifact arguments" do` at line 86.
pub fn ruby_cask_struct_spec_l86_d5_replaces() bool {
	mut hash := cask_struct_spec_minimal_hash()
	hash['raw_artifacts'] = ruby.array_value([cask_struct_spec_artifact_value('app', [
		ruby.string_value('\$APPDIR/Test.app'),
	], {}, false)])
	cask := brew_api.cask_struct_from_hash(hash, cask_struct_spec_paths(), false)
	artifacts := cask.artifacts('/Applications', cask_struct_spec_paths())
	return artifacts.len == 1 && artifacts[0].key == 'app' && artifacts[0].args[0].as_string() == '/Applications/Test.app'
}

// Ruby it `it "replaces placeholders in caveats string" do` at line 101.
pub fn ruby_cask_struct_spec_l101_d6_replaces() bool {
	mut hash := cask_struct_spec_minimal_hash()
	hash['raw_caveats'] = ruby.string_value('Installed to \$HOMEBREW_PREFIX/bin')
	cask := brew_api.cask_struct_from_hash(hash, cask_struct_spec_paths(), false)
	caveats := cask.caveats('/Applications', cask_struct_spec_paths()) or { '' }
	return caveats == 'Installed to /opt/testbrew/bin'
}

// Ruby it `it "returns nil when raw_caveats is nil" do` at line 114.
pub fn ruby_cask_struct_spec_l114_d7_returns() bool {
	return cask_struct_spec_minimal().caveats('/Applications', cask_struct_spec_paths()) == none
}

// Ruby it `it "selects matching locale groups and falls back to the default" do` at line 126.
pub fn ruby_cask_struct_spec_l126_d8_selects() bool {
	mut hash := cask_struct_spec_minimal_hash()
	hash['sha256'] = ruby.string_value('english')
	hash['url_args'] = ruby.string_array_value(['https://example.com/en.dmg'])
	hash['language_variations'] = ruby.array_value([
		ruby.map_value({
			'languages': ruby.string_array_value(['zh', 'CN'])
			'value':     ruby.string_value('zh-CN')
			'overrides': ruby.map_value({
				'sha256':   ruby.string_value('chinese')
				'url_args': ruby.string_array_value(['https://example.com/zh.dmg'])
				'names':    ruby.string_array_value([':Chinese'])
			})
		}),
		ruby.map_value({
			'languages': ruby.string_array_value(['en'])
			'default':   ruby.bool_value(true)
			'value':     ruby.string_value('en-US')
			'overrides': ruby.map_value({})
		}),
	])
	cask := brew_api.cask_struct_from_hash(hash, cask_struct_spec_paths(), false)
	chinese := cask.localise(['zh-Hans-CN'], cask_struct_spec_paths())
	fallback := cask.localise(['fr'], cask_struct_spec_paths())
	chinese_language := cask.language(['zh-Hans-CN']) or { '' }
	fallback_language := cask.language(['fr']) or { '' }
	return chinese.sha256 == 'chinese' && chinese.url_args == [
		'https://example.com/zh.dmg',
	] && chinese.names == [':Chinese'] && chinese_language == 'zh-CN' && fallback.sha256 == 'english' && fallback.url_args == [
		'https://example.com/en.dmg',
	] && fallback_language == 'en-US'
}

// Ruby specify `specify "#serialize_artifact_args", :aggregate_failures do` at line 158.
pub fn ruby_cask_struct_spec_l158_d9_serialize_artifact_args() bool {
	cask := cask_struct_spec_minimal()
	with_block := cask.serialize_artifact_args(brew_api.CaskArtifact{
		key: 'preflight'
		has_block: true
	})
	with_args := cask.serialize_artifact_args(brew_api.CaskArtifact{
		key: 'preflight'
		args: [ruby.string_value('foo')]
		kwargs: {
			'bar': ruby.string_value('baz')
		}
	})
	return with_block.len == 2 && with_block[1].as_string() == ':empty_block' && with_args.len == 3 && with_args[1].array_data[0].as_string() == 'foo' && with_args[2].map_data['bar'].as_string() == 'baz'
}

// Ruby it `it "preserves zero values in serialized artifact arguments" do` at line 172.
pub fn ruby_cask_struct_spec_l172_d10_preserves() bool {
	mut hash := cask_struct_spec_minimal_hash()
	hash['raw_artifacts'] = ruby.array_value([cask_struct_spec_artifact_value('pkg', [
		ruby.string_value('Test.pkg'),
	], {
		':choices': ruby.array_value([
			ruby.map_value({
				':choiceIdentifier': ruby.string_value('choice1')
				':choiceAttribute':  ruby.string_value('selected')
				':attributeSetting': ruby.int_value(0)
			}),
		])
	}, false)])
	serialized := brew_api.cask_struct_from_hash(hash, cask_struct_spec_paths(), false).serialize()
	artifact := serialized['raw_artifacts'].array_data[0].array_data
	setting := artifact[2].map_data[':choices'].array_data[0].map_data[':attributeSetting']
	return setting.type_name == 'Integer' && setting.int_data == 0
}

// Ruby it `it "preserves false values in serialized artifact arguments" do` at line 198.
pub fn ruby_cask_struct_spec_l198_d11_preserves() bool {
	mut hash := cask_struct_spec_minimal_hash()
	hash['raw_artifacts'] = ruby.array_value([cask_struct_spec_artifact_value('uninstall', [], {
		':script': ruby.map_value({
			':executable':   ruby.string_value('/usr/bin/pkill')
			':must_succeed': ruby.bool_value(false)
		})
	}, false)])
	serialized := brew_api.cask_struct_from_hash(hash, cask_struct_spec_paths(), false).serialize()
	artifact := serialized['raw_artifacts'].array_data[0].array_data
	must_succeed := artifact[1].map_data[':script'].map_data[':must_succeed']
	return must_succeed.type_name == 'Bool' && !must_succeed.bool_data
}

// Ruby specify `specify "::deserialize_artifact_args", :aggregate_failures do` at line 222.
pub fn ruby_cask_struct_spec_l222_d12_deserialize_artifact_args() bool {
	key := ruby.object_value('Symbol', ':foo')
	array := ruby.string_array_value(['abc', 'def'])
	hash := ruby.map_value({
		'ghi': ruby.string_value('jkl')
	})
	block := ruby.object_value('Symbol', ':empty_block')
	cases := [
		brew_api.cask_struct_deserialize_artifact_args([key]),
		brew_api.cask_struct_deserialize_artifact_args([key, array]),
		brew_api.cask_struct_deserialize_artifact_args([key, hash]),
		brew_api.cask_struct_deserialize_artifact_args([key, block]),
		brew_api.cask_struct_deserialize_artifact_args([key, array, hash]),
		brew_api.cask_struct_deserialize_artifact_args([key, array, block]),
		brew_api.cask_struct_deserialize_artifact_args([key, hash, block]),
		brew_api.cask_struct_deserialize_artifact_args([key, array, hash, block]),
	]
	return cases.all(it.key == 'foo') && cases[0].args.len == 0 && cases[0].kwargs.len == 0 && cases[1].args.len == 2 && cases[2].kwargs['ghi'].as_string() == 'jkl' && cases[3].has_block && cases[4].args.len == 2 && cases[4].kwargs.len == 1 && cases[5].has_block && cases[5].args.len == 2 && cases[6].has_block && cases[6].kwargs.len == 1 && cases[7].has_block && cases[7].args.len == 2 && cases[7].kwargs.len == 1
}

// Ruby it `it "populates predicate fields to false when not specified" do` at line 249.
pub fn ruby_cask_struct_spec_l249_d13_populates() bool {
	cask := brew_api.cask_struct_deserialize(cask_struct_spec_minimal_hash(), cask_struct_spec_paths())
	return brew_api.cask_struct_predicate_names.all(!cask.predicate(it))
}

// Ruby it `it "populates special predicate fields", :aggregate_failures do` at line 263.
pub fn ruby_cask_struct_spec_l263_d14_populates() bool {
	mut hash := cask_struct_spec_minimal_hash()
	hash['auto_updates'] = ruby.bool_value(true)
	hash['raw_caveats'] = ruby.string_value('Some caveats')
	hash['conflicts_with_args'] = ruby.map_value({
		'cask': ruby.string_array_value(['other-cask'])
	})
	hash['container_args'] = ruby.map_value({
		'type': ruby.object_value('Symbol', ':zip')
	})
	hash['depends_on_args'] = ruby.map_value({
		'macos': ruby.string_value('>= :catalina')
	})
	hash['deprecate_args'] = ruby.map_value({
		'date': ruby.string_value('2025-01-01')
	})
	hash['desc'] = ruby.string_value('A description')
	hash['disable_args'] = ruby.map_value({
		'date': ruby.string_value('2025-01-01')
	})
	hash['homepage'] = ruby.string_value('https://example.com')
	cask := brew_api.cask_struct_deserialize(hash, cask_struct_spec_paths())
	return brew_api.cask_struct_predicate_names.all(cask.predicate(it))
}

// Ruby it `it "reconstructs an equivalent struct after serialize then deserialize", :needs_macos do` at line 288.
pub fn ruby_cask_struct_spec_l288_d15_reconstructs() bool {
	original := cask_struct_spec_round_trip()
	restored := brew_api.cask_struct_deserialize(original.serialize(), cask_struct_spec_paths())
	return restored.equals(original)
}

fn cask_struct_spec_paths() brew_api.ApiStructPaths {
	return brew_api.ApiStructPaths{
		prefix: '/opt/testbrew'
		cellar: '/opt/testbrew/Cellar'
		home: '/Users/tester'
		appdir: '/Applications'
	}
}

fn cask_struct_spec_minimal_hash() map[string]ruby.Value {
	return {
		'sha256':               ruby.string_value('abc123')
		'version':              ruby.string_value('1.0.0')
		'ruby_source_checksum': ruby.map_value({
			'sha256': ruby.string_value('def456')
		})
	}
}

fn cask_struct_spec_minimal() brew_api.CaskStruct {
	return brew_api.cask_struct_from_hash(cask_struct_spec_minimal_hash(), cask_struct_spec_paths(), false)
}

fn cask_struct_spec_artifact_value(key string, args []ruby.Value,
	kwargs map[string]ruby.Value, has_block bool) ruby.Value {
	return ruby.array_value([
		ruby.object_value('Symbol', ':${key}'),
		ruby.array_value(args),
		ruby.map_value(kwargs),
		if has_block {
			ruby.object_value('Symbol', ':empty_block')
		} else {
			ruby.object_value('NilClass', '')
		},
	])
}

fn cask_struct_spec_round_trip() brew_api.CaskStruct {
	mut hash := cask_struct_spec_minimal_hash()
	hash['auto_updates'] = ruby.bool_value(true)
	hash['conflicts_with_args'] = ruby.map_value({
		'cask': ruby.string_array_value(['other-cask'])
	})
	hash['container_args'] = ruby.map_value({
		'nested': ruby.object_value('NilClass', '')
		'type':   ruby.object_value('Symbol', ':zip')
	})
	hash['depends_on_args'] = ruby.map_value({
		'macos': ruby.string_value('>= :catalina')
	})
	hash['deprecate_args'] = ruby.map_value({
		'date': ruby.string_value('2025-01-01')
	})
	hash['desc'] = ruby.string_value('A description')
	hash['disable_args'] = ruby.map_value({
		'date': ruby.string_value('2025-01-01')
	})
	hash['homepage'] = ruby.string_value('https://example.com')
	hash['languages'] = ruby.string_array_value(['en'])
	hash['names'] = ruby.string_array_value(['Test Cask'])
	hash['raw_artifacts'] = ruby.array_value([cask_struct_spec_artifact_value('app', [
		ruby.string_value('\$APPDIR/Test.app'),
	], {}, false)])
	hash['raw_caveats'] = ruby.string_value('Some caveats')
	hash['renames'] = ruby.array_value([ruby.string_array_value([
		'Old Name',
		'New Name',
	])])
	hash['ruby_source_path'] = ruby.string_value('/path/to/source')
	hash['tap_string'] = ruby.string_value('homebrew/cask')
	hash['url_args'] = ruby.string_array_value(['https://example.com/file.dmg'])
	hash['url_kwargs'] = ruby.map_value({
		'user_agent': ruby.string_value(':fake')
	})
	return brew_api.cask_struct_from_hash(hash, cask_struct_spec_paths(), false)
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
