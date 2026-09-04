module hardware

import ruby
import os

// Translated from Homebrew/brew `extend/os/linux/hardware/cpu.rb`.

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

fn linux_cpu_optional_value(value ?string) ruby.Value {
	return if actual := value {
		ruby.object_value('Symbol', actual)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

fn linux_cpu_flags_arg(args []ruby.Value, index int) []string {
	if args.len <= index {
		return linux_cpu_flags(linux_cpuinfo('/proc/cpuinfo') or { '' })
	}
	return args[index].as_string_array() or { linux_cpu_flags(args[index].as_string()) }
}
