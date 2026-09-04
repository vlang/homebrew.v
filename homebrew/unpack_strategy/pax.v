module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/pax.rb`.

pub fn pax_extensions() []string {
	return ['.pax']
}

pub fn pax_can_extract(path string) bool {
	_ = path
	return false
}

pub fn pax_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	pax := command_path('pax')!
	members := archive_listing(pax, ['-f', path])!
	validate_archive_members(members)!
	checked_command_in_directory(pax, ['-rf', path], unpack_dir)!
}
