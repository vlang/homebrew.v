module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/mercurial.rb`.

pub fn mercurial_can_extract(path string) bool {
	return directory_can_extract(path) && ruby.is_dir(ruby.join_path(path, '.hg'))
}

pub fn mercurial_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	checked_command(command_path('hg')!, ['--cwd', path, 'archive', '--subrepos', '-y', '-t', 'files',
		unpack_dir])!
}
