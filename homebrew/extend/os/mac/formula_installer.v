module mac

// Translated from Homebrew/brew `extend/os/mac/formula_installer.rb`.
pub fn mac_fresh_install(developer bool, outdated_release bool, installed_on_request bool,
	any_version_installed bool) bool {
	return !developer && !outdated_release && (installed_on_request || !any_version_installed)
}
