module ffi

import homebrew.os.mac.ffi as mac_ffi

// Translated from Homebrew/brew `test/os/mac/ffi/objective_c_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "looks up Objective-C classes, selectors and sends messages" do` at line 7.
pub fn ruby_objective_c_spec_l7_d1_looks() bool {
	file_manager_class := mac_ffi.objective_c_class_get('NSFileManager')
	selector := mac_ffi.objective_c_selector('defaultManager')
	file_manager := mac_ffi.objective_c_message_send(file_manager_class, 'defaultManager', []int{}, 1, []mac_ffi.NativePointer{})
	return !file_manager_class.is_null() && !selector.is_null() && !file_manager.is_null()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi/objective_c"
// 5:
// 6: RSpec.describe MacOS::FFI::ObjectiveC, :needs_macos do
// 7:   it "looks up Objective-C classes, selectors and sends messages" do
// 8:     file_manager_class = described_class.class_get("NSFileManager")
// 9:     expect(file_manager_class.null?).to be(false)
// 10:
// 11:     expect(described_class.selector("defaultManager").null?).to be(false)
// 12:
// 13:     file_manager = described_class.message_send(
// 14:       file_manager_class,
// 15:       "defaultManager",
// 16:       [],
// 17:       Fiddle::TYPE_VOIDP,
// 18:     )
// 19:     expect(file_manager.null?).to be(false)
// 20:   end
// 21: end
