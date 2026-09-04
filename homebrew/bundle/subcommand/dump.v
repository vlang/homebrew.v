module subcommand

import ruby
import homebrew.bundle

// Translated from Homebrew/brew `bundle/subcommand/dump.rb`.

pub struct BundleDumpCommandOptions {
pub:
	config          bundle.BundleBrewfilePathConfig
	input           bundle.BundleDumpInput
	describe        bool
	force           bool
	no_restart      bool
	formulae        bool
	taps            bool
	casks           bool
	extension_types map[string]bool
}

pub fn run_bundle_dump(options BundleDumpCommandOptions,
	writer bundle.BrewfileWriter) !bundle.BundleDumpResult {
	return bundle.dump_brewfile(options.config, options.input, bundle.BundleDumpSelection{
		describe: options.describe
		no_restart: options.no_restart
		formulae: options.formulae
		taps: options.taps
		casks: options.casks
		extension_types: options.extension_types
	}, options.force, writer)
}
