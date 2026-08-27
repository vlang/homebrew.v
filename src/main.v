module main

import brew_runtime
import os

fn main() {
	brew_runtime.exec_compatibility_backend(os.args[1..]) or {
		eprintln('brew.v: ${err}')
		exit(1)
	}
}
