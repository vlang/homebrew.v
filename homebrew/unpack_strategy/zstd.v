module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `unpack_strategy/zstd.rb`.

pub fn zstd_extensions() []string {
	return ['.zst']
}

pub fn zstd_can_extract(path string) bool {
	return file_prefix_contains(path, [u8(0x28), 0xb5, 0x2f, 0xfd])
}

pub fn zstd_dependencies() []string {
	return ['zstd']
}

pub fn zstd_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	target := ruby.join_path(unpack_dir, basename)
	os.cp(path, target)!
	mut args := []string{}
	if !verbose { args << '-q' }
	args << ['-T0', '--rm', '--', target]
	unzstd := command_path('unzstd') or { command_path('zstd')! }
	if os.file_name(unzstd) == 'zstd' { args.prepend('-d') }
	checked_command(unzstd, args)!
}
