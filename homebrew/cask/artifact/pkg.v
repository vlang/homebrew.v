module artifact

import ruby

// Translated from Homebrew/brew `cask/artifact/pkg.rb`.
pub struct PkgArtifact {
pub:
	cask           ruby.Value
	path           string
	stanza_options map[string]ruby.Value
}

pub fn (pkg PkgArtifact) summarize() string {
	staged := (pkg.cask.map_data['staged_path'] or { ruby.string_value('') }).as_string().trim_right('/')
	return pkg.path.trim_string_left(staged).trim_left('/')
}
