module cask

import ruby
import homebrew.api
import homebrew.api.cask as generator
import homebrew.requirements

// Translated from Homebrew/brew `test/api/cask/cask_struct_generator_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn cask_struct_generator_spec_symbol(value string) ruby.Value {
	return ruby.object_value('Symbol', value.trim_string_left(':'))
}

fn cask_struct_generator_spec_string_array(values []string) ruby.Value {
	return ruby.array_value(values.map(ruby.string_value(it)))
}

fn cask_struct_generator_spec_requirement(tags []string, comparator string) ruby.Value {
	requirement := requirements.new_macos_requirement(tags, comparator) or { panic(err) }
	return ruby.Value{
		type_name: 'MacOSRequirement'
		repr: requirement.inspect()
		map_data: {
			'comparator': ruby.string_value(requirement.comparator)
			'versions':   ruby.string_array_value(requirement.versions.map(it.str()))
		}
	}
}

fn cask_struct_generator_spec_maps_equal(left map[string]ruby.Value,
	right map[string]ruby.Value) bool {
	return api.api_struct_value_equal(ruby.map_value(left), ruby.map_value(right))
}

// Ruby let `let(:depends_on_non_macos) do` at line 8.
pub fn ruby_cask_struct_generator_spec_l8_d1_depends_on_non_macos() map[string]ruby.Value {
	return {
		'arch':    ruby.array_value([
			ruby.map_value({
				'type': cask_struct_generator_spec_symbol('intel')
				'bits': ruby.int_value(64)
			}),
		])
		'formula': cask_struct_generator_spec_string_array(['foo'])
	}
}

// Ruby let `let(:depends_on_linux) { { linux: LinuxRequirement.new } }` at line 14.
pub fn ruby_cask_struct_generator_spec_l14_d2_depends_on_linux() map[string]ruby.Value {
	return {
		'linux': ruby.object_value('LinuxRequirement', 'Linux')
	}
}

// Ruby let `let(:depends_on_macos_equals) { { macos: { :== => ["15"] } } }` at line 15.
pub fn ruby_cask_struct_generator_spec_l15_d3_depends_on_macos_equals() map[string]ruby.Value {
	return {
		'macos': ruby.map_value({
			'==': cask_struct_generator_spec_string_array(['15'])
		})
	}
}

// Ruby let `let(:depends_on_macos_greater) { { macos: MacOSRequirement.new([:sequoia], comparator: ">=") } }` at line 16.
pub fn ruby_cask_struct_generator_spec_l16_d4_depends_on_macos_greater() map[string]ruby.Value {
	return {
		'macos': cask_struct_generator_spec_requirement(['sequoia'], '>=')
	}
}

// Ruby let `let(:depends_on_macos_bare) { { macos: MacOSRequirement.new([]) } }` at line 17.
pub fn ruby_cask_struct_generator_spec_l17_d5_depends_on_macos_bare() map[string]ruby.Value {
	return {
		'macos': cask_struct_generator_spec_requirement([], '>=')
	}
}

// Ruby let `let(:depends_on_maximum_macos) { { maximum_macos: MacOSRequirement.new([:sequoia], comparator: "<=") } }` at line 18.
pub fn ruby_cask_struct_generator_spec_l18_d6_depends_on_maximum_macos() map[string]ruby.Value {
	return {
		'maximum_macos': cask_struct_generator_spec_requirement(['sequoia'], '<=')
	}
}

// Ruby specify `specify :aggregate_failures do` at line 20.
pub fn ruby_cask_struct_generator_spec_l20_d7_aggregate_failures() bool {
	non_macos := generator.ruby_cask_struct_generator_l110_d2_process_depends_on(ruby_cask_struct_generator_spec_l8_d1_depends_on_non_macos())
	linux := generator.ruby_cask_struct_generator_l110_d2_process_depends_on(ruby_cask_struct_generator_spec_l14_d2_depends_on_linux())
	macos_equals := generator.ruby_cask_struct_generator_l110_d2_process_depends_on(ruby_cask_struct_generator_spec_l15_d3_depends_on_macos_equals())
	macos_greater := generator.ruby_cask_struct_generator_l110_d2_process_depends_on(ruby_cask_struct_generator_spec_l16_d4_depends_on_macos_greater())
	macos_bare := generator.ruby_cask_struct_generator_l110_d2_process_depends_on(ruby_cask_struct_generator_spec_l17_d5_depends_on_macos_bare())
	empty_macos := generator.ruby_cask_struct_generator_l110_d2_process_depends_on({
		'macos': ruby.map_value({})
	})
	maximum_macos := generator.ruby_cask_struct_generator_l110_d2_process_depends_on(ruby_cask_struct_generator_spec_l18_d6_depends_on_maximum_macos())
	return cask_struct_generator_spec_maps_equal(non_macos, {
		'arch':    cask_struct_generator_spec_symbol('intel')
		'formula': cask_struct_generator_spec_string_array(['foo'])
	}) && cask_struct_generator_spec_maps_equal(linux, {
		'linux': cask_struct_generator_spec_symbol('any')
	}) && cask_struct_generator_spec_maps_equal(macos_equals, {
		'macos': ruby.array_value([
			cask_struct_generator_spec_symbol('sequoia'),
		])
	}) && cask_struct_generator_spec_maps_equal(macos_greater, {
		'macos': cask_struct_generator_spec_symbol('sequoia')
	}) && cask_struct_generator_spec_maps_equal(macos_bare, {
		'macos': cask_struct_generator_spec_symbol('any')
	}) && cask_struct_generator_spec_maps_equal(empty_macos, {
		'macos': cask_struct_generator_spec_symbol('any')
	}) && cask_struct_generator_spec_maps_equal(maximum_macos, {
		'maximum_macos': cask_struct_generator_spec_symbol('sequoia')
	})
}

// Ruby specify `specify "::process_artifacts" do` at line 45.
pub fn ruby_cask_struct_generator_spec_l45_d8_process_artifacts() bool {
	input := [
		ruby.map_value({
			'preflight': ruby.object_value('NilClass', '')
		}),
		ruby.map_value({
			'foo': cask_struct_generator_spec_string_array(['arg1', 'arg2'])
		}),
		ruby.map_value({
			'bar': ruby.array_value([
				ruby.string_value('arg1'),
				ruby.string_value('arg2'),
				ruby.map_value({
					'kwarg1': ruby.string_value('value1')
				}),
			])
		}),
		ruby.map_value({
			'baz': ruby.array_value([
				ruby.map_value({
					'kwarg1': ruby.string_value('value1')
				}),
			])
		}),
		ruby.map_value({
			'target':         ruby.string_value(r'$HOMEBREW_PREFIX/share/zsh/site-functions/_foo')
			'zsh_completion': cask_struct_generator_spec_string_array([
				r'$APPDIR/Foo.app/Contents/Resources/completions/zsh/_foo',
			])
		}),
		ruby.map_value({
			'zsh_completion': cask_struct_generator_spec_string_array([
				r'$APPDIR/Bar.app/Contents/Resources/completions/zsh/_bar',
			])
			'target':         ruby.string_value(r'$HOMEBREW_PREFIX/share/zsh/site-functions/_bar')
		}),
		ruby.map_value({
			'target': ruby.string_value('/Applications/Bar.app')
			'app':    ruby.array_value([
				ruby.string_value('Foo.app'),
				ruby.map_value({
					'target': ruby.string_value('Bar.app')
				}),
			])
		}),
	]
	output := generator.ruby_cask_struct_generator_l146_d3_process_artifacts(input)
	return output.len == 7 && output[0].key == 'preflight' && output[0].args.len == 0
		&& output[0].kwargs.len == 0 && output[0].has_block && output[1].key == 'foo'
		&& output[1].args.map(it.as_string()) == ['arg1', 'arg2'] && output[2].key == 'bar'
		&& output[2].args.map(it.as_string()) == ['arg1', 'arg2']
		&& output[2].kwargs['kwarg1'].as_string() == 'value1' && output[3].key == 'baz'
		&& output[3].args.len == 0 && output[3].kwargs['kwarg1'].as_string() == 'value1'
		&& output[4].key == 'zsh_completion' && output[4].args[0].as_string().contains('Foo.app')
		&& output[5].key == 'zsh_completion' && output[5].args[0].as_string().contains('Bar.app')
		&& output[6].key == 'app' && output[6].args[0].as_string() == 'Foo.app'
		&& output[6].kwargs['target'].as_string() == 'Bar.app'
}

// Ruby specify `specify "::process_url_specs" do` at line 77.
pub fn ruby_cask_struct_generator_spec_l77_d9_process_url_specs() bool {
	output := generator.ruby_cask_struct_generator_l165_d4_process_url_specs({
		'user_agent': ruby.string_value(':fake')
		'using':      ruby.string_value('curl')
		'foo':        ruby.object_value('NilClass', '')
		'bar':        ruby.string_value('baz')
	})
	return cask_struct_generator_spec_maps_equal(output, {
		'user_agent': cask_struct_generator_spec_symbol('fake')
		'using':      cask_struct_generator_spec_symbol('curl')
		'bar':        ruby.string_value('baz')
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "api"
// 5:
// 6: RSpec.describe Homebrew::API::Cask::CaskStructGenerator do
// 7:   describe ":process_depends_on" do
// 8:     let(:depends_on_non_macos) do
// 9:       {
// 10:         arch:    [{ type: :intel, bits: 64 }],
// 11:         formula: ["foo"],
// 12:       }
// 13:     end
// 14:     let(:depends_on_linux) { { linux: LinuxRequirement.new } }
// 15:     let(:depends_on_macos_equals) { { macos: { :== => ["15"] } } }
// 16:     let(:depends_on_macos_greater) { { macos: MacOSRequirement.new([:sequoia], comparator: ">=") } }
// 17:     let(:depends_on_macos_bare) { { macos: MacOSRequirement.new([]) } }
// 18:     let(:depends_on_maximum_macos) { { maximum_macos: MacOSRequirement.new([:sequoia], comparator: "<=") } }
// 19:
// 20:     specify :aggregate_failures do
// 21:       expect(
// 22:         described_class.process_depends_on(depends_on_non_macos),
// 23:       ).to eq({ arch: :intel, formula: ["foo"] })
// 24:       expect(
// 25:         described_class.process_depends_on(depends_on_linux),
// 26:       ).to eq({ linux: :any })
// 27:       expect(
// 28:         described_class.process_depends_on(depends_on_macos_equals),
// 29:       ).to eq({ macos: [:sequoia] })
// 30:       expect(
// 31:         described_class.process_depends_on(depends_on_macos_greater),
// 32:       ).to eq({ macos: :sequoia })
// 33:       expect(
// 34:         described_class.process_depends_on(depends_on_macos_bare),
// 35:       ).to eq({ macos: :any })
// 36:       expect(
// 37:         described_class.process_depends_on({ macos: {} }),
// 38:       ).to eq({ macos: :any })
// 39:       expect(
// 40:         described_class.process_depends_on(depends_on_maximum_macos),
// 41:       ).to eq({ maximum_macos: :sequoia })
// 42:     end
// 43:   end
// 44:
// 45:   specify "::process_artifacts" do
// 46:     input = [
// 47:       { preflight: nil },
// 48:       { foo:       ["arg1", "arg2"] },
// 49:       { bar:       ["arg1", "arg2", { kwarg1: "value1" }] },
// 50:       { baz:       [{ kwarg1: "value1" }] },
// 51:       {
// 52:         target:         "$HOMEBREW_PREFIX/share/zsh/site-functions/_foo",
// 53:         zsh_completion: ["$APPDIR/Foo.app/Contents/Resources/completions/zsh/_foo"],
// 54:       },
// 55:       {
// 56:         zsh_completion: ["$APPDIR/Bar.app/Contents/Resources/completions/zsh/_bar"],
// 57:         target:         "$HOMEBREW_PREFIX/share/zsh/site-functions/_bar",
// 58:       },
// 59:       {
// 60:         target: "/Applications/Bar.app",
// 61:         app:    ["Foo.app", { target: "Bar.app" }],
// 62:       },
// 63:     ]
// 64:     expected_output = [
// 65:       [:preflight, [], {}, Homebrew::API::CaskStruct::EMPTY_BLOCK],
// 66:       [:foo, ["arg1", "arg2"], {}, nil],
// 67:       [:bar, ["arg1", "arg2"], { kwarg1: "value1" }, nil],
// 68:       [:baz, [], { kwarg1: "value1" }, nil],
// 69:       [:zsh_completion, ["$APPDIR/Foo.app/Contents/Resources/completions/zsh/_foo"], {}, nil],
// 70:       [:zsh_completion, ["$APPDIR/Bar.app/Contents/Resources/completions/zsh/_bar"], {}, nil],
// 71:       [:app, ["Foo.app"], { target: "Bar.app" }, nil],
// 72:     ]
// 73:     output = described_class.process_artifacts(input)
// 74:     expect(output).to eq expected_output
// 75:   end
// 76:
// 77:   specify "::process_url_specs" do
// 78:     input = {
// 79:       user_agent: ":fake",
// 80:       using:      "curl",
// 81:       foo:        nil,
// 82:       bar:        "baz",
// 83:     }
// 84:     expected_output = {
// 85:       user_agent: :fake,
// 86:       using:      :curl,
// 87:       bar:        "baz",
// 88:     }
// 89:     output = described_class.process_url_specs(input)
// 90:     expect(output).to eq expected_output
// 91:   end
// 92: end
