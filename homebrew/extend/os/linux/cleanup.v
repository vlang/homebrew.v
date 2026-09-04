module linux

import ruby
import homebrew.utils as brew_utils

// Translated from Homebrew/brew `extend/os/linux/cleanup.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `use_system_ruby?` at line 12.
pub fn ruby_cleanup_l12_d1_use_system_ruby(args ...ruby.Value) ruby.Value {
	force_vendor := if args.len > 0 {
		args[0].as_bool() or { false }
	} else {
		ruby.environment_value('HOMEBREW_FORCE_VENDOR_RUBY') != ''
	}
	required := if args.len > 1 {
		args[1].as_string()
	} else {
		ruby.environment_value('HOMEBREW_REQUIRED_RUBY_VERSION')
	}
	return ruby.bool_value(use_system_ruby(force_vendor, required))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Cleanup
// 7:       extend T::Helpers
// 8:
// 9:       requires_ancestor { Homebrew::Cleanup }
// 10:
// 11:       sig { returns(T::Boolean) }
// 12:       def use_system_ruby?
// 13:         return false if Homebrew::EnvConfig.force_vendor_ruby?
// 14:
// 15:         rubies = [which("ruby"), which("ruby", ORIGINAL_PATHS)].compact
// 16:         system_ruby = ::Pathname.new("/usr/bin/ruby")
// 17:         rubies << system_ruby if system_ruby.exist?
// 18:
// 19:         check_ruby_version = HOMEBREW_LIBRARY_PATH/"utils/ruby_check_version_script.rb"
// 20:         rubies.uniq.any? do |ruby|
// 21:           quiet_system ruby, "--enable-frozen-string-literal", "--disable=gems,did_you_mean,rubyopt",
// 22:                        check_ruby_version, RUBY_VERSION
// 23:         end
// 24:       end
// 25:     end
// 26:   end
// 27: end
// 28:
// 29: Homebrew::Cleanup.prepend(OS::Linux::Cleanup)
