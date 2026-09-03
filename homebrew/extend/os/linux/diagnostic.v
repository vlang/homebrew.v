module linux

import brew_runtime
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

fn linux_diagnostic_context_value(context &LinuxDiagnosticContext) brew_runtime.Value {
	return brew_runtime.structured_value('OS::Linux::Diagnostic::Checks', '', {
		'linux_diagnostic_address': u64(voidptr(context)).str()
	})
}

fn linux_diagnostic_context_from_value(value brew_runtime.Value) &LinuxDiagnosticContext {
	address := value.attributes['linux_diagnostic_address'] or {
		panic('invalid OS::Linux::Diagnostic::Checks receiver')
	}
	return unsafe { &LinuxDiagnosticContext(voidptr(address.u64())) }
}

pub fn linux_diagnostic_boundary(context &LinuxDiagnosticContext) brew_runtime.Value {
	return linux_diagnostic_context_value(context)
}

fn linux_diagnostic_finding_value(result ?diagnostic.Finding) brew_runtime.Value {
	value := result or { return brew_runtime.object_value('NilClass', 'nil') }
	mut attributes := {
		'text':  value.text
		'tier':  value.tier
		'links': value.links.join('\n')
	}
	if remediation := value.remediation {
		attributes['remediation_text'] = remediation.text
		attributes['remediation_commands'] = remediation.commands.join('\n')
	}
	return brew_runtime.structured_value('Homebrew::Diagnostic::Finding', value.string(), attributes)
}

// Translated from Homebrew/brew `extend/os/linux/diagnostic.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `fatal_preinstall_checks` at line 22.
pub fn ruby_diagnostic_l22_d1_fatal_preinstall_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(linux_fatal_preinstall_checks())
}

// Ruby method `supported_configuration_checks` at line 31.
pub fn ruby_diagnostic_l31_d2_supported_configuration_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(linux_supported_configuration_checks())
}

// Ruby method `check_tmpdir_sticky_bit` at line 40.
pub fn ruby_diagnostic_l40_d3_check_tmpdir_sticky_bit(args ...brew_runtime.Value) brew_runtime.Value {
	return linux_diagnostic_finding_value(linux_check_tmpdir_sticky_bit(*linux_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_tmpdir_executable` at line 56.
pub fn ruby_diagnostic_l56_d4_check_tmpdir_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return linux_diagnostic_finding_value(linux_check_tmpdir_executable(*linux_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_umask_not_zero` at line 83.
pub fn ruby_diagnostic_l83_d5_check_umask_not_zero(args ...brew_runtime.Value) brew_runtime.Value {
	return linux_diagnostic_finding_value(linux_check_umask_not_zero(*linux_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_supported_architecture` at line 102.
pub fn ruby_diagnostic_l102_d6_check_supported_architecture(args ...brew_runtime.Value) brew_runtime.Value {
	return linux_diagnostic_finding_value(linux_check_supported_architecture(*linux_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_glibc_minimum_version` at line 116.
pub fn ruby_diagnostic_l116_d7_check_glibc_minimum_version(args ...brew_runtime.Value) brew_runtime.Value {
	return linux_diagnostic_finding_value(linux_check_glibc_minimum_version(*linux_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_glibc_version` at line 134.
pub fn ruby_diagnostic_l134_d8_check_glibc_version(args ...brew_runtime.Value) brew_runtime.Value {
	return linux_diagnostic_finding_value(linux_check_glibc_version(*linux_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_glibc_next_version` at line 155.
pub fn ruby_diagnostic_l155_d9_check_glibc_next_version(args ...brew_runtime.Value) brew_runtime.Value {
	return linux_diagnostic_finding_value(linux_check_glibc_next_version(*linux_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_kernel_minimum_version` at line 177.
pub fn ruby_diagnostic_l177_d10_check_kernel_minimum_version(args ...brew_runtime.Value) brew_runtime.Value {
	return linux_diagnostic_finding_value(linux_check_kernel_minimum_version(*linux_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_linux_sandbox` at line 196.
pub fn ruby_diagnostic_l196_d11_check_linux_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	return linux_diagnostic_finding_value(linux_check_linux_sandbox(*linux_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_linuxbrew_core` at line 221.
pub fn ruby_diagnostic_l221_d12_check_linuxbrew_core(args ...brew_runtime.Value) brew_runtime.Value {
	return linux_diagnostic_finding_value(linux_check_linuxbrew_core(*linux_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_linuxbrew_bottle_domain` at line 239.
pub fn ruby_diagnostic_l239_d13_check_linuxbrew_bottle_domain(args ...brew_runtime.Value) brew_runtime.Value {
	return linux_diagnostic_finding_value(linux_check_linuxbrew_bottle_domain(*linux_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_for_symlinked_home` at line 249.
pub fn ruby_diagnostic_l249_d14_check_for_symlinked_home(args ...brew_runtime.Value) brew_runtime.Value {
	return linux_diagnostic_finding_value(linux_check_for_symlinked_home(*linux_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_gcc_dependent_linkage` at line 272.
pub fn ruby_diagnostic_l272_d15_check_gcc_dependent_linkage(args ...brew_runtime.Value) brew_runtime.Value {
	return linux_diagnostic_finding_value(linux_check_gcc_dependent_linkage(*linux_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_cask_software_versions` at line 316.
pub fn ruby_diagnostic_l316_d16_check_cask_software_versions(args ...brew_runtime.Value) brew_runtime.Value {
	mut context := linux_diagnostic_context_from_value(args[0])
	linux_check_cask_software_versions(mut context)
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "tempfile"
// 5: require "utils/shell"
// 6: require "hardware"
// 7: require "os/linux"
// 8: require "os/linux/glibc"
// 9: require "os/linux/kernel"
// 10: require "sandbox"
// 11:
// 12: module OS
// 13:   module Linux
// 14:     module Diagnostic
// 15:       # Linux-specific diagnostic checks for Homebrew.
// 16:       module Checks
// 17:         extend T::Helpers
// 18:
// 19:         requires_ancestor { Homebrew::Diagnostic::Checks }
// 20:
// 21:         sig { returns(T::Array[String]) }
// 22:         def fatal_preinstall_checks
// 23:           %w[
// 24:             check_access_directories
// 25:             check_linuxbrew_core
// 26:             check_linuxbrew_bottle_domain
// 27:           ].freeze
// 28:         end
// 29:
// 30:         sig { returns(T::Array[String]) }
// 31:         def supported_configuration_checks
// 32:           %w[
// 33:             check_glibc_minimum_version
// 34:             check_kernel_minimum_version
// 35:             check_supported_architecture
// 36:           ].freeze
// 37:         end
// 38:
// 39:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 40:         def check_tmpdir_sticky_bit
// 41:           finding = super
// 42:           return if finding.nil?
// 43:
// 44:           finding.remediation.text += <<~EOS
// 45:             If you don't have administrative privileges on this machine,
// 46:             create a directory and set the `$HOMEBREW_TEMP` environment variable,
// 47:             for example:
// 48:               install -d -m 1755 ~/tmp
// 49:               #{Utils::Shell.set_variable_in_profile("HOMEBREW_TEMP", "~/tmp")}
// 50:           EOS
// 51:
// 52:           finding
// 53:         end
// 54:
// 55:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 56:         def check_tmpdir_executable
// 57:           f = Tempfile.new(%w[homebrew_check_tmpdir_executable .sh], HOMEBREW_TEMP)
// 58:           f.write "#!/bin/sh\n"
// 59:           f.chmod 0700
// 60:           f.close
// 61:           return if system T.must(f.path)
// 62:
// 63:           ::Homebrew::Diagnostic::Finding.new(
// 64:             <<~EOS,
// 65:               The directory #{HOMEBREW_TEMP} does not permit executing
// 66:               programs. It is likely mounted as "noexec".
// 67:             EOS
// 68:             remediation: ::Homebrew::Diagnostic::Finding::Remediation.new(
// 69:               commands: ["export HOMEBREW_TEMP=~/tmp", "echo 'export HOMEBREW_TEMP=~/tmp' >> #{Utils::Shell.profile}"],
// 70:               text:     <<~EOS,
// 71:                 Please set `$HOMEBREW_TEMP`
// 72:                 in your #{Utils::Shell.profile} to a different directory, for example:
// 73:                   export HOMEBREW_TEMP=~/tmp
// 74:                   echo 'export HOMEBREW_TEMP=~/tmp' >> #{Utils::Shell.profile}
// 75:               EOS
// 76:             ),
// 77:           )
// 78:         ensure
// 79:           f&.unlink
// 80:         end
// 81:
// 82:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 83:         def check_umask_not_zero
// 84:           return unless File.umask.zero?
// 85:
// 86:           ::Homebrew::Diagnostic::Finding.new(
// 87:             <<~EOS,
// 88:               umask is currently set to 000. Directories created by Homebrew cannot
// 89:               be world-writable.
// 90:             EOS
// 91:             remediation: ::Homebrew::Diagnostic::Finding::Remediation.new(
// 92:               text:     <<~EOS,
// 93:                 This issue can be resolved by adding "umask 002" to
// 94:                 your #{Utils::Shell.profile}:
// 95:               EOS
// 96:               commands: ["echo 'umask 002' >> #{Utils::Shell.profile}"],
// 97:             ),
// 98:           )
// 99:         end
// 100:
// 101:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 102:         def check_supported_architecture
// 103:           return if ::Hardware::CPU.intel?
// 104:           return if ::Hardware::CPU.arm64?
// 105:
// 106:           ::Homebrew::Diagnostic::Finding.new(
// 107:             <<~EOS,
// 108:               Your CPU architecture (#{::Hardware::CPU.arch}) is not supported. We only support
// 109:               x86_64 or ARM64/AArch64 CPU architectures. You will be unable to use binary packages (bottles).
// 110:             EOS
// 111:             tier: 2,
// 112:           )
// 113:         end
// 114:
// 115:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 116:         def check_glibc_minimum_version
// 117:           return unless OS::Linux::Glibc.below_minimum_version?
// 118:
// 119:           ::Homebrew::Diagnostic::Finding.new(
// 120:             <<~EOS,
// 121:               Your system glibc #{OS::Linux::Glibc.system_version} is too old.
// 122:               We only support glibc #{OS::Linux::Glibc.minimum_version} or later.
// 123:             EOS
// 124:             tier:        :unsupported,
// 125:             remediation: <<~EOS,
// 126:               We recommend updating to a newer version via your distribution's
// 127:               package manager, upgrading your distribution to the latest version,
// 128:               or changing distributions.
// 129:             EOS
// 130:           )
// 131:         end
// 132:
// 133:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 134:         def check_glibc_version
// 135:           return unless OS::Linux::Glibc.below_ci_version?
// 136:
// 137:           # We want to bypass this check in some tests.
// 138:           return if ENV["HOMEBREW_GLIBC_TESTING"]
// 139:
// 140:           ::Homebrew::Diagnostic::Finding.new(
// 141:             <<~EOS,
// 142:               Your system glibc #{OS::Linux::Glibc.system_version} is too old.
// 143:               We will need to automatically install a newer version.
// 144:             EOS
// 145:             tier:        2,
// 146:             remediation: <<~EOS,
// 147:               We recommend updating to a newer version via your distribution's
// 148:               package manager, upgrading your distribution to the latest version,
// 149:               or changing distributions.
// 150:             EOS
// 151:           )
// 152:         end
// 153:
// 154:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 155:         def check_glibc_next_version
// 156:           return if OS::LINUX_GLIBC_NEXT_CI_VERSION.blank?
// 157:           return if OS::Linux::Glibc.below_ci_version?
// 158:           return if OS::Linux::Glibc.system_version >= OS::LINUX_GLIBC_NEXT_CI_VERSION
// 159:
// 160:           # We want to bypass this check in some tests.
// 161:           return if ENV["HOMEBREW_GLIBC_TESTING"] || ENV["CI"] || ENV["HOMEBREW_TEST_BOT"].present?
// 162:
// 163:           ::Homebrew::Diagnostic::Finding.new(
// 164:             <<~EOS,
// 165:               Your system glibc #{OS::Linux::Glibc.system_version} is older than #{OS::LINUX_GLIBC_NEXT_CI_VERSION}.
// 166:               An upcoming brew release will automatically install a newer version.
// 167:             EOS
// 168:             remediation: <<~EOS,
// 169:               We recommend updating to a newer version via your distribution's
// 170:               package manager, upgrading your distribution to the latest version,
// 171:               or changing distributions.
// 172:             EOS
// 173:           )
// 174:         end
// 175:
// 176:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 177:         def check_kernel_minimum_version
// 178:           return unless OS::Linux::Kernel.below_minimum_version?
// 179:
// 180:           ::Homebrew::Diagnostic::Finding.new(
// 181:             <<~EOS,
// 182:               Your Linux kernel #{OS.kernel_version} is too old.
// 183:               We only support kernel #{OS::Linux::Kernel.minimum_version} or later.
// 184:               You will be unable to use binary packages (bottles).
// 185:             EOS
// 186:             tier:        3,
// 187:             remediation: <<~EOS,
// 188:               We recommend updating to a newer version via your distribution's
// 189:               package manager, upgrading your distribution to the latest version,
// 190:               or changing distributions.
// 191:             EOS
// 192:           )
// 193:         end
// 194:
// 195:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 196:         def check_linux_sandbox
// 197:           return unless Homebrew::EnvConfig.sandbox_linux?
// 198:
// 199:           return if OS::Linux.inside_docker? && !GitHub::Actions.env_set?
// 200:
// 201:           state = ::Sandbox.state
// 202:           return if state == :available
// 203:
// 204:           fix = if state == :missing_fiddle
// 205:             "Run Homebrew with its vendored Ruby, which includes Fiddle."
// 206:           else
// 207:             "Homebrew's Linux sandbox requires a kernel with Landlock enabled."
// 208:           end
// 209:
// 210:           ::Homebrew::Diagnostic::Finding.new(
// 211:             ::Sandbox.failure_reason || "The Linux sandbox is not available.",
// 212:             remediation: <<~EOS.chomp,
// 213:               #{fix}
// 214:               As a final workaround, disable the Linux sandbox:
// 215:                 export HOMEBREW_NO_SANDBOX_LINUX=1
// 216:             EOS
// 217:           )
// 218:         end
// 219:
// 220:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 221:         def check_linuxbrew_core
// 222:           return unless Homebrew::EnvConfig.no_install_from_api?
// 223:           return unless CoreTap.instance.linuxbrew_core?
// 224:
// 225:           ::Homebrew::Diagnostic::Finding.new(
// 226:             <<~EOS,
// 227:               Your Linux core repository is still linuxbrew-core.
// 228:               You must either unset `$HOMEBREW_NO_INSTALL_FROM_API` or set
// 229:               the repository's remote to homebrew-core to update core formulae.
// 230:             EOS
// 231:             remediation: <<~EOS,
// 232:               You can unset `$HOMEBREW_NO_INSTALL_FROM_API` or set
// 233:               the repository's remote to homebrew-core to update core formulae.
// 234:             EOS
// 235:           )
// 236:         end
// 237:
// 238:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 239:         def check_linuxbrew_bottle_domain
// 240:           return unless Homebrew::EnvConfig.bottle_domain.include?("linuxbrew")
// 241:
// 242:           ::Homebrew::Diagnostic::Finding.new(
// 243:             'Your `$HOMEBREW_BOTTLE_DOMAIN` still contains "linuxbrew".',
// 244:             remediation: "You must unset `$HOMEBREW_BOTTLE_DOMAIN` or adjust it to not contain \"linuxbrew\".",
// 245:           )
// 246:         end
// 247:
// 248:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 249:         def check_for_symlinked_home
// 250:           return unless File.symlink?("/home")
// 251:
// 252:           ::Homebrew::Diagnostic::Finding.new(
// 253:             <<~EOS,
// 254:               Your /home directory is a symlink.
// 255:               This is known to cause issues with formula linking, particularly when installing
// 256:               multiple formulae that create symlinks in shared directories.
// 257:
// 258:               While this may be a standard directory structure in some distributions
// 259:               (e.g. Fedora Silverblue) there are known issues as-is.
// 260:             EOS
// 261:             tier:        2,
// 262:             links:       ["https://github.com/Homebrew/brew/issues/18036"],
// 263:             remediation: <<~EOS,
// 264:               If you encounter linking issues, you may need to manually create conflicting
// 265:               directories or use `brew link --overwrite` as a workaround.
// 266:               We'd welcome a PR to fix this functionality.
// 267:             EOS
// 268:           )
// 269:         end
// 270:
// 271:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 272:         def check_gcc_dependent_linkage
// 273:           gcc_dependents = ::Formula.installed.select do |formula|
// 274:             next false unless formula.tap&.core_tap?
// 275:
// 276:             # FIXME: This includes formulae that have no runtime dependency on GCC.
// 277:             formula.recursive_dependencies.map(&:name).include? "gcc"
// 278:           rescue TapFormulaUnavailableError
// 279:             false
// 280:           end
// 281:           return if gcc_dependents.empty?
// 282:
// 283:           badly_linked = gcc_dependents.select do |dependent|
// 284:             dependent_prefix = dependent.any_installed_prefix
// 285:             # Keg.new() may raise an error if it is not a directory.
// 286:             # As the result `brew doctor` may display `Error: <keg> is not a directory`
// 287:             # instead of proper `doctor` information.
// 288:             # There are other checks that test that, we can skip broken kegs.
// 289:             next if dependent_prefix.nil? || !dependent_prefix.exist? || !dependent_prefix.directory?
// 290:
// 291:             keg = ::Keg.new(dependent_prefix)
// 292:             keg.binary_executable_or_library_files.any? do |binary|
// 293:               paths = binary.rpaths
// 294:               versioned_linkage = paths.any? { |path| path.match?(%r{lib/gcc/\d+$}) }
// 295:               unversioned_linkage = paths.any? { |path| path.match?(%r{lib/gcc/current$}) }
// 296:
// 297:               versioned_linkage && !unversioned_linkage
// 298:             end
// 299:           end
// 300:
// 301:           return if badly_linked.empty?
// 302:
// 303:           remediation = ::Homebrew::Diagnostic::Finding::Remediation.new(
// 304:             commands: ["brew reinstall #{badly_linked.join(" ")}"],
// 305:           )
// 306:           ::Homebrew::Diagnostic::Finding.new(
// 307:             <<~EOS,
// 308:               Formulae which link to GCC through a versioned path were found. These formulae
// 309:               are prone to breaking when GCC is updated.
// 310:             EOS
// 311:             remediation:,
// 312:           )
// 313:         end
// 314:
// 315:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 316:         def check_cask_software_versions
// 317:           super
// 318:           add_info "Linux", OS::Linux.os_version
// 319:
// 320:           nil
// 321:         end
// 322:       end
// 323:     end
// 324:   end
// 325: end
// 326:
// 327: Homebrew::Diagnostic::Checks.prepend(OS::Linux::Diagnostic::Checks)
