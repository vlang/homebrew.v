module patchelf

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/patchelf-1.6.2/lib/patchelf/patcher.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum PatchElfErrorMode {
	exception
	log
	silent
}

pub struct PatchElfMaybeString {
pub:
	exists bool
	value  string
}

pub struct PatchElfMaybeStrings {
pub:
	exists bool
	value  []string
}

pub struct PatchElfMaybeSection {
pub:
	exists bool
	value  AltSection
}

@[heap]
pub struct Patcher {
pub:
	in_file string
	elf     &AltSaver
pub mut:
	set       map[string]ruby.Value
	rpath_sym string = 'runpath'
	on_error  PatchElfErrorMode
}

fn patcher_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn patcher_value(patcher &Patcher) ruby.Value {
	return ruby.structured_value('PatchELF::Patcher', 'Patcher(${patcher.in_file})', {
		'patcher_address': u64(voidptr(patcher)).str()
		'in_file':         patcher.in_file
	})
}

fn patcher_from_args(args []ruby.Value) &Patcher {
	if args.len == 0 {
		panic('PatchELF::Patcher method requires a receiver')
	}
	address := args[0].attribute('patcher_address') or { panic('invalid PatchELF::Patcher receiver') }
	return unsafe { &Patcher(voidptr(address.u64())) }
}

fn patcher_require(args []ruby.Value, count int, name string) {
	if args.len < count {
		panic('${name} requires ${count} argument(s), including receiver')
	}
}

pub fn patch_elf_error_mode(name string) ?PatchElfErrorMode {
	return match name.trim_string_left(':') {
		'exception' { .exception }
		'log' { .log }
		'silent' { .silent }
		else { none }
	}
}

pub fn new_patcher(filename string, on_error PatchElfErrorMode, logging bool) !&Patcher {
	mode := if logging { on_error } else { PatchElfErrorMode.exception }
	elf := new_alt_saver(filename, filename, {})!
	return &Patcher{
		in_file: filename
		elf: elf
		set: map[string]ruby.Value{}
		on_error: mode
	}
}

pub fn new_patcher_from_bytes(filename string, data []u8, on_error PatchElfErrorMode,
	logging bool) !&Patcher {
	mode := if logging { on_error } else { PatchElfErrorMode.exception }
	elf := new_alt_saver_from_bytes(filename, filename, {}, data)!
	return &Patcher{
		in_file: filename
		elf: elf
		set: map[string]ruby.Value{}
		on_error: mode
	}
}

pub fn (patcher &Patcher) log_or_raise(message string, exception_name string) ! {
	match patcher.on_error {
		.exception {
			return error('${exception_name}: ${message}')
		}
		.log {
			PatchElfLogger{}.log_to_stderr(.warn, message)
		}
		.silent {}
	}
}

pub fn (patcher &Patcher) dynamic_or_log() !PatchElfMaybeSection {
	section := patcher.elf.find_section('.dynamic') or {
		patcher.log_or_raise('DYNAMIC segment not found, might be a statically-linked ELF?', 'MissingSegmentError')!
		return PatchElfMaybeSection{}
	}
	return PatchElfMaybeSection{ exists: true, value: section }
}

fn (patcher &Patcher) dynamic_string(offset u64) ?string {
	dynstr := patcher.elf.find_section('.dynstr') or { return none }
	position := int(dynstr.header.sh_offset + offset)
	return patcher.elf.buf_cstr(position) or { none }
}

pub fn (patcher &Patcher) interpreter_raw() !PatchElfMaybeString {
	section := patcher.elf.find_section('.interp') or {
		patcher.log_or_raise('No interpreter found.', 'MissingSegmentError')!
		return PatchElfMaybeString{}
	}
	return PatchElfMaybeString{
		exists: true
		value: patcher.elf.buf_cstr(int(section.header.sh_offset))!
	}
}

pub fn (patcher &Patcher) needed_raw() !PatchElfMaybeStrings {
	dynamic := patcher.dynamic_or_log()!
	if !dynamic.exists {
		return PatchElfMaybeStrings{}
	}
	mut result := []string{}
	for tag in patcher.elf.dynamic_tags()! {
		if tag.d_tag == saver_dt_needed {
			if name := patcher.dynamic_string(tag.d_val) {
				result << name
			}
		}
	}
	return PatchElfMaybeStrings{ exists: true, value: result }
}

pub fn (patcher &Patcher) tag_name_or_log(kind string, log_message string) !PatchElfMaybeString {
	dynamic := patcher.dynamic_or_log()!
	if !dynamic.exists {
		return PatchElfMaybeString{}
	}
	tag_kind := saver_tag_constant(kind)!
	for tag in patcher.elf.dynamic_tags()! {
		if tag.d_tag == tag_kind {
			if value := patcher.dynamic_string(tag.d_val) {
				return PatchElfMaybeString{ exists: true, value: value }
			}
			return PatchElfMaybeString{}
		}
	}
	patcher.log_or_raise(log_message, 'MissingTagError')!
	return PatchElfMaybeString{}
}

pub fn (patcher &Patcher) runpath_raw(kind string) !PatchElfMaybeString {
	clean := kind.trim_string_left(':')
	return patcher.tag_name_or_log(clean, 'Entry DT_${clean.to_upper()} not found.')!
}

pub fn (patcher &Patcher) soname_raw() !PatchElfMaybeString {
	return patcher.tag_name_or_log('soname', 'Entry DT_SONAME not found, not a shared library?')!
}

pub fn (patcher &Patcher) interpreter() !PatchElfMaybeString {
	if value := patcher.set['interpreter'] {
		return PatchElfMaybeString{ exists: true, value: value.as_string() }
	}
	return patcher.interpreter_raw()!
}

pub fn (mut patcher Patcher) set_interpreter(interpreter string) !bool {
	current := patcher.interpreter_raw()!
	if !current.exists {
		return false
	}
	patcher.set['interpreter'] = ruby.string_value(interpreter)
	return true
}

pub fn (patcher &Patcher) needed() !PatchElfMaybeStrings {
	if value := patcher.set['needed'] {
		return PatchElfMaybeStrings{ exists: true, value: value.as_string_array()! }
	}
	return patcher.needed_raw()!
}

pub fn (mut patcher Patcher) set_needed(needed []string) {
	patcher.set['needed'] = ruby.string_array_value(needed)
}

pub fn (mut patcher Patcher) add_needed(name string) ! {
	current := patcher.needed()!
	mut needed := if current.exists { current.value.clone() } else { []string{} }
	needed << name
	patcher.set_needed(needed)
}

pub fn (mut patcher Patcher) remove_needed(name string) ! {
	current := patcher.needed()!
	mut needed := if current.exists { current.value.clone() } else { []string{} }
	needed = needed.filter(it != name)
	patcher.set_needed(needed)
}

pub fn (mut patcher Patcher) replace_needed(source string, target string) ! {
	current := patcher.needed()!
	mut needed := if current.exists { current.value.clone() } else { []string{} }
	for index, name in needed {
		if name == source {
			needed[index] = target
		}
	}
	patcher.set_needed(needed)
}

pub fn (patcher &Patcher) soname() !PatchElfMaybeString {
	if value := patcher.set['soname'] {
		return PatchElfMaybeString{ exists: true, value: value.as_string() }
	}
	return patcher.soname_raw()!
}

pub fn (mut patcher Patcher) set_soname(name string) !bool {
	current := patcher.soname_raw()!
	if !current.exists {
		return false
	}
	patcher.set['soname'] = ruby.string_value(name)
	return true
}

pub fn (patcher &Patcher) runpath() !PatchElfMaybeString {
	if value := patcher.set[patcher.rpath_sym] {
		return PatchElfMaybeString{ exists: true, value: value.as_string() }
	}
	return patcher.runpath_raw(patcher.rpath_sym)!
}

pub fn (patcher &Patcher) rpath() !PatchElfMaybeString {
	if value := patcher.set['rpath'] {
		return PatchElfMaybeString{ exists: true, value: value.as_string() }
	}
	return patcher.runpath_raw('rpath')!
}

pub fn (mut patcher Patcher) set_rpath(path string) {
	patcher.set['rpath'] = ruby.string_value(path)
}

pub fn (mut patcher Patcher) set_runpath(path string) {
	patcher.set[patcher.rpath_sym] = ruby.string_value(path)
}

pub fn (mut patcher Patcher) use_rpath() &Patcher {
	patcher.rpath_sym = 'rpath'
	return patcher
}

pub fn (patcher &Patcher) dirty() bool {
	return patcher.set.len > 0
}

pub fn (mut patcher Patcher) save(out_file ?string, patchelf_compatible bool) !bool {
	target := out_file or { patcher.in_file }
	if out_file == none && !patcher.dirty() {
		return false
	}
	if patchelf_compatible && 'needed' !in patcher.set && 'soname' !in patcher.set {
		mut saver := new_alt_saver(patcher.in_file, target, patcher.set)!
		saver.save()!
	} else {
		mut saver := new_saver(patcher.in_file, target, patcher.set)!
		saver.save()!
	}
	return true
}

// Ruby attr_reader `attr_reader :elf` at line 18.
pub fn ruby_patcher_l18_d1_elf(args ...ruby.Value) ruby.Value {
	return alt_saver_value(patcher_from_args(args).elf)
}

// Ruby method `initialize(filename, on_error: :log, logging: true)` at line 30.
pub fn ruby_patcher_l30_d2_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Patcher#initialize requires a filename')
	}
	mut mode := PatchElfErrorMode.log
	mut logging := true
	if args.len > 1 {
		if args[1].type_name == 'Hash' {
			if value := args[1].map_data['on_error'] {
				mode = patch_elf_error_mode(value.as_string()) or { panic('invalid on_error mode') }
			}
			if value := args[1].map_data['logging'] {
				logging = value.as_bool() or { panic(err) }
			}
		} else {
			mode = patch_elf_error_mode(args[1].as_string()) or { panic('invalid on_error mode') }
		}
	}
	return patcher_value(new_patcher(args[0].as_string(), mode, logging) or { panic(err) })
}

// Ruby method `interpreter` at line 50.
pub fn ruby_patcher_l50_d3_interpreter(args ...ruby.Value) ruby.Value {
	result := patcher_from_args(args).interpreter() or { panic(err) }
	return if result.exists { ruby.string_value(result.value) } else { patcher_nil_value() }
}

// Ruby method `interpreter=(interp)` at line 60.
pub fn ruby_patcher_l60_d4_interpreter(args ...ruby.Value) ruby.Value {
	patcher_require(args, 2, 'Patcher#interpreter=')
	mut patcher := patcher_from_args(args)
	changed := patcher.set_interpreter(args[1].as_string()) or { panic(err) }
	return if changed { args[1] } else { patcher_nil_value() }
}

// Ruby method `needed` at line 72.
pub fn ruby_patcher_l72_d5_needed(args ...ruby.Value) ruby.Value {
	result := patcher_from_args(args).needed() or { panic(err) }
	return if result.exists {
		ruby.string_array_value(result.value)
	} else {
		patcher_nil_value()
	}
}

// Ruby method `needed=(needs)` at line 79.
pub fn ruby_patcher_l79_d6_needed(args ...ruby.Value) ruby.Value {
	patcher_require(args, 2, 'Patcher#needed=')
	mut patcher := patcher_from_args(args)
	patcher.set_needed(args[1].as_string_array() or { panic(err) })
	return args[1]
}

// Ruby method `add_needed(need)` at line 87.
pub fn ruby_patcher_l87_d7_add_needed(args ...ruby.Value) ruby.Value {
	patcher_require(args, 2, 'Patcher#add_needed')
	mut patcher := patcher_from_args(args)
	patcher.add_needed(args[1].as_string()) or { panic(err) }
	return patcher_nil_value()
}

// Ruby method `remove_needed(need)` at line 96.
pub fn ruby_patcher_l96_d8_remove_needed(args ...ruby.Value) ruby.Value {
	patcher_require(args, 2, 'Patcher#remove_needed')
	mut patcher := patcher_from_args(args)
	patcher.remove_needed(args[1].as_string()) or { panic(err) }
	return patcher_nil_value()
}

// Ruby method `replace_needed(src, tar)` at line 109.
pub fn ruby_patcher_l109_d9_replace_needed(args ...ruby.Value) ruby.Value {
	patcher_require(args, 3, 'Patcher#replace_needed')
	mut patcher := patcher_from_args(args)
	patcher.replace_needed(args[1].as_string(), args[2].as_string()) or { panic(err) }
	return patcher_nil_value()
}

// Ruby method `soname` at line 124.
pub fn ruby_patcher_l124_d10_soname(args ...ruby.Value) ruby.Value {
	result := patcher_from_args(args).soname() or { panic(err) }
	return if result.exists { ruby.string_value(result.value) } else { patcher_nil_value() }
}

// Ruby method `soname=(name)` at line 134.
pub fn ruby_patcher_l134_d11_soname(args ...ruby.Value) ruby.Value {
	patcher_require(args, 2, 'Patcher#soname=')
	mut patcher := patcher_from_args(args)
	changed := patcher.set_soname(args[1].as_string()) or { panic(err) }
	return if changed { args[1] } else { patcher_nil_value() }
}

// Ruby method `runpath` at line 142.
pub fn ruby_patcher_l142_d12_runpath(args ...ruby.Value) ruby.Value {
	result := patcher_from_args(args).runpath() or { panic(err) }
	return if result.exists { ruby.string_value(result.value) } else { patcher_nil_value() }
}

// Ruby method `rpath` at line 148.
pub fn ruby_patcher_l148_d13_rpath(args ...ruby.Value) ruby.Value {
	result := patcher_from_args(args).rpath() or { panic(err) }
	return if result.exists { ruby.string_value(result.value) } else { patcher_nil_value() }
}

// Ruby method `rpath=(rpath)` at line 158.
pub fn ruby_patcher_l158_d14_rpath(args ...ruby.Value) ruby.Value {
	patcher_require(args, 2, 'Patcher#rpath=')
	mut patcher := patcher_from_args(args)
	patcher.set_rpath(args[1].as_string())
	return args[1]
}

// Ruby method `runpath=(runpath)` at line 168.
pub fn ruby_patcher_l168_d15_runpath(args ...ruby.Value) ruby.Value {
	patcher_require(args, 2, 'Patcher#runpath=')
	mut patcher := patcher_from_args(args)
	patcher.set_runpath(args[1].as_string())
	return args[1]
}

// Ruby method `use_rpath!` at line 174.
pub fn ruby_patcher_l174_d16_use_rpath(args ...ruby.Value) ruby.Value {
	mut patcher := patcher_from_args(args)
	return patcher_value(patcher.use_rpath())
}

// Ruby method `save(out_file = nil, patchelf_compatible: false)` at line 185.
pub fn ruby_patcher_l185_d17_save(args ...ruby.Value) ruby.Value {
	mut patcher := patcher_from_args(args)
	mut output := ?string(none)
	mut compatible := false
	if args.len > 1 && args[1].type_name != 'NilClass' {
		output = args[1].as_string()
	}
	if args.len > 2 {
		compatible = args[2].as_bool() or { panic(err) }
	}
	return ruby.bool_value(patcher.save(output, compatible) or { panic(err) })
}

// Ruby method `log_or_raise(msg, exception = PatchELF::PatchError)` at line 202.
pub fn ruby_patcher_l202_d18_log_or_raise(args ...ruby.Value) ruby.Value {
	patcher_require(args, 2, 'Patcher#log_or_raise')
	exception := if args.len > 2 { args[2].as_string() } else { 'PatchError' }
	patcher_from_args(args).log_or_raise(args[1].as_string(), exception) or { panic(err) }
	return patcher_nil_value()
}

// Ruby method `interpreter_` at line 208.
pub fn ruby_patcher_l208_d19_interpreter(args ...ruby.Value) ruby.Value {
	result := patcher_from_args(args).interpreter_raw() or { panic(err) }
	return if result.exists { ruby.string_value(result.value) } else { patcher_nil_value() }
}

// Ruby method `needed_` at line 216.
pub fn ruby_patcher_l216_d20_needed(args ...ruby.Value) ruby.Value {
	result := patcher_from_args(args).needed_raw() or { panic(err) }
	return if result.exists {
		ruby.string_array_value(result.value)
	} else {
		patcher_nil_value()
	}
}

// Ruby method `runpath_(rpath_sym = :runpath)` at line 224.
pub fn ruby_patcher_l224_d21_runpath(args ...ruby.Value) ruby.Value {
	kind := if args.len > 1 { args[1].as_string() } else { 'runpath' }
	result := patcher_from_args(args).runpath_raw(kind) or { panic(err) }
	return if result.exists { ruby.string_value(result.value) } else { patcher_nil_value() }
}

// Ruby method `soname_` at line 229.
pub fn ruby_patcher_l229_d22_soname(args ...ruby.Value) ruby.Value {
	result := patcher_from_args(args).soname_raw() or { panic(err) }
	return if result.exists { ruby.string_value(result.value) } else { patcher_nil_value() }
}

// Ruby method `dirty?` at line 234.
pub fn ruby_patcher_l234_d23_dirty(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(patcher_from_args(args).dirty())
}

// Ruby method `tag_name_or_log(type, log_msg)` at line 238.
pub fn ruby_patcher_l238_d24_tag_name_or_log(args ...ruby.Value) ruby.Value {
	patcher_require(args, 3, 'Patcher#tag_name_or_log')
	result := patcher_from_args(args).tag_name_or_log(args[1].as_string(), args[2].as_string()) or {
		panic(err)
	}
	return if result.exists { ruby.string_value(result.value) } else { patcher_nil_value() }
}

// Ruby method `dynamic_or_log` at line 248.
pub fn ruby_patcher_l248_d25_dynamic_or_log(args ...ruby.Value) ruby.Value {
	result := patcher_from_args(args).dynamic_or_log() or { panic(err) }
	return if result.exists { alt_section_value(result.value) } else { patcher_nil_value() }
}

// Original Ruby source (line-for-line):
// 1: # encoding: ascii-8bit
// 2: # frozen_string_literal: true
// 3:
// 4: require 'elftools/elf_file'
// 5: require 'objspace'
// 6:
// 7: require 'patchelf/exceptions'
// 8: require 'patchelf/helper'
// 9: require 'patchelf/logger'
// 10: require 'patchelf/saver'
// 11:
// 12: module PatchELF
// 13:   # Class to handle all patching things.
// 14:   class Patcher
// 15:     # @!macro [new] note_apply
// 16:     #   @note This setting will be saved after {#save} being invoked.
// 17:
// 18:     attr_reader :elf # @return [ELFTools::ELFFile] ELF parser object.
// 19:
// 20:     # Instantiate a {Patcher} object.
// 21:     # @param [String] filename
// 22:     #   Filename of input ELF.
// 23:     # @param [Boolean] logging
// 24:     #   *deprecated*: use +on_error+ instead
// 25:     # @param [:log, :silent, :exception] on_error
// 26:     #   action when the desired segment/tag field isn't present
// 27:     #     :log = logs to stderr
// 28:     #     :exception = raise exception related to the error
// 29:     #     :silent = ignore the errors
// 30:     def initialize(filename, on_error: :log, logging: true)
// 31:       @in_file = filename
// 32:       f = File.open(filename) # rubocop:disable Style/FileOpen
// 33:       @elf = ELFTools::ELFFile.new(f)
// 34:       @set = {}
// 35:       @rpath_sym = :runpath
// 36:       @on_error = logging ? on_error : :exception
// 37:
// 38:       on_error_syms = %i[exception log silent]
// 39:       raise ArgumentError, "on_error must be one of #{on_error_syms}" unless on_error_syms.include?(@on_error)
// 40:
// 41:       # Ensure file is closed when the {Patcher} object is garbage collected.
// 42:       ObjectSpace.define_finalizer(self, Helper.close_file_proc(f))
// 43:     end
// 44:
// 45:     # @return [String?]
// 46:     #   Get interpreter's name.
// 47:     # @example
// 48:     #   PatchELF::Patcher.new('/bin/ls').interpreter
// 49:     #   #=> "/lib64/ld-linux-x86-64.so.2"
// 50:     def interpreter
// 51:       @set[:interpreter] || interpreter_
// 52:     end
// 53:
// 54:     # Set interpreter's name.
// 55:     #
// 56:     # If the input ELF has no existent interpreter,
// 57:     # this method will show a warning and has no effect.
// 58:     # @param [String] interp
// 59:     # @macro note_apply
// 60:     def interpreter=(interp)
// 61:       return if interpreter_.nil? # will also show warning if there's no interp segment.
// 62:
// 63:       @set[:interpreter] = interp
// 64:     end
// 65:
// 66:     # Get needed libraries.
// 67:     # @return [Array<String>]
// 68:     # @example
// 69:     #   patcher = PatchELF::Patcher.new('/bin/ls')
// 70:     #   patcher.needed
// 71:     #   #=> ["libselinux.so.1", "libc.so.6"]
// 72:     def needed
// 73:       @set[:needed] || needed_
// 74:     end
// 75:
// 76:     # Set needed libraries.
// 77:     # @param [Array<String>] needs
// 78:     # @macro note_apply
// 79:     def needed=(needs)
// 80:       @set[:needed] = needs
// 81:     end
// 82:
// 83:     # Add the needed library.
// 84:     # @param [String] need
// 85:     # @return [void]
// 86:     # @macro note_apply
// 87:     def add_needed(need)
// 88:       @set[:needed] ||= needed_
// 89:       @set[:needed] << need
// 90:     end
// 91:
// 92:     # Remove the needed library.
// 93:     # @param [String] need
// 94:     # @return [void]
// 95:     # @macro note_apply
// 96:     def remove_needed(need)
// 97:       @set[:needed] ||= needed_
// 98:       @set[:needed].delete(need)
// 99:     end
// 100:
// 101:     # Replace needed library +src+ with +tar+.
// 102:     #
// 103:     # @param [String] src
// 104:     #   Library to be replaced.
// 105:     # @param [String] tar
// 106:     #   Library replace with.
// 107:     # @return [void]
// 108:     # @macro note_apply
// 109:     def replace_needed(src, tar)
// 110:       @set[:needed] ||= needed_
// 111:       @set[:needed].map! { |v| v == src ? tar : v }
// 112:     end
// 113:
// 114:     # Get the soname of a shared library.
// 115:     # @return [String?] The name.
// 116:     # @example
// 117:     #   patcher = PatchELF::Patcher.new('/bin/ls')
// 118:     #   patcher.soname
// 119:     #   # [WARN] Entry DT_SONAME not found, not a shared library?
// 120:     #   #=> nil
// 121:     # @example
// 122:     #   PatchELF::Patcher.new('/lib/x86_64-linux-gnu/libc.so.6').soname
// 123:     #   #=> "libc.so.6"
// 124:     def soname
// 125:       @set[:soname] || soname_
// 126:     end
// 127:
// 128:     # Set soname.
// 129:     #
// 130:     # If the input ELF is not a shared library with a soname,
// 131:     # this method will show a warning and has no effect.
// 132:     # @param [String] name
// 133:     # @macro note_apply
// 134:     def soname=(name)
// 135:       return if soname_.nil?
// 136:
// 137:       @set[:soname] = name
// 138:     end
// 139:
// 140:     # Get runpath.
// 141:     # @return [String?]
// 142:     def runpath
// 143:       @set[@rpath_sym] || runpath_(@rpath_sym)
// 144:     end
// 145:
// 146:     # Get rpath
// 147:     # return [String?]
// 148:     def rpath
// 149:       @set[:rpath] || runpath_(:rpath)
// 150:     end
// 151:
// 152:     # Set rpath
// 153:     #
// 154:     # Modify / set DT_RPATH of the given ELF.
// 155:     # similar to runpath= except DT_RPATH is modifed/created in DYNAMIC segment.
// 156:     # @param [String] rpath
// 157:     # @macro note_apply
// 158:     def rpath=(rpath)
// 159:       @set[:rpath] = rpath
// 160:     end
// 161:
// 162:     # Set runpath.
// 163:     #
// 164:     # If DT_RUNPATH is not presented in the input ELF,
// 165:     # a new DT_RUNPATH attribute will be inserted into the DYNAMIC segment.
// 166:     # @param [String] runpath
// 167:     # @macro note_apply
// 168:     def runpath=(runpath)
// 169:       @set[@rpath_sym] = runpath
// 170:     end
// 171:
// 172:     # Set all operations related to DT_RUNPATH to use DT_RPATH.
// 173:     # @return [self]
// 174:     def use_rpath!
// 175:       @rpath_sym = :rpath
// 176:       self
// 177:     end
// 178:
// 179:     # Save the patched ELF as +out_file+.
// 180:     # @param [String?] out_file
// 181:     #   If +out_file+ is +nil+, the original input file will be modified.
// 182:     # @param [Boolean] patchelf_compatible
// 183:     #   When +patchelf_compatible+ is true, tries to produce same ELF as the one produced by NixOS/patchelf.
// 184:     # @return [void]
// 185:     def save(out_file = nil, patchelf_compatible: false)
// 186:       # If nothing is modified, return directly.
// 187:       return if out_file.nil? && !dirty?
// 188:
// 189:       out_file ||= @in_file
// 190:       saver = if patchelf_compatible
// 191:                 require 'patchelf/alt_saver'
// 192:                 PatchELF::AltSaver.new(@in_file, out_file, @set)
// 193:               else
// 194:                 PatchELF::Saver.new(@in_file, out_file, @set)
// 195:               end
// 196:
// 197:       saver.save!
// 198:     end
// 199:
// 200:     private
// 201:
// 202:     def log_or_raise(msg, exception = PatchELF::PatchError)
// 203:       raise exception, msg if @on_error == :exception
// 204:
// 205:       PatchELF::Logger.warn(msg) if @on_error == :log
// 206:     end
// 207:
// 208:     def interpreter_
// 209:       segment = @elf.segment_by_type(:interp)
// 210:       return log_or_raise 'No interpreter found.', PatchELF::MissingSegmentError if segment.nil?
// 211:
// 212:       segment.interp_name
// 213:     end
// 214:
// 215:     # @return [Array<String>]
// 216:     def needed_
// 217:       segment = dynamic_or_log
// 218:       return if segment.nil?
// 219:
// 220:       segment.tags_by_type(:needed).map(&:name)
// 221:     end
// 222:
// 223:     # @return [String?]
// 224:     def runpath_(rpath_sym = :runpath)
// 225:       tag_name_or_log(rpath_sym, "Entry DT_#{rpath_sym.to_s.upcase} not found.")
// 226:     end
// 227:
// 228:     # @return [String?]
// 229:     def soname_
// 230:       tag_name_or_log(:soname, 'Entry DT_SONAME not found, not a shared library?')
// 231:     end
// 232:
// 233:     # @return [Boolean]
// 234:     def dirty?
// 235:       @set.any?
// 236:     end
// 237:
// 238:     def tag_name_or_log(type, log_msg)
// 239:       segment = dynamic_or_log
// 240:       return if segment.nil?
// 241:
// 242:       tag = segment.tag_by_type(type)
// 243:       return log_or_raise log_msg, PatchELF::MissingTagError if tag.nil?
// 244:
// 245:       tag.name
// 246:     end
// 247:
// 248:     def dynamic_or_log
// 249:       @elf.segment_by_type(:dynamic).tap do |s|
// 250:         if s.nil?
// 251:           log_or_raise 'DYNAMIC segment not found, might be a statically-linked ELF?', PatchELF::MissingSegmentError
// 252:         end
// 253:       end
// 254:     end
// 255:   end
// 256: end
