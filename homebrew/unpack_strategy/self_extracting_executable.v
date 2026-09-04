module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/self_extracting_executable.rb`.

pub fn self_extracting_executable_extensions() []string {
	return []
}

pub fn self_extracting_executable_can_extract(path string) bool {
	if !file_starts_with(path, 'MZ'.bytes()) {
		return false
	}
	file := command_path('file') or { return false }
	result := ruby.run_command(file, ['-b', path])
	return result.exit_code == 0 && result.output.to_lower().contains('self-extracting archive')
}
