module ffi

import homebrew.os.mac.ffi as mac_ffi

// Translated from Homebrew/brew `test/os/mac/ffi/security_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "uses designated requirements to identify signed code" do` at line 7.
pub fn ruby_security_spec_l7_d1_uses() bool {
	paths := ['/bin/ls', '/bin/cat']
	requirement := mac_ffi.security_designated_requirement('/bin/ls', paths, map[string]string{}) or { return false }
	ls_matches := mac_ffi.security_requirement_match('/bin/ls', requirement, paths, map[string]string{}) or { return false }
	cat_matches := mac_ffi.security_requirement_match('/bin/cat', requirement, paths, map[string]string{}) or { return false }
	missing := mac_ffi.security_requirement_match('/does/not/exist', requirement, paths, map[string]string{})
	return requirement.contains('identifier "com.apple.ls"') && ls_matches && !cat_matches && missing == none
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi/security"
// 5:
// 6: RSpec.describe MacOS::FFI::Security, :needs_macos do
// 7:   it "uses designated requirements to identify signed code" do
// 8:     requirement = described_class.designated_requirement("/bin/ls")
// 9:     expect(requirement).not_to be_nil
// 10:
// 11:     if requirement
// 12:       aggregate_failures do
// 13:         expect(requirement).to include('identifier "com.apple.ls"')
// 14:         expect(described_class.requirement_match("/bin/ls", requirement)).to be(true)
// 15:         expect(described_class.requirement_match("/bin/cat", requirement)).to be(false)
// 16:         expect(described_class.requirement_match("/does/not/exist", requirement)).to be_nil
// 17:       end
// 18:     end
// 19:   end
// 20: end
