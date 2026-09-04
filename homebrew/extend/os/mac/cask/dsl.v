module cask

import ruby

pub fn mac_cask_dsl_os_version(full_version string) ?string {
	if full_version == '' {
		return none
	}
	return full_version
}

// Translated from Homebrew/brew `extend/os/mac/cask/dsl.rb`.
