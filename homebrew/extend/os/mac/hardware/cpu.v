module hardware

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/hardware/cpu.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `type` at line 20.
pub fn ruby_cpu_l20_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `family` at line 32.
pub fn ruby_cpu_l32_d2_family(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('family', ...args)
}

// Ruby method `in_rosetta2?` at line 47.
pub fn ruby_cpu_l47_d3_in_rosetta2(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('in_rosetta2?', ...args)
}

// Ruby method `rosetta_installed?` at line 52.
pub fn ruby_cpu_l52_d4_rosetta_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rosetta_installed?', ...args)
}

// Ruby method `features` at line 57.
pub fn ruby_cpu_l57_d5_features(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('features', ...args)
}

// Ruby method `sse4?` at line 66.
pub fn ruby_cpu_l66_d6_sse4(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sse4?', ...args)
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
