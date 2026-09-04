module api

import ruby
import homebrew.api as internal_api
import os

// Translated from Homebrew/brew `test/api/internal_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cache_dir) { mktmpdir }` at line 7.
pub fn ruby_internal_spec_l7_d1_cache_dir(args ...ruby.Value) ruby.Value {
	path := os.join_path(os.temp_dir(), 'brew-v-internal-${os.getpid()}')
	os.mkdir_all(path) or {}
	return ruby.object_value('Pathname', path)
}

// Ruby let `let(:packages_json) do` at line 8.
pub fn ruby_internal_spec_l8_d2_packages_json(args ...ruby.Value) ruby.Value {
	return ruby.string_value(internal_spec_packages_json())
}

// Ruby let `let(:formula_hashes) do` at line 87.
pub fn ruby_internal_spec_l87_d3_formula_hashes(args ...ruby.Value) ruby.Value {
	return ruby.map_value(internal_spec_formula_hashes())
}

// Ruby let `let(:cask_hashes) do` at line 117.
pub fn ruby_internal_spec_l117_d4_cask_hashes(args ...ruby.Value) ruby.Value {
	return ruby.map_value(internal_spec_cask_hashes())
}

// Ruby let `let(:formula_structs) do` at line 139.
pub fn ruby_internal_spec_l139_d5_formula_structs(args ...ruby.Value) ruby.Value {
	mut values := map[string]ruby.Value{}
	for name, hash in internal_spec_formula_hashes() {
		values[name] = ruby.map_value(internal_api.formula_struct_deserialize(hash.map_data.clone(), 'arm64_sonoma', internal_api.ApiStructPaths{}).serialize('arm64_sonoma'))
	}
	return ruby.map_value(values)
}

// Ruby let `let(:cask_structs) do` at line 145.
pub fn ruby_internal_spec_l145_d6_cask_structs(args ...ruby.Value) ruby.Value {
	mut values := map[string]ruby.Value{}
	for name, hash in internal_spec_cask_hashes() {
		values[name] = ruby.map_value(internal_api.cask_struct_deserialize(hash.map_data.clone(), internal_api.ApiStructPaths{}).serialize())
	}
	return ruby.map_value(values)
}

// Ruby let `let(:formulae_aliases) do` at line 151.
pub fn ruby_internal_spec_l151_d7_formulae_aliases(args ...ruby.Value) ruby.Value {
	return ruby.map_value(internal_spec_string_map_value({
		'foo-alias1': 'foo'
		'foo-alias2': 'foo'
		'bar-alias':  'bar'
	}))
}

// Ruby let `let(:formulae_renames) do` at line 158.
pub fn ruby_internal_spec_l158_d8_formulae_renames(args ...ruby.Value) ruby.Value {
	return ruby.map_value(internal_spec_string_map_value({
		'foo-old': 'foo'
		'bar-old': 'bar'
		'baz-old': 'baz'
	}))
}

// Ruby let `let(:cask_renames) do` at line 165.
pub fn ruby_internal_spec_l165_d9_cask_renames(args ...ruby.Value) ruby.Value {
	return ruby.map_value(internal_spec_string_map_value({
		'foo-old': 'foo'
		'bar-old': 'bar'
		'baz-old': 'baz'
	}))
}

// Ruby let `let(:formula_tap_git_head) { "b871900717ccbb3508ca93fa56e128940b9bd371" }` at line 172.
pub fn ruby_internal_spec_l172_d10_formula_tap_git_head(args ...ruby.Value) ruby.Value {
	return ruby.string_value('b871900717ccbb3508ca93fa56e128940b9bd371')
}

// Ruby let `let(:cask_tap_git_head) { "030eea17b14b437b0a7b96f4dbc9473cce4be31c" }` at line 173.
pub fn ruby_internal_spec_l173_d11_cask_tap_git_head(args ...ruby.Value) ruby.Value {
	return ruby.string_value('030eea17b14b437b0a7b96f4dbc9473cce4be31c')
}

// Ruby let `let(:formula_tap_migrations) do` at line 174.
pub fn ruby_internal_spec_l174_d12_formula_tap_migrations(args ...ruby.Value) ruby.Value {
	return ruby.map_value(internal_spec_string_map_value({
		'abc': 'some/tap'
		'def': 'another/tap'
	}))
}

// Ruby let `let(:cask_tap_migrations) do` at line 180.
pub fn ruby_internal_spec_l180_d13_cask_tap_migrations(args ...ruby.Value) ruby.Value {
	return ruby.map_value(internal_spec_string_map_value({
		'abc': 'some/tap'
		'def': 'another/tap'
	}))
}

// Ruby it `it "returns the expected formula structs" do` at line 199.
pub fn ruby_internal_spec_l199_d14_returns(args ...ruby.Value) ruby.Value {
	mut state := internal_spec_state()
	for name, expected in internal_spec_formula_hashes() {
		actual := internal_api.internal_state_formula_struct(mut state, name) or { return ruby.bool_value(false) }
		if !actual.equals(internal_api.formula_struct_deserialize(expected.map_data.clone(), 'arm64_sonoma', internal_api.ApiStructPaths{}), 'arm64_sonoma') {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby it `it "returns the expected cask structs" do` at line 205.
pub fn ruby_internal_spec_l205_d15_returns(args ...ruby.Value) ruby.Value {
	mut state := internal_spec_state()
	for name, expected in internal_spec_cask_hashes() {
		actual := internal_api.internal_state_cask_struct(mut state, name) or { return ruby.bool_value(false) }
		if !actual.equals(internal_api.cask_struct_deserialize(expected.map_data.clone(), internal_api.ApiStructPaths{})) {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby it `it "returns the expected formula hashes" do` at line 211.
pub fn ruby_internal_spec_l211_d16_returns(args ...ruby.Value) ruby.Value {
	mut state := internal_spec_state()
	return ruby.bool_value(internal_spec_maps_equal(internal_api.internal_formula_hashes(mut state) or { return ruby.bool_value(false) }, internal_spec_formula_hashes()))
}

// Ruby it `it "writes formula executables from the internal packages JSON" do` at line 216.
pub fn ruby_internal_spec_l216_d17_writes(args ...ruby.Value) ruby.Value {
	mut state := internal_spec_state()
	state.cache_dir = os.join_path(os.temp_dir(), 'brew-v-internal-write-${os.getpid()}')
	internal_api.internal_write_formula_names_and_aliases(mut state, true) or { return ruby.bool_value(false) }
	contents := os.read_file(os.join_path(state.cache_dir, 'internal', 'executables.txt')) or { return ruby.bool_value(false) }
	return ruby.bool_value(contents == 'foo:foo-bin food\n')
}

// Ruby it `it "returns the expected cask hashes" do` at line 222.
pub fn ruby_internal_spec_l222_d18_returns(args ...ruby.Value) ruby.Value {
	mut state := internal_spec_state()
	return ruby.bool_value(internal_spec_maps_equal(internal_api.internal_cask_hashes(mut state) or { return ruby.bool_value(false) }, internal_spec_cask_hashes()))
}

// Ruby it `it "returns the expected formula alias list" do` at line 227.
pub fn ruby_internal_spec_l227_d19_returns(args ...ruby.Value) ruby.Value {
	mut state := internal_spec_state()
	return ruby.bool_value(internal_spec_value_equal(internal_api.internal_packages_value(mut state, 'formula_aliases') or { return ruby.bool_value(false) }, ruby_internal_spec_l151_d7_formulae_aliases()))
}

// Ruby it `it "returns the expected formula rename list" do` at line 232.
pub fn ruby_internal_spec_l232_d20_returns(args ...ruby.Value) ruby.Value {
	mut state := internal_spec_state()
	return ruby.bool_value(internal_spec_value_equal(internal_api.internal_packages_value(mut state, 'formula_renames') or { return ruby.bool_value(false) }, ruby_internal_spec_l158_d8_formulae_renames()))
}

// Ruby it `it "returns the expected cask rename list" do` at line 237.
pub fn ruby_internal_spec_l237_d21_returns(args ...ruby.Value) ruby.Value {
	mut state := internal_spec_state()
	return ruby.bool_value(internal_spec_value_equal(internal_api.internal_packages_value(mut state, 'cask_renames') or { return ruby.bool_value(false) }, ruby_internal_spec_l165_d9_cask_renames()))
}

// Ruby it `it "returns the expected formula tap git head" do` at line 242.
pub fn ruby_internal_spec_l242_d22_returns(args ...ruby.Value) ruby.Value {
	mut state := internal_spec_state()
	return ruby.bool_value((internal_api.internal_packages_value(mut state, 'formula_tap_git_head') or { return ruby.bool_value(false) }).as_string() == ruby_internal_spec_l172_d10_formula_tap_git_head().as_string())
}

// Ruby it `it "returns the expected cask tap git head" do` at line 247.
pub fn ruby_internal_spec_l247_d23_returns(args ...ruby.Value) ruby.Value {
	mut state := internal_spec_state()
	return ruby.bool_value((internal_api.internal_packages_value(mut state, 'cask_tap_git_head') or { return ruby.bool_value(false) }).as_string() == ruby_internal_spec_l173_d11_cask_tap_git_head().as_string())
}

// Ruby it `it "returns the expected formula tap migrations list" do` at line 252.
pub fn ruby_internal_spec_l252_d24_returns(args ...ruby.Value) ruby.Value {
	mut state := internal_spec_state()
	return ruby.bool_value(internal_spec_value_equal(internal_api.internal_packages_value(mut state, 'formula_tap_migrations') or { return ruby.bool_value(false) }, ruby_internal_spec_l174_d12_formula_tap_migrations()))
}

// Ruby it `it "returns the expected cask tap migrations list" do` at line 257.
pub fn ruby_internal_spec_l257_d25_returns(args ...ruby.Value) ruby.Value {
	mut state := internal_spec_state()
	return ruby.bool_value(internal_spec_value_equal(internal_api.internal_packages_value(mut state, 'cask_tap_migrations') or { return ruby.bool_value(false) }, ruby_internal_spec_l180_d13_cask_tap_migrations()))
}

// Ruby let `let(:compact_payload) { JSON.generate(JSON.parse(packages_json)) }` at line 263.
pub fn ruby_internal_spec_l263_d26_compact_payload(args ...ruby.Value) ruby.Value {
	parsed := ruby.parse_json_value(internal_spec_packages_json()) or { return ruby.string_value('') }
	return ruby.string_value(ruby.json_value_to_string(parsed))
}

// Ruby it `it "builds an index on first load and serves formula structs from it afterwards" do` at line 280.
pub fn ruby_internal_spec_l280_d27_builds(args ...ruby.Value) ruby.Value {
	mut fixture := internal_spec_index_fixture() or { return ruby.bool_value(false) }
	defer { os.rmdir_all(fixture.cache_dir) or {} }
	first := internal_api.internal_state_formula_struct(mut fixture, 'foo') or { return ruby.bool_value(false) }
	if first.desc != 'Foo formula' || !os.exists(internal_api.packages_index_path_for(internal_api.internal_cached_packages_json_file_path(fixture.cache_dir, fixture.effective_tag))) {
		return ruby.bool_value(false)
	}
	mut loaded := internal_spec_index_state(fixture.cache_dir)
	second := internal_api.internal_state_formula_struct(mut loaded, 'foo') or { return ruby.bool_value(false) }
	return ruby.bool_value(second.desc == 'Foo formula' && (internal_api.internal_packages_value(mut loaded, 'formula_tap_git_head') or { return ruby.bool_value(false) }).as_string() == 'b871900717ccbb3508ca93fa56e128940b9bd371' && (internal_api.internal_formula_name(mut loaded, 'bar') or { false }) && !(internal_api.internal_formula_name(mut loaded, 'missing') or { true }))
}

// Ruby it `it "materialises full hashes from an index-served payload" do` at line 298.
pub fn ruby_internal_spec_l298_d28_materialises(args ...ruby.Value) ruby.Value {
	mut fixture := internal_spec_index_fixture() or { return ruby.bool_value(false) }
	defer { os.rmdir_all(fixture.cache_dir) or {} }
	_ := internal_api.internal_state_formula_struct(mut fixture, 'foo') or { return ruby.bool_value(false) }
	mut loaded := internal_spec_index_state(fixture.cache_dir)
	actual := internal_api.internal_formula_hashes(mut loaded) or { return ruby.bool_value(false) }
	return ruby.bool_value(internal_spec_maps_equal(actual, internal_spec_formula_hashes()))
}

fn internal_spec_packages_json() string {
	return '{"formulae":{"foo":{"desc":"Foo formula","executables":["foo-bin","food"],"homepage":"https://example.com/foo","license":"MIT","ruby_source_checksum":"09f88b61e36045188ddb1b1ba8e402b9f3debee1770cc4ca91355eeccb5f4a38","stable_version":"1.0.0"},"bar":{"desc":"Bar formula","homepage":"https://example.com/bar","license":"Apache-2.0","ruby_source_checksum":"bb6e3408f39a404770529cfce548dc2666e861077acd173825cb3138c27c205a","stable_version":"0.4.0","revision":5,"version_scheme":1},"baz":{"desc":"Baz formula","homepage":"https://example.com/baz","license":"GPL-3.0-or-later","ruby_source_checksum":"404c97537d65ca0b75c389e7d439dcefb9b56f34d3b98017669eda0d0501add7","stable_version":"10.4.5","revision":2,"bottle_rebuild":2}},"casks":{"foo":{"desc":"Foo cask","homepage":"https://example.com/foo","sha256":"09f88b61e36045188ddb1b1ba8e402b9f3debee1770cc4ca91355eeccb5f4a38","version":"1.0.0"},"bar":{"desc":"Bar cask","homepage":"https://example.com/bar","sha256":"bb6e3408f39a404770529cfce548dc2666e861077acd173825cb3138c27c205a","version":"0.4.0"},"baz":{"desc":"Baz cask","homepage":"https://example.com/baz","sha256":"404c97537d65ca0b75c389e7d439dcefb9b56f34d3b98017669eda0d0501add7","version":"10.4.5"}},"formula_aliases":{"foo-alias1":"foo","foo-alias2":"foo","bar-alias":"bar"},"formula_renames":{"foo-old":"foo","bar-old":"bar","baz-old":"baz"},"cask_renames":{"foo-old":"foo","bar-old":"bar","baz-old":"baz"},"formula_tap_git_head":"b871900717ccbb3508ca93fa56e128940b9bd371","cask_tap_git_head":"030eea17b14b437b0a7b96f4dbc9473cce4be31c","formula_tap_migrations":{"abc":"some/tap","def":"another/tap"},"cask_tap_migrations":{"abc":"some/tap","def":"another/tap"}}'
}

fn internal_spec_parsed() ruby.Value {
	return ruby.parse_json_value(internal_spec_packages_json()) or { ruby.map_value(map[string]ruby.Value{}) }
}

fn internal_spec_formula_hashes() map[string]ruby.Value {
	return (internal_spec_parsed().map_data['formulae'] or { ruby.map_value(map[string]ruby.Value{}) }).map_data.clone()
}

fn internal_spec_cask_hashes() map[string]ruby.Value {
	return (internal_spec_parsed().map_data['casks'] or { ruby.map_value(map[string]ruby.Value{}) }).map_data.clone()
}

fn internal_spec_state() internal_api.InternalApiState {
	mut state := internal_api.InternalApiState{ effective_tag: 'arm64_sonoma', sidecar_verified: true }
	internal_api.internal_cache_parsed_packages(mut state, internal_spec_parsed())
	return state
}

fn internal_spec_string_map_value(values map[string]string) map[string]ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in values {
		result[key] = ruby.string_value(value)
	}
	return result
}

fn internal_spec_value_equal(left ruby.Value, right ruby.Value) bool {
	return ruby.json_value_to_string(left) == ruby.json_value_to_string(right)
}

fn internal_spec_maps_equal(left map[string]ruby.Value, right map[string]ruby.Value) bool {
	return internal_spec_value_equal(ruby.map_value(left), ruby.map_value(right))
}

fn internal_spec_index_fixture() !internal_api.InternalApiState {
	cache_dir := os.join_path(os.temp_dir(), 'brew-v-internal-index-${os.getpid()}')
	os.rmdir_all(cache_dir) or {}
	target := internal_api.internal_cached_packages_json_file_path(cache_dir, 'arm64_sonoma')
	os.mkdir_all(os.dir(target))!
	os.write_file(target, 'envelope')!
	stat := internal_api.packages_source_stat(target)!
	payload := internal_spec_packages_json()
	header := ruby.map_value({
		'protected':       ruby.string_value('protected')
		'signature':       ruby.string_value('signature')
		'source_size':     ruby.int_value(stat.size)
		'source_mtime_ns': ruby.int_value(stat.mtime_ns)
	})
	os.write_file('${target}.payload', '${ruby.json_value_to_string(header)}\n${payload}')!
	return internal_spec_index_state(cache_dir)
}

fn internal_spec_index_state(cache_dir string) internal_api.InternalApiState {
	return internal_api.InternalApiState{ effective_tag: 'arm64_sonoma', cache_dir: cache_dir, sidecar_verified: true }
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "api/internal"
// 5:
// 6: RSpec.describe Homebrew::API::Internal do
// 7:   let(:cache_dir) { mktmpdir }
// 8:   let(:packages_json) do
// 9:     <<~JSON
// 10:       {
// 11:         "formulae": {
// 12:           "foo": {
// 13:             "desc": "Foo formula",
// 14:             "executables": ["foo-bin", "food"],
// 15:             "homepage": "https://example.com/foo",
// 16:             "license": "MIT",
// 17:             "ruby_source_checksum": "09f88b61e36045188ddb1b1ba8e402b9f3debee1770cc4ca91355eeccb5f4a38",
// 18:             "stable_version": "1.0.0"
// 19:           },
// 20:           "bar": {
// 21:             "desc": "Bar formula",
// 22:             "homepage": "https://example.com/bar",
// 23:             "license": "Apache-2.0",
// 24:             "ruby_source_checksum": "bb6e3408f39a404770529cfce548dc2666e861077acd173825cb3138c27c205a",
// 25:             "stable_version": "0.4.0",
// 26:             "revision": 5,
// 27:             "version_scheme": 1
// 28:           },
// 29:           "baz": {
// 30:             "desc": "Baz formula",
// 31:             "homepage": "https://example.com/baz",
// 32:             "license": "GPL-3.0-or-later",
// 33:             "ruby_source_checksum": "404c97537d65ca0b75c389e7d439dcefb9b56f34d3b98017669eda0d0501add7",
// 34:             "stable_version": "10.4.5",
// 35:             "revision": 2,
// 36:             "bottle_rebuild": 2
// 37:           }
// 38:         },
// 39:         "casks": {
// 40:           "foo": {
// 41:             "desc": "Foo cask",
// 42:             "homepage": "https://example.com/foo",
// 43:             "sha256": "09f88b61e36045188ddb1b1ba8e402b9f3debee1770cc4ca91355eeccb5f4a38",
// 44:             "version": "1.0.0"
// 45:           },
// 46:           "bar": {
// 47:             "desc": "Bar cask",
// 48:             "homepage": "https://example.com/bar",
// 49:             "sha256": "bb6e3408f39a404770529cfce548dc2666e861077acd173825cb3138c27c205a",
// 50:             "version": "0.4.0"
// 51:           },
// 52:           "baz": {
// 53:             "desc": "Baz cask",
// 54:             "homepage": "https://example.com/baz",
// 55:             "sha256": "404c97537d65ca0b75c389e7d439dcefb9b56f34d3b98017669eda0d0501add7",
// 56:             "version": "10.4.5"
// 57:           }
// 58:         },
// 59:         "formula_aliases": {
// 60:           "foo-alias1": "foo",
// 61:           "foo-alias2": "foo",
// 62:           "bar-alias": "bar"
// 63:         },
// 64:         "formula_renames": {
// 65:           "foo-old": "foo",
// 66:           "bar-old": "bar",
// 67:           "baz-old": "baz"
// 68:         },
// 69:         "cask_renames": {
// 70:           "foo-old": "foo",
// 71:           "bar-old": "bar",
// 72:           "baz-old": "baz"
// 73:         },
// 74:         "formula_tap_git_head": "b871900717ccbb3508ca93fa56e128940b9bd371",
// 75:         "cask_tap_git_head": "030eea17b14b437b0a7b96f4dbc9473cce4be31c",
// 76:         "formula_tap_migrations": {
// 77:           "abc": "some/tap",
// 78:           "def": "another/tap"
// 79:         },
// 80:         "cask_tap_migrations": {
// 81:           "abc": "some/tap",
// 82:           "def": "another/tap"
// 83:         }
// 84:       }
// 85:     JSON
// 86:   end
// 87:   let(:formula_hashes) do
// 88:     {
// 89:       "foo" => {
// 90:         "desc"                 => "Foo formula",
// 91:         "executables"          => ["foo-bin", "food"],
// 92:         "homepage"             => "https://example.com/foo",
// 93:         "license"              => "MIT",
// 94:         "ruby_source_checksum" => "09f88b61e36045188ddb1b1ba8e402b9f3debee1770cc4ca91355eeccb5f4a38",
// 95:         "stable_version"       => "1.0.0",
// 96:       },
// 97:       "bar" => {
// 98:         "desc"                 => "Bar formula",
// 99:         "homepage"             => "https://example.com/bar",
// 100:         "license"              => "Apache-2.0",
// 101:         "ruby_source_checksum" => "bb6e3408f39a404770529cfce548dc2666e861077acd173825cb3138c27c205a",
// 102:         "stable_version"       => "0.4.0",
// 103:         "revision"             => 5,
// 104:         "version_scheme"       => 1,
// 105:       },
// 106:       "baz" => {
// 107:         "desc"                 => "Baz formula",
// 108:         "homepage"             => "https://example.com/baz",
// 109:         "license"              => "GPL-3.0-or-later",
// 110:         "ruby_source_checksum" => "404c97537d65ca0b75c389e7d439dcefb9b56f34d3b98017669eda0d0501add7",
// 111:         "stable_version"       => "10.4.5",
// 112:         "revision"             => 2,
// 113:         "bottle_rebuild"       => 2,
// 114:       },
// 115:     }
// 116:   end
// 117:   let(:cask_hashes) do
// 118:     {
// 119:       "foo" => {
// 120:         "desc"     => "Foo cask",
// 121:         "homepage" => "https://example.com/foo",
// 122:         "sha256"   => "09f88b61e36045188ddb1b1ba8e402b9f3debee1770cc4ca91355eeccb5f4a38",
// 123:         "version"  => "1.0.0",
// 124:       },
// 125:       "bar" => {
// 126:         "desc"     => "Bar cask",
// 127:         "homepage" => "https://example.com/bar",
// 128:         "sha256"   => "bb6e3408f39a404770529cfce548dc2666e861077acd173825cb3138c27c205a",
// 129:         "version"  => "0.4.0",
// 130:       },
// 131:       "baz" => {
// 132:         "desc"     => "Baz cask",
// 133:         "homepage" => "https://example.com/baz",
// 134:         "sha256"   => "404c97537d65ca0b75c389e7d439dcefb9b56f34d3b98017669eda0d0501add7",
// 135:         "version"  => "10.4.5",
// 136:       },
// 137:     }
// 138:   end
// 139:   let(:formula_structs) do
// 140:     formula_hashes.to_h do |name, hash|
// 141:       struct = Homebrew::API::FormulaStruct.new(**hash.transform_keys(&:to_sym))
// 142:       [name, struct]
// 143:     end
// 144:   end
// 145:   let(:cask_structs) do
// 146:     cask_hashes.to_h do |name, hash|
// 147:       struct = Homebrew::API::CaskStruct.new(**hash.transform_keys(&:to_sym))
// 148:       [name, struct]
// 149:     end
// 150:   end
// 151:   let(:formulae_aliases) do
// 152:     {
// 153:       "foo-alias1" => "foo",
// 154:       "foo-alias2" => "foo",
// 155:       "bar-alias"  => "bar",
// 156:     }
// 157:   end
// 158:   let(:formulae_renames) do
// 159:     {
// 160:       "foo-old" => "foo",
// 161:       "bar-old" => "bar",
// 162:       "baz-old" => "baz",
// 163:     }
// 164:   end
// 165:   let(:cask_renames) do
// 166:     {
// 167:       "foo-old" => "foo",
// 168:       "bar-old" => "bar",
// 169:       "baz-old" => "baz",
// 170:     }
// 171:   end
// 172:   let(:formula_tap_git_head) { "b871900717ccbb3508ca93fa56e128940b9bd371" }
// 173:   let(:cask_tap_git_head) { "030eea17b14b437b0a7b96f4dbc9473cce4be31c" }
// 174:   let(:formula_tap_migrations) do
// 175:     {
// 176:       "abc" => "some/tap",
// 177:       "def" => "another/tap",
// 178:     }
// 179:   end
// 180:   let(:cask_tap_migrations) do
// 181:     {
// 182:       "abc" => "some/tap",
// 183:       "def" => "another/tap",
// 184:     }
// 185:   end
// 186:
// 187:   before do
// 188:     FileUtils.mkdir_p(cache_dir/"internal")
// 189:     stub_const("Homebrew::API::HOMEBREW_CACHE_API", cache_dir)
// 190:     described_class.clear_cache
// 191:     allow(Utils::Curl).to receive(:curl_download) do |*_args, **kwargs|
// 192:       kwargs[:to].write packages_json
// 193:     end
// 194:     allow(Homebrew::API).to receive(:verify_and_parse_jws) do |json_data|
// 195:       [true, json_data]
// 196:     end
// 197:   end
// 198:
// 199:   it "returns the expected formula structs" do
// 200:     formula_structs.each do |name, struct|
// 201:       expect(described_class.formula_struct(name)).to eq struct
// 202:     end
// 203:   end
// 204:
// 205:   it "returns the expected cask structs" do
// 206:     cask_structs.each do |name, struct|
// 207:       expect(described_class.cask_struct(name)).to eq struct
// 208:     end
// 209:   end
// 210:
// 211:   it "returns the expected formula hashes" do
// 212:     formula_hashes_output = described_class.formula_hashes
// 213:     expect(formula_hashes_output).to eq formula_hashes
// 214:   end
// 215:
// 216:   it "writes formula executables from the internal packages JSON" do
// 217:     Homebrew::API.write_names_and_aliases
// 218:
// 219:     expect((cache_dir/"internal/executables.txt").read).to eq("foo:foo-bin food\n")
// 220:   end
// 221:
// 222:   it "returns the expected cask hashes" do
// 223:     cask_hashes_output = described_class.cask_hashes
// 224:     expect(cask_hashes_output).to eq cask_hashes
// 225:   end
// 226:
// 227:   it "returns the expected formula alias list" do
// 228:     formula_aliases_output = described_class.formula_aliases
// 229:     expect(formula_aliases_output).to eq formulae_aliases
// 230:   end
// 231:
// 232:   it "returns the expected formula rename list" do
// 233:     formula_renames_output = described_class.formula_renames
// 234:     expect(formula_renames_output).to eq formulae_renames
// 235:   end
// 236:
// 237:   it "returns the expected cask rename list" do
// 238:     cask_renames_output = described_class.cask_renames
// 239:     expect(cask_renames_output).to eq cask_renames
// 240:   end
// 241:
// 242:   it "returns the expected formula tap git head" do
// 243:     formula_tap_git_head_output = described_class.formula_tap_git_head
// 244:     expect(formula_tap_git_head_output).to eq formula_tap_git_head
// 245:   end
// 246:
// 247:   it "returns the expected cask tap git head" do
// 248:     cask_tap_git_head_output = described_class.cask_tap_git_head
// 249:     expect(cask_tap_git_head_output).to eq cask_tap_git_head
// 250:   end
// 251:
// 252:   it "returns the expected formula tap migrations list" do
// 253:     formula_tap_migrations_output = described_class.formula_tap_migrations
// 254:     expect(formula_tap_migrations_output).to eq formula_tap_migrations
// 255:   end
// 256:
// 257:   it "returns the expected cask tap migrations list" do
// 258:     cask_tap_migrations_output = described_class.cask_tap_migrations
// 259:     expect(cask_tap_migrations_output).to eq cask_tap_migrations
// 260:   end
// 261:
// 262:   describe "with a cached payload sidecar" do
// 263:     let(:compact_payload) { JSON.generate(JSON.parse(packages_json)) }
// 264:
// 265:     before do
// 266:       target = described_class.cached_packages_json_file_path
// 267:       target.dirname.mkpath
// 268:       target.write "envelope"
// 269:       header = {
// 270:         "protected"       => "protected",
// 271:         "signature"       => "signature",
// 272:         "source_size"     => target.stat.size,
// 273:         "source_mtime_ns" => (target.stat.mtime.to_r * 1_000_000_000).to_i,
// 274:       }
// 275:       Pathname("#{target}.payload").write("#{JSON.generate(header)}\n#{compact_payload}")
// 276:       allow(Homebrew::API).to receive(:verify_jws_signature).and_return(nil)
// 277:       allow(Utils::Curl).to receive(:curl_download).and_raise("sidecar-served loads must not download")
// 278:     end
// 279:
// 280:     it "builds an index on first load and serves formula structs from it afterwards" do
// 281:       expect(described_class.formula_struct("foo")).to eq formula_structs.fetch("foo")
// 282:       index_path = Homebrew::API::PackagesIndex.path_for(described_class.cached_packages_json_file_path)
// 283:       expect(index_path).to exist
// 284:
// 285:       described_class.clear_cache
// 286:       loaded_index = T.let(nil, T.untyped)
// 287:       expect(Homebrew::API::PackagesIndex).to receive(:load).and_wrap_original do |original, *args, **kwargs|
// 288:         loaded_index = original.call(*args, **kwargs)
// 289:       end
// 290:
// 291:       expect(described_class.formula_struct("foo")).to eq formula_structs.fetch("foo")
// 292:       expect(loaded_index).not_to be_nil
// 293:       expect(described_class.formula_tap_git_head).to eq formula_tap_git_head
// 294:       expect(described_class.formula_name?("bar")).to be true
// 295:       expect(described_class.formula_name?("missing")).to be false
// 296:     end
// 297:
// 298:     it "materialises full hashes from an index-served payload" do
// 299:       described_class.formula_struct("foo")
// 300:       described_class.clear_cache
// 301:
// 302:       expect(described_class.formula_hashes).to eq formula_hashes
// 303:     end
// 304:   end
// 305: end
