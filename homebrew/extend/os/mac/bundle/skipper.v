module bundle

import ruby
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

fn mac_bundle_entry_from_value(value ruby.Value) !base_bundle.BundleSkipEntry {
	values := value.as_map()!
	return base_bundle.BundleSkipEntry{
		type_name: (values['type'] or { return error('entry type is required') }).as_string()
		name: (values['name'] or { return error('entry name is required') }).as_string()
		full_name: (values['full_name'] or { ruby.string_value('') }).as_string()
		id: (values['id'] or { ruby.string_value('') }).as_string()
	}
}

// Translated from Homebrew/brew `extend/os/mac/bundle/skipper.rb`.
