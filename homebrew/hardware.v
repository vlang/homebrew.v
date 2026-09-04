module homebrew

import ruby
import os

pub struct HardwareCpu {
pub:
	platform          string
	cores             int
	big_endian        bool
	virtualized       bool
	features          []string
	family            string
	in_rosetta2       bool
	rosetta_installed bool
}

pub fn current_hardware_cpu() &HardwareCpu {
	platform := os.uname().machine
	result := ruby.run_command('getconf', ['_NPROCESSORS_ONLN'])
	cores := if result.exit_code == 0 && result.output.trim_space().int() > 0 {
		result.output.trim_space().int()
	} else {
		1
	}
	return &HardwareCpu{ platform: platform, cores: cores }
}

pub fn hardware_cpu_type(platform string) string {
	lower := platform.to_lower()
	if lower.contains('x86_64') || lower.contains('i386') || lower.contains('i486') || lower.contains('i586') || lower.contains('i686') {
		return 'intel'
	}
	if lower.contains('arm') || lower.contains('aarch64') {
		return 'arm'
	}
	if lower.contains('ppc') || lower.contains('powerpc') {
		return 'ppc'
	}
	return 'dunno'
}

pub fn hardware_cpu_bits(platform string) int {
	lower := platform.to_lower()
	if lower.contains('x86_64') || lower.contains('ppc64') || lower.contains('powerpc64') || lower.contains('aarch64') || lower.contains('arm64') {
		return 64
	}
	if lower.contains('i386') || lower.contains('i486') || lower.contains('i586') || lower.contains('i686') || lower.contains('ppc') || lower.contains('arm') {
		return 32
	}
	return 0
}

pub fn hardware_cpu_arch(cpu HardwareCpu) string {
	kind := hardware_cpu_type(cpu.platform)
	bits := hardware_cpu_bits(cpu.platform)
	if kind == 'arm' {
		return if bits == 64 { 'arm64' } else { 'arm' }
	}
	if kind == 'intel' {
		return if bits == 64 { 'x86_64' } else { 'i386' }
	}
	if kind == 'ppc' && bits == 32 {
		return 'ppc32'
	}
	if kind == 'ppc' && bits == 64 {
		return if cpu.big_endian { 'ppc64' } else { 'ppc64le' }
	}
	return 'dunno'
}

pub fn hardware_arch_flag(cpu HardwareCpu, arch string) string {
	return if hardware_cpu_type(cpu.platform) == 'ppc' { '-mcpu=${arch}' } else { '-march=${arch}' }
}

pub fn hardware_optimization_flags(cpu HardwareCpu) map[string]string {
	return {
		'dunno':              ''
		'native':             hardware_arch_flag(cpu, 'native')
		'ivybridge':          '-march=ivybridge'
		'sandybridge':        '-march=sandybridge'
		'westmere':           '-march=westmere'
		'nehalem':            '-march=nehalem'
		'core2':              '-march=core2'
		'core':               '-march=prescott'
		'arm_vortex_tempest': ''
		'armv6':              '-march=armv6'
		'armv8':              '-march=armv8-a'
		'ppc64':              '-mcpu=powerpc64'
		'ppc64le':            '-mcpu=powerpc64le'
	}
}

pub fn hardware_cores_as_words(cores int) string {
	return match cores {
		1 { 'single' }
		2 { 'dual' }
		4 { 'quad' }
		6 { 'hexa' }
		8 { 'octa' }
		10 { 'deca' }
		12 { 'dodeca' }
		else { cores.str() }
	}
}

pub fn hardware_oldest_cpu(cpu HardwareCpu) string {
	kind := hardware_cpu_type(cpu.platform)
	bits := hardware_cpu_bits(cpu.platform)
	if kind == 'intel' {
		return if bits == 64 { 'core2' } else { 'core' }
	}
	if kind == 'arm' {
		return if bits == 64 { 'armv8' } else { 'armv6' }
	}
	if kind == 'ppc' && bits == 64 {
		return if cpu.big_endian { 'ppc64' } else { 'ppc64le' }
	}
	return if cpu.family == '' { 'dunno' } else { cpu.family }
}

pub fn hardware_rustflags_target_cpu(arch string) ?string {
	target := match arch {
		'core' { 'prescott' }
		'native', 'ivybridge', 'sandybridge', 'westmere', 'nehalem', 'core2' { arch }
		else { '' }
	}
	return if target == '' { none } else { '--codegen target-cpu=${target}' }
}

pub fn hardware_zig_cpu(arch string) string {
	return match arch {
		'arm_vortex_tempest' { 'apple_m1' }
		'armv6' { 'arm1136j_s' }
		'armv8' { 'xgene1' }
		'core' { 'prescott' }
		'dunno' { 'baseline' }
		else { arch.replace('-', '_') }
	}
}

pub fn hardware_cpu_value(cpu &HardwareCpu) ruby.Value {
	return ruby.structured_value('Hardware::CPU', hardware_cpu_arch(*cpu), {
		'cpu_address': u64(voidptr(cpu)).str()
	})
}

fn hardware_cpu_from_args(args []ruby.Value) (&HardwareCpu, int) {
	if args.len > 0 && args[0].type_name == 'Hardware::CPU' {
		address := args[0].attributes['cpu_address'] or { panic('invalid Hardware::CPU') }
		return unsafe { &HardwareCpu(voidptr(address.u64())) }, 1
	}
	return current_hardware_cpu(), 0
}

fn hardware_optional_value(value ?string) ruby.Value {
	if item := value {
		return ruby.string_value(item)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Translated from Homebrew/brew `hardware.rb`.
