module unpack_strategy

import brew_runtime

// Translated from Homebrew/brew `unpack_strategy/air.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.extensions` at line 10.
pub fn ruby_air_l10_d1_self_extensions() []string {
	return air_extensions()
}

// Ruby method `self.can_extract?(path)` at line 15.
pub fn ruby_air_l15_d2_self_can_extract(path string) bool {
	return air_can_extract(path)
}

// Ruby method `dependencies` at line 21.
pub fn ruby_air_l21_d3_dependencies() []string {
	return air_dependencies()
}

// Ruby method `extract_to_dir(unpack_dir, basename:, verbose:)` at line 33.
pub fn ruby_air_l33_d4_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	air_extract_to_dir(path, unpack_dir, basename, verbose)!
}

pub fn air_extensions() []string {
	return ['.air']
}

pub fn air_can_extract(path string) bool {
	return file_has_bytes_at(path, 59,
		'application/vnd.adobe.air-application-installer-package+zip'.bytes())
}

pub fn air_dependencies() []string {
	return ['adobe-air']
}

pub fn air_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	installer := '/Applications/Utilities/Adobe AIR Application Installer.app/Contents/MacOS/Adobe AIR Application Installer'
	if !brew_runtime.is_file(installer) {
		return error('Adobe AIR Application Installer is required to extract ${path}')
	}
	checked_command(installer, ['-silent', '-location', unpack_dir, path])!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module UnpackStrategy
// 5:   # Strategy for unpacking Adobe Air archives.
// 6:   class Air
// 7:     include UnpackStrategy
// 8:
// 9:     sig { override.returns(T::Array[String]) }
// 10:     def self.extensions
// 11:       [".air"]
// 12:     end
// 13:
// 14:     sig { override.params(path: Pathname).returns(T::Boolean) }
// 15:     def self.can_extract?(path)
// 16:       mime_type = "application/vnd.adobe.air-application-installer-package+zip"
// 17:       path.magic_number.match?(/.{59}#{Regexp.escape(mime_type)}/)
// 18:     end
// 19:
// 20:     sig { returns(T::Array[Cask::Cask]) }
// 21:     def dependencies
// 22:       @dependencies ||= T.let([Cask::CaskLoader.load("adobe-air")], T.nilable(T::Array[Cask::Cask]))
// 23:     end
// 24:
// 25:     AIR_APPLICATION_INSTALLER =
// 26:       "/Applications/Utilities/Adobe AIR Application Installer.app/Contents/MacOS/Adobe AIR Application Installer"
// 27:
// 28:     private_constant :AIR_APPLICATION_INSTALLER
// 29:
// 30:     private
// 31:
// 32:     sig { override.params(unpack_dir: Pathname, basename: Pathname, verbose: T::Boolean).void }
// 33:     def extract_to_dir(unpack_dir, basename:, verbose:)
// 34:       system_command! AIR_APPLICATION_INSTALLER,
// 35:                       args:    ["-silent", "-location", unpack_dir, path],
// 36:                       verbose:
// 37:     end
// 38:   end
// 39: end
