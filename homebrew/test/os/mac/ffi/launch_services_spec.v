module ffi

import homebrew.os.mac.ffi as mac_ffi

// Translated from Homebrew/brew `test/os/mac/ffi/launch_services_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "loads quarantine constants from LaunchServices" do` at line 7.
pub fn ruby_launch_services_spec_l7_d1_loads() bool {
	return !mac_ffi.core_foundation_constant('kLSQuarantineAgentNameKey', true).is_null() && !mac_ffi.core_foundation_constant('kLSQuarantineDataURLKey', true).is_null() && !mac_ffi.core_foundation_constant('kLSQuarantineOriginURLKey', true).is_null() && !mac_ffi.core_foundation_constant('kLSQuarantineTypeKey', true).is_null() && !mac_ffi.core_foundation_constant('kLSQuarantineTypeWebDownload', true).is_null()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi/launch_services"
// 5:
// 6: RSpec.describe MacOS::FFI::LaunchServices, :needs_macos do
// 7:   it "loads quarantine constants from LaunchServices" do
// 8:     expect(described_class.quarantine_agent_name_key.null?).to be(false)
// 9:     expect(described_class.quarantine_data_url_key.null?).to be(false)
// 10:     expect(described_class.quarantine_origin_url_key.null?).to be(false)
// 11:     expect(described_class.quarantine_type_key.null?).to be(false)
// 12:     expect(described_class.quarantine_type_web_download.null?).to be(false)
// 13:   end
// 14: end
