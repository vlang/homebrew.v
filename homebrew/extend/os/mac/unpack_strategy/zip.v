module unpack_strategy

import ruby
import homebrew.unpack_strategy as core_unpack
import os

// Translated from Homebrew/brew `extend/os/mac/unpack_strategy/zip.rb`.

pub fn zip_contains_extended_attributes(path string) bool {
	for member in core_unpack.zip_member_names(path) or { return false } {
		if member.starts_with('__MACOSX') || os.file_name(member).starts_with('._') {
			return true
		}
	}
	return false
}

pub fn macos_zip_extract_to_dir(path string, unpack_dir string, basename string, verbose bool, merge_xattrs bool) ! {
	if merge_xattrs && zip_contains_extended_attributes(path) {
		members := core_unpack.zip_member_names(path)!
		core_unpack.validate_archive_member_names(members)!
		ditto := ruby.find_executable('ditto')!
		result := ruby.run_command(ditto, ['-x', '-k', path, unpack_dir])
		if result.exit_code != 0 {
			return error('ditto failed (${result.exit_code}): ${result.output.trim_space()}')
		}
		return
	}
	core_unpack.zip_extract_to_dir(path, unpack_dir, basename, verbose) or {
		if !err.msg().contains('End-of-central-directory signature not found') {
			return err
		}
		ditto := ruby.find_executable('ditto')!
		result := ruby.run_command(ditto, ['-x', '-k', path, unpack_dir])
		if result.exit_code != 0 {
			return error('ditto failed (${result.exit_code}): ${result.output.trim_space()}')
		}
	}
}
