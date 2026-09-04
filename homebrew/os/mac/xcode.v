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
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.latest_version(macos: MacOS.version)` at line 17.
pub fn ruby_xcode_l17_d1_self_latest_version(args ...ruby.Value) ruby.Value {
	macos := if args.len > 0 { args[0].as_string() } else { '15' }
	prerelease := args.len > 1 && args[1].bool_data
	return ruby.string_value(xcode_latest_version(macos, prerelease) or { panic(err) })
}

// Ruby method `self.minimum_version` at line 39.
pub fn ruby_xcode_l39_d2_self_minimum_version(args ...ruby.Value) ruby.Value {
	return ruby.string_value(xcode_minimum_version(if args.len > 0 {
		args[0].as_string()
	} else {
		'15'
	}))
}

// Ruby method `self.below_minimum_version?` at line 54.
pub fn ruby_xcode_l54_d3_self_below_minimum_version(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(xcode_below_minimum(args.len > 0 && args[0].bool_data, if args.len > 1 {
		args[1].as_string()
	} else {
		''
	}, if args.len > 2 { args[2].as_string() } else { '15' }))
}

// Ruby method `self.latest_sdk_version?` at line 61.
pub fn ruby_xcode_l61_d4_self_latest_sdk_version(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(xcode_latest_sdk_version(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}, if args.len > 1 { args[1].as_string() } else { '' }))
}

// Ruby method `self.needs_clt_installed?` at line 66.
pub fn ruby_xcode_l66_d5_self_needs_clt_installed(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(xcode_needs_clt_installed(args.len > 0 && args[0].bool_data, args.len > 1 && args[1].bool_data))
}

// Ruby method `self.outdated?` at line 73.
pub fn ruby_xcode_l73_d6_self_outdated(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(xcode_outdated(args.len > 0 && args[0].bool_data, if args.len > 1 {
		args[1].as_string()
	} else {
		''
	}, if args.len > 2 { args[2].as_string() } else { '15' }, args.len > 3 && args[3].bool_data) or {
		panic(err)
	})
}

// Ruby method `self.without_clt?` at line 80.
pub fn ruby_xcode_l80_d7_self_without_clt(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!(args.len > 0 && args[0].bool_data))
}

// Ruby method `self.prefix` at line 87.
pub fn ruby_xcode_l87_d8_self_prefix(args ...ruby.Value) ruby.Value {
	prefix := xcode_prefix(if args.len > 0 { args[0].as_string() } else { '' }, clt_package_path, if args.len > 1 {
		args[1].as_string()
	} else {
		''
	}, args.len > 2 && args[2].bool_data)
	return if prefix == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.string_value(prefix)
	}
}

// Ruby method `self.toolchain_path` at line 102.
pub fn ruby_xcode_l102_d9_self_toolchain_path(args ...ruby.Value) ruby.Value {
	return ruby.string_value(xcode_toolchain_path(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `self.bundle_path` at line 107.
pub fn ruby_xcode_l107_d10_self_bundle_path(args ...ruby.Value) ruby.Value {
	path := xcode_bundle_path(args.len > 0 && args[0].bool_data, if args.len > 1 {
		args[1].as_string()
	} else {
		''
	})
	return if path == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.string_value(path)
	}
}

// Ruby method `self.installed?` at line 118.
pub fn ruby_xcode_l118_d11_self_installed(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && args[0].type_name != 'NilClass' && args[0].as_string() != '')
}

// Ruby method `self.sdk_locator` at line 123.
pub fn ruby_xcode_l123_d12_self_sdk_locator(args ...ruby.Value) ruby.Value {
	return ruby.object_value('OS::Mac::XcodeSDKLocator', 'XcodeSDKLocator')
}

// Ruby method `self.sdk(version = nil)` at line 128.
pub fn ruby_xcode_l128_d13_self_sdk(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.structured_value('OS::Mac::SDK', args[0].as_string(), {
		'version': args[0].as_string()
		'path':    if args.len > 1 { args[1].as_string() } else { '' }
	})
}

// Ruby method `self.sdk_path(version = nil)` at line 133.
pub fn ruby_xcode_l133_d14_self_sdk_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(args[0].attributes['path'] or { args[0].as_string() })
}

// Ruby method `self.installation_instructions` at line 138.
pub fn ruby_xcode_l138_d15_self_installation_instructions(args ...ruby.Value) ruby.Value {
	return ruby.string_value(xcode_installation_instructions(args.len > 0 && args[0].bool_data))
}

// Ruby method `self.update_instructions` at line 152.
pub fn ruby_xcode_l152_d16_self_update_instructions(args ...ruby.Value) ruby.Value {
	return ruby.string_value(xcode_update_instructions(args.len > 0 && args[0].bool_data))
}

// Ruby method `self.version` at line 169.
pub fn ruby_xcode_l169_d17_self_version(args ...ruby.Value) ruby.Value {
	return xcode_value(if args.len > 0 { args[0].as_string() } else { '' })
}

// Ruby method `self.detect_version` at line 181.
pub fn ruby_xcode_l181_d18_self_detect_version(args ...ruby.Value) ruby.Value {
	options := if args.len > 0 { args[0].map_data.clone() } else { map[string]ruby.Value{} }
	outputs := (options['xcodebuild_outputs'] or { ruby.string_array_value([]) }).as_array() or {
		[]
	}.map(it.as_string())
	version := xcode_detect_version((options['installed'] or { ruby.bool_value(false) }).bool_data, (options['clt_installed'] or { ruby.bool_value(false) }).bool_data, (options['plist'] or { ruby.string_value('') }).as_string(), outputs, (options['clang_version'] or { ruby.string_value('') }).as_string())
	return if version == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.string_value(version)
	}
}

// Ruby method `self.detect_version_from_clang_version(version = ::DevelopmentTools.clang_version)` at line 214.
pub fn ruby_xcode_l214_d19_self_detect_version_from_clang_version(args ...ruby.Value) ruby.Value {
	return ruby.string_value(xcode_version_from_clang(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}))
}

// Ruby method `self.default_prefix?` at line 237.
pub fn ruby_xcode_l237_d20_self_default_prefix(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && os.norm_path(args[0].as_string()) == '/Applications/Xcode.app/Contents/Developer')
}

// Ruby method `self.installed?` at line 251.
pub fn ruby_xcode_l251_d21_self_installed(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && args[0].as_string() !in ['', 'NULL'])
}

// Ruby method `self.sdk_locator` at line 256.
pub fn ruby_xcode_l256_d22_self_sdk_locator(args ...ruby.Value) ruby.Value {
	return ruby.object_value('OS::Mac::CLTSDKLocator', 'CLTSDKLocator')
}

// Ruby method `self.sdk(version = nil)` at line 261.
pub fn ruby_xcode_l261_d23_self_sdk(args ...ruby.Value) ruby.Value {
	return ruby_xcode_l128_d13_self_sdk(...args)
}

// Ruby method `self.sdk_path(version = nil)` at line 266.
pub fn ruby_xcode_l266_d24_self_sdk_path(args ...ruby.Value) ruby.Value {
	return ruby_xcode_l133_d14_self_sdk_path(...args)
}

// Ruby method `self.installation_instructions` at line 271.
pub fn ruby_xcode_l271_d25_self_installation_instructions(args ...ruby.Value) ruby.Value {
	prerelease := args.len > 0 && args[0].bool_data
	minimum := if args.len > 1 { args[1].as_string() } else { '16.0.0' }
	return ruby.string_value(clt_installation_instructions(prerelease, minimum))
}

// Ruby method `self.reinstall_instructions(reason: "resolve your issues")` at line 286.
pub fn ruby_xcode_l286_d26_self_reinstall_instructions(args ...ruby.Value) ruby.Value {
	reason := if args.len > 0 { args[0].as_string() } else { 'resolve your issues' }
	latest := if args.len > 1 { args[1].as_string() } else { '26.3' }
	return ruby.string_value(clt_reinstall_instructions(reason, latest))
}

// Ruby method `self.update_instructions` at line 299.
pub fn ruby_xcode_l299_d27_self_update_instructions(args ...ruby.Value) ruby.Value {
	macos := if args.len > 0 { args[0].as_string() } else { '15' }
	reinstall := if args.len > 1 {
		args[1].as_string()
	} else {
		clt_reinstall_instructions('show you any updates', '26.3')
	}
	return ruby.string_value(clt_update_instructions(macos, reinstall))
}

// Ruby method `self.installation_then_reinstall_instructions` at line 314.
pub fn ruby_xcode_l314_d28_self_installation_then_reinstall_instructions(args ...ruby.Value) ruby.Value {
	installation := if args.len > 0 {
		args[0].as_string()
	} else {
		clt_installation_instructions(false, '16.0.0')
	}
	reinstall := if args.len > 1 {
		args[1].as_string()
	} else {
		clt_reinstall_instructions('resolve your issues', '26.3')
	}
	return ruby.string_value('${installation}\n${reinstall}\n')
}

// Ruby method `self.latest_clang_version` at line 324.
pub fn ruby_xcode_l324_d29_self_latest_clang_version(args ...ruby.Value) ruby.Value {
	return ruby.string_value(clt_latest_clang_version(if args.len > 0 {
		args[0].as_string()
	} else {
		'15'
	}))
}

// Ruby method `self.minimum_version` at line 340.
pub fn ruby_xcode_l340_d30_self_minimum_version(args ...ruby.Value) ruby.Value {
	return ruby.string_value(clt_minimum_version(if args.len > 0 {
		args[0].as_string()
	} else {
		'15'
	}))
}

// Ruby method `self.below_minimum_version?` at line 355.
pub fn ruby_xcode_l355_d31_self_below_minimum_version(args ...ruby.Value) ruby.Value {
	installed := args.len > 0 && args[0].bool_data
	version := if args.len > 1 { args[1].as_string() } else { '' }
	macos := if args.len > 2 { args[2].as_string() } else { '15' }
	return ruby.bool_value(installed && xcode_compare_versions(version, clt_minimum_version(macos)) < 0)
}

// Ruby method `self.outdated?` at line 362.
pub fn ruby_xcode_l362_d32_self_outdated(args ...ruby.Value) ruby.Value {
	detected := if args.len > 0 { args[0].as_string() } else { '' }
	latest := if args.len > 1 { args[1].as_string() } else { '' }
	return ruby.bool_value(detected != '' && xcode_compare_versions(detected, latest) < 0)
}

// Ruby method `self.detect_clang_version` at line 370.
pub fn ruby_xcode_l370_d33_self_detect_clang_version(args ...ruby.Value) ruby.Value {
	version := clt_detect_clang_version(if args.len > 0 { args[0].as_string() } else { '' })
	return if version == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.string_value(version)
	}
}

// Ruby method `self.detect_version_from_clang_version` at line 376.
pub fn ruby_xcode_l376_d34_self_detect_version_from_clang_version(args ...ruby.Value) ruby.Value {
	version := clt_version_from_clang(if args.len > 0 { args[0].as_string() } else { '' })
	return if version == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.string_value(version)
	}
}

// Ruby method `self.version` at line 389.
pub fn ruby_xcode_l389_d35_self_version(args ...ruby.Value) ruby.Value {
	return xcode_value(if args.len > 0 { args[0].as_string() } else { '' })
}

// Ruby method `self.detect_version` at line 398.
pub fn ruby_xcode_l398_d36_self_detect_version(args ...ruby.Value) ruby.Value {
	version := clt_detect_version(args.len > 0 && args[0].bool_data, if args.len > 1 {
		args[1].as_string()
	} else {
		''
	}, if args.len > 2 { args[2].as_string() } else { '' })
	return if version == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.string_value(version)
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     # Helper module for querying Xcode information.
// 7:     module Xcode
// 8:       DEFAULT_BUNDLE_PATH = ::Pathname.new("/Applications/Xcode.app").freeze
// 9:       BUNDLE_ID = "com.apple.dt.Xcode"
// 10:       OLD_BUNDLE_ID = "com.apple.Xcode"
// 11:       APPLE_DEVELOPER_DOWNLOAD_URL = "https://developer.apple.com/download/all/"
// 12:
// 13:       # Bump these when a new version is available from the App Store and our
// 14:       # CI systems have been updated.
// 15:       # This may be a beta version for a beta macOS.
// 16:       sig { params(macos: MacOSVersion).returns(String) }
// 17:       def self.latest_version(macos: MacOS.version)
// 18:         macos = macos.strip_patch
// 19:         case macos
// 20:         when "26", "15" then "26.3"
// 21:         when "14" then "16.2"
// 22:         when "13" then "15.2"
// 23:         when "12" then "14.2"
// 24:         when "11" then "13.2.1"
// 25:         when "10.15" then "12.4"
// 26:         else
// 27:           raise "macOS '#{macos}' is invalid" unless macos.prerelease?
// 28:
// 29:           # Assume matching yearly Xcode release
// 30:           "#{macos}.0"
// 31:         end
// 32:       end
// 33:
// 34:       # Bump these if things are badly broken (e.g. no SDK for this macOS)
// 35:       # without this. Generally this will be the first Xcode release on that
// 36:       # macOS version (which may initially be a beta if that version of macOS is
// 37:       # also in beta).
// 38:       sig { returns(String) }
// 39:       def self.minimum_version
// 40:         macos = MacOS.version
// 41:         case macos
// 42:         when "15" then "16.0"
// 43:         when "14" then "15.0"
// 44:         when "13" then "14.1"
// 45:         when "12" then "13.1"
// 46:         when "11" then "12.2"
// 47:         when "10.15" then "11.0"
// 48:         else
// 49:           "#{macos}.0"
// 50:         end
// 51:       end
// 52:
// 53:       sig { returns(T::Boolean) }
// 54:       def self.below_minimum_version?
// 55:         return false unless installed?
// 56:
// 57:         version < minimum_version
// 58:       end
// 59:
// 60:       sig { returns(T::Boolean) }
// 61:       def self.latest_sdk_version?
// 62:         OS::Mac.full_version >= OS::Mac.latest_sdk_version
// 63:       end
// 64:
// 65:       sig { returns(T::Boolean) }
// 66:       def self.needs_clt_installed?
// 67:         return false if latest_sdk_version?
// 68:
// 69:         without_clt?
// 70:       end
// 71:
// 72:       sig { returns(T::Boolean) }
// 73:       def self.outdated?
// 74:         return false unless installed?
// 75:
// 76:         version < latest_version
// 77:       end
// 78:
// 79:       sig { returns(T::Boolean) }
// 80:       def self.without_clt?
// 81:         !MacOS::CLT.installed?
// 82:       end
// 83:
// 84:       # Returns a Pathname object corresponding to Xcode.app's Developer
// 85:       # directory or nil if Xcode.app is not installed.
// 86:       sig { returns(T.nilable(::Pathname)) }
// 87:       def self.prefix
// 88:         @prefix ||= T.let(begin
// 89:           dir = MacOS.active_developer_dir
// 90:
// 91:           if dir.empty? || dir == CLT::PKG_PATH || !File.directory?(dir)
// 92:             path = bundle_path
// 93:             path/"Contents/Developer" if path
// 94:           else
// 95:             # Use cleanpath to avoid pathological trailing slash
// 96:             ::Pathname.new(dir).cleanpath
// 97:           end
// 98:         end, T.nilable(::Pathname))
// 99:       end
// 100:
// 101:       sig { returns(::Pathname) }
// 102:       def self.toolchain_path
// 103:         Pathname("#{prefix}/Toolchains/XcodeDefault.xctoolchain")
// 104:       end
// 105:
// 106:       sig { returns(T.nilable(::Pathname)) }
// 107:       def self.bundle_path
// 108:         # Use the default location if it exists.
// 109:         return DEFAULT_BUNDLE_PATH if DEFAULT_BUNDLE_PATH.exist?
// 110:
// 111:         # Ask Spotlight where Xcode is. If the user didn't install the
// 112:         # helper tools and installed Xcode in a non-conventional place, this
// 113:         # is our only option. See: https://superuser.com/questions/390757
// 114:         MacOS.app_with_bundle_id(BUNDLE_ID, OLD_BUNDLE_ID)
// 115:       end
// 116:
// 117:       sig { returns(T::Boolean) }
// 118:       def self.installed?
// 119:         !prefix.nil?
// 120:       end
// 121:
// 122:       sig { returns(XcodeSDKLocator) }
// 123:       def self.sdk_locator
// 124:         @sdk_locator ||= T.let(XcodeSDKLocator.new, T.nilable(OS::Mac::XcodeSDKLocator))
// 125:       end
// 126:
// 127:       sig { params(version: T.nilable(MacOSVersion)).returns(T.nilable(SDK)) }
// 128:       def self.sdk(version = nil)
// 129:         sdk_locator.sdk_if_applicable(version)
// 130:       end
// 131:
// 132:       sig { params(version: T.nilable(MacOSVersion)).returns(T.nilable(::Pathname)) }
// 133:       def self.sdk_path(version = nil)
// 134:         sdk(version)&.path
// 135:       end
// 136:
// 137:       sig { returns(String) }
// 138:       def self.installation_instructions
// 139:         if OS::Mac.version.prerelease?
// 140:           <<~EOS
// 141:             Xcode can be installed from:
// 142:               #{Formatter.url(APPLE_DEVELOPER_DOWNLOAD_URL)}
// 143:           EOS
// 144:         else
// 145:           <<~EOS
// 146:             Xcode can be installed from the App Store.
// 147:           EOS
// 148:         end
// 149:       end
// 150:
// 151:       sig { returns(String) }
// 152:       def self.update_instructions
// 153:         if OS::Mac.version.prerelease?
// 154:           <<~EOS
// 155:             Xcode can be updated from:
// 156:               #{Formatter.url(APPLE_DEVELOPER_DOWNLOAD_URL)}
// 157:           EOS
// 158:         else
// 159:           <<~EOS
// 160:             Xcode can be updated from the App Store.
// 161:           EOS
// 162:         end
// 163:       end
// 164:
// 165:       # Get the Xcode version.
// 166:       #
// 167:       # @api internal
// 168:       sig { returns(::Version) }
// 169:       def self.version
// 170:         # may return a version string
// 171:         # that is guessed based on the compiler, so do not
// 172:         # use it in order to check if Xcode is installed.
// 173:         if @version ||= T.let(detect_version, T.nilable(String))
// 174:           ::Version.new @version
// 175:         else
// 176:           ::Version::NULL
// 177:         end
// 178:       end
// 179:
// 180:       sig { returns(T.nilable(String)) }
// 181:       def self.detect_version
// 182:         # This is a separate function as you can't cache the value out of a block
// 183:         # if return is used in the middle, which we do many times in here.
// 184:         return if !MacOS::Xcode.installed? && !MacOS::CLT.installed?
// 185:
// 186:         if MacOS::Xcode.installed?
// 187:           # Fast path that will probably almost always work unless `xcode-select -p` is misconfigured
// 188:           version_plist = T.must(prefix).parent/"version.plist"
// 189:           if version_plist.file?
// 190:             require "plist"
// 191:             data = Plist.parse_xml(version_plist, marshal: false)
// 192:             version = data["CFBundleShortVersionString"] if data
// 193:             return version if version
// 194:           end
// 195:
// 196:           %W[
// 197:             #{prefix}/usr/bin/xcodebuild
// 198:             #{which("xcodebuild")}
// 199:           ].uniq.each do |xcodebuild_path|
// 200:             next unless File.executable? xcodebuild_path
// 201:
// 202:             xcodebuild_output = Utils.popen_read(xcodebuild_path, "-version")
// 203:             next unless $CHILD_STATUS.success?
// 204:
// 205:             xcode_version = xcodebuild_output[/Xcode (\d+(\.\d+)*)/, 1]
// 206:             return xcode_version if xcode_version
// 207:           end
// 208:         end
// 209:
// 210:         detect_version_from_clang_version
// 211:       end
// 212:
// 213:       sig { params(version: ::Version).returns(String) }
// 214:       def self.detect_version_from_clang_version(version = ::DevelopmentTools.clang_version)
// 215:         return "dunno" if version.null?
// 216:
// 217:         # This logic provides a fake Xcode version based on the
// 218:         # installed CLT version. This is useful as they are packaged
// 219:         # simultaneously so workarounds need to apply to both based on their
// 220:         # comparable version.
// 221:         case version
// 222:         when "11.0.0" then "11.3.1"
// 223:         when "11.0.3" then "11.7"
// 224:         when "12.0.0" then "12.4"
// 225:         when "12.0.5" then "12.5.1"
// 226:         when "13.0.0" then "13.2.1"
// 227:         when "13.1.6" then "13.4.1"
// 228:         when "14.0.0" then "14.2"
// 229:         when "14.0.3" then "14.3.1"
// 230:         when "15.0.0" then "15.4"
// 231:         when "16.0.0" then "16.2"
// 232:         else               "26.3"
// 233:         end
// 234:       end
// 235:
// 236:       sig { returns(T::Boolean) }
// 237:       def self.default_prefix?
// 238:         prefix.to_s == "/Applications/Xcode.app/Contents/Developer"
// 239:       end
// 240:     end
// 241:
// 242:     # Helper module for querying macOS Command Line Tools information.
// 243:     module CLT
// 244:       extend Utils::Output::Mixin
// 245:
// 246:       EXECUTABLE_PKG_ID = "com.apple.pkg.CLTools_Executables"
// 247:       PKG_PATH = "/Library/Developer/CommandLineTools"
// 248:
// 249:       # Returns true even if outdated tools are installed.
// 250:       sig { returns(T::Boolean) }
// 251:       def self.installed?
// 252:         !version.null?
// 253:       end
// 254:
// 255:       sig { returns(CLTSDKLocator) }
// 256:       def self.sdk_locator
// 257:         @sdk_locator ||= T.let(CLTSDKLocator.new, T.nilable(OS::Mac::CLTSDKLocator))
// 258:       end
// 259:
// 260:       sig { params(version: T.nilable(MacOSVersion)).returns(T.nilable(SDK)) }
// 261:       def self.sdk(version = nil)
// 262:         sdk_locator.sdk_if_applicable(version)
// 263:       end
// 264:
// 265:       sig { params(version: T.nilable(MacOSVersion)).returns(T.nilable(::Pathname)) }
// 266:       def self.sdk_path(version = nil)
// 267:         sdk(version)&.path
// 268:       end
// 269:
// 270:       sig { returns(String) }
// 271:       def self.installation_instructions
// 272:         if OS::Mac.version.prerelease?
// 273:           <<~EOS
// 274:             Install the Command Line Tools for Xcode #{minimum_version.split(".").first} from:
// 275:               #{Formatter.url(MacOS::Xcode::APPLE_DEVELOPER_DOWNLOAD_URL)}
// 276:           EOS
// 277:         else
// 278:           <<~EOS
// 279:             Install the Command Line Tools:
// 280:               xcode-select --install
// 281:           EOS
// 282:         end
// 283:       end
// 284:
// 285:       sig { params(reason: String).returns(String) }
// 286:       def self.reinstall_instructions(reason: "resolve your issues")
// 287:         <<~EOS
// 288:           If that doesn't #{reason}, run:
// 289:             sudo rm -rf /Library/Developer/CommandLineTools
// 290:             sudo xcode-select --install
// 291:
// 292:           Alternatively, manually download them from:
// 293:             #{Formatter.url(MacOS::Xcode::APPLE_DEVELOPER_DOWNLOAD_URL)}.
// 294:           You should download the Command Line Tools for Xcode #{MacOS::Xcode.latest_version}.
// 295:         EOS
// 296:       end
// 297:
// 298:       sig { returns(String) }
// 299:       def self.update_instructions
// 300:         software_update_location = if MacOS.version >= "13"
// 301:           "System Settings"
// 302:         else
// 303:           "System Preferences"
// 304:         end
// 305:
// 306:         <<~EOS
// 307:           Update them from Software Update in #{software_update_location}.
// 308:
// 309:           #{reinstall_instructions(reason: "show you any updates")}
// 310:         EOS
// 311:       end
// 312:
// 313:       sig { returns(String) }
// 314:       def self.installation_then_reinstall_instructions
// 315:         <<~EOS
// 316:           #{installation_instructions}
// 317:           #{reinstall_instructions}
// 318:         EOS
// 319:       end
// 320:
// 321:       # Bump these when the new version is distributed through Software Update
// 322:       # and our CI systems have been updated.
// 323:       sig { returns(String) }
// 324:       def self.latest_clang_version
// 325:         case MacOS.version
// 326:         when "27" then "2100.3.20.102"
// 327:         when "26", "15" then "1700.6.4.2"
// 328:         when "14" then "1600.0.26.6"
// 329:         when "13" then "1500.1.0.2.5"
// 330:         when "12" then "1400.0.29.202"
// 331:         when "11" then "1300.0.29.30"
// 332:         else           "1200.0.32.29"
// 333:         end
// 334:       end
// 335:
// 336:       # Bump these if things are badly broken (e.g. no SDK for this macOS)
// 337:       # without this. Generally this will be the first stable CLT release on
// 338:       # that macOS version.
// 339:       sig { returns(String) }
// 340:       def self.minimum_version
// 341:         macos = MacOS.version
// 342:         case macos
// 343:         when "15" then "16.0.0"
// 344:         when "14" then "15.0.0"
// 345:         when "13" then "14.0.0"
// 346:         when "12" then "13.0.0"
// 347:         when "11" then "12.5.0"
// 348:         when "10.15" then "11.0.0"
// 349:         else
// 350:           "#{macos}.0.0"
// 351:         end
// 352:       end
// 353:
// 354:       sig { returns(T::Boolean) }
// 355:       def self.below_minimum_version?
// 356:         return false unless installed?
// 357:
// 358:         version < minimum_version
// 359:       end
// 360:
// 361:       sig { returns(T::Boolean) }
// 362:       def self.outdated?
// 363:         clang_version = detect_clang_version
// 364:         return false unless clang_version
// 365:
// 366:         ::Version.new(clang_version) < latest_clang_version
// 367:       end
// 368:
// 369:       sig { returns(T.nilable(String)) }
// 370:       def self.detect_clang_version
// 371:         version_output = Utils.popen_read("#{PKG_PATH}/usr/bin/clang", "--version")
// 372:         version_output[/clang-(\d+(\.\d+)+)/, 1]
// 373:       end
// 374:
// 375:       sig { returns(T.nilable(String)) }
// 376:       def self.detect_version_from_clang_version
// 377:         clang_version = detect_clang_version&.sub(/\A(\d+)(\d)(\d)\..*/, "\\1.\\2.\\3")
// 378:         return if clang_version.nil?
// 379:
// 380:         MacOS::Xcode.detect_version_from_clang_version(Version.new(clang_version))
// 381:       end
// 382:
// 383:       # Version string (a pretty long one) of the CLT package.
// 384:       # Note that the different ways of installing the CLTs lead to different
// 385:       # version numbers.
// 386:       #
// 387:       # @api internal
// 388:       sig { returns(::Version) }
// 389:       def self.version
// 390:         if @version ||= T.let(detect_version, T.nilable(String))
// 391:           ::Version.new @version
// 392:         else
// 393:           ::Version::NULL
// 394:         end
// 395:       end
// 396:
// 397:       sig { returns(T.nilable(String)) }
// 398:       def self.detect_version
// 399:         version = T.let(nil, T.nilable(String))
// 400:         if File.exist?("#{PKG_PATH}/usr/bin/clang")
// 401:           version = MacOS.pkgutil_info(EXECUTABLE_PKG_ID)[/version: (.+)$/, 1]
// 402:           return version if version
// 403:         end
// 404:
// 405:         detect_version_from_clang_version
// 406:       end
// 407:     end
// 408:   end
// 409: end
