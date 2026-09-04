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
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(*args)` at line 14.
pub fn ruby_mach_l14_d1_initialize(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 { args[0].as_string() } else { '' }
	return mach_state_value(new_mach_state(path, []MachSlice{}, []string{}, []MachLibrary{}, ''))
}

// Ruby method `dylib_id = macho.dylib_id` at line 24.
pub fn ruby_mach_l24_d2_dylib_id(args ...ruby.Value) ruby.Value {
	identifier := mach_state_from_value(args[0]).dylib_id
	return if identifier == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.string_value(identifier)
	}
}

// Ruby method `macho` at line 27.
pub fn ruby_mach_l27_d3_macho(args ...ruby.Value) ruby.Value {
	return args[0]
}

// Ruby method `mach_data` at line 34.
pub fn ruby_mach_l34_d4_mach_data(args ...ruby.Value) ruby.Value {
	state := mach_state_from_value(args[0])
	return ruby.array_value(state.slices.map(ruby.map_value({
		'arch': ruby.object_value('Symbol', mach_arch_name(it.cpu_type))
		'type': ruby.object_value('Symbol', mach_file_type(it.file_type))
	})))
}

// Ruby method `delete_rpath(rpath, strict: true)` at line 78.
pub fn ruby_mach_l78_d5_delete_rpath(args ...ruby.Value) ruby.Value {
	mut state := mach_state_from_value(args[0])
	deleted := state.delete_rpath(args[1].as_string(), if args.len > 2 {
		args[2].bool_data
	} else {
		true
	}) or { panic(err) }
	return if deleted == '' {
		ruby.object_value('NilClass', 'nil')
	} else {
		ruby.string_value(deleted)
	}
}

// Ruby method `change_rpath(old, new, uniq: false, last: false, strict: true)` at line 94.
pub fn ruby_mach_l94_d6_change_rpath(args ...ruby.Value) ruby.Value {
	mut state := mach_state_from_value(args[0])
	options := if args.len > 3 { args[3].map_data.clone() } else { map[string]ruby.Value{} }
	state.change_rpath(args[1].as_string(), args[2].as_string(), (options['uniq'] or { ruby.bool_value(false) }).bool_data, (options['last'] or { ruby.bool_value(false) }).bool_data, (options['strict'] or { ruby.bool_value(true) }).bool_data) or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `change_dylib_id(id, strict: true)` at line 100.
pub fn ruby_mach_l100_d7_change_dylib_id(args ...ruby.Value) ruby.Value {
	mut state := mach_state_from_value(args[0])
	state.change_dylib_id(args[1].as_string(), if args.len > 2 { args[2].bool_data } else { true }) or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `change_install_name(old, new, strict: true)` at line 106.
pub fn ruby_mach_l106_d8_change_install_name(args ...ruby.Value) ruby.Value {
	mut state := mach_state_from_value(args[0])
	state.change_install_name(args[1].as_string(), args[2].as_string(), if args.len > 3 {
		args[3].bool_data
	} else {
		true
	}) or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `dynamically_linked_libraries(except: :none, resolve_variable_references: true)` at line 112.
pub fn ruby_mach_l112_d9_dynamically_linked_libraries(args ...ruby.Value) ruby.Value {
	state := mach_state_from_value(args[0])
	except_flag := if args.len > 1 { args[1].as_string() } else { 'none' }
	resolve := if args.len > 2 { args[2].bool_data } else { true }
	return ruby.string_array_value(state.dynamically_linked_libraries(except_flag, resolve))
}

// Ruby method `rpaths(resolve_variable_references: true)` at line 122.
pub fn ruby_mach_l122_d10_rpaths(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(mach_state_from_value(args[0]).resolved_rpaths(if args.len > 1 {
		args[1].bool_data
	} else {
		true
	}))
}

// Ruby method `resolve_variable_name(name, resolve_rpaths: true)` at line 131.
pub fn ruby_mach_l131_d11_resolve_variable_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(mach_state_from_value(args[0]).resolve_variable_name(args[1].as_string(), if args.len > 2 {
		args[2].bool_data
	} else {
		true
	}))
}

// Ruby method `resolve_rpath(name)` at line 144.
pub fn ruby_mach_l144_d12_resolve_rpath(args ...ruby.Value) ruby.Value {
	target := mach_state_from_value(args[0]).resolve_rpath(args[1].as_string()) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(target)
}

// Ruby method `archs` at line 154.
pub fn ruby_mach_l154_d13_archs(args ...ruby.Value) ruby.Value {
	return ruby.array_value(mach_state_from_value(args[0]).archs().map(ruby.object_value('Symbol', it)))
}

// Ruby method `arch` at line 159.
pub fn ruby_mach_l159_d14_arch(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', mach_state_from_value(args[0]).arch())
}

// Ruby method `universal?` at line 168.
pub fn ruby_mach_l168_d15_universal(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(mach_state_from_value(args[0]).arch() == 'universal')
}

// Ruby method `i386?` at line 173.
pub fn ruby_mach_l173_d16_i386(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(mach_state_from_value(args[0]).arch() == 'i386')
}

// Ruby method `x86_64?` at line 178.
pub fn ruby_mach_l178_d17_x86_64(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(mach_state_from_value(args[0]).arch() == 'x86_64')
}

// Ruby method `ppc7400?` at line 183.
pub fn ruby_mach_l183_d18_ppc7400(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(mach_state_from_value(args[0]).arch() == 'ppc7400')
}

// Ruby method `ppc64?` at line 188.
pub fn ruby_mach_l188_d19_ppc64(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(mach_state_from_value(args[0]).arch() == 'ppc64')
}

// Ruby method `dylib?` at line 193.
pub fn ruby_mach_l193_d20_dylib(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(mach_state_from_value(args[0]).has_type('dylib'))
}

// Ruby method `mach_o_executable?` at line 198.
pub fn ruby_mach_l198_d21_mach_o_executable(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(mach_state_from_value(args[0]).has_type('executable'))
}

// Ruby alias `alias binary_executable? mach_o_executable?` at line 202.
pub fn ruby_mach_l202_d22_binary_executable(args ...ruby.Value) ruby.Value {
	return ruby_mach_l198_d21_mach_o_executable(...args)
}

// Ruby method `mach_o_bundle?` at line 205.
pub fn ruby_mach_l205_d23_mach_o_bundle(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(mach_state_from_value(args[0]).has_type('bundle'))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # {Pathname} extension for dealing with Mach-O files.
// 5: module MachOShim
// 6:   extend T::Helpers
// 7:
// 8:   requires_ancestor { Pathname }
// 9:
// 10:   MachOFile = T.type_alias { T.any(MachO::MachOFile, MachO::FatFile) }
// 11:   private_constant :MachOFile
// 12:
// 13:   sig { params(args: T.untyped).void }
// 14:   def initialize(*args)
// 15:     require "macho"
// 16:
// 17:     @macho = T.let(nil, T.nilable(MachOFile))
// 18:     @mach_data = T.let(nil, T.nilable(T::Array[T::Hash[Symbol, Symbol]]))
// 19:
// 20:     super
// 21:   end
// 22:
// 23:   sig { returns(T.nilable(String)) }
// 24:   def dylib_id = macho.dylib_id
// 25:
// 26:   sig { returns(MachOFile) }
// 27:   def macho
// 28:     require "macho"
// 29:     @macho ||= MachO.open(to_s)
// 30:   end
// 31:   private :macho
// 32:
// 33:   sig { returns(T::Array[T::Hash[Symbol, Symbol]]) }
// 34:   def mach_data
// 35:     @mach_data ||= begin
// 36:       machos = []
// 37:       mach_data = []
// 38:
// 39:       case (macho = self.macho)
// 40:       when MachO::FatFile
// 41:         machos = macho.machos
// 42:       else
// 43:         machos << macho
// 44:       end
// 45:
// 46:       machos.each do |m|
// 47:         arch = case m.cputype
// 48:         when :x86_64, :i386, :ppc64, :arm64, :arm then m.cputype
// 49:         when :ppc then :ppc7400
// 50:         else :dunno
// 51:         end
// 52:
// 53:         type = case m.filetype
// 54:         when :dylib, :bundle then m.filetype
// 55:         when :execute then :executable
// 56:         else :dunno
// 57:         end
// 58:
// 59:         mach_data << { arch:, type: }
// 60:       end
// 61:
// 62:       mach_data
// 63:     rescue MachO::NotAMachOError
// 64:       # Silently ignore errors that indicate the file is not a Mach-O binary ...
// 65:       []
// 66:     rescue
// 67:       # ... but complain about other (parse) errors for further investigation.
// 68:       onoe "Failed to read Mach-O binary: #{self}"
// 69:       raise if Homebrew::EnvConfig.developer?
// 70:
// 71:       []
// 72:     end
// 73:   end
// 74:   private :mach_data
// 75:
// 76:   # Returns the deleted rpath, or nil when there's nothing to delete.
// 77:   sig { params(rpath: String, strict: T::Boolean).returns(T.nilable(String)) }
// 78:   def delete_rpath(rpath, strict: true)
// 79:     candidates = rpaths(resolve_variable_references: false).select do |r|
// 80:       resolve_variable_name(r) == resolve_variable_name(rpath)
// 81:     end
// 82:
// 83:     # Delete the last instance to avoid changing the order in which rpaths are searched.
// 84:     rpath_to_delete = candidates.last
// 85:     # Avoid writing the whole binary back to disk when there's nothing to delete.
// 86:     return if rpath_to_delete.nil?
// 87:
// 88:     macho.delete_rpath(rpath_to_delete, { last: true, strict: })
// 89:     macho.write!
// 90:     rpath_to_delete
// 91:   end
// 92:
// 93:   sig { params(old: String, new: String, uniq: T::Boolean, last: T::Boolean, strict: T::Boolean).void }
// 94:   def change_rpath(old, new, uniq: false, last: false, strict: true)
// 95:     macho.change_rpath(old, new, { uniq:, last:, strict: })
// 96:     macho.write!
// 97:   end
// 98:
// 99:   sig { params(id: String, strict: T::Boolean).void }
// 100:   def change_dylib_id(id, strict: true)
// 101:     macho.change_dylib_id(id, { strict: })
// 102:     macho.write!
// 103:   end
// 104:
// 105:   sig { params(old: String, new: String, strict: T::Boolean).void }
// 106:   def change_install_name(old, new, strict: true)
// 107:     macho.change_install_name(old, new, { strict: })
// 108:     macho.write!
// 109:   end
// 110:
// 111:   sig { params(except: Symbol, resolve_variable_references: T::Boolean).returns(T::Array[String]) }
// 112:   def dynamically_linked_libraries(except: :none, resolve_variable_references: true)
// 113:     lcs = macho.dylib_load_commands
// 114:     lcs.reject! { |lc| lc.flag?(except) } if except != :none
// 115:     names = lcs.map { |lc| lc.name.to_s }.uniq
// 116:     names.map! { resolve_variable_name(it) } if resolve_variable_references
// 117:
// 118:     names
// 119:   end
// 120:
// 121:   sig { params(resolve_variable_references: T::Boolean).returns(T::Array[String]) }
// 122:   def rpaths(resolve_variable_references: true)
// 123:     names = macho.rpaths
// 124:     # Don't recursively resolve rpaths to avoid infinite loops.
// 125:     names.map! { |name| resolve_variable_name(name, resolve_rpaths: false) } if resolve_variable_references
// 126:
// 127:     names
// 128:   end
// 129:
// 130:   sig { params(name: String, resolve_rpaths: T::Boolean).returns(String) }
// 131:   def resolve_variable_name(name, resolve_rpaths: true)
// 132:     if name.start_with? "@loader_path"
// 133:       Pathname(name.sub("@loader_path", dirname.to_s)).cleanpath.to_s
// 134:     elsif name.start_with?("@executable_path") && binary_executable?
// 135:       Pathname(name.sub("@executable_path", dirname.to_s)).cleanpath.to_s
// 136:     elsif resolve_rpaths && name.start_with?("@rpath") && (target = resolve_rpath(name)).present?
// 137:       target
// 138:     else
// 139:       name
// 140:     end
// 141:   end
// 142:
// 143:   sig { params(name: String).returns(T.nilable(String)) }
// 144:   def resolve_rpath(name)
// 145:     target = T.let(nil, T.nilable(String))
// 146:     return unless rpaths(resolve_variable_references: true).find do |rpath|
// 147:       File.exist?(target = File.join(rpath, name.delete_prefix("@rpath")))
// 148:     end
// 149:
// 150:     target
// 151:   end
// 152:
// 153:   sig { returns(T::Array[Symbol]) }
// 154:   def archs
// 155:     mach_data.map { |m| m.fetch :arch }
// 156:   end
// 157:
// 158:   sig { returns(Symbol) }
// 159:   def arch
// 160:     case archs.length
// 161:     when 0 then :dunno
// 162:     when 1 then archs.fetch(0)
// 163:     else :universal
// 164:     end
// 165:   end
// 166:
// 167:   sig { returns(T::Boolean) }
// 168:   def universal?
// 169:     arch == :universal
// 170:   end
// 171:
// 172:   sig { returns(T::Boolean) }
// 173:   def i386?
// 174:     arch == :i386
// 175:   end
// 176:
// 177:   sig { returns(T::Boolean) }
// 178:   def x86_64?
// 179:     arch == :x86_64
// 180:   end
// 181:
// 182:   sig { returns(T::Boolean) }
// 183:   def ppc7400?
// 184:     arch == :ppc7400
// 185:   end
// 186:
// 187:   sig { returns(T::Boolean) }
// 188:   def ppc64?
// 189:     arch == :ppc64
// 190:   end
// 191:
// 192:   sig { returns(T::Boolean) }
// 193:   def dylib?
// 194:     mach_data.any? { |m| m.fetch(:type) == :dylib }
// 195:   end
// 196:
// 197:   sig { returns(T::Boolean) }
// 198:   def mach_o_executable?
// 199:     mach_data.any? { |m| m.fetch(:type) == :executable }
// 200:   end
// 201:
// 202:   alias binary_executable? mach_o_executable?
// 203:
// 204:   sig { returns(T::Boolean) }
// 205:   def mach_o_bundle?
// 206:     mach_data.any? { |m| m.fetch(:type) == :bundle }
// 207:   end
// 208: end
