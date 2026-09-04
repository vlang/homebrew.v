module pathname

import ruby
import os

// Translated from Homebrew/brew `extend/pathname/observer_pathname_extension.rb`.
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

fn observer_state_value(state &ObserverPathnameState) ruby.Value {
	return ruby.structured_value('ObserverPathnameExtension::State', '', {
		'observer_state_address': u64(voidptr(state)).str()
	})
}

fn observer_state_from_value(value ruby.Value) &ObserverPathnameState {
	address := value.attributes['observer_state_address'] or { panic('invalid observer state') }
	return unsafe { &ObserverPathnameState(voidptr(address.u64())) }
}

pub fn observer_pathname_state_boundary(state &ObserverPathnameState) ruby.Value {
	return observer_state_value(state)
}

fn observed_pathname_value(pathname &ObservedPathname) ruby.Value {
	return ruby.structured_value('Pathname', pathname.path, {
		'observed_pathname_address': u64(voidptr(pathname)).str()
	})
}

fn observed_pathname_from_value(value ruby.Value) &ObservedPathname {
	address := value.attributes['observed_pathname_address'] or { panic('invalid observed pathname') }
	return unsafe { &ObservedPathname(voidptr(address.u64())) }
}

pub fn observed_pathname_boundary(pathname &ObservedPathname) ruby.Value {
	return observed_pathname_value(pathname)
}
