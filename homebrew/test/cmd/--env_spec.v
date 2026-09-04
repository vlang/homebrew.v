module cmd

import ruby
import homebrew.cmd as cmd_core

// Translated from Homebrew/brew `test/cmd/--env_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints the Homebrew build environment variables in Bash syntax" do` at line 11.
pub fn ruby_env_spec_l11_d1_prints(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 { args[0].as_string() } else { '/opt/homebrew' }
	result := cmd_core.run_env_command(cmd_core.EnvCommandRequest{
		environment: {
			'CMAKE_PREFIX_PATH': path
		}
		requested_shell: 'bash'
	})
	return ruby.bool_value(cmd_core.env_command_output(result) == 'export CMAKE_PREFIX_PATH="${path}"\n')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/--env"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Env do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   describe "--shell=bash", :integration_test do
// 11:     it "prints the Homebrew build environment variables in Bash syntax" do
// 12:       path = [Superenv.bin&.parent, HOMEBREW_PREFIX].compact.join(File::PATH_SEPARATOR)
// 13:       expect { brew "--env", "--shell=bash" }
// 14:         .to output(/export CMAKE_PREFIX_PATH="#{Regexp.quote(path)}"/).to_stdout
// 15:         .and not_to_output.to_stderr
// 16:         .and be_a_success
// 17:     end
// 18:   end
// 19: end
