module rubocops

import brew_runtime

// Translated from Homebrew/brew `test/rubocops/exec_shell_metacharacters_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:cop) { described_class.new }` at line 7.
pub fn ruby_exec_shell_metacharacters_spec_l7_d1_cop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cop', ...args)
}

// Ruby it `it "reports aan offense when output piping is used" do` at line 10.
pub fn ruby_exec_shell_metacharacters_spec_l10_d2_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "reports no offenses when no metacharacters are used" do` at line 19.
pub fn ruby_exec_shell_metacharacters_spec_l19_d3_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shell_commands"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::ExecShellMetacharacters do
// 7:   subject(:cop) { described_class.new }
// 8:
// 9:   context "when auditing exec calls" do
// 10:     it "reports aan offense when output piping is used" do
// 11:       expect_offense(<<~RUBY)
// 12:         fork do
// 13:           exec "foo bar > output"
// 14:                ^^^^^^^^^^^^^^^^^^ Homebrew/ExecShellMetacharacters: Don't use shell metacharacters in `exec`. Implement the logic in Ruby instead, using methods like `$stdout.reopen`.
// 15:         end
// 16:       RUBY
// 17:     end
// 18:
// 19:     it "reports no offenses when no metacharacters are used" do
// 20:       expect_no_offenses(<<~RUBY)
// 21:         fork do
// 22:           exec "foo bar"
// 23:         end
// 24:       RUBY
// 25:     end
// 26:   end
// 27: end
