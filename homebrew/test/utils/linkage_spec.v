module utils

import brew_runtime

// Translated from Homebrew/brew `test/utils/linkage_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:suffix) { OS.mac? ? ".dylib" : ".so" }` at line 9.
pub fn ruby_linkage_spec_l9_d1_suffix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('suffix', ...args)
}

// Ruby it `it "returns true if the binary is linked to the library" do` at line 40.
pub fn ruby_linkage_spec_l40_d2_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false if the binary is not linked to the library" do` at line 46.
pub fn ruby_linkage_spec_l46_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "can check if the binary is linked to a non-brew library" do` at line 52.
pub fn ruby_linkage_spec_l52_d4_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/linkage"
// 5:
// 6: RSpec.describe Utils do
// 7:   test_each([:needs_macos, :needs_linux]) do |needs_os|
// 8:     describe "::binary_linked_to_library?", needs_os do
// 9:       let(:suffix) { OS.mac? ? ".dylib" : ".so" }
// 10:
// 11:       before do
// 12:         mktmpdir do |dir|
// 13:           (dir/"foo.h").write "void foo();"
// 14:           (dir/"foo.c").write <<~C
// 15:             #include <stdio.h>
// 16:             #include "foo.h"
// 17:             void foo() { printf("foo\\\\n"); }
// 18:           C
// 19:           (dir/"bar.c").write <<~C
// 20:             #include <stdio.h>
// 21:             void bar() { printf("bar\\\\n"); }
// 22:           C
// 23:           (dir/"test.c").write <<~C
// 24:             #include "foo.h"
// 25:             int main() { foo(); return 0; }
// 26:           C
// 27:
// 28:           system "cc", "-c", "-fpic", dir/"foo.c", "-o", dir/"foo.o"
// 29:           system "cc", "-c", "-fpic", dir/"bar.c", "-o", dir/"bar.o"
// 30:           dll_flag = OS.mac? ? "-dynamiclib" : "-shared"
// 31:           (HOMEBREW_PREFIX/"lib").mkdir
// 32:           system "cc", dll_flag, "-o", HOMEBREW_PREFIX/"lib/libbrewfoo#{suffix}", dir/"foo.o"
// 33:           system "cc", dll_flag, "-o", HOMEBREW_PREFIX/"lib/libbrewbar#{suffix}", dir/"bar.o"
// 34:           rpath_flag = "-Wl,-rpath,#{HOMEBREW_PREFIX}/lib" if OS.linux?
// 35:           system "cc", "-o", dir/"brewtest", dir/"test.c", *rpath_flag, "-L#{HOMEBREW_PREFIX/"lib"}", "-lbrewfoo"
// 36:           (HOMEBREW_PREFIX/"bin").install dir/"brewtest"
// 37:         end
// 38:       end
// 39:
// 40:       it "returns true if the binary is linked to the library" do
// 41:         result = described_class.binary_linked_to_library?(HOMEBREW_PREFIX/"bin/brewtest",
// 42:                                                            HOMEBREW_PREFIX/"lib/libbrewfoo#{suffix}")
// 43:         expect(result).to be true
// 44:       end
// 45:
// 46:       it "returns false if the binary is not linked to the library" do
// 47:         result = described_class.binary_linked_to_library?(HOMEBREW_PREFIX/"bin/brewtest",
// 48:                                                            HOMEBREW_PREFIX/"lib/libbrewbar#{suffix}")
// 49:         expect(result).to be false
// 50:       end
// 51:
// 52:       it "can check if the binary is linked to a non-brew library" do
// 53:         non_brew_library = "/usr/lib/libtest#{suffix}"
// 54:         shim = OS.mac? ? MachOShim : ELFShim
// 55:         allow_any_instance_of(shim).to receive(:dynamically_linked_libraries).and_return([non_brew_library])
// 56:         result = described_class.binary_linked_to_library?(HOMEBREW_PREFIX/"bin/brewtest", non_brew_library)
// 57:         expect(result).to be true
// 58:       end
// 59:     end
// 60:   end
// 61: end
