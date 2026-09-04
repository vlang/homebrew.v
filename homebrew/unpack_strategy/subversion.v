module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/subversion.rb`.

pub fn subversion_can_extract(path string) bool {
	return directory_can_extract(path) && ruby.is_dir(ruby.join_path(path, '.svn'))
}

pub fn subversion_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	checked_command_in_directory(command_path('svn')!, ['export', '--force', '.', unpack_dir], path)!
}
