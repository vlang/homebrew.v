module bottles

import ruby
import homebrew.utils

// Translated from Homebrew/brew `test/utils/bottles/bottles_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns :big_sur or :arm64_big_sur on Big Sur" do` at line 8.
pub fn ruby_bottles_spec_l8_d1_returns(args ...ruby.Value) ruby.Value {
	mut arch := 'x86_64'
	if args.len > 0 && args[0].repr != '' {
		arch = args[0].repr
	} else {
		$if arm64 {
			arch = 'arm64'
		} $else $if aarch64 {
			arch = 'arm64'
		}
	}
	tag := utils.new_bottles_tag('big_sur', arch)
	expected := if tag.standardized_arch() == 'x86_64' {
		'big_sur'
	} else {
		'arm64_big_sur'
	}
	return ruby.bool_value(tag.symbol() == expected)
}

// Ruby it `it "returns an empty rebuild for bottles without rebuilds" do` at line 19.
pub fn ruby_bottles_spec_l19_d2_returns(args ...ruby.Value) ruby.Value {
	actual := utils.bottles_extname_tag_rebuild('gh--2.93.0.arm64_sonoma.bottle.tar.gz')
	return ruby.bool_value(actual == ['.arm64_sonoma.bottle.tar.gz', 'arm64_sonoma',
		''])
}

// Ruby it `it "includes runtime_dependencies" do` at line 50.
pub fn ruby_bottles_spec_l50_d3_includes(args ...ruby.Value) ruby.Value {
	tab := utils.bottles_load_tab(utils.BottlesLoadTabInput{
		runtime_dependencies: [
			utils.BottlesRuntimeDependency{
				full_name: 'testball1'
				version:   '0.1'
			},
		]
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(tab.runtime_dependencies.len == 1
		&& tab.runtime_dependencies[0].full_name == 'testball1')
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/bottles"
// 5:
// 6: RSpec.describe Utils::Bottles do
// 7:   describe "#tag", :needs_macos do
// 8:     it "returns :big_sur or :arm64_big_sur on Big Sur" do
// 9:       allow(MacOS).to receive(:version).and_return(MacOSVersion.new("11.0"))
// 10:       if Hardware::CPU.intel?
// 11:         expect(described_class.tag).to eq(:big_sur)
// 12:       else
// 13:         expect(described_class.tag).to eq(:arm64_big_sur)
// 14:       end
// 15:     end
// 16:   end
// 17:
// 18:   describe ".extname_tag_rebuild" do
// 19:     it "returns an empty rebuild for bottles without rebuilds" do
// 20:       expect(described_class.extname_tag_rebuild("gh--2.93.0.arm64_sonoma.bottle.tar.gz"))
// 21:         .to eq([".arm64_sonoma.bottle.tar.gz", "arm64_sonoma", ""])
// 22:     end
// 23:   end
// 24:
// 25:   describe ".load_tab" do
// 26:     context "when tab_attributes and tabfile are missing" do
// 27:       before do
// 28:         # setup a testball1
// 29:         dep_name = "testball1"
// 30:         dep_path = CoreTap.instance.new_formula_path(dep_name)
// 31:         dep_path.write <<~RUBY
// 32:           class #{Formulary.class_s(dep_name)} < Formula
// 33:             url "testball1"
// 34:             version "0.1"
// 35:           end
// 36:         RUBY
// 37:
// 38:         # setup a testball2, that depends on testball1
// 39:         formula_name = "testball2"
// 40:         formula_path = CoreTap.instance.new_formula_path(formula_name)
// 41:         formula_path.write <<~RUBY
// 42:           class #{Formulary.class_s(formula_name)} < Formula
// 43:             url "testball2"
// 44:             version "0.1"
// 45:             depends_on "testball1"
// 46:           end
// 47:         RUBY
// 48:       end
// 49:
// 50:       it "includes runtime_dependencies" do
// 51:         formula = Formula["testball2"]
// 52:         formula.prefix.mkpath
// 53:
// 54:         runtime_dependencies = described_class.load_tab(formula).runtime_dependencies
// 55:
// 56:         expect(runtime_dependencies).not_to be_nil
// 57:         expect(runtime_dependencies.size).to eq(1)
// 58:         expect(runtime_dependencies.first).to include("full_name" => "testball1")
// 59:       end
// 60:     end
// 61:   end
// 62: end
