module macho

import ruby
import encoding.binary
import os

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho/tools.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ToolModificationOptions {
pub:
	strict bool = true
	uniq   bool
	last   bool
}

pub enum MachoBinaryKind {
	thin
	fat
}

// MachoBinary retains the concrete file returned by MachO.open while offering
// the common operations shared by MachoFile and FatFile.
@[heap]
pub struct MachoBinary {
pub:
	kind MachoBinaryKind
pub mut:
	thin &MachoFile = unsafe { nil }
	fat  &FatFile = unsafe { nil }
}

fn tool_options_from_value(value ruby.Value) ToolModificationOptions {
	values := value.as_map() or { return ToolModificationOptions{} }
	return ToolModificationOptions{
		strict: (values['strict'] or { ruby.bool_value(true) }).as_bool() or { true }
		uniq: (values['uniq'] or { ruby.bool_value(false) }).as_bool() or { false }
		last: (values['last'] or { ruby.bool_value(false) }).as_bool() or { false }
	}
}

fn tool_fat_options(options ToolModificationOptions) FatFileModificationOptions {
	return FatFileModificationOptions{
		strict: options.strict
		uniq: options.uniq
		last: options.last
	}
}

fn tool_delete_options(options ToolModificationOptions) DeleteRpathOptions {
	return DeleteRpathOptions{
		uniq: options.uniq
		last: options.last
	}
}

fn tool_source_error_message(message string) string {
	mut translated := message
	if translated.starts_with('File is too short') || translated.contains(' is truncated') {
		return 'File is too short to be a valid Mach-O'
	}
	translated = translated.replace('Mach-O dylib is missing LC_ID_DYLIB', 'Dylib is missing a dylib ID')
	translated = translated.replace('Unknown linked dylib: ', 'No such dylib name: ')
	translated = translated.replace('Unknown rpath: ', 'No such runtime path: ')
	if translated.contains('Rpath already exists: ') {
		prefix := translated.all_before('Rpath already exists: ')
		path := translated.all_after('Rpath already exists: ')
		translated = '${prefix}${path} already exists'
	}
	if translated.ends_with(': not enough header padding for the load command') {
		filename := translated.all_before(': not enough header padding for the load command')
		return 'Updated load commands do not fit in the header of ${filename}. ${filename} needs to be relinked, possibly with -headerpad or -headerpad_max_install_names'
	}
	return translated
}

pub fn macho_binary_boundary(file &MachoBinary) ruby.Value {
	return match file.kind {
		.thin { macho_file_boundary(file.thin) }
		.fat { fat_file_boundary(file.fat) }
	}
}

pub fn open_macho(filename string) !&MachoBinary {
	if !os.is_file(filename) {
		return error('${filename}: no such file')
	}
	data := os.read_bytes(filename)!
	if data.len < 4 {
		return truncated_file_error()
	}
	magic := binary.big_endian_u32(data[..4])
	if macho_fat_magic(magic) {
		fat := new_fat_file(filename, MachoFileOptions{}) or {
			return error(tool_source_error_message(err.msg()))
		}
		return &MachoBinary{
			kind: .fat
			fat: fat
		}
	}
	if macho_magic(magic) {
		thin := new_macho_file(filename, MachoFileOptions{}) or {
			return error(tool_source_error_message(err.msg()))
		}
		return &MachoBinary{
			kind: .thin
			thin: thin
		}
	}
	return magic_error(magic)
}

pub fn (file &MachoBinary) linked_dylibs() []string {
	return match file.kind {
		.thin { file.thin.linked_dylibs() }
		.fat { file.fat.linked_dylibs() }
	}
}

pub fn (file &MachoBinary) machos() []&MachoFile {
	return match file.kind {
		.thin { [file.thin] }
		.fat { file.fat.machos.clone() }
	}
}

pub fn (mut file MachoBinary) change_dylib_id(new_id string, options ToolModificationOptions) ! {
	match file.kind {
		.thin {
			mut thin := file.thin
			thin.change_dylib_id(new_id) or {
				return error(tool_source_error_message(err.msg()))
			}
		}
		.fat {
			mut fat := file.fat
			fat.change_dylib_id(new_id, tool_fat_options(options)) or {
				return error(tool_source_error_message(err.msg()))
			}
		}
	}
}

pub fn (mut file MachoBinary) change_install_name(old_name string, new_name string, options ToolModificationOptions) ! {
	match file.kind {
		.thin {
			mut thin := file.thin
			thin.change_install_name(old_name, new_name) or {
				return error(tool_source_error_message(err.msg()))
			}
		}
		.fat {
			mut fat := file.fat
			fat.change_install_name(old_name, new_name, tool_fat_options(options)) or {
				return error(tool_source_error_message(err.msg()))
			}
		}
	}
}

pub fn (mut file MachoBinary) change_rpath(old_path string, new_path string, options ToolModificationOptions) ! {
	match file.kind {
		.thin {
			mut thin := file.thin
			thin.change_rpath(old_path, new_path, tool_delete_options(options)) or {
				return error(tool_source_error_message(err.msg()))
			}
		}
		.fat {
			mut fat := file.fat
			fat.change_rpath(old_path, new_path, tool_fat_options(options)) or {
				return error(tool_source_error_message(err.msg()))
			}
		}
	}
}

pub fn (mut file MachoBinary) add_rpath(path string, options ToolModificationOptions) ! {
	match file.kind {
		.thin {
			mut thin := file.thin
			thin.add_rpath(path) or { return error(tool_source_error_message(err.msg())) }
		}
		.fat {
			mut fat := file.fat
			fat.add_rpath(path, tool_fat_options(options)) or {
				return error(tool_source_error_message(err.msg()))
			}
		}
	}
}

pub fn (mut file MachoBinary) delete_rpath(path string, options ToolModificationOptions) ! {
	match file.kind {
		.thin {
			mut thin := file.thin
			thin.delete_rpath(path, tool_delete_options(options)) or {
				return error(tool_source_error_message(err.msg()))
			}
		}
		.fat {
			mut fat := file.fat
			fat.delete_rpath(path, tool_fat_options(options)) or {
				return error(tool_source_error_message(err.msg()))
			}
		}
	}
}

pub fn (mut file MachoBinary) codesign(identifier string) ! {
	match file.kind {
		.thin {
			mut thin := file.thin
			thin.codesign(identifier)!
		}
		.fat {
			mut fat := file.fat
			fat.codesign(identifier)!
		}
	}
}

pub fn (file &MachoBinary) write_initial() !int {
	match file.kind {
		.thin { file.thin.write_initial()! }
		.fat { file.fat.write_initial()! }
	}
	return match file.kind {
		.thin { file.thin.raw_data.len }
		.fat { file.fat.raw_data.len }
	}
}

pub fn dylibs(filename string) ![]string {
	return open_macho(filename)!.linked_dylibs()
}

pub fn change_dylib_id(filename string, new_id string, options ToolModificationOptions) !int {
	mut file := open_macho(filename)!
	file.change_dylib_id(new_id, options)!
	return file.write_initial()!
}

pub fn change_install_name(filename string, old_name string, new_name string, options ToolModificationOptions) !int {
	mut file := open_macho(filename)!
	file.change_install_name(old_name, new_name, options)!
	return file.write_initial()!
}

pub fn change_rpath(filename string, old_path string, new_path string, options ToolModificationOptions) !int {
	mut file := open_macho(filename)!
	file.change_rpath(old_path, new_path, options)!
	return file.write_initial()!
}

pub fn add_rpath(filename string, new_path string, options ToolModificationOptions) !int {
	mut file := open_macho(filename)!
	file.add_rpath(new_path, options)!
	return file.write_initial()!
}

pub fn delete_rpath(filename string, old_path string, options ToolModificationOptions) !int {
	mut file := open_macho(filename)!
	file.delete_rpath(old_path, options)!
	return file.write_initial()!
}

pub fn merge_machos(filename string, files []string, fat64 bool) !int {
	mut machos := []&MachoFile{}
	for input in files {
		opened := open_macho(input)!
		machos << opened.machos()
	}
	fat_macho := new_fat_file_from_machos(machos, fat64)!
	fat_macho.write(filename)!
	return fat_macho.raw_data.len
}

// Ruby method `self.dylibs(filename)` at line 9.
pub fn ruby_tools_l9_d1_self_dylibs(args ...ruby.Value) ruby.Value {
	if args.len < 1 {
		panic('dylibs requires a filename')
	}
	return ruby.string_array_value(dylibs(args[0].as_string()) or { panic(err) })
}

// Ruby method `self.change_dylib_id(filename, new_id, options = {})` at line 23.
pub fn ruby_tools_l23_d2_self_change_dylib_id(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('change_dylib_id requires a filename and new ID')
	}
	options := if args.len > 2 {
		tool_options_from_value(args[2])
	} else {
		ToolModificationOptions{}
	}
	return ruby.int_value(change_dylib_id(args[0].as_string(), args[1].as_string(), options) or { panic(err) })
}

// Ruby method `self.change_install_name(filename, old_name, new_name, options = {})` at line 39.
pub fn ruby_tools_l39_d3_self_change_install_name(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('change_install_name requires a filename, old name, and new name')
	}
	options := if args.len > 3 {
		tool_options_from_value(args[3])
	} else {
		ToolModificationOptions{}
	}
	return ruby.int_value(change_install_name(args[0].as_string(), args[1].as_string(), args[2].as_string(), options) or { panic(err) })
}

// Ruby method `self.change_rpath(filename, old_path, new_path, options = {})` at line 57.
pub fn ruby_tools_l57_d4_self_change_rpath(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		panic('change_rpath requires a filename, old path, and new path')
	}
	options := if args.len > 3 {
		tool_options_from_value(args[3])
	} else {
		ToolModificationOptions{}
	}
	return ruby.int_value(change_rpath(args[0].as_string(), args[1].as_string(), args[2].as_string(), options) or { panic(err) })
}

// Ruby method `self.add_rpath(filename, new_path, options = {})` at line 71.
pub fn ruby_tools_l71_d5_self_add_rpath(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('add_rpath requires a filename and new path')
	}
	options := if args.len > 2 {
		tool_options_from_value(args[2])
	} else {
		ToolModificationOptions{}
	}
	return ruby.int_value(add_rpath(args[0].as_string(), args[1].as_string(), options) or {
		panic(err)
	})
}

// Ruby method `self.delete_rpath(filename, old_path, options = {})` at line 88.
pub fn ruby_tools_l88_d6_self_delete_rpath(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('delete_rpath requires a filename and old path')
	}
	options := if args.len > 2 {
		tool_options_from_value(args[2])
	} else {
		ToolModificationOptions{}
	}
	return ruby.int_value(delete_rpath(args[0].as_string(), args[1].as_string(), options) or {
		panic(err)
	})
}

// Ruby method `self.merge_machos(filename, *files, fat64: false)` at line 100.
pub fn ruby_tools_l100_d7_self_merge_machos(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('merge_machos requires an output filename and at least one input file')
	}
	mut values := args[1..].clone()
	mut fat64 := false
	if values.len > 0 && values.last().type_name == 'Hash' {
		options := values.pop().as_map() or { panic(err) }
		fat64 = (options['fat64'] or { ruby.bool_value(false) }).as_bool() or { false }
	}
	mut files := []string{}
	for value in values {
		if value.type_name == 'Array' {
			files << (value.as_array() or { panic(err) }).map(it.as_string())
		} else {
			files << value.as_string()
		}
	}
	return ruby.int_value(merge_machos(args[0].as_string(), files, fat64) or {
		panic(err)
	})
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
