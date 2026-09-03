module pathname

import brew_runtime
import os

// Translated from Homebrew/brew `extend/pathname/observer_pathname_extension.rb`.
// The original source is retained below until every stub has a typed V body.
pub const observer_maximum_verbose_output = 100

@[heap]
pub struct ObserverPathnameState {
pub mut:
	n                           int
	d                           int
	ci                          bool
	verbose                     bool
	put_verbose_trimmed_warning bool
	output                      []string
}

@[heap]
pub struct ObservedPathname {
pub:
	path  string
	state &ObserverPathnameState
}

pub fn new_observer_pathname_state(ci bool, verbose bool) &ObserverPathnameState {
	return &ObserverPathnameState{
		ci: ci
		verbose: verbose
	}
}

pub fn new_observed_pathname(path string, state &ObserverPathnameState) &ObservedPathname {
	return &ObservedPathname{
		path: path
		state: state
	}
}

pub fn (mut state ObserverPathnameState) reset_counts() {
	state.n = 0
	state.d = 0
	state.put_verbose_trimmed_warning = false
}

pub fn (state ObserverPathnameState) total() int {
	return state.n + state.d
}

pub fn (mut state ObserverPathnameState) verbose_enabled() bool {
	if !state.ci {
		return state.verbose
	}
	if !state.verbose {
		return false
	}
	if state.total() < observer_maximum_verbose_output {
		return true
	}
	if !state.put_verbose_trimmed_warning {
		state.output << 'Only the first ${observer_maximum_verbose_output} operations were output.'
		state.put_verbose_trimmed_warning = true
	}
	return false
}

fn observer_relative_path(target string, directory string) string {
	target_parts := os.norm_path(os.abs_path(target)).trim_left(os.path_separator).split(os.path_separator)
	directory_parts := os.norm_path(os.abs_path(directory)).trim_left(os.path_separator).split(os.path_separator)
	mut common := 0
	for common < target_parts.len && common < directory_parts.len && target_parts[common] == directory_parts[common] {
		common++
	}
	mut parts := []string{}
	for _ in common .. directory_parts.len {
		parts << '..'
	}
	parts << target_parts[common..]
	return if parts.len == 0 { '.' } else { parts.join(os.path_separator) }
}

pub fn (mut pathname ObservedPathname) unlink() ! {
	os.rm(pathname.path)!
	mut state := pathname.state
	if state.verbose_enabled() {
		state.output << 'rm ${pathname.path}'
	}
	state.n++
}

pub fn (mut pathname ObservedPathname) mkpath() ! {
	os.mkdir_all(pathname.path)!
	mut state := pathname.state
	if state.verbose_enabled() {
		state.output << 'mkdir -p ${pathname.path}'
	}
}

pub fn (mut pathname ObservedPathname) rmdir() ! {
	os.rmdir(pathname.path)!
	mut state := pathname.state
	if state.verbose_enabled() {
		state.output << 'rmdir ${pathname.path}'
	}
	state.d++
}

pub fn (mut pathname ObservedPathname) make_relative_symlink(source string) ! {
	relative := observer_relative_path(source, os.dir(pathname.path))
	os.symlink(relative, pathname.path)!
	mut state := pathname.state
	if state.verbose_enabled() {
		state.output << 'ln -s ${relative} ${os.base(pathname.path)}'
	}
	state.n++
}

pub fn (mut pathname ObservedPathname) install_info() {
	mut state := pathname.state
	if state.verbose_enabled() {
		state.output << 'info ${pathname.path}'
	}
}

pub fn (mut pathname ObservedPathname) uninstall_info() {
	mut state := pathname.state
	if state.verbose_enabled() {
		state.output << 'uninfo ${pathname.path}'
	}
}

fn observer_state_value(state &ObserverPathnameState) brew_runtime.Value {
	return brew_runtime.structured_value('ObserverPathnameExtension::State', '', {
		'observer_state_address': u64(voidptr(state)).str()
	})
}

fn observer_state_from_value(value brew_runtime.Value) &ObserverPathnameState {
	address := value.attributes['observer_state_address'] or { panic('invalid observer state') }
	return unsafe { &ObserverPathnameState(voidptr(address.u64())) }
}

pub fn observer_pathname_state_boundary(state &ObserverPathnameState) brew_runtime.Value {
	return observer_state_value(state)
}

fn observed_pathname_value(pathname &ObservedPathname) brew_runtime.Value {
	return brew_runtime.structured_value('Pathname', pathname.path, {
		'observed_pathname_address': u64(voidptr(pathname)).str()
	})
}

fn observed_pathname_from_value(value brew_runtime.Value) &ObservedPathname {
	address := value.attributes['observed_pathname_address'] or { panic('invalid observed pathname') }
	return unsafe { &ObservedPathname(voidptr(address.u64())) }
}

pub fn observed_pathname_boundary(pathname &ObservedPathname) brew_runtime.Value {
	return observed_pathname_value(pathname)
}

// Ruby method `n` at line 15.
pub fn ruby_observer_pathname_extension_l15_d1_n(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(if args.len > 0 {
		observer_state_from_value(args[0]).n
	} else {
		0
	})
}

// Ruby attr_writer `attr_writer :n` at line 20.
pub fn ruby_observer_pathname_extension_l20_d2_n(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'state and n are required')
	}
	mut state := observer_state_from_value(args[0])
	state.n = int(args[1].int_data)
	return args[1]
}

// Ruby method `d` at line 23.
pub fn ruby_observer_pathname_extension_l23_d3_d(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(if args.len > 0 {
		observer_state_from_value(args[0]).d
	} else {
		0
	})
}

// Ruby attr_writer `attr_writer :d` at line 28.
pub fn ruby_observer_pathname_extension_l28_d4_d(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'state and d are required')
	}
	mut state := observer_state_from_value(args[0])
	state.d = int(args[1].int_data)
	return args[1]
}

// Ruby method `reset_counts!` at line 31.
pub fn ruby_observer_pathname_extension_l31_d5_reset_counts(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 0 {
		mut state := observer_state_from_value(args[0])
		state.reset_counts()
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `total` at line 38.
pub fn ruby_observer_pathname_extension_l38_d6_total(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(if args.len > 0 {
		observer_state_from_value(args[0]).total()
	} else {
		0
	})
}

// Ruby method `counts` at line 43.
pub fn ruby_observer_pathname_extension_l43_d7_counts(args ...brew_runtime.Value) brew_runtime.Value {
	state := if args.len > 0 {
		observer_state_from_value(args[0])
	} else {
		new_observer_pathname_state(false, false)
	}
	return brew_runtime.array_value([
		brew_runtime.int_value(state.n),
		brew_runtime.int_value(state.d),
	])
}

// Ruby method `verbose?` at line 51.
pub fn ruby_observer_pathname_extension_l51_d8_verbose(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	mut state := observer_state_from_value(args[0])
	return brew_runtime.bool_value(state.verbose_enabled())
}

// Ruby method `unlink` at line 68.
pub fn ruby_observer_pathname_extension_l68_d9_unlink(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'pathname is required')
	}
	mut pathname := observed_pathname_from_value(args[0])
	pathname.unlink() or { return brew_runtime.object_value('SystemCallError', err.msg()) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `mkpath` at line 75.
pub fn ruby_observer_pathname_extension_l75_d10_mkpath(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'pathname is required')
	}
	mut pathname := observed_pathname_from_value(args[0])
	pathname.mkpath() or { return brew_runtime.object_value('SystemCallError', err.msg()) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `rmdir` at line 81.
pub fn ruby_observer_pathname_extension_l81_d11_rmdir(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'pathname is required')
	}
	mut pathname := observed_pathname_from_value(args[0])
	pathname.rmdir() or { return brew_runtime.object_value('SystemCallError', err.msg()) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `make_relative_symlink(src)` at line 88.
pub fn ruby_observer_pathname_extension_l88_d12_make_relative_symlink(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'pathname and source are required')
	}
	mut pathname := observed_pathname_from_value(args[0])
	pathname.make_relative_symlink(args[1].as_string()) or {
		return brew_runtime.object_value('SystemCallError', err.msg())
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `install_info` at line 95.
pub fn ruby_observer_pathname_extension_l95_d13_install_info(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 0 {
		mut pathname := observed_pathname_from_value(args[0])
		pathname.install_info()
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `uninstall_info` at line 101.
pub fn ruby_observer_pathname_extension_l101_d14_uninstall_info(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 0 {
		mut pathname := observed_pathname_from_value(args[0])
		pathname.uninstall_info()
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "context"
// 5:
// 6: module ObserverPathnameExtension
// 7:   extend T::Helpers
// 8:
// 9:   requires_ancestor { Pathname }
// 10:
// 11:   class << self
// 12:     include Context
// 13:
// 14:     sig { returns(Integer) }
// 15:     def n
// 16:       @n ||= 0
// 17:     end
// 18:
// 19:     sig { params(n: Integer).void }
// 20:     attr_writer :n
// 21:
// 22:     sig { returns(Integer) }
// 23:     def d
// 24:       @d ||= 0
// 25:     end
// 26:
// 27:     sig { params(d: Integer).void }
// 28:     attr_writer :d
// 29:
// 30:     sig { void }
// 31:     def reset_counts!
// 32:       @n = T.let(0, T.nilable(Integer))
// 33:       @d = T.let(0, T.nilable(Integer))
// 34:       @put_verbose_trimmed_warning = T.let(false, T.nilable(T::Boolean))
// 35:     end
// 36:
// 37:     sig { returns(Integer) }
// 38:     def total
// 39:       n + d
// 40:     end
// 41:
// 42:     sig { returns([Integer, Integer]) }
// 43:     def counts
// 44:       [n, d]
// 45:     end
// 46:
// 47:     MAXIMUM_VERBOSE_OUTPUT = 100
// 48:     private_constant :MAXIMUM_VERBOSE_OUTPUT
// 49:
// 50:     sig { returns(T::Boolean) }
// 51:     def verbose?
// 52:       return super unless ENV["CI"]
// 53:       return false unless super
// 54:
// 55:       if total < MAXIMUM_VERBOSE_OUTPUT
// 56:         true
// 57:       else
// 58:         unless @put_verbose_trimmed_warning
// 59:           puts "Only the first #{MAXIMUM_VERBOSE_OUTPUT} operations were output."
// 60:           @put_verbose_trimmed_warning = true
// 61:         end
// 62:         false
// 63:       end
// 64:     end
// 65:   end
// 66:
// 67:   sig { void }
// 68:   def unlink
// 69:     super
// 70:     puts "rm #{self}" if ObserverPathnameExtension.verbose?
// 71:     ObserverPathnameExtension.n += 1
// 72:   end
// 73:
// 74:   sig { void }
// 75:   def mkpath
// 76:     super
// 77:     puts "mkdir -p #{self}" if ObserverPathnameExtension.verbose?
// 78:   end
// 79:
// 80:   sig { void }
// 81:   def rmdir
// 82:     super
// 83:     puts "rmdir #{self}" if ObserverPathnameExtension.verbose?
// 84:     ObserverPathnameExtension.d += 1
// 85:   end
// 86:
// 87:   sig { params(src: Pathname).void }
// 88:   def make_relative_symlink(src)
// 89:     super
// 90:     puts "ln -s #{src.relative_path_from(dirname)} #{basename}" if ObserverPathnameExtension.verbose?
// 91:     ObserverPathnameExtension.n += 1
// 92:   end
// 93:
// 94:   sig { void }
// 95:   def install_info
// 96:     super
// 97:     puts "info #{self}" if ObserverPathnameExtension.verbose?
// 98:   end
// 99:
// 100:   sig { void }
// 101:   def uninstall_info
// 102:     super
// 103:     puts "uninfo #{self}" if ObserverPathnameExtension.verbose?
// 104:   end
// 105: end
