module homebrew

import homebrew.options as option_types

// Translated from Homebrew/brew `options.rb`.

// V cannot make the child options module depend on its parent without creating
// a cycle. These aliases expose the canonical translated types from homebrew.
pub type FormulaOption = option_types.FormulaOption

pub type Options = option_types.Options

pub type DeprecatedOption = option_types.DeprecatedOption

pub fn new_option(name string, description ...string) FormulaOption {
	return option_types.new_option(name, ...description)
}

pub fn new_options(flags ...string) Options {
	return option_types.create(flags)
}

pub fn new_deprecated_option(old string, current string) DeprecatedOption {
	return option_types.new_deprecated_option(old, current)
}
