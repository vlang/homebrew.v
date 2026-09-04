module subcommand

import ruby

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

fn bundle_exec_invocation_value(invocation BundleExecSubcommandInvocation) ruby.Value {
	return ruby.structured_value('Bundle::ExecSubcommand::Invocation', invocation.args.join(' '), {
		'command':    invocation.command
		'args':       invocation.args.join('\n')
		'check':      invocation.options.check.str()
		'no_secrets': invocation.options.no_secrets.str()
		'services':   invocation.options.services.str()
		'global':     invocation.options.global.str()
		'file':       invocation.options.file
	})
}
