module bundle

import homebrew.bundle as base_bundle

pub fn mac_bundle_linux_only_entry(entry base_bundle.BundleSkipEntry) bool {
	return entry.type_name == 'flatpak'
}

pub fn mac_bundle_skip(skipper &base_bundle.BundleSkipper,
	entry base_bundle.BundleSkipEntry, silent bool) base_bundle.BundleSkipResult {
	if entry.type_name == 'winget' {
		return base_bundle.BundleSkipResult{
			skipped: true
			warning: if silent {
				''
			} else {
				'Warning: Skipping winget ${entry.name} (requires WSL)'
			}
		}
	}
	if mac_bundle_linux_only_entry(entry) {
		return base_bundle.BundleSkipResult{
			skipped: true
			warning: if silent {
				''
			} else {
				'Warning: Skipping flatpak ${entry.name} (unsupported on macOS)'
			}
		}
	}
	return skipper.skip(entry, silent)
}

// Translated from Homebrew/brew `extend/os/mac/bundle/skipper.rb`.
