module utils

import ruby
import homebrew.extend.os.mac.utils as mac_socket_utils
import net.unix
import os
import time

// Translated from Homebrew/brew `utils/socket.rb`.
// The original source is retained below until every stub has a typed V body.
pub const socket_wait_readable_code = 11

pub struct SocketWaitReadableError {
pub:
	path string
}

pub fn (wait_error SocketWaitReadableError) msg() string {
	return 'Resource temporarily unavailable while accepting ${wait_error.path}'
}

pub fn (wait_error SocketWaitReadableError) code() int {
	return socket_wait_readable_code
}

pub enum UnixSocketRole {
	client
	accepted
	server
}

pub struct UnixSocketAddress {
pub:
	path   string
	packed []u8
}

@[heap]
pub struct UnixSocket {
pub:
	path string
	role UnixSocketRole
mut:
	connection &unix.StreamConn = unsafe { nil }
pub mut:
	closed bool
}

@[heap]
pub struct UnixServer {
pub:
	path string
mut:
	listener &unix.StreamListener = unsafe { nil }
pub mut:
	closed bool
}

pub struct UnixSocketState {
pub:
	path      string
	role      UnixSocketRole
	open      bool
	connected bool
	listening bool
}

pub type UnixSocketAction = fn(mut socket UnixSocket) !ruby.Value

pub fn unix_sockaddr(path string) !UnixSocketAddress {
	if path.bytes().contains(u8(0)) {
		return error('unix socket path cannot contain a null byte')
	}
	packed := $if macos { mac_socket_utils.sockaddr_un(path)! } $else {
		path_bytes := path.bytes()
		if path_bytes.len > 107 {
			return error('too long unix socket path (${path_bytes.len} bytes given but 107 bytes max)')
		}
		mut portable := []u8{cap: path_bytes.len + 3}
		portable << u8(1)
		portable << u8(0)
		portable << path_bytes
		portable << u8(0)
		portable
	}
	return UnixSocketAddress{
		path: path
		packed: packed
	}
}

pub fn connect_unix_socket(path string) !&UnixSocket {
	unix_sockaddr(path)!
	connection := unix.connect_stream(path)!
	return &UnixSocket{
		path: path
		role: .client
		connection: connection
	}
}

pub fn open_unix_socket(path string, action UnixSocketAction) !ruby.Value {
	mut socket := connect_unix_socket(path)!
	defer {
		socket.close() or {}
	}
	return action(mut socket)
}

pub fn (mut socket UnixSocket) write(data string) !int {
	if socket.closed || isnil(socket.connection) {
		return error('unix socket is closed')
	}
	return socket.connection.write_string(data)
}

pub fn (mut socket UnixSocket) read(max_bytes int) !string {
	if socket.closed || isnil(socket.connection) {
		return error('unix socket is closed')
	}
	if max_bytes <= 0 {
		return error('read size must be positive')
	}
	mut buffer := []u8{len: max_bytes}
	read := socket.connection.read(mut buffer)!
	return buffer[..read].bytestr()
}

pub fn (mut socket UnixSocket) close() ! {
	if socket.closed {
		return
	}
	if !isnil(socket.connection) {
		socket.connection.close()!
	}
	socket.closed = true
}

pub fn new_unix_server(path string, backlog int) !&UnixServer {
	unix_sockaddr(path)!
	if os.exists(path) {
		return error('unix socket path already exists: ${path}')
	}
	if !os.is_dir(os.dir(path)) {
		return error('unix socket parent directory does not exist: ${os.dir(path)}')
	}
	listener := unix.listen_stream(path, backlog: if backlog > 0 { backlog } else { 128 })!
	return &UnixServer{
		path: path
		listener: listener
	}
}

pub fn (mut server UnixServer) accept_nonblock() !&UnixSocket {
	if server.closed || isnil(server.listener) {
		return error('unix server is closed')
	}
	// net.unix exposes readiness deadlines separately from accept. A very short
	// readiness probe preserves Ruby's accept_nonblock/IO::WaitReadable contract
	// without risking a blocking accept when no client is queued.
	server.listener.set_accept_timeout(time.millisecond)
	server.listener.wait_for_accept() or {
		server.listener.set_accept_timeout(time.infinite)
		return SocketWaitReadableError{
			path: server.path
		}
	}
	server.listener.set_accept_timeout(time.infinite)
	connection := server.listener.accept()!
	return &UnixSocket{
		path: server.path
		role: .accepted
		connection: connection
	}
}

pub fn (mut server UnixServer) close() ! {
	if server.closed {
		return
	}
	if !isnil(server.listener) {
		server.listener.close()!
	}
	server.closed = true
}

pub fn unix_socket_state(socket &UnixSocket) UnixSocketState {
	return UnixSocketState{
		path: socket.path
		role: socket.role
		open: !socket.closed
		connected: !socket.closed && !isnil(socket.connection)
	}
}

pub fn unix_server_state(server &UnixServer) UnixSocketState {
	return UnixSocketState{
		path: server.path
		role: .server
		open: !server.closed
		listening: !server.closed && !isnil(server.listener)
	}
}

pub fn unix_socket_state_value(state UnixSocketState) ruby.Value {
	return ruby.structured_value('Utils::UNIXSocketState', state.path, {
		'path':      state.path
		'role':      state.role.str()
		'open':      state.open.str()
		'connected': state.connected.str()
		'listening': state.listening.str()
	})
}

pub fn unix_socket_state_from_value(value ruby.Value) UnixSocketState {
	role := match value.attributes['role'] or { '' } {
		'accepted' { UnixSocketRole.accepted }
		'server' { UnixSocketRole.server }
		else { UnixSocketRole.client }
	}
	return UnixSocketState{
		path: value.attributes['path'] or { value.as_string() }
		role: role
		open: (value.attributes['open'] or { 'false' }) == 'true'
		connected: (value.attributes['connected'] or { 'false' }) == 'true'
		listening: (value.attributes['listening'] or { 'false' }) == 'true'
	}
}

pub fn unix_sockaddr_value(address UnixSocketAddress) ruby.Value {
	return ruby.structured_value('Socket::SockaddrUn', address.path, {
		'path':   address.path
		'packed': address.packed.hex()
	})
}

// Ruby method `self.open(path, &_block)` at line 17.
pub fn ruby_socket_l17_d1_self_open(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'expected unix socket path')
	}
	mut socket := connect_unix_socket(args[0].as_string()) or {
		return ruby.object_value('SocketError', err.msg())
	}
	state := unix_socket_state(socket)
	socket.close() or {}
	return unix_socket_state_value(state)
}

// Ruby method `self.sockaddr_un(path)` at line 26.
pub fn ruby_socket_l26_d2_self_sockaddr_un(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'expected unix socket path')
	}
	address := unix_sockaddr(args[0].as_string()) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return unix_sockaddr_value(address)
}

// Ruby attr_reader `attr_reader :path` at line 38.
pub fn ruby_socket_l38_d3_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value('')
	}
	return ruby.string_value(args[0].attributes['path'] or { args[0].as_string() })
}

// Ruby method `initialize(path)` at line 41.
pub fn ruby_socket_l41_d4_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'expected unix socket path')
	}
	mut server := new_unix_server(args[0].as_string(), 128) or {
		return ruby.object_value('SocketError', err.msg())
	}
	state := unix_server_state(server)
	server.close() or {}
	return unix_socket_state_value(state)
}

// Ruby method `accept_nonblock` at line 49.
pub fn ruby_socket_l49_d5_accept_nonblock(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('IO::WaitReadable', 'Resource temporarily unavailable')
	}
	state := unix_socket_state_from_value(args[0])
	if !state.listening {
		return ruby.object_value('IO::WaitReadable', 'Resource temporarily unavailable while accepting ${state.path}')
	}
	return unix_socket_state_value(UnixSocketState{
		path: state.path
		role: .accepted
		open: true
		connected: true
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "socket"
// 5:
// 6: module Utils
// 7:   # Wrapper around UNIXSocket to allow > 104 characters on macOS.
// 8:   module UNIXSocketExt
// 9:     extend T::Generic
// 10:
// 11:     sig {
// 12:       type_parameters(:U).params(
// 13:         path:   String,
// 14:         _block: T.proc.params(arg0: UNIXSocket).returns(T.type_parameter(:U)),
// 15:       ).returns(T.type_parameter(:U))
// 16:     }
// 17:     def self.open(path, &_block)
// 18:       socket = Socket.new(:UNIX, :STREAM)
// 19:       socket.connect(sockaddr_un(path))
// 20:       unix_socket = UNIXSocket.for_fd(socket.fileno)
// 21:       socket.autoclose = false # Transfer autoclose responsibility to UNIXSocket
// 22:       yield unix_socket
// 23:     end
// 24:
// 25:     sig { params(path: String).returns(String) }
// 26:     def self.sockaddr_un(path)
// 27:       Socket.sockaddr_un(path)
// 28:     end
// 29:   end
// 30:
// 31:   # Wrapper around UNIXServer to allow > 104 characters on macOS.
// 32:   class UNIXServerExt < Socket
// 33:     extend T::Generic
// 34:
// 35:     Elem = type_member(:out) { { fixed: String } }
// 36:
// 37:     sig { returns(String) }
// 38:     attr_reader :path
// 39:
// 40:     sig { params(path: String).void }
// 41:     def initialize(path)
// 42:       super(:UNIX, :STREAM)
// 43:       bind(UNIXSocketExt.sockaddr_un(path))
// 44:       listen(Socket::SOMAXCONN)
// 45:       @path = path
// 46:     end
// 47:
// 48:     sig { returns(UNIXSocket) }
// 49:     def accept_nonblock
// 50:       socket, = super
// 51:       socket.autoclose = false # Transfer autoclose responsibility to UNIXSocket
// 52:       UNIXSocket.for_fd(socket.fileno)
// 53:     end
// 54:   end
// 55: end
// 56:
// 57: require "extend/os/utils/socket"
