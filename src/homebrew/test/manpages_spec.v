module test

import brew_runtime

// Translated from Homebrew/brew `test/manpages_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `subcommand_parser` at line 9.
pub fn ruby_manpages_spec_l9_d1_subcommand_parser(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subcommand_parser', ...args)
}

// Ruby it `it "lists options under the root command and matching subcommands", :aggregate_failures do` at line 35.
pub fn ruby_manpages_spec_l35_d2_lists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lists', ...args)
}

// Ruby it `it "does not include commands hidden from the manpage" do` at line 51.
pub fn ruby_manpages_spec_l51_d3_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "manpages"
// 5:
// 6: RSpec.describe Homebrew::Manpages do
// 7:   before { stub_const("Cmd", Class.new(Homebrew::AbstractCommand)) }
// 8:
// 9:   def subcommand_parser
// 10:     Homebrew::CLI::Parser.new(Cmd) do
// 11:       usage_banner "`test` [<subcommand>]"
// 12:       description "Test command."
// 13:       switch "--global"
// 14:
// 15:       subcommand "install", default: true do
// 16:         usage_banner <<~EOS
// 17:           `test install`:
// 18:           Install dependencies.
// 19:         EOS
// 20:         switch "--force"
// 21:         named_args :none
// 22:       end
// 23:
// 24:       subcommand "info" do
// 25:         usage_banner <<~EOS
// 26:           `test info` <service>:
// 27:           Show service information.
// 28:         EOS
// 29:         switch "--json"
// 30:         named_args :service, min: 1
// 31:       end
// 32:     end
// 33:   end
// 34:
// 35:   it "lists options under the root command and matching subcommands", :aggregate_failures do
// 36:     root_section, install_and_info_sections = described_class
// 37:                                               .cmd_parser_manpage_lines(subcommand_parser)
// 38:                                               .join
// 39:                                               .split("`test install`:")
// 40:     install_section, info_section = install_and_info_sections.split("`test info` <service>:")
// 41:
// 42:     expect(root_section).to include("`--global`")
// 43:     expect(root_section).not_to include("`--force`")
// 44:     expect(root_section).not_to include("`--json`")
// 45:     expect(install_section).to include("`--force`")
// 46:     expect(install_section).not_to include("`--json`")
// 47:     expect(info_section).to include("`--json`")
// 48:     expect(info_section).not_to include("`--force`")
// 49:   end
// 50:
// 51:   it "does not include commands hidden from the manpage" do
// 52:     hidden_commands = %w[
// 53:       dispatch-build-bottle
// 54:       formula-analytics
// 55:       generate-analytics-api
// 56:       generate-cask-api
// 57:       generate-formula-api
// 58:       generate-internal-api
// 59:       pr-automerge
// 60:       pr-publish
// 61:       pr-pull
// 62:       pr-upload
// 63:       release
// 64:       update-license-data
// 65:       update-maintainers
// 66:       update-sponsors
// 67:     ]
// 68:
// 69:     manpage = described_class.generate_cmd_manpages(
// 70:       hidden_commands.map { |command| Commands::HOMEBREW_DEV_CMD_PATH/"#{command}.rb" },
// 71:     )
// 72:
// 73:     expect(manpage).not_to include(*hidden_commands)
// 74:   end
// 75: end
