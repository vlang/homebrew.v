module hardware

import brew_runtime
import os

// Translated from Homebrew/brew `extend/os/linux/hardware/cpu.rb`.
// The original source is retained below for exact boundary auditing.

pub fn linux_cpu_optimization_flags(base map[string]string, arch string,
	ppc bool) map[string]string {
	mut flags := base.clone()
	flags['native'] = if ppc { '-mcpu=${arch}' } else { '-march=${arch}' }
	return flags
}

fn linux_cpuinfo_value(cpuinfo string, key string) string {
	for line in cpuinfo.split_into_lines() {
		separator := line.index(':') or { continue }
		if line[..separator].trim_space() == key {
			return line[separator + 1..].trim_space()
		}
	}
	return ''
}

pub fn linux_intel_family(family int, model int) ?string {
	if family == 0x06 {
		return match model {
			0x3a, 0x3e { 'ivybridge' }
			0x2a, 0x2d { 'sandybridge' }
			0x25, 0x2c, 0x2f { 'westmere' }
			0x1a, 0x1e, 0x1f, 0x2e { 'nehalem' }
			0x17, 0x1d { 'penryn' }
			0x0f, 0x16 { 'merom' }
			0x0d { 'dothan' }
			0x1c, 0x26, 0x27, 0x35, 0x36 { 'atom' }
			0x3c, 0x3f, 0x45, 0x46 { 'haswell' }
			0x3d, 0x47, 0x4f, 0x56 { 'broadwell' }
			0x4e, 0x5e, 0x8e, 0x9e, 0xa5, 0xa6 { 'skylake' }
			0x66 { 'cannonlake' }
			0x6a, 0x6c, 0x7d, 0x7e { 'icelake' }
			0xa7 { 'rocketlake' }
			0x8c, 0x8d { 'tigerlake' }
			0x97, 0x9a, 0xbe, 0xb7, 0xba, 0xbf, 0xaa, 0xac { 'alderlake' }
			0xc5, 0xb5, 0xc6, 0xbd { 'arrowlake' }
			0xcc { 'pantherlake' }
			0xad, 0xae { 'graniterapids' }
			0xcf, 0x8f { 'sapphirerapids' }
			else {
				return none
			}
		}
	}
	if family == 0x0f {
		return match model {
			0x06 { 'presler' }
			0x03, 0x04 { 'prescott' }
			else {
				return none
			}
		}
	}
	return none
}

pub fn linux_amd_family(family int, model int) ?string {
	return match family {
		0x06 { 'amd_k7' }
		0x0f { 'amd_k8' }
		0x10 { 'amd_k10' }
		0x11 { 'amd_k8_k10_hybrid' }
		0x12 { 'amd_k10_llano' }
		0x14 { 'bobcat' }
		0x15 { 'bulldozer' }
		0x16 { 'jaguar' }
		0x17 {
			if model >= 0x10 && model <= 0x2f {
				'zen'
			} else if (model >= 0x30 && model <= 0x3f) || model == 0x47
				|| (model >= 0x60 && model <= 0x7f) || (model >= 0x84 && model <= 0x87)
				|| (model >= 0x90 && model <= 0xaf) {
				'zen2'
			} else {
				return none
			}
		}
		0x19 {
			if model <= 0x0f || (model >= 0x20 && model <= 0x5f) {
				'zen3'
			} else if (model >= 0x10 && model <= 0x1f)
				|| (model >= 0x60 && model <= 0x7f) || (model >= 0xa0 && model <= 0xaf) {
				'zen4'
			} else {
				return none
			}
		}
		0x1a { 'zen5' }
		else {
			return none
		}
	}
}

pub fn linux_cpu_family(kind string, cpuinfo string) string {
	if kind == 'arm' {
		return 'arm'
	}
	if kind == 'ppc' {
		return 'ppc'
	}
	if kind != 'intel' {
		return 'dunno'
	}
	vendor := linux_cpuinfo_value(cpuinfo, 'vendor_id')
	family := linux_cpuinfo_value(cpuinfo, 'cpu family').int()
	model := linux_cpuinfo_value(cpuinfo, 'model').int()
	if vendor == 'GenuineIntel' {
		return linux_intel_family(family, model) or {
			'unknown_0x${family.hex()}_0x${model.hex()}'
		}
	}
	if vendor == 'AuthenticAMD' {
		return linux_amd_family(family, model) or {
			'unknown_0x${family.hex()}_0x${model.hex()}'
		}
	}
	return 'unknown_0x${family.hex()}_0x${model.hex()}'
}

pub fn linux_cpu_flags(cpuinfo string) []string {
	for line in cpuinfo.split_into_lines() {
		separator := line.index(':') or { continue }
		key := line[..separator].trim_space()
		if key in ['flags', 'Features'] {
			return line[separator + 1..].fields()
		}
	}
	return []
}

pub fn linux_cpu_has_flag(flags []string, flag string) bool {
	return flag in flags
}

pub fn linux_cpu_sse3(flags []string) bool {
	return 'pni' in flags || 'sse3' in flags
}

pub fn linux_cpu_sse4(flags []string) bool {
	return 'sse4_1' in flags
}

pub fn linux_cpuinfo(path string) !string {
	return os.read_file(path)
}

fn linux_cpu_optional_value(value ?string) brew_runtime.Value {
	return if actual := value {
		brew_runtime.object_value('Symbol', actual)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

fn linux_cpu_flags_arg(args []brew_runtime.Value, index int) []string {
	if args.len <= index {
		return linux_cpu_flags(linux_cpuinfo('/proc/cpuinfo') or { '' })
	}
	return args[index].as_string_array() or { linux_cpu_flags(args[index].as_string()) }
}

// Ruby method `optimization_flags` at line 14.
pub fn ruby_cpu_l14_d1_optimization_flags(args ...brew_runtime.Value) brew_runtime.Value {
	mut base := map[string]string{}
	if args.len > 0 && args[0].type_name == 'Hash' {
		for key, value in args[0].map_data {
			base[key] = value.as_string()
		}
	}
	arch := if args.len > 1 { args[1].as_string() } else { 'native' }
	ppc := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	mut values := map[string]brew_runtime.Value{}
	for key, value in linux_cpu_optimization_flags(base, arch, ppc) {
		values[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(values)
}

// Ruby method `family` at line 23.
pub fn ruby_cpu_l23_d2_family(args ...brew_runtime.Value) brew_runtime.Value {
	kind := if args.len > 0 { args[0].as_string() } else { 'dunno' }
	cpuinfo := if args.len > 1 {
		args[1].as_string()
	} else {
		linux_cpuinfo('/proc/cpuinfo') or { '' }
	}
	return brew_runtime.object_value('Symbol', linux_cpu_family(kind, cpuinfo))
}

// Ruby method `intel_family(family, cpu_model)` at line 44.
pub fn ruby_cpu_l44_d3_intel_family(args ...brew_runtime.Value) brew_runtime.Value {
	family := if args.len > 0 { int(args[0].as_int() or { 0 }) } else { 0 }
	model := if args.len > 1 { int(args[1].as_int() or { 0 }) } else { 0 }
	return linux_cpu_optional_value(linux_intel_family(family, model))
}

// Ruby method `amd_family(family, cpu_model)` at line 100.
pub fn ruby_cpu_l100_d4_amd_family(args ...brew_runtime.Value) brew_runtime.Value {
	family := if args.len > 0 { int(args[0].as_int() or { 0 }) } else { 0 }
	model := if args.len > 1 { int(args[1].as_int() or { 0 }) } else { 0 }
	return linux_cpu_optional_value(linux_amd_family(family, model))
}

// Ruby method `flags` at line 139.
pub fn ruby_cpu_l139_d5_flags(args ...brew_runtime.Value) brew_runtime.Value {
	cpuinfo := if args.len > 0 {
		args[0].as_string()
	} else {
		linux_cpuinfo('/proc/cpuinfo') or { '' }
	}
	return brew_runtime.string_array_value(linux_cpu_flags(cpuinfo))
}

// Ruby method `features` at line 147.
pub fn ruby_cpu_l147_d6_features(args ...brew_runtime.Value) brew_runtime.Value {
	flags := linux_cpu_flags_arg(args, 0)
	return brew_runtime.array_value(flags.map(brew_runtime.object_value('Symbol', it)))
}

// Ruby define_method `define_method(:"#{flag}?") do` at line 152.
pub fn ruby_cpu_l152_d7_flag(args ...brew_runtime.Value) brew_runtime.Value {
	flag := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.bool_value(linux_cpu_has_flag(linux_cpu_flags_arg(args, 1), flag))
}

// Ruby method `sse3?` at line 159.
pub fn ruby_cpu_l159_d8_sse3(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(linux_cpu_sse3(linux_cpu_flags_arg(args, 0)))
}

// Ruby method `sse4?` at line 164.
pub fn ruby_cpu_l164_d9_sse4(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(linux_cpu_sse4(linux_cpu_flags_arg(args, 0)))
}

// Ruby method `cpuinfo` at line 171.
pub fn ruby_cpu_l171_d10_cpuinfo(args ...brew_runtime.Value) brew_runtime.Value {
	path := if args.len > 0 { args[0].as_string() } else { '/proc/cpuinfo' }
	return brew_runtime.string_value(linux_cpuinfo(path) or {
		return brew_runtime.object_value('FileError', err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Hardware
// 7:       module CPU
// 8:         module ClassMethods
// 9:           extend T::Helpers
// 10:
// 11:           requires_ancestor { T.class_of(::Hardware::CPU) }
// 12:
// 13:           sig { returns(T::Hash[Symbol, String]) }
// 14:           def optimization_flags
// 15:             @optimization_flags ||= T.let(begin
// 16:               flags = super.dup
// 17:               flags[:native] = arch_flag(Homebrew::EnvConfig.arch)
// 18:               flags
// 19:             end, T.nilable(T::Hash[Symbol, String]))
// 20:           end
// 21:
// 22:           sig { returns(Symbol) }
// 23:           def family
// 24:             return :arm if arm?
// 25:             return :ppc if ppc?
// 26:             return :dunno unless intel?
// 27:
// 28:             # See https://software.intel.com/en-us/articles/intel-architecture-and-processor-identification-with-cpuid-model-and-family-numbers
// 29:             # and https://github.com/llvm/llvm-project/blob/main/llvm/lib/TargetParser/Host.cpp
// 30:             # and https://en.wikipedia.org/wiki/List_of_Intel_CPU_microarchitectures#Roadmap
// 31:             vendor_id = cpuinfo[/^vendor_id\s*: (.*)/, 1]
// 32:             cpu_family = cpuinfo[/^cpu family\s*: ([0-9]+)/, 1].to_i
// 33:             cpu_model = cpuinfo[/^model\s*: ([0-9]+)/, 1].to_i
// 34:             unknown = :"unknown_0x#{cpu_family.to_s(16)}_0x#{cpu_model.to_s(16)}"
// 35:             case vendor_id
// 36:             when "GenuineIntel"
// 37:               intel_family(cpu_family, cpu_model)
// 38:             when "AuthenticAMD"
// 39:               amd_family(cpu_family, cpu_model)
// 40:             end || unknown
// 41:           end
// 42:
// 43:           sig { params(family: Integer, cpu_model: Integer).returns(T.nilable(Symbol)) }
// 44:           def intel_family(family, cpu_model)
// 45:             case family
// 46:             when 0x06
// 47:               case cpu_model
// 48:               when 0x3a, 0x3e
// 49:                 :ivybridge
// 50:               when 0x2a, 0x2d
// 51:                 :sandybridge
// 52:               when 0x25, 0x2c, 0x2f
// 53:                 :westmere
// 54:               when 0x1a, 0x1e, 0x1f, 0x2e
// 55:                 :nehalem
// 56:               when 0x17, 0x1d
// 57:                 :penryn
// 58:               when 0x0f, 0x16
// 59:                 :merom
// 60:               when 0x0d
// 61:                 :dothan
// 62:               when 0x1c, 0x26, 0x27, 0x35, 0x36
// 63:                 :atom
// 64:               when 0x3c, 0x3f, 0x45, 0x46
// 65:                 :haswell
// 66:               when 0x3d, 0x47, 0x4f, 0x56
// 67:                 :broadwell
// 68:               when 0x4e, 0x5e, 0x8e, 0x9e, 0xa5, 0xa6
// 69:                 :skylake
// 70:               when 0x66
// 71:                 :cannonlake
// 72:               when 0x6a, 0x6c, 0x7d, 0x7e
// 73:                 :icelake
// 74:               when 0xa7
// 75:                 :rocketlake
// 76:               when 0x8c, 0x8d
// 77:                 :tigerlake
// 78:               when 0x97, 0x9a, 0xbe, 0xb7, 0xba, 0xbf, 0xaa, 0xac
// 79:                 :alderlake
// 80:               when 0xc5, 0xb5, 0xc6, 0xbd
// 81:                 :arrowlake
// 82:               when 0xcc
// 83:                 :pantherlake
// 84:               when 0xad, 0xae
// 85:                 :graniterapids
// 86:               when 0xcf, 0x8f
// 87:                 :sapphirerapids
// 88:               end
// 89:             when 0x0f
// 90:               case cpu_model
// 91:               when 0x06
// 92:                 :presler
// 93:               when 0x03, 0x04
// 94:                 :prescott
// 95:               end
// 96:             end
// 97:           end
// 98:
// 99:           sig { params(family: Integer, cpu_model: Integer).returns(T.nilable(Symbol)) }
// 100:           def amd_family(family, cpu_model)
// 101:             case family
// 102:             when 0x06
// 103:               :amd_k7
// 104:             when 0x0f
// 105:               :amd_k8
// 106:             when 0x10
// 107:               :amd_k10
// 108:             when 0x11
// 109:               :amd_k8_k10_hybrid
// 110:             when 0x12
// 111:               :amd_k10_llano
// 112:             when 0x14
// 113:               :bobcat
// 114:             when 0x15
// 115:               :bulldozer
// 116:             when 0x16
// 117:               :jaguar
// 118:             when 0x17
// 119:               case cpu_model
// 120:               when 0x10..0x2f
// 121:                 :zen
// 122:               when 0x30..0x3f, 0x47, 0x60..0x7f, 0x84..0x87, 0x90..0xaf
// 123:                 :zen2
// 124:               end
// 125:             when 0x19
// 126:               case cpu_model
// 127:               when ..0x0f, 0x20..0x5f
// 128:                 :zen3
// 129:               when 0x10..0x1f, 0x60..0x7f, 0xa0..0xaf
// 130:                 :zen4
// 131:               end
// 132:             when 0x1a
// 133:               :zen5
// 134:             end
// 135:           end
// 136:
// 137:           # Supported CPU instructions
// 138:           sig { returns(T::Array[String]) }
// 139:           def flags
// 140:             @flags ||= T.let(cpuinfo[/^(?:flags|Features)\s*: (.*)/, 1]&.split, T.nilable(T::Array[String]))
// 141:             @flags ||= []
// 142:           end
// 143:
// 144:           # Compatibility with Mac method, which returns lowercase symbols
// 145:           # instead of strings.
// 146:           sig { returns(T::Array[Symbol]) }
// 147:           def features
// 148:             @features ||= T.let(flags.map(&:intern), T.nilable(T::Array[Symbol]))
// 149:           end
// 150:
// 151:           %w[aes altivec avx avx2 lm ssse3 sse4_2].each do |flag|
// 152:             define_method(:"#{flag}?") do
// 153:               T.bind(self, OS::Linux::Hardware::CPU::ClassMethods)
// 154:               flags.include? flag
// 155:             end
// 156:           end
// 157:
// 158:           sig { returns(T::Boolean) }
// 159:           def sse3?
// 160:             flags.include?("pni") || flags.include?("sse3")
// 161:           end
// 162:
// 163:           sig { returns(T::Boolean) }
// 164:           def sse4?
// 165:             flags.include? "sse4_1"
// 166:           end
// 167:
// 168:           private
// 169:
// 170:           sig { returns(String) }
// 171:           def cpuinfo
// 172:             @cpuinfo ||= T.let(File.read("/proc/cpuinfo"), T.nilable(String))
// 173:           end
// 174:         end
// 175:       end
// 176:     end
// 177:   end
// 178: end
// 179:
// 180: Hardware::CPU.singleton_class.prepend(OS::Linux::Hardware::CPU::ClassMethods)
