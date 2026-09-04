module utils

import ruby
import os

// Translated from Homebrew/brew `utils/portable_ruby.rb`.
// The original source is retained below until every stub has a typed V body.

// sync_bundler_version finds the Bundler shipped in an unpacked portable Ruby
// and keeps utils/ruby.sh in step with it. The library path is explicit here so
// callers and tests do not need to mutate Homebrew's process-wide constants.
pub fn sync_bundler_version(library_path string, pkg_version string) !string {
	unpacked := os.join_path(library_path, 'vendor', 'portable-ruby', pkg_version)
	mut bundler_directories := os.glob(os.join_path(unpacked, 'lib', 'ruby', 'gems', '*', 'gems', 'bundler-*'))!
	bundler_directories.sort()
	if bundler_directories.len == 0 {
		return error('Cannot find vendored bundler for portable-ruby ${pkg_version}.')
	}

	bundler_basename := os.base(bundler_directories[0])
	if !bundler_basename.starts_with('bundler-') || bundler_basename.len == 'bundler-'.len {
		return error('Cannot determine vendored bundler version for portable-ruby ${pkg_version}.')
	}
	bundler_version := bundler_basename['bundler-'.len..]

	ruby_sh := os.join_path(library_path, 'utils', 'ruby.sh')
	original := ruby.read_file(ruby_sh)!
	updated := replace_bundler_version_export(original, bundler_version)
	if original != updated {
		ruby.atomic_write_file(ruby_sh, updated)!
	}
	return bundler_version
}

fn replace_bundler_version_export(contents string, bundler_version string) string {
	prefix := 'export HOMEBREW_BUNDLER_VERSION="'
	mut offset := 0
	for offset <= contents.len {
		relative_start := contents[offset..].index(prefix) or { return contents }
		start := offset + relative_start
		if start == 0 || contents[start - 1] == `\n` {
			version_start := start + prefix.len
			version_end := contents[version_start..].index('"') or { return contents }
			return contents[..version_start] + bundler_version + contents[version_start + version_end..]
		}
		offset = start + prefix.len
	}
	return contents
}

// Ruby method `self.sync_bundler_version!(pkg_version)` at line 14.
pub fn ruby_portable_ruby_l14_d1_self_sync_bundler_version(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name != 'String' {
		panic('self.sync_bundler_version! requires a package version')
	}
	library_path := ruby.environment_value('HOMEBREW_LIBRARY_PATH')
	if library_path == '' {
		panic('HOMEBREW_LIBRARY_PATH is not set')
	}
	version := sync_bundler_version(library_path, args[0].as_string()) or { panic(err) }
	return ruby.string_value(version)
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
