module bundle

import ruby

// Translated from Homebrew/brew `extend/os/linux/bundle/bundle.rb`.

pub fn prepend_pkgconf_path_if_needed(current_path string, pkgconf_opt_bin string,
	installed bool) string {
	if !installed {
		return current_path
	}
	if current_path.len == 0 {
		return pkgconf_opt_bin
	}
	return '${pkgconf_opt_bin}:${current_path}'
}
