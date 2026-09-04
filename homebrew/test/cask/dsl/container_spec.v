module dsl

import ruby
import homebrew.cask.dsl as cask_dsl

// Translated from Homebrew/brew `test/cask/dsl/container_spec.rb`.
// The executable helpers below retain each RSpec boundary while exercising the
// translated Cask::DSL::Container implementation.

fn container_spec_symbol(value string) ruby.Value {
	return ruby.Value{
		type_name: 'Symbol'
		repr: value.trim_left(':')
	}
}

fn container_spec_container_from(args []ruby.Value, fallback ruby.Value) ruby.Value {
	params := if args.len > 0 { args[0] } else { fallback }
	return cask_dsl.ruby_container_l17_d5_initialize(params)
}

// Ruby subject `subject(:container) { described_class.new(**params) }` at line 7.
pub fn ruby_container_spec_l7_d1_container(args ...ruby.Value) ruby.Value {
	return container_spec_container_from(args, ruby_container_spec_l9_d2_params())
}

// Ruby let `let(:params) { {} }` at line 9.
pub fn ruby_container_spec_l9_d2_params(args ...ruby.Value) ruby.Value {
	return ruby.map_value({})
}

// Ruby let `let(:params) { { nested: "NestedApp.dmg" } }` at line 12.
pub fn ruby_container_spec_l12_d3_params(args ...ruby.Value) ruby.Value {
	return ruby.map_value({
		'nested': ruby.string_value('NestedApp.dmg')
	})
}

// Ruby it `it "returns the attributes as a hash" do` at line 14.
pub fn ruby_container_spec_l14_d4_returns(args ...ruby.Value) ruby.Value {
	container := container_spec_container_from(args, ruby_container_spec_l12_d3_params())
	pairs := cask_dsl.ruby_container_l28_d6_pairs(container)
	nested := pairs.map_data['nested'] or { return ruby.bool_value(false) }
	return ruby.bool_value(pairs.map_data.len == 1 && nested.type_name == 'String'
		&& nested.as_string() == 'NestedApp.dmg')
}

// Ruby let `let(:params) { { nested: "NestedApp.dmg", type: :naked } }` at line 20.
pub fn ruby_container_spec_l20_d5_params(args ...ruby.Value) ruby.Value {
	return ruby.map_value({
		'nested': ruby.string_value('NestedApp.dmg')
		'type':   container_spec_symbol('naked')
	})
}

// Ruby it `it "returns the stringified attributes" do` at line 22.
pub fn ruby_container_spec_l22_d6_returns(args ...ruby.Value) ruby.Value {
	params := if args.len > 0 { args[0] } else { ruby_container_spec_l20_d5_params() }
	container := cask_dsl.ruby_container_l17_d5_initialize(params)
	actual := cask_dsl.ruby_container_l38_d8_to_s(container)
	return ruby.bool_value(actual.as_string() == '{:nested=>"NestedApp.dmg", :type=>:naked}')
}

// Ruby let `let(:params) { { nested: "NestedApp.dmg", type: :naked } }` at line 28.
pub fn ruby_container_spec_l28_d7_params(args ...ruby.Value) ruby.Value {
	return ruby.map_value({
		'nested': ruby.string_value('NestedApp.dmg')
		'type':   container_spec_symbol('naked')
	})
}

// Ruby it `it "returns the attributes in YAML format" do` at line 30.
pub fn ruby_container_spec_l30_d8_returns(args ...ruby.Value) ruby.Value {
	container := container_spec_container_from(args, ruby_container_spec_l28_d7_params())
	actual := cask_dsl.ruby_container_l33_d7_to_yaml(container)
	return ruby.bool_value(actual.as_string() == '---\n:nested: NestedApp.dmg\n:type: :naked\n')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "test/cask/dsl/shared_examples/base"
// 5:
// 6: RSpec.describe Cask::DSL::Container do
// 7:   subject(:container) { described_class.new(**params) }
// 8:
// 9:   let(:params) { {} }
// 10:
// 11:   describe "#pairs" do
// 12:     let(:params) { { nested: "NestedApp.dmg" } }
// 13:
// 14:     it "returns the attributes as a hash" do
// 15:       expect(container.pairs).to eq(nested: "NestedApp.dmg")
// 16:     end
// 17:   end
// 18:
// 19:   describe "#to_s" do
// 20:     let(:params) { { nested: "NestedApp.dmg", type: :naked } }
// 21:
// 22:     it "returns the stringified attributes" do
// 23:       expect(container.to_s).to eq(params.inspect)
// 24:     end
// 25:   end
// 26:
// 27:   describe "#to_yaml" do
// 28:     let(:params) { { nested: "NestedApp.dmg", type: :naked } }
// 29:
// 30:     it "returns the attributes in YAML format" do
// 31:       expect(container.to_yaml).to eq(<<~YAML)
// 32:         ---
// 33:         :nested: NestedApp.dmg
// 34:         :type: :naked
// 35:       YAML
// 36:     end
// 37:   end
// 38: end
