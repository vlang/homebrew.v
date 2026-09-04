module subcommand

import ruby
import homebrew.bundle

// Translated from Homebrew/brew `bundle/subcommand/list.rb`.

pub struct BundleListCommandOptions {
pub:
	formulae        bool
	casks           bool
	taps            bool
	all             bool
	no_type_args    bool
	extension_types map[string]bool
}

pub fn run_bundle_list(entries []bundle.BundleListEntry,
	options BundleListCommandOptions) []string {
	mut extensions := options.extension_types.clone()
	if options.all {
		for entry in entries {
			if entry.entry_type !in ['brew', 'cask', 'tap'] {
				extensions[entry.entry_type] = true
			}
		}
	}
	return bundle.list_bundle_entries(entries, options.formulae || options.all || options.no_type_args, options.casks || options.all, options.taps || options.all, extensions)
}

fn extension_flags_from_value(value ruby.Value) map[string]bool {
	flags := value.as_map() or { return map[string]bool{} }
	mut result := map[string]bool{}
	for name, enabled in flags {
		result[name] = enabled.as_bool() or { enabled.as_string() == 'true' }
	}
	return result
}
