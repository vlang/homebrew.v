module cpu

import ruby

pub struct MacCpuProperties {
pub:
	values map[string]string
}

pub fn mac_cpu_sysctl_n(properties MacCpuProperties, keys []string) string {
	cache_key := keys.join('\x00')
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
