module ffi

// Translated from Homebrew/brew `os/mac/ffi/dyld.rb`.
pub type DyldSharedCacheChecker = fn (string) bool

pub fn dyld_shared_cache_contains_path(path string, checker DyldSharedCacheChecker) bool {
	return checker(path)
}
