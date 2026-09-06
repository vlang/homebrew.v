module subcommand

// Translated from Homebrew/brew `bundle/subcommand/env.rb`.

pub struct BundleExecSubcommandOptions {
pub:
	check      bool
	no_secrets bool
	services   bool
	global     bool
	file       string
}

pub struct BundleExecSubcommandInvocation {
pub:
	command string
	args    []string
	options BundleExecSubcommandOptions
}

pub fn run_env_subcommand(options BundleExecSubcommandOptions) BundleExecSubcommandInvocation {
	return BundleExecSubcommandInvocation{
		command: 'env'
		args: ['env']
		options: options
	}
}
