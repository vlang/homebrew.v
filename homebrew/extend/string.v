module extend

// Translated from Homebrew/brew `extend/string.rb`.

pub fn string_excludes(input string, substring string) bool {
	return !input.contains(substring)
}
