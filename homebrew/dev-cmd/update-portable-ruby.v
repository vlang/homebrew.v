module dev_cmd

import brew_runtime
import os

// Translated from Homebrew/brew `dev-cmd/update-portable-ruby.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct PortableRubyChecksum {
pub:
	tag               string
	digest            string
	standardized_arch string
	linux             bool
}

pub struct UpdatePortableRubyOptions {
pub:
	library_path   string
	brew_file      string
	version        string
	pkg_version    string
	bundler_version string
	checksums      []PortableRubyChecksum
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
		os.join_path(vendor_dir, 'portable-ruby-version'): '${options.pkg_version}\n'
		os.join_path(options.library_path, '.ruby-version'): '${options.version}\n'
	}
	for checksum in options.checksums {
		operating_system := if checksum.linux { 'linux' } else { 'darwin' }
		path := os.join_path(vendor_dir, 'portable-ruby-${checksum.standardized_arch}-${operating_system}')
		writes[path] = 'ruby_TAG=${checksum.tag}\nruby_SHA=${checksum.digest}\n'
	}
	for path, contents in writes {
		brew_runtime.atomic_write_file(path, contents)!
	}
	return UpdatePortableRubyResult{
		formula_name: 'portable-ruby'
		no_api: true
		writes: writes
		commands: [
			[options.brew_file, 'vendor-install', 'ruby'],
			[options.brew_file, 'vendor-gems', '--no-commit', '--update=--ruby,--bundler=${options.bundler_version}'],
			[options.brew_file, 'typecheck', '--update'],
		]
	}
}

@[heap]
pub struct UpdatePortableRubyInput {
pub:
	options UpdatePortableRubyOptions
}

pub fn update_portable_ruby_input_boundary(input &UpdatePortableRubyInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::UpdatePortableRuby::Input', '', {
		'update_portable_ruby_input_address': u64(voidptr(input)).str()
	})
}

fn update_portable_ruby_input_from_value(value brew_runtime.Value) &UpdatePortableRubyInput {
	address := value.attributes['update_portable_ruby_input_address'] or {
		panic('invalid UpdatePortableRuby input')
	}
	return unsafe { &UpdatePortableRubyInput(voidptr(address.u64())) }
}

fn update_portable_ruby_result_value(result UpdatePortableRubyResult) brew_runtime.Value {
	mut writes := map[string]brew_runtime.Value{}
	for path, contents in result.writes {
		writes[path] = brew_runtime.string_value(contents)
	}
	return brew_runtime.map_value({
		'formula_name': brew_runtime.string_value(result.formula_name)
		'no_api': brew_runtime.bool_value(result.no_api)
		'writes': brew_runtime.map_value(writes)
		'commands': brew_runtime.array_value(result.commands.map(brew_runtime.string_array_value(it)))
	})
}

// Ruby method `run` at line 25.
pub fn ruby_update_portable_ruby_l25_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return update_portable_ruby_result_value(run_update_portable_ruby(update_portable_ruby_input_from_value(args[0]).options) or {
		return brew_runtime.object_value('Error', err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "utils/bottles"
// 7: require "utils/portable_ruby"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class UpdatePortableRuby < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Update the vendored `portable-ruby` from the current `portable-ruby` formula:
// 15:           write the version files and bottle checksums, run `brew vendor-install ruby`,
// 16:           then sync `utils/ruby.sh`, vendored gems and RBI files to the bundler shipped
// 17:           by the new ruby.
// 18:         EOS
// 19:         named_args :none
// 20:
// 21:         hide_from_man_page!
// 22:       end
// 23:
// 24:       sig { override.void }
// 25:       def run
// 26:         formula = Homebrew.with_no_api_env { Formulary.factory("portable-ruby") }
// 27:         version = formula.version.to_s
// 28:         pkg_version = formula.pkg_version.to_s
// 29:         vendor_dir = HOMEBREW_LIBRARY_PATH/"vendor"
// 30:
// 31:         (vendor_dir/"portable-ruby-version").atomic_write("#{pkg_version}\n")
// 32:         (HOMEBREW_LIBRARY_PATH/".ruby-version").atomic_write("#{version}\n")
// 33:
// 34:         formula.bottle_specification.checksums.each do |checksum|
// 35:           tag_symbol = checksum.fetch("tag")
// 36:           tag = Utils::Bottles::Tag.from_symbol(tag_symbol)
// 37:           os = tag.linux? ? "linux" : "darwin"
// 38:           path = vendor_dir/"portable-ruby-#{tag.standardized_arch}-#{os}"
// 39:           path.atomic_write("ruby_TAG=#{tag_symbol}\nruby_SHA=#{checksum.fetch("digest")}\n")
// 40:         end
// 41:
// 42:         safe_system HOMEBREW_BREW_FILE, "vendor-install", "ruby"
// 43:
// 44:         bundler_version = Utils::PortableRuby.sync_bundler_version!(pkg_version)
// 45:         safe_system HOMEBREW_BREW_FILE, "vendor-gems", "--no-commit",
// 46:                     "--update=--ruby,--bundler=#{bundler_version}"
// 47:         safe_system HOMEBREW_BREW_FILE, "typecheck", "--update"
// 48:       end
// 49:     end
// 50:   end
// 51: end
