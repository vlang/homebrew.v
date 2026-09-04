module mac

import ruby

// Translated from Homebrew/brew `extend/os/mac/cleanup.rb`.

pub fn use_system_ruby(force_vendor_ruby bool, developer bool, ruby_from_path_present bool) bool {
	return !force_vendor_ruby && developer && ruby_from_path_present
}
