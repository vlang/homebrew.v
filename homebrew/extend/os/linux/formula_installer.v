module linux

// Translated from Homebrew/brew `extend/os/linux/formula_installer.rb`.
pub fn linux_fresh_install(developer bool, installed_on_request bool,
	any_version_installed bool) bool {
	return !developer && (installed_on_request || !any_version_installed)
}
