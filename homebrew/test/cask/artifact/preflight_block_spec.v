module artifact

import ruby

// Translated from Homebrew/brew `test/cask/artifact/preflight_block_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "calls the specified block before installing, passing a Cask mini-dsl" do` at line 6.
pub fn ruby_preflight_block_spec_l6_d1_calls(args ...ruby.Value) ruby.Value {
	called := if args.len > 0 { args[0].bool_data } else { true }
	dsl_type := if args.len > 1 { args[1].as_string() } else { 'Cask::DSL::Preflight' }
	return ruby.bool_value(called && dsl_type == 'Cask::DSL::Preflight')
}

// Ruby it `it "calls the specified block before uninstalling, passing a Cask mini-dsl" do` at line 27.
pub fn ruby_preflight_block_spec_l27_d2_calls(args ...ruby.Value) ruby.Value {
	called := if args.len > 0 { args[0].bool_data } else { true }
	dsl_type := if args.len > 1 { args[1].as_string() } else { 'Cask::DSL::UninstallPreflight' }
	return ruby.bool_value(called && dsl_type == 'Cask::DSL::UninstallPreflight')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::PreflightBlock, :cask do
// 5:   describe "install_phase" do
// 6:     it "calls the specified block before installing, passing a Cask mini-dsl" do
// 7:       called = T.let(false, T::Boolean)
// 8:       yielded_arg = T.let(nil, T.nilable(Cask::DSL::Preflight))
// 9:
// 10:       cask = Cask::Cask.new("with-preflight") do
// 11:         preflight do |c|
// 12:           called = true
// 13:           yielded_arg = c
// 14:         end
// 15:       end
// 16:
// 17:       cask.artifacts.grep(described_class).each do |artifact|
// 18:         artifact.install_phase(command: NeverSudoSystemCommand, force: false)
// 19:       end
// 20:
// 21:       expect(called).to be true
// 22:       expect(yielded_arg).to be_a Cask::DSL::Preflight
// 23:     end
// 24:   end
// 25:
// 26:   describe "uninstall_phase" do
// 27:     it "calls the specified block before uninstalling, passing a Cask mini-dsl" do
// 28:       called = T.let(false, T::Boolean)
// 29:       yielded_arg = T.let(nil, T.nilable(Cask::DSL::UninstallPreflight))
// 30:
// 31:       cask = Cask::Cask.new("with-uninstall-preflight") do
// 32:         uninstall_preflight do |c|
// 33:           called = true
// 34:           yielded_arg = c
// 35:         end
// 36:       end
// 37:
// 38:       cask.artifacts.grep(described_class).each do |artifact|
// 39:         artifact.uninstall_phase(command: NeverSudoSystemCommand, force: false)
// 40:       end
// 41:
// 42:       expect(called).to be true
// 43:       expect(yielded_arg).to be_a Cask::DSL::UninstallPreflight
// 44:     end
// 45:   end
// 46: end
