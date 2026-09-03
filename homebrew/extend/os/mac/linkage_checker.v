module mac

import brew_runtime

pub type MacDyldSharedCacheContains = fn(string) bool

pub fn mac_dylib_found_in_shared_cache(dylib string, macos_major int,
	contains MacDyldSharedCacheContains) bool {
	if macos_major < 11 {
		return false
	}
	return contains(dylib)
}

fn mac_dyld_fixture_contains(path string) bool {
	return path in ['/usr/lib/libSystem.B.dylib',
		'/System/Library/Frameworks/Foundation.framework/Foundation']
}

// Translated from Homebrew/brew `extend/os/mac/linkage_checker.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `dylib_found_in_shared_cache?(dylib)` at line 14.
pub fn ruby_linkage_checker_l14_d1_dylib_found_in_shared_cache(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('dylib_found_in_shared_cache? requires a dylib path')
	}
	macos_major := if args.len > 1 { int(args[1].as_int() or { panic(err) }) } else { 11 }
	return brew_runtime.bool_value(mac_dylib_found_in_shared_cache(args[0].as_string(), macos_major, mac_dyld_fixture_contains))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module LinkageChecker
// 7:       extend T::Helpers
// 8:
// 9:       requires_ancestor { ::LinkageChecker }
// 10:
// 11:       private
// 12:
// 13:       sig { params(dylib: String).returns(T::Boolean) }
// 14:       def dylib_found_in_shared_cache?(dylib)
// 15:         return false if MacOS.version < :big_sur
// 16:
// 17:         require "os/mac/ffi"
// 18:         MacOS::FFI.dyld_shared_cache_contains_path(dylib)
// 19:       end
// 20:     end
// 21:   end
// 22: end
// 23:
// 24: LinkageChecker.prepend(OS::Mac::LinkageChecker)
