module utils

import ruby
import homebrew.extend.os.mac.utils as mac_socket_utils
import net.unix
import os
import time

// Translated from Homebrew/brew `utils/socket.rb`.
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

pub type UnixSocketAction = fn (mut socket UnixSocket) !ruby.Value

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
