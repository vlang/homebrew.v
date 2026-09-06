module cmd

// Translated from Homebrew/brew `cmd/unpin.rb`.
pub fn unpin_packages(mut packages []PinPackageState) PinCommandResult {
	mut warnings := []string{}
	mut failures := []string{}
	for package_kind in [PinPackageKind.formula, .cask] {
		for mut package in packages {
			if package.kind != package_kind {
				continue
			}
			if package.pinned || (package.kind == .cask && package.pin_symlink) {
				package.unpin()
			} else if !package.installed || !package.pinnable {
				failures << '${package.full_name} not installed'
			} else {
				warnings << '${package.full_name} not pinned'
			}
		}
	}
	return PinCommandResult{
		warnings: warnings
		failures: failures
	}
}
