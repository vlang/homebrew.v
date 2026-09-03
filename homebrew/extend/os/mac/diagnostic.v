module mac

import brew_runtime
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

fn mac_diagnostic_context_value(context &MacDiagnosticContext) brew_runtime.Value {
	return brew_runtime.structured_value('OS::Mac::Diagnostic::Checks', '', {
		'mac_diagnostic_address': u64(voidptr(context)).str()
	})
}

fn mac_diagnostic_context_from_value(value brew_runtime.Value) &MacDiagnosticContext {
	return unsafe { &MacDiagnosticContext(voidptr(value.attributes['mac_diagnostic_address'].u64())) }
}

pub fn mac_diagnostic_boundary(context &MacDiagnosticContext) brew_runtime.Value {
	return mac_diagnostic_context_value(context)
}

fn finding_value(result ?finding.Finding) brew_runtime.Value {
	value := result or { return brew_runtime.object_value('NilClass', 'nil') }
	return brew_runtime.structured_value('Homebrew::Diagnostic::Finding', value.string(), {
		'text': value.text
		'tier': value.tier
	})
}

// Translated from Homebrew/brew `extend/os/mac/diagnostic.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 11.
pub fn ruby_diagnostic_l11_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	output := if args.len > 0 { args[0].as_string() } else { '' }
	parsed := new_mac_diagnostic_volumes(output, map[string]string{})
	volumes := &MacDiagnosticVolumes{
		mounts: parsed.mounts.clone()
		outputs: parsed.outputs.clone()
	}
	return brew_runtime.structured_value('OS::Mac::Diagnostic::Volumes', '', {
		'volumes_address': u64(voidptr(volumes)).str()
	})
}

// Ruby method `index_of(path)` at line 16.
pub fn ruby_diagnostic_l16_d2_index_of(args ...brew_runtime.Value) brew_runtime.Value {
	volumes := unsafe { &MacDiagnosticVolumes(voidptr(args[0].attributes['volumes_address'].u64())) }
	return brew_runtime.int_value(volumes.index_of(args[1].as_string()))
}

// Ruby method `get_mounts(path = nil)` at line 30.
pub fn ruby_diagnostic_l30_d3_get_mounts(args ...brew_runtime.Value) brew_runtime.Value {
	volumes := unsafe { &MacDiagnosticVolumes(voidptr(args[0].attributes['volumes_address'].u64())) }
	return brew_runtime.string_array_value(volumes.get_mounts(if args.len > 1 {
		args[1].as_string()
	} else {
		''
	}))
}

// Ruby method `initialize(verbose: true)` at line 56.
pub fn ruby_diagnostic_l56_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	mut context := new_mac_diagnostic_context()
	context.verbose = if args.len > 0 { args[0].bool_data } else { true }
	return mac_diagnostic_context_value(context)
}

// Ruby method `fatal_preinstall_checks` at line 62.
pub fn ruby_diagnostic_l62_d5_fatal_preinstall_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(mac_fatal_preinstall_checks(mac_diagnostic_context_from_value(args[0]).arm_cpu))
}

// Ruby method `fatal_build_from_source_checks` at line 75.
pub fn ruby_diagnostic_l75_d6_fatal_build_from_source_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(mac_fatal_build_from_source_checks())
}

// Ruby method `fatal_setup_build_environment_checks` at line 88.
pub fn ruby_diagnostic_l88_d7_fatal_setup_build_environment_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(mac_fatal_setup_build_environment_checks())
}

// Ruby method `supported_configuration_checks` at line 97.
pub fn ruby_diagnostic_l97_d8_supported_configuration_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(mac_supported_configuration_checks())
}

// Ruby method `build_from_source_checks` at line 104.
pub fn ruby_diagnostic_l104_d9_build_from_source_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(mac_build_from_source_checks())
}

// Ruby method `check_for_non_prefixed_findutils` at line 113.
pub fn ruby_diagnostic_l113_d10_check_for_non_prefixed_findutils(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_non_prefixed_findutils(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_for_unsupported_macos` at line 131.
pub fn ruby_diagnostic_l131_d11_check_for_unsupported_macos(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_unsupported(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_for_opencore` at line 164.
pub fn ruby_diagnostic_l164_d12_check_for_opencore(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_opencore(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_xcode_up_to_date` at line 194.
pub fn ruby_diagnostic_l194_d13_check_xcode_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_xcode_up_to_date(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_clt_up_to_date` at line 229.
pub fn ruby_diagnostic_l229_d14_check_clt_up_to_date(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_clt_up_to_date(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_xcode_minimum_version` at line 249.
pub fn ruby_diagnostic_l249_d15_check_xcode_minimum_version(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_xcode_minimum(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_clt_minimum_version` at line 267.
pub fn ruby_diagnostic_l267_d16_check_clt_minimum_version(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_clt_minimum(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_if_xcode_needs_clt_installed` at line 279.
pub fn ruby_diagnostic_l279_d17_check_if_xcode_needs_clt_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_xcode_needs_clt(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_xcode_prefix` at line 291.
pub fn ruby_diagnostic_l291_d18_check_xcode_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_xcode_prefix(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_xcode_prefix_exists` at line 305.
pub fn ruby_diagnostic_l305_d19_check_xcode_prefix_exists(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_xcode_prefix_exists(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_xcode_select_path` at line 321.
pub fn ruby_diagnostic_l321_d20_check_xcode_select_path(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_xcode_select(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_xcode_license_approved` at line 344.
pub fn ruby_diagnostic_l344_d21_check_xcode_license_approved(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_xcode_license(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_filesystem_case_sensitive` at line 365.
pub fn ruby_diagnostic_l365_d22_check_filesystem_case_sensitive(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_case_sensitive(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_for_gettext` at line 401.
pub fn ruby_diagnostic_l401_d23_check_for_gettext(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_gettext(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_for_iconv` at line 443.
pub fn ruby_diagnostic_l443_d24_check_for_iconv(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_iconv(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby it `it was either installed by a user or some other third party software.` at line 469.
pub fn ruby_diagnostic_l469_d25_was(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('it was either installed by a user or some other third party software.')
}

// Ruby method `check_for_multiple_volumes` at line 480.
pub fn ruby_diagnostic_l480_d26_check_for_multiple_volumes(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_multiple_volumes(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_if_supported_sdk_available` at line 518.
pub fn ruby_diagnostic_l518_d27_check_if_supported_sdk_available(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_supported_sdk(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_broken_sdks` at line 554.
pub fn ruby_diagnostic_l554_d28_check_broken_sdks(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_broken_sdks(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_cask_software_versions` at line 592.
pub fn ruby_diagnostic_l592_d29_check_cask_software_versions(args ...brew_runtime.Value) brew_runtime.Value {
	mut context := mac_diagnostic_context_from_value(args[0])
	mac_add_cask_software_versions(mut context)
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `check_pkgconf_macos_sdk_mismatch` at line 615.
pub fn ruby_diagnostic_l615_d30_check_pkgconf_macos_sdk_mismatch(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_pkgconf(*mac_diagnostic_context_from_value(args[0])))
}

// Ruby method `check_cask_quarantine_support` at line 625.
pub fn ruby_diagnostic_l625_d31_check_cask_quarantine_support(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_value(mac_check_quarantine(*mac_diagnostic_context_from_value(args[0])))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/os/mac/pkgconf"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module Diagnostic
// 9:       class Volumes
// 10:         sig { void }
// 11:         def initialize
// 12:           @volumes = T.let(get_mounts, T::Array[String])
// 13:         end
// 14:
// 15:         sig { params(path: T.nilable(::Pathname)).returns(Integer) }
// 16:         def index_of(path)
// 17:           vols = get_mounts path
// 18:
// 19:           # no volume found
// 20:           return -1 if vols.empty?
// 21:
// 22:           vol_index = @volumes.index(vols[0])
// 23:           # volume not found in volume list
// 24:           return -1 if vol_index.nil?
// 25:
// 26:           vol_index
// 27:         end
// 28:
// 29:         sig { params(path: T.nilable(::Pathname)).returns(T::Array[String]) }
// 30:         def get_mounts(path = nil)
// 31:           vols = []
// 32:           # get the volume of path, if path is nil returns all volumes
// 33:
// 34:           args = %w[/bin/df -P]
// 35:           args << path.to_s if path
// 36:
// 37:           Utils.popen_read(*args) do |io|
// 38:             io.each_line do |line|
// 39:               case line.chomp
// 40:                 # regex matches: /dev/disk0s2   489562928 440803616  48247312    91%    /
// 41:               when /^.+\s+[0-9]+\s+[0-9]+\s+[0-9]+\s+[0-9]{1,3}%\s+(.+)/
// 42:                 vols << Regexp.last_match(1)
// 43:               end
// 44:             end
// 45:           end
// 46:           vols
// 47:         end
// 48:       end
// 49:
// 50:       module Checks
// 51:         extend T::Helpers
// 52:
// 53:         requires_ancestor { Homebrew::Diagnostic::Checks }
// 54:
// 55:         sig { params(verbose: T::Boolean).void }
// 56:         def initialize(verbose: true)
// 57:           super
// 58:           @found = T.let([], T::Array[String])
// 59:         end
// 60:
// 61:         sig { returns(T::Array[String]) }
// 62:         def fatal_preinstall_checks
// 63:           checks = %w[
// 64:             check_access_directories
// 65:           ]
// 66:
// 67:           # We need the developer tools for `codesign` on Intel:
// 68:           # https://github.com/Homebrew/brew/issues/23418
// 69:           checks << "check_for_installed_developer_tools" unless ::Hardware::CPU.arm?
// 70:
// 71:           checks.freeze
// 72:         end
// 73:
// 74:         sig { returns(T::Array[String]) }
// 75:         def fatal_build_from_source_checks
// 76:           %w[
// 77:             check_for_installed_developer_tools
// 78:             check_xcode_license_approved
// 79:             check_xcode_minimum_version
// 80:             check_clt_minimum_version
// 81:             check_if_xcode_needs_clt_installed
// 82:             check_if_supported_sdk_available
// 83:             check_broken_sdks
// 84:           ].freeze
// 85:         end
// 86:
// 87:         sig { returns(T::Array[String]) }
// 88:         def fatal_setup_build_environment_checks
// 89:           %w[
// 90:             check_xcode_minimum_version
// 91:             check_clt_minimum_version
// 92:             check_if_supported_sdk_available
// 93:           ].freeze
// 94:         end
// 95:
// 96:         sig { returns(T::Array[String]) }
// 97:         def supported_configuration_checks
// 98:           %w[
// 99:             check_for_unsupported_macos
// 100:           ].freeze
// 101:         end
// 102:
// 103:         sig { returns(T::Array[String]) }
// 104:         def build_from_source_checks
// 105:           %w[
// 106:             check_for_installed_developer_tools
// 107:             check_xcode_up_to_date
// 108:             check_clt_up_to_date
// 109:           ].freeze
// 110:         end
// 111:
// 112:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 113:         def check_for_non_prefixed_findutils
// 114:           findutils = ::Formula["findutils"]
// 115:           return unless findutils.any_version_installed?
// 116:
// 117:           gnubin = %W[#{findutils.opt_libexec}/gnubin #{findutils.libexec}/gnubin]
// 118:           default_names = Tab.for_name("findutils").with? "default-names"
// 119:           return if !default_names && !paths.intersect?(gnubin)
// 120:
// 121:           ::Homebrew::Diagnostic::Finding.new(
// 122:             <<~EOS,
// 123:               Putting non-prefixed findutils in your path can cause python builds to fail.
// 124:             EOS
// 125:           )
// 126:         rescue FormulaUnavailableError
// 127:           nil
// 128:         end
// 129:
// 130:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 131:         def check_for_unsupported_macos
// 132:           return if Homebrew::EnvConfig.developer?
// 133:           return if ENV["HOMEBREW_INTEGRATION_TEST"]
// 134:
// 135:           tier = 2
// 136:           who = +"We"
// 137:           remediation = nil
// 138:           what = if OS::Mac.version.prerelease?
// 139:             "pre-release version."
// 140:           elsif OS::Mac.version.outdated_release?
// 141:             tier = 3
// 142:             who << " (and Apple)"
// 143:             remediation = <<~EOS
// 144:               You may have better luck with MacPorts which supports older versions of macOS:
// 145:               #{Formatter.url("https://www.macports.org")}
// 146:             EOS
// 147:             "old version."
// 148:           end
// 149:           return if what.blank?
// 150:
// 151:           who.freeze
// 152:
// 153:           ::Homebrew::Diagnostic::Finding.new(
// 154:             <<~EOS,
// 155:               You are using macOS #{MacOS.version}.
// 156:               #{who} do not provide support for this #{what}
// 157:             EOS
// 158:             remediation:,
// 159:             tier:,
// 160:           )
// 161:         end
// 162:
// 163:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 164:         def check_for_opencore
// 165:           return if ::Hardware::CPU.physical_cpu_arm64?
// 166:
// 167:           # https://dortania.github.io/OpenCore-Legacy-Patcher/UPDATE.html#checking-oclp-and-opencore-versions
// 168:           begin
// 169:             opencore_version = Utils.safe_popen_read("/usr/sbin/nvram",
// 170:                                                      "4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version").split[1]
// 171:             oclp_version = Utils.safe_popen_read("/usr/sbin/nvram",
// 172:                                                  "4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:OCLP-Version").split[1]
// 173:             return if opencore_version.blank? || oclp_version.blank?
// 174:           rescue ErrorDuringExecution
// 175:             return
// 176:           end
// 177:
// 178:           oclp_support_tier = if ::Hardware::CPU.features.include?(:pclmulqdq) && !OS::Mac.version.outdated_release?
// 179:             2
// 180:           else
// 181:             3
// 182:           end
// 183:
// 184:           ::Homebrew::Diagnostic::Finding.new(
// 185:             <<~EOS,
// 186:               You have booted macOS using OpenCore Legacy Patcher.
// 187:               We do not provide support for this configuration.
// 188:             EOS
// 189:             tier: oclp_support_tier,
// 190:           )
// 191:         end
// 192:
// 193:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 194:         def check_xcode_up_to_date
// 195:           return unless MacOS::Xcode.outdated?
// 196:
// 197:           # avoid duplicate very similar messages
// 198:           return if MacOS::Xcode.below_minimum_version?
// 199:
// 200:           # CI images are going to end up outdated so don't complain when
// 201:           # `brew test-bot` runs `brew doctor` in the CI for the Homebrew/brew
// 202:           # repository. This only needs to support whatever CI providers
// 203:           # Homebrew/brew is currently using.
// 204:           return if GitHub::Actions.env_set?
// 205:
// 206:           remediation = <<~EOS
// 207:             Please update to Xcode #{MacOS::Xcode.latest_version} (or delete it).
// 208:             #{MacOS::Xcode.update_instructions}
// 209:           EOS
// 210:
// 211:           if OS::Mac.version.prerelease?
// 212:             current_path = Utils.popen_read("/usr/bin/xcode-select", "-p")
// 213:             remediation += <<~EOS
// 214:               If #{MacOS::Xcode.latest_version} is installed, you may need to:
// 215:                 sudo xcode-select --switch /Applications/Xcode.app
// 216:               Current developer directory is:
// 217:                 #{current_path}
// 218:             EOS
// 219:           end
// 220:
// 221:           ::Homebrew::Diagnostic::Finding.new(
// 222:             "Your Xcode (#{MacOS::Xcode.version}) is outdated.",
// 223:             tier:        2,
// 224:             remediation:,
// 225:           )
// 226:         end
// 227:
// 228:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 229:         def check_clt_up_to_date
// 230:           return unless MacOS::CLT.outdated?
// 231:
// 232:           # avoid duplicate very similar messages
// 233:           return if MacOS::CLT.below_minimum_version?
// 234:
// 235:           # CI images are going to end up outdated so don't complain when
// 236:           # `brew test-bot` runs `brew doctor` in the CI for the Homebrew/brew
// 237:           # repository. This only needs to support whatever CI providers
// 238:           # Homebrew/brew is currently using.
// 239:           return if GitHub::Actions.env_set?
// 240:
// 241:           ::Homebrew::Diagnostic::Finding.new(
// 242:             "A newer Command Line Tools release is available.",
// 243:             tier:        2,
// 244:             remediation: MacOS::CLT.update_instructions,
// 245:           )
// 246:         end
// 247:
// 248:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 249:         def check_xcode_minimum_version
// 250:           return unless MacOS::Xcode.below_minimum_version?
// 251:
// 252:           xcode = MacOS::Xcode.version.to_s
// 253:           xcode += " => #{MacOS::Xcode.prefix}" unless MacOS::Xcode.default_prefix?
// 254:
// 255:           ::Homebrew::Diagnostic::Finding.new(
// 256:             <<~EOS,
// 257:               Your Xcode (#{xcode}) at #{MacOS::Xcode.bundle_path} is too outdated.
// 258:             EOS
// 259:             remediation: <<~EOS,
// 260:               Please update to Xcode #{MacOS::Xcode.latest_version} (or delete it).
// 261:               #{MacOS::Xcode.update_instructions}
// 262:             EOS
// 263:           )
// 264:         end
// 265:
// 266:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 267:         def check_clt_minimum_version
// 268:           return unless MacOS::CLT.below_minimum_version?
// 269:
// 270:           ::Homebrew::Diagnostic::Finding.new(
// 271:             <<~EOS,
// 272:               Your Command Line Tools are too outdated.
// 273:             EOS
// 274:             remediation: MacOS::CLT.update_instructions,
// 275:           )
// 276:         end
// 277:
// 278:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 279:         def check_if_xcode_needs_clt_installed
// 280:           return unless MacOS::Xcode.needs_clt_installed?
// 281:
// 282:           ::Homebrew::Diagnostic::Finding.new(
// 283:             <<~EOS,
// 284:               Xcode alone is not sufficient on #{MacOS.version.pretty_name}.
// 285:             EOS
// 286:             remediation: ::DevelopmentTools.installation_instructions,
// 287:           )
// 288:         end
// 289:
// 290:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 291:         def check_xcode_prefix
// 292:           prefix = MacOS::Xcode.prefix
// 293:           return if prefix.nil?
// 294:           return unless prefix.to_s.include?(" ")
// 295:
// 296:           ::Homebrew::Diagnostic::Finding.new(
// 297:             <<~EOS,
// 298:               Xcode is installed to a directory with a space in the name.
// 299:               This will cause some formulae to fail to build.
// 300:             EOS
// 301:           )
// 302:         end
// 303:
// 304:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 305:         def check_xcode_prefix_exists
// 306:           prefix = MacOS::Xcode.prefix
// 307:           return if prefix.nil? || prefix.exist?
// 308:
// 309:           ::Homebrew::Diagnostic::Finding.new(
// 310:             <<~EOS,
// 311:               The directory Xcode is reportedly installed to doesn't exist:
// 312:               #{prefix}
// 313:             EOS
// 314:             remediation: <<~EOS,
// 315:               You may need to `xcode-select` the proper path if you have moved Xcode.
// 316:             EOS
// 317:           )
// 318:         end
// 319:
// 320:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 321:         def check_xcode_select_path
// 322:           return if MacOS::CLT.installed?
// 323:           return unless MacOS::Xcode.installed?
// 324:           return if File.file?("#{MacOS.active_developer_dir}/usr/bin/xcodebuild")
// 325:
// 326:           path = MacOS::Xcode.bundle_path
// 327:           path = "/Developer" if path.nil? || !path.directory?
// 328:
// 329:           ::Homebrew::Diagnostic::Finding.new(
// 330:             <<~EOS,
// 331:               Your Xcode is configured with an invalid path.
// 332:             EOS
// 333:             remediation: ::Homebrew::Diagnostic::Finding::Remediation.new(
// 334:               commands: ["sudo xcode-select --switch #{path}"],
// 335:               text:     <<~EOS,
// 336:                 You should change it to the correct path:
// 337:                   sudo xcode-select --switch #{path}
// 338:               EOS
// 339:             ),
// 340:           )
// 341:         end
// 342:
// 343:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 344:         def check_xcode_license_approved
// 345:           # If the user installs Xcode-only, they have to approve the
// 346:           # license or no "xc*" tool will work.
// 347:           return unless `/usr/bin/xcrun --find clang 2>&1`.include?("license")
// 348:           return if $CHILD_STATUS.success?
// 349:
// 350:           ::Homebrew::Diagnostic::Finding.new(
// 351:             <<~EOS,
// 352:               You have not agreed to the Xcode license.
// 353:             EOS
// 354:             remediation: ::Homebrew::Diagnostic::Finding::Remediation.new(
// 355:               commands: ["sudo xcodebuild -license"],
// 356:               text:     <<~EOS,
// 357:                 Agree to the license by opening Xcode.app or running:
// 358:                   sudo xcodebuild -license
// 359:               EOS
// 360:             ),
// 361:           )
// 362:         end
// 363:
// 364:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 365:         def check_filesystem_case_sensitive
// 366:           dirs_to_check = [
// 367:             HOMEBREW_PREFIX,
// 368:             HOMEBREW_REPOSITORY,
// 369:             HOMEBREW_CELLAR,
// 370:             HOMEBREW_TEMP,
// 371:           ]
// 372:           case_sensitive_dirs = dirs_to_check.select do |dir|
// 373:             # We select the dir as being case-sensitive if either the UPCASED or the
// 374:             # downcased variant is missing.
// 375:             # Of course, on a case-insensitive fs, both exist because the os reports so.
// 376:             # In the rare situation when the user has indeed a downcased and an upcased
// 377:             # dir (e.g. /TMP and /tmp) this check falsely thinks it is case-insensitive
// 378:             # but we don't care because: 1. there is more than one dir checked, 2. the
// 379:             # check is not vital and 3. we would have to touch files otherwise.
// 380:             upcased = ::Pathname.new(dir.to_s.upcase)
// 381:             downcased = ::Pathname.new(dir.to_s.downcase)
// 382:             dir.exist? && !(upcased.exist? && downcased.exist?)
// 383:           end
// 384:           return if case_sensitive_dirs.empty?
// 385:
// 386:           volumes = Volumes.new
// 387:           case_sensitive_vols = case_sensitive_dirs.map do |case_sensitive_dir|
// 388:             volumes.get_mounts(case_sensitive_dir)
// 389:           end
// 390:           case_sensitive_vols.uniq!
// 391:
// 392:           ::Homebrew::Diagnostic::Finding.new(
// 393:             <<~EOS,
// 394:               The filesystem on #{case_sensitive_vols.join(",")} appears to be case-sensitive.
// 395:               The default macOS filesystem is case-insensitive. Please report any apparent problems.
// 396:             EOS
// 397:           )
// 398:         end
// 399:
// 400:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 401:         def check_for_gettext
// 402:           find_relative_paths("lib/libgettextlib.dylib",
// 403:                               "lib/libintl.dylib",
// 404:                               "include/libintl.h")
// 405:           return if @found.empty?
// 406:
// 407:           # Our gettext formula will be caught by check_linked_keg_only_brews
// 408:           gettext = begin
// 409:             Formulary.factory("gettext")
// 410:           rescue
// 411:             nil
// 412:           end
// 413:
// 414:           if gettext&.linked_keg&.directory?
// 415:             allowlist = ["#{HOMEBREW_CELLAR}/gettext"]
// 416:             if ::Hardware::CPU.physical_cpu_arm64?
// 417:               allowlist += %W[
// 418:                 #{HOMEBREW_MACOS_ARM_DEFAULT_PREFIX}/Cellar/gettext
// 419:                 #{HOMEBREW_DEFAULT_PREFIX}/Cellar/gettext
// 420:               ]
// 421:             end
// 422:
// 423:             return if @found.all? do |path|
// 424:               realpath = ::Pathname.new(path).realpath.to_s
// 425:               realpath.start_with?(*allowlist)
// 426:             end
// 427:           end
// 428:
// 429:           ::Homebrew::Diagnostic::Finding.new(
// 430:             <<~EOS,
// 431:               gettext files detected at a system prefix.
// 432:               These files can cause compilation and link failures, especially if they
// 433:               are compiled with improper architectures.
// 434:             EOS
// 435:             remediation: <<~EOS,
// 436:               Consider removing these files:
// 437:                 #{@found.join("\n  ")}
// 438:             EOS
// 439:           )
// 440:         end
// 441:
// 442:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 443:         def check_for_iconv
// 444:           find_relative_paths("lib/libiconv.dylib", "include/iconv.h")
// 445:           return if @found.empty?
// 446:
// 447:           libiconv = begin
// 448:             Formulary.factory("libiconv")
// 449:           rescue
// 450:             nil
// 451:           end
// 452:           if libiconv&.linked_keg&.directory?
// 453:             unless libiconv&.keg_only?
// 454:               ::Homebrew::Diagnostic::Finding.new(
// 455:                 <<~EOS,
// 456:                   A libiconv formula is installed and linked.
// 457:                   This will break stuff. For serious. Unlink it.
// 458:                 EOS
// 459:               )
// 460:             end
// 461:           else
// 462:             ::Homebrew::Diagnostic::Finding.new(
// 463:               <<~EOS,
// 464:                 libiconv files detected at a system prefix other than /usr.
// 465:                 Homebrew doesn't provide a libiconv formula and expects to link against
// 466:                 the system version in /usr. libiconv in other prefixes can cause
// 467:                 compile or link failure, especially if compiled with improper
// 468:                 architectures. macOS itself never installs anything to /usr/local so
// 469:                 it was either installed by a user or some other third party software.
// 470:               EOS
// 471:               remediation: <<~EOS,
// 472:                 tl;dr: delete these files:
// 473:                   #{@found.join("\n")}
// 474:               EOS
// 475:             )
// 476:           end
// 477:         end
// 478:
// 479:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 480:         def check_for_multiple_volumes
// 481:           return unless HOMEBREW_CELLAR.exist?
// 482:
// 483:           volumes = Volumes.new
// 484:
// 485:           # Find the volumes for the TMP folder & HOMEBREW_CELLAR
// 486:           real_cellar = HOMEBREW_CELLAR.realpath
// 487:           where_cellar = volumes.index_of real_cellar
// 488:
// 489:           begin
// 490:             tmp = ::Pathname.new(Dir.mktmpdir("doctor", HOMEBREW_TEMP))
// 491:             begin
// 492:               real_tmp = tmp.realpath.parent
// 493:               where_tmp = volumes.index_of real_tmp
// 494:             ensure
// 495:               Dir.delete tmp.to_s
// 496:             end
// 497:           rescue
// 498:             return
// 499:           end
// 500:
// 501:           return if where_cellar == where_tmp
// 502:
// 503:           ::Homebrew::Diagnostic::Finding.new(
// 504:             <<~EOS,
// 505:               Your Cellar and TEMP directories are on different volumes.
// 506:               macOS won't move relative symlinks across volumes unless the target file already
// 507:               exists. Formulae known to be affected by this are Git and Narwhal.
// 508:             EOS
// 509:             tier:        2,
// 510:             remediation: <<~EOS,
// 511:               You should set the `$HOMEBREW_TEMP` environment variable to a suitable
// 512:               directory on the same volume as your Cellar.
// 513:             EOS
// 514:           )
// 515:         end
// 516:
// 517:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 518:         def check_if_supported_sdk_available
// 519:           return unless ::DevelopmentTools.installed?
// 520:           return if MacOS.sdk
// 521:
// 522:           locator = MacOS.sdk_locator
// 523:
// 524:           source = if locator.source == :clt
// 525:             return if MacOS::CLT.below_minimum_version? # Handled by other diagnostics.
// 526:
// 527:             update_instructions = MacOS::CLT.update_instructions
// 528:             "Command Line Tools (CLT)"
// 529:           else
// 530:             return if MacOS::Xcode.below_minimum_version? # Handled by other diagnostics.
// 531:
// 532:             update_instructions = MacOS::Xcode.update_instructions
// 533:             "Xcode"
// 534:           end
// 535:
// 536:           ::Homebrew::Diagnostic::Finding.new(
// 537:             <<~EOS,
// 538:               Your #{source} does not support macOS #{MacOS.version}.
// 539:               It is either outdated or was modified.
// 540:             EOS
// 541:             remediation: ::Homebrew::Diagnostic::Finding::Remediation.new(
// 542:               text: <<~EOS,
// 543:                 Please update your #{source} or delete it if no updates are available.
// 544:                 #{update_instructions}
// 545:               EOS
// 546:             ),
// 547:           )
// 548:         end
// 549:
// 550:         # The CLT 10.x -> 11.x upgrade process on 10.14 contained a bug which broke the SDKs.
// 551:         # Notably, MacOSX10.14.sdk would indirectly symlink to MacOSX10.15.sdk.
// 552:         # This diagnostic was introduced to check for this and recommend a full reinstall.
// 553:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 554:         def check_broken_sdks
// 555:           locator = MacOS.sdk_locator
// 556:
// 557:           return if locator.all_sdks.all? do |sdk|
// 558:             path_version = sdk.path.basename.to_s[MacOS::SDK::VERSIONED_SDK_REGEX, 1]
// 559:             next true if path_version.blank?
// 560:
// 561:             sdk.version == MacOSVersion.new(path_version).strip_patch
// 562:           end
// 563:
// 564:           if locator.source == :clt
// 565:             source = "Command Line Tools (CLT)"
// 566:             path_to_remove = MacOS::CLT::PKG_PATH
// 567:             installation_instructions = MacOS::CLT.installation_instructions
// 568:           else
// 569:             source = "Xcode"
// 570:             path_to_remove = MacOS::Xcode.bundle_path
// 571:             installation_instructions = MacOS::Xcode.installation_instructions
// 572:           end
// 573:
// 574:           remediation = ::Homebrew::Diagnostic::Finding::Remediation.new(
// 575:             commands: ["sudo rm -rf #{path_to_remove}"],
// 576:             text:     <<~EOS,
// 577:               Remove the broken installation before reinstalling
// 578:
// 579:                 #{installation_instructions}
// 580:             EOS
// 581:           )
// 582:           ::Homebrew::Diagnostic::Finding.new(
// 583:             <<~EOS,
// 584:               The contents of the SDKs in your #{source} installation do not match the SDK folder names.
// 585:               A clean reinstall of #{source} should fix this.
// 586:             EOS
// 587:             remediation:,
// 588:           )
// 589:         end
// 590:
// 591:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 592:         def check_cask_software_versions
// 593:           super
// 594:           add_info "macOS", MacOS.full_version
// 595:           add_info "SIP", begin
// 596:             csrutil = "/usr/bin/csrutil"
// 597:             if File.executable?(csrutil)
// 598:               Open3.capture2(csrutil, "status")
// 599:                    .first
// 600:                    .gsub("This is an unsupported configuration, likely to break in " \
// 601:                          "the future and leave your machine in an unknown state.", "")
// 602:                    .gsub("System Integrity Protection status: ", "")
// 603:                    .delete("\t.")
// 604:                    .capitalize
// 605:                    .strip
// 606:             else
// 607:               "N/A"
// 608:             end
// 609:           end
// 610:
// 611:           nil
// 612:         end
// 613:
// 614:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 615:         def check_pkgconf_macos_sdk_mismatch
// 616:           mismatch = Homebrew::Pkgconf.macos_sdk_mismatch
// 617:           return unless mismatch
// 618:
// 619:           ::Homebrew::Diagnostic::Finding.new(
// 620:             Homebrew::Pkgconf.mismatch_warning_message(mismatch),
// 621:           )
// 622:         end
// 623:
// 624:         sig { returns(T.nilable(::Homebrew::Diagnostic::Finding)) }
// 625:         def check_cask_quarantine_support
// 626:           status, check_output = ::Cask::Quarantine.check_quarantine_support
// 627:
// 628:           messages = case status
// 629:           when :quarantine_available
// 630:             [nil, nil]
// 631:           when :xattr_broken
// 632:             ["No Cask quarantine support available: there's no working version of `xattr` on this system.", nil]
// 633:           when :no_swift
// 634:             ["No Cask quarantine support available: there's no available version of `swift` on this system.", nil]
// 635:           when :swift_broken_clt
// 636:             ["No Cask quarantine support available: Swift is not working due to missing Command Line Tools.", MacOS::CLT.installation_then_reinstall_instructions]
// 637:           when :swift_compilation_failed
// 638:             msg = <<~EOS
// 639:               No Cask quarantine support available: Swift compilation failed.
// 640:               This is usually due to a broken or incompatible Command Line Tools installation.
// 641:             EOS
// 642:             [msg, MacOS::CLT.installation_then_reinstall_instructions]
// 643:           when :swift_runtime_error
// 644:             msg = <<~EOS
// 645:               No Cask quarantine support available: Swift runtime error.
// 646:               Your Command Line Tools installation may be broken or incomplete.
// 647:             EOS
// 648:             [msg, MacOS::CLT.installation_then_reinstall_instructions]
// 649:           when :swift_not_executable
// 650:             msg = <<~EOS
// 651:               No Cask quarantine support available: Swift is not executable.
// 652:               Your Command Line Tools installation may be incomplete.
// 653:             EOS
// 654:             [msg, MacOS::CLT.installation_then_reinstall_instructions]
// 655:           when :swift_unexpected_error
// 656:             msg = <<~EOS
// 657:               No Cask quarantine support available: Swift returned an unexpected error:
// 658:               #{check_output}
// 659:             EOS
// 660:             [msg, nil]
// 661:           else
// 662:             msg = <<~EOS
// 663:               No Cask quarantine support available: unknown reason: #{status.inspect}:
// 664:               #{check_output}
// 665:             EOS
// 666:             [msg, nil]
// 667:           end
// 668:
// 669:           return unless messages.first.present?
// 670:
// 671:           ::Homebrew::Diagnostic::Finding.new(
// 672:             T.must(messages.first),
// 673:             remediation: messages.last,
// 674:           )
// 675:         end
// 676:       end
// 677:     end
// 678:   end
// 679: end
// 680:
// 681: Homebrew::Diagnostic::Checks.prepend(OS::Mac::Diagnostic::Checks)
