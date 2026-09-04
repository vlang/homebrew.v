module tab

import ruby
import homebrew
import json2

// Translated from Homebrew/brew `tab/tab.rb`.

fn tab_receiver(args []ruby.Value, method string) homebrew.Tab {
	if args.len == 0 { panic('Tab#${method} requires a receiver') }
	return homebrew.tab_from_boundary(args[0])
}
