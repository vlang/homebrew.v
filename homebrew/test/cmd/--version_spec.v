module cmd

import brew_runtime
import homebrew.cmd as brew_cmd

// Translated from Homebrew/brew `test/cmd/--version_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints the Homebrew's version", :integration_test do` at line 5.
pub fn ruby_version_spec_l5_d1_prints(args ...brew_runtime.Value) brew_runtime.Value {
	version := if args.len > 0 {
		args[0].as_string()
	} else {
		brew_runtime.environment_value('HOMEBREW_VERSION')
	}
	lines := brew_cmd.version_lines(brew_cmd.VersionCommandConfig{
		homebrew_version: version
		core_repository: '/path/that/does/not/exist/homebrew-core'
		cask_repository: '/path/that/does/not/exist/homebrew-cask'
	})
	return brew_runtime.bool_value(lines.len == 1 && lines[0] == 'Homebrew ${version}')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe "brew --version", type: :system do
// 5:   it "prints the Homebrew's version", :integration_test do
// 6:     expect { brew_sh "--version" }
// 7:       .to output(/^Homebrew #{Regexp.escape(HOMEBREW_VERSION)}\n/o).to_stdout
// 8:       .and not_to_output.to_stderr
// 9:       .and be_a_success
// 10:   end
// 11: end
