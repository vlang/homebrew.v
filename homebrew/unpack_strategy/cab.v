module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/cab.rb`.

pub fn cab_extensions() []string {
	return ['.cab']
}

pub fn cab_can_extract(path string) bool {
	return file_starts_with(path, 'MSCF'.bytes())
}

pub fn cab_dependencies() []string {
	return ['cabextract']
}

pub fn cab_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	cabextract := command_path('cabextract')!
	listing := checked_command(cabextract, ['-l', path])!
	mut members := []string{}
	for line in listing.output.split_into_lines() {
		fields := line.fields()
		if fields.len >= 3 && fields[0].bytes().all(it.is_digit()) {
			members << fields[2..].join(' ')
		}
	}
	validate_archive_members(members)!
	checked_command(cabextract, ['-d', unpack_dir, '--', path])!
}
