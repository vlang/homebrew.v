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
// The original source is retained below until every stub has a typed V body.

// Ruby method `type` at line 20.
pub fn ruby_cpu_l20_d1_type(args ...ruby.Value) ruby.Value {
	properties := if args.len > 0 {
		mac_hardware_properties_from_value(args[0])
	} else {
		mac_cpu.MacCpuProperties{}
	}
	platform := if args.len > 1 { args[1].as_string() } else { os.uname().machine }
	return ruby.string_value(mac_hardware_cpu_type(properties, platform))
}

// Ruby method `family` at line 32.
pub fn ruby_cpu_l32_d2_family(args ...ruby.Value) ruby.Value {
	properties := if args.len > 0 {
		mac_hardware_properties_from_value(args[0])
	} else {
		mac_cpu.MacCpuProperties{}
	}
	arm := if args.len > 1 {
		args[1].as_bool() or { panic(err) }
	} else {
		mac_hardware_cpu_type(properties, os.uname().machine) == 'arm'
	}
	intel := if args.len > 2 { args[2].as_bool() or { panic(err) } } else { !arm }
	return ruby.string_value(mac_hardware_cpu_family(properties, arm, intel))
}

// Ruby method `in_rosetta2?` at line 47.
pub fn ruby_cpu_l47_d3_in_rosetta2(args ...ruby.Value) ruby.Value {
	properties := if args.len > 0 {
		mac_hardware_properties_from_value(args[0])
	} else {
		mac_cpu.MacCpuProperties{}
	}
	return ruby.bool_value(mac_cpu.mac_cpu_sysctl_bool(properties, 'sysctl.proc_translated'))
}

// Ruby method `rosetta_installed?` at line 52.
pub fn ruby_cpu_l52_d4_rosetta_installed(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 {
		args[0].as_string()
	} else {
		'/Library/Apple/usr/libexec/oah/libRosettaRuntime'
	}
	return ruby.bool_value(os.exists(path))
}

// Ruby method `features` at line 57.
pub fn ruby_cpu_l57_d5_features(args ...ruby.Value) ruby.Value {
	properties := if args.len > 0 {
		mac_hardware_properties_from_value(args[0])
	} else {
		mac_cpu.MacCpuProperties{}
	}
	return ruby.string_array_value(mac_hardware_cpu_features(properties))
}

// Ruby method `sse4?` at line 66.
pub fn ruby_cpu_l66_d6_sse4(args ...ruby.Value) ruby.Value {
	properties := if args.len > 0 {
		mac_hardware_properties_from_value(args[0])
	} else {
		mac_cpu.MacCpuProperties{}
	}
	return ruby.bool_value(mac_cpu.mac_cpu_sysctl_bool(properties, 'hw.optional.sse4_1'))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module Hardware
// 7:       module CPU
// 8:         module ClassMethods
// 9:           extend T::Helpers
// 10:
// 11:           # Darwin's Mach-O CPU type for 32-bit Intel.
// 12:           CPU_TYPE_I386 = 7
// 13:           # Darwin's Mach-O CPU type for 64-bit ARM.
// 14:           CPU_TYPE_ARM64 = 0x100000C
// 15:           private_constant :CPU_TYPE_I386, :CPU_TYPE_ARM64
// 16:
// 17:           # These methods use info spewed out by sysctl.
// 18:           # Look in <mach/machine.h> for decoding info.
// 19:           sig { returns(Symbol) }
// 20:           def type
// 21:             case ::Hardware::CPU.sysctl_int("hw.cputype")
// 22:             when CPU_TYPE_I386
// 23:               :intel
// 24:             when CPU_TYPE_ARM64
// 25:               :arm
// 26:             else
// 27:               super
// 28:             end
// 29:           end
// 30:
// 31:           sig { returns(Symbol) }
// 32:           def family
// 33:             if ::Hardware::CPU.arm?
// 34:               ::Hardware::CPU.arm_family
// 35:             elsif ::Hardware::CPU.intel?
// 36:               ::Hardware::CPU.intel_family
// 37:             else
// 38:               :dunno
// 39:             end
// 40:           end
// 41:
// 42:           # True when running under an Intel-based shell via Rosetta 2 on an
// 43:           # Apple Silicon Mac. This can be detected via seeing if there's a
// 44:           # conflict between what `uname` reports and the underlying `sysctl` flags,
// 45:           # since the `sysctl` flags don't change behaviour under Rosetta 2.
// 46:           sig { returns(T::Boolean) }
// 47:           def in_rosetta2?
// 48:             ::Hardware::CPU.sysctl_bool!("sysctl.proc_translated")
// 49:           end
// 50:
// 51:           sig { returns(T::Boolean) }
// 52:           def rosetta_installed?
// 53:             File.exist?(::Hardware::CPU::ROSETTA_RUNTIME_PATH)
// 54:           end
// 55:
// 56:           sig { returns(T::Array[Symbol]) }
// 57:           def features
// 58:             @features ||= T.let(::Hardware::CPU.sysctl_n(
// 59:               "machdep.cpu.features",
// 60:               "machdep.cpu.extfeatures",
// 61:               "machdep.cpu.leaf7_features",
// 62:             ).split.map { |s| s.downcase.to_sym }, T.nilable(T::Array[Symbol]))
// 63:           end
// 64:
// 65:           sig { returns(T::Boolean) }
// 66:           def sse4?
// 67:             ::Hardware::CPU.sysctl_bool!("hw.optional.sse4_1")
// 68:           end
// 69:         end
// 70:       end
// 71:     end
// 72:   end
// 73: end
// 74:
// 75: Hardware::CPU.singleton_class.prepend(OS::Mac::Hardware::CPU::ClassMethods)
// 76: require "extend/os/mac/hardware/cpu/hardware"
