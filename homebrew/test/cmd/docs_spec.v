module cmd

import homebrew.cmd as brew_cmd

// Translated from Homebrew/brew `test/cmd/docs_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "opens the docs page", :integration_test do` at line 10.
pub fn ruby_docs_spec_l10_d1_opens() bool {
	plan := brew_cmd.docs_browser_plan('echo', '', '')
	return plan.available && plan.command.program == 'echo' && plan.command.arguments == [
		brew_cmd.homebrew_docs_url,
	]
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/docs"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Docs do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "opens the docs page", :integration_test do
// 11:     expect { brew "docs", "HOMEBREW_BROWSER" => "echo" }
// 12:       .to output("https://docs.brew.sh\n").to_stdout
// 13:       .and not_to_output.to_stderr
// 14:       .and be_a_success
// 15:   end
// 16: end
