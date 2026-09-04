module subcommand

import ruby

// Translated from Homebrew/brew `bundle/subcommand/sh.rb`.

pub fn run_sh_subcommand(options BundleExecSubcommandOptions) BundleExecSubcommandInvocation {
	return BundleExecSubcommandInvocation{
		command: 'sh'
		args: ['sh']
		options: options
	}
}
