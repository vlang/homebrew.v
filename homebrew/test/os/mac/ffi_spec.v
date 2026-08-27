module mac

import brew_runtime

// Translated from Homebrew/brew `test/os/mac/ffi_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "loads the macOS FFI wrapper modules" do` at line 7.
pub fn ruby_ffi_spec_l7_d1_loads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('loads', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi"
// 5:
// 6: RSpec.describe MacOS::FFI, :needs_macos do
// 7:   it "loads the macOS FFI wrapper modules" do
// 8:     expect(MacOS::FFI::CoreFoundation).to be_a(Module)
// 9:     expect(MacOS::FFI::Foundation).to be_a(Module)
// 10:     expect(MacOS::FFI::LaunchServices).to be_a(Module)
// 11:     expect(MacOS::FFI::NativeLibrary).to be_a(Module)
// 12:     expect(MacOS::FFI::ObjectiveC).to be_a(Module)
// 13:   end
// 14: end
