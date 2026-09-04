module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/p7zip.rb`.

pub fn p7zip_extensions() []string {
	return ['.7z']
}

pub fn p7zip_can_extract(path string) bool {
	return file_starts_with(path, [u8(`7`), `z`, 0xbc, 0xaf, 0x27, 0x1c])
}

pub fn p7zip_dependencies() []string {
	return ['p7zip']
}

pub fn p7zip_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	seven_zip := command_path('7zr')!
	listing := checked_command(seven_zip, ['l', '-slt', '--', path])!
	mut members := []string{}
	for line in listing.output.split_into_lines() {
		if line.starts_with('Path = ') {
			member := line.all_after('Path = ').trim_space()
			if member != path && member != ruby.real_path(path) {
				members << member
			}
		}
	}
	validate_archive_members(members)!
	checked_command(seven_zip, ['x', '-y', '-bd', '-bso0', path, '-o${unpack_dir}'])!
}
