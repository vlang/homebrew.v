module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/update-portable-ruby.rb`.

pub struct PortableRubyChecksum {
pub:
	tag               string
	digest            string
	standardized_arch string
	linux             bool
}

pub struct UpdatePortableRubyOptions {
pub:
	library_path    string
	brew_file       string
	version         string
	pkg_version     string
	bundler_version string
	checksums       []PortableRubyChecksum
}

pub struct UpdatePortableRubyResult {
pub:
	formula_name string
	no_api       bool
	writes       map[string]string
	commands     [][]string
}

pub fn run_update_portable_ruby(options UpdatePortableRubyOptions) !UpdatePortableRubyResult {
	vendor_dir := os.join_path(options.library_path, 'vendor')
	os.mkdir_all(vendor_dir)!
	mut writes := {
		os.join_path(vendor_dir, 'portable-ruby-version'):   '${options.pkg_version}\n'
		os.join_path(options.library_path, '.ruby-version'): '${options.version}\n'
	}
	for checksum in options.checksums {
		operating_system := if checksum.linux { 'linux' } else { 'darwin' }
		path := os.join_path(vendor_dir, 'portable-ruby-${checksum.standardized_arch}-${operating_system}')
		writes[path] = 'ruby_TAG=${checksum.tag}\nruby_SHA=${checksum.digest}\n'
	}
	for path, contents in writes {
		ruby.atomic_write_file(path, contents)!
	}
	return UpdatePortableRubyResult{
		formula_name: 'portable-ruby'
		no_api: true
		writes: writes
		commands: [
			[options.brew_file, 'vendor-install', 'ruby'],
			[options.brew_file, 'vendor-gems', '--no-commit',
				'--update=--ruby,--bundler=${options.bundler_version}'],
			[options.brew_file, 'typecheck', '--update'],
		]
	}
}

@[heap]
pub struct UpdatePortableRubyInput {
pub:
	options UpdatePortableRubyOptions
}
