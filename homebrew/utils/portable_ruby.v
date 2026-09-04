module utils

import ruby
import os

// Translated from Homebrew/brew `utils/portable_ruby.rb`.

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
