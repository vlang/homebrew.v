module macho

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/tools.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.dylibs(filename)` at line 9.
pub fn ruby_tools_l9_d1_self_dylibs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.dylibs', ...args)
}

// Ruby method `self.change_dylib_id(filename, new_id, options = {})` at line 23.
pub fn ruby_tools_l23_d2_self_change_dylib_id(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.change_dylib_id', ...args)
}

// Ruby method `self.change_install_name(filename, old_name, new_name, options = {})` at line 39.
pub fn ruby_tools_l39_d3_self_change_install_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.change_install_name', ...args)
}

// Ruby method `self.change_rpath(filename, old_path, new_path, options = {})` at line 57.
pub fn ruby_tools_l57_d4_self_change_rpath(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.change_rpath', ...args)
}

// Ruby method `self.add_rpath(filename, new_path, options = {})` at line 71.
pub fn ruby_tools_l71_d5_self_add_rpath(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.add_rpath', ...args)
}

// Ruby method `self.delete_rpath(filename, old_path, options = {})` at line 88.
pub fn ruby_tools_l88_d6_self_delete_rpath(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.delete_rpath', ...args)
}

// Ruby method `self.merge_machos(filename, *files, fat64: false)` at line 100.
pub fn ruby_tools_l100_d7_self_merge_machos(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.merge_machos', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module MachO
// 4:   # A collection of convenient methods for common operations on Mach-O and Fat
// 5:   # binaries.
// 6:   module Tools
// 7:     # @param filename [String] the Mach-O or Fat binary being read
// 8:     # @return [Array<String>] an array of all dylibs linked to the binary
// 9:     def self.dylibs(filename)
// 10:       file = MachO.open(filename)
// 11:
// 12:       file.linked_dylibs
// 13:     end
// 14:
// 15:     # Changes the dylib ID of a Mach-O or Fat binary, overwriting the source
// 16:     #  file.
// 17:     # @param filename [String] the Mach-O or Fat binary being modified
// 18:     # @param new_id [String] the new dylib ID for the binary
// 19:     # @param options [Hash]
// 20:     # @option options [Boolean] :strict (true) whether or not to fail loudly
// 21:     #  with an exception if the change cannot be performed
// 22:     # @return [void]
// 23:     def self.change_dylib_id(filename, new_id, options = {})
// 24:       file = MachO.open(filename)
// 25:
// 26:       file.change_dylib_id(new_id, options)
// 27:       file.write!
// 28:     end
// 29:
// 30:     # Changes a shared library install name in a Mach-O or Fat binary,
// 31:     #  overwriting the source file.
// 32:     # @param filename [String] the Mach-O or Fat binary being modified
// 33:     # @param old_name [String] the old shared library name
// 34:     # @param new_name [String] the new shared library name
// 35:     # @param options [Hash]
// 36:     # @option options [Boolean] :strict (true) whether or not to fail loudly
// 37:     #  with an exception if the change cannot be performed
// 38:     # @return [void]
// 39:     def self.change_install_name(filename, old_name, new_name, options = {})
// 40:       file = MachO.open(filename)
// 41:
// 42:       file.change_install_name(old_name, new_name, options)
// 43:       file.write!
// 44:     end
// 45:
// 46:     # Changes a runtime path in a Mach-O or Fat binary, overwriting the source
// 47:     #  file.
// 48:     # @param filename [String] the Mach-O or Fat binary being modified
// 49:     # @param old_path [String] the old runtime path
// 50:     # @param new_path [String] the new runtime path
// 51:     # @param options [Hash]
// 52:     # @option options [Boolean] :strict (true) whether or not to fail loudly
// 53:     #  with an exception if the change cannot be performed
// 54:     # @option options [Boolean] :uniq (false) whether or not to change duplicate
// 55:     #  rpaths simultaneously
// 56:     # @return [void]
// 57:     def self.change_rpath(filename, old_path, new_path, options = {})
// 58:       file = MachO.open(filename)
// 59:
// 60:       file.change_rpath(old_path, new_path, options)
// 61:       file.write!
// 62:     end
// 63:
// 64:     # Add a runtime path to a Mach-O or Fat binary, overwriting the source file.
// 65:     # @param filename [String] the Mach-O or Fat binary being modified
// 66:     # @param new_path [String] the new runtime path
// 67:     # @param options [Hash]
// 68:     # @option options [Boolean] :strict (true) whether or not to fail loudly
// 69:     #  with an exception if the change cannot be performed
// 70:     # @return [void]
// 71:     def self.add_rpath(filename, new_path, options = {})
// 72:       file = MachO.open(filename)
// 73:
// 74:       file.add_rpath(new_path, options)
// 75:       file.write!
// 76:     end
// 77:
// 78:     # Delete a runtime path from a Mach-O or Fat binary, overwriting the source
// 79:     #  file.
// 80:     # @param filename [String] the Mach-O or Fat binary being modified
// 81:     # @param old_path [String] the old runtime path
// 82:     # @param options [Hash]
// 83:     # @option options [Boolean] :strict (true) whether or not to fail loudly
// 84:     #  with an exception if the change cannot be performed
// 85:     # @option options [Boolean] :uniq (false) whether or not to delete duplicate
// 86:     #  rpaths simultaneously
// 87:     # @return [void]
// 88:     def self.delete_rpath(filename, old_path, options = {})
// 89:       file = MachO.open(filename)
// 90:
// 91:       file.delete_rpath(old_path, options)
// 92:       file.write!
// 93:     end
// 94:
// 95:     # Merge multiple Mach-Os into one universal (Fat) binary.
// 96:     # @param filename [String] the fat binary to create
// 97:     # @param files [Array<String>] the files to merge
// 98:     # @param fat64 [Boolean] whether to use {Headers::FatArch64}s to represent each slice
// 99:     # @return [void]
// 100:     def self.merge_machos(filename, *files, fat64: false)
// 101:       machos = files.map do |file|
// 102:         macho = MachO.open(file)
// 103:         case macho
// 104:         when MachO::MachOFile
// 105:           macho
// 106:         else
// 107:           macho.machos
// 108:         end
// 109:       end.flatten
// 110:
// 111:       fat_macho = MachO::FatFile.new_from_machos(*machos, :fat64 => fat64)
// 112:       fat_macho.write(filename)
// 113:     end
// 114:   end
// 115: end
