module subcommand

import ruby

// Translated from Homebrew/brew `bundle/subcommand/edit.rb`.

pub struct BundleEditPlan {
pub:
	path   string
	editor string
}

pub fn run_bundle_edit(path string, editor string) BundleEditPlan {
	return BundleEditPlan{
		path: if path.trim_space() != '' { path } else { 'Brewfile' }
		editor: editor
	}
}
