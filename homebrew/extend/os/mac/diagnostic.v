module mac

import ruby
import homebrew.diagnostic as finding
import homebrew.os.mac as sdk
import os

pub struct MacDiagnosticVolumes {
pub:
	mounts  []string
	outputs map[string]string
}

pub fn parse_df_mounts(output string) []string {
	mut mounts := []string{}
	for line in output.split_into_lines() {
		fields := line.fields()
		if fields.len >= 6 && fields[4].ends_with('%') && fields[4].trim_right('%').int() >= 0 {
			mounts << fields[5..].join(' ')
		}
	}
	return mounts
}

pub fn new_mac_diagnostic_volumes(all_output string, outputs map[string]string) MacDiagnosticVolumes {
	return MacDiagnosticVolumes{
		mounts: parse_df_mounts(all_output)
		outputs: outputs.clone()
	}
}

pub fn (volumes MacDiagnosticVolumes) get_mounts(path string) []string {
	if path == '' {
		return volumes.mounts.clone()
	}
	return parse_df_mounts(volumes.outputs[path] or { '' })
}

pub fn (volumes MacDiagnosticVolumes) index_of(path string) int {
	for mount in volumes.get_mounts(path) {
		index := volumes.mounts.index(mount)
		if index >= 0 {
			return index
		}
	}
	return -1
}

pub struct MacDiagnosticContext {
pub mut:
	found                        []string
	info                         [][]string
	verbose                      bool = true
	arm_cpu                      bool
	physical_arm64               bool
	paths                        []string
	findutils_installed          bool
	findutils_default_names      bool
	findutils_gnubin             []string
	developer                    bool
	integration_test             bool
	macos_version                string = '15'
	macos_pre_release            bool
	macos_outdated               bool
	cpu_features                 []string
	opencore_version             string
	oclp_version                 string
	xcode_installed              bool
	xcode_outdated               bool
	xcode_below_minimum          bool
	xcode_version                string
	xcode_latest_version         string
	xcode_prefix                 string
	xcode_default_prefix         bool = true
	xcode_bundle_path            string
	xcode_update_instructions    string
	xcode_needs_clt              bool
	clt_installed                bool
	clt_outdated                 bool
	clt_below_minimum            bool
	clt_update_instructions      string
	developer_tools_installed    bool = true
	developer_tools_instructions string
	github_actions               bool
	active_developer_dir         string
	xcodebuild_exists            bool
	xcode_license_output         string
	xcode_license_success        bool = true
	existing_paths               []string
	case_sensitive_paths         []string
	path_mounts                  map[string]string
	gettext_paths                []string
	gettext_linked               bool
	gettext_allowed_prefixes     []string
	iconv_paths                  []string
	libiconv_linked              bool
	libiconv_keg_only            bool
	cellar_exists                bool
	cellar_mount_index           int = -1
	temp_mount_index             int = -1
	sdk_present                  bool
	sdk_locator_source           string = 'clt'
	sdks                         []sdk.MacSdk
	cask_software_version        string
	sip_status                   string
	pkgconf_available            bool = true
	pkgconf_installed            bool
	pkgconf_built_on             map[string]string
	quarantine_status            string = 'quarantine_available'
	quarantine_output            string
}

pub fn new_mac_diagnostic_context() &MacDiagnosticContext {
	return &MacDiagnosticContext{}
}

fn diagnostic_finding(text string, tier string, remediation string) ?finding.Finding {
	return finding.new_finding(text, tier, []string{}, []string{}, if remediation == '' {
		none
	} else {
		finding.Remediation{ text: remediation }
	})
}

pub fn mac_fatal_preinstall_checks(arm_cpu bool) []string {
	mut checks := ['check_access_directories']
	if !arm_cpu { checks << 'check_for_installed_developer_tools' }
	return checks
}

pub fn mac_fatal_build_from_source_checks() []string {
	return ['check_for_installed_developer_tools', 'check_xcode_license_approved',
		'check_xcode_minimum_version', 'check_clt_minimum_version',
		'check_if_xcode_needs_clt_installed', 'check_if_supported_sdk_available', 'check_broken_sdks']
}

pub fn mac_fatal_setup_build_environment_checks() []string {
	return ['check_xcode_minimum_version', 'check_clt_minimum_version',
		'check_if_supported_sdk_available']
}

pub fn mac_supported_configuration_checks() []string {
	return ['check_for_unsupported_macos']
}

pub fn mac_build_from_source_checks() []string {
	return ['check_for_installed_developer_tools', 'check_xcode_up_to_date', 'check_clt_up_to_date']
}

pub fn mac_check_non_prefixed_findutils(context MacDiagnosticContext) ?finding.Finding {
	if !context.findutils_installed {
		return none
	}
	if !context.findutils_default_names && !context.paths.any(it in context.findutils_gnubin) {
		return none
	}
	return diagnostic_finding('Putting non-prefixed findutils in your path can cause python builds to fail.', '1', '')
}

pub fn mac_check_unsupported(context MacDiagnosticContext) ?finding.Finding {
	if context.developer || context.integration_test {
		return none
	}
	if context.macos_pre_release {
		return diagnostic_finding('You are using macOS ${context.macos_version}.\nWe do not provide support for this pre-release version.', '2', '')
	}
	if context.macos_outdated {
		return diagnostic_finding('You are using macOS ${context.macos_version}.\nWe (and Apple) do not provide support for this old version.', '3', 'You may have better luck with MacPorts which supports older versions of macOS:\nhttps://www.macports.org')
	}
	return none
}

pub fn mac_check_opencore(context MacDiagnosticContext) ?finding.Finding {
	if context.physical_arm64 || context.opencore_version.trim_space() == '' || context.oclp_version.trim_space() == '' {
		return none
	}
	tier := if 'pclmulqdq' in context.cpu_features && !context.macos_outdated { '2' } else { '3' }
	return diagnostic_finding('You have booted macOS using OpenCore Legacy Patcher.\nWe do not provide support for this configuration.', tier, '')
}

pub fn mac_check_xcode_up_to_date(context MacDiagnosticContext) ?finding.Finding {
	if !context.xcode_outdated || context.xcode_below_minimum || context.github_actions {
		return none
	}
	mut remediation := 'Please update to Xcode ${context.xcode_latest_version} (or delete it).\n${context.xcode_update_instructions}'
	if context.macos_pre_release {
		remediation += '\nIf ${context.xcode_latest_version} is installed, you may need to:\n  sudo xcode-select --switch /Applications/Xcode.app\nCurrent developer directory is:\n  ${context.active_developer_dir}'
	}
	return diagnostic_finding('Your Xcode (${context.xcode_version}) is outdated.', '2', remediation)
}

pub fn mac_check_clt_up_to_date(context MacDiagnosticContext) ?finding.Finding {
	if !context.clt_outdated || context.clt_below_minimum || context.github_actions {
		return none
	}
	return diagnostic_finding('A newer Command Line Tools release is available.', '2', context.clt_update_instructions)
}

pub fn mac_check_xcode_minimum(context MacDiagnosticContext) ?finding.Finding {
	if !context.xcode_below_minimum {
		return none
	}
	version := if context.xcode_default_prefix {
		context.xcode_version
	} else {
		'${context.xcode_version} => ${context.xcode_prefix}'
	}
	return diagnostic_finding('Your Xcode (${version}) at ${context.xcode_bundle_path} is too outdated.', '1', 'Please update to Xcode ${context.xcode_latest_version} (or delete it).\n${context.xcode_update_instructions}')
}

pub fn mac_check_clt_minimum(context MacDiagnosticContext) ?finding.Finding {
	if !context.clt_below_minimum {
		return none
	}
	return diagnostic_finding('Your Command Line Tools are too outdated.', '1', context.clt_update_instructions)
}

pub fn mac_pretty_version(version string) string {
	return match version.split('.')[0] {
		'11' { 'Big Sur' }
		'12' { 'Monterey' }
		'13' { 'Ventura' }
		'14' { 'Sonoma' }
		'15' { 'Sequoia' }
		else { 'macOS ${version}' }
	}
}

pub fn mac_check_xcode_needs_clt(context MacDiagnosticContext) ?finding.Finding {
	if !context.xcode_needs_clt {
		return none
	}
	return diagnostic_finding('Xcode alone is not sufficient on ${mac_pretty_version(context.macos_version)}.', '1', context.developer_tools_instructions)
}

pub fn mac_check_xcode_prefix(context MacDiagnosticContext) ?finding.Finding {
	if context.xcode_prefix == '' || !context.xcode_prefix.contains(' ') {
		return none
	}
	return diagnostic_finding('Xcode is installed to a directory with a space in the name.\nThis will cause some formulae to fail to build.', '1', '')
}

pub fn mac_check_xcode_prefix_exists(context MacDiagnosticContext) ?finding.Finding {
	if context.xcode_prefix == '' || context.xcode_prefix in context.existing_paths {
		return none
	}
	return diagnostic_finding("The directory Xcode is reportedly installed to doesn't exist:\n${context.xcode_prefix}", '1', 'You may need to `xcode-select` the proper path if you have moved Xcode.')
}

pub fn mac_check_xcode_select(context MacDiagnosticContext) ?finding.Finding {
	if context.clt_installed || !context.xcode_installed || context.xcodebuild_exists {
		return none
	}
	path := if context.xcode_bundle_path != '' && context.xcode_bundle_path in context.existing_paths {
		context.xcode_bundle_path
	} else {
		'/Developer'
	}
	return finding.new_finding('Your Xcode is configured with an invalid path.', '1', []string{}, []string{}, finding.Remediation{
		commands: ['sudo xcode-select --switch ${path}']
		text: 'You should change it to the correct path:\n  sudo xcode-select --switch ${path}'
	})
}

pub fn mac_check_xcode_license(context MacDiagnosticContext) ?finding.Finding {
	if context.xcode_license_success || !context.xcode_license_output.contains('license') {
		return none
	}
	return finding.new_finding('You have not agreed to the Xcode license.', '1', []string{}, []string{}, finding.Remediation{
		commands: ['sudo xcodebuild -license']
		text: 'Agree to the license by opening Xcode.app or running:\n  sudo xcodebuild -license'
	})
}

pub fn mac_check_case_sensitive(context MacDiagnosticContext) ?finding.Finding {
	paths := context.case_sensitive_paths.filter(it in context.existing_paths)
	if paths.len == 0 {
		return none
	}
	mut mounts := []string{}
	for path in paths {
		mount := context.path_mounts[path] or { path }
		if mount !in mounts { mounts << mount }
	}
	return diagnostic_finding('The filesystem on ${mounts.join(',')} appears to be case-sensitive.\nThe default macOS filesystem is case-insensitive. Please report any apparent problems.', '1', '')
}

pub fn mac_check_gettext(context MacDiagnosticContext) ?finding.Finding {
	if context.gettext_paths.len == 0 {
		return none
	}
	if context.gettext_linked && context.gettext_paths.all(path_starts_with_any(it, context.gettext_allowed_prefixes)) {
		return none
	}
	return diagnostic_finding('gettext files detected at a system prefix.\nThese files can cause compilation and link failures, especially if they are compiled with improper architectures.', '1', 'Consider removing these files:\n  ${context.gettext_paths.join('\n  ')}')
}

fn path_starts_with_any(path string, prefixes []string) bool {
	return prefixes.any(path.starts_with(it))
}

pub fn mac_check_iconv(context MacDiagnosticContext) ?finding.Finding {
	if context.iconv_paths.len == 0 {
		return none
	}
	if context.libiconv_linked && !context.libiconv_keg_only {
		return diagnostic_finding('A libiconv formula is installed and linked.\nThis will break stuff. For serious. Unlink it.', '1', '')
	}
	if context.libiconv_linked {
		return none
	}
	return diagnostic_finding("libiconv files detected at a system prefix other than /usr.\nHomebrew doesn't provide a libiconv formula and expects to link against the system version in /usr.", '1', 'tl;dr: delete these files:\n  ${context.iconv_paths.join('\n')}')
}

pub fn mac_check_multiple_volumes(context MacDiagnosticContext) ?finding.Finding {
	if !context.cellar_exists || context.cellar_mount_index < 0 || context.temp_mount_index < 0 || context.cellar_mount_index == context.temp_mount_index {
		return none
	}
	return diagnostic_finding("Your Cellar and TEMP directories are on different volumes.\nmacOS won't move relative symlinks across volumes unless the target file already exists.", '2', 'You should set the `\$HOMEBREW_TEMP` environment variable to a suitable directory on the same volume as your Cellar.')
}

pub fn mac_check_supported_sdk(context MacDiagnosticContext) ?finding.Finding {
	if !context.developer_tools_installed || context.sdk_present {
		return none
	}
	if context.sdk_locator_source == 'clt' && context.clt_below_minimum {
		return none
	}
	if context.sdk_locator_source != 'clt' && context.xcode_below_minimum {
		return none
	}
	source := if context.sdk_locator_source == 'clt' { 'Command Line Tools (CLT)' } else { 'Xcode' }
	instructions := if context.sdk_locator_source == 'clt' {
		context.clt_update_instructions
	} else {
		context.xcode_update_instructions
	}
	return diagnostic_finding('Your ${source} does not support macOS ${context.macos_version}.\nIt is either outdated or was modified.', '1', 'Please update your ${source} or delete it if no updates are available.\n${instructions}')
}

fn sdk_folder_version(path string) string {
	name := os.base(path)
	if !name.starts_with('MacOSX') || !name.ends_with('.sdk') {
		return ''
	}
	return name.trim_string_left('MacOSX').trim_string_right('.sdk')
}

pub fn mac_check_broken_sdks(context MacDiagnosticContext) ?finding.Finding {
	for candidate in context.sdks {
		path_version := sdk_folder_version(candidate.path)
		if path_version != '' && candidate.version != path_version {
			source := if context.sdk_locator_source == 'clt' {
				'Command Line Tools (CLT)'
			} else {
				'Xcode'
			}
			remove_path := if context.sdk_locator_source == 'clt' {
				'/Library/Developer/CommandLineTools'
			} else {
				context.xcode_bundle_path
			}
			instructions := if context.sdk_locator_source == 'clt' {
				context.developer_tools_instructions
			} else {
				context.xcode_update_instructions
			}
			return finding.new_finding('The contents of the SDKs in your ${source} installation do not match the SDK folder names.\nA clean reinstall of ${source} should fix this.', '1', []string{}, []string{}, finding.Remediation{
				commands: ['sudo rm -rf ${remove_path}']
				text: 'Remove the broken installation before reinstalling\n\n  ${instructions}'
			})
		}
	}
	return none
}

pub fn mac_add_cask_software_versions(mut context MacDiagnosticContext) {
	context.info << ['macOS', context.cask_software_version]
	context.info << ['SIP',
		context.sip_status.replace('System Integrity Protection status: ', '').replace('\t', '').replace('.', '').trim_space().capitalize()]
}

pub fn mac_check_pkgconf(context MacDiagnosticContext) ?finding.Finding {
	if !context.pkgconf_available || !context.pkgconf_installed {
		return none
	}
	built_version := context.pkgconf_built_on['os_version'] or { return none }
	if built_version == context.macos_version {
		return none
	}
	return diagnostic_finding('pkgconf was built on macOS ${built_version} but is running on macOS ${context.macos_version}.\nPlease run `brew reinstall pkgconf`.', '1', '')
}

pub fn mac_check_quarantine(context MacDiagnosticContext) ?finding.Finding {
	mut message := ''
	mut remediation := ''
	match context.quarantine_status {
		'quarantine_available' {
			return none
		}
		'xattr_broken' {
			message = "No Cask quarantine support available: there's no working version of `xattr` on this system."
		}
		'no_swift' {
			message = "No Cask quarantine support available: there's no available version of `swift` on this system."
		}
		'swift_broken_clt' {
			message = 'No Cask quarantine support available: Swift is not working due to missing Command Line Tools.'
			remediation = context.developer_tools_instructions
		}
		'swift_compilation_failed' {
			message = 'No Cask quarantine support available: Swift compilation failed.\nThis is usually due to a broken or incompatible Command Line Tools installation.'
			remediation = context.developer_tools_instructions
		}
		'swift_runtime_error' {
			message = 'No Cask quarantine support available: Swift runtime error.\nYour Command Line Tools installation may be broken or incomplete.'
			remediation = context.developer_tools_instructions
		}
		'swift_not_executable' {
			message = 'No Cask quarantine support available: Swift is not executable.\nYour Command Line Tools installation may be incomplete.'
			remediation = context.developer_tools_instructions
		}
		'swift_unexpected_error' {
			message = 'No Cask quarantine support available: Swift returned an unexpected error:\n${context.quarantine_output}'
		}
		else {
			message = 'No Cask quarantine support available: unknown reason: ${context.quarantine_status}:\n${context.quarantine_output}'
		}
	}
	return diagnostic_finding(message, '1', remediation)
}

fn mac_diagnostic_context_value(context &MacDiagnosticContext) ruby.Value {
	return ruby.structured_value('OS::Mac::Diagnostic::Checks', '', {
		'mac_diagnostic_address': u64(voidptr(context)).str()
	})
}

fn mac_diagnostic_context_from_value(value ruby.Value) &MacDiagnosticContext {
	return unsafe { &MacDiagnosticContext(voidptr(value.attributes['mac_diagnostic_address'].u64())) }
}

pub fn mac_diagnostic_boundary(context &MacDiagnosticContext) ruby.Value {
	return mac_diagnostic_context_value(context)
}

fn finding_value(result ?finding.Finding) ruby.Value {
	value := result or { return ruby.object_value('NilClass', 'nil') }
	return ruby.structured_value('Homebrew::Diagnostic::Finding', value.string(), {
		'text': value.text
		'tier': value.tier
	})
}

// Translated from Homebrew/brew `extend/os/mac/diagnostic.rb`.
