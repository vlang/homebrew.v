module cask

import ruby

// Translated from Homebrew/brew `cask/denylist.rb`.

// denylist_reason returns Homebrew's source-defined reason for casks that are
// not accepted in official taps.
pub fn denylist_reason(name string) ?string {
	if name.starts_with('adobe-after') || name.starts_with('adobe-illustrator')
		|| name.starts_with('adobe-indesign') || name.starts_with('adobe-photoshop')
		|| name.starts_with('adobe-premiere') {
		return 'Adobe casks were removed because they are too difficult to maintain.'
	}
	if name == 'pharo' {
		return 'Pharo developers maintain their own tap.'
	}
	return none
}
