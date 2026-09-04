module homebrew

import homebrew.options as option_types

// Translated from Homebrew/brew `build_options.rb`.

// BuildOptions is implemented alongside Options to keep the canonical types in
// one dependency-free V module, then exposed from Homebrew through this alias.
pub type BuildOptions = option_types.BuildOptions

// new_build_options translates BuildOptions.new(args, options).
pub fn new_build_options(args Options, options Options) BuildOptions {
	return option_types.new_build_options(args, options)
}
