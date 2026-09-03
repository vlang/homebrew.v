module linux

import brew_runtime
import os
import strconv

pub const linux_system_config_host_ruby_path = '/usr/bin/ruby'

pub struct LinuxSystemConfigCommand {
pub:
	executable string
	arguments  []string
}

pub struct LinuxSystemConfigCommandResult {
pub:
	stdout  string
	stderr  string
	success bool = true
}

// LinuxSystemConfig retains the host facts consumed by the Linux extension.
// command_results and executable_paths are injectable equivalents of
// SystemCommand and File.executable?, while an empty collection uses the host.
pub struct LinuxSystemConfig {
pub:
	host_glibc_version                  ?string
	host_libstdcxx_version              ?string
	host_gcc_path                       string = '/usr/bin/gcc'
	host_ruby_path                      string = linux_system_config_host_ruby_path
	ruby_path                           string = linux_system_config_host_ruby_path
	no_install_from_api                 bool
	core_tap_installed                  bool
	linked_formula_versions             map[string]string
	wsl                                 bool
	wsl_version                         string
	windows_cmd                         string
	original_paths                      []string
	executable_paths                    []string
	command_results                     map[string]LinuxSystemConfigCommandResult
	landlock_abi                        ?int
	os_version                          string = 'Unknown'
	preferred_gcc                       string = 'gcc@13'
	linux_preferred_gcc_runtime_formula string = 'gcc'
	base_sections                       []string
}

fn linux_system_config_version_from_output(output string, components int) ?string {
	for start in 0 .. output.len {
		if !output[start].is_digit() || start == 0 || output[start - 1] != ` ` {
			continue
		}
		mut finish := start
		mut dots := 0
		for finish < output.len && (output[finish].is_digit() || output[finish] == `.`) {
			if output[finish] == `.` {
				dots++
			}
			finish++
		}
		if dots == components - 1 && finish > start && output[finish - 1].is_digit() {
			return output[start..finish]
		}
	}
	return none
}

pub fn linux_system_config_glibc_version_from_output(output string) ?string {
	return linux_system_config_version_from_output(output, 2)
}

pub fn linux_system_config_gcc_version_from_output(output string) ?string {
	return linux_system_config_version_from_output(output, 3)
}

fn linux_system_config_command_key(command LinuxSystemConfigCommand) string {
	mut values := [command.executable]
	values << command.arguments
	return values.join('\x00')
}

pub fn linux_system_config_run(config &LinuxSystemConfig,
	command LinuxSystemConfigCommand) LinuxSystemConfigCommandResult {
	key := linux_system_config_command_key(command)
	if key in config.command_results {
		return config.command_results[key]
	}
	result := brew_runtime.run_command(command.executable, command.arguments)
	return LinuxSystemConfigCommandResult{
		stdout: result.output
		success: result.exit_code == 0
	}
}

fn linux_system_config_executable(config &LinuxSystemConfig, path string) bool {
	if config.executable_paths.len > 0 {
		return path in config.executable_paths
	}
	return os.is_file(path) && os.is_executable(path)
}

fn linux_system_config_path_entries(value string) []string {
	if value == '' {
		return []
	}
	return value.split(os.path_delimiter)
}

fn linux_system_config_find_executable(config &LinuxSystemConfig, name string) ?string {
	for directory in config.original_paths {
		path := os.join_path(directory, name)
		if linux_system_config_executable(config, path) {
			return path
		}
	}
	return none
}

pub fn linux_system_config_parse_registry_values(output string) map[string]string {
	mut values := map[string]string{}
	for raw_line in output.split_into_lines() {
		fields := raw_line.replace('\r', '').fields()
		if fields.len < 3 || !fields[1].starts_with('REG_') {
			continue
		}
		mut value := fields[2..].join(' ').trim_space()
		if value.starts_with('0x') && value.len > 2 {
			parsed := strconv.parse_uint(value[2..], 16, 64) or { continue }
			value = parsed.str()
		}
		values[fields[0]] = value
	}
	return values
}

pub fn linux_system_config_windows_registry_version(values map[string]string) ?string {
	mut product_name := (values['ProductName'] or { return none }).trim_space()
	mut build := (values['CurrentBuildNumber'] or { return none }).trim_space()
	if product_name == '' || build == '' {
		return none
	}
	if build.int() >= 22_000 && (product_name == 'Windows 10'
		|| (product_name.starts_with('Windows 10') && product_name.len > 'Windows 10'.len
			&& !product_name['Windows 10'.len].is_alnum()
			&& product_name['Windows 10'.len] != `_`)) {
		product_name = 'Windows 11' + product_name['Windows 10'.len..]
	}
	if update_build_revision := values['UBR'] {
		if update_build_revision.trim_space() != '' {
			build += '.${update_build_revision.trim_space()}'
		}
	}
	version := (values['DisplayVersion'] or { values['ReleaseId'] or { '' } }).trim_space()
	if version == '' {
		return '${product_name} [${build}]'
	}
	return '${product_name} (${version}) [${build}]'
}

fn linux_system_config_windows_ver(output string) ?string {
	for raw_line in output.replace('\r', '').split_into_lines() {
		line := raw_line.trim_space()
		if line.starts_with('Microsoft Windows') {
			return line
		}
	}
	return none
}

pub fn linux_system_config_host_glibc_version(config &LinuxSystemConfig) string {
	return config.host_glibc_version or { 'N/A' }
}

pub fn linux_system_config_host_libstdcxx_version(config &LinuxSystemConfig) string {
	return config.host_libstdcxx_version or { 'N/A' }
}

pub fn linux_system_config_host_gcc_version(config &LinuxSystemConfig) string {
	if !linux_system_config_executable(config, config.host_gcc_path) {
		return 'N/A'
	}
	result := linux_system_config_run(config, LinuxSystemConfigCommand{
		executable: config.host_gcc_path
		arguments: ['--version']
	})
	return linux_system_config_gcc_version_from_output(result.stdout) or { 'N/A' }
}

pub fn linux_system_config_formula_linked_version(config &LinuxSystemConfig,
	formula string) string {
	if config.no_install_from_api && !config.core_tap_installed {
		return 'N/A'
	}
	version := config.linked_formula_versions[formula] or { return 'N/A' }
	return if version == '' { 'N/A' } else { version }
}

pub fn linux_system_config_host_ruby_version(config &LinuxSystemConfig) string {
	result := linux_system_config_run(config, LinuxSystemConfigCommand{
		executable: config.host_ruby_path
		arguments: ['-e', 'puts RUBY_VERSION']
	})
	return if result.success { result.stdout } else { 'N/A' }
}

pub fn linux_system_config_registry_values(config &LinuxSystemConfig,
	cmd string) map[string]string {
	result := linux_system_config_run(config, LinuxSystemConfigCommand{
		executable: cmd
		arguments: ['/d', '/c', 'reg', 'query', 'HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion']
	})
	return linux_system_config_parse_registry_values(result.stdout)
}

pub fn linux_system_config_registry_version(config &LinuxSystemConfig, cmd string) ?string {
	return linux_system_config_windows_registry_version(linux_system_config_registry_values(config, cmd))
}

pub fn linux_system_config_windows_version(config &LinuxSystemConfig) ?string {
	if !config.wsl {
		return none
	}
	cmd := if config.windows_cmd != '' {
		config.windows_cmd
	} else {
		linux_system_config_find_executable(config, 'cmd.exe') or {
			'/mnt/c/Windows/System32/cmd.exe'
		}
	}
	if !linux_system_config_executable(config, cmd) {
		return none
	}
	if registry_version := linux_system_config_registry_version(config, cmd) {
		return registry_version
	}
	result := linux_system_config_run(config, LinuxSystemConfigCommand{
		executable: cmd
		arguments: ['/d', '/c', 'ver']
	})
	return linux_system_config_windows_ver(result.stdout)
}

pub fn linux_system_config_lines(config &LinuxSystemConfig) []string {
	kernel := linux_system_config_run(config, LinuxSystemConfigCommand{
		executable: 'uname'
		arguments: ['-mors']
	}).stdout.trim_space()
	mut lines := [
		'Kernel: ${kernel}',
		'Landlock ABI: ${if abi := config.landlock_abi { abi.str() } else { 'N/A' }}',
		'OS: ${config.os_version}',
	]
	if config.wsl {
		lines << 'WSL: ${config.wsl_version}'
		if windows := linux_system_config_windows_version(config) {
			lines << 'Windows: ${windows}'
		}
	}
	lines << 'Host glibc: ${linux_system_config_host_glibc_version(config)}'
	lines << 'Host libstdc++: ${linux_system_config_host_libstdcxx_version(config)}'
	lines << '${config.host_gcc_path}: ${linux_system_config_host_gcc_version(config)}'
	if config.ruby_path != config.host_ruby_path {
		lines << '${config.host_ruby_path}: ${linux_system_config_host_ruby_version(config)}'
	}
	for formula in ['glibc', config.preferred_gcc, config.linux_preferred_gcc_runtime_formula, 'xorg'] {
		lines << '${formula}: ${linux_system_config_formula_linked_version(config, formula)}'
	}
	return lines
}

pub fn linux_system_config_output(config &LinuxSystemConfig) string {
	return linux_system_config_lines(config).map(it.trim_right('\r\n')).join('\n') + '\n'
}

pub fn linux_system_config_sections(config &LinuxSystemConfig) []string {
	mut sections := config.base_sections.clone()
	sections << 'linux_config'
	return sections
}

fn linux_system_config_detect_libstdcxx_version() ?string {
	for compiler in ['/usr/bin/g++', '/usr/bin/c++'] {
		if !os.is_file(compiler) || !os.is_executable(compiler) {
			continue
		}
		result := brew_runtime.run_command(compiler, ['-print-file-name=libstdc++.so.6'])
		path := result.output.trim_space()
		if result.exit_code != 0 || path == '' || path == 'libstdc++.so.6' || !os.exists(path) {
			continue
		}
		basename := os.base(os.real_path(path))
		if basename.starts_with('libstdc++.so.6') {
			return '6' + basename['libstdc++.so.6'.len..]
		}
	}
	return none
}

fn linux_system_config_detect_os_version() string {
	result := brew_runtime.run_command('lsb_release', ['-a'])
	if result.exit_code != 0 {
		return if value := os.getenv_opt('OS_VERSION') { value } else { 'Unknown' }
	}
	mut description := ''
	mut codename := ''
	for line in result.output.split_into_lines() {
		if line.starts_with('Description:') {
			description = line.all_after(':').trim_space()
		} else if line.starts_with('Codename:') {
			codename = line.all_after(':').trim_space()
		}
	}
	if description == '' {
		return 'Unknown'
	}
	return if codename == '' || codename == 'n/a' {
		description
	} else {
		'${description} (${codename})'
	}
}

fn linux_system_config_wsl_version(kernel string) string {
	if kernel.contains('-') {
		version := kernel.all_before('-').split('.')
		major := if version.len > 0 { version[0].int() } else { 0 }
		minor := if version.len > 1 { version[1].int() } else { 0 }
		if major > 5 || (major == 5 && minor > 15) {
			return '2 (Microsoft Store)'
		}
	}
	if kernel.contains('-microsoft') {
		return '2'
	}
	if kernel.contains('-Microsoft') {
		return '1'
	}
	return 'N/A'
}

pub fn new_linux_system_config() &LinuxSystemConfig {
	glibc_result := brew_runtime.run_command('/usr/bin/ldd', ['--version'])
	glibc_version := linux_system_config_glibc_version_from_output(glibc_result.output)
	kernel := brew_runtime.kernel_info().release
	wsl := kernel.to_lower().contains('-microsoft')
	preferred_gcc := 'gcc@13'
	versioned_gcc := '/usr/bin/${preferred_gcc.replace('@', '-')}'
	host_gcc_path := if os.is_file(versioned_gcc) && os.is_executable(versioned_gcc) {
		versioned_gcc
	} else {
		'/usr/bin/gcc'
	}
	original_path := os.getenv('HOMEBREW_PATH')
	return &LinuxSystemConfig{
		host_glibc_version: glibc_version
		host_libstdcxx_version: linux_system_config_detect_libstdcxx_version()
		host_gcc_path: host_gcc_path
		ruby_path: if value := os.getenv_opt('HOMEBREW_RUBY_PATH') {
			value
		} else {
			linux_system_config_host_ruby_path
		}
		no_install_from_api: os.getenv_opt('HOMEBREW_NO_INSTALL_FROM_API') != none
		core_tap_installed: os.is_dir(os.join_path(os.getenv('HOMEBREW_LIBRARY'), 'Taps/homebrew/homebrew-core'))
		wsl: wsl
		wsl_version: if wsl { linux_system_config_wsl_version(kernel) } else { '' }
		original_paths: linux_system_config_path_entries(if original_path == '' {
			os.getenv('PATH')
		} else {
			original_path
		})
		os_version: linux_system_config_detect_os_version()
		preferred_gcc: preferred_gcc
	}
}

fn linux_system_config_value(config &LinuxSystemConfig) brew_runtime.Value {
	return brew_runtime.structured_value('SystemConfig', '', {
		'linux_system_config_address': u64(voidptr(config)).str()
	})
}

fn linux_system_config_from_args(args []brew_runtime.Value) (&LinuxSystemConfig, int) {
	if args.len > 0 && 'linux_system_config_address' in args[0].attributes {
		return unsafe { &LinuxSystemConfig(voidptr(args[0].attributes['linux_system_config_address'].u64())) }, 1
	}
	return new_linux_system_config(), 0
}

pub fn linux_system_config_boundary(config &LinuxSystemConfig) brew_runtime.Value {
	return linux_system_config_value(config)
}

// Translated from Homebrew/brew `extend/os/linux/system_config.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `host_glibc_version` at line 19.
pub fn ruby_system_config_l19_d1_host_glibc_version(args ...brew_runtime.Value) brew_runtime.Value {
	config, _ := linux_system_config_from_args(args)
	version := linux_system_config_host_glibc_version(config)
	return if version == 'N/A' {
		brew_runtime.string_value(version)
	} else {
		brew_runtime.object_value('Version', version)
	}
}

// Ruby method `host_libstdcxx_version` at line 27.
pub fn ruby_system_config_l27_d2_host_libstdcxx_version(args ...brew_runtime.Value) brew_runtime.Value {
	config, _ := linux_system_config_from_args(args)
	version := linux_system_config_host_libstdcxx_version(config)
	return if version == 'N/A' {
		brew_runtime.string_value(version)
	} else {
		brew_runtime.object_value('Version', version)
	}
}

// Ruby method `host_gcc_version` at line 35.
pub fn ruby_system_config_l35_d3_host_gcc_version(args ...brew_runtime.Value) brew_runtime.Value {
	config, _ := linux_system_config_from_args(args)
	return brew_runtime.string_value(linux_system_config_host_gcc_version(config))
}

// Ruby method `formula_linked_version(formula)` at line 43.
pub fn ruby_system_config_l43_d4_formula_linked_version(args ...brew_runtime.Value) brew_runtime.Value {
	config, offset := linux_system_config_from_args(args)
	if args.len <= offset {
		return brew_runtime.string_value('N/A')
	}
	version := linux_system_config_formula_linked_version(config, args[offset].as_string())
	return if version == 'N/A' {
		brew_runtime.string_value(version)
	} else {
		brew_runtime.object_value('PkgVersion', version)
	}
}

// Ruby method `host_ruby_version` at line 52.
pub fn ruby_system_config_l52_d5_host_ruby_version(args ...brew_runtime.Value) brew_runtime.Value {
	config, _ := linux_system_config_from_args(args)
	return brew_runtime.string_value(linux_system_config_host_ruby_version(config))
}

// Ruby method `windows_version` at line 60.
pub fn ruby_system_config_l60_d6_windows_version(args ...brew_runtime.Value) brew_runtime.Value {
	config, _ := linux_system_config_from_args(args)
	version := linux_system_config_windows_version(config) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.string_value(version)
}

// Ruby method `windows_registry_version(cmd)` at line 74.
pub fn ruby_system_config_l74_d7_windows_registry_version(args ...brew_runtime.Value) brew_runtime.Value {
	config, offset := linux_system_config_from_args(args)
	if args.len <= offset {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	version := linux_system_config_registry_version(config, args[offset].as_string()) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.string_value(version)
}

// Ruby method `windows_registry_values(cmd)` at line 90.
pub fn ruby_system_config_l90_d8_windows_registry_values(args ...brew_runtime.Value) brew_runtime.Value {
	config, offset := linux_system_config_from_args(args)
	if args.len <= offset {
		return brew_runtime.map_value({})
	}
	values := linux_system_config_registry_values(config, args[offset].as_string())
	mut result := map[string]brew_runtime.Value{}
	for key, value in values {
		result[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(result)
}

// Ruby method `linux_config(out = $stdout)` at line 108.
pub fn ruby_system_config_l108_d9_linux_config(args ...brew_runtime.Value) brew_runtime.Value {
	config, _ := linux_system_config_from_args(args)
	return brew_runtime.string_value(linux_system_config_output(config))
}

// Ruby method `config_sections` at line 127.
pub fn ruby_system_config_l127_d10_config_sections(args ...brew_runtime.Value) brew_runtime.Value {
	config, _ := linux_system_config_from_args(args)
	return brew_runtime.array_value(linux_system_config_sections(config).map(brew_runtime.object_value('Symbol', it)))
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
