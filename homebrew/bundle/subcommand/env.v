module subcommand

import ruby

// Translated from Homebrew/brew `bundle/subcommand/env.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 28.
pub fn ruby_env_l28_d1_run(args ...ruby.Value) ruby.Value {
	options := BundleExecSubcommandOptions{
		check: if args.len > 0 { args[0].as_bool() or { false } } else { false }
		no_secrets: if args.len > 1 { args[1].as_bool() or { false } } else { false }
		global: if args.len > 2 { args[2].as_bool() or { false } } else { false }
		file: if args.len > 3 { args[3].as_string() } else { '' }
	}
	return bundle_exec_invocation_value(run_env_subcommand(options))
}

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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class Bundle < Homebrew::AbstractCommand
// 9:       class EnvSubcommand < Homebrew::AbstractSubcommand
// 10:         subcommand_args do
// 11:           usage_banner <<~EOS
// 12:             `brew bundle env` [`--check`] [`--no-secrets`]:
// 13:             Print the environment variables that would be set in a `brew bundle exec` environment.
// 14:           EOS
// 15:           named_args :none
// 16:           switch "--install",
// 17:                  description: "Run `install` before printing the environment."
// 18:           switch "--check",
// 19:                  description: "Check that all dependencies in the Brewfile are installed before " \
// 20:                               "printing the environment.",
// 21:                  env:         :bundle_check
// 22:           switch "--no-secrets",
// 23:                  description: "Attempt to remove secrets from the environment before printing it.",
// 24:                  env:         :bundle_no_secrets
// 25:         end
// 26:
// 27:         sig { override.void }
// 28:         def run
// 29:           ExecSubcommand.run_command("env", args:, context:)
// 30:         end
// 31:       end
// 32:     end
// 33:   end
// 34: end
