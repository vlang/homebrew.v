module dev_cmd

import ruby

// Translated from Homebrew/brew `test/dev-cmd/sh_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "runs a shell with the Homebrew environment", :integration_test do` at line 10.
pub fn ruby_sh_spec_l10_d1_runs(args ...ruby.Value) ruby.Value {
	preferred_shell := if args.len > 0 { args[0].as_string() } else { '/usr/bin/true' }
	plan := run_sh_command(ShOptions{
		preferred_shell: preferred_shell
		environment: {
			'PATH': '/usr/bin:/bin'
		}
		homebrew_prefix: '/homebrew'
		homebrew_library_path: '/homebrew/Library/Homebrew'
	})
	notice := plan.environment.notice or { '' }
	return ruby.bool_value(plan.mode == 'interactive' && !plan.safe
		&& notice.contains('Your shell has been configured') && plan.prompt.command != '')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/sh"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Sh do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "runs a shell with the Homebrew environment", :integration_test do
// 11:     expect { brew "sh", "SHELL" => which("true") }
// 12:       .to output(/Your shell has been configured/).to_stdout
// 13:       .and not_to_output.to_stderr
// 14:       .and be_a_success
// 15:   end
// 16: end
