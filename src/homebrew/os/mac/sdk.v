module mac

import brew_runtime

// Translated from Homebrew/brew `os/mac/sdk.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :version` at line 14.
pub fn ruby_sdk_l14_d1_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby attr_reader `attr_reader :path` at line 17.
pub fn ruby_sdk_l17_d2_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby attr_reader `attr_reader :source` at line 20.
pub fn ruby_sdk_l20_d3_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source', ...args)
}

// Ruby method `initialize(version, path, source)` at line 23.
pub fn ruby_sdk_l23_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize` at line 40.
pub fn ruby_sdk_l40_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `sdk_for(version)` at line 46.
pub fn ruby_sdk_l46_d6_sdk_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sdk_for', ...args)
}

// Ruby method `all_sdks` at line 54.
pub fn ruby_sdk_l54_d7_all_sdks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('all_sdks', ...args)
}

// Ruby method `sdk_if_applicable(version = nil)` at line 84.
pub fn ruby_sdk_l84_d8_sdk_if_applicable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sdk_if_applicable', ...args)
}

// Ruby method `source; end` at line 104.
pub fn ruby_sdk_l104_d9_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source', ...args)
}

// Ruby method `sdk_prefix; end` at line 109.
pub fn ruby_sdk_l109_d10_sdk_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sdk_prefix', ...args)
}

// Ruby method `latest_sdk` at line 112.
pub fn ruby_sdk_l112_d11_latest_sdk(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('latest_sdk', ...args)
}

// Ruby method `read_sdk_version(sdk_path)` at line 117.
pub fn ruby_sdk_l117_d12_read_sdk_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('read_sdk_version', ...args)
}

// Ruby method `source` at line 141.
pub fn ruby_sdk_l141_d13_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source', ...args)
}

// Ruby method `sdk_prefix` at line 148.
pub fn ruby_sdk_l148_d14_sdk_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sdk_prefix', ...args)
}

// Ruby method `source` at line 167.
pub fn ruby_sdk_l167_d15_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('source', ...args)
}

// Ruby method `sdk_prefix` at line 176.
pub fn ruby_sdk_l176_d16_sdk_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sdk_prefix', ...args)
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
