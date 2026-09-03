module ffi

import homebrew.os.mac.ffi as mac_ffi
import os

// Translated from Homebrew/brew `test/os/mac/ffi/native_library_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:library) do` at line 7.
pub fn ruby_native_library_spec_l7_d1_library() &mac_ffi.NativeLibrary {
	mut library := mac_ffi.new_native_library(map[string]u64{})
	library.use_library('/usr/lib/libSystem.B.dylib')
	return library
}

// Ruby method `self.process_id` at line 13.
pub fn ruby_native_library_spec_l13_d2_self_process_id() !int {
	mut library := ruby_native_library_spec_l7_d1_library()
	function := library.load_function('getpid', []int{}, 1)!
	return int(function.call()!)
}

// Ruby it `it "loads native functions from a system library" do` at line 19.
pub fn ruby_native_library_spec_l19_d3_loads() !bool {
	return ruby_native_library_spec_l13_d2_self_process_id()! == os.getpid()
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi/native_library"
// 5:
// 6: RSpec.describe MacOS::FFI::NativeLibrary, :needs_macos do
// 7:   let(:library) do
// 8:     Module.new do
// 9:       extend MacOS::FFI::NativeLibrary
// 10:
// 11:       use_library "/usr/lib/libSystem.B.dylib"
// 12:
// 13:       def self.process_id
// 14:         function("getpid", [], Fiddle::TYPE_INT).call
// 15:       end
// 16:     end
// 17:   end
// 18:
// 19:   it "loads native functions from a system library" do
// 20:     expect(library.process_id).to eq(Process.pid)
// 21:   end
// 22: end
