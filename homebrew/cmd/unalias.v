module cmd

import homebrew.aliases

// Translated from Homebrew/brew `cmd/unalias.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn run_unalias(config aliases.AliasConfig, names []string) ! {
	aliases.init_aliases(config)!
	for name in names {
		aliases.remove_alias(config, name)!
	}
}

// Ruby method `run` at line 19.
pub fn ruby_unalias_l19_d1_run(config aliases.AliasConfig, names []string) ! {
	run_unalias(config, names)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "aliases/aliases"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Unalias < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Remove aliases.
// 13:         EOS
// 14:
// 15:         named_args :alias, min: 1
// 16:       end
// 17:
// 18:       sig { override.void }
// 19:       def run
// 20:         Aliases.init
// 21:         args.named.each { |a| Aliases.remove a }
// 22:       end
// 23:     end
// 24:   end
// 25: end
