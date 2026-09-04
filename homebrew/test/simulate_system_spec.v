module test

import ruby
import homebrew
import homebrew.extend.os.linux
import homebrew.extend.os.mac

// Translated from Homebrew/brew `test/simulate_system_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns true on macOS", :needs_macos do` at line 12.
pub fn ruby_simulate_system_spec_l12_d1_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(mac.simulating_or_running_on_macos(''))
}

// Ruby it `it "returns false on Linux", :needs_linux do` at line 17.
pub fn ruby_simulate_system_spec_l17_d2_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!homebrew.new_system_simulation('linux', 'intel').simulating_or_running_on_macos())
}

// Ruby it `it "returns false on macOS when simulating Linux", :needs_macos do` at line 22.
pub fn ruby_simulate_system_spec_l22_d3_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!mac.simulating_or_running_on_macos('linux'))
}

// Ruby it `it "returns true on Linux when simulating a generic macOS version", :needs_linux do` at line 28.
pub fn ruby_simulate_system_spec_l28_d4_returns(args ...ruby.Value) ruby.Value {
	mut state := homebrew.new_system_simulation('linux', 'intel')
	state.set_os('macos') or { return ruby.bool_value(false) }
	return ruby.bool_value(state.simulating_or_running_on_macos())
}

// Ruby it `it "returns true on Linux when simulating a specific macOS version", :needs_linux do` at line 34.
pub fn ruby_simulate_system_spec_l34_d5_returns(args ...ruby.Value) ruby.Value {
	mut state := homebrew.new_system_simulation('linux', 'intel')
	state.set_os('monterey') or { return ruby.bool_value(false) }
	return ruby.bool_value(state.simulating_or_running_on_macos())
}

// Ruby it `it "returns true on Linux with HOMEBREW_SIMULATE_MACOS_ON_LINUX", :needs_linux do` at line 40.
pub fn ruby_simulate_system_spec_l40_d6_returns(args ...ruby.Value) ruby.Value {
	effective := linux.effective_os('', true, 'sequoia')
	return ruby.bool_value(mac.simulating_or_running_on_macos(effective))
}

// Ruby it `it "returns true on Linux", :needs_linux do` at line 48.
pub fn ruby_simulate_system_spec_l48_d7_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(linux.simulating_or_running_on_linux(''))
}

// Ruby it `it "returns false on macOS", :needs_macos do` at line 53.
pub fn ruby_simulate_system_spec_l53_d8_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!homebrew.new_system_simulation('macos', 'arm').simulating_or_running_on_linux())
}

// Ruby it `it "returns true on macOS when simulating Linux", :needs_macos do` at line 58.
pub fn ruby_simulate_system_spec_l58_d9_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(linux.simulating_or_running_on_linux('linux'))
}

// Ruby it `it "returns false on Linux when simulating a generic macOS version", :needs_linux do` at line 64.
pub fn ruby_simulate_system_spec_l64_d10_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!linux.simulating_or_running_on_linux('macos'))
}

// Ruby it `it "returns false on Linux when simulating a specific macOS version", :needs_linux do` at line 70.
pub fn ruby_simulate_system_spec_l70_d11_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!linux.simulating_or_running_on_linux('monterey'))
}

// Ruby it `it "returns false on Linux with HOMEBREW_SIMULATE_MACOS_ON_LINUX", :needs_linux do` at line 76.
pub fn ruby_simulate_system_spec_l76_d12_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!linux.simulating_or_running_on_linux(linux.effective_os('',
		true, 'sequoia')))
}

// Ruby it `it "returns false without any simulation" do` at line 84.
pub fn ruby_simulate_system_spec_l84_d13_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!homebrew.new_system_simulation('linux', 'intel').simulating())
}

// Ruby it `it "returns true when simulating an OS" do` at line 89.
pub fn ruby_simulate_system_spec_l89_d14_returns(args ...ruby.Value) ruby.Value {
	mut state := homebrew.new_system_simulation('linux', 'intel')
	state.set_os('linux') or { return ruby.bool_value(false) }
	return ruby.bool_value(state.simulating())
}

// Ruby it `it "returns true when simulating an architecture" do` at line 95.
pub fn ruby_simulate_system_spec_l95_d15_returns(args ...ruby.Value) ruby.Value {
	mut state := homebrew.new_system_simulation('linux', 'intel')
	state.set_arch('arm') or { return ruby.bool_value(false) }
	return ruby.bool_value(state.simulating())
}

// Ruby it `it "returns the current architecture" do` at line 103.
pub fn ruby_simulate_system_spec_l103_d16_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(homebrew.new_system_simulation('linux', 'intel').current_arch() == 'intel')
}

// Ruby it `it "returns the simulated architecture" do` at line 108.
pub fn ruby_simulate_system_spec_l108_d17_returns(args ...ruby.Value) ruby.Value {
	mut state := homebrew.new_system_simulation('linux', 'intel')
	state.set_arch('arm') or { return ruby.bool_value(false) }
	return ruby.bool_value(state.current_arch() == 'arm')
}

// Ruby it `it "returns the current macOS version on macOS", :needs_macos do` at line 121.
pub fn ruby_simulate_system_spec_l121_d18_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(mac.current_os('', 'sonoma') == 'sonoma')
}

// Ruby it `it "returns `:linux` on Linux", :needs_linux do` at line 126.
pub fn ruby_simulate_system_spec_l126_d19_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(linux.current_os('') == 'linux')
}

// Ruby it `it "returns `:linux` when simulating Linux on macOS", :needs_macos do` at line 131.
pub fn ruby_simulate_system_spec_l131_d20_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(linux.current_os('linux') == 'linux')
}

// Ruby it `it "returns `:macos` when simulating a generic macOS version on Linux", :needs_linux do` at line 137.
pub fn ruby_simulate_system_spec_l137_d21_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(linux.current_os('macos') == 'macos')
}

// Ruby it `it "returns `:macos` when simulating a specific macOS version on Linux", :needs_linux do` at line 143.
pub fn ruby_simulate_system_spec_l143_d22_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(linux.current_os('monterey') == 'monterey')
}

// Ruby it `it "returns the current macOS version on macOS with HOMEBREW_SIMULATE_MACOS_ON_LINUX", :needs_macos do` at line 149.
pub fn ruby_simulate_system_spec_l149_d23_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(mac.current_os('', 'sonoma') == 'sonoma')
}

// Ruby it `it "returns the newest supported macOS symbol on Linux with HOMEBREW_SIMULATE_MACOS_ON_LINUX", :needs_linux do` at line 155.
pub fn ruby_simulate_system_spec_l155_d24_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(linux.current_os(linux.effective_os('', true, 'sequoia')) == 'sequoia')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "settings"
// 5:
// 6: RSpec.describe Homebrew::SimulateSystem do
// 7:   after do
// 8:     described_class.clear
// 9:   end
// 10:
// 11:   describe "::simulating_or_running_on_macos?" do
// 12:     it "returns true on macOS", :needs_macos do
// 13:       described_class.clear
// 14:       expect(described_class.simulating_or_running_on_macos?).to be true
// 15:     end
// 16:
// 17:     it "returns false on Linux", :needs_linux do
// 18:       described_class.clear
// 19:       expect(described_class.simulating_or_running_on_macos?).to be false
// 20:     end
// 21:
// 22:     it "returns false on macOS when simulating Linux", :needs_macos do
// 23:       described_class.clear
// 24:       described_class.os = :linux
// 25:       expect(described_class.simulating_or_running_on_macos?).to be false
// 26:     end
// 27:
// 28:     it "returns true on Linux when simulating a generic macOS version", :needs_linux do
// 29:       described_class.clear
// 30:       described_class.os = :macos
// 31:       expect(described_class.simulating_or_running_on_macos?).to be true
// 32:     end
// 33:
// 34:     it "returns true on Linux when simulating a specific macOS version", :needs_linux do
// 35:       described_class.clear
// 36:       described_class.os = :monterey
// 37:       expect(described_class.simulating_or_running_on_macos?).to be true
// 38:     end
// 39:
// 40:     it "returns true on Linux with HOMEBREW_SIMULATE_MACOS_ON_LINUX", :needs_linux do
// 41:       described_class.clear
// 42:       ENV["HOMEBREW_SIMULATE_MACOS_ON_LINUX"] = "1"
// 43:       expect(described_class.simulating_or_running_on_macos?).to be true
// 44:     end
// 45:   end
// 46:
// 47:   describe "::simulating_or_running_on_linux?" do
// 48:     it "returns true on Linux", :needs_linux do
// 49:       described_class.clear
// 50:       expect(described_class.simulating_or_running_on_linux?).to be true
// 51:     end
// 52:
// 53:     it "returns false on macOS", :needs_macos do
// 54:       described_class.clear
// 55:       expect(described_class.simulating_or_running_on_linux?).to be false
// 56:     end
// 57:
// 58:     it "returns true on macOS when simulating Linux", :needs_macos do
// 59:       described_class.clear
// 60:       described_class.os = :linux
// 61:       expect(described_class.simulating_or_running_on_linux?).to be true
// 62:     end
// 63:
// 64:     it "returns false on Linux when simulating a generic macOS version", :needs_linux do
// 65:       described_class.clear
// 66:       described_class.os = :macos
// 67:       expect(described_class.simulating_or_running_on_linux?).to be false
// 68:     end
// 69:
// 70:     it "returns false on Linux when simulating a specific macOS version", :needs_linux do
// 71:       described_class.clear
// 72:       described_class.os = :monterey
// 73:       expect(described_class.simulating_or_running_on_linux?).to be false
// 74:     end
// 75:
// 76:     it "returns false on Linux with HOMEBREW_SIMULATE_MACOS_ON_LINUX", :needs_linux do
// 77:       described_class.clear
// 78:       ENV["HOMEBREW_SIMULATE_MACOS_ON_LINUX"] = "1"
// 79:       expect(described_class.simulating_or_running_on_linux?).to be false
// 80:     end
// 81:   end
// 82:
// 83:   describe "::simulating?" do
// 84:     it "returns false without any simulation" do
// 85:       described_class.clear
// 86:       expect(described_class.simulating?).to be false
// 87:     end
// 88:
// 89:     it "returns true when simulating an OS" do
// 90:       described_class.clear
// 91:       described_class.os = :linux
// 92:       expect(described_class.simulating?).to be true
// 93:     end
// 94:
// 95:     it "returns true when simulating an architecture" do
// 96:       described_class.clear
// 97:       described_class.arch = :arm
// 98:       expect(described_class.simulating?).to be true
// 99:     end
// 100:   end
// 101:
// 102:   describe "::current_arch" do
// 103:     it "returns the current architecture" do
// 104:       described_class.clear
// 105:       expect(described_class.current_arch).to eq Hardware::CPU.type
// 106:     end
// 107:
// 108:     it "returns the simulated architecture" do
// 109:       described_class.clear
// 110:       simulated_arch = if Hardware::CPU.arm?
// 111:         :intel
// 112:       else
// 113:         :arm
// 114:       end
// 115:       described_class.arch = simulated_arch
// 116:       expect(described_class.current_arch).to eq simulated_arch
// 117:     end
// 118:   end
// 119:
// 120:   describe "::current_os" do
// 121:     it "returns the current macOS version on macOS", :needs_macos do
// 122:       described_class.clear
// 123:       expect(described_class.current_os).to eq MacOS.version.to_sym
// 124:     end
// 125:
// 126:     it "returns `:linux` on Linux", :needs_linux do
// 127:       described_class.clear
// 128:       expect(described_class.current_os).to eq :linux
// 129:     end
// 130:
// 131:     it "returns `:linux` when simulating Linux on macOS", :needs_macos do
// 132:       described_class.clear
// 133:       described_class.os = :linux
// 134:       expect(described_class.current_os).to eq :linux
// 135:     end
// 136:
// 137:     it "returns `:macos` when simulating a generic macOS version on Linux", :needs_linux do
// 138:       described_class.clear
// 139:       described_class.os = :macos
// 140:       expect(described_class.current_os).to eq :macos
// 141:     end
// 142:
// 143:     it "returns `:macos` when simulating a specific macOS version on Linux", :needs_linux do
// 144:       described_class.clear
// 145:       described_class.os = :monterey
// 146:       expect(described_class.current_os).to eq :monterey
// 147:     end
// 148:
// 149:     it "returns the current macOS version on macOS with HOMEBREW_SIMULATE_MACOS_ON_LINUX", :needs_macos do
// 150:       described_class.clear
// 151:       ENV["HOMEBREW_SIMULATE_MACOS_ON_LINUX"] = "1"
// 152:       expect(described_class.current_os).to eq MacOS.version.to_sym
// 153:     end
// 154:
// 155:     it "returns the newest supported macOS symbol on Linux with HOMEBREW_SIMULATE_MACOS_ON_LINUX", :needs_linux do
// 156:       described_class.clear
// 157:       ENV["HOMEBREW_SIMULATE_MACOS_ON_LINUX"] = "1"
// 158:       expect(described_class.current_os).to eq MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED).to_sym
// 159:     end
// 160:   end
// 161: end
