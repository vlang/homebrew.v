module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `unpack_strategy/xz.rb`.

pub fn xz_extensions() []string {
	return ['.xz']
}

pub fn xz_can_extract(path string) bool {
	return file_starts_with(path, [u8(0xfd), 0x37, 0x7a, 0x58, 0x5a, 0x00])
}

pub fn xz_dependencies() []string {
	return ['xz']
}

pub fn xz_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	target := ruby.join_path(unpack_dir, basename)
	os.cp(path, target)!
	mut arguments := []string{}
	if !verbose {
		arguments << '-q'
	}
	arguments << ['-T0', '--', target]
	checked_command(command_path('unxz')!, arguments)!
}
