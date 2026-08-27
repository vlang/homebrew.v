module bottles

import brew_runtime

// Translated from Homebrew/brew `test/utils/bottles/tag_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "can parse macOS symbols with archs" do` at line 7.
pub fn ruby_tag_spec_l7_d1_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "can parse macOS symbols without archs" do` at line 18.
pub fn ruby_tag_spec_l18_d2_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "can parse Linux symbols" do` at line 29.
pub fn ruby_tag_spec_l29_d3_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "parses an explicit tag argument" do` at line 41.
pub fn ruby_tag_spec_l41_d4_parses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parses', ...args)
}

// Ruby it `it "builds from the given os and arch when no argument is passed" do` at line 46.
pub fn ruby_tag_spec_l46_d5_builds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('builds', ...args)
}

// Ruby it `it "compares using the standardized arch" do` at line 53.
pub fn ruby_tag_spec_l53_d6_compares(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compares', ...args)
}

// Ruby specify `specify do` at line 62.
pub fn ruby_tag_spec_l62_d7_do(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do', ...args)
}

// Ruby it `it "returns true for Intel" do` at line 69.
pub fn ruby_tag_spec_l69_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false for ARM on macOS Catalina" do` at line 76.
pub fn ruby_tag_spec_l76_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns true for ARM on macOS Big Sur or newer" do` at line 81.
pub fn ruby_tag_spec_l81_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns true for ARM on Linux" do` at line 90.
pub fn ruby_tag_spec_l90_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/bottles"
// 5:
// 6: RSpec.describe Utils::Bottles::Tag do
// 7:   it "can parse macOS symbols with archs" do
// 8:     symbol = :arm64_big_sur
// 9:     tag = described_class.from_symbol(symbol)
// 10:     expect(tag.system).to eq(:big_sur)
// 11:     expect(tag.arch).to eq(:arm64)
// 12:     expect(tag.to_macos_version).to eq(MacOSVersion.from_symbol(:big_sur))
// 13:     expect(tag.macos?).to be true
// 14:     expect(tag.linux?).to be false
// 15:     expect(tag.to_sym).to eq(symbol)
// 16:   end
// 17:
// 18:   it "can parse macOS symbols without archs" do
// 19:     symbol = :big_sur
// 20:     tag = described_class.from_symbol(symbol)
// 21:     expect(tag.system).to eq(:big_sur)
// 22:     expect(tag.arch).to eq(:x86_64)
// 23:     expect(tag.to_macos_version).to eq(MacOSVersion.from_symbol(:big_sur))
// 24:     expect(tag.macos?).to be true
// 25:     expect(tag.linux?).to be false
// 26:     expect(tag.to_sym).to eq(symbol)
// 27:   end
// 28:
// 29:   it "can parse Linux symbols" do
// 30:     symbol = :x86_64_linux
// 31:     tag = described_class.from_symbol(symbol)
// 32:     expect(tag.system).to eq(:linux)
// 33:     expect(tag.arch).to eq(:x86_64)
// 34:     expect { tag.to_macos_version }.to raise_error(MacOSVersion::Error)
// 35:     expect(tag.macos?).to be false
// 36:     expect(tag.linux?).to be true
// 37:     expect(tag.to_sym).to eq(symbol)
// 38:   end
// 39:
// 40:   describe ".from_arg" do
// 41:     it "parses an explicit tag argument" do
// 42:       expect(described_class.from_arg(:arm64_big_sur, os: :monterey, arch: :x86_64))
// 43:         .to eq(described_class.new(system: :big_sur, arch: :arm64))
// 44:     end
// 45:
// 46:     it "builds from the given os and arch when no argument is passed" do
// 47:       expect(described_class.from_arg(nil, os: :monterey, arch: :arm64))
// 48:         .to eq(described_class.new(system: :monterey, arch: :arm64))
// 49:     end
// 50:   end
// 51:
// 52:   describe "#==" do
// 53:     it "compares using the standardized arch" do
// 54:       monterey_intel = described_class.new(system: :monterey, arch: :intel)
// 55:       monterex_x86_64 = described_class.new(system: :monterey, arch: :x86_64)
// 56:
// 57:       expect(monterey_intel).to eq monterex_x86_64
// 58:     end
// 59:   end
// 60:
// 61:   describe "#standardized_arch" do
// 62:     specify do
// 63:       expect(described_class.new(system: :all, arch: :intel).standardized_arch).to eq(:x86_64)
// 64:       expect(described_class.new(system: :all, arch: :arm).standardized_arch).to eq(:arm64)
// 65:     end
// 66:   end
// 67:
// 68:   describe "#valid_combination?" do
// 69:     it "returns true for Intel" do
// 70:       tag = described_class.new(system: :big_sur, arch: :intel)
// 71:       expect(tag.valid_combination?).to be true
// 72:       tag = described_class.new(system: :linux, arch: :x86_64)
// 73:       expect(tag.valid_combination?).to be true
// 74:     end
// 75:
// 76:     it "returns false for ARM on macOS Catalina" do
// 77:       tag = described_class.new(system: :catalina, arch: :arm64)
// 78:       expect(tag.valid_combination?).to be false
// 79:     end
// 80:
// 81:     it "returns true for ARM on macOS Big Sur or newer" do
// 82:       tag = described_class.new(system: :big_sur, arch: :arm64)
// 83:       expect(tag.valid_combination?).to be true
// 84:       tag = described_class.new(system: :monterey, arch: :arm)
// 85:       expect(tag.valid_combination?).to be true
// 86:       tag = described_class.new(system: :ventura, arch: :arm)
// 87:       expect(tag.valid_combination?).to be true
// 88:     end
// 89:
// 90:     it "returns true for ARM on Linux" do
// 91:       tag = described_class.new(system: :linux, arch: :arm64)
// 92:       expect(tag.valid_combination?).to be true
// 93:       tag = described_class.new(system: :linux, arch: :arm)
// 94:       expect(tag.valid_combination?).to be true
// 95:     end
// 96:   end
// 97: end
