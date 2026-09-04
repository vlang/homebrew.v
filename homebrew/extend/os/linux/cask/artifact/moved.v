module artifact

import ruby

// Translated from Homebrew/brew `extend/os/linux/cask/artifact/moved.rb`.
pub fn linux_backup_copy_args(target string, source string) []string {
	return ['--reflink=auto', '-pR', target, source]
}
