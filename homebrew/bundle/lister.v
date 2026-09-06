module bundle

// Translated from Homebrew/brew `bundle/lister.rb`.

pub struct BundleListEntry {
pub:
	entry_type string
	name       string
}

pub fn show_bundle_entry(entry_type string, formulae bool, casks bool, taps bool,
	extension_types map[string]bool) bool {
	return (formulae && entry_type == 'brew') || (casks && entry_type == 'cask') || (taps && entry_type == 'tap') || extension_types[entry_type]
}

pub fn list_bundle_entries(entries []BundleListEntry, formulae bool, casks bool, taps bool,
	extension_types map[string]bool) []string {
	mut names := []string{cap: entries.len}
	for entry in entries {
		if show_bundle_entry(entry.entry_type, formulae, casks, taps, extension_types) {
			names << entry.name
		}
	}
	return names
}
