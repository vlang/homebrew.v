module homebrew

import net

// Translated from Homebrew/brew `formula_free_port.rb`.

// free_port asks the kernel to bind an ephemeral TCP port, reads the assigned
// port, and closes the listener before returning it.
pub fn free_port() !int {
	mut server := net.listen_tcp(.ip, '127.0.0.1:0')!
	defer {
		server.close() or {}
	}
	return int(server.addr()!.port()!)
}
