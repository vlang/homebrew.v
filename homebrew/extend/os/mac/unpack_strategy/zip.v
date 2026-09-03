module unpack_strategy

import brew_runtime
import homebrew.unpack_strategy as core_unpack
import os

// Translated from Homebrew/brew `extend/os/mac/unpack_strategy/zip.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 16.
pub fn ruby_zip_l16_d1_extract_to_dir(path string, unpack_dir string, basename string, verbose bool, merge_xattrs bool) ! {
	macos_zip_extract_to_dir(path, unpack_dir, basename, verbose, merge_xattrs)!
}

// Ruby method `contains_extended_attributes?(path)` at line 64.
pub fn ruby_zip_l64_d2_contains_extended_attributes(path string) bool {
	return zip_contains_extended_attributes(path)
}

pub fn zip_contains_extended_attributes(path string) bool {
	for member in core_unpack.zip_member_names(path) or { return false } {
		if member.starts_with('__MACOSX') || os.file_name(member).starts_with('._') { return true }
	}
	return false
}

pub fn macos_zip_extract_to_dir(path string, unpack_dir string, basename string, verbose bool, merge_xattrs bool) ! {
	if merge_xattrs && zip_contains_extended_attributes(path) {
		members := core_unpack.zip_member_names(path)!
		core_unpack.validate_archive_member_names(members)!
		ditto := brew_runtime.find_executable('ditto')!
		result := brew_runtime.run_command(ditto, ['-x', '-k', path, unpack_dir])
		if result.exit_code != 0 {
			return error('ditto failed (${result.exit_code}): ${result.output.trim_space()}')
		}
		return
	}
	core_unpack.zip_extract_to_dir(path, unpack_dir, basename, verbose) or {
		if !err.msg().contains('End-of-central-directory signature not found') { return err }
		ditto := brew_runtime.find_executable('ditto')!
		result := brew_runtime.run_command(ditto, ['-x', '-k', path, unpack_dir])
		if result.exit_code != 0 {
			return error('ditto failed (${result.exit_code}): ${result.output.trim_space()}')
		}
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5:
// 6: module UnpackStrategy
// 7:   class Zip
// 8:     module MacOSZipExtension
// 9:       extend T::Helpers
// 10:
// 11:       requires_ancestor { UnpackStrategy }
// 12:
// 13:       private
// 14:
// 15:       sig { params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 16:       def extract_to_dir(unpack_dir, basename:, verbose:)
// 17:         with_env(TZ: "UTC") do
// 18:           if merge_xattrs && contains_extended_attributes?(path)
// 19:             # We use ditto directly, because dot_clean has issues if the __MACOSX
// 20:             # folder has incorrect permissions.
// 21:             # (Also, Homebrew's ZIP artifact automatically deletes this folder.)
// 22:             return system_command! "ditto",
// 23:                                    args:         ["-x", "-k", path, unpack_dir],
// 24:                                    verbose:,
// 25:                                    print_stderr: false
// 26:           end
// 27:
// 28:           result = begin
// 29:             T.let(super, T.nilable(SystemCommand::Result))
// 30:           rescue ErrorDuringExecution => e
// 31:             raise unless e.stderr.include?("End-of-central-directory signature not found.")
// 32:
// 33:             system_command!("ditto",
// 34:                             args:    ["-x", "-k", path, unpack_dir],
// 35:                             verbose:)
// 36:             nil
// 37:           end
// 38:
// 39:           return if result.blank?
// 40:
// 41:           volumes = result.stderr.chomp
// 42:                           .split("\n")
// 43:                           .filter_map { |l| l[/\A   skipping: (.+)  volume label\Z/, 1] }
// 44:
// 45:           return if volumes.empty?
// 46:
// 47:           Dir.mktmpdir("homebrew-zip", HOMEBREW_TEMP) do |tmp_unpack_dir|
// 48:             tmp_unpack_dir = Pathname(tmp_unpack_dir)
// 49:
// 50:             # `ditto` keeps Finder attributes intact and does not skip volume labels
// 51:             # like `unzip` does, which can prevent disk images from being unzipped.
// 52:             system_command!("ditto",
// 53:                             args:    ["-x", "-k", path, tmp_unpack_dir],
// 54:                             verbose:)
// 55:
// 56:             volumes.each do |volume|
// 57:               FileUtils.mv tmp_unpack_dir/volume, unpack_dir/volume, verbose:
// 58:             end
// 59:           end
// 60:         end
// 61:       end
// 62:
// 63:       sig { params(path: Pathname).returns(T::Boolean) }
// 64:       def contains_extended_attributes?(path)
// 65:         path.zipinfo.grep(/(^__MACOSX|\._)/).any?
// 66:       end
// 67:     end
// 68:     private_constant :MacOSZipExtension
// 69:
// 70:     prepend MacOSZipExtension
// 71:   end
// 72: end
