module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/search_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "finds formula in search", :integration_test, :no_api do` at line 10.
pub fn ruby_search_spec_l10_d1_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "shows missing cask descriptions in description searches" do` at line 18.
pub fn ruby_search_spec_l18_d2_shows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shows', ...args)
}

// Ruby let `let(:search_cmd) { described_class.new([""]) }` at line 26.
pub fn ruby_search_spec_l26_d3_search_cmd(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('search_cmd', ...args)
}

// Ruby it `it "skips" do` at line 31.
pub fn ruby_search_spec_l31_d4_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "skips a regex query" do` at line 40.
pub fn ruby_search_spec_l40_d5_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "skips if there is not a reason" do` at line 45.
pub fn ruby_search_spec_l45_d6_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "prints additional output if `found_matches` is true" do` at line 51.
pub fn ruby_search_spec_l51_d7_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "only prints reason if `found_matches` is false" do` at line 57.
pub fn ruby_search_spec_l57_d8_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('only', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/search"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::SearchCmd do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "finds formula in search", :integration_test, :no_api do
// 11:     setup_test_formula "testball"
// 12:
// 13:     expect { brew "search", "testball" }
// 14:       .to output(/testball/).to_stdout
// 15:       .and be_a_success
// 16:   end
// 17:
// 18:   it "shows missing cask descriptions in description searches" do
// 19:     expect(Homebrew::Search).to receive(:search_descriptions)
// 20:       .with("testball", anything, show_missing: true)
// 21:
// 22:     described_class.new(["--desc", "testball"]).run
// 23:   end
// 24:
// 25:   describe "::print_missing_formula_help" do
// 26:     let(:search_cmd) { described_class.new([""]) }
// 27:
// 28:     context "when $stdout is not a TTY" do
// 29:       before { allow_any_instance_of(StringIO).to receive(:tty?).and_return(false) }
// 30:
// 31:       it "skips" do
// 32:         expect { search_cmd.print_missing_formula_help("formula", false) }
// 33:           .not_to output.to_stdout
// 34:       end
// 35:     end
// 36:
// 37:     context "when $stdout is a TTY" do
// 38:       before { allow_any_instance_of(StringIO).to receive(:tty?).and_return(true) }
// 39:
// 40:       it "skips a regex query" do
// 41:         expect { search_cmd.print_missing_formula_help("/formula/", false) }
// 42:           .not_to output.to_stdout
// 43:       end
// 44:
// 45:       it "skips if there is not a reason" do
// 46:         allow(Homebrew::MissingFormula).to receive(:reason).and_return(nil)
// 47:         expect { search_cmd.print_missing_formula_help("formula", false) }
// 48:           .not_to output.to_stdout
// 49:       end
// 50:
// 51:       it "prints additional output if `found_matches` is true" do
// 52:         allow(Homebrew::MissingFormula).to receive(:reason).and_return("Reason")
// 53:         expect { search_cmd.print_missing_formula_help("formula", true) }
// 54:           .to output("\nIf you meant \"formula\" specifically:\nReason\n").to_stdout
// 55:       end
// 56:
// 57:       it "only prints reason if `found_matches` is false" do
// 58:         allow(Homebrew::MissingFormula).to receive(:reason).and_return("Reason")
// 59:         expect { search_cmd.print_missing_formula_help("formula", false) }
// 60:           .to output("Reason\n").to_stdout
// 61:       end
// 62:     end
// 63:   end
// 64: end
