module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/generic_unar.rb`.

pub fn generic_unar_extensions() []string {
	return []
}

pub fn generic_unar_can_extract(path string) bool {
	_ = path
	return false
}

pub fn generic_unar_dependencies() []string {
	return ['unar']
}

pub fn generic_unar_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	lsar := command_path('lsar')!
	listing := checked_command(lsar, ['-q', '--', path])!
	mut members := listing.output.split_into_lines()
	if members.len > 0 { members.delete(0) }
	validate_archive_members(members)!
	unar := command_path('unar')!
	checked_command(unar, ['-force-overwrite', '-quiet', '-no-directory', '-output-directory',
		unpack_dir, '--', path])!
}
