module artifact

import ruby
import homebrew.cask as cask_macos
import homebrew.cask.artifact as base_artifact

pub fn mac_moved_undeletable(target string) bool {
	return cask_macos.macos_undeletable(target)
}

pub fn mac_moved_backup_copy_args(target string, source string, macos_major int,
	target_device u64, source_parent_device u64) []string {
	base := base_artifact.moved_backup_copy_args(target, source)
	if macos_major < 14 || target_device != source_parent_device {
		return base
	}
	mut arguments := ['-c']
	arguments << base
	return arguments
}

// Translated from Homebrew/brew `extend/os/mac/cask/artifact/moved.rb`.
