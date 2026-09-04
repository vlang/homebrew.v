module utils

// Translated from Homebrew/brew `extend/os/linux/cask/utils/trash.rb`.
pub struct LinuxTrashResult {
pub:
	trashed []string
	failed  []string
}

pub type FreedesktopTrashAction = fn ([]string) !LinuxTrashResult

pub fn linux_trash(paths []string, action FreedesktopTrashAction) !LinuxTrashResult {
	return action(paths)!
}
