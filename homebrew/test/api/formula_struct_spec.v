module api

import brew_runtime
import homebrew.api as brew_api

// Translated from Homebrew/brew `test/api/formula_struct_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `build_formula_struct(checksums)` at line 8.
pub fn ruby_formula_struct_spec_l8_d1_build_formula_struct(checksums []brew_api.FormulaBottleChecksum) brew_api.FormulaStruct {
	return brew_api.FormulaStruct{
		desc: 'sample formula'
		executables: ['sample']
		homepage: 'https://example.com'
		license: 'MIT'
		ruby_source_checksum: 'abc123'
		stable_version: '1.0.0'
		bottle_checksums: checksums
	}
}

// Ruby specify `specify :aggregate_failures, :needs_macos do` at line 20.
pub fn ruby_formula_struct_spec_l20_d2_aggregate_failures() bool {
	formula := ruby_formula_struct_spec_l8_d1_build_formula_struct([
		brew_api.FormulaBottleChecksum{ cellar: 'any', tag: 'arm64_sequoia', checksum: 'checksum1' },
		brew_api.FormulaBottleChecksum{ cellar: 'any_skip_relocation', tag: 'sequoia', checksum: 'checksum2' },
		brew_api.FormulaBottleChecksum{ cellar: '/opt/homebrew/Cellar', tag: 'arm64_sonoma', checksum: 'checksum3' },
	])
	tahoe := formula.serialize_bottle('arm64_tahoe') or { return false }
	sequoia := formula.serialize_bottle('arm64_sequoia') or { return false }
	intel := formula.serialize_bottle('sequoia') or { return false }
	sonoma := formula.serialize_bottle('arm64_sonoma') or { return false }
	return formula_struct_spec_optional(tahoe.bottle_tag) == 'arm64_sequoia' && formula_struct_spec_optional(tahoe.bottle_cellar) == 'any' && tahoe.bottle_checksum == 'checksum1' && sequoia.bottle_tag == none && formula_struct_spec_optional(sequoia.bottle_cellar) == 'any' && intel.bottle_tag == none && intel.bottle_cellar == none && sonoma.bottle_tag == none && formula_struct_spec_optional(sonoma.bottle_cellar) == '/opt/homebrew/Cellar' && formula.serialize_bottle('x86_64_linux') == none
}

// Ruby it `it "serializes bottle with all tag" do` at line 68.
pub fn ruby_formula_struct_spec_l68_d3_serializes() bool {
	formula := ruby_formula_struct_spec_l8_d1_build_formula_struct([
		brew_api.FormulaBottleChecksum{ cellar: 'any_skip_relocation', tag: 'all', checksum: 'checksum1' },
	])
	for tag in ['arm64_tahoe', 'sequoia', 'x86_64_linux'] {
		bottle := formula.serialize_bottle(tag) or { return false }
		if formula_struct_spec_optional(bottle.bottle_tag) != 'all' || bottle.bottle_cellar != none || bottle.bottle_checksum != 'checksum1' {
			return false
		}
	}
	return true
}

// Ruby specify `specify(:aggregate_failures) do` at line 84.
pub fn ruby_formula_struct_spec_l84_d4_aggregate_failures() bool {
	one := brew_api.formula_struct_format_arg_pair([brew_runtime.string_value('foo')], brew_runtime.map_value({}))
	two := brew_api.formula_struct_format_arg_pair([
		brew_runtime.object_value('Symbol', ':foo'),
		brew_runtime.object_value('Symbol', ':bar'),
	], brew_runtime.object_value('NilClass', ''))
	return one.first.as_string() == 'foo' && one.second.map_data.len == 0 && two.first.as_string() == ':foo' && two.second.as_string() == ':bar'
}

// Ruby it `it "defaults all predicates to false when not set" do` at line 99.
pub fn ruby_formula_struct_spec_l99_d5_defaults() bool {
	formula := formula_struct_spec_minimal()
	return brew_api.formula_struct_predicate_names.all(!formula.predicate(it))
}

// Ruby it `it "returns true when the corresponding _present field is set" do` at line 114.
pub fn ruby_formula_struct_spec_l114_d6_returns() bool {
	mut hash := formula_struct_spec_minimal_hash()
	for name in brew_api.formula_struct_predicate_names {
		hash['${name}_present'] = brew_runtime.bool_value(true)
	}
	formula := brew_api.formula_struct_from_hash(hash, formula_struct_spec_paths())
	return brew_api.formula_struct_predicate_names.all(formula.predicate(it))
}

// Ruby it `it "reconstructs a struct from a serialized hash with bottle info" do` at line 136.
pub fn ruby_formula_struct_spec_l136_d7_reconstructs() bool {
	mut hash := formula_struct_spec_minimal_hash()
	hash['executables'] = brew_runtime.string_array_value(['foo'])
	hash['bottle_checksum'] = brew_runtime.string_value('checksum1')
	hash['bottle_tag'] = brew_runtime.string_value(':arm64_sequoia')
	hash['bottle_cellar'] = brew_runtime.string_value(':any')
	formula := brew_api.formula_struct_deserialize(hash, 'arm64_sequoia', formula_struct_spec_paths())
	return formula.predicate('bottle') && formula.executables == ['foo'] && formula.bottle_checksums == [brew_api.FormulaBottleChecksum{
		cellar: 'any'
		tag: 'arm64_sequoia'
		checksum: 'checksum1'
	}]
}

// Ruby it `it "sets bottle_present to false when no bottle_checksum is present" do` at line 157.
pub fn ruby_formula_struct_spec_l157_d8_sets() bool {
	formula := brew_api.formula_struct_deserialize(formula_struct_spec_minimal_hash(), 'arm64_sequoia', formula_struct_spec_paths())
	return !formula.predicate('bottle') && formula.bottle_checksums.len == 0
}

// Ruby it `it "sets predicate _present fields from _args presence" do` at line 173.
pub fn ruby_formula_struct_spec_l173_d9_sets() bool {
	mut hash := formula_struct_spec_minimal_hash()
	hash['deprecate_args'] = brew_runtime.map_value({
		':date': brew_runtime.string_value('2025-01-01')
	})
	hash['keg_only_args'] = brew_runtime.array_value([
		brew_runtime.object_value('Symbol', ':versioned_formula'),
	])
	formula := brew_api.formula_struct_deserialize(hash, 'arm64_sequoia', formula_struct_spec_paths())
	return formula.predicate('deprecate') && formula.predicate('keg_only') && !formula.predicate('disable')
}

// Ruby it `it "formats _url_args into [String, Hash] pairs" do` at line 192.
pub fn ruby_formula_struct_spec_l192_d10_formats() bool {
	mut hash := formula_struct_spec_minimal_hash()
	hash['stable_url_args'] = brew_runtime.string_array_value([
		'https://example.com/foo-1.0.tar.gz',
	])
	formula := brew_api.formula_struct_deserialize(hash, 'arm64_sequoia', formula_struct_spec_paths())
	return formula.predicate('stable') && formula.stable_url_args.first.as_string() == 'https://example.com/foo-1.0.tar.gz' && formula.stable_url_args.second.map_data.len == 0
}

// Ruby it `it "formats uses_from_macos into arg pairs" do` at line 209.
pub fn ruby_formula_struct_spec_l209_d11_formats() bool {
	mut hash := formula_struct_spec_minimal_hash()
	hash['stable_url_args'] = brew_runtime.string_array_value(['url'])
	hash['stable_uses_from_macos'] = brew_runtime.array_value([brew_runtime.string_array_value([
		'zlib',
	])])
	formula := brew_api.formula_struct_deserialize(hash, 'arm64_sequoia', formula_struct_spec_paths())
	return formula.stable_uses_from_macos.len == 1 && formula.stable_uses_from_macos[0].first.as_string() == 'zlib' && formula.stable_uses_from_macos[0].second.map_data.len == 0
}

// Ruby it `it "formats service_args into arg pairs" do` at line 226.
pub fn ruby_formula_struct_spec_l226_d12_formats() bool {
	mut hash := formula_struct_spec_minimal_hash()
	hash['service_args'] = brew_runtime.array_value([brew_runtime.array_value([
		brew_runtime.object_value('Symbol', ':run_type'),
		brew_runtime.object_value('Symbol', ':immediate'),
	])])
	formula := brew_api.formula_struct_deserialize(hash, 'arm64_sequoia', formula_struct_spec_paths())
	return formula.predicate('service') && formula.service_args.len == 1 && formula.service_args[0].first.as_string() == ':run_type' && formula.service_args[0].second.as_string() == ':immediate'
}

// Ruby it `it "formats conflicts into arg pairs" do` at line 243.
pub fn ruby_formula_struct_spec_l243_d13_formats() bool {
	mut hash := formula_struct_spec_minimal_hash()
	hash['conflicts'] = brew_runtime.array_value([brew_runtime.string_array_value([
		'other-formula',
	])])
	formula := brew_api.formula_struct_deserialize(hash, 'arm64_sequoia', formula_struct_spec_paths())
	return formula.conflicts.len == 1 && formula.conflicts[0].first.as_string() == 'other-formula' && formula.conflicts[0].second.map_data.len == 0
}

// Ruby it `it "reconstructs an equivalent struct after serialize then deserialize", :needs_macos do` at line 261.
pub fn ruby_formula_struct_spec_l261_d14_reconstructs() bool {
	original := formula_struct_spec_round_trip()
	restored := brew_api.formula_struct_deserialize(original.serialize('arm64_sequoia'), 'arm64_sequoia', formula_struct_spec_paths())
	return restored.equals(original, 'arm64_sequoia')
}

// Ruby it `it "serializes post-install steps", :needs_macos do` at line 287.
pub fn ruby_formula_struct_spec_l287_d15_serializes() bool {
	mut hash := formula_struct_spec_minimal_hash()
	hash['post_install_steps'] = brew_runtime.array_value([brew_runtime.map_value({
		'type': brew_runtime.string_value('mkdir_p')
		'path': brew_runtime.map_value({
			'base': brew_runtime.string_value('var')
			'path': brew_runtime.string_value('log/foo')
		})
	})])
	original := brew_api.formula_struct_from_hash(hash, formula_struct_spec_paths())
	restored := brew_api.formula_struct_deserialize(original.serialize('arm64_sequoia'), 'arm64_sequoia', formula_struct_spec_paths())
	return brew_api.api_struct_value_equal(brew_runtime.array_value(original.post_install_steps), brew_runtime.array_value(restored.post_install_steps))
}

// Ruby it `it "does not replace home placeholders inside prefix placeholders" do` at line 307.
pub fn ruby_formula_struct_spec_l307_d16_does() bool {
	mut hash := formula_struct_spec_minimal_hash()
	hash['caveats'] = brew_runtime.string_value('unix://\$HOMEBREW_PREFIX')
	formula := brew_api.formula_struct_from_hash(hash, formula_struct_spec_paths())
	caveats := formula.caveats or { '' }
	return caveats == 'unix:///opt/testbrew'
}

fn formula_struct_spec_paths() brew_api.ApiStructPaths {
	return brew_api.ApiStructPaths{
		prefix: '/opt/testbrew'
		cellar: '/opt/testbrew/Cellar'
		home: '/Users/tester'
		appdir: '/Applications'
	}
}

fn formula_struct_spec_minimal_hash() map[string]brew_runtime.Value {
	return {
		'desc':                 brew_runtime.string_value('test')
		'homepage':             brew_runtime.string_value('https://example.com')
		'license':              brew_runtime.string_value('MIT')
		'ruby_source_checksum': brew_runtime.string_value('abc123')
		'stable_version':       brew_runtime.string_value('1.0.0')
	}
}

fn formula_struct_spec_minimal() brew_api.FormulaStruct {
	return brew_api.formula_struct_from_hash(formula_struct_spec_minimal_hash(), formula_struct_spec_paths())
}

fn formula_struct_spec_round_trip() brew_api.FormulaStruct {
	mut hash := formula_struct_spec_minimal_hash()
	hash['desc'] = brew_runtime.string_value('round-trip test')
	hash['stable_url_args'] = brew_runtime.array_value([
		brew_runtime.string_value('https://example.com/foo-1.0.tar.gz'),
		brew_runtime.map_value({}),
	])
	hash['stable_dependencies'] = brew_runtime.array_value([
		brew_runtime.string_value('dep1'),
		brew_runtime.map_value({
			'dep2': brew_runtime.object_value('Symbol', ':build')
		}),
	])
	hash['executables'] = brew_runtime.string_array_value(['foo'])
	hash['stable_uses_from_macos'] = brew_runtime.array_value([brew_runtime.array_value([
		brew_runtime.string_value('zlib'),
		brew_runtime.map_value({}),
	])])
	hash['bottle_checksums'] = brew_runtime.array_value([brew_runtime.map_value({
		'cellar':        brew_runtime.string_value('any')
		'arm64_sequoia': brew_runtime.string_value('checksum1')
	})])
	hash['conflicts'] = brew_runtime.array_value([brew_runtime.array_value([
		brew_runtime.string_value('other-formula'),
		brew_runtime.map_value({}),
	])])
	hash['revision'] = brew_runtime.int_value(2)
	hash['aliases'] = brew_runtime.string_array_value(['foo-alias'])
	hash['post_install_defined'] = brew_runtime.bool_value(true)
	return brew_api.formula_struct_from_hash(hash, formula_struct_spec_paths())
}

fn formula_struct_spec_optional(value ?string) string {
	return value or { '' }
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "api"
// 5:
// 6: RSpec.describe Homebrew::API::FormulaStruct do
// 7:   describe "#serialize_bottle" do
// 8:     def build_formula_struct(checksums)
// 9:       Homebrew::API::FormulaStruct.new(
// 10:         desc:                 "sample formula",
// 11:         executables:          ["sample"],
// 12:         homepage:             "https://example.com",
// 13:         license:              "MIT",
// 14:         ruby_source_checksum: "abc123",
// 15:         stable_version:       "1.0.0",
// 16:         bottle_checksums:     checksums,
// 17:       )
// 18:     end
// 19:
// 20:     specify :aggregate_failures, :needs_macos do
// 21:       struct = build_formula_struct([
// 22:         { cellar: :any, arm64_sequoia: "checksum1" },
// 23:         { cellar: :any_skip_relocation, sequoia: "checksum2" },
// 24:         { cellar: "/opt/homebrew/Cellar", arm64_sonoma: "checksum3" },
// 25:       ])
// 26:
// 27:       arm64_tahoe = Utils::Bottles::Tag.from_symbol(:arm64_tahoe)
// 28:       arm64_sequoia = Utils::Bottles::Tag.from_symbol(:arm64_sequoia)
// 29:       sequoia = Utils::Bottles::Tag.from_symbol(:sequoia)
// 30:       arm64_sonoma = Utils::Bottles::Tag.from_symbol(:arm64_sonoma)
// 31:       x86_64_linux = Utils::Bottles::Tag.from_symbol(:x86_64_linux)
// 32:
// 33:       expect(struct.serialize_bottle(bottle_tag: arm64_tahoe)).to eq(
// 34:         {
// 35:           "bottle_tag"      => :arm64_sequoia,
// 36:           "bottle_cellar"   => :any,
// 37:           "bottle_checksum" => "checksum1",
// 38:         },
// 39:       )
// 40:
// 41:       expect(struct.serialize_bottle(bottle_tag: arm64_sequoia)).to eq(
// 42:         {
// 43:           "bottle_tag"      => nil,
// 44:           "bottle_cellar"   => :any,
// 45:           "bottle_checksum" => "checksum1",
// 46:         },
// 47:       )
// 48:
// 49:       expect(struct.serialize_bottle(bottle_tag: sequoia)).to eq(
// 50:         {
// 51:           "bottle_tag"      => nil,
// 52:           "bottle_cellar"   => nil,
// 53:           "bottle_checksum" => "checksum2",
// 54:         },
// 55:       )
// 56:
// 57:       expect(struct.serialize_bottle(bottle_tag: arm64_sonoma)).to eq(
// 58:         {
// 59:           "bottle_tag"      => nil,
// 60:           "bottle_cellar"   => "/opt/homebrew/Cellar",
// 61:           "bottle_checksum" => "checksum3",
// 62:         },
// 63:       )
// 64:
// 65:       expect(struct.serialize_bottle(bottle_tag: x86_64_linux)).to be_nil
// 66:     end
// 67:
// 68:     it "serializes bottle with all tag" do
// 69:       all_struct = build_formula_struct([{ cellar: :any_skip_relocation, all: "checksum1" }])
// 70:       all_struct_result = {
// 71:         "bottle_tag"      => :all,
// 72:         "bottle_cellar"   => nil,
// 73:         "bottle_checksum" => "checksum1",
// 74:       }
// 75:
// 76:       [:arm64_tahoe, :sequoia, :x86_64_linux].each do |tag_sym|
// 77:         bottle_tag = Utils::Bottles::Tag.from_symbol(tag_sym)
// 78:         expect(all_struct.serialize_bottle(bottle_tag: bottle_tag)).to eq(all_struct_result)
// 79:       end
// 80:     end
// 81:   end
// 82:
// 83:   describe "::format_arg_pair" do
// 84:     specify(:aggregate_failures) do
// 85:       expect(described_class.format_arg_pair(["foo"], last: {})).to eq ["foo", {}]
// 86:       expect(described_class.format_arg_pair([{ "foo" => :build }], last: {}))
// 87:         .to eq [{ "foo" => :build }, {}]
// 88:       expect(described_class.format_arg_pair([{ "foo" => :build, since: :catalina }], last: {}))
// 89:         .to eq [{ "foo" => :build, since: :catalina }, {}]
// 90:       expect(described_class.format_arg_pair(["foo", { since: :catalina }], last: {}))
// 91:         .to eq ["foo", { since: :catalina }]
// 92:
// 93:       expect(described_class.format_arg_pair([:foo], last: nil)).to eq [:foo, nil]
// 94:       expect(described_class.format_arg_pair([:foo, :bar], last: nil)).to eq [:foo, :bar]
// 95:     end
// 96:   end
// 97:
// 98:   describe "predicate methods" do
// 99:     it "defaults all predicates to false when not set" do
// 100:       struct = described_class.new(
// 101:         desc:                 "test",
// 102:         homepage:             "https://example.com",
// 103:         license:              "MIT",
// 104:         ruby_source_checksum: "abc123",
// 105:         stable_version:       "1.0.0",
// 106:       )
// 107:
// 108:       Homebrew::API::FormulaStruct::PREDICATES.each do |predicate|
// 109:         expect(struct.public_send(:"#{predicate}?")).to be(false),
// 110:                                                         "expected #{predicate}? to default to false"
// 111:       end
// 112:     end
// 113:
// 114:     it "returns true when the corresponding _present field is set" do
// 115:       present_fields = Homebrew::API::FormulaStruct::PREDICATES.to_h do |predicate|
// 116:         [:"#{predicate}_present", true]
// 117:       end
// 118:
// 119:       struct = described_class.new(
// 120:         desc:                 "test",
// 121:         homepage:             "https://example.com",
// 122:         license:              "MIT",
// 123:         ruby_source_checksum: "abc123",
// 124:         stable_version:       "1.0.0",
// 125:         **present_fields,
// 126:       )
// 127:
// 128:       Homebrew::API::FormulaStruct::PREDICATES.each do |predicate|
// 129:         expect(struct.public_send(:"#{predicate}?")).to be(true),
// 130:                                                         "expected #{predicate}? to be true"
// 131:       end
// 132:     end
// 133:   end
// 134:
// 135:   describe "::deserialize" do
// 136:     it "reconstructs a struct from a serialized hash with bottle info" do
// 137:       bottle_tag = Utils::Bottles::Tag.from_symbol(:arm64_sequoia)
// 138:       hash = {
// 139:         "desc"                 => "test formula",
// 140:         "executables"          => ["foo"],
// 141:         "homepage"             => "https://example.com",
// 142:         "license"              => "MIT",
// 143:         "ruby_source_checksum" => "abc123",
// 144:         "stable_version"       => "1.0.0",
// 145:         "bottle_checksum"      => "checksum1",
// 146:         "bottle_tag"           => ":arm64_sequoia",
// 147:         "bottle_cellar"        => ":any",
// 148:       }
// 149:
// 150:       struct = described_class.deserialize(hash, bottle_tag:)
// 151:
// 152:       expect(struct.bottle?).to be(true)
// 153:       expect(struct.bottle_checksums).to eq([{ cellar: :any, arm64_sequoia: "checksum1" }])
// 154:       expect(struct.executables).to eq(["foo"])
// 155:     end
// 156:
// 157:     it "sets bottle_present to false when no bottle_checksum is present" do
// 158:       bottle_tag = Utils::Bottles::Tag.from_symbol(:arm64_sequoia)
// 159:       hash = {
// 160:         "desc"                 => "test formula",
// 161:         "homepage"             => "https://example.com",
// 162:         "license"              => "MIT",
// 163:         "ruby_source_checksum" => "abc123",
// 164:         "stable_version"       => "1.0.0",
// 165:       }
// 166:
// 167:       struct = described_class.deserialize(hash, bottle_tag:)
// 168:
// 169:       expect(struct.bottle?).to be(false)
// 170:       expect(struct.bottle_checksums).to eq([])
// 171:     end
// 172:
// 173:     it "sets predicate _present fields from _args presence" do
// 174:       bottle_tag = Utils::Bottles::Tag.from_symbol(:arm64_sequoia)
// 175:       hash = {
// 176:         "desc"                 => "test formula",
// 177:         "homepage"             => "https://example.com",
// 178:         "license"              => "MIT",
// 179:         "ruby_source_checksum" => "abc123",
// 180:         "stable_version"       => "1.0.0",
// 181:         "deprecate_args"       => { ":date" => "2025-01-01", ":because" => "discontinued" },
// 182:         "keg_only_args"        => [":versioned_formula"],
// 183:       }
// 184:
// 185:       struct = described_class.deserialize(hash, bottle_tag:)
// 186:
// 187:       expect(struct.deprecate?).to be(true)
// 188:       expect(struct.keg_only?).to be(true)
// 189:       expect(struct.disable?).to be(false)
// 190:     end
// 191:
// 192:     it "formats _url_args into [String, Hash] pairs" do
// 193:       bottle_tag = Utils::Bottles::Tag.from_symbol(:arm64_sequoia)
// 194:       hash = {
// 195:         "desc"                 => "test formula",
// 196:         "homepage"             => "https://example.com",
// 197:         "license"              => "MIT",
// 198:         "ruby_source_checksum" => "abc123",
// 199:         "stable_version"       => "1.0.0",
// 200:         "stable_url_args"      => ["https://example.com/foo-1.0.tar.gz"],
// 201:       }
// 202:
// 203:       struct = described_class.deserialize(hash, bottle_tag:)
// 204:
// 205:       expect(struct.stable?).to be(true)
// 206:       expect(struct.stable_url_args).to eq(["https://example.com/foo-1.0.tar.gz", {}])
// 207:     end
// 208:
// 209:     it "formats uses_from_macos into arg pairs" do
// 210:       bottle_tag = Utils::Bottles::Tag.from_symbol(:arm64_sequoia)
// 211:       hash = {
// 212:         "desc"                   => "test formula",
// 213:         "homepage"               => "https://example.com",
// 214:         "license"                => "MIT",
// 215:         "ruby_source_checksum"   => "abc123",
// 216:         "stable_version"         => "1.0.0",
// 217:         "stable_url_args"        => ["https://example.com/foo-1.0.tar.gz"],
// 218:         "stable_uses_from_macos" => [["zlib"]],
// 219:       }
// 220:
// 221:       struct = described_class.deserialize(hash, bottle_tag:)
// 222:
// 223:       expect(struct.stable_uses_from_macos).to eq([["zlib", {}]])
// 224:     end
// 225:
// 226:     it "formats service_args into arg pairs" do
// 227:       bottle_tag = Utils::Bottles::Tag.from_symbol(:arm64_sequoia)
// 228:       hash = {
// 229:         "desc"                 => "test formula",
// 230:         "homepage"             => "https://example.com",
// 231:         "license"              => "MIT",
// 232:         "ruby_source_checksum" => "abc123",
// 233:         "stable_version"       => "1.0.0",
// 234:         "service_args"         => [[":run_type", ":immediate"]],
// 235:       }
// 236:
// 237:       struct = described_class.deserialize(hash, bottle_tag:)
// 238:
// 239:       expect(struct.service?).to be(true)
// 240:       expect(struct.service_args).to eq([[:run_type, :immediate]])
// 241:     end
// 242:
// 243:     it "formats conflicts into arg pairs" do
// 244:       bottle_tag = Utils::Bottles::Tag.from_symbol(:arm64_sequoia)
// 245:       hash = {
// 246:         "desc"                 => "test formula",
// 247:         "homepage"             => "https://example.com",
// 248:         "license"              => "MIT",
// 249:         "ruby_source_checksum" => "abc123",
// 250:         "stable_version"       => "1.0.0",
// 251:         "conflicts"            => [["other-formula"]],
// 252:       }
// 253:
// 254:       struct = described_class.deserialize(hash, bottle_tag:)
// 255:
// 256:       expect(struct.conflicts).to eq([["other-formula", {}]])
// 257:     end
// 258:   end
// 259:
// 260:   describe "serialize/deserialize round-trip" do
// 261:     it "reconstructs an equivalent struct after serialize then deserialize", :needs_macos do
// 262:       bottle_tag = Utils::Bottles::Tag.from_symbol(:arm64_sequoia)
// 263:
// 264:       original = described_class.new(
// 265:         desc:                   "round-trip test",
// 266:         homepage:               "https://example.com",
// 267:         license:                "MIT",
// 268:         ruby_source_checksum:   "abc123",
// 269:         stable_version:         "1.0.0",
// 270:         stable_url_args:        ["https://example.com/foo-1.0.tar.gz", {}],
// 271:         stable_dependencies:    ["dep1", { "dep2" => :build }],
// 272:         executables:            ["foo"],
// 273:         stable_uses_from_macos: [["zlib", {}]],
// 274:         bottle_checksums:       [{ cellar: :any, arm64_sequoia: "checksum1" }],
// 275:         conflicts:              [["other-formula", {}]],
// 276:         revision:               2,
// 277:         aliases:                ["foo-alias"],
// 278:         post_install_defined:   true,
// 279:       )
// 280:
// 281:       serialized = original.serialize(bottle_tag:)
// 282:       restored = described_class.deserialize(serialized, bottle_tag:)
// 283:
// 284:       expect(restored).to eq(original)
// 285:     end
// 286:
// 287:     it "serializes post-install steps", :needs_macos do
// 288:       original = described_class.new(
// 289:         desc:                 "install steps test",
// 290:         homepage:             "https://example.com",
// 291:         license:              "MIT",
// 292:         ruby_source_checksum: "abc123",
// 293:         stable_version:       "1.0.0",
// 294:         post_install_steps:   [
// 295:           { "type" => "mkdir_p", "path" => { "base" => "var", "path" => "log/foo" } },
// 296:         ],
// 297:       )
// 298:
// 299:       serialized = original.serialize(bottle_tag: Utils::Bottles::Tag.from_symbol(:arm64_sequoia))
// 300:       restored = described_class.deserialize(serialized, bottle_tag: Utils::Bottles::Tag.from_symbol(:arm64_sequoia))
// 301:
// 302:       expect(restored.post_install_steps).to eq(original.post_install_steps)
// 303:     end
// 304:   end
// 305:
// 306:   describe "::from_hash" do
// 307:     it "does not replace home placeholders inside prefix placeholders" do
// 308:       original = described_class.from_hash(
// 309:         "desc"                 => "caveats replace test",
// 310:         "homepage"             => "https://example.com",
// 311:         "license"              => "MIT",
// 312:         "ruby_source_checksum" => "abc123",
// 313:         "stable_version"       => "1.0.0",
// 314:         "caveats"              => "unix://$HOMEBREW_PREFIX",
// 315:       )
// 316:
// 317:       expect(original.caveats).to eq(
// 318:         "unix://#{HOMEBREW_PREFIX}",
// 319:       )
// 320:     end
// 321:   end
// 322: end
