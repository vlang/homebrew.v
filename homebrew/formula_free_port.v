module homebrew

import brew_runtime
import net

// Translated from Homebrew/brew `formula_free_port.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `free_port` at line 12.
pub fn ruby_formula_free_port_l12_d1_free_port(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(free_port() or { panic(err) })
}

// free_port asks the kernel to bind an ephemeral TCP port, reads the assigned
// port, and closes the listener before returning it.
pub fn free_port() !int {
	mut server := net.listen_tcp(.ip, '127.0.0.1:0')!
	defer {
		server.close() or {}
	}
	return int(server.addr()!.port()!)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "socket"
// 5:
// 6: module Homebrew
// 7:   # Helper function for finding a free port.
// 8:   module FreePort
// 9:     # Returns a free port.
// 10:     # @api public
// 11:     sig { returns(Integer) }
// 12:     def free_port
// 13:       server = TCPServer.new 0
// 14:       _, port, = server.addr
// 15:       server.close
// 16:
// 17:       port
// 18:     end
// 19:   end
// 20: end
