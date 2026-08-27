module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/update-portable-ruby.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 25.
pub fn ruby_update_portable_ruby_l25_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
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
