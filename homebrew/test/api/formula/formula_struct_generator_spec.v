module formula

import ruby
import homebrew.api
import homebrew.api.formula as generator

// Translated from Homebrew/brew `test/api/formula/formula_struct_generator_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn formula_struct_generator_spec_string_array(values []string) ruby.Value {
	return ruby.array_value(values.map(ruby.string_value(it)))
}

fn formula_struct_generator_spec_symbol(value string) ruby.Value {
	return ruby.object_value('Symbol', value)
}

fn formula_struct_generator_spec_values_equal(left []ruby.Value,
	right []ruby.Value) bool {
	if left.len != right.len {
		return false
	}
	for index, value in left {
		if !api.api_struct_value_equal(value, right[index]) {
			return false
		}
	}
	return true
}

fn formula_struct_generator_spec_maps_equal(left map[string]ruby.Value,
	right map[string]ruby.Value) bool {
	return api.api_struct_value_equal(ruby.map_value(left), ruby.map_value(right))
}

fn formula_struct_generator_spec_pairs_equal(left []api.ApiStructArgPair,
	right []api.ApiStructArgPair) bool {
	if left.len != right.len {
		return false
	}
	for index, pair in left {
		if !api.api_struct_value_equal(pair.first, right[index].first) || !api.api_struct_value_equal(pair.second, right[index].second) {
			return false
		}
	}
	return true
}

fn formula_struct_generator_spec_options() generator.FormulaStructGeneratorOptions {
	return generator.FormulaStructGeneratorOptions{
		bottle_tag: 'arm64_sonoma'
		paths: api.ApiStructPaths{
			prefix: '/opt/homebrew'
			cellar: '/opt/homebrew/Cellar'
			home: '/Users/brew'
		}
		no_autobump_reasons: ['incompatible_version_format', 'bumped_by_upstream', 'extract_plist',
			'latest_version', 'requires_manual_review']
	}
}

fn formula_struct_generator_spec_base_hash() map[string]ruby.Value {
	return {
		'desc':                 ruby.string_value('Test formula')
		'homepage':             ruby.string_value('https://example.com')
		'license':              ruby.string_value('MIT')
		'ruby_source_checksum': ruby.map_value({
			'sha256': ruby.string_value('abc123')
		})
		'versions':             ruby.map_value({
			'stable': ruby.string_value('1.0.0')
		})
		'urls':                 ruby.map_value({
			'stable': ruby.map_value({
				'url': ruby.string_value('https://example.com/foo-1.0.tar.gz')
			})
		})
	}
}

// Ruby let `let(:raw_dependency_hash) do` at line 7.
pub fn ruby_formula_struct_generator_spec_l7_d1_raw_dependency_hash() map[string]ruby.Value {
	return {
		'dependencies':           ruby.array_value([
			ruby.string_value('foo'),
			ruby.map_value({
				'bar': ruby.string_value('build')
			}),
			ruby.map_value({
				'baz': formula_struct_generator_spec_string_array(['build', 'test'])
			}),
		])
		'uses_from_macos':        ruby.array_value([
			ruby.string_value('abc'),
			ruby.map_value({
				'def': ruby.string_value('build')
			}),
			ruby.map_value({
				'ghi': formula_struct_generator_spec_string_array(['build', 'test'])
			}),
			ruby.string_value('jkl'),
		])
		'uses_from_macos_bounds': ruby.array_value([
			ruby.map_value({}),
			ruby.map_value({
				'since': ruby.string_value('catalina')
			}),
			ruby.map_value({}),
			ruby.map_value({
				'since': ruby.string_value('catalina')
			}),
		])
	}
}

// Ruby let `let(:symbolized_dependency_hash) do` at line 29.
pub fn ruby_formula_struct_generator_spec_l29_d2_symbolized_dependency_hash() map[string]ruby.Value {
	return {
		'dependencies':           ruby.array_value([
			ruby.string_value('foo'),
			ruby.map_value({
				'bar': formula_struct_generator_spec_symbol('build')
			}),
			ruby.map_value({
				'baz': ruby.array_value([
					formula_struct_generator_spec_symbol('build'),
					formula_struct_generator_spec_symbol('test'),
				])
			}),
		])
		'uses_from_macos':        ruby.array_value([
			ruby.string_value('abc'),
			ruby.map_value({
				'def': formula_struct_generator_spec_symbol('build')
			}),
			ruby.map_value({
				'ghi': ruby.array_value([
					formula_struct_generator_spec_symbol('build'),
					formula_struct_generator_spec_symbol('test'),
				])
			}),
			ruby.string_value('jkl'),
		])
		'uses_from_macos_bounds': ruby.array_value([
			ruby.map_value({}),
			ruby.map_value({
				'since': formula_struct_generator_spec_symbol('catalina')
			}),
			ruby.map_value({}),
			ruby.map_value({
				'since': formula_struct_generator_spec_symbol('catalina')
			}),
		])
	}
}

// Ruby let `let(:dependency_args) do` at line 51.
pub fn ruby_formula_struct_generator_spec_l51_d3_dependency_args() []ruby.Value {
	dependencies := ruby_formula_struct_generator_spec_l29_d2_symbolized_dependency_hash()['dependencies'] or {
		return []ruby.Value{}
	}
	return dependencies.as_array() or { []ruby.Value{} }
}

// Ruby let `let(:uses_from_macos_args) do` at line 59.
pub fn ruby_formula_struct_generator_spec_l59_d4_uses_from_macos_args() []api.ApiStructArgPair {
	return [
		api.ApiStructArgPair{
			first: ruby.string_value('abc')
			second: ruby.map_value({})
		},
		api.ApiStructArgPair{
			first: ruby.map_value({
				'def':   formula_struct_generator_spec_symbol('build')
				'since': formula_struct_generator_spec_symbol('catalina')
			})
			second: ruby.map_value({})
		},
		api.ApiStructArgPair{
			first: ruby.map_value({
				'ghi': ruby.array_value([
					formula_struct_generator_spec_symbol('build'),
					formula_struct_generator_spec_symbol('test'),
				])
			})
			second: ruby.map_value({})
		},
		api.ApiStructArgPair{
			first: ruby.string_value('jkl')
			second: ruby.map_value({
				'since': formula_struct_generator_spec_symbol('catalina')
			})
		},
	]
}

// Ruby let `let(:requirements_array) do` at line 68.
pub fn ruby_formula_struct_generator_spec_l68_d5_requirements_array() []ruby.Value {
	return [
		ruby.map_value({
			'name':  ruby.string_value('linux')
			'specs': formula_struct_generator_spec_string_array(['head'])
		}),
		ruby.map_value({
			'name':  ruby.string_value('codesign')
			'specs': formula_struct_generator_spec_string_array(['stable', 'head'])
		}),
		ruby.map_value({
			'name':    ruby.string_value('arch')
			'version': ruby.string_value('arm64')
			'specs':   formula_struct_generator_spec_string_array(['stable', 'head'])
		}),
		ruby.map_value({
			'name':    ruby.string_value('macos')
			'version': ruby.string_value('14')
			'specs':   formula_struct_generator_spec_string_array(['stable'])
		}),
		ruby.map_value({
			'name':     ruby.string_value('maximum_macos')
			'version':  ruby.string_value('13')
			'specs':    formula_struct_generator_spec_string_array(['stable', 'head'])
			'contexts': formula_struct_generator_spec_string_array(['build'])
		}),
		ruby.map_value({
			'name':  ruby.string_value('xcode')
			'specs': formula_struct_generator_spec_string_array(['stable', 'head'])
		}),
		ruby.map_value({
			'name':     ruby.string_value('xcode')
			'version':  ruby.string_value('11.2')
			'specs':    formula_struct_generator_spec_string_array(['stable', 'head'])
			'contexts': formula_struct_generator_spec_string_array(['build', 'test'])
		}),
	]
}

// Ruby let `let(:stable_requirements_args) do` at line 80.
pub fn ruby_formula_struct_generator_spec_l80_d6_stable_requirements_args() []ruby.Value {
	return [
		ruby.map_value({
			'arch': ruby.array_value([
				formula_struct_generator_spec_symbol('arm64'),
			])
		}),
		ruby.map_value({
			'macos': ruby.array_value([
				formula_struct_generator_spec_symbol('sonoma'),
			])
		}),
		ruby.map_value({
			'maximum_macos': ruby.array_value([
				formula_struct_generator_spec_symbol('ventura'),
				formula_struct_generator_spec_symbol('build'),
			])
		}),
		formula_struct_generator_spec_symbol('xcode'),
		ruby.map_value({
			'xcode': ruby.array_value([
				ruby.string_value('11.2'),
				formula_struct_generator_spec_symbol('build'),
				formula_struct_generator_spec_symbol('test'),
			])
		}),
	]
}

// Ruby let `let(:head_requirements_args) do` at line 90.
pub fn ruby_formula_struct_generator_spec_l90_d7_head_requirements_args() []ruby.Value {
	return [
		formula_struct_generator_spec_symbol('linux'),
		ruby.map_value({
			'arch': ruby.array_value([
				formula_struct_generator_spec_symbol('arm64'),
			])
		}),
		ruby.map_value({
			'maximum_macos': ruby.array_value([
				formula_struct_generator_spec_symbol('ventura'),
				formula_struct_generator_spec_symbol('build'),
			])
		}),
		formula_struct_generator_spec_symbol('xcode'),
		ruby.map_value({
			'xcode': ruby.array_value([
				ruby.string_value('11.2'),
				formula_struct_generator_spec_symbol('build'),
				formula_struct_generator_spec_symbol('test'),
			])
		}),
	]
}

// Ruby specify `specify "::process_dependencies_and_requirements", :aggregate_failures do` at line 100.
pub fn ruby_formula_struct_generator_spec_l100_d8_process_dependencies_and_requirements() bool {
	raw := ruby_formula_struct_generator_spec_l7_d1_raw_dependency_hash()
	requirements := ruby_formula_struct_generator_spec_l68_d5_requirements_array()
	dependency_args := ruby_formula_struct_generator_spec_l51_d3_dependency_args()
	uses_from_macos_args := ruby_formula_struct_generator_spec_l59_d4_uses_from_macos_args()
	stable_requirements := ruby_formula_struct_generator_spec_l80_d6_stable_requirements_args()
	head_requirements := ruby_formula_struct_generator_spec_l90_d7_head_requirements_args()
	stable := generator.ruby_formula_struct_generator_l203_d2_process_dependencies_and_requirements(raw, requirements, 'stable')
	head := generator.ruby_formula_struct_generator_l203_d2_process_dependencies_and_requirements(raw, requirements, 'head')
	head_without_requirements := generator.ruby_formula_struct_generator_l203_d2_process_dependencies_and_requirements(raw, none, 'head')
	stable_without_dependencies := generator.ruby_formula_struct_generator_l203_d2_process_dependencies_and_requirements(none, requirements, 'stable')
	head_without_dependencies := generator.ruby_formula_struct_generator_l203_d2_process_dependencies_and_requirements(none, requirements, 'head')
	empty := generator.ruby_formula_struct_generator_l203_d2_process_dependencies_and_requirements(none, none, 'stable')
	mut expected_stable := dependency_args.clone()
	expected_stable << stable_requirements
	mut expected_head := dependency_args.clone()
	expected_head << head_requirements
	return formula_struct_generator_spec_values_equal(stable.dependencies, expected_stable) && formula_struct_generator_spec_pairs_equal(stable.uses_from_macos, uses_from_macos_args) && formula_struct_generator_spec_values_equal(head.dependencies, expected_head) && formula_struct_generator_spec_pairs_equal(head.uses_from_macos, uses_from_macos_args) && formula_struct_generator_spec_values_equal(head_without_requirements.dependencies, dependency_args) && formula_struct_generator_spec_pairs_equal(head_without_requirements.uses_from_macos, uses_from_macos_args) && formula_struct_generator_spec_values_equal(stable_without_dependencies.dependencies, stable_requirements) && stable_without_dependencies.uses_from_macos.len == 0 && formula_struct_generator_spec_values_equal(head_without_dependencies.dependencies, head_requirements) && head_without_dependencies.uses_from_macos.len == 0 && empty.dependencies.len == 0 && empty.uses_from_macos.len == 0
}

// Ruby specify `specify "::generate_formula_struct_hash falls back to stable deps when head_dependencies is absent" do` at line 138.
pub fn ruby_formula_struct_generator_spec_l138_d9_generate_formula_struct_hash() bool {
	mut hash := formula_struct_generator_spec_base_hash()
	hash['dependencies'] = formula_struct_generator_spec_string_array(['foo'])
	hash['recommended_dependencies'] = ruby.array_value([])
	hash['optional_dependencies'] = ruby.array_value([])
	hash['uses_from_macos'] = ruby.array_value([])
	hash['uses_from_macos_bounds'] = ruby.array_value([])
	formula := generator.ruby_formula_struct_generator_l43_d1_generate_formula_struct_hash(hash, formula_struct_generator_spec_options()) or { return false }
	return formula.head_dependencies.len > 0 && formula_struct_generator_spec_values_equal(formula.head_dependencies, formula.stable_dependencies)
}

// Ruby specify `specify "::generate_formula_struct_hash preserves stable patches" do` at line 159.
pub fn ruby_formula_struct_generator_spec_l159_d10_generate_formula_struct_hash() bool {
	mut hash := formula_struct_generator_spec_base_hash()
	patches := [ruby.map_value({
		'strip':  ruby.string_value('p1')
		'url':    ruby.string_value('https://example.com/foo.patch')
		'sha256': ruby.string_value('def456')
	})]
	hash['patches'] = ruby.array_value(patches)
	formula := generator.ruby_formula_struct_generator_l43_d1_generate_formula_struct_hash(hash, formula_struct_generator_spec_options()) or { return false }
	return formula_struct_generator_spec_values_equal(formula.stable_patches, patches)
}

// Ruby specify `specify "::symbolize_dependency_hash" do` at line 179.
pub fn ruby_formula_struct_generator_spec_l179_d11_symbolize_dependency_hash() bool {
	output := generator.ruby_formula_struct_generator_l223_d3_symbolize_dependency_hash(ruby_formula_struct_generator_spec_l7_d1_raw_dependency_hash())
	return formula_struct_generator_spec_maps_equal(output, ruby_formula_struct_generator_spec_l29_d2_symbolized_dependency_hash())
}

// Ruby specify `specify "::process_dependencies" do` at line 184.
pub fn ruby_formula_struct_generator_spec_l184_d12_process_dependencies() bool {
	output := generator.ruby_formula_struct_generator_l251_d4_process_dependencies(ruby_formula_struct_generator_spec_l29_d2_symbolized_dependency_hash())
	return formula_struct_generator_spec_values_equal(output, ruby_formula_struct_generator_spec_l51_d3_dependency_args())
}

// Ruby specify `specify "::process_uses_from_macos" do` at line 189.
pub fn ruby_formula_struct_generator_spec_l189_d13_process_uses_from_macos() bool {
	output := generator.ruby_formula_struct_generator_l299_d6_process_uses_from_macos(ruby_formula_struct_generator_spec_l29_d2_symbolized_dependency_hash())
	return formula_struct_generator_spec_pairs_equal(output, ruby_formula_struct_generator_spec_l59_d4_uses_from_macos_args())
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "api"
// 5:
// 6: RSpec.describe Homebrew::API::Formula::FormulaStructGenerator do
// 7:   let(:raw_dependency_hash) do
// 8:     {
// 9:       "dependencies"           => [
// 10:         "foo",
// 11:         { "bar" => "build" },
// 12:         { "baz" => ["build", "test"] },
// 13:       ],
// 14:       "uses_from_macos"        => [
// 15:         "abc",
// 16:         { "def" => "build" },
// 17:         { "ghi" => ["build", "test"] },
// 18:         "jkl",
// 19:       ],
// 20:       "uses_from_macos_bounds" => [
// 21:         {},
// 22:         { "since" => "catalina" },
// 23:         {},
// 24:         { "since" => "catalina" },
// 25:       ],
// 26:     }
// 27:   end
// 28:
// 29:   let(:symbolized_dependency_hash) do
// 30:     {
// 31:       "dependencies"           => [
// 32:         "foo",
// 33:         { "bar" => :build },
// 34:         { "baz" => [:build, :test] },
// 35:       ],
// 36:       "uses_from_macos"        => [
// 37:         "abc",
// 38:         { "def" => :build },
// 39:         { "ghi" => [:build, :test] },
// 40:         "jkl",
// 41:       ],
// 42:       "uses_from_macos_bounds" => [
// 43:         {},
// 44:         { since: :catalina },
// 45:         {},
// 46:         { since: :catalina },
// 47:       ],
// 48:     }
// 49:   end
// 50:
// 51:   let(:dependency_args) do
// 52:     [
// 53:       "foo",
// 54:       { "bar" => :build },
// 55:       { "baz" => [:build, :test] },
// 56:     ]
// 57:   end
// 58:
// 59:   let(:uses_from_macos_args) do
// 60:     [
// 61:       ["abc", {}],
// 62:       [{ "def" => :build, since: :catalina }, {}],
// 63:       [{ "ghi" => [:build, :test] }, {}],
// 64:       ["jkl", { since: :catalina }],
// 65:     ]
// 66:   end
// 67:
// 68:   let(:requirements_array) do
// 69:     [
// 70:       { "name" => "linux", "specs" => ["head"] },
// 71:       { "name" => "codesign", "specs" => ["stable", "head"] },
// 72:       { "name" => "arch", "version" => "arm64", "specs" => ["stable", "head"] },
// 73:       { "name" => "macos", "version" => "14", "specs" => ["stable"] },
// 74:       { "name" => "maximum_macos", "version" => "13", "specs" => ["stable", "head"], "contexts" => ["build"] },
// 75:       { "name" => "xcode", "specs" => ["stable", "head"] },
// 76:       { "name" => "xcode", "version" => "11.2", "specs" => ["stable", "head"], "contexts" => ["build", "test"] },
// 77:     ]
// 78:   end
// 79:
// 80:   let(:stable_requirements_args) do
// 81:     [
// 82:       { arch: [:arm64] },
// 83:       { macos: [:sonoma] },
// 84:       { maximum_macos: [:ventura, :build] },
// 85:       :xcode,
// 86:       { xcode: ["11.2", :build, :test] },
// 87:     ]
// 88:   end
// 89:
// 90:   let(:head_requirements_args) do
// 91:     [
// 92:       :linux,
// 93:       { arch: [:arm64] },
// 94:       { maximum_macos: [:ventura, :build] },
// 95:       :xcode,
// 96:       { xcode: ["11.2", :build, :test] },
// 97:     ]
// 98:   end
// 99:
// 100:   specify "::process_dependencies_and_requirements", :aggregate_failures do
// 101:     expect(
// 102:       described_class.process_dependencies_and_requirements(
// 103:         raw_dependency_hash, requirements_array, :stable
// 104:       ),
// 105:     ).to eq [dependency_args + stable_requirements_args, uses_from_macos_args]
// 106:
// 107:     expect(
// 108:       described_class.process_dependencies_and_requirements(
// 109:         raw_dependency_hash, requirements_array, :head
// 110:       ),
// 111:     ).to eq [dependency_args + head_requirements_args, uses_from_macos_args]
// 112:
// 113:     expect(
// 114:       described_class.process_dependencies_and_requirements(
// 115:         raw_dependency_hash, nil, :head
// 116:       ),
// 117:     ).to eq [dependency_args, uses_from_macos_args]
// 118:
// 119:     expect(
// 120:       described_class.process_dependencies_and_requirements(
// 121:         nil, requirements_array, :stable
// 122:       ),
// 123:     ).to eq [stable_requirements_args, []]
// 124:
// 125:     expect(
// 126:       described_class.process_dependencies_and_requirements(
// 127:         nil, requirements_array, :head
// 128:       ),
// 129:     ).to eq [head_requirements_args, []]
// 130:
// 131:     expect(
// 132:       described_class.process_dependencies_and_requirements(
// 133:         nil, nil, :stable
// 134:       ),
// 135:     ).to eq [[], []]
// 136:   end
// 137:
// 138:   specify "::generate_formula_struct_hash falls back to stable deps when head_dependencies is absent" do
// 139:     hash = {
// 140:       "desc"                     => "Test formula",
// 141:       "homepage"                 => "https://example.com",
// 142:       "license"                  => "MIT",
// 143:       "ruby_source_checksum"     => { "sha256" => "abc123" },
// 144:       "versions"                 => { "stable" => "1.0.0" },
// 145:       "urls"                     => { "stable" => { "url" => "https://example.com/foo-1.0.tar.gz" } },
// 146:       "dependencies"             => ["foo"],
// 147:       "recommended_dependencies" => [],
// 148:       "optional_dependencies"    => [],
// 149:       "uses_from_macos"          => [],
// 150:       "uses_from_macos_bounds"   => [],
// 151:     }
// 152:
// 153:     struct = described_class.generate_formula_struct_hash(hash)
// 154:
// 155:     expect(struct.head_dependencies).not_to be_empty
// 156:     expect(struct.head_dependencies).to eq struct.stable_dependencies
// 157:   end
// 158:
// 159:   specify "::generate_formula_struct_hash preserves stable patches" do
// 160:     hash = {
// 161:       "desc"                 => "Test formula",
// 162:       "homepage"             => "https://example.com",
// 163:       "license"              => "MIT",
// 164:       "ruby_source_checksum" => { "sha256" => "abc123" },
// 165:       "versions"             => { "stable" => "1.0.0" },
// 166:       "urls"                 => { "stable" => { "url" => "https://example.com/foo-1.0.tar.gz" } },
// 167:       "patches"              => [
// 168:         {
// 169:           "strip"  => "p1",
// 170:           "url"    => "https://example.com/foo.patch",
// 171:           "sha256" => "def456",
// 172:         },
// 173:       ],
// 174:     }
// 175:
// 176:     expect(described_class.generate_formula_struct_hash(hash).stable_patches).to eq hash["patches"]
// 177:   end
// 178:
// 179:   specify "::symbolize_dependency_hash" do
// 180:     output = described_class.symbolize_dependency_hash(raw_dependency_hash)
// 181:     expect(output).to eq symbolized_dependency_hash
// 182:   end
// 183:
// 184:   specify "::process_dependencies" do
// 185:     output = described_class.process_dependencies(symbolized_dependency_hash)
// 186:     expect(output).to eq dependency_args
// 187:   end
// 188:
// 189:   specify "::process_uses_from_macos" do
// 190:     output = described_class.process_uses_from_macos(symbolized_dependency_hash)
// 191:     expect(output).to eq uses_from_macos_args
// 192:   end
// 193: end
