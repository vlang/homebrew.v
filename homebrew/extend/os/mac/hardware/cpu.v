module hardware

import ruby
import homebrew
import homebrew.extend.os.mac.hardware.cpu as mac_cpu
import os

pub fn mac_hardware_cpu_type(properties mac_cpu.MacCpuProperties, fallback_platform string) string {
	cputype := mac_cpu.mac_cpu_sysctl_int(properties, 'hw.cputype')
	return match cputype {
		7 { 'intel' }
		0x100000c { 'arm' }
		else { homebrew.hardware_cpu_type(fallback_platform) }
	}
}

pub fn mac_hardware_cpu_family(properties mac_cpu.MacCpuProperties, arm bool,
	intel bool) string {
	value := mac_cpu.mac_cpu_sysctl_int(properties, 'hw.cpufamily')
	return if arm {
		mac_cpu.mac_cpu_arm_family(value)
	} else if intel {
		mac_cpu.mac_cpu_intel_family(value)
	} else {
		'dunno'
	}
}

pub fn mac_hardware_cpu_features(properties mac_cpu.MacCpuProperties) []string {
	return mac_cpu.mac_cpu_sysctl_n(properties, ['machdep.cpu.features', 'machdep.cpu.extfeatures',
		'machdep.cpu.leaf7_features']).split_any(' \n\t').filter(it != '').map(it.to_lower())
}

fn mac_hardware_properties_from_value(value ruby.Value) mac_cpu.MacCpuProperties {
	mut values := map[string]string{}
	if value.type_name == 'Hash' {
		for name, item in value.map_data {
			values[name] = item.as_string()
		}
	}
	return mac_cpu.MacCpuProperties{ values: values }
}

// Translated from Homebrew/brew `extend/os/mac/hardware/cpu.rb`.
