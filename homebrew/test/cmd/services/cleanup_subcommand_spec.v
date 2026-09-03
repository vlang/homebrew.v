module services

import brew_runtime
import homebrew.services.subcommand as service_subcommand

// Translated from Homebrew/brew `test/cmd/services/cleanup_subcommand_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "root - prints on empty cleanup" do` at line 10.
pub fn ruby_cleanup_subcommand_spec_l10_d1_root(args ...brew_runtime.Value) brew_runtime.Value {
	result := service_subcommand.service_cleanup(service_subcommand.ServiceSubcommandRequest{
		root: true
	})
	return brew_runtime.bool_value(result.output == 'All root services OK, nothing cleaned...\n')
}

// Ruby it `it "user - prints on empty cleanup" do` at line 20.
pub fn ruby_cleanup_subcommand_spec_l20_d2_user(args ...brew_runtime.Value) brew_runtime.Value {
	result := service_subcommand.service_cleanup(service_subcommand.ServiceSubcommandRequest{})
	return brew_runtime.bool_value(result.output == 'All user-space services OK, nothing cleaned...\n')
}

// Ruby it `it "prints nothing on cleanup" do` at line 30.
pub fn ruby_cleanup_subcommand_spec_l30_d3_prints(args ...brew_runtime.Value) brew_runtime.Value {
	result := service_subcommand.service_cleanup(service_subcommand.ServiceSubcommandRequest{
		orphaned: ['a']
		unused: ['b']
	})
	return brew_runtime.bool_value(result.output == '' && result.cleaned == ['a', 'b'])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "services/subcommand/cleanup"
// 5: require "services/system"
// 6: require "services/cli"
// 7:
// 8: RSpec.describe Homebrew::Cmd::Services::CleanupSubcommand do
// 9:   describe "#run" do
// 10:     it "root - prints on empty cleanup" do
// 11:       expect(Homebrew::Services::System).to receive(:root?).once.and_return(true)
// 12:       expect(Homebrew::Services::Cli).to receive(:kill_orphaned_services).once.and_return([])
// 13:       expect(Homebrew::Services::Cli).to receive(:remove_unused_service_files).once.and_return([])
// 14:
// 15:       expect do
// 16:         described_class.new(nil).run
// 17:       end.to output("All root services OK, nothing cleaned...\n").to_stdout
// 18:     end
// 19:
// 20:     it "user - prints on empty cleanup" do
// 21:       expect(Homebrew::Services::System).to receive(:root?).once.and_return(false)
// 22:       expect(Homebrew::Services::Cli).to receive(:kill_orphaned_services).once.and_return([])
// 23:       expect(Homebrew::Services::Cli).to receive(:remove_unused_service_files).once.and_return([])
// 24:
// 25:       expect do
// 26:         described_class.new(nil).run
// 27:       end.to output("All user-space services OK, nothing cleaned...\n").to_stdout
// 28:     end
// 29:
// 30:     it "prints nothing on cleanup" do
// 31:       expect(Homebrew::Services::System).not_to receive(:root?)
// 32:       expect(Homebrew::Services::Cli).to receive(:kill_orphaned_services).once.and_return(["a"])
// 33:       expect(Homebrew::Services::Cli).to receive(:remove_unused_service_files).once.and_return(["b"])
// 34:
// 35:       expect do
// 36:         described_class.new(nil).run
// 37:       end.not_to output("All user-space services OK, nothing cleaned...\n").to_stdout
// 38:     end
// 39:   end
// 40: end
