module unpack_strategy

import ruby

// Translated from Homebrew/brew `unpack_strategy/air.rb`.

pub fn air_extensions() []string {
	return ['.air']
}

pub fn air_can_extract(path string) bool {
	return file_has_bytes_at(path, 59, 'application/vnd.adobe.air-application-installer-package+zip'.bytes())
}

pub fn air_dependencies() []string {
	return ['adobe-air']
}

pub fn air_extract_to_dir(path string, unpack_dir string, basename string, verbose bool) ! {
	_ = basename
	_ = verbose
	installer := '/Applications/Utilities/Adobe AIR Application Installer.app/Contents/MacOS/Adobe AIR Application Installer'
	if !ruby.is_file(installer) {
		return error('Adobe AIR Application Installer is required to extract ${path}')
	}
	checked_command(installer, ['-silent', '-location', unpack_dir, path])!
}
