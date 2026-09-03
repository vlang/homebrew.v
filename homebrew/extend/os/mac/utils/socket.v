module utils

// Translated from Homebrew/brew `extend/os/mac/utils/socket.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn sockaddr_un(path string) ![]u8 {
	path_bytes := path.bytes()
	if path_bytes.len > 252 {
		return error('too long unix socket path (${path_bytes.len} bytes given but 252 bytes max)')
	}
	mut packed := []u8{cap: path_bytes.len + 3}
	packed << u8(path_bytes.len + 3)
	packed << u8(1)
	packed << path_bytes
	packed << u8(0)
	return packed
}

// Ruby method `sockaddr_un(path)` at line 16.
pub fn ruby_socket_l16_d1_sockaddr_un(path string) ![]u8 {
	return sockaddr_un(path)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "socket"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     # Wrapper around UNIXSocket to allow > 104 characters on macOS.
// 9:     module UNIXSocketExt
// 10:       module ClassMethods
// 11:         extend T::Helpers
// 12:
// 13:         requires_ancestor { Kernel }
// 14:
// 15:         sig { params(path: String).returns(String) }
// 16:         def sockaddr_un(path)
// 17:           if path.bytesize > 252 # largest size that can fit into a single-byte length
// 18:             raise ArgumentError, "too long unix socket path (#{path.bytesize} bytes given but 252 bytes max)"
// 19:           end
// 20:
// 21:           [
// 22:             path.bytesize + 3, # = length (1 byte) + family (1 byte) + path (variable) + null terminator (1 byte)
// 23:             1, # AF_UNIX
// 24:             path,
// 25:           ].pack("CCZ*")
// 26:         end
// 27:       end
// 28:     end
// 29:   end
// 30: end
// 31:
// 32: Utils::UNIXSocketExt.singleton_class.prepend(OS::Mac::UNIXSocketExt::ClassMethods)
