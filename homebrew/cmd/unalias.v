module cmd

import homebrew.aliases

// Translated from Homebrew/brew `cmd/unalias.rb`.
pub fn run_unalias(config aliases.AliasConfig, names []string) ! {
	aliases.init_aliases(config)!
	for name in names {
		aliases.remove_alias(config, name)!
	}
}
