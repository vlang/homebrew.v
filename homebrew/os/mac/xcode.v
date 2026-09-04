module mac

import ruby
import os

const xcode_default_bundle_path = '/Applications/Xcode.app'
const xcode_developer_download_url = 'https://developer.apple.com/download/all/'
const clt_package_path = '/Library/Developer/CommandLineTools'

pub struct XcodeSdk {
pub:
	version string
	path    string
}

fn xcode_strip_patch(version string) string {
	parts := version.split('.')
	if parts.len == 0 {
		return version
	}
	if parts[0].int() >= 11 {
		return parts[0]
	}
	return if parts.len > 1 { parts[..2].join('.') } else { version }
}

fn xcode_version_parts(version string) []int {
	mut numeric := version
	for separator in [' ', '-', 'b'] {
		numeric = numeric.all_before(separator)
	}
	return numeric.split('.').map(it.int())
}

fn xcode_compare_versions(left string, right string) int {
	left_parts := xcode_version_parts(left)
	right_parts := xcode_version_parts(right)
	max_len := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. max_len {
		left_value := if index < left_parts.len { left_parts[index] } else { 0 }
		right_value := if index < right_parts.len { right_parts[index] } else { 0 }
		if left_value != right_value {
			return if left_value < right_value { -1 } else { 1 }
		}
	}
	return 0
}

pub fn xcode_latest_version(macos string, prerelease bool) !string {
	stripped := xcode_strip_patch(macos)
	return match stripped {
		'26', '15' { '26.3' }
		'14' { '16.2' }
		'13' { '15.2' }
		'12' { '14.2' }
		'11' { '13.2.1' }
		'10.15' { '12.4' }
		else {
			if !prerelease {
				return error("macOS '${stripped}' is invalid")
			}
			'${stripped}.0'
		}
	}
}

pub fn xcode_minimum_version(macos string) string {
	return match xcode_strip_patch(macos) {
		'15' { '16.0' }
		'14' { '15.0' }
		'13' { '14.1' }
		'12' { '13.1' }
		'11' { '12.2' }
		'10.15' { '11.0' }
		else { '${xcode_strip_patch(macos)}.0' }
	}
}

pub fn xcode_below_minimum(installed bool, version string, macos string) bool {
	return installed && xcode_compare_versions(version, xcode_minimum_version(macos)) < 0
}

pub fn xcode_latest_sdk_version(full_version string, latest_sdk_version string) bool {
	return xcode_compare_versions(full_version, latest_sdk_version) >= 0
}

pub fn xcode_needs_clt_installed(latest_sdk bool, clt_installed bool) bool {
	return !latest_sdk && !clt_installed
}

pub fn xcode_outdated(installed bool, version string, macos string, prerelease bool) !bool {
	return installed && xcode_compare_versions(version, xcode_latest_version(macos, prerelease)!) < 0
}

pub fn xcode_prefix(active_developer_dir string, clt_path string, bundle_path string,
	active_directory_exists bool) string {
	if active_developer_dir == '' || active_developer_dir == clt_path || !active_directory_exists {
		return if bundle_path == '' {
			''
		} else {
			os.norm_path(os.join_path(bundle_path, 'Contents/Developer'))
		}
	}
	return os.norm_path(active_developer_dir)
}

pub fn xcode_toolchain_path(prefix string) string {
	return os.join_path(prefix, 'Toolchains/XcodeDefault.xctoolchain')
}

pub fn xcode_bundle_path(default_exists bool, located_path string) string {
	return if default_exists { xcode_default_bundle_path } else { located_path }
}

pub fn xcode_sdk(sdks []XcodeSdk, version string) ?XcodeSdk {
	if version == '' {
		return if sdks.len > 0 { sdks[0] } else { none }
	}
	for sdk in sdks {
		if sdk.version == version {
			return sdk
		}
	}
	return none
}

pub fn xcode_installation_instructions(prerelease bool) string {
	return if prerelease {
		'Xcode can be installed from:\n  ${xcode_developer_download_url}\n'
	} else {
		'Xcode can be installed from the App Store.\n'
	}
}

pub fn xcode_update_instructions(prerelease bool) string {
	return if prerelease {
		'Xcode can be updated from:\n  ${xcode_developer_download_url}\n'
	} else {
		'Xcode can be updated from the App Store.\n'
	}
}

pub fn xcode_detect_version(installed bool, clt_installed bool, plist_contents string,
	xcodebuild_outputs []string, clang_version string) string {
	if !installed && !clt_installed {
		return ''
	}
	if installed {
		key := '<key>CFBundleShortVersionString</key>'
		if plist_contents.contains(key) {
			rest := plist_contents.all_after(key)
			value := rest.all_after('<string>').all_before('</string>').trim_space()
			if value != '' {
				return value
			}
		}
		for output in xcodebuild_outputs {
			for line in output.split_into_lines() {
				if line.starts_with('Xcode ') {
					candidate := line.all_after('Xcode ').fields()[0]
					if candidate != '' {
						return candidate
					}
				}
			}
		}
	}
	return xcode_version_from_clang(clang_version)
}

pub fn xcode_version_from_clang(version string) string {
	if version == '' || version == 'NULL' {
		return 'dunno'
	}
	return match version {
		'11.0.0' { '11.3.1' }
		'11.0.3' { '11.7' }
		'12.0.0' { '12.4' }
		'12.0.5' { '12.5.1' }
		'13.0.0' { '13.2.1' }
		'13.1.6' { '13.4.1' }
		'14.0.0' { '14.2' }
		'14.0.3' { '14.3.1' }
		'15.0.0' { '15.4' }
		'16.0.0' { '16.2' }
		else { '26.3' }
	}
}

pub fn clt_installation_instructions(prerelease bool, minimum_version string) string {
	return if prerelease {
		'Install the Command Line Tools for Xcode ${minimum_version.all_before('.')} from:\n  ${xcode_developer_download_url}\n'
	} else {
		'Install the Command Line Tools:\n  xcode-select --install\n'
	}
}

pub fn clt_reinstall_instructions(reason string, latest_xcode string) string {
	return "If that doesn't ${reason}, run:\n  sudo rm -rf ${clt_package_path}\n  sudo xcode-select --install\n\nAlternatively, manually download them from:\n  ${xcode_developer_download_url}.\nYou should download the Command Line Tools for Xcode ${latest_xcode}.\n"
}

pub fn clt_update_instructions(macos string, reinstall string) string {
	location := if xcode_compare_versions(macos, '13') >= 0 {
		'System Settings'
	} else {
		'System Preferences'
	}
	return 'Update them from Software Update in ${location}.\n\n${reinstall}\n'
}

pub fn clt_latest_clang_version(macos string) string {
	return match xcode_strip_patch(macos) {
		'27' { '2100.3.20.102' }
		'26', '15' { '1700.6.4.2' }
		'14' { '1600.0.26.6' }
		'13' { '1500.1.0.2.5' }
		'12' { '1400.0.29.202' }
		'11' { '1300.0.29.30' }
		else { '1200.0.32.29' }
	}
}

pub fn clt_minimum_version(macos string) string {
	return match xcode_strip_patch(macos) {
		'15' { '16.0.0' }
		'14' { '15.0.0' }
		'13' { '14.0.0' }
		'12' { '13.0.0' }
		'11' { '12.5.0' }
		'10.15' { '11.0.0' }
		else { '${xcode_strip_patch(macos)}.0.0' }
	}
}

pub fn clt_detect_clang_version(output string) string {
	marker := 'clang-'
	if !output.contains(marker) {
		return ''
	}
	mut candidate := output.all_after(marker).fields()[0]
	for index, character in candidate {
		if !(character.is_digit() || character == `.`) {
			candidate = candidate[..index]
			break
		}
	}
	return candidate.trim_right('.')
}

pub fn clt_version_from_clang(output string) string {
	raw := clt_detect_clang_version(output)
	if raw == '' {
		return ''
	}
	major := raw.all_before('.')
	if major.len < 3 {
		return ''
	}
	clang := '${major[..major.len - 2].int()}.${major[major.len - 2..major.len - 1]}.${major[major.len - 1..]}'
	return xcode_version_from_clang(clang)
}

pub fn clt_detect_version(clang_exists bool, pkgutil_output string, clang_output string) string {
	if clang_exists {
		for line in pkgutil_output.split_into_lines() {
			if line.starts_with('version: ') {
				return line.all_after('version: ').trim_space()
			}
		}
	}
	return clt_version_from_clang(clang_output)
}

fn xcode_value(value string) ruby.Value {
	return if value == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.structured_value('Version', value, {
			'version': value
		})
	}
}

// Translated from Homebrew/brew `os/mac/xcode.rb`.
