module ffi

// Translated from Homebrew/brew `os/mac/ffi/dyld.rb`.
// The original source is retained below until every stub has a typed V body.
pub type DyldSharedCacheChecker = fn(string) bool

pub fn dyld_shared_cache_contains_path(path string, checker DyldSharedCacheChecker) bool {
	return checker(path)
}

// Ruby method `self.dyld_shared_cache_contains_path(path)` at line 16.
pub fn ruby_dyld_l16_d1_self_dyld_shared_cache_contains_path(path string,
	checker DyldSharedCacheChecker) bool {
	return dyld_shared_cache_contains_path(path, checker)
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
// 9:       extend NativeLibrary
// 10:
// 11:       use_library "/usr/lib/libSystem.B.dylib"
// 12:
// 13:       # mach-o/dyld.h:
// 14:       #   bool _dyld_shared_cache_contains_path(const char* path);
// 15:       sig { params(path: String).returns(T::Boolean) }
// 16:       def self.dyld_shared_cache_contains_path(path)
// 17:         function(
// 18:           "_dyld_shared_cache_contains_path",
// 19:           [Fiddle::TYPE_CONST_STRING],
// 20:           Fiddle::TYPE_BOOL,
// 21:         ).call(path)
// 22:       end
// 23:     end
// 24:   end
// 25: end
