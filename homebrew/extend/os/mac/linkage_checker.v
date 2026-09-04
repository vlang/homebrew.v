module mac

import ruby

pub type MacDyldSharedCacheContains = fn (string) bool

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
