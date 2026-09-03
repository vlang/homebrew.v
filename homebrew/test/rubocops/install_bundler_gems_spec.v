module rubocops

import homebrew.rubocops as install_bundler_gems_core

// Translated from Homebrew/brew `test/rubocops/install_bundler_gems_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "registers an offense and corrects when using `Homebrew.install_bundler_gems!`" do` at line 7.
pub fn ruby_install_bundler_gems_spec_l7_d1_registers() bool {
	source := 'Homebrew.install_bundler_gems!\n'
	offense := install_bundler_gems_core.audit_install_bundler_gems(source, '/tmp/example.rb') or {
		return false
	}
	return offense.begin_pos == 0 && offense.end_pos == 'Homebrew.install_bundler_gems!'.len && offense.message == install_bundler_gems_core.install_bundler_gems_message
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/install_bundler_gems"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::InstallBundlerGems, :config do
// 7:   it "registers an offense and corrects when using `Homebrew.install_bundler_gems!`" do
// 8:     expect_offense(<<~RUBY)
// 9:       Homebrew.install_bundler_gems!
// 10:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Only use `Homebrew.install_bundler_gems!` in dev-cmd.
// 11:     RUBY
// 12:   end
// 13: end
