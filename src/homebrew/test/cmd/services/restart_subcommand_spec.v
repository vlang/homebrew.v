module services

import brew_runtime

// Translated from Homebrew/brew `test/cmd/services/restart_subcommand_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "fails with empty list" do` at line 8.
pub fn ruby_restart_subcommand_spec_l8_d1_fails(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fails', ...args)
}

// Ruby it `it "starts if services are not loaded" do` at line 16.
pub fn ruby_restart_subcommand_spec_l16_d2_starts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('starts', ...args)
}

// Ruby it `it "starts if services are loaded with file" do` at line 27.
pub fn ruby_restart_subcommand_spec_l27_d3_starts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('starts', ...args)
}

// Ruby it `it "runs if services are loaded without file" do` at line 39.
pub fn ruby_restart_subcommand_spec_l39_d4_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runs', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/services"
// 5:
// 6: RSpec.describe Homebrew::Cmd::Services::RestartSubcommand do
// 7:   describe "#run" do
// 8:     it "fails with empty list" do
// 9:       expect do
// 10:         described_class.new(Homebrew::Cmd::Services.new(%w[restart testball]).args,
// 11:                             targets: []).run
// 12:       end.to raise_error UsageError,
// 13:                          "Invalid usage: Formula(e) missing, please provide a formula name or use `--all`."
// 14:     end
// 15:
// 16:     it "starts if services are not loaded" do
// 17:       expect(Homebrew::Services::Cli).not_to receive(:run)
// 18:       expect(Homebrew::Services::Cli).not_to receive(:stop)
// 19:       expect(Homebrew::Services::Cli).to receive(:start).once
// 20:       service = instance_double(Homebrew::Services::FormulaWrapper, service_name: "name", loaded?: false)
// 21:       expect do
// 22:         described_class.new(Homebrew::Cmd::Services.new(%w[restart testball]).args,
// 23:                             targets: [service]).run
// 24:       end.not_to raise_error
// 25:     end
// 26:
// 27:     it "starts if services are loaded with file" do
// 28:       expect(Homebrew::Services::Cli).not_to receive(:run)
// 29:       expect(Homebrew::Services::Cli).to receive(:start).once
// 30:       expect(Homebrew::Services::Cli).to receive(:stop).once
// 31:       service = instance_double(Homebrew::Services::FormulaWrapper, service_name: "name", loaded?: true,
// 32: service_file_present?: true)
// 33:       expect do
// 34:         described_class.new(Homebrew::Cmd::Services.new(%w[restart testball]).args,
// 35:                             targets: [service]).run
// 36:       end.not_to raise_error
// 37:     end
// 38:
// 39:     it "runs if services are loaded without file" do
// 40:       expect(Homebrew::Services::Cli).not_to receive(:start)
// 41:       expect(Homebrew::Services::Cli).to receive(:run).once
// 42:       expect(Homebrew::Services::Cli).to receive(:stop).once
// 43:       service = instance_double(Homebrew::Services::FormulaWrapper, service_name: "name", loaded?: true,
// 44: service_file_present?: false)
// 45:       expect do
// 46:         described_class.new(Homebrew::Cmd::Services.new(%w[restart testball]).args,
// 47:                             targets: [service]).run
// 48:       end.not_to raise_error
// 49:     end
// 50:   end
// 51: end
