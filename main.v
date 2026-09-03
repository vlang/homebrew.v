module main

import homebrew
import os

fn main() {
	dispatch := homebrew.ruby_brew_file_body(os.args[1..], os.getenv('HOMEBREW_HELP').len > 0)
	match dispatch.action {
		.help {
			println(dispatch.message)
		}
		.usage_error {
			eprintln(dispatch.message)
			exit(1)
		}
		.execute {
			homebrew.execute_dispatch(dispatch) or {
				eprintln('brew.v: ${err}')
				exit(1)
			}
		}
	}
}
