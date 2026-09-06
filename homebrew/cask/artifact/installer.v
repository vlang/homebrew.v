module artifact

import ruby

// Translated from Homebrew/brew `cask/artifact/installer.rb`.
pub struct InstallerArtifact {
pub:
	cask           ruby.Value
	path           string
	arguments      map[string]ruby.Value
	manual_install bool
}

fn installer_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}
