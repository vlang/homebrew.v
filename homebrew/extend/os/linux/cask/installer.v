module cask

// Translated from Homebrew/brew `extend/os/linux/cask/installer.rb`.
pub fn check_linux_cask_requirements(cask_name string, supports_linux bool) ! {
	if !supports_linux {
		return error('${cask_name}: This cask requires macOS.')
	}
}
