module linux

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/system_config.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `host_glibc_version` at line 19.
pub fn ruby_system_config_l19_d1_host_glibc_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('host_glibc_version', ...args)
}

// Ruby method `host_libstdcxx_version` at line 27.
pub fn ruby_system_config_l27_d2_host_libstdcxx_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('host_libstdcxx_version', ...args)
}

// Ruby method `host_gcc_version` at line 35.
pub fn ruby_system_config_l35_d3_host_gcc_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('host_gcc_version', ...args)
}

// Ruby method `formula_linked_version(formula)` at line 43.
pub fn ruby_system_config_l43_d4_formula_linked_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_linked_version', ...args)
}

// Ruby method `host_ruby_version` at line 52.
pub fn ruby_system_config_l52_d5_host_ruby_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('host_ruby_version', ...args)
}

// Ruby method `windows_version` at line 60.
pub fn ruby_system_config_l60_d6_windows_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('windows_version', ...args)
}

// Ruby method `windows_registry_version(cmd)` at line 74.
pub fn ruby_system_config_l74_d7_windows_registry_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('windows_registry_version', ...args)
}

// Ruby method `windows_registry_values(cmd)` at line 90.
pub fn ruby_system_config_l90_d8_windows_registry_values(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('windows_registry_values', ...args)
}

// Ruby method `linux_config(out = $stdout)` at line 108.
pub fn ruby_system_config_l108_d9_linux_config(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('linux_config', ...args)
}

// Ruby method `config_sections` at line 127.
pub fn ruby_system_config_l127_d10_config_sections(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('config_sections', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "compilers"
// 5: require "extend/os/linux/sandbox/landlock"
// 6: require "os/linux/glibc"
// 7: require "os/linux/libstdcxx"
// 8: require "system_command"
// 9:
// 10: module OS
// 11:   module Linux
// 12:     module SystemConfig
// 13:       module ClassMethods
// 14:         include SystemCommand::Mixin
// 15:
// 16:         HOST_RUBY_PATH = "/usr/bin/ruby"
// 17:
// 18:         sig { returns(T.any(String, Version)) }
// 19:         def host_glibc_version
// 20:           version = OS::Linux::Glibc.system_version
// 21:           return "N/A" if version.null?
// 22:
// 23:           version
// 24:         end
// 25:
// 26:         sig { returns(T.any(String, Version)) }
// 27:         def host_libstdcxx_version
// 28:           version = OS::Linux::Libstdcxx.system_version
// 29:           return "N/A" if version.null?
// 30:
// 31:           version
// 32:         end
// 33:
// 34:         sig { returns(String) }
// 35:         def host_gcc_version
// 36:           gcc = ::DevelopmentTools.host_gcc_path
// 37:           return "N/A" unless gcc.executable?
// 38:
// 39:           Utils.popen_read(gcc, "--version")[/ (\d+\.\d+\.\d+)/, 1] || "N/A"
// 40:         end
// 41:
// 42:         sig { params(formula: T.any(::Pathname, String)).returns(T.any(String, PkgVersion)) }
// 43:         def formula_linked_version(formula)
// 44:           return "N/A" if Homebrew::EnvConfig.no_install_from_api? && !CoreTap.instance.installed?
// 45:
// 46:           Formulary.factory(formula).any_installed_version || "N/A"
// 47:         rescue FormulaUnavailableError
// 48:           "N/A"
// 49:         end
// 50:
// 51:         sig { returns(String) }
// 52:         def host_ruby_version
// 53:           out, _, status = system_command(HOST_RUBY_PATH, args: ["-e", "puts RUBY_VERSION"], print_stderr: false).to_a
// 54:           return "N/A" unless status.success?
// 55:
// 56:           out
// 57:         end
// 58:
// 59:         sig { returns(T.nilable(String)) }
// 60:         def windows_version
// 61:           return unless OS.wsl?
// 62:
// 63:           cmd = Kernel.which("cmd.exe", ORIGINAL_PATHS) || ::Pathname.new("/mnt/c/Windows/System32/cmd.exe")
// 64:           return unless cmd.executable?
// 65:
// 66:           windows_registry_version(cmd) || Utils.popen_read(cmd, "/d", "/c", "ver", err: :close)
// 67:                                                 .delete("\r")
// 68:                                                 .lines
// 69:                                                 .map(&:strip)
// 70:                                                 .find { |line| line.start_with?("Microsoft Windows") }
// 71:         end
// 72:
// 73:         sig { params(cmd: ::Pathname).returns(T.nilable(String)) }
// 74:         def windows_registry_version(cmd)
// 75:           values = windows_registry_values(cmd)
// 76:           product_name = values["ProductName"]
// 77:           build = values["CurrentBuildNumber"]
// 78:           return if product_name.blank? || build.blank?
// 79:
// 80:           product_name = product_name.sub(/\AWindows 10\b/, "Windows 11") if build.to_i >= 22_000
// 81:           build += ".#{values["UBR"]}" if values["UBR"].present?
// 82:
// 83:           version = values["DisplayVersion"] || values["ReleaseId"]
// 84:           return "#{product_name} [#{build}]" if version.blank?
// 85:
// 86:           "#{product_name} (#{version}) [#{build}]"
// 87:         end
// 88:
// 89:         sig { params(cmd: ::Pathname).returns(T::Hash[String, String]) }
// 90:         def windows_registry_values(cmd)
// 91:           output = Utils.popen_read(cmd, "/d", "/c", "reg", "query",
// 92:                                     "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
// 93:                                     err: :close)
// 94:
// 95:           output.each_line.with_object({}) do |line, values|
// 96:             match = line.delete("\r").match(/^\s*(\S+)\s+REG_\S+\s+(.+?)\s*$/)
// 97:             next if match.nil?
// 98:
// 99:             key = match[1]
// 100:             value = match[2]
// 101:             next if key.nil? || value.nil?
// 102:
// 103:             values[key] = value.start_with?("0x") ? value.to_i(16).to_s : value
// 104:           end
// 105:         end
// 106:
// 107:         sig { params(out: T.any(File, StringIO, IO)).void }
// 108:         def linux_config(out = $stdout)
// 109:           out.puts "Kernel: #{Utils.safe_popen_read("uname", "-mors").chomp}"
// 110:           out.puts "Landlock ABI: #{::Sandbox::Landlock.kernel_abi_version || "N/A"}"
// 111:           out.puts "OS: #{OS::Linux.os_version}"
// 112:           if OS.wsl?
// 113:             out.puts "WSL: #{OS::Linux.wsl_version}"
// 114:             windows = windows_version
// 115:             out.puts "Windows: #{windows}" if windows
// 116:           end
// 117:           out.puts "Host glibc: #{host_glibc_version}"
// 118:           out.puts "Host libstdc++: #{host_libstdcxx_version}"
// 119:           out.puts "#{::DevelopmentTools.host_gcc_path}: #{host_gcc_version}"
// 120:           out.puts "/usr/bin/ruby: #{host_ruby_version}" if RUBY_PATH != HOST_RUBY_PATH
// 121:           ["glibc", ::CompilerSelector.preferred_gcc, OS::LINUX_PREFERRED_GCC_RUNTIME_FORMULA, "xorg"].each do |f|
// 122:             out.puts "#{f}: #{formula_linked_version(f)}"
// 123:           end
// 124:         end
// 125:
// 126:         sig { returns(T::Array[Symbol]) }
// 127:         def config_sections
// 128:           super + [:linux_config]
// 129:         end
// 130:       end
// 131:     end
// 132:   end
// 133: end
// 134:
// 135: SystemConfig.singleton_class.prepend(OS::Linux::SystemConfig::ClassMethods)
