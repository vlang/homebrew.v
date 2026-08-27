module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/custom-external-command_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "is supported" do` at line 5.
pub fn ruby_custom_external_command_spec_l5_d1_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe "brew custom-external-command", :integration_test, type: :system do
// 5:   it "is supported" do
// 6:     mktmpdir do |path|
// 7:       cmd = "custom-external-command-#{rand}"
// 8:       file = path/"brew-#{cmd}"
// 9:
// 10:       file.write <<~SH
// 11:         #!/bin/sh
// 12:         echo 'I am #{cmd}.'
// 13:       SH
// 14:       FileUtils.chmod "+x", file
// 15:
// 16:       expect { brew cmd, "PATH" => "#{path}#{File::PATH_SEPARATOR}#{ENV.fetch("PATH")}" }
// 17:         .to output("I am #{cmd}.\n").to_stdout
// 18:         .and not_to_output.to_stderr
// 19:         .and be_a_success
// 20:     end
// 21:   end
// 22: end
