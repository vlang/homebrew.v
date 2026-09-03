module developer

import homebrew.developer.subcommand

// Translated from Homebrew/brew `developer/subcommand.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `dispatch(args)` at line 16.
pub fn ruby_subcommand_l16_d1_dispatch(arguments []string, mut state subcommand.DeveloperState) !string {
	if arguments.len > 1 {
		return error('developer accepts at most one named argument')
	}
	name := if arguments.len == 0 { 'state' } else { arguments[0] }
	return match name {
		'on' { subcommand.ruby_on_l22_d1_run(mut state) }
		'off' { subcommand.ruby_off_l22_d1_run(mut state) }
		'state' { subcommand.ruby_state_l21_d1_run(state) }
		else { error('unknown developer subcommand: ${name}') }
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5: require "cli/parser"
// 6:
// 7: Dir["#{__dir__}/subcommand/*.rb"].each do |subcommand|
// 8:   require "developer/subcommand/#{File.basename(subcommand, ".rb")}"
// 9: end
// 10:
// 11: module Homebrew
// 12:   module Cmd
// 13:     class Developer < Homebrew::AbstractCommand
// 14:       class << self
// 15:         sig { params(args: T.untyped).void }
// 16:         def dispatch(args)
// 17:           subcommand_class = Homebrew::AbstractSubcommand
// 18:                              .subcommands_for(Homebrew::Cmd::Developer)
// 19:                              .find do |candidate|
// 20:             candidate.subcommand_name == args.subcommand
// 21:           end
// 22:           T.must(subcommand_class).new(args).run
// 23:         end
// 24:       end
// 25:     end
// 26:   end
// 27: end
