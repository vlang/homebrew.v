module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `unpack_strategy/directory.rb`.

pub fn directory_extensions() []string {
	return []
}

pub fn new_directory_strategy(path string, move bool) Strategy {
	return Strategy{
		kind: .directory
		path: os.abs_path(path)
		move: move
	}
}

pub fn directory_can_extract(path string) bool {
	return ruby.is_dir(path)
}

pub fn directory_extract_to_dir(path string, unpack_dir string, basename string, verbose bool, move bool) ! {
	_ = basename
	_ = verbose
	if move {
		directory_move_to_dir(path, unpack_dir, verbose)!
		return
	}
	children := ruby.list_dir(path)!
	if children.len == 0 {
		return
	}
	mut arguments := ['-pR']
	for child in children {
		arguments << ruby.join_path(path, child)
	}
	arguments << unpack_dir
	checked_command(command_path('cp')!, arguments)!
}

pub fn directory_move_to_dir(path string, unpack_dir string, verbose bool) ! {
	_ = verbose
	for name in ruby.list_dir(path)! {
		source := ruby.join_path(path, name)
		destination := ruby.join_path(unpack_dir, name)
		if os.exists(destination) || os.is_link(destination) {
			source_directory := os.is_dir(source) && !os.is_link(source)
			destination_directory := os.is_dir(destination) && !os.is_link(destination)
			if source_directory && !destination_directory {
				return error("mv: cannot overwrite non-directory '${destination}' with directory '${source}'")
			}
			if !source_directory && destination_directory {
				return error("mv: cannot overwrite directory '${destination}' with non-directory '${source}'")
			}
			if source_directory {
				// Pathname#find retains the source directory attributes even when its
				// children are merged into an existing destination directory.
				source_stat := os.stat(source)!
				source_mode := os.inode(source).bitmask()
				directory_move_to_dir(source, destination, verbose)!
				os.chmod(destination, int(source_mode))!
				os.utime(destination, source_stat.atime, source_stat.mtime)!
				continue
			}
			remove_path(destination)!
		}
		os.mv(source, destination)!
	}
}
