module subcommand

import homebrew.bundle

// Translated from Homebrew/brew `bundle/subcommand/remove.rb`.

pub struct BundleRemoveCommandOptions {
pub:
	items          []string
	selected_types []string
	file           string
	packages       []bundle.BundlePackage
}

pub fn run_bundle_remove(options BundleRemoveCommandOptions) !bundle.BundleRemoveResult {
	if options.selected_types.len != 1 {
		return error('`remove` supports only one type of entry at a time.')
	}
	return bundle.remove_bundle_entries(options.file, options.items, options.selected_types[0], options.packages)
}
