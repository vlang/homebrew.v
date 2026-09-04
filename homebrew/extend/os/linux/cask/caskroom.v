module cask

import ruby

// Translated from Homebrew/brew `extend/os/linux/cask/caskroom.rb`.
pub fn expected_caskroom_group() string {
	result := ruby.run_command('id', ['-gn'])
	if result.exit_code == 0 && result.output.trim_space() != '' {
		return result.output.trim_space()
	}
	return 'root'
}
