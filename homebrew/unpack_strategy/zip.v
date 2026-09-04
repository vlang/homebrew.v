module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `unpack_strategy/zip.rb`.

pub fn zip_extensions() []string {
	return ['.zip']
}

pub fn zip_can_extract(path string) bool {
	return file_starts_with(path, [u8(`P`), `K`, 0x03, 0x04])
		|| file_starts_with(path, [u8(`P`), `K`, 0x05, 0x06])
}

pub fn zip_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	unzip := command_path('unzip')!
	validate_archive_members(zip_member_names(path)!)!
	mut arguments := []string{}
	if !verbose {
		arguments << '-qq'
	}
	arguments << ['-o', path, '-d', unpack_dir]
	checked_command(unzip, arguments)!
	macosx := ruby.join_path(unpack_dir, '__MACOSX')
	if os.is_dir(macosx) {
		os.rmdir_all(macosx)!
	}
}

pub fn zip_member_names(path string) ![]string {
	unzip := command_path('unzip')!
	return archive_listing(unzip, ['-Z1', path])
}
