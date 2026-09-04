module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/rar.rb`.

pub fn rar_extensions() []string {
	return ['.rar']
}

pub fn rar_can_extract(path string) bool {
	return file_starts_with(path, 'Rar!'.bytes())
}

pub fn rar_dependencies() []string {
	return ['libarchive']
}

pub fn rar_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	bsdtar := command_path('bsdtar') or { command_path('tar')! }
	members := archive_listing(bsdtar, ['-tf', path])!
	validate_archive_members(members)!
	checked_command(bsdtar, ['x', '-f', path, '-C', unpack_dir])!
}
