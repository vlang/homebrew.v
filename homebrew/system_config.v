module homebrew

import strconv

// Translated from Homebrew/brew `system_config.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum SystemConfigPlatform {
	other
	linux
	macos
}

pub enum SystemConfigSection {
	homebrew_config
	core_tap_config
	homebrew_env_config
	hardware_config
	host_software_config
	linux_config
	macos_config
}

pub enum SystemConfigTapKind {
	core
	core_cask
	unknown
}

pub enum SystemConfigBooleanMode {
	none
	falsy_values
	set
}

pub struct SystemConfigCommand {
pub:
	executable string
	arguments  []string
}

pub struct SystemConfigCommandResult {
pub:
	stdout  string
	stderr  string
	success bool = true
}

pub type SystemConfigCommandProbe = fn(SystemConfigCommand) !SystemConfigCommandResult

pub type SystemConfigSectionRenderer = fn(SystemConfigSection) !string

struct SystemConfigRenderedSection {
	index         int
	output        string
	error_message string
}

pub struct SystemConfigGitHead {
pub:
	head        ?string
	last_commit ?string
	branch      ?string
}

pub struct SystemConfigRepository {
pub:
	path   string
	origin ?string
	head   SystemConfigGitHead
}

pub struct SystemConfigTool {
pub:
	available  bool
	version    string
	path       string
	executable string
}

pub struct SystemConfigHardware {
pub:
	known          bool
	cores_as_words string
	bits           int
	family         string
}

pub struct SystemConfigTap {
pub:
	kind              SystemConfigTapKind
	installed         bool
	remote            string
	default_remote    string
	head              SystemConfigGitHead
	json_modified_utc ?string
}

pub struct SystemConfigEnvVariable {
pub:
	name          string
	value         ?string
	default_value ?string
	boolean_mode  SystemConfigBooleanMode
	default_bool  bool
	sensitive     bool
	directly_set  bool
}

pub struct SystemConfigLinkedFormula {
pub:
	name    string
	version string
}

pub struct SystemConfigHost {
pub:
	platform               SystemConfigPlatform
	os_version             string
	wsl                    bool
	wsl_version            string
	windows_cmd            string
	windows_cmd_executable bool
	landlock_abi           ?int
	host_glibc             string
	host_libstdcxx         string
	host_gcc_path          string
	host_gcc_version       string
	host_ruby_version      string
	linked_formulae        []SystemConfigLinkedFormula
	macos_output           string
}

pub struct SystemConfigContext {
pub:
	homebrew_version            string
	homebrew_prefix             string
	homebrew_repository         string
	default_repository          string
	homebrew_cellar             string
	default_cellar              string
	ruby_version                string
	ruby_path                   string
	development_tools_installed bool
	clang_version               ?string
	clang_build_version         ?string
	repository                  SystemConfigRepository
	hardware                    SystemConfigHardware
	git                         SystemConfigTool
	curl                        SystemConfigTool
	core_tap                    SystemConfigTap
	core_cask_tap               SystemConfigTap
	environment                 []SystemConfigEnvVariable
	host                        SystemConfigHost
}

@[heap]
pub struct SystemConfigState {
pub:
	context SystemConfigContext
}

pub fn new_system_config(context SystemConfigContext) &SystemConfigState {
	return &SystemConfigState{
		context: context
	}
}

fn output_lines(lines []string) string {
	if lines.len == 0 {
		return ''
	}
	return lines.join('\n') + '\n'
}

fn optional_or(value ?string, fallback string) string {
	return value or { fallback }
}

pub fn system_config_clang(state &SystemConfigState) ?string {
	if !state.context.development_tools_installed {
		return none
	}
	return state.context.clang_version
}

pub fn system_config_clang_build(state &SystemConfigState) ?string {
	if !state.context.development_tools_installed {
		return none
	}
	return state.context.clang_build_version
}

pub fn system_config_describe_clang(state &SystemConfigState) string {
	clang := system_config_clang(state) or { return 'N/A' }
	if build := system_config_clang_build(state) {
		return '${clang} build ${build}'
	}
	return clang
}

pub fn system_config_hardware(state &SystemConfigState) ?string {
	hardware := state.context.hardware
	if !hardware.known {
		return none
	}
	return 'CPU: ${hardware.cores_as_words}-core ${hardware.bits}-bit ${hardware.family}'
}

pub fn system_config_describe_git(state &SystemConfigState) string {
	if !state.context.git.available {
		return 'N/A'
	}
	return '${state.context.git.version} => ${state.context.git.path}'
}

fn curl_version_from_output(output string) ?string {
	lines := output.split_into_lines()
	if lines.len == 0 {
		return none
	}
	first_line := lines[0]
	if !first_line.starts_with('curl ') {
		return none
	}
	mut version_end := 'curl '.len
	for version_end < first_line.len && (first_line[version_end].is_digit() || first_line[version_end] == `.`) {
		version_end++
	}
	version := first_line['curl '.len..version_end]
	if version == '' || !version[0].is_digit() {
		return none
	}
	return version
}

pub fn system_config_describe_curl(state &SystemConfigState,
	probe SystemConfigCommandProbe) !string {
	result := probe(SystemConfigCommand{
		executable: state.context.curl.executable
		arguments: ['--version']
	})!
	version := curl_version_from_output(result.stdout) or { return 'N/A' }
	return '${version} => ${state.context.curl.path}'
}

pub fn parse_windows_registry_values(output string) map[string]string {
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

pub fn windows_registry_version(values map[string]string) ?string {
	mut product_name := (values['ProductName'] or { return none }).trim_space()
	mut build := (values['CurrentBuildNumber'] or { return none }).trim_space()
	if product_name == '' || build == '' {
		return none
	}
	if build.int() >= 22_000 && (product_name == 'Windows 10' || (product_name.starts_with('Windows 10') && product_name.len > 'Windows 10'.len && !product_name['Windows 10'.len].is_alnum() && product_name['Windows 10'.len] != `_`)) {
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

fn windows_ver_fallback(output string) string {
	for raw_line in output.replace('\r', '').split_into_lines() {
		line := raw_line.trim_space()
		if line.starts_with('Microsoft Windows') {
			return line
		}
	}
	return ''
}

pub fn system_config_windows_version(state &SystemConfigState,
	probe SystemConfigCommandProbe) !string {
	host := state.context.host
	if !host.wsl || !host.windows_cmd_executable || host.windows_cmd == '' {
		return ''
	}
	registry := probe(SystemConfigCommand{
		executable: host.windows_cmd
		arguments: ['/d', '/c', 'reg', 'query', 'HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion']
	}) or { SystemConfigCommandResult{} }
	if registry_version := windows_registry_version(parse_windows_registry_values(registry.stdout)) {
		return registry_version
	}
	version := probe(SystemConfigCommand{
		executable: host.windows_cmd
		arguments: ['/d', '/c', 'ver']
	}) or { return '' }
	return windows_ver_fallback(version.stdout)
}

fn system_config_tap_name(kind SystemConfigTapKind) !(string, string) {
	return match kind {
		.core { 'Core tap', 'formula.jws.json' }
		.core_cask { 'Core cask tap', 'cask.jws.json' }
		.unknown {
			return error('Unknown tap')
		}
	}
}

pub fn system_config_dump_tap(tap SystemConfigTap) !string {
	tap_name, _ := system_config_tap_name(tap.kind)!
	mut lines := []string{}
	if tap.installed {
		if tap.remote != tap.default_remote {
			lines << '${tap_name} origin: ${tap.remote}'
		}
		lines << '${tap_name} HEAD: ${optional_or(tap.head.head, '(none)')}'
		lines << '${tap_name} last commit: ${optional_or(tap.head.last_commit, 'never')}'
		branch := optional_or(tap.head.branch, '(none)')
		if branch !in ['main', 'master'] {
			lines << '${tap_name} branch: ${branch}'
		}
	}
	if modified := tap.json_modified_utc {
		lines << '${tap_name} JSON: ${modified}'
	} else if !tap.installed {
		lines << '${tap_name}: N/A'
	}
	return output_lines(lines)
}

pub fn system_config_core_taps(state &SystemConfigState) !string {
	return system_config_dump_tap(state.context.core_tap)! + system_config_dump_tap(state.context.core_cask_tap)!
}

pub fn system_config_homebrew(state &SystemConfigState) string {
	return output_lines([
		'HOMEBREW_VERSION: ${state.context.homebrew_version}',
		'ORIGIN: ${optional_or(state.context.repository.origin, '(none)')}',
		'HEAD: ${optional_or(state.context.repository.head.head, '(none)')}',
		'Last commit: ${optional_or(state.context.repository.head.last_commit, 'never')}',
		'Branch: ${optional_or(state.context.repository.head.branch, '(none)')}',
	])
}

fn falsy_system_config_value(value string) bool {
	return value.to_lower() in ['false', 'no', 'off', 'nil', '0']
}

pub fn system_config_non_default_environment(variables []SystemConfigEnvVariable) []SystemConfigEnvVariable {
	mut filtered := []SystemConfigEnvVariable{}
	for variable in variables {
		value := variable.value or { continue }
		if value.trim_space() == '' || !variable.directly_set {
			continue
		}
		if variable.boolean_mode != .none {
			enabled := variable.boolean_mode == .set || !falsy_system_config_value(value)
			if enabled == variable.default_bool {
				continue
			}
		} else if value == (variable.default_value or { '' }) {
			continue
		}
		filtered << variable
	}
	filtered.sort_with_compare(fn (left &SystemConfigEnvVariable, right &SystemConfigEnvVariable) int {
		return left.name.compare(right.name)
	})
	return filtered
}

pub fn system_config_homebrew_environment(state &SystemConfigState) string {
	mut lines := ['HOMEBREW_PREFIX: ${state.context.homebrew_prefix}']
	if state.context.homebrew_repository != state.context.default_repository {
		lines << 'HOMEBREW_REPOSITORY: ${state.context.homebrew_repository}'
	}
	if state.context.homebrew_cellar != state.context.default_cellar {
		lines << 'HOMEBREW_CELLAR: ${state.context.homebrew_cellar}'
	}
	for variable in system_config_non_default_environment(state.context.environment) {
		value := variable.value or { continue }
		if variable.boolean_mode != .none {
			enabled := variable.boolean_mode == .set || !falsy_system_config_value(value)
			lines << '${variable.name}: ${if enabled { 'set' } else { 'false' }}'
		} else if variable.sensitive {
			lines << '${variable.name}: set'
		} else {
			lines << '${variable.name}: ${value}'
		}
	}
	lines << 'Homebrew Ruby: ${state.context.ruby_version} => ${state.context.ruby_path}'
	return output_lines(lines)
}

pub fn system_config_host_software(state &SystemConfigState,
	probe SystemConfigCommandProbe) !string {
	return output_lines([
		'Clang: ${system_config_describe_clang(state)}',
		'Git: ${system_config_describe_git(state)}',
		'Curl: ${system_config_describe_curl(state, probe)!}',
	])
}

pub fn system_config_hardware_output(state &SystemConfigState) string {
	if hardware := system_config_hardware(state) {
		return '${hardware}\n'
	}
	return ''
}

pub fn system_config_linux(state &SystemConfigState,
	probe SystemConfigCommandProbe) !string {
	kernel_result := probe(SystemConfigCommand{
		executable: 'uname'
		arguments: ['-mors']
	}) or { SystemConfigCommandResult{} }
	host := state.context.host
	mut lines := [
		'Kernel: ${kernel_result.stdout.trim_space()}',
		'Landlock ABI: ${if abi := host.landlock_abi { abi.str() } else { 'N/A' }}',
		'OS: ${host.os_version}',
	]
	if host.wsl {
		lines << 'WSL: ${host.wsl_version}'
		windows := system_config_windows_version(state, probe)!
		if windows != '' {
			lines << 'Windows: ${windows}'
		}
	}
	lines << 'Host glibc: ${if host.host_glibc == '' { 'N/A' } else { host.host_glibc }}'
	lines << 'Host libstdc++: ${if host.host_libstdcxx == '' { 'N/A' } else { host.host_libstdcxx }}'
	lines << '${host.host_gcc_path}: ${if host.host_gcc_version == '' {
		'N/A'
	} else {
		host.host_gcc_version
	}}'
	if state.context.ruby_path != '/usr/bin/ruby' {
		lines << '/usr/bin/ruby: ${if host.host_ruby_version == '' {
			'N/A'
		} else {
			host.host_ruby_version
		}}'
	}
	for formula in host.linked_formulae {
		lines << '${formula.name}: ${if formula.version == '' { 'N/A' } else { formula.version }}'
	}
	return output_lines(lines)
}

pub fn system_config_sections(state &SystemConfigState) []SystemConfigSection {
	mut sections := [
		SystemConfigSection.homebrew_config,
		.core_tap_config,
		.homebrew_env_config,
		.hardware_config,
		.host_software_config,
	]
	match state.context.host.platform {
		.linux { sections << .linux_config }
		.macos { sections << .macos_config }
		.other {}
	}
	return sections
}

pub fn render_system_config_sections_ordered(sections []SystemConfigSection,
	render SystemConfigSectionRenderer) !string {
	if sections.len == 0 {
		return ''
	}
	results := chan SystemConfigRenderedSection{ cap: sections.len }
	for index, section in sections {
		spawn render_system_config_section(index, section, render, results)
	}
	return collect_system_config_sections(sections.len, results)
}

fn render_system_config_section(index int, section SystemConfigSection,
	render SystemConfigSectionRenderer, results chan SystemConfigRenderedSection) {
	output := render(section) or {
		results <- SystemConfigRenderedSection{
			index: index
			error_message: err.msg()
		}
		return
	}
	results <- SystemConfigRenderedSection{
		index: index
		output: output
	}
}

fn collect_system_config_sections(count int, results chan SystemConfigRenderedSection) !string {
	mut ordered := []string{len: count}
	mut errors := []string{len: count}
	for _ in 0 .. count {
		result := <-results
		ordered[result.index] = result.output
		errors[result.index] = result.error_message
	}
	for message in errors {
		if message != '' {
			return error(message)
		}
	}
	return ordered.join('')
}

fn render_system_config_state_section(index int, section SystemConfigSection,
	state &SystemConfigState, probe SystemConfigCommandProbe,
	results chan SystemConfigRenderedSection) {
	output := match section {
		.homebrew_config { system_config_homebrew(state) }
		.core_tap_config {
			system_config_core_taps(state) or {
				results <- SystemConfigRenderedSection{
					index: index
					error_message: err.msg()
				}
				return
			}
		}
		.homebrew_env_config { system_config_homebrew_environment(state) }
		.hardware_config { system_config_hardware_output(state) }
		.host_software_config {
			system_config_host_software(state, probe) or {
				results <- SystemConfigRenderedSection{
					index: index
					error_message: err.msg()
				}
				return
			}
		}
		.linux_config {
			system_config_linux(state, probe) or {
				results <- SystemConfigRenderedSection{
					index: index
					error_message: err.msg()
				}
				return
			}
		}
		.macos_config { state.context.host.macos_output }
	}
	results <- SystemConfigRenderedSection{
		index: index
		output: output
	}
}

pub fn system_config_dump_verbose(state &SystemConfigState,
	probe SystemConfigCommandProbe) !string {
	sections := system_config_sections(state)
	if sections.len == 0 {
		return ''
	}
	results := chan SystemConfigRenderedSection{ cap: sections.len }
	for index, section in sections {
		spawn render_system_config_state_section(index, section, state, probe, results)
	}
	return collect_system_config_sections(sections.len, results)
}

// Ruby method `initialize` at line 17.
pub fn ruby_system_config_l17_d1_initialize(context SystemConfigContext) &SystemConfigState {
	return new_system_config(context)
}

// Ruby method `clang` at line 23.
pub fn ruby_system_config_l23_d2_clang(state &SystemConfigState) ?string {
	return system_config_clang(state)
}

// Ruby method `clang_build` at line 32.
pub fn ruby_system_config_l32_d3_clang_build(state &SystemConfigState) ?string {
	return system_config_clang_build(state)
}

// Ruby method `homebrew_repo` at line 41.
pub fn ruby_system_config_l41_d4_homebrew_repo(state &SystemConfigState) SystemConfigRepository {
	return state.context.repository
}

// Ruby method `homebrew_head_info` at line 46.
pub fn ruby_system_config_l46_d5_homebrew_head_info(state &SystemConfigState) SystemConfigGitHead {
	return state.context.repository.head
}

// Ruby method `branch` at line 54.
pub fn ruby_system_config_l54_d6_branch(state &SystemConfigState) string {
	return optional_or(state.context.repository.head.branch, '(none)')
}

// Ruby method `head` at line 59.
pub fn ruby_system_config_l59_d7_head(state &SystemConfigState) string {
	return optional_or(state.context.repository.head.head, '(none)')
}

// Ruby method `last_commit` at line 64.
pub fn ruby_system_config_l64_d8_last_commit(state &SystemConfigState) string {
	return optional_or(state.context.repository.head.last_commit, 'never')
}

// Ruby method `origin` at line 69.
pub fn ruby_system_config_l69_d9_origin(state &SystemConfigState) string {
	return optional_or(state.context.repository.origin, '(none)')
}

// Ruby method `describe_clang` at line 74.
pub fn ruby_system_config_l74_d10_describe_clang(state &SystemConfigState) string {
	return system_config_describe_clang(state)
}

// Ruby method `describe_homebrew_ruby` at line 85.
pub fn ruby_system_config_l85_d11_describe_homebrew_ruby(state &SystemConfigState) string {
	return '${state.context.ruby_version} => ${state.context.ruby_path}'
}

// Ruby method `hardware` at line 90.
pub fn ruby_system_config_l90_d12_hardware(state &SystemConfigState) ?string {
	return system_config_hardware(state)
}

// Ruby method `kernel` at line 97.
pub fn ruby_system_config_l97_d13_kernel(probe SystemConfigCommandProbe) !string {
	return (probe(SystemConfigCommand{
		executable: 'uname'
		arguments: ['-m']
	})!).stdout.trim_space()
}

// Ruby method `windows_version; end` at line 102.
pub fn ruby_system_config_l102_d14_windows_version(state &SystemConfigState,
	probe SystemConfigCommandProbe) !string {
	return system_config_windows_version(state, probe)
}

// Ruby method `describe_git` at line 105.
pub fn ruby_system_config_l105_d15_describe_git(state &SystemConfigState) string {
	return system_config_describe_git(state)
}

// Ruby method `describe_curl` at line 112.
pub fn ruby_system_config_l112_d16_describe_curl(state &SystemConfigState,
	probe SystemConfigCommandProbe) !string {
	return system_config_describe_curl(state, probe)
}

// Ruby method `dump_tap_config(tap, out = $stdout)` at line 124.
pub fn ruby_system_config_l124_d17_dump_tap_config(tap SystemConfigTap) !string {
	return system_config_dump_tap(tap)
}

// Ruby method `core_tap_config(out = $stdout)` at line 154.
pub fn ruby_system_config_l154_d18_core_tap_config(state &SystemConfigState) !string {
	return system_config_core_taps(state)
}

// Ruby method `homebrew_config(out = $stdout)` at line 160.
pub fn ruby_system_config_l160_d19_homebrew_config(state &SystemConfigState) string {
	return system_config_homebrew(state)
}

// Ruby method `homebrew_env_config(out = $stdout)` at line 169.
pub fn ruby_system_config_l169_d20_homebrew_env_config(state &SystemConfigState) string {
	return system_config_homebrew_environment(state)
}

// Ruby method `host_software_config(out = $stdout)` at line 198.
pub fn ruby_system_config_l198_d21_host_software_config(state &SystemConfigState,
	probe SystemConfigCommandProbe) !string {
	return system_config_host_software(state, probe)
}

// Ruby method `hardware_config(out = $stdout)` at line 205.
pub fn ruby_system_config_l205_d22_hardware_config(state &SystemConfigState) string {
	return system_config_hardware_output(state)
}

// Ruby method `config_sections` at line 211.
pub fn ruby_system_config_l211_d23_config_sections(state &SystemConfigState) []SystemConfigSection {
	return system_config_sections(state)
}

// Ruby method `dump_verbose_config(out = $stdout)` at line 216.
pub fn ruby_system_config_l216_d24_dump_verbose_config(state &SystemConfigState,
	probe SystemConfigCommandProbe) !string {
	return system_config_dump_verbose(state, probe)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "hardware"
// 5: require "tap"
// 6: require "development_tools"
// 7: require "extend/ENV"
// 8: require "system_command"
// 9: require "git_repository"
// 10:
// 11: # Helper module for querying information about the system configuration.
// 12: module SystemConfig
// 13:   class << self
// 14:     include SystemCommand::Mixin
// 15:
// 16:     sig { void }
// 17:     def initialize
// 18:       @clang = T.let(nil, T.nilable(Version))
// 19:       @clang_build = T.let(nil, T.nilable(Version))
// 20:     end
// 21:
// 22:     sig { returns(Version) }
// 23:     def clang
// 24:       @clang ||= if DevelopmentTools.installed?
// 25:         DevelopmentTools.clang_version
// 26:       else
// 27:         Version::NULL
// 28:       end
// 29:     end
// 30:
// 31:     sig { returns(Version) }
// 32:     def clang_build
// 33:       @clang_build ||= if DevelopmentTools.installed?
// 34:         DevelopmentTools.clang_build_version
// 35:       else
// 36:         Version::NULL
// 37:       end
// 38:     end
// 39:
// 40:     sig { returns(GitRepository) }
// 41:     def homebrew_repo
// 42:       GitRepository.new(HOMEBREW_REPOSITORY)
// 43:     end
// 44:
// 45:     sig { returns([T.nilable(String), T.nilable(String), T.nilable(String)]) }
// 46:     def homebrew_head_info
// 47:       @homebrew_head_info ||= T.let(
// 48:         homebrew_repo.head_info,
// 49:         T.nilable([T.nilable(String), T.nilable(String), T.nilable(String)]),
// 50:       )
// 51:     end
// 52:
// 53:     sig { returns(String) }
// 54:     def branch
// 55:       homebrew_head_info[2] || "(none)"
// 56:     end
// 57:
// 58:     sig { returns(String) }
// 59:     def head
// 60:       homebrew_head_info[0] || "(none)"
// 61:     end
// 62:
// 63:     sig { returns(String) }
// 64:     def last_commit
// 65:       homebrew_head_info[1] || "never"
// 66:     end
// 67:
// 68:     sig { returns(String) }
// 69:     def origin
// 70:       homebrew_repo.origin_url || "(none)"
// 71:     end
// 72:
// 73:     sig { returns(String) }
// 74:     def describe_clang
// 75:       return "N/A" if clang.null?
// 76:
// 77:       if clang_build.null?
// 78:         clang.to_s
// 79:       else
// 80:         "#{clang} build #{clang_build}"
// 81:       end
// 82:     end
// 83:
// 84:     sig { returns(String) }
// 85:     def describe_homebrew_ruby
// 86:       "#{RUBY_VERSION} => #{RUBY_PATH}"
// 87:     end
// 88:
// 89:     sig { returns(T.nilable(String)) }
// 90:     def hardware
// 91:       return if Hardware::CPU.type == :dunno
// 92:
// 93:       "CPU: #{Hardware.cores_as_words}-core #{Hardware::CPU.bits}-bit #{Hardware::CPU.family}"
// 94:     end
// 95:
// 96:     sig { returns(String) }
// 97:     def kernel
// 98:       `uname -m`.chomp
// 99:     end
// 100:
// 101:     sig { returns(T.nilable(String)) }
// 102:     def windows_version; end
// 103:
// 104:     sig { returns(String) }
// 105:     def describe_git
// 106:       return "N/A" unless Utils::Git.available?
// 107:
// 108:       "#{Utils::Git.version} => #{Utils::Git.path}"
// 109:     end
// 110:
// 111:     sig { returns(String) }
// 112:     def describe_curl
// 113:       out = system_command(Utils::Curl.curl_executable, args: ["--version"], verbose: false).stdout
// 114:
// 115:       match_data = /^curl (?<curl_version>[\d.]+)/.match(out)
// 116:       if match_data
// 117:         "#{match_data[:curl_version]} => #{Utils::Curl.curl_path}"
// 118:       else
// 119:         "N/A"
// 120:       end
// 121:     end
// 122:
// 123:     sig { params(tap: Tap, out: T.any(File, StringIO, IO)).void }
// 124:     def dump_tap_config(tap, out = $stdout)
// 125:       case tap
// 126:       when CoreTap
// 127:         tap_name = "Core tap"
// 128:         json_file_name = "formula.jws.json"
// 129:       when CoreCaskTap
// 130:         tap_name = "Core cask tap"
// 131:         json_file_name = "cask.jws.json"
// 132:       else
// 133:         raise ArgumentError, "Unknown tap: #{tap}"
// 134:       end
// 135:
// 136:       if tap.installed?
// 137:         out.puts "#{tap_name} origin: #{tap.remote}" if tap.remote != tap.default_remote
// 138:         head, last_commit, branch = tap.git_repository.head_info
// 139:         out.puts "#{tap_name} HEAD: #{head || "(none)"}"
// 140:         out.puts "#{tap_name} last commit: #{last_commit || "never"}"
// 141:         default_branches = %w[main master].freeze
// 142:         out.puts "#{tap_name} branch: #{branch || "(none)"}" if default_branches.exclude?(branch)
// 143:       end
// 144:
// 145:       json_file = Homebrew::API::HOMEBREW_CACHE_API/json_file_name
// 146:       if json_file.exist?
// 147:         out.puts "#{tap_name} JSON: #{json_file.mtime.utc.strftime("%d %b %H:%M UTC")}"
// 148:       elsif !tap.installed?
// 149:         out.puts "#{tap_name}: N/A"
// 150:       end
// 151:     end
// 152:
// 153:     sig { params(out: T.any(File, StringIO, IO)).void }
// 154:     def core_tap_config(out = $stdout)
// 155:       dump_tap_config(CoreTap.instance, out)
// 156:       dump_tap_config(CoreCaskTap.instance, out)
// 157:     end
// 158:
// 159:     sig { params(out: T.any(File, StringIO, IO)).void }
// 160:     def homebrew_config(out = $stdout)
// 161:       out.puts "HOMEBREW_VERSION: #{HOMEBREW_VERSION}"
// 162:       out.puts "ORIGIN: #{origin}"
// 163:       out.puts "HEAD: #{head}"
// 164:       out.puts "Last commit: #{last_commit}"
// 165:       out.puts "Branch: #{branch}"
// 166:     end
// 167:
// 168:     sig { params(out: T.any(File, StringIO, IO)).void }
// 169:     def homebrew_env_config(out = $stdout)
// 170:       out.puts "HOMEBREW_PREFIX: #{HOMEBREW_PREFIX}"
// 171:       repository = HOMEBREW_REPOSITORY
// 172:       cellar = HOMEBREW_CELLAR
// 173:       out.puts "HOMEBREW_REPOSITORY: #{repository}" if repository.to_s != Homebrew::DEFAULT_REPOSITORY.to_s
// 174:       out.puts "HOMEBREW_CELLAR: #{cellar}" if cellar.to_s != Homebrew::DEFAULT_CELLAR.to_s
// 175:
// 176:       Homebrew::EnvConfig.non_default_variables.each do |env|
// 177:         env_symbol = env.to_sym
// 178:         hash = Homebrew::EnvConfig::ENVS.fetch(env_symbol)
// 179:         value = Homebrew::EnvConfig.public_send(Homebrew::EnvConfig.env_method_name(env_symbol, hash))
// 180:
// 181:         if hash[:boolean]
// 182:           out.puts "#{env}: #{value ? "set" : "false"}"
// 183:           next
// 184:         end
// 185:
// 186:         next unless value
// 187:
// 188:         if ENV.sensitive?(env)
// 189:           out.puts "#{env}: set"
// 190:         else
// 191:           out.puts "#{env}: #{value}"
// 192:         end
// 193:       end
// 194:       out.puts "Homebrew Ruby: #{describe_homebrew_ruby}"
// 195:     end
// 196:
// 197:     sig { params(out: T.any(File, StringIO, IO)).void }
// 198:     def host_software_config(out = $stdout)
// 199:       out.puts "Clang: #{describe_clang}"
// 200:       out.puts "Git: #{describe_git}"
// 201:       out.puts "Curl: #{describe_curl}"
// 202:     end
// 203:
// 204:     sig { params(out: T.any(File, StringIO, IO)).void }
// 205:     def hardware_config(out = $stdout)
// 206:       hardware = self.hardware
// 207:       out.puts hardware if hardware
// 208:     end
// 209:
// 210:     sig { returns(T::Array[Symbol]) }
// 211:     def config_sections
// 212:       [:homebrew_config, :core_tap_config, :homebrew_env_config, :hardware_config, :host_software_config]
// 213:     end
// 214:
// 215:     sig { params(out: T.any(File, StringIO, IO)).void }
// 216:     def dump_verbose_config(out = $stdout)
// 217:       # Most sections shell out for their values (Git, compilers, curl,
// 218:       # etc.), so render them concurrently and print them in order.
// 219:       sections = Utils.parallel_map(config_sections) do |section|
// 220:         io = StringIO.new
// 221:         public_send(section, io)
// 222:         io.string
// 223:       end
// 224:       sections.each { |section| out.print section }
// 225:     end
// 226:   end
// 227: end
// 228:
// 229: require "extend/os/system_config"
