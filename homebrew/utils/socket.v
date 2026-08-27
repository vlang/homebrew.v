module utils

import brew_runtime

// Translated from Homebrew/brew `utils/socket.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.open(path, &_block)` at line 17.
pub fn ruby_socket_l17_d1_self_open(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.open', ...args)
}

// Ruby method `self.sockaddr_un(path)` at line 26.
pub fn ruby_socket_l26_d2_self_sockaddr_un(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sockaddr_un', ...args)
}

// Ruby attr_reader `attr_reader :path` at line 38.
pub fn ruby_socket_l38_d3_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby method `initialize(path)` at line 41.
pub fn ruby_socket_l41_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `accept_nonblock` at line 49.
pub fn ruby_socket_l49_d5_accept_nonblock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accept_nonblock', ...args)
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
