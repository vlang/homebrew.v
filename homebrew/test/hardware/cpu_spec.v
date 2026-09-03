module hardware

import brew_runtime
import homebrew
import homebrew.extend.os.mac.hardware as mac_hardware
import homebrew.extend.os.mac.hardware.cpu as mac_cpu

fn cpu_spec_types() []string {
	return ['arm', 'intel', 'ppc', 'dunno']
}

fn cpu_spec_families() []string {
	return ['alderlake', 'amd_k7', 'amd_k8', 'amd_k8_k10_hybrid', 'amd_k10', 'amd_k10_llano', 'arm',
		'arm_blizzard_avalanche', 'arm_brava', 'arm_donan', 'arm_firestorm_icestorm', 'arm_hidra',
		'arm_hurricane_zephyr', 'arm_ibiza', 'arm_lightning_thunder', 'arm_lobos',
		'arm_monsoon_mistral', 'arm_palma', 'arm_sotra', 'arm_twister', 'arm_typhoon',
		'arm_vortex_tempest', 'arrowlake', 'atom', 'bobcat', 'broadwell', 'bulldozer', 'cannonlake',
		'cometlake', 'core', 'core2', 'dothan', 'graniterapids', 'haswell', 'icelake', 'ivybridge',
		'jaguar', 'kabylake', 'merom', 'nehalem', 'pantherlake', 'penryn', 'ppc', 'prescott',
		'presler', 'rocketlake', 'sandybridge', 'sapphirerapids', 'skylake', 'tigerlake', 'westmere',
		'zen', 'zen2', 'zen3', 'zen4', 'zen5', 'dunno']
}

// Translated from Homebrew/brew `test/hardware/cpu_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cpu_types) do` at line 8.
pub fn ruby_cpu_spec_l8_d1_cpu_types(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(cpu_spec_types())
}

// Ruby it `it "returns the current CPU's type as a symbol, or :dunno if it cannot be detected" do` at line 17.
pub fn ruby_cpu_spec_l17_d2_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(homebrew.hardware_cpu_type(homebrew.current_hardware_cpu().platform) in cpu_spec_types())
}

// Ruby it `it "falls back when hw.cputype cannot be detected on a Mac", :needs_macos do` at line 21.
pub fn ruby_cpu_spec_l21_d3_falls(args ...brew_runtime.Value) brew_runtime.Value {
	properties := mac_cpu.MacCpuProperties{
		values: {
			'hw.cputype': '0'
		}
	}
	return brew_runtime.bool_value(mac_hardware.mac_hardware_cpu_type(properties, 'arm64') != 'dunno')
}

// Ruby let `let(:cpu_families) do` at line 30.
pub fn ruby_cpu_spec_l30_d4_cpu_families(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(cpu_spec_families())
}

// Ruby it `it "returns the current CPU's family name as a symbol, or :dunno if it cannot be detected" do` at line 92.
pub fn ruby_cpu_spec_l92_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	cpu := homebrew.current_hardware_cpu()
	family := if cpu.family == '' { 'dunno' } else { cpu.family }
	return brew_runtime.bool_value(family in cpu_spec_families())
}

// Ruby it `it "returns :arm_firestorm_icestorm on ARM" do` at line 104.
pub fn ruby_cpu_spec_l104_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	properties := mac_cpu.MacCpuProperties{
		values: {
			'hw.cpufamily': '1463508716'
		}
	}
	return brew_runtime.bool_value(mac_hardware.mac_hardware_cpu_family(properties, true, false) == 'arm_firestorm_icestorm')
}

// Ruby it `it "returns :westmere on Intel" do` at line 110.
pub fn ruby_cpu_spec_l110_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	properties := mac_cpu.MacCpuProperties{
		values: {
			'hw.cpufamily': '1463508716'
		}
	}
	return brew_runtime.bool_value(mac_hardware.mac_hardware_cpu_family(properties, false, true) == 'westmere')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "hardware"
// 5:
// 6: RSpec.describe Hardware::CPU do
// 7:   describe "::type" do
// 8:     let(:cpu_types) do
// 9:       [
// 10:         :arm,
// 11:         :intel,
// 12:         :ppc,
// 13:         :dunno,
// 14:       ]
// 15:     end
// 16:
// 17:     it "returns the current CPU's type as a symbol, or :dunno if it cannot be detected" do
// 18:       expect(cpu_types).to include(described_class.type)
// 19:     end
// 20:
// 21:     it "falls back when hw.cputype cannot be detected on a Mac", :needs_macos do
// 22:       expect(described_class).to receive(:sysctl_int).with("hw.cputype").and_return(0)
// 23:
// 24:       # Unlike the previous test, we can usually assume this will never be `dunno` on a Mac.
// 25:       expect(described_class.type).not_to eq(:dunno)
// 26:     end
// 27:   end
// 28:
// 29:   describe "::family" do
// 30:     let(:cpu_families) do
// 31:       [
// 32:         :alderlake,
// 33:         :amd_k7,
// 34:         :amd_k8,
// 35:         :amd_k8_k10_hybrid,
// 36:         :amd_k10,
// 37:         :amd_k10_llano,
// 38:         :arm,
// 39:         :arm_blizzard_avalanche,
// 40:         :arm_brava,
// 41:         :arm_donan,
// 42:         :arm_firestorm_icestorm,
// 43:         :arm_hidra,
// 44:         :arm_hurricane_zephyr,
// 45:         :arm_ibiza,
// 46:         :arm_lightning_thunder,
// 47:         :arm_lobos,
// 48:         :arm_monsoon_mistral,
// 49:         :arm_palma,
// 50:         :arm_sotra,
// 51:         :arm_twister,
// 52:         :arm_typhoon,
// 53:         :arm_vortex_tempest,
// 54:         :arrowlake,
// 55:         :atom,
// 56:         :bobcat,
// 57:         :broadwell,
// 58:         :bulldozer,
// 59:         :cannonlake,
// 60:         :cometlake,
// 61:         :core,
// 62:         :core2,
// 63:         :dothan,
// 64:         :graniterapids,
// 65:         :haswell,
// 66:         :icelake,
// 67:         :ivybridge,
// 68:         :jaguar,
// 69:         :kabylake,
// 70:         :merom,
// 71:         :nehalem,
// 72:         :pantherlake,
// 73:         :penryn,
// 74:         :ppc,
// 75:         :prescott,
// 76:         :presler,
// 77:         :rocketlake,
// 78:         :sandybridge,
// 79:         :sapphirerapids,
// 80:         :skylake,
// 81:         :tigerlake,
// 82:         :westmere,
// 83:         :zen,
// 84:         :zen2,
// 85:         :zen3,
// 86:         :zen4,
// 87:         :zen5,
// 88:         :dunno,
// 89:       ]
// 90:     end
// 91:
// 92:     it "returns the current CPU's family name as a symbol, or :dunno if it cannot be detected" do
// 93:       expect(cpu_families).to include described_class.family
// 94:     end
// 95:
// 96:     context "when hw.cpufamily is 0x573b5eec on a Mac", :needs_macos do
// 97:       before do
// 98:         allow(described_class)
// 99:           .to receive(:sysctl_int)
// 100:           .with("hw.cpufamily")
// 101:           .and_return(0x573b5eec)
// 102:       end
// 103:
// 104:       it "returns :arm_firestorm_icestorm on ARM" do
// 105:         allow(described_class).to receive_messages(arm?: true, intel?: false)
// 106:
// 107:         expect(described_class.family).to eq(:arm_firestorm_icestorm)
// 108:       end
// 109:
// 110:       it "returns :westmere on Intel" do
// 111:         allow(described_class).to receive_messages(arm?: false, intel?: true)
// 112:
// 113:         expect(described_class.family).to eq(:westmere)
// 114:       end
// 115:     end
// 116:   end
// 117: end
