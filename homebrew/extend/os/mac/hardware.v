module mac

// Translated from Homebrew/brew `extend/os/mac/hardware.rb`.
// The original source is retained below until every stub has a typed V body.
fn macos_version_number(version string) int {
	return match version.to_lower() {
		'ventura' { 1300 }
		'sonoma' { 1400 }
		'sequoia' { 1500 }
		'tahoe' { 1600 }
		'catalina' { 1015 }
		'big_sur' { 1100 }
		'monterey' { 1200 }
		else {
			parts := version.split('.')
			if parts.len == 0 {
				0
			} else {
				parts[0].int() * 100 + if parts.len > 1 { parts[1].int() } else { 0 }
			}
		}
	}
}

pub fn mac_oldest_cpu(version string, arm64 bool, inherited_cpu string) string {
	if arm64 {
		return 'arm_vortex_tempest'
	}
	version_number := macos_version_number(version)
	if version_number >= 1300 {
		return 'westmere'
	}
	if version_number >= 1015 {
		return 'nehalem'
	}
	return inherited_cpu
}

// Ruby method `oldest_cpu(version = nil)` at line 9.
pub fn ruby_hardware_l9_d1_oldest_cpu(version string, arm64 bool,
	inherited_cpu string) string {
	return mac_oldest_cpu(version, arm64, inherited_cpu)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module Hardware
// 7:       module ClassMethods
// 8:         sig { params(version: T.nilable(MacOSVersion)).returns(Symbol) }
// 9:         def oldest_cpu(version = nil)
// 10:           version = if version
// 11:             MacOSVersion.new(version.to_s)
// 12:           else
// 13:             MacOS.version
// 14:           end
// 15:           if ::Hardware::CPU.arm64?
// 16:             :arm_vortex_tempest
// 17:           # This cannot use a newer CPU e.g. haswell because Rosetta 2 does not
// 18:           # support AVX instructions in bottles:
// 19:           #   https://github.com/Homebrew/homebrew-core/issues/67713
// 20:           elsif version >= :ventura
// 21:             :westmere
// 22:           elsif version >= :catalina
// 23:             :nehalem
// 24:           else
// 25:             super
// 26:           end
// 27:         end
// 28:       end
// 29:     end
// 30:   end
// 31: end
// 32:
// 33: Hardware.singleton_class.prepend(OS::Mac::Hardware::ClassMethods)
