module dev_cmd

import ruby

// Translated from Homebrew/brew `extend/os/mac/dev-cmd/bottle.rb`.
pub fn mac_bottle_tar_args() []string {
	return ['--no-mac-metadata', '--no-acls', '--no-xattrs']
}

pub fn mac_bottle_gnu_tar(opt_bin string) string {
	return ruby.join_path(opt_bin, 'gtar')
}
