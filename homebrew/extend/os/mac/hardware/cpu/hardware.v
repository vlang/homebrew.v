module cpu

import ruby

pub struct MacCpuProperties {
pub:
	values map[string]string
}

pub fn mac_cpu_sysctl_n(properties MacCpuProperties, keys []string) string {
	cache_key := keys.join('\0')
	if cache_key in properties.values {
		return properties.values[cache_key]
	}
	if keys.len == 1 && keys[0] in properties.values {
		return properties.values[keys[0]]
	}
	mut arguments := ['-n']
	arguments << keys
	result := ruby.run_command('/usr/sbin/sysctl', arguments)
	return if result.exit_code == 0 { result.output } else { '' }
}

pub fn mac_cpu_sysctl_int(properties MacCpuProperties, key string) u32 {
	return u32(mac_cpu_sysctl_n(properties, [key]).trim_space().u64() & u64(0xffffffff))
}

pub fn mac_cpu_sysctl_bool(properties MacCpuProperties, key string) bool {
	return mac_cpu_sysctl_int(properties, key) == 1
}

pub fn mac_cpu_arm_family(value u32) string {
	return match value {
		0x2c91a47e { 'arm_typhoon' }
		0x92fb37c8 { 'arm_twister' }
		0x67ceee93 { 'arm_hurricane_zephyr' }
		0xe81e7ef6 { 'arm_monsoon_mistral' }
		0x07d34b9f { 'arm_vortex_tempest' }
		0x462504d2 { 'arm_lightning_thunder' }
		0x573b5eec, 0x1b588bb3 { 'arm_firestorm_icestorm' }
		0xda33d83d { 'arm_blizzard_avalanche' }
		0xfa33415e { 'arm_ibiza' }
		0x5f4dea93 { 'arm_lobos' }
		0x72015832 { 'arm_palma' }
		0x6f5129ac { 'arm_donan' }
		0x17d5b93a { 'arm_brava' }
		0x1d5a87e8 { 'arm_hidra' }
		0xf76c5b1a { 'arm_sotra' }
		else { 'dunno' }
	}
}

pub fn mac_cpu_intel_family(value u32) string {
	return match value {
		0x73d67300 { 'core' }
		0x426f69ef { 'core2' }
		0x78ea4fbc { 'penryn' }
		0x6b5a4cd2 { 'nehalem' }
		0x573b5eec { 'westmere' }
		0x5490b78c { 'sandybridge' }
		0x1f65e835 { 'ivybridge' }
		0x10b282dc { 'haswell' }
		0x582ed09c { 'broadwell' }
		0x37fc219f { 'skylake' }
		0x0f817246 { 'kabylake' }
		0x38435547 { 'icelake' }
		0x1cf8a03e { 'cometlake' }
		else { 'dunno' }
	}
}

fn mac_cpu_properties_from_args(args []ruby.Value) (MacCpuProperties, int) {
	if args.len > 0 && args[0].type_name == 'Hash' {
		mut values := map[string]string{}
		for name, value in args[0].map_data {
			values[name] = value.as_string()
		}
		return MacCpuProperties{ values: values }, 1
	}
	return MacCpuProperties{}, 0
}

// Translated from Homebrew/brew `extend/os/mac/hardware/cpu/hardware.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `extmodel` at line 8.
pub fn ruby_hardware_l8_d1_extmodel(args ...ruby.Value) ruby.Value {
	properties, _ := mac_cpu_properties_from_args(args)
	return ruby.int_value(mac_cpu_sysctl_int(properties, 'machdep.cpu.extmodel'))
}

// Ruby method `aes?` at line 13.
pub fn ruby_hardware_l13_d2_aes(args ...ruby.Value) ruby.Value {
	properties, _ := mac_cpu_properties_from_args(args)
	return ruby.bool_value(mac_cpu_sysctl_bool(properties, 'hw.optional.aes'))
}

// Ruby method `altivec?` at line 18.
pub fn ruby_hardware_l18_d3_altivec(args ...ruby.Value) ruby.Value {
	properties, _ := mac_cpu_properties_from_args(args)
	return ruby.bool_value(mac_cpu_sysctl_bool(properties, 'hw.optional.altivec'))
}

// Ruby method `avx?` at line 23.
pub fn ruby_hardware_l23_d4_avx(args ...ruby.Value) ruby.Value {
	properties, _ := mac_cpu_properties_from_args(args)
	return ruby.bool_value(mac_cpu_sysctl_bool(properties, 'hw.optional.avx1_0'))
}

// Ruby method `avx2?` at line 28.
pub fn ruby_hardware_l28_d5_avx2(args ...ruby.Value) ruby.Value {
	properties, _ := mac_cpu_properties_from_args(args)
	return ruby.bool_value(mac_cpu_sysctl_bool(properties, 'hw.optional.avx2_0'))
}

// Ruby method `sse3?` at line 33.
pub fn ruby_hardware_l33_d6_sse3(args ...ruby.Value) ruby.Value {
	properties, _ := mac_cpu_properties_from_args(args)
	return ruby.bool_value(mac_cpu_sysctl_bool(properties, 'hw.optional.sse3'))
}

// Ruby method `ssse3?` at line 38.
pub fn ruby_hardware_l38_d7_ssse3(args ...ruby.Value) ruby.Value {
	properties, _ := mac_cpu_properties_from_args(args)
	return ruby.bool_value(mac_cpu_sysctl_bool(properties, 'hw.optional.supplementalsse3'))
}

// Ruby method `sse4_2?` at line 43.
pub fn ruby_hardware_l43_d8_sse4_2(args ...ruby.Value) ruby.Value {
	properties, _ := mac_cpu_properties_from_args(args)
	return ruby.bool_value(mac_cpu_sysctl_bool(properties, 'hw.optional.sse4_2'))
}

// Ruby method `physical_cpu_arm64?` at line 50.
pub fn ruby_hardware_l50_d9_physical_cpu_arm64(args ...ruby.Value) ruby.Value {
	properties, _ := mac_cpu_properties_from_args(args)
	return ruby.bool_value(mac_cpu_sysctl_bool(properties, 'hw.optional.arm64'))
}

// Ruby method `virtualized?` at line 55.
pub fn ruby_hardware_l55_d10_virtualized(args ...ruby.Value) ruby.Value {
	properties, _ := mac_cpu_properties_from_args(args)
	return ruby.bool_value(mac_cpu_sysctl_bool(properties, 'kern.hv_vmm_present'))
}

// Ruby method `arm_family` at line 60.
pub fn ruby_hardware_l60_d11_arm_family(args ...ruby.Value) ruby.Value {
	properties, _ := mac_cpu_properties_from_args(args)
	return ruby.string_value(mac_cpu_arm_family(mac_cpu_sysctl_int(properties, 'hw.cpufamily')))
}

// Ruby method `intel_family(_family = T.unsafe(nil), _cpu_model = T.unsafe(nil))` at line 100.
pub fn ruby_hardware_l100_d12_intel_family(args ...ruby.Value) ruby.Value {
	properties, _ := mac_cpu_properties_from_args(args)
	return ruby.string_value(mac_cpu_intel_family(mac_cpu_sysctl_int(properties, 'hw.cpufamily')))
}

// Ruby method `sysctl_bool!(key)` at line 134.
pub fn ruby_hardware_l134_d13_sysctl_bool(args ...ruby.Value) ruby.Value {
	properties, offset := mac_cpu_properties_from_args(args)
	if args.len <= offset { panic('sysctl_bool! requires a key') }
	return ruby.bool_value(mac_cpu_sysctl_bool(properties, args[offset].as_string()))
}

// Ruby method `sysctl_int(key)` at line 139.
pub fn ruby_hardware_l139_d14_sysctl_int(args ...ruby.Value) ruby.Value {
	properties, offset := mac_cpu_properties_from_args(args)
	if args.len <= offset { panic('sysctl_int requires a key') }
	return ruby.int_value(mac_cpu_sysctl_int(properties, args[offset].as_string()))
}

// Ruby method `sysctl_n(*keys)` at line 144.
pub fn ruby_hardware_l144_d15_sysctl_n(args ...ruby.Value) ruby.Value {
	properties, offset := mac_cpu_properties_from_args(args)
	mut keys := []string{}
	for value in args[offset..] {
		keys << value.as_string()
	}
	return ruby.string_value(mac_cpu_sysctl_n(properties, keys))
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
