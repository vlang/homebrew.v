module mac

import ruby

pub struct MacSystemConfig {
pub:
	clang                string
	clang_build          string
	xcode_installed      bool
	xcode_version        string
	xcode_prefix         string
	xcode_default_prefix bool = true
	clt_installed        bool
	clt_version          string
	arm64                bool
	physical_arm64       bool
	in_rosetta2          bool
	metal_success        bool
	metal_output         string
	macos_full_version   string
	kernel               string
	base_sections        []string
}

pub fn mac_describe_clang(config MacSystemConfig) string {
	if config.clang == '' {
		return 'N/A'
	}
	build := if config.clang_build == '' { '(parse error)' } else { config.clang_build }
	return '${config.clang} build ${build}'
}

pub fn mac_system_xcode(config MacSystemConfig) ?string {
	if !config.xcode_installed {
		return none
	}
	return if config.xcode_default_prefix {
		config.xcode_version
	} else {
		'${config.xcode_version} => ${config.xcode_prefix}'
	}
}

pub fn mac_system_clt(config MacSystemConfig) ?string {
	if !config.clt_installed {
		return none
	}
	return config.clt_version
}

pub fn mac_metal_toolchain(config MacSystemConfig) ?string {
	if !config.arm64 || !(config.xcode_installed || config.clt_installed) || !config.metal_success {
		return none
	}
	marker := 'MetalToolchain-v'
	if !config.metal_output.contains(marker) {
		return none
	}
	version := config.metal_output.all_after(marker).fields()[0]
	parts := version.split('.')
	if parts.len < 4 {
		return none
	}
	letter_value := parts[1].int()
	if letter_value < 1 || letter_value > 26 {
		return none
	}
	letter := rune(`A` + letter_value - 1).str()
	return '${parts[0]}.${parts[3]} (${parts[0]}${letter}${parts[2]})'
}

pub fn macos_config_lines(config MacSystemConfig) []string {
	mut lines := ['macOS: ${config.macos_full_version}-${config.kernel}']
	lines << 'CLT: ${mac_system_clt(config) or { 'N/A' }}'
	lines << 'Xcode: ${mac_system_xcode(config) or { 'N/A' }}'
	if config.arm64 && config.xcode_installed && version_at_least(config.xcode_version, '26.0') {
		lines << 'Metal Toolchain: ${mac_metal_toolchain(config) or { 'N/A' }}'
	}
	if config.physical_arm64 { lines << 'Rosetta 2: ${config.in_rosetta2}' }
	return lines
}

fn version_at_least(current string, required string) bool {
	a := current.split('.').map(it.int())
	b := required.split('.').map(it.int())
	maximum := if a.len > b.len { a.len } else { b.len }
	for index in 0 .. maximum {
		av := if index < a.len { a[index] } else { 0 }
		bv := if index < b.len { b[index] } else { 0 }
		if av != bv {
			return av > bv
		}
	}
	return true
}

pub fn mac_config_sections(config MacSystemConfig) []string {
	mut sections := config.base_sections.clone()
	sections << 'macos_config'
	return sections
}

fn mac_system_config_value(config &MacSystemConfig) ruby.Value {
	return ruby.structured_value('SystemConfig', '', {
		'mac_system_config_address': u64(voidptr(config)).str()
	})
}

fn mac_system_config_from_value(value ruby.Value) &MacSystemConfig {
	return unsafe { &MacSystemConfig(voidptr(value.attributes['mac_system_config_address'].u64())) }
}

pub fn mac_system_config_boundary(config &MacSystemConfig) ruby.Value {
	return mac_system_config_value(config)
}

// Translated from Homebrew/brew `extend/os/mac/system_config.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 15.
pub fn ruby_system_config_l15_d1_initialize(args ...ruby.Value) ruby.Value {
	config := &MacSystemConfig{}
	return mac_system_config_value(config)
}

// Ruby method `describe_clang` at line 22.
pub fn ruby_system_config_l22_d2_describe_clang(args ...ruby.Value) ruby.Value {
	return ruby.string_value(mac_describe_clang(*mac_system_config_from_value(args[0])))
}

// Ruby method `xcode` at line 30.
pub fn ruby_system_config_l30_d3_xcode(args ...ruby.Value) ruby.Value {
	value := mac_system_xcode(*mac_system_config_from_value(args[0])) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(value)
}

// Ruby method `clt` at line 39.
pub fn ruby_system_config_l39_d4_clt(args ...ruby.Value) ruby.Value {
	value := mac_system_clt(*mac_system_config_from_value(args[0])) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(value)
}

// Ruby method `metal_toolchain` at line 44.
pub fn ruby_system_config_l44_d5_metal_toolchain(args ...ruby.Value) ruby.Value {
	value := mac_metal_toolchain(*mac_system_config_from_value(args[0])) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(value)
}

// Ruby method `macos_config(out = $stdout)` at line 60.
pub fn ruby_system_config_l60_d6_macos_config(args ...ruby.Value) ruby.Value {
	return ruby.string_value(macos_config_lines(*mac_system_config_from_value(args[0])).join('\n') + '\n')
}

// Ruby method `config_sections` at line 72.
pub fn ruby_system_config_l72_d7_config_sections(args ...ruby.Value) ruby.Value {
	return ruby.array_value(mac_config_sections(*mac_system_config_from_value(args[0])).map(ruby.object_value('Symbol', it)))
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
