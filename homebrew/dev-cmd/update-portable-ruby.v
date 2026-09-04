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

pub fn update_portable_ruby_input_boundary(input &UpdatePortableRubyInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::UpdatePortableRuby::Input', '', {
		'update_portable_ruby_input_address': u64(voidptr(input)).str()
	})
}

fn update_portable_ruby_input_from_value(value ruby.Value) &UpdatePortableRubyInput {
	address := value.attributes['update_portable_ruby_input_address'] or {
		panic('invalid UpdatePortableRuby input')
	}
	return unsafe { &UpdatePortableRubyInput(voidptr(address.u64())) }
}

fn update_portable_ruby_result_value(result UpdatePortableRubyResult) ruby.Value {
	mut writes := map[string]ruby.Value{}
	for path, contents in result.writes {
		writes[path] = ruby.string_value(contents)
	}
	return ruby.map_value({
		'formula_name': ruby.string_value(result.formula_name)
		'no_api':       ruby.bool_value(result.no_api)
		'writes':       ruby.map_value(writes)
		'commands':     ruby.array_value(result.commands.map(ruby.string_array_value(it)))
	})
}
