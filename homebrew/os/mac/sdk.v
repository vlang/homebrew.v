module mac

import brew_runtime
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

fn sdk_value(sdk MacSdk) brew_runtime.Value {
	return brew_runtime.structured_value('OS::Mac::SDK', sdk.path, {
		'version': sdk.version
		'path':    sdk.path
		'source':  sdk.source
	})
}

fn sdk_from_value(value brew_runtime.Value) MacSdk {
	return MacSdk{
		version: value.attributes['version'] or { '' }
		path: value.attributes['path'] or { value.repr }
		source: value.attributes['source'] or { '' }
	}
}

fn sdk_locator_value(locator &SdkLocator) brew_runtime.Value {
	return brew_runtime.structured_value('OS::Mac::BaseSDKLocator', locator.prefix, {
		'locator_address': u64(voidptr(locator)).str()
	})
}

fn sdk_locator_from_value(value brew_runtime.Value) &SdkLocator {
	address := value.attributes['locator_address'] or { panic('invalid SDK locator receiver') }
	return unsafe { &SdkLocator(voidptr(address.u64())) }
}

// Translated from Homebrew/brew `os/mac/sdk.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :version` at line 14.
pub fn ruby_sdk_l14_d1_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(sdk_from_value(args[0]).version)
}

// Ruby attr_reader `attr_reader :path` at line 17.
pub fn ruby_sdk_l17_d2_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(sdk_from_value(args[0]).path)
}

// Ruby attr_reader `attr_reader :source` at line 20.
pub fn ruby_sdk_l20_d3_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', sdk_from_value(args[0]).source)
}

// Ruby method `initialize(version, path, source)` at line 23.
pub fn ruby_sdk_l23_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 { panic('SDK#initialize requires version, path, and source') }
	return sdk_value(MacSdk{ version: args[0].as_string(), path: args[1].as_string(), source: args[2].as_string() })
}

// Ruby method `initialize` at line 40.
pub fn ruby_sdk_l40_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return sdk_locator_value(new_sdk_locator(if args.len > 0 { args[0].as_string() } else { '' }, if args.len > 1 {
		args[1].as_string()
	} else {
		'clt'
	}))
}

// Ruby method `sdk_for(version)` at line 46.
pub fn ruby_sdk_l46_d6_sdk_for(args ...brew_runtime.Value) brew_runtime.Value {
	mut locator := sdk_locator_from_value(args[0])
	return sdk_value(locator.sdk_for(args[1].as_string()) or { panic(err) })
}

// Ruby method `all_sdks` at line 54.
pub fn ruby_sdk_l54_d7_all_sdks(args ...brew_runtime.Value) brew_runtime.Value {
	mut locator := sdk_locator_from_value(args[0])
	return brew_runtime.array_value(locator.all_sdks().map(sdk_value(it)))
}

// Ruby method `sdk_if_applicable(version = nil)` at line 84.
pub fn ruby_sdk_l84_d8_sdk_if_applicable(args ...brew_runtime.Value) brew_runtime.Value {
	mut locator := sdk_locator_from_value(args[0])
	requested := if args.len > 1 && args[1].type_name != 'NilClass' {
		args[1].as_string()
	} else {
		''
	}
	os_version := if args.len > 2 { args[2].as_string() } else { requested }
	sdk := locator.sdk_if_applicable(requested, os_version) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return sdk_value(sdk)
}

// Ruby method `source; end` at line 104.
pub fn ruby_sdk_l104_d9_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', sdk_locator_from_value(args[0]).source)
}

// Ruby method `sdk_prefix; end` at line 109.
pub fn ruby_sdk_l109_d10_sdk_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(sdk_locator_from_value(args[0]).prefix)
}

// Ruby method `latest_sdk` at line 112.
pub fn ruby_sdk_l112_d11_latest_sdk(args ...brew_runtime.Value) brew_runtime.Value {
	mut locator := sdk_locator_from_value(args[0])
	sdk := locator.latest_sdk() or { return brew_runtime.object_value('NilClass', 'nil') }
	return sdk_value(sdk)
}

// Ruby method `read_sdk_version(sdk_path)` at line 117.
pub fn ruby_sdk_l117_d12_read_sdk_version(args ...brew_runtime.Value) brew_runtime.Value {
	contents := if args.len > 0 && os.is_dir(args[0].as_string()) {
		os.read_file(os.join_path(args[0].as_string(), 'SDKSettings.json')) or { '' }
	} else if args.len > 0 { args[0].as_string() } else { '' }
	version := read_sdk_version(contents)
	return if version == '' {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		brew_runtime.string_value(version)
	}
}

// Ruby method `source` at line 141.
pub fn ruby_sdk_l141_d13_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', 'xcode')
}

// Ruby method `sdk_prefix` at line 148.
pub fn ruby_sdk_l148_d14_sdk_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(xcode_sdk_prefix(if args.len > 0 {
		args[0].as_string()
	} else {
		''
	}, args.len > 1 && args[1].bool_data, if args.len > 2 { args[2].as_string() } else { '' }))
}

// Ruby method `source` at line 167.
pub fn ruby_sdk_l167_d15_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', 'clt')
}

// Ruby method `sdk_prefix` at line 176.
pub fn ruby_sdk_l176_d16_sdk_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(clt_sdk_prefix(if args.len > 0 {
		args[0].as_string()
	} else {
		'/Library/Developer/CommandLineTools'
	}))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     # Class representing a macOS SDK.
// 9:     class SDK
// 10:       # 11.x SDKs are explicitly excluded - we want the MacOSX11.sdk symlink instead.
// 11:       VERSIONED_SDK_REGEX = /MacOSX(10\.\d+|\d+)\.sdk$/
// 12:
// 13:       sig { returns(MacOSVersion) }
// 14:       attr_reader :version
// 15:
// 16:       sig { returns(::Pathname) }
// 17:       attr_reader :path
// 18:
// 19:       sig { returns(Symbol) }
// 20:       attr_reader :source
// 21:
// 22:       sig { params(version: MacOSVersion, path: T.any(String, ::Pathname), source: Symbol).void }
// 23:       def initialize(version, path, source)
// 24:         @version = version
// 25:         @path = T.let(Pathname(path), ::Pathname)
// 26:         @source = source
// 27:       end
// 28:     end
// 29:
// 30:     # Base class for SDK locators.
// 31:     class BaseSDKLocator
// 32:       extend T::Helpers
// 33:       include SystemCommand::Mixin
// 34:
// 35:       abstract!
// 36:
// 37:       class NoSDKError < StandardError; end
// 38:
// 39:       sig { void }
// 40:       def initialize
// 41:         @all_sdks = T.let(nil, T.nilable(T::Array[SDK]))
// 42:         @sdk_prefix = T.let(nil, T.nilable(String))
// 43:       end
// 44:
// 45:       sig { params(version: MacOSVersion).returns(SDK) }
// 46:       def sdk_for(version)
// 47:         sdk = all_sdks.find { |s| s.version == version }
// 48:         raise NoSDKError if sdk.nil?
// 49:
// 50:         sdk
// 51:       end
// 52:
// 53:       sig { returns(T::Array[SDK]) }
// 54:       def all_sdks
// 55:         return @all_sdks if @all_sdks
// 56:
// 57:         @all_sdks = []
// 58:
// 59:         # Bail out if there is no SDK prefix at all
// 60:         return @all_sdks unless File.directory? sdk_prefix
// 61:
// 62:         found_versions = Set.new
// 63:
// 64:         Dir["#{sdk_prefix}/MacOSX*.sdk"].each do |sdk_path|
// 65:           next unless sdk_path.match?(SDK::VERSIONED_SDK_REGEX)
// 66:
// 67:           version = read_sdk_version(::Pathname.new(sdk_path))
// 68:           next if version.nil?
// 69:
// 70:           @all_sdks << SDK.new(version, sdk_path, source)
// 71:           found_versions << version
// 72:         end
// 73:
// 74:         # Use unversioned SDK only if we don't have one matching that version.
// 75:         sdk_path = ::Pathname.new("#{sdk_prefix}/MacOSX.sdk")
// 76:         if (version = read_sdk_version(sdk_path)) && found_versions.exclude?(version)
// 77:           @all_sdks << SDK.new(version, sdk_path, source)
// 78:         end
// 79:
// 80:         @all_sdks
// 81:       end
// 82:
// 83:       sig { params(version: T.nilable(MacOSVersion)).returns(T.nilable(SDK)) }
// 84:       def sdk_if_applicable(version = nil)
// 85:         sdk = begin
// 86:           if version.blank?
// 87:             sdk_for OS::Mac.version
// 88:           else
// 89:             sdk_for version
// 90:           end
// 91:         rescue NoSDKError
// 92:           latest_sdk
// 93:         end
// 94:         return if sdk.blank?
// 95:
// 96:         # On OSs lower than 11, whenever the major versions don't match,
// 97:         # only return an SDK older than the OS version if it was specifically requested
// 98:         return if version.blank? && sdk.version < OS::Mac.version
// 99:
// 100:         sdk
// 101:       end
// 102:
// 103:       sig { abstract.returns(Symbol) }
// 104:       def source; end
// 105:
// 106:       private
// 107:
// 108:       sig { abstract.returns(String) }
// 109:       def sdk_prefix; end
// 110:
// 111:       sig { returns(T.nilable(SDK)) }
// 112:       def latest_sdk
// 113:         all_sdks.max_by(&:version)
// 114:       end
// 115:
// 116:       sig { params(sdk_path: ::Pathname).returns(T.nilable(MacOSVersion)) }
// 117:       def read_sdk_version(sdk_path)
// 118:         sdk_settings = sdk_path/"SDKSettings.json"
// 119:         sdk_settings_string = sdk_settings.read if sdk_settings.exist?
// 120:
// 121:         return if sdk_settings_string.blank?
// 122:
// 123:         sdk_settings_json = JSON.parse(sdk_settings_string)
// 124:         return if sdk_settings_json.blank?
// 125:
// 126:         version_string = sdk_settings_json.fetch("Version", nil)
// 127:         return if version_string.blank?
// 128:
// 129:         begin
// 130:           MacOSVersion.new(version_string).strip_patch
// 131:         rescue MacOSVersion::Error
// 132:           nil
// 133:         end
// 134:       end
// 135:     end
// 136:     private_constant :BaseSDKLocator
// 137:
// 138:     # Helper class for locating the Xcode SDK.
// 139:     class XcodeSDKLocator < BaseSDKLocator
// 140:       sig { override.returns(Symbol) }
// 141:       def source
// 142:         :xcode
// 143:       end
// 144:
// 145:       private
// 146:
// 147:       sig { override.returns(String) }
// 148:       def sdk_prefix
// 149:         @sdk_prefix ||= begin
// 150:           # Xcode.prefix is pretty smart, so let's look inside to find the sdk
// 151:           sdk_prefix = "#{Xcode.prefix}/Platforms/MacOSX.platform/Developer/SDKs"
// 152:
// 153:           # Finally query Xcode itself (this is slow, so check it last)
// 154:           if !File.directory?(sdk_prefix) && (xcrun = ::DevelopmentTools.locate("xcrun"))
// 155:             sdk_platform_path = Utils.popen_read(xcrun, "--show-sdk-platform-path").chomp
// 156:             sdk_prefix = File.join(sdk_platform_path, "Developer", "SDKs")
// 157:           end
// 158:
// 159:           sdk_prefix
// 160:         end
// 161:       end
// 162:     end
// 163:
// 164:     # Helper class for locating the macOS Command Line Tools SDK.
// 165:     class CLTSDKLocator < BaseSDKLocator
// 166:       sig { override.returns(Symbol) }
// 167:       def source
// 168:         :clt
// 169:       end
// 170:
// 171:       private
// 172:
// 173:       # As of Xcode 10, the Unix-style headers are installed via a
// 174:       # separate package, so we can't rely on their being present.
// 175:       sig { override.returns(String) }
// 176:       def sdk_prefix
// 177:         @sdk_prefix ||= "#{CLT::PKG_PATH}/SDKs"
// 178:       end
// 179:     end
// 180:   end
// 181: end
