module cmd

import brew_runtime
import homebrew.cmd as production_cmd

// Translated from Homebrew/brew `test/cmd/search_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn search_spec_context() production_cmd.SearchCommandContext {
	return production_cmd.SearchCommandContext{
		formulae: ['testball']
		casks: ['testball-cask']
		description_stdout: '==> Formulae\ntestball: Some test\n\n==> Casks\ntestball-cask: (Test Ball) Some cask test\n'
	}
}

// Ruby it `it "finds formula in search", :integration_test, :no_api do` at line 10.
pub fn ruby_search_spec_l10_d1_finds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := production_cmd.run_search_command(production_cmd.SearchCommandRequest{
		options: production_cmd.SearchCommandOptions{
			named: ['testball']
		}
		context: search_spec_context()
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(!result.failed && result.stdout.contains('testball'))
}

// Ruby it `it "shows missing cask descriptions in description searches" do` at line 18.
pub fn ruby_search_spec_l18_d2_shows(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := production_cmd.run_search_command(production_cmd.SearchCommandRequest{
		options: production_cmd.SearchCommandOptions{
			desc: true
			named: ['testball']
		}
		context: search_spec_context()
	}) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.description_search && result.description_query == 'testball'
		&& !result.description_query_regex && result.description_show_missing
		&& result.description_calls.contains('descriptions:cask:api:eval_all=false'))
}

// Ruby let `let(:search_cmd) { described_class.new([""]) }` at line 26.
pub fn ruby_search_spec_l26_d3_search_cmd(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	input := &production_cmd.SearchCommandInput{
		request: production_cmd.SearchCommandRequest{
			options: production_cmd.SearchCommandOptions{
				named: ['']
			}
		}
	}
	return production_cmd.search_command_input_boundary(input)
}

// Ruby it `it "skips" do` at line 31.
pub fn ruby_search_spec_l31_d4_skips(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(production_cmd.search_missing_formula_help('formula', false, false, 'Reason') == '')
}

// Ruby it `it "skips a regex query" do` at line 40.
pub fn ruby_search_spec_l40_d5_skips(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(production_cmd.search_missing_formula_help('/formula/', false, true, 'Reason') == '')
}

// Ruby it `it "skips if there is not a reason" do` at line 45.
pub fn ruby_search_spec_l45_d6_skips(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(production_cmd.search_missing_formula_help('formula', false, true, none) == '')
}

// Ruby it `it "prints additional output if `found_matches` is true" do` at line 51.
pub fn ruby_search_spec_l51_d7_prints(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(production_cmd.search_missing_formula_help('formula', true, true, 'Reason') == '\nIf you meant "formula" specifically:\nReason\n')
}

// Ruby it `it "only prints reason if `found_matches` is false" do` at line 57.
pub fn ruby_search_spec_l57_d8_only(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(production_cmd.search_missing_formula_help('formula', false, true, 'Reason') == 'Reason\n')
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
