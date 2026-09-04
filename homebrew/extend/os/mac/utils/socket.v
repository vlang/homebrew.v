module utils

// Translated from Homebrew/brew `extend/os/mac/utils/socket.rb`.
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
