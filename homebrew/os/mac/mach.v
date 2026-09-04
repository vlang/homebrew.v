module mac

import ruby
import os

pub struct MachSlice {
pub:
	cpu_type  string
	file_type string
}

pub struct MachLibrary {
pub:
	name  string
	flags []string
}

pub struct MachState {
pub:
	path string
pub mut:
	dylib_id  string
	slices    []MachSlice
	rpaths    []string
	libraries []MachLibrary
	writes    int
}

pub fn new_mach_state(path string, slices []MachSlice, rpaths []string,
	libraries []MachLibrary, dylib_id string) &MachState {
	return &MachState{
		path: path
		slices: slices.clone()
		rpaths: rpaths.clone()
		libraries: libraries.clone()
		dylib_id: dylib_id
	}
}

fn mach_arch_name(cpu_type string) string {
	return match cpu_type {
		'x86_64', 'i386', 'ppc64', 'arm64', 'arm' { cpu_type }
		'ppc' { 'ppc7400' }
		else { 'dunno' }
	}
}

fn mach_file_type(file_type string) string {
	return match file_type {
		'dylib', 'bundle' { file_type }
		'execute' { 'executable' }
		else { 'dunno' }
	}
}

pub fn (state MachState) archs() []string {
	return state.slices.map(mach_arch_name(it.cpu_type))
}

pub fn (state MachState) arch() string {
	architectures := state.archs()
	return match architectures.len {
		0 { 'dunno' }
		1 { architectures[0] }
		else { 'universal' }
	}
}

pub fn (state MachState) has_type(kind string) bool {
	return state.slices.any(mach_file_type(it.file_type) == kind)
}

pub fn (state MachState) resolve_variable_name(name string, resolve_rpaths bool) string {
	directory := os.dir(state.path)
	if name.starts_with('@loader_path') {
		return os.norm_path(name.replace_once('@loader_path', directory))
	}
	if name.starts_with('@executable_path') && state.has_type('executable') {
		return os.norm_path(name.replace_once('@executable_path', directory))
	}
	if resolve_rpaths && name.starts_with('@rpath') {
		return state.resolve_rpath(name) or { name }
	}
	return name
}

pub fn (state MachState) resolved_rpaths(resolve_variables bool) []string {
	if !resolve_variables {
		return state.rpaths.clone()
	}
	return state.rpaths.map(state.resolve_variable_name(it, false))
}

pub fn (state MachState) resolve_rpath(name string) ?string {
	suffix := name.trim_string_left('@rpath').trim_left('/')
	for rpath in state.resolved_rpaths(true) {
		candidate := os.join_path(rpath, suffix)
		if os.exists(candidate) {
			return candidate
		}
	}
	return none
}

pub fn (state MachState) dynamically_linked_libraries(except_flag string,
	resolve_variables bool) []string {
	mut names := []string{}
	for library in state.libraries {
		if except_flag != 'none' && except_flag in library.flags {
			continue
		}
		name := if resolve_variables {
			state.resolve_variable_name(library.name, true)
		} else {
			library.name
		}
		if name !in names {
			names << name
		}
	}
	return names
}

pub fn (mut state MachState) delete_rpath(rpath string, strict bool) !string {
	resolved := state.resolve_variable_name(rpath, true)
	mut candidate_index := -1
	for index, existing in state.rpaths {
		if state.resolve_variable_name(existing, true) == resolved {
			candidate_index = index
		}
	}
	if candidate_index < 0 {
		return ''
	}
	state.rpaths.delete(candidate_index)
	state.writes++
	return rpath
}

pub fn (mut state MachState) change_rpath(old string, replacement string, uniq bool,
	last bool, strict bool) ! {
	mut indexes := []int{}
	for index, existing in state.rpaths {
		if existing == old { indexes << index }
	}
	if indexes.len == 0 {
		if strict {
			return error('rpath ${old} not found')
		}
		return
	}
	selected := if last { [indexes.last()] } else { indexes }
	for index in selected {
		state.rpaths[index] = replacement
	}
	if uniq {
		mut unique := []string{}
		for value in state.rpaths {
			if value !in unique { unique << value }
		}
		state.rpaths = unique.clone()
	}
	state.writes++
}

pub fn (mut state MachState) change_dylib_id(identifier string, strict bool) ! {
	if strict && state.dylib_id == '' {
		return error('dylib id not found')
	}
	state.dylib_id = identifier
	state.writes++
}

pub fn (mut state MachState) change_install_name(old string, replacement string,
	strict bool) ! {
	mut changed := false
	for index, library in state.libraries {
		if library.name == old {
			state.libraries[index] = MachLibrary{ ...library, name: replacement }
			changed = true
		}
	}
	if strict && !changed {
		return error('install name ${old} not found')
	}
	if changed { state.writes++ }
}

pub fn mach_text_executable(contents string) bool {
	return contents.starts_with('#!')
}

fn mach_state_value(state &MachState) ruby.Value {
	return ruby.structured_value('MachOPathname', state.path, {
		'mach_address': u64(voidptr(state)).str()
	})
}

fn mach_state_from_value(value ruby.Value) &MachState {
	address := value.attributes['mach_address'] or { panic('invalid MachOPathname receiver') }
	return unsafe { &MachState(voidptr(address.u64())) }
}

// Translated from Homebrew/brew `os/mac/mach.rb`.
