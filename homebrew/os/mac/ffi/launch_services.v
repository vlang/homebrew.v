module ffi

import ruby

// Translated from Homebrew/brew `os/mac/ffi/launch_services.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.quarantine_agent_name_key = constant("kLSQuarantineAgentNameKey", dereference: true)` at line 21.
pub fn ruby_launch_services_l21_d1_self_quarantine_agent_name_key(args ...ruby.Value) ruby.Value {
	return native_pointer_value(core_foundation_constant('kLSQuarantineAgentNameKey', true))
}

// Ruby method `self.quarantine_type_key = constant("kLSQuarantineTypeKey", dereference: true)` at line 26.
pub fn ruby_launch_services_l26_d2_self_quarantine_type_key(args ...ruby.Value) ruby.Value {
	return native_pointer_value(core_foundation_constant('kLSQuarantineTypeKey', true))
}

// Ruby method `self.quarantine_type_web_download = constant("kLSQuarantineTypeWebDownload", dereference: true)` at line 31.
pub fn ruby_launch_services_l31_d3_self_quarantine_type_web_download(args ...ruby.Value) ruby.Value {
	return native_pointer_value(core_foundation_constant('kLSQuarantineTypeWebDownload', true))
}

// Ruby method `self.quarantine_data_url_key = constant("kLSQuarantineDataURLKey", dereference: true)` at line 36.
pub fn ruby_launch_services_l36_d4_self_quarantine_data_url_key(args ...ruby.Value) ruby.Value {
	return native_pointer_value(core_foundation_constant('kLSQuarantineDataURLKey', true))
}

// Ruby method `self.quarantine_origin_url_key = constant("kLSQuarantineOriginURLKey", dereference: true)` at line 41.
pub fn ruby_launch_services_l41_d5_self_quarantine_origin_url_key(args ...ruby.Value) ruby.Value {
	return native_pointer_value(core_foundation_constant('kLSQuarantineOriginURLKey', true))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi/native_library"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module FFI
// 9:       # LaunchServices.framework wrapper
// 10:       module LaunchServices
// 11:         extend NativeLibrary
// 12:
// 13:         use_library(
// 14:           "/System/Library/Frameworks/CoreServices.framework/Versions/A/" \
// 15:           "Frameworks/LaunchServices.framework/Versions/A/LaunchServices",
// 16:         )
// 17:
// 18:         # LaunchServices/LSQuarantine.h:
// 19:         #   extern const CFStringRef kLSQuarantineAgentNameKey;
// 20:         sig { returns(Fiddle::Pointer) }
// 21:         def self.quarantine_agent_name_key = constant("kLSQuarantineAgentNameKey", dereference: true)
// 22:
// 23:         # LaunchServices/LSQuarantine.h:
// 24:         #   extern const CFStringRef kLSQuarantineTypeKey;
// 25:         sig { returns(Fiddle::Pointer) }
// 26:         def self.quarantine_type_key = constant("kLSQuarantineTypeKey", dereference: true)
// 27:
// 28:         # LaunchServices/LSQuarantine.h:
// 29:         #   extern const CFStringRef kLSQuarantineTypeWebDownload;
// 30:         sig { returns(Fiddle::Pointer) }
// 31:         def self.quarantine_type_web_download = constant("kLSQuarantineTypeWebDownload", dereference: true)
// 32:
// 33:         # LaunchServices/LSQuarantine.h:
// 34:         #   extern const CFStringRef kLSQuarantineDataURLKey;
// 35:         sig { returns(Fiddle::Pointer) }
// 36:         def self.quarantine_data_url_key = constant("kLSQuarantineDataURLKey", dereference: true)
// 37:
// 38:         # LaunchServices/LSQuarantine.h:
// 39:         #   extern const CFStringRef kLSQuarantineOriginURLKey;
// 40:         sig { returns(Fiddle::Pointer) }
// 41:         def self.quarantine_origin_url_key = constant("kLSQuarantineOriginURLKey", dereference: true)
// 42:       end
// 43:     end
// 44:   end
// 45: end
