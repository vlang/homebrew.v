module patchelf

import ruby
import os

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/patchelf-1.6.2/lib/patchelf/helper.rb`.
// The original source is retained below until every stub has a typed V body.
const helper_escape_reset = '\x1b[0m'

@[heap]
pub struct CloseFileAction {
mut:
	file     &os.File = unsafe { nil }
	has_file bool
}

pub fn patch_elf_page_size(machine int) int {
	return if machine in [2, 8, 20, 21, 183, 191, 258] { 0x10000 } else { 0x1000 }
}

pub fn patch_elf_colorize(text string, kind string, enabled bool) string {
	if !enabled {
		return text
	}
	color := match kind.trim_string_left(':') {
		'info' { '\x1b[38;5;82m' }
		'warn' { '\x1b[38;5;230m' }
		'error' { '\x1b[38;5;196m' }
		else { '' }
	}
	return '${color}${text.replace_once(helper_escape_reset, color)}${helper_escape_reset}'
}

pub fn patch_elf_color_enabled() bool {
	return os.is_atty(2) != 0
}

pub fn patch_elf_align_down(value i64, alignment i64) i64 {
	return value - (value & (alignment - 1))
}

pub fn patch_elf_align_up(value i64, alignment i64) i64 {
	return if value & (alignment - 1) == 0 {
		value
	} else {
		patch_elf_align_down(value, alignment) + alignment
	}
}

pub fn new_close_file_action(file &os.File) &CloseFileAction {
	return &CloseFileAction{
		file: file
		has_file: true
	}
}

pub fn new_empty_close_file_action() &CloseFileAction {
	return &CloseFileAction{}
}

pub fn (mut action CloseFileAction) call() {
	if action.has_file && action.file.is_opened {
		action.file.close()
	}
}

fn helper_file_value(file &os.File) ruby.Value {
	return ruby.structured_value('File', '#<File:${file.fd}>', {
		'helper_file_address': u64(voidptr(file)).str()
	})
}

fn close_file_action_value(action &CloseFileAction) ruby.Value {
	return ruby.structured_value('Proc', '#<Proc:close_file>', {
		'close_file_action_address': u64(voidptr(action)).str()
	})
}

fn close_file_action_from_value(value ruby.Value) &CloseFileAction {
	address := value.attribute('close_file_action_address') or {
		panic('invalid PatchELF close-file action')
	}
	return unsafe { &CloseFileAction(voidptr(address.u64())) }
}

// Ruby method `page_size(e_machine = nil)` at line 17.
pub fn ruby_helper_l17_d1_page_size(args ...ruby.Value) ruby.Value {
	machine := if args.len == 0 || args[0].type_name == 'NilClass' {
		-1
	} else {
		int(args[0].as_int() or { panic(err) })
	}
	return ruby.int_value(patch_elf_page_size(machine))
}

// Ruby method `colorize(str, type)` at line 40.
pub fn ruby_helper_l40_d2_colorize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('PatchELF::Helper.colorize requires a string and type')
	}
	return ruby.string_value(patch_elf_colorize(args[0].as_string(), args[1].as_string(), patch_elf_color_enabled()))
}

// Ruby method `color_enabled?` at line 50.
pub fn ruby_helper_l50_d3_color_enabled(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(patch_elf_color_enabled())
}

// Ruby method `aligndown(val, align = page_size)` at line 65.
pub fn ruby_helper_l65_d4_aligndown(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('PatchELF::Helper.aligndown requires a value')
	}
	value := args[0].as_int() or { panic(err) }
	alignment := if args.len > 1 { args[1].as_int() or { panic(err) } } else { i64(0x1000) }
	return ruby.int_value(patch_elf_align_down(value, alignment))
}

// Ruby method `alignup(val, align = page_size)` at line 80.
pub fn ruby_helper_l80_d5_alignup(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('PatchELF::Helper.alignup requires a value')
	}
	value := args[0].as_int() or { panic(err) }
	alignment := if args.len > 1 { args[1].as_int() or { panic(err) } } else { i64(0x1000) }
	return ruby.int_value(patch_elf_align_up(value, alignment))
}

// Ruby method `close_file_proc(file)` at line 87.
pub fn ruby_helper_l87_d6_close_file_proc(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return close_file_action_value(new_empty_close_file_action())
	}
	address := args[0].attribute('helper_file_address') or { panic('invalid File receiver') }
	file := unsafe { &os.File(voidptr(address.u64())) }
	return close_file_action_value(new_close_file_action(file))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: module PatchELF
// 4:   # Helper methods for internal usage.
// 5:   module Helper
// 6:     module_function
// 7:
// 8:     # Color codes for pretty print.
// 9:     COLOR_CODE = {
// 10:       esc_m: "\e[0m",
// 11:       info: "\e[38;5;82m", # light green
// 12:       warn: "\e[38;5;230m", # light yellow
// 13:       error: "\e[38;5;196m" # heavy red
// 14:     }.freeze
// 15:
// 16:     # The size of one page.
// 17:     def page_size(e_machine = nil)
// 18:       # Different architectures have different minimum section alignments.
// 19:       case e_machine
// 20:       when ELFTools::Constants::EM_SPARC,
// 21:            ELFTools::Constants::EM_MIPS,
// 22:            ELFTools::Constants::EM_PPC,
// 23:            ELFTools::Constants::EM_PPC64,
// 24:            ELFTools::Constants::EM_AARCH64,
// 25:            ELFTools::Constants::EM_TILEGX,
// 26:            ELFTools::Constants::EM_LOONGARCH
// 27:         0x10000
// 28:       else
// 29:         0x1000
// 30:       end
// 31:     end
// 32:
// 33:     # For wrapping string with color codes for prettier inspect.
// 34:     # @param [String] str
// 35:     #   Content to colorize.
// 36:     # @param [Symbol] type
// 37:     #   Specify which kind of color to use, valid symbols are defined in {.COLOR_CODE}.
// 38:     # @return [String]
// 39:     #   String that wrapped with color codes.
// 40:     def colorize(str, type)
// 41:       return str unless color_enabled?
// 42:
// 43:       cc = COLOR_CODE
// 44:       color = cc.key?(type) ? cc[type] : ''
// 45:       "#{color}#{str.sub(COLOR_CODE[:esc_m], color)}#{cc[:esc_m]}"
// 46:     end
// 47:
// 48:     # For {#colorize} to decide if need add color codes.
// 49:     # @return [Boolean]
// 50:     def color_enabled?
// 51:       $stderr.tty?
// 52:     end
// 53:
// 54:     # @param [Integer] val
// 55:     # @param [Integer] align
// 56:     # @return [Integer]
// 57:     #   Aligned result.
// 58:     # @example
// 59:     #   aligndown(0x1234)
// 60:     #   #=> 4096
// 61:     #   aligndown(0x33, 0x20)
// 62:     #   #=> 32
// 63:     #   aligndown(0x10, 0x8)
// 64:     #   #=> 16
// 65:     def aligndown(val, align = page_size)
// 66:       val - (val & (align - 1))
// 67:     end
// 68:
// 69:     # @param [Integer] val
// 70:     # @param [Integer] align
// 71:     # @return [Integer]
// 72:     #   Aligned result.
// 73:     # @example
// 74:     #   alignup(0x1234)
// 75:     #   #=> 8192
// 76:     #   alignup(0x33, 0x20)
// 77:     #   #=> 64
// 78:     #   alignup(0x10, 0x8)
// 79:     #   #=> 16
// 80:     def alignup(val, align = page_size)
// 81:       val.nobits?(align - 1) ? val : (aligndown(val, align) + align)
// 82:     end
// 83:
// 84:     # @param [File?] file
// 85:     # @return [Proc]
// 86:     #   A proc that closes the file if it's open.
// 87:     def close_file_proc(file)
// 88:       proc { file.close if file && !file.closed? }
// 89:     end
// 90:   end
// 91: end
