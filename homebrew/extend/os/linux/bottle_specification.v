module linux

import ruby

// Translated from Homebrew/brew `extend/os/linux/bottle_specification.rb`.

pub fn skip_relocation(tab_present bool, parsed_version_at_least_5_1_15 bool,
	base_skip_relocation bool) bool {
	return tab_present && parsed_version_at_least_5_1_15 && base_skip_relocation
}
