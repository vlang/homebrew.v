module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/xar.rb`.

pub fn xar_extensions() []string {
	return ['.xar']
}

pub fn xar_can_extract(path string) bool {
	return file_starts_with(path, 'xar!'.bytes())
}

pub fn xar_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	xar := command_path('xar')!
	members := archive_listing(xar, ['-tf', path])!
	validate_archive_members(members)!
	checked_command(xar, ['-x', '-f', path, '-C', unpack_dir])!
}
