module os

import brew_runtime

// Translated from Homebrew/brew `os/mac.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.version` at line 32.
pub fn ruby_mac_l32_d1_self_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.version', ...args)
}

// Ruby method `self.full_version` at line 41.
pub fn ruby_mac_l41_d2_self_full_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.full_version', ...args)
}

// Ruby method `self.full_version=(version)` at line 54.
pub fn ruby_mac_l54_d3_self_full_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.full_version=', ...args)
}

// Ruby method `self.latest_sdk_version` at line 60.
pub fn ruby_mac_l60_d4_self_latest_sdk_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.latest_sdk_version', ...args)
}

// Ruby method `self.preferred_perl_version` at line 67.
pub fn ruby_mac_l67_d5_self_preferred_perl_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.preferred_perl_version', ...args)
}

// Ruby method `self.languages` at line 78.
pub fn ruby_mac_l78_d6_self_languages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.languages', ...args)
}

// Ruby method `self.language` at line 93.
pub fn ruby_mac_l93_d7_self_language(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.language', ...args)
}

// Ruby method `self.active_developer_dir` at line 98.
pub fn ruby_mac_l98_d8_self_active_developer_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.active_developer_dir', ...args)
}

// Ruby method `self.sdk_locator` at line 106.
pub fn ruby_mac_l106_d9_self_sdk_locator(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sdk_locator', ...args)
}

// Ruby method `self.sdk(version = nil)` at line 124.
pub fn ruby_mac_l124_d10_self_sdk(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sdk', ...args)
}

// Ruby method `self.sdk_for_formula(formula, version = nil, check_only_runtime_requirements: false)` at line 138.
pub fn ruby_mac_l138_d11_self_sdk_for_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sdk_for_formula', ...args)
}

// Ruby method `self.sdk_path(version = nil)` at line 156.
pub fn ruby_mac_l156_d12_self_sdk_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sdk_path', ...args)
}

// Ruby method `self.sdk_path_if_needed(version = nil)` at line 168.
pub fn ruby_mac_l168_d13_self_sdk_path_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sdk_path_if_needed', ...args)
}

// Ruby method `self.app_with_bundle_id(*ids)` at line 174.
pub fn ruby_mac_l174_d14_self_app_with_bundle_id(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.app_with_bundle_id', ...args)
}

// Ruby method `self.mdfind(*ids)` at line 187.
pub fn ruby_mac_l187_d15_self_mdfind(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.mdfind', ...args)
}

// Ruby method `self.pkgutil_info(id)` at line 195.
pub fn ruby_mac_l195_d16_self_pkgutil_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.pkgutil_info', ...args)
}

// Ruby method `self.mdfind_query(*ids)` at line 203.
pub fn ruby_mac_l203_d17_self_mdfind_query(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.mdfind_query', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "macos_version"
// 5:
// 6: require "os/mac/xcode"
// 7: require "os/mac/sdk"
// 8:
// 9: module OS
// 10:   # Helper module for querying system information on macOS.
// 11:   module Mac
// 12:     extend Utils::Output::Mixin
// 13:
// 14:     raise "Loaded OS::Mac on generic OS!" if ENV["HOMEBREW_TEST_GENERIC_OS"]
// 15:
// 16:     # This check is the only acceptable or necessary one in this file.
// 17:     # rubocop:disable Homebrew/MoveToExtendOS
// 18:     raise "Loaded OS::Mac on Linux!" if OS.linux?
// 19:     # rubocop:enable Homebrew/MoveToExtendOS
// 20:
// 21:     # Provide MacOS alias for backwards compatibility and nicer APIs.
// 22:     ::MacOS = OS::Mac
// 23:
// 24:     VERSION = T.let(ENV.fetch("HOMEBREW_MACOS_VERSION").chomp.freeze, String)
// 25:     private_constant :VERSION
// 26:
// 27:     # This can be compared to numerics, strings, or symbols
// 28:     # using the standard Ruby Comparable methods.
// 29:     #
// 30:     # @api internal
// 31:     sig { returns(MacOSVersion) }
// 32:     def self.version
// 33:       @version ||= T.let(full_version.strip_patch, T.nilable(MacOSVersion))
// 34:     end
// 35:
// 36:     # This can be compared to numerics, strings, or symbols
// 37:     # using the standard Ruby Comparable methods.
// 38:     #
// 39:     # @api internal
// 40:     sig { returns(MacOSVersion) }
// 41:     def self.full_version
// 42:       @full_version ||= T.let(nil, T.nilable(MacOSVersion))
// 43:       # HOMEBREW_FAKE_MACOS is set system-wide in the macOS 11-arm64-cross image
// 44:       # for building a macOS 11 Portable Ruby on macOS 12
// 45:       # odisabled: remove support for Big Sur September (or later) 2027
// 46:       @full_version ||= if (fake_macos = ENV.fetch("HOMEBREW_FAKE_MACOS", nil))
// 47:         MacOSVersion.new(fake_macos)
// 48:       else
// 49:         MacOSVersion.new(VERSION)
// 50:       end
// 51:     end
// 52:
// 53:     sig { params(version: String).void }
// 54:     def self.full_version=(version)
// 55:       @full_version = MacOSVersion.new(version.chomp)
// 56:       @version = nil
// 57:     end
// 58:
// 59:     sig { returns(::Version) }
// 60:     def self.latest_sdk_version
// 61:       # TODO: bump version when new Xcode macOS SDK is released
// 62:       # NOTE: We only track the major version of the SDK.
// 63:       ::Version.new("26")
// 64:     end
// 65:
// 66:     sig { returns(String) }
// 67:     def self.preferred_perl_version
// 68:       if version >= :sonoma
// 69:         "5.34"
// 70:       elsif version >= :big_sur
// 71:         "5.30"
// 72:       else
// 73:         "5.18"
// 74:       end
// 75:     end
// 76:
// 77:     sig { returns(T::Array[String]) }
// 78:     def self.languages
// 79:       @languages ||= T.let(nil, T.nilable(T::Array[String]))
// 80:       return @languages if @languages
// 81:
// 82:       os_langs = Utils.popen_read("defaults", "read", "-g", "AppleLanguages")
// 83:       if os_langs.blank?
// 84:         # User settings don't exist so check the system-wide one.
// 85:         os_langs = Utils.popen_read("defaults", "read", "/Library/Preferences/.GlobalPreferences", "AppleLanguages")
// 86:       end
// 87:       os_langs = T.cast(os_langs.scan(/[^ \n"(),]+/), T::Array[String])
// 88:
// 89:       @languages = os_langs
// 90:     end
// 91:
// 92:     sig { returns(T.nilable(String)) }
// 93:     def self.language
// 94:       languages.first
// 95:     end
// 96:
// 97:     sig { returns(String) }
// 98:     def self.active_developer_dir
// 99:       @active_developer_dir ||= T.let(
// 100:         Utils.popen_read("/usr/bin/xcode-select", "-print-path").strip,
// 101:         T.nilable(String),
// 102:       )
// 103:     end
// 104:
// 105:     sig { returns(T.any(CLTSDKLocator, XcodeSDKLocator)) }
// 106:     def self.sdk_locator
// 107:       if CLT.installed?
// 108:         CLT.sdk_locator
// 109:       else
// 110:         Xcode.sdk_locator
// 111:       end
// 112:     end
// 113:
// 114:     # If a specific SDK is requested:
// 115:     #
// 116:     #   1. The requested SDK is returned, if it's installed.
// 117:     #   2. If the requested SDK is not installed, the newest SDK (if any SDKs
// 118:     #      are available) is returned.
// 119:     #   3. If no SDKs are available, nil is returned.
// 120:     #
// 121:     # If no specific SDK is requested, the SDK matching the OS version is returned,
// 122:     # if available. Otherwise, the latest SDK is returned.
// 123:     sig { params(version: T.nilable(MacOSVersion)).returns(T.nilable(SDK)) }
// 124:     def self.sdk(version = nil)
// 125:       sdk_locator.sdk_if_applicable(version)
// 126:     end
// 127:
// 128:     # Returns the path to the SDK needed based on the formula's requirements.
// 129:     #
// 130:     # @api public
// 131:     sig {
// 132:       params(
// 133:         formula:                         Formula,
// 134:         version:                         T.nilable(MacOSVersion),
// 135:         check_only_runtime_requirements: T::Boolean,
// 136:       ).returns(T.nilable(SDK))
// 137:     }
// 138:     def self.sdk_for_formula(formula, version = nil, check_only_runtime_requirements: false)
// 139:       # If the formula requires Xcode, don't return the CLT SDK
// 140:       # If check_only_runtime_requirements is true, don't necessarily return the
// 141:       # Xcode SDK if the XcodeRequirement is only a build or test requirement.
// 142:       return Xcode.sdk if formula.requirements.any? do |req|
// 143:         next false unless req.is_a? XcodeRequirement
// 144:         next false if check_only_runtime_requirements && req.build? && !req.test?
// 145:
// 146:         true
// 147:       end
// 148:
// 149:       sdk(version)
// 150:     end
// 151:
// 152:     # Returns the path to an SDK or nil, following the rules set by {sdk}.
// 153:     #
// 154:     # @api public
// 155:     sig { params(version: T.nilable(MacOSVersion)).returns(T.nilable(::Pathname)) }
// 156:     def self.sdk_path(version = nil)
// 157:       s = sdk(version)
// 158:       s&.path
// 159:     end
// 160:
// 161:     # Prefer CLT SDK when both Xcode and the CLT are installed.
// 162:     # Expected results:
// 163:     # 1. On Xcode-only systems, return the Xcode SDK.
// 164:     # 2. On CLT-only systems, return the CLT SDK.
// 165:     #
// 166:     # @api public
// 167:     sig { params(version: T.nilable(MacOSVersion)).returns(T.nilable(::Pathname)) }
// 168:     def self.sdk_path_if_needed(version = nil)
// 169:       odeprecated "MacOS.sdk_path_if_needed", "MacOS.sdk_path"
// 170:       sdk_path(version)
// 171:     end
// 172:
// 173:     sig { params(ids: String).returns(T.nilable(::Pathname)) }
// 174:     def self.app_with_bundle_id(*ids)
// 175:       require "bundle_version"
// 176:
// 177:       paths = mdfind(*ids).filter_map do |bundle_path|
// 178:         ::Pathname.new(bundle_path) if bundle_path.exclude?("/Backups.backupdb/")
// 179:       end
// 180:       return paths.first unless paths.all? { |bp| (bp/"Contents/Info.plist").exist? }
// 181:
// 182:       # Prefer newest one, if we can find it.
// 183:       paths.max_by { |bundle_path| Homebrew::BundleVersion.from_info_plist(bundle_path/"Contents/Info.plist") }
// 184:     end
// 185:
// 186:     sig { params(ids: String).returns(T::Array[String]) }
// 187:     def self.mdfind(*ids)
// 188:       @mdfind ||= T.let(nil, T.nilable(T::Hash[T::Array[String], T::Array[String]]))
// 189:       (@mdfind ||= {}).fetch(ids) do
// 190:         @mdfind[ids] = Utils.popen_read("/usr/bin/mdfind", mdfind_query(*ids)).split("\n")
// 191:       end
// 192:     end
// 193:
// 194:     sig { params(id: String).returns(String) }
// 195:     def self.pkgutil_info(id)
// 196:       @pkginfo ||= T.let(nil, T.nilable(T::Hash[String, String]))
// 197:       (@pkginfo ||= {}).fetch(id) do |key|
// 198:         @pkginfo[key] = Utils.popen_read("/usr/sbin/pkgutil", "--pkg-info", key).strip
// 199:       end
// 200:     end
// 201:
// 202:     sig { params(ids: String).returns(String) }
// 203:     def self.mdfind_query(*ids)
// 204:       ids.map! { |id| "kMDItemCFBundleIdentifier == #{id}" }.join(" || ")
// 205:     end
// 206:   end
// 207: end
