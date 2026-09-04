module bundle

import homebrew.bundle as base_bundle

// Translated from Homebrew/brew `extend/os/linux/bundle/skipper.rb`.
pub struct LinuxBundleSkipContext {
pub:
	wsl                 bool
	cask_supports_linux map[string]bool
	cask_load_errors    []string
}

pub fn linux_bundle_requires_macos(entry base_bundle.BundleSkipEntry,
	context LinuxBundleSkipContext) bool {
	if entry.type_name == 'mas' {
		return true
	}
	if entry.type_name != 'cask' {
		return false
	}
	if entry.name in context.cask_load_errors {
		return !entry.full_name.contains('/')
	}
	return !(context.cask_supports_linux[entry.name] or { false })
}

pub fn linux_bundle_requires_wsl(entry base_bundle.BundleSkipEntry,
	context LinuxBundleSkipContext) bool {
	return entry.type_name == 'winget' && !context.wsl
}

pub fn linux_bundle_skip(skipper &base_bundle.BundleSkipper, entry base_bundle.BundleSkipEntry,
	silent bool, context LinuxBundleSkipContext) base_bundle.BundleSkipResult {
	if linux_bundle_requires_wsl(entry, context) {
		return base_bundle.BundleSkipResult{
			skipped: true
			warning: if silent {
				''
			} else {
				'Warning: Skipping ${entry.type_name} ${entry.name} (requires WSL)'
			}
		}
	}
	if !linux_bundle_requires_macos(entry, context) {
		return skipper.skip(entry, silent)
	}
	return base_bundle.BundleSkipResult{
		skipped: true
		warning: if silent {
			''
		} else {
			'Warning: Skipping ${entry.type_name} ${entry.name} (requires macOS)'
		}
	}
}
