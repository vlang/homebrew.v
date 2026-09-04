module subcommand

import ruby
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

fn subcommand_remove_packages_from_value(value ruby.Value) []bundle.BundlePackage {
	values := value.as_array() or { [] }
	return values.map(bundle.BundlePackage{
		kind: if (it.attribute('kind') or { 'formula' }) == 'cask' { .cask } else { .formula }
		name: it.attribute('name') or { it.as_string() }
		full_name: it.attribute('full_name') or { it.as_string() }
		aliases: (it.attribute('aliases') or { '' }).split(',').filter(it != '')
		oldnames: (it.attribute('oldnames') or { '' }).split(',').filter(it != '')
		desc: it.attribute('desc') or { '' }
	})
}
