module linux

import ruby
import homebrew.utils as brew_utils

// Translated from Homebrew/brew `extend/os/linux/cleanup.rb`.
fn ruby_executable_version(path string) ?string {
	result := ruby.run_command(path, ['--disable=gems,did_you_mean,rubyopt', '-e',
		'print RUBY_VERSION'])
	if result.exit_code != 0 {
		return none
	}
	version := result.output.trim_space()
	return if version == '' { none } else { version }
}

pub fn use_system_ruby(force_vendor bool, required_version string) bool {
	if force_vendor || required_version == '' {
		return false
	}
	mut candidates := []string{}
	if ruby_path := ruby.find_executable('ruby') {
		candidates << ruby_path
	}
	if ruby.is_file('/usr/bin/ruby') && '/usr/bin/ruby' !in candidates {
		candidates << '/usr/bin/ruby'
	}
	developer_or_tests := ruby.environment_value('HOMEBREW_DEVELOPER') != '' || ruby.environment_value('HOMEBREW_TESTS') != ''
	use_from_path := ruby.environment_value('HOMEBREW_USE_RUBY_FROM_PATH') != ''
	for candidate in candidates {
		version := ruby_executable_version(candidate) or { continue }
		if brew_utils.check_ruby_version(version, required_version, developer_or_tests, use_from_path) {
			return true
		}
	}
	return false
}
