module homebrew

import strconv

// Translated from Homebrew/brew `system_config.rb`.
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

pub type SystemConfigCommandProbe = fn (SystemConfigCommand) !SystemConfigCommandResult

pub type SystemConfigSectionRenderer = fn (SystemConfigSection) !string

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
