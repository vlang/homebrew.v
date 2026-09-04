module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `unpack_strategy/gzip.rb`.

pub fn gzip_extensions() []string {
	return ['.gz']
}

pub fn gzip_can_extract(path string) bool {
	return file_starts_with(path, [u8(0x1f), 0x8b])
}

pub fn gzip_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	target := ruby.join_path(unpack_dir, basename)
	os.cp(path, target)!
	mut arguments := []string{}
	if !verbose {
		arguments << '-q'
	}
	arguments << ['-N', '--', target]
	checked_command(command_path('gunzip')!, arguments)!
}
