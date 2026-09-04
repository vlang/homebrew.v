module linux

import ruby
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
	result := ruby.run_command(command.executable, command.arguments)
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
		result := ruby.run_command(compiler, ['-print-file-name=libstdc++.so.6'])
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
	result := ruby.run_command('lsb_release', ['-a'])
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
	glibc_result := ruby.run_command('/usr/bin/ldd', ['--version'])
	glibc_version := linux_system_config_glibc_version_from_output(glibc_result.output)
	kernel := ruby.kernel_info().release
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

fn linux_system_config_value(config &LinuxSystemConfig) ruby.Value {
	return ruby.structured_value('SystemConfig', '', {
		'linux_system_config_address': u64(voidptr(config)).str()
	})
}

fn linux_system_config_from_args(args []ruby.Value) (&LinuxSystemConfig, int) {
	if args.len > 0 && 'linux_system_config_address' in args[0].attributes {
		return unsafe { &LinuxSystemConfig(voidptr(args[0].attributes['linux_system_config_address'].u64())) }, 1
	}
	return new_linux_system_config(), 0
}

pub fn linux_system_config_boundary(config &LinuxSystemConfig) ruby.Value {
	return linux_system_config_value(config)
}

// Translated from Homebrew/brew `extend/os/linux/system_config.rb`.
