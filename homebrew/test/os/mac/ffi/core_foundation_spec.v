module ffi

import homebrew.os.mac.ffi as mac_ffi

// Translated from Homebrew/brew `test/os/mac/ffi/core_foundation_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "creates CoreFoundation strings, dictionaries and file URLs" do` at line 7.
pub fn ruby_core_foundation_spec_l7_d1_creates() bool {
	cf_string := mac_ffi.core_foundation_string_create('/tmp', 'UTF-8')
	key_callbacks := mac_ffi.core_foundation_constant('kCFTypeDictionaryKeyCallBacks', false)
	value_callbacks := mac_ffi.core_foundation_constant('kCFTypeDictionaryValueCallBacks', false)
	quarantine_key := mac_ffi.core_foundation_constant('kCFURLQuarantinePropertiesKey', true)
	dictionary := mac_ffi.core_foundation_dictionary_create({
		cf_string.address: cf_string
	})
	url := mac_ffi.core_foundation_url_create(cf_string)
	return !cf_string.is_null() && !key_callbacks.is_null() && !value_callbacks.is_null() && !quarantine_key.is_null() && !dictionary.is_null() && !url.is_null()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi/core_foundation"
// 5:
// 6: RSpec.describe MacOS::FFI::CoreFoundation, :needs_macos do
// 7:   it "creates CoreFoundation strings, dictionaries and file URLs" do
// 8:     string = described_class.string_create("/tmp")
// 9:     expect(string.null?).to be(false)
// 10:
// 11:     expect(described_class.type_dictionary_key_call_backs.null?).to be(false)
// 12:     expect(described_class.type_dictionary_value_call_backs.null?).to be(false)
// 13:     expect(described_class.url_quarantine_properties_key.null?).to be(false)
// 14:
// 15:     dictionary = described_class.dictionary_create({ string => string })
// 16:     expect(dictionary.null?).to be(false)
// 17:
// 18:     url = described_class.url_create_with_file_system_path(string)
// 19:     expect(url.null?).to be(false)
// 20:   end
// 21: end
