module subcommand

import ruby
import homebrew.bundle

// Translated from Homebrew/brew `bundle/subcommand/add.rb`.

pub struct BundleAddCommandOptions {
pub:
	items                  []string
	selected_types         []string
	file                   string
	describe               bool = true
	descriptions           map[string]string
	taps                   []string
	unsupported_extensions []string
}

pub fn selected_bundle_add_type(selected_types []string) !string {
	if selected_types.len != 1 {
		return error('`add` supports only one type of entry at a time.')
	}
	entry_type := selected_types[0]
	if entry_type == 'none' {
		return 'brew'
	}
	if entry_type == 'mas' {
		return error('`add` does not support `--mas`.')
	}
	return entry_type
}

pub fn run_bundle_add(options BundleAddCommandOptions) !bundle.BundleAddResult {
	entry_type := selected_bundle_add_type(options.selected_types)!
	if entry_type in options.unsupported_extensions {
		return error('`add` does not support `--${entry_type}`.')
	}
	return bundle.add_bundle_entries(bundle.BundleAddOptions{
		items: options.items
		entry_type: entry_type
		file: options.file
		describe: options.describe
		descriptions: options.descriptions
		taps: options.taps
	})
}

fn subcommand_descriptions_from_value(value ruby.Value) map[string]string {
	values := value.as_map() or { return map[string]string{} }
	mut descriptions := map[string]string{}
	for name, description in values {
		descriptions[name] = description.as_string()
	}
	return descriptions
}
