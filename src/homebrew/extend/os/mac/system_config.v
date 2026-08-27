module mac

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/system_config.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 15.
pub fn ruby_system_config_l15_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `describe_clang` at line 22.
pub fn ruby_system_config_l22_d2_describe_clang(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('describe_clang', ...args)
}

// Ruby method `xcode` at line 30.
pub fn ruby_system_config_l30_d3_xcode(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('xcode', ...args)
}

// Ruby method `clt` at line 39.
pub fn ruby_system_config_l39_d4_clt(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clt', ...args)
}

// Ruby method `metal_toolchain` at line 44.
pub fn ruby_system_config_l44_d5_metal_toolchain(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('metal_toolchain', ...args)
}

// Ruby method `macos_config(out = $stdout)` at line 60.
pub fn ruby_system_config_l60_d6_macos_config(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macos_config', ...args)
}

// Ruby method `config_sections` at line 72.
pub fn ruby_system_config_l72_d7_config_sections(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('config_sections', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module SystemConfig
// 9:       module ClassMethods
// 10:         extend T::Helpers
// 11:
// 12:         requires_ancestor { T.class_of(::SystemConfig) }
// 13:
// 14:         sig { void }
// 15:         def initialize
// 16:           super
// 17:           @xcode = T.let(nil, T.nilable(String))
// 18:           @clt = T.let(nil, T.nilable(Version))
// 19:         end
// 20:
// 21:         sig { returns(String) }
// 22:         def describe_clang
// 23:           return "N/A" if clang.null?
// 24:
// 25:           clang_build_info = clang_build.null? ? "(parse error)" : clang_build
// 26:           "#{clang} build #{clang_build_info}"
// 27:         end
// 28:
// 29:         sig { returns(T.nilable(String)) }
// 30:         def xcode
// 31:           @xcode ||= if MacOS::Xcode.installed?
// 32:             xcode = MacOS::Xcode.version.to_s
// 33:             xcode += " => #{MacOS::Xcode.prefix}" unless MacOS::Xcode.default_prefix?
// 34:             xcode
// 35:           end
// 36:         end
// 37:
// 38:         sig { returns(T.nilable(Version)) }
// 39:         def clt
// 40:           @clt ||= MacOS::CLT.version if MacOS::CLT.installed?
// 41:         end
// 42:
// 43:         sig { returns(T.nilable(String)) }
// 44:         def metal_toolchain
// 45:           return unless ::Hardware::CPU.arm64?
// 46:
// 47:           @metal_toolchain ||= T.let(nil, T.nilable(String))
// 48:           @metal_toolchain ||= if MacOS::Xcode.installed? || MacOS::CLT.installed?
// 49:             result = SystemCommand.run("xcrun", args: ["--find", "metal"],
// 50:                                        print_stderr: false, print_stdout: false)
// 51:             pattern = /MetalToolchain-v(?<major>\d+)\.(?<letter>\d+)\.(?<build>\d+)\.(?<minor>\d+)/
// 52:             if result.success? && (m = result.stdout.match(pattern))
// 53:               letter = ("A".ord - 1 + m[:letter].to_i).chr
// 54:               "#{m[:major]}.#{m[:minor]} (#{m[:major]}#{letter}#{m[:build]})"
// 55:             end
// 56:           end
// 57:         end
// 58:
// 59:         sig { params(out: T.any(File, StringIO, IO)).void }
// 60:         def macos_config(out = $stdout)
// 61:           out.puts "macOS: #{MacOS.full_version}-#{kernel}"
// 62:           out.puts "CLT: #{clt || "N/A"}"
// 63:           out.puts "Xcode: #{xcode || "N/A"}"
// 64:           # Metal Toolchain is a separate install starting with Xcode 26.
// 65:           if ::Hardware::CPU.arm64? && MacOS::Xcode.installed? && MacOS::Xcode.version >= "26.0"
// 66:             out.puts "Metal Toolchain: #{metal_toolchain || "N/A"}"
// 67:           end
// 68:           out.puts "Rosetta 2: #{::Hardware::CPU.in_rosetta2?}" if ::Hardware::CPU.physical_cpu_arm64?
// 69:         end
// 70:
// 71:         sig { returns(T::Array[Symbol]) }
// 72:         def config_sections
// 73:           super + [:macos_config]
// 74:         end
// 75:       end
// 76:     end
// 77:   end
// 78: end
// 79:
// 80: SystemConfig.singleton_class.prepend(OS::Mac::SystemConfig::ClassMethods)
