module linux

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/cleanup.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `use_system_ruby?` at line 12.
pub fn ruby_cleanup_l12_d1_use_system_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('use_system_ruby?', ...args)
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
