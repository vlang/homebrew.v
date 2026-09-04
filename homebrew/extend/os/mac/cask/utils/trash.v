module utils

import ruby
import homebrew.cask.utils as base_trash
import homebrew.os.mac.ffi
import os

pub type MacTrashRetry = fn (string) !string

pub fn mac_trash_paths(paths []string, trash_directory string,
	retry MacTrashRetry) base_trash.TrashResult {
	trashed, untrashable := ffi.foundation_trash_paths(paths, trash_directory)
	mut retried := []string{}
	mut still_untrashable := []string{}
	for path in untrashable {
		destination := retry(path) or {
			still_untrashable << path
			continue
		}
		if destination == '' {
			still_untrashable << path
		} else {
			retried << destination
		}
	}
	mut all_trashed := trashed.clone()
	all_trashed << retried
	return base_trash.TrashResult{ trashed: all_trashed, untrashable: still_untrashable }
}

fn mac_trash_fixture_retry(path string) !string {
	trash_directory := os.join_path(os.home_dir(), '.Trash')
	return ffi.foundation_trash_item(path, trash_directory)
}

// Translated from Homebrew/brew `extend/os/mac/cask/utils/trash.rb`.
