module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `unpack_strategy/lzip.rb`.

pub fn lzip_extensions() []string {
	return ['.lz']
}

pub fn lzip_can_extract(path string) bool {
	return file_starts_with(path, 'LZIP'.bytes())
}

pub fn lzip_dependencies() []string {
	return ['lzip']
}

pub fn lzip_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	target := ruby.join_path(unpack_dir, basename)
	os.cp(path, target)!
	mut args := ['-d']
	if !verbose { args << '-q' }
	args << target
	checked_command(command_path('lzip')!, args)!
}
