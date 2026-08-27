module cpu

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/hardware/cpu/hardware.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `extmodel` at line 8.
pub fn ruby_hardware_l8_d1_extmodel(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extmodel', ...args)
}

// Ruby method `aes?` at line 13.
pub fn ruby_hardware_l13_d2_aes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('aes?', ...args)
}

// Ruby method `altivec?` at line 18.
pub fn ruby_hardware_l18_d3_altivec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('altivec?', ...args)
}

// Ruby method `avx?` at line 23.
pub fn ruby_hardware_l23_d4_avx(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('avx?', ...args)
}

// Ruby method `avx2?` at line 28.
pub fn ruby_hardware_l28_d5_avx2(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('avx2?', ...args)
}

// Ruby method `sse3?` at line 33.
pub fn ruby_hardware_l33_d6_sse3(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sse3?', ...args)
}

// Ruby method `ssse3?` at line 38.
pub fn ruby_hardware_l38_d7_ssse3(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ssse3?', ...args)
}

// Ruby method `sse4_2?` at line 43.
pub fn ruby_hardware_l43_d8_sse4_2(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sse4_2?', ...args)
}

// Ruby method `physical_cpu_arm64?` at line 50.
pub fn ruby_hardware_l50_d9_physical_cpu_arm64(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('physical_cpu_arm64?', ...args)
}

// Ruby method `virtualized?` at line 55.
pub fn ruby_hardware_l55_d10_virtualized(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('virtualized?', ...args)
}

// Ruby method `arm_family` at line 60.
pub fn ruby_hardware_l60_d11_arm_family(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arm_family', ...args)
}

// Ruby method `intel_family(_family = T.unsafe(nil), _cpu_model = T.unsafe(nil))` at line 100.
pub fn ruby_hardware_l100_d12_intel_family(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('intel_family', ...args)
}

// Ruby method `sysctl_bool!(key)` at line 134.
pub fn ruby_hardware_l134_d13_sysctl_bool(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sysctl_bool!', ...args)
}

// Ruby method `sysctl_int(key)` at line 139.
pub fn ruby_hardware_l139_d14_sysctl_int(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sysctl_int', ...args)
}

// Ruby method `sysctl_n(*keys)` at line 144.
pub fn ruby_hardware_l144_d15_sysctl_n(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sysctl_n', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Hardware
// 5:   class CPU
// 6:     class << self
// 7:       sig { returns(Integer) }
// 8:       def extmodel
// 9:         sysctl_int("machdep.cpu.extmodel")
// 10:       end
// 11:
// 12:       sig { returns(T::Boolean) }
// 13:       def aes?
// 14:         sysctl_bool!("hw.optional.aes")
// 15:       end
// 16:
// 17:       sig { returns(T::Boolean) }
// 18:       def altivec?
// 19:         sysctl_bool!("hw.optional.altivec")
// 20:       end
// 21:
// 22:       sig { returns(T::Boolean) }
// 23:       def avx?
// 24:         sysctl_bool!("hw.optional.avx1_0")
// 25:       end
// 26:
// 27:       sig { returns(T::Boolean) }
// 28:       def avx2?
// 29:         sysctl_bool!("hw.optional.avx2_0")
// 30:       end
// 31:
// 32:       sig { returns(T::Boolean) }
// 33:       def sse3?
// 34:         sysctl_bool!("hw.optional.sse3")
// 35:       end
// 36:
// 37:       sig { returns(T::Boolean) }
// 38:       def ssse3?
// 39:         sysctl_bool!("hw.optional.supplementalsse3")
// 40:       end
// 41:
// 42:       sig { returns(T::Boolean) }
// 43:       def sse4_2?
// 44:         sysctl_bool!("hw.optional.sse4_2")
// 45:       end
// 46:
// 47:       # NOTE: This is more reliable than checking `uname`. `sysctl` returns
// 48:       #       the right answer even when running in Rosetta 2.
// 49:       sig { returns(T::Boolean) }
// 50:       def physical_cpu_arm64?
// 51:         sysctl_bool!("hw.optional.arm64")
// 52:       end
// 53:
// 54:       sig { returns(T::Boolean) }
// 55:       def virtualized?
// 56:         sysctl_bool!("kern.hv_vmm_present")
// 57:       end
// 58:
// 59:       sig { returns(Symbol) }
// 60:       def arm_family
// 61:         case sysctl_int("hw.cpufamily")
// 62:         when 0x2c91a47e             # ARMv8.0-A (Typhoon)
// 63:           :arm_typhoon
// 64:         when 0x92fb37c8             # ARMv8.0-A (Twister)
// 65:           :arm_twister
// 66:         when 0x67ceee93             # ARMv8.1-A (Hurricane, Zephyr)
// 67:           :arm_hurricane_zephyr
// 68:         when 0xe81e7ef6             # ARMv8.2-A (Monsoon, Mistral)
// 69:           :arm_monsoon_mistral
// 70:         when 0x07d34b9f             # ARMv8.3-A (Vortex, Tempest)
// 71:           :arm_vortex_tempest
// 72:         when 0x462504d2             # ARMv8.4-A (Lightning, Thunder)
// 73:           :arm_lightning_thunder
// 74:         when 0x573b5eec, 0x1b588bb3 # ARMv8.4-A (Firestorm, Icestorm)
// 75:           :arm_firestorm_icestorm
// 76:         when 0xda33d83d             # ARMv8.5-A (Blizzard, Avalanche)
// 77:           :arm_blizzard_avalanche
// 78:         when 0xfa33415e             # ARMv8.6-A (M3, Ibiza)
// 79:           :arm_ibiza
// 80:         when 0x5f4dea93             # ARMv8.6-A (M3 Pro, Lobos)
// 81:           :arm_lobos
// 82:         when 0x72015832             # ARMv8.6-A (M3 Max, Palma)
// 83:           :arm_palma
// 84:         when 0x6f5129ac             # ARMv9.2-A (M4, Donan)
// 85:           :arm_donan
// 86:         when 0x17d5b93a             # ARMv9.2-A (M4 Pro / M4 Max, Brava)
// 87:           :arm_brava
// 88:         when 0x1d5a87e8             # ARMv9.2-A (M5, Hidra)
// 89:           :arm_hidra
// 90:         when 0xf76c5b1a             # ARMv9.2-A (M5 Pro / M5 Max, Sotra)
// 91:           :arm_sotra
// 92:         else
// 93:           # When adding new ARM CPU families, please also update
// 94:           # test/hardware/cpu_spec.rb to include the new families.
// 95:           :dunno
// 96:         end
// 97:       end
// 98:
// 99:       sig { params(_family: Integer, _cpu_model: Integer).returns(Symbol) }
// 100:       def intel_family(_family = T.unsafe(nil), _cpu_model = T.unsafe(nil))
// 101:         case sysctl_int("hw.cpufamily")
// 102:         when 0x73d67300 # Yonah: Core Solo/Duo
// 103:           :core
// 104:         when 0x426f69ef # Merom: Core 2 Duo
// 105:           :core2
// 106:         when 0x78ea4fbc # Penryn
// 107:           :penryn
// 108:         when 0x6b5a4cd2 # Nehalem
// 109:           :nehalem
// 110:         when 0x573b5eec # Westmere
// 111:           :westmere
// 112:         when 0x5490b78c # Sandy Bridge
// 113:           :sandybridge
// 114:         when 0x1f65e835 # Ivy Bridge
// 115:           :ivybridge
// 116:         when 0x10b282dc # Haswell
// 117:           :haswell
// 118:         when 0x582ed09c # Broadwell
// 119:           :broadwell
// 120:         when 0x37fc219f # Skylake
// 121:           :skylake
// 122:         when 0x0f817246 # Kaby Lake
// 123:           :kabylake
// 124:         when 0x38435547 # Ice Lake
// 125:           :icelake
// 126:         when 0x1cf8a03e # Comet Lake
// 127:           :cometlake
// 128:         else
// 129:           :dunno
// 130:         end
// 131:       end
// 132:
// 133:       sig { params(key: String).returns(T::Boolean) }
// 134:       def sysctl_bool!(key)
// 135:         sysctl_int(key) == 1
// 136:       end
// 137:
// 138:       sig { params(key: String).returns(Integer) }
// 139:       def sysctl_int(key)
// 140:         sysctl_n(key).to_i & 0xffffffff
// 141:       end
// 142:
// 143:       sig { params(keys: String).returns(String) }
// 144:       def sysctl_n(*keys)
// 145:         (@properties ||= T.let({}, T.nilable(T::Hash[T::Array[String], String]))).fetch(keys) do
// 146:           @properties[keys] = Utils.popen_read("/usr/sbin/sysctl", "-n", *keys)
// 147:         end
// 148:       end
// 149:     end
// 150:   end
// 151: end
