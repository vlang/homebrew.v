module ffi

import ruby
import os

pub fn foundation_trash_item(path string, trash_directory string) !string {
	if !os.exists(path) {
		return ''
	}
	os.mkdir_all(trash_directory)!
	base := os.base(path)
	mut destination := os.join_path(trash_directory, base)
	mut suffix := 1
	for os.exists(destination) {
		destination = os.join_path(trash_directory, '${base}.${suffix}')
		suffix++
	}
	os.mv(path, destination)!
	return destination
}

pub fn foundation_trash_paths(paths []string, trash_directory string) ([]string, []string) {
	mut trashed := []string{}
	mut untrashable := []string{}
	for path in paths {
		result := foundation_trash_item(path, trash_directory) or {
			untrashable << path
			continue
		}
		if result != '' { trashed << result } else { untrashable << path }
	}
	return trashed, untrashable
}

// Translated from Homebrew/brew `os/mac/ffi/foundation.rb`.
