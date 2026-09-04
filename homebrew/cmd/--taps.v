module cmd

import ruby

// Translated from Homebrew/brew `cmd/--taps.rb`.

// taps_path translates the shell command paired with this Ruby command class.
// HOMEBREW_LIBRARY is set by brew.sh in Homebrew.
pub fn taps_path(library string) string {
	return '${library}/Taps'
}

pub fn taps_path_from_environment() string {
	mut library := ruby.environment_value('HOMEBREW_LIBRARY')
	if library == '' {
		// `Library/Homebrew` maps to the top-level `homebrew` module in this
		// translation, so the module's parent is the translated library root.
		library = @VMODROOT
	}
	return taps_path(library)
}
