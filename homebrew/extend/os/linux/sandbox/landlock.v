module sandbox

import homebrew
import os

// Translated from Homebrew/brew `extend/os/linux/sandbox/landlock.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `abi_version` at line 114.
pub fn ruby_landlock_l114_d4_abi_version(mut state LandlockClassState, context LandlockClassContext) ?int {
	landlock_state(mut state, context)
	return if state.abi_version > 0 { state.abi_version } else { none }
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

// Ruby method `landlock_create_ruleset(attributes, size, flags)` at line 163.
pub fn ruby_landlock_l163_d8_landlock_create_ruleset(mut syscalls LandlockSyscalls, attributes []u64, size int, flags int) int {
	mut values := [u64(size), u64(flags)]
	values << attributes
	syscalls.calls << LandlockSyscallCall{ operation: 'landlock_create_ruleset', values: values }
	return syscalls.create_result
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

// Ruby method `landlock_restrict_self(ruleset_fd, flags)` at line 189.
pub fn ruby_landlock_l189_d10_landlock_restrict_self(mut syscalls LandlockSyscalls, ruleset_fd int, flags int) int {
	syscalls.calls << LandlockSyscallCall{
		operation: 'landlock_restrict_self'
		values: [
			u64(ruleset_fd),
			u64(flags),
		]
	}
	return syscalls.restrict_result
}

// Ruby method `set_no_new_privileges` at line 202.
pub fn ruby_landlock_l202_d11_set_no_new_privileges(mut syscalls LandlockSyscalls) int {
	syscalls.calls << LandlockSyscallCall{ operation: 'prctl', values: [u64(38), 1, 0, 0, 0] }
	return syscalls.privilege_result
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

// Ruby method `last_error` at line 241.
pub fn ruby_landlock_l241_d14_last_error(syscalls LandlockSyscalls) int {
	return syscalls.last_error
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

// Ruby method `add_path_rule(ruleset_fd, path, allowed_access)` at line 416.
pub fn ruby_landlock_l416_d21_add_path_rule(mut syscalls LandlockSyscalls, ruleset_fd int, path string, allowed_access u64) !LandlockPathRule {
	fd := landlock_open_path(mut syscalls, path)!
	result := landlock_landlock_add_rule(mut syscalls, ruleset_fd, 1, allowed_access, fd, 0)
	landlock_close_fd(mut syscalls, fd)!
	if result < 0 {
		return landlock_raise_system_call_error('landlock_add_rule', syscalls.last_error)
	}
	return LandlockPathRule{ path: path, allowed_access: allowed_access, file_descriptor: fd }
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

// Ruby method `root_path` at line 459.
pub fn ruby_landlock_l459_d24_root_path(landlock Landlock) string {
	return landlock.root_path
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "fileutils"
// 5: require "env_config"
// 6: require "utils/output"
// 7: require "extend/os/linux/sandbox/backend"
// 8:
// 9: class Sandbox
// 10:   class Landlock < LinuxBackend
// 11:     include Utils::Output::Mixin
// 12:
// 13:     # Keep these constants and structure layouts in sync with Linux's Landlock UAPI:
// 14:     # https://github.com/torvalds/linux/blob/master/include/uapi/linux/landlock.h
// 15:     CREATE_RULESET_VERSION = 1
// 16:     RULE_PATH_BENEATH = 1
// 17:
// 18:     # Linux's `prctl(2)` operation and `open(2)` flags come from these UAPI headers:
// 19:     # https://github.com/torvalds/linux/blob/master/include/uapi/linux/prctl.h
// 20:     # https://github.com/torvalds/linux/blob/master/include/uapi/asm-generic/fcntl.h
// 21:     PR_SET_NO_NEW_PRIVS = 38
// 22:     O_PATH = 010000000
// 23:     O_CLOEXEC = 02000000
// 24:
// 25:     # Landlock has no dedicated libc wrappers, so call `syscall(2)` as documented:
// 26:     # https://man7.org/linux/man-pages/man2/landlock_create_ruleset.2.html
// 27:     # Homebrew's x86_64 and arm64 Linux architectures both use these numbers:
// 28:     # https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl
// 29:     # https://github.com/torvalds/linux/blob/master/include/uapi/asm-generic/unistd.h
// 30:     CREATE_RULESET_SYSCALL = 444
// 31:     ADD_RULE_SYSCALL = 445
// 32:     RESTRICT_SELF_SYSCALL = 446
// 33:
// 34:     ACCESS_FS_EXECUTE = 0x0001
// 35:     ACCESS_FS_WRITE_FILE = 0x0002
// 36:     ACCESS_FS_READ_FILE = 0x0004
// 37:     ACCESS_FS_READ_DIR = 0x0008
// 38:     ACCESS_FS_REMOVE_DIR = 0x0010
// 39:     ACCESS_FS_REMOVE_FILE = 0x0020
// 40:     ACCESS_FS_MAKE_CHAR = 0x0040
// 41:     ACCESS_FS_MAKE_DIR = 0x0080
// 42:     ACCESS_FS_MAKE_REG = 0x0100
// 43:     ACCESS_FS_MAKE_SOCK = 0x0200
// 44:     ACCESS_FS_MAKE_FIFO = 0x0400
// 45:     ACCESS_FS_MAKE_BLOCK = 0x0800
// 46:     ACCESS_FS_MAKE_SYM = 0x1000
// 47:     ACCESS_FS_REFER = 0x2000
// 48:     ACCESS_FS_TRUNCATE = 0x4000
// 49:     ACCESS_FS_IOCTL_DEV = 0x8000
// 50:     ACCESS_FS_RESOLVE_UNIX = 0x10000
// 51:
// 52:     ACCESS_NET_BIND_TCP = 0x01
// 53:     ACCESS_NET_CONNECT_TCP = 0x02
// 54:     ACCESS_NET_BIND_UDP = 0x04
// 55:     ACCESS_NET_CONNECT_SEND_UDP = 0x08
// 56:     SCOPE_ABSTRACT_UNIX_SOCKET = 0x01
// 57:     # ABI 2 is the first version that can permit cross-directory renames and
// 58:     # links, which earlier ABIs always deny for sandboxed processes:
// 59:     # https://www.kernel.org/doc/html/latest/userspace-api/landlock.html#previous-limitations
// 60:     MINIMUM_ABI = 2
// 61:     # File truncation cannot be restricted before ABI 3, letting sandboxed
// 62:     # processes truncate files outside allowed write paths. Every profile
// 63:     # needs write isolation, so unlike `@deny_all_network` there is no
// 64:     # profile-specific check that could gate a warning:
// 65:     # https://www.kernel.org/doc/html/latest/userspace-api/landlock.html#previous-limitations
// 66:     MINIMUM_TRUNCATE_ABI = 3
// 67:     # TCP bind and connect restrictions were added in ABI 4:
// 68:     # https://www.kernel.org/doc/html/latest/userspace-api/landlock.html#network-flags
// 69:     MINIMUM_NETWORK_ABI = 4
// 70:     # UDP controls required to block all network access were added in ABI 10:
// 71:     # https://www.kernel.org/doc/html/latest/userspace-api/landlock.html#network-flags
// 72:     MINIMUM_FULL_NETWORK_ABI = 10
// 73:
// 74:     WRITE_ACCESS_FS = T.let(
// 75:       (ACCESS_FS_WRITE_FILE | ACCESS_FS_REMOVE_DIR | ACCESS_FS_REMOVE_FILE | ACCESS_FS_MAKE_CHAR |
// 76:       ACCESS_FS_MAKE_DIR | ACCESS_FS_MAKE_REG | ACCESS_FS_MAKE_SOCK | ACCESS_FS_MAKE_FIFO |
// 77:       ACCESS_FS_MAKE_BLOCK | ACCESS_FS_MAKE_SYM).freeze,
// 78:       Integer,
// 79:     )
// 80:     FILE_WRITE_ACCESS_FS = T.let((ACCESS_FS_WRITE_FILE | ACCESS_FS_TRUNCATE).freeze, Integer)
// 81:     FILE_READ_ACCESS_FS = T.let((ACCESS_FS_EXECUTE | ACCESS_FS_READ_FILE).freeze, Integer)
// 82:     READ_ACCESS_FS = T.let((ACCESS_FS_EXECUTE | ACCESS_FS_READ_FILE | ACCESS_FS_READ_DIR).freeze, Integer)
// 83:     private_constant :CREATE_RULESET_VERSION, :RULE_PATH_BENEATH, :PR_SET_NO_NEW_PRIVS, :O_PATH, :O_CLOEXEC,
// 84:                      :CREATE_RULESET_SYSCALL, :ADD_RULE_SYSCALL, :RESTRICT_SELF_SYSCALL,
// 85:                      :ACCESS_FS_EXECUTE, :ACCESS_FS_WRITE_FILE, :ACCESS_FS_READ_FILE, :ACCESS_FS_READ_DIR,
// 86:                      :ACCESS_FS_REMOVE_DIR, :ACCESS_FS_REMOVE_FILE, :ACCESS_FS_MAKE_CHAR, :ACCESS_FS_MAKE_DIR,
// 87:                      :ACCESS_FS_MAKE_REG, :ACCESS_FS_MAKE_SOCK, :ACCESS_FS_MAKE_FIFO, :ACCESS_FS_MAKE_BLOCK,
// 88:                      :ACCESS_FS_MAKE_SYM, :ACCESS_FS_REFER, :ACCESS_FS_TRUNCATE, :ACCESS_FS_RESOLVE_UNIX,
// 89:                      :ACCESS_FS_IOCTL_DEV,
// 90:                      :ACCESS_NET_BIND_TCP, :ACCESS_NET_CONNECT_TCP, :ACCESS_NET_BIND_UDP,
// 91:                      :ACCESS_NET_CONNECT_SEND_UDP, :SCOPE_ABSTRACT_UNIX_SOCKET, :MINIMUM_ABI,
// 92:                      :MINIMUM_TRUNCATE_ABI, :MINIMUM_NETWORK_ABI, :MINIMUM_FULL_NETWORK_ABI,
// 93:                      :WRITE_ACCESS_FS, :FILE_WRITE_ACCESS_FS, :FILE_READ_ACCESS_FS, :READ_ACCESS_FS
// 94:
// 95:     class << self
// 96:       # Landlock cannot restrict chmod, chown, extended attributes or timestamp
// 97:       # changes. Callers requiring full write isolation must compensate for
// 98:       # these limitations:
// 99:       # https://www.kernel.org/doc/html/latest/userspace-api/landlock.html#filesystem-flags
// 100:       sig { returns(T::Boolean) }
// 101:       def full_write_isolation? = false
// 102:
// 103:       sig { returns(T::Boolean) }
// 104:       def available?
// 105:         state == :available
// 106:       end
// 107:
// 108:       sig { returns(Symbol) }
// 109:       def state
// 110:         @state ||= T.let(compute_state, T.nilable(Symbol))
// 111:       end
// 112:
// 113:       sig { returns(T.nilable(Integer)) }
// 114:       def abi_version
// 115:         state
// 116:         @abi_version
// 117:       end
// 118:
// 119:       # The Landlock ABI version provided by the running kernel, regardless of
// 120:       # whether Homebrew's Linux sandbox is enabled or usable.
// 121:       sig { returns(T.nilable(Integer)) }
// 122:       def kernel_abi_version
// 123:         require "fiddle"
// 124:
// 125:         version = landlock_create_ruleset(nil, 0, CREATE_RULESET_VERSION)
// 126:         version if version.positive?
// 127:       rescue LoadError, Fiddle::DLError
// 128:         nil
// 129:       end
// 130:
// 131:       sig { returns(T.nilable(String)) }
// 132:       def failure_reason
// 133:         case state
// 134:         when :available
// 135:           nil
// 136:         when :config_disabled
// 137:           "Landlock cannot be used because Linux sandboxing is disabled."
// 138:         when :missing_fiddle
// 139:           "Landlock requires Ruby's bundled Fiddle library."
// 140:         when :unsupported
// 141:           "Landlock is not supported by this Linux kernel."
// 142:         when :disabled
// 143:           "Landlock is disabled by this Linux kernel."
// 144:         when :unsupported_abi
// 145:           abi = @abi_version
// 146:           if abi
// 147:             "Landlock ABI #{MINIMUM_ABI} or later is required; found ABI #{abi}."
// 148:           else
// 149:             "Landlock ABI #{MINIMUM_ABI} or later is required."
// 150:           end
// 151:         else
// 152:           "Landlock is not available."
// 153:         end
// 154:       end
// 155:
// 156:       sig { void }
// 157:       def reset_state!
// 158:         @state = T.let(nil, T.nilable(Symbol))
// 159:         @abi_version = T.let(nil, T.nilable(Integer))
// 160:       end
// 161:
// 162:       sig { params(attributes: T.nilable(String), size: Integer, flags: Integer).returns(Integer) }
// 163:       def landlock_create_ruleset(attributes, size, flags)
// 164:         @landlock_create_ruleset ||= T.let(
// 165:           Fiddle::Function.new(
// 166:             Fiddle.dlopen(nil)["syscall"],
// 167:             [Fiddle::TYPE_LONG, Fiddle::TYPE_VOIDP, Fiddle::TYPE_SIZE_T, Fiddle::TYPE_UINT],
// 168:             Fiddle::TYPE_LONG,
// 169:           ),
// 170:           T.nilable(Fiddle::Function),
// 171:         )
// 172:         @landlock_create_ruleset.call(CREATE_RULESET_SYSCALL, attributes, size, flags)
// 173:       end
// 174:
// 175:       sig { params(ruleset_fd: Integer, type: Integer, attributes: String, flags: Integer).returns(Integer) }
// 176:       def landlock_add_rule(ruleset_fd, type, attributes, flags)
// 177:         @landlock_add_rule ||= T.let(
// 178:           Fiddle::Function.new(
// 179:             Fiddle.dlopen(nil)["syscall"],
// 180:             [Fiddle::TYPE_LONG, Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_UINT],
// 181:             Fiddle::TYPE_LONG,
// 182:           ),
// 183:           T.nilable(Fiddle::Function),
// 184:         )
// 185:         @landlock_add_rule.call(ADD_RULE_SYSCALL, ruleset_fd, type, attributes, flags)
// 186:       end
// 187:
// 188:       sig { params(ruleset_fd: Integer, flags: Integer).returns(Integer) }
// 189:       def landlock_restrict_self(ruleset_fd, flags)
// 190:         @landlock_restrict_self ||= T.let(
// 191:           Fiddle::Function.new(
// 192:             Fiddle.dlopen(nil)["syscall"],
// 193:             [Fiddle::TYPE_LONG, Fiddle::TYPE_INT, Fiddle::TYPE_UINT],
// 194:             Fiddle::TYPE_LONG,
// 195:           ),
// 196:           T.nilable(Fiddle::Function),
// 197:         )
// 198:         @landlock_restrict_self.call(RESTRICT_SELF_SYSCALL, ruleset_fd, flags)
// 199:       end
// 200:
// 201:       sig { returns(Integer) }
// 202:       def set_no_new_privileges
// 203:         @prctl ||= T.let(
// 204:           Fiddle::Function.new(
// 205:             Fiddle.dlopen(nil)["prctl"],
// 206:             [Fiddle::TYPE_INT, Fiddle::TYPE_ULONG, Fiddle::TYPE_ULONG, Fiddle::TYPE_ULONG, Fiddle::TYPE_ULONG],
// 207:             Fiddle::TYPE_INT,
// 208:           ),
// 209:           T.nilable(Fiddle::Function),
// 210:         )
// 211:         @prctl.call(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)
// 212:       end
// 213:
// 214:       sig { params(path: String).returns(Integer) }
// 215:       def open_path(path)
// 216:         @open ||= T.let(
// 217:           Fiddle::Function.new(
// 218:             Fiddle.dlopen(nil)["open"],
// 219:             [Fiddle::TYPE_CONST_STRING, Fiddle::TYPE_INT],
// 220:             Fiddle::TYPE_INT,
// 221:           ),
// 222:           T.nilable(Fiddle::Function),
// 223:         )
// 224:         @open.call(path, O_PATH | O_CLOEXEC)
// 225:       end
// 226:
// 227:       sig { params(file_descriptor: Integer).returns(Integer) }
// 228:       def close_file_descriptor(file_descriptor)
// 229:         @close ||= T.let(
// 230:           Fiddle::Function.new(
// 231:             Fiddle.dlopen(nil)["close"],
// 232:             [Fiddle::TYPE_INT],
// 233:             Fiddle::TYPE_INT,
// 234:           ),
// 235:           T.nilable(Fiddle::Function),
// 236:         )
// 237:         @close.call(file_descriptor)
// 238:       end
// 239:
// 240:       sig { returns(Integer) }
// 241:       def last_error
// 242:         Fiddle.last_error
// 243:       end
// 244:
// 245:       private
// 246:
// 247:       sig { returns(Symbol) }
// 248:       def compute_state
// 249:         return :config_disabled unless Homebrew::EnvConfig.sandbox_linux?
// 250:
// 251:         begin
// 252:           require "fiddle"
// 253:         rescue LoadError
// 254:           return :missing_fiddle
// 255:         end
// 256:
// 257:         version = kernel_abi_version
// 258:         if version
// 259:           @abi_version = T.let(version, T.nilable(Integer))
// 260:           if version >= MINIMUM_ABI
// 261:             :available
// 262:           else
// 263:             :unsupported_abi
// 264:           end
// 265:         else
// 266:           case last_error
// 267:           when Errno::ENOSYS::Errno then :unsupported
// 268:           when Errno::EOPNOTSUPP::Errno then :disabled
// 269:           else                               :unavailable
// 270:           end
// 271:         end
// 272:       end
// 273:     end
// 274:
// 275:     sig { params(profile: SandboxProfile).void }
// 276:     def initialize(profile)
// 277:       super
// 278:       @writable_paths = T.let([], T::Array[String])
// 279:       @readable_paths = T.let([], T::Array[String])
// 280:       @error_pipe_path = T.let(nil, T.nilable(String))
// 281:       @deny_all_network = T.let(false, T::Boolean)
// 282:       @deny_read = T.let(false, T::Boolean)
// 283:     end
// 284:
// 285:     sig { params(args: T::Array[T.any(String, ::Pathname)], tmpdir: String).returns(T::Array[T.any(String, ::Pathname)]) }
// 286:     def command(args, tmpdir)
// 287:       paths = writable_paths
// 288:       @writable_paths = paths.keys | [File::NULL, tmpdir]
// 289:       @writable_paths.each { |path| prepare_writable_path(path, paths.fetch(path, :subpath)) }
// 290:       denied_read_paths = self.denied_read_paths
// 291:       @readable_paths = readable_paths(denied_read_paths)
// 292:       @deny_read = denied_read_paths.any?
// 293:       @deny_all_network = deny_all_network?
// 294:       @error_pipe_path = File.join(tmpdir, "socket")
// 295:       args
// 296:     end
// 297:
// 298:     sig { void }
// 299:     def apply!
// 300:       abi = self.class.abi_version
// 301:       if !abi || abi < MINIMUM_ABI
// 302:         raise self.class.failure_reason || "Landlock ABI #{MINIMUM_ABI} or later is required."
// 303:       end
// 304:
// 305:       if @deny_all_network && abi < MINIMUM_FULL_NETWORK_ABI
// 306:         network_restrictions = if abi >= MINIMUM_NETWORK_ABI
// 307:           "Applying the network restrictions supported by this kernel."
// 308:         else
// 309:           "This kernel cannot restrict network access."
// 310:         end
// 311:         opoo "Landlock ABI #{MINIMUM_FULL_NETWORK_ABI} or later is required to deny all network access; " \
// 312:              "found ABI #{abi}. #{network_restrictions}"
// 313:       end
// 314:
// 315:       attributes, handled_access_fs, allowed_write_access_fs = ruleset_attributes(abi)
// 316:       ruleset_fd = self.class.landlock_create_ruleset(attributes, attributes.bytesize, 0)
// 317:       raise_system_call_error("landlock_create_ruleset") if ruleset_fd.negative?
// 318:
// 319:       begin
// 320:         # PTY allocation opens `/dev/ptmx` read-write, then configures its
// 321:         # dynamically allocated `/dev/pts/*` slave with device ioctls:
// 322:         # https://github.com/torvalds/linux/blob/master/drivers/tty/pty.c
// 323:         # https://www.kernel.org/doc/html/latest/userspace-api/landlock.html#ioctl-support
// 324:         pty_access = ACCESS_FS_WRITE_FILE
// 325:         pty_access |= ACCESS_FS_IOCTL_DEV if abi >= 5
// 326:         pty_access |= ACCESS_FS_READ_FILE if @deny_read
// 327:
// 328:         # `/dev/full` is Linux's standard ENOSPC test device. Opening it with
// 329:         # `fopen(..., "w")` also requires Landlock's truncate right:
// 330:         # https://github.com/torvalds/linux/blob/master/drivers/char/mem.c
// 331:         # POSIX shared memory and message queues use `/dev/shm` and
// 332:         # `/dev/mqueue`. These grants retain normal kernel permissions but do
// 333:         # not provide a private IPC namespace:
// 334:         # https://github.com/bminor/glibc/blob/master/sysdeps/posix/shm-directory.c
// 335:         # https://www.kernel.org/doc/html/latest/filesystems/mqueue.html
// 336:         device_path_rules = T.let({
// 337:           "/dev/full"   => FILE_WRITE_ACCESS_FS,
// 338:           "/dev/mqueue" => allowed_write_access_fs | (@deny_read ? ACCESS_FS_READ_FILE : 0),
// 339:           "/dev/ptmx"   => pty_access,
// 340:           "/dev/pts"    => pty_access,
// 341:           "/dev/shm"    => allowed_write_access_fs,
// 342:           "/dev/tty"    => pty_access,
// 343:         }, T::Hash[String, Integer])
// 344:         device_path_rules.each do |path, allowed_access|
// 345:           next unless File.exist?(path)
// 346:
// 347:           add_path_rule(ruleset_fd, path, allowed_access & handled_access_fs)
// 348:         end
// 349:
// 350:         error_pipe_path = @error_pipe_path
// 351:         if @deny_all_network && abi >= 9 && error_pipe_path
// 352:           add_path_rule(ruleset_fd, error_pipe_path, ACCESS_FS_RESOLVE_UNIX)
// 353:         end
// 354:         @readable_paths.each do |path|
// 355:           allowed_access = File.directory?(path) ? READ_ACCESS_FS : FILE_READ_ACCESS_FS
// 356:           add_path_rule(ruleset_fd, path, allowed_access)
// 357:         rescue Errno::ENOENT
// 358:           nil
// 359:         end
// 360:         @writable_paths.each do |path|
// 361:           allowed_access = if File.directory?(path)
// 362:             allowed_write_access_fs
// 363:           else
// 364:             allowed_write_access_fs & FILE_WRITE_ACCESS_FS
// 365:           end
// 366:           add_path_rule(ruleset_fd, path, allowed_access & handled_access_fs)
// 367:         end
// 368:
// 369:         raise_system_call_error("prctl") if self.class.set_no_new_privileges.negative?
// 370:         if self.class.landlock_restrict_self(ruleset_fd, 0).negative?
// 371:           raise_system_call_error("landlock_restrict_self")
// 372:         end
// 373:       ensure
// 374:         close_file_descriptor(ruleset_fd)
// 375:       end
// 376:     end
// 377:
// 378:     sig { params(abi: Integer).returns([String, Integer, Integer]) }
// 379:     def ruleset_attributes(abi)
// 380:       allowed_access_fs = WRITE_ACCESS_FS
// 381:       allowed_access_fs |= ACCESS_FS_REFER if abi >= MINIMUM_ABI
// 382:       allowed_access_fs |= ACCESS_FS_TRUNCATE if abi >= MINIMUM_TRUNCATE_ABI
// 383:       handled_access_fs = allowed_access_fs
// 384:       # IOCTL_DEV is available from ABI 5 and deliberately remains absent from
// 385:       # allowed path rules, denying device ioctls opened inside the sandbox:
// 386:       # https://www.kernel.org/doc/html/latest/userspace-api/landlock.html#ioctl-support
// 387:       handled_access_fs |= ACCESS_FS_IOCTL_DEV if abi >= 5
// 388:       handled_access_fs |= READ_ACCESS_FS if @deny_read
// 389:       handled_access_fs |= ACCESS_FS_RESOLVE_UNIX if @deny_all_network && abi >= 9
// 390:
// 391:       # Optional ruleset fields are appended as `__u64` members, so only pass
// 392:       # the prefix needed for features supported by the running kernel.
// 393:       attributes = [handled_access_fs]
// 394:       if @deny_all_network && abi >= MINIMUM_NETWORK_ABI
// 395:         handled_access_net = ACCESS_NET_BIND_TCP | ACCESS_NET_CONNECT_TCP
// 396:         handled_access_net |= ACCESS_NET_BIND_UDP | ACCESS_NET_CONNECT_SEND_UDP if abi >= MINIMUM_FULL_NETWORK_ABI
// 397:         attributes << handled_access_net
// 398:         attributes << SCOPE_ABSTRACT_UNIX_SOCKET if abi >= 6
// 399:       end
// 400:
// 401:       [attributes.pack("Q*"), handled_access_fs, allowed_access_fs]
// 402:     end
// 403:
// 404:     sig { params(denied_paths: T::Array[::Pathname]).returns(T::Array[String]) }
// 405:     def readable_paths(denied_paths)
// 406:       return [] if denied_paths.empty? || denied_paths.include?(root_path)
// 407:
// 408:       root_path.children.sort.each_with_object([]) do |path, paths|
// 409:         add_readable_path(path, denied_paths, paths)
// 410:       end
// 411:     end
// 412:
// 413:     private
// 414:
// 415:     sig { params(ruleset_fd: Integer, path: String, allowed_access: Integer).void }
// 416:     def add_path_rule(ruleset_fd, path, allowed_access)
// 417:       path_fd = open_path(path)
// 418:       result = self.class.landlock_add_rule(
// 419:         ruleset_fd,
// 420:         RULE_PATH_BENEATH,
// 421:         # The packed UAPI struct has no padding or reserved field: one `__u64`
// 422:         # access mask followed by one `__s32` file descriptor.
// 423:         [allowed_access, path_fd].pack("Ql"),
// 424:         0,
// 425:       )
// 426:       raise_system_call_error("landlock_add_rule") if result.negative?
// 427:     ensure
// 428:       close_file_descriptor(path_fd) if path_fd
// 429:     end
// 430:
// 431:     sig { returns(T::Array[::Pathname]) }
// 432:     def denied_read_paths
// 433:       profile_paths(allow: false, operation: "file-read").filter_map do |path|
// 434:         pathname = ::Pathname.new(path)
// 435:         pathname.lstat
// 436:         pathname
// 437:       rescue Errno::ENOENT
// 438:         nil
// 439:       end
// 440:     end
// 441:
// 442:     sig { params(path: ::Pathname, denied_paths: T::Array[::Pathname], paths: T::Array[String]).void }
// 443:     def add_readable_path(path, denied_paths, paths)
// 444:       return if denied_paths.include?(path)
// 445:
// 446:       path_stat = path.lstat
// 447:       return if path_stat.symlink?
// 448:
// 449:       if path_stat.directory? && denied_paths.any? { |denied_path| denied_path.ascend.include?(path) }
// 450:         path.children.sort.each { |child| add_readable_path(child, denied_paths, paths) }
// 451:       else
// 452:         paths << path.to_s
// 453:       end
// 454:     rescue Errno::EACCES, Errno::ENOENT
// 455:       nil
// 456:     end
// 457:
// 458:     sig { returns(::Pathname) }
// 459:     def root_path
// 460:       ::Pathname.new("/")
// 461:     end
// 462:
// 463:     sig { params(path: String).returns(Integer) }
// 464:     def open_path(path)
// 465:       file_descriptor = self.class.open_path(path)
// 466:       raise_system_call_error("open") if file_descriptor.negative?
// 467:
// 468:       file_descriptor
// 469:     end
// 470:
// 471:     sig { params(file_descriptor: Integer).void }
// 472:     def close_file_descriptor(file_descriptor)
// 473:       raise_system_call_error("close") if self.class.close_file_descriptor(file_descriptor).negative?
// 474:     end
// 475:
// 476:     sig { params(operation: String).void }
// 477:     def raise_system_call_error(operation)
// 478:       raise SystemCallError.new(operation, self.class.last_error)
// 479:     end
// 480:   end
// 481: end
