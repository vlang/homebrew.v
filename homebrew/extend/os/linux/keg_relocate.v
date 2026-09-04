module linux

import ruby

// Translated from Homebrew/brew `extend/os/linux/keg_relocate.rb`.

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
