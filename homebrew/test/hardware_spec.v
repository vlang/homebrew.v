module test

import brew_runtime
import homebrew

// Translated from Homebrew/brew `test/hardware_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns a specific Zig target CPU for known archs" do` at line 8.
pub fn ruby_hardware_spec_l8_d1_returns(args ...brew_runtime.Value) brew_runtime.Value {
	cpu := homebrew.HardwareCpu{platform: 'x86_64'}
	for arch in homebrew.hardware_optimization_flags(cpu).keys() {
		if arch != 'dunno' && homebrew.hardware_zig_cpu(arch) == 'baseline' {
			return brew_runtime.bool_value(false)
		}
	}
	return brew_runtime.bool_value(true)
}

// Ruby it `it "returns baseline Zig target CPU for unknown arch" do` at line 16.
pub fn ruby_hardware_spec_l16_d2_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(homebrew.hardware_zig_cpu('dunno') == 'baseline')
}

// Ruby it `it "converts GCC -march with dashes to Zig-equivalent target CPU" do` at line 20.
pub fn ruby_hardware_spec_l20_d3_converts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(homebrew.hardware_zig_cpu('x86-64-v4') == 'x86_64_v4')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "hardware"
// 5:
// 6: RSpec.describe Hardware do
// 7:   describe ".zig_cpu" do
// 8:     it "returns a specific Zig target CPU for known archs" do
// 9:       Hardware::CPU.optimization_flags.each_key do |arch|
// 10:         next if arch == :dunno
// 11:
// 12:         expect(described_class.zig_cpu(arch)).not_to be :baseline
// 13:       end
// 14:     end
// 15:
// 16:     it "returns baseline Zig target CPU for unknown arch" do
// 17:       expect(described_class.zig_cpu(:dunno)).to be :baseline
// 18:     end
// 19:
// 20:     it "converts GCC -march with dashes to Zig-equivalent target CPU" do
// 21:       expect(described_class.zig_cpu(:"x86-64-v4")).to be :x86_64_v4
// 22:     end
// 23:   end
// 24: end
