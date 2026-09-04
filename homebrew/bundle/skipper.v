module bundle

// Translated from Homebrew/brew `bundle/skipper.rb`.
const bundle_skip_types = ['brew', 'cask', 'mas', 'tap', 'flatpak', 'winget']

pub struct BundleSkipEntry {
pub:
	type_name string
	name      string
	full_name string
	id        string
}

pub struct BundleSkipResult {
pub:
	skipped bool
	warning string
}

pub struct BundleSkipper {
pub mut:
	failed_taps     []string
	skipped_entries map[string][]string
pub:
	initialized bool
}

pub fn bundle_skip_entries_from_environment(environment map[string]string) map[string][]string {
	mut entries := map[string][]string{}
	for entry_type in bundle_skip_types {
		key := 'HOMEBREW_BUNDLE_${entry_type.to_upper()}_SKIP'
		if value := environment[key] {
			entries[entry_type] = value.fields()
		} else {
			entries[entry_type] = []
		}
	}
	return entries
}

fn clone_bundle_skip_entries(entries map[string][]string) map[string][]string {
	mut cloned := map[string][]string{}
	for entry_type, values in entries {
		cloned[entry_type] = values.clone()
	}
	return cloned
}

pub fn new_bundle_skipper(environment map[string]string) BundleSkipper {
	return BundleSkipper{
		skipped_entries: bundle_skip_entries_from_environment(environment)
		initialized: true
	}
}

pub fn (skipper &BundleSkipper) skip(entry BundleSkipEntry, silent bool) BundleSkipResult {
	for failed_tap in skipper.failed_taps {
		prefix := '${failed_tap}/'
		if entry.name.starts_with(prefix) || entry.full_name.starts_with(prefix) {
			return BundleSkipResult{
				skipped: true
			}
		}
	}
	type_skips := skipper.skipped_entries[entry.type_name] or { []string{} }
	if type_skips.len == 0 || (entry.name !in type_skips && (entry.id == '' || entry.id !in type_skips)) {
		return BundleSkipResult{}
	}
	return BundleSkipResult{
		skipped: true
		warning: if silent { '' } else { 'Warning: Skipping ${entry.name}' }
	}
}

pub fn (mut skipper BundleSkipper) tap_failed(tap_name string) {
	skipper.failed_taps << tap_name
}
