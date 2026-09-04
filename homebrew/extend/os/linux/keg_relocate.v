module linux

import ruby

// Translated from Homebrew/brew `extend/os/linux/keg_relocate.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct LinuxElfFile {
pub:
	path               string
	elf                bool
	dynamic            bool
	binary_executable  bool
	dylib              bool
	section_names      []string
	dynamically_linked []string
	device             u64
	inode              u64
pub mut:
	rpath           string
	has_rpath       bool
	interpreter     string
	has_interpreter bool
	patched         bool
}

@[heap]
pub struct LinuxKegRelocateContext {
pub:
	name            string
	path            string
	readable_loader bool
pub mut:
	files              []LinuxElfFile
	require_relocation bool
}

fn linux_versioned_formula_name(name string, formula string) bool {
	return name == formula || name.starts_with('${formula}@')
}

fn linux_numeric_string(value string) bool {
	if value == '' {
		return false
	}
	for character in value.bytes() {
		if character < `0` || character > `9` {
			return false
		}
	}
	return true
}

fn linux_current_gcc_rpath(path string) string {
	mut parts := path.split('/')
	if parts.len >= 3 && parts[parts.len - 2] == 'gcc' && linux_numeric_string(parts.last()) {
		parts[parts.len - 1] = 'current'
		return parts.join('/')
	}
	return path
}

pub fn linux_change_rpath(mut file LinuxElfFile, keg_name string, old_prefix string,
	new_prefix string, skip_protodesc_cold bool, readable_loader bool) bool {
	if !file.elf || !file.dynamic {
		return false
	}
	if skip_protodesc_cold && 'protodesc_cold' in file.section_names {
		return false
	}
	mut changed := false
	if file.has_rpath {
		mut rpaths := []string{}
		for old_rpath in file.rpath.split(':') {
			mut rpath := old_rpath.replace_once(old_prefix, new_prefix)
			if !rpath.starts_with(new_prefix) && !rpath.starts_with(r'$ORIGIN') {
				continue
			}
			if !linux_versioned_formula_name(keg_name, 'gcc') {
				rpath = linux_current_gcc_rpath(rpath)
			}
			if rpath !in rpaths {
				rpaths << rpath
			}
		}
		lib_path := '${new_prefix}/lib'
		if lib_path !in rpaths {
			rpaths << lib_path
		}
		new_rpath := rpaths.join(':')
		if new_rpath != file.rpath {
			file.rpath = new_rpath
			changed = true
		}
	}
	if file.has_interpreter {
		new_interpreter := if readable_loader {
			'${new_prefix}/lib/ld.so'
		} else {
			file.interpreter.replace_once(old_prefix, new_prefix)
		}
		if new_interpreter != file.interpreter {
			file.interpreter = new_interpreter
			changed = true
		}
	}
	if changed {
		file.patched = true
	}
	return changed
}

pub fn linux_elf_file_indexes(context &LinuxKegRelocateContext) []int {
	mut indexes := []int{}
	mut hardlinks := map[string]bool{}
	for index, file in context.files {
		if !file.dylib && !file.binary_executable {
			continue
		}
		key := if file.device == 0 && file.inode == 0 {
			file.path
		} else {
			'${file.device}:${file.inode}'
		}
		if key in hardlinks {
			continue
		}
		hardlinks[key] = true
		indexes << index
	}
	return indexes
}

pub fn linux_elf_files(context &LinuxKegRelocateContext) []LinuxElfFile {
	return linux_elf_file_indexes(context).map(context.files[it])
}

pub fn linux_relocate_dynamic_linkage(mut context LinuxKegRelocateContext, old_prefix string,
	new_prefix string, skip_protodesc_cold bool) {
	if linux_versioned_formula_name(context.name, 'glibc') {
		return
	}
	for index in linux_elf_file_indexes(context) {
		mut file := context.files[index]
		if linux_change_rpath(mut file, context.name, old_prefix, new_prefix, skip_protodesc_cold, context.readable_loader) {
			context.require_relocation = true
		}
		context.files[index] = file
	}
}

pub fn linux_detect_cxx_stdlibs(context &LinuxKegRelocateContext,
	skip_executables bool) []string {
	mut results := []string{}
	for file in linux_elf_files(context) {
		if !file.dynamic || (skip_executables && file.binary_executable) {
			continue
		}
		for library in file.dynamically_linked {
			if library.contains('libc++.so') && 'libcxx' !in results {
				results << 'libcxx'
			}
			if library.contains('libstdc++.so') && 'libstdcxx' !in results {
				results << 'libstdcxx'
			}
		}
	}
	return results
}

pub fn linux_keg_relocate_boundary(context &LinuxKegRelocateContext) ruby.Value {
	return ruby.structured_value('OS::Linux::Keg', context.path, {
		'linux_keg_relocate_address': u64(voidptr(context)).str()
	})
}

fn linux_keg_relocate_from_value(value ruby.Value) &LinuxKegRelocateContext {
	address := value.attributes['linux_keg_relocate_address'] or {
		panic('invalid Linux keg relocation receiver')
	}
	return unsafe { &LinuxKegRelocateContext(voidptr(address.u64())) }
}

// Ruby method `relocate_dynamic_linkage(relocation, skip_protodesc_cold: false)` at line 14.
pub fn ruby_keg_relocate_l14_d1_relocate_dynamic_linkage(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.object_value('ArgumentError', 'receiver and replacement pair are required')
	}
	mut context := linux_keg_relocate_from_value(args[0])
	linux_relocate_dynamic_linkage(mut context, args[1].as_string(), args[2].as_string(), if args.len > 3 {
		args[3].as_bool() or { false }
	} else {
		false
	})
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `change_rpath!(file, old_prefix, new_prefix, skip_protodesc_cold: false)` at line 31.
pub fn ruby_keg_relocate_l31_d2_change_rpath(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		return ruby.bool_value(false)
	}
	mut context := linux_keg_relocate_from_value(args[0])
	path := args[1].as_string()
	for index, existing in context.files {
		if existing.path != path {
			continue
		}
		mut file := context.files[index]
		changed := linux_change_rpath(mut file, context.name, args[2].as_string(), args[3].as_string(), if args.len > 4 {
			args[4].as_bool() or { false }
		} else {
			false
		}, context.readable_loader)
		context.files[index] = file
		if changed {
			context.require_relocation = true
		}
		return ruby.bool_value(changed)
	}
	return ruby.bool_value(false)
}

// Ruby method `detect_cxx_stdlibs(options = {})` at line 76.
pub fn ruby_keg_relocate_l76_d3_detect_cxx_stdlibs(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	context := linux_keg_relocate_from_value(args[0])
	skip_executables := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	return ruby.string_array_value(linux_detect_cxx_stdlibs(context, skip_executables))
}

// Ruby method `elf_files` at line 91.
pub fn ruby_keg_relocate_l91_d4_elf_files(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	context := linux_keg_relocate_from_value(args[0])
	return ruby.string_array_value(linux_elf_files(context).map(it.path))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "compilers"
// 5:
// 6: module OS
// 7:   module Linux
// 8:     module Keg
// 9:       extend T::Helpers
// 10:
// 11:       requires_ancestor { ::Keg }
// 12:
// 13:       sig { params(relocation: ::Keg::Relocation, skip_protodesc_cold: T::Boolean).void }
// 14:       def relocate_dynamic_linkage(relocation, skip_protodesc_cold: false)
// 15:         # Patching the dynamic linker of glibc breaks it.
// 16:         return if name.match? Version.formula_optionally_versioned_regex(:glibc)
// 17:
// 18:         old_prefix, new_prefix = relocation.replacement_pair_for(:prefix)
// 19:
// 20:         elf_files.each do |file|
// 21:           file.ensure_writable do
// 22:             change_rpath!(file, old_prefix, new_prefix, skip_protodesc_cold:)
// 23:           end
// 24:         end
// 25:       end
// 26:
// 27:       sig {
// 28:         params(file: ELFShim, old_prefix: T.any(String, Regexp), new_prefix: String,
// 29:                skip_protodesc_cold: T::Boolean).returns(T::Boolean)
// 30:       }
// 31:       def change_rpath!(file, old_prefix, new_prefix, skip_protodesc_cold: false)
// 32:         return false if !file.elf? || !file.dynamic_elf?
// 33:
// 34:         # Skip relocation of files with `protodesc_cold` sections because patchelf.rb seems to break them,
// 35:         # but only when bottling (as we don't want to break existing bottles that require relocation).
// 36:         # https://github.com/Homebrew/homebrew-core/pull/232490#issuecomment-3161362452
// 37:         return false if skip_protodesc_cold && file.section_names.include?("protodesc_cold")
// 38:
// 39:         updated = {}
// 40:         old_rpath = file.rpath
// 41:         new_rpath = if old_rpath
// 42:           rpath = old_rpath.split(":")
// 43:                            .map { |x| x.sub(old_prefix, new_prefix) }
// 44:                            .select { |x| x.start_with?(new_prefix, "$ORIGIN") }
// 45:
// 46:           lib_path = "#{new_prefix}/lib"
// 47:           rpath << lib_path unless rpath.include? lib_path
// 48:
// 49:           # Add GCC's lib directory (as of GCC 12+) to RPATH when there is existing versioned linkage.
// 50:           # This prevents broken linkage when pouring bottles built with an old GCC formula.
// 51:           unless name.match?(Version.formula_optionally_versioned_regex(:gcc))
// 52:             rpath.map! { |rp| rp.sub(%r{lib/gcc/\d+$}, "lib/gcc/current") }
// 53:           end
// 54:
// 55:           rpath.join(":")
// 56:         end
// 57:         updated[:rpath] = new_rpath if old_rpath != new_rpath
// 58:
// 59:         old_interpreter = file.interpreter
// 60:         new_interpreter = if old_interpreter.nil?
// 61:           nil
// 62:         elsif File.readable? "#{new_prefix}/lib/ld.so"
// 63:           "#{new_prefix}/lib/ld.so"
// 64:         else
// 65:           old_interpreter.sub old_prefix, new_prefix
// 66:         end
// 67:         updated[:interpreter] = new_interpreter if old_interpreter != new_interpreter
// 68:         return false if updated.empty?
// 69:
// 70:         file.patch!(interpreter: updated[:interpreter], rpath: updated[:rpath])
// 71:         require_relocation!
// 72:         true
// 73:       end
// 74:
// 75:       sig { params(options: T::Hash[Symbol, T::Boolean]).returns(T::Array[Symbol]) }
// 76:       def detect_cxx_stdlibs(options = {})
// 77:         skip_executables = options.fetch(:skip_executables, false)
// 78:         results = Set.new
// 79:         elf_files.each do |file|
// 80:           next unless file.dynamic_elf?
// 81:           next if file.binary_executable? && skip_executables
// 82:
// 83:           dylibs = file.dynamically_linked_libraries
// 84:           results << :libcxx if dylibs.any? { |s| s.include? "libc++.so" }
// 85:           results << :libstdcxx if dylibs.any? { |s| s.include? "libstdc++.so" }
// 86:         end
// 87:         results.to_a
// 88:       end
// 89:
// 90:       sig { returns(T::Array[ELFShim]) }
// 91:       def elf_files
// 92:         hardlinks = Set.new
// 93:         elf_files = []
// 94:         path.find do |pn|
// 95:           next if pn.symlink? || pn.directory?
// 96:
// 97:           pn = ELFPathname.wrap(pn)
// 98:           next if !pn.dylib? && !pn.binary_executable?
// 99:
// 100:           # If we've already processed a file, ignore its hardlinks (which have the
// 101:           # same dev ID and inode). This prevents relocations from being performed
// 102:           # on a binary more than once.
// 103:           next unless hardlinks.add? [pn.stat.dev, pn.stat.ino]
// 104:
// 105:           elf_files << pn
// 106:         end
// 107:         elf_files
// 108:       end
// 109:     end
// 110:   end
// 111: end
// 112:
// 113: Keg.prepend(OS::Linux::Keg)
