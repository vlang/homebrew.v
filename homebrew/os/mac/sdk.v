module mac

import ruby
import os

pub struct MacSdk {
pub:
	version string
	path    string
	source  string
}

@[heap]
pub struct SdkLocator {
pub:
	prefix string
	source string
pub mut:
	loaded bool
	sdks   []MacSdk
}

pub fn new_sdk_locator(prefix string, source string) &SdkLocator {
	return &SdkLocator{ prefix: prefix, source: source }
}

fn sdk_version_parts(version string) []int {
	return version.split('.').map(it.int())
}

fn sdk_compare_versions(left string, right string) int {
	left_parts := sdk_version_parts(left)
	right_parts := sdk_version_parts(right)
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

fn sdk_strip_patch(version string) string {
	parts := version.split('.')
	if parts.len == 0 || parts[0].bytes().any(!it.is_digit()) {
		return ''
	}
	if parts[0].int() >= 11 {
		return parts[0]
	}
	return if parts.len >= 2 && parts[1].bytes().all(it.is_digit()) {
		parts[..2].join('.')
	} else {
		''
	}
}

pub fn read_sdk_version(settings_contents string) string {
	if settings_contents.trim_space() == '' || !settings_contents.contains('"Version"') {
		return ''
	}
	rest := settings_contents.all_after('"Version"')
	colon := rest.index(':') or { return '' }
	mut value := rest[colon + 1..].trim_space()
	if !value.starts_with('"') {
		return ''
	}
	value = value[1..]
	end := value.index('"') or { return '' }
	return sdk_strip_patch(value[..end])
}

fn sdk_versioned_directory(name string) bool {
	if !name.starts_with('MacOSX') || !name.ends_with('.sdk') || name == 'MacOSX.sdk' {
		return false
	}
	version := name['MacOSX'.len..name.len - '.sdk'.len]
	if version.starts_with('10.') {
		return version[3..].bytes().all(it.is_digit())
	}
	return !version.contains('.') && version.bytes().all(it.is_digit())
}

pub fn (mut locator SdkLocator) all_sdks() []MacSdk {
	if locator.loaded {
		return locator.sdks.clone()
	}
	locator.loaded = true
	if !os.is_dir(locator.prefix) {
		return []
	}
	mut found_versions := []string{}
	mut entries := os.ls(locator.prefix) or { [] }
	entries.sort()
	for name in entries {
		if !sdk_versioned_directory(name) {
			continue
		}
		path := os.join_path(locator.prefix, name)
		version := read_sdk_version(os.read_file(os.join_path(path, 'SDKSettings.json')) or { '' })
		if version == '' {
			continue
		}
		locator.sdks << MacSdk{ version: version, path: path, source: locator.source }
		found_versions << version
	}
	unversioned := os.join_path(locator.prefix, 'MacOSX.sdk')
	version := read_sdk_version(os.read_file(os.join_path(unversioned, 'SDKSettings.json')) or { '' })
	if version != '' && version !in found_versions {
		locator.sdks << MacSdk{ version: version, path: unversioned, source: locator.source }
	}
	return locator.sdks.clone()
}

pub fn (mut locator SdkLocator) sdk_for(version string) !MacSdk {
	for sdk in locator.all_sdks() {
		if sdk.version == version {
			return sdk
		}
	}
	return error('OS::Mac::BaseSDKLocator::NoSDKError')
}

pub fn (mut locator SdkLocator) latest_sdk() ?MacSdk {
	mut result := ?MacSdk(none)
	for sdk in locator.all_sdks() {
		if current := result {
			if sdk_compare_versions(sdk.version, current.version) > 0 {
				result = sdk
			}
		} else {
			result = sdk
		}
	}
	return result
}

pub fn (mut locator SdkLocator) sdk_if_applicable(requested_version string,
	os_version string) ?MacSdk {
	sdk := locator.sdk_for(if requested_version == '' { os_version } else { requested_version }) or {
		locator.latest_sdk() or { return none }
	}
	if requested_version == '' && sdk_compare_versions(sdk.version, os_version) < 0 {
		return none
	}
	return sdk
}

pub fn xcode_sdk_prefix(xcode_prefix string, prefix_exists bool, xcrun_platform_path string) string {
	primary := os.join_path(xcode_prefix, 'Platforms/MacOSX.platform/Developer/SDKs')
	return if prefix_exists || xcrun_platform_path == '' {
		primary
	} else {
		os.join_path(xcrun_platform_path, 'Developer/SDKs')
	}
}

pub fn clt_sdk_prefix(clt_path string) string {
	return os.join_path(clt_path, 'SDKs')
}

fn sdk_value(sdk MacSdk) ruby.Value {
	return ruby.structured_value('OS::Mac::SDK', sdk.path, {
		'version': sdk.version
		'path':    sdk.path
		'source':  sdk.source
	})
}

fn sdk_from_value(value ruby.Value) MacSdk {
	return MacSdk{
		version: value.attributes['version'] or { '' }
		path: value.attributes['path'] or { value.repr }
		source: value.attributes['source'] or { '' }
	}
}

fn sdk_locator_value(locator &SdkLocator) ruby.Value {
	return ruby.structured_value('OS::Mac::BaseSDKLocator', locator.prefix, {
		'locator_address': u64(voidptr(locator)).str()
	})
}

fn sdk_locator_from_value(value ruby.Value) &SdkLocator {
	address := value.attributes['locator_address'] or { panic('invalid SDK locator receiver') }
	return unsafe { &SdkLocator(voidptr(address.u64())) }
}

// Translated from Homebrew/brew `os/mac/sdk.rb`.
