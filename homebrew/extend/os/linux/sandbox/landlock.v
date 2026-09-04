module sandbox

import homebrew
import os

// Translated from Homebrew/brew `extend/os/linux/sandbox/landlock.rb`.

// Ruby method `full_write_isolation? = false` at line 101.
pub const access_fs_execute = u64(0x0001)
pub const access_fs_write_file = u64(0x0002)
pub const access_fs_read_file = u64(0x0004)
pub const access_fs_read_dir = u64(0x0008)
pub const access_fs_refer = u64(0x2000)
pub const access_fs_truncate = u64(0x4000)
pub const access_fs_ioctl_dev = u64(0x8000)
pub const access_fs_resolve_unix = u64(0x10000)
pub const write_access_fs = u64(0x1ff2)
pub const file_write_access_fs = access_fs_write_file | access_fs_truncate
pub const file_read_access_fs = access_fs_execute | access_fs_read_file
pub const read_access_fs = access_fs_execute | access_fs_read_file | access_fs_read_dir

pub struct LandlockClassContext {
pub:
	sandbox_linux    bool = true
	fiddle_available bool = true
	kernel_abi       int
	last_error       int
	setup_failed     bool
}

pub struct LandlockClassState {
pub mut:
	computed    bool
	state       homebrew.SandboxState
	abi_version int
}

pub struct LandlockSyscallCall {
pub:
	operation string
	values    []u64
	path      string
}

pub struct LandlockSyscalls {
pub mut:
	calls            []LandlockSyscallCall
	create_result    int
	add_result       int
	restrict_result  int
	privilege_result int
	open_results     map[string]int
	close_results    map[int]int
	last_error       int
}

pub struct LandlockRulesetAttributes {
pub:
	values                  []u64
	handled_access_fs       u64
	allowed_write_access_fs u64
	byte_size               int
}

pub struct LandlockPathRule {
pub:
	path            string
	allowed_access  u64
	file_descriptor int
}

struct LandlockDeviceRule {
	path   string
	access u64
}

pub struct LandlockApplyContext {
pub:
	abi                          int
	create_result                int = 17
	set_no_new_privileges_result int
	restrict_result              int
	device_paths                 map[string]bool
	file_descriptors             map[string]int
	missing_paths                []string
	last_error                   int
}

pub struct LandlockApplyResult {
pub:
	attributes              LandlockRulesetAttributes
	ruleset_fd              int
	path_rules              []LandlockPathRule
	closed_file_descriptors []int
	warning                 string
}

pub struct Landlock {
pub mut:
	backend          LinuxBackend
	writable_paths   []string
	readable_paths   []string
	error_pipe_path  string
	deny_all_network bool
	deny_read        bool
	root_path        string = '/'
	warnings         []string
}

pub fn landlock_full_write_isolation() bool {
	return false
}

// Ruby method `available?` at line 104.
pub fn landlock_available(mut state LandlockClassState, context LandlockClassContext) bool {
	return landlock_state(mut state, context) == .available
}

// Ruby method `state` at line 109.
pub fn landlock_state(mut state LandlockClassState, context LandlockClassContext) homebrew.SandboxState {
	if !state.computed {
		state.state = landlock_compute_state(mut state, context)
		state.computed = true
	}
	return state.state
}

// Ruby method `kernel_abi_version` at line 122.
pub fn landlock_kernel_abi_version(context LandlockClassContext) ?int {
	if !context.fiddle_available || context.setup_failed || context.kernel_abi <= 0 {
		return none
	}
	return context.kernel_abi
}

// Ruby method `failure_reason` at line 132.
pub fn landlock_failure_reason(state homebrew.SandboxState, abi int) ?string {
	return match state {
		.available { none }
		.config_disabled { 'Landlock cannot be used because Linux sandboxing is disabled.' }
		.missing_fiddle { "Landlock requires Ruby's bundled Fiddle library." }
		.unsupported { 'Landlock is not supported by this Linux kernel.' }
		.disabled { 'Landlock is disabled by this Linux kernel.' }
		.unsupported_abi {
			if abi > 0 {
				'Landlock ABI 2 or later is required; found ABI ${abi}.'
			} else {
				'Landlock ABI 2 or later is required.'
			}
		}
		else { 'Landlock is not available.' }
	}
}

// Ruby method `reset_state!` at line 157.
pub fn landlock_reset_state(mut state LandlockClassState) {
	state.computed = false
	state.state = .unavailable
	state.abi_version = 0
}

// Ruby method `landlock_add_rule(ruleset_fd, type, attributes, flags)` at line 176.
pub fn landlock_landlock_add_rule(mut syscalls LandlockSyscalls, ruleset_fd int, type_name int, allowed_access u64, path_fd int, flags int) int {
	syscalls.calls << LandlockSyscallCall{
		operation: 'landlock_add_rule'
		values: [
			u64(ruleset_fd),
			u64(type_name),
			allowed_access,
			u64(path_fd),
			u64(flags),
		]
	}
	return syscalls.add_result
}

// Ruby method `open_path(path)` at line 215.
pub fn landlock_open_path_raw(mut syscalls LandlockSyscalls, path string) int {
	syscalls.calls << LandlockSyscallCall{
		operation: 'open'
		path: path
		values: [
			u64(0o10000000 | 0o2000000),
		]
	}
	return syscalls.open_results[path] or { -1 }
}

// Ruby method `close_file_descriptor(file_descriptor)` at line 228.
pub fn landlock_close_fd_raw(mut syscalls LandlockSyscalls, file_descriptor int) int {
	syscalls.calls << LandlockSyscallCall{
		operation: 'close'
		values: [
			u64(file_descriptor),
		]
	}
	return syscalls.close_results[file_descriptor] or { 0 }
}

// Ruby method `compute_state` at line 248.
pub fn landlock_compute_state(mut state LandlockClassState, context LandlockClassContext) homebrew.SandboxState {
	if !context.sandbox_linux {
		return .config_disabled
	}
	if !context.fiddle_available {
		return .missing_fiddle
	}
	version := landlock_kernel_abi_version(context) or {
		return match context.last_error {
			38 { .unsupported }
			95 { .disabled }
			else { .unavailable }
		}
	}
	state.abi_version = version
	return if version >= 2 { .available } else { .unsupported_abi }
}

// Ruby method `initialize(profile)` at line 276.
pub fn landlock_initialize(profile homebrew.SandboxProfile) Landlock {
	return Landlock{ backend: backend_initialize(profile) }
}

// Ruby method `command(args, tmpdir)` at line 286.
pub fn landlock_command(mut landlock Landlock, args []string, tmpdir string) ![]string {
	paths := backend_writable_paths(landlock.backend)!
	landlock.writable_paths = paths.keys()
	for required in [os.path_devnull, tmpdir] {
		if required !in landlock.writable_paths { landlock.writable_paths << required }
	}
	for path in landlock.writable_paths {
		type_name := paths[path] or { homebrew.SandboxFilterType.subpath }
		backend_prepare_writable_path(mut landlock.backend, path, type_name)!
	}
	denied := landlock_denied_read_paths(landlock)
	landlock.readable_paths = landlock_readable_paths(landlock, denied)!
	landlock.deny_read = denied.len > 0
	landlock.deny_all_network = backend_deny_all_network(landlock.backend)
	landlock.error_pipe_path = os.join_path(tmpdir, 'socket')
	return args.clone()
}

// Ruby method `apply!` at line 299.
pub fn landlock_apply(mut landlock Landlock, context LandlockApplyContext) !LandlockApplyResult {
	abi := context.abi
	if abi < 2 {
		return error('Landlock ABI 2 or later is required; found ABI ${abi}.')
	}
	mut warning := ''
	if landlock.deny_all_network && abi < 10 {
		restriction := if abi >= 4 {
			'Applying the network restrictions supported by this kernel.'
		} else {
			'This kernel cannot restrict network access.'
		}
		warning = 'Landlock ABI 10 or later is required to deny all network access; found ABI ${abi}. ${restriction}'
		landlock.warnings << warning
	}
	attributes := landlock_ruleset_attributes(landlock, abi)
	if context.create_result < 0 {
		return landlock_raise_system_call_error('landlock_create_ruleset', context.last_error)
	}
	ruleset_fd := context.create_result
	mut rules := []LandlockPathRule{}
	mut closed := []int{}
	pty_access := access_fs_write_file | if abi >= 5 { access_fs_ioctl_dev } else { u64(0) } | if landlock.deny_read {
		access_fs_read_file
	} else {
		u64(0)
	}
	device_access := [
		LandlockDeviceRule{ path: '/dev/full', access: file_write_access_fs },
		LandlockDeviceRule{
			path: '/dev/mqueue'
			access: attributes.allowed_write_access_fs | if landlock.deny_read {
				access_fs_read_file
			} else {
				u64(0)
			}
		},
		LandlockDeviceRule{ path: '/dev/ptmx', access: pty_access },
		LandlockDeviceRule{ path: '/dev/pts', access: pty_access },
		LandlockDeviceRule{ path: '/dev/shm', access: attributes.allowed_write_access_fs },
		LandlockDeviceRule{ path: '/dev/tty', access: pty_access },
	]
	mut next_fd := 18
	for device in device_access {
		path := device.path
		access := device.access
		if !(context.device_paths[path] or { os.exists(path) }) {
			continue
		}
		fd := context.file_descriptors[path] or { next_fd }
		next_fd++
		rules << LandlockPathRule{ path: path, allowed_access: access & attributes.handled_access_fs, file_descriptor: fd }
		closed << fd
	}
	if landlock.deny_all_network && abi >= 9 && landlock.error_pipe_path != '' {
		fd := context.file_descriptors[landlock.error_pipe_path] or { next_fd }
		next_fd++
		rules << LandlockPathRule{ path: landlock.error_pipe_path, allowed_access: access_fs_resolve_unix, file_descriptor: fd }
		closed << fd
	}
	for path in landlock.readable_paths {
		if path in context.missing_paths || !os.exists(path) {
			continue
		}
		access := if os.is_dir(path) { read_access_fs } else { file_read_access_fs }
		fd := context.file_descriptors[path] or { next_fd }
		next_fd++
		rules << LandlockPathRule{ path: path, allowed_access: access, file_descriptor: fd }
		closed << fd
	}
	for path in landlock.writable_paths {
		access := if os.is_dir(path) {
			attributes.allowed_write_access_fs
		} else {
			attributes.allowed_write_access_fs & file_write_access_fs
		}
		fd := context.file_descriptors[path] or { next_fd }
		next_fd++
		rules << LandlockPathRule{ path: path, allowed_access: access & attributes.handled_access_fs, file_descriptor: fd }
		closed << fd
	}
	if context.set_no_new_privileges_result < 0 {
		return landlock_raise_system_call_error('prctl', context.last_error)
	}
	if context.restrict_result < 0 {
		return landlock_raise_system_call_error('landlock_restrict_self', context.last_error)
	}
	closed << ruleset_fd
	return LandlockApplyResult{ attributes: attributes, ruleset_fd: ruleset_fd, path_rules: rules, closed_file_descriptors: closed, warning: warning }
}

// Ruby method `ruleset_attributes(abi)` at line 379.
pub fn landlock_ruleset_attributes(landlock Landlock, abi int) LandlockRulesetAttributes {
	mut allowed := write_access_fs
	if abi >= 2 {
		allowed |= access_fs_refer
	}
	if abi >= 3 {
		allowed |= access_fs_truncate
	}
	mut handled := allowed
	if abi >= 5 {
		handled |= access_fs_ioctl_dev
	}
	if landlock.deny_read {
		handled |= read_access_fs
	}
	if landlock.deny_all_network && abi >= 9 {
		handled |= access_fs_resolve_unix
	}
	mut values := [handled]
	if landlock.deny_all_network && abi >= 4 {
		mut network := u64(3)
		if abi >= 10 {
			network |= u64(12)
		}
		values << network
		if abi >= 6 { values << u64(1) }
	}
	return LandlockRulesetAttributes{ values: values, handled_access_fs: handled, allowed_write_access_fs: allowed, byte_size: values.len * 8 }
}

// Ruby method `readable_paths(denied_paths)` at line 405.
pub fn landlock_readable_paths(landlock Landlock, denied_paths []string) ![]string {
	if denied_paths.len == 0 || os.norm_path(landlock.root_path) in denied_paths.map(os.norm_path(it)) {
		return []
	}
	mut paths := []string{}
	mut children := os.ls(landlock.root_path)!
	children.sort()
	for name in children {
		landlock_add_readable_path(os.join_path(landlock.root_path, name), denied_paths, mut paths)!
	}
	return paths
}

// Ruby method `denied_read_paths` at line 432.
pub fn landlock_denied_read_paths(landlock Landlock) []string {
	return backend_profile_paths(landlock.backend, false, 'file-read').filter(os.exists(it) || os.is_link(it))
}

// Ruby method `add_readable_path(path, denied_paths, paths)` at line 443.
pub fn landlock_add_readable_path(path string, denied_paths []string, mut paths []string) ! {
	normal := os.norm_path(path)
	if normal in denied_paths.map(os.norm_path(it)) {
		return
	}
	if os.is_link(path) {
		return
	}
	if os.is_dir(path) && denied_paths.any(os.norm_path(it).starts_with(normal.trim_right(os.path_separator) + os.path_separator)) {
		mut children := os.ls(path) or { return }
		children.sort()
		for child in children {
			landlock_add_readable_path(os.join_path(path, child), denied_paths, mut paths)!
		}
	} else {
		paths << path
	}
}

// Ruby method `open_path(path)` at line 464.
pub fn landlock_open_path(mut syscalls LandlockSyscalls, path string) !int {
	fd := landlock_open_path_raw(mut syscalls, path)
	if fd < 0 {
		return landlock_raise_system_call_error('open', syscalls.last_error)
	}
	return fd
}

// Ruby method `close_file_descriptor(file_descriptor)` at line 472.
pub fn landlock_close_fd(mut syscalls LandlockSyscalls, fd int) ! {
	if landlock_close_fd_raw(mut syscalls, fd) < 0 {
		return landlock_raise_system_call_error('close', syscalls.last_error)
	}
}

// Ruby method `raise_system_call_error(operation)` at line 477.
pub fn landlock_raise_system_call_error(operation string, last_error int) IError {
	return error('SystemCallError: ${operation} (${last_error})')
}
