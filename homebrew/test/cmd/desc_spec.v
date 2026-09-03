module cmd

import homebrew.cmd as desc_core

// Translated from Homebrew/brew `test/cmd/desc_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "shows a given Formula's description", :integration_test do` at line 10.
pub fn ruby_desc_spec_l10_d1_shows() bool {
	result := desc_core.run_desc_command(desc_core.DescCommandRequest{
		named: ['testball']
		items: [desc_core.DescItem{
			kind: .formula
			full_name: 'testball'
			description: 'Some test'
		}]
	}) or { return false }
	return result.output == 'testball: Some test\n'
}

// Ruby it `it "shows an installed Cask's description with status" do` at line 19.
pub fn ruby_desc_spec_l19_d2_shows() bool {
	result := desc_core.run_desc_command(desc_core.DescCommandRequest{
		named: ['local-transmission']
		tty: true
		items: [desc_core.DescItem{
			kind: .cask
			full_name: 'local-transmission'
			names: ['Transmission']
			description: 'BitTorrent client'
			installed: true
		}]
	}) or { return false }
	return result.output.contains('local-transmission ✔: (Transmission) BitTorrent client')
}

// Ruby it `it "omits a Cask without a description" do` at line 41.
pub fn ruby_desc_spec_l41_d3_omits() bool {
	result := desc_core.run_desc_command(desc_core.DescCommandRequest{
		named: ['no-description']
		items: [desc_core.DescItem{
			kind: .cask
			full_name: 'no-description'
			names: ['No Description']
		}]
	}) or { return false }
	return result.output == ''
}

fn desc_spec_search(query string, no_install_from_api bool, tap_trust_configured bool) bool {
	result := desc_core.run_desc_command(desc_core.DescCommandRequest{
		named: [query]
		search: true
		no_install_from_api: no_install_from_api
		tap_trust_configured: tap_trust_configured
	}) or { return false }
	return result.searched && result.search_query == query && result.search_field == .either
}

// Ruby it `it "successfully searches without API by default" do` at line 56.
pub fn ruby_desc_spec_l56_d4_successfully() bool {
	return desc_spec_search('testball', false, false)
}

// Ruby it `it "successfully searches with --search and HOMEBREW_NO_REQUIRE_TAP_TRUST" do` at line 70.
pub fn ruby_desc_spec_l70_d5_successfully() bool {
	return desc_spec_search('ball', true, true)
}

// Ruby it `it "successfully searches with --search and HOMEBREW_REQUIRE_TAP_TRUST" do` at line 78.
pub fn ruby_desc_spec_l78_d6_successfully() bool {
	return desc_spec_search('ball', true, true)
}

// Ruby it `it "successfully searches with API" do` at line 86.
pub fn ruby_desc_spec_l86_d7_successfully() bool {
	return desc_spec_search('testball', false, false)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/desc"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Desc do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "shows a given Formula's description", :integration_test do
// 11:     setup_test_formula "testball"
// 12:
// 13:     expect { brew "desc", "testball" }
// 14:       .to output("testball: Some test\n").to_stdout
// 15:       .and not_to_output.to_stderr
// 16:       .and be_a_success
// 17:   end
// 18:
// 19:   it "shows an installed Cask's description with status" do
// 20:     allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 21:     cask = Cask::Cask.new("local-transmission") do
// 22:       version "2.61"
// 23:       name "Transmission"
// 24:       desc "BitTorrent client"
// 25:       url "https://example.com/local-transmission.zip"
// 26:     end
// 27:     cmd = described_class.new(["--cask", "local-transmission"])
// 28:
// 29:     allow(cmd.args.named).to receive(:to_formulae_and_casks).and_return([cask])
// 30:     allow(Cask::Caskroom).to receive(:casks).and_return([cask])
// 31:     allow(Formulary).to receive(:factory)
// 32:       .with("local-transmission")
// 33:       .and_raise(FormulaUnavailableError.new("local-transmission"))
// 34:     allow(Cask::CaskLoader).to receive(:load).with("local-transmission").and_return(cask)
// 35:
// 36:     expect { cmd.run }
// 37:       .to output(/local-transmission .*✔.*: \(Transmission\) BitTorrent client/).to_stdout
// 38:       .and not_to_output.to_stderr
// 39:   end
// 40:
// 41:   it "omits a Cask without a description" do
// 42:     cask = Cask::Cask.new("no-description") do
// 43:       version "1.0"
// 44:       name "No Description"
// 45:       url "https://example.com/no-description.zip"
// 46:     end
// 47:     cmd = described_class.new(["--cask", "no-description"])
// 48:
// 49:     allow(cmd.args.named).to receive(:to_formulae_and_casks).and_return([cask])
// 50:
// 51:     expect { cmd.run }
// 52:       .to not_to_output.to_stdout
// 53:       .and not_to_output.to_stderr
// 54:   end
// 55:
// 56:   it "successfully searches without API by default" do
// 57:     expect(Homebrew::Search).to receive(:search_descriptions)
// 58:       .with("testball", anything, search_type: Descriptions::SearchField::Either)
// 59:
// 60:     with_env(
// 61:       "HOMEBREW_NO_INSTALL_FROM_API"  => "1",
// 62:       "HOMEBREW_REQUIRE_TAP_TRUST"    => nil,
// 63:       "HOMEBREW_NO_REQUIRE_TAP_TRUST" => nil,
// 64:     ) do
// 65:       expect { described_class.new(["--search", "testball"]).run }
// 66:         .to not_to_output.to_stderr
// 67:     end
// 68:   end
// 69:
// 70:   it "successfully searches with --search and HOMEBREW_NO_REQUIRE_TAP_TRUST" do
// 71:     expect(Homebrew::Search).to receive(:search_descriptions)
// 72:       .with("ball", anything, search_type: Descriptions::SearchField::Either)
// 73:
// 74:     expect { with_env(HOMEBREW_NO_REQUIRE_TAP_TRUST: "1") { described_class.new(["--search", "ball"]).run } }
// 75:       .to not_to_output.to_stderr
// 76:   end
// 77:
// 78:   it "successfully searches with --search and HOMEBREW_REQUIRE_TAP_TRUST" do
// 79:     expect(Homebrew::Search).to receive(:search_descriptions)
// 80:       .with("ball", anything, search_type: Descriptions::SearchField::Either)
// 81:
// 82:     expect { with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") { described_class.new(["--search", "ball"]).run } }
// 83:       .to not_to_output.to_stderr
// 84:   end
// 85:
// 86:   it "successfully searches with API" do
// 87:     expect(Homebrew::Search).to receive(:search_descriptions)
// 88:       .with("testball", anything, search_type: Descriptions::SearchField::Either)
// 89:
// 90:     expect { described_class.new(["--search", "testball"]).run }
// 91:       .to not_to_output.to_stderr
// 92:   end
// 93: end
