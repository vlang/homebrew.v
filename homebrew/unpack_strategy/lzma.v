module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `unpack_strategy/lzma.rb`.

pub fn lzma_extensions() []string {
	return ['.lzma']
}

pub fn lzma_can_extract(path string) bool {
	return file_starts_with(path, [u8(0x5d), 0, 0, 0x80, 0])
}

pub fn lzma_dependencies() []string {
	return ['xz']
}

pub fn lzma_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	target := ruby.join_path(unpack_dir, basename)
	os.cp(path, target)!
	mut args := []string{}
	if !verbose { args << '-q' }
	args << ['--', target]
	checked_command(command_path('unlzma')!, args)!
}
