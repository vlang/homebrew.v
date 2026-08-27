module ffi

import brew_runtime

// Translated from Homebrew/brew `test/os/mac/ffi/xattr_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "replaces destination extended attributes with source extended attributes" do` at line 8.
pub fn ruby_xattr_spec_l8_d1_replaces(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replaces', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi/xattr"
// 5:
// 6: RSpec.describe MacOS::FFI, :needs_macos do
// 7:   describe ".copy_xattrs" do
// 8:     it "replaces destination extended attributes with source extended attributes" do
// 9:       mktmpdir do |tmpdir|
// 10:         source = tmpdir/"source"
// 11:         destination = tmpdir/"destination"
// 12:         source.write("source")
// 13:         destination.write("destination")
// 14:
// 15:         described_class.set_xattr(source.to_s, "com.homebrew.test.source", "source")
// 16:         described_class.set_xattr(destination.to_s, "com.homebrew.test.destination", "destination")
// 17:
// 18:         described_class.copy_xattrs(source.to_s, destination.to_s)
// 19:
// 20:         destination_xattrs = described_class.list_xattrs(destination.to_s)
// 21:         expect(destination_xattrs).to include("com.homebrew.test.source")
// 22:         expect(destination_xattrs).not_to include("com.homebrew.test.destination")
// 23:         expect(described_class.get_xattr(destination.to_s, "com.homebrew.test.source")).to eq("source")
// 24:       end
// 25:     end
// 26:   end
// 27: end
