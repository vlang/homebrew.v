module cmd

// Translated from Homebrew/brew `cmd/pin.rb`.
pub enum PinPackageKind {
	formula
	cask
}

pub struct PinPackageState {
pub:
	kind         PinPackageKind
	full_name    string
	version      string
	auto_updates bool
pub mut:
	installed      bool
	pinnable       bool
	pinned         bool
	pin_symlink    bool
	pinned_version ?string
}

pub struct PinCommandResult {
pub:
	warnings []string
	failures []string
}

pub fn (result PinCommandResult) failed() bool {
	return result.failures.len > 0
}

pub fn (mut package PinPackageState) pin() {
	if !package.installed || !package.pinnable {
		return
	}
	package.pinned = true
	package.pin_symlink = true
	package.pinned_version = package.version
}

pub fn (mut package PinPackageState) unpin() {
	package.pinned = false
	package.pin_symlink = false
	package.pinned_version = none
}

pub fn pin_packages(mut packages []PinPackageState) PinCommandResult {
	mut warnings := []string{}
	mut failures := []string{}
	for mut package in packages {
		if package.pinned {
			warnings << '${package.full_name} already pinned'
		} else if !package.installed || !package.pinnable {
			failures << '${package.full_name} not installed'
		} else {
			package.pin()
			if package.kind == .cask && package.auto_updates {
				warnings << '${package.full_name} has `auto_updates true` and may update itself outside Homebrew despite being pinned.'
			}
		}
	}
	return PinCommandResult{
		warnings: warnings
		failures: failures
	}
}
