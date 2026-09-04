module unpack_strategy

import ruby
import os

// Translated from Homebrew/brew `unpack_strategy/bzip2.rb`.

pub fn bzip2_extensions() []string {
	return ['.bz2']
}

pub fn bzip2_can_extract(path string) bool {
	return file_starts_with(path, 'BZh'.bytes())
}

pub fn bzip2_dependencies() []string {
	// Formula resolution is not needed to identify the dependency. The typed
	// name lets the install layer resolve it once Formula is available.
	return ['bzip2']
}

pub fn bzip2_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	target := ruby.join_path(unpack_dir, basename)
	os.cp(path, target)!
	mut arguments := []string{}
	if !verbose {
		arguments << '-q'
	}
	arguments << ['-d', target]
	checked_command(command_path('bzip2')!, arguments)!
}
