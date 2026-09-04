module bundle

import ruby

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

fn bundle_list_entry_from_value(value ruby.Value) BundleListEntry {
	return BundleListEntry{
		entry_type: value.attribute('type') or { value.attribute('entry_type') or { '' } }
		name: value.attribute('name') or { value.as_string() }
	}
}

fn bundle_list_entries_from_value(value ruby.Value) []BundleListEntry {
	values := value.as_array() or { [] }
	return values.map(bundle_list_entry_from_value(it))
}

fn bundle_extension_types_from_value(value ruby.Value) map[string]bool {
	values := value.as_map() or { return map[string]bool{} }
	mut extensions := map[string]bool{}
	for name, enabled in values {
		extensions[name] = enabled.as_bool() or { enabled.as_string() == 'true' }
	}
	return extensions
}
