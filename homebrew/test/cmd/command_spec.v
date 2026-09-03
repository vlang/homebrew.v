module cmd

import homebrew.cmd as brew_cmd

// Translated from Homebrew/brew `test/cmd/command_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns the file for a given command", :integration_test do` at line 10.
pub fn ruby_command_spec_l10_d1_returns(library_path string) bool {
	paths := brew_cmd.command_paths(['info'], fn [library_path] (name string) ?string {
		return '${library_path}/cmd/${name}.rb'
	}) or { return false }
	return paths == ['${library_path}/cmd/info.rb']
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "cmd/command"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Command do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "returns the file for a given command", :integration_test do
// 11:     expect { brew "command", "info" }
// 12:       .to output(%r{#{Regexp.escape(HOMEBREW_LIBRARY_PATH)}/cmd/info.rb}o).to_stdout
// 13:       .and be_a_success
// 14:   end
// 15: end
