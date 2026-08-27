module bundle

import brew_runtime

// Translated from Homebrew/brew `bundle/dumper.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.can_write_to_brewfile?(brewfile_path, force: false)` at line 13.
pub fn ruby_dumper_l13_d1_self_can_write_to_brewfile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.can_write_to_brewfile?', ...args)
}

// Ruby method `self.build_brewfile(describe:, no_restart:, formulae:, taps:, casks:, extension_types: {})` at line 29.
pub fn ruby_dumper_l29_d2_self_build_brewfile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.build_brewfile', ...args)
}

// Ruby method `self.dump_brewfile(global:, file:, describe:, force:, no_restart:, formulae:, taps:, casks:,` at line 70.
pub fn ruby_dumper_l70_d3_self_dump_brewfile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.dump_brewfile', ...args)
}

// Ruby method `self.brewfile_path(global: false, file: nil)` at line 81.
pub fn ruby_dumper_l81_d4_self_brewfile_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.brewfile_path', ...args)
}

// Ruby method `self.should_not_write_file?(file, overwrite: false)` at line 87.
pub fn ruby_dumper_l87_d5_self_should_not_write_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.should_not_write_file?', ...args)
}

// Ruby method `self.write_file(file, content)` at line 92.
pub fn ruby_dumper_l92_d6_self_write_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.write_file', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "fileutils"
// 5: require "bundle/dsl"
// 6: require "bundle/extensions"
// 7: require "bundle/package_types"
// 8:
// 9: module Homebrew
// 10:   module Bundle
// 11:     module Dumper
// 12:       sig { params(brewfile_path: Pathname, force: T::Boolean).returns(T::Boolean) }
// 13:       private_class_method def self.can_write_to_brewfile?(brewfile_path, force: false)
// 14:         raise "#{brewfile_path} already exists" if should_not_write_file?(brewfile_path, overwrite: force)
// 15:
// 16:         true
// 17:       end
// 18:
// 19:       sig {
// 20:         params(
// 21:           describe:        T::Boolean,
// 22:           no_restart:      T::Boolean,
// 23:           formulae:        T::Boolean,
// 24:           taps:            T::Boolean,
// 25:           casks:           T::Boolean,
// 26:           extension_types: Homebrew::Bundle::ExtensionTypes,
// 27:         ).returns(String)
// 28:       }
// 29:       def self.build_brewfile(describe:, no_restart:, formulae:, taps:, casks:, extension_types: {})
// 30:         selected_package_types = extension_types.dup
// 31:         selected_package_types[:tap] = taps
// 32:         selected_package_types[:brew] = formulae
// 33:         selected_package_types[:cask] = casks
// 34:         dumped_formulae = if formulae
// 35:           Homebrew::Bundle::Brew.formulae.filter_map { |f| f[:full_name] if f[:installed_on_request?] }
// 36:         else
// 37:           []
// 38:         end
// 39:         dumped_casks = if casks
// 40:           Homebrew::Bundle::Cask.casks.map(&:full_name)
// 41:         else
// 42:           []
// 43:         end
// 44:         content = []
// 45:         Homebrew::Bundle.dump_package_types.select(&:dump_supported?).each do |package_type|
// 46:           next unless selected_package_types.fetch(package_type.type, false)
// 47:
// 48:           content << if package_type == Homebrew::Bundle::Tap
// 49:             Homebrew::Bundle::Tap.dump(dumped_formulae:, dumped_casks:)
// 50:           else
// 51:             package_type.dump_output(describe:, no_restart:)
// 52:           end
// 53:         end
// 54:         "#{content.reject(&:empty?).join("\n")}\n"
// 55:       end
// 56:
// 57:       sig {
// 58:         params(
// 59:           global:          T::Boolean,
// 60:           file:            T.nilable(String),
// 61:           describe:        T::Boolean,
// 62:           force:           T::Boolean,
// 63:           no_restart:      T::Boolean,
// 64:           formulae:        T::Boolean,
// 65:           taps:            T::Boolean,
// 66:           casks:           T::Boolean,
// 67:           extension_types: Homebrew::Bundle::ExtensionTypes,
// 68:         ).void
// 69:       }
// 70:       def self.dump_brewfile(global:, file:, describe:, force:, no_restart:, formulae:, taps:, casks:,
// 71:                              extension_types: {})
// 72:         path = brewfile_path(global:, file:)
// 73:         can_write_to_brewfile?(path, force:)
// 74:         content = build_brewfile(
// 75:           describe:, no_restart:, taps:, formulae:, casks:, extension_types:,
// 76:         )
// 77:         write_file path, content
// 78:       end
// 79:
// 80:       sig { params(global: T::Boolean, file: T.nilable(String)).returns(Pathname) }
// 81:       def self.brewfile_path(global: false, file: nil)
// 82:         require "bundle/brewfile"
// 83:         Brewfile.path(dash_writes_to_stdout: true, global:, file:)
// 84:       end
// 85:
// 86:       sig { params(file: Pathname, overwrite: T::Boolean).returns(T::Boolean) }
// 87:       private_class_method def self.should_not_write_file?(file, overwrite: false)
// 88:         file.exist? && !overwrite && file.to_s != "/dev/stdout"
// 89:       end
// 90:
// 91:       sig { params(file: Pathname, content: String).void }
// 92:       def self.write_file(file, content)
// 93:         Bundle.exchange_uid_if_needed! do
// 94:           file.open("w") { |io| io.write content }
// 95:         end
// 96:       end
// 97:     end
// 98:   end
// 99: end
