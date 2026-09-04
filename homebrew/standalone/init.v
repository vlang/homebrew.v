module standalone

import ruby
import os

// Translated from Homebrew/brew `standalone/init.rb`.
pub type FastBootRequire = fn (string) !ruby.Value

pub fn from_archdir(archdir string, feature string, require_fn FastBootRequire) !ruby.Value {
	return require_fn(os.join_path(archdir, feature))
}

pub fn from_rubylibdir(rubylibdir string, feature string,
	require_fn FastBootRequire) !ruby.Value {
	return require_fn(os.join_path(rubylibdir, '${feature}.rb'))
}
