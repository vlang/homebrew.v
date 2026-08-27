module utils

import brew_runtime

// Translated from Homebrew/brew `utils/portable_ruby.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.sync_bundler_version!(pkg_version)` at line 14.
pub fn ruby_portable_ruby_l14_d1_self_sync_bundler_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sync_bundler_version!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: module Utils
// 7:   # Helper functions for the vendored portable-ruby.
// 8:   module PortableRuby
// 9:     extend Utils::Output::Mixin
// 10:
// 11:     # Syncs `HOMEBREW_BUNDLER_VERSION` in `utils/ruby.sh` with the bundler shipped
// 12:     # by the portable-ruby unpacked at `pkg_version`.
// 13:     sig { params(pkg_version: String).returns(String) }
// 14:     def self.sync_bundler_version!(pkg_version)
// 15:       unpacked = HOMEBREW_LIBRARY_PATH/"vendor/portable-ruby/#{pkg_version}"
// 16:       bundler_dir = Pathname.glob(unpacked/"lib/ruby/gems/*/gems/bundler-*").first
// 17:       odie "Cannot find vendored bundler for portable-ruby #{pkg_version}." if bundler_dir.nil?
// 18:
// 19:       bundler_version = bundler_dir.basename.to_s.delete_prefix("bundler-")
// 20:
// 21:       ruby_sh = HOMEBREW_LIBRARY_PATH/"utils/ruby.sh"
// 22:       original = ruby_sh.read
// 23:       updated = original.sub(/(?<=^export HOMEBREW_BUNDLER_VERSION=")[^"]+/, bundler_version)
// 24:       ruby_sh.atomic_write(updated) if original != updated
// 25:
// 26:       bundler_version
// 27:     end
// 28:   end
// 29: end
