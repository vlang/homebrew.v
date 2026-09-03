module unpack_strategy

import brew_runtime
import os

// Translated from Homebrew/brew `unpack_strategy/zip.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_zip_l10_d1_self_extensions() []string {
	return zip_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_zip_l15_d2_self_can_extract(path string) bool {
	return zip_can_extract(path)
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 25.
pub fn ruby_zip_l25_d3_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	zip_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn zip_extensions() []string {
	return ['.zip']
}

pub fn zip_can_extract(path string) bool {
	return file_starts_with(path, [u8(`P`), `K`, 0x03, 0x04])
		|| file_starts_with(path, [u8(`P`), `K`, 0x05, 0x06])
}

pub fn zip_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	unzip := command_path('unzip')!
	validate_archive_members(zip_member_names(path)!)!
	mut arguments := []string{}
	if !verbose {
		arguments << '-qq'
	}
	arguments << ['-o', path, '-d', unpack_dir]
	checked_command(unzip, arguments)!
	macosx := brew_runtime.join_path(unpack_dir, '__MACOSX')
	if os.is_dir(macosx) {
		os.rmdir_all(macosx)!
	}
}

pub fn zip_member_names(path string) ![]string {
	unzip := command_path('unzip')!
	return archive_listing(unzip, ['-Z1', path])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking ZIP archives.
// 6:   class Zip
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".zip"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       path.magic_number.match?(/\APK(\003\004|\005\006)/n)
// 17:     end
// 18:
// 19:     private
// 20:
// 21:     sig {
// 22:       override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean)
// 23:               .returns(SystemCommand::Result)
// 24:     }
// 25:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 26:       odebug "in unpack_strategy, zip, extract_to_dir, verbose: #{verbose.inspect}"
// 27:       unzip = if which("unzip").blank?
// 28:         begin
// 29:           Formula["unzip"]
// 30:         rescue FormulaUnavailableError
// 31:           nil
// 32:         end
// 33:       end
// 34:
// 35:       with_env(TZ: "UTC") do
// 36:         quiet_flags = verbose ? [] : ["-qq"]
// 37:         result = system_command! "unzip",
// 38:                                  args:         [*quiet_flags, "-o", path, "-d", unpack_dir],
// 39:                                  env:          { "PATH" => PATH.new(unzip&.opt_bin, ENV.fetch("PATH")).to_s },
// 40:                                  verbose:,
// 41:                                  print_stderr: false
// 42:
// 43:         FileUtils.rm_rf unpack_dir/"__MACOSX"
// 44:
// 45:         result
// 46:       end
// 47:     end
// 48:   end
// 49: end
// 50:
// 51: require "extend/os/unpack_strategy/zip"
