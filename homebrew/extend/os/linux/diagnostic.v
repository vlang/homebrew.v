module linux

import ruby
import homebrew.diagnostic

pub enum LinuxSandboxState {
	available
	missing_fiddle
	unsupported
	disabled
}

pub struct LinuxDiagnosticFormula {
pub:
	name             string
	core_tap         bool
	dependencies     []string
	tap_load_error   bool
	prefix_exists    bool = true
	prefix_directory bool = true
	binary_rpaths    [][]string
}

@[heap]
pub struct LinuxDiagnosticContext {
pub mut:
	info                   [][]string
	events                 []string
	base_cask_check_called bool
pub:
	temp                         string = '/tmp'
	shell_profile                string = '~/.profile'
	base_tmpdir_sticky           ?diagnostic.Finding
	temp_executable              bool = true
	umask                        int = 0o022
	cpu_arch                     string = 'x86_64'
	glibc_below_minimum          bool
	glibc_below_ci               bool
	glibc_system_version         string = '2.39'
	glibc_minimum_version        string = '2.13'
	glibc_next_ci_version        string
	glibc_testing                bool
	ci                           bool
	test_bot                     bool
	kernel_below_minimum         bool
	kernel_version               string = '6.1'
	kernel_minimum_version       string = '3.2'
	sandbox_linux                bool = true
	inside_docker                bool
	github_actions               bool
	sandbox_state                LinuxSandboxState = .available
	sandbox_failure_reason       string
	no_install_from_api          bool
	linuxbrew_core               bool
	bottle_domain                string
	home_symlink                 bool
	formulae                     []LinuxDiagnosticFormula
	verbose                      bool = true
	linux_version                string = 'Unknown'
	developer_tools_installed    bool = true
	developer_tools_instructions string
}

pub fn new_linux_diagnostic_context() &LinuxDiagnosticContext {
	return &LinuxDiagnosticContext{}
}

fn linux_diagnostic_remediation(text string, commands []string) ?diagnostic.Remediation {
	return diagnostic.Remediation{
		text: text
		commands: commands.clone()
	}
}

fn linux_diagnostic_finding(text string, tier string, links []string, remediation string,
	commands []string) ?diagnostic.Finding {
	return diagnostic.Finding{
		text: text
		tier: if tier == '' { '1' } else { tier }
		links: links.clone()
		remediation: if remediation == '' && commands.len == 0 {
			none
		} else {
			linux_diagnostic_remediation(remediation, commands)
		}
	}
}

fn linux_diagnostic_version_parts(version string) []int {
	mut parts := []int{}
	for component in version.split('.') {
		mut digits := ''
		for character in component {
			if character < `0` || character > `9` {
				break
			}
			digits += character.ascii_str()
		}
		parts << if digits == '' { 0 } else { digits.int() }
	}
	return parts
}

fn linux_diagnostic_compare_versions(left string, right string) int {
	left_parts := linux_diagnostic_version_parts(left)
	right_parts := linux_diagnostic_version_parts(right)
	part_count := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. part_count {
		left_part := if index < left_parts.len { left_parts[index] } else { 0 }
		right_part := if index < right_parts.len { right_parts[index] } else { 0 }
		if left_part < right_part {
			return -1
		}
		if left_part > right_part {
			return 1
		}
	}
	return 0
}

pub fn linux_fatal_preinstall_checks() []string {
	return ['check_access_directories', 'check_linuxbrew_core', 'check_linuxbrew_bottle_domain']
}

pub fn linux_supported_configuration_checks() []string {
	return ['check_glibc_minimum_version', 'check_kernel_minimum_version',
		'check_supported_architecture']
}

pub fn linux_fatal_build_from_source_checks() []string {
	return ['check_for_installed_developer_tools']
}

pub fn linux_check_for_installed_developer_tools(context LinuxDiagnosticContext) ?diagnostic.Finding {
	if context.developer_tools_installed {
		return none
	}
	instructions := if context.developer_tools_instructions == '' {
		linux_development_tools_installation_instructions()
	} else {
		context.developer_tools_instructions
	}
	return linux_diagnostic_finding('No developer tools installed.\n', '1', []string{}, instructions, []string{})
}

pub fn linux_check_tmpdir_sticky_bit(context LinuxDiagnosticContext) ?diagnostic.Finding {
	base := context.base_tmpdir_sticky or { return none }
	base_remediation := base.remediation or { diagnostic.Remediation{} }
	extra := "If you don't have administrative privileges on this machine,\ncreate a directory and set the `\$HOMEBREW_TEMP` environment variable,\nfor example:\n  install -d -m 1755 ~/tmp\n  export HOMEBREW_TEMP=~/tmp\n"
	return diagnostic.Finding{
		text: base.text
		tier: base.tier
		affects: base.affects.clone()
		links: base.links.clone()
		remediation: diagnostic.Remediation{
			text: base_remediation.text + extra
			commands: base_remediation.commands.clone()
		}
	}
}

pub fn linux_check_tmpdir_executable(context LinuxDiagnosticContext) ?diagnostic.Finding {
	if context.temp_executable {
		return none
	}
	return linux_diagnostic_finding('The directory ${context.temp} does not permit executing\nprograms. It is likely mounted as "noexec".\n', '1', []string{}, "Please set `\$HOMEBREW_TEMP`\nin your ${context.shell_profile} to a different directory, for example:\n  export HOMEBREW_TEMP=~/tmp\n  echo 'export HOMEBREW_TEMP=~/tmp' >> ${context.shell_profile}\n", [
		'export HOMEBREW_TEMP=~/tmp',
		"echo 'export HOMEBREW_TEMP=~/tmp' >> ${context.shell_profile}",
	])
}

pub fn linux_check_umask_not_zero(context LinuxDiagnosticContext) ?diagnostic.Finding {
	if context.umask != 0 {
		return none
	}
	return linux_diagnostic_finding('umask is currently set to 000. Directories created by Homebrew cannot\nbe world-writable.\n', '1', []string{}, 'This issue can be resolved by adding "umask 002" to\nyour ${context.shell_profile}:\n', [
		"echo 'umask 002' >> ${context.shell_profile}",
	])
}

pub fn linux_check_supported_architecture(context LinuxDiagnosticContext) ?diagnostic.Finding {
	if context.cpu_arch.to_lower() in ['x86_64', 'amd64', 'arm64', 'aarch64'] {
		return none
	}
	return linux_diagnostic_finding('Your CPU architecture (${context.cpu_arch}) is not supported. We only support\nx86_64 or ARM64/AArch64 CPU architectures. You will be unable to use binary packages (bottles).\n', '2', []string{}, '', []string{})
}

fn linux_distribution_remediation() string {
	return "We recommend updating to a newer version via your distribution's\npackage manager, upgrading your distribution to the latest version,\nor changing distributions.\n"
}

pub fn linux_check_glibc_minimum_version(context LinuxDiagnosticContext) ?diagnostic.Finding {
	if !context.glibc_below_minimum {
		return none
	}
	return linux_diagnostic_finding('Your system glibc ${context.glibc_system_version} is too old.\nWe only support glibc ${context.glibc_minimum_version} or later.\n', 'unsupported', []string{}, linux_distribution_remediation(), []string{})
}

pub fn linux_check_glibc_version(context LinuxDiagnosticContext) ?diagnostic.Finding {
	if !context.glibc_below_ci || context.glibc_testing {
		return none
	}
	return linux_diagnostic_finding('Your system glibc ${context.glibc_system_version} is too old.\nWe will need to automatically install a newer version.\n', '2', []string{}, linux_distribution_remediation(), []string{})
}

pub fn linux_check_glibc_next_version(context LinuxDiagnosticContext) ?diagnostic.Finding {
	if context.glibc_next_ci_version.trim_space() == '' || context.glibc_below_ci || linux_diagnostic_compare_versions(context.glibc_system_version, context.glibc_next_ci_version) >= 0 {
		return none
	}
	// We want to bypass this check in some tests.
	if context.glibc_testing || context.ci || context.test_bot {
		return none
	}
	return linux_diagnostic_finding('Your system glibc ${context.glibc_system_version} is older than ${context.glibc_next_ci_version}.\nAn upcoming brew release will automatically install a newer version.\n', '1', []string{}, linux_distribution_remediation(), []string{})
}

pub fn linux_check_kernel_minimum_version(context LinuxDiagnosticContext) ?diagnostic.Finding {
	if !context.kernel_below_minimum {
		return none
	}
	return linux_diagnostic_finding('Your Linux kernel ${context.kernel_version} is too old.\nWe only support kernel ${context.kernel_minimum_version} or later.\nYou will be unable to use binary packages (bottles).\n', '3', []string{}, linux_distribution_remediation(), []string{})
}

pub fn linux_check_linux_sandbox(context LinuxDiagnosticContext) ?diagnostic.Finding {
	if !context.sandbox_linux {
		return none
	}
	if context.inside_docker && !context.github_actions {
		return none
	}
	if context.sandbox_state == .available {
		return none
	}
	fix := if context.sandbox_state == .missing_fiddle {
		'Run Homebrew with its vendored Ruby, which includes Fiddle.'
	} else {
		"Homebrew's Linux sandbox requires a kernel with Landlock enabled."
	}
	reason := if context.sandbox_failure_reason == '' {
		'The Linux sandbox is not available.'
	} else {
		context.sandbox_failure_reason
	}
	return linux_diagnostic_finding(reason, '1', []string{}, '${fix}\nAs a final workaround, disable the Linux sandbox:\n  export HOMEBREW_NO_SANDBOX_LINUX=1', []string{})
}

pub fn linux_check_linuxbrew_core(context LinuxDiagnosticContext) ?diagnostic.Finding {
	if !context.no_install_from_api || !context.linuxbrew_core {
		return none
	}
	return linux_diagnostic_finding("Your Linux core repository is still linuxbrew-core.\nYou must either unset `\$HOMEBREW_NO_INSTALL_FROM_API` or set\nthe repository's remote to homebrew-core to update core formulae.\n", '1', []string{}, "You can unset `\$HOMEBREW_NO_INSTALL_FROM_API` or set\nthe repository's remote to homebrew-core to update core formulae.\n", []string{})
}

pub fn linux_check_linuxbrew_bottle_domain(context LinuxDiagnosticContext) ?diagnostic.Finding {
	if !context.bottle_domain.contains('linuxbrew') {
		return none
	}
	return linux_diagnostic_finding('Your `\$HOMEBREW_BOTTLE_DOMAIN` still contains "linuxbrew".', '1', []string{}, 'You must unset `\$HOMEBREW_BOTTLE_DOMAIN` or adjust it to not contain "linuxbrew".', []string{})
}

pub fn linux_check_for_symlinked_home(context LinuxDiagnosticContext) ?diagnostic.Finding {
	if !context.home_symlink {
		return none
	}
	return linux_diagnostic_finding('Your /home directory is a symlink.\nThis is known to cause issues with formula linking, particularly when installing\nmultiple formulae that create symlinks in shared directories.\n\nWhile this may be a standard directory structure in some distributions\n(e.g. Fedora Silverblue) there are known issues as-is.\n', '2', [
		'https://github.com/Homebrew/brew/issues/18036',
	], "If you encounter linking issues, you may need to manually create conflicting\ndirectories or use `brew link --overwrite` as a workaround.\nWe'd welcome a PR to fix this functionality.\n", []string{})
}

fn linux_rpath_is_versioned_gcc(path string) bool {
	prefix := path.all_before_last('/')
	version := path.all_after_last('/')
	return prefix.ends_with('lib/gcc') && version != '' && version.bytes().all(it.is_digit())
}

fn linux_rpath_is_current_gcc(path string) bool {
	return path.ends_with('lib/gcc/current')
}

pub fn linux_badly_linked_gcc_dependents(formulae []LinuxDiagnosticFormula) []string {
	mut badly_linked := []string{}
	for formula in formulae {
		if formula.tap_load_error || !formula.core_tap || 'gcc' !in formula.dependencies || !formula.prefix_exists || !formula.prefix_directory {
			continue
		}
		for paths in formula.binary_rpaths {
			versioned := paths.any(linux_rpath_is_versioned_gcc(it))
			unversioned := paths.any(linux_rpath_is_current_gcc(it))
			if versioned && !unversioned {
				badly_linked << formula.name
				break
			}
		}
	}
	return badly_linked
}

pub fn linux_check_gcc_dependent_linkage(context LinuxDiagnosticContext) ?diagnostic.Finding {
	badly_linked := linux_badly_linked_gcc_dependents(context.formulae)
	if badly_linked.len == 0 {
		return none
	}
	return linux_diagnostic_finding('Formulae which link to GCC through a versioned path were found. These formulae\nare prone to breaking when GCC is updated.\n', '1', []string{}, '', [
		'brew reinstall ${badly_linked.join(' ')}',
	])
}

pub fn linux_check_cask_software_versions(mut context LinuxDiagnosticContext) {
	context.base_cask_check_called = true
	context.events << 'super.check_cask_software_versions'
	if context.verbose {
		context.info << ['Linux', context.linux_version]
	}
}

fn linux_diagnostic_context_value(context &LinuxDiagnosticContext) ruby.Value {
	return ruby.structured_value('OS::Linux::Diagnostic::Checks', '', {
		'linux_diagnostic_address': u64(voidptr(context)).str()
	})
}

fn linux_diagnostic_context_from_value(value ruby.Value) &LinuxDiagnosticContext {
	address := value.attributes['linux_diagnostic_address'] or {
		panic('invalid OS::Linux::Diagnostic::Checks receiver')
	}
	return unsafe { &LinuxDiagnosticContext(voidptr(address.u64())) }
}

pub fn linux_diagnostic_boundary(context &LinuxDiagnosticContext) ruby.Value {
	return linux_diagnostic_context_value(context)
}

fn linux_diagnostic_finding_value(result ?diagnostic.Finding) ruby.Value {
	value := result or { return ruby.object_value('NilClass', 'nil') }
	mut attributes := {
		'text':  value.text
		'tier':  value.tier
		'links': value.links.join('\n')
	}
	if remediation := value.remediation {
		attributes['remediation_text'] = remediation.text
		attributes['remediation_commands'] = remediation.commands.join('\n')
	}
	return ruby.structured_value('Homebrew::Diagnostic::Finding', value.string(), attributes)
}

// Translated from Homebrew/brew `extend/os/linux/diagnostic.rb`.
